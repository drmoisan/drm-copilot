# Preflight Fixes (confirming preflight after the planner revision)

Timestamp: 2026-11-14T17-24
Plan: docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/plan.2026-10-30T17-11.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan path> (re-run after the fixes)
EXIT_CODE: 0
Output Summary: plan validation passed after seven trivial fixes in task text; the MCP validator also passed. No task was added, removed or reordered, and the plan keeps 82 canonical tasks in 413 physical lines. Substantive defects are returned to the orchestrator and are not fixed here.

## Fix 1: [P1-T7] PowerShell prefix cases missing from the task's test list

- Defect class: task text omits a case that the plan's own `## Spec Rule Traceability` row ("prefix, pattern and known-root cases in the three suites") and the spec criterion on the known-root prefix function require.
- Change: the test list now names `Get-DevelopmentDocsKnownRootPrefix` cases that return both root forms for every area. The function and the suite were already in the task; the assertion matches the traceability row.

## Fix 2: [P2-T1] executor-selected dispositions replaced with named tests

- Defect class: validator-blind (changed existing behavior; dispositions left to the executor's search).
- Change: `direct invocation forwards the issue number without prompts` in `test/extension.new-active-feature-folder.test.ts` is named as updated (`blank-pr-context-104` becomes `0104-blank-pr-context`); `extension.new-active-feature-folder-inprocess.test.ts`, `flow.promoted-disposition.test.ts` and `promotion-lifecycle-sequence.test.ts` are named as unchanged, because they assert no issue-suffixed name and read `result.target`. The update is a folder-naming change already inside D-P20 item (1).

## Fix 3: [P2-T2] executor-selected dispositions replaced with named tests

- Defect class: validator-blind (same as Fix 2).
- Change: the six listed Python modules are stated as unchanged, because none asserts an issue-suffixed folder name; `_bug_template_preserved.py` reads `result.target`.

## Fix 4: [P5-T10] asserting suites not named

- Defect class: validator-blind (a changed function with asserting suites outside the task text).
- Change: `validate-required-artifact-output.Envelope.Tests.ps1` and `.TargetWorktree.Tests.ps1` are named as unchanged, and the task states that a `no-pipes` spec still throws the `Expected format` error that `R2` and `R-4` assert.

## Fix 5: [P6-T1] suite that dot-sources the review helper directly not named

- Defect class: validator-blind (D-P16 setup change not applied to a named suite).
- Change: the `review guard precedes the check` context of `tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1` dot-sources `enforce-epic-merge-gate-review.ps1` directly; the task now states that its `BeforeAll` imports `DevelopmentDocsRoot.psm1` per D-P16 and that its assertion is unchanged.

## Fix 6: [P6-T2] suites that dot-source hook-epic-fan-in.ps1 directly not named

- Defect class: validator-blind (D-P16 setup change not applied to named suites).
- Change: `enforce-orchestration-preimplementation-gate-bookkeeping.Tests.ps1` (which calls `Test-EpicMergedFeaturePath`) and `hook-epic-regeneration.Tests.ps1` dot-source `hook-epic-fan-in.ps1` directly; the task now states that their `BeforeAll` blocks import `DevelopmentDocsRoot.psm1` per D-P16 and that their expectations are unchanged.

## Fix 7: [P6-T6] incorrect disposition statement

- Defect class: incorrect factual statement about an asserting test.
- Change: the task said each existing case passes `-EvidenceRoot`. `STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS` also runs the entry without it. The task now states that, under the default key, the resolver returns `docs/features`, so that case's label assertions hold. The disposition (unchanged) is the same.
