module redis

import os
import vweb
import json
import time
import term
import x.json2

const (
	dbname = 'foodchain'
)

pub struct Animal {
pub mut:
	name  string
	age   int
	child []Animal
	id    int
}

pub struct Reptile {
pub mut:
	name  string
	age   int
	child []Animal
	id    int
}

fn test_node_hello() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}
	assert r.hello() == true
}

fn test_delete_db() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}

	for d in r.query('KEYS *').table.clone() {
		if d.content == dbname {
			r.query('DEL ' + d.content)
			assert r.result.content.int() == 1
			assert r.result.table.len == 0
			println(term.yellow('>>> Database ' + d.content + ' deleted'))
		} else {
			println(term.green('>>> Database ' + d.content + ' not deleted'))
		}
	}
}

fn test_insert_by_file() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}
	path := os.resource_abs_path('/Thai_foodchain.gql')
	queries_file := os.read_file(path) or { panic(err) }
	queries := queries_file.split_into_lines()

	for query in queries {
		if query.len == 0 {
			continue
		}

		r.query(query)

		match r.result.table[0].table.len {
			3 { // typically, result for relationship contains 3 elements
				assert r.result.table[0].table[0].content == 'Relationships created: 1'
			}
			4 { // typically, result for node with existing label contains 4 elements
				assert r.result.table[0].table[0].content == 'Nodes created: 1'
				assert r.result.table[0].table[1].content == 'Properties set: 2'
			}
			5 { // typically, result for node with new label contains 5 elements
				assert r.result.table[0].table[0].content == 'Labels added: 1'
				assert r.result.table[0].table[1].content == 'Nodes created: 1'
				assert r.result.table[0].table[2].content == 'Properties set: 2'
			}
			else {
				panic('A result length out of expected length has been returned')
			}
		}
	}
}

fn test_count() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}

	r.query('GRAPH.QUERY foodchain "MATCH (n:Animal) RETURN COUNT(n)"')
	assert r.result.table[1].table[0].table[0].content.int() == 14

	r.query('GRAPH.QUERY foodchain "MATCH (n:Plant) RETURN COUNT(n)"')
	assert r.result.table[1].table[0].table[0].content.int() == 1

	r.query('GRAPH.QUERY foodchain "MATCH (n:Insect) RETURN COUNT(n)"')
	assert r.result.table[1].table[0].table[0].content.int() == 2

	println(r.result)
	println(r.result())
	println(r.result())
}

fn test_node_create() {
	mut r := new(dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}

	mut g := Reptile{
		name: 'Gecko'
	}
	assert r.node_create(g) == true
	assert r.result() == 'Labels added: 1'
	assert r.result() == 'Nodes created: 1'
	assert r.result() == 'Properties set: 2'
	assert r.result() == 'Cached execution: 0'
}

// fn test_node_search() {
// 	mut r := new(dbname) or {panic(err)}
// 	assert r.connected == true
// 	defer{
// 		r.close()
// 		assert r.connected == false
// 	}

// 	s := r.node_search(Reptile{name:'Gecko'})
// 	assert s.name == "Gecko"
// 	assert s.id == 17
// }

// 		r.query(query)
// 		match r.result.table[0].table.len {
// 			3 { // typically, result for relationship contains 3 elements
// 				assert r.result.table[0].table[0].content == 'Relationships created: 1'
// 			}
// 			4 { // typically, result for node with existing label contains 4 elements
// 				assert r.result.table[0].table[0].content == 'Nodes created: 1'
// 				assert r.result.table[0].table[1].content == 'Properties set: 2'
// 			}
// 			5  {// typically, result for node with new label contains 5 elements
// 				assert r.result.table[0].table[0].content == 'Labels added: 1'
// 				assert r.result.table[0].table[1].content == 'Nodes created: 1'
// 				assert r.result.table[0].table[2].content == 'Properties set: 2'
// 			}
// 			else {
// 				panic('A result length out of expected length has been returned')
// 			}
// 		}
// 	}
// }

// fn test_update_nodes() {
// 	mut r := new(dbname) or { panic(err) }
// 	defer {
// 		r.close()
// 	}

// 	mut l := r.node_search(Animal{name:'Black Pantha'})
// 	assert l.id == 13
// 	l.name = 'Panther'
// 	assert r.node_update(l) == true

// 	mut ll := r.node_search(Animal{name:'Trees'})
// 	assert ll.id == 21
// 	ll.name = 'Tree'
// 	assert r.node_update(ll) == true

// 	mut lll := r.node_search(Animal{name:'Grass and Struglle'})
// 	assert lll.id == 21
// 	lll.name = 'Grass'
// 	assert r.node_update(ll) == true
// }

// fn test_delete_relations() {
// 	mut r := new(dbname) or {panic(err)}
// 	assert r.connected == true
// 	defer{
// 		r.close()
// 		assert r.connected == false
// 	}

// 	l := Animal{name:'Lion'}
// 	h := Animal{name:'Hyena'}
// 	rr := r.realtion_search(l,h)

// 	for rrr in rr {
// 		if r.@type == "Eat" {
// 			r.relation_delete()
// 		}
// 	}
// }

// fn test_create_relations() {
// 	mut r := new(dbname) or {panic(err)}
// 	assert r.connected == true
// 	defer{
// 		r.close()
// 		assert r.connected == false
// 	}

// 	l := Animal{name:'Lion'}
// 	h := Animal{name:'Hyena'}
// 	struggle := Relation{@type:'Struggle'}
// 	r.relation_create(l, struggle, h)
// 	r.relation_create(h, struggle, l)

// 	g := Animal{name:'Gazelle'}
// 	P := Animal{name:'Phanther'}
// 	eat := Relation{@type:'Eat'}
// 	r.relation_create(p, newrr, g)
// }

// fn test_find_path() {
// 	mut r := new(dbname) or {panic(err)}
// 	assert r.connected == true
// 	defer{
// 		r.close()
// 		assert r.connected == false
// 	}

// 	l := Animal{name:'Lion'}
// 	h := Plant{name:'Tree'}
// 	ps := r.path_search(l,h)

// 	for p in ps {
// 		if p.len == 0 {
// 				assert false == false
// 		}
// 	}
// }
