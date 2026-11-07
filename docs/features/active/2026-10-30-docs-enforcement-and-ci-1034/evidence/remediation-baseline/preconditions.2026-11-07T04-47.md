# Preconditions - Issue 1034 Remediation Cycle 3 (P0-T2)

Timestamp: 2026-11-07T04-47
Command: git fetch origin epic/documentation-estate-tooling-integration; git rev-parse EPIC_REF; git merge-base EPIC_REF HEAD; sh SCRATCH/issue-1034-p0.ps1 launcher reading the checkpoint, line counts and SHA-256 values
EXIT_CODE: 0
Output Summary: PASS. The route is `large` and the checkpoint is not terminal (`step7_status` is `in_progress`). The `.claude/hooks` and `.codex/hooks` copies of the four shared files are equal.

- `EPIC_REF` tip: `e1f4d2e54dd877929f28fd5496231304d3c5308f`
- `MERGE_BASE`: `e3e4aa551808a25c436337bf0dbcf298421a34d6`
- Route value: `path_selected` is `large`, and `route_id` is `large`

| File | Logical lines |
|---|---|
| `HOOK` | 325 |
| `HELPER` | 290 |
| `COMPOUND_SUITE` | 170 |
| `HELPER_SUITE` | 280 |

| Shared file | `.claude/hooks` SHA-256 | `.codex/hooks` SHA-256 | Equal |
|---|---|---|---|
| `hook-command-scanner.ps1` | 4E1796EDC01EBC272EF3F95D007C767BEB892C714C25055267BAE73A1C362460 | 4E1796EDC01EBC272EF3F95D007C767BEB892C714C25055267BAE73A1C362460 | yes |
| `hook-command-invocation.ps1` | A7EC95F8EA830740B40E0AB7C2556187CB1F32154ED12E9BD7BC00EB2D37665E | A7EC95F8EA830740B40E0AB7C2556187CB1F32154ED12E9BD7BC00EB2D37665E | yes |
| `hook-command-payload.ps1` | 8C833C86CC2E5F742E69935576257D71E876380CE1FBA1D3DA291134A2A439EE | 8C833C86CC2E5F742E69935576257D71E876380CE1FBA1D3DA291134A2A439EE | yes |
| `enforce-epic-merge-gate-command.ps1` | E34EAD45920FCE5AD5019A9C7334EF79B0CCF8FB7D0C21957EDC678B545F1921 | E34EAD45920FCE5AD5019A9C7334EF79B0CCF8FB7D0C21957EDC678B545F1921 | yes |
