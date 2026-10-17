# Code Review (issue #895)

Timestamp: 2026-10-12T18-30
Range: 88946d10a47911a426abec906b2b2163814f5950..18566f978bcf04c4411f975b5d4c08c3ff6fe97e
Files reviewed: `.codex/codex-web-setup.sh`, bundled mirror, `tests/shell/helpers/codex_web_setup_common.bash`, the four `test_codex_web_setup_codex_*.bats` suites, two fixtures.

## Summary

No blocking findings. Three non-blocking observations. The change is small, matches the issue's implementation intent, and keeps the mirror byte-identical.

## Review by Area

### Script (`.codex/codex-web-setup.sh`)
- `log_solution_selection` is a small pure-ish function taking the listing and selection as arguments, separate from the I/O call in `main`. Consistent with the existing `select_solution_file` and `resolve_repo_root` style. Good separation of concerns.
- The count uses `sed -n '$='`, which is portable and does not depend on `wc` whitespace formatting.
- With `set -euo pipefail`, an empty listing skips the block; the function returns 0 because the `if` has no failing final command. Verified by C824-63 expectation (status 0, empty output).
- GNU find comment is adjacent to the `find -printf` call (AC-3).

### Test helper and suites
- Shared helper defines `SCRIPT_UNDER_TEST`, `FIXTURES`, `setup`, `run_with_stub_path`, `record` once; the three suites load it and keep their own `teardown`. The three suites no longer redefine them (AC-4).
- `run_with_stub_path` now uses the committed `empty-path` fixture and sets `PATH`/`HOME` locally; no leakage because of `local`.
- New cases C824-62/-63/-64 follow AAA and cover two-file selection, empty-listing, and positive discovery.
- C824-37 asserts the fixture invariant with `grep -c -x ... = 1` in Arrange.

## Findings

| ID | Severity | Location | Finding | Recommendation |
|---|---|---|---|---|
| CRV-1 | Minor (non-blocking) | `tests/shell/test_codex_web_setup_codex_copy.bats` C824-62 | The case builds its own two-name listing; AC-1 requires a bats case with two root `*.sln` files, which this satisfies via a listing string rather than a two-file fixture. It does not exercise the `main` call site that passes `list_root_solution_files` output. | Acceptable as is. Optionally add a two-`.sln` fixture if call-site coverage is wanted. |
| CRV-2 | Nit | `tests/shell/test_codex_web_setup_codex_installers.bats` header comment (lines 14-18) | A re-wrapped comment line is longer than neighbouring lines ("functions the test defines satisfy `command -v`. Nothing is downloaded or installed and no"). | Re-wrap for consistency; no functional effect. |
| CRV-3 | Nit | `.codex/codex-web-setup.sh:29` | The GNU find comment is a single line over 100 characters, whereas other comments in the file wrap at about 90. | Optionally wrap across two lines. |

## Unverified Items

- shfmt, shellcheck, bats, and kcov results: not run (CI-only per operator constraint); pending S9.
- The subshell attribution-limit explanation (xtrace emits events only for simple commands) is a reasoned mechanism supported by `scripts/bash/kcov_trace_env.sh` per the evidence document; confirmation depends on the CI `cov.xml` hit counts (S9).
