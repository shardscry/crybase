# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-05-05

### Added
- Initial library scaffold (`shard.yml`, source layout, spec suite).
- `CryBase::CouchBase::ConnectionString` parser supporting `couchbase://`,
  `couchbases://`, `http(s)://` schemes, comma-separated seed hosts, and
  explicit ports.
- `CryBase::CouchBase::Service` enum covering Data (KV), Query, Search,
  Analytics, Index, Eventing, Views, and Management — with plaintext and TLS
  default ports.
- `CryBase::CouchBase::Endpoint` value type describing a single `host:port`
  per service.
- Dummy `CryBase::CouchBase::Client` that enumerates every `(host × service)`
  endpoint and TCP-probes reachability across all interfaces. No Couchbase
  protocol handshake is performed yet.

[0.0.1]: https://github.com/num8er/crybase/releases/tag/v0.0.1
