module redis

import json
import term
import io

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


// TODO
fn test_con() {
	mut r := new('test_con') or { panic(err) }
	defer {
		r.close()
	}
	mut q := ''

	println("===================")
	q = "GRAPH.QUERY test_result \"CREATE (x:Person {name:'Lea'}) SET x.id = ID(x)\""
	r.con.write_string('$q\r\n') or { panic(err) }
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())


	println("===================")
	q = "GRAPH.QUERY test_result \"CREATE (x:Person {name:'Lea'}) SET x.id == ID(x)\""
	r.con.write_string('$q\r\n') or { panic(err) }
	println('-' + r.con.read_line().trim_space())

	println("===================")
	q = "CREATE (x:Person {name:'Lea'})"
	r.con.write_string('$q\r\n') or { panic(err) }
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())

	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())

	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())
	println('-' + r.con.read_line().trim_space())

	print('\n')
	println("===================")
	// q = "GRAPH.QUERY test_con \"CREATEE (x:Person {name='Lea'})\""
	r.con.write_string('$q\r\n') or { panic(err) }
	println('-' + r.con.read_line().trim_space())

	// println(r.con.read_line().trim_space())
}

// fn test_error_socket_message() {
// 	mut r := new('test_error_message') or { panic(err) }
// 	defer {
// 		r.close()
// 	}

// 	println("===================")
// 	r.rawquery('CREATEE (x:Person {name:\'Lea\'})')
// 	println(r.result)
// 	// assert r.result().contains("Protocol error")

// 	println("===================")
// 	// r.query("CREATEE (x:Person {name=\'Lea\'})")
// 	// println(r.result)
// 	// assert r.result().contains("Invalid input")

// 	q := "GRAPH.QUERY test_con \"CREATEE (x:Person {name='Lea'})\""
// 	r.con.write_string('$q\r\n') or { panic(err) }
// 	println(r.con.read_line().trim_space())
// }
