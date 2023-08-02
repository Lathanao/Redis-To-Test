module redis

// GRAPH.QUERY foodchain "MATCH (n:Animal {name:'Lion'})-[r:Eat]-(m:Animal {name:'Hyena'}) DELETE r"
pub fn (mut r Redis) realtion_create<T, R, U>(t T, rr R, u U) bool {
	if t.id == 0 {
		panic('Redis is trying to delete a relation without id')
	}
	if u.id == 0 {
		panic('Redis is trying to delete a relation without id')
	}

	@type := t.@type
	src_node := t.src_node
	dest_node := t.dest_node
	tname := typeof(t).name.trim('&')
	uname := typeof(u).name.trim('&')

	q := ("GRAPH.QUERY foodchain \"MATCH (n:tname{$src_node}),(m:tname{$dest_node}) CREATE (n)-[:$@type]->(m)\"")

	// q := ("GRAPH.QUERY $db \"MATCH (x:$name) WHERE ID(x)=$id DELETE x\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result(.table[0].table.len) == 0 {
		return false
	}
	return r.result() == 'Relationships deleted: 1'
}

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
pub struct Relation {
pub mut:
	@type string
	id    int
}

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
