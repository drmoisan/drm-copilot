# R3 Governed JSON Validation — dev.validate-json (#362, Remediation Cycle 1)

Timestamp: 2026-07-18T12-18
Command: poetry run dev.validate-json
EXIT_CODE: 0

Output Summary:
- The governed-glob validation (`docs/**/*.json` included, root `artifacts/**` excluded) passed with exit code 0.
- With `--verbose`, all seven `docs/discovery/templates/artifacts/*.template.json` files report `ok`, confirming their `$schema` values (`../../../../schemas/discovery/v1/<name>.schema.json`) now resolve via `validate_json._load_schema`'s no-scheme branch (`base_path.parent / uri`) to the merged #359 schemas at `schemas/discovery/v1/`, and that each instance validates against its resolved schema:
  - coverage-ledger.template.json: ok
  - evidence-reference.template.json: ok
  - feature-contract.template.json: ok
  - parity-matrix.template.json: ok
  - product-decision-record.template.json: ok
  - runtime-characterization-scenario.template.json: ok
  - unspecified-behavior-record.template.json: ok
- No governed JSON file failed validation.
