# CryBase

A Crystal client library for Couchbase.

> **Status:** early scaffold. Cluster-level service discovery still TCP-probes
> Couchbase service interfaces, while the KV service now includes a small
> binary-protocol client for authenticated `get` / `set` / `delete` operations
> and a fixed-size connection pool.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crybase:
       github: num8er/crybase
   ```

2. Run `shards install`.

## Usage

```crystal
require "crybase"

client = CryBase::CouchBase::Client.connect(
  "couchbases://node1.example.com,node2.example.com",
  username: "Administrator",
  password: "password",
)

client.endpoints_for(CryBase::CouchBase::Service::KV).each do |ep|
  puts ep # e.g. "Data (KV) couchbases://node1.example.com:11207"
end

client.close
```

### KV client and pool

```crystal
require "crybase"

endpoint = CryBase::CouchBase::Endpoint.new(
  "127.0.0.1",
  11210,
  CryBase::CouchBase::Service::KV,
  false,
)

pool = CryBase::CouchBase::Services::KV::Pool.new(
  endpoint,
  "Administrator",
  "password",
  "default",
)

pool.set("hello", %({"world":true}))
puts String.new(pool.get("hello"))
pool.delete("hello")
pool.close
```

`KV::Pool` opens `10` authenticated KV connections by default. Pass `size:` to
override it. `KV::Client` provides the same basic `get`, `set`, `delete`, and
`close` operations for a single connection.

### Public modules

| Module / Type | Purpose |
| ------------- | ------- |
| `CryBase` | Top-level namespace and shard entry point. |
| `CryBase::CouchBase` | Couchbase-specific namespace. |
| `CryBase::CouchBase::ConnectionString` | Parses `couchbase://`, `couchbases://`, and `http(s)://` connection strings. |
| `CryBase::CouchBase::Endpoint` | Value type for one service endpoint. |
| `CryBase::CouchBase::Service` | Service enum with plaintext and TLS default ports. |
| `CryBase::CouchBase::Client` | Cluster-level endpoint enumerator and TCP probe client. |
| `CryBase::CouchBase::Services` | Namespace for protocol-specific service clients. |
| `CryBase::CouchBase::Services::KV` | Binary-protocol KV namespace. |
| `CryBase::CouchBase::Services::KV::Client` | Single authenticated KV connection with `get`, `set`, `delete`. |
| `CryBase::CouchBase::Services::KV::Pool` | Fixed-size pool of authenticated KV clients. |
| `CryBase::Interfaces` | Abstract interface aliases for connection strings, endpoints, and clients. |

Generated API documentation is committed under [`docs/`](docs/index.html). To
refresh it manually:

```sh
crystal docs -o docs
```

### Connection strings

| Scheme         | TLS | Notes                                  |
| -------------- | --- | -------------------------------------- |
| `couchbase://` | no  | Plaintext (default if scheme omitted). |
| `couchbases://`| yes | TLS on every service port.             |
| `http(s)://`   | yes/no | Treated as a Management URL.        |

Multiple seed nodes are comma-separated:
`couchbase://node1,node2,node3`. An explicit `:port` is forwarded to the
Management endpoint only — every other service uses its standard port.

### Service ports probed

| Service         | Plaintext | TLS    |
| --------------- | --------- | ------ |
| Data (KV)       | 11210     | 11207  |
| Query (N1QL)    | 8093      | 18093  |
| Search (FTS)    | 8094      | 18094  |
| Analytics       | 8095      | 18095  |
| Index           | 9102      | 19102  |
| Eventing        | 8096      | 18096  |
| Views           | 8092      | 18092  |
| Management      | 8091      | 18091  |

## Development

```sh
crystal spec          # run the test suite
crystal tool format   # format sources
crystal docs -o docs  # generate API docs
```

Enable the project hooks once per clone:

```sh
git config core.hooksPath .githooks
```

The pre-commit hook checks formatting, verifies the library builds, regenerates
`docs/`, and runs the spec suite.

## Contributing

1. Fork it (<https://github.com/num8er/crybase/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anar K. Jafarov](https://github.com/num8er) - creator and maintainer
