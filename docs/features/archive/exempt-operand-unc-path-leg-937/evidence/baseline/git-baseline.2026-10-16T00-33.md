# Git Baseline (issue #937)

Timestamp: 2026-10-16T00-33
Task: P0-T5
Command: git fetch origin main; git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git rev-parse origin/main; git merge-base HEAD origin/main; git status --porcelain
EXIT_CODE: 0
Output Summary: branch bug/exempt-operand-unc-path-leg-937 at c7f4ce8c6, merge base equals origin/main adb9aa5f0; porcelain lists only FEATURE paths (plan file and new evidence folder).

## Outputs

- `git fetch origin main`: `From https://github.com/drmoisan/drm-copilot` / `* branch main -> FETCH_HEAD`
- `git rev-parse --abbrev-ref HEAD`: `bug/exempt-operand-unc-path-leg-937`
- `git rev-parse HEAD`: `c7f4ce8c646d8295ac913f347bc519b565b1e7b3`
- `git rev-parse origin/main`: `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- `git merge-base HEAD origin/main`: `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- `git status --porcelain`:

```text
 M docs/features/active/exempt-operand-unc-path-leg-937/plan.2026-10-15T17-45.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/
```

Acceptance: branch matches; no porcelain path lies outside FEATURE. PASS.
