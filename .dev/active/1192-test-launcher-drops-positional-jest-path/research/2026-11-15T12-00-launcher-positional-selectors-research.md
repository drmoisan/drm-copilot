# Research: launcher drops positional Jest path (Issue #1192)

## Current State (verified by reading source)

Command build: `Invoke-TestSuiteLauncher` in `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`.
- Step 2 resolves the suite; Step 3 takes `$extras` (all words after the suite name), runs `Get-TestExecutionLaneSelection` (refuses with exit 2 when a path operand's leaf ends with an excluded-lane suffix) and `Get-TestExecutionWorkerReductionToken` (exit 2); Step 4 calls `New-TestExecutionSuiteCommand`; Step 5 takes the machine lock; Step 6 starts the process with `workingDirectory`.
- `run-test-suite.sh` is a pure shim: `exec pwsh -NoProfile -File Invoke-TestSuite.ps1 "$@"`. It forwards every word. `Get-TestSuiteScriptArgument` re-reads the process command line, so no word is lost there either.
- `New-TestExecutionSuiteCommand` (`.claude/hooks/test-execution-policy.ps1`) emits: suite `command` words, then `Get-TestExecutionLaneExclusionArgument` words, then `$ExtraArgument`. Extras are forwarded, but placed AFTER the exclusions.
- Repo suites (`config/test-execution-policy.json`): `jest-extension` (`node run-jest.cjs`, `workingDirectory` `extensions/drm-copilot`, runner jest) and `bats`; built-in defaults add `pytest`, `pester`, `jest` (no working directory), `dotnet-test`.
- `extensions/drm-copilot/run-jest.cjs` rejects `--passWithNoTests`, `--onlyChanged`, `--lastCommit`, rewrites `--testPathPattern` to `--testPathPatterns`, and spawns `jest/bin/jest --config jest.config.cjs ...args` unchanged. It does not drop positionals.

## Root Cause (Jest)

`Get-TestExecutionLaneExclusionArgument`, jest branch, emits `--testPathIgnorePatterns=/node_modules/`, `--testPathIgnorePatterns=/out/`, and one `--testPathIgnorePatterns=<escaped suffix>$` per lane suffix. The caller's positional path follows the last such flag.

`node_modules/jest-cli/build/index.js` declares `testPathIgnorePatterns` with `type: 'array'`. An array option in the yargs parser consumes the following non-flag tokens, so the positional is parsed as one more ignore pattern, not a test-path pattern. Jest then runs the whole suite and additionally skips the named file. Inferred from the Jest option definition and the builder order; not reproduced, because heavy runs were out of scope.

Same defect class in Pester: the `pester` exclusion emits `-ExcludeTestFileSuffix <suffix...>` (array key) and extras follow. In `ConvertTo-PesterSuiteParameter` (`Invoke-PesterSuite.ps1`), a bare positional after that key becomes another suffix value, silently. A `-TestPath <paths>` extra starts a new key and works. A positional before any key throws.

pytest: `-m "<expr>"` and `--ignore-glob=<one word each>` are single-value options; positionals after them are collected normally. No defect. dotnet-test: one `--filter=` word; no defect. bats: no exclusions.

Lock, lane and worker rules are independent of the defect. Lane refusal operates on `$extras` before the build, so `*.integration.test.ts` and `*.golden.test.ts` operands still exit 2. Worker-reduction tokens still exit 2. The lock is acquired after the build.

## Candidate Approaches

1. Reorder in `New-TestExecutionSuiteCommand`: for runners whose exclusions are array options (jest, pester), emit extras before the exclusion words. One function change, no signature change.
2. Terminate the array with a sentinel (`--` or a non-array flag) after the exclusions. Depends on unverified yargs `--` handling in Jest and changes the command shape for every caller.
3. Fold exclusions into one `--testPathIgnorePatterns` word. Still an array option; does not fix it.

Recommendation: approach 1 for jest and pester. For pester, extras go before `-ExcludeTag`/`-ExcludeTestFileSuffix`; a bare leading word would throw in `ConvertTo-PesterSuiteParameter`, so the Pester selector form stays `-TestPath <paths>` (the documented form), and the reorder makes that selector's values safe from the suffix array. pytest, dotnet-test and bats keep the current order. Rejected: approaches 2 and 3.

## Existing tests asserting the current shape

- `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` (runs every case against `.claude/hooks` and `.codex/hooks` copies):
  - `builds the jest suite with one --testPathIgnorePatterns word per pattern and keeps a positional extra` asserts `$words[0..3]` is `node run-jest.cjs --testPathIgnorePatterns=/node_modules/ --testPathIgnorePatterns=/out/`, `$words[-1]` is the positional, count 13. Fails after a jest reorder; update.
  - `orders suite words, exclusions, then extras` (pytest): unaffected while pytest order is kept.
  - pester, non-default-lane, and integration-only builder tests have no extras; output unchanged.
- `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`: pytest argument-list case ending `...|-v|-s|--|-i` (unaffected); `starts jest-extension ...` (unaffected); `applies the runner of a configured suite ...` asserts `--testPathIgnorePatterns=*` count greater than 0 and pytest `ArgumentList[-1] -eq '-i'` (unaffected).
- `tests/scripts/claude-hooks/test-execution-policy.RepoConfig.Tests.ps1`: pins `jest-extension` and `bats` definitions (unaffected).
- `tests/shell/test_run_test_suite.bats` and `tests/fixtures/test-execution-policy/pwsh-stub.sh`: shim forwarding only (unaffected).
- `tests/unit/jest-config-resolution.test.ts` and `extensions/drm-copilot/test/jest-config-resolution.test.ts`: assert jest config, not the launcher (unaffected).
- Hook, registration, command-form, and dispatch parity corpora assert denial, not order (unaffected).
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` pins the brief; no brief change needed unless the plan states the selector rule there.

## Mirrors and bundles

`test-execution-policy.ps1` exists in four byte-identical copies: `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. Contract tests: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and the pack manifest tests. No `.github` copy of the hook exists. `Invoke-TestSuite.ps1`, `run-test-suite.sh`, `run-jest.cjs` need no change. Optional: the six `test-execution-policy` `SKILL.md` copies if the selector rule is documented.

## Stale comment

`extensions/drm-copilot/jest.config.cjs`, the comment above `const docsCoverageThresholds = require("./jest.docs-coverage.json")`, reads "the five docs MCP modules". `jest.docs-coverage.json` has seven module keys: `docs-command-envelope.ts`, `mcp-tool-inputs-docs.ts`, `mcp-tool-inputs-docs-ledger-batch.ts`, `mcp-tool-inputs-docs-grammar.ts`, `repo-automation-execute-docs.ts`, `mcp-docs-tool-definitions.ts`, `mcp-handlers/docs-handlers.ts` (read from the file). No test pins the comment text. This is not a spec acceptance-criterion numeric assertion, so no derivation section is proposed.

## Behavior Semantics

- A positional extra on a jest suite precedes every `--testPathIgnorePatterns` word, and no exclusion word is lost.
- No extras: command unchanged.
- Lane-suffix operand: exit 2 with `TEST_EXECUTION_POLICY_BLOCKED:`, unchanged.
- `--runInBand`, `-i`, `-w`, `--maxWorkers`: exit 2, unchanged.
- Machine lock still precedes the process start.

## Testing Implications

Update the jest builder test; add: single positional precedes the first ignore word; positional plus a flag extra; no extras unchanged; Pester `-TestPath a b` kept with exclusions after; a launcher-level `jest-extension` case with a positional asserting `ArgumentList` order and that an integration path still returns 2. Pester only, in-memory, no temp files, one parallel gate run.

## Pre-Mortem

- Review checklists: a reviewer will check all four hook copies and that the old jest test is updated, not weakened; the plan lists every file and the test dispositions above.
- Coverage: changed lines in `test-execution-policy.ps1` must stay at or above 85% line coverage; tests cover both the jest and pester reorder paths.
- Mirror parity: the four copies must be byte-identical; the plan runs the two push-down resource contract tests and the manifest tests.
- File size: keep `test-execution-policy.ps1` under 500 lines or extract the exclusion builder to a new module; the test file is 359 lines.
- Test isolation: policies come from in-memory text (`Get-TestPolicy -Text`); no temp files or leaked globals.
- CI-only behavior: the Linux hook-suite job runs claude-hooks and codex-hooks tests; avoid drive letters and backslash literals (existing launcher tests use `/repo`).
- Evidence: the jest cause is inferred from the option definition; fail-before is a builder-order test failing against the unmodified builder, not a live full Jest run.
