# AC Evidence Index (remediation cycle 1, P5-T7)

Timestamp: 2026-10-01T20-30
Source: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md`, `## Acceptance Criteria` (full-bug).
Final verification: CI run 36918378249 on CI_SHA 42db4491a6a7af4d0a876bf4022f7153e66f5c88 (all 17 jobs `success`). Evidence paths are relative to `<FEATURE>/evidence/`. Earlier-cycle paths are carried from `other/ac-evidence-index.2026-10-01T18-00.md`.

- AC-1: PASS — regression-testing/pass-after-poshqc-workflow.2026-10-01T16-55.md; qa-gates/ci-final-windows.2026-10-01T17-57.md; qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md
- AC-2: PASS — regression-testing/pass-after-poshqc-workflow.2026-10-01T16-55.md; qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md
- AC-3: PASS — regression-testing/pass-after-poshqc-workflow.2026-10-01T16-55.md; qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md (artifact `poshqc-linux-hook-test-results` downloaded from run 36918378249)
- AC-4: PASS — regression-testing/poshqc-job-unchanged.2026-10-01T16-37.md; qa-gates/scope-check.2026-10-01T19-59.md (this cycle changed no workflow file)
- AC-5: OPERATOR-PENDING — other/operator-run-items.2026-10-01T20-27.md; supplementary direct actionlint exit 0: qa-gates/qc-actionlint-direct.2026-10-01T19-58.md, qa-gates/qc-actionlint.2026-10-01T17-23.md
- AC-6: PASS — qa-gates/ci-remediation-conclusions.2026-10-01T20-21.md; qa-gates/ci-remediation-linux-log.2026-10-01T20-22.md; qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md; qa-gates/ac-6-run-record.2026-10-01T20-28.md
- AC-7: PASS — qa-gates/ci-remediation-conclusions.2026-10-01T20-21.md; qa-gates/ci-remediation-windows-log.2026-10-01T20-23.md; qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md
- AC-8: PASS — qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md; qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md (epic-child-launch-hardening suite `failures=0` on both runners)
- AC-9: PASS — qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md; qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md (decision-surface suite `failures=0` on both runners)
- AC-10: PASS — qa-gates/linux-first-run-failures.2026-10-01T20-26.md; qa-gates/ci-remediation-inventory.2026-10-01T20-22.md; regression-testing/linux-baseline-junit.2026-10-01T19-01.md (fail-before); qa-gates/no-unconditional-skip.2026-10-01T19-59.md
- AC-11: PASS — regression-testing/shellcheck-trace-env-initial.2026-10-01T16-33.md; qa-gates/qc-bash-check.2026-10-01T19-25.md
- AC-12: PASS — regression-testing/bash-static-post-edit.2026-10-01T16-34.md; regression-testing/trace-discard-negative-control.2026-10-01T16-35.md
- AC-13: PASS — regression-testing/fail-before-bats.2026-10-01T16-32.md; regression-testing/pass-after-bats.2026-10-01T16-34.md; qa-gates/qc-shell-qc-test-full.2026-10-01T19-57.md
- AC-14: PASS — regression-testing/pass-after-bats.2026-10-01T16-34.md; regression-testing/trace-discard-negative-control.2026-10-01T16-35.md; qa-gates/qc-shell-qc-test-full.2026-10-01T19-57.md
- AC-15: PASS — qa-gates/qc-shell-qc-test-full.2026-10-01T19-57.md (command line recorded with the `<npm-cache>` bats path); qa-gates/qc-shell-qc-test-not-ok.2026-10-01T19-57.md; qa-gates/ci-remediation-conclusions.2026-10-01T20-21.md
- AC-16: PASS — qa-gates/ci-remediation-conclusions.2026-10-01T20-21.md (shell-coverage job `success`); qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md
- AC-17: PASS — qa-gates/skill-guidance.2026-10-01T17-13.md
- AC-18: PASS — qa-gates/skill-guidance.2026-10-01T17-13.md
- AC-19: PASS — qa-gates/skill-hashes.2026-10-01T17-14.md; qa-gates/qc-pytest-claude-resource-contracts.2026-10-01T19-58.md
- AC-20: PASS — qa-gates/scope-check.2026-10-01T19-59.md; qa-gates/scope-forbidden-paths.2026-10-01T19-59.md
- AC-21: OPERATOR-PENDING — all other toolchain steps passed in loop pass 1 (qa-gates/qc-loop-pass.2026-10-01T20-00.md; PowerShell line coverage 96.31% in qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md); the actionlint step through `scripts/dev-tools/run-actionlint.ps1` is operator-run (other/operator-run-items.2026-10-01T20-27.md)
- AC-22: PASS — qa-gates/line-counts.2026-10-01T19-59.md; qa-gates/no-temp-files.2026-10-01T19-59.md

Plan outcome: OPERATOR-PENDING. 20 of 22 ACs are PASS; the remaining item is the operator-run `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`, which closes AC-5 and AC-21.

### Acceptance Criteria Status
Source: docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md
Total AC items: 22
Checked off (delivered): 20
Remaining (unchecked): 2
Items remaining: AC-5, AC-21
