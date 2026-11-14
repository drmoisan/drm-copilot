# Remediation Baseline — TypeScript Static Steps

Timestamp: 2026-11-13T15-48
Command: sh SCRATCH/issue-1163-c2-static.sh base (runs each step below in its package directory)
EXIT_CODE: 1
Output Summary:
| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| root format | npm run format:check | 1 | 3 (pre-existing, see below) |
| root lint | npm run lint | 0 | 0 |
| root typecheck | npm run typecheck | 0 | 0 |
| extension format | npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" | 0 | 0 ("All matched files use Prettier code style!") |
| extension lint | npm run lint | 0 | 0 |
| extension typecheck | npm run typecheck | 0 | 0 |
| extension build | npm run build | 0 | 0 |
| mcp-server build | npm run build | 0 | 0 |

Pre-existing root format findings (Prettier "Code style issues found in 3 files"):
- tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json
- tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json
- tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json

These three files are unchanged between the merge base of origin/main and HEAD (`git diff --stat` empty), so the findings exist on main and are outside this cycle's scope (P2-T8 forbids `tests/` changes). No CI workflow runs root Prettier. Later gates compare root format against this baseline: the gate condition applied is "no finding outside these three files".
