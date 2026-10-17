# Final QC: scope diff ([P13-T2], AC-40)

Timestamp: 2026-10-09T22-02
Merge-base substitution: every anchored command uses 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a (the recorded [P0-T4] `Merge-Base:` value) in place of e7d3779b398604af919678c16c877c8539a86cc0. With this merge-base the diff shows only this branch's changes.

Command: git diff --name-status 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a
EXIT_CODE: 0
Output Summary: 121 paths (statuses M and A only). Run at HEAD 0666a68de (after the Phase 12 commit) with the Phase 13 line-counts artifact written but uncommitted. A mechanical comparison (`comm -23` of the sorted union of blocks 1 and 2 against the sorted backtick-quoted paths of the "Files Written by This Plan" section plus the three pre-existing inputs) printed nothing: every path in the union appears in that section or in its pre-existing inputs paragraph. The five plan-listed paths not yet present at this point (closure-dispositions, ac-status, closure-paths-exist, protected-file-844 under qa-gates, and this artifact) are written by later Phase 13 tasks. A `grep -c` over the union for the protected #844 test file, `.github/workflows/`, `jest.config.cjs`, `tsconfig.jest.json`, `.gitignore`, `potential_to_issue_content.py`, and the four superseded #609 evidence files printed 0; the only #609 folder path present is the new ac-status-summary.2026-10-09T09-00.md note, which is listed.

Command: git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: one line, `?? docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/line-counts.2026-10-09T09-00.md` (the [P13-T1] artifact, listed). No `D` or `R` status.

Command: git diff --name-status --diff-filter=DR 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a
EXIT_CODE: 0
Output Summary: printed nothing (no deleted or renamed path).

## Block 1 output (verbatim)

```
M	.agents/skills/acceptance-criteria-tracking/SKILL.md
M	.claude/skills/acceptance-criteria-tracking/SKILL.md
M	.github/skills/acceptance-criteria-tracking/SKILL.md
M	docs/engineering/missed-npm-publish.runbook.md
M	docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md
M	docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md
M	docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md
A	docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/other/ac-status-summary.2026-10-09T09-00.md
M	docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/other/ac-status-summary-local.2026-09-30T03-18.md
M	docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md
M	docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md
A	docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/other/evidence-filename-timestamps.2026-10-09T09-00.md
M	docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md
M	docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/batch-budget-analysis.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/git-merge-base.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/line-counts.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/phase0-instructions-read.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ps-analyzer.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ps-formatter-check.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ps-pester-workflow.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-black-check.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-collect-quality-tiers.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-bug-entry-before.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-filesystem.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-promotion.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-quality-tiers.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-cov-whole-repo.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-coverage-thresholds.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-pyright.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-ruff-check.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/py-test-names-quality-tiers.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/toolchain-availability.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-it-titles.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-jest-coverage.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-jest-subagent-tree.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-lint.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-prettier-check.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/ts-typecheck.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-analyzer.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-coverage-not-applicable.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-formatter-check.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ps-pester.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-black-check.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-contract-tests.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-filesystem.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-promotion.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-quality-tiers.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-cov-whole-repo.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-coverage-comparison.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-coverage-thresholds.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-loop-summary.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-pyright.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-ruff-check.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/py-stages-not-applicable.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-coverage-comparison.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-jest-coverage.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-jest-subagent-tree.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-lint.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-loop-summary.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-prettier-check.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-stages-not-applicable.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/ts-typecheck.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/543-commit-dates.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/764-corrected-grep-current.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/764-corrected-grep-historical.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac-pin-fail-before.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac-pin-pass-after.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac-tracking-sentence.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ac3-338-jest.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-338-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-510-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-527-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-543-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-609-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-623-plan-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-723-exit1-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-723-runbook-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-744-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-764-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/doc-764-plan-checks.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/fail-before-exception.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/filesystem-coverage-after.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/partial-also-after.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/pester-workflow-after.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/promotion-coverage.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/promotion-docs.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/protected-file-844.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/qt009-fail-before.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/qt009-message-form.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/qt009-pass-after.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-cli.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-coverage.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-helper-and-rename.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-names-after.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/quality-tiers-split-collect.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ts-split-jest.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/ts-support-imports.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/workflow-unchanged.2026-10-09T09-00.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/issue.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.2026-10-08T23-42.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/research/research.2026-10-08T23-50.md
A	docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md
M	docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md
A	docs/features/potential/promoted/2026-10-08-bug-burndown-2026-09-29-review-nits.md
M	extensions/drm-copilot/CHANGELOG.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md
M	extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md
A	extensions/drm-copilot/test/subagent-tree-command-test-support.ts
A	extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts
M	extensions/drm-copilot/test/subagent-tree-command.test.ts
M	pyproject.toml
M	scripts/dev_tools/check_quality_tiers.py
M	scripts/dev_tools/potential_to_issue.py
A	tests/scripts/dev_tools/quality_tiers_contract_test_support.py
M	tests/scripts/dev_tools/test_check_quality_tiers.py
M	tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py
M	tests/scripts/dev_tools/test_quality_tiers_contract.py
A	tests/scripts/dev_tools/test_quality_tiers_contract_classification.py
M	tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
```
