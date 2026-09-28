# Baseline Lint-and-Format State (read-only `check`)

Timestamp: 2026-09-07T15-00
Task: [P0-T5]

Command: `sh scripts/bash/shell-qc.sh check`
EXIT_CODE: 0

The `sh` prefix supplies the interpreter explicitly; it is the only difference from the plan's stated
form `scripts/bash/shell-qc.sh check` and does not change which stages run. The script's own shebang
re-execs under bash, so `shfmt -d` and `shellcheck` run exactly as the toolchain policy specifies.

The write-mode `format` command was deliberately NOT run in this phase, so this baseline describes
the inherited tree rather than a tree this execution repaired.

## Observation

stdout: 0 bytes.
stderr: 0 bytes.

stdout and stderr were captured to separate files and measured with `wc -c`; both measured 0.

Output Summary: both stdout and stderr were empty and the exit code was 0. This is the clean-run
observation: the `check` command runs `shfmt -d` once over the discovered file list and then
`shellcheck` once per discovered file, and `shfmt -d` prints a unified diff for any unformatted
discovered file, so empty output is falsifiable positive evidence that no discovered shell file is
unformatted and that shellcheck reported no finding.
