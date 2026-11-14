# Commenting Sweep, Fail-Before (remediation P0-T2)

Timestamp: 2026-11-10T02-35
Command: python SCRATCH/issue-1164-comment-scan.py <worktree root>; sh SCRATCH/issue-1164-run-psscan.sh (pwsh -NoProfile -File SCRATCH/issue-1164-comment-scan.ps1 -Root <worktree root>)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Population: functions whose definition line is an added line in the merge-base diff (merge base of origin/main and HEAD, ff9d8afc0a61ac723cd449b0c0658ea42680cd2e) in production .py under scripts/dev_tools/, .ps1/.psm1 under .claude/lib/, .sh under .claude/lib/bash/, and .ts under extensions/drm-copilot/src/, plus _read_int_map and _path_pair_weight; and every DEC-1164-8 loop or pipeline on an added line inside them.
- Python/bash/TypeScript helper: 64 findings, VERDICT: FAIL, exit 1. PowerShell helper: 26 findings, VERDICT: FAIL, exit 1. Total 90 findings.
- The findings include all 13 Python functions named in P1-T1 to P1-T3; every finding lies in a file named in P1-T1 to P1-T7 (no other file reported). Expected fail-before outcome: the self-review gaps are present.

## Python, bash, TypeScript helper output

```
.claude/lib/bash/parallel-manifest-pairs.sh | pm_pair_endpoints | Returns: line missing
.claude/lib/bash/parallel-manifest-pairs.sh | pm_pair_endpoints | intent comment missing above 'for field in a b; do'
.claude/lib/bash/parallel-manifest-pairs.sh | pm_pair_reasons_valid | Returns: line missing
.claude/lib/bash/parallel-manifest-pairs.sh | pm_pair_reasons_valid | intent comment missing above 'for ((index = 0; index < count; index++)); do'
.claude/lib/bash/parallel-manifest-pairs.sh | pm_pair_fields | Returns: line missing
.claude/lib/bash/parallel-manifest-pairs.sh | pm_pair_fields | intent comment missing above 'for field in cost benefit; do'
.claude/lib/bash/parallel-manifest-pairs.sh | pm_validate_pair_decisions | Args: line missing
.claude/lib/bash/parallel-manifest-pairs.sh | pm_validate_pair_decisions | Returns: line missing
.claude/lib/bash/parallel-manifest-pairs.sh | pm_validate_pair_decisions | intent comment missing above 'for ((index = 0; index < total; index++)); do'
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | pairKey | @param missing for first
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | pairKey | @param missing for second
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | pairKey | @returns missing
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | estimateErrors | intent comment missing above 'return ["cost", "benefit"]' (loop at .filter((field) => field in entry && !is)
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | estimateErrors | intent comment missing above 'return ["cost", "benefit"]' (loop at .map()
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | overlapPair | intent comment missing above 'for (const field of ["a", "b"]) {' (loop at for (const field of ["a", "b"]) {)
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | reasonErrors | intent comment missing above 'if (' (loop at entries.some((entry) => !isEnumMember(VA)
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | reasonErrors | intent comment missing above '} else if (entries.some((entry) => isEnumMember(HARD_EDGE_RE' (loop at } else if (entries.some((entry) => isEnu)
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | accessListErrors | intent comment missing above 'entries.forEach((entry: unknown, index: number) => {' (loop at entries.forEach((entry: unknown, index: )
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | accessListErrors | intent comment missing above 'for (const field of ACCESS_LIST_FIELDS.filter((name) => name' (loop at for (const field of ACCESS_LIST_FIELDS.f)
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | precedenceErrors | intent comment missing above 'entries.forEach((entry: unknown, position: number) => {' (loop at entries.forEach((entry: unknown, positio)
extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | validateSchedulingDecisions | intent comment missing above 'for (const [first, second] of shared) {' (loop at for (const [first, second] of shared) {)
scripts/dev_tools/_blast_radius_scheduling.py | _path_pair_weight | Args: section missing
scripts/dev_tools/_blast_radius_scheduling.py | _read_int_map | Args: section missing
scripts/dev_tools/_blast_radius_scheduling.py | _read_int_map | Returns: section missing
scripts/dev_tools/_blast_radius_scheduling.py | _read_int_map | intent comment missing above comprehension at statement 'present = names + tuple(name for name in optional if name in'
scripts/dev_tools/_parallel_drift_scheduling.py | _access_list | Args: section missing
scripts/dev_tools/_parallel_drift_scheduling.py | _access_list | Returns: section missing
scripts/dev_tools/_parallel_drift_scheduling.py | _access_list | intent comment missing above all at statement 'if not all(isinstance(entry, str) and entry for entry in ent'
scripts/dev_tools/_parallel_drift_scheduling.py | _access_list | intent comment missing above comprehension at statement 'if not all(isinstance(entry, str) and entry for entry in ent'
scripts/dev_tools/_parallel_drift_scheduling.py | item_access | intent comment missing above comprehension at statement 'read_paths, separable_paths = ('
scripts/dev_tools/_parallel_state_records.py | _estimate_errors | Args: section missing
scripts/dev_tools/_parallel_state_records.py | _estimate_errors | Returns: section missing
scripts/dev_tools/_parallel_state_records.py | _estimate_errors | intent comment missing above comprehension at statement 'return ['
scripts/dev_tools/_parallel_state_records.py | _overlap_pair | Args: section missing
scripts/dev_tools/_parallel_state_records.py | _overlap_pair | Returns: section missing
scripts/dev_tools/_parallel_state_records.py | _overlap_pair | intent comment missing above loop at statement 'for field in ("a", "b"):'
scripts/dev_tools/_parallel_state_records.py | _reason_errors | Args: section missing
scripts/dev_tools/_parallel_state_records.py | _reason_errors | Returns: section missing
scripts/dev_tools/_parallel_state_records.py | _reason_errors | intent comment missing above any at statement 'if not entries or any(entry not in VALID_EDGE_REASONS for en'
scripts/dev_tools/_parallel_state_records.py | _reason_errors | intent comment missing above any at statement 'elif any(entry in HARD_EDGE_REASONS for entry in entries):'
scripts/dev_tools/_parallel_state_records.py | _reason_errors | intent comment missing above comprehension at statement 'if not entries or any(entry not in VALID_EDGE_REASONS for en'
scripts/dev_tools/_parallel_state_records.py | _reason_errors | intent comment missing above comprehension at statement 'elif any(entry in HARD_EDGE_REASONS for entry in entries):'
scripts/dev_tools/_parallel_state_records.py | _validate_tolerated_overlaps | Args: section missing
scripts/dev_tools/_parallel_state_records.py | _validate_tolerated_overlaps | Returns: section missing
scripts/dev_tools/_parallel_state_records.py | _edge_errors | Args: section missing
scripts/dev_tools/_parallel_state_records.py | _edge_errors | Returns: section missing
scripts/dev_tools/_parallel_state_records.py | _access_list_errors | Args: section missing
scripts/dev_tools/_parallel_state_records.py | _access_list_errors | Returns: section missing
scripts/dev_tools/_parallel_state_records.py | _access_list_errors | intent comment missing above loop at statement 'for index, entry in enumerate(entries):'
scripts/dev_tools/_parallel_state_records.py | _access_list_errors | intent comment missing above loop at statement 'for field in (name for name in ACCESS_LIST_FIELDS if name in'
scripts/dev_tools/_parallel_state_records.py | _access_list_errors | intent comment missing above comprehension at statement 'for field in (name for name in ACCESS_LIST_FIELDS if name in'
scripts/dev_tools/_parallel_state_records.py | _precedence_errors | Args: section missing
scripts/dev_tools/_parallel_state_records.py | _precedence_errors | Returns: section missing
scripts/dev_tools/_parallel_state_records.py | _precedence_errors | intent comment missing above loop at statement 'for position, entry in enumerate(entries):'
scripts/dev_tools/_parallel_state_records.py | validate_scheduling_decisions | Args: section missing
scripts/dev_tools/_parallel_state_records.py | validate_scheduling_decisions | Returns: section missing
scripts/dev_tools/parallel_manifest_contract.py | _pair_endpoint_errors | Args: section missing
scripts/dev_tools/parallel_manifest_contract.py | _pair_endpoint_errors | Returns: section missing
scripts/dev_tools/parallel_manifest_contract.py | _pair_endpoint_errors | intent comment missing above loop at statement 'for field in ("a", "b"):'
scripts/dev_tools/parallel_manifest_contract.py | _pair_field_errors | Args: section missing
scripts/dev_tools/parallel_manifest_contract.py | _pair_field_errors | Returns: section missing
scripts/dev_tools/parallel_manifest_contract.py | _pair_field_errors | intent comment missing above loop at statement 'for field in ("cost", "benefit"):'
scripts/dev_tools/parallel_manifest_contract.py | _pair_field_errors | intent comment missing above any at statement 'if not entries or any(reason not in VALID_EDGE_REASONS for r'
scripts/dev_tools/parallel_manifest_contract.py | _pair_field_errors | intent comment missing above comprehension at statement 'if not entries or any(reason not in VALID_EDGE_REASONS for r'
FINDINGS: 64
VERDICT: FAIL
```

## PowerShell helper output

```
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-AccessListEntry | comment-based help missing
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-AccessListEntry | intent comment missing above 'return [string[]]@($Access[$Name] | ForEach-Object { [string'
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-BlastRadiusAccessPathPairWeight | intent comment missing above 'foreach ($entry in $concrete) {'
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-PlanTaskWindow | comment-based help missing
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-PlanTaskWindow | intent comment missing above 'foreach ($line in ($PlanText -split "\r?\n")) {'
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-PlanTaskWindow | intent comment missing above 'return @($window | ForEach-Object { @{ title = $_['title']; '
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-TitleWord | comment-based help missing
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-TitleWord | intent comment missing above 'return [string[]]@($Title -split '[^A-Za-z]+' | Where-Object'
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Test-ReadOnlyWindowSet | comment-based help missing
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Test-ReadOnlyWindowSet | intent comment missing above 'foreach ($entry in $Window) {'
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Test-ReadOnlyWindowSet | intent comment missing above '$hasWriteVerb = @($words | Where-Object { $script:WriteTitle'
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-BlastRadiusReadOnlyPath | intent comment missing above 'foreach ($path in @($RadiusPath)) {'
.claude/lib/blast-radius/BlastRadiusAccess.psm1 | Get-BlastRadiusReadOnlyPath | intent comment missing above '$naming = @($windows | Where-Object { $_['text'].Contains($p'
.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | Invoke-ParallelAdmissionPrecedenceTest | .PARAMETER Option missing
.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | Invoke-ParallelAdmissionPrecedenceTest | .OUTPUTS missing
.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | Invoke-ParallelAdmissionAccessPath | .PARAMETER Option missing
.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | Invoke-ParallelAdmissionAccessPath | .OUTPUTS missing
.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | Invoke-ParallelAdmissionAccessPath | intent comment missing above 'foreach ($item in @(Get-ParallelAdmissionMapValue -Map $entr'
.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 | Get-PrecedenceGateValue | comment-based help missing
.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 | Find-PrecedenceGatePairRecord | comment-based help missing
.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 | Find-PrecedenceGatePairRecord | intent comment missing above 'foreach ($entry in @($Record)) {'
.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 | Get-PrecedenceGateItemBand | comment-based help missing
.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 | Get-PrecedenceGateItemBand | intent comment missing above 'foreach ($entry in @($Item)) {'
.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 | Test-ParallelPrecedenceJustified | intent comment missing above 'foreach ($precedence in @(Get-PrecedenceGateValue -Map $Entr'
.claude/lib/parallel-drift/ParallelDriftAccess.psm1 | Get-ParallelDriftAccessList | intent comment missing above 'foreach ($name in $script:AccessListName) {'
.claude/lib/parallel-drift/ParallelDriftAccess.psm1 | Get-ParallelDriftAccessList | intent comment missing above '$valid = @($entries | Where-Object { $_ -is [string] -and $_'
FINDINGS: 26
VERDICT: FAIL
```
