# Pre-Existing Conditions for Separate Filing (#414, [P6-T6])

Timestamp: 2026-07-25T22-28

Three conditions surfaced during #414 execution are pre-existing, independent of the `overrides`/lockfile change, and out of scope for the four-file change set that `spec.md` authorizes. Each is recorded here for separate filing as a potential issue. None was remediated within #414, because remediating any of them would require editing files outside the authorized change set and would violate the change-set acceptance criteria.

---

## Condition 1 — Root `format:check` fails on `main` for two committed fixtures

**Summary.** `npm run format:check` in the repository root exits 1 on `main` itself. Prettier flags two committed JSON test fixtures as having style issues:

- `tests/fixtures/discovery_schemas/v1/runtime-characterization-scenario.invalid.json`
- `tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json`

**Verified pre-existing status.** Both files are byte-identical to `origin/main`:

Command: `git diff --name-only origin/main -- tests/fixtures/discovery_schemas/`
EXIT_CODE: 0, no output (zero differing paths)

The gate is red on `main` before any branch change. The two files were introduced by commit `b69a84e1` ("feat(schemas): add versioned legacy-discovery JSON schemas and fixtures (#359)").

**Isolation from #414.** The `format:check` script's glob set covers `src/**`, `tests/**`, `eslint.config.mjs`, `jest.config.cjs`, `.vscode-test.mjs`, `tsconfig*.json`, and `run-*.cjs`. It does not include `package.json` or `package-lock.json`, so no file changed by #414 can affect this gate in either direction. The pre-edit and post-change runs flag exactly the same two files with the same exit code.

**Evidence paths.**
- Pre-edit baseline: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/format-check-root-baseline.2026-07-25T17-09.md`
- Post-change: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-format-check-root.2026-07-25T21-58.md`
- Escalation record: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/phase0-gate-baseline-escalation.2026-07-25T17-18.md` (Condition A)

**Out-of-scope note.** Fixing this requires running Prettier's `--write` over the two fixtures, which would add files outside the four-file change set #414 authorizes. Whether these `.invalid.json` fixtures should be Prettier-formatted at all, or excluded from the format glob because their content is deliberately malformed test input, is the question the separate issue should decide.

---

## Condition 2 — Root `test:integration` is unrunnable: no `vscode-test` configuration exists

**Summary.** The repository root defines `test:integration` as `vscode-test`, but no `.vscode-test.{json,js,cjs,mjs}` configuration file exists in the repository or any parent directory, and `tsconfig.vscode-test.json` is absent. `@vscode/test-cli` therefore exits 1 in `loadDefaultConfigFile` before starting any test runner:

```text
Error: Could not find a .vscode-test file in this directory or any parent. You can specify one with the --config option.
    at loadDefaultConfigFile (.../node_modules/@vscode/test-cli/out/cli/config.mjs:33:11)
```

**Verified pre-existing status.** The failure reproduces identically before and after the #414 change — same exit code, same message, same stack frames and line numbers. Config absence was verified at baseline: `ls -a | grep -i vscode-test` returns no match in the repository root, and `ls tsconfig*` lists only `tsconfig.jest.json`, `tsconfig.json`, and `tsconfig.tests.json`.

**Environment independence.** `@vscode/test-cli` searches the working directory and all parent directories for the config file. None exists anywhere in the repository, so the same error occurs on a CI runner. No workflow under `.github/workflows/**` invokes root `test:integration`, so the broken script is currently unobserved by CI.

**Consequence.** Mocha's `minimatch` call site is not exercised by any runnable gate in this repository. #414 compensated with a direct substitute verification ([P6-T4]), but that is a one-off; the underlying gap remains.

**Evidence paths.**
- Pre-edit baseline: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md`
- Post-change: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md`
- Substitute verification: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/regression-testing/mocha-minimatch-brace-path.2026-07-25T22-25.md`

**Out-of-scope note.** Fixing this requires adding a `.vscode-test` configuration (and likely `tsconfig.vscode-test.json` plus a workflow step), all outside the four-file change set. This condition is already recorded in `spec.md` under "Rollout & Follow-up". The separate issue should decide whether to supply the missing configuration or remove the dead `test:integration` script.

---

## Condition 3 — Jest `.claude`-path glob-escape artifact affects worktrees under dot-directories

**Summary.** Both jest coverage scripts report `No tests found` and exit 1 when run from a checkout whose absolute path contains a dot-directory component:

- root: `npm run test:unit:coverage`
- extension: `npm run test:coverage`

**Mechanism.** The execution path for this work was

```text
C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5
```

which contains the `.claude` dot-directory. The jest configs declare `testMatch` with a `<rootDir>` prefix. After substitution, jest reports the resolved pattern as

```text
C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/tests/unit/**/*.test.ts
```

The separator preceding `.claude` is emitted as a backslash, which the glob matcher consumes as an escape rather than a path separator, so the pattern can never match a real path and reports `0 matches` — even though jest reports it walked the whole tree (`443 files checked` at root, `373` in the extension) and the test files are present.

**Verified pre-existing status and non-reproduction on CI.** The failure is identical before and after the #414 change (baseline [P0-T11]/[P0-T13] and post-change [P4-T5]/[P5-T5] all show the same exit 1 and the same message). It is a function of the checkout path only: it does not occur in a checkout whose path has no dot-directory component and would not reproduce on a CI runner. It is not a repository defect in the sense of affecting normal checkouts, but it does make `npm test` unusable from any agent worktree under `.claude/worktrees/`.

**Workaround used.** The same jest binary and config invoked with rootDir-free `--testMatch` patterns passes and produces full coverage:
- root: 169/169 suites, 2032/2032 tests, line 97.00% / branch 89.06%
- extension: 168/168 suites, 2031/2031 tests, line 96.33% / branch 89.21%

**Evidence paths.**
- Root baseline: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-unit-coverage-root.2026-07-25T17-05.md`
- Extension baseline: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-coverage-extension.2026-07-25T17-08.md`
- Root post-change: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-test-unit-coverage-root.2026-07-25T22-02.md`
- Extension post-change: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-test-coverage-extension.2026-07-25T22-11.md`
- Escalation record: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/phase0-gate-baseline-escalation.2026-07-25T17-18.md` (Condition B)

**Out-of-scope note.** Fixing this requires editing `jest.config.cjs` (root) and the extension's jest configuration — both outside the four-file change set. The separate issue should decide whether to replace the `<rootDir>`-prefixed `testMatch` patterns with rootDir-free equivalents, or to normalize path separators before substitution.

---

Output Summary: Three pre-existing conditions are recorded for separate filing, each with its evidence paths, its verified pre-existing status, and an explicit out-of-scope note. (1) Root `npm run format:check` exits 1 on `main` itself over two committed `tests/fixtures/discovery_schemas/v1/*.invalid.json` fixtures that are byte-identical to `origin/main`. (2) Root `test:integration` cannot run because no `.vscode-test.{json,js,cjs,mjs}` configuration exists anywhere in the repository, an environment-independent condition that also holds on CI. (3) The jest `<rootDir>` glob-escape artifact makes both coverage scripts report `No tests found` from any worktree path containing a dot-directory such as `.claude`, which does not reproduce on CI or in a normal checkout. None is caused by #414, none was remediated within #414, and remediating any would require editing files outside the authorized four-file change set.
