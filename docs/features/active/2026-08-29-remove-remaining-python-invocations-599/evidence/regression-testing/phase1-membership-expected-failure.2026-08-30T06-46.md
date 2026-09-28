# Phase 1 end state: predicted membership-suite failure and sibling-suite check

Timestamp: 2026-08-30T06-46

## Predicted failure (Ordering Constraint 1)

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_bash_manifest_membership.bats'`

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary: 6 cases planned; cases 3 and 4 fail, both naming
`parallel-lane-assertion.sh`; cases 1, 2, 5, and 6 pass. This is the outcome
Ordering Constraint 1 predicts for the interval between Phase 1 creating the
library and Phase 4 registering it in `core.json` and mirroring it into the
bundle. Verbatim output:

```
1..6
ok 1 the repository bash library meets the discovery floor
ok 2 the core pack manifest exists and is readable
not ok 3 every repository bash library file has a core.json entry
# (in test file tests/shell/parallel_bash_manifest_membership.bats, line 49)
#   `return 1' failed
# missing core.json entry: .claude/lib/bash/parallel-lane-assertion.sh
not ok 4 every repository bash library file has a byte-identical bundled counterpart
# (in test file tests/shell/parallel_bash_manifest_membership.bats, line 62)
#   `return 1' failed
# missing bundled counterpart: parallel-lane-assertion.sh
ok 5 the bundled tree carries no bash library file the repository lacks
ok 6 the three CLI entry points are present in both trees
```

The two failure messages name only the new file, so the failure is attributable
to this feature's Phase 1 addition and to nothing else. Both are closed by
Phase 4: P4-T2 mirrors the file and the `core.json` registration follows.

Per Ordering Constraint 1, no whole-tree `shell-qc.sh test` run was performed in
this phase. The first whole-tree run is P4-T9.

## Sibling-suite regression check

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bats tests/shell/parallel_payload_only.bats tests/shell/parallel_manifest_validate.bats tests/shell/parallel_yaml_subset.bats tests/shell/parallel_common.bats tests/shell/test_shell_qc_discovery.bats'`

EXIT_CODE: 0

Output Summary: TAP plan line `1..95`; zero lines beginning `not ok`. The five
suites that exercise the surfaces this phase's new file sources or is discovered
by are unaffected. This is a targeted run, not a whole-tree run.
