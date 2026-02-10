---
title: "2026-02-10-agents-skills-and-sync - Plan"
issue: "14"
parent: "none"
owner: "drmoisan"
last_updated: "2026-02-10T14-22"
status: "Planned"
status_color: "blue"
version: "1.0"
---

# 2026-02-10-agents-skills-and-sync - Plan

- **Issue:** #14
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-10T09-08
- **Status:** Planned
- **Version:** 1.0

Status Badge: ![Planned](https://img.shields.io/badge/status-Planned-blue)

## Required References

- [`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md)
- [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- [`.github/instructions/python-suppressions.instructions.md`](../../../../.github/instructions/python-suppressions.instructions.md)
- [`.github/instructions/self-explanatory-code-commenting.instructions.md`](../../../../.github/instructions/self-explanatory-code-commenting.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

Requirements and constraints (machine-parseable):

| ID | Type | Statement | Source |
| --- | --- | --- | --- |
| REQ-1 | requirement | Document the SKILL taxonomy and the canonical-location rule. | spec.md, user-story.md |
| REQ-2 | requirement | Create a reusable feature-review workflow skill and reference it from the agent and prompt. | research.md, spec.md |
| REQ-3 | requirement | Provide actionable validation for missing skills, duplicate canonical locations, and sync conflicts. | user-story.md |
| REQ-4 | requirement | Use the MVP sync script to align `.github` content across repos and produce artifacts. | spec.md |
| REQ-5 | requirement | Add unit coverage for sync decision logic (forced direction, mtime-equivalence short-circuit). | spec.md, research.md |
| CON-1 | constraint | Preserve existing repo structure and instruction precedence. | spec.md |
| CON-2 | constraint | Avoid network-only assumptions; rely on local filesystem. | spec.md |
| CON-3 | constraint | Do not introduce new dependencies. | spec.md |

### Phase 0 — Compliance & Baseline

- [x] [P0-T1] Read `.github/copilot-instructions.md` and record completion in `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/baseline/policy-read.<timestamp>.md`.
  - Acceptance: Evidence file exists with `Timestamp`, `FilesRead`, and `Reader` fields; `FilesRead` includes `.github/copilot-instructions.md`.
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` and `.github/instructions/general-unit-test.instructions.md` in order and append them to the same policy-read evidence file.
  - Acceptance: Evidence file lists both policy paths in order under `FilesRead`.
- [x] [P0-T3] Read `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, and `.github/instructions/self-explanatory-code-commenting.instructions.md` and append them to the same policy-read evidence file.
  - Acceptance: Evidence file lists all four Python policy paths in order under `FilesRead`.
- [x] [P0-T4] Capture baseline toolchain results (format, lint, type-check, tests) and store them in `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/baseline/toolchain-baseline.<timestamp>.md`.
  - Acceptance: Baseline evidence exists at:
    - `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/baseline/toolchain-black.<timestamp>.md`
    - `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/baseline/toolchain-ruff.<timestamp>.md`
    - `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/baseline/toolchain-pyright.<timestamp>.md`
    - `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/baseline/toolchain-pytest.<timestamp>.md`
  - Acceptance: Each baseline evidence file includes `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` (pytest summary must include the total coverage line).
  - Acceptance: A consolidated baseline file at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/baseline/toolchain-baseline.<timestamp>.md` is optional and may be retained for convenience.

### Phase 1 — Taxonomy Documentation (REQ-1, CON-1, CON-2)

- [x] [P1-T1] Create `.github/skills/README.md` describing the SKILL taxonomy, required frontmatter keys, and the canonical-location rule.
  - Acceptance: File exists with sections titled `Taxonomy`, `Frontmatter Requirements`, `Canonical Location`, and `Examples`, and includes the example frontmatter from `research.md`.
- [x] [P1-T2] Update `README.md` to link to `.github/skills/README.md` under a new `Skills` subsection.
  - Acceptance: `README.md` contains a bullet link to `.github/skills/README.md` under a `Skills` subsection.

### Phase 2 — Skill Infrastructure & Reference Review (REQ-2, CON-1)

- [x] [P2-T1] Import the `.github/skills/make-skill-template/SKILL.md` scaffolding skill from awesome-copilot.
  - Acceptance: `.github/skills/make-skill-template/SKILL.md` exists with frontmatter `name: make-skill-template` and a description indicating it scaffolds new skills.
  - Evidence: `.github/skills/make-skill-template/SKILL.md`.
- [x] [P2-T2] Create `.github/skills/skill-canonical-location-audit/SKILL.md` to prevent canonical-location duplication.
  - Acceptance: `.github/skills/skill-canonical-location-audit/SKILL.md` exists with frontmatter `name: skill-canonical-location-audit` and guidance to detect duplicate canonical locations.
  - Evidence: `.github/skills/skill-canonical-location-audit/SKILL.md`.
- [x] [P2-T3] Create `.github/skills/atomic-plan-contract/SKILL.md` to centralize atomic plan format rules.
  - Acceptance: `.github/skills/atomic-plan-contract/SKILL.md` exists with frontmatter `name: atomic-plan-contract` and includes Phase 0 and final QA loop requirements.
  - Evidence: `.github/skills/atomic-plan-contract/SKILL.md`.
- [x] [P2-T4] Create `.github/skills/evidence-and-timestamp-conventions/SKILL.md` to centralize evidence locations and timestamp rules.
  - Acceptance: `.github/skills/evidence-and-timestamp-conventions/SKILL.md` exists with frontmatter `name: evidence-and-timestamp-conventions` and includes ISO-8601 timestamp guidance plus canonical evidence locations.
  - Evidence: `.github/skills/evidence-and-timestamp-conventions/SKILL.md`.
- [x] [P2-T5] Create `.github/skills/policy-audit-template-usage/SKILL.md` to standardize audit template usage.
  - Acceptance: `.github/skills/policy-audit-template-usage/SKILL.md` exists with frontmatter `name: policy-audit-template-usage` and describes template usage steps.
  - Evidence: `.github/skills/policy-audit-template-usage/SKILL.md`.
- [x] [P2-T6] Create `.github/skills/policy-compliance-order/SKILL.md` to standardize mandatory policy reading order.
  - Acceptance: `.github/skills/policy-compliance-order/SKILL.md` exists with frontmatter `name: policy-compliance-order` and lists policy precedence/order constraints.
  - Evidence: `.github/skills/policy-compliance-order/SKILL.md`.
- [x] [P2-T7] Create `.github/skills/pr-context-artifacts/SKILL.md` to define canonical PR context artifact locations and refresh rules.
  - Acceptance: `.github/skills/pr-context-artifacts/SKILL.md` exists with frontmatter `name: pr-context-artifacts` and documents artifact location and refresh behavior.
  - Evidence: `.github/skills/pr-context-artifacts/SKILL.md`.
- [x] [P2-T8] Create `.github/skills/remediation-handoff-atomic-planner/SKILL.md` to standardize feature/epic remediation handoffs.
  - Acceptance: `.github/skills/remediation-handoff-atomic-planner/SKILL.md` exists with frontmatter `name: remediation-handoff-atomic-planner` and specifies the atomic_planner delegation requirements.
  - Evidence: `.github/skills/remediation-handoff-atomic-planner/SKILL.md`.
- [x] [P2-T9] Review `.github/agents/`, `.github/instructions/`, and `.github/prompts/` for duplicative instructions and replace them with skill references where applicable.
  - Acceptance: A review summary exists at `artifacts/research/20260210-skill-files-reference-scan-research.md` listing reviewed paths and the skill references found.
  - Evidence: `artifacts/research/20260210-skill-files-reference-scan-research.md`.
- [x] [P2-T10] Mirror the review summary into the canonical evidence location.
  - Acceptance: `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/other/skill-files-reference-scan.<timestamp>.md` exists and includes `Timestamp`, `Command`, `EXIT_CODE`, and an `Output Summary` of the review.
  - Evidence (status_updater, 2026-02-10T13-45): `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/other/skill-files-reference-scan.2026-02-10T13-05.md`.

### Phase 3 — Skill Taxonomy Validator (REQ-3, CON-2, CON-3)

- [x] [P3-T1] [expect-fail] Add Pytest unit test for `SkillRegistry.validate()` reporting a missing `SKILL.md` file in `tests/scripts/dev_tools/test_skill_taxonomy.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_skill_taxonomy.py -k missing_skill` fails and a regression artifact is stored at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/missing-skill.<timestamp>.md` with `Timestamp`, `Command`, and `EXIT_CODE`.
  - Evidence (status_updater, 2026-02-10T13-45): `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/missing-skill.2026-02-10T13-10.md`.
- [x] [P3-T2] [expect-fail] Add Pytest unit test for `SkillRegistry.validate()` reporting duplicate canonical locations in `tests/scripts/dev_tools/test_skill_taxonomy.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_skill_taxonomy.py -k duplicate_canonical` fails and a regression artifact is stored at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/duplicate-canonical.<timestamp>.md` with `Timestamp`, `Command`, and `EXIT_CODE`.
  - Evidence (status_updater, 2026-02-10T13-45): `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/duplicate-canonical.2026-02-10T13-12.md`.
- [x] [P3-T3] [expect-fail] Add Pytest unit test for `SkillRegistry.validate()` reporting missing frontmatter keys in `tests/scripts/dev_tools/test_skill_taxonomy.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_skill_taxonomy.py -k missing_frontmatter` fails and a regression artifact is stored at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/missing-frontmatter.<timestamp>.md` with `Timestamp`, `Command`, and `EXIT_CODE`.
  - Evidence (status_updater, 2026-02-10T13-45): `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/missing-frontmatter.2026-02-10T13-14.md`.
- [x] [P3-T4] Implement `scripts/dev_tools/skill_taxonomy.py` with `SkillRegistry`, `SkillMetadata`, `SkillValidationError`, and `validate()` to satisfy tests.
  - Acceptance: The module defines `SkillRegistry.from_root(root: Path) -> SkillRegistry` and `validate() -> list[SkillValidationError]`, and the tests from P3-T1 through P3-T3 pass.
  - Evidence (status_updater, 2026-02-10T13-45): `scripts/dev_tools/skill_taxonomy.py`; `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.
- [ ] [P3-T5] Add CLI entry `python scripts/dev_tools/skill_taxonomy.py <repo_root>` that prints errors and exits non-zero when validation fails.
  - Acceptance: `python scripts/dev_tools/skill_taxonomy.py .` exits with code `1` when validation errors are present and prints one line per error prefixed with `SKILL_VALIDATION_ERROR:`.
  - Evidence gap (status_updater, 2026-02-10T13-50): `python scripts/dev_tools/skill_taxonomy.py .` exits with `0` because no validation errors are present in the repo root. Evidence captured at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/other/skill-taxonomy-cli.2026-02-10T13-50.md`.
  - Remaining requirement: demonstrate exit code `1` and `SKILL_VALIDATION_ERROR:` output when validation errors are present in the repo root.

### Phase 4 — Sync Engine Implementation & Coverage (REQ-4, REQ-5)

- [x] [P4-T1] Implement the filesystem abstraction for sync operations in `scripts/dev_tools/agentic_sync.py`.
  - Acceptance: `SyncFileSystem` protocol and `RealSyncFileSystem` class exist with methods `list_files`, `is_file`, `read_text`, `write_text`, `get_mtime`, `set_mtime`, and `ensure_dir`.
  - Evidence (status_updater, 2026-02-10T13-45): `scripts/dev_tools/agentic_sync.py`.
- [x] [P4-T2] Implement sync data models and decision logic in `scripts/dev_tools/agentic_sync.py`.
  - Acceptance: `SyncAction` and `SyncSummary` dataclasses exist, and `AgenticSyncer.sync_repos()` returns a populated `SyncSummary` using timestamp equivalence, content equivalence, and forced direction rules.
  - Evidence (status_updater, 2026-02-10T13-45): `scripts/dev_tools/agentic_sync.py`; `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.
- [x] [P4-T3] Implement artifact and CLI helpers in `scripts/dev_tools/agentic_sync.py`.
  - Acceptance: `build_artifact_path`, `render_sync_summary`, `write_sync_artifact`, `parse_args`, and `main` exist and `main(argv)` returns `0` on success.
  - Evidence (status_updater, 2026-02-10T13-45): `scripts/dev_tools/agentic_sync.py`; `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.
- [x] [P4-T4] Add an in-memory filesystem test double in `tests/scripts/dev_tools/test_agentic_sync.py` for deterministic sync tests.
  - Acceptance: `InMemorySyncFileSystem` exists and tests do not touch the real filesystem or create temporary files.
  - Evidence (status_updater, 2026-02-10T13-45): `tests/scripts/dev_tools/test_agentic_sync.py`.
- [x] [P4-T5] Add Pytest unit test for mtime-equivalent short-circuit in `tests/scripts/dev_tools/test_agentic_sync.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k sync_equivalent_mtime_skips_content` passes.
  - Evidence (status_updater, 2026-02-10T13-45): `tests/scripts/dev_tools/test_agentic_sync.py`; `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.
- [x] [P4-T6] Add Pytest unit test for equivalent content short-circuit in `tests/scripts/dev_tools/test_agentic_sync.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k sync_equivalent_content_skips_write` passes.
  - Evidence (status_updater, 2026-02-10T13-45): `tests/scripts/dev_tools/test_agentic_sync.py`; `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.
- [x] [P4-T7] Add Pytest unit test for newer content propagation and timestamp normalization in `tests/scripts/dev_tools/test_agentic_sync.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k sync_newer_content_propagates_and_normalizes_mtime` passes.
  - Evidence (status_updater, 2026-02-10T13-45): `tests/scripts/dev_tools/test_agentic_sync.py`; `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.
- [x] [P4-T8] Add Pytest unit test for forced direction overriding timestamp selection in `tests/scripts/dev_tools/test_agentic_sync.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k force_left_to_right_overrides_newer_right` passes.
  - Evidence (status_updater, 2026-02-10T13-45): `tests/scripts/dev_tools/test_agentic_sync.py`; `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.
- [x] [P4-T9] Add Pytest unit tests for artifact path generation, JSON rendering, artifact writing, and CLI parsing in `tests/scripts/dev_tools/test_agentic_sync.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k build_artifact_path_uses_timestamp` passes, `-k render_sync_summary_serializes_actions` passes, `-k write_sync_artifact_creates_dir_and_writes` passes, and `-k parse_args_defaults or parse_args_force_flags` passes.
  - Evidence (status_updater, 2026-02-10T13-45): `tests/scripts/dev_tools/test_agentic_sync.py`; `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.
- [x] [P4-T10] Add Pytest unit test for `main()` wiring in `tests/scripts/dev_tools/test_agentic_sync.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k main_runs_sync` passes.
  - Evidence (status_updater, 2026-02-10T13-45): `tests/scripts/dev_tools/test_agentic_sync.py`; `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.

### Phase 5 — Final QA Loop (CON-1, CON-2, CON-3)

- [x] [P5-T1] Run formatter QA gate: `poetry run black .`.
  - Acceptance: QA evidence exists at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-black.<timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` (final exit code `0`).
  - Evidence (status_updater, 2026-02-10T13-45): `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-black.2026-02-10T13-38.md`.
- [x] [P5-T2] Run lint QA gate: `poetry run ruff check`.
  - Acceptance: QA evidence exists at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-ruff.<timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` (final exit code `0`).
  - Evidence (status_updater, 2026-02-10T13-45): `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-ruff.2026-02-10T13-39.md`.
- [x] [P5-T3] Run type-check QA gate: `poetry run pyright`.
  - Acceptance: QA evidence exists at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pyright.<timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` (final exit code `0`).
  - Evidence (status_updater, 2026-02-10T13-45): `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pyright.2026-02-10T13-40.md`.
- [x] [P5-T4] Run tests with coverage QA gate: `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: QA evidence exists at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.<timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` including the total coverage line (final exit code `0`).
  - Evidence (status_updater, 2026-02-10T13-45): `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain-pytest.2026-02-10T13-41.md`.

## Test Plan

- Unit: `SkillRegistry.validate()` missing skill, duplicate canonical, missing frontmatter.
- Unit: `AgenticSyncer._select_source()` forced direction, mtime-equivalent short-circuit.
- Integration: `python scripts/dev_tools/agentic_sync.py <left_repo> <right_repo>` with overlapping `.github` files; verify `artifacts/agentic-sync/` output.
- Manual/CLI: `python scripts/dev_tools/skill_taxonomy.py <repo_root>` with intentional failures to verify error output.

## Open Questions / Notes

- Maintenance: add explicit JSON payload typing in `render_sync_summary` to
  resolve PyLance unknown payload types without behavior changes.
- Maintenance: align Pyright diagnostics with Pylance for unknown variable
  types by enforcing `reportUnknownVariableType` in config.
