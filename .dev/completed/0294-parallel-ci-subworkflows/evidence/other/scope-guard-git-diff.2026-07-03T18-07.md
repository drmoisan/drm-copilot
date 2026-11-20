# P4-T11 Scope Guard — `git diff --stat` (Issue #294)

Timestamp: 2026-07-03T18-07

Command: `git diff --stat`

EXIT_CODE: 0

Raw Output:
```
 .github/workflows/ci.yml | 308 ++---------------------------------------------
 1 file changed, 7 insertions(+), 301 deletions(-)
```

Command: `git status --porcelain`

EXIT_CODE: 0

Raw Output:
```
 M .github/workflows/ci.yml
?? .github/workflows/README.md
?? .github/workflows/_build-check.yml
?? .github/workflows/_docs-validation.yml
?? .github/workflows/_drm-copilot-extension-tests.yml
?? .github/workflows/_poshqc.yml
?? .github/workflows/_quality-checks.yml
?? .github/workflows/_security-scan.yml
?? .github/workflows/_shell-coverage.yml
?? docs/features/active/2026-07-03-parallel-ci-subworkflows-294/
```

Output Summary: `git diff --stat` (tracked-file modifications against the working
tree's `HEAD` base) shows exactly one file changed, `.github/workflows/ci.yml`. Zero
files under `src/` or `extensions/drm-copilot/src` appear in that diff. The
supplementary `git status --porcelain` output confirms all untracked additions from
this feature are confined to `.github/workflows/` (the 7 new `_<name>.yml` reusable
workflow files plus `README.md`) and the feature's own documentation folder under
`docs/features/active/2026-07-03-parallel-ci-subworkflows-294/`; no path under `src/`
or `extensions/drm-copilot/src` appears in either output. `.github/workflows/publish-extension.yml`
and `.github/workflows/publish-mcp-npm.yml` are also absent from both outputs, confirming
they were not touched by this feature.
