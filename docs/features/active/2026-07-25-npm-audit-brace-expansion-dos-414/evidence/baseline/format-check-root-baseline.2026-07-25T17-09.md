# Baseline Gate — `npm run format:check`, Repository Root (#414, [P0-T14])

Timestamp: 2026-07-25T17-09

Command: `npm run format:check` (working directory: repository root, BEFORE any manifest edit)
EXIT_CODE: 1

## Verbatim Output

```text
> drm-copilot@1.0.0 format:check
> node run-node-tool.cjs prettier/bin/prettier.cjs --no-error-on-unmatched-pattern --check "src/**/*.{ts,tsx,js,mjs,cjs,json}" "tests/**/*.{ts,tsx,js,mjs,cjs,json}" "eslint.config.mjs" "jest.config.cjs" ".vscode-test.mjs" "tsconfig*.json" "run-*.cjs"

Checking formatting...
[warn] tests/fixtures/discovery_schemas/v1/runtime-characterization-scenario.invalid.json
[warn] tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json
[warn] Code style issues found in 2 files. Run Prettier with --write to fix.
```

## Pre-Edit Gate State

This gate is **RED before any change made by #414**. Both flagged files are committed test fixtures under `tests/fixtures/discovery_schemas/v1/`, introduced by commit `b69a84e1` ("feat(schemas): add versioned legacy-discovery JSON schemas and fixtures (#359)"). Neither file is in the four-file change set authorized by `spec.md` for #414, and neither is modified in the working tree:

Command: `git status --porcelain tests/`
EXIT_CODE: 0

```text
(empty — no modification under tests/)
```

The failing input is therefore entirely pre-existing on the branch head `fa64e0aded2705823e7b6f7fc20222c3c9b6b884` and is independent of the `overrides`/lockfile change. Prettier does not inspect `package.json` or `package-lock.json` under this script's glob set (the patterns cover `src/**`, `tests/**`, `eslint.config.mjs`, `jest.config.cjs`, `.vscode-test.mjs`, `tsconfig*.json`, `run-*.cjs`), so no file changed by #414 can affect this gate's result in either direction.

No remediation is applied here: reformatting the two fixtures would add files outside the authorized four-file change set and would violate the change-set acceptance criteria for #414.

Output Summary: FAIL at baseline, pre-existing. `npm run format:check` exits 1 in the repository root before any #414 edit, reporting Prettier style issues in exactly 2 committed test fixtures (`tests/fixtures/discovery_schemas/v1/runtime-characterization-scenario.invalid.json`, `tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json`). Both are unmodified working-tree files from commit `b69a84e1` and lie outside the #414 change set; the script's glob set does not include `package.json` or `package-lock.json`. This establishes the pre-edit state of the gate for comparison against [P4-T2].
