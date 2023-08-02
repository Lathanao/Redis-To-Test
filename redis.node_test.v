module redis

import json
import term

const (
	dbname = 'test_redis'
)

pub struct Person {
pub mut:
	name string
	age int
	child []Person
	id int
}

fn test_delete_db() {
	mut r := new(dbname) or {panic(err)}
	assert r.connected == true
	defer{
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
	mut r := new(dbname) or {panic(err)}
	defer{
		r.close()
	}

	leo := Person{name:"Leo"}

	r.node_create(leo)
	assert r.node_exist(leo) == true
}

fn test_node_delete() {
	mut r := new(dbname) or {panic(err)}
	defer{
		r.close()
	}

	lea := Person{name:"lea"}
	r.node_create(lea)
	lea_node := r.node_search(lea)
	assert r.node_exist(lea_node) == true

	r.node_delete(lea_node)
	assert r.node_exist(lea_node) == false
}

fn test_change_db() {
	mut r := new(dbname) or {panic(err)}
	defer{
		r.close()
	}

	r.db = 'test_change_db1'
	leo := Person{name:"Leo"}
	r.node_create(leo)

	r.db = 'test_change_db2'
	lea := Person{name:"Lea"}
	r.node_create(lea)

	r.db = 'test_change_db1'
	res1 := r.node_exist(leo)
	res2 := r.node_search(leo)
	res3 := r.node_exist(lea)
	res4 := r.node_search(lea)

	assert res1 == true
	assert res2.name == "Leo"
	assert res3 == false
	assert res4.name != "Lea"
}

fn test_node_update() {
	mut r := new(dbname) or {panic(err)}
	defer{
		r.close()
	}

	leo := Person{name:"Leo"}
	r.node_create(leo)
	lea := Person{name:"Lea"}
	r.node_create(lea)

	criteria := Person{name: "Lea"}
	mut first_lea := r.node_search(criteria)
	first_lea.name = "Lea_modified"
	first_lea.age = 20

	r.node_update(first_lea)

	load_lea := r.node_load(first_lea)
	assert load_leo.name == first_lea.name
	assert load_leo.age == first_lea.age

	search_lea := r.node_search(first_lea)
	assert search_lea.name == first_lea.name
	assert search_lea.age == first_lea.age
}
