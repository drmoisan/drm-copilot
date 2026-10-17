# Remediation cycle 1 per-row Pester results (P5-T3)

Timestamp: 2026-10-13T15-54
Command: poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_rows_rem1_903.py <worktree>/artifacts/scratch-903/ci-rem1-903/pester-junit.xml <worktree>/artifacts/scratch-903/ci-rem1-903/pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary: Windows 10308 testcases (0 failed, 10 skipped overall); Linux 6221 testcases (0 failed, 0 skipped). All eight rows print `pass`. U26 Windows count 4 (2 data rows x 2 surfaces); Decision-suite Windows count 3.

Source: CI run https://github.com/drmoisan/drm-copilot/actions/runs/38423196404 (headSha 41d406d20de2ae850b60ee2b81e47276c1f0d4ff). Script: `artifacts/scratch-903/ps_rows_rem1_903.py`, a copy of `ps_rows_903.py` with the `ROWS` list replaced by the eight entries named in P5-T3.

```
windows testcases=10308 failed=0 skipped=10
linux testcases=6221 failed=0 skipped=0
```

| Row | Source | Windows m/f/s | Linux m/f/s | Result |
|---|---|---|---|---|
| U25 (both surfaces) | both | 10/0/0 | 10/0/0 | pass |
| U26 (both surfaces) | both | 4/0/0 | 4/0/0 | pass |
| Decision suite (every row) | both | 3/0/0 | 3/0/0 | pass |
| ES-D1 | both | 1/0/0 | 1/0/0 | pass |
| ES-D2 | both | 1/0/0 | 1/0/0 | pass |
| Discovery suite (every row) | both | 334/0/0 | 334/0/0 | pass |
| claude-hooks preimplementation-gate suites | both | 807/0/0 | 807/0/0 | pass |
| codex-hooks preimplementation-gate suites | both | 363/0/0 | 363/0/0 | pass |

Acceptance: exit 0; every row `pass`; U26 Windows `m` = 4; Decision-suite Windows `m` = 3. PASS.
