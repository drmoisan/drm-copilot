# Baseline — bash lint stage (remediation cycle 1, issue #631)

Timestamp: 2026-09-07T14-49

Command: `bash scripts/bash/shell-qc.sh check`

EXIT_CODE: 0

Output Summary:

- The command produced no output and exited 0.
- `check` runs `shfmt -d` once over the full discovered file list and then `shellcheck` once per
  file, returning the maximum exit code (`.claude/rules/shell.md`, Toolchain step 2).
- **shfmt diff count: 0.** A non-empty diff would have been printed to stdout and would have
  driven the stage's exit code non-zero.
- **shellcheck finding count: 0.** Any shellcheck finding would have been printed and would have
  driven the maximum exit code non-zero.
- Both tools resolved from the Windows PATH and ran locally; this stage is not subject to the
  plan's CI Route rule, which applies only to the `test` and `test --coverage` stages.
