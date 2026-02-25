# 2026-02-22-pr-context-verification-contract-gap (Spec)

- **Issue:** #46
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-22T21-00
- **Status:** Draft
- **Version:** 0.1

## Context
PR body generation under-reports completed verification because the `pr_context` contract does not expose canonical evidence artifacts as allowed additional context files. As a result, PR authoring follows strict anti-hallucination rules and defaults to “Not verified in this PR” even when feature-level QA evidence exists in canonical locations.

Environment:
- OS/version: Windows host workspace
- Python version: Poetry-managed interpreter
- Command/flags used: `poetry run python -m scripts.dev_tools.pr_context.collector --base development` + PR generation via `.github/prompts/generate-pr.prompt.md`
- Data source or fixture: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, and feature evidence folders under `docs/features/active/*/evidence/`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Generate PR context for `feature/bootstrap-utilities-#40` using `scripts.dev_tools.pr_context.collector`.
2. Generate a PR body using `.github/prompts/generate-pr.prompt.md` and only the allowed context sources.
3. Observe `## Verification` output reports “Not verified in this PR” despite canonical evidence artifacts existing for issues #40, #42, and #43.

Expected:
PR context should provide explicit, machine-readable verification summaries (or enumerate the canonical evidence files as allowed additional context), enabling PR authoring to state evidence-backed completion accurately without violating anti-hallucination constraints.

Actual:
PR authoring conservatively reports incomplete verification because the current contract only allows `pr_context` plus enumerated additional context files, and those additional files currently exclude `evidence/**`. `CI status (HEAD): (not available)` is also interpreted alongside missing explicit verification summaries, reinforcing the fallback wording.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:
	- `artifacts/pr_context.summary.txt` contains `===== CI status (HEAD) =====` with `(not available)`.
	- `scripts/dev_tools/pr_context/collector.py` builds additional context from `feature_docs.context_files` only.
	- `scripts/dev_tools/pr_context/feature_docs.py` currently derives context files from `{spec.md, plan.md, user-story.md}` only.


## Scope & Non-Goals
- In scope:
- Extend PR-context contract so canonical feature evidence artifacts are discoverable and explicitly enumerated under `Additional context files`.
- Add deterministic evidence parsing and normalized verification rendering in `artifacts/pr_context.summary.txt`.
- Preserve anti-hallucination prompt constraints while enabling evidence-backed verification wording when evidence proves pass/fail outcomes.
- Align verification heading extraction semantics between `feature_docs` and excerpt/render helpers.
- Out of scope / non-goals:
- Changing branch/merge behavior or GitHub issue auto-close semantics.
- Replacing the anti-hallucination guardrails in `.github/prompts/generate-pr.prompt.md`.
- Introducing non-canonical evidence sources outside `docs/features/active/*/evidence/**`.
- Retrofitting unrelated PR-context sections not involved in verification claims.
- Explicitly excluded systems, integrations, or datasets:
- External CI provider APIs beyond current `CI status (HEAD)` collection behavior.
- Non-feature evidence trees (for example ad-hoc local notes not under the active feature folder).

## Root Cause Analysis
Root cause appears to be a contract gap rather than missing evidence:
- Source restriction: PR prompt forbids claims not explicitly supported by context/allowed files.
- Enumeration gap: canonical evidence files are not included in “Additional context files”.
- Summary gap: no normalized verification section is emitted from evidence schema (`Timestamp`, `Command`, `EXIT_CODE`).
- Language contamination risk: PR digests include prior “Not verified in this PR” text, biasing conservative phrasing.

Primary files to inspect:
- `scripts/dev_tools/pr_context/collector.py`
- `scripts/dev_tools/pr_context/feature_docs.py`
- `scripts/dev_tools/pr_context/summary_helpers.py`
- `.github/prompts/generate-pr.prompt.md`


## Proposed Fix

### Design summary (what changes where):
- Add a deterministic verification-evidence discovery and parsing helper under `scripts/dev_tools/pr_context/` to read canonical evidence files from active feature folders and normalize schema fields (`Timestamp`, `Command`, `EXIT_CODE`).
- Update `scripts/dev_tools/pr_context/collector.py` to:
	- merge discovered evidence files into `Additional context files`, and
	- emit a dedicated summary section `===== Verification evidence (feature docs + canonical artifacts) =====` with normalized pass/fail results.
- Update `scripts/dev_tools/pr_context/feature_docs.py` and rendering helpers to share the same verification-heading fallback behavior (`Verification` first, then `Test Plan`) so summary and appendix stay semantically aligned.
- Update `.github/prompts/generate-pr.prompt.md` to keep strict source constraints but add explicit verification wording rules when evidence section/files prove status.

### Boundaries and invariants to preserve:
- PR generation must continue to cite only `pr_context` outputs and explicitly enumerated `Additional context files`.
- If evidence is missing, malformed, or non-deterministic, verification wording must remain conservative (no completion claim).
- Existing `CI status (HEAD)` output remains unchanged and separate from evidence-derived verification.
- `FeatureDocExcerpt.context_files` ordering/determinism must remain stable for reproducible artifact diffs.

### Dependencies or blocked work:
- Depends on canonical evidence documents containing parseable schema fields (`Timestamp`, `Command`, `EXIT_CODE`) for strong assertions.
- No external service dependency; parsing is file-system local under workspace root.
- No blocker identified in research for implementation start.

### Implementation strategy (what changes, not sequencing):
	Implement additive contract changes in collector/evidence parsing with deterministic discovery rules, then update prompt wording and tests to enforce allowed-claims behavior against parsed evidence and enumerated file paths.
	
#### Files/modules to change:
- `scripts/dev_tools/pr_context/collector.py`
- `scripts/dev_tools/pr_context/feature_docs.py`
- `scripts/dev_tools/pr_context/render_feature_excerpts.py`
- `scripts/dev_tools/pr_context/summary_helpers.py` (if formatting helpers are reused for evidence rendering)
- `scripts/dev_tools/pr_context/verification_evidence.py` (new helper module proposed in research)
- `.github/prompts/generate-pr.prompt.md`
- `tests/scripts/dev_tools/test_collect_pr_context.py`
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py`
- `tests/scripts/dev_tools/test_pr_context_integration.py`
- `tests/scripts/dev_tools/test_feature_docs.py` and/or existing excerpt-render helper test module

#### Functions/classes/CLI commands impacted:
- `scripts.dev_tools.pr_context.collector.collect_and_write` (summary rendering + additional context enumeration)
- `scripts.dev_tools.pr_context.feature_docs.gather_feature_excerpts` (`context_files` expansion and heading consistency)
- `scripts.dev_tools.pr_context.render_feature_excerpts.extract_plan_sections` (or equivalent helper path for heading fallback parity)
- `poetry run python -m scripts.dev_tools.pr_context.collector --base development` (output contract changes only)

#### Data flow and validation changes:
- New flow: active feature excerpt -> canonical evidence discovery (`evidence/qa-gates`, `evidence/regression-testing`, optional `evidence/other`) -> schema parse -> normalized verification records -> summary render + context-file enumeration.
- Validation rules:
	- `EXIT_CODE` parseable integer required for normalized result.
	- `EXIT_CODE == 0` => `pass`; non-zero => `fail`.
	- Missing required fields produce explicit fallback lines and do not permit “completed verification” wording.
- De-duplicate context file paths across doc-derived files and evidence-derived files.

#### Error handling and logging updates:
- Parse failures for individual evidence files should not fail collection; collector emits explicit non-fatal notes (for example `No canonical verification evidence parsed` or file-level parse warning text in summary section).
- Keep existing collector exit behavior unless a hard I/O failure occurs for core artifact writes.
- Preserve deterministic output under partial evidence availability.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag required; change is additive and backward compatible for existing callers.
- Rollback path: revert evidence-discovery integration and prompt wording update; base collector behavior reverts to spec/plan/story-only context list.

### Technical specifications (interfaces/contracts):

`Additional context files` contract (expanded):
- Existing: per-feature `spec.md`, `plan*.md`, `user-story.md` when present.
- Added: discovered canonical evidence files under each active feature folder using deterministic subpaths.

`Verification evidence` summary contract (new section):
- Section header: `===== Verification evidence (feature docs + canonical artifacts) =====`
- Per feature entry fields:
	- feature identifier/folder
	- evidence source file path
	- parsed `Timestamp`
	- parsed `Command`
	- parsed `EXIT_CODE`
	- normalized result (`pass`/`fail`)
- Fallback behavior:
	- If no parseable evidence exists, emit explicit “none parsed” messaging and preserve conservative downstream wording.

#### Inputs/outputs and formats:
- Inputs:
	- Active feature docs under `docs/features/active/*`
	- Canonical evidence markdown files under `docs/features/active/*/evidence/**`
	- Collector CLI argument `--base <branch>`
- Outputs:
	- `artifacts/pr_context.summary.txt` gains new verification-evidence section.
	- `artifacts/pr_context.appendix.txt` remains generated, with aligned verification semantics across excerpt paths.
	- `Additional context files` list includes evidence files used by verification claims.
- Format:
	- Plain-text sections in existing summary/appendix structure with deterministic sorting.

#### Required configuration keys and defaults:
- No new environment variables required.
- No new CLI flags required for MVP fix.
- Discovery defaults to canonical evidence folders; missing folders are treated as empty.

#### Backward-compatibility expectations:
- Existing collector command and output files remain in place.
- Existing consumers parsing legacy sections continue to function; new section is additive.
- Prompt contract remains strict; behavior change is that stronger evidence-backed wording becomes allowed when contract data is present.

#### Performance constraints (latency/throughput/memory):
- Evidence scan should remain linear in number of candidate evidence files under active features (target O(n) file reads).
- No long-lived caching required; one-pass collection should remain suitable for local dev workflows.
- If evidence corpus grows, deterministic path filtering (`qa-gates`, `regression-testing`, optional `other`) bounds scan scope.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
- Active feature folders follow current canonical layout with optional `evidence/` subdirectories.
- Evidence files used for pass/fail claims contain recognizable `Timestamp`, `Command`, and `EXIT_CODE` lines.
- PR generation continues using `.github/prompts/generate-pr.prompt.md` strict-source policy.
- Constraints (budget, performance, compatibility):
- Keep changes minimal and contract-focused; avoid broad refactors outside verification flow.
- Maintain compatibility with existing `pr_context` summary/appendix consumers.
- Preserve deterministic output ordering for reproducible diffs in artifacts.
- External dependencies (services, libraries, releases):
- None beyond existing Python standard library and repo tooling.

## Data / API / Config Impact
- User-facing or API changes:
- PR bodies generated from updated context can report evidence-backed verification when canonical artifacts prove success.
- No user-facing CLI surface expansion.
- Data or migration considerations:
- No data migration.
- Existing and future evidence files are consumed in-place; malformed files are tolerated with conservative fallback.
- Logging/telemetry updates (if any):
- Summary artifact gains explicit verification-evidence lines that act as auditable trace output.
- No new external telemetry system integration.
- Compatibility notes (CLI flags, config schemas, versioning):
- Collector CLI flags remain unchanged.
- Prompt behavior remains anti-hallucination constrained; only allowed wording tiers change based on explicit evidence presence.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas
	- Add/extend tests for `pr_context` collector to verify canonical evidence discovery and inclusion in additional context files.
	- Add tests for verification summary rendering from evidence artifacts using schema fields (`Timestamp`, `Command`, `EXIT_CODE`).
- [x] Integration scenario to retest
	- Re-run PR context collection + PR generation for the same branch and confirm verification section can state evidence-backed completion without violating source constraints.
- [x] Manual verification notes
	- Validate output wording distinguishes “CI unavailable” from “canonical evidence indicates pass”.
	- Confirm no non-enumerated files are cited in generated PR body.

- Regression tests to add or update:
- `tests/scripts/dev_tools/test_collect_pr_context.py`
	- Add regression test asserting evidence file paths are included in `additional_context_files` when canonical evidence exists.
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py`
	- Assert summary includes `Verification evidence (feature docs + canonical artifacts)` section and conservative fallback when evidence missing/malformed.
- `tests/scripts/dev_tools/test_pr_context_integration.py`
	- Assert prompt-contract alignment for evidence-backed wording while preserving `using only` + additional-context restrictions.
- `tests/scripts/dev_tools/test_feature_docs.py` (or equivalent excerpt rendering tests)
	- Assert shared heading fallback behavior (`Verification` then `Test Plan`) across feature docs and rendering helpers.
- Unit tests (pytest) for the fixed behavior and boundaries:
- Positive path: parse canonical evidence with `EXIT_CODE: 0` and produce normalized `pass` record.
- Negative path: parse canonical evidence with non-zero exit code and produce normalized `fail` record.
- Boundary path: missing one required schema field results in explicit fallback and no completion claim eligibility.
- Determinism: discovered evidence files are sorted and de-duplicated in `Additional context files`.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
- No evidence directories present for a feature.
- Evidence file present but malformed (`EXIT_CODE` non-integer, missing command, invalid timestamp text).
- CI status unavailable while evidence indicates pass; wording must separate those signals.
- Multiple evidence files with mixed pass/fail outcomes; summary must represent each deterministic source.
- Error handling and logging verification:
- Verify collection does not crash on malformed evidence files.
- Verify summary includes explicit fallback note when no parseable evidence exists.
- Coverage impact and targets for changed lines/modules:
- Maintain or improve coverage for changed `scripts/dev_tools/pr_context/*` lines.
- New helper module coverage target: >= 90% line coverage.
- Toolchain commands to run (format → lint → type-check → test):
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- Manual validation steps (if required):
- Run collector on repro branch and inspect `artifacts/pr_context.summary.txt` for new evidence section and expected normalized fields.
- Confirm `Additional context files` includes each evidence file cited by verification text.
- Generate PR body from `.github/prompts/generate-pr.prompt.md` and confirm verification wording uses evidence-backed phrasing when justified and conservative fallback when not.


## Acceptance Criteria
- [ ] Repro now yields verification output that can state evidence-backed completion when canonical evidence files are present and parseable.
- [ ] `tests/scripts/dev_tools/test_collect_pr_context.py` contains regression coverage proving evidence paths are enumerated in `Additional context files`.
- [ ] `tests/scripts/dev_tools/test_collect_pr_context_part4.py` verifies both positive evidence rendering and conservative fallback when evidence is absent/malformed.
- [ ] `tests/scripts/dev_tools/test_pr_context_integration.py` verifies prompt contract still forbids non-enumerated citations while allowing evidence-backed wording tiers.
- [ ] Unified heading fallback (`Verification` then `Test Plan`) is covered by tests in feature-doc/render-helper modules.
- [ ] `CI status (HEAD): (not available)` and canonical-evidence pass/fail signals are reported independently and accurately in generated artifacts.
- [ ] Full Python toolchain pass completed with final green run (`black`, `ruff`, `pyright`, `pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`).
- [ ] Prompt and docs references are updated to reflect the expanded verification contract without weakening anti-hallucination rules.

## Risks & Mitigations
- Technical or operational risks:
- Risk: malformed evidence files create false confidence if parser is too permissive.
- Risk: drift between feature-doc extraction and render helpers reappears if fallback logic diverges again.
- Risk: larger `Additional context files` list increases noise in downstream prompts.
- Mitigations and rollbacks:
- Enforce strict required-field parsing and explicit fallback text when parsing fails.
- Centralize heading fallback behavior in shared helper logic and add regression tests on both code paths.
- Keep discovery scope constrained to canonical evidence folders and deterministic ordering.
- Roll back by reverting additive evidence integration if regressions appear.

## Rollout & Follow-up
- Release/rollout steps:
- Implement and merge contract updates on feature branch, then regenerate `pr_context` artifacts before PR authoring.
- Validate generated PR verification section on the known repro branch (`feature/bootstrap-utilities-#40`).
- Post-fix monitoring or clean-up tasks:
- Track subsequent PRs for disappearance of unjustified blanket `Not verified in this PR` wording when canonical evidence exists.
- If drift risk persists, add a lightweight contract-check test for section headings and wording tiers.
- Links: issue, PRs, related docs
- Issue: `docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/issue.md`
- Research: `artifacts/research/20260222-pr-context-verification-contract-gap-implementation-research.md`
- Prompt contract: `.github/prompts/generate-pr.prompt.md`

## Implementation Outcomes

- Added canonical evidence discovery/parsing in `scripts/dev_tools/pr_context/verification_evidence.py` with deterministic normalized statuses (`pass`, `fail`, `unparseable`).
- Expanded `FeatureDocExcerpt.context_files` to include canonical `evidence/**` files under active feature folders.
- Added collector summary section `===== Verification evidence (feature docs + canonical artifacts) =====` while preserving separate `===== CI status (HEAD) =====` semantics.
- Unified heading fallback order in render helpers to `Verification` then `Test Plan`.
- Kept anti-hallucination constraints in `.github/prompts/generate-pr.prompt.md` and added evidence-backed wording tier plus explicit CI/evidence separation rule.

## Resolution Evidence

- Collector summary contract verification: `evidence/regression-testing/pass-collector-summary-contract.2026-02-22T21-00.md`
- Final QA loop summary: `evidence/qa-gates/final-pass-summary.2026-02-22T21-00.md`
