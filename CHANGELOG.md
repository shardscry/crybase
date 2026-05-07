# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Binary-protocol KV client support for authenticated `get`, `set`, and
  `delete` operations against Couchbase Server.
- KV expiration updates through `touch`, plus atomic get-and-touch via
  `get(key, expiry:)`, on both `KV::Client` and `KV::Pool`.
- KV counter operations through `increment` and `decrement` on both
  `KV::Client` and `KV::Pool`.
- Couchbase vbucket hashing for document operations so KV writes are visible
  through Couchbase management and dashboard document lookup.
- `CryBase::CouchBase::Services::KV::Pool`, a fixed-size pool of authenticated
  KV clients with a default size of 10 connections.
- Real Couchbase integration specs and a GitHub Actions job that boots
  `couchbase:community-7.6.0`, initializes a bucket, and verifies KV behavior
  against a live server.
- Generated API documentation under `docs/`, plus a pre-commit hook step that
  refreshes it with deterministic project metadata.

### Changed
- `KV::Request` and `KV::Response` are now Crystal `record` value types.
- `KV::Response#success?` is defined by reopening the generated response
  struct after the `record` declaration.
- README now documents public modules, KV usage, connection pooling, generated
  docs, and hook setup.

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

[0.0.1]: https://github.com/shardscry/crybase/releases/tag/v0.0.1
