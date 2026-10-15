# Remediation Inputs - Issue #887 (also resolves #888)

- Timestamp: 2026-10-12T15-00
- Source artifacts:
  - docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/policy-audit.2026-10-12T15-00.md
  - docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/feature-audit.2026-10-12T15-00.md

## Remediation-required findings

### R-1 (BLOCKING, policy-audit PA-2): PowerShell coverage not demonstrated

- Observation: the only local coverage artifact (`artifacts/pester/powershell-coverage.xml`, scoped local run) reports 4.04% repo-wide line coverage (496 of 12,282) and contains no entry for `HostTooling.psm1`, `HostBootstrapWorkspace.psm1`, `HostBootstrap.psm1`, or `publish-sideloaded-extension.ps1`.
- Required outcome: the CI `PowerShell QC` coverage artifact for the PR head shows line coverage >= 85% for each of the four changed files, with no changed-line regression against the main baseline (HostTooling 94.74%, the other three 100%), and no coverage exclusion added.
- Action: open the PR, obtain the CI run, and complete plan tasks P2-T10 to P2-T14 (CI job record, per-file coverage, coverage delta, reduced-audit handoff, commit). If a changed file is below 85% in CI, add tests for the uncovered lines before merge. No production or test code defect has been identified; the finding is an evidence gap, not a known coverage shortfall.
- Related AC: AC-16 and AC-17 (pending-CI, unchecked).

## Non-blocking items (no remediation required)

- PA-1: use the system clock for evidence filename timestamps in later artifacts.
- CR-1 to CR-3: see code-review.2026-10-12T15-00.md.
