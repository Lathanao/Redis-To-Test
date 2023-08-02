module redis

pub fn (mut r Redis) path<T, R, U>(t T, rl R, u U) {
	// db := r.db
	// e1 := cipher_data_format<T>(t)
	// r := cipher_data_format<R>(rl)
	// e2 := cipher_data_format<U>(u)

	// struct_name := typeof(t).name.trim(".")

	// GRAPH.QUERY $db "MATCH path = (a{name:'Lion'}) -[:eat]-> (b{name:'Trees'}) RETURN path"

	// q := ("GRAPH.QUERY $db \"CREATE (:$struct_name {$data})\"")
	// r.result = r.query(q)

	// if r.result.content.contains('errMsg') {
	// 	panic(r.result.content)
	// }
}

pub fn (mut r Redis) sortherpath<T>(t T) {
}
