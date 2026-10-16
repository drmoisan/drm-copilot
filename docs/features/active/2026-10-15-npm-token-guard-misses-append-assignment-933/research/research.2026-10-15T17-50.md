# Research: npm-token-guard-misses-append-assignment (Issue #933)

- Issue: #933 (minor-audit bug, preparation mode)
- Branch: `bug/npm-token-guard-misses-append-assignment-933` (feature-folder commit `babb2c2a4`)
- Stamp note: this agent had no shell tool, so it could not read the host clock. The stamp `2026-10-15T17-50` was chosen to fall after the existing `plan.2026-10-15T17-44.md`. The orchestrator may rename the file if it needs an exact clock value.
- Method: every finding below comes from reading files and running ripgrep/glob searches in this worktree. The regex behavior tables come from tracing each pattern by hand. They were not executed, because no Python execution tool was available. Phase 2 of the plan must confirm them.

## Recorded Decision (orchestrator; not reopened)

The append form `NPM_TOKEN+=...` is **in scope**. The guard must report append assignments. The #903 pinned row `residual-bash-append-not-reported` (#903 AC-14) flips to expect a finding.

This reverses a #845 spec non-goal, which is written at:

- `docs/features/active/2026-10-08-npm-token-guard-comparison-false-positive-and-stale-docstring-845/spec.md:61`: "Pre-existing residuals that behave the same before and after the change: single-`=` shell test `[ $NPM_TOKEN = "" ]` and Bash `=~` (still reported), and Bash append `NPM_TOKEN+=x` (not reported)."

Related records of the same non-goal (historical, not to be edited):

- #845 research `research/research.2026-10-08T23-50.md:103`
- #845 `code-review.2026-10-09T21-30.md:36` (CR-2)
- #903 `issue.md:57` (AC-14) and `issue.md:224` (Operator Follow-up 1, which proposes `\bNPM_TOKEN\s*\+?=(?!=)`)

The other residuals in that non-goal are unchanged by this decision. A single-`=` shell test and a bash `=~` match stay reported. The #845 non-goal at `spec.md:62`, "Broadening the lookahead to `(?![=~])` or any other change to alternative A", is also respected: the recommended change touches alternative B only.

## 1. Current State: Guard Modules and the Four Finders

There is no guard under `scripts/` or `src/`. The guard lives entirely in test code:

- Detection helpers: `tests/scripts/dev_tools/npm_token_guard_test_support.py` (178 lines; the module is not collected by pytest, per its docstring at lines 22-23).
- Tests: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (388 lines).

All four finders share `_matching_line_numbers` (support module line 51), which runs `pattern.search` on each line separately.

| # | Finder (support module line) | Pattern constant (line) | Regex (all `re.IGNORECASE`) | Detects |
|---|---|---|---|---|
| 1 | `find_npm_token_references` (72) | `_NPM_TOKEN_CONTEXT_REFERENCE` (38-41) | `\b(?:secrets\|vars)\s*(?:\.\s*NPM_TOKEN\b\|\[\s*['\"]NPM_TOKEN['\"]\s*\])` | Reads of the `NPM_TOKEN` secret or variable |
| 2 | `find_node_auth_token_references` (90) | `_NODE_AUTH_TOKEN_REFERENCE` (42) | `\bNODE_AUTH_TOKEN\b` | Any mention of `NODE_AUTH_TOKEN` |
| 3 | `find_npm_auth_token_config_references` (105) | `_NPM_AUTH_TOKEN_CONFIG_REFERENCE` (43-45) | `(?<![A-Za-z0-9])_authtoken\b` | `_authToken` configuration keys |
| 4 | `find_npm_token_assignments` (121) | `_NPM_TOKEN_ASSIGNMENT` (46-48) | A: `(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:`  B: `\bNPM_TOKEN\s*=(?!=)` | Assignments to `NPM_TOKEN` |

### Which finders can see an append, by context

- **Finder 1** looks only at the right-hand side, and only when that side reads `secrets.NPM_TOKEN` or `vars.NPM_TOKEN`. `NPM_TOKEN+=${{ secrets.NPM_TOKEN }}` is therefore already reported by finder 1. `NPM_TOKEN+=${{ secrets.X }}` with any other name is not.
  - The #903 Operator Follow-up 1 statement "escapes all four finders" is accurate only for secret names other than `NPM_TOKEN`.
  - No change is needed in finder 1.
- **Finders 2 and 3** are unrelated to the `NPM_TOKEN` name. They report an append line only if it also mentions `NODE_AUTH_TOKEN` or `_authToken`. No change is needed.
- **Finder 4, alternative A (YAML mapping key)**: YAML has no append operator, so no append context can reach it. No change is needed.
- **Finder 4, alternative B (shell/PowerShell `=`)**: this is the only finder that can see an append. It currently fails because `\s*=` meets `+` immediately after the name. This is the only place that must change.

Append-shaped contexts and whether the proposed alternative B would report them (hand trace):

| Context | Example | Today | Proposed |
|---|---|---|---|
| bash append in a `run:` block (issue repro) | `NPM_TOKEN+=${{ secrets.X }}` | `[]` | `[1]` |
| bash append, bare | `NPM_TOKEN+=x` | `[]` | `[1]` |
| bash `export`/`declare`/`local` append (bash allows `+=` in these builtins; not verified against a bash binary here) | `export NPM_TOKEN+=x` | `[]` | `[1]` |
| PowerShell compound assignment | `$env:NPM_TOKEN += 'x'` | `[]` | `[1]` (`\s*` takes the space before `+=`) |
| `GITHUB_ENV` line (the runner has no append semantics, but the textual rule reports it like the existing `github-env-append` row) | `echo "NPM_TOKEN+=x" >> "$GITHUB_ENV"` | `[]` | `[1]` |
| empty append at end of line | `NPM_TOKEN+=` | `[]` | `[1]` |
| YAML env key | not expressible | n/a | n/a |

Residuals that remain unreported both before and after the change. These are out of scope and are recorded only:

- `${env:NPM_TOKEN} += 'x'`. The plain `=` form of this is also unreported today.
- bash array element `NPM_TOKEN[0]+=x`. The plain `=` form is also unreported today.
- `[Environment]::SetEnvironmentVariable('NPM_TOKEN', ...)` and `printf -v NPM_TOKEN`.

## 2. Regression Analysis of `\bNPM_TOKEN\s*\+?=(?!=)`

Hand trace of alternative B with the proposed change. Alternative A is unchanged; none of these rows reaches alternative A unless stated.

| Input | Current row / note | Today | Proposed | Reason |
|---|---|---|---|---|
| `if: ${{ env.NPM_TOKEN == '' }}` | `equality-comparison` | `[]` | `[]` | `\+?` is empty and `=` takes the first `=`. `(?!=)` fails, and shrinking `\s*` puts `=` against a space. |
| `[[ $NPM_TOKEN == "" ]]` | `shell-equality-test` | `[]` | `[]` | Same as above. |
| `if: ${{ env.NPM_TOKEN != '' }}` | `inequality-comparison` | `[]` | `[]` | `!` is neither `+` nor `=`. `\+?` matches only a literal `+`, so `!=` cannot slip through. |
| `NPM_TOKEN==value` | `accepted-double-equals-narrowing-not-reported` | `[]` | `[]` | `(?!=)` fails. |
| `NPM_TOKEN+==x` / `NPM_TOKEN +== x` | new | `[]` | `[]` | With `+` taken, `=` is followed by `=` and the lookahead fails. With `\+?` empty, `=` meets `+`. This matches the accepted `==` narrowing (bash would append `=x`). |
| `[ $NPM_TOKEN = "" ]` | `residual-single-equals-shell-test-reported` | `[1]` | `[1]` | Unchanged. |
| `[[ $NPM_TOKEN =~ ^npm_ ]]` | `residual-bash-regex-match-reported` | `[1]` | `[1]` | Unchanged. |
| `[ "$NPM_TOKEN" -eq 0 ]`, `$env:NPM_TOKEN -eq ''` | none | `[]` | `[]` | No `=` follows the name. |
| `NPM_TOKEN <= x`, `NPM_TOKEN >= x` | none | `[]` | `[]` | `<`/`>` is not `+` or `=`. |
| `(( NPM_TOKEN++ ))`, `NPM_TOKEN + 1`, `NPM_TOKEN+ =x` | new | `[]` | `[]` | After `+` the next character is not `=`, and with `\+?` empty, `=` meets `+`. |
| `NPM_TOKEN_V2+=x` / `MY_NPM_TOKEN+=x` | new | `[]` | `[]` | `_` follows the name, or there is no `\b` before `N`. |
| `${{ secrets.NPM_TOKEN }}`, `${{ env.NPM_TOKEN }}` | `secrets-dot-context`, `env-context-read` | `[]` | `[]` | No `=` follows the name. |
| All 8 `detects_assignment` rows | existing | `[1]`/`[2]` | unchanged | The added `\+?` is optional, so every existing match still succeeds. |

Conclusions:

- No existing negative row becomes a finding. The `\+?` cannot absorb `!` or a second `=`. The pattern has no nested quantifiers, so it adds no backtracking risk.
- The tree scan stays green. A case-insensitive search for `npm_token` under `.github/` returned no matches, so no current workflow line changes outcome.

### Exact minimal change (finder 4 only)

`tests/scripts/dev_tools/npm_token_guard_test_support.py` line 47:

- Before: `r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=(?!=)", re.IGNORECASE`
- After: `r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*\+?=(?!=)", re.IGNORECASE`

The `re.compile(` layout, alternative A, and `re.IGNORECASE` stay as they are. Finders 1-3 need no change.

### Rejected alternatives

- `\bNPM_TOKEN\s*(?:\+=|=(?!=))`: reports `NPM_TOKEN+==x`, which is inconsistent with the accepted `==` narrowing, and is longer.
- A separate fifth finder or pattern for appends: adds a tree-scan parametrize row and changes the "four detected families" wording in the support module docstring. It is more churn for the same detection.
- Broadening to `(?![=~])`: unrelated, and excluded by the #845 non-goal at `spec.md:62`.

## 3. Pinned Row and Stale Statements

### Pinned row

- File: `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
- Test: `test_find_npm_token_assignments_pins_documented_residuals` (line 285; parametrize block lines 264-284)
- Row at line 277: `pytest.param("NPM_TOKEN+=x", [], id="residual-bash-append-not-reported"),`
- Flip: change `[]` to `[1]` and rename the id. Recommended id: `bash-append-reported`. Keeping `residual-...-not-reported` with an expected `[1]` would contradict its own name.

Two placements are possible:

- Keep the row in the pin test, with the new id.
- Move it into `test_find_npm_token_assignments_detects_assignment` (lines 207-236), since it is no longer a residual.

The minimal option is to edit it in place. Either way, the fail-before run must show the row failing against the current pattern.

### Statements that become stale (must change)

1. `tests/scripts/dev_tools/test_workflow_npm_token_guard.py:288-296`, the pin test docstring. It says the #845 non-goal "accepts three residuals ... and a bash `+=` append is not". Rewrite it: two residuals stay reported (`=` test and `=~`), and #933 reversed the append non-goal, so `+=` is reported.
2. `tests/scripts/dev_tools/npm_token_guard_test_support.py:124-128`, the `find_npm_token_assignments` docstring. It does not mention `+=`, and line 127 says "prose without `:` or `=` after the name are not reported". Update it to state that the `+=` append (shell, `export`, PowerShell `+=`) is reported, and that `==`, including `+==`, is not.

### Optional reference updates (not stale)

- `test_workflow_npm_token_guard.py:7`: issue list "(issues #712, #739, and #845)". Optionally add #933.
- `npm_token_guard_test_support.py:11`: "(issues #712 and #739)". Optionally add #933.

### Historical records (do not edit)

These describe past behavior correctly as of their date:

- #845 `spec.md:61`, `research/research.2026-10-08T23-50.md:103`, `code-review.2026-10-09T21-30.md:36`
- #903 `issue.md:57`, `issue.md:224`, `research/p8a-review-nits-793-797-845-846-903.2026-10-11T11-00.md:128,152`, `evidence/regression-testing/fail-before-exception.p8-845.2026-10-13T11-26.md:11`, `evidence/regression-testing/p8-845-collect-compare.2026-10-13T11-26.md:22,40`
- `docs/features/potential/promoted/2026-10-11-round-2-review-nits-and-evidence-timestamps.md:40`

### Rule and instruction files

- A search of everything outside `docs/features/` for `NPM_TOKEN`/`npm_token_guard` matched only:
  - the two guard files
  - `README.md`, `docs/engineering/npm-token-rotation.runbook.md`, and `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md` (secret/OIDC prose, no append statement)
  - `tests/scripts/dev_tools/test_scratch_location_contracts.py` (an unrelated `npm_tokens` local variable)
  - two `tests/fixtures/blast_radius/historical-runs/*.json` files (historical data that must not change)
- No `.claude/rules`, `.github/instructions`, `.codex/`, or `extensions/` file mentions the append form.

## 4. Mirror and Parity Copies

None exist.

- A search for `find_npm_token|NPM_TOKEN_ASSIGNMENT|npm_token_guard` outside `docs/` matched only the two guard files and `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json` (historical path data).
- A glob for `**/*npm*token*` found no PowerShell, TypeScript, or `extensions/drm-copilot/resources/` copy.
- #845 `spec.md:66` reached the same conclusion: "no bundled mirror of this test exists".

## 5. Toolchain

- Language in scope: Python only. Tier: `quality-tiers.yml` classifies `scripts/dev_tools` (line 16) and has no entry for `tests/`. Both files are test code.
- Line counts:
  - `npm_token_guard_test_support.py` has 178 lines.
  - `test_workflow_npm_token_guard.py` has 388 lines.
  - Both counts are the last numbered content line in the Read tool output; the tool also displayed one trailing empty line.
  - Projection: the docstring edit adds about 2 lines to the support module. The new rows and docstring rewrite add about 10-25 lines to the test file. Both stay well under 500.
- Commands (repository forms; CI equivalents in `.github/workflows/_quality-checks.yml:54-91`):
  1. `poetry run black tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py` (CI: `poetry run black --check .`)
  2. `poetry run ruff check tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  3. `poetry run pyright tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  4. Architecture-boundary: no Python architecture tool is configured (`pyproject.toml` has no import-linter/tach/pytestarch entry). Not applicable.
  5. `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -v` (fail-before and pass-after)
  6. Contract/schema: not applicable.
  7. Integration: not applicable. The tree-scan tests in the same file serve as the repository-level check.
- Coverage:
  - Requested dotted form: `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py --cov=tests.scripts.dev_tools.npm_token_guard_test_support --cov-branch --cov-report=term-missing`.
  - Caveat: `pyproject.toml:122-124` omits `tests/*` from coverage, and `[tool.coverage.run] source` is `["src", "scripts/dev_tools"]`. The dotted target is therefore expected to measure nothing (likely "No data to report"). This was not executed. A gate built on it cannot fail and must not be used as evidence.
  - Follow the #739 precedent instead (`2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/coverage-comparison.2026-10-01T20-58.md`):
    - Run the full suite before and after with `poetry run pytest --cov --cov-branch --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing`.
    - Then run `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`.
    - Record `NewOrChangedCodeCoverage: not applicable - no production line changed`, supported by an empty `git diff --name-only origin/main...HEAD -- src scripts`.
  - Write evidence under `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/<kind>/`.

## 6. CI

- `.github/workflows/ci.yml:11-12`: job `quality-checks7` calls `.github/workflows/_quality-checks.yml`.
- That reusable workflow's job `quality-checks7` ("Code Quality & Tests") runs on Python 3.10-3.13 and includes step "Run tests with Pytest" (lines 79-85: `poetry run pytest --cov --cov-branch ...`). Pytest collects `tests/` (`pyproject.toml:117`).
- CI triggers on PRs to `main`, `development`, and `epic/**`.

## Numeric Derivation Evidence

Numeric claim: "the guard has four finders" (the issue's "none of the four finders").

- Complete Family: public `find_*` detection functions in `tests/scripts/dev_tools/npm_token_guard_test_support.py`, each with a module-level compiled pattern.
- Exhaustive Search Scope: the whole support module, plus the test module's import list and its tree-scan parametrization. A repository-wide search confirmed no other module defines these finders (Section 4).
- Inclusion Rules: a top-level function named `find_*` that returns line numbers through `_matching_line_numbers`.
- Exclusion Rules: `_matching_line_numbers`, `collect_offenders`, and `enumerate_github_yaml_files`, which are helpers rather than detection families.
- Primary Search Strategy: ripgrep `^def find_` in the support module.
- Primary Member Set: `find_npm_token_references` (72), `find_node_auth_token_references` (90), `find_npm_auth_token_config_references` (105), `find_npm_token_assignments` (121).
- Primary Count: 4.
- Cross-check Search Strategy: ripgrep `^_[A-Z_]+ = re\.compile` in the support module (pattern constants), plus ripgrep `^\s+find_\w+,$` in the test module (imports at lines 21-24 and tree-scan parametrization at lines 349, 354, 359, 364).
- Cross-check Member Set: the patterns `_NPM_TOKEN_CONTEXT_REFERENCE` (38), `_NODE_AUTH_TOKEN_REFERENCE` (42), `_NPM_AUTH_TOKEN_CONFIG_REFERENCE` (43), and `_NPM_TOKEN_ASSIGNMENT` (46). These map one-to-one to the same four functions. The tree-scan rows name the same four functions.
- Cross-check Count: 4.
- Member-set Comparison: after normalizing each pattern to its finder, the sets are identical: {references, node_auth, auth_token_config, assignments}. The count of 4 is supported.

No other numeric acceptance criterion is proposed. #933 has no `spec.md`, which matches minor-audit mode.

## Testing Implications

- Fail-before rows (expected to fail against the current pattern, as a Phase 2 regression):
  - the flipped pin row `NPM_TOKEN+=x` → `[1]`
  - new `detects_assignment` rows: `NPM_TOKEN+=${{ secrets.X }}` (issue repro, `[1]`), `export NPM_TOKEN+=x` (`[1]`), `$env:NPM_TOKEN += 'x'` (`[1]`)
- Non-regression rows (pass before and after; recommended additions):
  - `NPM_TOKEN+==x` → `[]` (pins the `+==` narrowing; this can sit in the pin test next to `accepted-double-equals-narrowing-not-reported`)
  - `NPM_TOKEN_V2+=x` → `[]`
  - `(( NPM_TOKEN++ ))` → `[]`
- Existing rows must stay unchanged, including the #845 AC-7 set and the `equality-comparison`, `shell-equality-test`, and `inequality-comparison` rows.
- No temporary files are needed. All rows are in-memory strings, in line with the existing test style (Arrange-Act-Assert with `!a` failure messages).

## Automation Feasibility

No human interaction is required:

- The change is one regex token, docstrings, and parametrize rows in two test files.
- The decision is already recorded by the orchestrator.
- Every verification step is a local `poetry run` command, and CI runs automatically on the PR.
- No secret, workflow edit, external service, or release step is involved.

## Recommended Change Set

- `tests/scripts/dev_tools/npm_token_guard_test_support.py`:
  - Line 47: change alternative B from `\bNPM_TOKEN\s*=(?!=)` to `\bNPM_TOKEN\s*\+?=(?!=)` so `+=` appends are reported.
  - Lines 124-128: update the `find_npm_token_assignments` docstring to state that `+=` is reported and `==`/`+==` are not (optionally add #933 at line 11).
- `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`:
  - Line 277: flip `residual-bash-append-not-reported` to expect `[1]` and rename it, for example to `bash-append-reported`.
  - Lines 288-296: rewrite the pin test docstring to record the #933 reversal of the #845 non-goal.
  - In the `detects_assignment` parametrize block (lines 207-224), add rows for the issue repro, `export ...+=`, and PowerShell `+=`.
  - Add non-regression rows for `+==`, the longer name with `+=`, and `++`.
  - Optionally add #933 to the module docstring at line 7.
- `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/issue.md`: record the scope decision (append form in scope, #845 `spec.md:61` non-goal reversed) and check the Proposed Fix item when it is delivered.
- `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/plan.<stamp>.md`: replace the template placeholders with the concrete tasks above (the planner's responsibility).
- `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/{baseline,regression-testing,qa-gates}/...`: fail-before, pass-after, toolchain, line-count, and full-suite coverage-comparison artifacts.
- No change to `.github/`, `src/`, `scripts/`, `extensions/`, `.codex/`, rule or instruction files, historical #845/#903 records, or `tests/fixtures/blast_radius/historical-runs/*.json`.
