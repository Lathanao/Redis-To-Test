module redis

pub fn (mut r Redis) node_create<T>(t T) bool {
	db := r.db

	data := cipher_data_format<T>(t)
	label_name := typeof(t).name.trim('.')

	if data.len == 0 {
		panic('Redis is trying to create a node without data')
	}

	q := ("GRAPH.QUERY $db \"CREATE (x:$label_name {$data}) SET x.id = ID(x)\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	return true
}

pub fn (mut r Redis) node_exist<T>(mut t T) bool {
	mut s := r.node_search(mut t)
	s.id = 0
	t.id = 0
	if t == s {
		return true
	}
	return false
}

pub fn (mut r Redis) node_update<T>(mut t T) bool {
	if t.id == 0 {
		panic('Redis is trying to update a node without id')
	}

	id := t.id
	db := r.db
	parameter := cipher_data_make_update<T>(t)
	name := typeof(t).name.trim('&').trim('.')

	q := ("GRAPH.QUERY $db \"MATCH (x:$name) WHERE ID(x)=$id SET $parameter\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	return r.result.table[0].table[0].content.contains('Properties set')
}

// Load by Id
pub fn (mut r Redis) node_load<T>(mut t T) T {
	if t.id == 0 {
		panic('Redis is trying to load a node without id')
	}
	db := r.db
	id := t.id
	name := typeof(t).name.trim('&').trim('.')

	q := ("GRAPH.QUERY $db \"MATCH (x:$name) WHERE ID(x)=$id RETURN x\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result.table[1].table.len == 0 {
		return T{}
	}
	return r.hydrate(mut t)
}

// Retireve an entry in DB following same similiraty that struct given in argument
// The final goal is to be sure to not getting double entry when create some relation
pub fn (mut r Redis) node_search<T>(mut t T) T {
	db := r.db
	name := typeof(t).name.trim('&').trim('.')
	parameter := cipher_data_make_update<T>(t)
	data := cipher_data_format<T>(t)

	if parameter.len == 0 {
		panic('Redis is trying to search a node without parameter')
	}

	q := ("GRAPH.QUERY $db \"MATCH (x:$name{$data}) RETURN x\"")

	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result.table[1].table.len == 0 {
		return T{}
	}
	return r.hydrate(mut t)
}

// Delete node and relations
pub fn (mut r Redis) node_delete<T>(mut t T) bool {
	if t.id == 0 {
		panic('Redis is trying to detach and delete some nodes without id')
	}

	db := r.db
	id := t.id
	name := typeof(t).name.trim('&').trim('.')

	q := ("GRAPH.QUERY $db \"MATCH (x:$name) WHERE ID(x)=$id DELETE x\"")
	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result.table[0].table.len == 0 {
		return false
	}
	return r.result.table[0].table[0].content.contains('Nodes deleted: 1')
}
