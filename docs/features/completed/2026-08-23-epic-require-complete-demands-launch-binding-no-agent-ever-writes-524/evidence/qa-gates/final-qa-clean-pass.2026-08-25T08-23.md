# Final QA — Single Clean Pass of Both Language Loops [P6-T9]

Timestamp: 2026-08-25T08-23

Task: [P6-T9]
Worktree: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab3e4d3669d51fc03`
Branch: `bug/epic-require-complete-demands-launch-binding-no-agent-ever-writes-524-r3`
HEAD: `14e9cac0a749d5bda53b34104f3511ef45b16e21`

## Purpose and relation to the earlier artifact

This artifact records an INDEPENDENT re-run of both language loops, executed in this session, in
plan order and in stage order. It does not rely on
`final-qa-clean-pass.2026-08-24T23-20.md`; it re-derives every exit code from the process that
produced it. The conclusion of the earlier artifact is REPRODUCED: both loops complete a single
clean pass with every stage at `EXIT_CODE: 0` and no tracked file changed by any stage.

The earlier artifact recorded zero loop restarts. This re-run required one restart per language,
both caused by the state of this worktree's environment rather than by the code under change. Each
restart and its cause is recorded below, and the clean pass reported in the tables is the pass that
followed those restarts.

## Python loop — clean pass (after 1 restart)

Working directory: repository root of the worktree.

| Stage | Command | EXIT_CODE | Tracked files changed |
| --- | --- | --- | --- |
| 1 format | `poetry run black .` | 0 | 0 (443 files left unchanged) |
| 1a tree check | `git status --porcelain` | 0 | empty output |
| 2 lint | `poetry run ruff check .` | 0 | 0 |
| 3 type-check | `poetry run pyright` | 0 | 0 |
| 4 test + coverage | `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` | 0 | 0 |
| 4a tree check | `git status --porcelain` | 0 | empty output |

Test summary, verbatim:

```
====================== 4117 passed, 5 skipped in 21.18s =======================
```

- Passed: **4117**. Failed: **0**. Skipped: 5 (all pre-existing, in
  `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py`, each declaring no accessor
  expectation).
- `TOTAL` coverage row: `14950 stmts, 1105 miss, 5492 branch, 559 BrPart, 91%` (combined column).
- Target-module row, verbatim:
  `scripts\dev_tools\_epic_orchestrator_state_launch_binding.py   119   3   56   3   97%   185, 224, 287`

`pyright` emitted the informational line `venv .venv subdirectory not found in venv path ...` and a
new-version notice on stderr. Neither is an error; the reported result is `0 errors, 0 warnings,
0 informations` and the process exit code is 0.

## TypeScript loop — clean pass (after 1 restart)

Working directory: `extensions/drm-copilot` (supplied inside the same shell invocation as the
command, see the invocation note below).

| Stage | Command | EXIT_CODE | Tracked files changed |
| --- | --- | --- | --- |
| 1 format | `npm run format` | 0 | 0 (400 files processed, 400 reported `(unchanged)`) |
| 1a tree check | `git status --porcelain` | 0 | empty output |
| 2 lint | `npm run lint` | 0 | 0 |
| 3 type-check | `npm run typecheck` | 0 | 0 |
| 4 test + coverage | `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` | 0 | 0 |
| 4a tree check | `git status --porcelain` | 0 | empty output |

Underlying commands from the npm script banners:

- format: `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- lint: `eslint --no-error-on-unmatched-pattern src test` (no output; zero errors, zero warnings)
- typecheck: `tsc -p ./ --noEmit` (no output; zero errors)

Coverage and test summary, verbatim:

```
=============================== Coverage summary ===============================
Statements   : 96.66% ( 43084/44571 )
Branches     : 90.05% ( 6128/6805 )
Functions    : 89.67% ( 1260/1405 )
Lines        : 96.66% ( 43084/44571 )
================================================================================

Test Suites: 195 passed, 195 total
Tests:       2658 passed, 2658 total
Snapshots:   0 total
Time:        8.877 s
```

Target-module row from the `text` table, verbatim:

```
  epic-orchestrator-state-launch-binding.ts                 |      96 |    92.72 |     100 |      96 | 45-46,56-61,215-217,256-257
```

## Loop restarts

Total restarts: **2** (one per language). Both restarts were caused by the environment of this
worktree, not by the diff under review.

### Restart 1 — Python loop, restarted from the format stage

- Failing stage: 4 (test). `poetry run pytest --cov=scripts.dev_tools --cov-branch
  --cov-report=term-missing` exited **1**.
- Failure: `1 failed, 4116 passed, 5 skipped`. The single failure was
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  with `AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json`.
- Cause: `.claude/state/python-batch-budget.default.json` is **gitignored session state** written by
  the Python batch-budget `PreToolUse` hook. `git status --porcelain --ignored .claude/state/`
  reports `!! .claude/state/`, and the file's contents named a `.py` path inside this session's
  scratchpad directory, confirming it was produced by the running harness after HEAD was committed
  (file mtime 2026-08-25 08:03, well after the 2026-08-24T23-13 recorded Python run). The test walks
  the on-disk `.claude/` tree without filtering gitignored paths, so the file's mere presence fails
  it. This is the exact interaction the earlier `final-python-test-coverage.2026-08-24T23-13.md`
  artifact documents; that run passed because the file was absent at the time.
- Not caused by this diff: the enumerated six-file change set contains no `.claude/state/` path, no
  push-down bundle path, and no part of `test_push_down_claude_resource_contracts.py`.
- Remediation: removed the transient, gitignored state file (`rm -f
  .claude/state/python-batch-budget.default.json`), then restarted the Python loop at its format
  stage per the Phase 6 restart rule. No tracked file was touched.
- Result after restart: all four stages exit 0; the Python table above is that pass.

### Restart 2 — TypeScript loop, restarted from the format stage

- Failing stage: 2 (lint). `npm run lint` exited **2**.
- Failure: `Error [ERR_MODULE_NOT_FOUND]: Cannot find package '@eslint/js' imported from
  ...\extensions\drm-copilot\eslint.config.mjs`.
- Cause: this worktree contained **no `node_modules` directory at all**, neither at the repository
  root nor under `extensions/drm-copilot`. The `prettier` and `eslint` executables resolved from the
  parent checkout's `node_modules/.bin` by npm's ancestor-directory lookup, but the ESM import of
  `@eslint/js` from `extensions/drm-copilot/eslint.config.mjs` could not resolve. `@eslint/js` is a
  declared devDependency of `extensions/drm-copilot/package.json` (`"^10.0.1"`).
- Not caused by this diff: no dependency manifest is in the change set.
- Remediation: `npm ci` in `extensions/drm-copilot` (EXIT_CODE 0, `found 0 vulnerabilities`), which
  installs into the gitignored `node_modules` and left `git status --porcelain` empty. Restarted the
  TypeScript loop at its format stage per the Phase 6 restart rule.
- Result after restart: all four stages exit 0; the TypeScript table above is that pass.

## Invocation note — a discarded format run that is not a loop restart

The first attempt at the TypeScript format stage was issued as a bare `npm run format` in a shell
invocation separate from the `cd extensions/drm-copilot` that preceded it. This agent's shell resets
its working directory between invocations, so npm resolved the **repository-root** `package.json`
instead of the extension's. The root `format` script has a wider glob
(`"tests/**/*.{ts,tsx,js,mjs,cjs,json}"`) and prettier rewrote 44 tracked JSON fixtures under the
repository-root `tests/fixtures/` tree (single-element arrays collapsed onto one line).

That run executed the wrong command, so it is recorded as a discarded invocation rather than as a
stage result or a loop restart. It was reverted in full with `git checkout -- tests/fixtures`,
after which `git status --porcelain` was empty, and the stage was re-issued with the directory
change inside the same invocation (`cd extensions/drm-copilot && npm run format`). Every TypeScript
figure in this artifact comes from the correctly-scoped invocation, whose banner shows
`prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` and which reported 400 of 400 files
unchanged.

The 44 reverted fixtures are unrelated to this feature and are unmodified at the end of this
session.

## Verdict

**PASS.** Both language loops completed a single clean pass in this session with every stage at
`EXIT_CODE: 0` and no tracked file changed by any stage. `git status --porcelain` from the
repository root is empty at the end of the pass. The recorded result of
`final-qa-clean-pass.2026-08-24T23-20.md` is reproduced; the two environment-caused restarts above
are the only difference between the two runs.
