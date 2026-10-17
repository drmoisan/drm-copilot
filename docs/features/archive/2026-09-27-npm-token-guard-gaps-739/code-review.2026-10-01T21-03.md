# Code Review: npm-token-guard-gaps (#739)

**Review Date:** 2026-10-01
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-27-npm-token-guard-gaps-739`
**Base Branch:** `main` (merge-base `12fd3c26`)
**Head Branch:** `bug/npm-token-guard-gaps-739` (`9273246f`)
**Review Type:** Initial review

---

## Executive Summary

The branch extends the #712 `NPM_TOKEN` guard test module (`tests/scripts/dev_tools/test_workflow_npm_token_guard.py`, 263 to 492 lines) and corrects one line of the #712 runbook. No production file and no `.github/` file changed.

**What changed:**
- The guard grows from two detected families to four:
  1. `NPM_TOKEN` context references, now covering `vars` as well as `secrets` (`_NPM_TOKEN_CONTEXT_REFERENCE`, renamed from `_NPM_TOKEN_SECRET_REFERENCE`).
  2. `NODE_AUTH_TOKEN` mentions (unchanged pattern).
  3. `_authToken` configuration keys in `.npmrc`, `npm_config_` environment variables, and `npm config set` (`_NPM_AUTH_TOKEN_CONFIG_REFERENCE`, new).
  4. `NPM_TOKEN` assignments as YAML keys, shell assignments, `$GITHUB_ENV` appends, and PowerShell `$env:` assignments (`_NPM_TOKEN_ASSIGNMENT`, new).
- Line scanning is consolidated into `_matching_line_numbers`, diagnostic formatting into `collect_offenders`, and the two former tree-scan tests are replaced by one test parametrized over the four finders.
- The module docstring is rewritten to remove the inaccurate "tracked files" claim.
- The #712 runbook "Recording completion" step 2 now points at the pending evidence record instead of the stale `docs/features/active/.../issue.md` path.

**Top 3 risks:**
1. `_NPM_TOKEN_ASSIGNMENT` matches an equality comparison (`env.NPM_TOKEN == ''`); fail-closed, no current impact (CR-2).
2. The tree-scan test reads the repository tree from disk inside the unit suite, inherited from #712 (CR-4).
3. One positive-case docstring no longer describes all its cases (CR-1).

**PR readiness recommendation:** **Go** (APPROVE) - 0 Blocking findings, 4 Non-blocking findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | line 208, docstring of `test_find_npm_token_references_detects_reintroduced_reference` (CR-1) | Summary says "``NPM_TOKEN`` secret reference" while the cases now include `vars` forms | Reword to "secret or variable reference" to match the D5 rewording applied to the negative test at line 235 | Docstring accuracy; no behavior impact | Reviewer read of the module |
| Minor | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 47-49, `_NPM_TOKEN_ASSIGNMENT` (CR-2) | The `\bNPM_TOKEN\s*=` alternative matches an equality comparison such as `if: ${{ env.NPM_TOKEN == '' }}` | Add a `(?!=)` lookahead after `=`, or add a documenting test case if the false positive is intended | Fail-closed (guard fails rather than misses a route); no current `.github/` file contains that shape | Reviewer in-memory regex probe returned `True` |
| Info | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 44-46, `_NPM_AUTH_TOKEN_CONFIG_REFERENCE` (CR-3) | The lookbehind excludes letters and digits but not `_`, so `GH__AUTHTOKEN` (double underscore) is reported | None; recorded for awareness | Required for `NPM_CONFIG__AUTHTOKEN` to match; fail-closed; the helper docstring's "letter- or digit-prefixed" wording is accurate | Reviewer in-memory regex probe returned `True` |
| Info | `tests/scripts/dev_tools/test_workflow_npm_token_guard.py` | lines 474-492, `test_github_yaml_files_contain_no_npm_token_route` (CR-4) | The tree-scan test reads repository files from disk inside the unit-test suite | No change within this issue's scope | Design inherited from #712 and documented in the module docstring; no temporary files; deterministic for a given tree | Module docstring; reviewer read |

No Blocker or Major findings. Total Blocking Count: 0.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `_matching_line_numbers` removes the duplicated comprehension from each finder; every public finder is now a one-line delegation with its own docstring. This follows the reusability principle without adding indirection beyond one level.
- Passing the finder as a `Callable[[str], list[int]]` into `collect_offenders` and parametrizing the tree scan over `(finder, family_label)` keeps the four families symmetric; adding a fifth family is a one-entry change.
- Patterns are compiled once at module scope with `re.IGNORECASE`, which is appropriate for the case-insensitive environment-variable and `.npmrc` forms.

#### Correctness of detection

- `_NPM_TOKEN_CONTEXT_REFERENCE`: the leading `\b` rejects `mysecrets.NPM_TOKEN` (`prefixed-context-name`), and the trailing `\b` rejects `NPM_TOKEN_V2` in both contexts. Bracket access tolerates inner whitespace (`spaced-bracket`).
- `_NPM_AUTH_TOKEN_CONFIG_REFERENCE`: the `(?<![A-Za-z0-9])` lookbehind permits the `__` in `NPM_CONFIG__AUTHTOKEN` and the `:` in registry-scoped keys while rejecting `GH_AUTHTOKEN`. The trailing `\b` rejects longer identifiers such as `_authTokenX`.
- `_NPM_TOKEN_ASSIGNMENT`: the first alternative's `(?<![\w.-])` lookbehind rejects `MY_NPM_TOKEN:` and `env.NPM_TOKEN` reads while allowing a quoted key; the second alternative's `\b` handles `export`, `$GITHUB_ENV` appends, and `$env:` assignments.

#### Type safety and maintainability

- Pyright strict reports 0 errors; `Callable` is imported under `TYPE_CHECKING`. No suppressions were added.

#### Error handling and logging

- Not applicable; test-only change.

### Documentation

- Module docstring accurately states disk enumeration through `pathlib`, independence from version control, and names all four families.
- Runbook step 2 is consistent with the #712 spec decision D5 and no longer directs the operator to edit acceptance criteria.

---

## Test Quality Audit

- 35 new parametrized nodes (17 to 52). Each finder has positive, negative, and `empty` cases; IDs are descriptive; assertion messages use `{text!a}` so control characters are visible in failures.
- `test_collect_offenders_names_each_matching_line` covers ordering and the `<path>:<line>` format, including a skipped non-matching middle line.
- `test_github_yaml_enumeration_is_non_vacuous` (unchanged) still guards the tree scan against an empty enumeration.
- The fail-before exception dossier (`evidence/regression-testing/fail-before-exception.2026-10-01T20-58.md`) explains why a failing tree-scan run was not staged (no `.github/` edit permitted, no temporary files permitted) and substitutes the in-memory positive cases as proof. This is a reasonable substitute given the constraints.

### Reviewer verification

| Check | Result |
|---|---|
| `poetry run black --check` on the module | `1 file would be left unchanged.`, exit 0 |
| `poetry run ruff check --no-fix` on the module | `All checks passed!`, exit 0 |
| `poetry run pyright` on the module | `0 errors, 0 warnings, 0 informations` |
| `poetry run pytest` on the module, `-q` | `52 passed in 0.09s` |
| `grep -c ""` on the module | `492` |
| Suppression and banned-token scan | no match |
| `git diff origin/main...HEAD -- docs/features/completed/` | exactly one line replaced in the runbook |
| Referenced record `docs/features/completed/unused-npm-token-secret-712/evidence/other/human-action-pending.2026-09-27T09-19.md` | exists; line 4 reads `Status: pending` |
| `spec.md` decision D5 in the #712 folder | exists (`### D5 — Human step`, line 95) |

### Quality assessment prompts

- **Determinism:** No clock, RNG, network, or sleep usage.
- **Isolation:** Helper tests use in-memory strings; the tree scan reads the repository tree (CR-4).
- **Speed:** 0.09s for the module.
- **Diagnostics:** Assertion messages name the input or the offender list.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Fixture literals use placeholders (`x`, `${TOKEN}`, `$TOKEN`, `${{ secrets.PUBLISH }}`) |
| No unsafe subprocess or command construction | PASS | Module does not import `subprocess` |
| `.github/` unmodified | PASS | Reviewer `git diff --name-only origin/main...HEAD -- .github` prints nothing |
| Guard passes on current tree | PASS | 4 tree-scan nodes pass on the combined #723 + #739 state |

---

## Research Log

No external research was required. Detection forms were taken from `issue.md` and `research/research.2026-09-29T22-05.md`; regex behavior was confirmed with in-memory probes.

---

## Verdict

**APPROVE.** 0 Blocking findings, 4 Non-blocking findings (CR-1 through CR-4). The change is consistent with the acceptance criteria and repository policy.
