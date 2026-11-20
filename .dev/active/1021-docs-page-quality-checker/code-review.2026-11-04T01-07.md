# Code Review: Documentation page quality checker (#1021)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-page-quality-checker-1021`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (tip and merge base `fd6ee4e5a`)
**Head Branch:** `feature/docs-page-quality-checker-1021-r2` (head `f18016516`)
**Review Type:** Re-audit after remediation cycle 1

---

## Executive Summary

This re-audit covers the full branch diff against the epic integration branch (118 paths, `git diff fd6ee4e5a...HEAD`), with attention to the cycle-1 commit `f18016516`, which changes `DocsPageFrontMatter.psm1` and `DocsPageCheck.psm1` (and their bundle copies), extends `DocsPageFrontMatter.Tests.ps1`, and adds `DocsPageCheck.LinkMap.Tests.ps1`. The reviewer read the cycle diff line by line, re-ran the docs Pester suites with the module-convention gate suite, PSScriptAnalyzer and the formatter over `.claude/lib/docs` and `tests/scripts/claude-lib/docs`, the push-down contract pytest (34 passed), and direct probes of the flow-sequence parser; it also parsed the coverage artifact written by the cycle's `Invoke-PoshQCTest` run (100% for each new module).

**What changed in cycle 1:**
- F1 fixed: `ConvertFrom-DocsPageFlowSequence` now tracks an escape flag for the current double-quoted item instead of looking back one character. A `\` with the flag clear sets the flag, the next character clears it, and `"` closes the item only when the flag is clear. The flag is reset when an item opens. Single-quoted items keep the existing rule.
- N1 fixed: `Invoke-DocsCheckCommand` builds `Get-DocsPageLinkMap` once and passes it to `Get-DocsPageExternalTarget` and, through the new optional `-LinkMap` parameter, to `Get-DocsPageCheckFinding`, which still builds the map itself when the parameter is null.

**Top 3 risks:**
1. Required CI (`poshqc / PowerShell QC` on `windows-latest`) has not run for a PR head (F2, `awaiting_ci`).
2. `DocsPageCheck.Tests.ps1` is at 696 logical lines, 4 lines below the 700-line advisory tier; further tests for that module belong in a separate file, as cycle 1 did.
3. `-LinkMap` is trusted as given: a caller that passes a map built from a different `PageText` gets findings for that other map. The parameter is documented as the result of the private helper for the same `PageText`, and the only in-repo caller passes the matching map, so this is recorded as Info.

**PR readiness recommendation:** **Ready for PR, pending CI** - no autonomous finding remains; F2 resolves at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/docs/DocsPageFrontMatter.psm1` (and bundle copy) | `ConvertFrom-DocsPageFlowSequence`, lines 159-171 | F1 resolved. Reviewer probes at head: `["a\\", b]` gives `Ok=True`, items `a\`, `b`; `["a\\\"", b]` gives `a\"`, `b`; `["a\", b]` gives `Ok=False`, `unclosed flow sequence`; additional probes listed in the Test Quality Audit agree with JSON string rules. | None. | The spec value-form table (spec line 390) admits JSON double-quoted scalars in a single-line flow sequence; the fix conforms. | Reviewer probe script; `evidence/regression-testing/f1-fail-before.2026-11-04T00-46.md` (red before the fix) |
| Info | `.claude/lib/docs/DocsPageCheck.psm1` (and bundle copy) | lines 269-270, 281, 312-313, 417-423 | N1 resolved. One `Get-DocsPageLinkMap` call per run; the new parameter is optional, typed `[hashtable]` with `[AllowNull()]`, and documented in comment help. The exported-function list and result shape are unchanged. | None. | `DocsPageCheck.LinkMap.Tests.ps1` asserts exactly one call and equal findings with and without the precomputed map. | Reviewer Pester run; `evidence/regression-testing/n1-fail-before.2026-11-04T00-47.md` |
| Info | `.claude/lib/docs/DocsPageCheck.psm1` | `Get-DocsPageCheckFinding -LinkMap` | The function does not verify that a supplied map was built from the supplied `PageText`. | None required. If more callers appear, consider validating that `$LinkMap.Model.Keys` equals the `PageText` keys. | Single in-repo caller passes the matching map; the contract is stated in comment help. | Source inspection |
| Info | `.claude/lib/docs/DocsPageCheck.psm1` | line 274 | The public parameter `-Profile` of `Get-DocsPageCheckFinding` shares its name with the `$PROFILE` automatic variable (carried from the initial review). | None required; the name is fixed by the spec. | PSScriptAnalyzer reports no finding. | PSSA 0 findings |
| Info | `.claude/lib/docs/templates/page-check/vale.ini` | line 6 | `BasedOnStyles = Vale, DocsBase` enables Vale spelling checks against an empty consumer vocabulary (carried from the initial review). | None required; mandated by spec line 581. | Consumer-owned vocabulary by design. | Spec line 581 |

No covered file is at or above 700 logical lines (maximum 696, `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1`), so no file-size Warning applies. No file is above 800 lines and `config/file-size-baseline.json` is not in the diff. Cycle-1 sizes: `DocsPageFrontMatter.psm1` 426, `DocsPageCheck.psm1` 434, `DocsPageFrontMatter.Tests.ps1` 542, `DocsPageCheck.LinkMap.Tests.ps1` 107 (logical lines).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The F1 change is local to the quoted-item branch of one function: three statements replace one, and the item-open statement resets the flag. No other function changed, so the JSON fast path and the single-quote `''` rule are unaffected.
- The N1 change keeps `Get-DocsPageCheckFinding` pure and callable without the new parameter; the null fallback preserves the earlier behavior for every existing test caller.
- Both edited modules are byte-identical to their bundle copies (reviewer `sha256sum`: `1fa57407...` for `DocsPageCheck.psm1`, `19ecde92...` for `DocsPageFrontMatter.psm1`).
- The full-branch observations of the initial review still hold: pure rule functions over in-memory page maps, strict UTF-8 decoding with typed catches, ordinal ordering, a single masked line model, and one-row anchor edits in the three 1020 files.

#### API and safety notes

- `-LinkMap` adds an optional parameter to a public function; the change is backward compatible.
- The escape flag handles a trailing lone backslash before `]` as an unterminated item (`["a\", b]` reports `unclosed flow sequence`), which matches the spec's `UNSUPPORTED` rule for an unclosed sequence.

#### Error handling and logging

- No change to error handling in cycle 1. `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` remain at module scope.

---

## Test Quality Audit

Reviewed: reviewer re-run of the docs suites and the module-convention gate suite at head `f18016516`; executor evidence for cycle 1 (fail-before records for F1 and N1, `qa-pester-coverage.2026-11-04T00-55.md`, `coverage-delta.2026-11-04T00-55.md`, `isolation-shuffled.2026-11-04T00-58.md`).

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1` - new test `resolves a flow sequence whose double-quoted item ends in an escaped backslash` covers the value form and the block form for `["a\\", b]` and `["a\\\"", b]` and the unterminated `["a\", b]`; one construct case was added to the data-driven construct test. Values are single-quoted PowerShell literals, so the backslashes are literal.
- `tests/scripts/claude-lib/docs/DocsPageCheck.LinkMap.Tests.ps1` (new, 2 tests) - builds the real map inside the module scope before registering the mock, asserts `Should -Invoke Get-DocsPageLinkMap -Times 1 -Exactly`, exit code 0, zero findings and a page count of 2; the second test compares ordered `code artifact_path` lists with and without the map on a page set with a broken link. It writes no file and its mock is scoped to its `It` block.
- `evidence/regression-testing/f1-fail-before.2026-11-04T00-46.md` and `n1-fail-before.2026-11-04T00-47.md` - both new tests were red before the source change.
- `evidence/regression-testing/isolation-shuffled.2026-11-04T00-58.md` - seeds 1021, 20261030 and 7, 765 of 765 each, the new file present in every order.

Additional reviewer probes of `ConvertFrom-DocsPageYamlScalar` (module scope) at head, each consistent with JSON string rules:

| Input | Result |
|---|---|
| `["\\\\", "x"]` | Ok, items `\\`, `x` |
| `["a\"b", c]` | Ok, items `a"b`, `c` |
| `['a\', b]` | Ok, items `a\`, `b` (single-quoted items have no backslash escape) |
| `["a\\"]` | Ok, single item `a\` (whole value is valid JSON; fast path) |

### Quality assessment prompts

- **Determinism:** no clock, timer, sleep or unseeded randomness in the new tests.
- **Isolation:** in-memory command context from `Docs.TestSupport.psm1`; no temporary files.
- **Speed:** the two new link-map tests run in-process with in-memory pages.
- **Diagnostics:** assertions compare full item lists and ordered finding keys, so a failure names the differing value.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token in the cycle diff; earlier scan `qa-token-scan.2026-11-04T00-17.md`. |
| No unsafe subprocess or command construction | ✅ PASS | No process, `Invoke-Expression` or dot-sourcing added; `DocsPageImportIsolation.Tests.ps1` passes. |
| Input validation at boundaries | ✅ PASS | Unchanged; `-Profile` and `-Path` validated before any read; pages bounded at 1 MiB. |
| Error handling remains explicit | ✅ PASS | Unchanged typed catches. |
| Parser correctness against the spec | ✅ PASS | F1 resolved; reviewer probes above. |

---

## Research Log

No external research was required. Repository sources consulted: `spec.md` (`## Front-matter subset` value-form table), `remediation-inputs.2026-11-04T00-25.md`, `remediation-plan.2026-11-04T00-25.md`, the cycle-1 evidence records, and `.claude/rules/powershell.md`.

---

## Verdict

Both cycle-1 items (F1, N1) are resolved with red-then-green regression tests, unchanged 100% line coverage of the edited modules and byte-identical bundle copies. No Blocker, Major or Minor finding remains. The CI-dependent criteria S20 and U10 (F2) resolve through `windows-latest` CI on the PR head at S9.
