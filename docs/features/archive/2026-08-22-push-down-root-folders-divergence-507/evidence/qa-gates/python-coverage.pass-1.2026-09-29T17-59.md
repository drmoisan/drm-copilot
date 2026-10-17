# Python Coverage for New and Changed Modules, Pass 1 (P8-T5, AC21)

Timestamp: 2026-09-29T17-59
Command: poetry run pytest tests/scripts/dev_tools -k push_down_claude --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_routing_merge --cov=scripts.dev_tools.push_down_claude_blast_radius_derive_manifests --cov=scripts.dev_tools.push_down_claude_blast_radius_derive_core --cov=scripts.dev_tools.push_down_claude_blast_radius_derive --cov=scripts.dev_tools.push_down_claude_destination_writes --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/coverage-final.json
EXIT_CODE: 0

Output Summary:
- Exit code 0; `194 passed, 5196 deselected in 2.41s`.
- Six module rows present. Terminal table (Stmts / Miss / Branch / BrPart / Cover / Missing) and JSON-derived percentages (`files` keys normalized `\` -> `/`):

| Module | Stmts | Miss | Branch | BrPart | Cover | Missing | Line % (covered/stmts) | Branch % (covered/branches) |
|---|---|---|---|---|---|---|---|---|
| scripts/dev_tools/push_down_claude_customizations.py (changed) | 69 | 5 | 8 | 0 | 91% | 100-109 | 64/69 = 92.75 | 6/8 = 75.00 |
| scripts/dev_tools/push_down_claude_routing_merge.py (new) | 44 | 0 | 18 | 0 | 100% | - | 44/44 = 100.00 | 18/18 = 100.00 |
| scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py (new) | 46 | 0 | 14 | 0 | 100% | - | 46/46 = 100.00 | 14/14 = 100.00 |
| scripts/dev_tools/push_down_claude_blast_radius_derive_core.py (new) | 61 | 0 | 16 | 0 | 100% | - | 61/61 = 100.00 | 16/16 = 100.00 |
| scripts/dev_tools/push_down_claude_blast_radius_derive.py (new) | 46 | 0 | 10 | 0 | 100% | - | 46/46 = 100.00 | 10/10 = 100.00 |
| scripts/dev_tools/push_down_claude_destination_writes.py (new) | 86 | 1 | 12 | 1 | 98% | 106 | 85/86 = 98.84 | 11/12 = 91.67 |

- TOTAL row: 352 statements, 6 missed, 78 branches, 1 partial, 98%.
- Acceptance: each of the five new modules has line % >= 85 and branch % >= 75 (minimum line 98.84, minimum branch 91.67).
- Uncovered line 106 of push_down_claude_destination_writes.py is the `path == root` branch of `_relative_posix` (returns `""`); the missing lines of push_down_claude_customizations.py (100-103, 109) are the pre-existing second dual-import fallback block (baseline Missing 86-95 at the pre-change line numbers).
