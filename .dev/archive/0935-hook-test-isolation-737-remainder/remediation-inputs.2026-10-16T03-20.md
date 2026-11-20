# Remediation Inputs — Issue #935 (hook-test-isolation-737-remainder)

Review-Verdict: REMEDIATION_REQUIRED

One blocking finding requires remediation. No code defect was found. The blocking finding concerns coverage evidence.

## BLOCKING COV-1: PowerShell post-change coverage artifact below the 85% line floor

Remediability: autonomous
Remediability-Evidence: The shortfall can be resolved on the branch before a pull request exists, by producing a full-population local coverage measurement; no external system, policy decision or CI result is needed for the first remedy step.

- Source: `policy-audit.2026-10-16T03-20.md` sections 1.2 and 1.2.1; enforced by the `validate-feature-review-coverage.ps1` SubagentStop hook.
- Observed: `artifacts/pester/powershell-coverage.xml` root LINE counter is covered 8110, not covered 4170, so line coverage is 66.04%. The floor is the 85% default (the root `CLAUDE.md` states no threshold). The baseline is 90.42% (16381/18116, CI run 38730332356, `evidence/baseline/ci-baseline.2026-10-16T00-11.md`).
- Probable cause (not demonstrated): the artifact was written by the final `run_poshqc_test` call scoped to three folders (`tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, `tests/scripts/claude-runtime`). Its denominator (12280 lines) differs from CI's (18116). The branch changes no file under the `config/poshqc-coverage.json` roots and removes no production-exercising test, because the I-3 splits are pure moves.
- Required fix:
  1. Run `mcp__drm-copilot__run_poshqc_test` over the full PowerShell test population, the same set of folders that the CI job `poshqc / PowerShell QC` runs, so that `artifacts/pester/powershell-coverage.xml` is regenerated with a repo-wide denominator.
  2. Read the root `counter type="LINE"` of the regenerated file (D-COV) and write `FEATURE/evidence/qa-gates/coverage-comparison.<timestamp>.md`. Record baseline 90.42%, the post-change percentage with covered and not-covered counts, both denominators, and the folder list used.
  3. Acceptance: post-change line coverage is at or above 85% and not below 90.42%. If the local runner cannot reproduce the CI coverage population (denominator differs from 18116 because of runner configuration), record the difference and the measured figure. The finding then becomes `awaiting_ci` on P7-T6 (AC-24) instead of being closed locally.
- Do not: edit any production file, edit `config/poshqc-coverage.json` or any coverage exclusion, add or remove tests to move the figure, or edit any file under `.claude/`, `.codex/`, `.github/`, `scripts/`, `config/`, `extensions/`.
- Files in scope: `artifacts/pester/powershell-coverage.xml` (regenerated, not committed) and `FEATURE/evidence/qa-gates/coverage-comparison.<timestamp>.md` (new). `FEATURE` = `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935`.

## Pending CI (non-blocking, orchestrator at S9, plan Phase 7)

- PC-1: AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24 require PR CI JUnit artifacts, job conclusions, the CI coverage file, or the JUnit artifact of run 38404520141. None of these results can exist before the pull request. PR Creation Gate condition 2 accepts criteria listed as pending-CI, so they are not recorded as findings. Mapping: P7-T2 (AC-23), P7-T3 (AC-1..AC-5, AC-10..AC-12), P7-T4 (AC-7, AC-8), P7-T5 (AC-14..AC-18), P7-T6 (AC-24), P7-T7 (AC-12 report), P7-T8 (AC-6), P7-T9 (AC-19, AC-26 PR half), P7-T10 (ledger and check-off).

## Non-blocking Observations (orchestrator may address)

- O-1: AC-26 PR-description half. The PR body must list the operator follow-ups (F-3 enforcement using the AC-5b report after splitting `legacy-codex-hook-contracts.Tests.ps1`; shape-B limit for hook-local seams; F-6 mirror drift in `.claude/rules/powershell.md` line 31; I-3 residue of 13 files at 490-499 lines and `BlastRadiusConfig.Tests.ps1`) and the N-2 and F-6 decisions.
- O-2: Phase 6 local evidence predates the merge commit `793866195`; the incoming main changes touch no PowerShell suite or coverage root.
- O-3: CI baseline `B` (`adb9aa5f0`) differs from the current merge-base (`97559c3e0`); the drift is `.github/dependabot.yml`, one Python test and Markdown. P7 artifacts should record both SHAs.
- CR-N1 (Low): `EpicStateIsolation.Discovery.Helpers.ps1` header does not declare that `Get-EpicStateProcessSpawningHook` and `Get-EpicStateVariableHookLoad` require `Get-EpicStateIsolationHookReference` from the HookReference helper.
- CR-N2 (Low): duplicated literal predicate, regex patterns and binding traversal in `EpicStateIsolation.HookReference.Helpers.ps1`.
- CR-N3 (Low): `Get-EpicStateIsolationHookReference` and `Get-EpicStateIsolationJoinPathPart` treat separate-token values of unrecognized parameters as load or positional arguments; report-only false-positive surface.
- CR-N4 (Low): the `AC-5b` and `F-3 non-vacuity` Discovery rows each re-read every suite of the surface.
- CR-N5 (Info): long comment line and one-line `param()` in `Test-EpicStateIsolationConditionalAncestor` (recovered verbatim).
- CR-N6 (Info): recovered `$script:UnderTest` fixture lines sit at column 0 inside indented here-strings.
- CR-N7 (Info): split suites reuse original Describe titles; the Selectors title names #539 while holding #671/#663 Contexts.
- CR-N8 (Info): bare `+ 5` for the length of `hooks` in `Get-EpicStateIsolationReferenceRecord`.

Artifacts:
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-16T03-20.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T03-20.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-16T03-20.md`
