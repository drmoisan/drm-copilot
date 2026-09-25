# Policy Audit — cleanup-worktrees-test-suite-blind-spots-660

- Issue: #660
- Branch: `bug/cleanup-worktrees-test-suite-blind-spots-660`
- Base: `origin/main` @ `26d57cb37f91e6a695f4ab4c1f57366229756fdc`
- Head: `783df800710ab0b9ebf9ae0119521bd34c112838`
- Work mode: `minor-audit` (AC source: `issue.md`, `## Acceptance Criteria`, AC-1 through AC-7)
- Reviewer: feature-review agent
- Timestamp: 2026-09-25T15-48

## Scope and Method

Scope is the full branch diff against the resolved base branch (`origin/main` at the
recorded merge-base), per the Scope Invariant. The diff was independently re-derived with
`git diff --name-status 26d57cb3..783df800` (24 files changed, 1500 insertions, 9 deletions)
and cross-checked against `artifacts/pr_context.summary.txt` and
`artifacts/pr_context.appendix.txt`; both match. All 24 changed files are either markdown
docs/evidence under `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/` or
bash test/fixture files under `tests/`. No production file under `scripts/` changed. No
other language has any changed file in this branch.

## Rejected Scope Narrowing

None. The delegating prompt specified the full-branch scope explicitly (resolved base
`main`, merge-base SHA, PR context artifacts) and did not attempt to narrow the audit to a
plan phase, task, or file subset. No caller instruction to skip a toolchain/coverage check
or to mark any language "out of scope" was present. This section is recorded to satisfy the
Scope Invariant's disclosure requirement, not because narrowing was attempted.

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
independently records the same four core files read by the plan author in the same order.
**Verdict: PASS.**

## Evidence Location Compliance

- Ran `python scripts/dev_tools/validate_evidence_locations.py --root .` against the
  worktree root: exit code 0, no output (no violations reported).
- Manually scanned the branch diff's 24 changed paths for `artifacts/baselines/`,
  `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/` prefixes: zero matches.
- All evidence this branch adds lives under
  `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/evidence/{baseline,qa-gates}/`,
  which is the canonical `<FEATURE>/evidence/<kind>/` location.

**Verdict: PASS.** No evidence-location violations found; no
`EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries required.

## Coverage Verification

**Languages with changed files in this branch: Bash only.** No TypeScript, Python,
PowerShell, or C# file is touched by this branch, so the coverage artifact table
(`coverage/lcov.info`, `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`,
`artifacts/csharp/coverage.xml`) has no applicable row for this diff — none of those four
mandatory-coverage languages has a changed file. This is stated explicitly, not silently
assumed: the Coverage Verification section's mandatory table covers TypeScript, Python,
PowerShell, and C#, and bash is outside that table's four listed rows.

Bash is nonetheless a coverage language under `.claude/rules/shell.md` and
`.claude/rules/general-unit-test.md` (kcov, line coverage only, no branch gate). The
following facts were independently verified for the bash coverage obligation that does
apply:

- **No production line changed.** `git diff origin/main --name-status -- scripts/` and
  `git status --porcelain -- scripts/`, re-run directly by this review (not merely trusting
  the recorded evidence), both produced empty output. kcov's include pattern is `tools/`,
  `scripts/`, and `.claude/lib/bash/` (`.claude/rules/shell.md`); none of those roots has a
  changed file on this branch. The "no regression on changed lines" gate
  (`.claude/rules/general-unit-test.md`) is therefore vacuously satisfied for bash
  production code — there are no changed production lines to regress.
- **No repo-wide kcov artifact was generated or checked, by design.** The plan
  (`plan.2026-09-25T08-25.md`, "Coverage applicability" note) documents this as a
  disclosed scope decision, not a skipped obligation: kcov is CI-built from source and not
  confirmed available in this Windows worktree, and with zero changed production lines
  (structurally proven by the AC-6 diff above) a repo-wide kcov percentage would be a
  strictly weaker proxy for the same fact the diff already proves directly. CI's
  `.github/workflows/_shell-coverage.yml` remains the confirming gate for the repo-wide
  bash coverage floor.

**Verdict: PASS** for "no regression on changed lines" (bash), verified directly.
**UNVERIFIED** for the repo-wide bash line-coverage percentage against the 85% floor — no
artifact exists locally to inspect, and this review did not rerun kcov generation (consistent
with the "verify from existing artifacts, do not regenerate" model for coverage). This is a
pre-existing, disclosed, and reasoned gap for a test-only branch that changes zero production
lines, not a new defect introduced by this branch. Recorded as UNVERIFIED rather than FAIL
because zero changed files exist in any of the four coverage-mandatory languages, and the
one coverage-relevant language present (bash) has zero changed production lines to regress.

## Toolchain Verification (`.claude/rules/shell.md`)

| Stage | Branch's recorded evidence | Independent re-run by this review | Verdict |
|---|---|---|---|
| Format/Lint (`sh scripts/bash/shell-qc.sh check`) | `final-shell-qc-check.2026-09-25T14-48.md`: EXIT 0, no diagnostics | Re-ran directly: exit 0, no stdout/stderr | **PASS** |
| Test (`npx --yes bats tests/shell`) | `final-shell-qc-test.2026-09-25T15-37.md`: EXIT 0, `1..463`, 463 ok, 0 not ok | Independent re-run completed (backgrounded, ~15+ minutes wall time): `[exited with code 0]`; the captured tail runs from `ok 381` through `ok 463` with zero `not ok` lines and five pre-existing `BW01` informational warnings matching the recorded evidence | **PASS** — confirmed by direct independent execution |
| Production-file diff (`scripts/`) | `final-ac6-scripts-diff.2026-09-25T15-09.md`: empty diff, empty status | Re-ran directly: empty diff, empty status | **PASS** |

Note on the test-stage re-run: this review started `npx --yes bats tests/shell` as a
background command from the worktree root. It produced no incremental output for
approximately 15+ minutes of wall time (463 tests, many of which fork a `bash -c` subshell
per assertion, on Windows git-bash) before completing — an environment/buffering
characteristic, not a failure (recorded in agent memory as
`project_bats_full_suite_slow_no_incremental_output.md`). On completion the process exited
with code 0; the captured tail (last 100 lines) shows tests 381 through 463 all `ok`, with
the same five `BW01` bats-linter informational warnings (stubbed-missing-tool exit-127
scenarios in `test_cleanup_worktrees_preserve.bats` and `test_shell_qc_commands.bats`, none
attributable to a test this plan added or modified) that the branch's own
`final-shell-qc-test.2026-09-25T15-37.md` evidence describes. Because `bats` exits non-zero
on any `not ok`, the exit code 0 independently confirms zero failures across the full
463-test suite, corroborating the recorded artifact's `EXIT_CODE: 0` / `1..463` / 463-ok /
0-not-ok claim rather than merely trusting it.

**Verdict: PASS**, confirmed both by the recorded final-QC artifact and by this review's own
completed independent re-run of the full test suite, the check stage, and the AC-6 diff
proof.

## General Code Change Policy (`.claude/rules/general-code-change.md`)

- **File size limit (500 lines).** Verified by direct line count:
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats` = 425 lines,
  `tests/shell/test_cleanup_worktrees_dirt_clear.bats` = 336 lines,
  `tests/fixtures/cleanup_worktrees/stub-bin/git` = 416 lines. All under 500.
  `plan.2026-09-25T08-25.md` (449 lines) and `research.2026-09-25T12-30.md` (661 lines) are
  markdown documentation, which is an explicit exemption from the 500-line limit.
  **PASS.**
- **Mandatory toolchain loop.** No stage rewrote a file in this review's re-run (check
  stage produced no diagnostics or diffs); the branch's own final-QC evidence records the
  same across both the defective P1-T6 attempt and its correction, restarting from
  formatting was not required because no auto-fix occurred at any stage. **PASS.**
- **Error handling / naming / dependencies / I/O boundaries / public APIs.** Not applicable
  in a meaningful sense: this branch adds zero production code (AC-6, verified). The
  changed bash files are test files and a test-fixture stub, not production modules.
  **N/A (no production code in scope).**

## General Unit Test Policy (`.claude/rules/general-unit-test.md`)

- **Independence / Isolation / Determinism.** Each new/modified test sources the same
  library files as its sibling tests via the file's existing `setup()`, uses `run env ...
  bash -c '...'` per test with no shared mutable state, and drives the classifier through a
  stub git binary keyed by canned fixture files rather than a live git repository or clock.
  No `sleep`, no wall-clock read. **PASS.**
- **No temporary files.** All three new/modified tests compose mutated source text into an
  in-memory shell variable (`mutated="$(sed ... )"`) and `eval`/pipe it into a subshell via
  `<<<"$mutated"`; none of the three writes a scratch file to disk. Verified by reading each
  test body directly (see AC-2 and AC-5 negative-control tests in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats` and
  `tests/shell/test_cleanup_worktrees_dirt_clear.bats`). **PASS.**
- **Test file location.** New/modified tests remain in `tests/shell/*.bats`, mirroring
  `scripts/bash/`, per the existing convention; the new fixture directory sits under
  `tests/fixtures/cleanup_worktrees/scenarios/`, matching the existing sibling scenario
  layout. No colocation with production source. **PASS.**
- **Scenario completeness / documentation.** Each new test carries an inline comment
  explaining the scenario and, for the two negative controls, an explicit statement of what
  a passing assertion would mean if the mutation under test were reverted. **PASS.**
- **Coverage Exclusion Policy.** No `exclude` entry was added or modified in this branch;
  `scripts/bash/shell_qc_lib.sh`'s discovery/kcov include pattern is untouched. **PASS
  (no change in scope).**

## Tonality Policy

The branch's own authored prose (`issue.md`, `plan.2026-09-25T08-25.md`,
`research.2026-09-25T12-30.md`, `remediation-inputs.2026-09-25T15-13.md`, and the evidence
files) was scanned for hyperbole, humor, and unsupported certainty. Language is factual and
measured throughout (e.g., "Severity: Low," "This is a defect in the plan's own literal task
text ... not an execution error," explicit EXIT_CODE and TAP-line citations for every claim).
No hyperbolic or joking language was found. **PASS.**

## Summary Verdict Table

| Area | Verdict |
|---|---|
| Policy reading order | PASS |
| Rejected scope narrowing | N/A (none attempted) |
| Evidence location compliance | PASS |
| Coverage — mandatory 4-language table | N/A (zero changed files in TS/Python/PowerShell/C#) |
| Coverage — bash changed-line regression | PASS |
| Coverage — bash repo-wide kcov percentage | UNVERIFIED (no local artifact; disclosed scope decision; CI is confirming gate) |
| Toolchain — format/lint | PASS |
| Toolchain — bats test suite | PASS (recorded artifact and completed independent re-run agree: exit 0, 463 tests, 0 not ok) |
| Toolchain — AC-6 production-file diff | PASS |
| General code change policy | PASS |
| General unit test policy | PASS |
| Tonality | PASS |

## Blocking Findings

**None.** No Blocking-severity finding was identified in this audit.
