# P17-T6 Bash Coverage Comparison

Timestamp: 2026-10-10T10-10
Command: none - comparison of recorded values
EXIT_CODE: 0
Output Summary:
- Inputs: docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/baseline/ci-shell-round0.2026-10-10T09-40.md (P13-T1, CI run 38056265858); docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/qa-gates/ci-bats-round1.2026-10-10T10-08.md (P16-T4) and docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/evidence/qa-gates/ci-kcov-codex-setup-round1.2026-10-10T10-08.md (P16-T5), passing round 1, CI run 38057811190.
- Repo-wide Bash line coverage: BASE_BASH_LINE 94.2; FINAL_BASH_LINE 94.3; delta +0.1 percentage points. The delta is reported and not gated, because `.codex/codex-web-setup.sh` entered the denominator in round 1 and changed the population.
- `.codex/codex-web-setup.sh` baseline: NOT MEASURED (round 0 MATCHES 0).
- `.codex/codex-web-setup.sh` post-change: FINAL_CODEX_SETUP_PCT 95.67 (199 of 208 lines hit); FINAL_CODEX_SETUP_RATE 0.957.
- New/changed-code coverage: .codex/codex-web-setup.sh 95.67 (the shfmt layout changed every indented line, so the whole-file value is the changed-line value)
- Branch coverage: N/A - kcov measures no bash branch coverage; no bash branch gate applies
- Gate: FINAL_CODEX_SETUP_RATE 0.957 is at least 0.85; FINAL_BASH_LINE 94.3 is at least 85.0.

Verdict: PASS
