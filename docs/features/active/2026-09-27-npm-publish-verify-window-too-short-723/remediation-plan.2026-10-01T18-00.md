# npm-publish-verify-window-too-short (Remediation Plan, Cycle 1)

- **Issue:** #723
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-01T18-00
- **Status:** In Progress (Phases 0-2 executed except P2-T2; P2-T2 reaudit is performed by the orchestrator)
- **Version:** 0.1
- **Work Mode:** minor-audit
- **Complexity Band:** C1

**Evidence accounting rule:** Each evidence-producing task names its expected artifact path. Do not mark evidence-backed work complete without the artifact.

## Requirements Source

The sole acceptance-criteria source is the `## Acceptance Criteria` section (AC-1 through AC-6) of `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/issue.md`. The remediation input is `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/remediation-inputs.2026-10-01T18-00.md`, which cites `policy-audit.2026-10-01T18-00.md` in the same folder. No spec or user-story document exists for this item, and none may be created.

## Scope and Boundaries

- Single finding R1: the PowerShell coverage artifact is missing. Remediation is evidence-only: create one evidence artifact. No product, test, workflow, or runbook file changes.
- No production `.ps1` file changed on this branch. The only changed `.ps1` is the Pester test file `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`; see `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-no-source-change-check.md`.
- Format, lint, and test loops are not applicable to this remediation because no code, test, or workflow file changes. Those gates were already recorded green in the existing qa-gates artifacts and in the CI run named below. This plan adds no command tasks that cannot fail.
- Evidence location: all artifacts live under `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/` in canonical kinds only. The caller supplied no non-canonical path.

## Fixed Evidence Values (embedded; the executor does not select evidence)

Source: GitHub Actions run https://github.com/drmoisan/drm-copilot/actions/runs/36927150048, job "poshqc / PowerShell QC" (job id 110587188174), head 9a6e0aa7. Artifact name: `poshqc-test-results`. File: `powershell-coverage.xml` (JaCoCo-style report-level LINE counter), extracted by the orchestrator.

- LINE missed = 430, covered = 11353.
- Line coverage = 11353 / (430 + 11353) = 11353 / 11783 = 96.35 percent. Threshold: at least 85 percent. Result: meets threshold.
- Branch coverage: no branch metric exists for PowerShell (Pester exempt per `.claude/rules/general-unit-test.md`); no branch gate applies.
- Orchestrator download command: `gh run download 36927150048 --repo drmoisan/drm-copilot -n poshqc-test-results`, exit code 0.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in the order defined by the policy-compliance-order skill: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`.
  - Acceptance: each of the four files was opened in this session; the file list is recorded by P0-T2.
- [x] [P0-T2] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/remediation-baseline/phase0-instructions-read.md` listing every file read in P0-T1, in the order read.
  - Acceptance: the artifact contains a `Timestamp:` line, a `Policy Order:` line, and one list entry for each of the four files read in P0-T1.
- [x] [P0-T3] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/remediation-baseline/baseline-branch-state.md` recording the output of `git status --porcelain --branch`.
  - Acceptance: the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` that quotes the first output line beginning with two hash characters (the branch line), which names branch `bug/npm-publish-verify-window-too-short-723`.

### Phase 1 — Implementation (evidence-only remediation of R1)

- [x] [P1-T1] Create `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-powershell-coverage.md` recording the CI poshqc PowerShell coverage output using the values in the Fixed Evidence Values section of this plan.
  - The artifact must contain these fields: a `Timestamp:` line in ISO-8601 form; a `Command:` line stating `gh run download 36927150048 --repo drmoisan/drm-copilot -n poshqc-test-results`; the line `EXIT_CODE: 0`; and an `Output Summary:` block.
  - The `Output Summary:` block must state: artifact name `poshqc-test-results`, file `powershell-coverage.xml`, run https://github.com/drmoisan/drm-copilot/actions/runs/36927150048, job "poshqc / PowerShell QC" 110587188174, head 9a6e0aa7; LINE counter missed 430 and covered 11353; line coverage 11353/11783 = 96.35 percent against the 85 percent threshold; no branch metric exists for PowerShell (Pester exempt); no production `.ps1` file changed and the only changed `.ps1` is the test file, with a reference to `evidence/qa-gates/final-no-source-change-check.md`.
  - Acceptance: the file exists at the stated path, contains all four fields, and the `Output Summary:` quotes the literals "11353", "430", and "96.35".

### Phase 2 — Final QC Loop

Format, lint, type-check, and test loops are not applicable: no code, test, workflow, or runbook file changes in this remediation, and the already-green CI run named above covers the existing gates.

- [x] [P2-T1] Verify with the Grep tool that `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/evidence/qa-gates/final-powershell-coverage.md` contains the token "11353" (pattern `11353`, output mode content, path set to that file).
  - Acceptance: the Grep result returns at least one matching line within the artifact. Zero matches fails the task and returns the loop to P1-T1.
- [ ] [P2-T2] Re-run the feature-review reaudit handoff, supplying the feature folder, `remediation-inputs.2026-10-01T18-00.md`, this plan, and the new artifact `evidence/qa-gates/final-powershell-coverage.md`, so that finding R1 is re-evaluated.
  - Acceptance: the reviewer receives the handoff with all Phase 0, Phase 1, and Phase 2 artifacts from this plan present on disk, and the reaudit is requested to re-verify the PowerShell coverage verdict against the new artifact.
