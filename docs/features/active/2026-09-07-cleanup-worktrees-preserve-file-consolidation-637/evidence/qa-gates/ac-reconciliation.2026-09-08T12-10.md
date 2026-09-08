# Final QC — `[P10-T9]`, the acceptance-criteria reconciliation

Timestamp: 2026-09-08T12-10
Task: `[P10-T9]`
Command: (derivation only; no command executed)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: 43 identifiers enumerated, AC-01 through AC-43. **Complete: 41.** **INCOMPLETE: 2 —
AC-39 and AC-40**, both blocked on evidence that is `EXIT_CODE: PENDING-CI`. Every complete
identifier is checked off in `spec.md` and no identifier is checked off without complete evidence.
The two INCOMPLETE identifiers are unchecked. The verdict is therefore **blocked pending the final
CI round**, not PASS.

Evidence root, for the absolute paths abbreviated below as `<E>`:

    C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a817693674107cbe5/docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/evidence

Every artifact named below was checked for all four required fields. **Every one carries
`Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.** No artifact is missing a field.

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
| AC-39 | `<E>/qa-gates/final-qc-single-pass.2026-09-08T12-10.md`; `<E>/qa-gates/final-qc-format.2026-09-08T12-10.md`; `<E>/qa-gates/final-qc-check.2026-09-08T12-10.md`; `<E>/qa-gates/final-qc-test.2026-09-08T12-10.md`; `<E>/qa-gates/final-qc-preformat-tree.2026-09-08T12-10.md` | **PENDING-CI**; 0; 0; **PENDING-CI**; 0 | **INCOMPLETE** | `[ ]` |
| AC-40 | `<E>/qa-gates/final-qc-coverage.2026-09-08T12-10.md`; `<E>/qa-gates/coverage-comparison.2026-09-08T12-10.md` | **PENDING-CI**; **PENDING-CI** | **INCOMPLETE** | `[ ]` |
| AC-41 | `<E>/qa-gates/gate-ac41-no-coverage-exclusion.2026-09-08T11-55.md` | 0 | complete | `[x]` |
| AC-42 | `<E>/regression-testing/fail-before-untracked.2026-09-08T09-49.md`; `<E>/regression-testing/fail-before-stale-eol.2026-09-08T09-49.md`; `<E>/regression-testing/fail-before-host-token.2026-09-08T09-49.md` | 1; 1; 1 (each `ExpectedExitCode: 1`) | complete | `[x]` |
| AC-43 | `<E>/qa-gates/gate-ac43-no-temp-files.2026-09-08T12-10.md` (gate of record); `<E>/qa-gates/gate-ac43-no-temp-files.2026-09-08T11-55.md` (superseded) | 1; 1 (each `ExpectedExitCode: 1`) | complete | `[x]` |

## The two INCOMPLETE identifiers, with the reason for each

**AC-39** requires a single pass of format, then check, then test with every stage exiting 0. Two of
the three stages are discharged: `[P10-T2]` format exited 0 and `[P10-T3]` check exited 0, both
within one uninterrupted iteration, and the format stage rewrote no file. The third stage,
`[P10-T4]`, is `EXIT_CODE: PENDING-CI` because `bats` is not installed on this host and the
`pwsh`-wrapped WSL route is refused in this agent-isolated worktree. The local run of that stage
prints `bats not installed; skipping shell tests.` and returns 0 without executing a test; that
exit code is a false pass and was deliberately not recorded as the gate result.

**AC-40** requires the coverage headline and a value of at least 85.0. Neither `bats` nor `kcov` is
installed here and the local run returns 127 with no `cov.xml` produced, so no headline exists to
record. `[P10-T6]` and the dependent `[P10-T7]` are both `EXIT_CODE: PENDING-CI`.

Both become checkable from the final CI round with no further work in this worktree.

## Verification that no identifier is checked off without complete evidence

The `spec.md` acceptance-criteria section was read after the check-offs. It carries 43 identifiers,
41 marked `[x]` and 2 marked `[ ]`, and the 2 unchecked are exactly AC-39 and AC-40. Each of the 41
checked identifiers maps to at least one artifact above whose recorded `EXIT_CODE:` is a discharged
value: `0`, or `1` accompanied by `ExpectedExitCode: 1` for the four gates whose expected outcome is
a non-zero exit (the three fail-before records and the two `grep`-selects-nothing scans of AC-43).
No identifier is checked off whose evidence carries `PENDING-CI`.

## Evidence added or refreshed after CI round C, recorded so the audit is not surprised

- **Nineteen gate artifacts discharged.** Every artifact that carried `EXIT_CODE: PENDING-CI` was
  updated in place with the round C result, the run URL, the plan line `1..375`, the statement that
  the run carried zero `not ok` lines, and the verbatim `ok N <name>` line for each test the gate
  names, read from the run log rather than paraphrased. The three that complete a fail-before record
  additionally state the red-to-green transition, citing run 34213641449 for the red state and run
  34219866134 for the green state.
- **`[P9-T3]` and `[P9-T5]` re-run** against the file list as it stands after the
  coverage-remediation pass, producing
  `<E>/qa-gates/gate-ac38-line-caps.2026-09-08T12-10.md` and
  `<E>/qa-gates/gate-ac43-no-temp-files.2026-09-08T12-10.md`. Both supersede their 11-55
  predecessors, which remain valid for the trees they measured. The `[P9-T5]` re-run also closes a
  pre-existing enumeration gap: the earlier artifact named only the first suite file, omitting the
  second created at `[P5-T9]`.
- **`[P9-T4]` re-verified.** `git diff epic/cleanup-merged-worktrees-hardening-integration --
  scripts/bash/shell_qc_lib.sh scripts/bash/shell-qc.sh .github/workflows/_shell-coverage.yml`
  printed nothing and exited 0 after the remediation, so
  `<E>/qa-gates/gate-ac41-no-coverage-exclusion.2026-09-08T11-55.md` remains accurate and no new
  artifact was needed. The remediation added no `exclude` entry of any kind.
- **`<E>/other/coverage-remediation-decision.2026-09-08T12-10.md`** records the per-module coverage
  finding, the eleven tests added to address it, the per-test line attribution, and the evidence
  that two of the three uncovered clusters are literal-data lines that no test can execute.

## `[P0-T2]`, recorded rather than tidied away

`[P0-T2]` remains unchecked and is expected to stay unchecked permanently. Its route probe was
genuinely refused; `<E>/baseline/baseline-git-state.2026-09-08T09-36.md` records
`EXIT_CODE: 1` with `ExpectedExitCode: 1` and an `Output Summary:` beginning `ROUTE REFUSED`, which
is the branch the task text itself defines for that outcome. The substitution is recorded at the
orchestration level. No acceptance criterion depends on it.
