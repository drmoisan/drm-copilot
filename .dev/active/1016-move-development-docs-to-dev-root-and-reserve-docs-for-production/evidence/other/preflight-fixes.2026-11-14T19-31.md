# Preflight Fixes — Stage A plan, confirming preflight after the single planner revision

Timestamp: 2026-11-14T19-31
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T18-59.md
Command: env -u VIRTUAL_ENV poetry -C <worktree> run python scripts/dev_tools/validate_orchestration_artifacts.py plan <plan>; MCP validate_orchestration_artifacts (artifact_type plan)
EXIT_CODE: 0
Output Summary: both validators pass before and after the fixes below; the plan has 193 physical lines and 29 canonical tasks (the legacy 40/400 pair applies to this pre-cutoff plan stamp, and the plan carries a `## Size Justification` section). All six round 1 defects are resolved in the revised plan. No substantive defect remains.

## Round 1 defects re-checked

- Launcher precondition: `## Execution Preconditions` makes the integration-branch sync of `origin/main` (with #1158) orchestrator-owned, and [P0-T1] records `BLOCKED: precondition` and stops when `run-test-suite.sh` or `config/test-execution-policy.json` is absent on `HEAD`. Resolved.
- lcov comparison: [P0-T4] stores zero-count `DA` and per-line zero-count `BRDA` records and the `HEAD` commit in the baseline artifact; [P4-T4] compares records through a diff line map. Resolved (fix 7 below anchors the map to the measured state).
- [P1-T5] key rules: `RECORD_ONLY_KEYS` rejected when null, missing or non-string; `CONSUMED_CHOICES` accepted when null or missing and gated by `requiredChoices`. Resolved.
- [P1-T6] decision and mapping-record tests: present, including each `REQUIRED_CHOICE_CONDITIONS` case with its false-condition counterpart. Resolved.
- Rule-5 `kept` folders: [P1-T3] `kept` list, `REPORT_CATEGORIES` and `SUMMARY_COUNTS` entries, [P1-T8] rendering test, [P4-T7] count. Resolved.
- [P2-T1] refusal-writes-nothing and injected-clock tests: present. Resolved.

## Fixes (task text and preamble only; no task added, removed or reordered)

1. Scope and Conventions (`REPORT_CATEGORIES`) | set-definition enumeration omission | Added the dry-run alternatives that spec `## Design Rule for Unresolved Owner Questions` states the report lists (the entry-by-entry plan for the OQ-1 alternative `.dev/templates/` and both OQ-12 orderings); [P1-T8] already asserts every member of the set, and [P1-T6] already computes these values.
2. [P1-T5] | test-row enumeration omission | Added the non-refusing case for a reported mechanical (F-1) rename without a decision entry, per spec `## Decision File` ("Unreported F-1 folders follow the mechanical rule and need no entry"); the function and file are unchanged.
3. [P2-T1] | test-row enumeration omission | Added that `artifacts` names both written report files (spec `### MCP tool migrate_development_docs` output).
4. [P2-T1] | test-row enumeration omission | Added a case for the task's own stated behavior: relative `report_directory` and `rename_decisions_path` resolve under `workspace_root`.
5. [P2-T1] | test-row enumeration omission | The `SUMMARY_COUNTS` presence case now covers both a dry-run and an apply-mode result, per spec `### Untracked-file reporting` (the apply result also lists untracked files).
6. [P2-T4] | test isolation | Each `main` case restores `process.exitCode`, because a leaked non-zero value in an in-band Jest run makes the run exit non-zero with every test passing. No assertion changed.
7. [P4-T4] | unsatisfiable-by-state anchor | The line-map diff now runs from the commit recorded by [P0-T4] to the working tree, which is the state the [P4-T3] coverage run measured; a diff to `HEAD` misses uncommitted changes and maps lines wrongly when Phase 1 to 3 work is not yet committed. Meaning of the comparison unchanged.
8. [P2-T3] | missing existing-test disposition | Added `repo-automation-render-subagent-tree.test.ts` (finds `render_subagent_tree` by name through `listRepoAutomationTools`) to the unchanged find-by-name suites.

## Classification note

Fixes 1 to 5 add test cases inside tasks that already own the behavior, the file and the cited spec section. They change no task, file set, design or existing assertion, and follow the round 1 precedent for an enumeration omission in a test row ([P2-T4] `--workspace`). They are recorded here so the orchestrator can review the classification.
