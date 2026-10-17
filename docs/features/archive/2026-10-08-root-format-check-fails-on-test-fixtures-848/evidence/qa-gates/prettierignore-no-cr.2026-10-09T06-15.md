# Prettier ignore no-CR check

Timestamp: 2026-10-09T06-15
Command: grep -cP "\r" .prettierignore
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: grep printed 0 with exit 1; .prettierignore contains no carriage return (LF endings; wc reports 2 lines).
