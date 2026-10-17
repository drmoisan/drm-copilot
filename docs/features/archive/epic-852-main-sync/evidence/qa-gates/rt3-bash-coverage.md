# RT-3 bash Coverage (CI kcov artifact)

Timestamp: 2026-10-11T01-44
Task: [P3-T2]
Command: Grep artifacts/pester/kcov/cov.xml pattern `line-rate=["'][0-9.]+["']` (head limit 1); Read docs/features/active/epic-852-main-sync/evidence/other/rt3-ci-run.md for `ShellCoverageJobConclusion:`
EXIT_CODE: 0

- cov.xml path (resolved in [P0-T4]): `artifacts/pester/kcov/cov.xml`
- First match (line 3, root `<coverage>` element): `line-rate="0.945"`
- Raw line-rate: 0.945
- Line percent (line-rate * 100, 2 decimals): 94.50
- Root element counters (informational): `lines-covered="3049" lines-valid="3225"`
- ShellCoverageJobConclusion: success
- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38112992719
- Head SHA: d1211a7aebefe9648e16542919027587544ee153
- [P3-T1] head qualification: passed (all four exit codes 0; SHAs match)
- Branch threshold: not applicable to bash (kcov measures line coverage only).

Output Summary: bash line coverage 94.50% (line-rate 0.945; 3049/3225) >= 85.00; shell-coverage job conclusion success; head qualification passed.

RT-3 VERDICT: PASS
