# Remediation Inputs — Issue 1156 (re-audit after remediation cycle 1)

Timestamp: 2026-11-14T05-56
Review-Verdict: PASS
Issue: 1156
Base: main
Merge-Base: 2c8dee6dd3a82f210561d9efe623767ae902de51
Reviewed-Head: 6bb6365d1bf4aafcbc958ebf2b9e295a22dc1a90
Source review artifacts:
- `docs/features/active/regenerate-after-integration-merge-1156/policy-audit.2026-11-14T05-56.md`
- `docs/features/active/regenerate-after-integration-merge-1156/code-review.2026-11-14T05-56.md`
- `docs/features/active/regenerate-after-integration-merge-1156/feature-audit.2026-11-14T05-56.md`

## Disposition

No finding requires remediation. R1 (tier entry for `.claude/lib/regeneration`) and R2 (Windows shim start in the process seam default) from `remediation-inputs.2026-11-14T04-29.md` are closed. All 49 acceptance criteria evaluate PASS. The reviewer's Pester gate at the merged head passed (24724 tests, 0 failures, 95.94% repo-wide lines).

## Non-remediation notes

- Minor (code review CR-3): `Get-RegenerationProcessStartSpec` screens batch arguments but not the resolved batch path; a path holding `&` or `%` makes cmd.exe run a different command line (`evidence/other/process-start-probe.2026-11-14T05-56.md`).
- Minor (code review CR-4): the orchestrate skill config rules and the rules-file config paragraph do not state executable resolution or the Windows batch-argument refusal that `spec.md` now states.
- Minor (code review): the refusal table of `Invoke-RegenerationPath.ProcessStart.Tests.ps1` covers a space, a double quote, and `&` only.
- Warning (code review): `Invoke-RegenerationPath.ps1` and its bundle copy are 788 logical lines.
- These items are optional under OD-6 and do not gate the PR.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
