# CI Gate Evidence (S9) for PR #1044

Timestamp: 2026-10-31T12-45
Command: gh pr checks 1044 --required; gh pr checks 1044; gh api repos/drmoisan/drm-copilot/commits/52d818c3fc93288e1133f7d36fe76857f3c879a4/check-runs
EXIT_CODE: 0
Output Summary: PR head bde38d8868f6e6ed1d822d97ad5966c85d824040, ci.yml run 41198486948. All 11 required contexts of ruleset 15241672 pass, including poshqc / PowerShell QC (Windows shards with coverage) and, among the non-required jobs, poshqc / PowerShell hook suites (Linux). 24 of 26 checks pass. The two failures are the non-required jobs NPM Audit Gate / npm audit (.) and NPM Audit Gate / npm audit (extensions/drm-copilot); both fail identically on main at merge base 52d818c3f (issue #1041) and are not caused by this change. AC-20 is checked off on this evidence.

## Required contexts (all pass)

- build-check / Build Package
- docs-validation / Documentation Validation
- drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)
- drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)
- poshqc / PowerShell QC
- quality-checks7 / Code Quality & Tests (3.10)
- quality-checks7 / Code Quality & Tests (3.11)
- quality-checks7 / Code Quality & Tests (3.12)
- quality-checks7 / Code Quality & Tests (3.13)
- security-scan / Security Scanning
- shell-coverage / Shell Coverage (Bats + kcov)

## Non-required failures (pre-existing on main, issue #1041)

- NPM Audit Gate / npm audit (.): failure on PR head and on main at 52d818c3f
- NPM Audit Gate / npm audit (extensions/drm-copilot): failure on PR head and on main at 52d818c3f
