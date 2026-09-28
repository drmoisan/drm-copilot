# Feature Audit: PR-context gh detection false negative (#588)

---

**Audit Date:** 2026-09-26
**Feature Folder:** `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588`
**Base Branch:** `origin/main`
**Head Branch:** `bug/pr-context-gh-detection-false-negative-588`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `b67453837646fd2dd4f5ac692f76e6f7703fe798`, merge commit of PR #703 for sibling #622)
- **Head branch/commit:** `bug/pr-context-gh-detection-false-negative-588` (commit `51f852dc807308d645486960fea2e73edaae8ca3`)
- **Merge base:** `b67453837646fd2dd4f5ac692f76e6f7703fe798` (equals the execution-time sync SHA recorded in `evidence/baseline/branch-and-sync.2026-09-25T22-06.md`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (head SHA `51f852dc`, generated 2026-09-27 01:31:40 UTC; fresh)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff origin/main...HEAD`
  - Feature evidence: `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/evidence/**` (42 files)
  - Additional evidence: reviewer reruns of tsc, ESLint, Prettier, Jest (9 suites, 97 tests), Black, Ruff, Pyright, Pytest (10 tests); reviewer parse of `extensions/drm-copilot/coverage/lcov.info` and `artifacts/python/lcov.info`
- **Feature folder used:** `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: full-bug`, so `spec.md` `## Acceptance Criteria` is the sole AC source.
- **Scope note:** Sibling #622 merged first (ORDER: 622-MERGED). #622 owns autoclose derivation, relocation into `autoclose.ts`, non-empty rendering, and the `Unverified: ...` annotation line; #588 builds on it per spec D8-D13, which the operator approved on 2026-09-26. The PR-context summary was produced by the published pre-fix MCP build and therefore still reports `GitHub CLI unavailable`; this is expected until release (spec Rollout) and is not evidence against the fix.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/spec.md` — only source

### Acceptance criteria

1. `resolveExecutableOnPath` with `platform: "win32"`, a Windows-style `pathValue` and `pathExtValue: ".COM;.EXE;.BAT;.CMD"`, and an injected `exists` containing only `<dir>\gh.exe` returns that `gh.exe` path for `name: "gh"`, verified by a test in `extensions/drm-copilot/test/lib/executable-resolver.test.ts`.
2. `resolveExecutableOnPath` on `win32` matches PATHEXT extensions case-insensitively (for example PATHEXT `.exe` or a name `gh.EXE` resolves against an existing `gh.exe`), verified by a test.
3. `resolveExecutableOnPath` with `platform: "linux"` returns `<dir>/gh` for the first PATH directory where `exists` is true, ignores PATHEXT, and returns the earlier directory's match when multiple directories contain `gh`, verified by tests.
4. `resolveExecutableOnPath` returns `undefined` when no candidate exists, verified by a test.
5. `resolveExecutableOnPath` returns `undefined` for an empty or undefined `pathValue` and skips empty PATH entries without error, verified by tests.
6. `defaultWhichGh` delegates to `resolveExecutableOnPath` using `process.env.PATH`, `process.env.PATHEXT`, `process.platform`, and `fs.existsSync`, verified by a test that controls those inputs through mocks without touching the real filesystem.
7. `collectPrContextServiceCall` accepts an optional `whichGh` and defaults it to `defaultWhichGh`; with an injected resolvable `gh` and a fake runner answering `auth status` and `repo view`, the runner receives the resolved path with `auth status` and the summary contains `GitHub CLI authenticated for <owner/repo>`. The test fails on the pre-fix code.
8. The composition-root test in `extensions/drm-copilot/test/extension.collect-pr-context-gh-resolution.test.ts` (a sibling of `extension.collect-pr-context.test.ts`, per D12), with a POSIX `PATH` and mocked `existsSync`, asserts that mocked `spawnSync` receives the resolved `gh` path with `auth status`. The test fails on the pre-fix code.
9. `GhClient`'s library default resolver remains `() => undefined`, and existing service-call tests inject `whichGh` explicitly so their code path does not depend on the host PATH.
10. In the TypeScript port, when `gh` is unavailable and the autoclose list is empty, the `Issues to autoclose (verified or pending)` body is exactly `None (GitHub CLI unavailable; closing issues not verified)`, verified by tests in `render-pr-helpers.test.ts` and `collector-core.test.ts`.
11. In the Python collector, when `gh` is unavailable and the autoclose list is empty, the same section body is exactly `None (GitHub CLI unavailable; closing issues not verified)`, verified by a Python unit test for `render_pr_helpers.py` and the offline scenario in `tests/scripts/dev_tools/test_pr_context_integration.py`.
12. When `gh` is available, the empty-body texts `None (no verified closing issues and readiness not PASS)` and `None (no verified closing issues and no deterministic pending issue)` are unchanged in both runtimes, verified by existing and new tests.
13. Relative to the execution-time sync SHA (D9): the not-installed, not-authenticated, and repository-unresolved status messages are unchanged; `gh-client-core.ts` and `github.py` have no diff; #588's diff does not modify the #622-owned derivation code or non-empty rendering branches; and with `gh` unavailable and a non-empty list, the bulleted entries are rendered and the empty-list unavailable body is not emitted (D11), verified by tests in both runtimes.
14. New and touched TypeScript production files meet line coverage >= 85% and branch coverage >= 75%, and `extensions/drm-copilot/jest.config.cjs` contains exactly one per-file `coverageThreshold` entry each for `./src/lib/executable-resolver.ts`, `./src/lib/pr-context/render-pr-helpers.ts`, and, when the TypeScript builder is defined in `./src/lib/pr-context/autoclose.ts`, that file (an entry already supplied by #622 satisfies this).
15. Touched Python production files under `scripts/dev_tools/pr_context` meet line coverage >= 85% and branch coverage >= 75%, measured with `--cov=scripts.dev_tools.pr_context`.
16. All new and modified tests run on Linux CI and do not depend on remote refs (including `origin/main`; CI uses a depth-1 checkout), gitignored state, a real `gh` binary, network access, temporary files, or Windows drive roots/paths.
17. No touched production or test file exceeds 500 lines.
18. The full TypeScript toolchain loop (Prettier, ESLint, `tsc`, dependency-cruiser, Jest) and the full Python toolchain loop (Black, Ruff, Pyright, Pytest) complete clean in a single pass.
19. The D5 `.cmd`/`.bat` spawn limitation is documented in the resolver module's documentation comment.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | win32 PATHEXT resolves `<dir>\gh.exe` | PASS | R1 in `executable-resolver.test.ts` (lines 40-58): PATH `\tools\bin;\apps\GitHub CLI`, PATHEXT `.COM;.EXE;.BAT;.CMD`, `exists` holding only `\apps\github cli\gh.exe`; asserts result `\apps\GitHub CLI\gh.EXE` and its lower-cased equality with the gh.exe path. | `npm --prefix extensions/drm-copilot test -- executable-resolver` (pass) | The returned string carries PATHEXT casing (`.EXE`); it names the same file on a case-insensitive Windows filesystem (code-review CR-8). |
| 2 | win32 PATHEXT case-insensitive | PASS | R2 (PATHEXT `.exe` vs `gh.exe`) and R3 (name `gh.EXE`, PATHEXT `.exe;.cmd`, first probe is the bare name) pass; implementation lowercases both sides in `candidateNames` (lines 70-73). | same | |
| 3 | linux first-dir match, PATHEXT ignored, earlier dir wins | PASS | R4, R5 (probe list equals `["/opt/gh-bin/gh"]` with PATHEXT `.EXE`), R6. | same | |
| 4 | undefined when no candidate | PASS | R7. | same | |
| 5 | undefined for empty/undefined PATH; empty entries skipped | PASS | R8 and R9 (no probe made), R10 (`::/opt/gh-bin:` probes only `/opt/gh-bin/gh`). | same | |
| 6 | `defaultWhichGh` delegates with process inputs and `fs.existsSync` | PASS | D1 and D2 with `node:fs` module-mocked, `process.platform` pinned to `linux`, `PATH`/`PATHEXT` set and restored; D1 asserts `existsSync` called with `/opt/gh-bin/gh`. Source lines 113-121 read `process.env["PATH"]`, `process.env["PATHEXT"]`, `process.platform`, `existsSync`. | same | |
| 7 | service call optional `whichGh`, default `defaultWhichGh`, authenticated summary; fail-first | PASS | `pr-context-service-call.ts` line 152 `whichGh: input.whichGh ?? defaultWhichGh`; S1 asserts `runner.calls` contains `[GH_PATH, "auth", "status"]` and summary contains `GitHub CLI authenticated for owner/repo`. Fail-first: `evidence/regression-testing/ts-fail-first.2026-09-25T22-06.md` (S1 failed pre-fix); pass-after: `ts-pass-after...md`. | `npm --prefix extensions/drm-copilot test -- pr-context-service-call` (pass) | Default arm is exercised by the composition-root test (AC 8). |
| 8 | composition-root test with POSIX PATH and mocked `existsSync`; fail-first | PASS | C1 in `extension.collect-pr-context-gh-resolution.test.ts` asserts `spawnSync` called with `"/opt/gh-bin/gh", ["auth","status"], anything`. C1 failed pre-fix per `ts-fail-first...md`. | `npm --prefix extensions/drm-copilot test -- collect-pr-context-gh-resolution` (pass) | File placed per D12. |
| 9 | `GhClient` default unchanged; service-call tests inject `whichGh` | PASS | `git diff --stat origin/main...HEAD -- extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts` empty. `pr-context-service-call.test.ts` (8 existing tests) and `pr-context-service-call-target.test.ts` (7 tests) inject `whichGh`. `repo-automation-dispatch-pr-context-verification.test.ts` and `extension.integration.test.ts` reach the service through a composition root with no `whichGh` seam and pin `defaultWhichGh` to `undefined` by module mock. | `git diff --stat ...`; file inspection; reviewer search of every test calling `collectPrContext(` | The two composition-root suites use a module mock rather than an injected argument; the criterion's stated purpose (host-PATH independence) is met. |
| 10 | TS empty-list unavailable body exact | PASS | H1/H2 in `render-pr-helpers.test.ts` assert the last line `toBe` the exact body and absence of the available fallbacks; K1 in `collector-core.test.ts` asserts the body through `collectPrContext` with `whichGh: () => undefined`. K1 failed pre-fix (`ts-fail-first...md`). Source: `autoclose.ts` lines 277-280. | `npm --prefix extensions/drm-copilot test -- render-pr-helpers collector-core` (pass) | Builder is defined in `autoclose.ts` (#622 relocation) and re-exported from `render-pr-helpers.ts`, which the test imports. |
| 11 | Python empty-list unavailable body exact | PASS | `test_render_pr_helpers.py` asserts `result.splitlines()[-1] == UNAVAILABLE_BODY` in two tests; `test_pr_context_integration.py` `OfflineGh` scenario asserts the body in the summary and failed pre-fix (`py-fail-first...md`). Source: `render_pr_helpers.py` lines 288-291. | `poetry run pytest tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py tests/scripts/dev_tools/test_pr_context_integration.py` (10 passed) | |
| 12 | available-state empty texts unchanged in both runtimes | PASS | H4 and the two pre-existing TS fallback tests; K2; Python `keeps_available_fallback_texts[readiness0/1]` (default `gh_available`); `OnlineGh` empty scenario asserts `None (no verified closing issues and readiness not PASS)`. The diff removes no line containing either text. | same Jest and Pytest commands | |
| 13 | status messages and #622 regions unchanged; D11 non-empty rendering | PASS | Reviewer: `git diff --stat origin/main...HEAD -- gh-client-core.ts github.py collector-core.ts collector.py render-pr-helpers.ts autoclose.py` empty; builder hunks in `autoclose.ts` and `render_pr_helpers.py` are pure insertions (`@@ -274,0 +277,4 @@`, `@@ -284,0 +288,4 @@`, plus doc lines). H3 and `lists_pending_refs_when_gh_unavailable` assert `- #7` present and the empty-list body absent, without asserting on the annotation line (D11, D13). | `git diff -U0 origin/main...HEAD -- <builder files>` | Merge base equals the sync SHA, so the base anchor and the D9 anchor are the same commit. |
| 14 | TS coverage >= 85/75 and exactly one threshold entry each | PASS | lcov: `executable-resolver.ts` 100.00%/100.00%; `pr-context-service-call.ts` 100.00%/93.75%; `autoclose.ts` 98.68%/95.74%; `render-pr-helpers.ts` 87.53%/93.75% (not edited). `grep -c` for each of the three keys in `jest.config.cjs` returns `1`. | `node <scratchpad>/lcov.js extensions/drm-copilot/coverage/lcov.info ...`; `grep -c -F '"./src/lib/executable-resolver.ts": {' ...` | `collector-core.ts` (no diff, not a touched file) fell to 89.29% branches; non-blocking, see code-review CR-1. |
| 15 | Python touched files >= 85/75 | PASS | `render_pr_helpers.py` 96.21% lines (127/132), 95.45% branches (63/66) in `artifacts/python/lcov.info` and `coverage-588-final.json`. | `node <scratchpad>/lcov.js artifacts/python/lcov.info render_pr_helpers.py` | Only touched Python production file. |
| 16 | tests hermetic on Linux CI | PASS | New tests: no remote ref, drive path, or temp-file API (`evidence/qa-gates/hermeticity-new-tests...md`, reviewer inspection). Added lines in modified tests: none (`hermeticity-modified-tests...md`). Platform pinned to `linux` where process state matters; Windows cases use the `platform` parameter with drive-letter-free strings. Every suite reaching the service call mocks `node:fs`, pins the resolver, or injects `whichGh`. | file inspection; `grep` scans in evidence | Linux execution itself is not yet observed (no CI run on head); established by inspection. Pre-existing `C:/workspace` literals in an unchanged region of one modified file are opaque strings over an in-memory FS (CR-9). |
| 17 | no touched file over 500 lines | PASS | Reviewer `wc -l`: maximum 491 (`extension.integration.test.ts`). | `wc -l <15 files>` | |
| 18 | TS and Python toolchain loops clean in a single pass | PASS | Executor iteration 2 for both loops with no file change (`evidence/qa-gates/*`). Reviewer reruns: tsc exit 0, ESLint exit 0, Prettier clean, Jest 97/97; Black, Ruff, Pyright clean, Pytest 10/10. dependency-cruiser has no configuration in the repository; the stage has no tool to run. | commands in policy-audit Appendix B | |
| 19 | D5 limitation documented in resolver doc comment | PASS | `executable-resolver.ts` lines 15-20 (module doc comment, before the first import at line 23) cite CVE-2024-27980, `shell: false`, `.cmd`, `.bat`. | `grep -n -F -e "CVE-2024-27980" extensions/drm-copilot/src/lib/executable-resolver.ts` | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 19 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Non-blocking observations (from the code review):**

- CR-1 `collector-core.ts` branch coverage 91.22% -> 89.28% with no diff to the file (uncovered `whichGh === undefined` arm at line 135). Not blocking; add one test that omits `whichGh`.
- CR-2 stale precedence comments in both builders.
- CR-4 evidence `Timestamp:` values do not agree with commit times and the host clock.
- CR-10 author-asserted tokens `#CVE-2024`, `#R2-1`, `#R2-6`, `#7` in the PR-context summary are not issues; `#588` is the only closing issue.

**Recommended follow-up verification steps:**

1. Confirm the CI run for the PR head passes on Linux (depth-1 checkout).
2. After publishing `@danmoisan/drm-copilot-mcp` and the VSIX, run `collect_pr_context` where `gh auth status` succeeds, confirm `GitHub CLI authenticated for <owner/repo>`, then confirm with `gh pr view <N> --json closingIssuesReferences` (spec post-release follow-up).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 19 criteria were already checked (`- [x]`) by the executor in commit `51f852dc`. Each evaluated PASS, so no checkbox was changed and no item was unchecked. `spec.md` was not modified by this review.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/spec.md`
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/spec.md` | 19 | 19 | 0 | Checkbox-backed; all previously checked by executor and confirmed PASS by reviewer |
