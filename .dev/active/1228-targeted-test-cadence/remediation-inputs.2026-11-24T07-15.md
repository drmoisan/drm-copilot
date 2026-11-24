# Remediation Inputs (Issue #1228), feature review 2026-11-24T07-15

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design

**Entry timestamp:** 2026-11-24T07-15
**Feature folder:** `.dev/active/1228-targeted-test-cadence`
**Base branch:** `main` (merge base `a4ebf96688106d9bcd0baf51d237a6b77c055560`)
**Head reviewed:** `731163ca96861582594fb861f370e5153cd76369` on `feature/targeted-test-cadence-1228`
**Work mode:** `full-feature`; AC sources are `spec.md` and `user-story.md` (25 of 28 met; 3 PARTIAL: spec AC-08, user-story items 2 and 3)
**Finding count:** 2 (autonomous: 2)
**Target remediation plan:** `.dev/active/1228-targeted-test-cadence/remediation-plan.2026-11-24T07-15.md` (to be authored by `atomic-planner`)
**Audit artifacts:**
- `.dev/active/1228-targeted-test-cadence/policy-audit.2026-11-24T07-15.md`
- `.dev/active/1228-targeted-test-cadence/code-review.2026-11-24T07-15.md`
- `.dev/active/1228-targeted-test-cadence/feature-audit.2026-11-24T07-15.md`

## Findings

### F1 - QA-gate skills contradict the selection-based remediation gate

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is a wording change on repository skill files, their mirrors and bundles, plus contract-test rows and a ledger update on this branch; no external system, owner ruling, or CI result is needed.
Finding-Scope: design

Files: `.claude/skills/python-qa-gate/SKILL.md`, `.claude/skills/powershell-qa-gate/SKILL.md`, `.claude/skills/csharp-qa-gate/SKILL.md`; their `.agents/skills/` copies; their bundles under `extensions/drm-copilot/resources/claude-customizations/` and `codex-and-agents-customizations/`; the csharp-legacy variants under `.claude-variants/` and `.agents-variants/`.

Current state: the branch makes each skill apply to "the final QA loop or a remediation gate" and adds that in a remediation gate the test step runs the cycle's test selection in coverage mode. The unchanged `## Delta Requirements` bullet `Overall coverage delta` (overall coverage >= baseline) and the unchanged `## Prohibited Shortcuts` bullets ("Do not disable, skip, or narrow any step", "Do not report success based on partial or targeted runs ... the final gate is the single gate run") contradict that run form. A selection run cannot meet an overall delta against the full `Phase 0 baseline`, and the prohibition forbids reporting it.

Fix:
1. In each QA-gate skill (all copies), scope `Overall coverage delta` to the final QA loop, and state that in a remediation gate the per-file coverage delta applies to the files the cycle changed, read from the remediation gate run, while the repository-wide figure comes from the orchestration's final-QC artifact and CI.
2. Reword the partial-run prohibition so that the remediation gate's selection run, as `## Test Cadence (Mandatory)` defines it, is the gate run of a remediation gate; keep the prohibition for any other partial or focused run.
3. Copy each edited file to its bundle and variant paths byte-identically.
4. Add required tokens for the new clauses and forbidden tokens for the unscoped old clauses to the `TCW-QAGATE` rows of `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, in the same commit as the wording.

Verification: `TCW-QAGATE-*` rows pass on every copy; `parallel-gate-wording.Tests.ps1` QA-gate rows pass.

### F2 - Feature-review repo-wide coverage source contradicts the selection re-run

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is a wording change on the feature-review agent source, its generated outputs, the feature-review skill copies, and the policy-audit template, regenerated and re-copied on this branch; no external dependency or owner decision is needed.
Finding-Scope: design

Files: `scripts/harness-generation/sources/agents/feature-review.md` (Claude and Codex halves) and its generated `.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, and bundles; `.claude/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review-workflow/SKILL.md`, and bundles; `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` and its bundle under `extensions/drm-copilot/resources/templates/policy_audit/`.

Current state: the branch's D3 text re-runs coverage over the branch's selection when a report is absent or stale and takes repo-wide totals from the final-QC artifact and `## CI Cross-check`. The agent's `### Verification Procedure` step 3 still parses the repo-wide figure from the local artifact and grades it FAIL below the threshold, and the agent still states "The agent does NOT rerun coverage generation." The skill step 5 Python bullet, the agent, and template section 4A.1 keep "a local artifact that shows the Python total below a threshold is still FAIL". Every pytest run writes `artifacts/python/lcov.info` (pyproject `addopts`) and a `-TestPath` Pester run rewrites `artifacts/pester/powershell-coverage.xml`, so after a remediation gate or a D3 re-run the local artifact is selection-only. The reviewer's own selection run produced a merged PowerShell report of 917 covered and 48059 missed lines (1.87%), which the unchanged procedure grades FAIL.

Fix:
1. In the agent source (both halves), change step 3 so the repo-wide figure per language is read from the final-QC artifact and `## CI Cross-check`, a local artifact from a selection run supplies per-file figures only, and replace "does NOT rerun coverage generation" with the D3 rule (re-run over the branch's or cycle's selection through the launcher when a report is absent or stale, never the full suite).
2. In the skill step 5 Python bullet, the agent, and template 4A.1, limit "a local artifact that shows the Python total below a threshold is still FAIL" to a full-suite artifact (the final-QC run), or remove it in favour of the CI result.
3. Regenerate with `Invoke-HarnessGeneration.ps1` and the Codex variant generator, then run both `-Check` modes and `--check`; copy the skill and template to their bundles byte-identically.
4. Add required-token rows for the agent surfaces and the template, and add the old sentences to a forbidden list, in `test-cadence-wording.Tests.ps1`; keep the `less-evidence-contract.Tests.ps1` pinned tokens (`Enforce Python coverage thresholds`, `## CI Cross-check`, `regression on changed lines`, `Phase 0 baseline`).

Verification: new `TCW-REVIEW` rows pass on every copy; `less-evidence-contract.Tests.ps1` and `parallel-gate-wording.Tests.ps1` `REVIEW-*` rows pass; generator checks exit 0.

## Ledger and records

- Extend ledger entry `.dev/engineering/process-reductions/0014-targeted-test-cadence.md` in the same commit as the wording: add every new path to `## Files Changed`, regenerate `patches/0014-targeted-test-cadence.patch` from the merge base so it carries the new hunks, and keep the commit subject token `reduction: 0014`. `ProcessReductionChain.Ledger.Tests.ps1` and `ProcessReductionLedger.Index.Tests.ps1` must pass.
- After the fixes pass, check off spec AC-08 and user-story items 2 and 3 only with their verification evidence.

## Do not do

- Do not change hooks, validators, CI workflows, or any Python file.
- Do not edit the frozen epic surfaces (D5), the standalone Copilot agents and prompts (D10), or the docs estate owned by epic #1217.
- Do not lower any coverage threshold, add a coverage exclusion, or reintroduce a full-suite run outside the `Phase 0 baseline` and the final QA loop.
- Do not hand-edit a generated file; change its source and run the generator.
- Do not use serial, single-process, shuffled, or reversed test runs; run selections through the launcher.
- Write evidence only under `.dev/active/1228-targeted-test-cadence/evidence/<kind>/`, append-only, with clock-read timestamps.
