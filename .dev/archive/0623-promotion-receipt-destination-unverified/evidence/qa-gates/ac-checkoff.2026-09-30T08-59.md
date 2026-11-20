# Acceptance Criteria Check-Off Totals (#623)

Timestamp: 2026-09-30T08-59
Command: grep -c -F -e "- [x] AC-" "docs/features/active/promotion-receipt-destination-unverified-623/spec.md"; grep -c -F -e "- [ ] AC-" "docs/features/active/promotion-receipt-destination-unverified-623/spec.md"
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Printed 15 (checked) and 0 (unchecked; grep exits 1 for a zero count, expected). Each AC-1..AC-15 line was checked off individually (P11-T1..P11-T15), and each per-AC grep for `- [x] AC-n:` printed 1. git diff --numstat HEAD on spec.md printed `15	15`: only the 15 checkbox markers changed; criterion text is preserved.

| AC | Evidence |
| --- | --- |
| AC-1 | regression-testing/ts-move-verification-pass-after.2026-09-30T08-39.md |
| AC-2 | regression-testing/ts-move-verification-fail-before.2026-09-30T08-35.md |
| AC-3 | ts-move-verification-pass-after, ts-promotion-suites-pass-after.2026-09-30T08-39.md, qa-gates/existing-suites-unmodified.2026-09-30T08-56.md |
| AC-4 | regression-testing/ts-service-call-pass-after.2026-09-30T08-39.md |
| AC-5 | ts-service-call-pass-after, qa-gates/ts-test-coverage.2026-09-30T08-46.md (DA223=2), qa-gates/service-call-unchanged.2026-09-30T08-56.md |
| AC-6 | regression-testing/py-move-verification-fail-before.2026-09-30T08-35.md, py-move-verification-pass-after.2026-09-30T08-43.md |
| AC-7 | py-move-verification-pass-after, py-existing-suites-pass-after.2026-09-30T08-43.md, existing-suites-unmodified |
| AC-8 | qa-gates/message-parity.2026-09-30T08-56.md |
| AC-9 | qa-gates/filesystem-extraction.2026-09-30T08-56.md, py-move-verification-pass-after |
| AC-10 | qa-gates/py-line-count.2026-09-30T08-56.md |
| AC-11 | qa-gates/line-limits.2026-09-30T08-56.md |
| AC-12 | other/py-filesystem-tests.2026-09-30T08-43.md, qa-gates/test-isolation.2026-09-30T08-56.md |
| AC-13 | qa-gates/ts-format, ts-lint, ts-typecheck, ts-architecture, ts-test-coverage (all 2026-09-30T08-46; one clean Phase 7 pass, P7-T5 case (a)); other/jest-threshold-decision.2026-09-30T08-45.md (DECISION: ADDED); qa-gates/ts-coverage-delta.2026-09-30T08-55.md |
| AC-14 | qa-gates/py-format, py-lint, py-typecheck, py-architecture, py-test-coverage (all 2026-09-30T08-54; Phase 8 pass 2 clean, P8-T5 case (a)); qa-gates/py-coverage-delta.2026-09-30T08-55.md |
| AC-15 | qa-gates/scope.2026-09-30T08-56.md |
