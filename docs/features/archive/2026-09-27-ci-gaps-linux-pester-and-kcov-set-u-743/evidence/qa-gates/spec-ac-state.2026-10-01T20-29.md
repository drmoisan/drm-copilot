# spec.md Acceptance Criteria State (P5-T6)

Timestamp: 2026-10-01T20-29

Command: grep -c -F -e '- [x] AC-' docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md
EXIT_CODE: 0
Output Summary: `20`

Command: grep -c -F -e '- [ ] AC-' docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md
EXIT_CODE: 0
Output Summary: `2`

Command: grep -n -F -e '- [ ] AC-5:' -e '- [ ] AC-21:' docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md
EXIT_CODE: 0
Output Summary: exactly two lines: line 238 (AC-5) and line 254 (AC-21).

AC-5 and AC-21 are not checked because the `scripts/dev-tools/run-actionlint.ps1` wrapper run they name is an operator-run item that has not been recorded.

Acceptance: counts 20 and 2; the third command prints exactly the AC-5 and AC-21 lines. Met.
