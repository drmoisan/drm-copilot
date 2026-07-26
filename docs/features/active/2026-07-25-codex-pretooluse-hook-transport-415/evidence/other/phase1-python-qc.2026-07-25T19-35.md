# Phase 1 — Python QC Loop (Issue #415)

Timestamp: 2026-07-25T19-35

Trigger: plan task `[P1-T4]` edited one `.py` file (`tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`), which engages `.claude/rules/python.md`. The four stages below ran in the mandated order and **all four passed in a single uninterrupted pass** — no stage failed and no stage changed a file, so no restart was required.

## Stage 1 — Format

Command: `poetry run black --check tests/scripts/dev_tools`
EXIT_CODE: 0

```
All done! ✨ 🍰 ✨
182 files would be left unchanged.
```

## Stage 2 — Lint

Command: `poetry run ruff check tests/scripts/dev_tools`
EXIT_CODE: 0

```
All checks passed!
```

## Stage 3 — Type check

Command: `poetry run pyright`
EXIT_CODE: 0

```
0 errors, 0 warnings, 0 informations
```

(The trailing Pyright upgrade advisory v1.1.409 → v1.1.411 is a wrapper notice on stderr, not a diagnostic; it does not affect the exit code. Dependency upgrades are out of scope.)

## Stage 4 — Targeted tests

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`
EXIT_CODE: 0

```
........                                                                 [100%]
8 passed in 0.10s
```

## Output Summary

**All four stages exit 0 in one pass.** Black: 182 files unchanged. Ruff: zero findings. Pyright: 0 errors / 0 warnings / 0 informations. Pytest: 8 passed, 0 failed.

The acceptance clause of `[P1-T5]` is satisfied on both of its substantive points:

- **Config parity restored.** `[P1-T2]` confirmed `git diff .codex/config.toml` is empty and root/bundle SHA256 both equal `160C5A0601918775D4190EF5EB14BB9F5DCD3FB8D8CF7FC3F80A20DCC4F704BD`, so `test_codex_config_files_retain_full_drm_copilot_transport` and the payload-contract tests in `test_push_down_codex_and_agents_resource_contracts.py` pass.
- **Exception list consistent with disk.** `[P1-T3]` deleted the bundle orphan `enforce-pr-author-skill.ps1` and `[P1-T4]` removed its now-stale entry from `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS`. `test_no_bundled_codex_file_is_absent_from_disk_and_exception_list` — which asserts every exception entry still exists on disk — passes with the pair applied together. Applying either change without the other would have produced a red test.

Change scope for this stage: exactly one removed line, verified by `git diff --stat` (`1 file changed, 1 deletion(-)`).
