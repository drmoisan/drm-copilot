# Preflight Fixes: Remediation Cycle 1 (#1035)

Timestamp: 2026-11-17T12-26
Plan: remediation-plan.2026-11-17T11-41.md
Mode: proportionate remediation cycle, single-pass preflight followed by execution in the same delegation.
Validator: env -u VIRTUAL_ENV poetry -C <worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan> (branch-current Python CLI), EXIT_CODE 0 before and after the fixes.

## Fixes

1. [P0-T1] Literal-formatting defect (validator-blind; meaning unchanged). The task asked for "the PoshQC formatter in check-only mode". `Invoke-PoshQCFormat` has no check switch; the established non-writing form used by this feature's earlier static gates is a no-op `-WriteFile` seam with the `Formatted:` log-line count as the drift count. Task text now names that form.
2. [P3-T1] Same defect class and same correction for the final static loop ("formatter check" replaced by the non-writing `-WriteFile` seam form counting `Formatted:` lines).

## Design check (no defect)

- F1 rows map to tasks: copy_research_to_issue P1-T1; plan_progress_report P1-T2; atomic_executor.cli P1-T3; enforce-completion-helpers P1-T4; epic-child-launch-contract P1-T5; link-feature-docs P1-T6; new-potential-entry P1-T7; authorize-root-epic-invocation P2-T1; epic-child-launch-runtime P2-T2. Each is verified by the per-file rows of P3-T2, P3-T3 and P3-T5.
- F1 parity rule maps to the bundle copy and hash checks of P2-T1 and P2-T2 and the unchanged-file conditions of P1-T7.
- F2 maps to P3-T2 (pytest), P3-T3 (Pester), P3-T4 (root and extension Jest), each after the last commit of its language.
- Batch budget: the worktree checkpoint selects route `large` and is not terminal, so the four production PowerShell edits of Phase 2 are exempt.
- The `& $<param>` calls of the new `[scriptblock]` parameters in `.codex/hooks/authorize-root-epic-invocation.ps1` fall under carve-out (a) of `Get-PythonInvocationFinding` (a `[scriptblock]` parameter), so the no-Python guard reports no finding.
