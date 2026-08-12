# Codex Additive Routing Merge Evidence

Timestamp: `2026-08-10T20-25`

Task: `[P5-T6]`

Command: `poetry run black --check scripts/dev_tools/push_down_codex_routing_merge.py scripts/dev_tools/push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_routing_merge.py tests/scripts/dev_tools/test_push_down_codex_portable_assets.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`

EXIT_CODE: `0`

Output Summary: Black reported that all six scoped Python files would remain unchanged.

Command: `poetry run ruff check scripts/dev_tools/push_down_codex_routing_merge.py scripts/dev_tools/push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_routing_merge.py tests/scripts/dev_tools/test_push_down_codex_portable_assets.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`

EXIT_CODE: `0`

Output Summary: Ruff reported that all checks passed.

Command: `poetry run pyright scripts/dev_tools/push_down_codex_routing_merge.py scripts/dev_tools/push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_routing_merge.py tests/scripts/dev_tools/test_push_down_codex_portable_assets.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`

EXIT_CODE: `0`

Output Summary: Pyright reported 0 errors, 0 warnings, and 0 information diagnostics.

Command: `poetry run pytest -q tests/scripts/dev_tools/test_push_down_codex_routing_merge.py tests/scripts/dev_tools/test_push_down_codex_portable_assets.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`

EXIT_CODE: `0`

Output Summary: 20 focused and public Python tests passed in 0.28 seconds.

Command: `npm exec -- prettier --check src/lib/push-down/claude-routing-merge.ts src/lib/push-down/codex-agents-customizations.ts test/lib/push-down/codex-routing-merge.test.ts test/lib/push-down/codex-portable-assets.test.ts test/lib/push-down/codex-agents-customizations.test.ts`

EXIT_CODE: `0`

Output Summary: All five scoped TypeScript files use the repository Prettier style.

Command: `npm exec -- eslint src/lib/push-down/claude-routing-merge.ts src/lib/push-down/codex-agents-customizations.ts test/lib/push-down/codex-routing-merge.test.ts test/lib/push-down/codex-portable-assets.test.ts test/lib/push-down/codex-agents-customizations.test.ts`

EXIT_CODE: `0`

Output Summary: ESLint completed without diagnostics.

Command: `npm exec -- tsc --noEmit`

EXIT_CODE: `0`

Output Summary: TypeScript compilation completed without diagnostics.

Command: `npm run test:unit -- --runInBand test/lib/push-down/codex-routing-merge.test.ts test/lib/push-down/codex-portable-assets.test.ts test/lib/push-down/codex-agents-customizations.test.ts`

EXIT_CODE: `0`

Output Summary: 3 suites and 19 focused, direct, and public TypeScript tests passed in 0.379 seconds.

Command: `read-only normalized Python and TypeScript additive-routing probes`

EXIT_CODE: `0`

Output Summary: All 6 normalized matrix cells were identical; normalized SHA-256 was `241adbc54845b8b5b93cd9430901396f7eea1a4dab2358bca1501841494620ca`.

## Verified Contract

- Destination-owned top-level and route entries survive publication.
- Missing source top-level keys and route keys append in ascending order.
- Structurally equal entries preserve the destination's exact bytes.
- Substantive collisions emit `ROUTING_MERGE_SUBSTANTIVE_COLLISION` with
  `routes.alpha, routes.zeta` in the same order and message in both runtimes.
- Collision input and destination bytes remain unchanged.
- Unrelated `config/blast-radius.json` writes and non-write filesystem operations
  delegate unchanged; the routing destination is not rewritten by those calls.
- Existing TypeScript exports `RoutingMergeError`, `mergeRoutingDocuments`, and
  `RoutingMergeFileSystem` remain available alongside the additive exports.
- Python files are 190 lines for the helper, 373 lines for the public publisher,
  and 186 lines for the focused test.
- TypeScript files are 491 lines for the merge authority, 314 lines for the
  public publisher, 165 lines for the focused test, and 385 lines for the
  existing public test owner.
- Every production, test, and reusable file remains at or below 500 lines.
- `.claude` diff and status counts are zero, `.codex/state` is absent, and
  `git diff --check` exits 0. The existing `testResults.xml` line-ending warning
  is non-failing.
- `[P5-T7]` was not started.
