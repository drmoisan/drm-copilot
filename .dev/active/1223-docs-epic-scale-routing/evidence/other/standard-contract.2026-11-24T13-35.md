# Standard contract check

Timestamp: 2026-11-24T13-35
Command: sh SCRATCH/issue-1223-standard-contract.sh (imports scripts/harness/HarnessSkillContract.psm1 and runs Get-HarnessSkillContractViolation -Name documentation-workflow over .agents/skills/documentation-workflow/references/standard.md)
EXIT_CODE: 0
Output Summary: VIOLATION_COUNT=0 (including the uncited-behavior rule). The standard gains OB-6 (Epic-Scale Routing), AC-7 citing OB-6, and the AC-6 citation list extended to OB-6.
