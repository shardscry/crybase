# Implementation of the Couchbase KV (Data) service over the memcached
# binary protocol.
#
# The public entry point is `KV::Client`; everything else is structured
# as small composable pieces:
#
# * `KV::Request`        — value type describing one outbound packet
# * `KV::RequestWriter`  — mixin: `write(req)` serializes to a socket
# * `KV::Response`       — value type describing one inbound packet
# * `KV::ResponseReader` — mixin: `read` decodes one packet from a socket
# * `KV::Bucket`         — mixin: SELECT_BUCKET handshake
# * `KV::Serializable`   — typed value codec
# * `KV::Pool`           — fixed-size pool of authenticated clients
#
# These mixins are composed into `KV::Client`, which also handles
# `HELLO`, `SASL_AUTH(PLAIN)` and offers `get`/`set`/`delete`.
#
# ```
# endpoint = CryBase::CouchBase::Endpoint.new(
#   "node1", 11210, CryBase::CouchBase::Service::KV, false
# )
# kv = CryBase::CouchBase::Services::KV::Client.new(endpoint, "user", "pass", "default")
# kv.set("hello", "world")
# kv.get("hello") # => Bytes containing "world"
# kv.delete("hello")
# kv.close
# ```
module CryBase::CouchBase::Services::KV
  # Binary-protocol magic byte indicating an outbound (request) packet.
  REQUEST_MAGIC = 0x80_u8

  # Binary-protocol magic byte indicating an inbound (response) packet.
  RESPONSE_MAGIC = 0x81_u8

  # Fixed-width header size in bytes for both requests and responses.
  HEADER_SIZE = 24

  # User-agent string sent in the HELLO request body.
  AGENT = "crybase"

  # HELLO feature code that opts the connection into bucket selection.
  # Sent during the handshake so the server accepts SELECT_BUCKET.
  FEATURE_SELECT_BUCKET = 0x0008_u16

  # Number of vbuckets in Couchbase buckets.
  VBUCKET_COUNT = 1024_u16
end

require "digest/crc32"

require "./kv/opcode"
require "./kv/status"
require "./kv/vbucket"
require "./kv/expiry"
require "./kv/counter"
require "./kv/serializable"
require "./kv/response"
require "./kv/error"
require "./kv/not_found"
require "./kv/auth_failed"
require "./kv/request"
require "./kv/request_writer"
require "./kv/response_reader"
require "./kv/bucket"
require "./kv/client"
require "./kv/pool"
