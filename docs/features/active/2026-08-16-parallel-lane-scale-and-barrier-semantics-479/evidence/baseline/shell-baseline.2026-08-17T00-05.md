# Bash (Shell) Baseline via CI Dispatch (Issue #479)

Timestamp: 2026-08-17T00-05

Command:
```
git push -u origin HEAD
gh workflow run _shell-coverage.yml --ref bug/parallel-lane-scale-and-barrier-semantics-479
gh run watch 31992757936 --exit-status
gh run view 31992757936 --json conclusion,url,headSha,status
```

EXIT_CODE: 0 (all four commands)

## Output Summary

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/31992757936
- Conclusion: **success** (status `completed`)
- headSha: `a43deb731c9e11296b19d5b81c233ff81625704c` — equals the local baseline HEAD.
- Job: `Shell Coverage (Bats + kcov)` in 4m26s (ID 95279085873).
- Step `Run shell-qc check (shfmt diff + shellcheck)`: green.
- Step `Run shell-qc test with coverage`: green. TAP plan `1..245`; all 245 bats tests reported `ok`, zero `not ok`.
- Numeric line coverage: **`Bash coverage (lines): 92.3%`** — above the uniform line threshold of 85%.
- Branch coverage: `N/A — kcov does not measure branch coverage; PowerShell/bash are exempt from the branch threshold only`.

Local execution is not available on this Windows host (the shell-QC toolchain requires
shfmt/shellcheck/bats/kcov under WSL), so CI dispatch is the verification path for the bash
lane, both at baseline and at final QC (P7-T12).
