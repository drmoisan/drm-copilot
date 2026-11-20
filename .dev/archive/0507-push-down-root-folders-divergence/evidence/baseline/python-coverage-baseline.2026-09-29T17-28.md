# Baseline Python Coverage (P0-T15)

Timestamp: 2026-09-29T17-28
Command: poetry run pytest tests/scripts/dev_tools -k push_down_claude --cov=scripts.dev_tools.push_down_claude_customizations --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/coverage-baseline.json
EXIT_CODE: 0

Output Summary:
- Exit code 0; `62 passed, 5196 deselected in 1.83s` (pass count = 62).
- Terminal table row `scripts\dev_tools\push_down_claude_customizations.py`: Stmts 66, Miss 5, Branch 8, BrPart 0, Cover 91%, Missing 86-95.
- From coverage-baseline.json (`files` key normalized `\` -> `/`, entry `scripts/dev_tools/push_down_claude_customizations.py`):
  - Line percentage: covered_lines 61 / num_statements 66 = 92.42%
  - Branch percentage: covered_branches 6 / num_branches 8 = 75.00%
- The five new modules (push_down_claude_routing_merge, push_down_claude_blast_radius_derive_manifests, push_down_claude_blast_radius_derive_core, push_down_claude_blast_radius_derive, push_down_claude_destination_writes) have no baseline because they do not yet exist.
