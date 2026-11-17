# Skill matrix upkeep — D-14 excluded skills set native ([P3-T2])

Timestamp: 2026-11-17T22-06
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-matrixnative.ps1 -IdList <the eleven ids> -Write (a text-level edit of `config/harness-parity-matrix.json` that keeps order and two-space indentation); sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-selcheck.ps1 (`Get-HarnessMatrixSelection` from `scripts/harness-generation/HarnessGeneration.psm1`); git diff -U0 -- config/harness-parity-matrix.json
EXIT_CODE: 0
Output Summary: Exactly eleven matrix entries changed, and their ids are `claude:skill:<name>` for the eleven `## Constraints` mirror-exclusion skills. The matrix change was made before any reconciliation edit and before the skill generator first ran. Each changed entry now has `disposition` `native`, has no `target_paths` and no `generated_from`, keeps `owner_child` 3, `decision_status` `provisional`, `parity_group` and `consumers`, and has `decision_ref` `#1028:spec.md#owner-decisions`. No other entry changed; for example `codex:skill:epic-orchestrate` stays `shared`. `Get-HarnessMatrixSelection` for `kind` `skill`, `ecosystem` `claude`, `disposition` `generated` and `owner_child` 3 returns 54 entries, none of the eleven, and still returns `evidence-and-timestamp-conventions`, `remediation-handoff-atomic-planner` and `execution-environment`. `HarnessParityMatrix.RepoGate.Tests.ps1` (`committed matrix has no violation against the live inventory`) passed in the task check.

Changed entries:
- `claude:skill:atomic-plan-contract`
- `claude:skill:csharp-qa-gate`
- `claude:skill:invoke-csharp-engineer`
- `claude:skill:invoke-powershell-engineer`
- `claude:skill:invoke-python-engineer`
- `claude:skill:powershell-qa-gate`
- `claude:skill:python-qa-gate`
- `claude:skill:feature-review-workflow`
- `claude:skill:orchestrate`
- `claude:skill:epic-orchestrate`
- `claude:skill:epic-run`
