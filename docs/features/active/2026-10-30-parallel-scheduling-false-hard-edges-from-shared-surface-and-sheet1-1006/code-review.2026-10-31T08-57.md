# Code Review: parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1 (#1006)

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006`
**Feature Folder Selection Rule:** Named by the caller. It matches issue #1006 and the branch suffix `-1006`, and it is the only active folder touched by the branch diff.
**Base Branch:** `main` (merge base `1898400756e909b88cde5f51a05f0b11d423d3b0`)
**Head Branch:** `bug/parallel-scheduling-false-hard-edges-1006` @ `fc1d8618bf26e9e2ffa2e81dec5e1380ec2763f8`
**Review Type:** Initial review

---

## Executive Summary

The branch removes two sources of false hard scheduling edges and gives destinations a durable demotion control. Three changes deliver this. First, a closed generic-contract predicate (`Sheet`/`Chart` followed by ASCII digits, case-insensitive, with an ASCII guard) is added to the Python and PowerShell token-shape leaf modules and applied at all six contract-filtering sites. Second, `quality-tiers.yml` moves from `shared_surfaces` to `conflict_tolerance.append_only_paths` in both committed truth tables. Third, a `shared_surfaces_demote` overlay directive is implemented in the Python and TypeScript composers, with identical fail-closed error text. The production delta is about 300 lines across 12 files, and the frozen scheduling surfaces (`HARD_REASON_KINDS`, `decide_pair`, `conflicts`, truth-table readers) are unchanged against the merge base.

I inspected the full production diff. I spot-read the new tests in all three runtimes, confirmed byte-identity of the six bundle copies with `cmp`, checked the coverage artifacts directly (`artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`), and reviewed the executor's evidence under `evidence/`. Implementation quality is good: the code is minimal, documented, and placed in leaf modules. The parity design (constant read from Python source by a Pester test, shared corpus fixtures with `expected_error`, constant-parity test for the directive key) is sound.

**What changed:**
`_blast_radius_token_shapes.py` and `BlastRadiusTokenShape.psm1` gain the stem constant, compiled pattern, and predicate. `_blast_radius_extraction.py`, `_blast_radius_write_intent.py`, `compute_blast_radius.py`, `BlastRadiusNormalization.psm1`, `BlastRadiusWriteIntent.psm1`, and `BlastRadius.psm1` each add one `and not is_generic_contract_token(...)` conjunct. `push_down_claude_blast_radius_overlay.py` adds `_apply_shared_surface_demotion` and dispatches to it after composition. The new `claude-blast-radius-overlay-demote.ts` holds the TypeScript port, and `claude-blast-radius-overlay.ts` dispatches to it. Both truth tables and the parallel-orchestration rule are updated in the source and bundle copies.

**Top 3 risks:**
1. TypeScript coverage has no `lcov.info` artifact and no repo-wide figure. Per-file thresholds are enforced by Jest and passed, but the reviewer contract requires the artifact.
2. The repo-wide Python coverage figure is not in the local artifact, which is scoped to five modules. CI enforces it on the PR head.
3. `.claude/skills/parallel-plan/SKILL.md` still states "three token shapes" while the rule now lists five. The spec puts this out of scope and it is recorded as a follow-up, so a known documentation inconsistency remains.

**PR readiness recommendation:** **Needs Revision**. The code is ready; the only blocking item is the missing TypeScript coverage artifact, which a single local coverage run with the lcov reporter resolves.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `extensions/drm-copilot/coverage/lcov.info` (absent) | n/a | TypeScript has changed production files, but no TypeScript coverage artifact exists (`coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` are both absent). The recorded run overrode the configured `lcov` reporter with `--coverageReporters=text`. | Run `npm --prefix extensions/drm-copilot run test:coverage` and record the per-file figures for both changed TS files and the repo-wide line and branch figures under `evidence/qa-gates/`. | Coverage verification from an artifact is mandatory for every language with changed files. CI's extension job runs `npm run test` without coverage, so CI cannot supply this. | `ls` of both paths: no such file; `evidence/qa-gates/ts-jest.2026-10-31T08-36.md` |
| Major | `artifacts/python/lcov.info` | `SF:` records | The Python coverage artifact contains only the five changed modules (dotted `--cov=` targets), so it gives no repo-wide Python figure. | Confirm from the PR CI step `Enforce Python coverage thresholds` (`--min-line 85 --min-branch 75`) on the final head, or run a full `pytest --cov --cov-branch` locally. | The repo-wide threshold must be shown. The changed files cannot lower it, because each holds or raises its coverage. | `grep -c '^SF:'` returned 5; `.github/workflows/_quality-checks.yml` lines 102-117 |
| Minor | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts` | `applySharedSurfaceDemotion`, union loop | The demotion re-implements an order-preserving union with `Array.includes` instead of reusing `unionStrings` from `claude-blast-radius-overlay.ts`, which the spec named ("existing union semantics (`unionStrings` / `_union_strings`)"). The Python side reuses `_union_strings`. The behavior is equivalent for string entries. | Move `unionStrings` to a shared leaf (for example the demote module or a small helper) and use it from both, keeping the no-cycle property. | This avoids two union implementations that could drift; the reusability principle in `.claude/rules/general-code-change.md`. | Diff of `claude-blast-radius-overlay-demote.ts` lines 106-112; `claude-blast-radius-overlay.ts` line 142 |
| Minor | `.claude/skills/parallel-plan/SKILL.md` (and bundle copy) | "three token shapes" sentence | The skill restates a token-shape count that was already stale and now differs from the rule's "five token shapes". | Replace the count with a reference to `### Read-by-mandate classification` in `.claude/rules/parallel-orchestration.md` and update both copies, in a remediation cycle or a follow-up item. | Agents read the skill as operating guidance, so a wrong count can mislead planners. | `evidence/other/follow-ups.2026-10-31T08-43.md`; spec Scope & Non-Goals |
| Nit | `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` | lines 174-183 (added block) | The new assertion assigns `$script:OverlayDirectiveKey` inside an `It` block, which writes to the test file's script scope. | Use a local variable (`$overlayDirectiveKey`) or define it in `BeforeAll`. | Script-scope writes inside `It` blocks can leak between tests. The isolation shuffles passed, so this is hygiene only. | Diff of the file |
| Info | `docs/features/potential/promoted/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1.md` | n/a | The issue-promotion record is in the branch diff but is not listed under spec "Files/modules to change" or inside the feature folder. | None. It is the standard lifecycle record written by issue promotion, and the executor's scope check records it explicitly. | Recorded for AC-23 transparency. | `evidence/qa-gates/scope-check.2026-10-31T08-40.md` |
| Info | `scripts/dev_tools/push_down_claude_blast_radius_overlay.py` | `_apply_shared_surface_demotion` | Check order, error text, empty-`conflict_tolerance` handling, absent-`shared_surfaces` handling, and non-string member filtering match the TypeScript port exactly. The three shared corpus fixtures (including `expected_error`) pin this across runtimes. | None. | Confirms parity. | Diff inspection; `tests/fixtures/blast_radius_overlay/shared-surfaces-demote*.json` |

There are no Blocker findings. The two Major findings are coverage-evidence gaps, not code defects. No covered file is at or above 700 logical lines, so no file-size Warning applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `is_generic_contract_token` is a total, pure one-liner. `token.isascii()` short-circuits before `re.fullmatch` with `re.IGNORECASE | re.ASCII`, which closes the Kelvin-sign and long-s folding gaps (issue #903 precedent).
- `GENERIC_CONTRACT_STEMS` uses the `tuple("...".split())` shape that the Pester parity test parses from source text.
- Each filtering site adds a single conjunct without restructuring the surrounding logic, and the docstrings are updated to state the new rule.
- The demotion validates everything before building output and returns a new document without mutating the composed input.

#### Typing and API notes

- `SHARED_SURFACES_DEMOTE_KEY` is added to `__all__`; internal key constants are underscore-prefixed.
- `cast` is used only on values already narrowed by `isinstance`, matching the module's existing pattern. Pyright exits 0.

#### Error handling and logging

- Three distinct `BlastRadiusOverlayError` details, asserted verbatim in both runtimes. No partial `conflict_tolerance` is created. No logging is added, as the spec requires.

### TypeScript implementation audit

#### What changed well

- The demotion is a pure function in its own module with a discriminated-union result (`{ ok: true, document } | { ok: false, detail }`), so the composer owns error construction and no import cycle exists.
- The composer change is minimal: the directive key is skipped in the overlay-only loop, and the no-directive path returns exactly the previous serialization, which preserves byte identity (AC-16).

#### Type safety and maintainability

- Type guards (`isPlainObject`, `isStringList`) narrow `unknown` without `any`, `as` casts, or suppressions. The input is typed `Readonly<Record<string, unknown>>`.
- The duplicated union loop is the one maintainability gap (Minor above).

#### Error handling and logging

- Failure details are identical to Python, and `BlastRadiusOverlayError` is thrown before any write.

### PowerShell implementation audit

#### What changed well

- `Test-GenericContractToken` uses an ordinal `-cnotmatch` ASCII check before a `\A...\z`-anchored regex with `IgnoreCase -bor CultureInvariant`, which reproduces Python `fullmatch` semantics.
- It is exported from `BlastRadiusTokenShape.psm1` and re-exported from `BlastRadiusExtraction.psm1`, as AC-07 requires.

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType([bool])]`, mandatory `[string]` parameter with `[AllowEmptyString()]`; the approved verb `Test-`. PSScriptAnalyzer exits 0.

#### Error handling and logging

- The predicate is total and never throws; the call sites remain fail-fast as before.

---

## Test Quality Audit

Verification evidence is complete for behavior. Fail-before runs failed with the expected hard reason kinds (`path_overlap`, `shared_surface_overlap`, `contract_dependency`) in both Python and Pester, and pass-after runs succeeded. Isolation was checked with a seeded Jest shuffle, a reversed-order pytest run, and three seeded Pester file-order shuffles. The strict-identity pins re-ran unchanged. Coverage of changed lines is 100% in all three languages; the gaps are in artifact form and repo-wide reporting only.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_blast_radius_generic_contracts.py`: predicate rows (including non-ASCII look-alikes), all three Python sites, and the end-to-end scenario under both committed tables. It imports the module object so that collection succeeds pre-change and each row fails independently, which is good fail-before design.
- `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay_demote.py`: full demotion semantics, rejection with prior-bytes preservation through `DestinationMergeFileSystem`, the guard, and the AC-04 push-down against the committed bundled table. It uses in-memory file systems only.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1`: the Pester mirror, plus the stem parity test reading the Python source and the export checks.
- `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-demote.test.ts`: the TS mirror, including a non-mutation test.
- `tests/fixtures/blast_radius_overlay/shared-surfaces-demote*.json`: three corpus cases asserted identically by Python and TS.
- `evidence/regression-testing/fail-before.2026-10-31T08-11.md`: pre-change failure with the expected hard reasons.
- `evidence/regression-testing/isolation.2026-10-31T08-39.md`: order-independence checks.
- `evidence/qa-gates/strict-identity.2026-10-31T08-37.md`: strict-identity pins unchanged and passing.

### Quality assessment prompts

- **Determinism:** Fixed timestamps and in-memory file systems; no clock, RNG, or network.
- **Isolation:** One behavior per test; the parametrized rows identify the failing token or table.
- **Speed:** The new pytest file runs in well under one second; the full dev_tools suite runs in 52 s.
- **Diagnostics:** The scenario assertion reports every hard reason kind per edge, not only the first recorded reason.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | The diff contains no credentials, tokens, or keys. |
| No unsafe subprocess or command construction | PASS | No subprocess, `Invoke-Expression`, or shell construction added. |
| Input validation at boundaries | PASS | Overlay directive validated for type, member type, required target list, and known entries before any write. |
| Error handling remains explicit | PASS | Fail-closed `BlastRadiusOverlayError`; no broad catch added. |
| Configuration / path handling is safe | PASS | The forbidden-glob guard on `modules` is unchanged and tested alongside the directive; demotion never touches `modules`. |
| Regex safety | PASS | Patterns are anchored, have no nested quantifiers, and are built from a closed literal stem list. |

---

## Research Log

No external research was required. All decisions are grounded in the in-repo spec, research record, rule text, and the precedent of issue #903 for the ASCII guard.

---

## Verdict

The implementation is correct, minimal, and consistent across Python, PowerShell, and TypeScript. All toolchain stages pass, and fail-before, pass-after, isolation, and strict-identity evidence is recorded. The code needs no further change before merge. The two non-blocking Minor items (shared union helper, stale skill count) are suitable for the remediation cycle under the repository practice of resolving related findings inside the item.

The change is not yet ready for normal PR flow. The TypeScript coverage artifact must be produced with the lcov reporter and its per-file and repo-wide figures recorded. The repo-wide Python figure must be confirmed by the PR CI coverage-threshold step on the final head.
