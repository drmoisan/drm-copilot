# Remediation Inputs: Development-Docs Root Resolver and Feature-Folder Name Parser (#1035)

Review-Verdict: PASS

- Feature folder: `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035`
- Branch: `feature/dev-docs-root-resolver-phase1-1035` (reviewed head `8ef56f9c7082bfdc79e2bb1c69e2f1bf10aabdef`; PR base `epic/shared-agent-harness-layer-integration`, merge base `7ebf1347dd8fb86613d40e66461fa5ad64a07cfb`)
- Review artifacts: `policy-audit.2026-11-17T16-03.md`, `code-review.2026-11-17T16-03.md`, `feature-audit.2026-11-17T16-03.md` in this folder.
- This file supersedes `remediation-inputs.2026-11-17T11-41.md`: findings F1 and F2 from that review are closed, and the re-audit records no finding that requires remediation.

## Findings

None.

## Non-Blocking Items (no action required for the verdict)

- Warning: six covered files at or above 700 logical lines (`EpicCrossDependency.psm1` 780 in three copies, `Invoke-ParallelAdmission.Tests.ps1` 756, `Invoke-ParallelAdmission.ps1` 711 in two copies).
- Minor CR-7: the hook entry line of `.codex/hooks/authorize-root-epic-invocation.ps1` reads stdin outside the try/catch of `Invoke-RootEpicInvocationHook`.
- Minor CR-2 and CR-3 (carried from the prior review).
- Pending CI (not findings): spec and user-story criteria for the full suites and the seven-stage toolchain, and DoD "Behavior matches acceptance criteria in all documented environments".
