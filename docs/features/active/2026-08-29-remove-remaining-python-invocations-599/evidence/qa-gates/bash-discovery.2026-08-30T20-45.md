# P6-T3 — Both new bash files are inside the shell-QC discovery set

Timestamp: 2026-08-30T20-45

Command:

```
wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash -c "source scripts/bash/shell_qc_lib.sh; discover_shell_scripts" | grep -c -F -e .claude/lib/bash/parallel-lane-assertion.sh -e .claude/lib/bash/report-lane-assertion.sh'
```

EXIT_CODE: 0

Output Summary:

```
2
```

Acceptance: satisfied. The command printed `2` and exited 0.

Supporting observation — the full discovered set under the `.claude/lib/bash` root, showing both
new files present with the root-relative spellings the acceptance asserts:

```
.claude/lib/bash/compute-cohorts.sh
.claude/lib/bash/compute-concurrency-batches.sh
.claude/lib/bash/parallel-cohorts.sh
.claude/lib/bash/parallel-common.sh
.claude/lib/bash/parallel-items-validate.sh
.claude/lib/bash/parallel-lane-assertion.sh
.claude/lib/bash/parallel-manifest-validate.sh
.claude/lib/bash/parallel-yaml-emit.sh
.claude/lib/bash/parallel-yaml-scan.sh
.claude/lib/bash/report-lane-assertion.sh
.claude/lib/bash/validate-parallel-manifest.sh
```

This is what makes the P6-T1 and P6-T2 gates load-bearing for this feature's two new files
rather than vacuous: both files are inside the set those gates format and lint.
