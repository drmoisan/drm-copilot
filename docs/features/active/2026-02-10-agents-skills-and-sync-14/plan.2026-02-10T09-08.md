---
title: "2026-02-10-agents-skills-and-sync - Plan"
issue: "14"
parent: "none"
owner: "drmoisan"
last_updated: "2026-02-10T09-08"
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
  - Acceptance: Evidence file contains `Timestamp`, `Command`, and `EXIT_CODE` for each command run in the exact order: `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.

### Phase 1 — Taxonomy Documentation (REQ-1, CON-1, CON-2)

- [x] [P1-T1] Create `.github/skills/README.md` describing the SKILL taxonomy, required frontmatter keys, and the canonical-location rule.
  - Acceptance: File exists with sections titled `Taxonomy`, `Frontmatter Requirements`, `Canonical Location`, and `Examples`, and includes the example frontmatter from `research.md`.
- [x] [P1-T2] Update `README.md` to link to `.github/skills/README.md` under a new `Skills` subsection.
  - Acceptance: `README.md` contains a bullet link to `.github/skills/README.md` under a `Skills` subsection.

### Phase 2 — Feature Review Skill Extraction (REQ-2, CON-1)

- [ ] [P2-T1] Create `.github/skills/feature-review-workflow/SKILL.md` with the workflow content from `research.md` and include a `Canonical Location` section that points to `.github/skills/feature-review-workflow/SKILL.md`.
  - Acceptance: File exists with frontmatter `name: feature-review-workflow` and `description:` as in `research.md`, and includes the four-step process listed in `research.md`.
- [ ] [P2-T2] Update `.github/agents/feature-review.agent.md` to reference the new skill and remove duplicated workflow steps.
  - Acceptance: The agent file contains an explicit reference to `.github/skills/feature-review-workflow/SKILL.md` and no longer lists the baseline/evidence/remediation steps verbatim.
- [ ] [P2-T3] Update `.github/prompts/review-feature.prompt.md` to be a thin loader that references the skill and lists only required inputs and deliverables.
  - Acceptance: The prompt file removes duplicate workflow steps and includes a single sentence noting the skill provides operational steps.

### Phase 3 — Skill Taxonomy Validator (REQ-3, CON-2, CON-3)

- [ ] [P3-T1] [expect-fail] Add Pytest unit test for `SkillRegistry.validate()` reporting a missing `SKILL.md` file in `tests/scripts/dev_tools/test_skill_taxonomy.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_skill_taxonomy.py -k missing_skill` fails and a regression artifact is stored at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/missing-skill.<timestamp>.md` with `Timestamp`, `Command`, and `EXIT_CODE`.
- [ ] [P3-T2] [expect-fail] Add Pytest unit test for `SkillRegistry.validate()` reporting duplicate canonical locations in `tests/scripts/dev_tools/test_skill_taxonomy.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_skill_taxonomy.py -k duplicate_canonical` fails and a regression artifact is stored at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/duplicate-canonical.<timestamp>.md` with `Timestamp`, `Command`, and `EXIT_CODE`.
- [ ] [P3-T3] [expect-fail] Add Pytest unit test for `SkillRegistry.validate()` reporting missing frontmatter keys in `tests/scripts/dev_tools/test_skill_taxonomy.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_skill_taxonomy.py -k missing_frontmatter` fails and a regression artifact is stored at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/missing-frontmatter.<timestamp>.md` with `Timestamp`, `Command`, and `EXIT_CODE`.
- [ ] [P3-T4] Implement `scripts/dev_tools/skill_taxonomy.py` with `SkillRegistry`, `SkillMetadata`, `SkillValidationError`, and `validate()` to satisfy tests.
  - Acceptance: The module defines `SkillRegistry.from_root(root: Path) -> SkillRegistry` and `validate() -> list[SkillValidationError]`, and the tests from P3-T1 through P3-T3 pass.
- [ ] [P3-T5] Add CLI entry `python scripts/dev_tools/skill_taxonomy.py <repo_root>` that prints errors and exits non-zero when validation fails.
  - Acceptance: `python scripts/dev_tools/skill_taxonomy.py .` exits with code `1` when validation errors are present and prints one line per error prefixed with `SKILL_VALIDATION_ERROR:`.

### Phase 4 — Sync Validation Coverage (REQ-4, REQ-5)

- [ ] [P4-T1] [expect-fail] Add Pytest unit test for `AgenticSyncer._select_source()` choosing forced direction in `tests/scripts/dev_tools/test_agentic_sync.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k force_direction` fails and a regression artifact is stored at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/force-direction.<timestamp>.md` with `Timestamp`, `Command`, and `EXIT_CODE`.
- [ ] [P4-T2] [expect-fail] Add Pytest unit test for mtime-equivalent short-circuit in `tests/scripts/dev_tools/test_agentic_sync.py`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k mtime_equivalent` fails and a regression artifact is stored at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/regression-testing/mtime-equivalent.<timestamp>.md` with `Timestamp`, `Command`, and `EXIT_CODE`.
- [ ] [P4-T3] Add an in-memory filesystem test double in `tests/scripts/dev_tools/test_agentic_sync.py` and use it for the new tests.
  - Acceptance: Tests run without touching the real filesystem and do not create temporary files.
- [ ] [P4-T4] Update `scripts/dev_tools/agentic_sync.py` docstrings (if needed) to reference the new validator script and ensure error messages are actionable.
  - Acceptance: `agentic_sync.py` includes a short note in the module docstring pointing to `skill_taxonomy.py` and uses clear error text for invalid repo paths.

### Phase 5 — Final QA Loop (CON-1, CON-2, CON-3)

- [ ] [P5-T1] Run the full toolchain loop until clean: `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: A QA evidence file exists at `docs/features/active/2026-02-10-agents-skills-and-sync-14/evidence/qa-gates/toolchain.<timestamp>.md` with `Timestamp`, `Command`, and `EXIT_CODE` entries for each step, and all exit codes are `0` in the final loop pass.

## Test Plan

- Unit: `SkillRegistry.validate()` missing skill, duplicate canonical, missing frontmatter.
- Unit: `AgenticSyncer._select_source()` forced direction, mtime-equivalent short-circuit.
- Integration: `python scripts/dev_tools/agentic_sync.py <left_repo> <right_repo>` with overlapping `.github` files; verify `artifacts/agentic-sync/` output.
- Manual/CLI: `python scripts/dev_tools/skill_taxonomy.py <repo_root>` with intentional failures to verify error output.

## Open Questions / Notes

- None.
