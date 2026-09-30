# promotion-gate-lacks-preexisting-issue-branch (Spec)

- **Issue:** #509
- **Parent (optional):** epic `orchestrator-state-contract-correctness` (#771), wave 1, depends on #405
- **Owner:** drmoisan
- **Branch:** `bug/promotion-gate-lacks-preexisting-issue-branch-509`
- **Work Mode:** full-bug (this `spec.md` is the sole acceptance-criteria source; no `user-story.md`)
- **Research:** `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/research/research.2026-09-29T15-15.md`
- **Last Updated:** 2026-09-29
- **Status:** Draft
- **Version:** 1.0

## Context

The routing-contract completion gate requires a successful `mcp_call_receipts[]` entry for every tool in the selected route's `required_mcp_tools`, including `potential_to_issue`. When the GitHub issue already exists (transferred from another repository, filed before orchestration began, or created by epic decomposition), `potential_to_issue` cannot be run truthfully: it has no idempotent path and always calls `issueCreate`. The orchestration must then either file a duplicate issue or fail its own completion gate. The run for issue #500 encountered this and completed by recording the substitution under `human_interaction.requirements[]`, which waives nothing and left the gate failing.

A secondary exposure exists today: any `{"tool":"potential_to_issue","ok":true,"evidence":"..."}` entry passes the gate, so a fabricated receipt cannot be distinguished from a real one. A structured, validated adoption record makes the substitution explicit and auditable.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: `validate_orchestration_artifacts orchestrator-state <path> --require-complete`
- Data source or fixture: `scripts/dev_tools/_orchestrator_state_routing.py` and `config/orchestration-routing.json`

Impact / Severity: Medium. Delivered code is unaffected, but the completion gate is unsatisfiable for a legitimate and recurring situation, which creates pressure to fabricate a receipt or file duplicate issues.

## Repro & Evidence

Steps to Reproduce:
1. Begin an orchestration against an issue that already exists on GitHub and has no local potential record.
2. Run the promotion lifecycle. The potential-entry and active-folder tools run truthfully; `potential_to_issue` cannot, because it would create a second issue.
3. Complete the work and run the completion validator with `--require-complete`.

Expected: an orchestration working a pre-existing issue reaches a clean completion without filing a duplicate, by recording structured evidence of the existing issue in place of the `potential_to_issue` receipt.

Actual: `validate_routing_contract` emits `Checkpoint missing successful MCP receipt: potential_to_issue.` and offers no branch for an existing issue.

Routes affected (research Claim N1, primary and cross-check member sets identical): the routes whose `required_mcp_tools` contain `potential_to_issue` are `small`, `large`, and `preparation`. The `remediation`, `parallel`, and `epic` routes do not require it.

## Root Cause Analysis

The routing matrix models promotion as one linear path (potential entry, then issue, then feature folder), and every runtime's routing-contract validator treats each resolved required tool as mandatory:

- Python: `validate_routing_contract` in `scripts/dev_tools/_orchestrator_state_routing.py` resolves `required_mcp_tools` (lines 557-559), checks declared equality (571-575), and loops over the resolved list against `_mcp_tools(state)` (587-590), emitting `Checkpoint missing successful MCP receipt: {tool}.`
- PowerShell: `Get-OrchestratorStateRoutingContractError` in `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` (receipt loop at 412-417).
- TypeScript: `validateRoutingContract` in `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` (receipt loop at 440-445).

None of the three has a branch for a pre-existing issue, and no checkpoint field exists that could carry verified evidence of one. The `potential_to_issue` implementation (`promotion.ts` `promotePotential`, byte-parity port of `scripts/dev_tools/potential_to_issue.py`) always creates an issue and parses the new URL, so it cannot adopt an existing issue.

## Scope & Non-Goals

### In scope

1. A behavior-preserving split of `scripts/dev_tools/_orchestrator_state_routing.py` (595 lines) below the 500-line cap, performed as the first implementation step.
2. A new optional top-level checkpoint object `issue_adoption`, validated only inside the routing contract (completion gate), in Python (authoritative), PowerShell (`.claude/lib/orchestrator-state/` and its bundled copy), and TypeScript.
3. Waiver semantics that let a valid `issue_adoption` record stand in for the `potential_to_issue` receipt, and optionally for the promotion-type-resolved potential-entry tool, and for no other tool.
4. Shared cross-runtime parity fixtures and readers in all three runtimes.
5. Documentation updates listed under "Documentation surfaces", with their bundled mirrors.
6. Registration of the new PowerShell module in every test-pinned registry.

### Non-goals and out of scope

- Making `potential_to_issue` idempotent (research option (c), rejected: widest blast radius, requires an MCP schema change and an extension release, does not cover the no-potential-record case, and hides adoption inside an ordinary receipt).
- Adoption-shaped `mcp_call_receipts[]` entries (research option (b), rejected).
- Network verification of the adopted issue by any validator. Validators perform no network I/O; `evidence` and `verified_via` are an auditable declaration.
- Changes to `scripts/dev_tools/validate_orchestrator_state.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`, `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`, `config/orchestration-routing.json`, `REQUIRED_STATE_KEYS`, plain (non-complete) validation, and the PR-creation-readiness gate.
- Any file under `.claude/hooks/`. In particular, `.claude/hooks/enforce-powershell-batch-budget.ps1` and related files and tests (#769) are not touched.
- The observed ordering difference in `orchestrator-state-core.ts` (preparation-terminal contract evaluated before the routing contract, unlike Python and PowerShell). It is recorded here and not changed.
- The issue's manual-verification note about `.claude/hooks/enforce-promotion-mcp-only.ps1` matching the tool name anywhere in a shell command. Hook changes are excluded from this epic; it is recorded as a follow-up.
- #343 (`pr_gate`/`ci_gate` route-gating parity) and the `require_pr_creation_ready` MCP parity potential entry.
- Correcting the epic manifest's `feature_folder` value for #509 (it names `2026-09-29-...`, while the canonical folder is `2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509`). That is an orchestrator task.

### Deferred documentation (recorded follow-ups)

- `.github/skills/feature-promotion-lifecycle/SKILL.md` and its copy at `extensions/drm-copilot/resources/customizations/.github/skills/feature-promotion-lifecycle/SKILL.md`. The text describes the MCP call sequence for a new promotion and states no receipt requirement, so it remains accurate for the default path. Deferred to a follow-up that adds the adoption path to the Copilot surface.

### Deviation from the research recommendation

The research defers `.agents/skills/orchestrator-workflow/SKILL.md` and `.codex/agents/orchestrator.toml`, stating that their text gives the default rule, which remains true. A direct reading shows both state the receipt requirement without exception: `orchestrator-workflow/SKILL.md` lines 200-201 ("every required MCP tool MUST have a successful `mcp_call_receipts[].tool` receipt") and line 407, and `orchestrator.toml` line 160 ("Each required MCP tool must have an `mcp_call_receipts[]` entry with `ok = true`"). Those statements would become false once a valid `issue_adoption` record can waive a tool. Both are therefore in scope. The `orchestrator.toml` edit requires regenerating the checked-in variants in both surfaces through `scripts/dev_tools/generate_codex_agent_variants.py`.

## Proposed Fix

### Design summary

Add a presence-gated top-level `issue_adoption` object. Only the routing-contract completion check evaluates it. A pure resolver in each runtime validates the object against the route's already-resolved `required_mcp_tools` and the harvested successful-receipt set. It returns an ordered error list and a set of waived tools. The receipt loop skips waived tools only when the adoption error list is empty. Adoption errors are appended after the MCP receipt loop and before the `local_execution_overrides` errors, in the same position in all three runtimes.

### Boundaries and invariants to preserve

- Presence gating: when the key `issue_adoption` is absent, the resolver returns no errors and no waivers, and every runtime's ordered validator output is byte-identical to the output before this change.
- The declared `required_mcp_tools` must still equal the resolved matrix list, including `potential_to_issue`. Adoption affects only receipt presence.
- Python is authoritative; PowerShell and TypeScript emit identical error strings in identical order.
- The Python import surface of `scripts.dev_tools._orchestrator_state_routing` is preserved for all nine importing files (research Claim N2: `scripts/dev_tools/validate_orchestrator_state.py`; `tests/scripts/dev_tools/test_compute_complexity_floor.py`, `test_resolve_delegation_model.py`, `test_validate_orchestration_artifacts.py`, `test_validate_orchestrator_state_complexity.py`, `test_validate_orchestrator_state_routing_contract.py`, `test_validate_orchestrator_state_preparation_route.py`, `test_validate_orchestrator_state_step_status_extras.py`, `validate_orchestrator_state_test_support.py`) without editing any of them.
- `_receipt_agents`, `_receipt_skills`, and `_mcp_tools` remain defined in `_orchestrator_state_routing.py`, so the sentence at `.claude/skills/orchestrate/SKILL.md` line 367 stays true.
- No import cycle: the new Python modules do not import `_orchestrator_state_routing`.
- Every production and test file stays below 500 lines.

### Dependencies or blocked work

- Depends on #405. #509 consumes #405's promotion-type-resolved tool list and constants and does not duplicate them:
  - TypeScript: `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts` (created by #405) exports `resolvePromotionEntryTools`, `FEATURE_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_TYPE`, and `PROMOTION_TYPE_KEY`. #509 does not modify that module (its #405 purity checks forbid `import {` statements and references to `orchestrator-state-routing`). The new TypeScript adoption module imports its constants.
  - Python: `FEATURE_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_ENTRY_TOOL`, and `_resolve_promotion_entry_tools` move verbatim into `_orchestrator_state_promotion_tools.py`, and the adoption module imports from there.
  - PowerShell: the adoption module receives the output of `Get-ResolvedRequiredMcpTool` as a parameter.
  - The adoption resolver never re-resolves the promotion type; it takes the resolved list as input.
- Coordination with #464 (wave 0): #464 creates `_orchestrator_state_remediation_loop.py` and `validate_orchestrator_state_cli.py`, edits `validate_orchestrator_state.py`, edits `.claude/rules/orchestrator-state.md` line 95 (adding a `## Bare-Module CLI Contract` section), and edits `.claude/skills/orchestrate/SKILL.md` lines 84 and 187. #509 does not edit those modules or lines. Its documentation edits go in separate sections of the same files, so a rebase causes no textual conflict.
- Coordination with #523 (wave 1, concurrent): #523 edits `validate_orchestrator_state.py` and `.agents/`/Codex skill documents. #509 does not edit `validate_orchestrator_state.py`. Edits to `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, and `.codex/agents/orchestrator.toml` are limited to the receipt-requirement text to reduce the risk of overlapping hunks.
- Epic substitution: until #509 merges into the integration branch, this child records its own `potential_to_issue` substitution under `human_interaction.requirements[]` citing #509, per the epic's Shared Design.

### Implementation strategy

#### Step 1 (mandatory, first): behavior-preserving Python module split

Move code verbatim; change no behavior.

| Module | Contents |
| --- | --- |
| `scripts/dev_tools/_orchestrator_state_route_gates.py` (new) | `ROUTING_MATRIX_PATH`, `PR_GATE_KEYS`, `MANDATORY_ROUTE_PHASES`, `load_routing_matrix`, `_selected_route_id`, `route_requires_pr_gate`, `route_requires_ci_gate`, `validate_route_membership`, `validate_phase_completeness`, `_missing_pr_gate_keys`, `validate_completion_pr_gate`, `_string_list` |
| `scripts/dev_tools/_orchestrator_state_promotion_tools.py` (new) | `FEATURE_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_ENTRY_TOOL`, `_resolve_promotion_entry_tools` |
| `scripts/dev_tools/_orchestrator_state_routing.py` (reduced) | re-export block with `__all__` (following the precedent in `_orchestrator_state_human_interaction.py` lines 36-42, as required by Pyright strict), `_route_list`, `_state_list`, `_list_receipts`, `_receipt_agents`, `_receipt_skills`, `_mcp_tools`, `_validate_empty_list_field`, `_validate_lifecycle_operations`, `validate_routing_contract` |

`ROUTING_MATRIX_PATH` keeps `Path(__file__).resolve().parents[2]`, which resolves identically from a sibling module. The split is verified before any behavior change by the unchanged existing suites plus a new identity test.

#### Step 2: Python adoption resolver

New `scripts/dev_tools/_orchestrator_state_issue_adoption.py`:

- Constants: `ISSUE_ADOPTION_KEY = "issue_adoption"`, `POTENTIAL_TO_ISSUE_TOOL = "potential_to_issue"`, the `origin` and `verified_via` enumerations, and `WAIVABLE_TOOLS = {potential_to_issue, FEATURE_PROMOTION_ENTRY_TOOL, BUG_PROMOTION_ENTRY_TOOL}` built from the constants imported from `_orchestrator_state_promotion_tools`.
- `resolve_issue_adoption(state, *, route_id, required_mcp_tools, successful_tools) -> IssueAdoptionResult`, a pure function. `IssueAdoptionResult` is a frozen dataclass with `errors: tuple[str, ...]` and `waived_tools: frozenset[str]`.
- Imports only from `_orchestrator_state_promotion_tools` (and the standard library).

`validate_routing_contract` passes the resolved `required_mcp_tools` and the `_mcp_tools(state)` set, skips waived tools in the receipt loop only when `result.errors` is empty, and appends `result.errors` after the receipt loop and before the `local_execution_overrides` errors.

#### Step 3: PowerShell mirror

- New `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` exporting `Get-OrchestratorStateIssueAdoptionResult -State -RouteId -RequiredMcpTool -SuccessfulTool`, returning `@{ Errors; WaivedTools }`, importing `OrchestratorStateCheckpointValue.psm1` with `-ErrorAction Stop`.
- `OrchestratorStateRoutingContract.psm1` imports it, wires it into `Get-OrchestratorStateRoutingContractError` at the same position as Python, and adds a C6.15 row to the parity header inventory.
- Both files are copied byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/` in the same commit.
- Registration of the new module in: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `$script:ExpectedPaths` in `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1`; the coverage list in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; and its bundled twin `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- String comparisons use case-sensitive operators (`-ceq`, `-ccontains`, `-cmatch`).

#### Step 4: TypeScript mirror

- New `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts` exporting `resolveIssueAdoption(state, { routeId, requiredMcpTools, successfulTools }): { errors: string[]; waivedTools: ReadonlySet<string> }`, importing constants from `./orchestrator-state-promotion-tools`.
- `orchestrator-state-routing.ts` `validateRoutingContract` wires it in at the same position as Python.
- `extensions/drm-copilot/jest.config.cjs` gains a per-file threshold entry for the new file (lines 85, branches 75), because the config has no global threshold and an unlisted file is ungated.

#### Step 5: fixtures, parity readers, documentation

See "Test Strategy" and "Documentation surfaces".

#### Files/modules to change

- Python production: edit `scripts/dev_tools/_orchestrator_state_routing.py`; new `_orchestrator_state_route_gates.py`, `_orchestrator_state_promotion_tools.py`, `_orchestrator_state_issue_adoption.py`.
- Python tests: new `tests/scripts/dev_tools/test_orchestrator_state_routing_split.py`, `test_orchestrator_state_issue_adoption.py`, `test_validate_orchestrator_state_issue_adoption.py`, `test_orchestrator_state_issue_adoption_parity.py`.
- Fixtures: new `tests/fixtures/orchestrator_state_issue_adoption/*.json`.
- PowerShell production (each with bundled copy): new `OrchestratorStateIssueAdoption.psm1`; edit `OrchestratorStateRoutingContract.psm1`.
- PowerShell registration: `core.json`, both `pester.runsettings.psd1` files, `OrchestratorState.Manifest.Tests.ps1`.
- Pester tests: new `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`, `OrchestratorStateIssueAdoption.Parity.Tests.ps1`.
- TypeScript: new `src/lib/validate/orchestrator-state-issue-adoption.ts`; edit `src/lib/validate/orchestrator-state-routing.ts`, `jest.config.cjs`; new `test/lib/validate/orchestrator-state-issue-adoption.test.ts`, `orchestrator-state-issue-adoption-parity.test.ts`.
- Documentation: see "Documentation surfaces".

#### Documentation surfaces

| Path | Change | Mirror and parity test |
| --- | --- | --- |
| `.claude/rules/orchestrator-state.md` | Add an `issue_adoption` scope, field invariants, waiver and fail-closed rules, an honest-disclosure paragraph (declaration, not proof, matching the `standalone_merge_authorizations` precedent), and an Enforcement bullet. | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`; `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` |
| `.claude/skills/orchestrate/SKILL.md` | In `## Routing-Contract Receipt Emission` / `### mcp_call_receipts[]`, document when to record `issue_adoption` instead of a `potential_to_issue` receipt. | bundled copy under `claude-customizations/.claude/skills/orchestrate/`; same test |
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | Document the pre-existing-issue path: skip `potential_to_issue`, verify the issue read-only, record `issue_adoption`. | bundled copy under `claude-customizations/`; same test |
| `.agents/skills/orchestrate/SKILL.md` | Receipt list (lines 284-300): add the adoption exception. | `codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`; `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` |
| `.agents/skills/feature-promotion-lifecycle/SKILL.md` | Step 5 (line 86): add the pre-existing-issue path. | bundled copy under `codex-and-agents-customizations/`; same test |
| `.agents/skills/orchestrator-workflow/SKILL.md` | Lines 200-201 and 407: qualify the receipt requirement with the adoption exception. | same codex-and-agents bundle test |
| `.codex/agents/orchestrator.toml` | Line 160: qualify the receipt requirement with the adoption exception; regenerate variants. | `test_generate_codex_agent_variants.py::test_checked_in_variants_match_generator_output_in_both_surfaces`, plus the codex-and-agents bundle test |

#### Error handling and logging updates

No logging changes. All new behavior is expressed as validator error strings (below). Errors accumulate; only rule 1 stops evaluation of the object.

#### Rollback considerations

The change is additive and presence-gated. Reverting the commit restores prior behavior; checkpoints that never used `issue_adoption` are unaffected either way. A checkpoint that relies on `issue_adoption` fails the gate after a revert with the pre-existing missing-receipt error, which is the intended fail-closed outcome.

### Technical specifications

#### `issue_adoption` schema

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

| Field | Rule |
| --- | --- |
| `issue_num` | String of ASCII decimal digits with no leading zero. Pattern: Python `re.fullmatch(r"[1-9][0-9]*", s)`; TypeScript `/^[1-9][0-9]*$/`; PowerShell `-cmatch '\A[1-9][0-9]*\z'`. A JSON number (for example `509` or `509.0`) is invalid. When the checkpoint's `issue-num` is a string, `issue_num` must equal it ordinally. |
| `issue_url` | String ending with `/issues/` followed by `issue_num`. Invalid whenever `issue_num` is invalid. |
| `origin` | One of `transferred`, `filed_before_orchestration`, `epic_decomposition`. |
| `verified_via` | One of `gh_issue_view`, `gh_api_get`, `github_mcp_issue_read`. |
| `verified_at` | Presence-only: not absent, not `null`, not a blank string. No format check, because PowerShell `ConvertFrom-Json` coerces ISO-8601 strings to `System.DateTime` and post-parse repair is prohibited (`OrchestratorState.psm1` 145-152). |
| `evidence` | Non-blank string. |
| `waived_tools` | Non-empty list whose elements are all non-blank strings (`_string_list` semantics). |
| `potential_record` | Required only when `waived_tools` names `new_potential_entry` or `new_potential_bug_entry`: a string starting with `docs/features/potential/` and ending with `.md`. Ignored otherwise. |
| other keys | Ignored, consistent with `human_interaction`. |

#### Validation rules (fixed order; errors accumulate)

Let `resolved` be the route's `required_mcp_tools` after promotion-type resolution (#405), `successful` the harvested successful-receipt set, and `route_id` the selected route id. The rules run only when the key `issue_adoption` is present.

1. Value is not an object (including `null`): `Checkpoint issue_adoption must be an object when present.` Evaluation of the object stops.
2. `issue_num` invalid: `Checkpoint issue_adoption.issue_num must be a string of decimal digits without a leading zero.` Otherwise, if the checkpoint `issue-num` is a string and not ordinally equal: `Checkpoint issue_adoption.issue_num must equal the checkpoint issue-num.`
3. `issue_url` invalid, or `issue_num` invalid: `Checkpoint issue_adoption.issue_url must end with /issues/ followed by issue_num.`
4. `origin` invalid: `Checkpoint issue_adoption.origin must be one of transferred, filed_before_orchestration, epic_decomposition.`
5. `verified_via` invalid: `Checkpoint issue_adoption.verified_via must be one of gh_issue_view, gh_api_get, github_mcp_issue_read.`
6. `verified_at` absent, `null`, or blank string: `Checkpoint issue_adoption.verified_at must be present.`
7. `evidence` invalid: `Checkpoint issue_adoption.evidence must be a non-empty string.`
8. `waived_tools` malformed or empty: `Checkpoint issue_adoption.waived_tools must be a non-empty list of tool names.` Otherwise, for each entry in list order, the first matching rule applies:
   - already seen earlier in the list: `Checkpoint issue_adoption.waived_tools lists a tool more than once: {tool}.`
   - not in `{potential_to_issue, new_potential_entry, new_potential_bug_entry}`: `Checkpoint issue_adoption.waived_tools names a tool that cannot be waived: {tool}.`
   - not in `resolved`: `Checkpoint issue_adoption.waived_tools names a tool that is not required by route {route_id}: {tool}.`
   - in `successful`: `Checkpoint issue_adoption.waived_tools names a tool that has a successful MCP receipt: {tool}.`

   Then, if `potential_to_issue` is not in the list: `Checkpoint issue_adoption.waived_tools must include potential_to_issue.`
9. For each distinct promotion-entry tool (`new_potential_entry`, `new_potential_bug_entry`) named in a well-formed `waived_tools`, in list order, when `potential_record` is invalid: `Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving {tool}.`

Messages interpolate only validated tool names and the route id. No raw checkpoint value is rendered, which avoids cross-runtime repr divergence. All comparisons are ordinal and case-sensitive.

#### Waiver semantics

- The waivable set is closed: `potential_to_issue` (mandatory in `waived_tools`) and the promotion-type-resolved potential-entry tool (`new_potential_entry` for feature or absent promotion type; `new_potential_bug_entry` for `promotion-type: "bug"`). Because rule 8 checks membership in `resolved`, a bug checkpoint that names `new_potential_entry` receives the "not required by route" error.
- Never waivable: `new_active_feature_folder`, `validate_orchestration_artifacts`, `collect_pr_context`, and every other tool outside the closed set; any tool not in `resolved`; any tool that already has a successful receipt; and duplicate entries.
- Fail-closed: `waived_tools` takes effect only when the adoption error list is empty. With any adoption error, nothing is waived, and the checkpoint receives both the adoption errors and the unchanged `Checkpoint missing successful MCP receipt: <tool>.` errors for each resolved tool lacking a receipt.
- Error placement: adoption errors follow the MCP receipt-loop errors and precede the `local_execution_overrides` errors in all three runtimes.

#### Inputs/outputs and formats

Input: parsed checkpoint JSON. Output: the existing ordered error list of each runtime's routing-contract function, extended as above. No CLI flag, exit code, or MCP tool schema changes.

#### Required configuration keys and defaults

None. `config/orchestration-routing.json` is unchanged; `issue_adoption` is optional and defaults to absent.

#### Backward-compatibility expectations

Checkpoints without `issue_adoption` produce byte-identical ordered validator output in Python, PowerShell, and TypeScript. The Python module import surface is unchanged.

#### Performance constraints

The resolver is linear in the length of `waived_tools` and `required_mcp_tools`, with no I/O. No measurable change is expected.

## Assumptions, Constraints, Dependencies

- Assumptions: #405 has merged into the integration branch before #509 implementation begins, so `orchestrator-state-promotion-tools.ts` exists. Checkpoints store `issue-num` as a string.
- Constraints:
  - No enforcement hook gains a Python leg; no `.claude/hooks/*` file is edited.
  - `.claude/hooks/enforce-powershell-batch-budget.ps1` (#769) is not touched. Phases are sized to fit the batch budget noted by #464 (at most 3 production and 3 test files per phase).
  - No conflicting edits with #464's new modules (`_orchestrator_state_remediation_loop.py`, `validate_orchestrator_state_cli.py`) or with `validate_orchestrator_state.py`.
  - Every production and test file stays below 500 lines.
  - Line coverage >= 85% and branch coverage >= 75% where the tooling measures branch coverage (Pester line-only).
  - Python coverage commands use dotted module targets (`--cov=scripts.dev_tools.<module>`) with `--cov-report=term-missing`; path-form `--cov=<path>.py` measures nothing and is not accepted as evidence.
  - No test creates temporary files: fixtures are committed JSON; Pester unit tests use in-memory JSON strings.
  - `hypothesis` and `fast-check` are not available; T1/T2 property-density obligations are met with deterministic fixed-grid invariant tests, as in #405.
- External dependencies: none new.

## Data / API / Config Impact

- User-facing or API changes: new optional checkpoint field `issue_adoption`; new validator error strings listed above.
- Data or migration considerations: none; the field is additive.
- Logging/telemetry updates: none.
- Compatibility notes: no CLI flag, MCP schema, or routing-matrix change. PowerShell bundle byte identity is maintained.

## Test Strategy

### Python

- `tests/scripts/dev_tools/test_orchestrator_state_routing_split.py`: asserts that each re-exported name in `_orchestrator_state_routing` is the identical object (`is`) to its definition in `_orchestrator_state_route_gates` or `_orchestrator_state_promotion_tools`, and that `__all__` lists them.
- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py`: unit tests for every rule and message, plus a fixed-grid invariant test (for example: for every combination on a fixed grid of field validity, a non-empty `errors` implies an empty `waived_tools`; an absent key always yields empty errors and waivers).
- `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py`: full-validator regression, written to fail before the fix: a `large` checkpoint with a valid `issue_adoption` and no `potential_to_issue` receipt, validated with `require_complete`, yields `[]`.
- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`: corpus reader calling `validate_routing_contract(checkpoint)`.

### Shared fixtures

`tests/fixtures/orchestrator_state_issue_adoption/*.json` with shape `{name, notes, checkpoint, expected_errors}` (the #405 shape). Python and TypeScript use the real `config/orchestration-routing.json`; PowerShell uses its pinned matrix. The minimum corpus contains: a valid adoption on `large`; a bug `large` checkpoint waiving `new_potential_bug_entry` with `potential_record`; a valid adoption on `preparation`; an absent key (baseline missing-receipt error); a `null` object; one case per rule 2-9; waiving `new_active_feature_folder`; waiving `validate_orchestration_artifacts`; waiving `new_potential_entry` on a bug checkpoint; waiving a tool with a successful receipt; an adoption on the `remediation` route (tool not required); a duplicate entry; and an integer `issue_num`. Each reader asserts ordered equality with `expected_errors` and carries a minimum-corpus-size guard.

### PowerShell

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`: unit tests for `Get-OrchestratorStateIssueAdoptionResult`.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1`: discovery-time `-ForEach` corpus reader calling `Get-OrchestratorStateRoutingContractError -State`.
- `OrchestratorState.Manifest.Tests.ps1`: `ExpectedPaths` addition; the existing bundle byte-identity test stays green.

### TypeScript

- `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts`: unit tests for `resolveIssueAdoption`.
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts`: corpus reader calling `validateRoutingContract(checkpoint, { routingMatrix })` directly (not through `orchestrator-state-core.ts`, whose ordering differs).
- `orchestrator-state-routing.test.ts` is not extended (#405 constraint).

### Toolchain commands

- Python baseline (before the split): `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py tests/scripts/dev_tools/test_validate_orchestrator_state_preparation_route.py --cov=scripts.dev_tools._orchestrator_state_routing --cov-branch --cov-report=term-missing`
- Python after the change: `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools._orchestrator_state_routing --cov=scripts.dev_tools._orchestrator_state_route_gates --cov=scripts.dev_tools._orchestrator_state_promotion_tools --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing`
- Python format, lint, type check: Black, Ruff, Pyright (strict) over changed files.
- Bundle and registration: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py`
- TypeScript (in `extensions/drm-copilot`, after `npm ci`): `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit -- test/lib/validate`, `npm run test:coverage -- --coverageReporters=text`.
- Pester: MCP `run_poshqc_test` with `scan_folders: ["tests/scripts/claude-lib/orchestrator-state"]` for pass/fail. The MCP runner returns no counts and reads the installed extension's settings. PowerShell line coverage for the new module is therefore taken from the CI `_poshqc.yml` artifact `artifacts/pester/powershell-coverage.xml`. A `COVERAGE-UNMEASURED` disposition is not acceptable, because a PowerShell production file changes.

## Acceptance Criteria

- [x] AC-1: `scripts/dev_tools/_orchestrator_state_routing.py` is split into `_orchestrator_state_route_gates.py`, `_orchestrator_state_promotion_tools.py`, and the reduced `_orchestrator_state_routing.py` as the first implementation step, and the commit containing the split changes no behavior: `test_validate_orchestrator_state_routing_contract.py` and `test_validate_orchestrator_state_preparation_route.py` pass unmodified at that commit.
- [ ] AC-2: Every Python, PowerShell, and TypeScript production and test file created or modified by this change is below 500 lines, including the reduced `_orchestrator_state_routing.py`, `OrchestratorStateRoutingContract.psm1`, and `orchestrator-state-routing.ts` (verified by a line count of each file, recorded in the evidence).
- [x] AC-3: `tests/scripts/dev_tools/test_orchestrator_state_routing_split.py` passes. It asserts object identity (`is`) between each re-exported name in `_orchestrator_state_routing` and its definition in the new module, and each name is listed in `__all__`.
- [x] AC-4: None of the nine Python files that import `scripts.dev_tools._orchestrator_state_routing` (research Claim N2) is edited, and all their test modules pass; `_receipt_agents`, `_receipt_skills`, and `_mcp_tools` remain defined in `_orchestrator_state_routing.py`; neither `_orchestrator_state_route_gates.py`, `_orchestrator_state_promotion_tools.py`, nor `_orchestrator_state_issue_adoption.py` imports `_orchestrator_state_routing`.
- [x] AC-5: `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py` contains a full-validator regression test that fails before the fix. After the fix it passes: a `large`-route checkpoint with a valid `issue_adoption` waiving `potential_to_issue` and no `potential_to_issue` receipt, validated with `require_complete`, returns an empty error list.
- [x] AC-6: Positive schema cases pass in `test_orchestrator_state_issue_adoption.py`, each yielding no adoption errors and the stated waiver set: a feature checkpoint waiving `potential_to_issue`; a feature checkpoint waiving `potential_to_issue` and `new_potential_entry` with a valid `potential_record`; a bug checkpoint waiving `potential_to_issue` and `new_potential_bug_entry` with a valid `potential_record`; a `preparation`-route checkpoint; every `origin` value; every `verified_via` value.
- [x] AC-7: Negative schema cases in `test_orchestrator_state_issue_adoption.py` each emit exactly the specified message string. This covers every error in validation rules 1-9, including a non-object and a `null` value, integer `issue_num`, leading-zero `issue_num`, `issue_num` not equal to a string `issue-num`, a mismatched `issue_url`, an unknown `origin`, an unknown `verified_via`, absent/`null`/blank `verified_at`, blank `evidence`, empty or malformed `waived_tools`, `waived_tools` without `potential_to_issue`, and an invalid `potential_record` when waiving a promotion-entry tool.
- [x] AC-8: Never-waivable tools are rejected by named tests: waiving `new_active_feature_folder` and waiving `validate_orchestration_artifacts` each emit `names a tool that cannot be waived`; waiving `new_potential_entry` on a `promotion-type: "bug"` checkpoint emits `names a tool that is not required by route large`; waiving `potential_to_issue` on the `remediation` route emits `names a tool that is not required by route remediation`; waiving a tool that has a successful receipt emits `names a tool that has a successful MCP receipt`; a duplicate entry emits `lists a tool more than once`.
- [ ] AC-9: Fail-closed behavior is verified by a named test in each runtime: a checkpoint with any adoption error and no `potential_to_issue` receipt receives both the adoption error(s) and `Checkpoint missing successful MCP receipt: potential_to_issue.`, with adoption errors placed after the receipt-loop errors and before the `local_execution_overrides` errors. A fixed-grid invariant test in `test_orchestrator_state_issue_adoption.py` asserts that a non-empty `errors` always implies an empty `waived_tools`.
- [x] AC-10: The declared `required_mcp_tools` equality check is unchanged under adoption: a checkpoint with a valid `issue_adoption` whose declared `required_mcp_tools` omits `potential_to_issue` still receives the existing equality error (named test in `test_orchestrator_state_issue_adoption.py` or `test_validate_orchestrator_state_issue_adoption.py`).
- [ ] AC-11: Presence gating produces byte-identical output: in each runtime, a named test shows that the routing-contract function returns no adoption errors and no waivers when `issue_adoption` is absent. The pre-existing routing-contract suites pass without modification: Python `test_validate_orchestrator_state_routing_contract.py` and `test_validate_orchestrator_state_preparation_route.py`, TypeScript `orchestrator-state-routing.test.ts`, `orchestrator-state-core.completion.test.ts`, `orchestrator-state-preparation-route.test.ts`, and #405's promotion-type parity tests, and the existing Pester orchestrator-state suites. The absent-key fixture in the shared corpus produces the same ordered error list as before the change.
- [ ] AC-12: `tests/fixtures/orchestrator_state_issue_adoption/*.json` is committed with the `{name, notes, checkpoint, expected_errors}` shape and contains every corpus case listed under "Shared fixtures". `test_orchestrator_state_issue_adoption_parity.py`, `orchestrator-state-issue-adoption-parity.test.ts`, and `OrchestratorStateIssueAdoption.Parity.Tests.ps1` each read the same files, assert ordered equality with `expected_errors`, and enforce a minimum-corpus-size guard. All three pass.
- [ ] AC-13: The error-message strings in `_orchestrator_state_issue_adoption.py`, `orchestrator-state-issue-adoption.ts`, and `OrchestratorStateIssueAdoption.psm1` are identical to the strings in the "Validation rules" section, as shown by the parity corpus in AC-12 covering every rule.
- [ ] AC-14: The TypeScript adoption module imports its promotion-entry constants from `./orchestrator-state-promotion-tools`, and the Python adoption module imports them from `_orchestrator_state_promotion_tools`. Neither redefines the literal strings `new_potential_entry` or `new_potential_bug_entry`, and #405's `orchestrator-state-promotion-tools.ts` is not modified (verified by the diff and by #405's purity test still passing).
- [ ] AC-15: `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` and the modified `OrchestratorStateRoutingContract.psm1` are byte-identical to their copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/` in the same commit. `OrchestratorState.Manifest.Tests.ps1` (bundle mirror byte identity and `ExpectedPaths`) passes, as do `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_poshqc_bundled_parity.py`, with the new module registered in `core.json` and in both `pester.runsettings.psd1` files.
- [x] AC-16: `OrchestratorStateRoutingContract.psm1` carries a C6.15 parity-inventory header row for `issue_adoption`, and the PowerShell adoption module uses only case-sensitive comparison operators for tool names, enumerations, and `issue_num` (verified by review and by a case-variant test such as `Potential_To_Issue` being rejected).
- [ ] AC-17: Documentation is updated, and each bundled mirror matches its source: `.claude/rules/orchestrator-state.md` (scope, invariants, waiver and fail-closed rules, honest-disclosure paragraph, Enforcement bullet), `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md` (lines 200-201 and 407), and `.codex/agents/orchestrator.toml` (line 160, with regenerated variants). The bundle tests `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, and `test_checked_in_variants_match_generator_output_in_both_surfaces` pass.
- [ ] AC-18: The deferred surfaces (`.github/skills/feature-promotion-lifecycle/SKILL.md` and its `resources/customizations` copy) and the `enforce-promotion-mcp-only.ps1` read-only-inspection note are recorded as follow-ups (potential entries or issue references) in the feature folder's completion artifacts. Neither surface is edited by this change.
- [ ] AC-19: The diff contains no change under `.claude/hooks/`, no change to `.claude/hooks/enforce-powershell-batch-budget.ps1` or its tests, no change to `scripts/dev_tools/validate_orchestrator_state.py`, `_orchestrator_state_remediation_loop.py`, `validate_orchestrator_state_cli.py`, `orchestrator-state-core.ts`, `OrchestratorStateCompletion.psm1`, or `config/orchestration-routing.json`, and no new Python invocation in any enforcement hook (verified by `git diff --name-only` against the integration branch base).
- [ ] AC-20: The Python toolchain passes on changed files (Black, Ruff, Pyright strict, pytest). The dotted-module coverage command in "Toolchain commands" reports line coverage >= 85% and branch coverage >= 75% for each of `scripts.dev_tools._orchestrator_state_routing`, `_orchestrator_state_route_gates`, `_orchestrator_state_promotion_tools`, and `_orchestrator_state_issue_adoption`, with `--cov-report=term-missing` output recorded under `evidence/`.
- [ ] AC-21: The TypeScript toolchain passes in `extensions/drm-copilot` (`npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit -- test/lib/validate`). `jest.config.cjs` contains a per-file threshold entry for `src/lib/validate/orchestrator-state-issue-adoption.ts` (lines 85, branches 75), and `npm run test:coverage` meets it and the existing entry for `orchestrator-state-routing.ts`.
- [ ] AC-22: The Pester suites under `tests/scripts/claude-lib/orchestrator-state/` pass, and CI `_poshqc.yml` coverage output (`artifacts/pester/powershell-coverage.xml`) shows line coverage >= 85% for `OrchestratorStateIssueAdoption.psm1` and no reduction on the changed lines of `OrchestratorStateRoutingContract.psm1`. No test in any runtime creates a temporary file.

## Risks & Mitigations

- Risk: cross-runtime drift in message text or order. Mitigation: a single shared fixture corpus asserted by ordered equality in all three runtimes (AC-12, AC-13).
- Risk: the split changes behavior or breaks an importer. Mitigation: the split lands as its own step, verified by unmodified suites and identity tests before any behavior change (AC-1, AC-3, AC-4).
- Risk: an adoption record is fabricated. Mitigation: the record is structured and auditable, and it cannot waive tools outside the closed set or tools that already have receipts. The honest-disclosure paragraph states that the record is a declaration, not proof.
- Risk: rebase conflicts with #464 and #523 in shared documentation files. Mitigation: edits go in separate sections, and `validate_orchestrator_state.py` is not edited.
- Risk: PowerShell date coercion of `verified_at`. Mitigation: presence-only validation in all runtimes.
- Rollback: revert the commit; the change is presence-gated.

## Rollout & Follow-up

- Release/rollout: merges into `epic/orchestrator-state-contract-correctness-integration`. After merge, later epic waves (#484) may use `issue_adoption` instead of the `human_interaction.requirements[]` substitution.
- Follow-ups: `.github/skills/feature-promotion-lifecycle/SKILL.md` adoption path (Copilot surface); `enforce-promotion-mcp-only.ps1` blocking read-only inspection because it matches the tool name anywhere in a shell command; the TypeScript routing-contract/preparation-terminal ordering difference in `orchestrator-state-core.ts`; correcting the epic manifest `feature_folder` for #509.
- Links: issue #509; epic #771; dependency #405; coordination #464, #523; excluded #769, #343.
