# QA Gate — Schema Domain-Neutrality and $ref Locality (#359, P1-T8)

Timestamp: 2026-07-18T10-12

## Prohibited-vocabulary scan

Command: `rg -i "taskmaster|tmw|outlook|vsto|email|task-management" schemas/discovery/v1/`
EXIT_CODE: 1

Output Summary:
Zero matches (ripgrep exit code 1 indicates no matches found). None of the seven schema documents
contains TaskMaster, TMW, Outlook, VSTO, email, or task-management vocabulary in any field name, enum
value, title, or description. The domain-neutrality invariant holds.

## $ref-locality scan

Command: Python traversal of every `$ref` value in the seven schema files asserting each begins with `#/`.
EXIT_CODE: 0

Output Summary:
- total_refs: 38
- nonlocal_refs: 0

Every `$ref` is an internal `#/$defs/...` reference. No cross-file `$ref` exists, satisfying the
self-contained-`$defs` rule. `check_schema(Draft202012Validator)` was also run over all seven schema
documents offline and raised no error (exit 0), confirming Draft 2020-12 meta-conformance.
