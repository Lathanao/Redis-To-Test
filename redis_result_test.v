module redis

import os
import vweb
import json
import time
import term
import x.json2

const (
	dbname = 'test_foodchain'
)

pub struct Animal {
pub mut:
	id 		int
	name  string
}

pub struct Reptile {
pub mut:
	name  string
	id 		int
}

pub struct Insect {
pub mut:
	id 		int = default_id
	name  string
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
			assert r.result.content.int() == 1
			assert r.result.table.len == 0
			eprint(term.red('>>> Database ' + d.content + ' deleted') + '\n')
		}else {
			println(term.green('>>> Database ' + d.content + ' not deleted'))
		}
	}
}

fn test_insert_by_file() {
	mut r := new(db: dbname) or { panic(err) }
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
				assert r.result() == 'Relationships created: 1'
			}
			4 { // typically, result for node with existing label contains 4 elements
				assert r.result() == 'Nodes created: 1'
				assert r.result() == 'Properties set: 2'
			}
			5 { // typically, result for node with new label contains 5 elements
				assert r.result() == 'Labels added: 1'
				assert r.result() == 'Nodes created: 1'
				assert r.result() == 'Properties set: 2'
			}
			else {
				panic('A result length out of expected length has been returned')
			}
		}
	}
}

fn test_count() {
	mut r := new(db: dbname) or { panic(err) }
	assert r.connected == true
	defer {
		r.close()
		assert r.connected == false
	}

	r.query('GRAPH.QUERY $dbname "MATCH (n:Animal) RETURN COUNT(n)"')
	assert r.result() == "13"
	println(r.result)
	// r.query('GRAPH.QUERY $dbname "MATCH (n:Plant) RETURN COUNT(n)"')
	// assert r.result() == "3"

	// r.query('GRAPH.QUERY $dbname "MATCH (n:Insect) RETURN COUNT(n)"')
	// assert r.result() == "2"
}
