# Remediation Inputs (Issue #723)

Artifacts: `policy-audit.2026-10-01T18-00.md`, `code-review.2026-10-01T18-00.md`, `feature-audit.2026-10-01T18-00.md` in this folder.

## Remediation-required

- R1 (policy FAIL, procedural): `artifacts/pester/powershell-coverage.xml` is absent, so coverage verification for PowerShell (changed file: the Pester test file only) has no artifact. Remediation: attach the CI poshqc coverage output from run 36927150048 (or the PR-head run) as `evidence/qa-gates/final-powershell-coverage.md`, recording repo-wide line coverage (>= 85%) and the note that no production `.ps1` file changed. No product file change is required.

## Non-blocking (no action required)

- N1: Optionally add the `npm view` command to the runbook.
- N2/N3: See `code-review.2026-10-01T18-00.md`.
