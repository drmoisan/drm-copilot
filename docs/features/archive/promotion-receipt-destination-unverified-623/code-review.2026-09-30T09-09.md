# Code Review: promotion-receipt-destination-unverified (#623)

---

**Review Date:** 2026-09-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/promotion-receipt-destination-unverified-623`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue #623 in the branch name.
**Base Branch:** `main` (`origin/main` at `6e6ccd62792e0838bee7459a2b468de83ad5d408`; merge-base identical)
**Head Branch:** `bug/promotion-receipt-destination-unverified-623` at `2597e26d78b11eb03be0ad13c750360bd7793443`
**Review Type:** Initial review

---

## Executive Summary

The branch closes a structural gap in the potential-to-issue promotion workflow: neither the TypeScript `promotePotential` nor the Python parity `promote_potential` verified that the destination file existed after the move, so a move that removed the source without producing the destination was reported as success. Both workflows now query the injected filesystem's existing `exists` member immediately after `move`; on absence they emit `Promoted file missing after move: <dest>` and return exit code 1 with no destination. The non-zero outcome (rather than a thrown error) routes through the service-call layer's existing non-zero path, so the MCP caller receives every emitted line, including the created issue URL. The Python `FileSystem` Protocol and `RealFileSystem` adapter were moved verbatim to `scripts/dev_tools/potential_to_issue_filesystem.py` and re-exported, which keeps the oversized `potential_to_issue.py` from growing (639 to 559 lines).

The production delta is small (7 added TS lines, 3 added Python lines, one extracted module of 101 lines, one Jest threshold entry). Evidence reviewed: the full branch diff, the PR context summary and appendix (fresh at HEAD `2597e26d`), 49 feature evidence files, the two lcov artifacts (parsed by the reviewer), and reviewer re-runs of Black check, Ruff, Pyright, Prettier check, ESLint, TSC, and the targeted Pytest and Jest suites. Implementation quality is high: the change is minimal, mirrored exactly across languages, regression-tested with recorded fail-before runs, and leaves the #487 receipt guard untouched with its true branch still covered.

**What changed:**
- `promotion.ts:443-446`: post-move `if (!filesystem.exists(destPath))` branch returning `{ exitCode: 1, messages }`; `PromotionOutcome.exitCode` doc updated.
- `potential_to_issue.py:469-471`: mirrored branch returning `PromotionOutcome(exit_code=1, messages=messages)`; filesystem classes removed and imported from the new module; unused `Iterable` import dropped.
- `potential_to_issue_filesystem.py`: new module holding the moved classes.
- `jest.config.cjs`: per-file threshold (85/75) for `promotion.ts`.
- Tests: new TS `promotion.move-verification.test.ts` (2 tests); new service-call test; `BlockedPathPotentialFileSystem` replaced by `LateBlockedPathPotentialFileSystem`; new `DroppingMovePotentialFileSystem`; new Python move-verification tests (3) and filesystem adapter tests (8).

**Top 3 risks:**
1. The GitHub issue is created before the move, so a missing-destination failure leaves an issue with no promoted record. This is a documented residual in `spec.md`; the error message now carries the issue URL so the caller can reconcile it.
2. The fix is defense in depth at the move site; the TaskMaster #554 instance is most likely attributable to the already-fixed #487 defect, which is unproven. External removal after the receipt is built (research C6) remains undetectable.
3. `LateBlockedPathPotentialFileSystem` depends on the workflow issuing exactly one `exists` query for the destination before the receipt guard. A future workflow change that adds another destination query would make the guard test fail at the workflow layer instead of the guard; the failure would be visible, not silent.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; all toolchain stages and coverage thresholds pass, and every acceptance criterion is verified.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py` | lines 207-235, `test_file_system_protocol_members_declare_no_behavior` | Executor deviation from plan P5-T3 ("exactly seven tests"). The eighth test calls each `FileSystem` Protocol member through the Protocol class on a `RealFileSystem` receiver and asserts each returns None. It exists to take the seven `->exit` arcs of one-line Protocol stubs, which moved the new module from 7/14 (50.00%) to 14/14 branches. It verifies a language property of Protocol placeholder bodies rather than product behavior. | Accept for this PR. Open a follow-up to treat one-line Protocol stubs repository-wide in coverage measurement (the current `exclude_lines` pattern `^\s*\.\.\.\s*$` cannot match Black's `def f(...) -> T: ...` form), after which this test can be removed. The same uncovered arcs exist at `potential_to_issue.py` 82-88 (`GhClient`) and in the other `FileSystem` Protocols under `scripts/dev_tools/`. | Evaluated on merits: no I/O, no suppression pragma, no coverage-config change outside the blast radius, deterministic, documented, and the arcs it covers are real code objects in the file. The alternatives available inside the plan's blast radius were a `# pragma: no cover` suppression (lower integrity) or leaving the new module below the 75% branch threshold (a gate failure). The cost is one low-value test; the benefit is an honest metric without suppression. | `evidence/qa-gates/py-test-coverage-pass1-failed.2026-09-30T08-46.md`; `evidence/qa-gates/py-test-coverage.2026-09-30T08-54.md`; `pyproject.toml` lines 129-140; baseline term-missing `216->exit` through `228->exit` |
| Minor | `docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md` | line 7 (header); line 228 (P5-T3) | P5-T3 is checked, but its acceptance line (`grep -c -E "^def test_"` prints 7) no longer holds at HEAD (8). The header status still reads "Draft (revision 1.2 ... pending validator and executor preflight round 3)" although preflight cleared and all 77 tasks are checked. | When archiving the feature, annotate P5-T3 with the deviation and a pointer to the pass-1 evidence, and update the header status. No code change is needed. | A checked task whose stated acceptance is false at HEAD can mislead a later reconciliation pass. | `grep -n "P5-T3"` and line 7 of the plan; `evidence/qa-gates/test-isolation.2026-09-30T08-56.md` (records the eighth test) |
| Nit | `scripts/dev_tools/potential_to_issue.py` | lines 196-218 (`PromotionOutcome` docstring); line 469 | The TS side documents the new exit-code meaning (`promotion.ts:88`) and explains the non-zero-over-throw choice (`promotion.ts:440-442`). The Python mirror has neither the docstring update nor the rationale comment. | Add a one-line note to the Python `PromotionOutcome` docstring (exit code 1 when the promoted file is missing after the move) and a brief rationale comment above line 469. | Parity of documentation helps maintainers keep the two declared-parity sources aligned. | `git diff 6e6ccd62...HEAD -- scripts/dev_tools/` |
| Info | `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts` | lines 89-120 | `LateBlockedPathPotentialFileSystem` answers true on the first destination query and false afterward, coupling the guard test to the number of workflow-side `exists` queries. The coupling is documented in the class docstring. | No change required. | Documented and fails visibly if the query count changes. | File inspection; reviewer Jest run (118 passed) |
| Info | `scripts/dev_tools/potential_to_issue.py` | whole file (559 lines) | File exceeds the 500-line limit. Pre-existing (639 at merge-base), reduced by 80 lines here, owned by #406, and excluded from scope by `spec.md`. | None for this PR; #406 continues to own it. | Tracked pre-existing exception; this branch improves it. | `evidence/qa-gates/py-line-count.2026-09-30T08-56.md`; reviewer line count via `git show` |
| Info | `scripts/dev_tools/validate_policy_audit_artifact.py` | lines 59-68 (`PLACEHOLDER_MARKERS`) | The placeholder guard matches the substring `unverified` anywhere in a checklist or comparison line, so any evidence path under this feature folder (slug `promotion-receipt-destination-unverified-623`) is rejected as a placeholder. The policy audit uses a defined `<FEATURE>` prefix to pass. | Consider a potential entry to match placeholder markers as bracketed or whole-word tokens rather than raw substrings. Not in scope for #623. | A validator false positive that depends on a feature slug can block review artifacts for unrelated reasons. | Reviewer validator run before and after the prefix change |
| Info | `artifacts/pr_context.summary.txt` | "Verification evidence" section | The PR context classifies `py-test-coverage-pass1-failed.2026-09-30T08-46.md` as `Normalized result: pass` because its recorded `EXIT_CODE` is 0, although the artifact records a failed coverage criterion. | None for this PR; readers should rely on the artifact body. | Classification is exit-code based and does not read criterion outcomes. | PR context summary lines 535-540 |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The post-move check is three lines placed exactly where the TS check is, with byte-identical message text (`git grep -n -F "Promoted file missing after move: "` returns one match in each language).
- The extraction is verbatim (docstrings preserved) and re-exported by a plain import, so `mod.FileSystem` subclassing in existing tests continues to work; `test_filesystem_names_are_reexported` asserts object identity.
- The previously uncovered `RealFileSystem` methods (baseline lines 255-275 uncovered) are now covered by monkeypatch-only tests.

#### Typing and API notes

- No new public API. `FileSystem` gains no members. Pyright strict reports 0 errors. The `Iterable` import moved under `TYPE_CHECKING` in the new module, consistent with `from __future__ import annotations`.

#### Error handling and logging

- A missing destination produces a non-zero `PromotionOutcome`; `main()` exits with that code, so the Python CLI now reports failure. A raising `move` still propagates unchanged. No source restoration is attempted, as specified.

### TypeScript implementation audit

#### What changed well

- The branch reuses `emitLine` and the shared `messages` array, so the service-call's existing non-zero path surfaces `Command exited with code 1.` with all emitted lines; the new service-call test asserts this end to end.
- The #487 receipt guard in `potential-to-issue-service-call.ts` is unchanged (`git diff` empty) and its true branch remains covered (`BRDA:222,13,0,2`; lines 223-226 hit 2 times).
- A per-file Jest threshold now protects `promotion.ts` at 85/75, added only after measured coverage met it.

#### Type safety and maintainability

- No `any`, casts, or suppressions. The new service-call test narrows `unknown` with `instanceof Error`. `promotion.test.ts` (near 500 lines) was not extended; the new cases live in a separate file.

#### Error handling and logging

- Failure is reported through the return value, not an exception, preserving the created issue URL for the caller. The explanatory comment at `promotion.ts:440-442` states why.

---

## Test Quality Audit

Fail-before evidence exists for both languages and for the service-call guard test: the new negative tests failed against the unchanged production files (TS `exitCode` 0 where 1 was expected; Python `assert 0 == 1`), and the service-call guard test failed once the workflow check existed without the late-blocked fake. Pass-after runs and full-suite runs are recorded. The reviewer re-ran the targeted suites at HEAD: 60 Python tests and 118 Jest tests passed.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/potential-to-issue/promotion.move-verification.test.ts` — negative and positive control for the TS branch; asserts exit code, destination, last message, issue URL presence, and absence of the "Moved" line.
- `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` — guard test retargeted to `LateBlockedPathPotentialFileSystem` with original assertions intact; new test verifies the surfaced error content.
- `tests/scripts/dev_tools/test_potential_to_issue_move_verification.py` — Python mirror of the two workflow cases plus re-export identity.
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py` — one monkeypatch test per `RealFileSystem` method plus the Protocol placeholder test (see Findings).
- `evidence/regression-testing/*-fail-before.2026-09-30T08-35.md` — recorded failing runs against unchanged production code.
- `evidence/qa-gates/py-coverage-delta.2026-09-30T08-55.md`, `ts-coverage-delta.2026-09-30T08-55.md` — per-file baseline versus post-change deltas; matched by the reviewer's lcov parse.

### Quality assessment prompts

- **Determinism:** in-memory fakes and monkeypatch only; no clock, RNG, network, subprocess, or disk.
- **Isolation:** one behavior per test except the Protocol placeholder test, which covers seven stubs in one assertion.
- **Speed:** 60 Python tests in 0.90 s; Jest promotion suites complete within the normal run.
- **Diagnostics:** exact-value assertions print actual versus expected outcomes; the recorded fail-before output shows the full `PromotionOutcome`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; only test URLs (`https://example.com/issues/123`). |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess code changed. |
| Input validation at boundaries | ✅ PASS | The new check validates the filesystem post-condition at the move boundary. |
| Error handling remains explicit | ✅ PASS | Explicit non-zero outcome with a specific message; no broad catches added. |
| Configuration / path handling is safe | ✅ PASS | Destination path construction unchanged; Jest config adds a threshold only, no `exclude` entry. |
| Scope confined to spec | ✅ PASS | No changes under `extensions/drm-copilot/src/lib/new-active-feature-folder/`, `extensions/drm-copilot/resources/`, or `.claude/skills/feature-promotion-lifecycle/` (reviewer check). |

---

## Research Log

No external research was required. The feature folder's research record (`research/2026-09-29T19-15-promotion-destination-verification-research.md`) and the #487 completed-feature artifacts were read through the spec's citations; code claims were verified by direct inspection of the diff and the current source.

---

## Verdict

The change is ready for normal PR flow. It implements the specified Approach A exactly in both languages, keeps message and branch parity, preserves the #487 guard and its coverage, and improves the Python module's size and coverage. The eighth filesystem test is a coverage-motivated plan deviation that is acceptable on its merits for this PR; the underlying measurement issue with one-line Protocol stubs is repository-wide and is better addressed by a separate follow-up than by suppressions in this branch.

The remaining findings are Minor, Nit, or Info and do not block merge: a stale plan header and P5-T3 acceptance text, a Python docstring and comment parity gap, and two tooling observations outside this feature's scope.
