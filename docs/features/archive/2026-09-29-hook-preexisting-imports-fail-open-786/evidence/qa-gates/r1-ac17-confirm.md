# Remediation Cycle 1 AC-17 Non-Regression Confirmation ([P6-T4])

Timestamp: 2026-10-10T18-41
Command: grep -c "^- \[x\] AC-17:" docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md; grep "^- \[x\] AC-17:" docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md | tr -d '\n' | sha256sum (SHA-256 of the UTF-8 line text, as in [P0-T2]); root counts from evidence/qa-gates/final-pester-coverage.md ([P5-T3]); result from evidence/qa-gates/r1-preexisting-tests.md ([P5-T8])
EXIT_CODE: 0
Output Summary: one `- [x] AC-17:` line; its SHA-256 equals the [P0-T2] value; [P5-T3] JUnit root failures 0 and errors 0; [P5-T8] AC17-RESULT pass.

AC-17-CHECKED-COUNT: 1
AC-17-SHA256: b1edbd7e5ea3b1da150b90b0052d4bb15190b347d6290c828896b3291ac77690
P0-T2-AC-17-SHA256: b1edbd7e5ea3b1da150b90b0052d4bb15190b347d6290c828896b3291ac77690 (evidence/baseline/r1-inputs-read.md)
SHA-MATCH: yes
P5-T3-ROOT: JUNIT_ROOT: tests=9505 failures=0 errors=0
P5-T8-RESULT: AC17-RESULT: pass | failing paths=0
