# Agent matrix override — D-11 ([P5-T1])

Timestamp: 2026-11-18T00-00
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-matrixnative.ps1 -IdList <the 33 ids below> -Write (an in-place text edit); sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-matrixdiff.ps1 -OldFile SCRATCH/issue-1028-matrix-head.json (the `HEAD` copy from `git show HEAD:config/harness-parity-matrix.json`); sh SCRATCH/issue-1028-retry.sh pester -TestPath tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1 tests/scripts/harness/HarnessParityMatrix.Tests.ps1
EXIT_CODE: 0
Output Summary: 33 of the 655 entries changed, and the entry order is unchanged. The changed names equal the list in gate check 2 of `evidence/baseline/phase0-gate.2026-11-17T17-17.md`:
- Claude-only: `commit-message`, `human-exception-runbook`, `parallel-orchestrator`, `parallel-planner`.
- Codex-only: `5.1-beast-adjusted`, `5.1-thinking-beast-mode-adjusted`, `api-architect`, `atomic-planning`, `commentary-remediation`, `commit-steward`, `csharp-atomic-executor`, `csharp-atomic-planning`, `csharp-orchestrator`, `expert-nextjs-developer`, `expert-react-frontend-engineer`, `feature-reviewer`, `gpt-5-beast-mode`, `hlbpa`, `mentor`, `powershell-atomic-executor`, `powershell-atomic-planning`, `powershell-di-unit-test-engineer`, `powershell-orchestrator`, `prd`, `pytest-unit-test-coding`, `python-atomic-executor`, `python-atomic-planning`, `python-execution-only-typed`, `python-orchestrator`, `tdd-green`, `tdd-red`, `tdd-refactor`, `voidbeast-gpt41enhanced`.

Each changed entry now has `disposition` `native`, has no `target_paths` or `generated_from`, keeps `owner_child` 3 and `decision_status` `provisional`, and has `decision_ref` `#1028:spec.md#owner-decisions`. `Get-HarnessMatrixSelection` for `kind` `agent`, `disposition` `generated` and `owner_child` 3 returns 50 entries: the claude and codex entries of the 25 agents present in both trees. None of them is a single-ecosystem agent. The edit keeps child 1's ordering and two-space indentation, and `git diff --stat` reports 66 insertions and 198 deletions in the one file.

Task check: `HarnessParityMatrix.RepoGate.Tests.ps1` and `HarnessParityMatrix.Tests.ps1`, 83 passed, 0 failed.
