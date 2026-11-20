# Research: NPM_TOKEN guard comparison false positive and stale docstring (Issue #845)

- **Issue:** #845
- **Branch:** bug/npm-token-guard-comparison-false-positive-and-stale-docstring-845
- **Timestamp:** 2026-10-08T23-50
- **Mode:** preparation-mode research (no source, test, or configuration edits)
- **Single in-scope file:** `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (492 lines on the current tree)

## Method and Evidence Limits

- All file:line references below were verified by reading the current worktree with the Read and Grep tools.
- This research session had no shell tool (no Bash, PowerShell, or `poetry run`). The regex probe results in this document are therefore derived by stepping through Python `re` semantics by hand, alternative by alternative, including backtracking of `\s*`. They are not executed results. The issue's own executed probe (issue.md lines 38 and 44-49: `== ''` True, `!= ''` False, `NPM_TOKEN=abc` True) agrees with the hand derivation for the current pattern. The executor must confirm the proposed pattern by running the regression rows in Phase 2 (fail-first) and Phase 4 (pass); the parametrized rows proposed below are the executable probes.
- Only synthetic strings are used (`x`, `abc`, `''`, `secrets.PUBLISH`). No real token value was read or recorded.
- No evidence artifacts were produced by this session.

## 1. Current State (Question 1)

### Pattern and finder

- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:47-49`:

  ```python
  _NPM_TOKEN_ASSIGNMENT = re.compile(
      r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=", re.IGNORECASE
  )
  ```

  Alternative A (YAML key): `(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:`. Alternative B (shell/PowerShell assignment): `\bNPM_TOKEN\s*=`.
- Finder `find_npm_token_assignments` at lines 122-136; docstring lines 123-135; body line 136 `return _matching_line_numbers(_NPM_TOKEN_ASSIGNMENT, text)`.
- Shared scanner `_matching_line_numbers` at lines 52-70 (line-wise `pattern.search`).

### Every test that exercises the pattern (Grep for `_NPM_TOKEN_ASSIGNMENT|find_npm_token_assignments` under `tests/`)

| Test | Lines | Rows (id: input -> expected) |
|---|---|---|
| `test_find_npm_token_assignments_detects_assignment` | parametrize 357-374, def 375-385 | `yaml-env-key-other-secret` (361-363): `"env:\n  NPM_TOKEN: ${{ secrets.PUBLISH }}"` -> `[2]`; `yaml-flow-mapping` (365): `"env: { NPM_TOKEN: x }"` -> `[1]`; `quoted-key` (366): `'"NPM_TOKEN": x'` -> `[1]`; `shell-export` (367): `"export NPM_TOKEN=x"` -> `[1]`; `github-env-append` (368-370): `'echo "NPM_TOKEN=x" >> "$GITHUB_ENV"'` -> `[1]`; `powershell-env` (371): `"$env:NPM_TOKEN = 'x'"` -> `[1]`; `lowercase-key` (372): `"npm_token: x"` -> `[1]` |
| `test_find_npm_token_assignments_ignores_non_matching_text` | parametrize 388-398, def 399-407 | `secrets-dot-context` (391): `"${{ secrets.NPM_TOKEN }}"`; `env-context-read` (392): `"${{ env.NPM_TOKEN }}"`; `longer-name-key` (393): `"NPM_TOKEN_V2: x"`; `prefixed-name-key` (394): `"MY_NPM_TOKEN: x"`; `prose-comment` (395): `"# NPM_TOKEN is no longer used"`; `empty` (396): `""` -- all expect `[]` |
| `test_collect_offenders_names_each_matching_line` | 410-424 | text `"NPM_TOKEN: a\nname: b\nnpm_token: c"` with `find_npm_token_assignments` (line 421) -> lines 1 and 3 |
| `test_github_yaml_files_contain_no_npm_token_route` | parametrize 449-473 (row `npm-token-assignment`, lines 467-471), def 474-492 | tree scan of every `*.yml`/`*.yaml` under `.github/` must yield no offender |

No existing row contains `==`, `!=`, `<=`, or `>=`. The comparison behavior is undocumented by any test (confirms issue.md line 38).

## 2. Root Cause and Candidate Approaches (Questions 2 and 3)

### Why `==` matches and `!=` does not

For `if: ${{ env.NPM_TOKEN == '' }}`:

- Alternative A: the only `NPM_TOKEN` occurrence is preceded by `.`, which the negative lookbehind `(?<![\w.-])` rejects. No match.
- Alternative B: `\b` holds between `.` and `N`; `NPM_TOKEN` matches; `\s*` consumes the space; `=` matches the first character of `==`. Nothing follows `=` in the pattern, so the search succeeds. Match.

For `if: ${{ env.NPM_TOKEN != '' }}`: alternative B reaches `\s*` then requires `=`, but the next character is `!` (or the space, after backtracking `\s*` to zero). No match. The same reasoning gives no match for `<=` and `>=` (next character `<` or `>`).

### Candidate A (recommended): negative lookahead `(?!=)` after `=`

Proposed line 48:

```python
    r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=(?!=)", re.IGNORECASE
```

Line length after the change: 79 characters (current 74), within the 88-character Black/Ruff limit; the `re.compile(` call layout at lines 47-49 is unchanged.

Hand-derived probe table for the proposed pattern (the current pattern gives the same result in every row except those marked "changed"):

| Probe string | Current | Proposed | Deciding step |
|---|---|---|---|
| `NPM_TOKEN=abc` | match | match | B: `=` then `a`; lookahead passes |
| `export NPM_TOKEN=x` (`shell-export`) | match | match | B: `=` then `x` |
| `echo "NPM_TOKEN=x" >> "$GITHUB_ENV"` (`github-env-append`) | match | match | B: `\b` after `"`; `=` then `x` |
| `$env:NPM_TOKEN = 'x'` (`powershell-env`) | match | match | B: `\s*` takes the space; `=` then space |
| `NPM_TOKEN = x` | match | match | B: `=` then space |
| `NPM_TOKEN=${{ secrets.X }}` | match | match | B: `=` then `$` |
| `NPM_TOKEN=` (end of line) | match | match | B: lookahead at end of string finds no `=`, so `(?!=)` passes |
| `  NPM_TOKEN: ${{ secrets.PUBLISH }}` (`yaml-env-key-other-secret`) | match | match | A (unchanged) |
| `env: { NPM_TOKEN: x }` (`yaml-flow-mapping`) | match | match | A |
| `"NPM_TOKEN": x` (`quoted-key`) | match | match | A: optional quotes |
| `npm_token: x` (`lowercase-key`) | match | match | A: `re.IGNORECASE` |
| `if: ${{ env.NPM_TOKEN == '' }}` | match | **no match (changed)** | B: `=` followed by `=`; backtracking `\s*` to zero leaves a space, not `=` |
| `[[ $NPM_TOKEN == "" ]]` | match | **no match (changed)** | B: `\b` after `$`; `=` followed by `=` |
| `NPM_TOKEN==x` | match | **no match (changed)** | B: `=` followed by `=` |
| `process.env.NPM_TOKEN === ''` | match | **no match (changed)** | B: first `=` followed by `=` |
| `if: ${{ env.NPM_TOKEN != '' }}` | no match | no match | B: `!` is not `=` |
| `NPM_TOKEN <= x` / `NPM_TOKEN >= x` | no match | no match | B: `<` / `>` is not `=` |
| `$env:NPM_TOKEN -eq ''` | no match | no match | no `=` and no `:` after the name |
| `${{ secrets.NPM_TOKEN }}`, `${{ env.NPM_TOKEN }}`, `NPM_TOKEN_V2: x`, `MY_NPM_TOKEN: x`, `# NPM_TOKEN is no longer used`, `""` (current negative rows) | no match | no match | unchanged; none reaches `=` |

Collect-offenders text `"NPM_TOKEN: a\nname: b\nnpm_token: c"` uses alternative A only and is unaffected.

### False-negative analysis (Question 3)

The change removes detection only for lines where `NPM_TOKEN`, optional whitespace, and `==` appear in sequence. Assessment of whether that sequence can be a real assignment route:

- YAML: a mapping key requires `:`; alternative A covers it and is unchanged. `NPM_TOKEN==x` in YAML is a plain scalar, not a key.
- GitHub Actions expressions: `==` is the equality operator; it reads a value and cannot set one.
- `$GITHUB_ENV` lines and POSIX shell: `NPM_TOKEN==x` is accepted as an assignment whose value is `=x` (the value starts after the first `=`). The resulting value carries a leading `=` and is therefore not an unmodified secret; a functional token route would be written `NPM_TOKEN=${{ secrets.X }}`, which still matches. This residual is judged acceptable; it is the only syntactic route lost.
- PowerShell: `==` is not a PowerShell operator; assignment uses a single `=`, which still matches.
- Independent coverage: any `env.NPM_TOKEN` read must be populated somewhere; that population is either an `NPM_TOKEN:` key (alternative A), a single-`=` assignment (alternative B), or a `secrets`/`vars` reference (`_NPM_TOKEN_CONTEXT_REFERENCE`, lines 39-42). All three remain detected.

Residuals that exist before and after the change (out of scope; recorded for awareness, no action proposed):

- Single-`=` shell test `[ $NPM_TOKEN = "" ]` and Bash `=~` still match alternative B (fail-closed false positive).
- Bash append `NPM_TOKEN+=x` matches neither alternative before or after (pre-existing; `+` is not `=`).

### Candidate B (rejected): keep the behavior and document it with a positive row

Add a positive row asserting `if: ${{ env.NPM_TOKEN == '' }}` -> `[1]`. This is the most fail-closed option, but it contradicts the finder's own contract at lines 126-128 ("A context read (``secrets.NPM_TOKEN``, ``env.NPM_TOKEN``) ... [is] not reported"): `env.NPM_TOKEN == ''` is a context read, while `env.NPM_TOKEN` alone is already a negative row (`env-context-read`, line 392). It would also make a legitimate emptiness check fail the tree-scan guard (issue.md line 58).

### Recommendation

Adopt Candidate A. It is a five-character change, aligns the pattern with the documented read/assign distinction, keeps every current positive row, and the only lost syntax (`NPM_TOKEN==value`) cannot deliver an unmodified secret. The fail-closed posture is preserved for every functional assignment form.

## 3. Stale Docstring (Question 4)

- Line 208 (summary line of `test_find_npm_token_references_detects_reintroduced_reference`, def at 205-207): `    """A reintroduced ``NPM_TOKEN`` secret reference is reported at its line.`
- Parameter rows `vars-dot` (line 201) and `vars-bracket` (line 202) are `vars` references not described by "secret reference".
- Sibling negative test docstring, line 235 (D5 wording, #739 plan line 191): `"""Text that does not consume the ``NPM_TOKEN`` secret or variable is ignored."""`
- Constraint found during research: the issue's example wording, "A reintroduced ``NPM_TOKEN`` secret or variable reference is reported at its line.", produces an 89-character line with the 4-space indent and opening `"""` (counted by character). Ruff selects `E` (`pyproject.toml:94-95`) with `line-length = 88` (line 89), so E501 would fail. Black does not reflow docstrings and would not fix it.
- Proposed replacement for line 208 (77 characters):

  ```python
      """A reintroduced ``NPM_TOKEN`` secret or variable reference is reported.
  ```

  The following body lines 210-212 are unchanged. Acceptable alternative if "its line" must be retained (82 characters): `"""A reintroduced ``NPM_TOKEN`` secret or variable reference reports its line.`

## 4. Other Docstrings (Question 5)

- Module docstring, lines 1-23 (the closing `"""` is line 23): line 10-11 "an ``NPM_TOKEN`` assignment fed from any secret" and lines 14-16 ("a match in any key, block scalar, expression, or comment is reported") remain accurate; a comparison is not a match under the new pattern. No change required.
- `find_npm_token_assignments` docstring, lines 125-128: currently lists the exclusions as "a context read ..., a longer or prefixed name, and prose without ``:`` or ``=`` after the name". Recommend naming the new exclusion so the contract matches the pattern:

  ```python
      A YAML mapping key (block, flow, or quoted) and a shell or PowerShell
      assignment are reported whichever secret feeds them. A context read
      (``secrets.NPM_TOKEN``, ``env.NPM_TOKEN``), an ``==`` comparison, a longer
      or prefixed name, and prose without ``:`` or ``=`` after the name are not
      reported.
  ```

  Longest line 78 characters; net +1 line.
- Negative test docstring line 400 ("Text that reads but does not assign ``NPM_TOKEN`` is not reported.") already covers comparisons. No change.
- Positive test docstring line 378 and all other docstrings: no change.

## 5. Toolchain and Coverage (Question 6)

Commands for the single in-scope file (forms match #739 final QA evidence):

1. `poetry run black tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
2. `poetry run ruff check --no-fix tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
3. `poetry run pyright tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
4. `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -q`
5. Full suite coverage mode: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`

Coverage applicability:

- `pyproject.toml:119-127`: `[tool.coverage.run] source = ["src", "scripts/dev_tools"]` and `omit` includes `tests/*`. The in-scope file and its in-file helpers are test code and are never measured.
- A targeted `--cov=tests.scripts.dev_tools.test_workflow_npm_token_guard` (or any `--cov=<path>.py`) measures nothing useful and cannot fail; do not use it as a gate. Line/branch coverage of changed lines is not applicable; the full-suite TOTAL row is expected to be unchanged.
- `pyproject.toml:116` `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"` adds only a report format; pytest-cov does not start measurement without `--cov`, so the targeted run (step 4) is not affected.

Prior recorded results (#739, current file content):

- Black: "1 file left unchanged." (`docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-black.2026-10-01T20-55.md`)
- Ruff: "All checks passed!" (`.../final-ruff.2026-10-01T20-55.md`)
- Pyright: "0 errors, 0 warnings, 0 informations" (`.../final-pyright.2026-10-01T20-55.md`)
- Targeted pytest: "52 passed" (`.../final-pytest-guard.2026-10-01T20-55.md`)
- Full suite: "6331 passed, 6 skipped", TOTAL 92% (`.../final-pytest-coverage.2026-10-01T20-57.md`); the full-suite count has since changed on main and must be re-baselined.

## 6. Mirrors and Other Files (Questions 7 and 8)

- Bundled mirrors: Glob `extensions/drm-copilot/resources/**/*npm_token*` returned no file; Grep `NPM_TOKEN` (case-insensitive) under `extensions/` returned no file. No mirror copy exists.
- Grep for `test_workflow_npm_token_guard|_NPM_TOKEN_ASSIGNMENT|find_npm_token_assignments` outside `docs/` found only the test file and `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json:509`, which records the path as historical declared-scope data. That fixture does not depend on file content and must not change.
- No other repository file must change apart from feature-folder documentation.
- `.github/`: Grep `NPM_TOKEN` (case-insensitive, all files, on-disk including untracked) under `.github/` returned no file. The current tree has 15 YAML files under `.github/` (Glob `.github/**/*.y*ml`), including `.github/workflows/publish-mcp-npm.yml`; none is affected. There is no live impact, and the tree-scan row `npm-token-assignment` will pass before and after the change.

## 7. Requirements Mapping

| Issue Expected Behavior bullet (issue.md lines 33-34) | Proposed change | Test |
|---|---|---|
| A comparison (`==`) is not reported as an assignment, or a test documents intentional reporting | Line 48: append `(?!=)` to alternative B; lines 125-128: name the `==` exclusion in the finder docstring | New negative rows in `test_find_npm_token_assignments_ignores_non_matching_text` (after line 396): `pytest.param("if: ${{ env.NPM_TOKEN == '' }}", id="equality-comparison")` (fails before the fix), `pytest.param('[[ $NPM_TOKEN == "" ]]', id="shell-equality-test")` (fails before the fix), `pytest.param("if: ${{ env.NPM_TOKEN != '' }}", id="inequality-comparison")` (passes before and after; guards the `!=` boundary). New positive row in `test_find_npm_token_assignments_detects_assignment` (after line 372): `pytest.param("NPM_TOKEN=", [1], id="empty-assignment-end-of-line")` (passes before and after; guards that `(?!=)` does not reject a trailing `=`). Existing `shell-export`, `github-env-append`, `powershell-env` rows guard single-`=` assignments. |
| The docstring describes all parameterized cases | Line 208 replaced with `"""A reintroduced ``NPM_TOKEN`` secret or variable reference is reported.` | Verified by Ruff (E501) and review; no behavior test applies |
| Integration retest (issue.md line 70) | None | `test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment]` against the current `.github/` tree |

Every proposed row line is at most 83 characters. Black keeps single quotes for the `[[ ... "" ]]` string because it contains double quotes (same as existing line 366).

Projected file length: 492 + 4 rows + 1 docstring line = 497 lines (limit 500). If the finder-docstring edit is dropped, 496.

Fail-first expectation for Phase 2: with only the rows added, exactly the `equality-comparison` and `shell-equality-test` nodes fail; all other nodes pass.

## 8. Numeric Derivation Evidence

The spec has no numeric acceptance criterion yet. The following counts are recorded so a plan can assert node counts.

### Claim N1: current test node count of the module is 52

- Complete Family: every collected pytest node in `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`.
- Exhaustive Search Scope: the whole file (lines 1-492), all 11 `def test_` functions, parametrized and non-parametrized.
- Inclusion Rules: one node per `pytest.param` row of a parametrized test; one node per non-parametrized test function.
- Exclusion Rules: helper functions (`_matching_line_numbers`, finders, `collect_offenders`, `enumerate_github_yaml_files`) are not tests.
- Primary Search Strategy or Query Expression: Grep `id="[^"]+"` with only-matching output (50 ids at lines 184-202, 226-231, 251-253, 272-274, 294-314, 334-341, 363-372, 391-396, 455-470) plus the 2 non-parametrized functions found by reading (`test_collect_offenders_names_each_matching_line` line 410, `test_github_yaml_enumeration_is_non_vacuous` line 427).
- Primary Member Set: 50 parametrized ids listed by the Grep above + 2 non-parametrized tests.
- Primary Count: 52.
- Cross-check Search Strategy or Query Expression: (a) Grep count of `pytest\.param\(|^def test_` = 61 occurrences, minus 11 `def test_` functions = 50 params; (b) per-function enumeration by reading: references positive 9, references negative 6, NODE_AUTH_TOKEN positive 2, negative 3, `_authToken` positive 7, negative 6, assignment positive 7, negative 6, collect_offenders 1, enumeration 1, tree scan 4; (c) prior executed result "52 passed" in `final-pytest-guard.2026-10-01T20-55.md`.
- Cross-check Member Set: the 11 functions with the per-function counts in (b).
- Cross-check Count: 9+6+2+3+7+6+7+6+1+1+4 = 52.
- Member-set Comparison: the per-function partition in (b) equals the Grep id ranges grouped by parametrize block; both total 52 and agree with the executed 52.

### Claim N2: proposed node count is 56 (assignment positive 7 -> 8, assignment negative 6 -> 9)

- Complete Family: N1 family plus the four proposed rows in Section 7.
- Exhaustive Search Scope: the two assignment parametrize blocks (lines 357-374 and 388-398); no other block changes.
- Inclusion Rules / Exclusion Rules: as N1; docstring edits add no nodes.
- Primary Search Strategy or Query Expression: N1 primary member set + the 4 new ids (`empty-assignment-end-of-line`, `equality-comparison`, `shell-equality-test`, `inequality-comparison`).
- Primary Member Set: 50 + 4 ids, + 2 non-parametrized tests.
- Primary Count: 56.
- Cross-check Search Strategy or Query Expression: per-function enumeration with the two assignment blocks updated.
- Cross-check Member Set: 9, 6, 2, 3, 7, 6, 8, 9, 1, 1, 4.
- Cross-check Count: 56.
- Member-set Comparison: agree. The executor must confirm 56 by an executed run; the count is valid only if exactly the four rows above are added.

## 9. Testing Implications

- Fail-first: add the three negative rows and one positive row, run the targeted pytest, record that exactly `equality-comparison` and `shell-equality-test` fail; then apply the line-48 change and confirm all 56 nodes pass.
- Keep `test_github_yaml_files_contain_no_npm_token_route` unchanged; rerun it as the integration retest.
- No property-based, mutation, or coverage obligation applies to changed lines: the file is test code omitted from coverage (`pyproject.toml:122-123`).
- No temporary files, network access, or clock dependency is introduced.

## 10. Rejected Alternatives

- Candidate B (document the comparison match with a positive row): contradicts the finder's documented exclusion of context reads and would fail the guard on a harmless emptiness check.
- Broader lookahead such as `=(?![=~])` to also exclude Bash `=~`: out of scope for #845, and not requested; it would widen the behavior change beyond the reported defect.
- Issue's exact docstring wording: rejected only because it produces an 89-character line that fails Ruff E501.

## Automation Feasibility

No human interaction is required. All changes are confined to one test file plus feature-folder documentation; verification uses the Poetry toolchain (Black, Ruff, Pyright, pytest) and a read of the `.github/` tree. No secret, repository setting, or external service is touched.
