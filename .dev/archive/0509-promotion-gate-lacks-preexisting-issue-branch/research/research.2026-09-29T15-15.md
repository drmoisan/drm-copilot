# Research: promotion-gate-lacks-preexisting-issue-branch (Issue #509)

- Issue: #509 (epic `orchestrator-state-contract-correctness`, #771, wave 1, depends on #405)
- Branch: `bug/promotion-gate-lacks-preexisting-issue-branch-509`
- Timestamp: 2026-09-29T15-15
- Mode: preparation research only. No source, test, or configuration file was changed.
- Method: every finding below was read from the working tree with Read, Grep, and Glob. No shell was available in this session, so no command, test, `wc`, or `git` invocation was executed; line counts are the last line number shown by Read unless marked approximate.

## 0. Input Observations

- The feature folder is `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/`. The epic manifest (`docs/features/epics/orchestrator-state-contract-correctness/epic.md` line 26) records `feature_folder: 2026-09-29-promotion-gate-lacks-preexisting-issue-branch-509`, which does not exist. The orchestrator should correct the manifest or treat the 2026-08-22 folder as canonical.
- `spec.md` and `plan.2026-09-29T15-26.md` in the folder are unfilled templates (every design heading is empty).
- #405 (`plan.2026-09-29T14-19.md`) creates `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts` exporting `resolvePromotionEntryTools(requiredMcpTools, state)` and the constants `FEATURE_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_TYPE`, `PROMOTION_TYPE_KEY`. Its P4-T2 requires that module to contain no `import {` statement and no reference to `orchestrator-state-routing`. #405 edits only `orchestrator-state-routing.ts` line 408 plus one import, and changes no Python or PowerShell production file.
- #464 (`plan.2026-09-29T14-20.md`) creates `scripts/dev_tools/_orchestrator_state_remediation_loop.py` and `scripts/dev_tools/validate_orchestrator_state_cli.py`, deletes lines 110-177 of `validate_orchestrator_state.py`, inserts an import between the `_orchestrator_state_preparation_terminal` and `_orchestrator_state_routing` imports (lines 33-42), appends a `__main__` guard, edits `.claude/rules/orchestrator-state.md` line 95 and adds a `## Bare-Module CLI Contract` section after it, and edits `.claude/skills/orchestrate/SKILL.md` lines 84 and 187, each with its bundled mirror. #464 does not touch `_orchestrator_state_routing.py`.
- #523 (wave 1, concurrent with #509) edits `validate_orchestrator_state.py` (`blocked_reason`) and the `.agents/` and Codex skill documents. Its feature folder is not present in this worktree.

## 1. Python: `scripts/dev_tools/_orchestrator_state_routing.py` (595 lines)

### 1.1 Function map

| Lines | Symbol | Internal callers | Group |
| --- | --- | --- | --- |
| 1-26 | docstring, imports, `ROUTING_MATRIX_PATH` (9-11), `PR_GATE_KEYS` (12), `FEATURE_PROMOTION_ENTRY_TOOL`/`BUG_PROMOTION_ENTRY_TOOL` (18-19), `MANDATORY_ROUTE_PHASES` (23-26) | - | constants |
| 29-33 | `load_routing_matrix` | every gate, `validate_routing_contract` | matrix |
| 36-60 | `_selected_route_id` | 63-256 gates (not used by `validate_routing_contract`, which inlines the same rule at 541-543) | route selection |
| 63-104 | `route_requires_pr_gate` | `validate_completion_pr_gate` | route gates |
| 107-153 | `route_requires_ci_gate` | external only | route gates |
| 156-199 | `validate_route_membership` | external only | route gates |
| 202-256 | `validate_phase_completeness` | external only (uses `_string_list`) | route gates |
| 259-290 | `_missing_pr_gate_keys` | `validate_completion_pr_gate` | route gates |
| 293-336 | `validate_completion_pr_gate` | external only | route gates |
| 339-347 | `_string_list` | 245, 353, 414 | shared helper |
| 350-354 | `_route_list` | `validate_routing_contract` | routing contract |
| 357-406 | `_resolve_promotion_entry_tools` | `validate_routing_contract` (557) | promotion tools |
| 409-419 | `_state_list` | `validate_routing_contract` | routing contract |
| 422-432 | `_list_receipts` | `_receipt_agents` | receipts |
| 435-443 | `_receipt_agents` | contract | receipts |
| 446-468 | `_receipt_skills` | contract | receipts |
| 471-493 | `_mcp_tools` | contract (587) | receipts |
| 496-504 | `_validate_empty_list_field` | contract | completion lists |
| 507-527 | `_validate_lifecycle_operations` | contract | completion lists |
| 530-595 | `validate_routing_contract` | external | routing contract |

The required-tool check: `required_mcp_tools` is resolved once at 557-559, compared to the declared list at 571-575, and iterated against `_mcp_tools(state)` at 587-590, emitting `Checkpoint missing successful MCP receipt: {tool}.` No branch exists for an existing issue.

### 1.2 Importers (import surface to preserve)

Production: `scripts/dev_tools/validate_orchestrator_state.py` lines 36-42 import `route_requires_ci_gate`, `validate_completion_pr_gate`, `validate_phase_completeness`, `validate_route_membership`, `validate_routing_contract`; consumed at lines 453, 467, 472, 474, 475 (`validate_routing_contract` runs only under `require_complete`).

Tests: `tests/scripts/dev_tools/test_compute_complexity_floor.py:21`, `test_resolve_delegation_model.py:22`, `test_validate_orchestration_artifacts.py:170`, `test_validate_orchestrator_state_complexity.py:19`, `test_validate_orchestrator_state_step_status_extras.py:25`, `validate_orchestrator_state_test_support.py:54` (all `load_routing_matrix`); `test_validate_orchestrator_state_routing_contract.py:9-12` (`load_routing_matrix`, `validate_route_membership`); `test_validate_orchestrator_state_preparation_route.py:16-19` (`load_routing_matrix`, `route_requires_ci_gate`). No test monkeypatches any attribute of the module (grep for `monkeypatch`/`setattr` with `routing` returned nothing).

Non-Python references: `.claude/skills/orchestrate/SKILL.md:367` (and its bundled mirror) names `_receipt_agents`, `_receipt_skills`, and `_mcp_tools` "in `scripts/dev_tools/_orchestrator_state_routing.py`". `OrchestratorStateRoutingContract.psm1:7` and `orchestrator-state-routing.ts:8` cite the file as their port source.

Existing tests: `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` (366 lines, 17 tests, including the four PR #402 promotion-type tests at 279, 298, 317, 333); gate behavior is also covered through `test_validate_orchestrator_state_preparation_route.py`.

### 1.3 Recommended behavior-preserving split

Constraints that shape it: keep every current import path working without editing `validate_orchestrator_state.py` (#464 edits its import block and #523 edits it concurrently); keep `_receipt_agents`, `_receipt_skills`, `_mcp_tools` in `_orchestrator_state_routing.py` so the SKILL.md sentence at line 367 stays true; avoid an import cycle (the routing module re-exports from the new modules, so the new modules must not import it).

| Module | Contents (moved verbatim) | Approx. lines |
| --- | --- | --- |
| `scripts/dev_tools/_orchestrator_state_route_gates.py` (new) | `ROUTING_MATRIX_PATH`, `PR_GATE_KEYS`, `MANDATORY_ROUTE_PHASES`, `load_routing_matrix`, `_selected_route_id`, `route_requires_pr_gate`, `route_requires_ci_gate`, `validate_route_membership`, `validate_phase_completeness`, `_missing_pr_gate_keys`, `validate_completion_pr_gate`, `_string_list` (source lines 9-12, 20-347) | ~370 |
| `scripts/dev_tools/_orchestrator_state_promotion_tools.py` (new) | `FEATURE_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_ENTRY_TOOL`, `_resolve_promotion_entry_tools` (13-19, 357-406); mirrors the #405 TypeScript module name | ~80 |
| `scripts/dev_tools/_orchestrator_state_issue_adoption.py` (new) | the #509 validator (section 7) | ~220 |
| `scripts/dev_tools/_orchestrator_state_routing.py` (reduced) | re-export block with `__all__`, `_route_list`, `_state_list`, receipt harvesters, completion-list helpers, `validate_routing_contract` plus adoption wiring | ~300 |

`ROUTING_MATRIX_PATH` uses `Path(__file__).resolve().parents[2]`, which is unchanged in a sibling module. Pyright is `strict` (`pyproject.toml:141-142`); cross-module import of `_string_list`, `_selected_route_id`, and `_resolve_promotion_entry_tools` should follow the `__all__` precedent in `scripts/dev_tools/_orchestrator_state_human_interaction.py:36-42`. The extraction should be its own phase, verified by the unchanged existing suites plus an identity test (`_orchestrator_state_routing.load_routing_matrix is _orchestrator_state_route_gates.load_routing_matrix`, and likewise for the other re-exported names) before any behavior change.

## 2. PowerShell: `.claude/lib/orchestrator-state/`

- Receipt check: `OrchestratorStateRoutingContract.psm1` (430 lines). `Get-ResolvedRequiredMcpTool` (105-144) is the promotion-type substitution; `Get-CheckpointAcknowledgedName` (187-243) harvests `mcp_call_receipts`; `Get-OrchestratorStateRoutingContractError` (329-426) runs the receipt loop at 412-417. Only that function is exported (430). Header rows C6.1-C6.14 (lines 10-23) document the parity inventory.
- Consumers: `OrchestratorStateCompletion.psm1` (434 lines) imports it at 63 and calls it at 418 inside `Test-OrchestratorStateCompletionReadiness`; `.claude/hooks/validate-orchestrator-output.ps1` imports `OrchestratorStateCompletion.psm1` at 259 and calls `Test-OrchestratorStateCompletionReadiness` at 261. `.claude/hooks/enforce-pr-author-skill.ps1:53` imports `OrchestratorState.psm1`, which does not evaluate receipts. No `.codex/hooks` file imports these modules.
- Other file lengths: `OrchestratorState.psm1` 499, `OrchestratorStateCheckpointValue.psm1` 385, `OrchestratorStateRoutingMatrix.psm1` 379; approximate (export-line position): `OrchestratorStateCompletionChecks.psm1` ~419, `OrchestratorStateReceipts.psm1` ~410, `OrchestratorStateModelReceipts.psm1` ~368, `OrchestratorStateCodexTopologyReceipts.psm1` ~300, `OrchestratorStateCodexModelReceipts.psm1` ~299, `OrchestratorStateUnconditional.psm1` ~168.
- Bundle: every module has a copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/` (11 files, same names). Byte identity is enforced by `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` (`Describe 'OrchestratorState bundle mirror byte identity'`, lines 91-105) and by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (118-143), which covers every `.claude` file.
- A new module must also be registered in four places, each pinned by a test: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (lines 132-142); the `$script:ExpectedPaths` list in `OrchestratorState.Manifest.Tests.ps1` (28-40; the test at 78-88 fails for any unregistered on-disk module); `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` coverage list (orchestrator-state entries at 102-104, 116-121); and its bundled twin `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, pinned by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:16`.
- Value contract: `OrchestratorState.psm1` 145-152 documents that `ConvertFrom-Json` coerces ISO-8601 strings (including `verified_at`) to `System.DateTime`, that current validations are presence-only for that reason, and that a post-parse repair to string is prohibited. Any new timestamp field must therefore be validated presence-only in all three runtimes.

## 3. TypeScript: `extensions/drm-copilot/src/lib/validate/`

- `orchestrator-state-routing.ts` (451 lines): `validateRoutingContract` (380-451), unresolved list at 408, equality check 420, receipt loop `mcpTools` (280-305) at 440-445. Helpers `stringList`, `routeList`, `stateList`, `mcpTools` are exported. After #405 the file is about 455 lines.
- Consumer: `orchestrator-state-core.ts` (467 lines) imports it at 24-25 and calls it at 441-443 under `options.requireComplete`. Observed ordering difference outside this scope: TypeScript calls `validatePreparationTerminalContract` (439) before `validateRoutingContract` (441); Python (`validate_orchestrator_state.py` 475-476) and PowerShell (C6 before C7) call the routing contract first. Parity fixtures for #509 should therefore call the routing-contract function directly, as the #405 corpus does.
- #405 function to extend: `resolvePromotionEntryTools` in `orchestrator-state-promotion-tools.ts`. #509 should not modify that module (its purity checks forbid imports); the adoption module imports its constants and consumes the list it resolves.
- `jest.config.cjs` has per-file thresholds and no global key (`orchestrator-state-core.ts` at 73-76); a new production file is ungated unless it gets its own entry.
- Tests: `test/lib/validate/orchestrator-state-routing.test.ts` (301 lines, stale in-file matrix; #405 forbids extending it), `orchestrator-state-core.completion.test.ts`, `orchestrator-state-preparation-route.test.ts`; #405 adds `orchestrator-state-promotion-tools.test.ts`, `orchestrator-state-routing.promotion-type.test.ts`, `orchestrator-state-promotion-type-parity.test.ts`. `jest.config.cjs` line 4 matches `**/test/**/*.test.ts`.

## 4. Cross-Runtime Parity Fixtures

Existing pattern: `tests/fixtures/parallel_cohort_barrier/*.json` (30 files), read by `tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py` and `extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts`; `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` shows the Pester discovery-time `-ForEach` form. #405 adds `tests/fixtures/orchestrator_state_promotion_type/` with shape `{name, notes, checkpoint, expected_errors}` and readers in all three runtimes.

Recommendation: add `tests/fixtures/orchestrator_state_issue_adoption/*.json` with the #405 shape and construction rule (real `config/orchestration-routing.json` in Python and TypeScript, pinned matrix in PowerShell). Readers: `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` (calls `validate_routing_contract(checkpoint)`), `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts` (calls `validateRoutingContract(checkpoint, { routingMatrix })`), `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1` (calls `Get-OrchestratorStateRoutingContractError -State`). Each reads committed files only, asserts ordered equality, and carries a minimum-corpus-size guard. Fixture `verified_at` values are safe under PowerShell date coercion only because the rule is presence-only.

## 5. Documentation Surfaces

| Path | Describes | Mirror / parity test |
| --- | --- | --- |
| `.claude/rules/orchestrator-state.md` | checkpoint invariants; add an `issue_adoption` scope, invariants, honest-disclosure paragraph, and an Enforcement bullet | bundle `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`; `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. #464 edits line 95 first. |
| `.claude/skills/orchestrate/SKILL.md` | `## Routing-Contract Receipt Emission` (363-423), `### mcp_call_receipts[]` (405-421) | bundle under `claude-customizations/.claude/skills/orchestrate/`; same test. #464 edits lines 84 and 187 first. |
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | MCP-only sequence (18-39), `${issue-num}` (49) | bundle under `claude-customizations/`; same test |
| `.agents/skills/orchestrate/SKILL.md` | receipt list (284-300) | bundle `codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`; `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (215-228). Possible overlap with #523. |
| `.agents/skills/feature-promotion-lifecycle/SKILL.md` | step 5 (86) | bundle under `codex-and-agents-customizations/`; same test |
| `.agents/skills/orchestrator-workflow/SKILL.md` | 188-200, 407 | same bundle test |
| `.codex/agents/orchestrator.toml` | line 160 | five generated variants per surface; `tests/scripts/dev_tools/test_generate_codex_agent_variants.py::test_checked_in_variants_match_generator_output_in_both_surfaces`, plus the codex bundle test |
| `.github/skills/feature-promotion-lifecycle/SKILL.md` | promotion sequence | copy at `extensions/drm-copilot/resources/customizations/.github/skills/feature-promotion-lifecycle/SKILL.md`; no byte-identity test was located |

Recommendation: update the first five rows (and their bundles) in #509. Defer `orchestrator-workflow`, `orchestrator.toml` (12-file regeneration), and the `.github` copy to a recorded follow-up; their text states the default rule, which remains true.

## 6. Precedent and the Idempotent-Tool Alternative

- `human_interaction` (`_orchestrator_state_human_interaction.py`, 127 lines): key-gated in `validate_orchestrator_state.py` 432-448; a non-object value is an error; errors accumulate. It waives nothing, which is why the #500 run still failed the gate.
- `standalone_merge_authorizations` (`.claude/rules/orchestrator-state.md` 125-147) is the closest precedent: structured evidence, fixed field order, and an explicit honest-disclosure paragraph that the record is a declaration, not a cryptographic control.
- No prior adoption logic exists in production code (grep for `issue_adopt`, `adopt`, `pre-existing`, `preexisting` across `scripts/`, `extensions/drm-copilot/src/`, `.claude/lib/`, `.claude/skills/`, `.agents/`, `.codex/` found only unrelated matches).
- `delegation_receipts.promotion.issue` is not required by any validator or hook (grep found no reader), so omitting it under adoption is valid.
- Current exposure, verified by reading `_mcp_tools` (471-493), `mcpTools` (280-305), and `Get-CheckpointAcknowledgedName`: any `{"tool":"potential_to_issue","ok":true,"evidence":"..."}` entry passes today, so a fabricated receipt is indistinguishable from a real one. A structured field makes the substitution visible rather than hidden in a receipt.
- `potential_to_issue` implementation: `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` (443 lines) `promotePotential` requires an existing potential file (319-323), always calls `ghClient.issueCreate` (367), and parses the created URL (403); it is a byte-parity port of `scripts/dev_tools/potential_to_issue.py`. Making it idempotent would need a new MCP input in `mcp-tool-definitions.ts` (187) and `mcp-repo-automation-tool-definitions.ts` (219), `mcp-tool-inputs-potential-to-issue.ts`, the service call, both Python and TypeScript implementations, and an extension release. It would still require a local potential record, which a transferred issue lacks, and the result would be a receipt the gate cannot tell apart from a created issue.

## 7. Design Options and Recommendation

**Selected: (a) a new top-level, presence-gated `issue_adoption` object, evaluated only inside the routing contract (completion gate).**

Rejected alternatives:
- (b) An adoption-shaped `mcp_call_receipts` entry: overloads a record whose meaning is "an MCP call succeeded"; requires changing the shared harvester, which PowerShell also uses for `skill_receipts`; keeps the substitution hard to audit.
- (c) Idempotent `potential_to_issue`: the widest blast radius (MCP schema, two implementations, release), does not cover the no-potential-record case, and hides adoption inside an ordinary receipt.

### 7.1 Schema

```json
"issue_adoption": {
  "issue_num": "509",
  "issue_url": "https://github.com/drmoisan/drm-copilot/issues/509",
  "origin": "transferred",
  "verified_via": "gh_issue_view",
  "verified_at": "2026-09-29T15:15:00Z",
  "evidence": "gh issue view 509 --json number,state,url: number 509, state OPEN",
  "waived_tools": ["potential_to_issue"],
  "potential_record": "docs/features/potential/promoted/2026-08-22-promotion-gate-lacks-preexisting-issue-branch.md"
}
```

- `issue_num`: string of ASCII decimal digits with no leading zero. A string, not a number, because checkpoints store `issue-num` as a string (every fixture found uses `"1"`, `"545"`, and similar) and because JSON float and integer handling differs across runtimes (for example `509.0`).
- `issue_url`: string ending with `/issues/` followed by `issue_num`.
- `origin`: one of `transferred`, `filed_before_orchestration`, `epic_decomposition`.
- `verified_via`: one of `gh_issue_view`, `gh_api_get`, `github_mcp_issue_read`. `gh issue view` and `gh api` GET are not blocked by `.claude/hooks/enforce-promotion-mcp-only.ps1` (it blocks `gh issue create|new` and `gh api ... -X POST`, lines 114-141).
- `verified_at`: presence-only (not absent, not null, not a blank string), because of the PowerShell date-coercion contract.
- `evidence`: non-blank string.
- `waived_tools`: non-empty list of non-blank strings (`_string_list` semantics).
- `potential_record`: required only when `waived_tools` names a promotion-entry tool; a string starting with `docs/features/potential/` and ending with `.md`. Otherwise ignored.
- Unknown keys inside the object are ignored, consistent with `human_interaction`.

### 7.2 Validation rules (fixed order, errors accumulate)

Let `resolved` be the route's `required_mcp_tools` after `_resolve_promotion_entry_tools` / `resolvePromotionEntryTools` / `Get-ResolvedRequiredMcpTool`, and `successful` the harvested receipt set. Checks run only when the key `issue_adoption` is present.

1. Not an object (including `null`): `Checkpoint issue_adoption must be an object when present.` Stop.
2. `issue_num` invalid: `Checkpoint issue_adoption.issue_num must be a string of decimal digits without a leading zero.` If valid but not ordinally equal to a string checkpoint `issue-num`: `Checkpoint issue_adoption.issue_num must equal the checkpoint issue-num.`
3. `issue_url` not a string ending with `/issues/<issue_num>`, or `issue_num` invalid: `Checkpoint issue_adoption.issue_url must end with /issues/ followed by issue_num.`
4. `origin`: `Checkpoint issue_adoption.origin must be one of transferred, filed_before_orchestration, epic_decomposition.`
5. `verified_via`: `Checkpoint issue_adoption.verified_via must be one of gh_issue_view, gh_api_get, github_mcp_issue_read.`
6. `verified_at`: `Checkpoint issue_adoption.verified_at must be present.`
7. `evidence`: `Checkpoint issue_adoption.evidence must be a non-empty string.`
8. `waived_tools` malformed or empty: `Checkpoint issue_adoption.waived_tools must be a non-empty list of tool names.` Otherwise, per entry in list order, first matching rule: already seen, `... lists a tool more than once: {tool}.`; not in `{potential_to_issue, new_potential_entry, new_potential_bug_entry}`, `... names a tool that cannot be waived: {tool}.`; not in `resolved`, `... names a tool that is not required by route {route_id}: {tool}.`; in `successful`, `... names a tool that has a successful MCP receipt: {tool}.` Then, if `potential_to_issue` is absent from the list: `Checkpoint issue_adoption.waived_tools must include potential_to_issue.`
9. A promotion-entry tool is waived and `potential_record` is invalid: `Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving {tool}.`

Messages interpolate only tool names and the route id, which are validated non-blank strings and render identically in all three runtimes; no raw value is rendered, which avoids the repr divergence recorded in `OrchestratorStateCheckpointValue.psm1` 347-352. String comparisons are ordinal and case-sensitive (PowerShell `-ceq`, `-ccontains`). The digit pattern is `re.fullmatch(r"[1-9][0-9]*", s)` in Python, `/^[1-9][0-9]*$/` in TypeScript, and `-cmatch '\A[1-9][0-9]*\z'` in PowerShell (`$` in .NET accepts a trailing newline; `\d` is Unicode-aware in Python and .NET).

### 7.3 Waiver semantics and fail-closed behavior

- The waivable set is closed. `new_active_feature_folder`, `validate_orchestration_artifacts`, `collect_pr_context`, and any other tool are rejected by rule 8, so they can never be waived.
- `waived_tools` takes effect only when the adoption error list is empty. With any error, nothing is waived: the checkpoint gets both the adoption errors and the unchanged `Checkpoint missing successful MCP receipt: potential_to_issue.` This is how malformed evidence fails closed.
- The declared `required_mcp_tools` must still equal the resolved matrix list, including `potential_to_issue`. Adoption affects only receipt presence.
- Interaction with #405: rule 8 checks membership in the resolved list, so a bug checkpoint can waive only `new_potential_bug_entry`, and naming `new_potential_entry` reports "not required by route". The adoption function takes the resolved list as a parameter and does not re-resolve.
- Error placement: adoption errors are appended right after the MCP receipt loop and before the `local_execution_overrides` errors, identically in all three runtimes.
- Presence gating: if the key is absent, the function returns no errors and no waivers, and the ordered error list is byte-identical to today's. The key is not added to `REQUIRED_STATE_KEYS`, plain validation, or the PR-creation-readiness gate (`_orchestrator_state_pr_creation_readiness.py` 23, 57, 79-96 confirm that gate never evaluates receipts). No top-level key allowlist exists in any runtime (grep for `unsupported key` matched only the `delegation_receipts` namespaces).
- Honest disclosure (for the rules document): the validators perform no network I/O, so `evidence` and `verified_via` are an auditable declaration, not proof. This matches the standalone-merge precedent.

### 7.4 Per-runtime shape

- Python `_orchestrator_state_issue_adoption.py`: `ISSUE_ADOPTION_KEY`, enums, `WAIVABLE_TOOLS`, `POTENTIAL_TO_ISSUE_TOOL`, and a pure `resolve_issue_adoption(state, *, route_id, required_mcp_tools, successful_tools) -> IssueAdoptionResult` (frozen dataclass: `errors: tuple[str, ...]`, `waived_tools: frozenset[str]`). It imports constants from `_orchestrator_state_promotion_tools` only.
- TypeScript `orchestrator-state-issue-adoption.ts`: `resolveIssueAdoption(state, { routeId, requiredMcpTools, successfulTools }): { errors: string[]; waivedTools: ReadonlySet<string> }`. It imports constants from `./orchestrator-state-promotion-tools`. `validateRoutingContract` gains about 8 lines (to about 463).
- PowerShell `OrchestratorStateIssueAdoption.psm1`: `Get-OrchestratorStateIssueAdoptionResult -State -RouteId -RequiredMcpTool -SuccessfulTool`, returning `@{ Errors; WaivedTools }` and importing `OrchestratorStateCheckpointValue.psm1` with `-ErrorAction Stop`. `OrchestratorStateRoutingContract.psm1` imports it and adds a C6.15 header row (about 455 lines after the change).

## 8. Enforcement Hooks

No hook file changes. The PowerShell completion path reaches the new module through `validate-orchestrator-output.ps1` → `OrchestratorStateCompletion.psm1` → `OrchestratorStateRoutingContract.psm1`, all PowerShell. No hook gains a Python leg. `.claude/hooks/enforce-powershell-batch-budget.ps1` (#769) is not touched. The #464 plan notes a batch budget of at most 3 production and 3 test files per phase; the planner should size phases to fit it.

## 9. Test Constraints and Commands

No command below was executed in this session: there was no shell tool, and `extensions/drm-copilot/node_modules` is absent (Glob for `node_modules/jest/package.json` returned nothing). `hypothesis` is not in `pyproject.toml` and `fast-check` is not an extension dependency (#405 plan), so property-density obligations should use deterministic fixed-grid invariant tests as #405 does. No `quality-tiers.yml` exists at the repository root (Glob returned nothing). No test may create temporary files: fixtures are committed JSON and Pester uses in-memory JSON strings.

- Python baseline: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py tests/scripts/dev_tools/test_validate_orchestrator_state_preparation_route.py --cov=scripts.dev_tools._orchestrator_state_routing --cov-branch --cov-report=term-missing`
- Python after the change: `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools._orchestrator_state_routing --cov=scripts.dev_tools._orchestrator_state_route_gates --cov=scripts.dev_tools._orchestrator_state_promotion_tools --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing`
- Bundle and registration: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`
- TypeScript (working directory `extensions/drm-copilot`, after `npm ci`): `npm run test:unit -- test/lib/validate`; `npm run test:coverage -- --coverageReporters=text`; `npm run format`, `npm run lint`, `npm run typecheck`.
- Pester: MCP `mcp__drm-copilot__run_poshqc_test` with `scan_folders: ["tests/scripts/claude-lib/orchestrator-state"]`. Known limitations: the MCP runner reads the installed extension's `pester.runsettings.psd1` and returns no counts, and command text containing `pwsh` is refused inside agent worktrees. Unlike #405, a PowerShell production file changes here, so a `COVERAGE-UNMEASURED` disposition would not be justified. The dependable PowerShell coverage source is CI `.github/workflows/_poshqc.yml` (`Invoke-PoshQCTest`, lines 42-51), which uploads `artifacts/pester/powershell-coverage.xml` using the repo settings.

Proposed tests (names are proposals): Python `test_orchestrator_state_routing_split.py` (re-export identity), `test_orchestrator_state_issue_adoption.py` (unit plus fixed-grid invariant), `test_validate_orchestrator_state_issue_adoption.py` (full-validator regression that must fail first: a `large` checkpoint with valid adoption and no `potential_to_issue` receipt expects `[]`), and the corpus reader. TypeScript `orchestrator-state-issue-adoption.test.ts` plus the corpus reader, and a `jest.config.cjs` entry at 85/75. Pester `OrchestratorStateIssueAdoption.Tests.ps1` plus the corpus reader, and the `ExpectedPaths` addition. Corpus cases: valid on `large`, bug `large` waiving the bug entry tool with `potential_record`, `preparation`, absent key (baseline error), `null` object, and one case per rule in 7.2, including waiving `new_active_feature_folder`, waiving `validate_orchestration_artifacts`, the feature entry tool on a bug checkpoint, the receipt conflict, the `remediation` route, a duplicate, and integer `issue_num`.

## Numeric Derivation Evidence

### Claim N1: routes whose `required_mcp_tools` include `potential_to_issue` = 3

- Complete Family: every route in the routing matrix.
- Exhaustive Search Scope: `config/orchestration-routing.json` `routes` object (all six routes) and the pinned `$script:PINNED_ROUTES` in `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1`.
- Inclusion Rules: the route's `required_mcp_tools` list contains the exact string `potential_to_issue`.
- Exclusion Rules: mentions outside `required_mcp_tools`.
- Primary Search Strategy or Query Expression: Grep `"(small|large|remediation|preparation|parallel|epic|[a-z_-]+)": \{|potential_to_issue` on the JSON, mapping hit lines to route ranges (small 5-33, large 34-60, remediation 61-78, preparation 79-99, parallel 100-121, epic 122-143).
- Primary Member Set: {small (line 28), large (55), preparation (95)}.
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: Read of `OrchestratorStateRoutingMatrix.psm1` lines 51-94, inspecting each route's `required_mcp_tools` literal.
- Cross-check Member Set: {small (57), large (64), preparation (78)}; remediation (71), parallel (85), and epic (92) lack it.
- Cross-check Count: 3.
- Member-set Comparison: identical sets; the claim holds.

### Claim N2: Python files importing `_orchestrator_state_routing` = 9 (1 production, 8 test/support)

- Complete Family: every `.py` file in the repository referencing the module by any import form.
- Exhaustive Search Scope: whole worktree, `.py` files.
- Inclusion Rules: an import statement or module string naming `scripts.dev_tools._orchestrator_state_routing`.
- Exclusion Rules: comments or docs in non-Python files.
- Primary Search Strategy or Query Expression: Grep `_orchestrator_state_routing` with glob `*.py`, content mode.
- Primary Member Set: `scripts/dev_tools/validate_orchestrator_state.py`; `tests/scripts/dev_tools/test_compute_complexity_floor.py`, `test_resolve_delegation_model.py`, `test_validate_orchestration_artifacts.py`, `test_validate_orchestrator_state_complexity.py`, `test_validate_orchestrator_state_routing_contract.py`, `test_validate_orchestrator_state_preparation_route.py`, `test_validate_orchestrator_state_step_status_extras.py`, `validate_orchestrator_state_test_support.py`.
- Primary Count: 9.
- Cross-check Search Strategy or Query Expression: Grep `dev_tools\._orchestrator_state_routing\b`, `type: py`, count mode; plus Grep `import\s+_orchestrator_state_routing|_orchestrator_state_routing\s+as\b|"_orchestrator_state_routing"` for other import forms (0 hits).
- Cross-check Member Set: the same nine paths, one occurrence each.
- Cross-check Count: 9.
- Member-set Comparison: identical; no alternative import form exists.

## Automation Feasibility

No third-party UI is involved. Every change is to repository source, tests, fixtures, and Markdown, and every verification is a CLI or MCP test run. Verifying an issue's existence at runtime (`gh issue view`, `gh api` GET, or a GitHub MCP read) is agent-executable and is not blocked by `enforce-promotion-mcp-only.ps1`. The only step that cannot be fully automated inside an agent worktree is the local PowerShell coverage figure. The CI `_poshqc.yml` artifact is the automated substitute.

## Files the Implementation Would Touch

- Python production: `scripts/dev_tools/_orchestrator_state_routing.py` (edit); new `_orchestrator_state_route_gates.py`, `_orchestrator_state_promotion_tools.py`, `_orchestrator_state_issue_adoption.py`.
- Python tests: new `tests/scripts/dev_tools/test_orchestrator_state_routing_split.py`, `test_orchestrator_state_issue_adoption.py`, `test_validate_orchestrator_state_issue_adoption.py`, `test_orchestrator_state_issue_adoption_parity.py`.
- Fixtures: new `tests/fixtures/orchestrator_state_issue_adoption/*.json`.
- PowerShell production (each with its bundle copy under `extensions/drm-copilot/resources/claude-customizations/`): new `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`; edit `OrchestratorStateRoutingContract.psm1`.
- PowerShell registration: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`; `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1`.
- Pester tests: new `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`, `OrchestratorStateIssueAdoption.Parity.Tests.ps1`.
- TypeScript: new `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`; edit `orchestrator-state-routing.ts`; edit `extensions/drm-copilot/jest.config.cjs`; new `test/lib/validate/orchestrator-state-issue-adoption.test.ts`, `orchestrator-state-issue-adoption-parity.test.ts`.
- Documentation (each with its bundle): `.claude/rules/orchestrator-state.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/feature-promotion-lifecycle/SKILL.md`.
- Not touched: `scripts/dev_tools/validate_orchestrator_state.py`, `orchestrator-state-core.ts`, `OrchestratorStateCompletion.psm1`, every `.claude/hooks/*` file, `config/orchestration-routing.json`, and the `potential_to_issue` implementation.
