# 2026-03-14-orchestrator-not-following-sequential-tasks (Plan)

- **Issue:** #101
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-14T18-08
- **Status:** Approved
- **Version:** 0.2

## Implementation Plan (Atomic Tasks)

DIRECTIVE: PREFLIGHT VALIDATION ONLY

- Requirements source: `spec.md` (resolved from `issue.md` work mode `full-bug`)
- User-story source: `NONE`
- Feature folder: `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101`
- Required target plan path: `c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-14-orchestrator-not-following-sequential-tasks-101\plan.2026-03-14T18-08.md`
- Required preflight validator: `atomic_executor`
- Required final preflight signal: `PREFLIGHT: ALL CLEAR`
- Revision rule: update this exact plan file in place for every preflight revision; do not create sibling `plan.*.md` files.
- Execution gate: Phase 0 may begin only after validation-only preflight reports `PREFLIGHT: ALL CLEAR` for this exact plan path.

### Phase 0 — Context & Baseline

- [x] [P0-T1] Read `.github/copilot-instructions.md` and record completion in the Phase 0 evidence artifact
	- Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/copilot-instructions.md` in `Files Read:`.
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` and record completion in the Phase 0 evidence artifact
	- Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/general-code-change.instructions.md` in `Files Read:`.
- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` and record completion in the Phase 0 evidence artifact
	- Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/general-unit-test.instructions.md` in `Files Read:`.
- [x] [P0-T4] Read `.github/instructions/python-code-change.instructions.md` and record completion in the Phase 0 evidence artifact
	- Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/python-code-change.instructions.md` in `Files Read:`.
- [x] [P0-T5] Read `.github/instructions/python-unit-test.instructions.md` and record completion in the Phase 0 evidence artifact
	- Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/python-unit-test.instructions.md` in `Files Read:`.
- [x] [P0-T6] Read `.github/instructions/python-suppressions.instructions.md` and record completion in the Phase 0 evidence artifact
	- Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/python-suppressions.instructions.md` in `Files Read:`.
- [x] [P0-T7] Read `.github/instructions/self-explanatory-code-commenting.instructions.md` and record completion in the Phase 0 evidence artifact
	- Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/self-explanatory-code-commenting.instructions.md` in `Files Read:`.
- [x] [P0-T8] Record the policy-read order, context package, resolved work mode, acceptance-criteria source, and exact target plan path in `evidence/baseline/phase0-instructions-read.md`
	- Preconditions: `issue.md`, `spec.md`, `artifacts/research/20260314-csharp-orchestrator-small-path-lifecycle-research.md`, `.github/agents/orchestrator.agent.md`, `.github/agents/csharp-orchestrator.agent.md`, `.github/prompts/orchestrate-work.prompt.md`, `.github/prompts/orchestrate-csharp-work.prompt.md`, `.github/skills/feature-promotion-lifecycle/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, `.github/skills/acceptance-criteria-tracking/SKILL.md`, `.github/skills/csharp-orchestration-state-machine/SKILL.md`, and `.github/skills/csharp-change-budget-router/SKILL.md` exist.
	- Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, `Files Read:`, `Work Mode: full-bug`, `AC Source: spec.md`, and `Target Plan Path: c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-14-orchestrator-not-following-sequential-tasks-101\plan.2026-03-14T18-08.md`; its `Files Read:` section explicitly lists `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, and `.github/instructions/self-explanatory-code-commenting.instructions.md`.
- [x] [P0-T9] Run `poetry run black .` and store the baseline result in `evidence/baseline/python-black.<timestamp>.md`
	- Acceptance: a file matching `evidence/baseline/python-black.*.md` exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T10] Run `poetry run ruff check` and store the baseline result in `evidence/baseline/python-ruff.<timestamp>.md`
	- Acceptance: a file matching `evidence/baseline/python-ruff.*.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T11] Run `poetry run pyright` and store the baseline result in `evidence/baseline/python-pyright.<timestamp>.md`
	- Acceptance: a file matching `evidence/baseline/python-pyright.*.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T12] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and store the baseline result in `evidence/baseline/python-pytest.<timestamp>.md`
	- Acceptance: a file matching `evidence/baseline/python-pytest.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric total coverage and numeric `scripts/dev_tools` coverage values.

### Phase 1 — Red Regression Coverage

- [x] [P1-T1] [expect-fail] Add pytest case `test_csharp_orchestrator_small_path_requires_minor_audit_lifecycle` to `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`
	- Acceptance: `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` contains a test named `test_csharp_orchestrator_small_path_requires_minor_audit_lifecycle`, and `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_orchestrator_small_path_requires_minor_audit_lifecycle` fails while writing `evidence/regression-testing/csharp-orchestrator-small-path-red.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_orchestrator_small_path_requires_minor_audit_lifecycle`, and non-zero `EXIT_CODE:`.
- [x] [P1-T2] [expect-fail] Add pytest case `test_orchestrate_csharp_work_prompt_requires_minor_audit_lifecycle` to `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`
	- Acceptance: `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` contains a test named `test_orchestrate_csharp_work_prompt_requires_minor_audit_lifecycle`, and `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_orchestrate_csharp_work_prompt_requires_minor_audit_lifecycle` fails while writing `evidence/regression-testing/orchestrate-csharp-work-prompt-red.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_orchestrate_csharp_work_prompt_requires_minor_audit_lifecycle`, and non-zero `EXIT_CODE:`.
- [x] [P1-T3] [expect-fail] Add pytest case `test_csharp_orchestration_state_machine_requires_plan_path_and_bootstrap_fields` to `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`
	- Acceptance: `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` contains a test named `test_csharp_orchestration_state_machine_requires_plan_path_and_bootstrap_fields`, and `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_orchestration_state_machine_requires_plan_path_and_bootstrap_fields` fails while writing `evidence/regression-testing/csharp-state-machine-red.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_orchestration_state_machine_requires_plan_path_and_bootstrap_fields`, and non-zero `EXIT_CODE:`.
- [x] [P1-T4] [expect-fail] Add pytest case `test_csharp_change_budget_router_requires_orchestrated_small_path_wording` to `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`
	- Acceptance: `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` contains a test named `test_csharp_change_budget_router_requires_orchestrated_small_path_wording`, and `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_change_budget_router_requires_orchestrated_small_path_wording` fails while writing `evidence/regression-testing/csharp-change-budget-router-red.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_change_budget_router_requires_orchestrated_small_path_wording`, and non-zero `EXIT_CODE:`.
- [x] [P1-T5] [expect-fail] Add pytest case `test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence` to `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`
	- Acceptance: `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` contains a test named `test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence`, and `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence` fails while writing `evidence/regression-testing/csharp-customization-bundle-red.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -k test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence`, and non-zero `EXIT_CODE:`.

### Phase 2 — Root Contract Alignment

- [x] [P2-T1] Update `.github/agents/csharp-orchestrator.agent.md` so the C# small path follows the generic short-path Step S1-S8 lifecycle, persists `${plan-path}`, and keeps the existing large-path C# planning/execution chain intact
	- Acceptance: `.github/agents/csharp-orchestrator.agent.md` contains `Build minimal-audit atomic plan (preflight all clear)`, `Execute Phase 0 only`, `Small-scope implementation path`, `Validate small-path delivery and post-QC docs`, `Post-implementation small-path audit`, `${plan-path}`, and the large-path enforcement line `The planning route MUST be csharp-atomic-planning -> atomic_planner -> atomic_executor`.
- [x] [P2-T2] Update `.github/prompts/orchestrate-csharp-work.prompt.md` so the documented small path requires `minor-audit` promotion, folder initialization, minimal-plan preflight, Phase 0-only execution, validation against `issue.md`, and reduced audit
	- Acceptance: `.github/prompts/orchestrate-csharp-work.prompt.md` contains `minor-audit`, `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`, `PREFLIGHT: ALL CLEAR`, `Phase 0 only`, and `validation against issue.md`, and it does not contain `Delegate directly to csharp-typed-engineer for plan + implementation + QA closure.`
- [x] [P2-T3] Update `.github/skills/csharp-orchestration-state-machine/SKILL.md` so the checkpoint schema documents `work-mode`, `plan-path`, bootstrap metadata, and Phase 0 continuity for the small path
	- Acceptance: `.github/skills/csharp-orchestration-state-machine/SKILL.md` contains `work-mode`, `plan-path`, `bootstrap_mode`, `phase0_execution_summary`, and `resume_after_manual_bootstrap` in the required checkpoint-field contract.
- [x] [P2-T4] Update `.github/skills/csharp-change-budget-router/SKILL.md` so the C# router preserves the `1-3` / `>3` thresholds while requiring orchestrated short-path lifecycle steps instead of plan-and-execute shortcut wording
	- Acceptance: `.github/skills/csharp-change-budget-router/SKILL.md` still contains `1-3` and `>3`, and also contains `--work-mode minor-audit`, `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`, `PREFLIGHT: ALL CLEAR`, and `Phase 0 only via atomic_executor`.

### Phase 3 — Bundled Mirror Alignment

- [x] [P3-T1] Sync `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md` to the approved root C# orchestrator contract
	- Acceptance: `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md` exists and matches `.github/agents/csharp-orchestrator.agent.md` exactly.
- [x] [P3-T2] Sync `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-csharp-work.prompt.md` to the approved root C# prompt contract
	- Acceptance: `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-csharp-work.prompt.md` exists and matches `.github/prompts/orchestrate-csharp-work.prompt.md` exactly.
- [x] [P3-T3] Sync `extensions/drm-copilot/resources/customizations/.github/skills/csharp-orchestration-state-machine/SKILL.md` to the approved root C# state-machine skill
	- Acceptance: `extensions/drm-copilot/resources/customizations/.github/skills/csharp-orchestration-state-machine/SKILL.md` exists and matches `.github/skills/csharp-orchestration-state-machine/SKILL.md` exactly.
- [x] [P3-T4] Sync `extensions/drm-copilot/resources/customizations/.github/skills/csharp-change-budget-router/SKILL.md` to the approved root C# change-budget router skill
	- Acceptance: `extensions/drm-copilot/resources/customizations/.github/skills/csharp-change-budget-router/SKILL.md` exists and matches `.github/skills/csharp-change-budget-router/SKILL.md` exactly.
- [x] [P3-T5] Refresh `extensions/drm-copilot/resources/customizations/.github/skills/feature-promotion-lifecycle/SKILL.md` to the current root lifecycle contract
	- Acceptance: `extensions/drm-copilot/resources/customizations/.github/skills/feature-promotion-lifecycle/SKILL.md` exists and matches `.github/skills/feature-promotion-lifecycle/SKILL.md` exactly.
- [x] [P3-T6] Refresh `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` to the current root atomic-plan contract
	- Acceptance: `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` exists and matches `.github/skills/atomic-plan-contract/SKILL.md` exactly.
- [x] [P3-T7] Add `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md` as the bundled mirror of the root shared skill
	- Acceptance: `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md` exists and matches `.github/skills/acceptance-criteria-tracking/SKILL.md` exactly.

### Phase 4 — Green Regression & Audit Readiness

- [x] [P4-T1] Add pytest case `test_csharp_orchestrator_large_path_chain_remains_csharp_atomic_pipeline` to `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`
	- Acceptance: `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` contains a test named `test_csharp_orchestrator_large_path_chain_remains_csharp_atomic_pipeline` that asserts `.github/agents/csharp-orchestrator.agent.md` still contains `Build C# atomic plan (preflight all clear)` and `Execute approved C# atomic plan` in the large-path workflow.
- [x] [P4-T2] Run `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` and store the passing targeted regression result in `evidence/other/csharp-orchestration-contracts-green.<timestamp>.md`
	- Acceptance: a file matching `evidence/other/csharp-orchestration-contracts-green.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`, `EXIT_CODE: 0`, and `Output Summary:` naming the new C# orchestration contract tests.
- [x] [P4-T3] Record an audit-readiness summary in `evidence/qa-gates/csharp-orchestration-contract-summary.<timestamp>.md`
	- Acceptance: a file matching `evidence/qa-gates/csharp-orchestration-contract-summary.*.md` exists and contains the headings `Changed Root Files:`, `Changed Mirror Files:`, `Targeted Regression Command:`, and `Large-Path Preservation:`.

### Phase 5 — Final QA & Audit Closure

If any command in this phase changes files or exits non-zero, restart Phase 5 from [P5-T1].

- [x] [P5-T1] Run `poetry run black .` and store the final QA result in `evidence/qa-gates/python-black.<timestamp>.md`
	- Acceptance: a file matching `evidence/qa-gates/python-black.*.md` exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T2] Run `poetry run ruff check` and store the final QA result in `evidence/qa-gates/python-ruff.<timestamp>.md`
	- Acceptance: a file matching `evidence/qa-gates/python-ruff.*.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T3] Run `poetry run pyright` and store the final QA result in `evidence/qa-gates/python-pyright.<timestamp>.md`
	- Acceptance: a file matching `evidence/qa-gates/python-pyright.*.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T4] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and store the final QA result in `evidence/qa-gates/python-pytest.<timestamp>.md`
	- Acceptance: a file matching `evidence/qa-gates/python-pytest.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric total coverage and numeric `scripts/dev_tools` coverage values.
- [x] [P5-T5] Record the baseline-versus-final Python coverage delta in `evidence/qa-gates/python-coverage-delta.<timestamp>.md`
	- Acceptance: a file matching `evidence/qa-gates/python-coverage-delta.*.md` exists and contains `Baseline Total Coverage:`, `Final Total Coverage:`, `Baseline scripts/dev_tools Coverage:`, `Final scripts/dev_tools Coverage:`, and `No planned command task skipped: true`.
