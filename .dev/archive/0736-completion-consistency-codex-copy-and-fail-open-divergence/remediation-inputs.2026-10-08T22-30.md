# Remediation Inputs (issue #736)

- Reviewed: 2026-10-08
- Source artifacts:
  - `docs/features/active/2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736/policy-audit.2026-10-08T22-30.md`
  - `docs/features/active/2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736/code-review.2026-10-08T22-30.md`
  - `docs/features/active/2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736/feature-audit.2026-10-08T22-30.md`

## Remediation-Required Findings

### R-1: Repo-wide PowerShell line coverage below policy (pre-existing)

- Severity: FAIL by the repo-wide coverage rule; not attributable to this branch.
- Evidence: `artifacts/pester/powershell-coverage.xml` report-level LINE counter covered=8966, missed=6846, which is 56.70%. Policy requires >= 85% (remediation trigger below 80%).
- Attribution: none of the four changed production files lowered coverage (deltas +1.49, +3.99, 0, +8.99 points). The baseline repo-wide figure was not captured in the executor evidence, so a repo-wide before and after delta is UNVERIFIED.
- Recommended disposition: do not remediate inside this bug fix. File or reference a repo-level coverage issue, or have the orchestrator accept the finding as pre-existing. Capturing a repo-wide baseline figure in future baseline evidence would make attribution verifiable.

## Not Remediation-Required (for orchestrator awareness)

- CI confirmation of the two Python bundle-parity tests and a full CI run (AC-14): orchestrator step.
- The two pre-existing baseline test failures (`enforce-pr-author-skill.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`): outside this branch.

## Blocking Summary

- No code, test, or documentation change in this branch requires remediation.
- R-1 is the only item and is a pre-existing, non-attributable finding.
