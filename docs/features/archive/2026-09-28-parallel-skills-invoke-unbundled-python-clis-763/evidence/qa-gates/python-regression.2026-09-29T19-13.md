# Python Regression (P9-T6)

Timestamp: 2026-09-29T19-13
Command: poetry run pytest -v <the 19 files of Appendix C3> tests/scripts/dev_tools/test_parallel_drift_parity.py tests/scripts/dev_tools/test_parallel_abandon_ba?h_parity.py ; poetry run pytest tests/scripts/dev_tools -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary (loop pass 4, the recorded result, on commit 0e41ad84):
- Named set (C3 plus the two new parity lanes): `1 failed, 290 passed in 1.38s`. Every node is
  PASSED except KL-510.
- Full run: `1 failed, 5287 passed, 6 skipped in 22.57s`. The only FAILED line is the KL-510 node.
- KL-510: STATE-ONLY
  - `FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  - assertion message: `Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a90ad325ab30cb89c-bcb36b66.json`
    (first two path components `.claude` and `state`)
  - `Bundle content differs from repo for:` appears on no output line (count 0 in both runs).
- The P0-T16 baseline failure set is empty; the only failure is the KL-510 node in case (b).
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` PASSED in the named set,
  including `test_orchestrate_skill_first_thirteen_headings_match_required_layout`.

## Loop pass 3 regression and fix

Pass 3's full run reported a second failure, not in the baseline:
`FAILED tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant`
with `the parallel-orchestrate procedure prescribes a command invocation no parallel-orchestrator Bash grant covers: ('parallel drift detection failed: ',)`.
The seam support parser (`prescribed_command_invocations` in
`tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py`) treats every inline code
span of two or more words that starts with a lowercase word as a command invocation, so the B22c
text's inline code span holding the stderr prefix read as a command. The cause was corrected in the
SKILL, not in the test: the prefix is now written in double quotes (`prefixed "parallel drift
detection failed: "`) on the same line, so the line count and meaning are unchanged, and the bundle
mirror was refreshed with cp (A5 `same=1`). Committed as `0e41ad84` and pushed; the Python loop
restarted at P9-T2 (pass 4: black `7 files left unchanged.`, ruff `All checks passed!`, pyright
`0 errors`), and the permission and surface contract suites passed (`39 passed`). This departs from
B22c's exact text by the delimiter only; the deviation is recorded here and in the completion report.
