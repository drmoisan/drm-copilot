# CI Record: Remediation Cycle 1 (#1182)

Timestamp: 2026-11-14T16-56
Command: gh run view 43615945680 --json jobs (workflow CI, event pull_request, head of the code commit "fix(hooks): decline non-receipt absolute paths before listing worktrees")
EXIT_CODE: 0
Output Summary:
- Full run on the code head (the commit that carries the prefilter, the bundle mirror, and the new test rows): run 43615945680, conclusion success. Change scope = success; poshqc / PowerShell QC = success; poshqc / PowerShell hook suites (Linux) = success; poshqc / PowerShell QC shard 1, shard 2, shard 3, and static = success; CI Required Gate = success.
- The earlier run on the phase 1 head (run 43613917646) failed by design: that head held the [expect-fail] row without the prefilter.
- The run on the later evidence-only head (run 43618002343) was still in progress at the time of this record; that head changes only files under the feature folder.
