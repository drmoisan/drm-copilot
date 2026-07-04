# JSON Validator Remote-Schema Divergence (Accepted)

Timestamp: 2026-06-25T23-14

Scope: `extensions/drm-copilot/src/lib/validate/json-validator.ts` (F2 port of
`scripts/dev_tools/validate_json.py`).

## Accepted Divergence

The Python source resolves a document's `$schema` URI by fetching `http`/`https`
schemas over the network (via `urllib.request.urlopen`), caching them by SHA-256
under `.cache/schemas`, and optionally validating with the `jsonschema` library
when installed.

The in-process TypeScript port intentionally excludes remote-schema fetching and
the SHA-256 cache. `loadSchema` supports only:
- local relative `$schema` paths (resolved against the source file directory), and
- `file:` URIs.

For `http`/`https` (and any other unsupported scheme) the port throws the same
`Unsupported schema URI scheme: <scheme>` error the Python source raises for
unknown schemes.

## WhyFailingRunImpossible

A fail-before run that exercises a regression is not applicable here: the
divergence is a deliberate scope exclusion, not a defect. The MCP/extension path
that consumes this validator does not validate remote-schema JSON, so there is no
remote-fetch behavior to regress against. Network I/O is also prohibited in unit
tests by repository policy, so a remote-fetch test cannot exist in this suite.

## Alternative Proof

The unsupported-scheme behavior is asserted directly in
`extensions/drm-copilot/test/lib/validate/json-validator.test.ts`: a document
whose `$schema` is an `http`/`https` URI produces a `validation error (...)`
result whose message contains `Unsupported schema URI scheme: <scheme>`. The
local relative-path and `file:` resolution paths, the missing-schema-file error,
and the built-in schema-checker branches are covered by hermetic tests using an
injected in-memory `FileSystem`.

SearchScope: docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/regression-testing/
SearchPatterns: json-validator-remote-schema-divergence.*.md, fail-before-exception.*.md
SearchResult: this divergence note (json-validator-remote-schema-divergence.md)
