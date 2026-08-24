# Code Review: Promotion Lifecycle Promoted-Record Retention (#487)

**Review Date:** 2026-08-20
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487`
**Feature Folder Selection Rule:** Folder suffix matches the issue number in the branch name (`bug/promotion-lifecycle-loses-promoted-record-487`); it is the only active folder with material scoping-doc changes on this branch.
**Base Branch:** `origin/main` @ `cd4b887f4e56606a7aca4bd02e093829b33bf8db`
**Head Branch:** `bug/promotion-lifecycle-loses-promoted-record-487` @ `6f7f864b`
**Review Type:** Initial review

---

## Executive Summary

This branch fixes the promoted-record loss defect in the promotion lifecycle. `new_active_feature_folder` previously performed an unconditional `filesystem.move` of the resolved potential file into `<targetDir>/issue.md` at both of its work-mode placement sites, which destroyed the promoted archive record whenever the source had already been moved to `docs/features/potential/promoted/` by `potential_to_issue`. The fix computes a single disposition decision from the resolved source path (`retainsPotentialSource` / `retains_potential_source`), copies when the source is under the promoted root, moves otherwise, and reports the actual disposition in the emitted line. Both MCP service-call layers additionally gained an existence post-condition so a receipt can no longer report a filesystem path that is absent on disk.

Evidence reviewed: the full `git diff origin/main...HEAD` (68 files), the regenerated PR-context summary/appendix, all 48 evidence artifacts, both lcov coverage artifacts (parsed independently), and reviewer re-runs of the five changed Jest suites (37/37 pass) and three changed pytest modules (28/28 pass). Implementation quality is high: the change is minimal, symmetric across both language implementations, documented with why-comments, and backed by a fail-before regression demonstrating that all seven new failing tests were capable of failing.

**What changed:**
Four production files (2 flow implementations, 2 service-call helpers), eight test files (three new), five documentation/skill files including the byte-identical bundle mirror, plus feature-folder scoping docs and canonical evidence.

**Top 3 risks:**
1. The 85/75 per-file coverage gate for the four changed production files is asserted by hand in evidence, not enforced by the runner — a future coverage regression in these files will not fail CI (finding CR-1).
2. TS/Python parity is maintained by convention and inspection only; no automated test exercises the two flows against a shared fixture, so the implementations can drift silently (finding CR-3).
3. The receipt post-condition depends on the hoisted-filesystem pattern; a future contributor reintroducing an inline `new RealFolderFileSystem()` at the call site would silently decouple the assertion from the workflow's filesystem in tests (mitigated by the comments and by the negative-arm tests, which would fail).

**PR readiness recommendation:** **Go** — zero Blocker or Major findings; all gates pass with independently verified evidence.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `extensions/drm-copilot/jest.config.cjs` | `coverageThreshold` block (line 25 onward) | No per-file threshold entry exists for `flow.ts`, `new-active-feature-folder-service-call.ts`, or `potential-to-issue-service-call.ts`, so the 85/75 gate for this feature's changed files is asserted manually in `evidence/qa-gates/coverage-delta.2026-08-20T20-44.md` rather than enforced by the runner. The repo's own config comment documents the issue-#305 per-changed-file pattern. | Add three per-file `coverageThreshold` entries in a follow-up change (non-gating for this PR; the executor recorded the gap transparently and this reviewer verified every figure independently from `lcov.info`). | Without runner enforcement, a future regression in these files passes CI silently. | `grep` of `jest.config.cjs` for the three file names returns no matches; independent lcov parse confirms all thresholds currently met with margin (narrowest: 83.33% branch vs 75%). |
| Minor | `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/` | filename timestamps | Evidence filename timestamps run roughly 50-65 minutes ahead of the files' mtimes (e.g., `final-ts-jest-coverage.2026-08-20T20-24.md` has mtime 19:28 -0400). | None required; the evidence set's internal ordering is self-consistent and the lcov artifacts (mtimes 19:35/19:38) postdate the fix commit `ecfb64d3` (19:19) and match branch-head file shapes, so anchoring to the reviewed code state is confirmed by content, not by clock. | A reader comparing filename timestamps to commit times could question evidence freshness; recording the discrepancy pre-empts that. | `stat` of evidence files vs `git log --format=%ci`; `flow.ts` LF=492 in lcov equals the post-change line count. |
| Info | `tests/scripts/dev_tools/test_new_active_feature_folder.py` | whole file (533 lines) | File exceeds the 500-line limit, but it was already 533 lines on `origin/main`; this branch's edit is a net-zero two-line inversion/rename, and all new Python tests were placed in the new 151-line `_part5` module. | Track the pre-existing over-limit file separately (alongside the already-tracked `potential_to_issue.py` at 639 lines); no action in this PR. | Pre-existing condition, not worsened; the executor followed the correct split convention for new content. | `git show origin/main:...` line count 533 = current 533. |
| Info | `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts` | whole file (500 lines) | The one-line retention assertion brought the file from 499 to exactly 500 lines — at, not over, the limit ("may not exceed 500 lines"). | Any future addition to this suite must go to a sibling file; `flow.promoted-disposition.test.ts` already establishes the pattern. | Zero headroom remains. | `wc -l` = 500; base = 499. |
| Nit | `tests/scripts/dev_tools/test_new_active_feature_folder_part5.py` | n/a | Python has no analogue of the TS sibling-prefix boundary test (`promoted-notes-feature.md` proving the containment predicate requires a `<root>/` boundary). Risk is low because `Path.relative_to` is exact containment by construction, unlike a string `startsWith`. | Optionally add the boundary case for cross-language test parity. | The TS predicate needed the test because `startsWith(root)` without the `/` boundary is a plausible wrong implementation; Python's `relative_to` cannot exhibit that defect. | `flow.promoted-disposition.test.ts` third case; `new_active_feature_folder_flow.py:57-62`. |

No Blockers or Major findings.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- **Decide-once disposition.** `retainsPotentialSource` is computed a single time from the resolved source path, immediately after discovery, so the two placement sites and the two emission sites cannot disagree. The comment states this rationale explicitly.
- **Correct containment predicate.** `isPromotedPotentialSource` delegates to the existing `isRelativeTo`, which normalizes to POSIX and requires equality or a `<root>/` prefix — so `docs/features/potential/promoted-notes.md` (a string prefix of the promoted root) correctly takes the move branch. This exact adversarial case is unit-tested with `startsWith` preconditions proving the fixture discriminates.
- **MOVE invariant preserved.** The predicate matches only paths under `docs/features/potential/promoted`; a source directly under `docs/features/potential/` cannot match (its next segment is a filename, not `promoted/`), so unpromoted sources still move. Verified by predicate reading, by the unmodified existing `flow.test.ts` move case, and by the sibling-prefix test.
- **Post-condition at the correct layer.** The existence assertions live in the service-call layer, not the workflow layer, honoring the byte-parity constraint with the receipt-less Python CLI (spec INV-6). The filesystem instance is hoisted so the assertion observes the same seam the workflow wrote through — which is precisely what makes the negative arm testable with `Map`-backed fakes.
- **Receipt scope is exact.** `new_active_feature_folder` checks `result.target` (becomes `destinationPath`) and non-null `result.potentialIssuePath` (becomes the only `artifacts` entry) — full coverage of every reported filesystem path. `potential_to_issue` checks `outcome.destination` only; its `artifacts` entry is a GitHub issue URL and is deliberately excluded with a comment saying so. Confirmed by reading the return-record construction: no URL is ever passed to `exists`.

#### Type safety and maintainability

- No `any`, no non-null assertions, no suppressions anywhere in the diff. The new helper and the test fakes are fully typed; test subclass overrides use the `override` keyword.
- No public API change: both result-record interfaces are unchanged; the new functions are module-private.

#### Error handling and logging

- Post-condition failures `throw new Error` with messages naming the tool and the absent path (`new_active_feature_folder reported a path that does not exist: <path>`), which `toFailureToolResult` renders as `ok: false` with the message as `summary`. No silent degradation or warning-only path exists, per the spec's explicit prohibition.
- The emitted line now states the operation actually performed (`Copied ...` vs `Moved ...`), removing the misleading log line that contributed to the five-observation misattribution.

### Python implementation audit

#### What changed well

- Faithful parity mirror: same decide-once structure, same two placement sites, same two emission sites, byte-identical emitted wording (`Copied potential file to {path}` / `Moved potential file to {path}`), verified side-by-side against the TS diff.
- `_is_promoted_potential_source` uses `Path.relative_to` inside a narrow `try/except ValueError` — the idiomatic exact-containment check, immune to the string-prefix defect by construction.

#### Typing and API notes

- Full annotations (`Path`, `bool`); Google-style docstring with Args/Returns; pyright reports 0 errors / 0 warnings / 0 informations on the final pass. No new public Python API surface was added.

#### Error handling and logging

- The receipt assertion is deliberately not mirrored because the Python CLI emits no receipt (spec INV-6); this asymmetry is documented in the spec and in AC-9. The `print`-based stdout contract is pre-existing and only its wording branch was extended.

---

## Test Quality Audit

The verification evidence is complete on all three axes required for a bug fix: fail-before demonstration, both-arms branch coverage, and cross-call sequence coverage.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts` — both placement sites' copy arms, content byte-identity, disposition-accurate emission, and the sibling-prefix boundary negative. Hermetic, AAA, fixed clock. No gaps.
- `extensions/drm-copilot/test/lib/promotion-lifecycle-sequence.test.ts` — the two-call lifecycle against one shared in-memory filesystem implementing both cluster seams, with intermediate-state assertions so a failure is unambiguous. This is the coverage whose absence let the defect persist across six observations.
- `extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` and `.../potential-to-issue-service-call.test.ts` — both arms of both post-conditions via `BlockedPath*` fakes that fail `exists` for exactly one designated path; thrown messages asserted to contain tool name and path; success arms assert the enriched records (including that the issue-URL artifact passes without an existence check).
- `tests/scripts/dev_tools/test_new_active_feature_folder_part5.py` — Python parity: unpromoted move, full-mode copy, minor-audit copy, all with emitted-wording assertions via `capsys`.
- `evidence/regression-testing/fail-before-ts-jest.2026-08-20T19-16.md` and `fail-before-py-pytest.2026-08-20T19-16.md` — seven TS tests and the Python inversions failing pre-fix with per-test assertion diagnostics; proves every new gate was capable of failing. The exception dossier for the two success-arm tests that pass pre-fix is recorded (`fail-before-exception-not-required.2026-08-20T19-16.md`).
- `evidence/qa-gates/coverage-delta.2026-08-20T20-44.md` — per-file and changed-line coverage; every figure re-derived independently by this reviewer from the lcov artifacts and confirmed exact (including the uncovered-line sets {388, 389} and {117, 322, 399-416}).
- `evidence/qa-gates/final-qc-loop-ledger.2026-08-20T20-42.md` — per-iteration toolchain ledger with numeric exit codes; notable for treating a zero-exit-code changed-line coverage regression (iteration 3) as blocking and restarting the loop, which is the policy-correct behavior.

### Quality assessment prompts

- **Determinism:** Fixed `nowProvider`/`datetime`, injected `GhClient`/`CommandRunner` fakes, `Map`-backed filesystems; no wall clock, timers, network, or temporary files in any changed test.
- **Isolation:** One disposition arm or post-condition arm per test; fail-before evidence shows failures identify the exact placement site.
- **Speed:** Reviewer re-runs: 37 Jest tests in 0.57 s, 28 pytest tests in 0.14 s.
- **Diagnostics:** `Expected: true, Received: false` on a named promoted path; `Received function did not throw` on a named tool — both demonstrated in the fail-before capture.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no credentials, tokens, or `.env` content anywhere in the 68 changed files. |
| No unsafe subprocess or command construction | ✅ PASS | No new subprocess invocation; the `gh` seam is unchanged and injected. |
| Input validation at boundaries | ✅ PASS | The disposition decision is taken from the resolved source path at placement time, never from the requested feature name; containment requires a normalized `<root>/` boundary. |
| Error handling remains explicit | ✅ PASS | Post-conditions throw with tool + path; the only `except` added is a narrow `ValueError` from `Path.relative_to`. |
| Configuration / path handling is safe | ✅ PASS | POSIX-normalized joins via existing `joinPosix`/`toPosixPath`; Windows-rooted paths handled by `isAbsolutePosix`; no user-controlled path concatenation added. |

---

## Research Log

No external research was required. All findings derive from the branch diff, the repository's policy rules, the feature-folder artifacts, the lcov coverage artifacts, and reviewer-executed commands (targeted Jest/pytest runs, lcov parsing, plan and evidence-location validators, PR-context regeneration).

---

## Verdict

The change is ready for normal PR flow. It is a minimal, well-factored fix with symmetric implementations in both languages, complete both-arms test coverage including the sequenced lifecycle regression that was structurally missing, a demonstrated fail-before baseline, and independently verified coverage above every uniform threshold. The Findings Table contains two Minor, two Info, and one Nit finding; none blocks merge. The single recommended follow-up is adding per-file Jest `coverageThreshold` entries for the three changed TypeScript production files so the gate this branch satisfies by evidence becomes runner-enforced going forward.
