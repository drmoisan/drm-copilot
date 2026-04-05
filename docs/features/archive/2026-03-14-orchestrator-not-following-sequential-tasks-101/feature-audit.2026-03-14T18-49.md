# Feature Audit: orchestrator-not-following-sequential-tasks (#101)

**Audit Date:** 2026-03-14  
**Base Branch:** `development`  
**Feature Folder:** `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101`

## Scope and baseline

- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101/evidence/**`
  - Live working-tree supplement: current `git status` / diff state, because the refreshed PR context reports an empty committed range against `development`
- **Requirements source:** `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101/spec.md`
- **Work mode:** `full-bug` (resolved from `issue.md`)
- **Base branch assumption:** none; the user explicitly provided `PRBaseBranch=development`
- **Note:** The refreshed canonical PR summary uses the correct base and merge-base (`dc0502de6e7b02ea76720fb898c038f01ad13f92` at `2026-03-14T18:06:59-04:00`), but it shows `Range: dc0502de6e7b02ea76720fb898c038f01ad13f92..dc0502de6e7b02ea76720fb898c038f01ad13f92` because the #101 implementation currently lives in the working tree rather than in branch commits. This audit therefore validates the current code and evidence directly.

## Acceptance criteria inventory (authoritative for this run)

From `spec.md`:

1. For the issue #101 repro, the documented C# small path now requires the sequential short-path lifecycle before planning/execution: potential entry resolution, promotion with `--work-mode minor-audit`, branch creation, active feature folder creation, folder-integrity validation, `${plan-path}` resolution, Phase 0-only execution, validation, and reduced audit.
2. `artifacts/orchestration/csharp-orchestrator-state.json` is documented and validated to carry the lifecycle variables needed for small-path continuity, including non-null `${promotion-type}`, `${short-name}`, `${relativeFile}`, `${long-name}`, `${issue-num}`, `${feature-folder}`, and `${plan-path}` before completion is allowed.
3. Minor-audit invariants are explicit and testable: a valid short-path folder contains `issue.md` with `- Work Mode: minor-audit`, does not contain `spec.md` or `user-story.md`, and cannot pass completion if Phase 0 evidence or reduced-audit artifacts are missing.
4. The root C# orchestrator agent, root C# prompt, root C# state/router skills, and their bundled extension mirrors are updated together so the small-path contract is no longer contradictory across root and packaged customization sources.
5. Regression tests are added or updated in the existing Python test suite to fail on: direct-to-planning/direct-to-engineer shortcut wording, missing `${plan-path}` continuity, missing bundled `acceptance-criteria-tracking` mirror when referenced, or root↔mirror drift.
6. The fix does not change large-path routing thresholds or large-path lifecycle behavior beyond additive checkpoint compatibility needed to share the updated state contract.
7. Final validation for the implementation pass includes a clean repo-root toolchain pass (`poetry run black .`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest`).
8. Documentation and bundled customization references match the final behavior closely enough that a future reader cannot derive a shortcut small path from the C# agent/prompt/skill set.

## Acceptance criteria evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1. Document the full sequential short-path lifecycle before planning/execution. | PASS | `.github/agents/csharp-orchestrator.agent.md` now contains the `S1`–`S8` small-path lifecycle plus `Build minimal-audit atomic plan (preflight all clear)`, `Execute Phase 0 only`, validation, and reduced-audit steps; the prompt mirrors that lifecycle. Red artifacts show the old wording failed before the fix. | `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`; red artifacts under `evidence/regression-testing/` | The implementation is contract-level, so evidence is strongest in the agent/prompt files and fail-before/pass-after test artifacts. |
| 2. Document and validate the required checkpoint continuity fields, including `${plan-path}`. | PASS | `.github/skills/csharp-orchestration-state-machine/SKILL.md` now documents `work-mode`, `plan-path`, bootstrap metadata, and Phase 0 continuity; `test_csharp_orchestration_state_machine_requires_plan_path_and_bootstrap_fields` passed green after failing red. | same targeted Pytest suite | Validation here is documentation-contract validation rather than a fresh live orchestration rerun. |
| 3. Make minor-audit invariants explicit and testable. | PASS | The root agent, bundled mirrors, and refreshed bundled `feature-promotion-lifecycle` / `atomic-plan-contract` skills now require `issue.md`, reject unexpected `spec.md` / `user-story.md`, and fail closed when Phase 0 evidence or checklist state is inconsistent. | same targeted Pytest suite; static inspection of root and bundled skill files | The invariant language is present in both root and bundled customization sources. |
| 4. Update root and bundled C# customization sources together. | PASS | `evidence/qa-gates/csharp-orchestration-contract-summary.2026-03-14T18-42-49.md` lists changed root and mirror files; `test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence` enforces mirror parity and presence of bundled `acceptance-criteria-tracking`. | `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` | The bundled mirror now includes `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md`. |
| 5. Add regression tests for shortcut wording, continuity, and mirror drift. | PASS | `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` adds six focused tests; five red artifacts capture pre-fix failures; the green artifact records `6 passed in 0.04s`. | `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` | The tests directly lock the issue’s contract drift vectors. |
| 6. Preserve large-path thresholds and large-path lifecycle behavior. | PASS | `.github/skills/csharp-change-budget-router/SKILL.md` still contains `1-3` and `>3` thresholds; `test_csharp_orchestrator_large_path_chain_remains_csharp_atomic_pipeline` confirms the large-path C# atomic planning chain remains present. | same targeted Pytest suite | The update is additive to checkpoint continuity and small-path lifecycle wording. |
| 7. Finish with a clean repo-root toolchain pass. | PASS | In-session verification succeeded: Black clean, Ruff clean, Pyright clean, and Pytest `873 passed in 2.99s`; final QA artifacts also exist under `evidence/qa-gates/`. | `poetry run black .`; `poetry run ruff check`; `poetry run pyright`; `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info` | Aggregate coverage stayed stable at `83%`. |
| 8. Keep documentation and bundled references aligned so a shortcut small path cannot be re-derived. | PASS | Root agent/prompt/router/state-machine files, bundled mirrors, and the added bundled shared skill all reflect the same final behavior; the parity test and summary artifact confirm alignment. | same targeted Pytest suite plus static file inspection | The only remaining caution is operational: commit the changes so PR-context can represent them. |

## Summary

**Overall feature readiness:** PASS

The #101 implementation satisfies the acceptance criteria defined in `spec.md` and is supported by strong red/green regression evidence plus a clean repo-root Python QC pass. The refreshed `pr_context` is correctly targeted at `development` and the requested merge-base, even though the committed branch range is empty because the implementation is still uncommitted. That affects PR packaging, not the acceptance status of the current code.

**Recommended follow-up verification steps:**
- Commit the current working-tree changes and rerun `poetry run python -m scripts.dev_tools.pr_context.collector --base development` so the canonical PR artifacts describe a real branch diff.
- Optional but useful: capture one short `/orchestrate-csharp-work` manual rerun note for the original small-scope scenario described in `issue.md`.

## Acceptance Criteria Status
- Source: `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101/spec.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: None. All eight checkbox criteria were already checked in `spec.md`, and this audit verified that checked state against the current code and evidence; no source-file checkbox update was needed.
