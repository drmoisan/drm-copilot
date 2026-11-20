# Task Check — [P1-T5] (Issue 1025, remediation cycle 2)

Timestamp: 2026-11-17T05-29
Plan: remediation-plan.2026-11-16T06-14.md

## Changed Files

- `.agents/skills/powershell-qa-gate/references/standard.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/references/standard.md`

## Selection and Rule

Rule: plan `## Task Check` for a changed contract file under `.agents/skills/**` or its bundle copy: Text Checks (a) and (b) over the changed contracts and (c) over both trees; format, lint and type check N/A (Markdown); the Pester selection `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`; the plan A Python contract set (five modules).

## Commands

Command: `sh SCRATCH/issue-1025-textcheck.sh powershell-qa-gate` (Text Checks (a), (b), (c))
EXIT_CODE: 1 (the script exits with the status of its final grep guard: 1 means the last grep matched nothing; the pass criteria are LINT_EXIT=0, DIFFERING=0 and each grep exit 1 with 0 lines)
Output Summary:

```text
CONTRACTS_CHECKED: 1 (x2 copies)
VIOLATIONS: 0
LINT_EXIT=0
PAIRS=1 DIFFERING=0
-- tree .agents/skills
g1 exit=1 lines=0
g1-inputs exit=1 lines=0
g2 exit=1 lines=0
g3 exit=1 lines=0
g4 exit=1 lines=0
g-r3r5 exit=1 lines=0
-- tree extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills
g1 exit=1 lines=0
g1-inputs exit=1 lines=0
g2 exit=1 lines=0
g3 exit=1 lines=0
g4 exit=1 lines=0
g-r3r5 exit=1 lines=0
```

Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` with the five plan A contract modules
EXIT_CODE: 0
Output Summary: pytest attempt 1 exit 0;  92 passed in 4.27s 

Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath` with the four selected test files
EXIT_CODE: 0
Output Summary: pester attempt 1 exit 0; Invoke-PoshQCParallelTest: workers=4; wall-clock=162.74s; exit code=0; per-shard: Tests Passed: 136, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 108, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 18, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 Tests Passed: 7, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0 

## Results and Decisions

- Decision D-C2-2 (applied here, autonomous mode): the inputs' non-remediation note leaves `powershell-qa-gate` unchanged, while the coordinator's cycle 2 delegation directs the CR-14 nit to be applied; it is applied because the owner's forethought rule fixes related findings in the item.
- Only the coverage-check clause of OB-2 changes: it now carries the neutral form of the source qualifier "(when enforced by task/repo flow)" from `## Toolchain Execution Sequence` step 4, as "when the task or repository flow enforces it". The rest of the item is byte-unchanged.
- Text Check (c): every grep exits 1 with empty output in both trees.

## Source-Check Table (1 rows)

| Contract | OB | Source heading | Members the section enumerates | Members the new text names | Prior text | New text | Class closed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| powershell-qa-gate | OB-2 | `## Toolchain Execution Sequence` | 4 steps in order (format, analyze, one parallel test run, coverage check) with the step 4 qualifier (when enforced by task/repo flow) and the restart rule | all named | The toolchain runs in a fixed order of PoshQC formatting, PoshQC analysis, one `Invoke-PoshQCParallelTest` run, and the coverage check read from that run; when any step fails or modifies files, the issue is fixed and the loop restarts from step 1 until all steps complete without errors in a single pass. | The toolchain runs in a fixed order of PoshQC formatting, PoshQC analysis, one `Invoke-PoshQCParallelTest` run, and, when the task or repository flow enforces it, the coverage check read from that run; when any step fails or modifies files, the issue is fixed and the loop restarts from step 1 until all steps complete without errors in a single pass. | none (CR-14 nit) |
