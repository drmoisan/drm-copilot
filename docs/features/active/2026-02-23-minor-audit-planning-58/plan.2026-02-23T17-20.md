---
issue: 58
parent: none
owner: drmoisan
last_updated: 2026-02-23T17-20
status: Planned
status_color: blue
version: 0.2
work_mode: full
---

# 2026-02-23-minor-audit-planning (Plan)

![Status: Planned](https://img.shields.io/badge/Status-Planned-blue)

- Issue: #58
- Parent: none
- Owner: drmoisan
- Last Updated: 2026-02-23T17-20
- Status: Planned
- Version: 0.2
- Work Mode Source: `docs/features/active/2026-02-23-minor-audit-planning-58/issue.md` (`- Work Mode: full`)

## Preflight Route Contract

- Planning route: `python-atomic-planning -> atomic_planner -> atomic_executor`
- Directive line for validation handoff:

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

- Validation loop rule: apply executor plan deltas and re-run preflight until final signal is exactly:

`PREFLIGHT: ALL CLEAR`

## Deterministic Scope

- Feature folder: `docs/features/active/2026-02-23-minor-audit-planning-58`
- Authoritative docs:
  - `docs/features/active/2026-02-23-minor-audit-planning-58/issue.md`
  - `docs/features/active/2026-02-23-minor-audit-planning-58/spec.md`
  - `docs/features/active/2026-02-23-minor-audit-planning-58/user-story.md`
- Prior-context docs to ingest:
  - `artifacts/research/20260223-minor-audit-planning-58-research.md`
  - `docs/features/active/2026-02-22-create-active-folder-bug-43/plan.2026-02-22T14-53.md`
- `.github` and resolver/task files in scope:
  - `.github/prompts/generate-atomic-plan.prompt.md`
  - `.github/codex/execute-hard-lock.prompt.md`
  - `.github/codex/resume-hard-lock.prompt.md`
  - `.github/agents/atomic_planning.agent.md`
  - `.github/agents/atomic_executor.agent.md`
  - `.github/agents/python-atomic-planning.agent.md`
  - `.github/agents/python-atomic-executor.agent.md`
  - `.github/agents/powershell-atomic-planning.agent.md`
  - `.github/agents/powershell-atomic-executor.agent.md`
  - `scripts/dev_tools/resolve_file_prompt.py`
  - `scripts/dev_tools/resolve_hard_lock_prompt.py`
  - `scripts/dev_tools/resolve_execute_plan_prompt.py`
  - `.vscode/tasks.json`
- New helper and tests in scope:
  - `scripts/dev_tools/prompt_mode_contract.py`
  - `tests/scripts/dev_tools/test_prompt_mode_contract.py`
  - `tests/scripts/dev_tools/test_resolve_file_prompt.py`
  - `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`
  - `tests/scripts/dev_tools/test_resolve_execute_plan_prompt.py`
  - `tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py`

## Requirements and Constraints

| ID | Type | Deterministic Statement |
| --- | --- | --- |
| REQ-1 | Context | Implementation must read `.github` contracts plus prior minor-audit artifacts before editing in-scope files. |
| REQ-2 | Functional | Atomic planning/execution agent docs must express a single minor-audit mode precedence contract that fails closed to `full`. |
| REQ-3 | Functional | Skill references must be used as canonical logic source instead of duplicated mode-rule prose where practical. |
| REQ-4 | Functional | `generate-atomic-plan` prompt and its resolver path must carry selected mode and fallback reason context. |
| REQ-5 | Functional | Execute and resume hard-lock templates and resolver selection must be mode-aware and use dynamic `${plan-path}` resolution. |
| REQ-6 | Functional | A new developer task must resolve and load the resume hard-lock prompt from the active plan file. |
| REQ-7 | Quality | All changed Python files must satisfy repo typing, linting, and intent-doc/comment policy expectations. |
| REQ-8 | Verification | Full-process QA evidence and post-implementation audit artifacts must be produced under canonical evidence locations. |
| CON-1 | Process | Preflight validation route must be `python-atomic-planning -> atomic_planner -> atomic_executor` and must iterate to `PREFLIGHT: ALL CLEAR`. |
| CON-2 | Process | Final QA loop must pass in one clean pass: Black -> Ruff -> Pyright -> Pytest coverage; JSON format/validate for `.vscode/tasks.json`. |

## Requirements Traceability

| Requirement ID | Implemented By Tasks |
| --- | --- |
| REQ-1 | P0-T1, P0-T2 |
| REQ-2 | P2-T1, P2-T2, P2-T3, P2-T4, P2-T5 |
| REQ-3 | P1-T1, P1-T2, P1-T3 |
| REQ-4 | P3-T1, P3-T2 |
| REQ-5 | P4-T1, P4-T2, P4-T3 |
| REQ-6 | P5-T1, P5-T2 |
| REQ-7 | P6-T1, P6-T2, P6-T3 |
| REQ-8 | P7-T1, P7-T2, P8-T1, P8-T2 |
| CON-1 | P9-T1, P9-T2 |
| CON-2 | P8-T1, P8-T2 |

### Phase 0 — Policy, Context, and Baseline Evidence

Completion Criteria: policy/context read proofs and baseline toolchain artifacts exist under canonical feature evidence folders.

- [x] [P0-T1] Record policy-and-context read evidence in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/baseline/context-read.2026-02-23T17-20.md`.
  - Acceptance: artifact exists and contains exact lines `Timestamp: 2026-02-23T17-20`, `Command: context-read`, `EXIT_CODE: 0`, and explicit file list entries for the three authoritative feature docs, the two prior-context docs, and `.github/skills/atomic-plan-contract/SKILL.md`.

- [x] [P0-T2] Record `.github` contract read evidence in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/baseline/github-contract-read.2026-02-23T17-20.md`.
  - Acceptance: artifact exists and contains exact lines `Timestamp: 2026-02-23T17-20`, `Command: github-contract-read`, `EXIT_CODE: 0`, and references the nine in-scope `.github` files listed in Deterministic Scope.

- [x] [P0-T3] Capture baseline Python formatter evidence in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/baseline/black.2026-02-23T17-20.md`.
  - Acceptance: artifact contains `Timestamp`, `Command: poetry run black .`, `EXIT_CODE`, and `Output Summary`.

- [x] [P0-T4] Capture baseline Python lint evidence in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/baseline/ruff.2026-02-23T17-20.md`.
  - Acceptance: artifact contains `Timestamp`, `Command: poetry run ruff check`, `EXIT_CODE`, and `Output Summary`.

- [x] [P0-T5] Capture baseline Python type-check evidence in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/baseline/pyright.2026-02-23T17-20.md`.
  - Acceptance: artifact contains `Timestamp`, `Command: poetry run pyright`, `EXIT_CODE`, and `Output Summary`.

- [x] [P0-T6] Capture baseline Python test evidence in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/baseline/pytest.2026-02-23T17-20.md`.
  - Acceptance: artifact contains `Timestamp`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE`, and `Output Summary`.

- [x] [P0-T7] Capture baseline JSON tooling evidence in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/baseline/json-gates.2026-02-23T17-20.md`.
  - Acceptance: artifact contains exact lines for both commands `poetry run python -m scripts.dev_tools.format_json` and `poetry run python -m scripts.dev_tools.validate_json`, plus `Timestamp` and `EXIT_CODE` fields.

### Phase 1 — Shared Mode-Contract and Skill Reuse Design Lock

Completion Criteria: helper-module contract and skill-reference usage map are frozen before implementation edits.

- [x] [P1-T1] Define shared mode parser API in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/other/mode-contract-api.2026-02-23T17-20.md`.
  - Acceptance: artifact contains exact exported names `parse_issue_work_mode`, `resolve_selected_work_mode`, and `build_fallback_reason` for the planned `scripts/dev_tools/prompt_mode_contract.py` module.

- [x] [P1-T2] Define skill de-duplication mapping in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/other/skill-dedup-map.2026-02-23T17-20.md`.
  - Acceptance: artifact lists `atomic-plan-contract` as canonical source for mode precedence and preflight loop text, and `policy-compliance-order` as canonical policy-order source.

- [x] [P1-T3] Define resolver/template variable contract in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/other/prompt-variable-contract.2026-02-23T17-20.md`.
  - Acceptance: artifact contains exact placeholder names `${work-mode}`, `${fallback-reason}`, and `${plan-path}` with source-of-truth note `issue.md marker first, fail closed to full`.

### Phase 2 — Atomic Planning/Execution Agents Minor-Audit Parity

Completion Criteria: all in-scope planning/execution agent files express aligned mode precedence and preflight behavior.

- [x] [P2-T1] Update `.github/agents/python-atomic-planning.agent.md` to include explicit three-step mode precedence with override reconciliation.
  - Acceptance: file contains exact ordered text `Persisted marker`, `Explicit workflow override only if repo policy allows and only if reconciled against issue.md`, and `fail closed to full when marker is missing or malformed`.

- [x] [P2-T2] Update `.github/agents/powershell-atomic-planning.agent.md` to mirror the same three-step precedence wording.
  - Acceptance: file contains the same three precedence steps in order and retains the existing `powershell_atomic_executor` preflight label.

- [x] [P2-T3] Update `.github/agents/atomic_executor.agent.md` to reference `atomic-plan-contract` for mode gate semantics where duplicated prose can be reduced.
  - Acceptance: file still contains required signals `PREFLIGHT: ALL CLEAR` and `PREFLIGHT: REVISIONS REQUIRED` and includes an explicit mention of `atomic-plan-contract` as system-of-record for mode gate behavior.

- [x] [P2-T4] Update `.github/agents/python-atomic-executor.agent.md` to ensure mode-aware preflight text matches generic executor semantics.
  - Acceptance: file contains `Resolve mode from issue.md marker first`, `fail closed to full`, and `minor-audit evidence-task gate` statements with no contradictory alternate precedence.

- [x] [P2-T5] Update `.github/agents/powershell-atomic-executor.agent.md` to ensure mode-aware preflight text matches generic executor semantics.
  - Acceptance: file contains `Resolve mode from issue.md marker first`, `fail closed to full`, and `minor-audit evidence-task gate` statements with no contradictory alternate precedence.

### Phase 3 — generate-atomic-plan Minor-Audit Template and Resolver Selection

Completion Criteria: planning prompt and file resolver flow carry mode and fallback variables deterministically.

- [x] [P3-T1] Update `.github/prompts/generate-atomic-plan.prompt.md` to require mode-aware inputs for `${work-mode}` and `${fallback-reason}`.
  - Acceptance: prompt file contains exact placeholder tokens `${work-mode}` and `${fallback-reason}` and retains mandatory preflight loop language with directive line unchanged.

- [x] [P3-T2] Update `scripts/dev_tools/resolve_file_prompt.py` to resolve `${work-mode}` and `${fallback-reason}` from feature `issue.md` via shared helper logic.
  - Acceptance: running `poetry run pytest tests/scripts/dev_tools/test_resolve_file_prompt.py -k work_mode` exits with code 0 after corresponding tests are added.

### Phase 4 — Hard-Lock and Resume-Hard-Lock Mode-Aware Templates and Resolver Selection

Completion Criteria: execute/resume templates are symmetric, dynamic-path based, and mode-aware.

- [x] [P4-T1] Update `.github/codex/execute-hard-lock.prompt.md` to include resolved work-mode context block without changing existing preflight signal requirements.
  - Acceptance: prompt includes `${work-mode}` and retains exact strings `DIRECTIVE: PREFLIGHT VALIDATION ONLY`, `PREFLIGHT: ALL CLEAR`, and `PREFLIGHT: REVISIONS REQUIRED`.

- [x] [P4-T2] Replace static path in `.github/codex/resume-hard-lock.prompt.md` with dynamic `${plan-path}` and add `${work-mode}` context.
  - Acceptance: file no longer contains the hardcoded feature plan path `docs/features/active/2026-01-06-populate-open-stax-ck-12-manifest-73/v4/plan.2026-01-29T05-45.md` and now contains `${plan-path}` and `${work-mode}`.

- [x] [P4-T3] Update `scripts/dev_tools/resolve_hard_lock_prompt.py` to support template selection for execute vs resume and inject mode/fallback variables.
  - Acceptance: running `poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k resume` exits with code 0 after corresponding tests are added.

### Phase 5 — New Resume Hard-Lock Resolve/Load Tooling

Completion Criteria: developer tasking can resolve resume hard-lock prompts from active plan files.

- [x] [P5-T1] Add `Dev: Resolve Resume Hard-Lock Prompt` task entry to `.vscode/tasks.json` using `scripts/dev_tools/resolve_hard_lock_prompt.py` with explicit resume template selection argument.
  - Acceptance: `.vscode/tasks.json` contains exactly one task label `Dev: Resolve Resume Hard-Lock Prompt` and includes argument token `--template-kind` with value `resume`.

- [x] [P5-T2] Ensure existing execute hard-lock task remains backward compatible after resolver interface change.
  - Acceptance: `.vscode/tasks.json` retains task label `Dev: Resolve Execute Hard-Lock Prompt` and still passes `--workspace ${workspaceFolder}` and `--target ${file}`.

### Phase 6 — Python Helper + Test Coverage + Doc-Comment Compliance

Completion Criteria: shared Python helper exists with robust docstrings/intent comments and scenario-level tests cover mode/fallback contracts.

- [x] [P6-T1] Create `scripts/dev_tools/prompt_mode_contract.py` with typed helper functions and required intent-first docstrings/comments.
  - Acceptance: file exists and contains function definitions `parse_issue_work_mode`, `resolve_selected_work_mode`, and `build_fallback_reason`, each with docstring sections including `Purpose:` and `Args:`.

- [x] [P6-T2] Add `tests/scripts/dev_tools/test_prompt_mode_contract.py` scenarios for valid minor marker, valid full marker, missing marker fail-closed full, malformed marker fail-closed full, and explicit fallback reason text.
  - Acceptance: running `poetry run pytest tests/scripts/dev_tools/test_prompt_mode_contract.py` exits with code 0.

- [x] [P6-T3] Extend resolver tests with mode-aware scenarios in `tests/scripts/dev_tools/test_resolve_file_prompt.py`, `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`, and `tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py`.
  - Acceptance: commands `poetry run pytest tests/scripts/dev_tools/test_resolve_file_prompt.py -k work_mode`, `poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k resume`, and `poetry run pytest tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py -k mode` each exit with code 0.

### Phase 7 — Targeted Verification Evidence

Completion Criteria: targeted resolver/template validations are recorded with machine-checkable evidence.

- [x] [P7-T1] Record targeted execute/resume resolver pass evidence in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/regression-testing/pass-hard-lock-resolvers.2026-02-23T17-20.md`.
  - Acceptance: artifact exists with `Timestamp`, `Command`, and `EXIT_CODE: 0` fields and includes both commands for execute and resume resolver tests.

- [x] [P7-T2] Record targeted mode-contract pass evidence in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/regression-testing/pass-mode-contract.2026-02-23T17-20.md`.
  - Acceptance: artifact exists with `Timestamp`, `Command: poetry run pytest tests/scripts/dev_tools/test_prompt_mode_contract.py`, and `EXIT_CODE: 0`.

### Phase 8 — Final QA Loop and End-State Audit Artifacts

Completion Criteria: one clean final QA pass is documented and policy/code/feature audits are present under the feature folder.

- [x] [P8-T1] Execute final QA loop and record qa-gate artifacts under `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/qa-gates/`.
  - Acceptance: artifacts `black-final.2026-02-23T17-20.md`, `ruff-final.2026-02-23T17-20.md`, `pyright-final.2026-02-23T17-20.md`, `pytest-final.2026-02-23T17-20.md`, and `json-final.2026-02-23T17-20.md` exist and each contains `Timestamp`, `Command`, `EXIT_CODE`, and for baseline-style summaries include `Output Summary`.

- [x] [P8-T2] Create final QA summary in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/qa-gates/final-pass-summary.2026-02-23T17-20.md`.
  - Acceptance: summary file exists with exact line `AllFinalGatesPassed: true` and references all five final qa-gate artifact filenames from P8-T1.

- [x] [P8-T3] Generate policy audit artifact from template at `docs/features/active/2026-02-23-minor-audit-planning-58/policy-audit.2026-02-23T17-20.md`.
  - Acceptance: file exists, has no placeholder token `[Component Name]`, and includes section header `## Compliance Verdict`.

- [x] [P8-T4] Generate post-implementation review artifacts `code-review.2026-02-23T17-20.md` and `feature-audit.2026-02-23T17-20.md` in the feature folder.
  - Acceptance: both files exist and each contains exact lines `Issue: #58`, `Work Mode: full`, and `Plan Path: docs/features/active/2026-02-23-minor-audit-planning-58/plan.2026-02-23T17-20.md`.

### Phase 9 — Mandatory Planner-Executor Preflight Loop

Completion Criteria: preflight loop evidence proves validator route and final all-clear signal.

- [x] [P9-T1] Run validation-only preflight via route `python-atomic-planning -> atomic_planner -> atomic_executor` using directive `DIRECTIVE: PREFLIGHT VALIDATION ONLY` and store each iteration response in `docs/features/active/2026-02-23-minor-audit-planning-58/evidence/other/preflight-loop.2026-02-23T17-20.md`.
  - Acceptance: artifact includes at least one iteration block with exact fields `Iteration`, `ValidatorRoute`, `Directive`, and `Signal`.

- [x] [P9-T2] Iterate plan revisions until final preflight signal is all-clear and record final line in the same preflight artifact.
  - Acceptance: last non-empty line of `preflight-loop.2026-02-23T17-20.md` is exactly `PREFLIGHT: ALL CLEAR`.
