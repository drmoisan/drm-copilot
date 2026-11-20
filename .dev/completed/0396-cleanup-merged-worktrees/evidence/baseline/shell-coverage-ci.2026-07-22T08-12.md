# Baseline Shell Coverage via CI Dispatch (Issue #396)

Timestamp: 2026-07-22T08-12

Command:

```
git push -u origin drm-copilot-wt-2026-07-21T21-57
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57
gh run watch 29918840204 --exit-status
gh run view 29918840204 --log | grep "Bash coverage (lines)"
```

EXIT_CODE: 0

Workflow run URL: https://github.com/drmoisan/drm-copilot/actions/runs/29918840204

Output Summary:

- Run conclusion: success (green) on `ubuntu-latest`.
- Bash coverage (lines): 88.2%  (pre-change baseline, existing `scripts/bash/` shell scripts only; the new `cleanup_worktrees_*` files are not yet committed to the branch head at baseline capture time).
- kcov measures line coverage only; there is no bash branch-coverage gate per `.claude/rules/shell.md`.
- This numeric baseline (88.2%) is the reference for the P7-T4 coverage-delta no-regression comparison.
