# 2026-02-22-pr-does-not-autoclose-with-valid-issue-audit (Spec)

- **Issue:** #48
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-22T22-33
- **Status:** Draft
- **Version:** 0.1

## Context
PR generation misses auto-close for issue #46 even when the active feature audit readiness is PASS and the feature docs declare `Issue: #46`. `pr_context` currently places `#46` under `Close candidates`, but the PR prompt only permits auto-close numbers from `Issues to autoclose (verified or pending)` or `PR Intent -> Author-asserted autoclose issues`.

Environment:
- OS/version: Windows host workspace
- Python version: Poetry-managed interpreter
- Command/flags used: `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`
- Data source or fixture: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, `.github/prompts/generate-pr.prompt.md`, and active feature docs (`spec.md`/`user-story.md`) that declare `Issue: #46`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`.
2. Open `artifacts/pr_context.summary.txt` and confirm `Close candidates` contains `Auto-close issues (author asserted): #40, #42, #43, #46` while `PR Intent` shows `Author-asserted autoclose issues:` with no value.
3. Confirm there is no `Issues to autoclose (verified or pending)` section in the summary output.
4. Generate PR content using `.github/prompts/generate-pr.prompt.md` and observe the `GitHub Auto-close` output does not emit `Closes #46`.

Expected:
When the active feature has a deterministic issue ID (`Issue: #46` in `spec.md`/`user-story.md`) and feature-audit readiness is PASS, `pr_context` should emit an approved auto-close source so the PR author can produce `Closes #46` under existing prompt rules.

Actual:
`#46` appears only under `Close candidates`, which the PR prompt does not allow as an auto-close source. Because `PR Intent -> Author-asserted autoclose issues` is blank and no `Issues to autoclose (verified or pending)` section exists, generated PRs omit `Closes #46`.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:
	- `artifacts/pr_context.summary.txt`:
		- `Author-asserted autoclose issues:` (blank in `PR Intent`)
		- `Auto-close issues (author asserted): #40 #42 #43 #46` (under `Close candidates`)
	- `.github/prompts/generate-pr.prompt.md` allows auto-close from only:
		1) `Issues to autoclose (verified or pending)`
		2) `PR Intent -> Author-asserted autoclose issues`


## Scope & Non-Goals
- In scope:
- Emit a deterministic `===== Issues to autoclose (verified or pending) =====` section in `artifacts/pr_context.summary.txt`.
- Source pending autoclose only from the active feature's explicit primary issue metadata (`- Issue: #NN`) when readiness is `PASS`.
- Keep `Close candidates` as diagnostic output only; it must not be treated as an auto-close source.
- Preserve compatibility with `.github/prompts/generate-pr.prompt.md` without expanding allowed source categories.
- Out of scope / non-goals:
- Modifying GitHub keyword semantics (`Closes`, `Fixes`, `Resolves`) or branch-default behavior.
- Auto-populating `PR Intent -> Author-asserted autoclose issues` from broad issue mentions.
- Changing unrelated `pr_context` sections (verification, CI status, risk narratives).
- Explicitly excluded systems, integrations, or datasets:
- External API calls or new GitHub integrations.
- Non-active-feature docs as primary issue sources.

## Root Cause Analysis
Contract mismatch between `pr_context` rendering and PR prompt consumption:
- `scripts/dev_tools/pr_context/collector.py` computes issue references and surfaces them in `Close candidates`, but does not populate the `PR Intent` author-asserted field.
- The summary schema does not emit `Issues to autoclose (verified or pending)` for pending deterministic close targets.
- Candidate issue derivation appears mention-based (includes `#40/#42/#43`) instead of using the active feature’s primary issue metadata (`Issue: #46`).

Files to inspect:
- `scripts/dev_tools/pr_context/collector.py`
- `scripts/dev_tools/pr_context/feature_docs.py`
- `tests/scripts/dev_tools/test_collect_pr_context.py`
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py`
- `tests/scripts/dev_tools/test_pr_context_integration.py`
- `.github/prompts/generate-pr.prompt.md`


## Proposed Fix

### Design summary (what changes where):
- Extend feature-doc metadata extraction to parse deterministic primary issue from explicit metadata line `- Issue: #NN`.
- Add readiness resolution from the latest `feature-audit.<timestamp>.md` in the active feature folder.
- In collector rendering flow, compute `issues_to_autoclose` with strict precedence:
	1) verified closing issues from PR metadata (`closingIssuesReferences`) when available,
	2) pending deterministic primary issue when readiness is `PASS`,
	3) conservative `None` fallback with reason.
- Render `===== Issues to autoclose (verified or pending) =====` before `Close candidates` so prompt consumers can deterministically use an approved source.

### Boundaries and invariants to preserve:
- Never promote narrative mentions (for example `#40/#42/#43`) to autoclose targets.
- Keep existing collector command and artifact paths unchanged.
- Keep output deterministic (stable ordering, deduplicated issue refs).
- Preserve prompt anti-hallucination contract: only approved sections may drive `Closes #NN`.

### Dependencies or blocked work:
- Depends on presence of explicit `Issue: #NN` metadata in active feature docs.
- Depends on readiness artifact convention (`feature-audit.<timestamp>.md`) and `PASS` readiness semantics.
- No blocking external dependency identified.

### Implementation strategy (what changes, not sequencing):
	Add a narrow metadata path for deterministic autoclose derivation, thread it into collector summary rendering, and lock behavior via unit/integration regressions that prove prompt-contract compatibility.
	
#### Files/modules to change:
- `scripts/dev_tools/pr_context/feature_docs.py` (extract explicit primary issue, resolve readiness signal)
- `scripts/dev_tools/pr_context/models.py` (extend excerpt metadata for primary issue/readiness)
- `scripts/dev_tools/pr_context/collector.py` (compute verified/pending autoclose list and render section)
- `scripts/dev_tools/pr_context/render_pr_helpers.py` (add formatter for new autoclose section)
- `tests/scripts/dev_tools/test_feature_docs.py`
- `tests/scripts/dev_tools/test_collect_pr_context.py`
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py`
- `tests/scripts/dev_tools/test_pr_context_integration.py`

#### Functions/classes/CLI commands impacted:
- `gather_feature_excerpts(...)` and related metadata extraction helpers in `feature_docs.py`
- `FeatureDocExcerpt` data contract in `models.py`
- `collect_and_write(...)` in `collector.py`
- Summary rendering helper(s) in `render_pr_helpers.py`
- CLI command behavior for `poetry run python -m scripts.dev_tools.pr_context.collector --base <branch>` (output contract only, no new flags)

#### Data flow and validation changes:
- Parse primary issue from explicit metadata fields, not full-text mention scanning.
- Resolve readiness from canonical audit artifact and gate pending autoclose on `PASS` only.
- Build `issues_to_autoclose` list from verified or pending deterministic sources; deduplicate and preserve stable order.
- Keep mention-derived issue refs in `Close candidates` only, explicitly separated from autoclose list.

#### Error handling and logging updates:
- Missing/invalid primary issue metadata: emit conservative `None` in autoclose section with explanatory text.
- Missing readiness artifact or readiness not `PASS`: do not emit pending autoclose issue.
- Preserve collector non-fatal behavior for partial metadata gaps; continue writing summary/appendix artifacts.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag required; change is additive and backward compatible.
- Rollback path is a straight revert of new section and metadata derivation logic.

### Technical specifications (interfaces/contracts):
- New summary section contract:
	- Header: `===== Issues to autoclose (verified or pending) =====`
	- Content priority: verified issues first; otherwise pending deterministic issue(s); otherwise explicit `None` reason.
- Prompt compatibility contract:
	- Section is intentionally named to match accepted source in `.github/prompts/generate-pr.prompt.md`.
	- `Close candidates` remains non-authoritative for auto-close emission.

#### Inputs/outputs and formats:
- Inputs:
	- Active feature docs including metadata line `- Issue: #NN`
	- Feature audit artifacts (`feature-audit.<timestamp>.md`) for readiness state
	- Optional GitHub PR metadata (`closingIssuesReferences`) from collector pipeline
- Outputs:
	- `artifacts/pr_context.summary.txt` includes new approved autoclose source section
	- `artifacts/pr_context.appendix.txt` remains unchanged except for consistency references if needed
- Format:
	- Plain-text issue refs in `#NN` form, sorted deterministically

#### Required configuration keys and defaults:
- No new environment variables.
- No new CLI flags.
- Default behavior remains conservative when deterministic inputs are unavailable.

#### Backward-compatibility expectations:
- Existing collector invocation remains unchanged.
- Existing consumers of `Close candidates` continue to work.
- Added section is additive; legacy parsing of existing sections is unaffected.

#### Performance constraints (latency/throughput/memory):
- Keep additional parsing linear in number of active feature docs and audit files.
- No new persistent cache or heavy I/O paths.
- Expected runtime impact is negligible for current repo scale.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
- Active feature folder for issue #48 contains authoritative metadata and accessible audit artifacts.
- Prompt contract in `.github/prompts/generate-pr.prompt.md` remains authoritative for allowed autoclose sources.
- Constraints (budget, performance, compatibility):
- Minimal-surface bug fix; avoid broad refactors.
- Must preserve deterministic output and conservative fallback behavior.
- External dependencies (services, libraries, releases):
- No new dependencies required.

## Data / API / Config Impact
- User-facing or API changes:
- PR authors gain a deterministic approved source for `Closes #NN` emission when audited issue readiness is `PASS`.
- Data or migration considerations:
- No migration; artifact schema is extended with one additive summary section.
- Logging/telemetry updates (if any):
- Summary artifact gains explicit autoclose eligibility visibility (`verified`, `pending`, or `none`).
- Compatibility notes (CLI flags, config schemas, versioning):
- Collector CLI/config unchanged; prompt compatibility improved through section alignment, not prompt relaxation.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas
	- Add/extend tests so `pr_context` emits an approved auto-close source when feature docs provide a deterministic `Issue: #NN` and readiness is PASS.
	- Add regression assertions that narrative mentions (`#40/#42/#43`) are not promoted to close targets.
- [x] Integration scenario to retest
	- Re-run `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40` and regenerate PR content.
	- Verify generated `GitHub Auto-close` includes `Closes #46` and excludes `Closes #40/#42/#43` unless explicitly author-asserted in PR Intent.
- [x] Manual verification notes
	- Confirm summary includes either populated `PR Intent -> Author-asserted autoclose issues` or `Issues to autoclose (verified or pending)` with `#46`.
	- Confirm behavior remains conservative when deterministic primary issue cannot be resolved.

- Regression tests to add or update:
- `tests/scripts/dev_tools/test_feature_docs.py`
	- Add extraction tests for explicit `Issue: #NN` metadata and readiness parsing from `feature-audit` docs.
- `tests/scripts/dev_tools/test_collect_pr_context.py`
	- Add regression ensuring only deterministic audited issue is emitted in `Issues to autoclose (verified or pending)` for readiness `PASS`.
	- Add regression ensuring narrative mentions (`#40/#42/#43`) are excluded from autoclose section.
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py`
	- Add summary rendering assertions for header presence, deterministic issue ordering, and conservative `None` fallback reasons.
- `tests/scripts/dev_tools/test_pr_context_integration.py`
	- Add contract test proving generated PR content can emit `Closes #46` from approved section and does not emit `Closes` for mention-only refs.
- Unit tests (pytest) for the fixed behavior and boundaries:
- Positive: explicit issue + `PASS` readiness -> pending deterministic issue appears in new section.
- Positive: verified closing issues present -> verified issues are emitted as highest-priority source.
- Negative: readiness missing/non-`PASS` -> no pending issue emitted.
- Negative: malformed issue metadata -> no pending issue emitted.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
- Multiple active feature docs with mixed issue refs should still emit only deterministic eligible issue(s).
- Duplicate issue references across sources should be deduplicated.
- Empty feature-doc set should produce explicit `None` with reason.
- Error handling and logging verification:
- Assert collector completes and writes artifacts when readiness artifact is missing.
- Assert summary text clearly communicates conservative fallback cause.
- Coverage impact and targets for changed lines/modules:
- Maintain repo policy target and achieve >=90% coverage for new/modified autoclose-related lines.
- Toolchain commands to run (format → lint → type-check → test):
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- Manual validation steps (if required):
- Re-run collector for repro branch and inspect `artifacts/pr_context.summary.txt`.
- Confirm section includes `#46` only when readiness is `PASS`.
- Regenerate PR body and confirm `GitHub Auto-close` emits `Closes #46` and excludes mention-only issues.

### Executed verification commands and evidence
- `poetry run pytest tests/scripts/dev_tools/test_feature_docs.py -q -k primary_issue_and_pass_readiness`
	- Evidence: `evidence/regression-testing/pass-primary-issue-and-pass-readiness.2026-02-22T23-15.md`
- `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_part4.py -q -k pass_readiness_autoclose_section`
	- Evidence: `evidence/regression-testing/pass-pass-readiness-autoclose-section.2026-02-22T23-15.md`
- `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context.py -q -k narrative_mentions_excluded_from_autoclose_section`
	- Evidence: `evidence/regression-testing/pass-narrative-mention-exclusion.2026-02-22T23-15.md`
- `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_part4.py -q -k non_pass_readiness_fallback`
	- Evidence: `evidence/regression-testing/pass-non-pass-fallback.2026-02-22T23-15.md`
- `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40`
	- Evidence: `evidence/other/pass-collector-autoclose-contract.2026-02-22T23-15.md`
- Final QA toolchain evidence:
	- `evidence/qa-gates/black-final.2026-02-22T23-15.md`
	- `evidence/qa-gates/ruff-final.2026-02-22T23-15.md`
	- `evidence/qa-gates/pyright-final.2026-02-22T23-15.md`
	- `evidence/qa-gates/pytest-final.2026-02-22T23-15.md`
	- `evidence/qa-gates/final-pass-summary.2026-02-22T23-15.md`


## Acceptance Criteria
- [x] Running `poetry run python -m scripts.dev_tools.pr_context.collector --base feature/bootstrap-utilities-#40` emits `===== Issues to autoclose (verified or pending) =====` in `artifacts/pr_context.summary.txt`.
- [x] For audited issue metadata `Issue: #46` with readiness `PASS`, the new section includes `#46` (validated by targeted regression evidence) and remains compatible with existing prompt rules.
- [x] Mention-only refs (`#40/#42/#43`) do not appear in the approved autoclose source section and are not emitted as `Closes` lines unless explicitly asserted through approved sources.
- [x] Conservative fallback is emitted when deterministic inputs are missing (no primary issue, readiness not `PASS`, or malformed metadata).
- [x] Regression coverage is added in `tests/scripts/dev_tools/test_feature_docs.py`, `tests/scripts/dev_tools/test_collect_pr_context.py`, and `tests/scripts/dev_tools/test_collect_pr_context_part4.py` with failing-before/fixing-after behavior.
- [x] No unintended behavior change occurs for unrelated `pr_context` sections (verification, CI status, close candidates diagnostics).
- [x] Full Python toolchain pass is recorded for final implementation (black, ruff, pyright, pytest --cov command).
- [x] Feature docs and prompt-contract references remain consistent with deterministic autoclose emission behavior.

## Risks & Mitigations
- Technical or operational risks:
- Risk: readiness parsing could drift from audit file conventions and suppress valid pending autoclose.
- Risk: over-broad issue extraction could reintroduce false-positive auto-close issues.
- Risk: downstream consumers may rely on old summary assumptions and mis-handle additive section.
- Mitigations and rollbacks:
- Restrict deterministic source to explicit `Issue: #NN` metadata and explicit readiness `PASS` only.
- Add regression tests that lock out mention-based promotion.
- Keep change additive and reversible; rollback by reverting new section and derivation path.

## Rollout & Follow-up
- Release/rollout steps:
- Implement fix + tests on feature branch, regenerate artifacts, and validate PR output contract before merge.
- Post-fix monitoring or clean-up tasks:
- Verify subsequent PRs for audited features emit expected `Closes #NN` lines only from approved sources.
- Track any false-negative cases where readiness exists but pending autoclose is not emitted; adjust parsing only with evidence.
- Links: issue, PRs, related docs
- Issue: `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/issue.md`
- Research: `docs/features/active/2026-02-22-pr-does-not-autoclose-with-valid-issue-audit-48/research.md`
- Prompt contract: `.github/prompts/generate-pr.prompt.md`
