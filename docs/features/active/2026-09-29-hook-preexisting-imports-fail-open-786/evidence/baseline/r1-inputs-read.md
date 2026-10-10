# Remediation Cycle 1 Inputs Read ([P0-T2])

Timestamp: 2026-10-10T08-26
Command: <SCRATCHPAD>/r1-aclines.ps1 (route sh, fresh process; reads spec.md as UTF-8 and hashes each matching AC line with SHA-256)
EXIT_CODE: 0
Output Summary: five AC lines found at 233, 238, 239, 244, 251; AC-6 and AC-24 unchecked; AC-11, AC-12, AC-17 checked; 25 checked and 2 unchecked AC items in total.

Files Read:
1. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/remediation-inputs.2026-10-10T06-50.md
2. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/policy-audit.2026-10-10T06-50.md
3. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/code-review.2026-10-10T06-50.md
4. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/feature-audit.2026-10-10T06-50.md
5. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md
6. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/remediation-plan.2026-10-10T06-50.md
7. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md (sections 0 and 5)
8. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/deviations.md
9. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pester-coverage.md
10. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/coverage-comparison.md
11. docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p10-coverage-pass2.md

AC Lines:
- AC-6 | line=233 | state=[ ] | sha256=b1373d71f8d3880b03f659e041cc920957d3ae6954fd6450f80490fffa795def
- AC-11 | line=238 | state=[x] | sha256=6cb5ec2448e66f283605bc034ae7c476a02c6ba8bf2d62556186da2c3ca76eb8
- AC-12 | line=239 | state=[x] | sha256=65dcd2292361ba247115265e0661384d1e509b89ac537e3cfd55dbdf28ea177e
- AC-17 | line=244 | state=[x] | sha256=b1edbd7e5ea3b1da150b90b0052d4bb15190b347d6290c828896b3291ac77690
- AC-24 | line=251 | state=[ ] | sha256=4f0e53d36ec728f7f2fbcaf6b319096ecb70be79e9b025e1161aae15de51aa66

AC-6-TEXT: - [ ] AC-6: For every registered Claude PreToolUse hook with dependencies, a test per direct edge simulates that edge's failure with the C3 mocks and asserts a deny decision whose reason begins with the hook's existing leading token (or existing prose prefix) and names the failed dependency; the entry point returns exit code 0 with the deny JSON and calls no HookPayload function.
