# 2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48 (Python Atomic Plan)

DIRECTIVE: FULL EXECUTION

- Issue: #48
- Owner: drmoisan
- Work Mode: full
- Last Updated: 2026-02-22T23-15
- Plan Path: docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/plan.2026-02-22T22-33.md

## Execution Scope (bounded)

Production files allowed in this plan:
- `scripts/dev_tools/pr_context/models.py`
- `scripts/dev_tools/pr_context/feature_docs.py`
- `scripts/dev_tools/pr_context/collector.py`
- `scripts/dev_tools/pr_context/render_pr_helpers.py`

Test files allowed in this plan:
- `tests/scripts/dev_tools/test_feature_docs.py`
- `tests/scripts/dev_tools/test_collect_pr_context.py`
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py`
- `tests/scripts/dev_tools/test_pr_context_integration.py`

Evidence roots used in this plan:
- `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/baseline/`
- `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/regression-testing/`
- `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/qa-gates/`
- `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/other/`

### Phase 0 — Context, Policy, and Baseline Capture

- [x] [P0-T1] Read policy inputs and feature inputs, then record a single baseline manifest at `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/baseline/policy-and-input-read.2026-02-22T23-15.md`.
	- Preconditions: `issue.md`, `spec.md`, `user-story.md`, `research.md`, `artifacts/pr_context.summary.txt`, and `artifacts/pr_context.appendix.txt` are present.
	- Acceptance: Manifest file exists and contains exact lines for `Timestamp: 2026-02-22T23-15`, `Work Mode: full`, and absolute paths for each required input.

- [x] [P0-T2] Verify full-mode source marker from `issue.md` and document full-document expectations in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/baseline/full-mode-preconditions.2026-02-22T23-15.md`.
	- Preconditions: `issue.md` metadata block includes `- Work Mode: full`.
	- Acceptance: Evidence file exists and contains exact lines `ModeSource: issue.md`, `ResolvedMode: full`, `RequiredDocs: spec.md,user-story.md`.

- [x] [P0-T3] Run baseline collector repro command and save command output summary to `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/baseline/collector-baseline.2026-02-22T23-15.md`.
	- Preconditions: Working tree is clean.
	- Acceptance: Evidence file contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Run baseline formatter check and record result in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/baseline/black-baseline.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Command: poetry run black .`, integer `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Run baseline lint check and record result in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/baseline/ruff-baseline.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Command: poetry run ruff check`, integer `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Run baseline type check and record result in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/baseline/pyright-baseline.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Command: poetry run pyright`, integer `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T7] Run baseline pytest coverage command and record result in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/baseline/pytest-cov-baseline.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, integer `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — TDD Red Regression Tests

- [x] [P1-T1] Add a regression test in `tests/scripts/dev_tools/test_feature_docs.py` that asserts explicit metadata `Issue: #46` is parsed as deterministic primary issue and readiness `PASS` is resolved from latest `feature-audit.*.md`.
	- Preconditions: Existing feature-doc test fixtures remain deterministic and file-system isolated.
	- Acceptance: New test function exists and references only fixture-controlled inputs.

- [x] [P1-T2] [expect-fail] Run the new `test_feature_docs.py` nodeid before implementation and store failure evidence at `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/regression-testing/expect-fail-primary-issue-and-pass-readiness.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Timestamp:`, exact `Command: poetry run pytest tests/scripts/dev_tools/test_feature_docs.py -q -k primary_issue_and_pass_readiness`, integer `EXIT_CODE:` with non-zero value, and a `Failure:` excerpt.

- [x] [P1-T3] Add a regression test in `tests/scripts/dev_tools/test_collect_pr_context_part4.py` that asserts summary includes header `===== Issues to autoclose (verified or pending) =====` and includes `#46` when readiness is `PASS`.
	- Preconditions: Test uses deterministic fixture context and does not depend on network or external services.
	- Acceptance: New test function exists and asserts exact header text plus `#46` presence.

- [x] [P1-T4] [expect-fail] Run the new PASS-readiness summary nodeid before implementation and store failure evidence at `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/regression-testing/expect-fail-pass-readiness-autoclose-section.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Timestamp:`, exact `Command: poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_part4.py -q -k pass_readiness_autoclose_section`, integer `EXIT_CODE:` with non-zero value, and a `Failure:` excerpt.

- [x] [P1-T5] Add a regression test in `tests/scripts/dev_tools/test_collect_pr_context.py` that asserts narrative mentions `#40/#42/#43` remain excluded from `Issues to autoclose (verified or pending)`.
	- Preconditions: Fixture data includes mention-only issue references.
	- Acceptance: New test function exists and asserts mention refs are absent from approved autoclose section.

- [x] [P1-T6] [expect-fail] Run the narrative-exclusion nodeid before implementation and store failure evidence at `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/regression-testing/expect-fail-narrative-mention-exclusion.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Timestamp:`, exact `Command: poetry run pytest tests/scripts/dev_tools/test_collect_pr_context.py -q -k narrative_mentions_excluded_from_autoclose_section`, integer `EXIT_CODE:` with non-zero value, and a `Failure:` excerpt.

- [x] [P1-T7] Add a regression test in `tests/scripts/dev_tools/test_collect_pr_context_part4.py` that asserts conservative `None` text is emitted when readiness is missing or not `PASS`.
	- Preconditions: Test fixtures can produce non-PASS readiness state without external files.
	- Acceptance: New test function exists and asserts exact `None` fallback wording in approved autoclose section.

- [x] [P1-T8] [expect-fail] Run the non-PASS fallback nodeid before implementation and store failure evidence at `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/regression-testing/expect-fail-non-pass-fallback.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Timestamp:`, exact `Command: poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_part4.py -q -k non_pass_readiness_fallback`, integer `EXIT_CODE:` with non-zero value, and a `Failure:` excerpt.

### Phase 2 — Minimal Production Fix

- [x] [P2-T1] Extend `FeatureDocExcerpt` in `scripts/dev_tools/pr_context/models.py` with typed fields required for deterministic autoclose derivation (`primary_issue_ref` and readiness signal).
	- Preconditions: Existing constructor call sites are identified.
	- Acceptance: Model type-checks and all call sites compile with explicit values or `None` defaults.

- [x] [P2-T2] Implement explicit primary-issue metadata parsing in `scripts/dev_tools/pr_context/feature_docs.py` using only `Issue: #NN` metadata lines, not narrative references.
	- Acceptance: Parser returns deterministic `primary_issue_ref` when metadata is valid and returns `None` for malformed/missing metadata.

- [x] [P2-T3] Implement readiness resolver in `scripts/dev_tools/pr_context/feature_docs.py` that reads the latest `feature-audit.*.md` and returns normalized readiness status.
	- Acceptance: Resolver returns `PASS`, `NEEDS REVISION`, `BLOCKED`, or `None` deterministically for fixture-driven inputs.

- [x] [P2-T4] Thread primary issue and readiness metadata through collector inputs in `scripts/dev_tools/pr_context/collector.py`.
	- Acceptance: Collector runtime model exposes both values at summary-render decision points.

- [x] [P2-T5] Implement `issues_to_autoclose` precedence in `scripts/dev_tools/pr_context/collector.py`: verified PR closing issues first; pending deterministic primary issue only when readiness is `PASS`; otherwise conservative none.
	- Acceptance: Logic path is deterministic, deduplicated, and preserves stable order.

- [x] [P2-T6] Add rendering helper in `scripts/dev_tools/pr_context/render_pr_helpers.py` for `===== Issues to autoclose (verified or pending) =====` section with explicit `None` reason text when empty.
	- Acceptance: Helper returns section text with exact header and deterministic formatting.

- [x] [P2-T7] Insert the new autoclose section into `scripts/dev_tools/pr_context/collector.py` before `Close candidates` without changing unrelated summary sections.
	- Acceptance: Summary output order contains new section immediately before `===== Close candidates =====`.

### Phase 3 — Targeted Verification (Pass After Fix)

- [x] [P3-T1] Re-run `test_feature_docs.py` primary-issue/readiness nodeid and save pass evidence to `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/regression-testing/pass-primary-issue-and-pass-readiness.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains exact command from P1-T2 and `EXIT_CODE: 0`.

- [x] [P3-T2] Re-run PASS-readiness autoclose-section nodeid and save pass evidence to `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/regression-testing/pass-pass-readiness-autoclose-section.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains exact command from P1-T4 and `EXIT_CODE: 0`.

- [x] [P3-T3] Re-run narrative-mention exclusion nodeid and save pass evidence to `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/regression-testing/pass-narrative-mention-exclusion.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains exact command from P1-T6 and `EXIT_CODE: 0`.

- [x] [P3-T4] Re-run non-PASS fallback nodeid and save pass evidence to `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/regression-testing/pass-non-pass-fallback.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains exact command from P1-T8 and `EXIT_CODE: 0`.

- [x] [P3-T5] Run collector repro command and save end-state contract evidence to `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/other/pass-collector-autoclose-contract.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Command: poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`, `EXIT_CODE: 0`, and output assertions for: new section header present, `#46` present only for readiness `PASS`, and `#40/#42/#43` absent from approved section.

### Phase 4 — Final QA Toolchain Loop

- [x] [P4-T1] Run formatter step for final pass and record result in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/qa-gates/black-final.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Command: poetry run black .` and `EXIT_CODE: 0` from the final clean pass.

- [x] [P4-T2] Run lint step for final pass and record result in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/qa-gates/ruff-final.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Command: poetry run ruff check` and `EXIT_CODE: 0` from the final clean pass.

- [x] [P4-T3] Run type-check step for final pass and record result in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/qa-gates/pyright-final.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Command: poetry run pyright` and `EXIT_CODE: 0` from the final clean pass.

- [x] [P4-T4] Run test step for final pass and record result in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/qa-gates/pytest-final.2026-02-22T23-15.md`.
	- Acceptance: Evidence file contains `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and `EXIT_CODE: 0` from the final clean pass.

- [x] [P4-T5] Record single-pass toolchain completion summary in `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/evidence/qa-gates/final-pass-summary.2026-02-22T23-15.md`.
	- Acceptance: Summary file states that formatting, linting, type checking, and testing all passed in one final pass and lists artifact file names from P4-T1 through P4-T4.

### Phase 5 — Documentation and Handoff

- [x] [P5-T1] Update `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/spec.md` acceptance checklist and test strategy sections to reflect implemented deterministic autoclose behavior and evidence files.
	- Acceptance: `spec.md` explicitly references `Issues to autoclose (verified or pending)` and includes evidence paths for regressions and final QA.

- [x] [P5-T2] Update `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/issue.md` with final behavior summary and verification commands used.
	- Acceptance: `issue.md` contains exact command list and confirms narrative mentions are not promoted to autoclose targets.

