module redis

import json
import term

const (
	dbname = 'test_redis'
)

pub struct Person {
pub mut:
	name  string
	age   int
	child []Person
	id    int
}

fn test_delete_db() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}

	for d in r.query('KEYS *').table.clone() {
		if d.content.match_glob('test_*') {
			r.query('DEL ' + d.content)
			assert r.result.content.int() == 1
			assert r.result.table.len == 0
			eprint(term.red('>>> Database ' + d.content + ' deleted') + '\n')
		}
	}
}

fn test_node_create() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}

	leo := Person{
		name: 'Leo'
	}

	r.node_create(leo)
	assert r.node_exist(leo) == true
}

fn test_node_delete() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}

	lea := Person{
		name: 'lea'
	}
	r.node_create(lea)
	lea_node := r.node_search(lea)
	assert r.node_exist(lea_node) == true

	r.node_delete(lea_node)
	assert r.node_exist(lea_node) == false
}

fn test_query_result_1() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}

	q := 'GRAPH.QUERY test_redis "MATCH (x:Person) RETURN count(x)"'
	r.query(q)

	assert r.result().int() == 1
}

fn test_node_update() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
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

	load_leo := r.node_load(first_lea)
	assert load_leo.name == first_lea.name
	assert load_leo.age == first_lea.age

	search_leo := r.node_search(first_lea)
	assert search_leo.name == first_lea.name
	assert search_leo.age == first_lea.age
}
