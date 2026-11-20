# Baseline — Existing shell-qc --help (parity reference) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: poetry run shell-qc --help
EXIT_CODE: NOT-EXECUTED (see note)

Note: Per the orchestrator's toolchain-execution constraints, the old Poetry-driven
`poetry run shell-qc` entry point is not executed by the executor: it is the Python/Poetry
surface being removed by this feature, and it is not on the executor's Bash allowlist.
The parity reference is captured from the authoritative source
`scripts/dev_tools/shell_qc.py::parse_args` (lines 438-457).

Argparse structure (parity reference for the NEW wrapper `--help` surface):
- program description: "Run shell script formatting, linting, and tests."
- required subcommand (dest="command"): {check, format, pyright, test}
  - check:   "Run shfmt -d and shellcheck."
  - format:  "Format shell scripts with shfmt."
  - pyright: "Run pyright with --project pyproject.toml." (intentionally NOT ported; Non-Goal)
  - test:    "Run bats tests when available." with optional `--coverage` flag
- argparse exits 0 on `--help`/`-h`; exits 2 on usage errors (unknown/missing subcommand).

Output Summary: The native wrapper implements a distinct `--help`/`-h`/`help` usage surface
(research 2.8) documenting `check|format|test [--coverage]`, exit 0 on help, exit 2 on usage
errors. Byte-identical argparse output is NOT a requirement; the exit-code contract (0 for
help, 2 for usage error) is the parity requirement carried forward. The `pyright` subcommand
is intentionally excluded (spec Non-Goals).
