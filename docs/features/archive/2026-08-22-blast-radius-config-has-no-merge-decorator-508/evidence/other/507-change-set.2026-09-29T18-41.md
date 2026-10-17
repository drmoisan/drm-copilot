# #507 Change Set (P0-T6)

Timestamp: 2026-09-29T18-41
Command: git diff --name-status origin/main...origin/epic/push-down-payload-correctness-integration; git status --porcelain
EXIT_CODE: 0
Output Summary:
- name-status diff exit 0; 88 paths listed verbatim below (code paths: 1 TS test, 6 Python production files under scripts/dev_tools, 1 fixture, 10 Python tests).
- porcelain companion exit 0; recorded verbatim below.

## git diff --name-status origin/main...origin/epic/push-down-payload-correctness-integration

```
M	README.md
A	docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/issue.md
A	docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/plan.2026-09-29T14-14.md
A	docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/research/research.2026-09-29T14-18.md
A	docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/spec.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/code-review.2026-09-29T18-12.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/coverage-baseline.json
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/git-anchor.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/line-counts.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/npm-ci.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/phase0-instructions-read.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-black-check.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-coverage-baseline.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-pyright.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-pytest-full.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-ruff-check.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-eslint.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-jest-coverage.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-prettier-check.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-typecheck-src.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-typecheck-tests.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/other/ac-reconciliation.2026-09-29T18-04.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/other/ac23-config-mentions.2026-09-29T17-58.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/other/ac24-follow-up-candidates.2026-09-29T17-58.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/other/cli-help-stale-text-absent.2026-09-29T17-54.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/other/extension-seam-docstring.2026-09-29T17-58.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/other/line-counts.2026-09-29T17-58.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/other/no-temp-files.2026-09-29T17-58.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/other/scope-boundary.2026-09-29T17-58.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/coverage-final.json
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/python-black-check.pass-1.2026-09-29T17-59.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/python-coverage-delta.2026-09-29T17-59.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/python-coverage.pass-1.2026-09-29T17-59.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/python-loop-clean-pass.2026-09-29T17-59.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/python-pyright.pass-1.2026-09-29T17-59.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/python-pytest-full.pass-1.2026-09-29T17-59.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/python-ruff-check.pass-1.2026-09-29T17-59.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/ts-eslint.pass-1.2026-09-29T18-02.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/ts-jest-coverage.pass-1.2026-09-29T18-02.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/ts-loop-clean-pass.2026-09-29T18-02.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/ts-prettier-check.pass-1.2026-09-29T18-02.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/ts-typecheck-src.pass-1.2026-09-29T18-02.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/ts-typecheck-tests.pass-1.2026-09-29T18-02.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/ac1-root-folders-fail-before.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/ac1-root-folders-pass-after.2026-09-29T17-54.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/jest-routing-merge-parity.2026-09-29T17-57.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/parity-fail-before.2026-09-29T17-28.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/parity-pass-after.2026-09-29T17-54.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/feature-audit.2026-09-29T18-12.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/issue.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/plan.2026-09-29T14-13.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/policy-audit.2026-09-29T18-12.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/research/research.2026-09-29T14-20.md
A	docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md
A	docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/issue.md
A	docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/plan.2026-09-29T14-14.md
A	docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/research/2026-09-29-unbundled-python-clis-research.md
A	docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/spec.md
A	docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/issue.md
A	docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/plan.2026-09-29T14-15.md
A	docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/research/2026-09-29T14-25-exclusion-manifest-design.research.md
A	docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/spec.md
A	docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/user-story.md
A	docs/features/epics/push-down-payload-correctness/epic-kickoff.md
A	docs/features/epics/push-down-payload-correctness/epic.md
A	docs/features/potential/2026-09-29-issue-507-python-push-down-divergence-follow-ups.md
A	docs/features/potential/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups.md
A	docs/features/potential/promoted/2026-09-29-push-down-payload-correctness.md
A	extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts
A	scripts/dev_tools/push_down_claude_blast_radius_derive.py
A	scripts/dev_tools/push_down_claude_blast_radius_derive_core.py
A	scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py
M	scripts/dev_tools/push_down_claude_customizations.py
A	scripts/dev_tools/push_down_claude_destination_writes.py
A	scripts/dev_tools/push_down_claude_routing_merge.py
A	tests/fixtures/push_down/routing-merge-parity.json
A	tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive.py
A	tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core.py
A	tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core_guard.py
A	tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_manifests.py
A	tests/scripts/dev_tools/test_push_down_claude_config_carriage.py
M	tests/scripts/dev_tools/test_push_down_claude_customizations.py
A	tests/scripts/dev_tools/test_push_down_claude_destination_writes.py
A	tests/scripts/dev_tools/test_push_down_claude_parity.py
A	tests/scripts/dev_tools/test_push_down_claude_routing_merge.py
```

## git status --porcelain (companion)

```
 M docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/plan.2026-09-29T14-14.md
?? docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/evidence/
```
