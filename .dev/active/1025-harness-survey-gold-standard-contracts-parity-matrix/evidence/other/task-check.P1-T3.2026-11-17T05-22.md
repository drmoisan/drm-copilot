# Task Check — [P1-T3] (Issue 1025, remediation cycle 2)

Timestamp: 2026-11-17T05-22
Plan: remediation-plan.2026-11-16T06-14.md

## Changed Files

- `.agents/skills/execute-hard-lock/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execute-hard-lock/references/standard.md`
- `.agents/skills/invoke-csharp-engineer/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-csharp-engineer/references/standard.md`
- `.agents/skills/invoke-powershell-engineer/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-powershell-engineer/references/standard.md`
- `.agents/skills/invoke-python-engineer/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/invoke-python-engineer/references/standard.md`

## Selection and Rule

Rule: plan `## Task Check` for a changed contract file under `.agents/skills/**` or its bundle copy: Text Checks (a) and (b) over the changed contracts and (c) over both trees; format, lint and type check N/A (Markdown); the Pester selection `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`; the plan A Python contract set (five modules).

## Commands

Command: `sh SCRATCH/issue-1025-textcheck.sh execute-hard-lock,invoke-csharp-engineer,invoke-powershell-engineer,invoke-python-engineer` (Text Checks (a), (b), (c))
EXIT_CODE: 0
Output Summary:

```text
CONTRACTS_CHECKED: 4 (x2 copies)
VIOLATIONS: 0
LINT_EXIT=0
PAIRS=4 DIFFERING=0
-- tree .agents/skills
g1 exit=1 lines=0
g1-inputs exit=1 lines=0
g2 exit=1 lines=0
g3 exit=1 lines=0
g4 exit=1 lines=0
g-r3r5 exit=0 lines=4
-- tree extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills
g1 exit=1 lines=0
g1-inputs exit=1 lines=0
g2 exit=1 lines=0
g3 exit=1 lines=0
g4 exit=1 lines=0
g-r3r5 exit=0 lines=4
```

Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` with the five plan A contract modules
EXIT_CODE: 0
Output Summary: pytest attempt 1 exit 75;pytest attempt 2 exit 0;  92 passed in 5.93s 

Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath` with the four selected test files
EXIT_CODE: 0
Output Summary: pester attempt 1 exit 0; Invoke-PoshQCParallelTest: workers=4; wall-clock=159.82s; exit code=0; per-shard: Tests Passed: 136, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 108, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 18, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 7, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 

## Results and Decisions

- Text Check (c): greps 1 to 4 and the inputs' R1 form exit 1 with empty output in both trees; the R3–R5 grep still returns only the 4 R5 lines per tree that [P1-T4] fixes.
- Each source-check row names every member the section enumerates (named-member count equals the source member count, as the Members column states).
- `invoke-*-engineer` OB-5: the source lists the shared skills, the language rule and three entries that a path substitution renders as the standing-instruction file name; the companion runtime copy names them as the cross-language code-change, unit-test and tonality policies, so the item names them tool-neutrally.
- `execute-hard-lock` OB-2 names the two resolver inputs as the plan-of-record path and the absolute root of the calling checkout or worktree, with no MCP tool name and no agent-spawn tool name; OB-5 names the plan executor and all four preloaded shared skills.
- Pytest attempt 1 exited 75 (queue timeout: the machine test-suite lock was busy); it was re-run and recorded as a queue timeout, not a failure. Attempt 2 exited 0.

## Source-Check Table (8 rows)

| Contract | OB | Source heading | Members the section enumerates | Members the new text names | Prior text | New text | Class closed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| invoke-csharp-engineer | OB-3 | `## Required Reporting Block` | 5 entries in order: Scope, Baseline, Plan, Diffs, QA Gate Results | all named | Baseline (CSharpier, .NET Analyzers, Nullable Analysis, MSTest, coverage status). | The worker returns a reporting block of five entries in order: Scope (the exact file list), Baseline (CSharpier, .NET Analyzers, Nullable Analysis, MSTest and coverage status), Plan (the design and test strategy), Diffs (patch-style or full-file replacements), and QA Gate Results (CSharpier, .NET Analyzers, Nullable Analysis, MSTest and coverage deltas against the baseline, with failures and per-file coverage read from the single gate run, or clearly marked **unverified**). | R4 |
| invoke-csharp-engineer | OB-5 | `## Preloaded Contracts` | 8 shared skills, the C# rule, 3 cross-language policies (code change, unit test, tonality) | all named | `policy-compliance-order`. | The worker operates under eight preloaded shared skills, `policy-compliance-order`, `csharp-change-budget-router`, `atomic-plan-contract`, `csharp-qa-gate`, `acceptance-criteria-tracking`, `feature-promotion-lifecycle`, `remediation-handoff-atomic-planner` and `evidence-and-timestamp-conventions`, together with the C# coding rule scoped to `**/*.cs` and `**/*.csproj` files and the cross-language code-change, unit-test and tonality policies. | R4 |
| invoke-powershell-engineer | OB-3 | `## Required Reporting Block` | 5 entries in order: Scope, Baseline, Plan, Diffs, QA Gate Results | all named | Baseline (PSScriptAnalyzer, Pester, coverage status). | The worker returns the `powershell-qa-gate` reporting block of five entries in order: Scope (the exact file list), Baseline (PSScriptAnalyzer, Pester and coverage status), Plan (the design and test strategy, including minimal DI seams and the external executable wrapper mock strategy), Diffs (patch-style or full-file replacements), and QA Gate Results (PSScriptAnalyzer, Pester and coverage deltas against the baseline, with failures and per-file coverage read from the single gate run, or clearly marked **unverified**). | R4 |
| invoke-powershell-engineer | OB-5 | `## Preloaded Contracts` | 9 shared skills, the PowerShell rule, 3 cross-language policies (code change, unit test, tonality) | all named | `policy-compliance-order`. | The worker operates under nine preloaded shared skills, `policy-compliance-order`, `powershell-change-budget-router`, `powershell-orchestration-state-machine`, `atomic-plan-contract`, `powershell-qa-gate`, `acceptance-criteria-tracking`, `feature-promotion-lifecycle`, `remediation-handoff-atomic-planner` and `evidence-and-timestamp-conventions`, together with the PowerShell coding rule scoped to `**/*.ps1`, `**/*.psm1` and `**/*.psd1` files and the cross-language code-change, unit-test and tonality policies. | R4 |
| invoke-python-engineer | OB-3 | `## Required Reporting Block` | 5 entries in order: Scope, Baseline, Plan, Diffs, QA Gate Results | all named | Baseline (Ruff, Pyright, Pytest, coverage status). | The worker returns the `python-qa-gate` reporting block of five entries in order: Scope (the exact file list), Baseline (Ruff, Pyright, Pytest and coverage status), Plan (the design and test strategy), Diffs (patch-style or full-file replacements), and QA Gate Results (Ruff, Pyright, Pytest and coverage deltas against the baseline, with failures and per-file coverage read from the single gate run, or clearly marked **unverified**). | R4 |
| invoke-python-engineer | OB-5 | `## Preloaded Contracts` | 8 shared skills, the Python rule, 3 cross-language policies (code change, unit test, tonality) | all named | `policy-compliance-order`. | The worker operates under eight preloaded shared skills, `policy-compliance-order`, `python-change-budget-router`, `atomic-plan-contract`, `python-qa-gate`, `acceptance-criteria-tracking`, `feature-promotion-lifecycle`, `remediation-handoff-atomic-planner` and `evidence-and-timestamp-conventions`, together with the Python coding rule scoped to `**/*.py` files and the cross-language code-change, unit-test and tonality policies. | R4 |
| execute-hard-lock | OB-2 | `## Invocation Flow` | 2 resolver inputs (plan path, calling checkout root) and 3 steps in order: resolve, read the prompt, delegate | all named | `target` (required): the plan-of-record path (`${plan-path}`). | As its first action the skill resolves the hard-lock prompt from two required inputs, the plan-of-record path and the absolute root of the calling checkout or worktree, then reads the resolved prompt file that the resolver returns and treats its contents as the authoritative hard-lock instruction set, and then delegates to the plan executor with the resolved prompt as its kickoff directive followed by the plan path and the work mode, stopping with a `BLOCKED: execute-hard-lock` report when the plan executor is unavailable. | R4 |
| execute-hard-lock | OB-5 | `## Delegation Contract` | the delegation to the plan executor, its 4 behaviors and 4 preloaded shared skills | all named | `policy-compliance-order` — mandatory policy reading order. | Execution is delegated to the plan executor, which enforces anti-replanning, preflight-only blocking, persistence across turns and resume, and preloads four shared skills: `policy-compliance-order` for the mandatory policy reading order, `atomic-plan-contract` for plan format, Phase 0 requirements, preflight signals, the validator gate and mode-specific plan gates, `acceptance-criteria-tracking` for the check-off protocol and status summary format, and `evidence-and-timestamp-conventions` for baseline and final-QC artifact paths and required fields. | R4 |
