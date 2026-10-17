# Isolation Run — Seeded Shuffled Pester File Order (directive D1)

Timestamp: 2026-10-17T01-20
Task: [P6-T9]
Command: sh SCRATCH/issue-964-pester-shuffle.sh 964 20261016 31337 (one PowerShell 7 process; for each seed, a System.Random(seed) Fisher-Yates shuffle of the file list, then Invoke-Pester with Run.Path set to the shuffled order)
EXIT_CODE: 0
Output Summary:
- 15 files: every `tests/scripts/claude-hooks/validate-planner-output*.Tests.ps1`, `validate-task-researcher-output*.Tests.ps1`, `validate-executor-output*.Tests.ps1`, `premortem-section.Tests.ps1`, and the three `tests/scripts/claude-runtime` suites of [P5-T4].
- Seed 964: Passed=897 Failed=0. Seed 20261016: Passed=897 Failed=0. Seed 31337: Passed=897 Failed=0. FAILED_RUNS=0.
- The executed container order reported by Pester matched the shuffled order for every seed.
- Order dependence: none found. No repository-wide shuffle guard was added and no EpicStateIsolation suite was touched.

## File Order per Seed

Seed 964: validate-task-researcher-output.Tests.ps1, hook-dependency-guard-completeness.Tests.ps1, validate-planner-output.PreMortem.Tests.ps1, validate-planner-output.Tests.ps1, validate-executor-output.Preflight.Tests.ps1, validate-task-researcher-output.PreMortem.Tests.ps1, validate-executor-output.Envelope.Tests.ps1, premortem-section.Tests.ps1, claude-architecture-doc.Tests.ps1, enforcement-hooks-no-python-invocation.Tests.ps1, validate-executor-output.Tests.ps1, validate-executor-output.Reentry.Tests.ps1, validate-planner-output.Reentry.Tests.ps1, validate-task-researcher-output.Coverage.Tests.ps1, validate-planner-output.Coverage.Tests.ps1.

Seed 20261016: hook-dependency-guard-completeness.Tests.ps1, validate-task-researcher-output.Tests.ps1, validate-executor-output.Reentry.Tests.ps1, validate-executor-output.Tests.ps1, claude-architecture-doc.Tests.ps1, validate-planner-output.PreMortem.Tests.ps1, validate-task-researcher-output.Coverage.Tests.ps1, enforcement-hooks-no-python-invocation.Tests.ps1, validate-planner-output.Reentry.Tests.ps1, validate-task-researcher-output.PreMortem.Tests.ps1, premortem-section.Tests.ps1, validate-executor-output.Preflight.Tests.ps1, validate-planner-output.Tests.ps1, validate-executor-output.Envelope.Tests.ps1, validate-planner-output.Coverage.Tests.ps1.

Seed 31337: validate-executor-output.Reentry.Tests.ps1, validate-planner-output.Reentry.Tests.ps1, premortem-section.Tests.ps1, validate-task-researcher-output.Tests.ps1, validate-executor-output.Envelope.Tests.ps1, validate-task-researcher-output.PreMortem.Tests.ps1, validate-planner-output.PreMortem.Tests.ps1, enforcement-hooks-no-python-invocation.Tests.ps1, validate-planner-output.Coverage.Tests.ps1, validate-planner-output.Tests.ps1, validate-executor-output.Tests.ps1, validate-executor-output.Preflight.Tests.ps1, claude-architecture-doc.Tests.ps1, validate-task-researcher-output.Coverage.Tests.ps1, hook-dependency-guard-completeness.Tests.ps1.

All directory prefixes are `tests/scripts/claude-hooks/` except the three `tests/scripts/claude-runtime/` suites.
