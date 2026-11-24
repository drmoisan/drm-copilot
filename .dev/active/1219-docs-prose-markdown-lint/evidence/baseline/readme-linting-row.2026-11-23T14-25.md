# README linting row baseline (P0-T1)

Timestamp: 2026-11-23T14-25
Command: Grep (ripgrep) pattern `(?i)(optional[^.\n]{0,40}lint|lint[^.\n]{0,40}optional)`, output mode count, one call per path below
EXIT_CODE: 0
Output Summary: exactly one match, in `.dev/engineering/documentation-estate/README.md`; none in the other four paths.

| Path | Matches |
|---|---|
| `.dev/engineering/documentation-estate/` | 1 (`README.md`) |
| `.claude/lib/docs/` | 0 |
| `.claude/skills/docs-*` | 0 |
| `.agents/skills/docs-*` | 0 |
| `extensions/drm-copilot/resources/` | 0 |

Each call returned exit 0 (ripgrep tool; "No matches found" is a valid zero count). The Pester coverage baseline is the existing `evidence/baseline/pester-gate.2026-11-23T07-39.md` and was not recaptured.
