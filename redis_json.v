module redis

pub fn (mut r Redis) json_create<T>(t T) bool {

	q := ("JSON.GET $tname")

	r.result = r.query(q)

	if r.result.content.contains('errMsg') {
		panic(r.result.content)
	}

	if r.result(.table[0].table.len) == 0 {
		return false
	}
	return r.result() == '???'
}
