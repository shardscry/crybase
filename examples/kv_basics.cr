# Basic KV operations — connect to one Couchbase KV node, store a
# document, read it back, and store a typed JSON value.
#
# Reads from `.envrc` (loaded via direnv): COUCHBASE_HOST,
# COUCHBASE_USER, COUCHBASE_PASS, COUCHBASE_BUCKET.
#
#   crystal run examples/kv_basics.cr
require "json"
require "../src/crybase"

struct Profile
  include JSON::Serializable

  property name : String
  property score : Int32

  def initialize(@name : String, @score : Int32)
  end
end

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

kv.set("crybase:profile", Profile.new("ada", 42))
profile = kv.get_as("crybase:profile", Profile)
puts "GET    crybase:profile => #{profile.name} scored #{profile.score}"

# kv.delete("crybase:hello")
# kv.delete("crybase:profile")
# puts "DELETE crybase:hello"

kv.close
