# epic-orchestrate (#275) — Remediation Plan (Cycle 2)

- **Issue:** #275
- **Remediation cycle entry timestamp:** 2026-07-03T00-15
- **Source:** `docs/features/active/2026-07-02-epic-orchestrate-275/remediation-inputs.2026-07-03T00-15.md`
- **Head commit under review:** `44c827d` (built on `4921aaa` and `25a4a36`, branch `drm-copilot-wt-2026-07-02-19-03`)
- **Base branch:** `main` (merge-base `3c5ff3289022abc3b7b16e2441c772e5f81fd9ff`)
- **Status:** Draft

## Required References

- Standing instructions: [`CLAUDE.md`](../../../../CLAUDE.md)
- General Code Change Policy: [`.claude/rules/general-code-change.md`](../../../../.claude/rules/general-code-change.md)
- General Unit Test Policy: [`.claude/rules/general-unit-test.md`](../../../../.claude/rules/general-unit-test.md)
- Python: [`.claude/rules/python.md`](../../../../.claude/rules/python.md), [`.claude/rules/python-suppressions.md`](../../../../.claude/rules/python-suppressions.md)
- Code commenting: [`.claude/rules/self-explanatory-code-commenting.md`](../../../../.claude/rules/self-explanatory-code-commenting.md)
- Quality tiers / coverage floor: [`.claude/rules/quality-tiers.md`](../../../../.claude/rules/quality-tiers.md)
- Remediation inputs: [`remediation-inputs.2026-07-03T00-15.md`](remediation-inputs.2026-07-03T00-15.md)
- Prior-cycle evidence (context only, not re-run): [`evidence/qa-gates/python-test-split.2026-07-02T23-35.md`](evidence/qa-gates/python-test-split.2026-07-02T23-35.md)
- Spec: [`spec.md`](spec.md)

**All work must comply with these policies; do not duplicate their content here.**

Evidence for every baseline/QA artifact in this plan is written under
`docs/features/active/2026-07-02-epic-orchestrate-275/evidence/<kind>/` per
`evidence-and-timestamp-conventions`. No task in this plan writes evidence under
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical
path. Cycle-2 baseline artifacts use `evidence/remediation-baseline/`, distinct from cycle 1's
baseline artifacts, so each cycle's starting state remains independently auditable.

## Scope

This plan implements the single fix enumerated in `remediation-inputs.2026-07-03T00-15.md` and
no other change:

1. Reduce `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` from 513 lines to
   ≤ 500 lines by relocating the residual, less-fixture-cohesive `orchestrator-state`
   payload-shape tests (and the two helper functions used exclusively by them) into a new
   sibling test file, following the same convention already used twice in this feature.

Per the remediation-inputs "Do Not Do" section:

- Do not weaken, remove, or skip any existing passing test to make the extraction easier.
- Do not change any test's assertions or the production code under test — structural
  reorganization only.
- Do not expand scope beyond this one fix (the carried-forward worktree-removal-gate design
  note and the broken "Merge-Conflict Remediation" cross-reference are explicitly out of scope
  for this cycle).
- Do not check off `spec.md`'s AC14 checkbox or the "Toolchain pass completed" generic closing
  item in this plan — both remain unchecked pending an independent `feature-review` re-audit.
- Do not re-run or regenerate the PowerShell/TypeScript coverage artifacts — they are unaffected
  by a Python-only test-file reorganization and are out of scope for this cycle.
- If, after a genuine attempt, ≤ 500 lines is not achievable without breaking shared-fixture
  cohesion, [P1-T3] requires stopping and producing a documented exception request rather than
  declaring partial compliance sufficient (the "as close as achievable" leniency from cycle 1 is
  explicitly rejected as a valid outcome for this cycle).

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture & Policy Reads

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`,
  `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`,
  `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`;
  write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Policy Order:`, and an explicit list of the 6
    files read, in the order read.

- [x] [P0-T2] Capture the current line-count baseline for the fix target: run
  `(Get-Content tests/scripts/dev_tools/test_validate_orchestration_artifacts.py | Measure-Object -Line).Lines`;
  write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-linecount-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`
    recording the value `513`.

- [x] [P0-T3] Capture the current line-count baseline for the existing sibling split file: run
  `(Get-Content tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py | Measure-Object -Line).Lines`;
  write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-dispatch-linecount-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`
    recording the current line count of that file, confirmed unchanged by this cycle's fix.

- [x] [P0-T4] Capture Python format baseline: run
  `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`; write
  `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-format-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T5] Capture Python lint baseline: run
  `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`; write
  `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-lint-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
    (violation count).

- [x] [P0-T6] Capture Python type-check baseline: run
  `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`; write
  `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-typecheck-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
    (error count).

- [x] [P0-T7] Capture Python test baseline (with coverage): run
  `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools`;
  write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-test-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
    recording the total passed/skipped/failed counts and numeric line/branch coverage
    percentages for `scripts.dev_tools`.

### Phase 1 — Fix: Relocate Residual `orchestrator-state` Payload-Shape Tests

- [x] [P1-T1] Create `tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py`
  containing, moved verbatim (unchanged bodies, assertions, and docstrings) from
  `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`: the 8 test functions
  `test_validate_orchestrator_state_text_requires_receipts_for_completion`,
  `test_validate_orchestrator_state_text_accepts_legacy_list_delegation_receipts`,
  `test_validate_orchestrator_state_text_accepts_promotion_receipt_namespace`,
  `test_validate_orchestrator_state_text_rejects_json_root_that_is_not_an_object`,
  `test_validate_orchestrator_state_rejects_noncontainer_receipts`,
  `test_validate_orchestrator_state_rejects_unknown_promotion_receipt_keys`,
  `test_validate_orchestrator_state_text_rejects_receipt_missing_result_signal`,
  `test_validate_orchestrator_state_rejects_receipt_nonlist_artifact_paths`, plus the 2 helper
  functions used exclusively by them, `get_first_receipt` and
  `build_namespaced_orchestrator_state`; import `build_valid_orchestrator_state` from
  `tests.scripts.dev_tools.test_validate_orchestration_artifacts` rather than duplicating it,
  following the sibling-module convention already used by
  `test_validate_orchestration_artifacts_dispatch.py`; name the new file distinctly from the
  pre-existing, unrelated `tests/scripts/dev_tools/test_validate_orchestrator_state.py` (which
  tests a different module, `scripts.dev_tools.validate_orchestrator_state`, directly) to avoid
  collision or confusion between the two files
  - Acceptance: new file exists at the stated path; contains all 8 named test functions and both
    named helper functions with unchanged bodies/assertions/docstrings;
    `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py -q`
    collects and passes all 8 moved tests with 0 failures.

- [x] [P1-T2] Edit `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` to remove
  the 8 test functions and 2 helper functions moved in P1-T1, leaving every other existing test
  and helper (including `build_valid_orchestrator_state`, `build_valid_policy_audit_text`,
  `build_read_text_stub`, `build_complete_large_orchestrator_state`, and all 8 non-relocated
  `test_` functions) in place and unmodified
  - Acceptance:
    `Select-String -Path tests/scripts/dev_tools/test_validate_orchestration_artifacts.py -Pattern 'def test_validate_orchestrator_state_text_requires_receipts_for_completion|def test_validate_orchestrator_state_text_accepts_legacy_list_delegation_receipts|def test_validate_orchestrator_state_text_accepts_promotion_receipt_namespace|def test_validate_orchestrator_state_text_rejects_json_root_that_is_not_an_object|def test_validate_orchestrator_state_rejects_noncontainer_receipts|def test_validate_orchestrator_state_rejects_unknown_promotion_receipt_keys|def test_validate_orchestrator_state_text_rejects_receipt_missing_result_signal|def test_validate_orchestrator_state_rejects_receipt_nonlist_artifact_paths|def get_first_receipt|def build_namespaced_orchestrator_state'`
    returns no matches; `git diff --stat -- tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`
    shows only removed lines and the necessary import-line adjustment, no other line changed.

- [x] [P1-T3] Run
  `(Get-Content tests/scripts/dev_tools/test_validate_orchestration_artifacts.py | Measure-Object -Line).Lines`
  and record the result against the two acceptance branches below (exactly one applies):
  - **Primary branch (target achieved):** if the recorded value is ≤ 500, write
    `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/python-linecount-result.<timestamp>.md`
    recording the value, and proceed to P1-T4.
  - **Escalation branch (target not achieved):** if the recorded value still exceeds 500 after
    the P1-T1/P1-T2 relocation, do not perform any further relocation attempt in this task; do
    not record the outcome as passing or "as close as achievable." Instead write
    `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/other/file-size-exception-request.<timestamp>.md`
    documenting: the recorded line count, the exact remaining functions/helpers in the file, and
    a concrete explanation of why relocating any of them further would break shared-fixture
    cohesion; the task is then complete only once this exception-request artifact exists, and
    plan execution halts at this task pending an explicit, documented, user-approved exception —
    Phase 2 and Phase 3 of this plan are not executed under this branch until that approval is
    granted and recorded.
  - Acceptance: exactly one of the two artifacts above exists, recording which branch applied; a
    plan progress note (in the plan-execution log, not `spec.md`) states which branch was taken.

- [x] [P1-T4] (Primary branch only) Confirm
  `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` was not modified by
  this fix: run
  `git diff --stat -- tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py`
  and confirm the output is empty
  - Acceptance: command output is empty, proving the existing sibling split file from cycle 1
    was neither weakened nor altered by this cycle's extraction.

- [x] [P1-T5] (Primary branch only) Run `poetry run pytest tests/scripts/dev_tools -q`; confirm
  total passed count equals the P0-T7 baseline passed count (net-zero change, since tests were
  relocated, not added or removed or skipped), skipped count unchanged, and 0 failures
  - Acceptance: `EXIT_CODE: 0`; recorded passed/skipped counts equal the P0-T7 baseline values;
    0 failed.

### Phase 2 — Python Toolchain Verification (Primary Branch Only)

- [x] [P2-T1] Run `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`; write
  `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-python-format.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`
    recording zero files requiring reformatting.

- [x] [P2-T2] Run `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`; write
  `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-python-lint.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`
    recording zero violations.

- [x] [P2-T3] Run `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`; write
  `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-python-typecheck.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`
    recording zero errors.

- [x] [P2-T4] Run
  `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools`;
  write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-python-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`
    recording total passed/skipped counts equal to the P0-T7 baseline (0 failed), and numeric
    line/branch coverage percentages for `scripts.dev_tools` with no regression relative to the
    P0-T7 baseline figures.

- [x] [P2-T5] Write
  `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/python-test-split-cycle2.<timestamp>.md`
  consolidating the P1-T3 line-count result, P1-T4 and P1-T5 results, and the P2-T1 through
  P2-T4 toolchain results
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for
    each of the four toolchain stages plus the final line-count figure and the P1-T5 pass-count
    comparison against baseline.

### Phase 3 — Closeout: Checkbox-State Confirmation (Primary Branch Only)

- [x] [P3-T1] Confirm `spec.md`'s AC14 checkbox (all four quality toolchains pass with no
  coverage regression) remains unchecked (`- [ ]`); do not edit `spec.md` in this task
  - Acceptance: `Select-String -Path docs/features/active/2026-07-02-epic-orchestrate-275/spec.md -Pattern '^- \[ \] AC14:'`
    returns exactly one match; `spec.md` is unmodified by this task.

- [x] [P3-T2] Confirm `spec.md`'s Generic closing item
  `- [ ] Toolchain pass completed (format → lint → type-check → test)` remains unchecked
  (`- [ ]`); do not edit `spec.md` in this task
  - Acceptance: `Select-String -Path docs/features/active/2026-07-02-epic-orchestrate-275/spec.md -Pattern '^- \[ \] Toolchain pass completed'`
    returns exactly one match; `spec.md` is unmodified by this task.

- [x] [P3-T3] Write
  `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/remediation-cycle-2026-07-03T00-15-final-summary.<timestamp>.md`
  stating the outcome of the single fix (line-count result, toolchain pass/fail state), that no
  PowerShell/TypeScript artifact was re-run in this cycle (out of scope per
  `remediation-inputs.2026-07-03T00-15.md`), that `spec.md` AC14 and the Generic
  "Toolchain pass completed" item remain unchecked pending re-audit, and that the next step is a
  `feature-review` pass producing new `code-review`, `feature-audit`, and `policy-audit`
  artifacts at a new exit timestamp, which alone may re-evaluate those items for check-off
  - Acceptance: artifact contains `Timestamp:` and an explicit pass/fail line for the single fix,
    referencing the P1-T3/P1-T5 and P2-T1 through P2-T4 evidence files produced in this cycle.
