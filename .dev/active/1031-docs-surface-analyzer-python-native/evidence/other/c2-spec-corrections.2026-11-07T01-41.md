# [P2-T1] Specification correction M1

Timestamp: 2026-11-07T01-41
Command: git grep -c on FEATURE/spec.md for the two tokens
EXIT_CODE: 0
Output Summary: M1 applied: exit 4 maps to version-below-floor and any other non-zero exit to exit-nonzero.

## Outputs

- `git grep -c "treated by the adapter" -- FEATURE/spec.md` printed nothing.
- `git grep -c version-below-floor -- FEATURE/spec.md` printed a count of 3 (it was 2 before the edit).

Edited heading: `### Helper protocol (protocol version 1)`. The sentence now matches `### Fallback rules` and the `ExitCode -eq 4` branch of `Get-DocsPythonNativeResult`.
