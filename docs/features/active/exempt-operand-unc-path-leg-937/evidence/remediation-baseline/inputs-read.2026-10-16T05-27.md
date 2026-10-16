# Remediation Cycle 1 Inputs Read (issue #937)

Timestamp: 2026-10-16T05-27
Task: P0-T2 (remediation-plan.2026-10-16T03-39.md)

Files Read:

1. `docs/features/active/exempt-operand-unc-path-leg-937/remediation-inputs.2026-10-16T03-39.md` (entire file)
2. `docs/features/active/exempt-operand-unc-path-leg-937/code-review.2026-10-16T03-39.md`
3. `docs/features/active/exempt-operand-unc-path-leg-937/policy-audit.2026-10-16T03-39.md`
4. `docs/features/active/exempt-operand-unc-path-leg-937/feature-audit.2026-10-16T03-39.md`
5. `docs/features/active/exempt-operand-unc-path-leg-937/spec.md`
6. `docs/features/active/exempt-operand-unc-path-leg-937/plan.2026-10-15T17-45.md`

Orchestrator Scope Dispositions (cycle 1), quoted verbatim from the remediation inputs:

1. - RI-1: required (blocking, autonomous).
2. - RI-2 (CR-1): required. Fail closed on surrounding whitespace in the R1 path leg.
3. - RI-3 (CR-3): required. Complete the U30 assertions.
4. - RI-4 (CR-2): required. `file:` URI spellings (`file:///C:/wt/a.ps1`, `file://server/share/a.ps1`) and `~`-prefixed spellings (`~/wt/a.ps1`, `~\wt\a.ps1`) take the relative fallback to the session root, which is the misresolution class #937 fixes. Extend the non-local check in the R1 loop so these deny with `path-not-local`, with expect-fail rows first on both surfaces.
5. - RI-5 (CR-4): required. A single-backslash root-relative spelling (`\wt\a.ps1`, current-drive-rooted on Windows) cannot be resolved to a local absolute path deterministically. Deny it with `path-not-local` through the non-local check, without editing `OrchestrationTargetAbsolutePattern` (spec Non-Goal kept). A single forward-slash POSIX absolute path (`/wt/a.ps1`) stays resolvable.
6. - RI-6 (CR-6): required. Wrap the 11 added test lines that exceed 120 characters, without altering row names or values.
7. - PA-1 / CR-5 (P3-T12 report-row variance in the unchanged `WorktreeTargetResolution.psm1`): accepted plan deviation; unrelated to the #937 change surface; not fixed in this item.
8. - CR-7 (single-feature fallback in `Resolve-WorktreeOperandTarget`): unrelated module with documented fallback semantics; not fixed in this item.
