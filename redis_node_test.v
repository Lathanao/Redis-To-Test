module redis

import term

const (
	dbname = 'test_redis'
)

pub struct Person {
pub mut:
	name  string [required]
	age   int
	child []Person
	id    int = default_id
}

fn test_delete_db() {
	mut r := new(db: dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}

	for d in r.rawquery('KEYS *').table.clone() {
		if d.content.match_glob('test_*') {
			r.rawquery('DEL ' + d.content)
			assert r.result.content == "1"
			assert r.result.table.len == 0
			eprint(term.green('>>> Database ' + d.content + ' deleted') + '\n')
		}else {
			println(term.green('>>> Database ' + d.content + ' not deleted'))
		}
	}
}

fn test_node_create() {
	mut r := new(db: dbname) or { panic(err) }
	defer {
		r.close()
	}

	r.node_create(Person{name: "Leo"})
	r.rawquery("GRAPH.QUERY $r.db \"MATCH (x:Person{name:'Leo'}) RETURN COUNT(x)\"")
	assert r.result() == "1"
}

fn test_node_create_2() {
	mut r := new(db: dbname) or { panic(err) }
	defer {
		r.close()
	}

	r.node_create(Person{name: "Leo"})
	r.rawquery("GRAPH.QUERY $r.db \"MATCH (x:Person{name:'Leo'}) RETURN COUNT(x)\"")
	assert r.result() == "2"
}

fn test_node_delete() {
	mut r := new(db: dbname) or { panic(err) }
	defer {
		r.close()
	}
	leo := Person{
		name: 'Leo'
	}
	lea := Person{
		name: 'Lea'
	}
	r.node_create(leo)
	r.node_create(lea)

	lea_node := r.node_search(lea)
	assert r.node_exist(lea_node) == true
	assert lea_node.id == 3

	r.node_delete(lea_node)
	assert r.node_exist(lea_node) == false
}

fn test_change_db() {
	mut r := new(db: dbname) or { panic(err) }
	defer {
		r.close()
	}

	r.db = 'test_change_db1'
	leo := Person{
		name: 'Leo'
	}
	r.node_create(leo)

	r.db = 'test_change_db2'
	lea := Person{
		name: 'Lea'
	}
	r.node_create(lea)

	r.db = 'test_change_db1'
	res1 := r.node_exist(leo)
	res2 := r.node_search(leo)
	res3 := r.node_exist(lea)
	res4 := r.node_search(lea)

	assert res1 == true
	assert res2.name == 'Leo'
	assert res3 == false
	assert res4.name != 'Lea'
}

fn test_node_update() {
	mut r := new(db: dbname) or { panic(err) }
	defer {
		r.close()
	}

	leo := Person{
		name: 'Leo'
	}
	r.node_create(leo)
	lea := Person{
		name: 'Lea'
	}
	r.node_create(lea)

	criteria := Person{
		name: 'Lea'
	}
	mut first_lea := r.node_search(criteria)
	first_lea.name = 'Lea_modified'
	first_lea.age = 20

	r.node_update(first_lea)

	load_lea := r.node_load(first_lea)
	assert load_lea.name == first_lea.name
	assert load_lea.age == first_lea.age

	search_lea := r.node_search(first_lea)
	assert search_lea.name == first_lea.name
	assert search_lea.age == first_lea.age
}
