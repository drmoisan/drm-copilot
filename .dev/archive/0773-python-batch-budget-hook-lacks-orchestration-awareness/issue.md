# python-batch-budget-hook-lacks-orchestration-awareness (Issue #773)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/python-batch-budget-hook-lacks-orchestration-awareness/ (Issue #773)
- Related: #769

- Issue: #773
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/773
- Last Updated: 2026-09-29
- Work Mode: full-bug

## Summary

The Python batch-budget hooks follow the session-keyed per-batch pattern that #769 replaced for PowerShell. They count production and test files per session, deny when a fixed cap is reached, and tell the caller to split the work, raise the cap, or delete the state file. They do not read the orchestrator checkpoint, so an orchestrated large-path Python change is capped the same way a direct-mode change is.

The deny messages are at `.claude/hooks/enforce-python-batch-budget.ps1:293` and `.codex/hooks/enforce-python-batch-budget.ps1:137`.

## Scope

- `.claude/hooks/enforce-python-batch-budget.ps1` and `.codex/hooks/enforce-python-batch-budget.ps1`, with both bundle copies under `extensions/drm-copilot/resources/`.
- `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`.
- The Python row of `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`, including the Python-only cap Context added by #769.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:227-231`.
- Python text surfaces on every runtime, with their mirrors: `python-change-budget-router`, `invoke-python-engineer`, and `python-typed-engineer`.

## Acceptance Criteria (early draft)

- [ ] Both Python hooks read `<root>/artifacts/orchestration/orchestrator-state.json` through an injectable seam and allow every Python path, without writing state, on a non-terminal `large`, `remediation`, or `preparation` route (mirrors #769 AC-1 through AC-4).
- [ ] Route selection, terminal detection, and malformed-checkpoint handling match #769 AC-5 and AC-6.
- [ ] Direct mode counts only distinct production Python paths; test files are never counted (mirrors #769 AC-7).
- [ ] The runtime cap overrides are removed and legacy state keys load and are ignored (mirrors #769 AC-8).
- [ ] A case-insensitive search for the #769 AC-13 phrases returns no match in Python-scoped surfaces and their mirrors.

## Acceptance Criteria

Work mode is `full-bug`; the authoritative acceptance-criteria source is `spec.md` (`## Acceptance Criteria`). The list below mirrors it for reference and is kept identical in text. It supersedes the early draft above.

- [x] AC-1: In direct mode (no checkpoint, or a checkpoint whose selected route is `small`), the Claude Python hook allows the first three distinct production Python paths and denies the 4th; the deny reason begins `PYTHON_LARGE_PATH_REQUIRED` and names `/orchestrate`.
- [x] AC-2: In direct mode, the Codex Python hook allows the first three distinct production Python paths and denies the 4th; the deny reason begins `PYTHON_LARGE_PATH_REQUIRED` and names `.codex/prompts/orchestrate-work.md`.
- [x] AC-3: Neither Python hook's deny reason contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_PYTHON_BUDGET`, `record an approved cap`, `deleting`, `python-batch-budget.`, or the state-file path; asserted by unit tests for both hooks.
- [x] AC-4: With a non-terminal checkpoint whose selected route is `large`, `remediation`, or `preparation`, neither Python hook denies any Python path for file count at any number of distinct production files, and neither hook reads state, writes state, or creates the state directory for those paths.
- [x] AC-5: Route precedence is `route_id` when the key is present and `path_selected` only when `route_id` is absent; a present-but-null or blank `route_id` with `path_selected: large` yields direct-mode enforcement in both Python hooks.
- [x] AC-6: A missing checkpoint, a throwing reader, a malformed or non-object checkpoint, a blank or unknown route, a checkpoint with `next_step: "complete"`, and a checkpoint with `S12_complete` in `completed_steps` each yield direct-mode enforcement in both Python hooks, and no checkpoint condition causes a non-zero hook exit.
- [x] AC-7: Test Python paths matching the unchanged classification rule (`tests/**/*.py` and `test_*.py`) are never denied for count and are not recorded in state, in either mode, in both Python hooks.
- [x] AC-8: `CLAUDE_PYTHON_BUDGET_PROD`/`_TEST` and persisted `prodCap`/`testCap` no longer change the threshold; a legacy state file containing `prodCap`, `testCap`, and `testFiles` loads without error in both Python hooks; a search for `CLAUDE_PYTHON_BUDGET` in both Python hooks and their bundle copies returns no match.
- [x] AC-9: Existing behaviors hold in both Python hooks: fail-closed deny on an unreadable envelope (Claude) or malformed JSON (Codex), including under a large route; allow on missing `file_path` or non-`.py` path without invoking the checkpoint reader; out-of-root discard without a state write (Claude); repeated-path allow without a state write; deny-only output with `state` stripped; and the `Get-PythonBatchBudgetBlockDecision` deny shape (`PreToolUseSchema.Contract.Tests.ps1` passes).
- [x] AC-10: The Codex Python hook contains no `$env:CLAUDE_` read, exposes `Invoke-PythonBatchBudgetCodexEntryPoint` exercised in-process through seams, and still requires `session_id` (`legacy-codex-hook-contracts.Tests.ps1` and `codex-pretooluse-transport.Tests.ps1` pass).
- [x] AC-11: The checkpoint is supplied to both Python hooks through an injectable `ReadCheckpoint` seam; no new or modified test creates a temporary file; and no new or modified Python-hook test depends on the live `artifacts/orchestration/orchestrator-state.json` (the Python row of the shared Codex Context injects an empty checkpoint).
- [x] AC-12: `.claude/hooks/enforce-batch-budget-route.ps1` and `.codex/hooks/enforce-batch-budget-route.ps1` exist, define `ConvertFrom-BatchBudgetCheckpoint`, `Get-BatchBudgetSelectedRoute`, and `Test-BatchBudgetLargePathRoute`, and are byte-identical; `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`, and `.codex/hooks/enforce-python-batch-budget.ps1` each dot-source their runtime's helper.
- [x] AC-13: A search for `PowerShellBatchBudgetCheckpoint`, `PowerShellBatchBudgetSelectedRoute`, and `PowerShellBatchBudgetLargePathRoute` returns no match under `.claude/hooks/`, `.codex/hooks/`, `tests/scripts/`, or their bundle mirrors under `extensions/drm-copilot/resources/` (no inline or PowerShell-named copy of the route helper remains).
- [x] AC-14: `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1` exists, asserts the Claude and Codex helper copies are byte-identical, runs the route predicate table against each copy, and passes.
- [x] AC-15: `.claude/hooks/enforce-powershell-batch-budget-route.ps1` and its bundle copy no longer exist; the Claude helper is listed in `claude-customizations/pack-manifests/core.json` and a search for `enforce-powershell-batch-budget-route` in `claude-customizations/pack-manifests/powershell.json` returns no match; the Codex helper is listed in `codex-and-agents-customizations/pack-manifests/core.json` and in `$script:SharedModuleNames`; both `pester.runsettings.psd1` copies list both new helper paths and do not list the old path.
- [x] AC-16: No PowerShell regression: `enforce-powershell-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget-routing.Tests.ps1`, `codex-powershell-batch-budget-routing.Tests.ps1`, and the PowerShell row of `codex-batch-budget-hooks.Tests.ps1` pass after the switch to the shared helper, and the diff of the two #769 routing suites relative to `main` consists only of the helper function-name renames.
- [x] AC-17: New suites `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` and `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` exist and pass, and the updated `enforce-python-batch-budget.Tests.ps1`, `codex-batch-budget-hooks.Tests.ps1`, and `legacy-codex-hook-contracts.Tests.ps1` pass.
- [x] AC-18: A case-insensitive search for `per-batch`, `per batch`, `batch cap`, `smaller batches`, `split the work`, `new batch`, `three-test`, `in-flight batch`, `budget: prod=`, `budget override`, and `seek an override` returns no match in files whose path contains `python` under `.claude/`, `.agents/`, `.codex/`, `.github/agents/`, `.github/skills/`, or `.github/prompts/`, or in their bundle mirrors under `extensions/drm-copilot/resources/`, excluding `.github/agents/python-execution-only-typed.agent.md` and its mirror.
- [x] AC-19: Python routing text in `python-change-budget-router` (both copies), `invoke-python-engineer` (both copies), `.claude/agents/python-typed-engineer.md`, `.codex/agents/python-typed-engineer.toml`, and `.github/agents/python-typed-engineer.agent.md` states `1-3` production files for the small/direct path and more than 3 for the large path, states that the large path has no production-file cap, and states that test files are not counted toward the routing threshold.
- [x] AC-20: A case-insensitive regex search for ``>\s*`?3`?\s*test`` and for `1-3 test Python files` returns no match in `.github/agents/python-orchestrator.agent.md`, `.github/prompts/orchestrate-python-work.prompt.md`, `.codex/agents/python-orchestrator.toml`, or their bundle mirrors, and the path-selection rules in those files route on production-file count only.
- [x] AC-21: Routing instructions in `.claude/skills/python-change-budget-router/SKILL.md`, `.claude/skills/invoke-python-engineer/SKILL.md`, and `.claude/agents/python-typed-engineer.md` name `/orchestrate` and do not name `python-orchestrator`; the `.agents` router and invoke-skill copies and `.codex/agents/python-typed-engineer.toml` name `.codex/prompts/orchestrate-work.md`; `.github/agents/python-typed-engineer.agent.md` names `python-orchestrator`.
- [x] AC-22: Neither `invoke-python-engineer` copy nor `.agents/skills/invoke-powershell-engineer/SKILL.md` (nor their bundle mirrors) offers the `budget: prod=<N>, test=<M>` input, and neither `python-change-budget-router` copy contains a `Per-Batch Change Budget` or `Scope Expansion Protocol` section.
- [x] AC-23: Every generated variant of `.codex/agents/python-typed-engineer.toml` is regenerated with `scripts/dev_tools/generate_codex_agent_variants.py`, and `test_generate_codex_agent_variants.py` passes.
- [x] AC-24: Bundle parity and manifest completeness pass: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, `test_orchestrator_direct_command_contracts.py`, and the byte-identity and core-manifest checks in `legacy-codex-hook-contracts.Tests.ps1`; every changed `.github` file is identical to its copy under `extensions/drm-copilot/resources/customizations/.github/`.
- [x] AC-25: `.github/copilot-instructions.md`, `.github/instructions/*`, `.github/agents/python-execution-only-typed.agent.md`, `scripts/dev_tools/resolve_codex_topology.py`, and `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` are unchanged on the branch relative to `main`, and no `.py` file is modified.
- [x] AC-26: No production or test file created or modified by this item exceeds 500 lines, and the 500-line checks in `legacy-codex-hook-contracts.Tests.ps1` and `codex-epic-runtime-contracts.Tests.ps1` pass.
- [x] AC-27: PoshQC format -> analyze -> test passes with zero analyzer findings; line coverage is >= 85% for each changed hook and each helper copy (helper figures from a direct Pester run recorded under `<FEATURE>/evidence/qa-gates/`); and there is no coverage regression on changed lines.
- [x] AC-28: Both Python hook docstrings describe the routing model and document the stale-checkpoint limitation with the #673 hygiene mitigation, and contain no per-batch, cap-override, or state-file-deletion guidance.
- [x] AC-29: Potential entries under `docs/features/potential/` are recorded for the `python-execution-only-typed` 30/30 cap (owner decision) and for the language-generic orchestrator test-file routing clause in `.github/agents/orchestrator.agent.md` and `.github/prompts/orchestrate-work.prompt.md`.

## Constraints & Risks

- Threshold confirmed 2026-09-29: every Python surface already agrees that 1-3 production files is the small path and more than 3 is the large path (`.claude/skills/python-change-budget-router/SKILL.md` Canonical Routing Rules; the hook denies the 4th production file; `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` `LANGUAGE_BUDGETS.python.max_production_files: 3`). No threshold text changes are required; only the per-batch cap, batching, override, and scope-expansion text is removed. Per the owner's #769 direction, the large path has no cap on the number of files it may touch.
- The Codex topology resolver carries its own Python budget; any change must keep the resolver and the hook text consistent.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.
