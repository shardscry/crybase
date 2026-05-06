# KV expiration operations — set a document with TTL, extend it with
# TOUCH, and fetch while atomically resetting expiry with GET_AND_TOUCH.
#
# Reads from `.envrc` (loaded via direnv): COUCHBASE_HOST,
# COUCHBASE_USER, COUCHBASE_PASS, COUCHBASE_BUCKET.
#
#   crystal run examples/kv_expiration.cr
require "../src/crybase"

host = ENV["COUCHBASE_HOST"]? || "localhost"
user = ENV["COUCHBASE_USER"]? || "Administrator"
pass = ENV["COUCHBASE_PASS"]? || "password"
bucket = ENV["COUCHBASE_BUCKET"]? || "default"

endpoint = CryBase::CouchBase::Endpoint.new(host, 11210, CryBase::CouchBase::Service::KV, false)
kv = CryBase::CouchBase::Services::KV::Client.new(endpoint, user, pass, bucket)

key = "crybase:expiration"

kv.set(key, "short lived", expiry: 2_u32)
puts "SET    #{key} with expiry=2s"

sleep 1.second
kv.touch(key, 10_u32)
puts "TOUCH  #{key} with expiry=10s"

sleep 2.seconds
puts "GET    #{key} => #{String.new(kv.get(key))}"

kv.set(key, "get and touch", expiry: 2_u32)
puts "SET    #{key} with expiry=2s"

sleep 1.second
puts "GAT    #{key} => #{String.new(kv.get(key, expiry: 10_u32))}"

sleep 2.seconds
puts "GET    #{key} => #{String.new(kv.get(key))}"

kv.delete(key)
puts "DELETE #{key}"

kv.close
