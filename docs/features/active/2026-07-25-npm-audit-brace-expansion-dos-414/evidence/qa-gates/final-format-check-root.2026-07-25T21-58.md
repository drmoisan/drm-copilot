# Final QA Gate — `npm run format:check`, Repository Root (#414, [P4-T2])

Timestamp: 2026-07-25T21-58

Command: `npm run format:check` (working directory: repository root, AFTER the manifest edit and lockfile regeneration)
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

(ANSI colour escapes around the `warn` labels are stripped above; the text is otherwise verbatim.)

## Acceptance Evaluation — Baseline Parity

The plan's acceptance for [P4-T2] is `EXIT_CODE: 0`, OR post-change output identical to the [P0-T14] pre-edit baseline — the same two fixture files flagged and no additional file.

| | [P0-T14] pre-edit baseline | [P4-T2] post-change |
|---|---|---|
| Artifact | `evidence/baseline/format-check-root-baseline.2026-07-25T17-09.md` | this artifact |
| EXIT_CODE | 1 | 1 |
| Files flagged | 2 | 2 |
| File 1 | `tests/fixtures/discovery_schemas/v1/runtime-characterization-scenario.invalid.json` | same |
| File 2 | `tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json` | same |
| Additional files flagged | none | none |

Status: **MET by baseline parity.** The post-change output is identical to the pre-edit baseline — the same two fixtures, the same count, no additional file. The change introduced no new formatting failure.

## Pre-Existing Status of the Two Fixtures

Command: `git diff --name-only origin/main -- tests/fixtures/discovery_schemas/` (working directory: repository root)
EXIT_CODE: 0

```text
(no output — zero differing paths)
```

An empty result proves both flagged fixtures are byte-identical to `origin/main`. The gate is therefore already red on `main` itself; the condition is pre-existing and out of scope for #414.

No remediation is applied. Reformatting the two fixtures would add files outside the four-file change set authorized by `spec.md` and would violate the change-set acceptance criteria. This condition is recorded for separate filing in [P6-T6] (Condition A).

## Isolation from the #414 Change

Prettier does not inspect `package.json` or `package-lock.json` under this script's glob set (the patterns cover `src/**`, `tests/**`, `eslint.config.mjs`, `jest.config.cjs`, `.vscode-test.mjs`, `tsconfig*.json`, `run-*.cjs`). No file changed by #414 can affect this gate's result in either direction.

## QA Loop Disposition

`prettier --check` writes no files, so this step changed nothing in the working tree. The exit code matches the recorded baseline exactly, which is the dispositioned acceptance for this gate, so the Phase 4 QA loop continues to [P4-T3] rather than restarting.

Output Summary: `npm run format:check` exits 1 in the repository root after the change, flagging exactly the same two committed test fixtures as the pre-edit [P0-T14] baseline and no additional file. Acceptance is met by baseline parity: the change introduced no new formatting failure. Both fixtures are verified byte-identical to `origin/main` (`git diff --name-only origin/main -- tests/fixtures/discovery_schemas/` returns nothing), so the red gate is a pre-existing condition on `main`, recorded for separate filing and out of scope for #414.
