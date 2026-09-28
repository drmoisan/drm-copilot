# P6-T5 — Per-file coverage for the two new bash files

Timestamp: 2026-08-30T20-45

Command:

```
wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && grep -n -F -e parallel-lane-assertion.sh -e report-lane-assertion.sh artifacts/pester/kcov/cov.xml'
```

EXIT_CODE: 0

Output Summary — every matching line, verbatim:

```
1268:				<class name="parallel_lane_assertion_sh__30" filename=".claude/lib/bash/parallel-lane-assertion.sh" branch-rate="1.0" complexity="1.0" line-rate="0.989">
1717:				<class name="report_lane_assertion_sh__34" filename=".claude/lib/bash/report-lane-assertion.sh" branch-rate="1.0" complexity="1.0" line-rate="0.949">
```

`line-rate` values read directly from those two lines:

| File | `line-rate` | Threshold | Result |
| --- | --- | --- | --- |
| `.claude/lib/bash/parallel-lane-assertion.sh` | 0.989 | >= 0.85 | PASS |
| `.claude/lib/bash/report-lane-assertion.sh` | 0.949 | >= 0.85 | PASS |

Acceptance: satisfied. The command exits 0; both files are named; both `line-rate` values are
at or above 0.85.

## No coverage exclusion applies to either file

Neither file appears in any coverage exclusion, and no per-file exclusion mechanism exists on
the bash path. The kcov exclude pattern is `$repo_root/tests` only
(`scripts/bash/shell_qc_lib.sh:336`) and the include pattern is the three directory roots
`tools`, `scripts`, and `.claude/lib/bash` (`:335`). Both new files are under
`.claude/lib/bash`, so both are inside the include set and outside the exclude set.

## Blocking finding raised on the first run, and its remediation

The first run of this task recorded:

```
1717:				<class name="report_lane_assertion_sh__34" filename=".claude/lib/bash/report-lane-assertion.sh" branch-rate="1.0" complexity="1.0" line-rate="0.814">
```

0.814 is below the 0.85 threshold, which the task defines as a blocking finding. It was
investigated rather than accepted, and the investigation is recorded here because the remedy
was a test addition rather than a production change.

**The uncovered lines.** Reading the `<line number= hits=>` entries under the
`report_lane_assertion_sh__34` class, the entries carrying `hits="0"` were lines
50, 51, 57, 58, 68, 100, 101, 109, 110, 116, 117, 126, 127, 148, and 150 of
`.claude/lib/bash/report-lane-assertion.sh`. Excluding the four comment and heredoc-body lines
(50, 51, 57, 58), the remainder are exactly the argument-dispatch arms of `rla_main` and the
out-of-subset refusal:

| Lines | Construct |
| --- | --- |
| 100, 101 | `--manifest` present with no value: `rla_usage >&2` / `return 2` inside `|| { ... }` |
| 109, 110 | `--edges` present with no value: same shape |
| 116, 117 | `--help \| -h` case body: `rla_usage` / `return 0` |
| 126, 127 | absent `--manifest`: `rla_usage >&2` / `return 2` inside `|| { ... }` |
| 148, 150 | out-of-subset refusal `printf` and its `return 0` |
| 68 | `file is not readable` branch of `rla_manifest_unreadable_detail` |

**Why this was an attribution defect and not a testing gap.** Every one of those behaviours was
already exercised and asserted by `tests/shell/parallel_lane_assertion.bats`, and every one of
those cases passed on the same run that reported the lines as unhit — for example
`the entry point exits 2 only on a usage error` (line 276) drives `--help`, an absent
`--manifest`, and no-arguments; `an out-of-subset manifest prints the refusal line and exits 0`
(line 363) drives the refusal path. Those cases invoke the entry point as a subprocess
(`run bash "$(ENTRY_POINT)" ...`), which is the correct shape for asserting a CLI contract's
process exit status. kcov's bash line attribution does not credit lines inside `|| { ...; }`
brace groups or inside `case` branch bodies when the traced script is reached that way.

The diagnosis was confirmed by measurement, not by inference. An unmerged kcov run over the
sibling suite alone reproduced `line-rate="0.814"` exactly, ruling out the report-merge step as
the cause:

```
kcov --include-pattern=<repo>/.claude/lib/bash --exclude-pattern=<repo>/tests <out> bats tests/shell/parallel_lane_assertion.bats
  -> filename="report-lane-assertion.sh" line-rate="0.814"
```

**The remediation.** A second bats suite,
`tests/shell/report_lane_assertion_dispatch.bats` (14 cases), was added in the same directory.
It sources the entry point through its own `BASH_SOURCE[0] == "${0}"` guard — which defines
`rla_usage`, `rla_manifest_unreadable_detail`, `rla_report`, and `rla_main` without running
anything — and then calls `rla_main` in process. The dispatch arms are then both executed and
attributed. Measured alone, that suite reports the file at `line-rate="0.898"`; merged with the
sibling suite, the file reports `line-rate="0.949"`, recorded above.

The new suite asserts the same observable behaviour as the subprocess cases (return status, and
the content of the usage and report lines) and is **additional to** them, not a replacement:
the subprocess cases remain the authority for the process exit status and for which stream the
usage text reaches, which an in-process call cannot certify.

A second file was created rather than extending the sibling suite because
`tests/shell/parallel_lane_assertion.bats` stood at 458 lines against the 500-line cap in
`.claude/rules/general-code-change.md`. The plan's own recorded remedy for that cap (P6-T19)
is to split along `@test` group boundaries into a second bats file in the same directory.
`scripts/bash/shell-qc.sh test` enumerates test directories rather than individual files, so the
new suite is picked up by the existing gate with no configuration change.

No file under `.claude/lib/bash/` was modified by this remediation. The production behaviour
measured before and after is identical; only the measurement's fidelity changed.
