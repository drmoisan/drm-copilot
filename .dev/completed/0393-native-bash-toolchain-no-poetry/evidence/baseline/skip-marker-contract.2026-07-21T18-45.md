# Baseline — Skip-Marker and Missing-Tool Contract (verbatim) (Issue #393)

Timestamp: 2026-07-21T18-45

Source files:
- `scripts/dev_tools/shell_qc.py` (emitter)
- `scripts/dev_tools/fix_all.py::shell_test_was_skipped` (consumer, lines 306-331)

## fix_all-consumed skip markers (byte-identical contract — MUST match)

Emitted by `shell_qc.py`; string-matched by `fix_all.py::shell_test_was_skipped`
(lines 326-329). If these diverge, `fix_all` misreports a skip as a pass.

1. `No shell test directories found; skipping.`
   - Emitter: `shell_qc.py` line 372 (`run_test_with_options`, no test dir).
   - Consumer: `fix_all.py` line 327.
2. `bats not installed; skipping shell tests.`
   - Emitter: `shell_qc.py` line 379 (`run_test_with_options`, bats missing, non-coverage).
   - Consumer: `fix_all.py` line 328.

## Other exact strings (parity, not fix_all-matched)

3. `No shell scripts found; skipping.`
   - Emitter: `shell_qc.py` lines 172 and 201 (`run_check`, `run_format`, no scripts).

## Coverage-mode missing-tool messages

4. `bats not installed; cannot run shell tests with coverage.`
   - Emitter: `shell_qc.py` line 377 (coverage mode, bats missing; exit 127).
5. `kcov not installed; cannot run shell tests with coverage.`
   - Emitter: `shell_qc.py` line 390 (coverage mode, kcov missing; exit 127), followed by
     the five-line missing-tool block for `kcov`.

## Missing-tool block (exactly five lines; source `shell_qc.py` lines 119-132)

Package name defaults to the tool name. For tool `<tool>` / package `<package>`:

```
Missing required tool: <tool>
Devcontainer install (apt-get): apt-get update && apt-get install -y <package>
macOS (Homebrew): brew install <package>
Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y <package>
On Windows, use WSL for best results.
```

Exit code for any missing required tool: 127.

Output Summary: All contract strings captured verbatim with source-file and line attribution.
These are asserted byte-identically by the bats command suite at P2-T6.
