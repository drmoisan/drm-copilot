# AC Evidence Index (P7-T25)

Timestamp: 2026-10-01T18-00
Source: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md`, `## Acceptance Criteria` (full-bug).
Final verification: CI run 36901896617 on CI_SHA ecba8829604f6265dc491c74cf42546f9d5aab57. Evidence paths are relative to `<FEATURE>/evidence/`.

- AC-1: PASS — regression-testing/pass-after-poshqc-workflow.2026-10-01T16-55.md; qa-gates/ci-final-windows.2026-10-01T17-57.md
- AC-2: PASS — regression-testing/pass-after-poshqc-workflow.2026-10-01T16-55.md; qa-gates/ci-final-windows.2026-10-01T17-57.md
- AC-3: PASS — regression-testing/pass-after-poshqc-workflow.2026-10-01T16-55.md; qa-gates/ci-final-windows.2026-10-01T17-57.md
- AC-4: PASS — regression-testing/poshqc-job-unchanged.2026-10-01T16-37.md; regression-testing/pass-after-poshqc-workflow.2026-10-01T16-55.md
- AC-5: REMEDIATION-REQUIRED — operator-run blockers B1, B2, B3: `scripts/dev-tools/run-actionlint.ps1` was not run (no pwsh in this session). Supplementary direct `actionlint` exit 0: baseline/actionlint-poshqc.2026-10-01T16-13.md, regression-testing/actionlint-poshqc.2026-10-01T16-37.md, qa-gates/qc-actionlint.2026-10-01T17-23.md
- AC-6: REMEDIATION-REQUIRED — qa-gates/ci-final-conclusions.2026-10-01T17-57.md; qa-gates/ci-final-linux.2026-10-01T17-57.md; qa-gates/linux-remediation-required.2026-10-01T16-58.md (12 Linux failures remain in 5 hook-suite files outside this plan's file list)
- AC-7: PASS — qa-gates/ci-final-conclusions.2026-10-01T17-57.md; qa-gates/ci-final-windows.2026-10-01T17-57.md
- AC-8: PASS — qa-gates/ci-final-windows.2026-10-01T17-57.md; qa-gates/ci-final-linux.2026-10-01T17-57.md (epic-child-launch-hardening suite `failures=0` on both runners)
- AC-9: PASS — qa-gates/ci-final-windows.2026-10-01T17-57.md; qa-gates/ci-final-linux.2026-10-01T17-57.md (decision-surface suite `failures=0` on both runners; premise comment corrected, P5-T3)
- AC-10: REMEDIATION-REQUIRED — qa-gates/linux-first-run-failures.2026-10-01T17-57.md; qa-gates/no-unconditional-skip.2026-10-01T17-57.md; qa-gates/linux-remediation-required.2026-10-01T16-58.md (rows 13 to 21 fixed; rows 1 to 12 not fixed here)
- AC-11: PASS — regression-testing/shellcheck-trace-env-initial.2026-10-01T16-33.md; qa-gates/qc-bash-check.2026-10-01T17-23.md; qa-gates/qc-bats-shell-qc.2026-10-01T17-23.md
- AC-12: PASS — regression-testing/bash-static-post-edit.2026-10-01T16-34.md; regression-testing/trace-discard-negative-control.2026-10-01T16-35.md
- AC-13: PASS — regression-testing/fail-before-bats.2026-10-01T16-32.md; regression-testing/pass-after-bats.2026-10-01T16-34.md; qa-gates/qc-bats-shell-qc.2026-10-01T17-23.md
- AC-14: PASS — regression-testing/pass-after-bats.2026-10-01T16-34.md; regression-testing/trace-discard-negative-control.2026-10-01T16-35.md; qa-gates/qc-bats-shell-qc.2026-10-01T17-23.md
- AC-15: PASS — qa-gates/qc-bats-shell-qc.2026-10-01T17-23.md; qa-gates/qc-shell-qc-test-full.2026-10-01T17-45.md; qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md
- AC-16: PASS — qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md; qa-gates/coverage-comparison.2026-10-01T17-58.md
- AC-17: PASS — qa-gates/skill-guidance.2026-10-01T17-13.md
- AC-18: PASS — qa-gates/skill-guidance.2026-10-01T17-13.md
- AC-19: PASS — qa-gates/pytest-claude-resource-contracts.2026-10-01T17-14.md; qa-gates/skill-hashes.2026-10-01T17-14.md; qa-gates/qc-pytest-claude-resource-contracts.2026-10-01T17-23.md
- AC-20: PASS — qa-gates/scope-check.2026-10-01T17-57.md; qa-gates/scope-forbidden-paths.2026-10-01T17-57.md
- AC-21: REMEDIATION-REQUIRED — every other toolchain step passed in loop pass 1 (qa-gates/qc-loop-pass.2026-10-01T17-23.md, qa-gates/qc-ps-pester-full.2026-10-01T17-57.md with PowerShell line coverage 96.31%), but the actionlint step through `scripts/dev-tools/run-actionlint.ps1` is operator-pending (B3).
- AC-22: PASS — qa-gates/line-counts.2026-10-01T17-25.md; qa-gates/no-temp-files.2026-10-01T17-25.md; qa-gates/no-temp-files-status.2026-10-01T17-25.md

Plan outcome: REMEDIATION-REQUIRED. 18 of 22 ACs are PASS. AC-6 and AC-10 require fixing the 12 Linux-only failures in `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`, `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`, and `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` in a remediation cycle. AC-5 and AC-21 require the operator to run `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`.

No PRE-EXISTING-FAILURE status applies: every baseline failure set (P0-T12, P0-T18, P0-T23, P0-T24) is empty.
