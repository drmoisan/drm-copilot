# Final acceptance-criteria check-off — remediation cycle 1 — [P4-T8]

Timestamp: 2026-09-07T20-23
Task: [P4-T8]
AC source file: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
Work Mode: `full-bug` (from `issue.md` line 12), so `spec.md` is the sole AC source; `user-story.md`
is not an AC source under that mode.
EXIT_CODE: 0

## 1. Ordering precondition

The plan forbids performing this task before `[P4-T4]`, `[P4-T6]`, and `[P4-T7]` have all passed.
All three are checked off in the canonical plan before this task ran:

| Task | State | Artifact |
|---|---|---|
| `[P4-T4]` final test stage | passed | `evidence/qa-gates/final-poshqc-test.2026-09-07T20-08.md` |
| `[P4-T6]` per-file coverage | passed, not blocked | `evidence/qa-gates/final-per-file-coverage.2026-09-07T20-21.md` |
| `[P4-T7]` coverage delta | passed on both copies | `evidence/qa-gates/final-coverage-delta.2026-09-07T20-22.md` |

## 2. Criteria checked off

### AC-07 — trigger literals byte-unchanged (first line begins `The five trigger pattern strings`)

- State change: `- [ ]` to `- [x]`
- Location at check-off time: `spec.md` line 1480
- Discharging evidence: `[P3-T1]` performed the amendment to this criterion, and `[P3-T2]` proved
  that R-2 changed no code and deleted no frozen literal. Recorded at
  `evidence/qa-gates/r2-no-code-change.2026-09-07T20-02.md`. The criterion's own supporting record,
  cited inside the criterion text, is
  `evidence/qa-gates/trigger-literals-byte-unchanged.2026-09-07T15-50.md` §4, which covers the
  pr-author expressions that the amendment marks superseded.

### AC-09 — no existing denial is weakened (first line begins `**No existing denial is weakened.**`)

- State change: `- [ ]` to `- [x]`
- Location at check-off time: `spec.md` line 1499
- Discharging evidence: `[P4-T4]`, recorded at
  `evidence/qa-gates/final-poshqc-test.2026-09-07T20-08.md`. That artifact records the final test
  stage green on all four `validate-bash` suites at the required counts — `validate-bash.Tests.ps1`
  26/0/0, `validate-bash.TriggerScoping.Tests.ps1` 12/0/0,
  `validate-bash-decision-surface.Tests.ps1` 37/0/0, and
  `validate-bash-trigger-scoping.Tests.ps1` 8/0/0 — with all ten new pinning cases (`R1-C1` through
  `R1-C5` and `R1-X1` through `R1-X5`) carrying `status="Passed"`. The 26 pre-existing
  `validate-bash.Tests.ps1` cases and the 7 pre-existing
  `validate-bash.TriggerScoping.Tests.ps1` cases are still green: 12 minus the 5 new `R1-C` cases
  leaves exactly the 7 pre-existing cases, and no pre-existing case appears in the failing set. The
  only failures across both folders are the two tolerated pre-existing ambient cases named in the
  plan preamble, which are outside the four suites above.

## 3. Criterion deliberately left unchecked

### AC-22 — issue #591 recorded as superseded (first line begins `**Issue #591 is recorded as superseded`)

- State: remains `- [ ]`
- Location at check-off time: `spec.md` line 1565
- Reason: the criterion closes on `pr-author`, which is out of this plan's scope. Its closure
  condition depends on the pull-request body, which does not exist yet. Checking it now would
  assert an outcome for which no evidence exists.

## 4. Line-number drift note

The plan cites the second criterion at line 1488 and the third at line 1554. Their actual locations
are 1499 and 1565. The difference of 11 lines is accounted for by the `[P3-T1]` amendment, which
lengthened the AC-07 criterion at line 1480 and shifted every following line down by the same
amount. The plan identifies all three criteria by their verbatim first-line literal in addition to
the line number, and each literal matched exactly one line, so the identification is unambiguous
and the drift changes no target.

## 5. Acceptance verification

All three commands run from the repository root with the path spelled as the plan gives it. The
`-e` is required rather than stylistic: each pattern's first character is `-`, so without `-e` GNU
grep parses the pattern as an option bundle and exits 2 regardless of file content, which would
make the conditions unfalsifiable.

```
grep -F -c -e "- [x] The five trigger pattern strings" docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
```
Output: `1`   EXIT_CODE: 0

```
grep -F -c -e "- [x] **No existing denial is weakened.**" docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
```
Output: `1`   EXIT_CODE: 0

```
grep -F -c -e "- [ ] **Issue #591 is recorded as superseded" docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
```
Output: `1`   EXIT_CODE: 0

All three required values are `1`. The first two literals were absent from `spec.md` before this
task and this task created them; the third was present before this task and survived it.

## 6. Text preservation

Only the three characters between the brackets on lines 1480 and 1499 changed, from a space to `x`.
No criterion text was modified, no criterion was added, and no criterion was removed.

## Output Summary

Checked off two acceptance criteria in `spec.md`: AC-07 (trigger literals byte-unchanged, line
1480), discharged by `[P3-T1]` and `[P3-T2]`; and AC-09 (no existing denial weakened, line 1499),
discharged by `[P4-T4]` at counts 26/0/0, 12/0/0, 37/0/0, 8/0/0 with all ten new pinning cases
passing. Left AC-22 (issue #591 superseded, line 1565) unchecked because it closes on `pr-author`
and the pull-request body does not yet exist. All three acceptance greps returned `1` with
EXIT_CODE 0.
