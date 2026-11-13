# Coverage comparison for Pester run 2 (issue #1157, P6-T6)

Timestamp: 2026-11-11T06-20
Command: pwsh SCRATCH/issue-1157-summary.ps1 and SCRATCH/issue-1157-missed.ps1 over artifacts/pester/powershell-coverage.xml written by the run recorded in pester-final.2026-11-11T06-18.md
EXIT_CODE: 1
Output Summary:
- Outcome: remediation-required; two values miss their threshold.
- New files (threshold 90%): enforce-owner-directive-pass-down.ps1 91.41% (149/163) PASS; owner-directive-pass-down-target.ps1 88.33% (106/120) FAIL; validate-orchestrator-output-owner-pass-down.ps1 92.86% (117/126) PASS; OrchestratorStateOwnerDirectiveSelection.psm1 100.00% (110/110) PASS; OrchestratorStateOwnerDirectiveDecision.psm1 98.53% (67/68) PASS.
- Changed files (threshold 85% and no drop against the Phase 0 baseline in pester-baseline.2026-11-10T04-02.md): OrchestratorStateOwnerDirectives.psm1 99.04% (207/209) against baseline 100.00% (151/151) FAIL (drop); validate-orchestrator-output.ps1 99.32% (147/148) against baseline 99.30% (141/142) PASS.
- Repo-wide line coverage: 95.77% (38169/39854) against the 85% threshold PASS; baseline 95.80%.
- Uncovered lines: owner-directive-pass-down-target.ps1 holds 14 uncovered lines, mostly default seam script blocks that the suite always replaced; OrchestratorStateOwnerDirectives.psm1 holds 2 uncovered lines, the "Ledger line #N is not a JSON object." branch for a line that parses as JSON but is not an object.
- Remediation: five rows added to tests/scripts/claude-hooks/owner-directive-pass-down-target.Tests.ps1 (`default seam parameters delegate to the named readers and resolvers`) that exercise the default reader, file-test, and epic and parallel resolver seams through mocks of the named functions, and one row added to tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Entry.Tests.ps1 for a ledger line that parses as a JSON array. Static checks re-run clean (42 files, 0 format differences, 0 analyzer findings, leak scan exit 0). The Pester gate is re-run for the post-remediation figures.
