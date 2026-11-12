# 0011: Task-check cadence

## Summary

reduction: 0011
Date: 2026-11-12
Issue: #1167
Merge commit: pending (PR #1167)

Replaces the per-task full toolchain run with a task check during atomic plan execution. A new section `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill defines the cadence once: after each task, a task check runs format, lint, and type check scoped to the changed files and then the task's test selection (mirrored and importing tests, and the contract tests that read a changed Markdown or configuration path), with no coverage and no gate status; the last task of every phase between Phase 0 and the final QA phase is a `[phase-gate]` task that runs stages 1 to 6 of the toolchain loop with one run of each parallel gate; the final QA loop, the `Phase 0 baseline` comparison, and the no-SKIPPED rule are unchanged. Stage 7 (integration tests) of the general code-change loop, and golden suites, run in CI for phase gates and the final QA loop. The policy texts, the orchestrate skill, the executor and planner surfaces, the hard-lock prompts, the language rules and skills, the QA-gate skills, the plan templates, and the execution-environment brief reference the section instead of restating a per-task full run. Until the pull request exists, the `Merge commit:` line carries the canonical issue number as a stand-in, as entry `0005` did.

## Reason and Evidence

The owner rule, verbatim: "The rule for an orchestration is a full test after every phase and only targeted tests after every task". The harness text did not distinguish a per-task check from a phase-level gate, so executors ran the full unit suite after every task. In the downstream repository iar-migration, issue #145, the executor ran about 10,400 unit tests after every task of a 68-task plan, at about 10 tasks per hour. The design basis is `docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/research/research.2026-11-12T00-42.md`; the Python atomic executor CLI already runs a scoped check per task and a full run per phase (`QCRunner.run_scoped` and `run_full` in `scripts/dev_tools/atomic_executor/qc_runner.py`), which this change leaves untouched.

The reduction narrows the policy rule `## Mandatory Toolchain Loop`: stage 7 integration tests move to CI for phase gates and the final QA loop, by the owner's instruction that integration and golden suites stay CI-only. The owner's request for issue #1167 authorizes the edits to `.claude/rules/` and `.github/instructions/` named below, for this issue only (spec decision D13). The time saved per task is unknown until stage timing records an orchestration under the new cadence.

## Files Changed

- `.agents/skills/atomic-executor/SKILL.md`
- `.agents/skills/atomic-plan-contract/SKILL.md`
- `.agents/skills/atomic-planner/SKILL.md`
- `.agents/skills/csharp-qa-gate/SKILL.md`
- `.agents/skills/csharp/SKILL.md`
- `.agents/skills/general-code-change/SKILL.md`
- `.agents/skills/orchestrate/SKILL.md`
- `.agents/skills/powershell-qa-gate/SKILL.md`
- `.agents/skills/powershell/SKILL.md`
- `.agents/skills/python-qa-gate/SKILL.md`
- `.agents/skills/python/SKILL.md`
- `.agents/skills/typescript/SKILL.md`
- `.claude/agents/atomic-executor.md`
- `.claude/agents/atomic-planner.md`
- `.claude/rules/csharp.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/powershell.md`
- `.claude/rules/python.md`
- `.claude/rules/shell.md`
- `.claude/rules/typescript.md`
- `.claude/skills/atomic-plan-contract/SKILL.md`
- `.claude/skills/csharp-qa-gate/SKILL.md`
- `.claude/skills/execution-environment/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/powershell-qa-gate/SKILL.md`
- `.claude/skills/python-qa-gate/SKILL.md`
- `.codex/agents/atomic-executor.toml`
- `.codex/agents/atomic-planner.toml`
- `.github/agents/atomic_executor.agent.md`
- `.github/agents/atomic_planning.agent.md`
- `.github/agents/csharp-atomic-executor.agent.md`
- `.github/agents/csharp-atomic-planning.agent.md`
- `.github/agents/powershell-atomic-executor.agent.md`
- `.github/agents/powershell-atomic-planning.agent.md`
- `.github/agents/python-atomic-executor.agent.md`
- `.github/agents/python-atomic-planning.agent.md`
- `.github/codex/execute-hard-lock.prompt.md`
- `.github/codex/resume-hard-lock.prompt.md`
- `.github/instructions/general-code-change.instructions.md`
- `.github/prompts/execute-hard-lock.prompt.md`
- `.github/skills/atomic-plan-contract/SKILL.md`
- `AGENTS.md`
- `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`
- `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`
- `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`, a byte-identical copy of `.claude/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`, a byte-identical copy of `.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`, a byte-identical copy of `.claude/agents/atomic-executor.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`, a byte-identical copy of `.claude/agents/atomic-planner.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`, a byte-identical copy of `.claude/rules/csharp.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md`, a byte-identical copy of `.claude/rules/general-code-change.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/powershell.md`, a byte-identical copy of `.claude/rules/powershell.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/python.md`, a byte-identical copy of `.claude/rules/python.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`, a byte-identical copy of `.claude/rules/shell.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`, a byte-identical copy of `.claude/rules/typescript.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, a byte-identical copy of `.claude/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/csharp-qa-gate/SKILL.md`, a byte-identical copy of `.claude/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, a byte-identical copy of `.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`, a byte-identical copy of `.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/powershell-qa-gate/SKILL.md`, a byte-identical copy of `.claude/skills/powershell-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md`, a byte-identical copy of `.claude/skills/python-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`, a byte-identical copy of `.agents/skills/atomic-executor/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`, a byte-identical copy of `.agents/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md`, a byte-identical copy of `.agents/skills/atomic-planner/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md`, a byte-identical copy of `.agents/skills/csharp-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md`, a byte-identical copy of `.agents/skills/csharp/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, a byte-identical copy of `.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md`, a byte-identical copy of `.agents/skills/general-code-change/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`, a byte-identical copy of `.agents/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell-qa-gate/SKILL.md`, a byte-identical copy of `.agents/skills/powershell-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell/SKILL.md`, a byte-identical copy of `.agents/skills/powershell/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md`, a byte-identical copy of `.agents/skills/python-qa-gate/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python/SKILL.md`, a byte-identical copy of `.agents/skills/python/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/typescript/SKILL.md`, a byte-identical copy of `.agents/skills/typescript/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml`, a byte-identical copy of `.codex/agents/atomic-executor.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml`, a byte-identical copy of `.codex/agents/atomic-planner.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md`, a byte-identical copy of `AGENTS.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_executor.agent.md`, a byte-identical copy of `.github/agents/atomic_executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/atomic_planning.agent.md`, a byte-identical copy of `.github/agents/atomic_planning.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-executor.agent.md`, a byte-identical copy of `.github/agents/csharp-atomic-executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-atomic-planning.agent.md`, a byte-identical copy of `.github/agents/csharp-atomic-planning.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-executor.agent.md`, a byte-identical copy of `.github/agents/powershell-atomic-executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/powershell-atomic-planning.agent.md`, a byte-identical copy of `.github/agents/powershell-atomic-planning.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md`, a byte-identical copy of `.github/agents/python-atomic-executor.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-planning.agent.md`, a byte-identical copy of `.github/agents/python-atomic-planning.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md`, a byte-identical copy of `.github/codex/execute-hard-lock.prompt.md`
- `extensions/drm-copilot/resources/customizations/.github/codex/resume-hard-lock.prompt.md`, a byte-identical copy of `.github/codex/resume-hard-lock.prompt.md`
- `extensions/drm-copilot/resources/customizations/.github/instructions/general-code-change.instructions.md`, a byte-identical copy of `.github/instructions/general-code-change.instructions.md`
- `extensions/drm-copilot/resources/customizations/.github/prompts/execute-hard-lock.prompt.md`, a byte-identical copy of `.github/prompts/execute-hard-lock.prompt.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`, a byte-identical copy of `.github/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`, a byte-identical copy of `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/feature-templates/bug/plan.yyyy-MM-ddTHH-mm.md`, a byte-identical copy of `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md`
- `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`, a byte-identical copy of `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`
- `extensions/drm-copilot/resources/feature-templates/refactor/plan.yyyy-MM-ddTHH-mm.md`, a byte-identical copy of `docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md`
- `.codex/agents/atomic-executor-c1.toml`, a generated Codex variant
- `.codex/agents/atomic-executor-c2.toml`, a generated Codex variant
- `.codex/agents/atomic-executor-c3-elevated.toml`, a generated Codex variant
- `.codex/agents/atomic-executor-c3.toml`, a generated Codex variant
- `.codex/agents/atomic-executor-c4.toml`, a generated Codex variant
- `.codex/agents/atomic-planner-c1.toml`, a generated Codex variant
- `.codex/agents/atomic-planner-c2.toml`, a generated Codex variant
- `.codex/agents/atomic-planner-c3-elevated.toml`, a generated Codex variant
- `.codex/agents/atomic-planner-c3.toml`, a generated Codex variant
- `.codex/agents/atomic-planner-c4.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml`, a generated Codex variant
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml`, a generated Codex variant
- `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, a new contract test

## Prior Text

### Revert Block: .agents/skills/atomic-executor/SKILL.md

````Current
2. Perform only the micro-actions needed for that task.
3. Verify the task acceptance criteria and run the task check before marking it complete; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
4. Check off the plan file on disk immediately after verification passes.
````

````Prior
2. Perform only the micro-actions needed for that task.
3. Verify the task acceptance criteria before marking it complete.
4. Check off the plan file on disk immediately after verification passes.
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current

Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

## Minimal-Audit Directive Contract (Small Path)
````

````Prior

## Minimal-Audit Directive Contract (Small Path)
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current

## Test Cadence (Mandatory)

This section defines when the toolchain runs during plan execution. Other plan-execution surfaces reference this section instead of restating it.

- **Task check (after each task).** After each task, the executor runs a task check: format, lint, and type check scoped to the files the task changed, then the task's test selection. The task's test selection is the mirrored test files under `tests/` of each changed production file, plus every test file that imports, dot-sources, or names a changed module or file; for a changed Markdown or configuration path, it is the contract tests that read that path. Integration and golden suites are never part of the task's test selection. A task check is not a gate: it measures no coverage and does not replace the phase gate. Its evidence is a new append-only file per task, `<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`, which records the changed files, the selection and the rule that produced it, and each command with its exit code.
- **Phase gate (after each phase).** The last task of every phase between Phase 0 and the final QA phase carries the `[phase-gate]` tag, placed after the task ID as `[expect-fail]` is. That task runs stages 1 to 6 of the toolchain loop across the repository: format, lint, type check, architecture-boundary tests, the full unit suite, and contract checks. The unit stage is one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers. On a failure or an auto-fix, fix the cause and restart from step 1; the phase closes only after one clean pass. Its evidence is `<FEATURE>/evidence/qa-gates/phase-gate.P<N>.<timestamp>.md`. Phase 0 needs no gate task, and the loop of the final QA phase is its own gate.
- **Final QA loop (unchanged).** The final QA loop in the next section remains a full run with coverage compared with the `Phase 0 baseline`, and the no-SKIPPED rule is unchanged.
- **CI-only suites.** Integration and golden suites run in CI only.

## Final QA Loop (Required for Code/Test Changes)
````

````Prior

## Final QA Loop (Required for Code/Test Changes)
````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current

Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

## No-SKIPPED Rule for Planned Command Tasks
````

````Prior

## No-SKIPPED Rule for Planned Command Tasks
````

### Revert Block: .agents/skills/atomic-planner/SKILL.md

````Current

In every plan, every phase between Phase 0 and the final QA phase ends with a `[phase-gate]` task, placed after the task ID. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

In a workspace with an active discovery activation, the planner launch itself is admitted
````

````Prior

In a workspace with an active discovery activation, the planner launch itself is admitted
````

### Revert Block: .agents/skills/csharp-qa-gate/SKILL.md

````Current
- `csharp-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

````Prior
- `csharp-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`).
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

### Revert Block: .agents/skills/csharp/SKILL.md

````Current

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files.

````

### Revert Block: .agents/skills/general-code-change/SKILL.md

````Current

This loop is the phase-gate and final-QA requirement; integration tests (stage 7) run in CI for phase gates and the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

Mutation testing and golden tests run in pre-merge or nightly pipelines, not the per-commit loop.
````

````Prior

Mutation testing and golden tests run in pre-merge or nightly pipelines, not the per-commit loop.
````

### Revert Block: .agents/skills/orchestrate/SKILL.md

````Current
- `atomic-planner` — generates phased implementation plans
- `atomic-executor` — executes approved plans task-by-task. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- `feature-reviewer` — produces policy, code, and feature audit artifacts by
````

````Prior
- `atomic-planner` — generates phased implementation plans
- `atomic-executor` — executes approved plans task-by-task
- `feature-reviewer` — produces policy, code, and feature audit artifacts by
````

### Revert Block: .agents/skills/orchestrate/SKILL.md

````Current
- **R2 — Preflight clearance:** Delegate to `atomic-executor` for precondition validation only (no implementation), with the preflight directive in the delegation prompt. Trivial defects are fixed in place. If the executor returns `PREFLIGHT: REVISIONS REQUIRED`, return to R1 once by re-delegating to `atomic-planner` against the same remediation-plan path with the full `PREFLIGHT-DEFECT:` list; if the following preflight still reports a substantive defect, record `final_status: "blocked_preflight_iteration_limit"` on the cycle and halt. Only after `PREFLIGHT: ALL CLEAR` may the orchestrator advance to R3.
- **R3 — Remediation execution:** Delegate to `atomic-executor` with full execution authorization. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- **Pre-R4 commit:** Stage all changes (`git add -A`), run MCP tool `collect_commit_context`, delegate to `commit_steward` using the resulting artifact, and commit with the generated message. Advance to R4 only after a successful commit.
````

````Prior
- **R2 — Preflight clearance:** Delegate to `atomic-executor` for precondition validation only (no implementation), with the preflight directive in the delegation prompt. Trivial defects are fixed in place. If the executor returns `PREFLIGHT: REVISIONS REQUIRED`, return to R1 once by re-delegating to `atomic-planner` against the same remediation-plan path with the full `PREFLIGHT-DEFECT:` list; if the following preflight still reports a substantive defect, record `final_status: "blocked_preflight_iteration_limit"` on the cycle and halt. Only after `PREFLIGHT: ALL CLEAR` may the orchestrator advance to R3.
- **R3 — Remediation execution:** Delegate to `atomic-executor` with full execution authorization. Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping.
- **Pre-R4 commit:** Stage all changes (`git add -A`), run MCP tool `collect_commit_context`, delegate to `commit_steward` using the resulting artifact, and commit with the generated message. Advance to R4 only after a successful commit.
````

### Revert Block: .agents/skills/powershell-qa-gate/SKILL.md

````Current
- `powershell-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

````Prior
- `powershell-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`).
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

### Revert Block: .agents/skills/powershell/SKILL.md

````Current

Run the toolchain in order: format → analyze → test. Restart from step 1 if any step fails or changes files. Use the MCP server functions; do not substitute VS Code task wrappers. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → analyze → test. Restart from step 1 if any step fails or changes files. Use the MCP server functions; do not substitute VS Code task wrappers.

````

### Revert Block: .agents/skills/python-qa-gate/SKILL.md

````Current
- `python-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

````Prior
- `python-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`).
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

### Revert Block: .agents/skills/python/SKILL.md

````Current

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Do not stop the loop until all four steps complete without errors in a single pass. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Do not stop the loop until all four steps complete without errors in a single pass.

````

### Revert Block: .agents/skills/typescript/SKILL.md

````Current

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files.

````

### Revert Block: .claude/agents/atomic-executor.md

````Current
3. **Perform**: Make the minimum edits required to satisfy the task.
4. **Verify**: Explicitly verify acceptance criteria and run the task check; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
5. **Check off**: Mark the task `[x]` in the canonical plan file on disk only when verification passes.
````

````Prior
3. **Perform**: Make the minimum edits required to satisfy the task.
4. **Verify**: Explicitly verify acceptance criteria. If the repo policy requires a toolchain loop, run it.
5. **Check off**: Mark the task `[x]` in the canonical plan file on disk only when verification passes.
````

### Revert Block: .claude/agents/atomic-executor.md

````Current

Run toolchain in order: format, lint, type-check, test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run toolchain in order: format, lint, type-check, test. Restart from step 1 if any step fails or changes files.

````

### Revert Block: .claude/agents/atomic-planner.md

````Current
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
- Phase gates: every phase between Phase 0 and the final QA phase ends with a `[phase-gate]` task, placed after the task ID. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- Final phase: full QA loop for each applicable language, with one final-QC static artifact per language for the format, lint, and type-check steps, ending with the self-review task that writes `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`
````

````Prior
- Phase 0: baseline capture (language-specific static tool baselines and one parallel test-suite baseline run per gate, the `Phase 0 baseline`)
- Final phase: full QA loop for each applicable language, with one final-QC static artifact per language for the format, lint, and type-check steps, ending with the self-review task that writes `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`
````

### Revert Block: .claude/rules/csharp.md

````Current

Run the toolchain in order: format → lint → type-check → architecture → test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → lint → type-check → architecture → test. Restart from step 1 if any step fails or changes files.

````

### Revert Block: .claude/rules/general-code-change.md

````Current

This loop is the phase-gate and final-QA requirement; integration tests (stage 7) run in CI for phase gates and the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

Mutation testing and golden tests run in pre-merge or nightly pipelines, not the per-commit loop.
````

````Prior

Mutation testing and golden tests run in pre-merge or nightly pipelines, not the per-commit loop.
````

### Revert Block: .claude/rules/powershell.md

````Current

Run the toolchain in order: format → analyze → test. Restart from step 1 if any step fails or changes files. Use the MCP server functions; do not substitute VS Code task wrappers. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → analyze → test. Restart from step 1 if any step fails or changes files. Use the MCP server functions; do not substitute VS Code task wrappers.

````

### Revert Block: .claude/rules/python.md

````Current

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Do not stop the loop until all four steps complete without errors in a single pass. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Do not stop the loop until all four steps complete without errors in a single pass.

````

### Revert Block: .claude/rules/shell.md

````Current

Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

## Native Invocation and Environment
````

````Prior

## Native Invocation and Environment
````

### Revert Block: .claude/rules/typescript.md

````Current

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files.

````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current

Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

## Minimal-Audit Directive Contract (Small Path)
````

````Prior

## Minimal-Audit Directive Contract (Small Path)
````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current

## Test Cadence (Mandatory)

This section defines when the toolchain runs during plan execution. Other plan-execution surfaces reference this section instead of restating it.

- **Task check (after each task).** After each task, the executor runs a task check: format, lint, and type check scoped to the files the task changed, then the task's test selection. The task's test selection is the mirrored test files under `tests/` of each changed production file, plus every test file that imports, dot-sources, or names a changed module or file; for a changed Markdown or configuration path, it is the contract tests that read that path. Integration and golden suites are never part of the task's test selection. A task check is not a gate: it measures no coverage and does not replace the phase gate. Its evidence is a new append-only file per task, `<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`, which records the changed files, the selection and the rule that produced it, and each command with its exit code.
- **Phase gate (after each phase).** The last task of every phase between Phase 0 and the final QA phase carries the `[phase-gate]` tag, placed after the task ID as `[expect-fail]` is. That task runs stages 1 to 6 of the toolchain loop across the repository: format, lint, type check, architecture-boundary tests, the full unit suite, and contract checks. The unit stage is one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers. On a failure or an auto-fix, fix the cause and restart from step 1; the phase closes only after one clean pass. Its evidence is `<FEATURE>/evidence/qa-gates/phase-gate.P<N>.<timestamp>.md`. Phase 0 needs no gate task, and the loop of the final QA phase is its own gate.
- **Final QA loop (unchanged).** The final QA loop in the next section remains a full run with coverage compared with the `Phase 0 baseline`, and the no-SKIPPED rule is unchanged.
- **CI-only suites.** Integration and golden suites run in CI only.

## Final QA Loop (Required for Code/Test Changes)
````

````Prior

## Final QA Loop (Required for Code/Test Changes)
````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current

Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

## No-SKIPPED Rule for Planned Command Tasks
````

````Prior

## No-SKIPPED Rule for Planned Command Tasks
````

### Revert Block: .claude/skills/csharp-qa-gate/SKILL.md

````Current
- `csharp-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

````Prior
- `csharp-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`).
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- `Invoke-Pester` without `-EnableExit` (or `Run.Exit`) exits 0 when tests fail; read the JUnit file rather than the exit code of such a run.
- A task check runs Pester on the selected test files through `New-PesterConfiguration` with `Run.Path` set to those files and `Run.Exit` set to `$true`, so its exit status reflects failures; it is not a gate.
- No MCP tool exposes `Invoke-PoshQCLeakScan`. The executor reaches it through the `sh` launcher route, importing the branch-current `scripts/powershell/PoshQC/PoshQC.psd1` and calling `Invoke-PoshQCLeakScan -Root`; the scan throws on any failure, so the launcher exits non-zero.
````

````Prior
- `Invoke-Pester` without `-EnableExit` (or `Run.Exit`) exits 0 when tests fail; read the JUnit file rather than the exit code of such a run.
- No MCP tool exposes `Invoke-PoshQCLeakScan`. The executor reaches it through the `sh` launcher route, importing the branch-current `scripts/powershell/PoshQC/PoshQC.psd1` and calling `Invoke-PoshQCLeakScan -Root`; the scan throws on any failure, so the launcher exits non-zero.
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1`: the light-remediation text of issue #1097 in the review and orchestration surfaces and their mirrors.
- `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`: the test-cadence wording of issue #1167 in the six `atomic-plan-contract` copies and the referring surfaces, the sweep for per-task full-suite wording, and the byte identity of the edited Copilot files and their bundles.

````

````Prior
- `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1`: the light-remediation text of issue #1097 in the review and orchestration surfaces and their mirrors.

````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- Parallel workers reduce wall-clock time only: they are capped by the slowest test and leave the cost in the product.
- pytest: pass `-n auto` (pytest-xdist) on the command line of the CI step `Run tests with Pytest`, of the parallel VS Code tasks, of the `fix_all` pytest step, and of the full-suite pytest commands of the atomic executor tool (its preflight QC, its phase-gate QC loop, and the commands its prompts state), never in `addopts`, because the VS Code Test Explorer keys results to the wrong file when `addopts` carries it. `-n auto` counts physical cores, so a runner can start fewer workers than it has vCPUs; measure it against an explicit count such as `-n 4` before keeping it. pytest-cov combines the worker coverage into one report.
- Pester: parallel validation uses separate Pester 6 processes: `Invoke-PoshQCTest -ShardIndex -ShardCount` on the CI runners and `Invoke-PoshQCParallelTest` locally. Read the per-file `time` of the JUnit `testsuite` elements before changing the shard count or the weights in `config/poshqc-shard-weights.json`.
````

````Prior
- Parallel workers reduce wall-clock time only: they are capped by the slowest test and leave the cost in the product.
- pytest: pass `-n auto` (pytest-xdist) on the command line of the CI step `Run tests with Pytest`, of the parallel VS Code tasks, of the `fix_all` pytest step, and of the full-suite pytest commands of the atomic executor tool (its preflight QC, its full QC loop, and the commands its prompts state), never in `addopts`, because the VS Code Test Explorer keys results to the wrong file when `addopts` carries it. `-n auto` counts physical cores, so a runner can start fewer workers than it has vCPUs; measure it against an explicit count such as `-n 4` before keeping it. pytest-cov combines the worker coverage into one report.
- Pester: parallel validation uses separate Pester 6 processes: `Invoke-PoshQCTest -ShardIndex -ShardCount` on the CI runners and `Invoke-PoshQCParallelTest` locally. Read the per-file `time` of the JUnit `testsuite` elements before changing the shard count or the weights in `config/poshqc-shard-weights.json`.
````

### Revert Block: .claude/skills/execution-environment/SKILL.md

````Current
- A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence.
- A task check under `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill runs the task's test selection; its selection and results are recorded as task-check evidence, never as a gate result or coverage evidence.
- Serial tasks remain for debugging one failure and are not gates.
````

````Prior
- A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence.
- Serial tasks remain for debugging one failure and are not gates.
````

### Revert Block: .claude/skills/orchestrate/SKILL.md

````Current
- `atomic-planner` — generates phased implementation plans
- `atomic-executor` — executes approved plans task-by-task. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- `feature-review` — produces policy, code, and feature audit artifacts
````

````Prior
- `atomic-planner` — generates phased implementation plans
- `atomic-executor` — executes approved plans task-by-task
- `feature-review` — produces policy, code, and feature audit artifacts
````

### Revert Block: .claude/skills/orchestrate/SKILL.md

````Current
- **R2 — Preflight clearance:** Delegate to `atomic-executor` for precondition validation only (no implementation), with the preflight directive in the delegation prompt. Trivial defects are fixed in place. If the executor returns `PREFLIGHT: REVISIONS REQUIRED`, return to R1 once and re-delegate to `atomic-planner` with the full `PREFLIGHT-DEFECT:` list; if the following preflight still reports a substantive defect, record `final_status: "blocked_preflight_iteration_limit"` on the cycle and halt per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`. Only after `PREFLIGHT: ALL CLEAR` may the orchestrator advance to R3.
- **R3 — Remediation execution:** Delegate to `atomic-executor` with full execution authorization. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- **Pre-R4 commit:** Stage all changes (`git add -A`), delegate to `Agent(commit-message)` to generate a commit message from the staged diff (the agent returns message text only and does not commit), then commit with the generated message. The `git commit` action remains on the orchestrator. Advance to R4 only after a successful commit.
````

````Prior
- **R2 — Preflight clearance:** Delegate to `atomic-executor` for precondition validation only (no implementation), with the preflight directive in the delegation prompt. Trivial defects are fixed in place. If the executor returns `PREFLIGHT: REVISIONS REQUIRED`, return to R1 once and re-delegate to `atomic-planner` with the full `PREFLIGHT-DEFECT:` list; if the following preflight still reports a substantive defect, record `final_status: "blocked_preflight_iteration_limit"` on the cycle and halt per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`. Only after `PREFLIGHT: ALL CLEAR` may the orchestrator advance to R3.
- **R3 — Remediation execution:** Delegate to `atomic-executor` with full execution authorization. Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping.
- **Pre-R4 commit:** Stage all changes (`git add -A`), delegate to `Agent(commit-message)` to generate a commit message from the staged diff (the agent returns message text only and does not commit), then commit with the generated message. The `git commit` action remains on the orchestrator. Advance to R4 only after a successful commit.
````

### Revert Block: .claude/skills/powershell-qa-gate/SKILL.md

````Current
- `powershell-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

````Prior
- `powershell-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`).
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

### Revert Block: .claude/skills/python-qa-gate/SKILL.md

````Current
- `python-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

````Prior
- `python-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`).
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

### Revert Block: .codex/agents/atomic-executor.toml

````Current
3. **Perform**: Make the minimum edits required to satisfy the task.
4. **Verify**: Explicitly verify acceptance criteria and run the task check; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
5. **Check off**: Mark the task `[x]` in the canonical plan file on disk only when verification passes.
````

````Prior
3. **Perform**: Make the minimum edits required to satisfy the task.
4. **Verify**: Explicitly verify acceptance criteria. If the repo policy requires a toolchain loop, run it.
5. **Check off**: Mark the task `[x]` in the canonical plan file on disk only when verification passes.
````

### Revert Block: .codex/agents/atomic-executor.toml

````Current

Run toolchain in order: format, lint, type-check, test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run toolchain in order: format, lint, type-check, test. Restart from step 1 if any step fails or changes files.

````

### Revert Block: .codex/agents/atomic-planner.toml

````Current
5. Do not execute implementation; produce the plan only.
6. In every plan, every phase between Phase 0 and the final QA phase ends with a `[phase-gate]` task, placed after the task ID. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior
5. Do not execute implementation; produce the plan only.

````

### Revert Block: .github/agents/atomic_executor.agent.md

````Current
- Bugfix workflow: smallest failing regression test first, then minimal fix.
- Toolchain loop: format → lint → type-check → test, run as a task check after each task and as the full loop at each phase gate and in the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- Dependencies: do not add new deps unless explicitly approved.
````

````Prior
- Bugfix workflow: smallest failing regression test first, then minimal fix.
- Toolchain loop: format → lint → type-check → test; repeat until clean.
- Dependencies: do not add new deps unless explicitly approved.
````

### Revert Block: .github/agents/atomic_executor.agent.md

````Current
- Explicitly verify the acceptance criteria.
- Run the task check for the task; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- If the task changes code/tests and the plan does not explicitly specify verification commands, prefer repo-defined tasks/commands and ensure the final QA phase executes the full toolchain loop for each language touched by the plan (per the table in Section 0).
````

````Prior
- Explicitly verify the acceptance criteria.
- If the repo policy requires a toolchain loop, run it at the appropriate points (or per plan).
- If the task changes code/tests and the plan does not explicitly specify verification commands, prefer repo-defined tasks/commands and ensure the final QA phase executes the full toolchain loop for each language touched by the plan (per the table in Section 0).
````

### Revert Block: .github/agents/atomic_planning.agent.md

````Current
- If the plan changes code or tests, it MUST include a final **QA phase** that runs the full toolchain loop and reports results.
- If the plan changes code or tests, every phase between Phase 0 and the final QA phase MUST end with a `[phase-gate]` task, placed after the task ID. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior
- If the plan changes code or tests, it MUST include a final **QA phase** that runs the full toolchain loop and reports results.

````

### Revert Block: .github/agents/atomic_planning.agent.md

````Current
   * Did you include a final QA phase that runs the toolchain loop **for each applicable language** and reports results?
   * Does every phase between Phase 0 and the final QA phase end with a `[phase-gate]` task?
* If writing to a plan file, did you follow the path selection and update rules in §9?
````

````Prior
   * Did you include a final QA phase that runs the toolchain loop **for each applicable language** and reports results?
* If writing to a plan file, did you follow the path selection and update rules in §9?
````

### Revert Block: .github/agents/csharp-atomic-executor.agent.md

````Current
- Bugfix workflow: smallest failing regression test first, then minimal fix.
- Toolchain loop: format → lint → type-check → test, run as a task check after each task and as the full loop at each phase gate and in the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- Dependencies: do not add new deps unless explicitly approved.
````

````Prior
- Bugfix workflow: smallest failing regression test first, then minimal fix.
- Toolchain loop: format → lint → type-check → test; repeat until clean.
- Dependencies: do not add new deps unless explicitly approved.
````

### Revert Block: .github/agents/csharp-atomic-executor.agent.md

````Current
- Explicitly verify the acceptance criteria.
- Run the task check for the task; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- If the task changes code/tests and the plan does not explicitly specify verification commands, prefer repo-defined tasks/commands and ensure the final QA phase executes the full toolchain loop for each language touched by the plan (per the table in Section 0).
````

````Prior
- Explicitly verify the acceptance criteria.
- If the repo policy requires a toolchain loop, run it at the appropriate points (or per plan).
- If the task changes code/tests and the plan does not explicitly specify verification commands, prefer repo-defined tasks/commands and ensure the final QA phase executes the full toolchain loop for each language touched by the plan (per the table in Section 0).
````

### Revert Block: .github/agents/csharp-atomic-executor.agent.md

````Current

Phase-gate and final-QA toolchain for C# (each task runs a task check instead). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
1) Format (`csharpier .` or repo task equivalent)
````

````Prior

Required toolchain for C# tasks:
1) Format (`csharpier .` or repo task equivalent)
````

### Revert Block: .github/agents/csharp-atomic-planning.agent.md

````Current
- If the plan changes code or tests, it MUST include a final **QA phase** that runs the full toolchain loop and reports results.
- If the plan changes code or tests, every phase between Phase 0 and the final QA phase MUST end with a `[phase-gate]` task, placed after the task ID. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior
- If the plan changes code or tests, it MUST include a final **QA phase** that runs the full toolchain loop and reports results.

````

### Revert Block: .github/agents/csharp-atomic-planning.agent.md

````Current
- final QA loop for affected toolchains,
- a `[phase-gate]` task ending every phase between Phase 0 and the final QA phase,
- REQ-ID closure when applicable.
````

````Prior
- final QA loop for affected toolchains,
- REQ-ID closure when applicable.
````

### Revert Block: .github/agents/powershell-atomic-executor.agent.md

````Current
- Bugfix workflow: smallest failing regression test first, then minimal fix.
- Toolchain loop: format → lint → type-check → test, run as a task check after each task and as the full loop at each phase gate and in the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- Dependencies: do not add new deps unless explicitly approved.
````

````Prior
- Bugfix workflow: smallest failing regression test first, then minimal fix.
- Toolchain loop: format → lint → type-check → test; repeat until clean.
- Dependencies: do not add new deps unless explicitly approved.
````

### Revert Block: .github/agents/powershell-atomic-executor.agent.md

````Current
- Explicitly verify the acceptance criteria.
- Run the task check for the task; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- If the task changes code/tests and the plan does not explicitly specify verification commands, prefer repo-defined tasks/commands and ensure the final QA phase executes the full toolchain loop for each language touched by the plan (per the table in Section 0).
````

````Prior
- Explicitly verify the acceptance criteria.
- If the repo policy requires a toolchain loop, run it at the appropriate points (or per plan).
- If the task changes code/tests and the plan does not explicitly specify verification commands, prefer repo-defined tasks/commands and ensure the final QA phase executes the full toolchain loop for each language touched by the plan (per the table in Section 0).
````

### Revert Block: .github/agents/powershell-atomic-executor.agent.md

````Current

Phase-gate and final-QA toolchain for PowerShell (each task runs a task check instead). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
1) Format (`mcp__drm-copilot__run_poshqc_format`)
````

````Prior

Required toolchain for PowerShell tasks:
1) Format (`mcp__drm-copilot__run_poshqc_format`)
````

### Revert Block: .github/agents/powershell-atomic-planning.agent.md

````Current
- If the plan changes code or tests, it MUST include a final **QA phase** that runs the full toolchain loop and reports results.
- If the plan changes code or tests, every phase between Phase 0 and the final QA phase MUST end with a `[phase-gate]` task, placed after the task ID. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior
- If the plan changes code or tests, it MUST include a final **QA phase** that runs the full toolchain loop and reports results.

````

### Revert Block: .github/agents/powershell-atomic-planning.agent.md

````Current
  * Did you include a final QA phase that runs the toolchain loop **for each applicable language** and reports results?
  * Does every phase between Phase 0 and the final QA phase end with a `[phase-gate]` task?
* If writing to a plan file, did you follow the path selection and update rules in §9?
````

````Prior
  * Did you include a final QA phase that runs the toolchain loop **for each applicable language** and reports results?
* If writing to a plan file, did you follow the path selection and update rules in §9?
````

### Revert Block: .github/agents/python-atomic-executor.agent.md

````Current
- Bugfix workflow: smallest failing regression test first, then minimal fix.
- Toolchain loop: format → lint → type-check → test, run as a task check after each task and as the full loop at each phase gate and in the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- Dependencies: do not add new deps unless explicitly approved.
````

````Prior
- Bugfix workflow: smallest failing regression test first, then minimal fix.
- Toolchain loop: format → lint → type-check → test; repeat until clean.
- Dependencies: do not add new deps unless explicitly approved.
````

### Revert Block: .github/agents/python-atomic-executor.agent.md

````Current
- Explicitly verify the acceptance criteria.
- Run the task check for the task; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- If the task changes code/tests and the plan does not explicitly specify verification commands, prefer repo-defined tasks/commands and ensure the final QA phase executes the full toolchain loop for each language touched by the plan (per the table in Section 0).
````

````Prior
- Explicitly verify the acceptance criteria.
- If the repo policy requires a toolchain loop, run it at the appropriate points (or per plan).
- If the task changes code/tests and the plan does not explicitly specify verification commands, prefer repo-defined tasks/commands and ensure the final QA phase executes the full toolchain loop for each language touched by the plan (per the table in Section 0).
````

### Revert Block: .github/agents/python-atomic-executor.agent.md

````Current

Phase-gate and final-QA toolchain for Python (each task runs a task check instead). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
1) Format (`poetry run black .` or repo task equivalent)
````

````Prior

Required toolchain for Python tasks:
1) Format (`poetry run black .` or repo task equivalent)
````

### Revert Block: .github/agents/python-atomic-planning.agent.md

````Current
- If the plan changes code or tests, it MUST include a final **QA phase** that runs the full toolchain loop and reports results.
- If the plan changes code or tests, every phase between Phase 0 and the final QA phase MUST end with a `[phase-gate]` task, placed after the task ID. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior
- If the plan changes code or tests, it MUST include a final **QA phase** that runs the full toolchain loop and reports results.

````

### Revert Block: .github/agents/python-atomic-planning.agent.md

````Current
- final QA loop for affected toolchains,
- a `[phase-gate]` task ending every phase between Phase 0 and the final QA phase,
- REQ-ID closure when applicable.
````

````Prior
- final QA loop for affected toolchains,
- REQ-ID closure when applicable.
````

### Revert Block: .github/codex/execute-hard-lock.prompt.md

````Current
4) Verify acceptance criteria
5) Run the task check; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
6) Check off the task ONLY when verification passes
````

````Prior
4) Verify acceptance criteria
5) Run required toolchains as specified or implied
6) Check off the task ONLY when verification passes
````

### Revert Block: .github/codex/resume-hard-lock.prompt.md

````Current
3) Verify acceptance criteria.
4) Run the task check; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
5) Check off the task ONLY when verification passes.
````

````Prior
3) Verify acceptance criteria.
4) Run required toolchains as specified or implied.
5) Check off the task ONLY when verification passes.
````

### Revert Block: .github/instructions/general-code-change.instructions.md

````Current
   - Re-run the original repro and the new regression test.
   - Run the full toolchain in order (format → lint → type-check → test) using the repo-standard commands or tasks; rerun from the start if any step changes files or fails. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior
   - Re-run the original repro and the new regression test.
   - Run the full toolchain in order (format → lint → type-check → test) using the repo-standard commands or tasks; rerun from the start if any step changes files or fails.

````

### Revert Block: .github/instructions/general-code-change.instructions.md

````Current

Treat these four steps as one **toolchain pass**. The toolchain pass is the phase-gate and final-QA requirement; integration tests run in CI for phase gates and the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Treat these four steps as one **toolchain pass**.

````

### Revert Block: .github/prompts/execute-hard-lock.prompt.md

````Current
4) Verify acceptance criteria
5) Run the task check; a `[phase-gate]` task runs the full toolchain loop instead. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
6) Check off the task ONLY when verification passes
````

````Prior
4) Verify acceptance criteria
5) Run required toolchains as specified or implied
6) Check off the task ONLY when verification passes
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current

Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

## Minimal-Audit Directive Contract (Small Path)
````

````Prior

## Minimal-Audit Directive Contract (Small Path)
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current

## Test Cadence (Mandatory)

This section defines when the toolchain runs during plan execution. Other plan-execution surfaces reference this section instead of restating it.

- **Task check (after each task).** After each task, the executor runs a task check: format, lint, and type check scoped to the files the task changed, then the task's test selection. The task's test selection is the mirrored test files under `tests/` of each changed production file, plus every test file that imports, dot-sources, or names a changed module or file; for a changed Markdown or configuration path, it is the contract tests that read that path. Integration and golden suites are never part of the task's test selection. A task check is not a gate: it measures no coverage and does not replace the phase gate. Its evidence is a new append-only file per task, `<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`, which records the changed files, the selection and the rule that produced it, and each command with its exit code.
- **Phase gate (after each phase).** The last task of every phase between Phase 0 and the final QA phase carries the `[phase-gate]` tag, placed after the task ID as `[expect-fail]` is. That task runs stages 1 to 6 of the toolchain loop across the repository: format, lint, type check, architecture-boundary tests, the full unit suite, and contract checks. The unit stage is one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers. On a failure or an auto-fix, fix the cause and restart from step 1; the phase closes only after one clean pass. Its evidence is `<FEATURE>/evidence/qa-gates/phase-gate.P<N>.<timestamp>.md`. Phase 0 needs no gate task, and the loop of the final QA phase is its own gate.
- **Final QA loop (unchanged).** The final QA loop in the next section remains a full run with coverage compared with the `Phase 0 baseline`, and the no-SKIPPED rule is unchanged.
- **CI-only suites.** Integration and golden suites run in CI only.

## Final QA Loop (Required for Code/Test Changes)
````

````Prior

## Final QA Loop (Required for Code/Test Changes)
````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current

Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

## No-SKIPPED Rule for Planned Command Tasks
````

````Prior

## No-SKIPPED Rule for Planned Command Tasks
````

### Revert Block: AGENTS.md

````Current

This loop is the phase-gate and final-QA requirement; integration tests run in CI for phase gates and the final QA loop. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

## File Size Limit
````

````Prior

## File Size Limit
````

### Revert Block: docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md

````Current
- [ ] [P3-T1] Apply the smallest change needed to make the regression test pass; avoid opportunistic refactors
- [ ] [P3-T2] [phase-gate] Run the full toolchain loop (stages 1 to 6) per `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill and record `<FEATURE>/evidence/qa-gates/phase-gate.P3.<timestamp>.md`

````

````Prior
- [ ] [P3-T1] Apply the smallest change needed to make the regression test pass; avoid opportunistic refactors

````

### Revert Block: docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md

````Current
  - Acceptance: <optional>
- [ ] [P1-T3] [phase-gate] Run the full toolchain loop (stages 1 to 6) per `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill and record `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md`

````

````Prior
  - Acceptance: <optional>

````

### Revert Block: docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md

````Current
- [ ] Remove or redirect legacy paths
- [ ] [phase-gate] Run the full toolchain loop (stages 1 to 6) per `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill and record `<FEATURE>/evidence/qa-gates/phase-gate.P2.<timestamp>.md`

````

````Prior
- [ ] Remove or redirect legacy paths

````

### Revert Block: extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md

````Current

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files.

````

### Revert Block: extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md

````Current
- `csharp-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

````Prior
- `csharp-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`).
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

### Revert Block: extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md

````Current
- `csharp-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

````Prior
- `csharp-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`).
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.
````

### Revert Block: extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md

````Current

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.

````

````Prior

Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files.

````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence in the named file, in the order of this entry. Revert this entry before any lower-numbered entry that names the same paths, per `## Revert Order` of the ledger README.
2. Re-copy mirrors and bundles: copy `.claude/skills/execution-environment/SKILL.md` to `.agents/skills/execution-environment/SKILL.md` and `.github/skills/execution-environment/SKILL.md`; copy every source named under `## Files Changed` to the bundle path listed beside its byte-identical copy (`claude-customizations/` for `.claude/` files, `codex-and-agents-customizations/` for `.agents/`, `.codex/agents/atomic-executor.toml`, `.codex/agents/atomic-planner.toml`, and `AGENTS.md`, `customizations/` for `.github/` files, and `feature-templates/` for the plan templates); the four csharp-legacy variants are sources and are restored by step 1.
3. Regenerate Codex variants: applicable, because the base agents `.codex/agents/atomic-executor.toml` and `.codex/agents/atomic-planner.toml` changed. Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form to rewrite the variants and their bundle copies, then run it with `--check`.
4. Restore pinned hashes: not applicable, because no pinned surface moved.
5. Restore contract-test literals: delete `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`; its listing in `## Contract Tests That Pin Mirrored Files` of the brief is restored by step 1.
6. Run the contract tests: run `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionLedger.Tests.ps1`, `test_execution_environment_brief_contracts.py`, `test_evidence_timestamp_contracts.py`, `test_single_pass_preflight_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_codex_agent_wrapper_contracts.py`, and `test_typescript_toolchain_instruction_contracts.py`.

## Revert Signals

- A phase gate or the final QA loop finds a failure in a test outside the task's test selection of the task that caused it, in more than one item.
- More remediation cycles, or CI failures on a pull request head, traced to a defect a per-task full run would have caught earlier.
- Integration or golden suite failures that CI reports only after merge.
