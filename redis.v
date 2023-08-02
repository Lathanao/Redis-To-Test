module redis

import net
import json
import term
import io

const (
	read_timeout     = 10_000_000_000 // 10s
	label_alias      = 'x' // Alias needed in cypher condition like""x.name='Tom' AND x.age=20"
	max_history_size = 1000
	min_history_size = 500
)

pub struct RedisGrab {
pub mut:
	content string
	table   []RedisGrab
}

pub struct RedisCon {
	port int    = 6379
	host string = '127.0.0.1'
}

pub struct Redis {
mut:
	con       net.TcpConn
	connected bool
	address   string
pub mut:
	db      string
	result  RedisGrab
	history []string
}

pub fn new(s string) ?&Redis {
	mut r := Redis{
		address: RedisCon{}.host.str() + ':' + RedisCon{}.port.str()
		db: s
	}
	r.connect()?
	return &r
}

fn (mut r Redis) connect() ? {
	r.con = net.dial_tcp(r.address) or { panic(err) }
	r.con.set_blocking(true) or { panic(err) }
	r.con.set_read_timeout(read_timeout)
	r.con.peer_addr() or { panic(err) }
	r.connected = true
	eprint(term.green('>>> Redis: Connected on TCP $r.address') + '\n')
	assert r.hello() == true
}

pub fn (mut r Redis) close() {
	r.con.close() or { panic(err) }
	r.connected = false
	eprint(term.rgb(255, 150, 80, '>>> Redis: Closed TCP $r.address') + '\n')
}

// Should that work?
pub fn (mut r Redis) echo() ? {
	mut c := r.con

	eprintln(' peer: ${r.con.peer_addr()?}')
	eprintln('local: ${r.con.addr()?}')
	eprintln('local: ' + c.addr()?.str())
	eprintln(' peer: ' + c.peer_addr()?.str())

	data := 'HELLO\r\n'
	c.write_string(data)?
	result := io.read_all(reader: c)?
	eprintln(result.bytestr())
}

// Query Redis with a already full made query
// Then, need to get answered datas replied on the socket
// So, run a recursive fn on the socket with r.grab()
pub fn (mut r Redis) query(q string) RedisGrab {
	if q.contains("GRAPH.QUERY") {
		return r.rawquery(q)
	}
	return r.rawquery('GRAPH.QUERY ${r.db} \"$q\"')
}

// TODO: Have to detect odd number of double to avoid the socket buggy
// TODO: Have to be sure the query is well formed to avoid the socket buggy
// e.g. query must start at least by something know like GRAPH.QUERY
pub fn (mut r Redis) rawquery(q string) RedisGrab {
	r.con.write_string('$q\r\n') or { panic(err) }

	if r.history.len > max_history_size {
		r.history = r.history[..min_history_size]
	}
	r.history << q
	$if !prod {
		eprintln(term.yellow(q))
	}
	r.result = r.grab()
	return r.result
}

pub fn (mut r Redis) explain() RedisGrab {
	q := r.history[r.history.len -1]
	q.replace('GRAPH.QUERY', 'GRAPH.EXPLAIN')
	r.con.write_string('$q\r\n') or { panic(err) }

	r.history << q
	$if !prod {
		eprintln(term.rgb(255, 150, 80, q))
	}
	r.result = r.grab()
	return r.result
}

pub fn (mut r Redis) profile() RedisGrab {
	q := r.history[r.history.len -1]
	q.replace('GRAPH.QUERY', 'GRAPH.PROFILE')
	r.con.write_string('$q\r\n') or { panic(err) }

	r.history << q
	$if !prod {
		eprintln(term.rgb(255, 150, 80, q))
	}
	r.result = r.grab()
	return r.result
}

// Grab content (e.g.'Hello word') and info (e.g. "$2" or "*9"), on socket
// $ Check for valide content on the socket
// if S-1, so index == -1, so index < 0 mean next row is empty
// * Check for another bunch of new lines is available
// else parse ":" (interger), and "-" (error)
fn (mut r Redis) grab() RedisGrab {

	mut rg := RedisGrab{}
	line := r.con.read_line()
	index := line[1..].int()

	match line[..1] {
		'*' {
			for _ in 0 .. index {
				rg.table << r.grab()
			}
		}
		'$' {
			if index > 0 {
				rg.content = r.con.read_line().trim_space()
			}
		}
		'-' {
			rg.content = line[1..].trim_space()
			eprintln(term.red('>>> RedisGRAPH: ' + rg.content))
		}
		else {
			rg.content = line[1..].trim_space()
		}
	}
	return rg
}

// Format data to insert them during a create query
// Result is close to json, but quote format differ
fn cipher_data_format<T>(t T) string {
	line := remove_json_child_struture(json.encode(t))

	mut ll := ''
	for lll in line.trim('{}').split(',') {
		mut l := lll
		// Avoid to set ID, because ID are set automatically with "WHERE ID(x)=$id"
		if l.contains('"id"') {
			continue
		}
		// Mean the struct contain child struture
		if l.contains_any('[]') {
			continue
		}
		// Mean the struct contain empty string value
		if l.contains('""') {
			continue
		}
		// TODO fix that
		// Mean the struct field is type integer
		// And interget are initialised with 0
		// So, actually, all values == 0 are not recorded
		if l.contains(':0') {
			continue
		}
		l = l.replace_once('"', '')
		l = l.replace_once('"', '')
		l = l.replace_once('"', "'")
		l = l.replace_once('"', "'")

		ll += ', ' + l
	}
	return ll#[2..]
}

// Remove all content in "[]" from jsom, e.g.
// {"name":"Tom","age":20,"child":[{"name":"","age":0,"child":[],"id":1},{"name":"Lea","age":0,"child":[],"id":0}],"id":0}
// will be returned as
// {"name":"Tom","age":20,"child":[],"id":0}
fn remove_json_child_struture(s string) string {
	index_min := s.index('[') or { 0 }
	index_max := s.last_index(']') or { s.len }

	return s[..index_min + 1] + s[index_max..]
}

// Build condition for match query
// Data in struture are used as criteria
// result sould be this form: "x.id=1 AND x.age=20"
fn cipher_data_make_condition<T>(t T) string {
	mut conjonction := ''
	mut condition := ''

	$for field in T.fields {
		$if field.typ is int {
			if t.$(field.name) > 0 {
				condition += conjonction + label_alias + '.$field.name=' + t.$(field.name).str()
				conjonction = ' AND '
			}
		}
		$if field.typ is string {
			condition += conjonction + label_alias + ".$field.name='" + t.$(field.name).str() + "'"
			conjonction = ' AND '
		}
		$if field.typ is bool {
			condition += conjonction + label_alias + '.$field.name=' + t.$(field.name).str()
			conjonction = ' AND '
		}
		$if field.typ is f32 {
			condition += conjonction + label_alias + '.$field.name=' + t.$(field.name).str()
			conjonction = ' AND '
		}
	}
	return condition
}

// Format struct fields to string,
// Must be compliant with format required in cypher
// e.g.: name="TOM", age=24
fn cipher_data_make_update<T>(t T) string {
	mut conjonction := ''
	mut condition := ''

	$for field in T.fields {
		$if field.typ is int {
			if t.$(field.name) > 0 {
				condition += conjonction + label_alias + '.$field.name=' + t.$(field.name).str()
				conjonction = ', '
			}
		}
		$if field.typ is string {
			condition += conjonction + label_alias + ".$field.name='" + t.$(field.name).str() + "'"
			conjonction = ', '
		}
		$if field.typ is bool {
			condition += conjonction + label_alias + '.$field.name=' + t.$(field.name).str()
			conjonction = ', '
		}
		$if field.typ is f32 {
			condition += conjonction + label_alias + '.$field.name=' + t.$(field.name).str()
			conjonction = ', '
		}
	}
	return condition
}

// Hydrate a struture t T from data grab in lastest query on Redis
fn (mut r Redis) hydrate<T>(mut t T) T {
	allcontent := r.result.table[1].table
	if allcontent.len == 0 {
		return T{}
	}
	for k, c in allcontent {
		// id := c.table[0].table[0].table[1].content
		// label := c.table[0].table[1].table[1].table[0].content
		content := c.table[0].table[2].table[1].table

		for _, cc in content {
			name_field := cc.table[0].content
			value := cc.table[1].content

			$for field in T.fields {
				$if field.typ is int {
					if field.name == name_field {
						t.$(field.name) = value.int()
						continue
					}
				}
				$if field.typ is string {
					if field.name == name_field {
						t.$(field.name) = value
						continue
					}
				}
				$if field.typ is bool {
					if field.name == name_field {
						t.$(field.name) = value.bool()
						continue
					}
				}
				$if field.typ is f32 {
					if field.name == name_field {
						t.$(field.name) = value.f32()
						continue
					}
				}
			}
		}
	}
	return t
}

// https://redis.io/commands/hello/
// Want to check if Redis modules are well loaded by running the HELLO command
// Result should be "Redis modules: ReJSON timeseries graph search bf"
// TODO, Check if module are in /usr/lib/redis/modules
pub fn (mut r Redis) hello() bool {
	r.rawquery('HELLO')

	mut index_modules := 0
	for k, res in r.result.table {
		if res.content == 'modules' {
			index_modules = k + 1
			break
		}
	}

	modules_table := r.result.table[index_modules].table
	if modules_table.len == 0 {
		eprint(term.red('>>> Redis: No module returned with HELLO command' + '\n'))
		return false
	}

	r.result.content += '>>> Modules: '
	for m in modules_table {
		r.result.content += m.table[1].content + ' '
	}
	r.result.table = []
	eprintln(term.green(r.result.content))

	return true
}

// Give an easy way to return some results, one by one
// If Redis socket return:
// 'Labels added: 1'
// 'Nodes created: 1'
// At firt call of result() will return 'Labels added: 1'
// At second call of result() will return 'Nodes created: 1'
// etc...
pub fn (mut r Redis) result() string {

	last_query := r.history[r.history.len - 1]
	if r.result.table.len == 0 {
		if r.result.content.contains('err') {
			eprint(term.red('>>> RedisGRAPH: Error in: $last_query' + '\n'))
		}
		return r.result.content
	}

	// In case the query RETURN something with RETURN inside the query,
	// the first part of the query 'r.result.table[0]' will return result type
	// I don't what the type, but I want the value contains in 'r.result.table[1]'
	mut index := 0
	if last_query.contains('RETURN') {
		index = 1
	}

	for k, _ in r.result.table[index].table {
		if r.result.table[index].table[k].content.len > 0 {
			res := r.result.table[index].table[k].content
			r.result.table[index].table[k].content = ''
			return res
		} else if r.result.table[index].table[k].table.len > 0 {
			if r.result.table[index].table[k].table[0].content.len > 0 {
				res := r.result.table[index].table[k].table[0].content
				r.result.table[index].table[k].table[0].content = ''
				return res
			}
		}
	}
	return ''
}
