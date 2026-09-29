---
parallel: "bug-burndown-2026-09-29"
mode: "closed"
max_concurrency: 3
created_at: "2026-09-29T18:35:41Z"
items:
  - issue_num: 338
    feature_folder: "docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/**"
        - "docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/evidence/baseline/phase0-instructions-read.md"
        - "docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md"
        - "docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/research/research.2026-09-29T14-20.md"
        - "docs/features/completed/2026-04-25-canonical-evidence-locations-non-overridable-158/evidence/qa-gates/python-black-final.md"
        - "docs/features/completed/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/final-format.md"
        - "docs/features/completed/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/checker-module-coverage.md"
        - "docs/features/completed/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/qa-gates/remediation-python-typecheck.md"
        - "docs/features/completed/compare-code-point-helper-duplicated-716/evidence/qa-gates/jest-coverage-final.2026-09-27T05-58.md"
        - "extensions/drm-copilot/package-lock.json"
        - "extensions/drm-copilot/package.json"
        - "extensions/drm-copilot/resources/templates/new-potential-entry.ps1"
        - "extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts"
        - "extensions/drm-copilot/src/lib/new-potential-bug-entry.ts"
        - "extensions/drm-copilot/test/lib/executable-resolver.test.ts"
        - "extensions/drm-copilot/test/lib/new-active-feature-folder/fakes.ts"
        - "extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts"
        - "extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts"
        - "extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts"
        - "scripts/dev-tools/new-potential-entry.ps1"
        - "scripts/dev_tools/new_active_feature_folder_io.py"
        - "scripts/dev_tools/new_potential_bug_entry.py"
        - "tests/scripts/dev_tools/test_new_active_feature_folder.py"
        - "tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py"
        - "tests/scripts/dev_tools/test_new_potential_bug_entry.py"
      modules:
        - "powershell-dev-tools"
      shared_surfaces:
        - "extensions/drm-copilot/package-lock.json"
      contracts: []
      source: "declared"
      computed_at: "2026-09-29T18:45:14Z"
  - issue_num: 406
    feature_folder: "docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/**"
        - "docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/issue.md"
        - "docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/research/research.2026-09-29T14-20.md"
        - "extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts"
        - "scripts/dev_tools/potential_to_issue.py"
        - "scripts/dev_tools/potential_to_issue_adapters.py"
        - "scripts/dev_tools/potential_to_issue_content.py"
        - "tests/scripts/dev_tools/potential_to_issue_test_support.py"
        - "tests/scripts/dev_tools/test_potential_to_issue.py"
        - "tests/scripts/dev_tools/test_potential_to_issue_branches.py"
        - "tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py"
        - "tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py"
        - "tests/scripts/dev_tools/test_potential_to_issue_content.py"
        - "tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py"
        - "tests/scripts/dev_tools/test_potential_to_issue_work_modes.py"
      modules: []
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "2026-09-29T18:34:03Z"
  - issue_num: 510
    feature_folder: "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/settings.json"
        - ".claude/settings.local.json"
        - ".claude/state/python-batch-budget.default.json"
        - ".claude/statement.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/**"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/baseline/baseline-black.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/baseline/baseline-environment.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/baseline/baseline-line-counts.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/baseline/baseline-pyright.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/baseline/baseline-pytest-coverage.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/baseline/baseline-pytest.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/baseline/baseline-ruff.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/baseline/phase0-instructions-read.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/other/coveragerc-helper.ini"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/other/follow-up-issue-request.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/ac-status-summary.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-black-check.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-black-write.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-helper-coverage.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-limits-and-boundary.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-pyright.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-pytest-coverage.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-pytest.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-ruff.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/regression-testing/contracts-test-wiring.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/regression-testing/fail-before.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/regression-testing/frontmatter-binding.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/regression-testing/helper-coverage.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/regression-testing/helper-tests-pass.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/regression-testing/removed-identifiers-grep.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/regression-testing/three-file-pass.2026-09-29T14-11.md"
        - "docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md"
        - "scripts/dev_tools/push_down_claude_customizations.py:392"
        - "tests/scripts/dev_tools/claude_payload_scope_test_support.py"
        - "tests/scripts/dev_tools/test_claude_payload_scope_support.py"
        - "tests/scripts/dev_tools/test_claude_rules_frontmatter.py"
        - "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py"
      modules: []
      shared_surfaces:
        - ".claude/settings.json"
      contracts: []
      source: "declared"
      computed_at: "2026-09-29T18:35:18Z"
---

# Parallel Run: bug-burndown-2026-09-29

Run manifest maintained by parallel-planner. Items appear here once prepared (preflight ALL CLEAR and declared radius V1/V2-clear). Cohorts are seeded after every item is prepared.

Prepared: 3 of 22. Pending: 512, 527, 532, 543, 609, 623, 645, 647, 658, 659, 723, 734, 739, 740, 741, 743, 744, 756, 764.
