[Foreword]

# Main resource
https://redis.io/docs/stack/graph/cypher_support/

# Can use with something like that:
fn main() {
	mut threads := []thread{}
	for c in 0..1{
		time.sleep(100*time.millisecond)
		threads << go go_redis(c)
	}
	threads.wait()
}

# Limitation
Only some few struct types allowed:
 - string
 - int
 - COLLECT is not plan

# Very Good Resources
https://d3gt.com/

# TODO
- get Order and Size of a Graph
- Check if the graph is complete or not: https://d3gt.com/unit.html?complete-graph
- createNode / node_create / relation_create

Node cc2 = graphDb.createNode(HrLabels.CostCenter);
cc2.setProperty(CostCenter. CODE, "CC2");

Add a e.g. underwood.setProperty(Employee.MIDDLE_NAME, "Mary")
to node or relation

Allow create empty node / empty relation

.createRelationshipTo


Node underwood = graphDb.createNode(HrLabels.Employee);
underwood.setProperty(Employee.NAME, "Heather");
underwood.setProperty(Employee.MIDDLE_NAME, "Mary");
underwood.setProperty(Employee.SURNAME, "Underwood");

Node smith = graphDb.createNode(HrLabels.Employee);
smith.setProperty(Employee.NAME, "John");
smith.setProperty(Employee.SURNAME, "Smith");
// There is a vacant post in the company

Node vacantPost = graphDb.createNode();
// davies belongs to CC1
davies.createRelationshipTo(cc1, EmployeeRelationship.
BELONGS_TO)
.setProperty(EmployeeRelationship.FROM,
new GregorianCalendar(2011, 1, 10).
getTimeInMillis());

// .. and reports to Taylor
davies.createRelationshipTo(taylor, EmployeeRelationship.
REPORTS_TO);

// Taylor is the manager of CC1
taylor.createRelationshipTo(cc1, EmployeeRelationship.
MANAGER_OF)

Unlike relational databases, node IDs in Neo4j are not guaranteed
to remain fixed forever. In fact, IDs are recomputed upon node
deletion, so don't trust IDs, especially for long operations.

# TODO Path
MATCH path = (a{surname:'Davies'}) -[*]- (b{surname:'Taylor'}) RETURN path

GRAPH.QUERY foodchain "MATCH path = (a{name:'Lion'}) -[*]-> (b{name:'Trees'}) RETURN path"
GRAPH.QUERY foodchain "MATCH path = (a{name:'Lion'}) -[*2..]-> (b{name:'Trees'}) RETURN path"

# TODO Path
Try
MATCH (a{surname:'Davies'}), (b{surname:'Taylor'})
RETURN allShortestPaths((a)-[*]-(b)) as path

# Try with Node IDs (Should be faster) -> START not supported
START a=node(2), b=node(3)
RETURN allShortestPaths((a)-[*]-(b)) AS path

GRAPH.QUERY foodchain "START a=node(0), b=node(22) RETURN allShortestPaths((a)-[*]-(b)) AS path"


# Load Demo

# SEARCH / Search exact / check for auto query it -> REGEXT "=~" not supported
MATCH (b:Book)
WHERE b.title =~ '.*Lost.*'
RETURN b

GRAPH.QUERY foodchain "MATCH (n) WHERE b.name =~ '.*a*' RETURN n"

# Search with regular expressions
Tom := Person{name:'.*[Tt]ale(s)?.*'}
r.regular_expressions(Tom)

MATCH (b:Book)
WHERE b.title =~ '.*Lost.*'
RETURN b

# Validate dd regular expression HTML element
([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})Matches
(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})
([\/\w \.-]*)*\/?An HTTP URL without
a query string
<([a-z]+)([^<]+)*(?:>(.*)<\/\1>|\s+\/>)HTML tags
\d{5}A ZIP code
\+?[\d\s]{3,}A phone number

# Check if setting none as return statement is usefull

# Check search string with escaped char
String query = "(?i).*" + Pattern.quote(textToFind);

# Check how to implement the IN predicate
WHERE tag IN ['nosql','neo4j']

# Check what is Predicate
The keyword ANY, just as every predicate...

# Think about how to set LIMIT and SKIP
params.put("query", query);
params.put("limit", limit);
params.put("skip", skip);
ORDER BY

# Check existing relationship with OPTIONAL MATCH before create it
This is a waste of storage. In this context, we need
to check the database and create the relation only if it does not exist. This is why an
OPTIONAL MATCH clause is required to prevent double storage. This is illustrated in
the following query:

MATCH (a:User {name: "Jack", surname: "Roe"}),
(b:User {name: "Jack", surname: "Smith"})
OPTIONAL MATCH (a) -[r:Knows]- (b)
WITH a,r,b
WHERE r IS NULL
CREATE (a) -[rn:Knows]-> (b)
RETURN a,rn,b

# Test with CREATE UNIQUE
MATCH (a:User {name: "Jack", surname: "Roe"}),
(b:User {name: "Jack", surname: "Smith"})
CREATE UNIQUE (a) -[rn:Knows]-> (b)
RETURN a,rn,b

# Adding labels to nodes

# print the query

# constraint unique
CREATE CONSTRAINT ON (user:User)
ASSERT user.userId IS UNIQUE
Then check:
CREATE INDEX ON :User(userId)

# CRUD
CREATE (a:Author { name: {name},
surname: {surname} })
SET a.id = ID(a)
RETURN a.id


Find the animal most in danger
Find the best meat
Find the easy prey
find error like Node with attbiute e.g. GRAPH.QUERY test_node_create "CREATE (x:Person {}) SET x.id = ID(x)"
