# Remediation Inputs (issue #895)

Timestamp: 2026-10-12T18-30

Artifacts:
- policy-audit: docs/features/active/2026-10-11-codex-web-setup-review-follow-ups-895/policy-audit.2026-10-12T18-30.md
- code-review: docs/features/active/2026-10-11-codex-web-setup-review-follow-ups-895/code-review.2026-10-12T18-30.md
- feature-audit: docs/features/active/2026-10-11-codex-web-setup-review-follow-ups-895/feature-audit.2026-10-12T18-30.md

## Remediation-Required Findings

All items below are CI-dependent and need no code change. They are completed at orchestrator step S9 after the PR exists.

1. RR-1 (policy-audit, Shell Toolchain: FAIL): shfmt, shellcheck, and bats results are absent. Action: open the PR, then record the green results of "Run shell-qc check (shfmt diff + shellcheck)" and "Run shell-qc test with coverage" against the PR head in `evidence/qa-gates/ci-shell-check-895.md` and `ci-bats-895.md`, replacing `S9-EVIDENCE: PENDING`. If either job fails, fix the reported file and rerun.
2. RR-2 (policy-audit, Coverage Verification: FAIL): Bash kcov artifact absent. Action: record the `Bash coverage (lines): NN.N%` line and the `.codex/codex-web-setup.sh` line rate from the PR head in `ci-kcov-coverage-895.md`; require repo-wide line coverage at or above 85% and no regression against `evidence/baseline/ci-baseline-kcov-coverage-895.md` (reference: 94.3% repo-wide, 95.7% script from PR #879).
3. RR-3 (feature-audit, AC-7 PARTIAL): replace the pending marker in the "## CI kcov evidence" section of `evidence/other/kcov-subshell-attribution-limit-895.md` with `cov.xml` hit counts for the three bare subshell delimiter lines and neighbouring command lines, then check AC-7.
4. RR-4 (feature-audit, AC-8 PARTIAL): after RR-1 and RR-2 are green, check AC-8 in `issue.md`. Byte identity is already verified.

## Non-Blocking Suggestions (optional)

- CRV-2: re-wrap the lengthened header comment in `tests/shell/test_codex_web_setup_codex_installers.bats`.
- CRV-3: wrap the GNU find comment at `.codex/codex-web-setup.sh:29` and mirror the change byte for byte.
