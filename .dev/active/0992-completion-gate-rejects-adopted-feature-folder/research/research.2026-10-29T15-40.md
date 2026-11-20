# Research: completion gate rejects an adopted feature folder (Issue #992)

- Issue: #992
- Branch: `bug/completion-gate-rejects-adopted-feature-folder-992`
- Timestamp: 2026-10-29T15-40 (UTC). The researcher has no shell and could not read the host clock. The stamp is taken from the checkpoint `last_updated` (`2026-10-29T15:35:00Z`) plus the 15:36Z complexity assessment and is therefore approximate.
- Scope: research only. No production file was modified.
- Verification limits: this agent has Read, Grep, Glob, WebFetch, and Write only. File, line, and count facts below were read from the tree. Git semantics (section 2.4) are stated from git documentation knowledge and were not executed; the orchestrator must confirm them with a test run. Line counts are physical (`Grep` count of `""`).

## 1. Current state: where the receipt requirement and waivable set live

### 1.1 Receipt requirement (all runtimes read `mcp_call_receipts[]` only)

| Runtime | File and lines | Behavior |
| --- | --- | --- |
| Python (authority) | `scripts/dev_tools/_orchestrator_state_routing.py:130-152` (`_mcp_tools`), `:246-260` | A tool counts only when a `mcp_call_receipts[]` entry has non-blank `tool`, `ok is True`, non-blank `evidence`. For each `required_mcp_tools` entry not in `adoption.waived_tools` and not in that set it appends `Checkpoint missing successful MCP receipt: {tool}.` (`:259`). `adoption.errors` are appended after the loop (`:260`). |
| TypeScript | `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts:445-461` (`mcpTools(state)`, `resolveIssueAdoption`, loop, `errors.push(...adoption.errors)`) | Same logic; message at `:458`. |
| PowerShell | `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1:415-425` | `Get-CheckpointAcknowledgedName -ArrayKey 'mcp_call_receipts' -NameKey 'tool' -FlagKey 'ok'`, then `Get-OrchestratorStateIssueAdoptionResult` (`:418`); message at `:422`. |

`delegation_receipts.promotion.feature_folder` is only an allowed key of the namespaced `delegation_receipts` object (`.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1:59` `PROMOTION_RECEIPT_KEYS`, `:186`). Nothing in the routing contract reads it as an MCP receipt. This confirms the report that adding it there "was not enough".

Where the check is entered:
- Python: `scripts/dev_tools/validate_orchestrator_state.py:388-406` (`require_complete` calls `validate_routing_contract(state_map)` at `:406`). The entry point is text-only (`validate_orchestrator_state_text(text, ...)`, `:296`): no file path, no repo root, no git.
- Hook: `.claude/hooks/validate-orchestrator-output.ps1:312` calls `Invoke-RoutingContractValidation` (defined in `.claude/hooks/validate-orchestrator-output-routing.ps1:64-170`). Its default invoker runs `Test-OrchestratorStateCompletionReadiness` (`.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1:364-432`), which calls `Get-OrchestratorStateRoutingContractError` at `:418`. Errors surface as `ROUTING_CONTRACT_BLOCKED: <text>` (`validate-orchestrator-output.ps1:322`).
- The hook contains no copy of the receipt or waiver logic. A grep of the hook for `new_active_feature_folder`, `mcp_call_receipts`, `feature-folder`, and `issue_adoption` returned no matches. It is a thin dispatcher.
- Only `orchestrator-state` reaches the routing contract. `epic-orchestrator-state` and `parallel-orchestrator-state` get the structural check only (`validate-orchestrator-output-routing.ps1:133-141`), so they are unaffected.

### 1.2 Waivable set (closed, defined three times)

- Python: `scripts/dev_tools/_orchestrator_state_issue_adoption.py:62-66` (`WAIVABLE_TOOLS` = `potential_to_issue`, `FEATURE_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_ENTRY_TOOL`; the two entry constants come from `_orchestrator_state_promotion_tools.py`). Rule 8 in `_waived_tool_errors` (`:199-236`) emits, in this order per entry: duplicate, not in `WAIVABLE_TOOLS` ("cannot be waived", `:217-221`), not required by route (`:222-226`), already has a successful receipt (`:227-231`); then `ERROR_WAIVED_TOOLS_INCLUDE` when `potential_to_issue` is absent (`:234`). Rule 9 is `_potential_record_errors` (`:239-279`). Public entry `resolve_issue_adoption` at `:282-352`; it is fail-closed (`:350-352`).
- TypeScript: `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts:52-56` (set), `:197-229` (rule 8), `:231-271` (rule 9), `:285-324` (entry).
- PowerShell: `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1:42` (`$script:WAIVABLE_TOOLS`), `:203-259` (rule 8), `:261-317` (rule 9), `:319-393` (entry), error constants `:50-59`.
- Rule prose: `.claude/rules/orchestrator-state.md:258-295` (`## Issue-Adoption Scope...` and `## Invariants (issue_adoption object)`); the closed-set sentence is at `:291` ("`new_active_feature_folder` ... can never be waived"); enforcement bullet at `:308`.
- Bundle copies (byte-equal): `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` and `.../lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` and `.../OrchestratorStateRoutingContract.psm1`.

### 1.3 Shared corpus and tests that pin current behavior

Corpus: `tests/fixtures/orchestrator_state_issue_adoption/*.json` (34 files read). Each has `name` (= stem), `notes`, `checkpoint`, `expected_errors`. Consumers (all drive the public routing-contract function and compare the ordered error list):
- Python: `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` (222 lines; `MINIMUM_CORPUS_COUNT = 34` at `:46`; uses `validate_routing_contract`).
- TypeScript: `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts` (176 lines; `MINIMUM_CORPUS_COUNT`, `:149-150`).
- Pester: `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1` (111 lines; `$minimumFixtureCount = 34` at `:46`).

No corpus checkpoint carries a `feature-folder` key (grep count 0), so new cases must add it.

Tests asserting that `new_active_feature_folder` is non-waivable (these must change):
- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py:44-57` (`test_waiving_new_active_feature_folder_is_rejected`).
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts:331-337` (`describe` "enforces the closed waivable set (AC-8)", case at `:334-337`).
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1:272-274`.
- Corpus `tests/fixtures/orchestrator_state_issue_adoption/waives-new-active-feature-folder.json` (its `notes` and both `expected_errors`, lines 3 and 120-123; its checkpoint also holds a successful `new_active_feature_folder` receipt at lines 89-93).

Tests that stay valid because they put `new_active_feature_folder` in the receipt set, not the waived list: `test_orchestrator_state_issue_adoption_waivers.py:251`, the `NonWaivableSuccessful` set at `OrchestratorStateIssueAdoption.Tests.ps1:39`, `orchestrator_state_issue_adoption_test_support.py:57-63`. `waives-validate-orchestration-artifacts.json` and `case-variant-tool-name.json` keep pinning the non-waivable behavior for other tools.

Other pins on this surface: `tests/scripts/claude-runtime/` and `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` (pins the parallel-plan adoption blockquote and `SHARED_RECORD_FRAGMENTS` at `:63-67`, heading `## Invariants (issue_adoption object)` at `:50`); `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1:28-43` (explicit module path list); hook suites `tests/scripts/claude-hooks/validate-orchestrator-output*.Tests.ps1` (454, 330, 254, 250, 210, 201, 161, 138, 366 lines).

Checkpoint facts: `feature-folder` is in `REQUIRED_STATE_KEYS` (`validate_orchestrator_state.py:63`, `orchestrator-state-core.ts:70`, `OrchestratorState.psm1:47`) and real values are repo-relative, no trailing slash, e.g. `docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992` (this run's own checkpoint, line 11).

## 2. Smallest change that lets `issue_adoption` waive `new_active_feature_folder`

### 2.1 Design

Add `new_active_feature_folder` to the closed waivable set and add one evidence object inside `issue_adoption`, `feature_folder_record`. Waiving the tool requires a valid record. A separate hook-side probe (PowerShell hook only) verifies the folder against git.

Field shape (nested, parallels `potential_record` but is an object because it needs provenance):

```json
"issue_adoption": {
  "...existing fields...": "...",
  "waived_tools": ["potential_to_issue", "new_potential_bug_entry", "new_active_feature_folder"],
  "feature_folder_record": {
    "path": "docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992",
    "verified_via": "git_cat_file_head",
    "verified_at": "2026-10-29T15:35:00Z",
    "evidence": "git cat-file -t HEAD:docs/features/active/...-992 printed tree"
  }
}
```

`verified_via` is a closed set of two: `git_cat_file_head`, `git_ls_tree_head` (both HEAD-based, so a staged-only folder is not "committed").

### 2.2 Validation rules (new rules after rule 9, same accumulate-and-fail-closed model)

They run only when the rule-8 shape check passed (same gate as rule 9). Constants: `FEATURE_FOLDER_TOOL = "new_active_feature_folder"`, `FEATURE_FOLDER_PATH_PATTERN = ^docs/features/active/[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$` applied as a full match (Python `re.fullmatch`, JS `^...$` without the `m` flag, PowerShell `\A...\z` with `-cmatch`, the same technique as `ISSUE_NUM_PATTERN`). The pattern excludes dot segments, empty segments, trailing slash, backslash, drive letters, glob and pathspec characters, and a leading `-`, so one regex is both the format rule and the argument-safety rule for the hook probe.

| Rule | Condition | Error string (byte-identical in three runtimes) |
| --- | --- | --- |
| 10 | `new_active_feature_folder` in `waived_tools` and `feature_folder_record` absent or not an object | `Checkpoint issue_adoption.feature_folder_record must be an object when waiving new_active_feature_folder.` |
| 11a | record is an object and `path` is not a string matching the pattern | `Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without dot segments or a trailing slash.` |
| 11b | `path` valid and checkpoint `feature-folder` is not the identical string (absent, non-string, or different) | `Checkpoint issue_adoption.feature_folder_record.path must equal the checkpoint feature-folder.` |
| 11c | `verified_via` not in the two values | `Checkpoint issue_adoption.feature_folder_record.verified_via must be one of git_cat_file_head, git_ls_tree_head.` |
| 11d | `verified_at` absent, null, or blank string | `Checkpoint issue_adoption.feature_folder_record.verified_at must be present.` |
| 11e | `evidence` not a non-blank string | `Checkpoint issue_adoption.feature_folder_record.evidence must be a non-empty string.` |

Interaction with existing rules, unchanged: the tool must be required by the route (`remediation` does not require it, so rule 8 reports "not required by route"); a tool that already holds a successful receipt cannot be waived (existing rule-8 message); `potential_to_issue` must still be listed; duplicates still error; any error waives nothing, so the missing-receipt line is still emitted. Records are validated whenever present, including when the tool is not waived (matches the `potential_record` precedent; see open decision 4). The waived set returned on success includes the new tool, which makes the receipt loop skip it in all three runtimes with no change to the three receipt loops.

### 2.3 What the pure validators can and cannot check

Can check (all three runtimes, no I/O): the record's presence when waived, the path format, equality of `path` with the checkpoint `feature-folder`, closed-set provenance values, non-blank `verified_at` and `evidence`.

Cannot check: that the folder exists, that it is tracked or committed, that it was created by the tool, or that `verified_at` and `evidence` are true. Python and TypeScript entry points take text only (`validate_orchestrator_state_text`, `validateOrchestrationArtifacts`) with no repo root. These remain declarations. This matches the existing disclosure at `.claude/rules/orchestrator-state.md:262` for the issue.

### 2.4 Bounded git check in the hook (Claude runtime only)

Place: a new dot-sourced sibling `.claude/hooks/validate-orchestrator-output-feature-folder.ps1`, loaded with the same guarded pattern as lines 56-57 of `validate-orchestrator-output.ps1` (`try { . ... } catch { Add-HookDependencyFailure ... }`), called from `Get-OrchestratorOutputBlockDecision` immediately after `$routingResult.HasErrors` is false (`validate-orchestrator-output.ps1:313-323`) and only when `$ArtifactType -eq 'orchestrator-state'` and the already-parsed `$checkpoint` (`:269`) has `issue_adoption.waived_tools` containing `new_active_feature_folder`. The worktree root is already available as `$resolution.WorktreeRoot` (`:298`).

Seam: one wrapper `Invoke-FeatureFolderGitExe -GitArgs <string[]> [-GitInvoker <scriptblock>]` modeled on `Invoke-PrAuthorCurrentBranchGitExe` (`.claude/hooks/enforce-pr-author-skill.current-branch.ps1:32-63`): never throws, returns `@{ ExitCode; Output }`, `ExitCode = -1` when git cannot start. Tests inject a scriptblock (no real git, no `Mock` of the executable, per `.claude/rules/powershell.md`). A matching optional `-FeatureFolderGitInvoker` parameter is threaded through `Invoke-OrchestratorOutputValidation` and `Get-OrchestratorOutputBlockDecision`, following the existing `RoutingInvoker` pattern (`:197`, `:207`, `:238`).

Probe (single command, fixed arguments, no pathspec or glob semantics): `git -C <WorktreeRoot> cat-file -t HEAD:<checkpoint feature-folder>`. Pass only when ExitCode is 0 and trimmed Output equals `tree`. Git does not track empty directories, so a tree object at that path implies at least one committed file. Block (Repairable = $true) otherwise, with a hook-local message such as `ROUTING_CONTRACT_BLOCKED: Checkpoint feature-folder is not committed in HEAD: <path>.`. The path comes from the checkpoint (not from the record) and has already passed the regex through rule 11b; the hook re-applies the regex before invoking git as defense in depth.

Honesty: this proves only that HEAD of the run worktree has a tree at the path at stop time. It does not prove the tool created it, that its contents are correct, or that it belongs to the adopted issue. It runs only under the Claude `SubagentStop` hook. `validate_orchestration_artifacts` through MCP, the Python CLI, and Codex gates (no `.codex/hooks/validate-orchestrator-output*` exists; Glob returned nothing) stay declaration-only.

Required-failure matrix (how each is met):
- Missing folder: hook probe fails (git non-zero). Pinned by Pester with an injected invoker.
- Untracked or staged-only folder: `cat-file HEAD:<path>` fails. Same test.
- Path differs from checkpoint `feature-folder`: rule 11b in all three runtimes (corpus case).
- Waiver listed without evidence: rule 10 (no record) and 11e (blank evidence), corpus cases.
- Run that skips both promotion and adoption evidence: unchanged missing-receipt error (existing `absent-key-large-missing-receipt.json`).

## 3. Alternative: planner/adoption path writes the receipt itself

Description: the preparation child (or a parallel-orchestrate step) copies or writes `{tool: new_active_feature_folder, ok: true, evidence}` into the execution run's `mcp_call_receipts[]`. No validator change.

Advantages: no code change; the preparation child really did call the tool, so its own checkpoint holds a legitimate receipt (the issue says the run copied it by hand).

Limitations: (1) `mcp_call_receipts` is an audit of tool calls made by this checkpoint's run; a copied receipt asserts a call this run did not make, and no validator can tell a carried-forward receipt from a fabricated one. (2) It depends on an LLM following prose; the report shows that step was missed. (3) It does not cover a folder created by an earlier session through the raw CLI or by hand (no receipt exists to copy). (4) It adds no git verification, so a receipt can exist for a folder that is not committed. (5) It leaves the validators' semantics ("receipt means this run called the tool") confused.

Recommendation: reject it. Use the evidence-record design (section 2), which keeps receipts truthful and gives the hook something verifiable. A hook-only waiver (no new field) was also considered and rejected: the MCP and CLI validators run `--require-complete` in the orchestrator completion steps (for example `.codex/agents/orchestrator.toml:193`) and would still fail.

## 4. Test files and corpus

### 4.1 Existing tests to update (disposition)
- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py:44-57`: rewrite to the new behavior (waiving without a record yields the rule-10 error).
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts:331-337` and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1:272-274`: same.
- Corpus `waives-new-active-feature-folder.json`: keep the name, update `notes`, and rework the checkpoint (remove the successful `new_active_feature_folder` receipt at lines 89-93, add `feature-folder`) so the case pins rule 10 plus the fail-closed missing-receipt lines.
- Parity minima (`MINIMUM_CORPUS_COUNT`, `$minimumFixtureCount`): raise by the number of added fixtures. The exact value is withheld here (no numeric derivation is proposed for a spec acceptance criterion; the plan must derive it by a directory listing and a second independent enumeration).
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1:28-43`: add the new module path.
- `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`: re-run; the `Issue adoption:` blockquote fragments (`:77-81`) and `SHARED_RECORD_FRAGMENTS` (`:63-67`) must remain in any edited prose.

### 4.2 New corpus cases (checkpoints carry `feature-folder`; filenames to be chosen by the plan)
1. Large route, valid record, tool waived: no errors.
2. Bug-type preparation route, valid record: no errors.
3. Waived without `feature_folder_record`: rule 10 plus the fail-closed missing-receipt lines.
4. Record `path` differs from checkpoint `feature-folder`: 11b.
5. Record `path` outside `docs/features/active/`, with a dot segment, with a trailing slash: 11a (one or more cases).
6. Checkpoint `feature-folder` absent or non-string: 11b.
7. Unknown `verified_via`, blank `verified_at`, blank `evidence`: 11c-11e, in rule order, in one multi-error case.
8. Waived on the `remediation` route: existing "not required by route" message.
9. Waived while a successful `new_active_feature_folder` receipt exists: existing "has a successful MCP receipt" message.
10. Record present but tool not waived: depends on open decision 4.

### 4.3 New test files (to respect the 500-line tiers; see section 6)
- Python: `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py` (plus builders in the support module, 187 lines).
- TypeScript: `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts`.
- Pester module: `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1`.
- Pester hook: `tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1`: tree output allows; empty output blocks; non-zero exit blocks; invoker throw or `-1` blocks; no waiver means the invoker is never called; `epic-orchestrator-state` and `parallel-orchestrator-state` never call it; a path failing the regex never reaches git. Use `Join-Path`, forward-slash paths, no drive letters (Linux hook-suite job).

### 4.4 Cross-runtime byte-identical strings
The six strings in section 2.2 plus the existing rule 8 strings. All three production modules and all three parity suites compare ordered lists exactly. The hook-local block message is not part of the corpus and is pinned only by the hook Pester suite.

## 5. Mirror surfaces and prose

Byte-equal mirror rule: every `.claude` file below has a copy under `extensions/drm-copilot/resources/claude-customizations/.claude/` (`test_push_down_claude_resource_contracts.py`).

Code and manifest:
- New: `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1`, `.claude/hooks/validate-orchestrator-output-feature-folder.ps1`, `scripts/dev_tools/_orchestrator_state_feature_folder_record.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts`, each with its bundle copy where a `.claude` file.
- Edited: `scripts/dev_tools/_orchestrator_state_issue_adoption.py`, `_orchestrator_state_promotion_tools.py` (or a constant in the new module), `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`, `orchestrator-state-promotion-tools.ts`, `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`, `.claude/hooks/validate-orchestrator-output.ps1`, and bundle copies.
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (the hook sibling is listed at line 88 beside the routing sibling; the module list is at about line 176): add both new `.claude` files, otherwise `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` fail. `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` checks the guarded dot-source pattern.
- `extensions/drm-copilot/jest.config.cjs`: a per-file `coverageThreshold` entry for the new TypeScript file.
- No `.codex` hook or lib mirror exists for this hook. Codex surface: `.codex/agents/orchestrator*.toml` (line 163 states generically "unless a valid `issue_adoption` record waives it") and `.agents/skills/orchestrate/SKILL.md:303`, `.agents/skills/orchestrator-workflow/SKILL.md:208,422` are generic and need no edit. If any Codex agent file is edited, run the Codex generator `--check`.
- `.github`: `.github/skills/feature-promotion-lifecycle/SKILL.md` has no `issue_adoption` text (absent from the grep), so no edit is required.

Rule prose:
- `.claude/rules/orchestrator-state.md`: the object-shape sentence (`:266`), the field table (`:268-277`), the ordered rules list (`:279-289`, add rules 10-11), the closed-set sentence (`:291`, remove `new_active_feature_folder` from the "can never be waived" list), the fail-closed paragraph (`:295`), an honest-disclosure sentence about the hook probe near `:262`, and the enforcement bullet (`:308`, name the new modules and the hook sibling). Mirror to the bundle copy.

Skill prose (each with bundle copy):
- `.claude/skills/orchestrate/SKILL.md:462` (waivable-tool sentence "It may waive only `potential_to_issue` and the checkpoint's promotion-entry tool ...").
- `.claude/skills/feature-promotion-lifecycle/SKILL.md:48,51`; `.agents/skills/feature-promotion-lifecycle/SKILL.md:86` and its bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/`.
- `.claude/skills/parallel-plan/SKILL.md:47,116` (the adoption blockquote; pinned by `test_parallel_issue_adoption_skill_contracts.py`), `.claude/skills/parallel-add/SKILL.md:68`, `.claude/skills/parallel-orchestrate/SKILL.md:262` (kickoff element 4: instruct the execution child to record `feature_folder_record` when the preparation child already created and committed the folder).
- `.claude/skills/execution-environment/SKILL.md`: states no fact this change alters; no edit.

## 6. File-size concerns (physical lines before the change)

| File | Lines | Plan |
| --- | --- | --- |
| `scripts/dev_tools/_orchestrator_state_issue_adoption.py` | 352 | Small edit (set entry, import, one call). Put rules 10-11 in the new module. |
| `scripts/dev_tools/_orchestrator_state_promotion_tools.py` | 95 | Optional constant. |
| `scripts/dev_tools/_orchestrator_state_routing.py` | 265 | No change. |
| `extensions/.../orchestrator-state-issue-adoption.ts` | 324 | Small edit; new module for the rules. |
| `extensions/.../orchestrator-state-routing.ts` | 467 | No change. |
| `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` | 396 | Small edit; new module for the rules. |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | 438 | No change expected. |
| `.claude/hooks/validate-orchestrator-output.ps1` | 346 | About 12-20 added lines. |
| `.claude/hooks/validate-orchestrator-output-routing.ps1` | 170 | No change. |
| `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | 462 | Do not add; new file. |
| `.../test_orchestrator_state_issue_adoption_waivers.py` | 338 | Edit one test only. |
| `extensions/.../orchestrator-state-issue-adoption.test.ts` | 477 | Edit one case only; new file for the rest. |
| `.../OrchestratorStateIssueAdoption.Tests.ps1` | 437 | Edit one case only; new file for the rest. |
| `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` | 454 | Do not add; new file. |

Markdown rule and skill files are exempt. New modules are expected to stay well under 200 lines.

## 7. Automation Feasibility

No human step is required. Implementation, mirroring, fixtures, and tests are file edits by an executor. The git probe is exercised in tests through an injected scriptblock, so no real git or network is needed. The Pester hook suite runs under the existing PoshQC shards and the Linux hook-suite job. Toolchain runs through the PoshQC MCP tools (results carry no output; read `artifacts/pester/pester-junit.xml`), `poetry run` for Python, and `node run-jest.cjs` for Jest. The only live-environment confirmation is a one-time check of the `git cat-file -t HEAD:<path>` output on a real worktree, which the orchestrator can run through `sh <file>.sh` or a direct Bash call; it is not a human step.

## 8. Open decisions and recommended defaults

1. Field location: nested `issue_adoption.feature_folder_record` (default) versus a top-level key. Default keeps the waiver and its evidence in one fail-closed object.
2. Probe: `git cat-file -t HEAD:<path>` expecting `tree` (default) versus `git ls-tree -r --name-only HEAD -- <path>`. Default avoids pathspec semantics. Confirm output on a real worktree.
3. Allowed path prefix: `docs/features/active/` only (default). Add `docs/features/completed/` or epic locations only if a real run needs it.
4. Validate `feature_folder_record` whenever present (default, like `potential_record`) versus only when waived.
5. `potential_to_issue` must still be listed in `waived_tools` (default; no change to rule 8).
6. Hook requires a specific file such as `<path>/issue.md` in the tree: no (default); any committed tree suffices.
7. Checkpoint `feature-folder` absent or non-string while waiving: error (default, stricter than the `issue-num` equality rule).
8. Hook block text keeps the `ROUTING_CONTRACT_BLOCKED:` prefix and is Repairable (default).
9. Codex and MCP-only gates stay declaration-only (default); a Codex hook port is a separate decision for the orchestrator to file only if wanted.
10. Self-application: this run's own checkpoint adopts issue 992 and a pre-existing folder (`artifacts/orchestration/orchestrator-state.json` lines 10-11, 27-34), so it will hit the same block at DONE until the fix is in the hook copy the stop hook runs. Default: the orchestrator records `feature_folder_record` in its own checkpoint after the change lands in the worktree and confirms which hook copy runs; do not hand-copy a receipt.

## Rejected alternatives (brief)
- Carry or write the receipt (section 3).
- Hook-only waiver without a checkpoint field (MCP and CLI validators would still fail).
- Git or filesystem reads inside the Python, TypeScript, or PowerShell validators (breaks the pure, text-only, three-runtime parity contract documented at the top of each adoption module).

## Pre-Mortem

- Review checklists: a reviewer could find an error string that differs by one character across Python, TypeScript, and PowerShell, or prose that still says `new_active_feature_folder` can never be waived. Mitigation: define the six strings once in the plan, assert them through the shared corpus in all three parity suites, and grep the rule, skills, and bundle copies for the old closed-set wording before review.
- Coverage: the new TypeScript file has no `coverageThreshold` entry and the hook sibling's failure branches (throw, `-1`, empty output) may go unexercised. Mitigation: add the jest.config.cjs entry in the same task, and list one Pester `It` per branch of the hook sibling and per rule 10-11 branch in each runtime; read per-file figures from the JSON, Pester coverage XML, and Jest output, not from MCP summaries.
- Mirror parity: every `.claude` file has a bundle copy, the two new files must be in `core.json`, and the pack-closure test requires the hook sibling in core. Mitigation: a task lists each of the bundle copies and `core.json`, then runs the push-down resource, manifest-completeness, dependency-closure, and `OrchestratorState.Manifest.Tests.ps1` suites; the brief `execution-environment` states no changed fact, so no six-copy brief update is needed (the plan's Mirror parity note must say so).
- File size: `test_orchestrator_state_issue_adoption.py` (462), the TS adoption test (477), the Pester adoption test (437), and `validate-orchestrator-output.Tests.ps1` (454) would cross 500 if extended. Mitigation: put new tests only in the new files named in section 4.3 and add production rules in the new modules.
- Test isolation: hook tests could be written with a real `git` call or a temp checkout, which fails on the Linux hook-suite job and violates the no-temp-file rule. Mitigation: inject a scriptblock invoker for every probe, no `Mock` of `git`, no drive letters; run the seeded shuffled Pester runs, the reversed-order Python run, and the seeded Jest shuffle recorded under `evidence/regression-testing/`.
- CI-only behavior: a test that reads this worktree's gitignored `artifacts/` checkpoint passes locally and fails in CI; the real `git cat-file` output on CI's depth-one or Linux checkouts is also untested. Mitigation: use in-memory checkpoint JSON only, keep the probe entirely behind the seam, and have the orchestrator confirm the real probe once locally.
- Evidence: PoshQC MCP results carry no output and the MCP validator applies the installed extension, so a plan that asserts counts or new rules from those results is unsatisfiable. Mitigation: take Pester counts from the JUnit file, coverage from the coverage XML, run branch-current plan validation through the Python CLI, and record command, exit code, and summary under `<FEATURE>/evidence/<kind>/`.
