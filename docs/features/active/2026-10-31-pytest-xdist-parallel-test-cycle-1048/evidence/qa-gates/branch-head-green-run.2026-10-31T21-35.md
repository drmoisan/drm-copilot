# Green run on the final branch head (P9-T5)

- Head: `6e5a0c249da783a3c4fba52bdcb4201f6e1af76f`. Run: `ci.yml` 41243409383 on PR #1053. Result: 26 checks, 24 success, 2 failure.
- The 2 failures are `NPM Audit Gate / npm audit (.)` and `NPM Audit Gate / npm audit (extensions/drm-copilot)`, the glob and minimatch advisories tracked in issue #1041. They fail the same way on main and are not required contexts.
- All 11 required contexts of ruleset 15241672 are success: Extension Tests (ubuntu-latest and windows-latest), Documentation Validation, `poshqc / PowerShell QC`, Shell Coverage (Bats + kcov), Security Scanning, `quality-checks7 / Code Quality & Tests` for 3.10, 3.11, 3.12 and 3.13, and Build Package.
- `poshqc / PowerShell QC` steps all success, including `Verify shard completeness` and `Merge PowerShell shard coverage`.
- Python 3.10 to 3.13 pass under the new strict pytest options (`--strict-markers`, `--strict-config`).
- `poshqc / PowerShell hook suites (Linux)`: success, 351 s. It is not among the required contexts in the ruleset read via `gh api repos/drmoisan/drm-copilot/rulesets/15241672`, and `_poshqc.yml` is unchanged by this item.
