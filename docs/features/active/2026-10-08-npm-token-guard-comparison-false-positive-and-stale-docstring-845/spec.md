# npm-token-guard-comparison-false-positive-and-stale-docstring (Spec)

- **Issue:** #845
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T23-58
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (AC source: this `spec.md` only; no `user-story.md`)
- **Requirements source:** `issue.md` (this folder)
- **Research:** `research/research.2026-10-08T23-50.md` (this folder)

## Context
The `NPM_TOKEN` assignment pattern added by #739 also matches an equality comparison such as `env.NPM_TOKEN == ''`, and one positive-case test docstring still describes only `secrets` references after `vars` cases were added. Both were recorded as non-blocking in the #739 review.

Environment:
- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
- Data source or fixture: origin/main at fb413fce; `docs/features/active/2026-09-27-npm-token-guard-gaps-739/code-review.2026-10-01T21-03.md` lines 39-40

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

A future workflow that tests whether `NPM_TOKEN` is empty would fail the guard test without introducing a token route. The docstring issue affects accuracy only. `.github/` currently contains no `NPM_TOKEN` text (research Section 6), so there is no live impact.


## Repro & Evidence
Steps to Reproduce:
1. Read `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:47-49`: `_NPM_TOKEN_ASSIGNMENT = re.compile(r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=", re.IGNORECASE)`.
2. Evaluate the pattern against `if: ${{ env.NPM_TOKEN == '' }}`, `if: ${{ env.NPM_TOKEN != '' }}`, and `NPM_TOKEN=abc`.
3. Read the docstring of `test_find_npm_token_references_detects_reintroduced_reference` (line 208) and its parameter list (lines 201-202).

Expected:
- A comparison (`==`) is not reported as an assignment, or a test case documents that it is reported intentionally.
- The docstring describes all parameterized cases (both `secrets` and `vars` references).

Actual:
- Step 2 printed `True` for `env.NPM_TOKEN == ''`, `False` for `env.NPM_TOKEN != ''`, and `True` for `NPM_TOKEN=abc` (in-memory `re` probe, 2026-10-08). The `\bNPM_TOKEN\s*=` alternative matches the first `=` of `==`. The failure mode is fail-closed (false positive). No test case documents the behavior.
- Line 208 reads "A reintroduced ``NPM_TOKEN`` secret reference is reported at its line." while lines 201-202 add `vars-dot` and `vars-bracket` cases.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:
  ```
  "if: ${{ env.NPM_TOKEN == '' }}" True
  "if: ${{ env.NPM_TOKEN != '' }}" False
  'NPM_TOKEN=abc' True
  ```


## Scope & Non-Goals
- In scope:
  - `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` only: the `_NPM_TOKEN_ASSIGNMENT` pattern (line 48), the `find_npm_token_assignments` docstring (lines 125-128), the summary line of the `test_find_npm_token_references_detects_reintroduced_reference` docstring (line 208), and new parametrize rows in the two `find_npm_token_assignments` tests.
  - Feature-folder documentation and evidence under `docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/`.
- Out of scope / non-goals:
  - CR-3 (`GH__AUTHTOKEN` matched by the `_authToken` lookbehind) and CR-4 (tree scan reads from disk); recorded as Info in #739 with no action.
  - Pre-existing residuals that behave the same before and after the change: single-`=` shell test `[ $NPM_TOKEN = "" ]` and Bash `=~` (still reported), and Bash append `NPM_TOKEN+=x` (not reported).
  - Broadening the lookahead to `(?![=~])` or any other change to alternative A (YAML key) or to the other three finder patterns.
  - Any edit to `.github/` workflows.
- Explicitly excluded systems, integrations, or datasets:
  - Production code under `src/` and `scripts/` (no change).
  - `extensions/drm-copilot/resources/` (no bundled mirror of this test exists; research Section 6).
  - `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json` (records the path as historical data; must not change).

## Root Cause Analysis
- Alternative B of `_NPM_TOKEN_ASSIGNMENT`, `\bNPM_TOKEN\s*=`, has no constraint after `=`. In `env.NPM_TOKEN == ''`, alternative A is rejected by the `(?<![\w.-])` lookbehind (preceding `.`), but alternative B matches `NPM_TOKEN`, the space, and the first `=` of `==`, so `pattern.search` succeeds. `!=`, `<=`, and `>=` do not match because the character after `\s*` is not `=` (research Section 2).
- This contradicts the finder's documented contract (lines 126-128), which states that a context read such as `env.NPM_TOKEN` is not reported; an `==` comparison is a read.
- The docstring at line 208 was not updated when #739 added the `vars-dot` and `vars-bracket` rows; deviation D5 in the #739 plan updated only the sibling negative test docstring (line 235).
- Originating item: #739. Sources: code review CR-1 and CR-2 (`code-review.2026-10-01T21-03.md:39-40`), policy audit NB-1 and NB-2 (`policy-audit.2026-10-01T21-03.md:186-187`), feature audit FA-1 (`feature-audit.2026-10-01T21-03.md:93`).


## Proposed Fix

### Design summary (what changes where):
1. Append a negative lookahead to alternative B so an equality comparison is not reported as an assignment:
   - Before: `r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=", re.IGNORECASE`
   - After: `r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=(?!=)", re.IGNORECASE`
2. Add regression rows:
   - Negative rows in `test_find_npm_token_assignments_ignores_non_matching_text`:
     - `pytest.param("if: ${{ env.NPM_TOKEN == '' }}", id="equality-comparison")` (fails before the fix)
     - `pytest.param('[[ $NPM_TOKEN == "" ]]', id="shell-equality-test")` (fails before the fix)
     - `pytest.param("if: ${{ env.NPM_TOKEN != '' }}", id="inequality-comparison")` (passes before and after; guards the `!=` boundary)
   - Positive row in `test_find_npm_token_assignments_detects_assignment`:
     - `pytest.param("NPM_TOKEN=", [1], id="empty-assignment-end-of-line")` (passes before and after; guards that `(?!=)` does not reject a trailing `=` at end of line)
3. Update the `find_npm_token_assignments` docstring so its exclusion list names an ``==`` comparison:
   ```
   A YAML mapping key (block, flow, or quoted) and a shell or PowerShell
   assignment are reported whichever secret feeds them. A context read
   (``secrets.NPM_TOKEN``, ``env.NPM_TOKEN``), an ``==`` comparison, a longer
   or prefixed name, and prose without ``:`` or ``=`` after the name are not
   reported.
   ```
4. Replace the summary line of the `test_find_npm_token_references_detects_reintroduced_reference` docstring with:
   `A reintroduced ``NPM_TOKEN`` secret or variable reference is reported.`
   The remaining docstring body (lines 210-212) is unchanged.

### Boundaries and invariants to preserve:
- Every existing positive row (`yaml-env-key-other-secret`, `yaml-flow-mapping`, `quoted-key`, `shell-export`, `github-env-append`, `powershell-env`, `lowercase-key`) continues to be reported at the same line.
- Every existing negative row (`secrets-dot-context`, `env-context-read`, `longer-name-key`, `prefixed-name-key`, `prose-comment`, `empty`) continues to return `[]`.
- Alternative A (YAML key) is unchanged.
- `test_collect_offenders_names_each_matching_line` and `test_github_yaml_files_contain_no_npm_token_route` are unchanged and continue to pass.
- The other three finder patterns and their tests are unchanged.
- The file remains at or under the 500-line limit (currently 492 lines; projected 497).

### Dependencies or blocked work:
- None. No open issue overlaps (checked 2026-10-08, issue.md line 65).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (test module containing the guard helpers and tests).

#### Functions/classes/CLI commands impacted:
- Module constant `_NPM_TOKEN_ASSIGNMENT`.
- `find_npm_token_assignments` (docstring only; body unchanged).
- `test_find_npm_token_references_detects_reintroduced_reference` (docstring summary line only).
- `test_find_npm_token_assignments_detects_assignment` (new parametrize row).
- `test_find_npm_token_assignments_ignores_non_matching_text` (new parametrize rows).

#### Data flow and validation changes:
- Lines where `NPM_TOKEN`, optional whitespace, and `==` (or `===`) appear in sequence are no longer reported by `find_npm_token_assignments`. All single-`=` assignments, including `NPM_TOKEN=` at end of line, remain reported.

#### Error handling and logging updates:
- None. The assertion failure messages are unchanged.

#### Rollback/feature-flag considerations (if applicable):
- Revert the single commit; the change is confined to one test file.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `find_npm_token_assignments(text: str) -> list[int]` signature and return format (ascending 1-based line numbers) are unchanged. Only the set of lines that match changes, as described above.

#### Required configuration keys and defaults:
- None.

#### Backward-compatibility expectations:
- No production API is affected. The test module's helpers are not imported elsewhere (research Section 6).
- Accepted behavioral narrowing: `NPM_TOKEN==value` in POSIX shell or `$GITHUB_ENV` would assign the value `=value` and is no longer reported. That value carries a leading `=` and cannot deliver an unmodified secret; a functional route (`NPM_TOKEN=${{ secrets.X }}`) is still reported (research Section 2, false-negative analysis).

#### Performance constraints (latency/throughput/memory):
- No measurable change; a single fixed-width lookahead is added to a line-wise regex search.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The issue body requested `minor-audit`; `full-bug` was selected because the preparation route requires a spec. The persisted `- Work Mode: full-bug` marker in `issue.md` is authoritative.
  - Test inputs are synthetic fixture strings only (`x`, `abc`, `''`, `""`, `secrets.PUBLISH`). No real token value is read, written, or recorded.
  - The orchestrator verified the proposed pattern in memory with Python `re` on synthetic strings: `env.NPM_TOKEN == ''` no match; `env.NPM_TOKEN != ''` no match; `NPM_TOKEN=abc`, `NPM_TOKEN = x`, `NPM_TOKEN=`, `export NPM_TOKEN=x`, YAML `NPM_TOKEN:` and quoted-key forms match; `[[ $NPM_TOKEN == "" ]]` and `NPM_TOKEN==x` no match. The executor must confirm this through the executed parametrize rows.
- Constraints (budget, performance, compatibility):
  - 500-line file limit (`.claude/rules/general-code-change.md`).
  - Black/Ruff line length 88 (`pyproject.toml`); Ruff selects `E`, so E501 applies.
- External dependencies (services, libraries, releases):
  - None beyond the existing Poetry toolchain (Black, Ruff, Pyright, pytest).

### Decisions
- **D1 (approach):** Adopt the `(?!=)` lookahead (research Candidate A) rather than documenting the comparison match with a positive row (Candidate B). Candidate B contradicts the finder's documented exclusion of context reads and would fail the tree-scan guard on a harmless emptiness check.
- **D2 (docstring wording):** The issue's example wording, "A reintroduced ``NPM_TOKEN`` secret or variable reference is reported at its line.", produces an 89-character line after indentation and the opening `"""`, which exceeds the 88-character Ruff E501 limit. The replacement drops "at its line": "A reintroduced ``NPM_TOKEN`` secret or variable reference is reported." (77 characters).
- **D3 (coverage gate applicability):** `pyproject.toml` `[tool.coverage.run]` measures `src` and `scripts/dev_tools` and omits `tests/*`. The changed file is test code and is never in the coverage denominator, so changed-line coverage is not applicable. This is a statement of measurement scope, not a waiver of the coverage policy for production code; no production file changes. A targeted `--cov=<path>` run must not be used as a gate because it measures nothing.
- **D4 (no numeric node-count criterion):** Acceptance criteria name pytest node IDs rather than asserting a total node count. The research count record's cross-check for the post-change total is derived from the primary enumeration rather than independently constructed, so a total-count assertion is omitted.

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): none. No bundled mirror under `extensions/drm-copilot/resources/` requires synchronization.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: add a `(?!=)` lookahead after `=` in the second alternative, plus negative rows for `==` comparisons.
- [ ] Integration scenario to retest: rerun `test_github_yaml_files_contain_no_npm_token_route` against the current `.github/` tree.
- [ ] Manual verification notes: reword the line-208 docstring to "secret or variable reference".

- Regression tests to add or update:
  - `test_find_npm_token_assignments_ignores_non_matching_text[equality-comparison]`
  - `test_find_npm_token_assignments_ignores_non_matching_text[shell-equality-test]`
  - `test_find_npm_token_assignments_ignores_non_matching_text[inequality-comparison]`
  - `test_find_npm_token_assignments_detects_assignment[empty-assignment-end-of-line]`
- Unit tests (pytest) for the fixed behavior and boundaries:
  - Fail-first: add the rows before changing the pattern and run the targeted pytest. The `equality-comparison` and `shell-equality-test` nodes must fail; `inequality-comparison` and `empty-assignment-end-of-line` must pass. Then apply the pattern change and confirm every node in the module passes.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - `!=` boundary (`inequality-comparison`), trailing `=` at end of line (`empty-assignment-end-of-line`), shell `[[ ... == ... ]]` test (`shell-equality-test`), existing `empty` row.
- Error handling and logging verification: not applicable (pure regex helper).
- Coverage impact and targets for changed lines/modules: not applicable; see D3.
- Toolchain commands to run (format → lint → type-check → test):
  1. `poetry run black tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  2. `poetry run ruff check --no-fix tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  3. `poetry run pyright tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  4. `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`
  - Evidence is written under `<FEATURE>/evidence/regression-testing/` (fail-first and pass runs) and `<FEATURE>/evidence/qa-gates/` (toolchain), per the evidence-location convention.
- Manual validation steps (if required): none beyond reading the two changed docstrings.


## Acceptance Criteria
- [ ] AC-1: In `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`, alternative B of `_NPM_TOKEN_ASSIGNMENT` is `\bNPM_TOKEN\s*=(?!=)` and alternative A is unchanged, so `_NPM_TOKEN_ASSIGNMENT.pattern` equals `(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=(?!=)` and the `re.IGNORECASE` flag is retained.
- [ ] AC-2: Fail-first evidence recorded under `<FEATURE>/evidence/regression-testing/`: with the new rows added and the pattern not yet changed, the nodes `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[equality-comparison]` and `...::test_find_npm_token_assignments_ignores_non_matching_text[shell-equality-test]` fail.
- [ ] AC-3: After the fix, the node `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[equality-comparison]` (input `if: ${{ env.NPM_TOKEN == '' }}`) passes.
- [ ] AC-4: After the fix, the node `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[shell-equality-test]` (input `[[ $NPM_TOKEN == "" ]]`) passes.
- [ ] AC-5: After the fix, the node `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[inequality-comparison]` (input `if: ${{ env.NPM_TOKEN != '' }}`) passes.
- [ ] AC-6: After the fix, the node `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[empty-assignment-end-of-line]` (input `NPM_TOKEN=`, expected `[1]`) passes.
- [ ] AC-7: Existing assignment rows are preserved and pass after the fix: `test_find_npm_token_assignments_detects_assignment` ids `yaml-env-key-other-secret`, `yaml-flow-mapping`, `quoted-key`, `shell-export`, `github-env-append`, `powershell-env`, `lowercase-key`, and `test_find_npm_token_assignments_ignores_non_matching_text` ids `secrets-dot-context`, `env-context-read`, `longer-name-key`, `prefixed-name-key`, `prose-comment`, `empty`, each with unchanged input text and expected value.
- [ ] AC-8: Integration retest: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment]` and `::test_collect_offenders_names_each_matching_line` pass against the current `.github/` tree after the fix.
- [ ] AC-9: The docstring of `find_npm_token_assignments` (as returned by `ast.get_docstring` or `inspect.getdoc`) lists ``==`` comparison among the inputs that are not reported, using the wording in Proposed Fix item 3.
- [ ] AC-10: The first line of the docstring of `test_find_npm_token_references_detects_reintroduced_reference` (as returned by `ast.get_docstring` or `inspect.getdoc`) equals `A reintroduced ``NPM_TOKEN`` secret or variable reference is reported.` (decision D2).
- [ ] AC-11: The targeted run `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q` reports zero failed and zero errored nodes after the fix, with output recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] AC-12: Toolchain passes on the changed file in a single pass, with output recorded under `<FEATURE>/evidence/qa-gates/`: `poetry run black --check` reports the file unchanged, `poetry run ruff check --no-fix` reports no findings (including E501), and `poetry run pyright` reports 0 errors.
- [ ] AC-13: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` is at or under the 500-line policy limit after the change.
- [ ] AC-14: Neither `git diff --name-only origin/main...HEAD` nor `git status --porcelain` lists a changed path outside `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`, the feature folder `docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/`, and the promoted lifecycle record `docs/features/potential/promoted/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring.md`.

## Risks & Mitigations
- Technical or operational risks:
  - The lookahead stops reporting `NPM_TOKEN==value`. Mitigation: that form assigns `=value` in shell and cannot deliver an unmodified secret; all single-`=` forms, YAML keys, and `secrets`/`vars` references remain detected by this and the sibling finder.
  - A docstring edit could exceed the 88-character limit. Mitigation: D2 wording (77 characters) and AC-12 Ruff check.
  - The file could exceed 500 lines. Mitigation: projected 497 lines; AC-13.
- Mitigations and rollbacks:
  - Revert the single test-file commit.

## Rollout & Follow-up
- Release/rollout steps: merge the PR; no release, publish, or extension rebuild is required.
- Post-fix monitoring or clean-up tasks: none. The pre-existing residuals listed under Non-Goals are not filed as follow-ups unless requested.
- Links: issue #845 (https://github.com/drmoisan/drm-copilot/issues/845); originating issue #739; research `research/research.2026-10-08T23-50.md`.
