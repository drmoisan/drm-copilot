# Dependency Gate — Issue #1006

Timestamp: 2026-10-31T15-01
Command: git fetch origin; git merge-base --is-ancestor origin/main HEAD; poetry run python SCRATCH/issue-1013-p0t1.py (reads each observable through git show at origin/main and HEAD)
EXIT_CODE: 0
Output Summary: all six observable rows PRESENT; ancestry exit 0; Merge: none.

| Observable | origin/main | HEAD |
|---|---|---|
| `def is_generic_contract_token` in `scripts/dev_tools/_blast_radius_token_shapes.py` | PRESENT | PRESENT |
| `SHARED_SURFACES_DEMOTE_KEY` defined in `scripts/dev_tools/push_down_claude_blast_radius_overlay.py` | PRESENT | PRESENT |
| `config/blast-radius.json`: `quality-tiers.yml` in `conflict_tolerance.append_only_paths`, not in `shared_surfaces` | PRESENT | PRESENT |

- Ancestry (`git merge-base --is-ancestor origin/main HEAD`): exit 0
- Merge: none
- Result: PASS
