# Remediation Inputs — Issue #962 (cycle 1, CI failure)

Timestamp: 2026-10-17T01-20
Source: CI run 38988542731 (workflow_dispatch, head 0f0d95c2d99f74f4d98994315dd7f4a7f73a512a)
Review-Verdict: REMEDIATION_REQUIRED

## Finding RI-1: required check security-scan fails on pre-existing dependency advisories

- Severity: Blocking
- Remediability: autonomous
- Failing check: `security-scan / Security Scanning`
- Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/38988542731/job/117265576360
- Evidence: `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/ci-security-scan.2026-10-17T01-18.md` (`SAFETY-RESULT: findings`, `101 vulnerabilities reported`, `##[error]Process completed with exit code 64.`); finding list in `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/security-scan-findings.2026-10-17T01-18.md` (101 findings, 14 packages).
- Cause: the D14-b change makes the scan non-vacuous (export plugin installed, `shell: bash` pipefail) and blocking (no `continue-on-error`). The 101 findings are pre-existing in `poetry.lock` and are not introduced by this branch.
- Required remediation (plan decision PD-18, findings branch): restore `continue-on-error: true` on the step `Check for security vulnerabilities` in `.github/workflows/_security-scan.yml` only, keeping the `Install the Poetry export plugin` step, `shell: bash`, and the run-heavy gating unchanged. Adjust row W18 of `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` and the `### Security scan` subsection of `.github/workflows/README.md` (section 10 of the plan) to describe the non-blocking scan with a working export. Re-run the workflow suite and the Phase 6 QA stages affected (format, analyzer, Pester for `tests/scripts/workflows`, actionlint). AC-36 stays unchecked until CI shows the scan step runs a non-vacuous scan (export succeeded, packages scanned) and the job concludes success.
- Coordinator follow-up (record only, not part of this cycle): upgrading the 14 affected packages and then removing `continue-on-error`.

## Carried forward (not remediated in this cycle)

The four `awaiting_ci` findings of `remediation-inputs.2026-10-17T00-43.md` (B-1 to B-4) are re-evaluated by the re-audit against the CI run of the remediated head.
