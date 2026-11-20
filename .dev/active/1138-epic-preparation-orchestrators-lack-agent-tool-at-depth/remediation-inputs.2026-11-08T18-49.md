# Remediation Inputs — Issue 1138

Timestamp: 2026-11-08T18-49
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Source review artifacts:
- `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/policy-audit.2026-11-08T18-49.md`
- `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/code-review.2026-11-08T18-49.md`
- `docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/feature-audit.2026-11-08T18-49.md`
Head reviewed: `88cbdb8eaf22197b1e74ba262affcbeb019e9b12` (merge base `a90d522c6ac239bca858d7bc800d52860e823219`; `origin/main` at `72e8b299c8ce99adce7db335e936974e8119493b`)
Prior cycle: remediation cycle 1 (light), inputs `remediation-inputs.2026-11-08T18-16.md`. F1 and P0-T2 are closed and verified. The path is full because the prior cycle was light.

## Findings requiring remediation

### F2 — Merge conflict with origin/main in the frozen-surface pin module

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The branch can merge origin/main locally, resolve one file, recompute one digest from the merged file, and re-run the existing gates; no external party, owner decision, or CI result is needed.
Finding-Scope: contained

- File: `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES` and the comment block above it).
- Problem: after the merge base, `origin/main` merged PR #1140 (issue #1136), which re-baselined the `.claude/skills/epic-orchestrate/SKILL.md` digest and added a #1136 comment block in the same region this branch edited. `git merge-tree --write-tree --name-only origin/main HEAD` exits 1 with `CONFLICT (content)` in this file. A conflicting PR gets zero CI checks, so the S9 gate cannot pass. Both sides also changed `.claude/skills/epic-orchestrate/SKILL.md`; the auto-merged file's SHA-256 is `2e67dae3dd5a015693696125374e341f8c21963f36145bcf5fa8265ff8be924e` (computed from the merge-tree result tree), which equals neither side's pin, so choosing one side of the textual conflict leaves the pin test failing.
- Required change: merge `origin/main` into `bug/epic-subagent-nesting-depth`. In the pin module keep both the #1136 and #1138 comment blocks (state that the skill digest is the merged result of #1129, #1130, #1136, and #1138), keep the branch's `.claude/agents/epic-orchestrator.md` digest (`5ff9c66f58595fa91a1f568a18a0a5aae5d1736a9dd1b13a9bbbab459df7899c`; main did not change that file), and set the skill digest to the SHA-256 of the merged `.claude/skills/epic-orchestrate/SKILL.md` computed at the merged head. Do not change spec acceptance-criterion text.
- Verification required: Black, Ruff, and Pyright on the pin module; one `Invoke-PoshQCParallelTest` run with 0 failures (covers `NestingDepthContract.Tests.ps1` parity over the merged skill and brief files); one `pytest -n auto --cov --cov-branch` run with 0 failures, including `test_frozen_epic_surface_matches_pinned_baseline_digest`, `test_brief_copies_are_byte_identical`, and the push-down resource and pack-manifest tests; `git merge-tree --write-tree origin/main HEAD` exits 0 afterward.

## Non-remediation items (record only)

- Info: repo-wide pytest branch figure 94.36% versus 94.37% at baseline; the single differing arc (395 to 362) is in `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py`, which is not in the branch diff, and depends on subprocess timing. Not attributable to this branch; no changed-line regression.
- Info: a value above the Int64 range still gets the parse message; fail-closed.
- Info: the main-session fallback does not say how the main session obtains the coordinator's delegation prompt; spec non-goal.
- AC9 CI confirmation on the PR head is pending-CI, owned by the orchestrator at S9. It is not a finding.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run.
- Tests create no files and set no environment variables.
- Any commit makes this review stale, so a re-review follows.
