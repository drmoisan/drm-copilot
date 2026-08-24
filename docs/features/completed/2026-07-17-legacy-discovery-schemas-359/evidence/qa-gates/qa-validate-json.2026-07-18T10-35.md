# QA Gate — JSON Governance (#359, P5-T5)

Timestamp: 2026-07-18T10-35
Command: `poetry run dev.validate-json`
EXIT_CODE: 0

Output Summary:
The governed set is discovered via the existing `examples/**/*.json` glob. All eight governed JSON files
validate cleanly (`--verbose` reports 8 `: ok` lines, 0 failures). The seven new conforming fixtures
under `examples/discovery/v1/` are discovered and validate against their schemas:

- examples/discovery/v1/coverage-ledger.example.json: ok
- examples/discovery/v1/evidence-reference.example.json: ok
- examples/discovery/v1/feature-contract.example.json: ok
- examples/discovery/v1/parity-matrix.example.json: ok
- examples/discovery/v1/product-decision-record.example.json: ok
- examples/discovery/v1/runtime-characterization-scenario.example.json: ok
- examples/discovery/v1/unspecified-behavior-record.example.json: ok

The pre-existing governed file (`docs/.../phase4-settings-pre.json`) continues to validate. Schema files
under `schemas/discovery/v1/` and non-conforming fixtures under `tests/fixtures/discovery_schemas/v1/`
remain intentionally ungoverned, so no meta-schema network fetch and no `.cache/` write is produced by
the discovery artifacts.
