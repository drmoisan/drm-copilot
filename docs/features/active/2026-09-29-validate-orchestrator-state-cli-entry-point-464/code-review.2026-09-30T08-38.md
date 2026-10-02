# Code Review: Issue #464 (validate-orchestrator-state CLI entry point)

- Timestamp: 2026-09-30T08-38
- Branch: `bug/validate-orchestrator-state-cli-entry-point-exec-464`
- HEAD: `7cf9f1f5`
- Diff base: `5b09b53899ac9dad870f855cbcc359098266e213`
- Reviewed: `validate_orchestrator_state_cli.py`, `_orchestrator_state_remediation_loop.py`, the `validate_orchestrator_state.py` diff, `test_validate_orchestrator_state_cli.py`, and the documentation diffs.

## Executive Summary

Verdict: Approve. Blocking findings: 0. Non-blocking findings: 4 (CR-1 to CR-4).

### Design Assessment

- Simplicity and separation of concerns: the CLI module holds parsing, one I/O seam (`read_checkpoint_text`), and exit-code mapping. The validator is injected through `main(..., *, validate=...)`, so there is no import cycle and no double import under `python -m`. The guard imports the CLI lazily inside `if __name__ == "__main__":`, so library importers do not load it. This matches the spec design.
- Extensibility: `main` takes `argv` and keyword-only `validate`, matching the keyword-style public API preference.
- Error handling: only `OSError` and `UnicodeDecodeError` are caught, only around the read. The diagnostic names the path and the exception type. Validation errors print one per stderr line in returned order. Exit codes 0, 1, 2 match the spec table.
- Typing: `cast("bool", args.<flag>)` and `cast("str", args.path)` follow the repository pattern for strict Pyright; `Callable` and `Sequence` are imported under `TYPE_CHECKING`, valid because of `from __future__ import annotations`.
- Extraction: the removed hunk in `validate_orchestrator_state.py` and the new module body are textually identical for `_validate_remediation_cycle`, `_validate_remediation_loop`, and the five constants (compared line by line from the diff). The validator imports back only `REMEDIATION_LOOP_KEY` and `_validate_remediation_loop`, in isort position. The only additions to the validator are the import and the guard.
- Behavior preservation: existing remediation-loop tests pass unchanged (31 passed across CLI and remediation-loop files in the reviewer run); the wider suite recorded 5718 passed.
- Live behavior (reviewer-run): missing path exits 2 with one line `orchestrator-state checkpoint could not be read: artifacts/nonexistent.json: FileNotFoundError: ...` and no traceback; valid checkpoint exits 0 with the success line; invalid checkpoint exits 1 with errors on stderr.

### Test Review

- 21 tests cover: valid checkpoint, complete-state with `--require-complete`, error ordering, five flags true and all-false (parametrized, including that `strict_route_membership` is never passed), missing path, `PermissionError` and `IsADirectoryError`, non-UTF-8, unexpected exception propagation, unknown flag, missing positional, empty and non-JSON text, CLI versus dispatcher exit-code parity, and the `runpy` guard test with the `filterwarnings` ignore.
- Tests are independent, deterministic, use no temp files, and keep a readable Arrange-Act-Assert layout.
- Recording-fake validator proves flag forwarding without constructing routing-valid checkpoints, as the spec requires.

### Risk Notes

- The exit-code difference from the dispatcher for a missing path (2 versus traceback exit 1) is documented in the spec and is a non-goal fix for the dispatcher.
- Validator headroom is 66 lines (434 of 500) for child #523.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (CR-1) | `scripts/dev_tools/_orchestrator_state_remediation_loop.py` | lines 25-32 | The module declares `__all__` containing a private name (`_validate_remediation_loop`). The spec said the block moves "verbatim" with imports only, and sibling modules may not use this pattern. | Leave as is, or confirm sibling convention in a later cleanup. | Harmless; a comment explains the re-export. | Reviewer read of module lines 25-32. |
| Non-blocking (CR-2) | `scripts/dev_tools/validate_orchestrator_state_cli.py` | line 118 | The body of `read_checkpoint_text` is not executed by unit tests (seam is stubbed; temp files are prohibited). | Add a test that monkeypatches `pathlib.Path.read_text` to cover it without temporary files and raise line coverage to 100%. | Current coverage (97.0% line) satisfies the 85% policy threshold. | `artifacts/python/lcov.info`; `coverage-new-modules.md`. |
| Non-blocking (CR-3) | `tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py` | lines 36-44 | Expected prefixes and flag map are duplicated from the production module instead of imported. | No change; note for maintainers. | Acceptable as an independent oracle; guards against accidental contract change. | Reviewer read of test lines 36-44. |
| Non-blocking (CR-4) | `scripts/dev_tools/validate_orchestrator_state_cli.py` | line 156 | The diagnostic embeds `str(error)`. A custom `OSError` message containing a newline would break the "single stderr line" contract. | No change needed. | For a path error the message is one line; no such case exists in practice. | Reviewer read of CLI line 156 and live missing-path run (single line output). |
