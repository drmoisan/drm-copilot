# Codex Publisher and Pack Fail-Before Readiness

Timestamp: `2026-08-11T13:32-04:00`

Task: `[P5-T1]`

Status: `COMPLETE`

Output Summary: P5-T1 persisted eight test-only publisher and pack contract owners below 500 lines; all Python, TypeScript, and Bash static checks passed, production remained unchanged, and behavioral execution was explicitly deferred to P5-T2.

## Scope

P5-T1 added test-only contracts. Publisher, pack-selection, bundle, configuration,
and workflow production files were not changed. Behavioral execution remains
reserved for the `[expect-fail]` boundary in P5-T2.

## Test owners and physical lines

- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`: 286
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`: 374
- `tests/scripts/dev_tools/test_push_down_codex_pack_selection.py`: 404
- `tests/scripts/dev_tools/test_push_down_codex_portable_assets.py`: 176
- `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts`: 385
- `extensions/drm-copilot/test/lib/push-down/codex-pack-selection.test.ts`: 285
- `tests/shell/parallel_bash_manifest_membership.bats`: 135
- `tests/shell/parallel_payload_only.bats`: 148

Every test owner is below the 500-line limit.

## Enumerated contract

- Six parallel skills and two forced parallel agents.
- Fourteen registered or shared hook files.
- Eight generalized child-launch or parallel runtime scripts.
- `.codex/config.toml`, `AGENTS.md`, `config/orchestration-routing.json`, and
  `config/blast-radius.json`.
- Exactly nine approved issue-462 Bash files.
- Exactly five approved blast-radius PowerShell modules.
- A 48-path core dependency closure with unique core membership and zero
  duplicate language-pack membership.
- Exact exclusion of unrelated `.claude/**` paths.
- Generic blast-radius configuration selection and deterministic unequal
  portable destination-collision rejection in both publisher contracts.
- Existing Claude and epic test owners were not modified.

## Static quality gates

Command: `poetry run black --check <four Python owners>`

Result: `PASS` — 4 files left unchanged.

Command: `poetry run ruff check <four Python owners>`

Result: `PASS` — all checks passed.

Command: `poetry run pyright <four Python owners>`

Result: `PASS` — 0 errors, 0 warnings, 0 information messages.

Command: `npx prettier --check test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-pack-selection.test.ts`

Result: `PASS` — both files match Prettier formatting.

Command: `npx eslint test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-pack-selection.test.ts`

Result: `PASS` — exit code 0.

Command: `npx tsc --noEmit -p tsconfig.json`

Result: `PASS` — exit code 0.

Command: `shfmt -d -ln=bats tests/shell/parallel_bash_manifest_membership.bats tests/shell/parallel_payload_only.bats`

Result: `PASS` — exit code 0 after the required formatting restart.

Command: `shellcheck --shell=bats tests/shell/parallel_bash_manifest_membership.bats tests/shell/parallel_payload_only.bats`

Result: `PASS` — exit code 0.

## Boundary checks

- `.claude/**` working-tree delta: 0 paths.
- `.codex/state`: absent after verified ephemeral Python batch-receipt cleanup.
- `git diff --check`: exit code 0; Git emitted only the existing line-ending
  advisory for `testResults.xml`.
- Pytest, Jest, and Bats behavioral commands: not run in P5-T1; P5-T2 remains
  the authoritative expected-failure execution owner.

EXIT_CODE: `0`

## P5-T2 expected-failure execution

Timestamp: `2026-08-11T13:51-04:00`

Command: `poetry run pytest -q tests/scripts/dev_tools -k 'codex and (push_down or pack or parity or publisher)'`

Result: `EXPECTED_FAIL` — exit code 1; 46 passed, 8 failed, and 3,785
deselected. The eight failures are limited to:

- two missing root/bundle membership assertions;
- four missing core or selected-pack dependency-closure assertions;
- one missing exact portable destination emission and generic-config assertion;
- one missing unequal portable destination-collision rejection.

No unrelated Python failure occurred.

Command: `npm --prefix extensions/drm-copilot run test:unit -- --runInBand`

Result: `EXPECTED_FAIL` — exit code 1; 189 suites passed, 2 suites failed;
2,654 tests passed and 3 tests failed. The failures are limited to missing exact
portable emission/generic config, missing unequal portable collision rejection,
and missing 48-path core closure. Every other extension suite passed, including
existing Claude and epic publisher-compatible behavior.

Command: `bash scripts/bash/shell-qc.sh test`

Environment note: Windows `bash.exe` resolved to an unavailable WSL relay and
the first Git Bash invocation reported `bats not installed; skipping shell
tests`; neither result was accepted as evidence. Bats 1.13.0 was resolved from
the npm cache and supplied through the wrapper's documented
`SHELL_QC_BATS_BIN` override. A 304.2-second diagnostic run timed out while the
suite was progressing. The authorized 900-second rerun completed in 505.4
seconds.

Focused modified-owner attribution: `EXPECTED_FAIL` — 20 passed and 1 failed.
The sole failure was the missing exact portable Claude membership in Codex
`core.json`; all 12 payload-only cases passed.

Full wrapper result: `EXPECTED_FAIL` — exit code 1; 249 passed and 1 failed out
of 250 cases. The sole failure was
`parallel_bash_manifest_membership.bats` case 9, which requires the Codex core
manifest to own exactly the approved portable Claude library. No unrelated
Bats failure occurred.

P5-T2 attribution: `CLEAN_EXPECTED_FAILURE`

- Missing new Codex membership: confirmed.
- Missing fixed portable selection and destination closure: confirmed.
- Missing deterministic collision rejection: confirmed.
- Existing Python, TypeScript, Claude, epic, payload-only, and unrelated shell
  cases: green.
- Production/configuration/workflow changes during P5-T2: none.

EXIT_CODE: `0`
