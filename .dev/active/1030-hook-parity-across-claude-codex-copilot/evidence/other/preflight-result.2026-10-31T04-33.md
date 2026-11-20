# Preflight Result

Timestamp: 2026-10-31T04-33
Plan: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md
Branch: issue-1030-prep-r2
Work Mode: full-feature (AC sources spec.md, user-story.md)

PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Validator Runs

- Command: poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md
- EXIT_CODE: 0 (run once before and once after the in-place fixes; both printed "plan validation passed")
- MCP validate_orchestration_artifacts (artifact_type plan): ok true, before and after the fixes
- Output Summary: no Blocking finding and no Warning from either validator. The substantive defects below fall in classes the validators do not check.

## In-Place Fixes

PREFLIGHT-FIX: ## Terms (RUN-ITEMS) | missing citation | named the run manifest docs/features/parallel/bugs-1001-1002-1003-1006/parallel.md (origin/main, else the run's plan branch) as the source of blast_radius.paths
PREFLIGHT-FIX: [P0-T3] | citation correction against the tree | "is a coverage root" / "is a scan folder" changed to "lies under" the existing scripts root / tests/scripts scan folder
PREFLIGHT-FIX: ## Pre-Mortem (Coverage) | citation correction against the tree | "must be a coverage root" changed to "must lie under a coverage root"
PREFLIGHT-FIX: [P5-T1] | incomplete anchor | the task now also names the Get-GuardedPowerShellFile synopsis, which also says "three scan roots"
PREFLIGHT-FIX: [P5-T5] | typo | added the missing comma before the Codex validate-executor-output note
PREFLIGHT-FIX: [P6-T1] | validator-blind assertion that cannot fail | the porcelain before/after listing is replaced with SHA256 before/after of each formatted file
PREFLIGHT-FIX: [P2-T10] | ambiguous acceptance literal | "the three named existing suites" now names codex-epic-runtime-contracts and codex-pretooluse-integration; the other two run in [P2-T15]
PREFLIGHT-FIX: [P2-T10] | omitted handler name | the epic-review, status-updater and staged-review groups each register validate-required-artifact-output.ps1 with that agent's arguments

preflight-fix-record: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/evidence/other/preflight-fixes.2026-10-31T04-33.md

## Substantive Defects

PREFLIGHT-DEFECT: ## Terms (BASE), [P0-T3], [P0-T4], [P0-T5], [P0-T6], [P6-T8], [P6-T10], [P6-T12] | wrong reference branch (task ordering and scope) | Epic children merge into epic/shared-agent-harness-layer-integration, not main. Sources: epic.md frontmatter integration_branch, and the epic-orchestrate skill rule that each child's PR base is the integration branch. When child 5 runs, the outputs of children 1, 2 and 3 are not on origin/main. Checks (b), (c), (d) and the child 1 runbook search in (e) therefore report MISMATCH on every run, and Phase 0 always stops. BASE = merge-base(origin/main, HEAD) also puts the child 1 to 3 changes into the [P6-T10] scope diff: child 2 adds extensions/drm-copilot/src/lib/development-docs/*.ts and edits .claude/agents and .claude/settings.json literals (D-16), and child 3 regenerates .claude/agents. [P6-T10] then fails, and [P6-T8] and [P6-T12] review the wrong change set. Required change: check (a) stays at origin/main and also confirms that the integration branch contains the merged run (the wave-2 main sync). Checks (b) to (e) read origin/epic/shared-agent-harness-layer-integration. BASE becomes the merge base of origin/epic/shared-agent-harness-layer-integration and HEAD. The orchestrator routes the matching spec correction: spec.md S-01 and ## Execution-Time Gating say "against origin/main".
PREFLIGHT-DEFECT: [P2-T10], [P3-T2], [P4-T3] | changed-behavior test not named with disposition | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 parses the bundled .codex/config.toml and pins exact values. Row "derives 20 PreToolUse hooks and excludes 5 non-PreToolUse registrations from the bundle config" pins 25 hooks, 20 PreToolUse and a fixed ExpectedExcludedHooks list. Row "returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location" pins 47 invocations. Both fail once these tasks change the bundle config. Required change: name the suite in each task with disposition "updated" and give the new values. [P2-T10]: the new SubagentStop hook names go into ExpectedExcludedHooks and the total. The parser's command regex matches only commands that end in .ps1"', so argument-carrying validate-required-artifact-output.ps1 registrations are counted only if the parser is also updated; state which. [P3-T2]: PreToolUse becomes 21, invocations become 49 (apply_patch and Edit are admitted), and enforce-feature-folder-order.ps1 must allow from the bundle location. [P4-T3], under C2 DELIVER: one more hook and one more invocation. Add the suite to each task's acceptance.
PREFLIGHT-DEFECT: [P0-T6], [P4-T1] | unsatisfiable deliverable and changed-behavior test not named | The process entry tail of .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 passes tool_input to Invoke-OrchestrationPreimplementationGateDecision only for Bash and apply_patch. Every other tool name goes through ConvertTo-CodexFileEditInput, which maps nothing for spawn_agent, so the hook exits 0 (allow) whatever subagent_type is. Registering the hook on the ^(Agent|Task|spawn_agent|run_subagent|delegate)$ group therefore enforces nothing. The planned "denied implementation delegation on spawn_agent payloads" can only be shown by calling the decision function directly, which bypasses the shipped transport (the D5 rule recorded in enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1). Changing the entry tail means editing a file that is in both CAPPED (500 lines) and RUN-HOOKS (#1010), which the spec forbids. Under C1 DELIVER, the existing row "registers no PreToolUse matcher admitting an Agent or Task tool name" in tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 fails, and no task names it. Required change: in [P0-T6], set C1: DELIVER only when, in addition to F1, the merged gate's entry tail is recorded as routing a spawn_agent payload into the delegation leg. Otherwise C1 is DEFER, recorded as NOT-EXPRESSIBLE without an edit to a capped file. [P4-T1] drives the gate through its process entry point with spawn_agent payloads, and names the mode-resolution row with disposition "updated" under DELIVER (the gap assertion replaced by a registered-and-enforced assertion; the gap is owned by issue #555).

## Design Decisions Reviewed (no defect)

- Codex function-twin port shape: workable. Every PORTS source keeps its decision logic in functions that return results and exits only in the entry tail (Exit-SubagentStopBlock is called only from the tail). The Codex continuation can therefore replace the tail without changing any twinned function. No source reads $env:CLAUDE_. The current line counts (planner 454, executor 450) are below the source-plus-five 480 bound in [P0-T7].
- codex-subagentstop-continuation.ps1: keeps Codex-only exit behavior out of the twinned files. A first block exits 2 with stderr, unlike the decision=block JSON exit-0 form of validate-feature-review-coverage.ps1. spec.md ## API / CLI Surface allows either form. Note for the executor: Exit-CodexSubagentStopDecision runs only in child processes, so an injectable exit seam may be needed to reach the 85% line floor.
- scripts/harness/HarnessHookParity.psm1 in child 1's folder: matches spec.md ## Implementation Strategy ("Any production module the gate needs is placed in child 1's scripts/harness/"). It runs only in repository CI, so PowerShell is correct.
- Git-only Phase 0 (a) merge check: acceptable. A missed merge (for example a squash commit message without #issue after the branch was deleted) produces STOP, which is the safe direction. All nine RUN-ITEMS were confirmed against the run manifest on the run's plan branch.
- ## Language Classification: complies with the owner rule. No new Python or TypeScript. Pushed-down hooks, twins and the continuation helper are PowerShell. Existing Python contract tests are edited in place only ([P2-T14]). E2 is correctly marked not applicable.
- Execution-environment brief: no brief fact changes (no CI job, required context, tool route or batch-budget rule), so no brief-update task is required.
