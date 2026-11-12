# orchestration-test-cadence-targeted-per-task (Spec)

- **Issue:** #1167
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-11T19-25
- **Status:** Draft
- **Version:** 0.2

## Context
The harness text reads as a full toolchain run (including the whole unit suite) after every atomic-plan task. The owner rule (verbatim) is: "The rule for an orchestration is a full test after every phase and only targeted tests after every task". This change makes the orchestration test cadence explicit: the atomic executor runs a task check (scoped static checks plus the task's test selection) after each task, and the full toolchain loop at each phase gate and in the final QA loop.

Downstream impact that motivated the change: in the downstream repository iar-migration, issue #145, the executor ran about 10,400 unit tests after every task of a 68-task plan, at about 10 tasks per hour.

Environment:
- OS/version: Windows 11 host and Linux CI; any destination repository that receives the push-down
- Python version: 3.13
- Command/flags used: `/orchestrate` and `/execute-hard-lock` atomic execution
- Data source or fixture: downstream repository iar-migration, issue #145, 2026-11-11 (about 10,400 unit tests)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Design basis: `research/research.2026-11-12T00-42.md` in this folder (sections 1 to 10 and Risks).

## Repro & Evidence
Steps to Reproduce:
1. Run an orchestration whose atomic plan has many tasks in a repository with a large unit suite.
2. Observe the atomic executor follow the per-task toolchain loop wording (for example R3 in `.claude/skills/orchestrate/SKILL.md`, "Mandatory Toolchain Loop" in `.claude/rules/general-code-change.md`).
3. Observe the full unit suite run after every task.

Expected:
After each task: format, lint, and type check scoped to the changed files, plus only the task's test selection, recorded in the task evidence. At each phase gate: the full toolchain loop, restarting from step 1 on a failure or auto-fix. Final QA loop unchanged. The cadence is defined once in the `atomic-plan-contract` skill and referenced from every other surface.

Actual:
Executors run the full unit suite after each task. Downstream observation: about 10 tasks per hour across a 68-task plan, with most task time spent in the full suite, and a second orchestration on the same machine queued behind each run under a downstream single-suite convention.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: R3: "Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping."

Evidence from research (section 1, Executive Summary):
- Per-task full-suite prescriptions: orchestrate R3 (`.claude` and `.agents` copies); the Copilot language executors' "Required toolchain for <language> tasks" (full `pytest -n auto --cov...` per task); the atomic-executor `## Toolchain Commands` loop sentence and `## Execution Protocol` step 4; the Copilot executor "Toolchain loop ... repeat until clean"; the hard-lock prompts' per-task "Run required toolchains as specified or implied".
- Unscoped loop statements that executors read as per task: `## Mandatory Toolchain Loop` in `.claude/rules/general-code-change.md` and its counterparts, and the "Run the toolchain in order" sentences of the language rules and `.agents` language skills.
- No surface defines a phase gate today.
- The Python atomic executor CLI already implements the owner's cadence: `scripts/dev_tools/atomic_executor/qc_runner.py` (`QCRunner.run_scoped()` after each task, `run_full()` after each phase). The agent-facing text diverged from that implementation.

## Scope & Non-Goals
- In scope:
  - A new canonical section `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill (three bases and their bundle copies).
  - Reference sentences that replace per-task full-run wording on every referring surface (Claude, Codex, `.agents`, Copilot, push-down bundles).
  - The general-code-change policy texts, the orchestrate skill, the atomic executor and planner surfaces, the hard-lock prompts, the language rules and `.agents` language skills, the QA-gate skills where they mention a per-task batch, the plan templates, and the execution-environment brief.
  - Regeneration of Codex agent variants.
  - A new Pester 6 contract test file.
  - Process-reduction ledger entry `0011` and its README index row.
- Out of scope / non-goals:
  - Any change to coverage thresholds, the Phase 0 baseline comparison, the no-SKIPPED rule, or the final QA loop procedure.
  - A new planner-hook rule, or any change to the Python or TypeScript plan validators (`scripts/dev_tools/validate_orchestration_artifacts.py`, `plan_gate_*.py`, `extensions/drm-copilot/src/lib/validate/`) or to `.claude/hooks/validate-planner-output.ps1`.
  - Any change to the Python atomic executor CLI (`scripts/dev_tools/atomic_executor/`), including `qc_runner.py` and `acquire_executor_lock` in `cli_workspace.py`.
  - Any change to the twelve issue-#1094 sweep tokens in `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
  - Any queue or lock mechanism (see D14).
- Explicitly excluded systems, integrations, or datasets:
  - Destination repositories: they receive the change only after an extension rebuild, reinstall, and push-down, which is outside this item.
  - Non-orchestration general-purpose agents (for example `.github/agents/5.1-Beast-adjusted.agent.md`) unless the planner's re-sweep or the new sweep test (D11c) finds a per-task full-suite prescription in them.

## Root Cause Analysis
The agent-facing harness text never distinguishes a per-task checkpoint from a phase-level gate. The seven-stage `## Mandatory Toolchain Loop` and its counterparts state no cadence, so an executor applies them after every change, which is after every task. Several surfaces state the per-task full run explicitly (orchestrate R3; the Copilot language executors' "Required toolchain for <language> tasks"; the atomic-executor per-task verify step). No surface defines a phase gate, so the only full run with a defined position is the final QA loop, and the per-task reading fills the gap. The Python executor CLI already separates `run_scoped` (per task) from `run_full` (per phase); the prose surfaces were not aligned with it.

No plan validator requires a full-suite command per task or rejects a scoped per-task command (research section 4). The only plan-structure check that reads test wording is `.claude/hooks/validate-planner-output.ps1`, which requires QA or toolchain work in the final phase only.

## Proposed Fix

### Design summary (what changes where):
Decisions made by the orchestrator, with rationale:

- **D1 Canonical location.** A new section `## Test Cadence (Mandatory)` is added to the `atomic-plan-contract` skill, placed immediately before `## Final QA Loop (Required for Code/Test Changes)`, in all three bases (`.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`) and their three bundle copies under `extensions/drm-copilot/resources/`. Every other surface carries a single reference sentence that names `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill instead of restating the rule. Rationale: the owner asked for one definition; the contract is the plan-execution source every planner and executor already loads; placing the cadence in `general-code-change` would spread it across four non-identical texts and apply it to direct-mode edits outside orchestration (research section 5, rejected alternatives).
- **D2 Vocabulary.** The per-task checkpoint is called the "task check" and its tests "the task's test selection". Neither the canonical section nor any reference sentence uses any of the twelve issue-#1094 sweep tokens in `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` (for example `targeted tests`, `targeted Pester`, `targeted Pytest`, `run tests after each`, `relevant tests pass`) or `Targeted runs are allowed`. The #1094 sweep stays unchanged. Rationale: the sweep tokens still describe runs that replace a gate, which remains prohibited; a distinct vocabulary avoids weakening that sweep (research Risk 1).
- **D3 Task check (after each task).** Format, lint, and type check scoped to the files the task changed; then the task's test selection, which is: the mirrored test files under `tests/` of each changed production file, plus every test file that imports, dot-sources, or names a changed module or file (for a Markdown or configuration change, the contract tests that read that path). A task check is not a gate, measures no coverage, and is not a substitute for the phase gate. Integration and golden suites are never part of a selection. The task's evidence records the changed files, the selection and the rule that produced it, and each command with its exit code, written as a new file per task (append-only), for example `<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`. Rationale: matches the owner rule and the existing `run_scoped` precedent, extended to mirrored and importing tests so that a change to a module exercises its tests; a new file per task keeps evidence append-only.
- **D4 Phase gate.** Every phase between Phase 0 and the final QA phase ends with a full-toolchain gate task tagged `[phase-gate]`, placed after the task ID (following the `[expect-fail]` precedent). The gate runs stages 1 to 6 of the toolchain loop (format, lint, type check, architecture, the full unit suite, contract checks) across the repository. The unit stage is one run of each parallel gate: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers. On a failure or an auto-fix, the gate restarts from step 1; the phase does not close until one clean pass. Evidence: `<FEATURE>/evidence/qa-gates/phase-gate.P<N>.<timestamp>.md`. Phase 0 (baseline) needs no gate task; the final QA phase's loop is its own gate. Rationale: implements "a full test after every phase" with a statically identifiable task, and reuses the parallel-gate definitions already pinned by issue #1094.
- **D5 Final QA loop unchanged.** The final QA loop remains a full run with coverage compared against the `Phase 0 baseline`, and the no-SKIPPED rule is unchanged. `## Final QA Loop` and `## Short-Path Minimal Plan Contract` gain only a reference to the cadence section. Rationale: the owner rule narrows per-task work only.
- **D6 Integration and golden suites are CI-only.** Stage 7 (integration tests) of `## Mandatory Toolchain Loop` in `.claude/rules/general-code-change.md` runs in CI for phase gates and the final QA loop. Rationale: the owner's explicit instruction ("Integration and golden suites stay CI-only"). This narrows a policy rule and is recorded in the process-reduction ledger (D12).
- **D7 General code-change policy.** All four non-identical texts (`.claude/rules/general-code-change.md`, `.agents/skills/general-code-change/SKILL.md`, `AGENTS.md`, `.github/instructions/general-code-change.instructions.md`, both of its loop sections) plus their bundle copies state that the loop is the phase-gate and final-QA requirement, and that per-task checks follow the contract. "Restart from step 1" is kept. Rationale: these texts are the owner's named source of the per-task reading.
- **D8 Orchestrate skill.** In `.claude/skills/orchestrate/SKILL.md` and `.agents/skills/orchestrate/SKILL.md` (plus bundles), the R3 sentence "Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping." is replaced by the reference sentence, and the `atomic-executor` delegation guidance references the cadence.
- **D9 Other surfaces reference the cadence (no restatement).**
  - Atomic executor: `.claude/agents/atomic-executor.md`; Codex base `.codex/agents/atomic-executor.toml`, then variants regenerated with `scripts/dev_tools/generate_codex_agent_variants.py`; `.agents/skills/atomic-executor/SKILL.md`; the Copilot executors `.github/agents/atomic_executor.agent.md`, `python-atomic-executor.agent.md`, `powershell-atomic-executor.agent.md`, `csharp-atomic-executor.agent.md`. The Copilot language executors' "Required toolchain for <language> tasks" becomes the phase-gate and final-QA toolchain.
  - Atomic planner: `.claude/agents/atomic-planner.md`; Codex base `.codex/agents/atomic-planner.toml` plus regeneration; `.agents/skills/atomic-planner/SKILL.md`; the Copilot planners `.github/agents/atomic_planning.agent.md` and the Python, PowerShell, and C# planning agents. Plans include the `[phase-gate]` task.
  - Hard-lock prompts: `.github/prompts/execute-hard-lock.prompt.md`, `.github/codex/execute-hard-lock.prompt.md`, `.github/codex/resume-hard-lock.prompt.md`, plus bundles.
  - Language rules (`.claude/rules/{python,powershell,typescript,csharp,shell}.md`) and `.agents` language skills: one reference sentence after the toolchain-order sentence; `typescript.md` keeps exactly one `**Testing` line.
  - QA-gate skills, where they mention a per-task or per-batch gate run.
  - Plan templates under `docs/features/templates/{bug,feature,refactor}/` plus bundle copies: an intermediate phase shows a `[phase-gate]` task.
  - Execution-environment brief (all byte-identical copies): `## Test Isolation Checks` gains a sentence that a task check's selection and results are recorded as task-check evidence, never as a gate result or coverage evidence (the pinned sentence "A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence" and the other pinned tokens stay); `## Test Runtime` "full QC loop" is reconciled to the phase-gate and final-QA wording; `## PowerShell Route and PoshQC MCP Limits` states the route for a task-check Pester run on named files; `## Contract Tests That Pin Mirrored Files` names the new test file.
  - The research file inventory (research section 6) is the minimum; the planner re-sweeps the tree before planning edits.
- **D10 Enforcement by policy text plus tests.** No new planner-hook rule and no change to the Python or TypeScript plan validators. Rationale: no validator requires a full-suite command per task (research section 4); the change avoids new production code, planner-hook fixture churn, and the `ProcessReductionLedger.Replay.Tests.ps1` trap; the Python atomic executor CLI (`qc_runner.run_scoped` per task, `run_full` per phase) already matches and stays unchanged. Consequence: the `[phase-gate]` tag is required by policy text and shown by templates, and is not structurally blocked by a hook. This supersedes the research recommendation of a new hook helper.
- **D11 Tests (Pester 6 only, no new Python).** New file `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` with four row groups: (a) canonical-wording rows for all six contract copies; (b) reference rows for every referring surface; (c) a sweep that fails if any harness surface (skills, agents, prompts, rules, instructions, templates, `AGENTS.md`, Codex agents, and their bundles) prescribes a full-suite run per task, using tokens such as `Each task's toolchain loop` and `Required toolchain for Python tasks`, with an in-memory helper test proving each token is detected and the token count pinned; (d) byte-identity rows for edited Copilot files not covered by existing parity tests (the general-code-change instruction and the three hard-lock prompts). The brief's `## Contract Tests That Pin Mirrored Files` lists the file.
- **D12 Process-reduction ledger.** `docs/engineering/process-reductions/` exists (entries `0001` to `0010`), so the change adds entry `0011-<short-name>.md` plus its README index row in the same commit, with revert blocks per non-identical source, following that folder's README and passing the ledger chain tests.
- **D13 Owner authorization for policy edits.** `CLAUDE.md` calls `.github/instructions/*.instructions.md` canonical and says not to modify them, and the policy-compliance skill says not to modify `.claude/rules/` or `.github/instructions/`. The owner's request for issue #1167 explicitly directs updating these policy files and their mirrors. This spec records that authorization; it is scoped to the cadence edits listed in D6, D7, and D9 for this issue only.
- **D14 Single-suite pseudo-queue rule.** The rule does not exist in this repository (research section 8 records the negative search, its scope, and its patterns); it is a downstream convention. This change adds, removes, or edits no queue or lock mechanism, and `acquire_executor_lock` in `scripts/dev_tools/atomic_executor/cli_workspace.py` is not touched.
- **D15 Expect-fail and no-change phases (remediation cycle R1, finding F1).** `## Test Cadence (Mandatory)` gains two bullets after the phase-gate bullet. D15a: a phase that ends with `[expect-fail]` tests keeps its `[phase-gate]` task, whose unit stage passes when its only failures are the plan's named `[expect-fail]` tests that a later phase makes pass, each confirmed failing, and every other test passes; the gate evidence lists those expected failures by name. D15b: a phase that changes no tracked file is a no-change phase and needs no `[phase-gate]` task; the next gate covers it. The planner surfaces and the bug plan template follow D15 (the bug template's Phase 1 is a no-change phase and its Phase 2 gate accepts the `[expect-fail]` failures of [P2-T1]); the feature and refactor templates already agree with it. The same cycle resolves CR1 (the ledger `0011` `## Summary` names pull request #1168 instead of the issue-number stand-in), CR2 (`## Mandatory Toolchain Loop` in `.claude/rules/general-code-change.md` and `.agents/skills/general-code-change/SKILL.md` no longer says the loop stops only after all seven stages; it stops when every stage it runs passes, and stage 7 runs in CI at phase gates and in the final QA loop), and CR3 (the per-task sweep also reads `CLAUDE.md` and `.github/copilot-instructions.md`). The D13 owner authorization covers the CR2 wording edit. Rationale: a gate that requires a clean unit suite cannot pass in a phase whose `[expect-fail]` tests fail by design, and a phase that changes nothing has nothing for a gate to verify.

Reference sentence (recommended text for every referring surface, research section 7): "Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop." Surface-specific wording may add context (for example, the Copilot language executors label their toolchain list as the phase-gate and final-QA toolchain) but keeps the anchor token `## Test Cadence (Mandatory)`.

### Boundaries and invariants to preserve:
- Coverage rules, the `Phase 0 baseline` comparison, the no-SKIPPED rule, and the final QA loop are not weakened.
- The Pre-Mortem `Test isolation` bullet keeps its pinned tokens ("one `Invoke-PoshQCParallelTest` run", "one `pytest -n auto` run", "Jest through its normal parallel workers", "re-run only after a fix").
- The brief keeps "debugging only", "never a gate or evidence", and "parallel gates govern" in `## Test Isolation Checks`, and all copies stay byte-identical.
- Mirrors and bundle copies stay byte-identical wherever parity tests require it.
- The twelve #1094 sweep tokens and their pinned count are unchanged; no new cadence text contains them.
- Test gates run in parallel only (no serial, shuffled, or reversed gate runs); test-order dependence is a violation.
- Evidence is append-only; no artifact encodes an absolute path.
- No new Python code.

### Dependencies or blocked work:
- None blocking. The ledger chain (`0001`, `0004`, `0005`, `0006`, `0009` record regions this change touches) requires entry `0011` to carry exact `Current` and `Prior` text that reverts cleanly in newest-first order.
- Destination repositories pick up the change only after an extension rebuild and push-down.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
- Contract (canonical): the three `atomic-plan-contract` bases and three bundle copies.
- Policy: `.claude/rules/general-code-change.md`, `.agents/skills/general-code-change/SKILL.md`, `AGENTS.md`, `.github/instructions/general-code-change.instructions.md`, plus bundle copies.
- Orchestrate: `.claude/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, plus bundles.
- Executor and planner surfaces listed in D9, with Codex variants regenerated by `scripts/dev_tools/generate_codex_agent_variants.py`.
- Hard-lock prompts listed in D9, plus bundles.
- Language rules and `.agents` language skills, plus bundles (and bundle-only csharp-legacy variants where the edited text is shared).
- QA-gate skills where they mention a per-task or per-batch gate run, plus bundles and csharp-legacy variants.
- Plan templates under `docs/features/templates/{bug,feature,refactor}/` and `extensions/drm-copilot/resources/feature-templates/`.
- Execution-environment brief, all copies.
- New test: `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`.
- Ledger: `docs/engineering/process-reductions/0011-<short-name>.md` and `docs/engineering/process-reductions/README.md`.

#### Functions/classes/CLI commands impacted:
- No production function, class, or CLI command changes.
- `scripts/dev_tools/generate_codex_agent_variants.py` is run (not edited) to regenerate variants, and `--check` verifies them.

#### Data flow and validation changes:
- None in code. Validation of the new wording is by the new Pester file and existing contract tests.

#### Error handling and logging updates:
- Not applicable (text and test changes only).

#### Rollback/feature-flag considerations (if applicable):
- Rollback is by ledger entry `0011`: its revert blocks restore every non-identical source; bundle copies and Codex variants are re-copied or regenerated from the restored sources.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Plan task tag: `[phase-gate]`, placed after the task ID on the last task of every phase between Phase 0 and the final QA phase (same position as `[expect-fail]`).
- Task-check evidence: a new file per task, for example `<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`, recording changed files, the selection and the rule that produced it, and each command with its exit code.
- Phase-gate evidence: `<FEATURE>/evidence/qa-gates/phase-gate.P<N>.<timestamp>.md`.

#### Required configuration keys and defaults:
- None.

#### Backward-compatibility expectations:
- Existing plans without `[phase-gate]` tasks still pass every validator and hook (D10). Executors following such plans run the full loop at the final QA phase as before; the task check replaces the per-task full run.
- The Python atomic executor CLI behavior is unchanged.

#### Performance constraints (latency/throughput/memory):
- Per-task test time scales with the task's test selection rather than the full suite. No numeric target is set; the downstream observation (about 10 tasks per hour with a full suite per task) is the motivating baseline.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The research file inventory is accurate as of 2026-11-12; the planner re-sweeps before planning edits.
  - Hooks of isolated subagents run the copies on `main`; this change adds no hook, so that lag does not apply.
- Constraints (budget, performance, compatibility):
  - Do not weaken the coverage rules, the Phase 0 baseline comparison, the no-SKIPPED rule, or the final QA loop.
  - Mirrors and bundle copies stay byte-identical where parity tests require.
  - Test gates run in parallel only; test-order dependence is a violation; no new Python; evidence append-only; no absolute paths in artifacts.
  - The PR body states the downstream impact: repositories pick up the change after an extension rebuild and push-down.
  - Gate tasks count toward the G13 plan-size guideline; plans with many phases need fewer phases or a `## Size Justification`.
- External dependencies (services, libraries, releases):
  - Extension rebuild and push-down for destination repositories (outside this item).

## Data / API / Config Impact
- User-facing or API changes: agent, skill, prompt, rule, and instruction text; plan templates gain a `[phase-gate]` task example.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag or schema change. MCP-resolved hard-lock prompts read the installed bundle, so they change only after an extension release.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: a Pester test pinning the canonical cadence wording, and a sweep test that fails when any harness surface prescribes a full-suite run per task; parity tests for every mirror.
- [ ] Integration scenario to retest: superseded by D10. No plan validator is changed; existing validators continue to accept scoped per-task test commands (research section 4), and the `[phase-gate]` task is required by policy text and templates.
- [ ] Manual verification notes: coverage rules, Phase 0 baseline comparison, the no-SKIPPED rule, and the final QA loop are unchanged; no queue or lock mechanism is touched (D14). Destinations receive the change after the extension rebuild and push-down.

- Regression tests to add or update: new `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` with row groups (a) canonical, (b) reference, (c) per-task full-suite sweep plus helper, (d) Copilot byte identity (D11).
- Unit tests (pytest) for the fixed behavior and boundaries: none added (no new Python). Existing Python contract tests are re-run unchanged.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): the sweep helper proves each sweep token is detected in in-memory text and pins the token count; canonical rows fail if a copy lacks the section or a pinned phrase; reference rows fail if a surface lacks the anchor token.
- Error handling and logging verification: not applicable.
- Coverage impact and targets for changed lines/modules: no production code changes; coverage must not regress against the `Phase 0 baseline`.
- Toolchain commands to run (format → lint → type-check → test): at each phase gate and in the final QA loop, one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers; `generate_codex_agent_variants.py --check`; the process-reduction ledger chain tests inside the Pester gate.
- Manual validation steps (if required): none.

Existing tests that must keep passing: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `planning-contract-wording.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, `test_execution_environment_brief_contracts.py`, `test_single_pass_preflight_contracts.py`, `test_typescript_toolchain_instruction_contracts.py`, `test_plan_templates_carry_premortem_skeleton`, `test_codex_agent_wrapper_contracts.py`, `ProcessReductionChain.Ledger.Tests.ps1`, and `ProcessReductionLedger*.Tests.ps1`.

## Acceptance Criteria
- [x] AC1: All six `atomic-plan-contract` copies contain `## Test Cadence (Mandatory)` immediately before `## Final QA Loop (Required for Code/Test Changes)`, stating the task check and the task's test selection (D3), the `[phase-gate]` phase gate running stages 1 to 6 with one run of each parallel gate and restart from step 1 (D4), the unchanged final QA loop (D5), and CI-only integration and golden suites (D6); each base is byte-identical to its bundle copy.
- [x] AC2: Neither the canonical section nor any added reference sentence contains any issue-#1094 sweep token or `Targeted runs are allowed`, and `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` is unchanged and passing.
- [x] AC3: Every referring surface named in D7, D8, and D9 contains a reference naming `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill, and no harness surface prescribes a full-suite run per task (verified by the new sweep rows).
- [x] AC4: `.claude/rules/general-code-change.md`, `.agents/skills/general-code-change/SKILL.md`, `AGENTS.md`, and `.github/instructions/general-code-change.instructions.md` (and their bundle copies) state that the toolchain loop is the phase-gate and final-QA requirement, that per-task checks follow the contract, that integration tests run in CI for phase gates and the final QA loop, and they keep "restart from step 1".
- [x] AC5: The orchestrate skill (`.claude` and `.agents` copies and their bundles) no longer contains "Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping.", carries the reference sentence in R3, and its `atomic-executor` delegation guidance references the cadence.
- [x] AC6: The atomic-planner surfaces (Claude agent, Codex base and variants, `.agents` skill, Copilot planners) require a `[phase-gate]` task as the last task of every phase between Phase 0 and the final QA phase, and the bug, feature, and refactor plan templates (and bundle copies) show a `[phase-gate]` task in an intermediate phase.
- [x] AC7: The atomic-executor surfaces (Claude agent, Codex base and variants, `.agents` skill, Copilot executors) and the hard-lock prompts (and bundles) reference the cadence, and the Copilot language executors label their toolchain list as the phase-gate and final-QA toolchain.
- [x] AC8: All execution-environment brief copies are byte-identical and contain the task-check evidence sentence in `## Test Isolation Checks`, the retained pinned sentence "A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence", the reconciled `## Test Runtime` wording, the task-check Pester route in `## PowerShell Route and PoshQC MCP Limits`, and the new test file in `## Contract Tests That Pin Mirrored Files`.
- [x] AC9: `scripts/dev_tools/generate_codex_agent_variants.py --check` exits 0 after the Codex base edits.
- [x] AC10: `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` exists with the canonical, reference, sweep (with an in-memory helper test that detects each token and pins the token count), and Copilot byte-identity row groups, and passes in the phase-gate and final-QA `Invoke-PoshQCParallelTest` runs.
- [x] AC11: The existing contract and parity tests pass: push-down Claude and Codex-and-agents resource contracts, `planning-contract-wording.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, the execution-environment brief contracts, the single-pass preflight contracts, `test_typescript_toolchain_instruction_contracts.py`, and `test_plan_templates_carry_premortem_skeleton`.
- [x] AC12: `docs/engineering/process-reductions/0011-<short-name>.md` and its `README.md` index row are added in the same commit with revert blocks for every non-identical source, and the process-reduction ledger chain tests pass.
- [x] AC13: Line and branch coverage do not regress against the `Phase 0 baseline`; no file under `scripts/dev_tools/atomic_executor/`, the Python or TypeScript plan validators, or `.claude/hooks/validate-planner-output.ps1` is modified; no new Python file is added.
- [ ] AC14 (CI-dependent): CI is green on the PR head.

## Risks & Mitigations
- Technical or operational risks:
  1. Sweep conflict with issue #1094 (high): the owner's word "targeted" collides with the sweep tokens and the QA-gate `Targeted runs are allowed` ban.
  2. Brief evidence sentence (high): "never a gate or evidence" is pinned; per-task evidence could be read as gate evidence.
  3. Ledger chain (high): every target lies in regions recorded by earlier entries; entry `0011` must revert cleanly in newest-first order with `Current` fences that occur exactly once.
  4. No structural enforcement (medium): with D10, a plan that omits `[phase-gate]` tasks is not blocked by a hook; Codex has no planner hook in any case.
  5. Seven-stage narrowing (medium): moving stage 7 to CI changes a policy rule.
  6. G13 size budget (medium): gate tasks consume the 20-task guideline.
  7. Mirror drift (medium): many bundle copies and generated Codex variants could diverge from their sources.
  8. Reviewer misreading (low): review checklists ask whether the full toolchain loop ran; task checks could be read as a skipped loop.
  9. Destination lag (low): destinations and MCP-resolved prompts change only after an extension release and push-down.
- Mitigations and rollbacks:
  1. "Task check" vocabulary (D2); the #1094 tokens stay unchanged; AC2 verifies.
  2. Keep the pinned sentence and add a separate sentence that frames task-check records as task-check evidence, never gate or coverage evidence (D9, AC8).
  3. Exact `Current`/`Prior` blocks per non-identical source and the ledger chain tests run inside the Pester gate before push (D12, AC12).
  4. Canonical text, planner guidance, templates, and the new sweep test carry the requirement; the reviewer checks phase-gate evidence.
  5. Owner instruction recorded (D6, D13) and ledger entry `0011`.
  6. Planners merge phases or add a `## Size Justification`.
  7. One copy task per family, generator `--check`, push-down resource contracts, brief byte-identity test, and the new byte-identity rows.
  8. The canonical section states the loop runs at every phase gate and in the final QA loop; self-review cites phase-gate and final-QA artifacts.
  9. The PR body states the downstream impact.
  Rollback: revert via ledger entry `0011`, then re-copy bundles and regenerate Codex variants.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; destinations receive the change after an extension rebuild, reinstall, and push-down. The PR body states this downstream impact.
- Post-fix monitoring or clean-up tasks: confirm with the owner where the downstream single-suite convention lives (D14); observe per-task time in the next large downstream orchestration.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/1167; research `research/research.2026-11-12T00-42.md`; process-reduction ledger `docs/engineering/process-reductions/README.md`; downstream iar-migration issue #145.
