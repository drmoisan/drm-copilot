# R3 CI dispatch on the final code state (issue #927, remediation cycle 3)

Timestamp: 2026-10-16T12-30
Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: HEAD equals origin at 8259a11df; every path changed since the final code commit f8adac1c9, and the one status line, is under the #927 feature folder. ci.yml dispatched (exit 0); the matching workflow_dispatch run is 38900960142 (queued at listing).

Command 2: git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927
EXIT_CODE_2: 0
R3_CI_HEAD: 8259a11df659283c4c78c443be99a02ca7698098

Command 3: git diff --name-only f8adac1c92b95eb7e0464a3e30e10d911e7908ee HEAD
EXIT_CODE_3: 0
DIFF_PATH: docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r3-coverage-delta.2026-10-16T12-29.md
DIFF_PATH: docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r3-pester-route-b.2026-10-16T12-28.md
DIFF_PATH: docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r3-qc-analyze.2026-10-16T12-12.md
DIFF_PATH: docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r3-qc-format.2026-10-16T12-11.md
DIFF_PATH: docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r3-qc-loop-record.2026-10-16T12-29.md
DIFF_PATH: docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r3-qc-parity.2026-10-16T12-12.md
DIFF_PATH: docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r3-qc-pytest-contracts.2026-10-16T12-13.md
DIFF_PATH: docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r3-qc-test-purity.2026-10-16T12-13.md
DIFF_PATH: docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-plan.2026-10-16T14-05.md

Command 4: git status --porcelain
EXIT_CODE_4: 0
STATUS:  M docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-plan.2026-10-16T14-05.md

Command 5: gh workflow run ci.yml --ref bug/pr-author-docs-only-exemption-hardening-927
EXIT_CODE_5: 0

Command 6: gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --event workflow_dispatch --json databaseId,headSha,status,conclusion,createdAt --limit 10
EXIT_CODE_6: 0
NEWEST_MATCHING_RUN: databaseId=38900960142 headSha=8259a11df659283c4c78c443be99a02ca7698098 status=queued createdAt=2026-10-16T12:30:13Z
R3_CI_RUN_ID: 38900960142
