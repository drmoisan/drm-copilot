# BF-1 Analysis: enforce-feature-folder-order.ps1 ([P1-T2])

Timestamp: 2026-10-09T22-29
Command: sh <SCRATCHPAD>/r.sh bf1-analysis (<SCRATCHPAD>/bf1-analysis.ps1 parses .claude/hooks/feature-folder-resolution.ps1 and .claude/hooks/enforce-feature-folder-order.ps1 with [System.Management.Automation.Language.Parser]::ParseFile)
EXIT_CODE: 0
Output Summary: the two resolver calls (Resolve-FeatureFolderWorkMode line 217, Get-FeatureFolderPlanPrerequisite line 218) are in Invoke-FeatureFolderOrderDecision after the plan-path gate (line 205, returns allow) and after the failure check (line 210); Test-IsFeaturePlanPath and FeaturePlanLeafPattern are defined in the hook and not in the resolver; BF1-DECISION: EXEMPT.

F18 citation: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1:325-340

Reasoning: the operator's BF-1 rule asks whether the resolver failure causes the hook to skip a check that it performs for a write when the resolver loads. The printed values show that every resolver call sits in Invoke-FeatureFolderOrderDecision at lines 217 and 218, both after the plan-path gate at line 205 and after the failure check at line 210. The plan-path gate returns allow for every path that is not a feature-folder plan path, and the gate depends only on Test-IsFeaturePlanPath and FeaturePlanLeafPattern, which the hook defines itself and the resolver does not define. A non-plan write therefore returns allow at line 206 whether or not the resolver loads, and it is never subject to a resolver-dependent check; every plan write reaches the failure check at line 210 and denies when the resolver failed to load. The allow of a non-plan write while the resolver cannot load is therefore not an allow on import failure, and the stated rule yields EXEMPT, which agrees with the printed BF1-DECISION line.

Output:

```text
RESOLVER-FUNCTION: Find-FeatureFolderCandidate | line=29
RESOLVER-FUNCTION: ConvertTo-FeatureFolderBasename | line=72
RESOLVER-FUNCTION: Find-FeatureFolderRecord | line=105
RESOLVER-FUNCTION: Select-FeatureFolderTarget | line=162
RESOLVER-FUNCTION: Resolve-FeatureFolderWorkMode | line=307
RESOLVER-FUNCTION: Get-FeatureFolderPlanPrerequisite | line=348
RESOLVER-CALL: Resolve-FeatureFolderWorkMode | line=217 | function=Invoke-FeatureFolderOrderDecision
RESOLVER-CALL: Get-FeatureFolderPlanPrerequisite | line=218 | function=Invoke-FeatureFolderOrderDecision
PLAN-PATH-GATE: line=205
PLAN-PATH-GATE-RETURNS-ALLOW: yes
FAILURE-CHECK: line=210
LOCAL-DEFINITION: Test-IsFeaturePlanPath | hook=yes | resolver=no
LOCAL-DEFINITION: FeaturePlanLeafPattern | hook=yes | resolver=no
BF1-DECISION: EXEMPT
```
