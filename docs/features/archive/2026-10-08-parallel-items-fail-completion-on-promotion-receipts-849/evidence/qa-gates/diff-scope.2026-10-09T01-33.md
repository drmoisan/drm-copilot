# Diff-Scope Gate (P9-T5, Issue #849)

Timestamp: 2026-10-10T15-15
Command: git diff --name-status --merge-base origin/main ; git status --porcelain
EXIT_CODE: 0

Both commands were run separately against the worktree root; each exited 0. At the time of the run, origin/main was 0ea7978a79b2ef5b237043923bff299e2b45cddf and `git merge-base HEAD origin/main` returned the same SHA, so the merge-base diff resolves against the current origin/main tip (expected after the two origin/main merges 3412e7f5a and baf63356b). P0-T2 recorded BASE_SHA 793731a12e0aafb5f6eb645fffa072d941797de1, the origin/main tip at Phase 0.

## Classification of `git diff --name-status --merge-base origin/main` (84 entries)

- 57 entries under `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/` (feature folder; includes `issue.md`, `spec.md`, `plan.2026-10-09T01-33.md`, `research/research.2026-10-09T05-40.md`, and committed evidence).
- 26 entries that are the 26 production and test paths listed under `## Files Written` (6 `.claude/` sources, 6 bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/`, the TypeScript source and two TypeScript tests, the Python module, five fixtures, two Pester test files, and three Python test files).
- 1 entry in `BASE_DIFF` (P0-T2): `A	docs/features/potential/promoted/2026-10-08-parallel-items-fail-completion-on-promotion-receipts.md`.
- 0 entries outside these three categories.

Paths introduced by the origin/main merges: none appear. `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (added by merge baf63356b) and `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` (changed by merge baf63356b) are present on origin/main and therefore produce no merge-base diff entry; a grep of the listing for both names returned 0 matches.

## Classification of `git status --porcelain` (8 entries)

All 8 entries are under the feature folder (the plan check-off and the Phase 8 and Phase 9 evidence written after commit 12580b1dc, including the H1 `qa-gates/poshqc-local/` copies and this artifact). Evidence files written later in Phase 9 (`evidence/other/follow-up-parallel-add.2026-10-09T01-33.md`) and the `spec.md` check-offs are also under the feature folder.

## Excluded paths

A grep of the name-status listing for `validate_orchestrator_state\.py` and `parallel-add/SKILL\.md` returned 0 matches, and neither appears in the porcelain listing. `scripts/dev_tools/validate_orchestrator_state.py` and `.claude/skills/parallel-add/SKILL.md` are unchanged.

## Gap records for P9-T22 and P9-T24

- RB_PY_FULL_FAILED is `{}` and the P6-T5 failed set is `{}`; no Python failing node ID is recorded as a gap.
- The P8-T5 failed-test set across the three PowerShell scan folders is `{}`; no PowerShell failing test is recorded as a gap.

Output Summary: PASS. 84 name-status entries (57 feature folder, 26 Files Written, 1 BASE_DIFF) and 8 porcelain entries (all feature folder); no out-of-scope path; validate_orchestrator_state.py and parallel-add/SKILL.md absent from both listings; no merge-introduced path appears.

## Verbatim listings

git diff --name-status --merge-base origin/main:

```text
M	.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
M	.claude/rules/orchestrator-state.md
M	.claude/skills/feature-promotion-lifecycle/SKILL.md
M	.claude/skills/orchestrate/SKILL.md
M	.claude/skills/parallel-orchestrate/SKILL.md
M	.claude/skills/parallel-plan/SKILL.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/corpus-count.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/file-line-counts.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/git-baseline.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/phase0-instructions-read.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/pester-junit.xml
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/powershell-coverage.xml
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/run-record.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ps-analyze.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ps-format.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ps-test-coverage.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-adoption-coverage.2026-10-09T01-33.json
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-adoption-coverage.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-black.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-full-coverage.2026-10-09T01-33.json
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-full-suite.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-pyright.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-ruff.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-skill-contracts.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-coverage-output.2026-10-09T01-33.txt
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-coverage.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-format.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-lint.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-typecheck.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-validate-dir-tests.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/corpus-recount.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/doc-observation.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/fixture-immutability.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/mirror-identity.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-analyze.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-format.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-test-mcp.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-adoption-coverage.2026-10-09T01-33.json
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-adoption-coverage.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-black.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-full-coverage.2026-10-09T01-33.json
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-full-suite.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-pyright.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-ruff.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-skill-contracts.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-output.2026-10-09T01-33.txt
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-format.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-lint.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-typecheck.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-validate-dir-tests.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-parity-expect-fail.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-parity-pass-after.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-skill-contracts-expect-fail.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-skill-contracts-pass-after.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-waivers-expect-fail.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-waivers-pass-after.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/ts-origin-expect-fail.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/ts-parity-origin-pass-after.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/issue.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/plan.2026-10-09T01-33.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/research/research.2026-10-09T05-40.md
A	docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md
A	docs/features/potential/promoted/2026-10-08-parallel-items-fail-completion-on-promotion-receipts.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
M	extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
M	extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts
A	extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts
M	extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts
M	scripts/dev_tools/_orchestrator_state_issue_adoption.py
A	tests/fixtures/orchestrator_state_issue_adoption/epic-decomposition-waives-entry-tool-without-record.json
A	tests/fixtures/orchestrator_state_issue_adoption/filed-before-orchestration-invalid-present-record.json
A	tests/fixtures/orchestrator_state_issue_adoption/valid-bug-large-filed-before-orchestration-without-record.json
A	tests/fixtures/orchestrator_state_issue_adoption/valid-bug-preparation-filed-before-orchestration-without-record.json
A	tests/fixtures/orchestrator_state_issue_adoption/valid-large-transferred-waives-feature-entry-tool-without-record.json
M	tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1
M	tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
M	tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py
M	tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py
A	tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py
```

git status --porcelain (taken after this artifact was created, so it lists this artifact too):

```text
 M docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/plan.2026-10-09T01-33.md
?? docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/diff-scope.2026-10-09T01-33.md
?? docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/file-size-gate.2026-10-09T01-33.md
?? docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/poshqc-local/
?? docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-coverage-delta.2026-10-09T01-33.md
?? docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-test-coverage.2026-10-09T01-33.md
?? docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-coverage-delta.2026-10-09T01-33.md
?? docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-delta.2026-10-09T01-33.md
```
