module redis

import json
import term

const (
	dbname = 'test_redis_relation'
)

pub struct Person {
pub mut:
	name  string
	age   int
	child []Person
	id    int
}

pub struct Is_father {
pub mut:
	name  string
}

fn test_delete_db() {
	mut r := new(dbname) or { panic(err) }
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

fn test_node_create() {
	mut r := new(dbname) or { panic(err) }
	defer {
		r.close()
	}

	leo := Person{
		name: 'Leo'
	}
	lea := Person{
		name: 'Lea'
	}
	tom := Person{
		name: 'Tom'
	}
	r.node_create(leo)
	r.node_create(lea)
	r.node_create(tom)
	assert r.node_exist(leo) == true
	assert r.node_exist(lea) == true
	assert r.node_exist(tom) == true
}

fn test_relation_create() {
	mut r := new(dbname) or { panic(err) }
	defer {
		r.close()
	}

	leo := r.node_search(Person{
		name: 'Leo'
	})
	lea := r.node_search(Person{
		name: 'Lea'
	})
	tom := r.node_search(Person{
		name: 'Tom'
	})
	is_father := Relation{@type:'is_father'}

	r.relation_create(tom, is_father, lea)
	res := r.relation_match(tom, is_father, lea)
	println(res)


}

fn test_relation_match() {
	mut r := new(dbname) or { panic(err) }
	defer {
		r.close()
	}

	r.node_create(Person{
		name: 'Lucy'
	})
	r.node_create(Person{
		name: 'Noe'
	})

	lucy := r.node_search(Person{
		name: 'Lucy'
	})
	noe := r.node_search(Person{
		name: 'Noe'
	})

	is_mother := Relation{@type:'is_mother'}

	r.relation_create(lucy, is_mother, noe)
	res := r.relation_match(Person{}, Relation{}, Person{})
	println(res)

}
