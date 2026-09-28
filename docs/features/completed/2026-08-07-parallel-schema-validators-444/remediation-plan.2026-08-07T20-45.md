# 2026-08-07-parallel-schema-validators — Remediation Plan (Cycle 1)

- **Issue:** #444
- **Parent (optional):** `parallel-orchestration` epic (child feature F3, wave 1)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07T20-45
- **Status:** Ready for Preflight
- **Version:** 1.0
- **Work Mode:** full-feature (remediation cycle 1; scope fixed by remediation inputs, not spec/user-story ACs)

## Required References

- Remediation inputs (authoritative scope for this cycle): `docs/features/active/2026-08-07-parallel-schema-validators-444/remediation-inputs.2026-08-07T20-45.md`
- Approved plan being amended (R2 only): `docs/features/active/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md`
- Rule file being corrected (R1): `.claude/rules/parallel-orchestration.md`, mandatory byte-identical mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
- Mirror-contract enforcement test: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
- General Coding Standards: `.claude/rules/general-code-change.md`
- General Unit Test Policy: `.claude/rules/general-unit-test.md`
- Tonality: `.claude/rules/tonality.md`
- Orchestrator-state precedent: `.claude/rules/orchestrator-state.md`
- Quality tiers: `.claude/rules/quality-tiers.md`

**This cycle is DOCUMENTATION-ONLY. No `.py`, `.ts`, `.cjs`, or `.json` source file may be modified, and no validator behavior may change.**

## Plan Conventions

- Evidence root (canonical, non-overridable): `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/`. Remediation baseline evidence goes to `evidence/remediation-baseline/`; final-QC evidence goes to `evidence/qa-gates/`. No `artifacts/`-rooted evidence path is permitted.
- `<ts>` in artifact filenames denotes the execution-time ISO-8601 timestamp `yyyy-MM-ddTHH-mm`.
- Every command-step evidence artifact must record `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Test-step artifacts must record numeric line and branch coverage in `Output Summary:` where the command runs in coverage mode.
- Python commands run from the repository root. TypeScript commands run from `extensions/drm-copilot/`.
- Final-QC command tasks are unconditional. `EXIT_CODE: SKIPPED` is not a valid outcome for any command task in this plan.
- Scope is fixed to exactly the two Advisory findings R1 and R2 recorded in the remediation inputs. No other file is edited. All produced/edited files in this cycle are Markdown; the 500-line cap does not apply.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Remediation Baseline Capture

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/tonality.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md`, then the scope documents `docs/features/active/2026-08-07-parallel-schema-validators-444/remediation-inputs.2026-08-07T20-45.md` and `docs/features/active/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md`, and write the read receipt
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/phase0-instructions-read.md` exists with `Timestamp:`, `Policy Order:`, and the explicit list of files read
- [x] [P0-T2] Capture the pre-edit byte-identity state of `.claude/rules/parallel-orchestration.md` against its mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` by running `git diff --no-index -- .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` from the repository root
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/mirror-parity-baseline.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` confirming zero diff output before any edit
- [x] [P0-T3] Capture the pre-edit working-tree state by running `git status --porcelain` from the repository root
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/git-status-baseline.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` recording the pre-edit change set
- [x] [P0-T4] Capture the Python formatting baseline by running `poetry run black --check .` from the repository root
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/python-format-baseline.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
- [x] [P0-T5] Capture the Python lint baseline by running `poetry run ruff check --no-fix .` from the repository root, followed by `git status --porcelain` to confirm no file changed
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/python-lint-baseline.<ts>.md` exists with all four required fields; `Output Summary:` records the diagnostic count and a changed-file count of 0
- [x] [P0-T6] Capture the Python type-check baseline by running `poetry run pyright` from the repository root
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/python-typecheck-baseline.<ts>.md` exists with all four required fields
- [x] [P0-T7] Capture the Python test baseline by running `poetry run pytest` from the repository root and confirm 2835 passed
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/python-test-baseline.<ts>.md` exists with all four required fields; `Output Summary:` records exactly 2835 passed
- [x] [P0-T8] Capture the TypeScript formatting baseline by running `npm run format` in `extensions/drm-copilot/`, followed by `git status --porcelain`
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/ts-format-baseline.<ts>.md` exists with all four required fields; `Output Summary:` records the changed-file count (expected 0)
- [x] [P0-T9] Capture the TypeScript lint baseline by running `npm run lint` in `extensions/drm-copilot/`
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/ts-lint-baseline.<ts>.md` exists with all four required fields
- [x] [P0-T10] Capture the TypeScript type-check baseline by running `npm run typecheck` in `extensions/drm-copilot/`
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/ts-typecheck-baseline.<ts>.md` exists with all four required fields
- [x] [P0-T11] Capture the TypeScript coverage-enabled test baseline by running `npm run test:coverage` in `extensions/drm-copilot/` and confirm 177 suites / 2363 tests
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/remediation-baseline/ts-test-coverage-baseline.<ts>.md` exists with all four required fields and `Output Summary:` recording exactly 177 suites, 2363 tests, and numeric line/branch coverage percentages

### Phase 1 — Documentation Corrections (R1, R2)

- [x] [P1-T1] Create `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md` following the `docs/features/potential/template.md` structure, documenting the repo-wide `pythonRepr` quote-selection defect: Python's `repr` switches to double quotes when a value contains a single quote, while every TypeScript port always single-quotes. Name all five occurrences with file:line: `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts:112-132`, `epic-planner-state-core.ts:63`, `epic-orchestrator-state-resolution.ts:52`, `codex-topology-resolver.ts:87`, `orchestrator-state-codex-model-routing.ts:133`. State explicitly that this entry is documentation-only, that fixing the defect requires modifying epic validators, and that no code fix accompanies this entry
  - Acceptance: the file exists at that path with `Problem / Why`, `Proposed Behavior`, and `Constraints & Risks` sections; all five file:line locations are named; an explicit statement that no code change accompanies this entry is present
- [x] [P1-T2] Edit the Enforcement bullet in `.claude/rules/parallel-orchestration.md` that currently asserts unqualified byte-identical TypeScript/Python error strings (the bullet beginning "The TypeScript parity port at ..."), rewriting it to state the verified scope — 96 of 96 error strings matched across 43 constructed documents, for JSON-representable values that round-trip through both runtimes' native types — and to name all three known divergence classes with their causes: (1) `pythonRepr` quote selection (`parallel-state-shared.ts:112-132` always single-quotes; Python's `repr` double-quotes when the value contains a single quote), (2) integral floats (`JSON.parse` erases Python's `int`/`float` distinction), (3) boolean/integer equality (`parallel-state-structures.ts:228` uses `===`, so Python's `True == 1` selection is not reproduced). Retain the parity statement rather than deleting it, and add a cross-reference to `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`. No other line in the file is modified
  - Acceptance: the rewritten bullet contains the "96 of 96" verified-scope statement, names all three divergence classes with their stated causes, and references the potential-entry path from P1-T1; a diff of the file against its pre-edit state (P0-T2 baseline) shows exactly one changed bullet
- [x] [P1-T3] Apply the identical bullet rewrite made in P1-T2 to the mirror file `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`, changing no other line
  - Acceptance: the mirror file's corresponding bullet is textually identical to the rewritten bullet in `.claude/rules/parallel-orchestration.md`; no other line in the mirror file differs from its pre-edit state
- [x] [P1-T4] Verify byte-identity between `.claude/rules/parallel-orchestration.md` and its mirror after the P1-T2/P1-T3 edits by running `git diff --no-index -- .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` from the repository root
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/mirror-parity-verification.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` confirming zero diff output
- [x] [P1-T5] Run the mirror-contract enforcement test `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` from the repository root and confirm a clean pass against the edited rule file
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/mirror-contract-test.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; exit code 0 with zero failures
- [x] [P1-T6] Add a new bullet to the "Open Questions / Notes" section of `docs/features/active/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md`, immediately alongside the existing SA16 file-count-divergence bullet, recording that `scripts/dev_tools/_parallel_state_records.py` and `extensions/drm-copilot/src/lib/validate/parallel-state-records.ts` are both absent from the plan's named file set in the "Plan Conventions" modified/created file list, and stating the 500-line-cap justification for the split (the records-shape validators were separated out of `_parallel_state_structures.py` / `parallel-state-structures.ts` to stay under the 500-line cap), matching the SA16 bullet's style and level of detail
  - Acceptance: the "Open Questions / Notes" section of `plan.2026-08-07T11-11.md` contains a new bullet naming both file paths, stating their absence from the named file set, and recording the 500-line-cap justification; the existing SA16 bullet is unmodified
- [x] [P1-T7] Verify no `.py`, `.ts`, `.cjs`, or `.json` file was modified by this cycle by running `git diff --name-only` from the repository root and confirming zero matches against those four extensions
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/documentation-only-scope-verification.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` confirming zero `.py`/`.ts`/`.cjs`/`.json` files in the change set (this also confirms `parallel_kickoff_contract.py` was not added)
- [x] [P1-T8] Verify no epic validator (`validate_epic_*`, `_epic_*`, `src/lib/validate/epic-*`) and no file under `.github/instructions/` was modified by running `git diff --name-only` from the repository root and confirming zero matches against those path patterns
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/out-of-scope-paths-verification.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, `SearchScope:`, and an explicit empty-result statement

### Phase 2 — Final QA Loop and Verification

Loop rule for this phase: run each language's steps in order (format, lint, type-check, test). If any step fails or changes files, fix the cause and restart that language's loop from its first step until all four steps pass cleanly in a single pass. Every command below is unconditional; `EXIT_CODE: SKIPPED` is invalid.

- [x] [P2-T1] Run `poetry run black .` from the repository root as the Python final-QC format step; restart the Python loop from this step if any file changes
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-format.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` from the final clean pass with zero files changed
- [x] [P2-T2] Run `poetry run ruff check .` from the repository root as the Python final-QC lint step, followed by `git status --porcelain`; if any file changed, restart the Python loop from P2-T1
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-lint.<ts>.md` exists with all four required fields and exit code 0; `Output Summary:` records a changed-file count of 0
- [x] [P2-T3] Run `poetry run pyright` from the repository root as the Python final-QC type-check step
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-typecheck.<ts>.md` exists with all four required fields and exit code 0
- [x] [P2-T4] Run `poetry run pytest` from the repository root as the Python final-QC test step and confirm 2835 passed
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-python-test.<ts>.md` exists with all four required fields, exit code 0, and `Output Summary:` recording exactly 2835 passed
- [x] [P2-T5] Run `npm run format` in `extensions/drm-copilot/` as the TypeScript final-QC format step, followed by `git status --porcelain`; restart the TypeScript loop from this step if any file changes
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-format.<ts>.md` exists with all four required fields and a recorded changed-file count of 0
- [x] [P2-T6] Run `npm run lint` in `extensions/drm-copilot/` as the TypeScript final-QC lint step
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-lint.<ts>.md` exists with all four required fields and exit code 0
- [x] [P2-T7] Run `npm run typecheck` in `extensions/drm-copilot/` as the TypeScript final-QC type-check step
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-typecheck.<ts>.md` exists with all four required fields and exit code 0
- [x] [P2-T8] Run `npm run test:coverage` in `extensions/drm-copilot/` as the TypeScript final-QC test step and confirm 177 suites / 2363 tests
  - Acceptance: `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/qa-gates/final-qc-ts-test-coverage.<ts>.md` exists with all four required fields, exit code 0, and `Output Summary:` recording exactly 177 suites, 2363 tests, and numeric line/branch coverage percentages

## Open Questions / Notes

- This remediation cycle addresses exactly the two Advisory findings (R1, R2) recorded in `remediation-inputs.2026-08-07T20-45.md`. No Blocking findings existed at entry.
- Three items are explicitly out of scope for code changes in this cycle: the integral-float and boolean-equality divergences (documented, not fixed, per remediation inputs), and the repo-wide `pythonRepr` quote-selection defect (recorded as a new potential entry in P1-T1, not fixed here because fixing it would require modifying epic validators).
- `parallel_kickoff_contract.py` and the `parallel-kickoff` `artifact_type` remain F4's scope and are not touched by this cycle (verified by P1-T7).
