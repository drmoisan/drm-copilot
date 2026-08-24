# Code Review: PR-Context ExpectedExitCode Evidence Key (#485)

**Review Date:** 2026-08-20
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the issue number (485) in the branch name.
**Base Branch:** `main` (merge base `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec`)
**Head Branch:** `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485` @ `a1a68417dec23a67be9bf07acd335efa8ff6cefb`
**Review Type:** Initial review

---

## Executive Summary

The branch fixes issue #485 by adding one optional, integer-valued evidence key `ExpectedExitCode` to the PR-context verification-evidence schema, in both members of the Python/TypeScript parity pair. Normalization is extracted into a pure two-argument helper per runtime and changed from "observed equals zero" to "observed equals declared expectation", with the default expectation `0` preserving every existing artifact's result. Each renderer gains one conditional row line shown only for a non-zero expectation. The change is small in production scope (four files, 110 added production lines, 2 deleted) and large in verification scope: 57 new Python tests, 22 new TypeScript tests, an eleven-shape cross-runtime parity fixture table transcribed into both suites, a corpus differential over 1293 artifacts proving zero rendered-row differences in both runtimes, and six byte-identical documentation copies.

**What changed:**
- `scripts/dev_tools/pr_context/verification_evidence.py` (+45/-1): new constant, defaulted dataclass field appended last, pure `normalize_result` helper, first-wins parse acceptance, non-integer-expectation unparseable path with uniform `exit_code=None` / `expected_exit_code=0` invariant.
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` (+56/-1): exact mirror, reusing the pre-existing `parseIntegerStrict`, with the addition written as a separate `if` so the pre-existing required-field block stays byte-identical.
- `scripts/dev_tools/pr_context/collector.py` (+4) and `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` (+5): one conditional `  - Expected EXIT_CODE: <int>` row between `EXIT_CODE` and `Normalized result`.
- Tests: two new Python modules (one a documented sibling of the over-limit `test_collect_pr_context_part4.py`); additions-only edits to the two existing TypeScript suites.
- Documentation: 13 identical lines added to all six copies of `evidence-and-timestamp-conventions/SKILL.md`.

**Top 3 risks:**
1. The deferred duplicate-required-key precedence divergence (Python last-wins, TypeScript first-wins) remains unfixed and now sits beside a correctly specified first-wins rule for the new key; until the follow-up bug is promoted and fixed, the two runtimes continue to disagree on 165+ existing artifacts (pre-existing, documented, out of scope here).
2. A mistyped expectation value silently removes the row from the PR body (unparseable records are dropped by both collector filters). This trade-off is documented in the schema docs and spec (risk R2) and is pinned by tests, but it remains an authoring hazard.
3. `collector.py` (623 lines) deepened its pre-existing over-limit state by 4 lines; the extraction debt is recorded but unscheduled.

**PR readiness recommendation:** **Conditional Go** — implementation and verification quality are high and no blocking defect was found; the conditions are pushing the head commit to origin and promoting the documented follow-up defect, neither of which requires changing this branch.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `spec.md` (AC10, AC17) | spec.md:488, spec.md:495 | Cross-runtime corpus parity criteria are PARTIAL: 5 content + 1 presence differences over the 641 single-`EXIT_CODE` artifacts, all caused by the pre-existing duplicate-required-key precedence divergence, which is wider than the multi-`EXIT_CODE` exclusion AC10 anticipated. | Promote the duplicate-REQUIRED-KEY precedence divergence as its own bug via the potential-to-issue path (already queued in `issue.md` Next Step) and widen the exclusion clause there. No code change on this branch. | The criteria as written cannot pass without a behavior change the spec prohibits (Invariant A, additive requirement). No difference touches an `EXIT_CODE`, `Normalized result`, or `Expected EXIT_CODE` row, so the parity of this change's own behavior is clean. | `evidence/other/additive-corpus-parity.2026-08-20T09-53.md`; spec.md "Delivered outcome (recorded 2026-08-20)" |
| Minor | `scripts/dev_tools/pr_context/collector.py` | whole file (623 lines) | Pre-existing 500-line-limit violation grew by 4 lines. | Schedule the extraction recorded in spec.md "Post-fix monitoring or clean-up tasks"; keep future additions in sibling modules as done here for tests. | Every addition to an over-limit file deepens a known violation; the spec capped growth at 5 lines (AC20) and the cap was honored. | `wc -l` = 623; `git diff --numstat 71aebdb9..HEAD -- scripts/dev_tools/pr_context/collector.py` = 4 added, 0 deleted |
| Minor | `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | lines 125-126 | The pre-existing comment "keeping only the first occurrence of each required schema field (mirrors the Python dict-first-write semantics)" is factually incorrect: Python's parse loop assigns unconditionally, so the last occurrence wins there. The branch deliberately left it untouched. | Correct the comment when the follow-up precedence bug converges the behavior; correcting it now without converging behavior would leave a comment describing a divergence rather than a contract. | A comment asserting parity that does not exist misleads maintainers of the parity pair; the research doc already records the claim as incorrect. | spec.md "Out of scope" section; research §2.3 |
| Info | `scripts/dev_tools/pr_context/verification_evidence.py`, `verification-evidence.ts` | `int()` vs `parseIntegerStrict` | Integer-grammar divergence class: Python `int()` accepts underscore separators (`1_0`) and non-ASCII digits that the TypeScript `^[+-]?\d+$` regex rejects, so an exotic expectation value could be parsed in one runtime and unparseable in the other. Pre-existing for `EXIT_CODE`; the new key inherits the same class symmetrically. | Note in the follow-up parity bug so both integer fields converge on one grammar in the same change. | Both fields go through the same per-runtime conversion, so no new asymmetry between fields was introduced; the corpus contains no such values today (AC11 grep). | `verification-evidence.ts:251-256`; Python `int()` semantics |
| Info | `artifacts/pr_context.summary.txt` | "Close candidates" section | The author-asserted autoclose list contains `#ISO-8601`, a token mis-parse (the collector matched a `#`-prefixed word from prose). Pre-existing collector behavior, not introduced by this branch. | Consider filing a small potential-entry for the autoclose token extractor to require numeric issue references. | Cosmetic today, but a mis-parsed autoclose assertion could reach a PR body. | `artifacts/pr_context.summary.txt` lines 33-36 |
| Info | branch state | n/a | Head commit `a1a68417` is not pushed: the branch is 1 commit ahead of `origin/bug/pr-context-verification-cannot-express-expected-nonzero-exit-485` (origin at `468dbe1e`). | Push before PR authoring. | The PR diff on GitHub would otherwise omit the entire fix commit. | `git status -sb` = `[ahead 1]`; `git rev-parse origin/<branch>` |
| Nit | `scripts/dev_tools/pr_context/collector.py` | line 158 | Python renderer gates the expectation row with integer truthiness (`if expected`), while the TypeScript renderer uses the explicit `expected === 0` comparison. Behaviorally identical for all integers. | Optionally align on the explicit comparison during the follow-up parity work for easier side-by-side review of the pair. | Parity-pair files are easiest to audit when structurally parallel; no functional impact. | diff hunks at `collector.py:156-158` and `collector-output.ts:116-119` |

No Blockers. One Major finding, which is an acceptance-criteria gap with a documented, out-of-branch remediation path rather than a code defect in this diff.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The optional key is accepted without touching `REQUIRED_FIELDS`, so the required-schema contract and every existing artifact's parse outcome are preserved by construction (AC12 verified: no changed line matches `REQUIRED_FIELDS`).
- Normalization is extracted into `normalize_result`, a pure, fully annotated two-argument function with a Google-style docstring including a Side Effects section — testable in isolation and exhaustively tested over a bounded integer range.
- The new dataclass field is appended last with a default (`expected_exit_code: int = 0`), avoiding breakage at every pre-existing construction site (sites enumerated in `evidence/baseline/record-construction-sites.2026-08-20T09-53.md`).
- The first-wins rule for the new key is implemented with an explicit `key not in parsed` guard and is deliberately distinct from the (pre-existing, divergent) required-key precedence, exactly as the spec's "Duplicate-key rule for the new key" requires.

#### Typing and API notes

- All new code is fully typed; no `Any`, no suppressions. The public surface grows by one constant, one helper function, and one defaulted record field.

#### Error handling and logging

- The expectation conversion catches exactly `ValueError` and converts to the documented `unparseable` record; every `unparseable` construction site uniformly sets `exit_code=None` and `expected_exit_code=0` (Invariant E), so downstream consumers see one canonical unparseable shape. No logging added (consistent with the module's `Side Effects: None` contract); the row-drop trade-off for typos is documented in the schema docs rather than hidden.

### TypeScript implementation audit

#### What changed well

- The mirror is faithful: same constant name modulo casing convention, same helper semantics, same defaulted-zero and unparseable invariants, and it reuses the existing `parseIntegerStrict` instead of introducing a second integer grammar.
- The parse-loop addition is a separate `if` with a comment explaining why (`else if` would have reflowed the pre-existing required-field block); the two conditions are provably mutually exclusive since `ExpectedExitCode` is not a required field.

#### Type safety and maintainability

- `readonly expectedExitCode: number` on the exported interface; `npm run typecheck` confirms every in-repo construction site was updated (spec risk R8 mitigation). No `eslint-disable` or `@ts-` suppression appears in the diff.

#### Error handling and logging

- A present but non-integer expectation returns the canonical unparseable record with `exitCode: null` and `expectedExitCode: 0`, byte-parallel to the Python paths.

---

## Test Quality Audit

Automated verification is comprehensive and was independently re-executed by this review: full Python suite (3995 passed, 5 pre-existing skips, 6.97s), full TypeScript suite (2580 passed, 185 suites, 3.30s), plus scoped format/lint/type-check runs, all clean in one pass. Coverage was re-derived from the LCOV artifacts rather than trusted from prose: repo-wide Python 92.45%/84.93%, TypeScript 96.62%/89.98%, and every uncovered line or branch in the four changed production files falls outside the changed hunks (changed-line coverage 100%).

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` — 54 cases covering default-absent equivalence (8 shapes), exhaustive default-path equivalence (-8..8 plus large magnitudes), pass/fail against non-zero expectations, non-integer and empty expectations, duplicate-key first-wins, `SKIPPED`, unrecognized rows, colon-bearing values, read-failure propagation, and the eleven-shape parity table. Execution quality is high; no gaps noted for the changed behavior.
- `tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py` — 3 renderer cases (non-zero renders; omitted and explicit-zero omit) via the in-memory `mem_fs_path` fixture; the single-line `reportPrivateUsage` suppression for the module-private renderer is justified in the docstring with repository precedent cited.
- `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts`, `collector-output.test.ts` — 22 added cases mirroring the Python set including `it.each(shapeCases)`; `git diff --numstat` confirms additions only (237+0, 62+0), satisfying the existing-tests-unmodified invariant (AC25).
- `evidence/other/additive-corpus-parity.2026-08-20T09-53.md` — proves Invariant A empirically: 1293 artifacts discovered, 0 rendered-row differences pre-vs-post in both runtimes; records the resolved module paths inside this worktree, ruling out a wrong-checkout measurement; records the 165 multi-`EXIT_CODE` exclusions and the 6 residual differences with attribution.
- `evidence/qa-gates/coverage-delta.2026-08-20T09-53.md` — baseline/post/new-code coverage tables; figures independently reproduced by this review from the LCOV artifacts.

### Quality assessment prompts

- **Determinism:** No wall-clock, randomness, timers, network, or temporary files; grep across the new/changed test files for banned APIs returns only a docstring mention of `tmp_path` stating it is never used.
- **Isolation:** One behavior per test; parametrization isolates input shapes with self-describing IDs.
- **Speed:** Targeted suites run in under half a second; full suites in seconds.
- **Diagnostics:** Whole-record and whole-string assertions print both sides on failure; parametrized IDs identify the failing shape without reading the test body.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: parsing/rendering logic and test fixtures only; no credentials, tokens, or endpoints. |
| No unsafe subprocess or command construction | PASS | No subprocess use added; the parser module retains its `Side Effects: None` contract. |
| Input validation at boundaries | PASS | Strict integer grammar on the TypeScript side (`^[+-]?\d+$`); Python catches `ValueError` from `int()`; malformed input degrades to the canonical `unparseable` record rather than throwing. |
| Error handling remains explicit | PASS | Exactly one exception type caught; no broad handlers; read failures still propagate (pinned by `test_parse_verification_evidence_file_propagates_read_failure`). |
| Configuration / path handling is safe | PASS | `CANONICAL_GLOBS` unchanged; no coverage-config change (`pyproject.toml` and Jest config untouched in the diff); no new filesystem paths. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff, the feature folder's research/spec/plan/evidence artifacts, the repository policy rules, direct re-execution of the toolchain, and direct re-parsing of the LCOV coverage artifacts.

---

## Verdict

The implementation is a disciplined, additive parity-pair change: minimal production diff, invariants stated and pinned by tests, cross-runtime behavior verified both by transcribed fixture tables and by a whole-corpus differential, and documentation fanned out through the push-down contract. No blocking defect was found in the diff. The one Major item (AC10/AC17 PARTIAL) is caused by a pre-existing runtime divergence that this branch correctly declined to fix, and its remediation path — promoting the duplicate-required-key precedence defect as its own bug — is already queued and is captured in `remediation-inputs.2026-08-20T11-33.md`. Recommendation: **Conditional Go** for normal PR flow after pushing head `a1a68417` to origin; the follow-up promotion does not block this merge.
