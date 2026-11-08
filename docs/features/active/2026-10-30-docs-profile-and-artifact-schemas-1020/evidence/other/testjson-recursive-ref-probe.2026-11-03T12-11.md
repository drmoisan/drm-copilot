# Test-Json Recursive Reference Probe (escalation, found during Phase 1)

Timestamp: 2026-11-03T12-11
Command: sh SCRATCH/issue-1020-probe.sh, sh SCRATCH/issue-1020-probe-flat.sh, and sh SCRATCH/issue-1020-run.sh issue-1020-probe3.ps1 (PowerShell 7.6.9, local host)
EXIT_CODE: 0
Output Summary: In PowerShell 7.6.9, Test-Json -Schema throws `Json.Schema.JsonSchemaException: Encountered circular reference at schema location ...#/$defs/<name>` for any schema whose `$defs` entry references itself, so every composed docs artifact schema (all reach `common.json-value` through `extensions`) returns False for its committed example. With `common.json-value` replaced in memory by the equivalent empty schema `{}`, all seven examples validate (True). The envelope schema, which does not reach `extensions`, validates as written.

## Observations

| Case (minimal schema) | Test-Json result |
|---|---|
| `$defs` recursion through `items` (`#/$defs/jv`), with or without a root `$id` (`urn:` or `https:`) | False, circular-reference exception |
| `$defs` recursion through `additionalProperties` only, or through `items` only | False, circular-reference exception |
| `$defs` recursion with a dotted name (`#/$defs/common.jv`) | False, circular-reference exception |
| `$anchor` recursion (`#jv`) | False, circular-reference exception |
| Root self reference (`"$ref": "#"`) | True |
| `$dynamicRef` to a root `$dynamicAnchor` | True |

| Composed schema and committed example | As written | `common.json-value` replaced by `{}` in memory |
|---|---|---|
| docs-profile | False | True |
| surface-inventory-snapshot | False | True |
| docs-coverage-ledger | False | True |
| docs-parity-matrix | False | True |
| docs-evidence-pin | False | True |
| docs-validation-receipt | False | True |
| docs-command-envelope | True | True |

## Impact on the plan

- `schemas/docs/v1/common.schema.json` copies `extensions` and its transitive `json-value` from `schemas/discovery/v2/common.schema.json` unchanged, as [P1-T2] and spec AC "Each docs common definition copied from discovery v2 common equals the discovery definition as canonical JSON, except `timestamp`" require (parity verified: every copied definition except `timestamp` is equal as canonical JSON).
- `json-value` is recursive, so on this host the [P3-T4] condition "each of the seven examples makes `Test-Json` return `True` against its composed schema" (spec AC S1) cannot pass with that copy, and `Test-DocsArtifactText` would fall through to `DOCS_SCHEMA_INVALID` for every valid artifact.
- The `windows-latest` runner's PowerShell version and bundled JsonSchema.Net may behave differently; this was not measured.
- `json-value` accepts every JSON value (scalars, arrays of JSON values, objects of JSON values), so an empty schema `{}` is semantically equivalent; adopting it, or a composition step that rewrites the recursive definition, changes spec AC S13 (parity exception list) or the spec `#### Schema composition` steps. That is a requirements decision for the planner or owner and is not made in this run. Phases 0 to 2 do not depend on it.
