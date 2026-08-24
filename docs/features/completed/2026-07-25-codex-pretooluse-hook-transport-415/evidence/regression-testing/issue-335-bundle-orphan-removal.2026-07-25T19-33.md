# Bundle-Only Orphan Removal — Cross-Reference Note for Issue #335 (delivered under Issue #415)

Timestamp: 2026-07-25T19-33

## Deleted path

```
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1
```

Command: `git rm extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`
EXIT_CODE: 0

Verification: `Test-Path -LiteralPath '<deleted path>'` returns **False**. `git status --porcelain` records the deletion as `D` and no other file was affected.

## Why the deletion removes no registration

Pre-deletion measurements, all taken before `git rm` ran:

- **Unregistered in both configs.** `grep -c "enforce-pr-author-skill"` returned `0` for `.codex/config.toml` **and** `0` for `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`. The file appears in no `[[hooks.PreToolUse]]` block, and in no other hook event block, in either the root or the bundled Codex configuration.
- **Bundle-only.** No root counterpart exists: `ls .codex/hooks/enforce-pr-author-skill.ps1` → "No such file or directory". The file was therefore a pure root/bundle divergence and is the last remaining obstacle to `.codex` byte-identity after `[P1-T2]` restored `config.toml` parity.
- **Legacy transport.** The file contains one `$env:CLAUDE_` reference (`:492` — `$decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT`) and **zero** occurrences of `[Console]::In.ReadToEnd()`. It is a legacy `CLAUDE_TOOL_INPUT`-transport hook that could not function under the native Codex stdin contract even if it were registered. File length: 500 lines.
- Last touched by commit `45aad955` ("fix(orchestration): add pre-PR-creation-ready check, adopt audit/remediation timestamped-folder convention (#272 remediation cycle 2)").

Because the file is registered nowhere, deleting it removes **no** Codex hook registration. Hard Constraint 2 (the registration set and matchers after the change must equal the set before it) is satisfied: the three `[[hooks.PreToolUse]]` matcher groups still carry **5 / 5 / 8** handler blocks respectively, unchanged.

## Cross-reference statement for issue #335 (required by `[P1-T3]`)

**Issue #335's future fix must reintroduce the `enforce-pr-author-skill` hook on BOTH the root `.codex/hooks/` and the bundled copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, using native Codex stdin transport (`[Console]::In.ReadToEnd()`, no `$env:CLAUDE_*` reads), AND must add a corresponding `[[hooks.PreToolUse]]` registration to both `config.toml` files.**

Reintroducing the file without a registration would recreate this orphan. Reintroducing it with legacy `CLAUDE_TOOL_INPUT` transport would recreate the class of defect that issue #415 repairs. Both root and bundle copies must be added together to preserve the byte-identity parity assertions in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and the new path must be added to a pack manifest under `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/` or it will fail `test_bundled_codex_files_are_listed_in_some_pack_manifest`.

Scope note: issue #415 explicitly does **not** reintroduce or rewire this hook (`spec.md:80`). It only deletes the unregistered legacy-transport orphan from the bundle to achieve root/bundle byte-identity, and records this cross-reference.

## Companion change

Plan task `[P1-T4]` removes the now-stale entry `".codex/hooks/enforce-pr-author-skill.ps1"` from `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS` in `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, because `test_no_bundled_codex_file_is_absent_from_disk_and_exception_list` asserts every exception entry still exists on disk. Without that removal this deletion would leave a red test. When issue #335 reintroduces the hook, that exception entry must **not** be restored — the reintroduced file belongs in a real pack manifest, not the exception list.
