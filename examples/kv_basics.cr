# Basic KV operations — connect to one Couchbase KV node, store a
# document, read it back, delete it.
#
# Reads from `.envrc` (loaded via direnv): COUCHBASE_HOST,
# COUCHBASE_USER, COUCHBASE_PASS, COUCHBASE_BUCKET.
#
#   crystal run examples/kv_basics.cr
require "../src/crybase"

host = ENV["COUCHBASE_HOST"]? || "localhost"
user = ENV["COUCHBASE_USER"]? || "Administrator"
pass = ENV["COUCHBASE_PASS"]? || "password"
bucket = ENV["COUCHBASE_BUCKET"]? || "default"

endpoint = CryBase::CouchBase::Endpoint.new(host, 11210, CryBase::CouchBase::Service::KV, false)
kv = CryBase::CouchBase::Services::KV::Client.new(endpoint, user, pass, bucket)

cas = kv.set("crybase:hello", "world")
puts "SET    crybase:hello => CAS=#{cas}"

value = kv.get("crybase:hello")
puts "GET    crybase:hello => #{String.new(value)}"

# kv.delete("crybase:hello")
# puts "DELETE crybase:hello"

kv.close
