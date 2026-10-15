# Claude Bundle Parity After the Parser Copy (#841, P2-T9 and P2-T10)

Timestamp: 2026-10-10T09-24
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
EXIT_CODE: 0
Output Summary:
- Summary line: `============================= 14 passed in 0.17s ==============================`
- FAILED lines: none (zero FAILED or ERROR lines in the -v output)
- P2-T9 mirror pair: PAIR-SUMMARY pairs=1 unequal=0

Route: the pytest command ran exactly as written. Output was captured to SCRATCH and inspected; not committed.

## P2-T9 mirror copy (recorded here; P2-T9 has no artifact of its own)

- Copy command: `cp .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (the plan's `cp` route; tool permissions allowed it).
- ROUTE_SUBSTITUTION: the acceptance command `sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1 <pair>` was replaced by the A4 substitute `git hash-object <source> <mirror>`.
- `git hash-object` output:
  - `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` 7c81ef17c6d627676472ca6311c8c1f4fdecdc5d
  - `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1` 7c81ef17c6d627676472ca6311c8c1f4fdecdc5d
- PAIR-SUMMARY pairs=1 unequal=0
