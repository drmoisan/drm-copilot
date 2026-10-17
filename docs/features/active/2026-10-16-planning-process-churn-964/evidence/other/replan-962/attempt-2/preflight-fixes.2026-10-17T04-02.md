# Preflight Fixes — replan-962 attempt 2

Timestamp: 2026-10-17T04-02
Plan: docs/features/active/2026-10-16-planning-process-churn-964/evidence/other/replan-962/attempt-2/plan.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-16-planning-process-churn-964/evidence/other/replan-962/attempt-2/plan.md
EXIT_CODE: 0
Output Summary: Branch-current plan validator passed after the in-place fixes below. One substantive defect (brief maintenance, `[P3-T2]`/`[P3-T8]` and `## Pre-Mortem` Mirror parity) remains and is returned to the planner; it is not fixed here.

Classification basis: `.claude/skills/atomic-plan-contract/SKILL.md` `### Single-Pass Preflight` (trivial defects include a validator-blind class from the `execution-environment` skill whose correction keeps the assertion's meaning). Each fix below adds or corrects an existing-test disposition under the "changed existing behavior" class; none changes an acceptance condition, a file set, or task order.

## Fixes

1. [P3-T3] | changed-existing-behavior disposition missing | Added the disposition for 'reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph' (`tests/scripts/workflows/CiWorkflow.Tests.ps1`), which reads every workflow `ci.yml` calls, including `_quality-checks.yml`: unchanged after P3-T2, because the task adds no event-field read and no path filter.
2. [P3-T4] | citation correction | Replaced "No file under `tests/` reads this workflow" with the same CiWorkflow test and its disposition. The original statement was false: the test reads `_security-scan.yml` through the `ci.yml` call graph.
3. [P3-T5] | changed-existing-behavior disposition missing | Added the same CiWorkflow test disposition for `_build-check.yml` and `_drm-copilot-extension-tests.yml`.
4. [P3-T6] | citation correction | Replaced "No file under `tests/` reads this workflow" with the same CiWorkflow test and its disposition, for `_shell-coverage.yml`.
5. [P3-T7] | changed-existing-behavior disposition missing | Added the same CiWorkflow test to the unchanged list for `_poshqc.yml`.
6. [P3-T8] | wording precision | Changed "The four `CiWorkflow.Tests.ps1` tests stay unchanged" to "receive no further change after P3-T2", because P3-T2 updates one of the four, and added that the caller lines add no event-field read.
7. [P4-T3] | changed-existing-behavior disposition missing | Added dispositions for '--help prints usage and exits 0', 'help subcommand prints usage and exits 0' and 'an unknown subcommand prints usage and exits 2' (`tests/shell/test_shell_qc_commands.bats`), which read the `scripts/bash/shell-qc.sh` usage text that the task edits: unchanged, because they match only the `Usage: shell-qc.sh` line.
8. [P4-T4] | changed-existing-behavior disposition missing | Added the same three usage-text test dispositions for the `SHELL_QC_MIN_LINE_COVERAGE` usage-text addition.

## Searches performed for the changed-existing-behavior class

- Workflow readers: repository-wide search of `tests/`, `extensions/drm-copilot/test/` and `scripts/` for each changed workflow file name and for `.github/workflows`; matches were `CiWorkflow.Tests.ps1`, `PoshQcWorkflow.Tests.ps1`, `PoshQC.RunSettings.Tests.ps1`, `test_quality_checks_workflow_contracts.py`, `test_ruff_config_alignment.py`, `package-typecheck-script.test.ts`, plus comment-only or fixture-string references (`jest-config-resolution.test.ts`, `hook-docs-only-diff.Tests.ps1`) and the NPM-token guard, which scans for NPM token names only.
- `quality-tiers.yml` readers: only `test_committed_quality_tiers_yml_matches_live_tree` and `test_committed_quality_tiers_yml_assigns_spec_tiers` read the committed file; the other matches use the file name as a string literal.
- Shell QC: `run_test`, `run_test_coverage`, the `bats`/`kcov`/`bats-nounset-source*` stubs, the usage text, and the fix_all skip markers; the skip markers are unchanged by the plan.
