# Self-Review: Preserve Copies an Older Snapshot over Newer Main (#1027)

Timestamp: 2026-11-03T13-14
Task: [P7-T8]
Scope: branch `bug/cleanup-preserve-older-snapshot-1027-r2`, diff from the merge base of `origin/main` and `HEAD` (the `Merge pull request #1060` commit) to head 456b9da17 plus the uncommitted loop-pass-2 evidence
Templates walked: `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, `feature-audit.yyyy-MM-ddTHH-mm.md`
Work mode: full-bug; AC source `spec.md` `## Acceptance Criteria` (20 items)

## Review history

- Pass 1 (after loop pass 1, CI run 41638835200) found one FAIL: policy-audit 1.2 **Error Handling**. Two fail-closed refusals in `preserve_merge_decide`, an unreadable base blob (G1) and an unreadable merged blob (G2), were driven by no test. `cov.xml` showed those two lines with zero hits.
- Fix (commit 456b9da17): two tests in `tests/shell/test_cleanup_worktrees_preserve_merge.bats` (`an unreadable base blob is refused by G1`, `an unreadable merged blob is refused by G2`). Each redefines `cleanup_wt_git` inside its own test process, so the fix adds no fixture and no temporary file.
- The QA loop was re-run from P7-T1 (loop pass 2, CI run 41640864723). The merge library reached 0.990 line coverage. This file replaces the pass-1 review and has no FAIL row.

## A. Policy audit template

| Item | Result | Evidence |
|---|---|---|
| Coverage metrics by language (Bash) | PASS | Baseline 95.2% lines (`baseline/shell-coverage.2026-11-03T12-30.md`); post-change 95.3% (`qa-gates/shell-coverage.2026-11-03T13-12.md`); new code (MLIB) 99.0% |
| Coverage metrics by language (JSON) | PASS | `core.json` and every new `manifest.json` parse (P6-T1, P1-T3) |
| Coverage metrics (Python, PowerShell, TypeScript) | N/A | No production or test file in these languages changed; Python contract tests ran unchanged (66 passed) |
| Coverage evidence checklist | PASS | Baseline and post-change artifacts present; comparison in `qa-gates/coverage-delta.2026-11-03T13-12.md` |
| Policy documents evaluated | PASS | `baseline/phase0-instructions-read.2026-11-03T12-09.md` (ten files, in order) |
| Language policy: Bash shfmt, shellcheck, bats | PASS | `qa-gates/shell-format.2026-11-03T13-02.md`, `qa-gates/shell-qc-check.2026-11-03T13-02.md`, CI run 41640864723 |
| Temporary artifacts cleanup | PASS | Launchers and generators live only under SCRATCH, outside the repository; none were committed |
| 1.1 Independence | PASS | `regression-testing/bats-order-isolation.2026-11-03T13-03.md`: forward and reversed file order, 71/71 each |
| 1.1 Isolation | PASS | One behavior per test (helpers, one verdict row per scenario, one base-unavailable cause per test) |
| 1.1 Fast execution | PASS | Each merge suite runs in seconds under Git Bash; CI full suite about 6 minutes, the same as baseline |
| 1.1 Determinism | PASS | All git calls go through the recording stub with canned answers; no clock, randomness, or real repository |
| 1.1 Readability | PASS | Descriptive test names; shared `merge_assert_refused`, `merge_assert_merge_entry`, `fallback_assert_ok_and_bad` helpers |
| 1.2 Baseline coverage documented | PASS | `baseline/shell-coverage.2026-11-03T12-30.md` (numeric, before any code change) |
| 1.2 No coverage regression | PASS | Aggregate +0.1 point; `cleanup_worktrees_preserve_lib.sh` 0.906 to 0.908; wrapper 0.976 to 0.977 |
| 1.2 New code coverage | PASS | `cleanup_worktrees_preserve_merge_lib.sh` 0.990 (uncovered: one `done` line that kcov does not attribute) |
| 1.2 Comprehensive coverage | PASS | Every MLIB function is driven: helpers (7 tests), refuse/duplicate/resolve/guard-b/decide (scenario tests) |
| 1.2 Positive flows | PASS | Clean merge, EOF union, already-on-main, absent-target copy, guard-b copy for `notes/ok.md` |
| 1.2 Negative flows | PASS | G1, G2, G3, merge-file error, guard-b refusal, duplicate target |
| 1.2 Edge cases | PASS | Empty inputs, CRLF, doubled CR, unterminated final line, blank lines, duplicate line counts |
| 1.2 Error handling | PASS | `merge-file rc=129`; base and merged blob read failures (fixed this pass); commit-phase `cat-file` failure reported `FAILED` |
| 1.2 Concurrency | N/A | Single-process CLI; no shared mutable state across processes |
| 1.2 State transitions | PASS | Seen-target state across records (`a duplicate target_path in one pass is refused after the first`); `PRESERVE_SEEN_TARGETS` reset per pass |
| 1.2.1 Per-language coverage comparison | PASS | Bash: 95.2% to 95.3%, +0.1; new code 99.0%; `qa-gates/coverage-delta.2026-11-03T13-12.md` |
| 1.3 Clear failure messages | PASS | The repro prints `plan entry columns: N, mode: '...'` on failure (seen in fail-before evidence) |
| 1.3 Arrange-Act-Assert | PASS | Scenario seams arranged, `run` acts, assertions follow |
| 1.3 Document intent | PASS | File headers and per-section comments state scope and fixture rationale |
| 1.4 Avoid external dependencies | PASS | No network, no real git, no real jq |
| 1.4 Use mocks/stubs | PASS | Git stub (four new key forms), jq stub, in-process `cleanup_wt_git` redefinition for two read-failure tests |
| 1.4 Environment stability | PASS | No temporary files; commit-phase writes go to `/dev/null`; merge scenarios drive `preserve_plan` only |
| 1.5 Pre-submission review | PASS | This document |
| 2.1 Clarify objective | PASS | Issue #1027; `spec.md` root-cause section |
| 2.1 Read existing change plans | PASS | Plan `plan.2026-10-30T20-58.md` executed task by task |
| 2.1 Document the plan | PASS | Plan file with every task checked off; commits per phase |
| 2.2 Simplicity first | PASS | One decision function; guards are pure string helpers |
| 2.2 Reusability | PASS | `preserve_merge_is_subsequence` serves G1, G2, and guard (b); `preserve_merge_refuse` centralizes the refusal contract |
| 2.2 Extensibility | PASS | Plan entry columns appended after column 8; empty column 9 means `copy`, so older eight-column entries still work |
| 2.2 Separation of concerns | PASS | Decision policy in MLIB; phase 2 stays policy-free and executes the mode |
| 2.3 Cohesive modules | PASS | MLIB holds only the staging decision |
| 2.3 At or below 800-line limit | PASS | Largest changed file 500 (`cleanup_worktrees_preserve_lib.sh`); no file at or above 700 (`qa-gates/file-sizes.2026-11-03T13-12.md`) |
| 2.3 Public vs internal | PASS | Wrapper CLI flags unchanged; new library functions are internal to the skill |
| 2.3 No circular dependencies | PASS | MLIB depends only on `cleanup_wt_git`; the preserve library calls MLIB, not the reverse |
| 2.4 Descriptive names | PASS | `preserve_merge_*` prefix; reason tokens `G1`, `G2`, `G3`, `guard-b`, `merge-file rc=`, `duplicate-target` |
| 2.4 Docs/docstrings | PASS | Every MLIB function carries a header comment with args and returns |
| 2.4 Comment why | PASS | Comments explain the CR variable, the key prefix for empty subscripts, and the SC2034 cross-file suppressions |
| 2.5 Formatting | PASS | `scripts/bash/shell-qc.sh format`: no file rewritten (hashes identical) |
| 2.5 Linting | PASS | `scripts/bash/shell-qc.sh check`: no output, exit 0 |
| 2.5 Type checking | N/A | Bash has no type-check stage |
| 2.5 Testing | PASS | CI `1..761`, 0 `not ok` |
| 2.5 Full toolchain loop | PASS | Two loop passes; pass 2 clean in a single pass after the self-review fix |
| 2.5 Explicit reporting | PASS | One evidence artifact per QC step under `evidence/qa-gates/` |
| 2.6 Summarize changes | PASS | Conventional commit messages per phase |
| 2.6 Design choices explained | PASS | Plan `## Design Decisions (planner)`; spec verdict table; MLIB header |
| 2.6 Update supporting documents | PASS | SKILL.md `### Preserve staging outcomes`; wrapper usage; library headers |
| 2.6 Provide next steps | PASS | Pending-CI ACs and the PR step are named in the execution report |
| 3A Python | N/A | No Python changed (no new Python, per rules) |
| 3B PowerShell | N/A | No PowerShell changed |
| 3C.1 shfmt | PASS | See 2.5 Formatting |
| 3C.1 shellcheck | PASS | See 2.5 Linting; three line- or function-scoped SC2034 suppressions, each with its reason |
| 3C.1 bats | PASS | See 2.5 Testing |
| 3C.2 Portable shebang | PASS | MLIB uses `#!/usr/bin/env bash` |
| 3C.2 Error handling | PASS | Fail-closed refusals; wrapper keeps `set -euo pipefail`; no `-f`/`--force` git call |
| 3C.2 At or below 800-line limit | PASS | See 2.3 |
| 3D JSON tooling and structure | PASS | Strict JSON; `core.json` entry in sorted position; manifests parse |
| 4A, 4B Python and PowerShell unit tests | N/A | No test in these languages changed |
| 5 Test coverage detail | PASS | MLIB per-file 0.990; each function driven, as listed under 1.2 |
| 6 Test execution metrics | PASS | 761 tests, 761 pass, 0 fail; test files at most 478 lines |
| 7 Code quality checks | PASS | Bash checks clean; Python and PowerShell checks N/A |
| 8 Gaps and exceptions | PASS | No open gap. Route W could not write `cov.xml` locally, so Route C (CI) was used, as the plan authorizes |
| 9 Summary of changes | PASS | Phase commits 0fa5e2f89, 915243340, efe3be650, 83bcb28a1, 990f5bf8e, fd3276f7a, dc1e9dc97, ba5ae650d, 16a1a6e77, 456b9da17 |
| 10 Compliance verdict | PASS | Fully compliant on the evidence above |

## B. Code review template

| Item | Result | Evidence |
|---|---|---|
| Findings table: Blocker or Major | PASS | None open; the one pass-1 finding (untested read-failure refusals) was fixed in 456b9da17 |
| File-size Warning (at or above 700) | N/A | No covered file at or above 700 lines |
| Implementation audit (bash) | PASS | Decision isolated in MLIB; phase 2 reads `cat-file blob <oid>` for `merge` and keeps the byte copy otherwise |
| Test quality audit | PASS | Fail-before (`regression-testing/fail-before-repro.2026-11-03T12-35.md`) and pass-after (`pass-after-repro.2026-11-03T12-41.md`) recorded |
| No secrets in code | PASS | Fixtures avoid host-token shapes (`grep -r -l -i -E '@|/home/|users'` over `merge-*` prints nothing) |
| No unsafe command construction | PASS | All git calls are argv arrays through `cleanup_wt_git`; no `eval`; no process substitution passed to git |
| Input validation at boundaries | PASS | Records still pass `preserve_validate_record` before the decision |
| Error handling remains explicit | PASS | Every guard failure emits a reason-tagged stderr line and `REFUSED-WOULD-REGRESS` |
| Configuration and path handling | PASS | Stub keys use only the final `-C` component; no absolute path enters a key or evidence file |
| Research log | N/A | No external research beyond the feature's `research/` document |
| Verdict | PASS | Ready for the normal PR flow |

## C. Feature audit template (spec.md acceptance criteria)

| # | Criterion (abbreviated) | Result | Evidence |
|---|---|---|---|
| 1 | Issue repro fixed | PASS | `an older modified snapshot never overwrites newer main lines` (fail-before, then pass-after) |
| 2 | Clean or union merge | PASS | `a clean merge plans the merged blob in merge mode`; `both sides appending at end of file is merged with OK`; `a merge-mode plan entry writes the merged blob through cat-file` |
| 3 | Addition already on main | PASS | `an addition already on main merges to main content` |
| 4 | G1 refusal | PASS | `a worktree that deleted a base line is refused by G1` |
| 5 | Merge-error refusal | PASS | `a merge-file error is refused and names the git exit code` (`merge-file rc=129`) |
| 6 | G2 and G3 refusals | PASS | `a merged result missing a main line is refused by G2`; `a resurrected base line is refused by G3` |
| 7 | Base-unavailable fallback | PASS | Four fallback tests, one per cause, each asserting the `notes/ok.md` copy and the `notes/bad.md` refusal |
| 8 | Refusal side effects | PASS | `merge_assert_refused` and `fallback_assert_ok_and_bad`: `PRESERVE|`, stderr reason, `PRESERVE_EXIT` 1, empty plan stream, no `ACTION|preserve-index` |
| 9 | Absent target unchanged | PASS | `an absent target is copied with no decision git call` (no `merge-file`, `hash-object`, `merge-base`, or `rev-parse`) |
| 10 | Untracked with existing target | PASS | `an untracked record with an existing target is guarded by guard-b` |
| 11 | Duplicate target | PASS | `a duplicate target_path in one pass is refused after the first` |
| 12 | CRLF and terminator tolerance | PASS | `is_subsequence strips one trailing carriage return per line`; `is_subsequence counts an unterminated final line` |
| 13 | Phase-1 write exception documented | PASS | `preserve_plan`, `preserve_plan_one`, library header, and MLIB header comments |
| 14 | Existing preserve suites pass unchanged in outcome | PASS | Baseline counts kept (26, 6, 11 plus 2 added, 21, 15); `modified` test comment rewritten |
| 15 | Fail-before evidence recorded | PASS | `regression-testing/fail-before-repro.2026-11-03T12-35.md` |
| 16 | Bundle mirrors and manifest updated | PASS | `cmp` exit 0 for four pairs; `core.json` entry; `qa-gates/python-contracts.2026-11-03T12-46.md` |
| 17 | Documentation updated | PASS | SKILL.md subsection; wrapper usage (`Copies each named source file` count 0); `NOT change the staging` count 0; merge-queue pins pass |
| 18 | Git stub comments corrected | PASS | `_lib[.]sh:[0-9]` count 0; `defines no -w` count 0 |
| 19 | Shell QC passes | PASS | check exit 0; CI `1..761`, 0 `not ok`, 95.3%; MLIB 0.990 |
| 20 | File-size tiers respected | PASS | `qa-gates/file-sizes.2026-11-03T13-12.md` |

AC status: 20 total, 20 PASS. No FAIL, PARTIAL, or UNVERIFIED row.

## Verdict

No FAIL row remains. All 20 acceptance criteria are checked off in `spec.md`. The branch is ready for the normal PR flow, and the PR-head CI run (`ci.yml`) remains the orchestrator's S9 gate.
