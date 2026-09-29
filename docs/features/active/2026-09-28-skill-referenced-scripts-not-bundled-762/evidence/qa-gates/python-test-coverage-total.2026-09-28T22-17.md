# Python Test with Coverage, dev_tools Tree (P9-T5)

Timestamp: 2026-09-28T22-17
Command: poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov-762-final.json ; poetry run python SCRATCH/py-cov-files.py SCRATCH/cov-762-final.json TOTAL
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Pytest summary (final accepted run, after the P9-T6 file-size loop restart): `1 failed, 5251 passed, 6 skipped in 61.20s (0:01:01)`. The collected total is 5258, which equals the P0-T14 collected total of 5216 plus the P9-T4 node count of 42.
- term-missing TOTAL row: `TOTAL                                                               16307   1124   5924    582    91%`
- A7: `COVERAGE file=TOTAL LinePercent=93.11 BranchPercent=85.92` (baseline P0-T14: 93.08 / 85.86). Both meet line >= 85 and branch >= 75, with no regression.
- KL-510: STATE-ONLY
  - Only failing node: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  - Assertion message (verbatim): `AssertionError: Repo file missing from bundle: .claude\state\current-session-id`
  - No output line contains "Bundle content differs from repo for:".

## Loop restart recorded (first P9-T5 attempt, not accepted)

The first run of this command printed `2 failed, 5250 passed, 6 skipped`. The second failure was
`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-14d6bf2f...]`.
That test pins the SHA-256 of `.claude/skills/epic-orchestrate/SKILL.md`, and the P3-T9 edit (the AC3
fix) changed that digest. Following the file's documented re-baselining precedent (issues #559, #673,
#663), `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` was re-baselined to
`620183f57a337dedf6158d61264b2257d012762454a9af0b3b6f059ff79ab00b`, with an issue #762 comment. The
agent-file pin is unchanged. No other file pins the old digests (`git grep` over the tree, excluding
docs/features, returned exit 1).

The first attempt at that edit was denied by the Python batch-budget PreToolUse hook ("Python per-batch
budget exceeded: test file cap is 3 and is already full ... Split the work into a new batch, ..."). A new
one-file remediation batch was opened with the plan's batch-start script A8
(`sh SCRATCH/run-ps.sh SCRATCH/reset-batch-budget.ps1 -Kind python` printed `RESET removed=1`), and the
edit was then applied. The cap was not raised.

The Python loop then restarted at P9-T1. black printed `6 files left unchanged.`, ruff printed
`All checks passed!`, pyright reported `0 errors` on the six files and on both trees, and P9-T4 gave
42 passed. The re-baselined expectations file also passes black --check and ruff.
`test_parallel_orchestrator_surface_contracts.py` gave 36 passed. P6-T1 (inside P9-T4) passed 5 of 5,
and the P6-T3 re-run printed `SWEEP-EXIT=1`.
