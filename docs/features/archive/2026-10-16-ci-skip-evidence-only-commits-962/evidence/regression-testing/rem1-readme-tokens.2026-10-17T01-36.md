# README token checks after P1-T5 (P1-T6, RI-1c)

Timestamp: 2026-10-17T01-36
Command: git grep -c -F -e 'The scan step carries' -- .github/workflows/README.md
EXIT_CODE: 0
Output Summary: The two new literals each occur once in README.md (exit 0); the removed literal `The scan step has no` is absent (no output, exit 1, as expected).

- `git grep -c -F -e 'The scan step carries' -- .github/workflows/README.md` EXIT: 0 -> `.github/workflows/README.md:1`
- `git grep -c -F -e '101 pre-existing findings' -- .github/workflows/README.md` EXIT: 0 -> `.github/workflows/README.md:1`
- `git grep -c -F -e 'The scan step has no' -- .github/workflows/README.md` EXIT: 1 (EXPECTED-EXIT: 1) -> (no output)

Exit-code observation method: each command was also run as `<command> || echo "EXIT-NONZERO: $?"`; the first two printed only their match count (exit 0), and the third printed `EXIT-NONZERO: 1`.
