module redis

pub struct Relation {
pub mut:
	@type string
	id    int
}

// GRAPH.QUERY foodchain "MATCH (n:Animal {name:'Lion'})-[r:Eat]-(m:Animal {name:'Hyena'}) DELETE r"
pub fn (mut r Redis) relation_create<T, R, U>(t T, rr R, u U) bool {
	if t.id == 0 || u.id == 0 {
		// dump(t) // cgen error
		// dump(u) // cgen error
		println(t)
		println(u)
		panic('Redis is trying to create a relation without id')
	}

	tdata := cipher_data_format<T>(t)
	tlabelname := typeof(t).name.trim('.').trim('&')

	udata := cipher_data_format<U>(u)
	ulabelname := typeof(u).name.trim('.').trim('&')

	rtype := rr.@type.capitalize()

	q := ("GRAPH.QUERY $r.db \"MATCH (n:$tlabelname{$tdata}),(m:$ulabelname{$udata}) CREATE (n)-[:$rtype]->(m)\"")

	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result().int() == 0 {
		return false
	}
	return r.result() == 'Relationships deleted: 1'
}


pub fn (mut r Redis) relation_create_unique<T, R, U>(t T, rr R, u U) bool {
	if t.id == 0 || u.id == 0 {
		println(t)
		println(u)
		panic('Redis is trying to create unique a relation without id')
	}

	tdata := cipher_data_format<T>(t)
	tlabelname := typeof(t).name.trim('.').trim('&')

	udata := cipher_data_format<U>(u)
	ulabelname := typeof(u).name.trim('.').trim('&')

	rtype := rr.@type.capitalize()

	q := ("GRAPH.QUERY $r.db \"MATCH (n:$tlabelname{$tdata}),(m:$ulabelname{$udata}) CREATE UNIQUE (n)-[:$rtype]->(m)\"")

	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result().int() == 0 {
		return false
	}
	return true
}

pub fn (mut r Redis) relation_match<T, R, U>(t T, rr R, u U) bool {

	tdata := cipher_data_format<T>(t)
	tlabelname := typeof(t).name.trim('.').trim('&')

	udata := cipher_data_format<U>(u)
	ulabelname := typeof(u).name.trim('.').trim('&')

	mut	relation_alias := 'r'
	mut	rtype := ''
	mut	returned_relation := ''

	if rr.@type.len > 0 {
		relation_alias = "r:"
		rtype = rr.@type.capitalize()
		returned_relation = "ID(r), "
	}

	q := ("GRAPH.QUERY $r.db \"MATCH (n:$tlabelname{$tdata})-[$relation_alias$rtype]->(m:$ulabelname{$udata}) RETURN ID(n), ID(r), ID(m)\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	// println(r.result.table[1])
	println(r.result.table[1].table)

	// new_lea :=
	return true
}



// MATCH (a:User {name: "Jack", surname: "Roe"}),
// (b:User {name: "Jack", surname: "Smith"})
// CREATE UNIQUE (a) -[rn:Knows]-> (b)
// RETURN a,rn,b

// N: Node
// R: Relation
// M: Node
// pub fn (mut r Redis) node_match<N, R, M>(mut n N, mut r R, mut m M) bool {
// 	if t.len == 0 {
// 		panic('Redis is trying to match and delete a batch of node')
// 	}

// 	db := r.db
// 	id := t.id

// 	n_struct_name := typeof(n).name.trim('&')
// 	m_struct_name := typeof(m).name.trim('&')

// 	q := ("GRAPH.QUERY $db \"MATCH (n)-[r]->(m) RETURN i.name, s.percentage, c.name\"")

// 	r.result = r.query(q)

// 	if r.result.content.contains('errMsg') {
// 		panic(r.result.content)
// 	}
// 	$if !prod {
// 		println(q)
// 		println(r.result)
// 		println(r.result.table[0].table[0].content)
// 		println(r.result.table[0].table.len)
// 	}
// 	if r.result.table[0].table.len == 0 {
// 		return false
// 	}
// 	return r.result.table[0].table[0].content.contains('Nodes deleted: 1')
// }


// GRAPH.QUERY foodchain "MATCH (n:Animal {name:'Lion'})-[r:Eat]-(m:Animal {name:'Hyena'}) DELETE r"
pub fn (mut r Redis) relation_delete<T>(mut t T) bool {
	if t.id == 0 {
		panic('Redis is trying to delete a relation without id')
	}

	db := r.db
	id := t.id
	@type := t.@type
	src_node := t.src_node
	dest_node := t.dest_node
	name := typeof(t).name.trim('&')

	q := ("GRAPH.QUERY $db \"MATCH (x:$name) WHERE ID(x)=$id DELETE x\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result.table[0].table.len == 0 {
		return false
	}
	return r.result.table[0].table[0].content.contains('Relationships deleted: 1')
}
