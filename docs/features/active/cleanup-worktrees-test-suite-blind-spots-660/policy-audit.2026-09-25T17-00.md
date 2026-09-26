# Policy Audit — cleanup-worktrees-test-suite-blind-spots-660

- Issue: #660
- Branch: `bug/cleanup-worktrees-test-suite-blind-spots-660`
- Base: `origin/main` @ `26d57cb37f91e6a695f4ab4c1f57366229756fdc`
- Head: `15aa71138bedbeb577906dd8ab05d92e0d08f30b`
- Work mode: `minor-audit` (AC source: `issue.md`, `## Acceptance Criteria`, AC-1 through AC-7)
- Reviewer: feature-review agent
- Timestamp: 2026-09-25T17-00
- Review cycle: remediation-cycle re-audit, cycle 1 of the R1-R5 loop. The prior review
  pass (`policy-audit.2026-09-25T15-48.md`, `code-review.2026-09-25T15-48.md`,
  `feature-audit.2026-09-25T15-48.md`, head `783df800710ab0b9ebf9ae0119521bd34c112838`)
  found zero blocking findings and PASS on all 7 AC. One commit has landed since that
  review: `15aa7113` ("fix(tests): remove CI-incompatible git diff origin/main from
  negative controls (#660)"), prompted by a CI failure of the required
  `shell-coverage / Shell Coverage (Bats + kcov)` check on PR #698 at the prior head. This
  audit re-derives the full branch-vs-base diff from scratch and does not treat the prior
  round's findings as pre-verified; every verdict below is independently re-checked at the
  new head.

## Scope and Method

Scope is the full branch diff against the resolved base branch (`origin/main` at the
recorded merge-base), per the Scope Invariant. The diff was independently re-derived with
`git diff --name-status 26d57cb37f91e6a695f4ab4c1f57366229756fdc..15aa71138bedbeb577906dd8ab05d92e0d08f30b`
(31 files changed: 28 added, 3 modified) and cross-checked against
`artifacts/pr_context.summary.txt` (head SHA `15aa71138bedbeb577906dd8ab05d92e0d08f30b`,
generated 2026-09-25 16:50:54 UTC, i.e. after the fix commit at 16:49:42 UTC) and
`artifacts/pr_context.appendix.txt`; both match. All 31 changed files are either markdown
docs/evidence under `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/`,
bash test files under `tests/shell/`, or bash test-fixture files under `tests/fixtures/`. No
production file under `scripts/` changed. No other language has any changed file in this
branch. This audit reviews the full diff end to end, not merely the delta since the prior
review round, per the caller's explicit instruction and the Scope Invariant.

## Rejected Scope Narrowing

None. The delegating prompt specified the full-branch scope explicitly (resolved base
`main`, merge-base SHA, current HEAD, PR context artifacts) and explicitly instructed this
audit not to treat the review as scoped to the delta since the last pass. No caller
instruction to skip a toolchain/coverage check or to mark any language "out of scope" was
present. This section is recorded to satisfy the Scope Invariant's disclosure requirement,
not because narrowing was attempted.

## CI Status Verification (new in this round)

The task context stated that CI had not yet been re-checked by the orchestrator after the
fix commit. This audit checked directly:

- `gh pr view 698 --json headRefOid` confirms PR #698's head SHA is
  `15aa71138bedbeb577906dd8ab05d92e0d08f30b`, matching the branch's current HEAD.
- `gh pr checks 698`, polled to completion (initial poll: 6 required checks pending,
  including `shell-coverage / Shell Coverage (Bats + kcov)`; final poll after
  approximately 5 minutes: 0 pending, all 16 required checks `pass`), confirms
  `shell-coverage / Shell Coverage (Bats + kcov)` now passes at 7m25s
  (run `https://github.com/drmoisan/drm-copilot/actions/runs/36163252436`, job
  `108164730498`).
- `gh pr view 698 --json mergeStateStatus,mergeable` now reports `CLEAN` /
  `MERGEABLE` (previously `BLOCKED` while the check was pending).
- Direct inspection of the job log (`gh run view --job 108164730498 --log`) confirms
  `1..463` and zero `not ok` lines (`grep -c "not ok "` = 0), and a
  `Bash coverage (lines): 93.3%` summary line from the coverage-reporting step. This is the
  same fix that was applied locally; the CI run genuinely exercises the shallow-checkout
  path the local re-runs cannot exercise (`origin/main` already exists locally from prior
  fetch history, per `.claude/rules/shell.md`'s "CI versions are canonical" guidance).

**Verdict: PASS.** The defect described in the task context (CI `not ok 275`/`not ok 297`
under shallow checkout) is confirmed fixed at HEAD by a genuine CI run, not merely by local
re-derivation of the same environment that could not have caught the original defect.

## Policy Compliance Reading Order

Read in full, in the order below, before evaluation:

1. `CLAUDE.md` — tone policy, policy-compliance order, architecture.
2. `.claude/rules/general-code-change.md` — cross-language code change policy.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy.
4. `.claude/rules/quality-tiers.md` — uniform coverage/gate matrix.
5. `.claude/rules/shell.md` — bash-specific toolchain, discovery contract, coverage
   expectations (the only language-specific rule file in scope, since bash is the only
   language with changed files).
6. `.claude/rules/tonality.md` — tone rules (mirrors `.github/instructions/tonality...`).

The branch's own Phase 0 evidence (`evidence/baseline/phase0-instructions-read.md`)
independently records the same four core files read by the plan author in the same order;
this audit independently re-read all files above before evaluation. **Verdict: PASS.**

## Evidence Location Compliance

- Ran `python scripts/dev_tools/validate_evidence_locations.py --root .` against the
  worktree root: exit code 0, no output (no violations reported).
- Manually scanned the full 31-file branch diff for `artifacts/baselines/`,
  `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/` prefixes: zero matches. The
  branch's only `artifacts/` writes are pre-existing session artifacts
  (`artifacts/pr_context.*`, `artifacts/pr_body_660.*`) outside this branch's diff and
  outside the canonical-evidence-path concern (they are PR-context/PR-body artifacts, not
  baseline/QA/coverage evidence).
- All evidence this branch adds lives under
  `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/evidence/{baseline,qa-gates}/`,
  which is the canonical `<FEATURE>/evidence/<kind>/` location. This round added two new
  files to that same canonical location (`final-shell-qc-check.2026-09-25T16-24.md`,
  `final-shell-qc-test.2026-09-25T16-48.md`, plus a second `final-ac6-scripts-diff` run at
  `16-48`), all under the same canonical prefix as the prior round's evidence.

**Verdict: PASS.** No evidence-location violations found; no
`EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries required.

## Coverage Verification

**Languages with changed files in this branch: Bash only.** No TypeScript, Python,
PowerShell, or C# file is touched by this branch, so the coverage artifact table
(`coverage/lcov.info`, `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`,
`artifacts/csharp/coverage.xml`) has no applicable row for this diff — none of those four
mandatory-coverage languages has a changed file.

Bash is nonetheless a coverage language under `.claude/rules/shell.md` and
`.claude/rules/general-unit-test.md` (kcov, line coverage only, no branch gate). The
following facts were independently verified for the bash coverage obligation that applies:

- **No production line changed.** `git diff origin/main --name-status -- scripts/` and
  `git status --porcelain -- scripts/`, re-run directly by this review, both produced empty
  output. kcov's include pattern is `tools/`, `scripts/`, and `.claude/lib/bash/`
  (`.claude/rules/shell.md`); none of those roots has a changed file on this branch. The "no
  regression on changed lines" gate (`.claude/rules/general-unit-test.md`) is therefore
  vacuously satisfied for bash production code — there are no changed production lines to
  regress.
- **Repo-wide bash line coverage: 93.3%, sourced from a genuine CI artifact and inspected,
  not regenerated.** The prior round recorded this figure as UNVERIFIED because no local
  kcov artifact existed and the review did not rerun coverage generation. This round
  resolves that gap without violating the "verify from existing artifacts, do not
  regenerate" constraint: CI's `shell-coverage` job (run `36163252436`, job `108164730498`,
  triggered independently by GitHub against this exact HEAD, not run by this review) already
  executed `bash scripts/bash/shell-qc.sh test --coverage` and printed
  `Bash coverage (lines): 93.3%` in its own log, which this audit read via
  `gh run view --job 108164730498 --log`. This is inspection of a pre-existing artifact
  produced by CI, consistent with the required evidence-verification model. 93.3% exceeds
  the uniform 85% line-coverage floor (`.claude/rules/quality-tiers.md`). The workflow itself
  (`.github/workflows/_shell-coverage.yml`) and `scripts/bash/shell-qc.sh` do not enforce
  this threshold programmatically (no `85`/threshold string found in either), so the job's
  `success` conclusion alone does not prove the floor was met; the printed percentage is what
  proves it, and 93.3% clears the 85% floor with margin.

**Verdict: PASS** for "no regression on changed lines" (bash), verified directly.
**PASS** for the repo-wide bash line-coverage percentage against the 85% floor (93.3%,
sourced from CI's own log for the current HEAD). This upgrades the prior round's UNVERIFIED
verdict on the same question, using evidence that did not exist at the time of the prior
round (the prior round's HEAD had not yet passed CI's shell-coverage check).

## Toolchain Verification (`.claude/rules/shell.md`)

| Stage | Branch's recorded evidence | Independent verification by this review | Verdict |
|---|---|---|---|
| Format/Lint (`sh scripts/bash/shell-qc.sh check`) | `final-shell-qc-check.2026-09-25T16-24.md`: EXIT 0, no diagnostics (post-dates the fix-round edits per its own text, though those edits are confined to `tests/shell/*.bats`, outside this stage's discovery roots) | CI's `shell-coverage` job independently ran `bash scripts/bash/shell-qc.sh check` at HEAD and passed (job conclusion `success`, no failure reported for that step in the job log) | **PASS** |
| Test (`npx --yes bats tests/shell` / CI's `bash scripts/bash/shell-qc.sh test --coverage`) | `final-shell-qc-test.2026-09-25T16-48.md`: EXIT 0, `1..463`, 463 `ok`, 0 `not ok`, explicitly naming tests 275 and 297 (the two tests this round's fix touches) as `ok` | Independently confirmed via CI job log: `1..463` present, `grep -c "not ok "` over the full job log = 0, job conclusion `success` at commit HEAD under CI's genuinely shallow checkout (the environment the local run cannot reproduce) | **PASS** — confirmed by both local evidence and an independent CI run at HEAD |
| Production-file diff (`scripts/`) | `final-ac6-scripts-diff.2026-09-25T16-48.md`: empty diff, empty status | Re-ran directly by this review: `git diff --name-status 26d57cb3..15aa7113 -- scripts/` and `git status --porcelain` both empty | **PASS** |

Note on this round's verification method: rather than re-running the full local bats suite
a third time (already run twice by the branch's own evidence at `16-24`/`16-48`, both
post-dating the fix), this review used the genuinely independent CI execution as its primary
corroborating evidence, because CI is the only environment that exercises the shallow-checkout
condition the original defect depended on (`.claude/rules/shell.md`, "CI versions are
canonical. When local and CI results disagree, defer to CI."). A local-only re-run would
re-confirm the tests pass under a checkout that already has `origin/main` locally — the exact
condition that let the original defect through undetected on this branch's earlier local
runs — and would not by itself confirm the CI-specific fix.

**Verdict: PASS**, confirmed by the recorded final-QC artifacts, this review's direct
re-derivation of the AC-6 diff, and an independent CI run at HEAD covering the
shallow-checkout condition the local environment cannot reproduce.

## General Code Change Policy (`.claude/rules/general-code-change.md`)

- **File size limit (500 lines).** Verified by direct line count at HEAD:
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats` = 422 lines (down from 425 in the
  prior round; the fix commit removed 3 lines),
  `tests/shell/test_cleanup_worktrees_dirt_clear.bats` = 333 lines (down from 336),
  `tests/fixtures/cleanup_worktrees/stub-bin/git` = 417 lines (unchanged by the fix commit).
  All under 500. `plan.2026-09-25T08-25.md` (507 lines at HEAD; the fix commit revised its
  P1-T3/P1-T6 task text in place, per the remediation-inputs' requested revision, with net
  line count unchanged) and `research.2026-09-25T12-30.md` (661 lines) are markdown
  documentation, an explicit exemption from the 500-line limit. **PASS.**
- **Mandatory toolchain loop.** No stage rewrote a file in this round's verification (check
  stage produced no diagnostics or diffs, both locally and in CI); the fix commit itself was
  a targeted, minimal removal (3 lines each in two test files) with no auto-fix churn.
  **PASS.**
- **Error handling / naming / dependencies / I/O boundaries / public APIs.** Not applicable
  in a meaningful sense: this branch adds zero production code (AC-6, verified). The changed
  bash files remain test files and a test-fixture stub, not production modules. **N/A (no
  production code in scope).**

## General Unit Test Policy (`.claude/rules/general-unit-test.md`)

- **Independence / Isolation / Determinism.** The fix commit's edits are pure deletions (the
  `git diff origin/main` triple) from two existing tests; nothing was added that introduces
  shared state, sleeps, or wall-clock reads. The retained `git status --porcelain` triple in
  each test still proves the production file was never opened for writing, using only local
  index/HEAD state available at any checkout depth. **PASS.**
- **No temporary files.** Unaffected by this round's edit; both tests still compose the
  mutated source into an in-memory shell variable and `eval`/pipe it into a subshell, with no
  scratch file written to disk. Re-verified by reading both test bodies directly at HEAD.
  **PASS.**
- **Test file location.** Unchanged by this round: tests remain in `tests/shell/*.bats`,
  fixtures remain under `tests/fixtures/cleanup_worktrees/scenarios/`. **PASS.**
- **Scenario completeness / documentation.** The fix commit's removed lines carried the same
  explanatory comment for the retained `git status --porcelain` check ("The mutated source
  was composed into a shell variable and evaluated in a child process; the production file on
  disk was never opened for writing"), which remains present and accurate after the edit.
  **PASS.**
- **Coverage Exclusion Policy.** No `exclude` entry was added or modified in this branch;
  `scripts/bash/shell_qc_lib.sh`'s discovery/kcov include pattern is untouched. **PASS (no
  change in scope).**

## Tonality Policy

The branch's own authored prose added or modified since the prior review round
(`issue.md`'s reconciled AC-2/AC-5/AC-7 narratives, `remediation-inputs.2026-09-25T17-00.md`,
the fix commit message) was scanned for hyperbole, humor, and unsupported certainty.
Language remains factual and measured (e.g., "Independently verified," "Root cause,
independently verified," explicit workflow-file citations and `grep` commands for every
scope claim rather than assertions). No hyperbolic or joking language was found. **PASS.**

## Summary Verdict Table

| Area | Verdict |
|---|---|
| Policy reading order | PASS |
| Rejected scope narrowing | N/A (none attempted) |
| CI status verification (this round's specific task) | PASS — `shell-coverage` check confirmed green at HEAD via direct polling |
| Evidence location compliance | PASS |
| Coverage — mandatory 4-language table | N/A (zero changed files in TS/Python/PowerShell/C#) |
| Coverage — bash changed-line regression | PASS |
| Coverage — bash repo-wide line coverage (85% floor) | PASS (93.3%, sourced from CI job log; upgraded from prior round's UNVERIFIED) |
| Toolchain — format/lint | PASS |
| Toolchain — bats test suite | PASS (local evidence and independent CI run at HEAD agree: exit 0, 463 tests, 0 not ok) |
| Toolchain — AC-6 production-file diff | PASS |
| General code change policy | PASS |
| General unit test policy | PASS |
| Tonality | PASS |

## Blocking Findings

**None.** No Blocking-severity finding was identified in this audit. The one defect this
review cycle exists to re-verify (CI's shallow-checkout `git diff origin/main` failure) is
confirmed fixed by a genuine CI run at HEAD, not merely by local re-derivation.
