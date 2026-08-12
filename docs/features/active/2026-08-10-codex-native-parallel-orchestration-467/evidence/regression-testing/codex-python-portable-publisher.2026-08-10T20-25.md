# Python Codex Portable Publisher Evidence

Timestamp: `2026-08-10T20-25`

Task: `[P5-T4]`

Command: `poetry run black --check scripts/dev_tools/push_down_codex_and_agents_customizations.py scripts/dev_tools/push_down_codex_filesystem.py tests/scripts/dev_tools/test_push_down_codex_portable_assets.py`

EXIT_CODE: `0`

Output Summary: Black reported that all three scoped files would remain unchanged.

Command: `poetry run ruff check scripts/dev_tools/push_down_codex_and_agents_customizations.py scripts/dev_tools/push_down_codex_filesystem.py tests/scripts/dev_tools/test_push_down_codex_portable_assets.py`

EXIT_CODE: `0`

Output Summary: Ruff reported that all checks passed.

Command: `poetry run pyright scripts/dev_tools/push_down_codex_and_agents_customizations.py scripts/dev_tools/push_down_codex_filesystem.py tests/scripts/dev_tools/test_push_down_codex_portable_assets.py`

EXIT_CODE: `0`

Output Summary: Pyright reported 0 errors, 0 warnings, and 0 information diagnostics.

Command: `poetry run pytest -q tests/scripts/dev_tools/test_push_down_codex_portable_assets.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`

EXIT_CODE: `0`

Output Summary: 16 tests passed in 0.17 seconds.

## Verified Contract

- The Python public publisher selects exactly 15 portable assets: nine approved
  Bash files, five approved blast-radius PowerShell modules, and
  `config/blast-radius.json`.
- All 15 generic resource sources exist and the allowlist contains no duplicate
  or unrelated `.claude/**` path.
- `config/blast-radius.json` is read from the generic Claude resource bundle,
  preserving generic-default behavior instead of publishing the repository's
  destination-specific value.
- Unequal pre-existing portable destinations are rejected before any publisher
  write, with collisions reported in deterministic allowlist order.
- Existing Codex/agents public publisher and root/resource parity contracts pass.
- `scripts/dev_tools/push_down_codex_and_agents_customizations.py` is 362 lines.
- `scripts/dev_tools/push_down_codex_filesystem.py` is 244 lines.
- `.claude` diff is zero, `.codex/state` is absent, and `git diff --check`
  exits 0. The existing `testResults.xml` line-ending warning is non-failing.
- TypeScript publisher production was not modified; `[P5-T5]` remains separate.
