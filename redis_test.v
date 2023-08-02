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

fn test_node_hello() {
	mut r := new(dbname) or {panic(err)}
	assert r.connected == true
	defer{
		r.close()
		assert r.connected == false
	}
	assert r.hello() == true
}

// Format data to insert them during a create query
// Result is close to json, but quote format differ
fn test_cipher_data_format() {

	leo := Person{id: 1} // Try to avoid to set ID, because ID are set automatically
	lea := Person{name: "Lea"}
	tom := Person{name: "Tom", age:20, child: [leo, lea]}
	res_leo := cipher_data_format(leo)
	res_lea := cipher_data_format(lea)
	res_tom := cipher_data_format(tom)

	assert res_leo == "" // Try to avoid to set ID, because ID are set automatically
	assert res_lea == "name:'Lea'"
	assert res_tom == "name:'Tom', age:20"
}

fn test_remove_json_child_struture() {
	leo := Person{id: 1}
	lea := Person{name: "Lea"}
	tom := Person{name: "Tom", age:20, child: [leo, lea]}

	tom_l := json.encode(tom) // {"name":"Tom","age":20,"child":[{"name":"","age":0,"child":[],"id":1},{"name":"Lea","age":0,"child":[],"id":0}],"id":0}
	test_tom := remove_json_child_struture(tom_l)

	test := Person{name: "Tom", age:20, child: []}
	test_json := json.encode(test)

	assert test_tom == test_json
}

// Build condition for match query
// Data in struture are used as criteria
// result sould be this form: "x.id=1 AND x.age=20"
fn test_cipher_data_make_condition() {
	leo := Person{id: 1}
	lea := Person{name: "Lea"}
	mut tom := Person{name: "Tom", age:20, child: [leo, lea]}

	condition_1 := cipher_data_make_condition(tom)
	assert condition_1 == "x.name='Tom' AND x.age=20"

	tom.id = 0

	condition_2 := cipher_data_make_condition(tom)
	assert condition_2 == "x.name='Tom' AND x.age=20"
}

// Format struct fields to string,
// Must be compliant with format required in cypher
// e.g.: name="TOM", age=24
fn test_cipher_data_make_update() {
	leo := Person{id: 1}
	lea := Person{name: "Lea"}
	mut tom := Person{name: "Tom", age:20, child: [leo, lea]}

	update_1 := cipher_data_make_update(tom)
	assert update_1 == "x.name='Tom', x.age=20"

	tom.id = 0

	update_2 := cipher_data_make_update(tom)
	assert update_2 == "x.name='Tom', x.age=20"
}

fn test_change_db() {
	mut r := new(dbname) or {panic(err)}
	assert r.connected == true
	defer{
		r.close()
		assert r.connected == false
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

fn test_query_result_1() {
	mut r := new(dbname) or {panic(err)}
	assert r.connected == true
	defer{
		r.close()
		assert r.connected == false
	}
	r.db = 'test_result'

	r.query("GRAPH.QUERY test_result \"CREATE (x:Person {name:'Lea'}) SET x.id = ID(x)\"")
	assert r.result() == "Labels added: 1"
	assert r.result() == "Nodes created: 1"
	assert r.result() == "Properties set: 2"
	assert r.result() == "Cached execution: 0"
	assert r.result().contains("Query internal execution time") == true

	r.query("GRAPH.QUERY test_result \"CREATE (x:Person {name:'Lea'}) SET x.id = ID(x)\"")
	assert r.result() == "Nodes created: 1"
	assert r.result() == "Properties set: 2"
	assert r.result() == "Cached execution: 1"
	assert r.result().contains("Query internal execution time") == true

	r.query("GRAPH.QUERY test_result \"MATCH (x:Person) RETURN count(x)\"")
	assert r.result().int() == 2

	r.query("GRAPH.QUERY test_result \"CREATE (x:Person {name:'Lea'}) SET x.id = ID(x)\"")
	r.query("GRAPH.QUERY test_result \"CREATE (x:Person {name:'Lea'}) SET x.id = ID(x)\"")
	r.query("GRAPH.QUERY test_result \"CREATE (x:Person {name:'Lea'}) SET x.id = ID(x)\"")
	r.query("GRAPH.QUERY test_result \"MATCH (x:Person) RETURN count(x)\"")
	assert r.result().int() == 5
}

// TODO
fn test_hydrate() {

}

// TODO
fn test_error_socket_message() {
	mut r := new(dbname) or {panic(err)}
	assert r.connected == true
	defer{
		r.close()
		assert r.connected == false
	}
	r.db = 'test_error_message'

	r.query("GRAPH.QUERY test_result \"CREATEE (x:Person {name='Lea'})\"")
}
