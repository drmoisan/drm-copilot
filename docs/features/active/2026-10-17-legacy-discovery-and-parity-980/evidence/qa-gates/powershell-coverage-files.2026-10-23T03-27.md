# P11-T4 PowerShell per-file line coverage of changed production files

Timestamp: 2026-10-23T03-27
Command: pwsh -File SCRATCH/issue-980-ps-coverage-files.ps1 -CoverageXml SCRATCH/p11t4/single-powershell-coverage.xml -ChangedList SCRATCH/issue-980-changed-powershell.txt (reads the retained powershell-coverage.2026-10-23T03-27.xml; changed files are the merge base of origin/main and HEAD against HEAD, production .ps1/.psm1 only, bundle mirrors and manifests excluded)
EXIT_CODE: 0
Output Summary: 35 changed production files (25 added, 10 modified), all 35 measured in the 240-file population; 25 at or above the 85% line floor, 10 below (all added host adapter scripts, listed with BELOW); carried to the P11-T5 delta table. Lines are covered/analyzed line counts from the LINE counters.

```text
A .claude/hooks/discovery-capability-probe.ps1 lines=31/35 percent=88.57
M .claude/hooks/enforce-discovery-artifact-gate.ps1 lines=28/29 percent=96.55
A .claude/hooks/enforce-discovery-planning-gate.ps1 lines=23/26 percent=88.46
A .claude/hooks/record-discovery-agent-start.ps1 lines=32/39 percent=82.05
M .claude/hooks/validate-discovery-artifact-gate.ps1 lines=33/33 percent=100.00
M .claude/lib/codex-routing/CodexDeployment.psm1 lines=68/68 percent=100.00
A .claude/lib/codex-routing/CodexDiscoveryRouting.psm1 lines=68/68 percent=100.00
M .claude/lib/codex-routing/CodexTopology.psm1 lines=112/112 percent=100.00
A .claude/lib/discovery-validation/DiscoveryAuthority.psm1 lines=139/147 percent=94.56
A .claude/lib/discovery-validation/DiscoveryAuthorization.psm1 lines=191/200 percent=95.50
A .claude/lib/discovery-validation/DiscoveryCapability.psm1 lines=124/127 percent=97.64
A .claude/lib/discovery-validation/DiscoveryEncoding.psm1 lines=43/46 percent=93.48
A .claude/lib/discovery-validation/DiscoveryManifest.psm1 lines=124/132 percent=93.94
A .claude/lib/discovery-validation/DiscoveryPayload.psm1 lines=97/97 percent=100.00
A .claude/lib/discovery-validation/DiscoveryPlanning.psm1 lines=126/129 percent=97.67
A .claude/lib/discovery-validation/DiscoveryStart.psm1 lines=135/136 percent=99.26
A .claude/lib/discovery-validation/DiscoveryStartRecord.psm1 lines=96/107 percent=89.72
A .claude/lib/discovery-validation/DiscoveryStop.psm1 lines=136/140 percent=97.14
M .claude/lib/discovery-validation/DiscoveryValidation.psm1 lines=77/78 percent=98.72
M .codex/hooks/codex-agent-profile-attestation.ps1 lines=81/86 percent=94.19
A .codex/hooks/discovery-capability-probe.ps1 lines=20/28 percent=71.43
A .codex/hooks/discovery-start-attestation.ps1 lines=77/77 percent=100.00
M .codex/hooks/enforce-codex-model-routing.ps1 lines=78/78 percent=100.00
A .codex/hooks/enforce-discovery-artifact-gate.ps1 lines=38/46 percent=82.61
A .codex/hooks/enforce-discovery-planning-gate.ps1 lines=36/46 percent=78.26
M .codex/hooks/record-subagent-routing-attestation.ps1 lines=194/209 percent=92.82
M .codex/hooks/validate-codex-subagent-routing.ps1 lines=73/73 percent=100.00
A .codex/hooks/validate-discovery-agent-output.ps1 lines=48/57 percent=84.21
M .codex/scripts/Resolve-CodexTopology.ps1 lines=46/46 percent=100.00
A .github/hooks/discovery-agent-start.ps1 lines=28/35 percent=80.00
A .github/hooks/discovery-agent-stop.ps1 lines=33/40 percent=82.50
A .github/hooks/discovery-capability-probe.ps1 lines=23/31 percent=74.19
A .github/hooks/discovery-planning.ps1 lines=13/25 percent=52.00
A .github/hooks/discovery-pre-tool.ps1 lines=27/31 percent=87.10
A scripts/dev-tools/Test-DiscoveryHostCapability.ps1 lines=15/21 percent=71.43
CHANGED_PRODUCTION=35 ABSENT=0 BELOW_FLOOR=10 MEASURED_FILES=240
BELOW A .claude/hooks/record-discovery-agent-start.ps1 percent=82.05
BELOW A .codex/hooks/discovery-capability-probe.ps1 percent=71.43
BELOW A .codex/hooks/enforce-discovery-artifact-gate.ps1 percent=82.61
BELOW A .codex/hooks/enforce-discovery-planning-gate.ps1 percent=78.26
BELOW A .codex/hooks/validate-discovery-agent-output.ps1 percent=84.21
BELOW A .github/hooks/discovery-agent-start.ps1 percent=80.00
BELOW A .github/hooks/discovery-agent-stop.ps1 percent=82.50
BELOW A .github/hooks/discovery-capability-probe.ps1 percent=74.19
BELOW A .github/hooks/discovery-planning.ps1 percent=52.00
BELOW A scripts/dev-tools/Test-DiscoveryHostCapability.ps1 percent=71.43
```
