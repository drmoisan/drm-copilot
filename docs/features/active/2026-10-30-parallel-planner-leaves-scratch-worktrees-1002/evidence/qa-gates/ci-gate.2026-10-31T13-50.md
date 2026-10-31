# CI Gate Evidence (S9), PR 1045

- Timestamp: 2026-10-31T13-50
- Command: gh pr checks 1045 --json bucket,name,state,workflow,link
- EXIT_CODE: 0
- Output Summary: Head 1459990541f1dc0ad29459d636c37765b69443b9, CI run 41205430972. 24 checks pass and 2 fail. All 11 required contexts of ruleset 15241672 pass (extension tests ubuntu and windows, docs-validation, poshqc / PowerShell QC, shell-coverage, security-scan, quality-checks 3.10 to 3.13, build-check). The two failures are `NPM Audit Gate / npm audit (.)` and `NPM Audit Gate / npm audit (extensions/drm-copilot)`.

## non_required_failures

- `NPM Audit Gate / npm audit (.)`: not a required context; fails on main itself (issue 1041).
- `NPM Audit Gate / npm audit (extensions/drm-copilot)`: not a required context; fails on main itself (issue 1041).
- No npm manifest or lockfile was changed for these jobs.

## CI-dependent acceptance criteria

None. All 17 criteria in spec.md were verified from local evidence and are checked off. This evidence commit moves the PR head; CI is re-confirmed on the new head after the push.
