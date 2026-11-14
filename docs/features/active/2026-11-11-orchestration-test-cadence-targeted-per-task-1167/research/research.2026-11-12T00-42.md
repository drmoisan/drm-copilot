# Research: Orchestration Test Cadence, Targeted per Task and Full per Phase (Issue #1167)

- Issue: #1167
- Branch: bug/orchestration-test-cadence-targeted-per-task-1167
- Feature folder: `docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/`
- Owner rule (verbatim): "The rule for an orchestration is a full test after every phase and only targeted tests after every task"
- Method: Read, Grep, and Glob over the item worktree. No command was run; every quoted sentence was read from the tree. The filename stamp was not read from a clock (the researcher has no Bash route); the orchestrator should confirm or rename it.

## Executive Summary

1. The per-task full-suite reading comes from a small number of explicit sentences (orchestrate R3, the Copilot language executors' "Required toolchain for <language> tasks", the atomic-executor `## Toolchain Commands` loop sentence, and the Copilot executor's "Toolchain loop ... repeat until clean") plus the unscoped "Mandatory Toolchain Loop" policy text that every agent reads. No surface defines a phase gate today.
2. The repository already implements the owner's cadence in code: the Python atomic executor CLI (`scripts/dev_tools/atomic_executor/qc_runner.py`, class `QCRunner`) documents `run_scoped()` "After each task" and `run_full()` "After each phase" (phase gate). The agent-facing text diverged from that implementation.
3. The largest risk is a direct conflict with issue #1094 (process-reduction entry `0001`): `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` sweeps every skill, agent, prompt, and template for the tokens `targeted tests`, `targeted Pester`, `targeted Pytest`, and `run tests after each` (and the QA-gate rows forbid `Targeted runs are allowed`). Canonical cadence wording that uses the owner's word "targeted tests" fails that sweep. The brief also pins "A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence" (`test_brief_test_isolation_states_parallel_gates`).
4. The change is a gate reduction under `docs/engineering/process-reductions/README.md` (the folder exists in the worktree with entries 0001 to 0010), so it needs ledger entry `0011` in the same commit, with revert blocks or a stored patch for every non-identical source file.
5. No plan validator (Python `scripts/dev_tools/validate_orchestration_artifacts.py` and `plan_gate_*.py`, TypeScript `extensions/drm-copilot/src/lib/validate/`, PowerShell `.claude/lib/`) requires a full-suite command per task or rejects a targeted per-task command. The only plan-structure check that reads test wording is `.claude/hooks/validate-planner-output.ps1` (final phase must contain QA or toolchain work). No surface is hash-frozen by `PINNED_FROZEN_SURFACE_HASHES`.
6. The "single-suite pseudo-queue rule" does not exist in this repository under that name or any synonym found (see `### 8`). The only queue-like mechanism is the per-workspace executor lock of the Python CLI (`.agent_logs/executor.lock`).

## 1. Current State: Every Cadence Statement

Classification key: **PT** = per-task prescription (states or implies the full loop or full suite after each task); **AMB** = unscoped loop statement (no cadence stated; read as per change, therefore per task by an executor); **PG** = phase-gate statement; **FQ** = final-QA statement; **REF** = refers to the contract only.

### 1.1 Claude surfaces (`.claude/`)

| Path | Heading / symbol | Quoted sentence | Class |
|---|---|---|---|
| `.claude/skills/orchestrate/SKILL.md` | `## Remediation Loop (R1–R5)`, bullet R3 | "Delegate to `atomic-executor` with full execution authorization. Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping." | PT |
| `.claude/skills/orchestrate/SKILL.md` | `## Delegation Model` | "`atomic-executor` — executes approved plans task-by-task" | REF (no cadence; the natural place for the delegation reference) |
| `.claude/skills/orchestrate/SKILL.md` | `## Completion Requirements` item 2; `## PR Creation Gate` condition 3 | "All validation gates (toolchain, acceptance criteria, audit artifacts) have passed." / "The mandatory toolchain passed in its most recent run on the branch" | FQ (unchanged) |
| `.claude/rules/general-code-change.md` | `## Mandatory Toolchain Loop` | "Run the full seven-stage toolchain in this exact order and repeat until all stages pass in a single pass:" ... "**Restart from step 1** if any stage fails or auto-fixes any files. Do not stop the loop until all seven stages complete without errors in a single pass." | AMB (the owner's named source) |
| `.claude/rules/python.md` | `## Toolchain` | "Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files. Do not stop the loop until all four steps complete without errors in a single pass." | AMB |
| `.claude/rules/powershell.md` | `## Toolchain` | "Run the toolchain in order: format → analyze → test. Restart from step 1 if any step fails or changes files." | AMB |
| `.claude/rules/typescript.md` | `## Toolchain` | "Run the toolchain in order: format → lint → type-check → test. Restart from step 1 if any step fails or changes files." | AMB |
| `.claude/rules/csharp.md` | `## Toolchain` | "Run the toolchain in order: format → lint → type-check → architecture → test. Restart from step 1 if any step fails or changes files." | AMB |
| `.claude/rules/shell.md` | toolchain paragraph | "Run the toolchain in this order and restart from step 1 if any step fails or rewrites files:" | AMB |
| `.claude/agents/atomic-executor.md` | `## Execution Protocol` step 4 | "**Verify**: Explicitly verify acceptance criteria. If the repo policy requires a toolchain loop, run it." | PT (inside the per-task protocol) |
| `.claude/agents/atomic-executor.md` | `## Toolchain Commands` | "Run toolchain in order: format, lint, type-check, test. Restart from step 1 if any step fails or changes files." followed by "The Phase 0 baseline and the final gate are each one run of these gates" | AMB / FQ |
| `.claude/agents/atomic-planner.md` | `## Plan Structure` | "Final phase: full QA loop for each applicable language, with one final-QC static artifact per language ..." | FQ (no phase-gate guidance) |
| `.claude/skills/atomic-plan-contract/SKILL.md` | `## Final QA Loop (Required for Code/Test Changes)` | "Run the full toolchain loop for each applicable language in order: ... If any step fails or changes files, restart the loop from step 1 until a clean pass completes." | FQ |
| `.claude/skills/atomic-plan-contract/SKILL.md` | `## Short-Path Minimal Plan Contract`, block 3 | "full language-appropriate QA loop (format → lint → type-check when applicable → test)" | FQ |
| `.claude/skills/atomic-plan-contract/SKILL.md` | `## Design-Level Plan Contract (Mandatory)`, `**Pre-Mortem.**` bullet | "The `Test isolation` bullet names the parallel gates the plan uses: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix." | gate definition (no cadence) |
| `.claude/skills/python-qa-gate/SKILL.md` (and `powershell-qa-gate`, `csharp-qa-gate`) | `## When to Use This Skill`; `## Toolchain Execution Sequence` | "An executor has finished applying a planned batch and must verify zero regressions in the single gate run ..." / "Run the full toolchain in this exact order. If any step fails or modifies files, fix the issue and restart from step 1." | FQ (the "planned batch" bullet is ambiguous) |
| `.claude/agents/python-typed-engineer.md` (and `powershell-`, `csharp-typed-engineer.md`) | workflow step 4 | "After each batch, run targeted Ruff and Pyright on touched files. Test and coverage results come from the single gate run. A focused run of one test file to debug a specific failure is debugging only." | per-batch static only; no tests per batch (consistent with the new cadence for static checks; diverges on tests) |
| `.claude/skills/execution-environment/SKILL.md` (six copies) | `## Test Runtime`, pytest bullet | "pass `-n auto` ... of the full-suite pytest commands of the atomic executor tool (its preflight QC, its full QC loop, and the commands its prompts state)" | refers to the Python CLI's phase-gate loop; wording "full QC loop" |
| same | `## Test Isolation Checks` | "The test gates are parallel: ... Each gate reaches zero failures and is re-run only after a fix. A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence. Serial tasks remain for debugging one failure and are not gates. ... The parallel gates govern where a policy file names a toolchain test command." | gate definition; conflicts with recording per-task test runs as evidence unless reworded |
| `.claude/hooks/validate-planner-output.ps1` | `Get-PlanStructureValidationReport` | error "The final phase must contain explicit QA or toolchain validation work." | FQ enforcement (keyword match on the final phase only) |
| `.claude/hooks/validate-executor-output.ps1` | completion branch | "completion output is missing explicit PASS/FAIL toolchain status lines for: ..." | per-language status at completion (no cadence) |

### 1.2 Copilot surfaces (`.github/`)

| Path | Heading / symbol | Quoted sentence | Class |
|---|---|---|---|
| `.github/instructions/general-code-change.instructions.md` | `## Bugfix Workflow`, step 3 | "Run the full toolchain in order (format → lint → type-check → test) using the repo-standard commands or tasks; rerun from the start if any step changes files or fails." | AMB |
| same | `## 8. After Making Changes`, `### 1. Run the full toolchain (no shortcuts)` | "You **must** run the full toolchain in this exact order and repeat it until everything passes: ... Only when **all four steps complete without errors in a single pass** are you allowed to consider the change complete." | AMB (the Copilot equivalent of the Mandatory Toolchain Loop; four steps, not seven) |
| `.github/instructions/typescript-code-change.instructions.md` | note | "The general code change policy requires the full toolchain loop: formatting → linting → type checking → testing." | REF (defers to general) |
| `.github/instructions/python-unit-test.instructions.md` | `## 4. Respecting the Toolchain Loop` | "When running the “After Making Changes” toolchain loop from the general code change policy on Python work, your **testing step** must be performed with **Pytest**." | REF |
| `.github/instructions/csharp-unit-test.instructions.md` | toolchain bullets | "The loop behavior (restart rules, must-pass requirements, and audit expectations) is defined by `general-code-change.instructions.md` and is intentionally not repeated here." | REF |
| `.github/instructions/powershell-code-change.instructions.md` | toolchain list | "When PowerShell code changes, your toolchain loop must include:" | REF (content, not cadence) |
| `.github/agents/atomic_executor.agent.md` | `## 0.` "Enforce implications" | "Toolchain loop: format → lint → type-check → test; repeat until clean." | AMB |
| same | `### 3.4 Verification (mandatory before check-off)` | "If the repo policy requires a toolchain loop, run it at the appropriate points (or per plan)." | AMB inside the per-task loop |
| same | `### 2.2 Validate plan format` | "For plans that change code or tests: a final QA phase exists that runs the full toolchain loop **for each applicable language** and reports results." | FQ |
| `.github/agents/python-atomic-executor.agent.md` (and `powershell-`, `csharp-atomic-executor.agent.md`) | `### 7.1 Python policy and toolchain gates` | "Required toolchain for Python tasks: ... 4) Test (`poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`) ... If any step fails in final QA, fix and restart from format." | PT (full suite with coverage per task) |
| same | section 0, 2.2, 3.4 | identical to `atomic_executor.agent.md` sentences above | AMB / FQ |
| `.github/agents/atomic_planning.agent.md` (and `python-`, `powershell-`, `csharp-atomic-planning.agent.md`) | core rules; checklist | "If the plan changes code or tests, it MUST include a final **QA phase** that runs the full toolchain loop and reports results." / "Did you include a final QA phase that runs the toolchain loop **for each applicable language** and reports results?" | FQ (no phase-gate guidance) |
| `.github/prompts/execute-hard-lock.prompt.md` | `PREFLIGHT VALIDATION GATE`; `EXECUTION LOOP` step 5 | "A final QA phase exists with full toolchain loops per touched language" / "For EACH task: ... 5) Run required toolchains as specified or implied" | FQ / AMB per task |
| `.github/codex/execute-hard-lock.prompt.md` | same | same two sentences | FQ / AMB |
| `.github/codex/resume-hard-lock.prompt.md` | execution step 4 | "Run required toolchains as specified or implied." | AMB per task |
| `.github/skills/atomic-plan-contract/SKILL.md` | `## Final QA Loop` | same text as the Claude copy | FQ |
| `.github/agents/python-typed-engineer.agent.md`, `python-execution-only-typed.agent.md`, `powershell-typed-engineer.agent.md`, `csharp-typed-engineer.agent.md`, `pytest-unit-test-coding.agent.md`, `Powershell DI Unit Test Engineer.agent.md`, `commentary-remediation.agent.md` | handoff prompts and workflow | for example "Run static checks after each batch; run the full toolchain, with one pytest -n auto run, at the end." | per-batch static, full at end (consistent) |
| `.github/agents/5.1-Beast-adjusted.agent.md`, `5.1-Thinking-Beast-Mode-adjusted.agent.md` | rules | "**Toolchain loop**: Run formatting → linting → type-check → testing, and repeat until a full clean pass." | AMB (not orchestration agents; out of scope unless the sweep covers them) |

### 1.3 Codex surfaces (`.codex/`, `.agents/`, `AGENTS.md`)

| Path | Heading / symbol | Quoted sentence | Class |
|---|---|---|---|
| `.agents/skills/orchestrate/SKILL.md` | R3 | identical R3 sentence | PT |
| `.agents/skills/general-code-change/SKILL.md` | `## Mandatory Toolchain Loop` | identical seven-stage text | AMB |
| `AGENTS.md` | `## Mandatory Toolchain Loop` | "Run the full toolchain in this exact order and repeat until all steps pass in a single pass: 1. **Formatting** ... 4. **Testing** ... **Restart from step 1** if any step fails or auto-fixes any files. Do not stop the loop until all four steps complete without errors in a single pass." | AMB (four steps; diverges from the seven-stage rule) |
| `.agents/skills/{python,powershell,typescript,csharp}/SKILL.md` | toolchain | identical to the Claude language rules | AMB |
| `.agents/skills/{python,powershell,csharp}-qa-gate/SKILL.md` | toolchain sequence | identical to the Claude QA gates | FQ |
| `.agents/skills/atomic-plan-contract/SKILL.md` | `## Final QA Loop` | same text | FQ |
| `.agents/skills/atomic-planner/SKILL.md` | requirements list | "final QA requirements," | FQ |
| `.agents/skills/atomic-executor/SKILL.md` | procedure | "Validate the plan format and Phase 0 / QA requirements using `atomic-plan-contract`." / "Verify the task acceptance criteria before marking it complete." | REF |
| `.codex/agents/atomic-executor.toml` | `Execution Protocol`, `Toolchain Commands` | "If the repo policy requires a toolchain loop, run it." / "Run toolchain in order: format, lint, type-check, test. Restart from step 1 if any step fails or changes files." | PT / AMB |
| `.codex/agents/atomic-planner.toml` | plan structure | "Final phase: full QA loop for each applicable language, ..." | FQ |
| `.codex/agents/{python,powershell,csharp}-typed-engineer.toml` | step 5 | "**Final QA gate** — apply `python-qa-gate` to run the full toolchain ..." | FQ |

### 1.4 Templates and push-down bundle

| Path | Quoted sentence | Class |
|---|---|---|
| `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` | "`[P4-T2]` Run formatter → linter → type checker → tests; restart loop if any step changes files or fails" | PG/FQ (single verification phase) |
| `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` | "**Self-Validating Phases:** Include necessary test creation/update tasks *within* the phase that implements the code. Do not defer verification to a final "Testing" phase." | neutral; natural place for a phase-gate placeholder task |
| `docs/features/templates/{bug,feature,refactor}/spec.md` | "Toolchain commands to run (format → lint → type-check → test):" / "Full toolchain pass completed" | FQ (no change needed) |
| `extensions/drm-copilot/src/lib/resolve/file-prompt-transforms.ts` (`applyMinorAuditOverrides`) | "Phase 2 — Final QC loop" | FQ (minor-audit three-phase layout; unaffected when Phase 1 needs no gate) |
| Every file above under `extensions/drm-copilot/resources/` | bundle copies (see the mirror-family table) | same class as source |

`packages/` holds no toolchain or cadence wording (searched; zero hits). The MCP prompt resolver `extensions/drm-copilot/src/lib/resolve/hard-lock-prompt.ts` reads `execute-hard-lock.prompt.md` or `resume-hard-lock.prompt.md` from the installed bundle, so the bundle copies are the runtime source for MCP-resolved prompts.

## 2. Mirror Families

"Byte-identical" means asserted by a test listed in the last column; "non-identical" means each copy is a source in its own right (process-reduction README: "A copy whose text differs from its source is a source in its own right").

| Family | Copies | Identity | Pinning tests |
|---|---|---|---|
| F1 atomic-plan-contract | `.claude/skills/atomic-plan-contract/SKILL.md`; `.agents/skills/...`; `.github/skills/...`; bundles `claude-customizations/.claude/skills/...`, `codex-and-agents-customizations/.agents/skills/...`, `customizations/.github/skills/...` | Each base equals its own bundle. The three bases differ from one another (the `## Final QA Loop` heading sits at different offsets; ledger `0001` lists the `.agents` copy as "a non-identical copy with its own revert block"). | `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_copilot_bundle_copies_match_canonical` (Copilot base list includes `.github/skills/atomic-plan-contract/SKILL.md`); wording: `planning-contract-wording.Tests.ps1` (`$script:ContractCopy`), `parallel-gate-wording.Tests.ps1` (`PLAN-*` rows), `test_single_pass_preflight_contracts.py` (`_CONTRACT_COPIES`) |
| F2 execution-environment brief | six copies (`.claude`, `.agents`, `.github`, three bundles) | All six byte-identical | `test_brief_copies_are_byte_identical`, `test_brief_test_isolation_states_parallel_gates`, `test_brief_test_runtime_section_orders_diagnosis_before_parallelism`, `test_brief_passages_state_parallel_gate_facts`, `PCW-BRIEF-*` rows |
| F3 orchestrate skill | `.claude/skills/orchestrate/SKILL.md` + Claude bundle; `.agents/skills/orchestrate/SKILL.md` + Codex bundle | Each base equals its bundle; `.claude` and `.agents` differ (R3 sits in different regions). No `.github` copy carries R3. | push-down resource contracts; `test_single_pass_preflight_contracts.py` (`_REMEDIATION_SURFACES`), `concurrent-review-skill-contract.Tests.ps1`, `light-remediation-skill-contract.Tests.ps1` |
| F4 general code-change policy | `.claude/rules/general-code-change.md` + bundle `claude-customizations/.claude/rules/`; `.agents/skills/general-code-change/SKILL.md` + Codex bundle; `AGENTS.md` + bundle `codex-and-agents-customizations/AGENTS.md`; `.github/instructions/general-code-change.instructions.md` + bundle `customizations/.github/instructions/` | Each base equals its bundle where a push-down test covers it. The `.claude` rule (seven stages), `AGENTS.md` (four steps), and `.github` instruction (four steps, different prose) are three different texts. No test was found that asserts the `.github/instructions/` bundle copy equals its base (the two copies carry the matched sentences at the same line positions, so they appear identical; unverified). | `test_typescript_toolchain_instruction_contracts.py` (Vitest bans only), `test_push_down_tier_rule_adoption_gate.py` (`## Module Rigor Tiers`, `## Test Categories` sections), `test_claude_rules_frontmatter.py` |
| F5 language rules | `.claude/rules/{python,powershell,typescript,csharp,shell}.md` + bundles; `.agents/skills/{python,powershell,typescript,csharp}/SKILL.md` + bundles; bundle-only variants `.claude-variants/csharp-legacy/...`, `.agents-variants/csharp-legacy/skills/csharp/` | base equals bundle | push-down contracts; `test_typescript_toolchain_instruction_contracts.py` requires exactly one `**Testing` line in `typescript.md` naming `npm run test:unit` |
| F6 atomic executor | `.claude/agents/atomic-executor.md` + bundle; `.codex/agents/atomic-executor.toml` (hand-edited base) with generated `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` and bundle copies; `.agents/skills/atomic-executor/SKILL.md` + bundle; `.github/agents/atomic_executor.agent.md`, `python-`, `powershell-`, `csharp-atomic-executor.agent.md` + bundles | Claude base = bundle; Codex variants generated; Copilot base = bundle | `parallel-gate-wording.Tests.ps1` (`EXEC-*`, `COPILOT-*EXEC*`), `planning-contract-wording.Tests.ps1` (`PCW-DESIGN-CHECK-EXEC-*`), `test_single_pass_preflight_contracts.py`, generator `--check`, `test_codex_agent_wrapper_contracts.py`, `test_typescript_toolchain_instruction_contracts.py` (`.claude/agents/atomic-executor.md` in its mirror list) |
| F7 atomic planner | `.claude/agents/atomic-planner.md` + bundle; `.codex/agents/atomic-planner.toml` + generated variants; `.agents/skills/atomic-planner/SKILL.md`; `.github/agents/atomic_planning.agent.md` and three language planners + bundles | as F6 | `PCW-SIZE-AGENT-*`, `PGW` `COPILOT-*PLANNING*`, generator `--check` |
| F8 hard-lock prompts | `.github/prompts/execute-hard-lock.prompt.md`, `.github/codex/execute-hard-lock.prompt.md`, `.github/codex/resume-hard-lock.prompt.md` + bundles under `customizations/.github/` | base equals bundle (not in `test_copilot_bundle_copies_match_canonical`'s list; no other parity test found) | `PCW-SURFACE-HARD-LOCK-*` (forbidden policy-read tokens only) |
| F9 QA-gate skills | `.claude/skills/{python,powershell,csharp}-qa-gate` + bundles; `.agents/...` + bundles; csharp-legacy variants | base equals bundle | `parallel-gate-wording.Tests.ps1` `QA-*` rows (require `debugging only`, forbid `Targeted runs are allowed`) |
| F10 planner hook | `.claude/hooks/validate-planner-output.ps1` + bundle `claude-customizations/.claude/hooks/` | byte-identical (ledger `0005` records the bundle as "a byte-identical bundle copy") | push-down contracts, `validate-planner-output*.Tests.ps1`, `ProcessReductionLedger.Replay.Tests.ps1` |
| F11 plan templates | `docs/features/templates/{bug,feature,refactor}/plan.yyyy-MM-ddTHH-mm.md` + `extensions/drm-copilot/resources/feature-templates/...` | byte-identical | `test_plan_templates_carry_premortem_skeleton` |

Generated vs hand-edited (research item 5): `scripts/dev_tools/generate_codex_agent_variants.py` reads each base `.codex/agents/<family>.toml` (`expected_variant_files`, `_synchronize`), rewrites the base as the C3 alias, and writes the `-c1` to `-c4` and `-c3-elevated` variants plus every bundle copy under `codex-and-agents-customizations/.codex/agents/`. The plan edits only `.codex/agents/atomic-executor.toml` and `.codex/agents/atomic-planner.toml` (and typed-engineer bases if in scope) and regenerates; the batch-budget hooks do not see generator writes. Every `.claude`, `.agents`, and `.github` bundle copy is a hand copy.

## 3. Contract Tests and How to Extend Them

| Test | Structure | Relevance |
|---|---|---|
| `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` (257 lines) | `PGW-<Id>` rows: `Path`, `Required`, `Forbidden` token arrays, whitespace-collapsed, forbidden matched case-insensitively. `Context 'Class sweep'`: `$script:SweepToken` (12 tokens) over `$script:SweepRoot` folders (`.md` and `.toml`), with `$script:SweepExclusion` path segments; `PGW-SWEEP-HELPER` pins the token count with `Should -Be 12`. | **Conflict.** Sweep tokens include `targeted tests`, `targeted Pester`, `targeted Pytest`, `run tests after each`. Rules, `.github/instructions/`, and the `.agents` language skills are excluded segments, so the conflict hits the contract, agents, prompts, and templates only. |
| `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1` (329 lines) | `BeforeDiscovery` arrays (`$script:ContractCopy` six copies, `$briefCopy`, `$script:PlannerAgent`, executor rows); helpers `Get-PcwSurfaceText` and `Get-PcwSectionText -Heading -Level` | Natural home for a section-scoped canonical-wording row, but it is ledger-touched by `0002`, `0003`, `0004`, `0005`, `0008`; a new file avoids editing recorded regions. |
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | `_BRIEF_COPIES` byte identity; `_section()` token checks | Pins `debugging only`, `never a gate or evidence`, `parallel gates govern` in `## Test Isolation Checks`; any brief edit must keep them and keep all six copies identical. Extending it adds Python test code; prefer a Pester row. |
| `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | tuples of surfaces; `test_contract_premortem_test_isolation_states_parallel_gates` requires "one `Invoke-PoshQCParallelTest` run", "one `pytest -n auto` run", "Jest through its normal parallel workers", "re-run only after a fix" in all six contract copies; `test_copilot_bundle_copies_match_canonical` byte-compares a fixed Copilot list | Keep the Pre-Mortem `Test isolation` tokens; add any newly edited Copilot file to a byte-identity check (new Pester file preferred). |
| `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` | every distributable `.claude`, `.agents`, `.codex` file equals its bundle copy | Every edit is followed by a bundle re-copy. |
| `test_push_down_*_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` | manifested files and `$PSScriptRoot` dependencies | Triggered only if a new hook helper file is added (it must be manifested in core plus the owning pack). |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | guarded dot-source pattern | Triggered by a new dot-sourced hook helper. |
| `generate_codex_agent_variants.py --check` | variant equality | Run after editing a Codex base agent. |
| `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionLedger*.Tests.ps1` | in-memory newest-first revert of all entries | Entry `0011` must revert cleanly; its `Current` fences must occur exactly once in the target files. |
| `tests/scripts/dev-tools/ProcessReductionLedger.Replay.Tests.ps1` | extracts exactly `Get-PlanStructureValidationReport` and `Test-TaskContainsExplicitPath` from the live and reverted planner hook text and runs them in a child scope | **Trap.** A new rule that calls a new helper from inside `Get-PlanStructureValidationReport` makes the replay throw ("Expected 2 function definitions" passes, but the call fails at run time). Put any new rule in a separate function called from `Get-PlannerOutputBlockDecision`, or inline it without helper calls. |
| `validate-planner-output.Tests.ps1`, `.Coverage`, `.PreMortem`, `.Reentry`, `.TargetWorktree` | in-memory plan fixtures | A new per-phase rule fails every fixture plan that has an intermediate phase without a gate task; each affected test must be named in the plan with its disposition. |
| `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | two pinned files: `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md` | Neither carries cadence wording (searched: zero hits for toolchain, full suite, each task, per task, test gate). No hash update is needed. |

## 4. Plan Validators and Hooks (research item 4)

- Python: `validate_plan_text_with_warnings` = `_plan_structure_errors` (phase heading, task-line shape, numbering) + `evaluate_plan_gates` (G1 to G13). No rule names a test command per task. `plan_gate_commands.py` extracts commands for G1 to G9 only; a targeted `pytest <file>` span is admitted like any other span. G9 (Warning) reports a `--cov` command with no terminal reporter; a targeted per-task command that carries no `--cov` is not affected.
- TypeScript: `extensions/drm-copilot/src/lib/validate/` has no toolchain or QA wording except `policy-audit-artifact.ts` (review artifacts, not plans).
- PowerShell `.claude/lib/`: zero hits.
- Hooks: `validate-planner-output.ps1` checks that the final phase text matches `(?i)(qa|quality|toolchain|format|lint|type|test|coverage)` and that Phase 0 has a baseline task; `premortem-section.ps1` checks the seven labels exist (it does not read their content). `validate-executor-output.ps1` requires per-language PASS/FAIL toolchain lines at completion. None requires a full-suite command per task. Codex has no planner hook (`.codex/` has no Pre-Mortem or final-phase check), so any new structural rule is Claude-only.
- Python atomic executor CLI (`scripts/dev_tools/atomic_executor/`): `cli_execute_one_task.py` calls `qc_runner.run_scoped(...)` per task; `plan_parser.py` "Determine when to trigger full QC (phase gate)"; `cli.py` calls `qc_runner.run_full(...)`. `run_scoped` runs Black, Ruff, Pyright on changed `.py` files and pytest only on changed test files (it does not add mirrored tests of changed modules or importers). No change is required for this issue; the plan should cite it as the existing precedent and leave it unchanged (avoid new Python).

## 5. Candidate Approaches

### Recommended: one canonical section in `atomic-plan-contract`, references everywhere else, Claude hook enforcement with a task tag

- Add `## Test Cadence (Mandatory)` to all three `atomic-plan-contract` bases (and their bundles), placed immediately before `## Final QA Loop (Required for Code/Test Changes)`. It defines three checkpoints:
  1. **Task check** (after each task): format, lint, and type check scoped to the changed files; then the task's test selection, which is the mirrored test files under `tests/` of each changed production file, plus every test file that imports, dot-sources, or names the changed module or file (for a Markdown or configuration change, the contract tests that read that path). The task's evidence records the changed files, the selection and the rule that produced it, each command, and its exit code. A task check is not a gate and does not measure coverage.
  2. **Phase gate** (the last task of every phase between Phase 0 and the final QA phase, tagged `[phase-gate]`): stages 1 to 6 of the toolchain loop in `.claude/rules/general-code-change.md` across the repository, with the test stage as one run of each parallel gate (`Invoke-PoshQCParallelTest`, `pytest -n auto`, Jest through its normal parallel workers); restart from step 1 on a failure or an auto-fix; zero failures. Coverage is read at the final QA loop, not at a phase gate.
  3. **Final QA loop**: unchanged (existing section; coverage against the `Phase 0 baseline`; no-SKIPPED rule unchanged).
  Integration and golden suites run in CI only.
- Every other surface carries one reference sentence instead of a restatement (`### 7` below).
- Enforcement: a new rule in the Claude planner SubagentStop hook, in a new dot-sourced helper (for example `.claude/hooks/planner-phase-gate.ps1`), called from `Get-PlannerOutputBlockDecision`, not from `Get-PlanStructureValidationReport`: for every phase `P` with `1 <= P <= max - 2` (the phase before the final QA phase is gated by the final QA loop, which avoids two back-to-back full runs), the last task line carries `[phase-gate]` after its task ID. The tag is statically decidable, unlike a keyword heuristic, and follows the `[expect-fail]` precedent (`EXPECT_FAIL_TAG` in `plan_parser.py`). A three-phase plan (minor-audit layout, `applyMinorAuditOverrides`) needs no gate task.
- Rationale: it matches the owner's "defined once" requirement, reuses the existing tag convention, keeps the Python and TypeScript validators unchanged (no new Python, no MCP release lag), and leaves the existing replay test working.

### Rejected alternatives

- **Canonical text in `.claude/rules/general-code-change.md`.** The rule loads for every code edit, including direct-mode typed engineers outside orchestration, and has four non-identical counterparts (`.agents` skill, `AGENTS.md`, `.github` instruction); placing the plan-execution cadence there spreads it across four sources. The rule instead states that the loop is the phase-gate and final-QA requirement and references the contract.
- **A new validator rule G14 in Python and TypeScript.** Requires new Python code, a TypeScript parity port, a parity test, and a corpus measurement under the `.claude/rules/plan-acceptance-gates.md` severity rules, and it reaches MCP only after an extension release. The hook route gives the same signal for Claude plans now.
- **Keyword detection of a gate task** (for example "full toolchain" in the last task). Not statically reliable; the G7 to G9 measurements show the false-positive cost of prose heuristics.

## 6. Behavior Semantics and Requirements Mapping

- Success: a plan whose intermediate phases end with a `[phase-gate]` task passes the planner hook; an executor runs the task check after each task and the full loop only at `[phase-gate]` tasks and the final QA loop.
- Failure: a missing tag on an intermediate phase's last task blocks the planner stop (repairable), naming the phase.
- Ordering: task check after the task's edits and before check-off; phase gate after every other task of the phase; a phase-gate failure is fixed inside the gate task (the executor does not block after execution starts) and the loop restarts from step 1.
- Edge cases: an `[expect-fail]` task's task check expects its named test to fail and keeps format, lint, and type checks as pass/fail; a phase that changes no code still ends with its gate task (the planner merges such a phase into a neighbor if the gate is not wanted); remediation plans are written by `atomic-planner` and fall under the same hook; light remediation cycles have no plan and run only the final QA obligations stated by the orchestrate skill.
- Design decision to record in the spec: the seven-stage loop's stage 7 (integration tests) moves to CI for phase gates and the final QA loop, per the owner's "Integration and golden suites stay CI-only". This narrows `## Mandatory Toolchain Loop` and must be in ledger entry `0011`.
- Evidence decision to record in the spec: the brief sentence "A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence" stays (it is pinned and governs debugging runs). The brief gains one sentence that a task check's selection and results are recorded in the task's evidence as a task check, never as a gate result and never as coverage evidence. Recommended artifact: one `<FEATURE>/evidence/qa-gates/task-checks.<timestamp>.md` per phase with one entry per task, written append-only, and one `phase-<N>-gate.<timestamp>.md` per gate.

### File change inventory (sources; each also needs its bundle copy)

1. `atomic-plan-contract` bases (three): new `## Test Cadence (Mandatory)`; `## Final QA Loop` and `## Short-Path Minimal Plan Contract` reference it; Pre-Mortem `Test isolation` bullet keeps its pinned tokens.
2. `.claude/skills/orchestrate/SKILL.md` and `.agents/skills/orchestrate/SKILL.md`: R3 sentence replaced by the reference sentence; one reference in `## Delegation Model` for the `atomic-executor` line.
3. `.claude/rules/general-code-change.md`, `.agents/skills/general-code-change/SKILL.md`, `AGENTS.md`, `.github/instructions/general-code-change.instructions.md` (both sections that state the loop): the loop is the phase-gate and final-QA requirement; per-task checks follow the contract; "Restart from step 1" kept.
4. Language rules (five `.claude/rules` files, four `.agents` skills): one reference sentence after each "Run the toolchain in order" sentence. `typescript.md` must keep exactly one `**Testing` line.
5. `.claude/agents/atomic-executor.md`, `.codex/agents/atomic-executor.toml` (then regenerate), `.agents/skills/atomic-executor/SKILL.md`, four Copilot executors: `Execution Protocol` step 4 and `## Toolchain Commands` reference the cadence; the Copilot language executors' "Required toolchain for <language> tasks" becomes the phase-gate and final-QA toolchain.
6. `.claude/agents/atomic-planner.md`, `.codex/agents/atomic-planner.toml`, `.agents/skills/atomic-planner/SKILL.md`, four Copilot planners: `## Plan Structure` adds the `[phase-gate]` task for intermediate phases.
7. Hard-lock prompts (three): execution-loop step 5 references task checks; preflight list adds the phase-gate tags.
8. QA-gate skills (three per surface, plus csharp-legacy variants if the C# gate is edited): the "planned batch" bullet becomes "a phase gate or the final QA loop". Optional; the gate procedure itself is unchanged.
9. Brief (six byte-identical copies): `## Test Isolation Checks` gains the task-check sentence; `## Test Runtime` pytest bullet "its full QC loop" may read "its phase-gate QC loop"; `## Contract Tests That Pin Mirrored Files` names the new Pester file; a targeted Pester route (for example a `sh`-launched `Invoke-Pester -Path <files>` with `Run.Exit`) is stated in `## PowerShell Route and PoshQC MCP Limits`, because the brief owns tool routes.
10. Plan templates (three bases plus bundles): an intermediate phase shows a `[phase-gate]` task.
11. `.claude/hooks/validate-planner-output.ps1` + bundle, plus the new helper + bundle, pack manifests.
12. Tests: new `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`; new or extended planner-hook Pester cases; fixture updates in existing `validate-planner-output*.Tests.ps1`.
13. `docs/engineering/process-reductions/0011-<short-name>.md` + index row in `README.md` (+ a stored patch if blocks are impractical).

## 7. Canonical Location and Reference Sentence (research item 7)

- Location: `.claude/skills/atomic-plan-contract/SKILL.md`, heading `## Test Cadence (Mandatory)`, before `## Final QA Loop (Required for Code/Test Changes)`; the same heading in the `.agents` and `.github` bases.
- Reference sentence for every other surface: "Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop."
- Wording constraint: neither the canonical section nor any reference may contain the sweep tokens `targeted tests`, `targeted Pester`, `targeted Pytest`, `run tests after each`, `relevant tests pass`, or `Targeted runs are allowed`, unless the plan changes the sweep. Recommended vocabulary: "task check" and "the task's test selection". Recommended: leave the twelve `#1094` sweep tokens unchanged (they still describe runs that replace a gate) and add a separate sweep for per-task full-suite prescriptions.

## 8. Single-Suite Pseudo-Queue Rule (research item 8)

- SearchScope: the item worktree excluding `docs/features/completed/` and `docs/features/archive/`, including `.claude/`, `.github/`, `.agents/`, `.codex/`, `scripts/`, `config/`, `extensions/`, `packages/`, and `tests/`.
- SearchPatterns: `single-suite`, `pseudo-queue`, `one suite at a time`, `suite lock`, `queued behind`, `mutex`, `run lock`, `test-run-lock`, `suite-lock`, `test.?lock`, `executor lock`, `same machine`, `one suite`.
- SearchResult: the phrase appears only in this item's `issue.md`, `spec.md`, and promoted lifecycle record. The only related mechanism is `acquire_executor_lock` in `scripts/dev_tools/atomic_executor/cli_workspace.py` (`EXECUTOR_LOCK_FILE = ".agent_logs/executor.lock"`), a per-workspace single-run lock of the Python CLI, which is not machine-wide.
- Conclusion: the rule is likely a downstream-repository convention (iar-migration) or an owner instruction outside this tree; this is unconfirmed. The plan should state that it does not add, remove, or edit any queue or lock mechanism, and the orchestrator may confirm the rule's location with the owner. The executor lock above must not be edited.

## 9. File-Size Headroom (research item 6)

- `config/file-size-baseline.json` lists no files (`"files": {}`), so no target is a legacy oversize file.
- Markdown is exempt from the size tiers; every skill, agent, rule, prompt, and template target is Markdown or TOML text (TOML is not production code; the generator writes the variants).
- Script and test targets (counted with a line-anchored Grep; physical counts may differ by one): `.claude/hooks/validate-planner-output.ps1` 470 (near the 500 guidance tier, so new logic goes to a new helper file); `.claude/hooks/premortem-section.ps1` 149; `.claude/hooks/validate-executor-output.ps1` 417; `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` 257; `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1` 329. A new Pester file keeps every existing test file well under 500.

## Numeric Derivation Evidence

The counts below are stated as facts for the planner; none is proposed as a `spec.md` acceptance criterion (the spec is Draft).

### Claim N1: the `atomic-plan-contract` skill has six copies

- Complete Family: every file named `SKILL.md` in a folder named `atomic-plan-contract` in the worktree.
- Exhaustive Search Scope: the whole item worktree.
- Inclusion Rules: path ends with `atomic-plan-contract/SKILL.md`.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `**/atomic-plan-contract/SKILL.md`.
- Primary Member Set: `.agents/skills/atomic-plan-contract/SKILL.md`; `.claude/skills/atomic-plan-contract/SKILL.md`; `.github/skills/atomic-plan-contract/SKILL.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`; `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: read `$script:ContractCopy` in `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`.
- Cross-check Member Set: CLAUDE, AGENTS, GITHUB, CLAUDE-BUNDLE, AGENTS-BUNDLE, GITHUB-BUNDLE, resolving to the same six paths.
- Cross-check Count: 6.
- Member-set Comparison: the normalized path sets are equal.

### Claim N2: the `#1094` class sweep holds twelve tokens

- Complete Family: the entries of `$script:SweepToken` in `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
- Exhaustive Search Scope: that file.
- Inclusion Rules: array members of `$script:SweepToken`.
- Exclusion Rules: tokens of the per-row `Forbidden` arrays.
- Primary Search Strategy or Query Expression: read the array literal.
- Primary Member Set: `targeted Pester`, `targeted Pytest`, `targeted xUnit`, `targeted MSTest`, `targeted tests`, `run tests after each`, `relevant tests using`, `running tests frequently`, `smallest applicable subset`, `relevant tests pass`, `repro and regression test`, `Run the regression to confirm`.
- Primary Count: 12.
- Cross-check Search Strategy or Query Expression: read the `PGW-SWEEP-HELPER` assertion `$tokens.Count | Should -Be 12`.
- Cross-check Member Set: the assertion iterates the same `$script:SweepToken` array.
- Cross-check Count: 12.
- Member-set Comparison: equal; the assertion pins the count, so adding a token requires changing that assertion.

## 10. Testing Implications

- New Pester 6 file `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` (read-only, whitespace-collapsed, modelled on `planning-contract-wording.Tests.ps1`):
  - `TCW-CANONICAL-<Copy>`: each of the six contract copies holds `## Test Cadence (Mandatory)` and the pinned phrases (task check, phase gate, `[phase-gate]`, restart from step 1, CI-only integration and golden suites), read with a section helper.
  - `TCW-REFERENCE-<Id>`: each referring surface holds the reference sentence's anchor token `## Test Cadence (Mandatory)` (a single-line, non-interpolated token).
  - `TCW-SWEEP-SURFACES`: no file under the same roots as the `#1094` sweep plus `.claude/rules`, `.agents/skills`, `.github/instructions`, `AGENTS.md`, and the bundles holds a per-task full-suite prescription token, for example `Each task's toolchain loop`, `Required toolchain for Python tasks`, `Required toolchain for PowerShell tasks`, `Required toolchain for C# tasks`; plus `TCW-SWEEP-HELPER` proving each token is detected in in-memory text, with the count pinned.
  - `TCW-BUNDLE-<Id>`: byte identity for edited Copilot files not in `test_copilot_bundle_copies_match_canonical` (the general-code-change instruction and the three hard-lock prompts).
- Planner-hook Pester cases for the `[phase-gate]` rule: positive (all intermediate phases tagged), negative (missing tag names the phase), boundary (two-phase and three-phase plans need no tag; four-phase plan needs it on Phase 1 only), tag not on the last task, remediation-plan shape. Existing fixtures in `validate-planner-output*.Tests.ps1` are updated where they hold four or more phases.
- Gates: Pester through one `Invoke-PoshQCParallelTest` run; pytest through one `pytest -n auto` run (contract tests in Python are re-run, not edited); the Codex generator `--check`; the ledger chain test.
- Coverage: the new hook helper is a production PowerShell file and needs at least 85% line coverage from the gate run; no Python or TypeScript production file changes.

## Risks

1. **Sweep conflict with `#1094` (high).** The owner's word "targeted" collides with the twelve sweep tokens and the QA-gate `Targeted runs are allowed` ban. Mitigation: "task check" vocabulary; leave the `#1094` tokens unchanged; record the decision in the spec.
2. **Brief evidence sentence (high).** "never a gate or evidence" is pinned; per-task evidence must be framed as task-check evidence. All six brief copies change together, and the brief's maintenance rule requires the same change to update it.
3. **Ledger chain (high).** Every target lies in regions recorded by `0001`, `0004`, `0005`, `0006`, or `0009`. Entry `0011` must carry exact `Current` and `Prior` text per non-identical source (the three contract bases, the two orchestrate bases, the four general-code-change texts, the planner hook, and others), or a stored patch checked by `git apply -R --check` after later entries revert. The chain test runs in the PowerShell shards on CI.
4. **Replay trap (medium).** `ProcessReductionLedger.Replay.Tests.ps1` extracts exactly two hook functions; keep new hook logic outside `Get-PlanStructureValidationReport`.
5. **Planner-hook fixture churn and isolated-subagent lag (medium).** Hooks of isolated subagents run `main`'s copies, so the new rule is proven only by Pester; existing fixtures with four or more phases fail until tagged.
6. **G13 size budget (medium).** Gate tasks consume the 20-task guideline; plans with many phases need a `## Size Justification` or fewer phases.
7. **Codex enforcement gap (low).** Codex has no planner hook; the cadence is policy text there.
8. **Seven-stage narrowing (medium).** Moving stage 7 to CI changes the policy rule; it needs owner confirmation in the spec and a ledger block.
9. **Copilot bundle parity unverified (low).** No test asserts the `.github/instructions/` and hard-lock prompt bundles equal their bases; the new Pester file closes that.
10. **Batch budget (low).** The two hook files plus bundle copies are four PowerShell production files; the orchestrated large path is exempt; generator and copy-script writes are not counted.
11. **Destination lag (low).** Destinations receive the text after an extension rebuild and push-down; MCP-resolved hard-lock prompts come from the installed bundle.

## Pre-Mortem

- Review checklists: the policy-audit and code-review templates ask whether the full toolchain loop ran; a reviewer could read the task checks as a skipped loop. Mitigation: the final self-review cites the phase-gate and final-QA artifacts, and the canonical section states that the loop runs at every phase gate and in the final QA loop.
- Coverage: the new hook helper is the only production script; it could fall below 85% line coverage. Mitigation: positive, negative, and boundary Pester cases for every branch, coverage read from the one `Invoke-PoshQCParallelTest` gate run against the `Phase 0 baseline`.
- Mirror parity: about forty bundle copies and generated Codex variants could drift from their sources, and the brief must change in all six byte-identical copies. Mitigation: one copy task per family, the generator `--check`, the push-down resource contracts, `test_brief_copies_are_byte_identical`, and the new `TCW-BUNDLE-*` rows; the `Mirror parity` bullet names the brief-update task.
- File size: `validate-planner-output.ps1` is at 470 lines, near the 500 guidance tier. Mitigation: the new rule lives in a new helper file with its own test file; all other targets are Markdown or TOML.
- Test isolation: new Pester files could read files through ambient paths or leave functions defined. Mitigation: read-only files resolved from `$PSScriptRoot`, helpers defined in `BeforeAll`, no temporary files, and `Invoke-PoshQCLeakScan` clean; gates are one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, and Jest through its normal parallel workers, each re-run only after a fix.
- CI-only behavior: the ledger chain test and the hook suites run on CI (`poshqc / PowerShell QC` shards; `poshqc / PowerShell hook suites (Linux)` for `tests/scripts/claude-hooks`) and could fail on Linux path case or on a `Current` fence that does not occur exactly once. Mitigation: `Join-Path` and forward-slash paths in new tests, and running the chain test inside the local Pester gate before push.
- Evidence: per-task test selections could be written as gate evidence or back-dated. Mitigation: one append-only task-check artifact per phase and one gate artifact per phase gate under `<FEATURE>/evidence/qa-gates/`, each with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, stamped at write time.

## Automation Feasibility

All work is repository-automatable with no human interaction: text edits, bundle copies, Codex variant regeneration, a new PowerShell hook helper, new Pester tests, and a ledger entry, all verified by local gates and CI. Two points are decisions rather than manual steps and belong in the spec: whether stage 7 (integration tests) leaves the local phase gate and final QA loop for CI, and where the single-suite pseudo-queue rule lives (it is not in this repository). Destination repositories receive the change only after an extension rebuild, reinstall, and push-down, which is outside this item.
