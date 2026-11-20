# Skill Text and Brief Tests (Issue #1026, P7-T5)

Timestamp: 2026-11-03T13-42
Command: sh SCRATCH/issue-1026-ps.sh SCRATCH/issue-1026-pester.txt tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1; sh SCRATCH/issue-1026-p7.sh (poetry run pytest -p no:cacheprovider -q --no-cov -rA tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py tests/scripts/dev_tools/test_single_pass_preflight_contracts.py)
EXIT_CODE: 0
Output Summary: SkillText suite: JUnit testcases 10, passed 10, failed 0 (Discovery-guard compliance 0 findings). pytest over the three brief-reading modules: 63 passed, 0 failed, including test_execution_environment_brief_contracts.py::test_brief_copies_are_byte_identical PASSED and test_execution_environment_brief_contracts.py::test_brief_has_no_g11_or_g12_findings PASSED.

Supporting observations:

- P7-T1: `git diff -U0 MERGE_BASE -- .claude/skills/cleanup-merged-worktrees/SKILL.md` shows hunks only in step 2, step 3, step 4, and `## Sanctioned Removal Manifest`; no hunk contains the step 5 merge-queue text, and the fragment `When \`main\` uses a merge queue (issue #952), the queue tests the merged` is still present once.
- P7-T2: `## Hook Execution Context` of the brief gains the two bullets naming `hook-cleanup-context.ps1` (cleanup legs) and `Get-OrchestrationGateTemporaryRoot` (scratch rule).
- P7-T3: SHA256 of all six brief copies is equal (`60d1b4c6...`, 6 of 6), at `.claude/skills/`, `.agents/skills/`, `.github/skills/`, and the three bundle roots.
- Disposition of `test_discovery_documentation_contracts.py` and `test_single_pass_preflight_contracts.py`: unchanged, both pass.
