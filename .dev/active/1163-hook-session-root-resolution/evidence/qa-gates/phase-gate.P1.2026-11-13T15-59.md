# Phase Gate — Phase 1 (Lockfile Remediation)

Timestamp: 2026-11-13T15-59
Command: sh SCRATCH/issue-1163-c2-static.sh p1gate2; sh SCRATCH/issue-1163-c2-jest.sh root p1gate2; sh SCRATCH/issue-1163-c2-jest.sh ext p1gate2; sh SCRATCH/issue-1163-c2-pytest.sh p1gate2
EXIT_CODE: 0
Output Summary: pass 2 of the loop is clean against the remediation baseline. Every step exits 0 except root `format:check`, which exits 1 on the same three pre-existing findings recorded in `remediation-baseline/typescript-static.2026-11-13T15-48.md` and on no other file (see Deviation).

## Pass 1 (restarted)

- Static steps: same results as pass 2.
- Root Jest: exit 0.
- Extension Jest: exit 1. One suite (`test/extension.new-active-feature-folder-inprocess.test.ts`) failed to run: `jest: failed to read cache file ... EPERM: operation not permitted` on the shared Jest transform cache under the system temp folder. 0 tests failed. The four per-file branch drops in that run came from the suite that did not run.
- Cause and fix: a Windows file lock on the shared Jest cache. The Jest launcher now passes `--cacheDirectory=SCRATCH/issue-1163-c2-jestcache-<pkg>`, which isolates the cache. No tracked file changed. The loop restarted from stage 1.

## Pass 2 (clean)

| Stage | Step | Command | EXIT_CODE | Findings |
|---|---|---|---|---|
| 1 format | root | npm run format:check | 1 | 3, all pre-existing baseline files (config-surface-corpus.json, python-native-corpus.json, python-surface-corpus.json under tests/scripts/claude-lib/docs/fixtures/); 0 new |
| 1 format | extension | npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" | 0 | 0, "All matched files use Prettier code style!" |
| 2 lint | root | npm run lint | 0 | 0 |
| 2 lint | extension | npm run lint | 0 | 0 |
| 3 type check | root | npm run typecheck | 0 | 0 |
| 3 type check | extension | npm run typecheck | 0 | 0 |
| build | extension | npm run build | 0 | 0 |
| build | mcp-server | npm run build | 0 | 0 |
| 4 architecture | n/a | no TypeScript architecture-boundary tool is configured for these packages | n/a | n/a |
| 5 unit | root Jest | node run-jest.cjs --cacheDirectory=SCRATCH/... --coverage (normal parallel workers) | 0 | 5493 passed, 0 failed; lines 98.27%, branches 93.59%; per-file drops 0 against baseline |
| 5 unit | extension Jest | node run-jest.cjs --cacheDirectory=SCRATCH/... --coverage (normal parallel workers) | 0 | 5476 passed, 0 failed; lines 97.15%, branches 93.87%; coverageThreshold passes; per-file drops 0 |
| 6 contract | pytest -n auto (P2-T5 selection, 9 files) | env -u VIRTUAL_ENV poetry run pytest -n auto -q -p no:cacheprovider -rfE <9 contract files> | 0 | 151 passed, 0 failed, 0 errors |

`git status --short` after the loop: clean (no auto-fix, no tracked change).

## Deviation

The task acceptance states every step exits 0. Root `format:check` cannot exit 0 without editing three `tests/` fixture files that this cycle's scope (P2-T8) forbids changing. The files are unchanged from the merge base of origin/main and HEAD and fail the same way there. The gate is evaluated against the Phase 0 baseline: no new finding. This is reported to the orchestrator for a separate decision.
