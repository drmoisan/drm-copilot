# completion-gate-rejects-adopted-feature-folder (Spec)

- **Issue:** #992
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-29T16-00
- **Status:** Draft
- **Version:** 0.2

## Context
The orchestrator completion gate requires a successful `new_active_feature_folder` MCP receipt in the finishing run's own checkpoint. An item whose issue and feature folder were created before the run started (by an earlier session, `/orchestrate` pause, or the parallel planner) cannot satisfy that check, although the folder exists and is committed. The `issue_adoption` waiver covers `potential_to_issue` and `new_potential_bug_entry` only.

Environment:
- OS/version: Windows 11
- Python version: not applicable
- Command/flags used: `.claude/hooks/validate-orchestrator-output.ps1` (SubagentStop) and `validate_orchestration_artifacts.py orchestrator-state --require-complete`
- Data source or fixture: parallel run `pr-author-and-file-size`, item #989 (PR #991)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Any item prepared outside its execution run stalls at the final gate and needs manual checkpoint editing. This affects every parallel or epic run whose items are prepared by a planner or an earlier session.


## Repro & Evidence
Steps to Reproduce:
1. Promote an item and create its feature folder in one session, then pause the orchestration and move its checkpoint to `artifacts/orchestration/handoff/`.
2. Include the item in a parallel run. The planner prepares it and the execution run adopts the existing issue (`issue_adoption`, waiving the two promotion tools).
3. Let the execution run reach DONE with PR open and CI green.

Expected:
An existing, committed feature folder is accepted as adopted work, with the same kind of evidence that `issue_adoption` accepts for the issue. The run reaches DONE.

Actual:
The stop hook returned `ROUTING_CONTRACT_BLOCKED: Checkpoint missing successful MCP receipt: new_active_feature_folder.` The run's own residual note records that the tool is outside the waivable set. The run could not record DONE until the receipt was copied by hand from the earlier checkpoint. Adding it under `delegation_receipts.promotion.feature_folder` was not enough; the check reads `mcp_call_receipts[]`.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `ROUTING_CONTRACT_BLOCKED: Checkpoint missing successful MCP receipt: new_active_feature_folder.`

Confirmed against source (research `research.2026-10-29T15-40.md`, section 1):
- All three validator runtimes read `mcp_call_receipts[]` only. `delegation_receipts.promotion.feature_folder` is an allowed key of the namespaced `delegation_receipts` object and is not read by the routing contract.
- The receipt loop skips a tool only when it is in the waived set returned by `issue_adoption` resolution. That set is closed and defined once per runtime, and `new_active_feature_folder` is outside it.
- The stop hook holds no copy of the receipt or waiver logic. It dispatches to the PowerShell routing contract.


## Scope & Non-Goals
- In scope:
  - Add `new_active_feature_folder` to the closed waivable set of `issue_adoption` in the Python, TypeScript, and PowerShell validators.
  - Add a `feature_folder_record` object to `issue_adoption` with rules 10 and 11a-11e and byte-identical error strings in the three validators.
  - Add shared corpus cases and raise the corpus parity minimums to match.
  - Add a bounded git probe in the Claude `SubagentStop` hook, behind a mockable wrapper seam, in a new sibling hook file.
  - Update rule prose, skill prose, bundle mirrors, and pack manifests.
- Out of scope / non-goals:
  - Changes to the merge gate. Those belong to #997.
  - Writing, copying, or carrying a receipt into `mcp_call_receipts[]` (research section 3 alternative). This is rejected: the research does not recommend it, and a copied receipt would assert a call the run did not make.
  - A hook-only waiver with no checkpoint field. The MCP and CLI `--require-complete` validators would still fail.
  - File-system or git reads inside the Python, TypeScript, or PowerShell validators. They remain pure and text-only.
  - A Codex hook port. No `.codex/hooks/validate-orchestrator-output*` exists, and Codex and MCP-only gates stay declaration-only. A port is a separate decision.
  - Changes to the `epic-orchestrator-state` and `parallel-orchestrator-state` artifact types, which receive the structural check only.
  - Prefixes other than `docs/features/active/` (for example `docs/features/completed/` or epic locations) unless a real run requires them.
- Explicitly excluded systems, integrations, or datasets: GitHub Actions workflows, the merge gate, the PR-author hook, and Codex agent files (the generic Codex wording needs no edit).

## Root Cause Analysis
The gate verifies that this run called the tool, not that the folder exists and was created correctly. `issue_adoption` has no counterpart for the feature folder: its waivable set is closed to `potential_to_issue` and the two promotion-entry tools, and rule 8 rejects any other waived tool as "cannot be waived". The routing contract in each runtime appends `Checkpoint missing successful MCP receipt: {tool}.` for each required tool that is neither waived nor receipted. Because the receipts are read from `mcp_call_receipts[]` of the finishing run only, a folder created earlier cannot be accepted.


## Proposed Fix

### Design summary (what changes where):
1. Validators (three runtimes): `new_active_feature_folder` joins the closed waivable set. Waiving it requires a valid `issue_adoption.feature_folder_record`. On success the returned waived set includes the tool, so the three existing receipt loops skip it with no change to those loops.
2. Hook (Claude runtime only): after the routing contract reports no errors, if the checkpoint waives `new_active_feature_folder`, a bounded git probe confirms that `HEAD` of the run worktree holds a tree at the checkpoint `feature-folder`.
3. The probe applies only under the Claude `SubagentStop` hook. The validators' checks remain declarations: they verify presence, format, equality with `feature-folder`, and closed-set provenance, and cannot verify that the folder exists, is committed, or was created by the tool.

Record shape:

```json
"issue_adoption": {
  "waived_tools": ["potential_to_issue", "new_potential_bug_entry", "new_active_feature_folder"],
  "feature_folder_record": {
    "path": "docs/features/active/<folder>",
    "verified_via": "git_cat_file_head",
    "verified_at": "<UTC timestamp>",
    "evidence": "<free text describing the check performed>"
  }
}
```

Defaults adopted from research section 8: nested field (decision 1); `git cat-file -t HEAD:<path>` expecting `tree` (decision 2); `docs/features/active/` prefix only (3); record validated whenever present (4); `potential_to_issue` must still be listed in `waived_tools` (5); no specific file required inside the tree (6); absent or non-string `feature-folder` while waiving is an error (7); hook block text keeps the `ROUTING_CONTRACT_BLOCKED:` prefix and is repairable (8); Codex and MCP-only gates stay declaration-only (9).

### Boundaries and invariants to preserve:
- The waivable set stays closed; every other tool name (for example `validate_orchestration_artifacts`, and case variants of tool names) still cannot be waived.
- Any `issue_adoption` error waives nothing, so the missing-receipt line is still emitted (fail-closed model unchanged).
- Rule 8 behavior is unchanged: duplicates, tool not required by route (including the `remediation` route), tool that already holds a successful receipt, and missing `potential_to_issue` keep their existing messages and order.
- A run that skips both promotion and adoption evidence stays blocked with the existing missing-receipt error.
- Python, TypeScript, and PowerShell validators accept and reject identical inputs and emit identical ordered error lists.
- Validators perform no I/O.
- Receipts remain truthful: `mcp_call_receipts[]` is never populated by the adoption path.

### Dependencies or blocked work:
- Merge gate changes: #997 (not part of this work).
- Self-application: this run's own checkpoint adopts issue 992 and a pre-existing folder, so it hits the same block at DONE until the fix is in the hook copy that the stop hook runs. The orchestrator records `feature_folder_record` in its own checkpoint after the change lands in the worktree and confirms which hook copy runs. A receipt is not hand-copied.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
New files (each `.claude` file also gets a byte-equal bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`):
- `scripts/dev_tools/_orchestrator_state_feature_folder_record.py`
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts`
- `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1`
- `.claude/hooks/validate-orchestrator-output-feature-folder.ps1` (hook sibling, loaded with the same guarded dot-source pattern as the existing siblings)

Edited files:
- `scripts/dev_tools/_orchestrator_state_issue_adoption.py` (set entry, import, one call to the new module)
- `scripts/dev_tools/_orchestrator_state_promotion_tools.py` (optional constant; may instead live in the new module)
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts` (optional constant)
- `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`
- `.claude/hooks/validate-orchestrator-output.ps1` (guarded load, call site, optional invoker parameter) and its bundle copy
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (list both new `.claude` files)
- `extensions/drm-copilot/jest.config.cjs` (per-file `coverageThreshold` entry for the new TypeScript file)
- Rule prose: `.claude/rules/orchestrator-state.md` (object-shape sentence, field table, ordered rules list, the closed-set sentence that currently lists `new_active_feature_folder` as never waivable, the fail-closed paragraph, a disclosure sentence about the hook probe, and the enforcement bullet) and its bundle copy.
- Skill prose, each with its bundle copy: `.claude/skills/orchestrate/SKILL.md` (waivable-tool sentence), `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/feature-promotion-lifecycle/SKILL.md` (bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/`), `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md` (kickoff: instruct the execution child to record `feature_folder_record` when the preparation child already created and committed the folder).
- Not edited: `.claude/skills/execution-environment/SKILL.md` (states no fact this change alters), `.github/skills/feature-promotion-lifecycle/SKILL.md` (no `issue_adoption` text), and generic Codex agent and skill wording.

#### Functions/classes/CLI commands impacted:
- `resolve_issue_adoption` (Python), `resolveIssueAdoption` (TypeScript), and `Get-OrchestratorStateIssueAdoptionResult` (PowerShell): the waivable set gains the tool and rules 10 and 11a-11e run after rule 9, only when the rule-8 shape check passed.
- `validate_routing_contract`, `validateRoutingContract`, and `Get-OrchestratorStateRoutingContractError`: no code change; they consume the extended waived set.
- `Get-OrchestratorOutputBlockDecision` and `Invoke-OrchestratorOutputValidation` in the hook: call the new probe and accept an optional `-FeatureFolderGitInvoker` parameter, following the existing `RoutingInvoker` pattern.
- New wrapper `Invoke-FeatureFolderGitExe -GitArgs <string[]> [-GitInvoker <scriptblock>]`: never throws, returns `@{ ExitCode; Output }`, with `ExitCode = -1` when git cannot start. Modeled on `Invoke-PrAuthorCurrentBranchGitExe`.
- CLI `validate_orchestration_artifacts.py orchestrator-state --require-complete`: behavior changes only through the validator.

#### Data flow and validation changes:
Constants: tool `new_active_feature_folder`; path pattern `^docs/features/active/[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$`, applied as a full match in each runtime (Python `re.fullmatch`; JavaScript anchors without the multiline flag; PowerShell `\A...\z` with `-cmatch`, matching the technique used for `ISSUE_NUM_PATTERN`). The pattern excludes dot segments, empty segments, a trailing slash, backslashes, drive letters, glob and pathspec characters, and a leading `-`.

Rules, in order, after rule 9 (error strings are byte-identical in the three runtimes):

| Rule | Condition | Error string |
| --- | --- | --- |
| 10 | `new_active_feature_folder` in `waived_tools` and `feature_folder_record` absent or not an object | `Checkpoint issue_adoption.feature_folder_record must be an object when waiving new_active_feature_folder.` |
| 11a | record is an object and `path` is not a string matching the pattern | `Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without dot segments or a trailing slash.` |
| 11b | `path` valid and checkpoint `feature-folder` is not the identical string (absent, non-string, or different) | `Checkpoint issue_adoption.feature_folder_record.path must equal the checkpoint feature-folder.` |
| 11c | `verified_via` not one of `git_cat_file_head`, `git_ls_tree_head` | `Checkpoint issue_adoption.feature_folder_record.verified_via must be one of git_cat_file_head, git_ls_tree_head.` |
| 11d | `verified_at` absent, null, or blank string | `Checkpoint issue_adoption.feature_folder_record.verified_at must be present.` |
| 11e | `evidence` not a non-blank string | `Checkpoint issue_adoption.feature_folder_record.evidence must be a non-empty string.` |

The record is validated whenever present, including when the tool is not waived (precedent: `potential_record`).

Hook probe, run after `$routingResult.HasErrors` is false, only when the artifact type is `orchestrator-state` and the parsed checkpoint's `issue_adoption.waived_tools` contains `new_active_feature_folder`:
- Command: `git -C <WorktreeRoot> cat-file -t HEAD:<checkpoint feature-folder>`, with fixed arguments and no pathspec or glob semantics.
- Pass: exit code 0 and trimmed output equal to `tree`. HEAD-based, so a staged-only or untracked folder fails.
- Path source: the checkpoint `feature-folder` (already equal to the record path through rule 11b). The hook re-applies the path pattern before invoking git as defense in depth; a failing path never reaches git.
- Epic and parallel artifact types never invoke the probe.

What the probe proves: only that HEAD of the run worktree has a tree at that path at stop time. It does not prove the tool created the folder, that its contents are correct, or that it belongs to the adopted issue.

#### Error handling and logging updates:
- Validator errors use the six strings above and join the existing ordered error list.
- Hook block text keeps the prefix and is repairable, for example `ROUTING_CONTRACT_BLOCKED: Checkpoint feature-folder is not committed in HEAD: <path>.`
- The probe fails closed: non-zero exit, empty output, output other than `tree`, a thrown invoker, or exit code -1 all block.
- No new logging channel is introduced.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is reverting the change. A checkpoint that carries `feature_folder_record` without waiving the tool is still validated for shape. A checkpoint that does not waive the tool behaves as before.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: checkpoint JSON with the optional `issue_adoption.feature_folder_record` object (fields `path`, `verified_via`, `verified_at`, `evidence`) and the existing `feature-folder` key.
- Validator output: ordered error list of strings (unchanged contract).
- Hook output: allow, or a block decision with `ROUTING_CONTRACT_BLOCKED:` text.

#### Required configuration keys and defaults:
No configuration keys. `verified_via` allowed values: `git_cat_file_head`, `git_ls_tree_head`. Path prefix: `docs/features/active/`.

#### Backward-compatibility expectations:
- Checkpoints that do not waive `new_active_feature_folder` validate as before.
- Checkpoints that waived it previously received the "cannot be waived" error and now receive rule 10 or pass with a valid record. This is an intended behavior change.
- Existing waivable tools and all other non-waivable tools keep current behavior.

#### Performance constraints (latency/throughput/memory):
The hook adds one git invocation, and only when the waiver is present. No performance target applies. The validators add constant-time checks.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The `git cat-file -t HEAD:<path>` output on a real worktree is `tree` for a committed directory. The research stated this from git documentation without executing it; the orchestrator confirms it once on a real worktree.
  - `feature-folder` values are repo-relative with no trailing slash.
- Constraints (budget, performance, compatibility):
  - Byte-identical error strings and ordered lists across Python, TypeScript, and PowerShell.
  - Bundle copies of `.claude` files are byte-equal to the sources.
  - No production file excluded from coverage measurement; line coverage and branch coverage thresholds follow the root `CLAUDE.md` and rules.
  - Tests use injected invokers; no real git, no temporary files, no drive-letter paths (Linux hook-suite job).
  - File-size limits are specified under Acceptance Criteria.
- External dependencies (services, libraries, releases): none added. Git must be available to the hook at stop time; unavailability blocks, by design.

## Data / API / Config Impact
- User-facing or API changes: new optional `issue_adoption.feature_folder_record` object; `new_active_feature_folder` becomes waivable with a valid record.
- Data or migration considerations: none. No stored data is migrated.
- Logging/telemetry updates (if any): none beyond the new hook block message.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag changes. The checkpoint schema gains one optional nested object. The pack manifest `core.json` lists two additional `.claude` files.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: extend the adoption waiver to `new_active_feature_folder` when the checkpoint's `feature-folder` exists on disk and is tracked in git; a missing or untracked folder still fails.
- [ ] Integration scenario to retest: a checkpoint with `issue_adoption` and an existing folder reaches DONE without a folder receipt.
- [ ] Manual verification notes: confirm a run that skips both promotion and adoption evidence is still blocked.

- Regression tests to add or update:
  - Changed (the three existing tests that assert `new_active_feature_folder` is non-waivable):
    1. `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py`, `test_waiving_new_active_feature_folder_is_rejected`: rewritten so that waiving without a record yields the rule 10 error.
    2. `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts`, the `new_active_feature_folder` case inside the "enforces the closed waivable set (AC-8)" describe block: same rewrite.
    3. `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`, the case that asserts the tool cannot be waived: same rewrite.
  - Changed corpus fixture: `tests/fixtures/orchestrator_state_issue_adoption/waives-new-active-feature-folder.json` keeps its name; `notes` are updated; the checkpoint drops the successful `new_active_feature_folder` receipt and adds `feature-folder`; `expected_errors` pin rule 10 plus the fail-closed missing-receipt lines.
  - Corpus fixtures that keep pinning non-waivable behavior for other tools (`waives-validate-orchestration-artifacts.json`, `case-variant-tool-name.json`) stay unchanged.
  - Changed: `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` explicit module path list gains the new module.
  - Changed: the corpus parity minimums (`MINIMUM_CORPUS_COUNT` in the Python and TypeScript parity suites and `$minimumFixtureCount` in the Pester parity suite) are raised by the number of fixtures added. The plan derives the value by a directory listing and a second independent enumeration; this spec states no count.
  - Re-run unchanged: `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`, which pins the parallel-plan `Issue adoption:` blockquote fragments, `SHARED_RECORD_FRAGMENTS`, and the heading `## Invariants (issue_adoption object)`.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - New file `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py` (builders go in the existing support module); each of rules 10, 11a, 11b, 11c, 11d, 11e has a positive and a negative case.
  - New TypeScript file `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts` and new Pester file `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1` cover the same matrix.
  - Property-based coverage per `quality-tiers.md` applies only if `quality-tiers.yml` exists at the repository root; the plan checks for it.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Shared corpus cases (names chosen by the plan; checkpoints carry `feature-folder`): valid record on a large route; valid record on a bug-type preparation route; waived without a record; `path` differs from `feature-folder`; `path` outside `docs/features/active/`, with a dot segment, and with a trailing slash; `feature-folder` absent or non-string; unknown `verified_via`, blank `verified_at`, and blank `evidence` together in rule order; waived on the `remediation` route (existing "not required by route" message); waived while a successful `new_active_feature_folder` receipt exists (existing message); record present but tool not waived (validated per default 4).
  - Hook cases in new file `tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1`, all through an injected scriptblock invoker: `tree` output allows; empty output blocks; non-zero exit blocks; invoker throw blocks; exit code -1 blocks; no waiver means the invoker is never called; `epic-orchestrator-state` and `parallel-orchestrator-state` never call it; a path failing the pattern never reaches git. Tests use `Join-Path`, forward-slash paths, and no drive letters.
- Error handling and logging verification: parity suites compare ordered error lists exactly; the hook suite pins the hook-local block message (not part of the corpus).
- Coverage impact and targets for changed lines/modules: per-file coverage for each new module is read from the JSON, Pester coverage XML, and Jest output, not from MCP summaries. Thresholds follow the root `CLAUDE.md` where stated, otherwise the repository defaults. Changed lines must not regress. The new TypeScript file has a `jest.config.cjs` entry.
- Toolchain commands to run (format → lint → type-check → test): Python through `poetry run` (Black, Ruff, Pyright, Pytest); TypeScript through Prettier, ESLint, `tsc`, and `node run-jest.cjs` in `extensions/drm-copilot`; PowerShell through the PoshQC tools, with Pester counts read from `artifacts/pester/pester-junit.xml`. The full seven-stage loop is repeated until one pass is clean. Branch-current plan validation runs through the Python CLI.
- Manual validation steps (if required): one local confirmation that `git cat-file -t HEAD:<path>` prints `tree` for a committed feature folder and fails for an untracked one, run through a direct shell call or `sh <file>.sh`.

## Acceptance Criteria
Each criterion is observable through a named test, command, file, or CI result. Numeric counts are intentionally not stated.

- [x] AC-1 (waivable set): In each of the Python, TypeScript, and PowerShell validators, a checkpoint that waives `new_active_feature_folder` with a valid `feature_folder_record` (and a route that requires the tool, `potential_to_issue` listed) produces no `issue_adoption` errors and no `Checkpoint missing successful MCP receipt: new_active_feature_folder.` line. Verified by the shared corpus valid-record cases passing in the Python, Jest, and Pester parity suites.
- [x] AC-2 (rule 10): Waiving the tool with `feature_folder_record` absent or not an object yields exactly `Checkpoint issue_adoption.feature_folder_record must be an object when waiving new_active_feature_folder.` followed by the fail-closed missing-receipt line. Verified by the reworked `waives-new-active-feature-folder.json` case and the new per-runtime unit tests.
- [x] AC-3 (rules 11a-11e): Each rule 11 condition (11a through 11e) yields its exact error string from the Proposed Fix table, in rule order when several apply, identically in the Python, TypeScript, and PowerShell runtimes. Verified by the shared corpus cases for path format (outside prefix, dot segment, trailing slash), path/`feature-folder` mismatch, absent or non-string `feature-folder`, and unknown `verified_via`, blank `verified_at`, and blank `evidence` together.
- [x] AC-4 (closed set preserved): Waiving any tool other than `potential_to_issue`, the feature and bug promotion-entry tools, and `new_active_feature_folder` (including `validate_orchestration_artifacts` and case-variant tool names) still produces the "cannot be waived" error. Verified by `waives-validate-orchestration-artifacts.json` and `case-variant-tool-name.json` passing unchanged.
- [x] AC-5 (existing rule 8 interactions): Waiving the tool on the `remediation` route, or while a successful `new_active_feature_folder` receipt exists, or without `potential_to_issue` listed, yields the existing rule 8 messages. Verified by corpus cases.
- [x] AC-6 (skip-both stays blocked): A checkpoint with neither a promotion receipt nor valid adoption evidence still yields the missing-receipt error. Verified by `absent-key-large-missing-receipt.json` passing unchanged.
- [x] AC-7 (changed existing tests): Each existing test that asserted `new_active_feature_folder` is non-waivable (one per runtime) is updated and passing, at these locations: `test_waiving_new_active_feature_folder_is_rejected` in `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py`; the `new_active_feature_folder` case under "enforces the closed waivable set (AC-8)" in `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts`; and the corresponding case in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`. A search of those test files finds no assertion that waiving the tool is rejected as "cannot be waived".
- [x] AC-8 (parity minimums): The Python, TypeScript, and Pester parity suites each raise their corpus minimum by the number of fixtures added, derived by directory listing and checked by a second independent enumeration recorded in the plan or evidence folder, and each of those suites passes.
- [x] AC-9 (hook probe, allow): Under the Claude `SubagentStop` hook, an `orchestrator-state` checkpoint that waives the tool, passes the routing contract, and whose injected git invoker returns exit code 0 and output `tree` is allowed. Verified in `tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1`.
- [x] AC-10 (hook probe, block): The same checkpoint is blocked with `ROUTING_CONTRACT_BLOCKED: Checkpoint feature-folder is not committed in HEAD: <path>.` (repairable) when the invoker returns a non-zero exit, empty output, output other than `tree`, throws, or returns exit code -1. One Pester case per branch.
- [x] AC-11 (hook probe, scope): The invoker is never called when the tool is not waived, when the artifact type is `epic-orchestrator-state` or `parallel-orchestrator-state`, or when the path fails the path pattern. The probe command is the fixed `git -C <WorktreeRoot> cat-file -t HEAD:<feature-folder>` form. Verified by Pester cases that assert on the recorded invoker arguments and call count.
- [x] AC-12 (declaration-only boundary): The validators perform no file-system or git access, and the rule prose states that the probe applies only under the Claude `SubagentStop` hook and that validator checks, the MCP `validate_orchestration_artifacts` path, the Python CLI, and Codex gates remain declarations. Verified by code review of the Python, TypeScript, and PowerShell record modules (no I/O imports or calls) and by a search of `.claude/rules/orchestrator-state.md` for the disclosure sentence.
- [x] AC-13 (rule prose): `.claude/rules/orchestrator-state.md` documents the new field, rules 10 and 11a-11e, the updated closed-set sentence, the fail-closed paragraph, and the enforcement bullet naming the new modules and hook sibling. A search of the rule, skill, and bundle files finds no remaining statement that `new_active_feature_folder` can never be waived.
- [x] AC-14 (skill prose and pinned surfaces): The skill files listed under Files/modules to change are updated with their bundle copies, and `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` passes, confirming the `Issue adoption:` blockquote fragments, `SHARED_RECORD_FRAGMENTS`, and the `## Invariants (issue_adoption object)` heading remain intact. Where prose files are edited, the stale-hash and pinned-surface checks that cover them (including the push-down resource byte-equality contract in `test_push_down_claude_resource_contracts.py`) pass, and any recorded hashes are recomputed rather than copied.
- [x] AC-15 (mirrors and manifests): Every new or edited `.claude` file has a byte-equal copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`; `pack-manifests/core.json` lists both new `.claude` files; `OrchestratorState.Manifest.Tests.ps1`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` pass. If any Codex agent file is edited, the Codex generator `--check` passes.
- [x] AC-16 (file-size limits): No production, test, or reusable script file exceeds 500 physical lines after the change (Markdown exempt). Pre-change physical line counts from the research: `_orchestrator_state_issue_adoption.py` 352; `_orchestrator_state_promotion_tools.py` 95; `_orchestrator_state_routing.py` 265 (not touched); `orchestrator-state-issue-adoption.ts` 324; `orchestrator-state-routing.ts` 467 (not touched); `OrchestratorStateIssueAdoption.psm1` 396; `OrchestratorStateRoutingContract.psm1` 438 (not touched); `validate-orchestrator-output.ps1` 346 (about 12-20 added lines); `validate-orchestrator-output-routing.ps1` 170 (not touched); `test_orchestrator_state_issue_adoption_waivers.py` 338 (one test edited); `orchestrator-state-issue-adoption.test.ts` 477 (one case edited); `OrchestratorStateIssueAdoption.Tests.ps1` 437 (one case edited). Files near the limit are not extended: `test_orchestrator_state_issue_adoption.py` (462) and `validate-orchestrator-output.Tests.ps1` (454) receive no additions. New logic and tests go into the new sibling files named in this spec (the record modules for each runtime, the hook sibling, and the new Python, Jest, Pester module, and Pester hook test files). Verified by a physical line count of every touched and new code, test, and script file at review time, using the same counting method as the research.
- [x] AC-17 (coverage): Each new module has per-file coverage meeting the repository thresholds (root `CLAUDE.md` where stated, otherwise defaults), with branch coverage applied only to languages whose tooling measures it; the new TypeScript file has a `jest.config.cjs` per-file entry; no production path is added to a coverage `exclude`. Verified from the JSON, Pester coverage XML, and Jest output; changed lines do not regress.
- [x] AC-18 (test isolation and determinism): New tests use no real git, no temporary files, no drive-letter paths, and no in-tree reads of the worktree's gitignored `artifacts/` checkpoint. Shuffled-order runs (seeded Pester, reversed-order Python, seeded Jest) pass and are recorded under `<FEATURE>/evidence/regression-testing/`.
- [x] AC-19 (manual probe confirmation): One local run shows `git cat-file -t HEAD:<path>` printing `tree` for a committed feature folder and failing for an untracked one; the command, exit codes, and output are recorded under `<FEATURE>/evidence/`.
- [x] AC-20 (full toolchain): The full seven-stage toolchain (format, lint, type check, architecture-boundary tests, unit tests, contract and schema checks, integration tests) passes in a single pass for the Python, TypeScript, and PowerShell surfaces touched.
- [x] AC-21 (repro, local): With a checkpoint that adopts an existing, committed feature folder and records a valid `feature_folder_record`, the Claude stop hook allows DONE without a `new_active_feature_folder` receipt; with the folder absent from HEAD, or with no record, it still blocks. Verified by the hook Pester suite and the Python CLI `--require-complete` run on the corresponding fixture.
- [x] AC-22 (CI verified on PR #999: every check passed on head 90f446e953eddaa40f8501f136df889a15d50e87): CI on the PR head is green for every required check, including the Python, Jest, and Pester jobs, the Linux hook-suite job, the push-down and manifest suites, and the shuffle guards. This criterion cannot be verified before the pull request exists. It stays unchecked and is listed as pending-CI until the item's own orchestrator run checks it off at S9, after `ci_gate.conclusion` is `success` and with `ci_gate.head_sha` equal to the final PR head.

### Acceptance Criteria Evidence

Clarification for AC-2 (ordering): at the resolver level (`resolve_issue_adoption`, `resolveIssueAdoption`, `Get-OrchestratorStateIssueAdoptionResult`), waiving the tool without a record yields exactly the rule-10 string. At the routing-contract level (the shared corpus), adoption errors follow the receipt-loop errors, so the reworked `waives-new-active-feature-folder.json` lists `Checkpoint missing successful MCP receipt: potential_to_issue.` and `Checkpoint missing successful MCP receipt: new_active_feature_folder.` first and the rule-10 string after them. The implementation follows this order in all three runtimes.

AC-22 was checked off by the item's own orchestrator run at S9: `gh pr checks 999` reported no failing or pending check on head 90f446e953eddaa40f8501f136df889a15d50e87, and a re-run on the final PR head follows this commit.

| AC | Evidence (under `evidence/`) |
| --- | --- |
| AC-1 | `regression-testing/pass-after.2026-10-29T14-51.md` (valid-record corpus cases pass in Python, Jest, and Pester) |
| AC-2 | `regression-testing/pass-after.2026-10-29T14-51.md`; `regression-testing/fail-before.2026-10-29T14-38.md` |
| AC-3 | `regression-testing/pass-after.2026-10-29T14-51.md` (rule-11 corpus cases in all three parity suites) |
| AC-4 | `regression-testing/pass-after.2026-10-29T14-51.md` (named unchanged cases table) |
| AC-5 | `regression-testing/pass-after.2026-10-29T14-51.md` (remediation-route, successful-receipt, and missing-`potential_to_issue` corpus cases) |
| AC-6 | `regression-testing/pass-after.2026-10-29T14-51.md` (`absent-key-large-missing-receipt`) |
| AC-7 | `regression-testing/fail-before.2026-10-29T14-38.md` and `regression-testing/pass-after.2026-10-29T14-51.md` (rewritten test in each runtime) |
| AC-8 | `baseline/corpus-count.2026-10-29T14-21.md`; `regression-testing/fail-before.2026-10-29T14-38.md` (48 by directory listing and by collected cases) |
| AC-9 | `qa-gates/ps-pester.2026-10-29T15-15.md` (`validate-orchestrator-output.FeatureFolder.Tests.ps1`, allow cases) |
| AC-10 | `qa-gates/ps-pester.2026-10-29T15-15.md`; `regression-testing/fail-before-hook-suite.2026-10-29T14-46.md` |
| AC-11 | `qa-gates/ps-pester.2026-10-29T15-15.md` (scope and command cases) |
| AC-12 | `other/stale-wording.2026-10-29T14-50.md` and `.claude/rules/orchestrator-state.md` (`declaration-only` disclosure); `qa-gates/self-review.*.md` (no I/O in the record modules) |
| AC-13 | `other/stale-wording.2026-10-29T14-50.md` |
| AC-14 | `qa-gates/contracts.2026-10-29T15-12.md`; `other/mirror-hashes.2026-10-29T14-49.md` |
| AC-15 | `other/mirror-hashes.2026-10-29T14-49.md`; `qa-gates/contracts.2026-10-29T15-12.md` |
| AC-16 | `qa-gates/line-counts.2026-10-29T15-00.md` |
| AC-17 | `qa-gates/coverage-comparison.2026-10-29T15-16.md` |
| AC-18 | `regression-testing/isolation.2026-10-29T15-16.md` |
| AC-19 | `other/probe-confirmation.2026-10-29T14-51.md` |
| AC-20 | `qa-gates/python-*.2026-10-29T15-04.md`, `qa-gates/ts-*.2026-10-29T14-54.md`, `qa-gates/ps-*.2026-10-29T15-15.md`, `qa-gates/contracts.2026-10-29T15-12.md` |
| AC-21 | `qa-gates/ps-pester.2026-10-29T15-15.md` (hook suite allow and block cases); `other/cli-require-complete.2026-10-29T14-51.md` |

## Risks & Mitigations
- Technical or operational risks:
  - An error string differs by one character across runtimes, or prose still says the tool can never be waived.
  - The new TypeScript file lacks a coverage entry, or hook failure branches go unexercised.
  - A new `.claude` file is missing from `core.json` or its bundle copy, failing the manifest, closure, or push-down suites.
  - Extending near-limit test files pushes them past 500 lines.
  - Hook tests written with real git or temporary checkouts fail on the Linux hook-suite job.
  - A test reading the worktree's gitignored checkpoint passes locally and fails in CI; real `git cat-file` output on shallow or Linux checkouts is untested.
  - PoshQC MCP results carry no output and the MCP validator applies the installed extension, so counts asserted from those results are unverifiable.
  - The probe proves only that HEAD has a tree at the path; it does not prove authorship or correctness of the folder, and Codex and MCP-only gates remain declarations.
  - This run hits the same block at its own DONE until the fix is in the running hook copy.
- Mitigations and rollbacks:
  - Define the six strings once, assert them through the shared corpus in all three parity suites, and search the rule, skill, and bundle files for the old closed-set wording before review.
  - Add the `jest.config.cjs` entry in the same task; write one test per branch of the hook sibling and per rule 10-11 branch in each runtime.
  - List each bundle copy and `core.json` in one task and run the push-down, manifest-completeness, dependency-closure, and `OrchestratorState.Manifest.Tests.ps1` suites.
  - Put new tests only in the new files and new production rules only in the new modules.
  - Inject a scriptblock invoker for every probe, with no `Mock` of `git`, in-memory checkpoint JSON only, and a one-time local confirmation of the real probe.
  - Take Pester counts from the JUnit file, coverage from the coverage XML, and run plan validation through the Python CLI.
  - State the probe limits in the rule prose (AC-12). The orchestrator records `feature_folder_record` in its own checkpoint after confirming which hook copy runs.
  - Rollback: revert the change; checkpoints that do not waive the tool are unaffected.

## Rollout & Follow-up
- Release/rollout steps: merge through the normal PR path. The extension bundle copies ship with the next extension build; a push-down serves the installed extension payload, so a repo-side `resources/` edit changes what a push-down writes only after a rebuild and reinstall.
- Post-fix monitoring or clean-up tasks: after merge, confirm that a parallel or epic run with a pre-prepared folder reaches DONE without a hand-copied receipt. File a separate decision for a Codex hook port only if wanted. Merge gate changes are tracked in #997.
- Links: issue #992 (https://github.com/drmoisan/drm-copilot/issues/992); research `research/research.2026-10-29T15-40.md`; plan `plan.2026-10-29T09-53.md`; related: #997 (merge gate).
