# P6-T19 — 500-line file cap over every file this feature creates

Timestamp: 2026-08-30T20-45

Command:

```
wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && wc -l .claude/lib/bash/parallel-lane-assertion.sh .claude/lib/bash/report-lane-assertion.sh tests/shell/parallel_lane_assertion.bats tests/shell/parallel_lane_assertion_parity.bats tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py tests/shell/report_lane_assertion_dispatch.bats'
```

EXIT_CODE: 0

Output, every line verbatim including the `total` line:

```
  495 .claude/lib/bash/parallel-lane-assertion.sh
  169 .claude/lib/bash/report-lane-assertion.sh
  458 tests/shell/parallel_lane_assertion.bats
  243 tests/shell/parallel_lane_assertion_parity.bats
  256 tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py
  160 tests/shell/report_lane_assertion_dispatch.bats
 1781 total
```

## Acceptance

Satisfied. `EXIT_CODE: 0`, one recorded line per file, and every per-file count is at or below
500.

| File | Lines | Cap | Headroom |
| --- | --- | --- | --- |
| `.claude/lib/bash/parallel-lane-assertion.sh` | 495 | 500 | 5 |
| `.claude/lib/bash/report-lane-assertion.sh` | 169 | 500 | 331 |
| `tests/shell/parallel_lane_assertion.bats` | 458 | 500 | 42 |
| `tests/shell/parallel_lane_assertion_parity.bats` | 243 | 500 | 257 |
| `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py` | 256 | 500 | 244 |
| `tests/shell/report_lane_assertion_dispatch.bats` | 160 | 500 | 340 |

No remedy is triggered. The cap in `.claude/rules/general-code-change.md` applies to production
code, test code, and reusable scripts alike, and all six files are inside it.

## Sixth file

The task as planned enumerates five files. A sixth,
`tests/shell/report_lane_assertion_dispatch.bats`, was created by the P6-T5 remediation recorded
in `evidence/qa-gates/bash-new-file-coverage.2026-08-30T20-45.md`. It is measured here on the
same terms, because the task's stated purpose is to measure every file this feature creates and
because no other task in this plan measures it.

Its existence is itself a consequence of this cap. `tests/shell/parallel_lane_assertion.bats`
stood at 458 lines with 42 lines of headroom, which the remediation's 14 cases would have
overrun. The plan's recorded remedy for a bats overrun is to split along `@test` group
boundaries into a second bats file in the same directory, so the remediation was written as a
second file from the outset rather than added to the sibling and then split. The two lowest
headroom values in the table above, 5 and 42, are both pre-existing and unchanged by this phase.
