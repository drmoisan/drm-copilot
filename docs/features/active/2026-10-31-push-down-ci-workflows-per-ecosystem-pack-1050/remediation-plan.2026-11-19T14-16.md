# Remediation Plan — Issue #1050, cycle 1, R1 (proportionate)

Source: `remediation-inputs.2026-11-19T14-16.md`, finding CI-1 (Remediation-Mode: proportionate).
Canonical issue: 1050. Branch: `feature/push-down-ci-workflows-per-ecosystem-pack-1050`.
Feature folder: `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050`.

## Scope

In `.github/workflows/harness-python.yml`, step `Check coverage thresholds` parses `artifacts/python/coverage.json` with `ConvertFrom-Json` and fails on the empty-string key of the coverage.py 7.17.3 report. The step switches to `ConvertFrom-Json -AsHashtable` and reads the totals through hashtable access. Thresholds, output messages, and exit behavior are unchanged. The bundle copy `extensions/drm-copilot/resources/ci-workflows/workflows/harness-python.yml` receives the identical step text so that it stays byte-identical to the source workflow. A contract helper and test case pin the `-AsHashtable` form, with a negative in-memory variant.

Acceptance criteria (from CI-1): AC-1 the step uses `-AsHashtable` and hashtable access; AC-2 the bundle copy is byte-identical to the source; AC-3 a contract test asserts AC-1 and fails on a variant that omits it; AC-4 actionlint 1.7.12 reports zero findings over the four harness workflows with no suppression.

Existing tests that assert the changed step text or the changed files, with dispositions:

- `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts`, case `harness workflows are destination-generic`: asserts the python workflow still carries the report path, the lcov report argument, and the default thresholds. Unchanged: those tokens stay in the edited workflow.
- Same file, case `CI bundle is complete and copies match`: asserts the bundle copy equals the source workflow. Unchanged: it passes only because both files receive the identical edit in P1-T1 and P1-T2.
- `extensions/drm-copilot/test/lib/push-down/push-down-harness.ci-workflows.test.ts`: reads the bundled harness texts and compares them with the rendered reference caller and bundle text. Unchanged: it does not read the threshold step.
- `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` and `scripts/dev_tools/check_python_coverage_thresholds.py`: cover `_quality-checks.yml` and the repository's own threshold script. Unchanged: neither reads `harness-python.yml`.
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`: reads coverage hook inputs, not the workflow. Unchanged.

## Pre-Mortem

- Review checklists: P2-T4 walks the policy-audit, code-review, and feature-audit templates against the branch diff from the merge base and records one row per item; a FAIL row is fixed and the loop re-run.
- Coverage: the only TypeScript change is a test helper under `test/`; the TypeScript gate is one Jest run whose coverage is compared with the Phase 0 baseline of the same gate, and the new helper function is exercised by the new case on the real workflow and the negative variants.
- Mirror parity: the bundle copy of `harness-python.yml` is edited in P1-T2 and proven byte-identical in P2-T3 and by the existing `CI bundle is complete and copies match` case; no fact stated by the execution-environment brief changes, so no brief-update task is needed.
- File size: `push-down-ci-contract.test-helpers.ts` grows by about 30 lines from roughly 420 and `push-down-ci-contract.test.ts` by about 20 from roughly 260, both below the 500-line guidance tier.
- Test isolation: the new case reads tracked files and in-memory variants only and creates no temporary files; the gate is Jest through its normal parallel workers via the test-execution launcher, re-run only after a fix. No Pester or pytest file changes, so those gates are not run; no serial, single-process, shuffled, or reversed run is used.
- CI-only behavior: the failure itself is CI-only (coverage.py report shape); the fix is proven by actionlint and the contract test, and the orchestrator re-runs the S17 scratch dispatch of the python pack after push as the end-to-end proof. The test uses no drive letters and no gitignored state.
- Evidence: artifacts are append-only files under `<FEATURE>/evidence/` with clock-read UTC stamps; Phase 0 reuses the existing baseline artifacts and re-captures nothing.

## Plan

### Phase 0 — Baseline reference

- [x] [P0-T1] Write the new append-only file `<FEATURE>/evidence/baseline/advisory-baseline-reference.<timestamp>.md` (stamp read from the clock) recording that the Phase 0 baselines are the existing `baseline-ts-static.*.md`, `baseline-yaml-static.*.md`, and `baseline-jest.*.md` artifacts in that folder, naming each file; no baseline is re-captured. Acceptance: the new file lists those three artifacts and each named artifact exists.

### Phase 1 — Hashtable parse and contract assertion

- [x] [P1-T1] Edit `.github/workflows/harness-python.yml`, step `Check coverage thresholds`: parse the report with `ConvertFrom-Json -AsHashtable` and read `totals`, `num_statements`, `covered_lines`, `num_branches`, and `covered_branches` by hashtable access; keep the threshold comparisons, the two `Write-Output` messages, the two `Write-Error` messages, and `exit 1` unchanged. Acceptance: the step text contains `ConvertFrom-Json -AsHashtable` and no `$report.totals` or `$totals.` property access; test `harness workflows are destination-generic` still passes.
- [x] [P1-T2] Apply the identical step edit to `extensions/drm-copilot/resources/ci-workflows/workflows/harness-python.yml`. Acceptance: the two files are byte-identical, asserted by the unchanged case `CI bundle is complete and copies match`.
- [x] [P1-T3] Add exported function `findPythonCoverageStepViolations(text: string): string[]` to `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test-helpers.ts`, using `workflowSteps` to select the step named `Check coverage thresholds` and returning one message per violation: step absent, `ConvertFrom-Json -AsHashtable` absent, or a `.totals` / `$totals.` property access present. Acceptance: it is a pure function with TSDoc and returns an empty array for the real workflow text.
- [x] [P1-T4] Add test `python harness threshold step parses the report with -AsHashtable` to `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts`: it expects an empty violation list for `HARNESS.python`, a list containing the missing-`-AsHashtable` message for an in-memory variant whose `ConvertFrom-Json -AsHashtable` is replaced by `ConvertFrom-Json`, and a non-empty list for a variant that reintroduces `$report.totals`. Acceptance: the named test passes in the task check of that file.
- [x] [P1-T5] [phase-gate] Run stages 1 to 6 for the touched language in `extensions/drm-copilot`: Prettier check, ESLint, TypeScript type check, architecture-boundary check, and the full Jest suite through the test-execution launcher, restarting from stage 1 after any failure or auto-fix. Python and PowerShell sources are untouched, so their unit gates are not run. Acceptance: one clean pass recorded in `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 2 — Final QA loop

- [x] [P2-T1] Run the TypeScript static steps in `extensions/drm-copilot` (Prettier check, ESLint, type check) and record them in `<FEATURE>/evidence/qa-gates/final-qc-ts-static.<timestamp>.md` with each step's command, exit code, and finding count; the Prettier success output states that all matched files use the configured style. Acceptance: each step exits 0 with zero findings and no file was rewritten.
- [x] [P2-T2] Run Jest with coverage through the launcher, one parallel run, and record pass and fail counts plus repo-wide and per-file coverage in `<FEATURE>/evidence/qa-gates/final-qc-jest.<timestamp>.md`, compared with the lexicographically greatest `baseline-jest.*.md`. Acceptance: zero failing tests, no coverage drop against the baseline, thresholds of 85% line and 75% branch met.
- [x] [P2-T3] Run actionlint 1.7.12 over `.github/workflows/harness-python.yml`, `harness-powershell.yml`, `harness-typescript.yml`, and `harness-dotnet.yml` with no ignore flag and no suppression comment, and compare `harness-python.yml` with its bundle copy by byte comparison. Record both in `<FEATURE>/evidence/qa-gates/final-qc-workflows.<timestamp>.md`. Acceptance: actionlint exits 0 with zero findings, and the byte comparison reports identical files.
- [x] [P2-T4] Walk the templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD` and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. Acceptance: no FAIL row remains; any FAIL is fixed and P2-T1 to P2-T3 are re-run first.
