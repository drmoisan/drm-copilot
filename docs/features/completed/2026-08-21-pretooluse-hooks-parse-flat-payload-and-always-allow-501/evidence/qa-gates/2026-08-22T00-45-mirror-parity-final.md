# QA gate — Final mirror parity (AC-9) (#501)

Timestamp: 2026-08-22T00-45

Task: [P7-T4]

## First action — clear `.claude/state/`

`test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates `.claude/**` with a bare `rglob("*")` and exempts only `.claude/settings.local.json` and `.claude/agent-memory/**`. `.claude/state/` is gitignored but not exempted, so any runtime file left there fails this gate with a missing-from-bundle error unrelated to the migration.

Command: `find .claude/state -type f -print -delete`

Output:

```
.claude/state/powershell-batch-budget.default.json
--- state files remaining: 0 ---
```

The batch-budget counter written by the migrated `enforce-powershell-batch-budget.ps1` was the only file present; the directory itself remains, which is harmless because the walk filters to files.

## Named-test gate

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts`

EXIT_CODE: 0

Output: `1 passed, 9 deselected in 0.10s`

## Independent SHA-256 confirmation

The pytest is the enforcement mechanism; this second measurement confirms it independently rather than relying on a single oracle.

Command: for every file under `.claude/hooks/` and `.claude/lib/`, compare `Get-FileHash` against the same relative path under `extensions/drm-copilot/resources/claude-customizations/`.

EXIT_CODE: 0

Output:

```
files checked: 73
mismatches: 0
```

All 73 files, including the 24 migrated hooks, the two new dot-sourced helper siblings (`enforce-pr-author-skill-helpers.ps1`, `enforce-parallel-cohort-barrier-helpers.ps1`), and the new shared module `.claude/lib/hook-payload/HookPayload.psm1`, hash identically to their mirror copies. No file is missing from the mirror.

Output Summary: The named mirror-parity test passes, and an independent SHA-256 comparison over all 73 `.claude/hooks/` and `.claude/lib/` files reports zero mismatches and zero missing mirrors. Byte parity holds for every changed hook, both new helper siblings, and the new module. AC-9 satisfied. Matches the [P0-T5] baseline result of `1 passed`.
