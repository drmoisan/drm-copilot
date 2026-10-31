# Preflight Fixes

Timestamp: 2026-10-31T00-04
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/plan.2026-10-30T18-40.md
Round: 2 (confirming single-pass preflight, preparation mode; no task executed, no checkbox changed)

## Fix 1

- Task: [P2-T3]
- Defect class: validator-blind unsatisfiable condition whose correction keeps the assertion's meaning (platform path separator).
- Before: the test case required that the `Source` of the `Get-DocsInitTemplate` row "ends in `templates/_docs-quality.yml`". The row builds `Source` with `Join-Path -Path $PSScriptRoot -ChildPath 'templates/_docs-quality.yml'`, and on Windows `Join-Path` returns the child path with `\` separators (observed on PowerShell 7.6.9: the result ends in `templates`, a backslash, then `_docs-quality.yml`). The suite runs with coverage on `windows-latest` in `poshqc / PowerShell QC`, so the case could not pass there.
- After: the case compares the `Source` value after normalizing path separators to `/`. The assertion still requires that the row's source is the committed template `templates/_docs-quality.yml`.
