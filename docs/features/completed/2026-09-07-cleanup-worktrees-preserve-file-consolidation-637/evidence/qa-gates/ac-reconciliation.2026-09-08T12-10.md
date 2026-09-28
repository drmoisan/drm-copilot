# Final QC — `[P10-T9]`, the acceptance-criteria reconciliation

Timestamp: 2026-09-08T12-10
ReconciledAt: 2026-09-08T12-03 (UTC; this artifact was re-derived after the final CI round, run
34223163823, discharged the four PENDING-CI tasks. The pre-discharge form of this artifact recorded
41 complete and 2 INCOMPLETE.)
Task: `[P10-T9]`
Command: (derivation only; no command executed)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: 43 identifiers enumerated, AC-01 through AC-43. **Complete: 43. INCOMPLETE: 0.**
The identifiers in the INCOMPLETE group: none. Every identifier is backed by at least one named
evidence artifact that exists on disk and carries all four required fields, every identifier is
checked off in `spec.md`, and no identifier is checked off without complete evidence. No evidence
artifact records `EXIT_CODE: PENDING-CI`. Verdict: **PASS**.

Evidence root, for the absolute paths abbreviated below as `<E>`:

    C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5/docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/evidence

Every artifact named below was re-checked for all four required fields in this reconciliation pass,
by enumerating every `.md` file under `<E>` and counting its `Timestamp:`, `Command:`, `EXIT_CODE:`,
and `Output Summary:` lines. **All 63 artifacts under `<E>` carry all four fields; none is missing
any field.** The enumeration also confirmed that no artifact carries `EXIT_CODE: PENDING-CI`.

## The 43 identifiers

| ID | Evidence artifact(s) | Recorded `EXIT_CODE:` | State | `spec.md` |
| --- | --- | --- | --- | --- |
| AC-01 | `<E>/qa-gates/gate-ac01-source-guard.2026-09-08T10-45.md` (gate of record); `<E>/qa-gates/gate-ac01-source-guard.2026-09-08T10-30.md` (superseded) | 0; 0 | complete | `[x]` |
| AC-02 | `<E>/qa-gates/gate-ac02-ac03-ac04-dispatch.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-03 | `<E>/qa-gates/gate-ac02-ac03-ac04-dispatch.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-04 | `<E>/qa-gates/gate-ac02-ac03-ac04-dispatch.2026-09-08T10-30.md`; `<E>/qa-gates/gate-ac04-usage-manifest-override.2026-09-08T10-30.md` | 0; 0 | complete | `[x]` |
| AC-05 | `<E>/qa-gates/gate-ac05-jq-127.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-06 | `<E>/qa-gates/gate-ac06-manifest-rejected.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-07 | `<E>/qa-gates/gate-ac07-ac09-ac10-ac12.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-08 | `<E>/qa-gates/gate-ac08-untracked-staged.2026-09-08T10-30.md`; `<E>/regression-testing/fail-before-untracked.2026-09-08T09-49.md` | 0; 1 (`ExpectedExitCode: 1`) | complete | `[x]` |
| AC-09 | `<E>/qa-gates/gate-ac07-ac09-ac10-ac12.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-10 | `<E>/qa-gates/gate-ac07-ac09-ac10-ac12.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-11 | `<E>/qa-gates/gate-ac11-index-verbatim.2026-09-08T10-45.md` | 0 | complete | `[x]` |
| AC-12 | `<E>/qa-gates/gate-ac07-ac09-ac10-ac12.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-13 | `<E>/qa-gates/gate-ac13-index-created.2026-09-08T10-45.md` | 0 | complete | `[x]` |
| AC-14 | `<E>/qa-gates/gate-ac14-index-duplicate.2026-09-08T10-45.md` | 0 | complete | `[x]` |
| AC-15 | `<E>/qa-gates/gate-ac15-ac17-eol.2026-09-08T11-05.md` | 0 | complete | `[x]` |
| AC-16 | `<E>/qa-gates/gate-ac16-stale-advisory.2026-09-08T11-05.md`; `<E>/regression-testing/fail-before-stale-eol.2026-09-08T09-49.md` | 0; 1 (`ExpectedExitCode: 1`) | complete | `[x]` |
| AC-17 | `<E>/qa-gates/gate-ac15-ac17-eol.2026-09-08T11-05.md` | 0 | complete | `[x]` |
| AC-18 | `<E>/qa-gates/gate-ac18-ac19-eol.2026-09-08T11-05.md` | 0 | complete | `[x]` |
| AC-19 | `<E>/qa-gates/gate-ac18-ac19-eol.2026-09-08T11-05.md` | 0 | complete | `[x]` |
| AC-20 | `<E>/qa-gates/gate-ac20-crlf-fixture.2026-09-08T09-49.md`; `<E>/qa-gates/gate-ac20-crlf-index-blob.2026-09-08T09-49.md` | 0; 0 | complete | `[x]` |
| AC-21 | `<E>/qa-gates/gate-ac21-gitattributes.2026-09-08T09-49.md` | 0 | complete | `[x]` |
| AC-22 | `<E>/qa-gates/gate-ac22-host-token-hard-stop.2026-09-08T11-25.md`; `<E>/regression-testing/fail-before-host-token.2026-09-08T09-49.md` | 0; 1 (`ExpectedExitCode: 1`) | complete | `[x]` |
| AC-23 | `<E>/qa-gates/gate-ac23-ac24-patterns.2026-09-08T11-25.md` | 0 | complete | `[x]` |
| AC-24 | `<E>/qa-gates/gate-ac23-ac24-patterns.2026-09-08T11-25.md` | 0 | complete | `[x]` |
| AC-25 | `<E>/qa-gates/gate-ac25-ac27-scan-scope.2026-09-08T11-25.md` | 0 | complete | `[x]` |
| AC-26 | `<E>/qa-gates/gate-ac26-scan-malformed.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-27 | `<E>/qa-gates/gate-ac25-ac27-scan-scope.2026-09-08T11-25.md`; `<E>/qa-gates/gate-pattern-set-identifier.2026-09-08T11-25.md` | 0; 0 | complete | `[x]` |
| AC-28 | `<E>/qa-gates/gate-ac28-field-matrix.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-29 | `<E>/qa-gates/gate-ac29-ac30-ac31-outcomes.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-30 | `<E>/qa-gates/gate-ac29-ac30-ac31-outcomes.2026-09-08T10-30.md`; `<E>/qa-gates/gate-no-force-flag.2026-09-08T10-30.md` | 0; 0 | complete | `[x]` |
| AC-31 | `<E>/qa-gates/gate-ac29-ac30-ac31-outcomes.2026-09-08T10-30.md` | 0 | complete | `[x]` |
| AC-32 | `<E>/qa-gates/gate-ac32-stub-replays.2026-09-08T09-49.md` | 0 | complete | `[x]` |
| AC-33 | `<E>/qa-gates/gate-ac33-skill-record.2026-09-08T11-40.md` | 0 | complete | `[x]` |
| AC-34 | `<E>/qa-gates/gate-ac34-pushdown-byte-identity.2026-09-08T11-40.md` | 0 | complete | `[x]` |
| AC-35 | `<E>/qa-gates/gate-ac35-pushdown-contracts.2026-09-08T11-40.md`; `<E>/qa-gates/final-qc-pushdown.2026-09-08T12-10.md`; `<E>/baseline/baseline-pushdown-parity.2026-09-08T09-49.md` | 0; 0; 0 | complete | `[x]` |
| AC-36 | `<E>/qa-gates/gate-ac36-lib-untouched.2026-09-08T11-55.md` | 0 | complete | `[x]` |
| AC-37 | `<E>/qa-gates/gate-ac37-hooks-untouched.2026-09-08T11-55.md` | 0 | complete | `[x]` |
| AC-38 | `<E>/qa-gates/gate-ac38-line-caps.2026-09-08T12-10.md` (gate of record); `<E>/qa-gates/gate-ac38-line-caps.2026-09-08T11-55.md` (superseded); `<E>/qa-gates/gate-library-line-cap.2026-09-08T10-30.md` | 0; 0; 0 | complete | `[x]` |
| AC-39 | `<E>/qa-gates/final-qc-single-pass.2026-09-08T12-10.md`; `<E>/qa-gates/final-qc-format.2026-09-08T12-10.md`; `<E>/qa-gates/final-qc-check.2026-09-08T12-10.md`; `<E>/qa-gates/final-qc-test.2026-09-08T12-10.md`; `<E>/qa-gates/final-qc-preformat-tree.2026-09-08T12-10.md` | 0; 0; 0; 0; 0 | **complete** | `[x]` |
| AC-40 | `<E>/qa-gates/final-qc-coverage.2026-09-08T12-10.md`; `<E>/qa-gates/coverage-comparison.2026-09-08T12-10.md` | 0; 0 | **complete** | `[x]` |
| AC-41 | `<E>/qa-gates/gate-ac41-no-coverage-exclusion.2026-09-08T11-55.md` | 0 | complete | `[x]` |
| AC-42 | `<E>/regression-testing/fail-before-untracked.2026-09-08T09-49.md`; `<E>/regression-testing/fail-before-stale-eol.2026-09-08T09-49.md`; `<E>/regression-testing/fail-before-host-token.2026-09-08T09-49.md` | 1; 1; 1 (each `ExpectedExitCode: 1`) | complete | `[x]` |
| AC-43 | `<E>/qa-gates/gate-ac43-no-temp-files.2026-09-08T12-10.md` (gate of record); `<E>/qa-gates/gate-ac43-no-temp-files.2026-09-08T11-55.md` (superseded) | 1; 1 (each `ExpectedExitCode: 1`) | complete | `[x]` |

## The two identifiers this pass moved from INCOMPLETE to complete

**AC-39** — a single pass of format, then check, then test, with every stage exiting 0 and no file
rewritten by the format stage. All three stages are now observed on the same tree state, head SHA
`c58ac6e58dd4831530509806143f4e32212bfeb0`: format `[P10-T2]` exit 0 with two byte-identical
porcelain captures, check `[P10-T3]` exit 0 with zero bytes of output, and the full bats suite
`[P10-T4]` exit 0 at plan line `1..386` with zero `not ok` lines from run 34223163823. The
no-rewrite claim rests on the `[P10-T1]` pre-format `shfmt -d` observation of no diff hunk. Recorded
at `<E>/qa-gates/final-qc-single-pass.2026-09-08T12-10.md`.

**AC-40** — the coverage headline at or above 85.0 with `cov.xml` produced. Run 34223163823 printed
`Bash coverage (lines): 93.2%` and produced and uploaded `artifacts/pester/kcov/cov.xml`. 93.2 is at
or above 85.0. Recorded at `<E>/qa-gates/final-qc-coverage.2026-09-08T12-10.md`, with the coverage
comparison at `<E>/qa-gates/coverage-comparison.2026-09-08T12-10.md`: baseline 93.5%, post-change
93.2%, signed delta -0.3 points, per-file rates 0.906 and 0.870 for the two new modules and 1.000 for
the modified wrapper, all at or above the 85% obligation, and zero files regressed on a per-file join
of the baseline and final `cov.xml` performed by the orchestrator.

## Verification that no identifier is checked off without complete evidence

The `spec.md` acceptance-criteria section was read after the check-offs. It carries 43 identifiers,
AC-01 through AC-43, with no gaps and no duplicates; **43 are marked `[x]` and 0 are marked `[ ]`**.
Each of the 43 maps to at least one artifact above whose recorded `EXIT_CODE:` is a discharged value:
`0`, or `1` accompanied by `ExpectedExitCode: 1` for the five gates whose expected outcome is a
non-zero exit — the three fail-before records, and the two `grep`-selects-nothing scans of AC-43. No
identifier is checked off whose evidence carries `PENDING-CI`, because no artifact carries it.

## Plan checklist state, reconciled against the evidence on disk

The plan carries 104 task checkboxes. **103 are checked and 1 is unchecked.**

The single unchecked task is **`[P0-T2]`**, and it is expected to stay unchecked permanently. Its
route probe was genuinely refused rather than failed:
`<E>/baseline/baseline-git-state.2026-09-08T09-36.md` records `EXIT_CODE: 1` with
`ExpectedExitCode: 1` and an `Output Summary:` beginning `ROUTE REFUSED`, which is precisely the
branch the task text itself defines for that outcome, and the task text directs that the task be left
unchecked and the refusal reported. Both were done, and the substitution route is recorded at the
orchestration level. **No acceptance criterion depends on `[P0-T2]`.**

Every other task in Phases 0 through 10 is checked and each is backed by the artifact its own
acceptance text names.

## Evidence added or refreshed after CI round C, recorded so the audit is not surprised

- **Nineteen gate artifacts discharged from round C.** Every artifact that carried
  `EXIT_CODE: PENDING-CI` at that point was updated in place with the round C result, the run URL,
  the plan line `1..375`, the statement that the run carried zero `not ok` lines, and the verbatim
  `ok N <name>` line for each test the gate names, read from the run log rather than paraphrased.
  The three that complete a fail-before record additionally state the red-to-green transition, citing
  run 34213641449 for the red state and run 34219866134 for the green state.
- **Four artifacts discharged from the final round, in this pass.** `[P10-T4]`, `[P10-T5]`,
  `[P10-T6]`, and `[P10-T7]` were the last four holding `EXIT_CODE: PENDING-CI`. Each was updated in
  place with the result of run 34223163823 on head SHA `c58ac6e58dd4831530509806143f4e32212bfeb0`.
  No local toolchain command was re-run for them: `bats` and `kcov` are not installed on this host
  and the `pwsh`-wrapped WSL route is refused in this agent-isolated worktree, so no local route can
  reproduce either stage, and the CI values are the authoritative observations.
- **`[P9-T3]` and `[P9-T5]` re-run** against the file list as it stands after the
  coverage-remediation pass, producing `<E>/qa-gates/gate-ac38-line-caps.2026-09-08T12-10.md` and
  `<E>/qa-gates/gate-ac43-no-temp-files.2026-09-08T12-10.md`. Both supersede their 11-55
  predecessors, which remain valid for the trees they measured. The `[P9-T5]` re-run also closed a
  pre-existing enumeration gap: the earlier artifact named only the first suite file, omitting the
  second created at `[P5-T9]`.
- **`[P9-T4]` re-verified.** Its anchored diff of `scripts/bash/shell_qc_lib.sh`,
  `scripts/bash/shell-qc.sh`, and `.github/workflows/_shell-coverage.yml` against
  `epic/cleanup-merged-worktrees-hardening-integration` printed nothing and exited 0 after the
  remediation, so `<E>/qa-gates/gate-ac41-no-coverage-exclusion.2026-09-08T11-55.md` remains accurate
  and no new artifact was needed. The remediation added no `exclude` entry of any kind, which the
  final round's per-file `cov.xml` corroborates: both new production libraries appear in the coverage
  denominator with their own `line-rate` entries.
- **`<E>/other/coverage-remediation-decision.2026-09-08T12-10.md`** records the per-module coverage
  finding, the eleven tests added to address it, the per-test line attribution, and the evidence that
  two of the three uncovered clusters are literal-data lines that no test can execute. Its projected
  post-remediation rate of 0.906 for `scripts/bash/cleanup_worktrees_preserve_lib.sh` matches the
  observed final rate exactly.

Verdict: **PASS.** 43 of 43 identifiers complete, 0 INCOMPLETE, 103 of 104 plan tasks checked, and
the single unchecked task is the permanently-refused route probe `[P0-T2]`, which no acceptance
criterion depends on.
