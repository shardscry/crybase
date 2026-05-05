# CryBase

A Crystal client library for Couchbase.

> **Status:** early scaffold. The current `CryBase::CouchBase::Client` is a
> *dummy* that enumerates and TCP-probes every Couchbase service interface
> (KV, Query, Search, Analytics, Index, Eventing, Views, Management) over both
> plaintext and TLS ports. No protocol handshake is implemented yet.

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
```

## Contributing

1. Fork it (<https://github.com/num8er/crybase/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anar K. Jafarov](https://github.com/num8er) - creator and maintainer
