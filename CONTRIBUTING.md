# Contributing to CryBase

Thanks for your interest in CryBase. This document explains how to set up
the project, the conventions we follow, and how to send a change for review.

By participating in this project you agree to abide by the
[Code of Conduct](CODE_OF_CONDUCT.md).

---

## Getting set up

You'll need [Crystal](https://crystal-lang.org/install/) `>= 1.20.1`.

```sh
git clone https://github.com/num8er/crybase.git
cd crybase
shards install
crystal spec
```

A local Couchbase Server is **not** required for the test suite — the
current `CryBase::CouchBase::Client` is a TCP-probing dummy and the specs
are pure unit tests. If you do want to exercise the probe end-to-end:

```sh
docker run -d --name couchbase -p 8091-8096:8091-8096 -p 11210-11211:11210-11211 couchbase:enterprise
```

---

## Workflow

1. **Open an issue first** for non-trivial changes so we can align on scope
   before you write code. Use the issue templates in
   [`.github/ISSUE_TEMPLATE`](.github/ISSUE_TEMPLATE).
2. **Fork & branch.** Branch names like `feat/query-service`,
   `fix/tls-port-mapping`, `docs/readme` are appreciated.
3. **Write tests.** Every new public API or bug fix should come with a spec.
4. **Keep PRs focused.** Smaller PRs ship faster than mega-PRs.

---

## Project conventions

These are non-obvious rules the project follows. They override defaults
you might be used to from other Crystal codebases.

### File & namespace layout

- One **flat** namespace declaration per file
  (`module CryBase::CouchBase`) — never deeply nested module blocks.
- The folder tree mirrors the namespace:
  `CryBase::CouchBase::Client` lives in
  `src/crybase/couchbase/client.cr`.
- Specs mirror the source tree under `spec/`.

### Aliases

When a file references the same fully-qualified type more than a couple
of times, declare an alias near the top:

```crystal
private alias Client = CryBase::CouchBase::Client
private alias Service = CryBase::CouchBase::Service
```

Use `private alias` in spec/source files so the binding is scoped to the
file and won't collide with another file that aliases the same short
name.

### Style

Run the formatter before committing:

```sh
crystal tool format
```

Default to writing **no comments**. Add one only when the *why* is
non-obvious (a hidden constraint, a workaround, a subtle invariant).
Don't comment what well-named identifiers already say.

---

## Testing

```sh
crystal spec                                       # whole suite
crystal spec spec/crybase/couchbase/client_spec.cr # single file
crystal spec -e "uses TLS ports"                   # by example name
```

CI runs `crystal tool format --check` and `crystal spec` on every PR.

---

## Commit messages

We follow a relaxed [Conventional Commits](https://www.conventionalcommits.org/)
style:

```
feat(client): add Query service handshake
fix(connection_string): treat trailing slash as empty path
docs(readme): document TLS port table
```

Common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.

---

## Releasing

Maintainers only:

1. Bump `version:` in `shard.yml` and `VERSION` in
   `src/crybase/version.cr`.
2. Add a section to `CHANGELOG.md` for the new version.
3. Tag the release: `git tag v0.0.x && git push --tags`.
4. Create a GitHub release pointing at the tag.

---

## Questions?

- Bug or concrete feature → [open an issue](https://github.com/num8er/crybase/issues/new/choose).
- Open-ended question → start a [Discussion](https://github.com/num8er/crybase/discussions).
