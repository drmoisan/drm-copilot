# Remediation Cycle 1 Resolution (P5-T2)

Timestamp: 2026-10-16T05-44
Plan: remediation-plan.2026-10-16T03-45.md
CYCLE_BASE: b08496681062990d39ccc4e1a07767b9854701d3

- CR-N1: resolved - U1-ST rows for validate-discovery-artifact-gate.ps1 and validate-pr-author-output.ps1 added; both validators block with exit 2 for a statement-terminating .NET method exception (regression-testing/lastexitcode-fail-before.2026-10-16T05-10.md, regression-testing/statement-terminating-after.2026-10-16T05-21.md). No validator was changed (qa-gates/validators-unchanged-cycle1.2026-10-16T05-42.md).
- CR-N2: resolved - Invoke-ValidatorUnderTest saves and restores `$global:LASTEXITCODE`; fail-before in regression-testing/lastexitcode-fail-before.2026-10-16T05-10.md (2 U1-ST failures at the restore assertion), pass-after in regression-testing/statement-terminating-after.2026-10-16T05-21.md (MATCHED 13 FAILED 0).
- CR-N3: resolved - docs/engineering/claude-code-architecture.md line 237 now describes the PreToolUse deny decision with exit 0 and the exit-2 guard-load path (qa-gates/architecture-doc-tokens.2026-10-16T05-26.md); spec Out of Scope bullet updated.
- CR-N4: resolved - citation lines rewrapped to at most 120 characters in the helper, its mirror, and the test (qa-gates/help-rewrap.2026-10-16T05-24.md, qa-gates/citation-width.2026-10-16T05-41.md).
- CR-N5: deferred - optional halt-line variable; not in this cycle's scope.
- CR-N6: resolved before this cycle - HEAD CYCLE_BASE merges origin/main (commit b62a865f1).
- F1: awaiting CI at S9 - unchanged by this cycle; verified with AC14 coverage and AC15 on the PR head.
