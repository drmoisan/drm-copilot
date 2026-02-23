# 2026-02-22-pr-context-verification-contract-gap (Plan)

- **Issue:** #46
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-22T21-00
- **Status:** Planned
- **Status Color:** blue
- **Version:** 1.0
- **Work Mode:** full

## Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan closes the PR-context verification contract gap by making canonical evidence artifacts discoverable and auditable in `pr_context` outputs, while preserving anti-hallucination constraints and the existing collector CLI surface.

## Requirements and Constraints

### Requirements

- **REQ-001:** Expand `Additional context files` enumeration to include canonical feature evidence artifacts under active feature folders used for verification claims.
- **REQ-002:** Add deterministic verification evidence parsing with normalized result derivation from `EXIT_CODE` while preserving conservative fallback for missing or malformed evidence.
- **REQ-003:** Add a summary section in `artifacts/pr_context.summary.txt` that separates evidence-derived verification state from `CI status (HEAD)` output.
- **REQ-004:** Align verification heading extraction semantics across feature-doc discovery and render helpers using the same fallback order (`Verification`, then `Test Plan`).
- **REQ-005:** Preserve collector CLI contract for `poetry run python -m scripts.dev_tools.pr_context.collector --base development` without adding required flags.
- **REQ-006:** Preserve anti-hallucination restrictions in `.github/prompts/generate-pr.prompt.md` while allowing evidence-backed verification wording only when context proves it.
- **REQ-007:** Add deterministic regression and integration coverage for evidence discovery, parsing, fallback behavior, and prompt-contract-safe wording.
- **REQ-008:** Pass final Python QA loop in required order: `black`, `ruff`, `pyright`, `pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.

### Security Requirements

- **SEC-001:** Verification claims in generated PR text must remain source-traceable to `pr_context` outputs and explicitly enumerated additional context files only.

### Constraints

- **CON-001:** TDD sequencing is mandatory; regression scenarios must fail first and capture auditable expect-fail evidence artifacts.
- **CON-002:** Distinguish CI unavailability from evidence-derived pass/fail in summary rendering and wording rules.
- **CON-003:** Keep production file changes limited to verification-contract paths identified in spec/research unless a dependency forcefully requires expansion.
- **CON-004:** Use canonical feature evidence folders and evidence schema fields (`Timestamp`, `Command`, `EXIT_CODE`) for baseline, regression, and QA artifacts.

## Requirements Traceability

| Requirement ID | Description | Implemented By Tasks | Verification Task |
|---|---|---|---|
| REQ-001 | Enumerate canonical evidence files in additional context | P3-T2, P3-T3 | P4-T1 |
| REQ-002 | Parse evidence fields and normalize pass/fail with fallback | P3-T1, P3-T4, P3-T5 | P4-T2, P4-T3 |
| REQ-003 | Add verification-evidence summary section and keep CI separate | P3-T4, P3-T6 | P4-T3 |
| REQ-004 | Unify verification heading fallback behavior | P3-T7 | P4-T4 |
| REQ-005 | Preserve collector CLI surface | P3-T6 | P4-T5 |
| REQ-006 | Keep anti-hallucination constraints with stricter evidence wording tier | P3-T8 | P4-T6 |
| REQ-007 | Add scenario-specific regression and integration tests | P2-T1, P2-T2, P2-T3, P2-T4, P2-T5, P3-T9 | P4-T1, P4-T2, P4-T3, P4-T6 |
| REQ-008 | Pass final full Python toolchain loop | P5-T1, P5-T2, P5-T3, P5-T4 | P5-T5 |
| SEC-001 | Claims remain traceable to allowed context only | P3-T8 | P4-T6 |
| CON-001 | Fail-before evidence before implementation | P2-T1, P2-T2, P2-T3, P2-T4, P2-T5 | P2-T6 |
| CON-002 | CI-unavailable is independent of evidence result | P3-T6, P3-T8 | P4-T3, P4-T6 |
| CON-003 | Scope limited to contract-related files | P1-T1 | P6-T1 |
| CON-004 | Canonical evidence schema/paths are used | P0-T4, P0-T5, P0-T6, P0-T7, P0-T8, P2-T6, P5-T5 | P6-T2 |

### Phase 0 — Context & Inputs

Completion Criteria (machine-verifiable): Policy/spec/research inputs are explicitly recorded, full-mode preconditions are documented, and baseline evidence artifacts exist under canonical `evidence/baseline/` with required fields (`Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`).

- [x] [P0-T1] Record required policy and feature input set in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/baseline/policy-and-input-read.2026-02-22T21-00.md`.
	- Acceptance: Artifact exists and lists exactly these files in order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/issue.md`, `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/spec.md`, `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/user-story.md`, `artifacts/research/20260222-pr-context-verification-contract-gap-implementation-research.md`.
- [x] [P0-T2] Capture baseline repository state in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/baseline/repo-baseline.2026-02-22T21-00.md`.
	- Acceptance: Artifact contains `Timestamp: 2026-02-22T21-00`, `Command: git rev-parse --abbrev-ref HEAD && git rev-parse HEAD`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [x] [P0-T3] Record full-mode precondition evidence in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/baseline/full-mode-preconditions.2026-02-22T21-00.md`.
	- Acceptance: Artifact contains `SpecExists: true` and `UserStoryExists: true` lines.
- [x] [P0-T4] Capture baseline collector output evidence in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/baseline/collector-baseline.2026-02-22T21-00.md` using `poetry run python -m scripts.dev_tools.pr_context.collector --base development`.
	- Acceptance: Artifact contains exact command, `EXIT_CODE`, and `Output Summary` line confirming whether `Verification evidence (feature docs + canonical artifacts)` section is present or absent.
- [x] [P0-T5] Capture baseline formatter evidence in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/baseline/black-baseline.2026-02-22T21-00.md`.
	- Acceptance: Artifact contains exact `Command: poetry run black .`, `EXIT_CODE`, and `Output Summary:`.
- [x] [P0-T6] Capture baseline linter evidence in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/baseline/ruff-baseline.2026-02-22T21-00.md`.
	- Acceptance: Artifact contains exact `Command: poetry run ruff check`, `EXIT_CODE`, and `Output Summary:`.
- [x] [P0-T7] Capture baseline type-check evidence in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/baseline/pyright-baseline.2026-02-22T21-00.md`.
	- Acceptance: Artifact contains exact `Command: poetry run pyright`, `EXIT_CODE`, and `Output Summary:`.
- [x] [P0-T8] Capture baseline test evidence in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/baseline/pytest-cov-baseline.2026-02-22T21-00.md`.
	- Acceptance: Artifact contains exact `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE`, and `Output Summary:`.

### Phase 1 — Scope Lock and Design Freeze

Completion Criteria (machine-verifiable): In-scope file list, out-of-scope boundaries, and deterministic parser/render contracts are frozen before TDD red tasks begin.

- [x] [P1-T1] Freeze scope map in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/other/scope-map.2026-02-22T21-00.md`.
	- Acceptance: Artifact lists only these production paths in scope: `scripts/dev_tools/pr_context/collector.py`, `scripts/dev_tools/pr_context/feature_docs.py`, `scripts/dev_tools/pr_context/render_feature_excerpts.py`, `scripts/dev_tools/pr_context/summary_helpers.py` (if needed), `scripts/dev_tools/pr_context/verification_evidence.py` (new), `.github/prompts/generate-pr.prompt.md`; and lists these test paths in scope: `tests/scripts/dev_tools/test_collect_pr_context.py`, `tests/scripts/dev_tools/test_collect_pr_context_part4.py`, `tests/scripts/dev_tools/test_pr_context_integration.py`, `tests/scripts/dev_tools/test_feature_docs.py`.
- [x] [P1-T2] Freeze canonical evidence discovery contract in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/other/evidence-discovery-contract.2026-02-22T21-00.md`.
	- Acceptance: Artifact contains exact deterministic search roots `evidence/qa-gates/**/*.md`, `evidence/regression-testing/**/*.md`, `evidence/other/**/*.md` under active feature folders and states stable sort + de-duplication.
- [x] [P1-T3] Freeze parser normalization contract in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/other/evidence-parser-contract.2026-02-22T21-00.md`.
	- Acceptance: Artifact contains exact rules `EXIT_CODE == 0 -> pass`, `EXIT_CODE != 0 -> fail`, and missing required field => `unparseable` fallback.
- [x] [P1-T4] Freeze wording-tier contract for `.github/prompts/generate-pr.prompt.md` in `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/other/prompt-wording-contract.2026-02-22T21-00.md`.
	- Acceptance: Artifact contains both constraints: `DO NOT cite files not listed under Additional context files` and `CI unavailable must not be treated as evidence failure`.

### Phase 2 — TDD Red (Regression Fails First)

Completion Criteria (machine-verifiable): Scenario-specific regression tests exist and each expect-fail run has auditable evidence with required fields and failing signals.

- [x] [P2-T1] [expect-fail] Add regression test `test_collector_includes_canonical_evidence_paths_in_additional_context_files` in `tests/scripts/dev_tools/test_collect_pr_context.py`.
	- Depends on: P1-T1, P1-T2.
	- Acceptance: Test name exists exactly and references expected path fragment `/evidence/`.
- [x] [P2-T2] [expect-fail] Add regression test `test_collector_verification_evidence_section_is_rendered_with_normalized_fields` in `tests/scripts/dev_tools/test_collect_pr_context_part4.py`.
	- Depends on: P1-T3.
	- Acceptance: Test name exists exactly and asserts `Timestamp`, `Command`, `EXIT_CODE`, and `Normalized result` substrings.
- [x] [P2-T3] [expect-fail] Add regression test `test_collector_reports_unparseable_evidence_without_claiming_completion` in `tests/scripts/dev_tools/test_collect_pr_context_part4.py`.
	- Depends on: P1-T3.
	- Acceptance: Test name exists exactly and asserts conservative fallback string `No canonical verification evidence parsed`.
- [x] [P2-T4] [expect-fail] Add regression test `test_feature_doc_and_render_helpers_share_verification_then_test_plan_fallback` in `tests/scripts/dev_tools/test_feature_docs.py`.
	- Depends on: P1-T1.
	- Acceptance: Test name exists exactly and asserts both headings are supported in order.
- [x] [P2-T5] [expect-fail] Add integration regression test `test_prompt_contract_allows_evidence_backed_verification_only_when_enumerated` in `tests/scripts/dev_tools/test_pr_context_integration.py`.
	- Depends on: P1-T4.
	- Acceptance: Test name exists exactly and asserts anti-hallucination restriction plus evidence-backed wording gate.
- [x] [P2-T6] [expect-fail] Run targeted red command set and store failure evidence artifacts under `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/regression-testing/`.
	- Depends on: P2-T1, P2-T2, P2-T3, P2-T4, P2-T5.
	- Acceptance: Five artifacts exist named `expect-fail-context-files.2026-02-22T21-00.md`, `expect-fail-verification-section.2026-02-22T21-00.md`, `expect-fail-unparseable-fallback.2026-02-22T21-00.md`, `expect-fail-heading-fallback-parity.2026-02-22T21-00.md`, `expect-fail-prompt-contract-tier.2026-02-22T21-00.md`; each contains `Timestamp`, exact `Command`, non-zero `EXIT_CODE`, and a `Failure:` excerpt.

### Phase 3 — Minimal Deterministic Implementation

Completion Criteria (machine-verifiable): Contract gap is closed with minimal file edits, deterministic behavior, and no CLI-surface breakage.

- [x] [P3-T1] Add typed helper module `scripts/dev_tools/pr_context/verification_evidence.py` implementing evidence record model and markdown field parsing for `Timestamp`, `Command`, and `EXIT_CODE`.
	- Depends on: P2-T6.
	- Acceptance: Module exports parser function returning normalized status values `pass`, `fail`, or `unparseable`.
- [x] [P3-T2] Add canonical evidence discovery function in `scripts/dev_tools/pr_context/verification_evidence.py` for active feature folders.
	- Depends on: P3-T1.
	- Acceptance: Discovery output is deterministic (sorted ascending path order) and deduplicated.
- [x] [P3-T3] Update `scripts/dev_tools/pr_context/feature_docs.py` to include discovered evidence file paths in each excerpt `context_files` list.
	- Depends on: P3-T2.
	- Acceptance: `context_files` construction includes spec/plan/user-story paths plus evidence paths and remains stable-order deterministic.
- [x] [P3-T4] Update `scripts/dev_tools/pr_context/collector.py` to render section header `===== Verification evidence (feature docs + canonical artifacts) =====` in `artifacts/pr_context.summary.txt`.
	- Depends on: P3-T1.
	- Acceptance: Summary rendering includes per-evidence source row with parsed field values when available.
- [x] [P3-T5] Update `scripts/dev_tools/pr_context/collector.py` fallback rendering for unparseable or missing evidence.
	- Depends on: P3-T4.
	- Acceptance: Summary includes exact fallback line `No canonical verification evidence parsed` when no parseable records exist.
- [x] [P3-T6] Update `scripts/dev_tools/pr_context/collector.py` to preserve independent CI status section semantics while adding evidence-derived section.
	- Depends on: P3-T4.
	- Acceptance: Output includes both section headers `===== CI status (HEAD) =====` and `===== Verification evidence (feature docs + canonical artifacts) =====` in separate blocks.
- [x] [P3-T7] Update `scripts/dev_tools/pr_context/render_feature_excerpts.py` to use the same heading fallback order as `feature_docs.py` (`Verification`, then `Test Plan`).
	- Depends on: P3-T3.
	- Acceptance: Extraction helper behavior matches frozen contract from P1-T4.
- [x] [P3-T8] Update `.github/prompts/generate-pr.prompt.md` verification guidance to allow evidence-backed completion wording only when supported by `pr_context` and enumerated files.
	- Depends on: P3-T6.
	- Acceptance: Prompt still contains anti-hallucination directives and adds explicit rule that CI-unavailable is separate from evidence-derived pass/fail.
- [x] [P3-T9] Update the five added regression tests to green expectations without broadening scope beyond issue #46 requirements.
	- Depends on: P3-T3, P3-T4, P3-T5, P3-T7, P3-T8.
	- Acceptance: No new test modules are introduced beyond files frozen in P1-T1.

### Phase 4 — Targeted Verification (Green)

Completion Criteria (machine-verifiable): All regression scenarios pass with evidence artifacts proving context enumeration, normalized rendering, fallback behavior, semantic parity, and prompt-contract-safe wording.

- [x] [P4-T1] Run green verification for additional-context evidence enumeration and save artifact `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/regression-testing/pass-context-files.2026-02-22T21-00.md`.
	- Depends on: P3-T9.
	- Acceptance: Artifact contains exact command `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context.py -q -k includes_canonical_evidence_paths_in_additional_context_files` and `EXIT_CODE: 0`.
- [x] [P4-T2] Run green verification for normalized evidence rendering and fallback handling and save artifact `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/regression-testing/pass-verification-render-and-fallback.2026-02-22T21-00.md`.
	- Depends on: P3-T9.
	- Acceptance: Artifact contains exact command `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_part4.py -q -k "verification_evidence_section_is_rendered_with_normalized_fields or reports_unparseable_evidence_without_claiming_completion"` and `EXIT_CODE: 0`.
- [x] [P4-T3] Run collector command and save artifact `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/regression-testing/pass-collector-summary-contract.2026-02-22T21-00.md`.
	- Depends on: P3-T6.
	- Acceptance: Artifact contains exact command `poetry run python -m scripts.dev_tools.pr_context.collector --base development`, `EXIT_CODE: 0`, and summary output excerpt containing both `===== CI status (HEAD) =====` and `===== Verification evidence (feature docs + canonical artifacts) =====`.
- [x] [P4-T4] Run green verification for heading-fallback parity and save artifact `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/regression-testing/pass-heading-fallback-parity.2026-02-22T21-00.md`.
	- Depends on: P3-T7.
	- Acceptance: Artifact contains exact command `poetry run pytest tests/scripts/dev_tools/test_feature_docs.py -q -k verification_then_test_plan_fallback` and `EXIT_CODE: 0`.
- [x] [P4-T5] Run CLI-surface compatibility check and save artifact `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/regression-testing/pass-cli-surface-compat.2026-02-22T21-00.md`.
	- Depends on: P3-T6.
	- Acceptance: Artifact contains exact command `poetry run python -m scripts.dev_tools.pr_context.collector --help`, `EXIT_CODE: 0`, and output excerpt proving `--base` option remains available.
- [x] [P4-T6] Run prompt-contract integration verification and save artifact `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/regression-testing/pass-prompt-contract-tier.2026-02-22T21-00.md`.
	- Depends on: P3-T8.
	- Acceptance: Artifact contains exact command `poetry run pytest tests/scripts/dev_tools/test_pr_context_integration.py -q -k allows_evidence_backed_verification_only_when_enumerated` and `EXIT_CODE: 0`.

### Phase 5 — Final QA Toolchain Loop

Completion Criteria (machine-verifiable): One clean Python toolchain pass is recorded in order with all commands exiting 0 and a final summary artifact stating pass.

- [x] [P5-T1] Run formatter gate and save `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/qa-gates/black-final.2026-02-22T21-00.md`.
	- Depends on: P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T6.
	- Acceptance: Artifact contains exact `Command: poetry run black .` and `EXIT_CODE: 0`.
- [x] [P5-T2] Run linter gate and save `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/qa-gates/ruff-final.2026-02-22T21-00.md`.
	- Depends on: P5-T1.
	- Acceptance: Artifact contains exact `Command: poetry run ruff check` and `EXIT_CODE: 0`.
- [x] [P5-T3] Run type-check gate and save `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/qa-gates/pyright-final.2026-02-22T21-00.md`.
	- Depends on: P5-T2.
	- Acceptance: Artifact contains exact `Command: poetry run pyright` and `EXIT_CODE: 0`.
- [x] [P5-T4] Run test gate and save `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/qa-gates/pytest-final.2026-02-22T21-00.md`.
	- Depends on: P5-T3.
	- Acceptance: Artifact contains exact `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and `EXIT_CODE: 0`.
- [x] [P5-T5] Write final QA loop summary artifact `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/qa-gates/final-pass-summary.2026-02-22T21-00.md`.
	- Depends on: P5-T1, P5-T2, P5-T3, P5-T4.
	- Acceptance: Summary lists all four QA artifacts in order and includes exact line `Final Loop Result: PASS`.

### Phase 6 — Documentation Sync and Handoff

Completion Criteria (machine-verifiable): Feature docs reflect delivered contract changes and evidence index is complete for autonomous audit and PR preparation.

- [x] [P6-T1] Update `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/spec.md` with implementation outcomes and explicit evidence links.
	- Depends on: P5-T5.
	- Acceptance: `spec.md` references `pass-collector-summary-contract.2026-02-22T21-00.md` and `final-pass-summary.2026-02-22T21-00.md`.
- [x] [P6-T2] Update `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/issue.md` with resolution summary and evidence index paths.
	- Depends on: P5-T5.
	- Acceptance: `issue.md` contains section `Resolution Evidence` listing `evidence/regression-testing/` and `evidence/qa-gates/`.
- [x] [P6-T3] Update `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/user-story.md` with validation outcome references.
	- Depends on: P6-T1, P6-T2.
	- Acceptance: `user-story.md` references `pass-prompt-contract-tier.2026-02-22T21-00.md` and `pass-verification-render-and-fallback.2026-02-22T21-00.md`.
- [x] [P6-T4] Create handoff artifact `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/evidence/other/execution-handoff.2026-02-22T21-00.md`.
	- Depends on: P6-T3.
	- Acceptance: Handoff artifact contains headings `Implemented Files`, `Added/Updated Tests`, `QA Commands`, and `Open Risks`.
