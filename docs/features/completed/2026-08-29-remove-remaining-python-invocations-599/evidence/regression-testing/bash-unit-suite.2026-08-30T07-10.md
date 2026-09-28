# Regression — bash lane-assertion unit suite ([P2-T10])

Timestamp: 2026-08-30T07-10

Command:

```
wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_lane_assertion.bats'
```

EXIT_CODE: 0

Output Summary:

Plan line `1..16`, sixteen `ok` lines, no line beginning `not ok`. The plan's
floor for this task is a plan line of `1..16` or higher; the observed value is
exactly `1..16`, which is the six cases added by P1-T1 through P1-T6, the three
added by P2-T1, and one each from P2-T2 through P2-T8.

```
1..16
ok 1 the library declares the four finding-class tokens
ok 2 parse_edges keeps input order and drops malformed tokens
ok 3 read_manifest_inputs skips malformed entries without raising
ok 4 derive_components partitions declared keys deterministically
ok 5 compare emits findings in the fixed class order
ok 6 format_report renders the header, findings, and closing line
ok 7 the entry point resolves its own directory before sourcing
ok 8 the entry point calls pc_enforce_c_locale before any output is produced
ok 9 the entry point establishes set -euo pipefail as its first executable line
ok 10 the entry point exits 2 only on a usage error
ok 11 the entry point rejects a --keys flag
ok 12 an unreadable manifest prints the unreadable line and exits 0
ok 13 an unparseable manifest prints the M1 error and exits 0
ok 14 an out-of-subset manifest prints the refusal line and exits 0
ok 15 the port drops an --edges endpoint outside the strict integer lexis
ok 16 no library file sources the diagnostic
```

Scope note. This is a single-file `bats` invocation and not
`bash scripts/bash/shell-qc.sh test`. Ordering Constraint 1 of the plan applies:
`tests/shell/parallel_bash_manifest_membership.bats` requires every repository
`.claude/lib/bash/*.sh` file to carry a `core.json` entry and a byte-identical
bundle counterpart, and neither `parallel-lane-assertion.sh` (Phase 1) nor
`report-lane-assertion.sh` (Phase 2) is mirrored or registered until P4-T2 and
P4-T3. A whole-tree run here would fail for that reason, which is unrelated to
the suite under test. The first whole-tree run is P4-T9.
