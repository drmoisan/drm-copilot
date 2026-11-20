# Phase 2 — Feature Addition Summary

Timestamp: 2026-04-18T17-29

## Scope
Production files (2):
- scripts/dev_tools/resolve_hard_lock_prompt.py (repo-root resolver)
- extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py (bundled resolver)

Test files (4, of which 2 new):
- tests/scripts/dev_tools/test_resolve_hard_lock_prompt_output.py (NEW)
- tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt_output.py (NEW)
- tests/scripts/dev_tools/test_resolve_hard_lock_prompt_part2.py (unchanged net — Phase 1 alias removal only)
- tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt_part2.py (unchanged net — Phase 1 alias removal only)

Note on file placement: new test coverage was placed in two new files (`test_resolve_hard_lock_prompt_output.py`) rather than cramming into the existing `_part2.py` files, because the combined size would exceed the 500-line file cap. The new files remain inside the authorized test file budget (4 hard-lock test files -> 6 in total).

## Implementation Approach
Both production files received the same additive changes:
1. New internal helper `_write_resolved_prompt(resolved_prompt, output_path, workspace_root)` that:
   - resolves relative `output_path` against `workspace_root` (absolute passed verbatim),
   - creates missing parent directories with `mkdir(parents=True, exist_ok=True)`,
   - writes UTF-8 text via `Path.write_text`,
   - returns the resolved absolute path,
   - lets `OSError` propagate to the caller.
2. New `--output` argparse Path flag (default None). When provided and the helper raises `OSError`, `main()` prints `Error writing output file: <err>` to stderr and returns 1.
3. New `--quiet` argparse store_true flag (default False). Documented in its `--help` text.
4. New argparse validation: `args.quiet and args.output is None` prints `Error: --quiet requires --output; --quiet alone would suppress all output.` to stderr and returns 1.
5. `main()` flow (after resolving the prompt):
   - if `--output` given: call the file-write helper; on OSError -> exit 1 with stderr.
   - if `--quiet` given: return 0 immediately (skip stdout + clipboard).
   - else: print to stdout + attempt clipboard (unchanged original behavior).

## Design Choices
- `--quiet` without `--output` is a **hard error (exit 1)**. Rationale: quiet-alone produces no user-visible artifact (no stdout, no file), only an opaque clipboard side effect; rejecting this configuration matches the `--target` required-flag style and protects against silently-misconfigured MCP callers. This is documented in the `--quiet` help text on both resolvers.
- The file-write helper is inlined per-resolver rather than factored into a shared module. Per task instructions, symmetry between the two packaging copies (root vs bundled) is prioritized over DRY. The helper is intentionally `_`-prefixed (module-internal); tests exercise it through `main()` to avoid Pyright `privateUsage` findings.
- `resolve_prompt(...)` signature is unchanged (instruction required).
- `_normalize_prompt_path_value()` (root) vs `.as_posix()` (bundled) packaging differences preserved.

## Test Coverage (18 new tests)
For each resolver (9 per resolver, mirrored):
1. `--output` absolute path writes verbatim.
2. `--output` relative path resolves against `--workspace`.
3. `--output` relative path resolves against cwd when `--workspace` omitted.
4. `--output` creates missing parent directories.
5. `--output` + `Path.write_text` OSError -> exit 1 + stderr.
6. `--output` + `--quiet` -> file written, no stdout, no clipboard attempt.
7. `--output` without `--quiet` -> file written, stdout + clipboard preserved.
8. No `--output` -> baseline stdout + clipboard behavior preserved.
9. `--quiet` without `--output` -> exit 1 + `--quiet requires --output` stderr, no stdout, no clipboard.

All new tests use the renamed `mem_fs_path` fixture; no real filesystem writes.

## Line Counts (final, all within 500-line limit)
- scripts/dev_tools/resolve_hard_lock_prompt.py: 479
- extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py: 444
- tests/scripts/dev_tools/test_resolve_hard_lock_prompt_output.py: 345
- tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt_output.py: 473
