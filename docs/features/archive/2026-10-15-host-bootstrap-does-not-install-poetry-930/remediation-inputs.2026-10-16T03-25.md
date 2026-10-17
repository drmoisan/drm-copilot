# Remediation Inputs: Host bootstrap installs poetry (Issue #930)

Review-Verdict: AWAITING_CI

Reviewed head: 4470de936

Artifacts:
- docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/policy-audit.2026-10-16T03-25.md
- docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/code-review.2026-10-16T03-25.md
- docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/feature-audit.2026-10-16T03-25.md

## Blocking Findings

### Finding 1: CI-dependent AC-11 and repo-wide PowerShell coverage are pending

Remediability: awaiting_ci
Remediability-Evidence: The check needs the result of the CI job on the PR head, which does not exist until the PR is opened and CI runs; no code change is indicated.

The `poshqc / PowerShell QC` job must pass on the PR head with line coverage at or above the repository threshold. The only on-disk coverage artifact comes from a run scoped to `tests/scripts/dev-tools`, so it cannot establish the repo-wide figure. Module-level coverage for `HostBootstrap.psm1` is 100.00% (155/155 lines).

Action: after the CI green gate records success, the item's orchestrator run checks off AC-11 in issue.md, pushes, and re-runs the gate against the final head.
