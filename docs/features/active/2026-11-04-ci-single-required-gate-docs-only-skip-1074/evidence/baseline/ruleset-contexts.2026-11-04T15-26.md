# Ruleset 15241672 Required Contexts (Issue #1074)

Timestamp: 2026-11-04T15-26
Task: [P0-T3]
Command: gh api repos/drmoisan/drm-copilot/rulesets/15241672 > SCRATCH/issue-1074-ruleset-15241672.backup.json
EXIT_CODE: 0
Output Summary:
- Read-only GET; no PUT, PATCH, or POST was sent. The response is saved at `SCRATCH/issue-1074-ruleset-15241672.backup.json` and is not copied into the repository.
- `name`: `protect-main`; `target`: `branch`; `enforcement`: `active`; conditions `ref_name.include` `~DEFAULT_BRANCH`, `ref_name.exclude` empty.
- Rule types: `deletion`, `non_fast_forward`, `pull_request`, `required_status_checks`.
- `required_status_checks` parameters: `strict_required_status_checks_policy` false, `do_not_enforce_on_create` false.
- `bypass_actors`: present (one entry, actor type `User`, bypass mode `pull_request`).
- Required context count: 20. The set equals research claim N3 (the ten brief contexts, `poshqc / PowerShell QC static`, `poshqc / PowerShell hook suites (Linux)`, and the eight contexts of the spec `Actual` section). No difference.

| # | Context | integration_id |
|---|---|---|
| 1 | `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` | 15368 |
| 2 | `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` | 15368 |
| 3 | `docs-validation / Documentation Validation` | 15368 |
| 4 | `poshqc / PowerShell QC` | 15368 |
| 5 | `shell-coverage / Shell Coverage (Bats + kcov)` | 15368 |
| 6 | `security-scan / Security Scanning` | 15368 |
| 7 | `quality-checks7 / Code Quality & Tests (3.11)` | 15368 |
| 8 | `quality-checks7 / Code Quality & Tests (3.12)` | 15368 |
| 9 | `quality-checks7 / Code Quality & Tests (3.13)` | 15368 |
| 10 | `build-check / Build Package` | 15368 |
| 11 | `NPM Audit Gate / npm audit (extensions/drm-copilot)` | 15368 |
| 12 | `NPM Audit Gate / npm audit (.)` | 15368 |
| 13 | `NPM Audit Gate / npm audit (packages/mcp-server)` | 15368 |
| 14 | `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)` | 15368 |
| 15 | `root-typescript-tests / Root TypeScript Tests (windows-latest)` | 15368 |
| 16 | `poshqc / PowerShell QC shard 1` | 15368 |
| 17 | `poshqc / PowerShell QC shard 2` | 15368 |
| 18 | `poshqc / PowerShell QC shard 3` | 15368 |
| 19 | `poshqc / PowerShell QC static` | 15368 |
| 20 | `poshqc / PowerShell hook suites (Linux)` | 15368 |
