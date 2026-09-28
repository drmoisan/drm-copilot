# P4-T9 — whole-tree bash suite, first run since Phase 0

Timestamp: 2026-08-30T07-55

Command:
`wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash scripts/bash/shell-qc.sh test'`

EXIT_CODE: 0

Output Summary:

- TAP plan line: `1..276`.
- Lines beginning `not ok`: 0. Zero bats failures.
- Trailing `SHELL_QC_TEST_RC=0` captured inside the WSL command confirms the subcommand's own status
  rather than the status of the capture wrapper.
- The run emitted four `BW01` bats warnings from `tests/shell/test_shell_qc_commands.bats` lines 36,
  47, 106, and 113. These are pre-existing advisory warnings about `run` invocations that exit 127
  by design in tool-missing fixtures. They are not failures and do not affect the exit code; they
  are unrelated to this feature.

## Ordering Constraint 1 is discharged here

Phases 1 through 3 could not run the whole tree, because
`tests/shell/parallel_bash_manifest_membership.bats` failed for as long as
`.claude/lib/bash/parallel-lane-assertion.sh` had no `core.json` entry and no bundled counterpart.
After P4-T2 mirrored both new files and P4-T3 registered both in `core.json`, that suite passes:

```
1..6
ok 1 the repository bash library meets the discovery floor
ok 2 the core pack manifest exists and is readable
ok 3 every repository bash library file has a core.json entry
ok 4 every repository bash library file has a byte-identical bundled counterpart
ok 5 the bundled tree carries no bash library file the repository lacks
ok 6 the four CLI entry points are present in both trees
```

Cases 3 and 4 are the two that were failing. Both now pass. Each returns 1 on the first offending
basename, so during Phases 1 through 3 only `parallel-lane-assertion.sh` was ever named even though
two files were outstanding; mirroring and registering both was required, and mirroring only one
would have surfaced `report-lane-assertion.sh` as the next offender.

## Case-count reconciliation against the Phase 0 baseline

The Phase 0 baseline (P0-T3) recorded 251 bats cases. This run reports 276, a delta of +25, fully
accounted for by cases this feature added:

| Suite | Cases | Origin |
|---|---|---|
| `tests/shell/parallel_lane_assertion.bats` | 16 | new file, Phases 1 and 2 |
| `tests/shell/parallel_lane_assertion_parity.bats` | 8 | new file, Phase 3 |
| `tests/shell/parallel_payload_only.bats` | 11 | was 10; P4-T8 added 1 |

16 + 8 + 1 = 25. Every other suite carries the same case count it carried at baseline, including
`tests/shell/parallel_bash_manifest_membership.bats`, which stays at 6 because P4-T5 edited an
existing case rather than adding one.

No suite changed state from passing to failing. The only state change relative to the mid-plan tree
is `parallel_bash_manifest_membership.bats` returning from failing to passing.

## Supplementary coverage measurement (not part of this task's acceptance)

The P4-T9 command as written by the plan carries no `--coverage` flag, so it prints no coverage
headline and no numeric coverage value can be read from it. The plan places the coverage gate at
P6-T4 and the no-regression delta at P6-T14. The coverage-bearing variant was run separately here
only to supply the number, and its result is recorded for reference:

Command:
`wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash scripts/bash/shell-qc.sh test --coverage'`

EXIT_CODE: 0

Output Summary: `Bash coverage (lines): 91.8%` over the same `1..276` plan line with 0 lines
beginning `not ok`. Against the Phase 0 baseline of `Bash coverage (lines): 91.4%` this is a
+0.4 point movement, above the 85.0 percent floor and no regression. Three further occurrences of
the string `Bash coverage (lines): NN.N%` appear in the captured output; those are the literal
placeholder inside `tests/shell/test_shell_qc_commands.bats` assertions, not measured values.
