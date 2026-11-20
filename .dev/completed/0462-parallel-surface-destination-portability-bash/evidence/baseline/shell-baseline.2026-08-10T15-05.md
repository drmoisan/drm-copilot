# Shell Baseline — Issue #462

Timestamp: 2026-08-10T15-05

Task: [P0-T5]
Command:
```
git push -u origin HEAD
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-08-10T09-25
gh run view 31401325490 --json status,conclusion,url,headSha
gh run view 31401325490 --log | grep -i "Bash coverage"
```
EXIT_CODE: 0

Bash verification is CI-only on this win32 host (binding constraint 1); this baseline is
a dispatched `ubuntu-latest` run, not a local toolchain invocation.

## Output Summary

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/31401325490
- Run ID: 31401325490
- headSha: `16ecb9d270640fd1be6f78ae9961f7cb2dceaeca` (branch head at dispatch time)
- Branch: `drm-copilot-wt-2026-08-10T09-25`
- Status: completed
- Conclusion: **success**
- Baseline coverage line printed by the run: `Bash coverage (lines): 91.5%`
- bats result: 102 tests, all `ok`, no `not ok` lines in the coverage step.

The workflow at baseline contains a single quality step, `Run shell-qc test with coverage`
(`bash scripts/bash/shell-qc.sh test --coverage`). There is no `check` step yet; [P1-T6]
adds one, so from that point every dispatch must show two green steps.

The workflow has no coverage-threshold gate — a low-coverage run still concludes
`success` — so the 91.5% value above is read from the printed coverage line and is the
reference value for the [P7-T11] delta. Baseline clears the >= 85% line threshold from
`.claude/rules/quality-tiers.md`. kcov measures line coverage only; there is no bash
branch-coverage gate.
