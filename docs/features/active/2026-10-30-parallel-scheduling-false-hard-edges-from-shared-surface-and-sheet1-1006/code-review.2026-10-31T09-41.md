# Code Review: parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1 (#1006), Remediation Cycle 1 Re-review

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006`
**Feature Folder Selection Rule:** Named by the caller. It matches issue #1006 and the branch suffix `-1006`, and it is the only active folder touched by the branch diff.
**Base Branch:** `main` (merge base `1898400756e909b88cde5f51a05f0b11d423d3b0`)
**Head Branch:** `bug/parallel-scheduling-false-hard-edges-1006` @ `d7dd48791e6ad0a1127251dcf32284c1cabd51aa`
**Review Type:** Re-review at the exit of remediation cycle 1 (prior review `code-review.2026-10-31T08-57.md`)

---

## Executive Summary

The branch removes two sources of false hard scheduling edges and gives destinations a durable demotion control: a closed generic-contract predicate (`Sheet`/`Chart` plus ASCII digits) at all six contract-filtering sites in Python and PowerShell, `quality-tiers.yml` moved to `conflict_tolerance.append_only_paths` in both truth tables, and a `shared_surfaces_demote` overlay directive in the Python and TypeScript composers. The frozen scheduling surfaces are unchanged against the merge base.

Remediation cycle 1 made two code changes, both inspected in full (`git diff fc1d8618b..HEAD -- extensions tests`):

1. `unionStrings` now has a single definition, exported from `claude-blast-radius-overlay-demote.ts` and imported by `claude-blast-radius-overlay.ts`. The demote module still imports nothing from the overlay module. `applySharedSurfaceDemotion` calls `unionStrings<unknown>(appendOnly, overlayValue)`. The behavior is equivalent to the removed `includes` loop: overlay values are verified strings, so seeding the seen-set with the string members of the base and de-duplicating the overlay in order yields the same list. The three overlay suites (71 tests) passed with no test file edited.
2. `BlastRadius.KeyPartition.Tests.ps1` uses the local `$overlayDirectiveKey` instead of writing `$script:OverlayDirectiveKey` inside an `It` block.

The cycle also produced the TypeScript lcov artifact. The reviewer re-read its per-file counters and confirmed they match the evidence.

**What changed:**
Initial delivery as described in the prior review. Cycle 1: the shared union helper and the Pester local variable, plus QA and coverage evidence.

**Top 3 risks:**
1. The repo-wide Python coverage figure is not in the local artifact, which is scoped to five modules; CI enforces it on the PR head (awaiting CI).
2. `.claude/skills/parallel-plan/SKILL.md` still states "three token shapes" while the rule lists five. It is out of scope by spec (AC-23 asserts the file is unchanged) and recorded as a follow-up.
3. `unionStrings` is now an export of the demote module. Only the overlay module imports it, but a future caller could take a dependency on a function whose home is a feature-specific module. The module comment documents the placement.

**PR readiness recommendation:** **Ready for PR, pending CI.** The code needs no further change. The one blocking item, the repo-wide Python coverage figure, is cleared by the PR CI coverage-threshold step on the final head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `artifacts/python/lcov.info` | `SF:` records | Carried forward. The Python coverage artifact contains only the five changed modules (dotted `--cov=` targets), so it gives no repo-wide Python figure. | At the S9 CI gate, record the PR CI step `Enforce Python coverage thresholds` (`--min-line 85 --min-branch 75`) conclusion and `TOTAL` line on the final head. | The repo-wide threshold must be shown. The changed files cannot lower it, because each holds or raises its coverage; cycle 1 changed no Python file. | `grep '^SF:'` lists five records; no PR exists (`gh pr list` returned `[]`) |
| Minor | `.claude/skills/parallel-plan/SKILL.md` (and bundle copy) | "three token shapes" sentence | Carried forward, non-blocking. The skill's token-shape count differs from the rule's "five token shapes". | Address in the recorded follow-up item: replace the count with a reference to `### Read-by-mandate classification`. | Out of scope by spec; AC-23 asserts the file is unchanged, and the parallel schedule admitted siblings against the declared radius. | `evidence/other/follow-ups.2026-10-31T08-43.md` |
| Info | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts` | `unionStrings` | Resolved from the prior Minor. One definition, generic over the base element type, no cast, no `any`; FNDA 85 with no zero-hit line. | None. | Removes the duplicated union and keeps the one-way import direction. | Reviewer grep over `extensions/drm-copilot/src`: one `function unionStrings`, no demote import of `./claude-blast-radius-overlay`; `coverage-comparison.2026-10-31T09-17.md` |
| Info | `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` | directive-key block | Resolved from the prior Nit. `$overlayDirectiveKey` is local to the `It` block. | None. | Removes a script-scope write inside a test. | Cycle diff; `pester-keypartition.2026-10-31T09-16.md` (6 tests, 0 failures); `pssa.2026-10-31T09-18.md` (0 findings) |
| Info | `extensions/drm-copilot/coverage/lcov.info` | both overlay files | Resolved from the prior Major. The artifact exists; overlay 442/444 line, 96/100 branch; demote 157/157, 27/27; repo-wide 97.05% line, 93.67% branch. | None. | Coverage verification from an artifact is satisfied for TypeScript. | Reviewer `awk` over `lcov.info`; `ts-coverage.2026-10-31T09-17.md` |
| Info | `docs/features/potential/promoted/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1.md` | n/a | The issue-promotion record is in the branch diff. | None. It is the standard lifecycle record written by issue promotion. | Recorded for AC-23 transparency. | `evidence/qa-gates/scope-check.2026-10-31T09-36.md` |

There are no Blocker findings. The one Major finding is a coverage-evidence item that the PR CI run clears; it is not a code defect. No covered file is at or above 700 logical lines (largest `extensions/drm-copilot/jest.config.cjs` at 540), so no file-size Warning applies, and `config/file-size-baseline.json` is not in the diff.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `is_generic_contract_token` is total and pure; `token.isascii()` short-circuits before `re.fullmatch` with `re.IGNORECASE | re.ASCII`.
- Each filtering site adds a single conjunct; docstrings state the new rule.
- The demotion validates before building output and does not mutate its input.

#### Typing and API notes

- `SHARED_SURFACES_DEMOTE_KEY` is in `__all__`; internal constants are underscore-prefixed. Pyright exits 0. No Python change in cycle 1.

#### Error handling and logging

- Distinct `BlastRadiusOverlayError` details asserted verbatim in both runtimes. No logging added, as the spec requires.

### TypeScript implementation audit

#### What changed well

- The demotion is a pure function with a discriminated-union result, so the composer owns error construction.
- Cycle 1 consolidated the union: `unionStrings<T>(base: ReadonlyArray<T>, overlay: ReadonlyArray<string>): (T | string)[]` replaces both the overlay module's `JsonValue` version and the demote module's inline loop. `composeStringList` and `mergeValues` keep their call sites and return types, and the shared parity corpus test confirms unchanged output.

#### Type safety and maintainability

- No `any`, `as` cast, or suppression in the cycle diff. The `Set<string>` is seeded only from `typeof item === "string"` members, which is the correct narrowing for a heterogeneous base.

#### Error handling and logging

- Failure details are identical to Python; `BlastRadiusOverlayError` is thrown before any write.

### PowerShell implementation audit

#### What changed well

- `Test-GenericContractToken` uses an ordinal ASCII check before a `\A...\z`-anchored, culture-invariant regex, matching Python `fullmatch` semantics.
- Exported from `BlastRadiusTokenShape.psm1` and re-exported from `BlastRadiusExtraction.psm1`. The five modules and the rule are byte-identical to their bundle copies (reviewer `cmp`).

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType([bool])]`, mandatory `[string]` with `[AllowEmptyString()]`. PSScriptAnalyzer 0 findings.

#### Error handling and logging

- The predicate is total; call sites remain fail-fast.

---

## Test Quality Audit

Behavioral verification is complete. Fail-before and pass-after evidence is recorded for both runtimes. Cycle 1 re-ran isolation checks (seeded Jest shuffle with seed 1006; Pester file-order shuffles with seeds 11, 23, 47) with zero failures, and a fresh single-process Pester run over `tests/scripts` (13541 tests, 0 failures). Changed-line coverage is 100% in all three languages.

### Reviewed test and QA artifacts

- `evidence/regression-testing/ts-union-helper.2026-10-31T09-15.md`: three overlay suites, 71 of 71, no test file edited.
- `evidence/regression-testing/pester-keypartition.2026-10-31T09-16.md`: 6 of 6, equal to the baseline count.
- `evidence/qa-gates/ts-coverage.2026-10-31T09-17.md` and `coverage-comparison.2026-10-31T09-17.md`: per-file and repo-wide figures with deltas.
- `evidence/qa-gates/pester-full.2026-10-31T09-35.md`: per-module 100% line coverage for the five blast-radius modules.
- `evidence/regression-testing/isolation.2026-10-31T09-36.md`: order-independence checks.
- `evidence/qa-gates/scope-check.2026-10-31T09-36.md`: no frozen path changed; one `unionStrings` definition.

### Quality assessment prompts

- **Determinism:** Fixed timestamps and in-memory file systems; no clock, RNG, or network.
- **Isolation:** The remaining script-scope write in a test was removed in cycle 1.
- **Speed:** New pytest file runs in well under one second.
- **Diagnostics:** Scenario assertions report every hard reason kind per edge.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | The diff contains no credentials, tokens, or keys. |
| No unsafe subprocess or command construction | PASS | None added. |
| Input validation at boundaries | PASS | Overlay directive validated for type, member type, target list, and known entries before any write. |
| Error handling remains explicit | PASS | Fail-closed `BlastRadiusOverlayError`; no broad catch. |
| Configuration / path handling is safe | PASS | The forbidden-glob guard on `modules` is unchanged and tested with the directive present. |
| Regex safety | PASS | Anchored patterns, no nested quantifiers, closed literal stem list. |
| Behavioral equivalence of the cycle refactor | PASS | Equivalence argument above; parity corpus and demotion tests pass unchanged. |

---

## Research Log

No external research was required. Decisions are grounded in the in-repo spec, research record, rule text, remediation plan, and the issue #903 precedent for the ASCII guard.

---

## Verdict

The implementation is correct, minimal, and consistent across Python, PowerShell, and TypeScript, and cycle 1 resolved the TypeScript coverage artifact, the duplicated union, and the Pester script-scope write. The code needs no further change. The remaining blocking item is the repo-wide Python coverage figure, which the PR CI step `Enforce Python coverage thresholds` confirms on the final head.
