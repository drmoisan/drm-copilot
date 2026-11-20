# Remediation Inputs: parallel-only-test-gates-and-leak-scan (#1094)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: design

Timestamp: 2026-11-07T05-01
Branch: `feature/parallel-only-test-gates-and-leak-scan-1094`, head `6b8c3640a48e0ea7f1c2c80e8bb89201d8a87164`
Base for diffs: `9a19be8e72ea479212e2e43c3ad766afb270fae6` (merge base with `origin/main`)

Mode note: the cycle is design because the files below are outside the branch diff. No acceptance criterion changes.

Audit artifacts:

- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/policy-audit.2026-11-07T05-01.md`
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/code-review.2026-11-07T05-01.md`
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/feature-audit.2026-11-07T05-01.md`

RF-1 to RF-5 from the earlier inputs are closed.

## RF-6: the coverage stop hooks reject the record the template prescribes

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: A narrow change to two hook scripts, their bundle copies, and their tests; no acceptance criterion changes, and no owner input or external system is required to apply it. The spec calls this item text and contract tests only, so the plan records the hook change in spec `## Constraints & Risks`; the hook is not on the spec out-of-scope list.

This finding does not concern an absent run. No baseline run is required or to be added.

Files:

- `.claude/hooks/validate-feature-review-coverage-rules.ps1`: `Test-LanguageCoverageRow`, the `$narrowingPattern` loop.
- `.codex/hooks/validate-feature-review-coverage.ps1`: the same pattern.
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-rules.ps1`: bundle copy.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1`: bundle copy.
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` and `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, or their sibling suites.

Current behavior: the hook rejects any line outside `## Rejected Scope Narrowing` that holds a changed-language label, a coverage word, and `N/A`. These prescribed lines match:

- `- PowerShell baseline coverage artifact: N/A - no pre-change run`
- `- TypeScript baseline coverage artifact: N/A - no pre-change run`
- `- <Language>: Baseline: N/A - no pre-change run -> Post-change: <percent>. Change: N/A. ...`

The real hook, run from the item worktree on `policy-audit.2026-11-07T04-20.md`, exits 2. It exits 2 again with `stop_hook_active` true, because the condition is classed repairable.

Expected behavior:

- The `N/A - no pre-change run` record, and `Change: N/A` on a comparison line that carries that record, are not narrowing.
- Every other narrowing form stays rejected, including `N/A - out of scope`, `not applicable`, `UNVERIFIED`, `informational only`, and a bare `N/A` on a coverage row such as `Python coverage N/A`.
- Both hooks behave the same, and each bundle copy equals its source.

Add tests that call the rule on the exact lines the template prescribes, for PowerShell, TypeScript, and Python, and tests that the other forms stay rejected.

## Verification

- Run the real hook from the item worktree on an audit filled from the template, with a SubagentStop payload on stdin, and confirm exit 0. Keep that output as evidence in `evidence/qa-gates/`.
- One `Invoke-PoshQCParallelTest` run after the fix, and one `pytest -n auto` run if a Python-read file changes, each re-run only after a fix. Set `PYTHONPATH` to the worktree `packages/discovery-runtime/src` for pytest, as in the previous cycles.
- The hook files are production PowerShell, so read their per-file line coverage from the gate run against the 85% threshold.
- Confirm that any bundle or hook parity suite covers the four files, and that each pair is equal in the task that edits it.
- The Jest gate need not re-run unless a TypeScript file changes; if `coverage/lcov.info` is absent at reaudit, run it once.

## Do Not

- Do not change the template record, the `feature-review-workflow` wording, or criterion 9.
- Do not widen the rule to accept `N/A` in general, and do not remove `\bN/A\b` from the pattern.
- Do not edit `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell`, or `.agents/skills/python`.
- Do not change the policy-audit validators, CI workflows, `scripts/powershell/PoshQC/`, `.vscode/tasks.json`, or the Python tools deferred to #1096.
- Do not add a leak scan or a serial, shuffled, reversed-order, comparison, or pre-change run.
- Do not remove tool-permission entries.
