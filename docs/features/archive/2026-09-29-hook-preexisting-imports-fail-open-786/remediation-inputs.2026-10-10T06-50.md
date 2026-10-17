# Remediation Inputs: Hook pre-existing imports fail open (#786, bundled #792)

- Review timestamp: 2026-10-10T06-50
- Base: `origin/epic/enforcement-hook-precision-integration` (merge base `86e457a003be0c60b65e01156e4cccd6495dfd1a`)
- Head: `76559b6df` (`origin/bug/hook-preexisting-imports-fail-open-exec-786`)
- Verdict: REMEDIATION_REQUIRED (one autonomous blocking finding, one human-decision blocking finding)

## Source artifacts

- policy-audit-path: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/policy-audit.2026-10-10T06-50.md
- code-review-path: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/code-review.2026-10-10T06-50.md
- feature-audit-path: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/feature-audit.2026-10-10T06-50.md
- PR context: artifacts/pr_context.summary.txt, artifacts/pr_context.appendix.txt (Head SHA `76559b6df`)

## Remediation-required findings

### RF-1 PowerShell coverage gate (AC-24) — Blocking

- Remediability: autonomous
- Remediability-Evidence: the gap is reproducible in the repository's standard full run (in-repo R-PESTER at 06:08 and the MCP route at 06:29 report the same values); the investigation and any test changes are within the repository. If the root cause cannot be removed by test changes, escalate the measurement route as `human_decision_required`.
- Facts:
  - Below 85% line coverage in the full run: `.codex/hooks/enforce-epic-child-worktree-binding.ps1` 74.70, `.codex/hooks/enforce-epic-planning-only.ps1` 82.25, `.codex/hooks/hook-dependency-guard.ps1` 57.89, `.codex/hooks/validate-bash.ps1` 80.25.
  - Regressions against baseline: the four files above (child-worktree-binding 95.62, planning-only 95.71, validate-bash 100.00 at baseline), `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` 100.00 -> 86.55, `.codex/hooks/enforce-epic-merge-gate.ps1` 98.68 -> 98.09.
  - Changed non-bootstrap lines reported uncovered: `.codex/hooks/hook-dependency-guard.ps1:103-111`, `.codex/hooks/validate-bash.ps1:305-306`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:467-468`.
  - The covering tests pass; the byte-identical Claude helper copy is 100%.
- Required remediation:
  1. Bisect the full run to identify what removes attribution for these Codex files. Candidates: the seven `Import-Module -Global` pre-loads added in `b83b121f9` (RS-10); identically named helper functions defined by the Claude and Codex helper copies in one session; any remaining `[scriptblock]::Create` mock bodies; module instances left by the SpecialCases C4 rows.
  2. Remove the cause in test code (or in the duplicate `OrchestratorState.psm1` import of `validate-orchestrator-output.ps1` if it is implicated) so that the standard `Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` run reports every changed production file at or above 85% with no regression.
  3. If no in-repository cause can be removed, record the finding in `evidence/other/deviations.md` and request an operator decision on a per-surface coverage pass; do not lower the threshold or exclude files (Coverage Exclusion Policy).
  4. Re-record `evidence/qa-gates/final-pester-coverage.md` and `coverage-comparison.md` (include a baseline row for `.claude/hooks/validate-orchestrator-output-resolution.ps1`), then check off AC-24.

### RF-2 AC-6 named-exemption edges acquire the payload first — Blocking

- Remediability: human_decision_required
- Remediability-Evidence: the 2026-10-09 operator decision keeps the H1 to H6 handlers unchanged and amends only AC-11 and AC-12; AC-6 still requires that the entry point call no HookPayload function on any direct-edge failure. For H1, BF-1 requires the payload to classify the write, so AC-6 as written cannot be met without converting H1.
- Facts: for the `feature-folder-resolution.ps1` edge of H1 (`enforce-feature-folder-order.ps1`), H4 (`enforce-epic-wave-barrier.ps1`), H5 (`enforce-parallel-drift-gate.ps1`), and H6 (`enforce-parallel-cohort-barrier.ps1`), the entry point reads the payload before the scoped handler denies. Every such failure denies with the existing token naming the dependency (FailClosed proofs).
- Required remediation (operator chooses one):
  1. Amend AC-6 in `spec.md` (Change Log entry) to exclude the named-exemption edges, which are covered by their fail-closed proofs; then check off AC-6.
  2. Or require pre-payload checks for H4 to H6 (their deny is unconditional) and amend AC-6 for H1 only.

## Non-blocking items (for the PR body or a follow-up)

- Plan check [P9-T7] (c) counts `python` in reason-prefix literals; revise it to match invocation forms. AC-26 is met.
- Add a leading-token assertion to `validate-orchestrator-output.WaveBarrier.Tests.ps1:246` and state in the PR body that the H8 block now uses `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` for every artifact type.
- Remove the duplicate `OrchestratorState.psm1` import in `validate-orchestrator-output.ps1`.
- Record in `fail-closed-proof.H8.md` that the CONVERT decision rests on the cited exit-1 tail.
- Remove stale variable resets in `hook-import-failure-exemptions.FailClosed.Tests.ps1:453,468` and the always-true conditionals in H4 to H6 catches.
