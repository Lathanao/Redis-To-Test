module redis

pub fn (mut r Redis) node_create<T>(mut t T) bool {

	data := cipher_data_format<T>(t)
	label_name := typeof(t).name.trim('&').trim('.')

	if data.len == 0 {
		println(t)
		println("Data: $data")
		panic('Redis is trying to create a node without data')
	}

	q := ("GRAPH.QUERY $r.db \"CREATE (x:$label_name {$data}) SET x.id = ID(x) RETURN x\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	id := r.result.table[1].table[0].table[0].table[0].table[1].content.int()
	if id > -1 {
		t.id = id
	}

	return true
}

pub fn (mut r Redis) node_exist<T>(t T) bool {
	mut tt := t
	mut s := r.node_search(mut tt)
	s.id = 0
	tt.id = 0
	if tt == s {
		return true
	}
	return false
}

pub fn (mut r Redis) node_update<T>(mut t T) bool {
	if t.id == 0 {
		panic('Redis is trying to update a node without id')
	}

	id := t.id
	parameter := cipher_data_make_update<T>(t)
	name := typeof(t).name.trim('&').trim('.')

	q := ("GRAPH.QUERY $r.db \"MATCH (x:$name) WHERE ID(x)=$id SET $parameter\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	return r.result.table[0].table[0].content.contains('Properties set')
}

// Load by Id
pub fn (mut r Redis) node_load<T>(mut t T) T {
	if t.id == 0 {
		panic('Redis is trying to load a node without id')
	}

	id := t.id
	name := typeof(t).name.trim('&').trim('.')

	q := ("GRAPH.QUERY $r.db \"MATCH (x:$name) WHERE ID(x)=$id RETURN x\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result.table[1].table.len == 0 {
		return T{}
	}
	return r.hydrate(mut t)
}

// Retireve an entry in DB following same similiraty that struct given in argument
// The final goal is to be sure to not getting double entry when create some relation
pub fn (mut r Redis) node_search<T>(mut t T) T {

	name := typeof(t).name.trim('&').trim('.')
	parameter := cipher_data_make_update<T>(t)
	data := cipher_data_format<T>(t)
	// println(data)
	// println(t)
	if parameter.len == 0 {
		panic('Redis is trying to search a node without parameter')
	}

	q := ("GRAPH.QUERY $r.db \"MATCH (x:$name{$data}) RETURN x\"")

	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result.table[1].table.len == 0 {
		return T{}
	}
	res := r.hydrate(mut t)
	// if res.id == 0 {
	// 	panic('Redis returned a hydrated struct without id')
	// }
	return res
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

// Delete node and relations
pub fn (mut r Redis) node_delete<T>(mut t T) bool {
	if t.id == 0 {
		eprint(t)
		eprint(' ')
		panic('Redis is trying to detach and delete some nodes without id')
	}

	id := t.id
	name := typeof(t).name.trim('&').trim('.')

	q := ("GRAPH.QUERY $r.db \"MATCH (x:$name) WHERE ID(x)=$id DELETE x\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result.table[0].table.len == 0 {
		return false
	}
	return r.result.table[0].table[0].content.contains('Nodes deleted: 1')
}
