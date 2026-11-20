# Remediation Inputs: #990 related follow-up (cycle 2)

- Timestamp: 2026-10-28T23-26
- Branch: `feature/tiered-file-size-policy-500-700-800-990` at `abb51cc69b4096ab367cc4fe708ff6cabf6dea03`
- Base: `main`, merge base `a7a928d59fd52610c1a627448c8fffac106b23c5`
- Opened by: orchestrator. The re-audit `code-review.2026-10-28T23-25.md` returned AWAITING_CI and left one related non-blocking finding open. Repository practice fixes related follow-ups inside the item with a remediation cycle before merge.

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

## Source audit artifacts

- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/code-review.2026-10-28T23-25.md`
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/feature-audit.2026-10-28T23-25.md`
- `docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/policy-audit.2026-10-28T23-25.md`

## Findings

### CR-M1 - Excluded directory-name list duplicated between the repository gate and the module

- Severity: Blocking (promoted by the orchestrator from the review's Minor row so that this cycle fixes it before merge)
- Remediability: autonomous
- Location: `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` (its own excluded-segment list used by the directory traversal) and `.claude/lib/file-size-policy/FileSizePolicy.psm1` (`Test-FileSizeCoveredPath` excluded segments).
- Issue: the gate suite keeps its own copy of the excluded directory names. If someone edits one list and not the other, the traversal and the covered-path rule disagree.
- Required change: make the module the single source of the excluded segment names. Expose them from `FileSizePolicy.psm1` (for example through a small exported accessor, or through `Get-FileSizePolicyLimit`-style data), and have the gate traversal consume that value instead of its own literal. Mirror the module change byte-identically to the Codex twin `.codex/hooks/file-size-policy.ps1` and to both bundle copies so that the function-level parity test still passes. Add or adjust a unit test asserting the accessor's value. Keep every touched file under 500 lines.
- Verification: the repository gate suite, `FileSizePolicy.Tests.ps1`, the Codex twin parity suite `tests/scripts/codex-hooks/file-size-policy.Tests.ps1`, `FileSizePolicy.Manifest.Tests.ps1`, and the push-down contract tests all pass. The final coverage evidence comes from a full `tests/scripts` Pester run.

### FA-B1 - AC7 awaiting CI on the PR head

- Severity: Blocking
- Remediability: awaiting_ci
- Carried forward unchanged. It is resolved at S9 by the item's own orchestrator run. Plan no work for it.
