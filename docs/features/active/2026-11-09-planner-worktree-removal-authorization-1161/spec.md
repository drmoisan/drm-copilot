# 2026-11-09-planner-worktree-removal-authorization — Spec

- **Issue:** #1161
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09T21-50
- **Status:** Approved for planning
- **Version:** 1.0

## Overview

The epic planner launches preparation children in isolation worktrees and must remove each worktree after its preparation branch is fanned in. No checkpoint read by the worktree-removal gates records those worktrees, so every removal reaches the final deny, and detaching HEAD has been the only way to free the branch. This feature records each preparation worktree in the epic-planner checkpoint by branch identity and adds a planner allow branch to each of the three removal gates that allows removal only when the record is eligible, the worktree is not in use, the worktree is clean, and its `HEAD` commit is already on a remote-tracking ref.

- Target users/personas and primary use cases:
  - Epic-planner operator (the `epic-planner` agent on Claude and on Codex, and the human who supervises it): removes a fanned-in preparation worktree without `--force` and without detaching HEAD.
  - Gate maintainer: keeps the removal gates conjunctive, deterministic, byte-stable for existing deny paths, and within their file-size caps.
- Success metrics or expected impact:
  - A recorded, eligible, clean, pushed, not-in-use preparation worktree is removed by a plain `git worktree remove` on Claude and on Codex.
  - Every existing gate suite passes unchanged, and deny text is byte-identical whenever no planner record names the target's branch.
  - No recorded value or test fixture carries an absolute host path.

Source research: `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/research/research.2026-11-09T21-36.md`.

## Decisions

| ID | Decision | Rationale |
| --- | --- | --- |
| D1 | Add a top-level optional array `planner_worktrees` to `artifacts/orchestration/epic-planner-state.json`. Each entry is an object with `branch` (required), `path` (optional), `purpose` (required), `preparation_status` (required), `feature_folder` (required), and `recorded_at` (optional). The key is not added to `REQUIRED_KEYS`. | One feature can own more than one preparation worktree after a re-plan, and the existing `features[]` names collide with Codex launch-binding rules. |
| D2 | AC5 decision: the branch name is the authoritative worktree identity. No absolute host path is recorded. `path` is optional and repository-relative to the main checkout. The gate resolves the branch at runtime to the single live root that has it checked out and requires that root to equal the command target. A detached worktree never matches. | Git checks a branch out in at most one worktree, so the branch is host-independent and resolvable at runtime; this satisfies the never-encode-absolute-paths rule. |
| D3 | `purpose` is the closed set {`preparation`}. `preparation_status` is the closed set {`preparing`, `prepared`, `fanned_in`, `removed`, `abandoned`}. Only `prepared` and `fanned_in` are gate-eligible. Comparisons are ordinal and case-sensitive. | Closed vocabularies are testable, and keeping `purpose` as a field makes later purposes additive. |
| D4 | Committed and pushed means the worktree `HEAD` commit is an ancestor of, or equal to, `refs/remotes/origin/<integration_branch>` or `refs/remotes/origin/<branch>`, tested with `git merge-base --is-ancestor`. Local refs only; no fetch. Any git failure denies. | Local remote-tracking refs need no network, and a stale ref makes the check more conservative. |
| D5 | Clean means `git status --porcelain=v1 --untracked-files=all` in the target exits 0 with empty output. Ignored files do not count. The check runs whether or not the command carries `--force`. | `git worktree remove` deletes ignored files without `--force`; evaluating cleanliness in the gate prevents a `--force` bypass. |
| D6 | In use is any one of the conditions U1 to U5 defined under `## Behavior`. Each condition has its own deny detail identifier. | A concrete, separately testable definition of "still in use" is required by the issue. |
| D7 | The allow branch is a byte-identical pure helper `.claude/hooks/hook-planner-worktree-removal.ps1` and `.codex/hooks/hook-planner-worktree-removal.ps1`, a Claude-only adapter `.claude/hooks/enforce-worktree-removal-gate-planner.ps1`, and Codex adapter functions in `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`. Each gate adds one guarded dot-source and one call. | Pure logic is separated from I/O, the precedent is `hook-epic-fan-in.ps1`, and both Claude gates must stay at or below their 500-line cap. |
| D8 | The planner check runs after the epic and parallel checkpoint allows and before the manifest branch in both Claude gates, and after the epic check in the Codex gate. When no planner record names the target's branch, all deny text is byte-identical to today. When a record matches and is refused, one sentence of the form `Planner worktree: PLANNER_WORKTREE_<CODE>: <detail>.` is appended. | Existing allows keep precedence, existing deny assertions stay valid, and a refusal is diagnosable. |
| D9 | On Claude, the adapter reads `artifacts/orchestration/epic-planner-state.json` beneath every live root through `Get-WorktreeRunCheckpointText`. On Codex, it reads the same relative path at the repository root the Codex gate already uses. More than one checkpoint naming the branch denies with `AMBIGUOUS`. | Reusing baseline-mocked seams keeps every existing gate suite deterministic. |
| D10 | All three gates gain the branch. The pure helper is byte-identical across `.claude/hooks/` and `.codex/hooks/` and is pinned by test. Codex documentation instructs recording `planner_worktrees` with branch identity and a relative path. | Claude and Codex parity; a Claude-only allow would leave Codex launcher worktrees unremovable. |
| D11 | The Python validator (extended in place) and a new TypeScript module validate `planner_worktrees` only when the key is present, in plain validation, with byte-identical error strings listed under `## API / CLI Surface`. No PowerShell validator is added. Readiness is not changed. | Key-gating keeps every existing checkpoint valid, and byte-identical strings are pinned by a shared corpus. |
| D12 | A new section `## Preparation Worktree Records` in `.claude/skills/epic-plan/SKILL.md` and `.agents/skills/epic-plan/SKILL.md` defines the recording protocol. Fan-In step 4 (Claude) and step 5 (Codex) point to it. `.claude/agents/epic-planner.md` and `.codex/agents/epic-planner.toml` list the key. The three gates' `.DESCRIPTION` blocks document the branch. | AC4 requires the skill, agent, and gate documentation; a new section limits edits to shared sections that sibling items also touch. |
| D13 | The parallel planner is not extended. The parallel removal gate changes only as a conjunctive consumer of the epic-planner branch and does not read the parallel-planner checkpoint. | The parallel planner creates no worktrees since #1002; the issue scope is the epic planner and is not reduced. |
| D14 | No new configuration knob. | The branch is inert unless a planner checkpoint carries `planner_worktrees` naming the target's branch, so current behavior is the default. |
| D15 | Honest disclosure: the branch is a policy-level control, not a security control (see `## Honest Disclosure`). | Same-session writers can author a record; the git checks bound the possible harm. |
| D16 | The Claude Code runtime locks an isolation worktree while its agent runs, and `git worktree list --porcelain` shows a `locked claude agent <id> (pid N)` line, so U3 reliably detects a live child. A preparation child switches its isolation worktree to the branch `feature/<short-name>-<issue>`, and that is the branch the planner records. | Orchestrator confirmation of the open items in the research. |
| D17 | The pre-existing absolute `features[].worktree_path` requirement of the Codex launch binding is left unchanged. | It is out of scope for this item (see `## Non-Goals`). |
| D18 | The new Python test module `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py` is permitted. | The no-new-Python constraint covers pushed-down code (skills, hooks, libs, skill helpers); this module tests the existing Python validator, which is extended in place, and is not pushed down. |
| D19 | The Codex adapter always lives in the new sibling `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1`; the Codex gate gains only a guarded dot-source and one call. | A deterministic file set for planning and scheduling, and the same gate-plus-adapter shape as the Claude side. |
| D20 | A refused planner check does not stop the cascade: the manifest branch still runs, and the planner sentence is appended only when the final deny is reached. `PLANNER_WORKTREE_IN_USE` details begin with the condition label `U1` to `U5`. U3 is read from the `locked` line of `git worktree list --porcelain`. | Orchestrator acceptance of the spec author's readings of D6, D8, and D16. |

## Behavior

### Main flow (happy path)

1. The planner launches a preparation child. The child switches its isolation worktree to `feature/<short-name>-<issue>` (D16).
2. When the child completes, the planner reads the child worktree's branch and appends a `planner_worktrees` entry with `purpose: preparation`, `preparation_status: prepared`, the feature's `feature_folder`, and optionally a repository-relative `path` and `recorded_at`.
3. The planner merges the preparation branch into the integration branch, pushes, and sets `preparation_status: fanned_in`.
4. The planner issues a plain `git worktree remove` of that worktree in its own Bash call, without `--force`.
5. Each removal gate reaches the planner check, which allows. The worktree is removed, and the planner sets `preparation_status: removed`.

### Gate cascade position

- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`: dependency failure, payload anomaly, scope filter, target derivation, then per target: epic and parallel `Ambiguous` denies, epic allow, parallel allow, planner check, manifest allow, final deny.
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`: per target: parallel allow, epic allow, planner check, manifest allow, final deny.
- `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`: per target: epic allow, planner check, final deny.
- A planner allow ends evaluation for that target with no denial. A planner refusal does not stop the cascade: the manifest branch still evaluates and may allow. If the final deny is reached, the planner sentence is appended.
- Manifest exclusion semantics are unchanged; `Test-CleanupManifestCheckpointCoversPath` is not changed.

### Record match

- Planner checkpoint discovery: Claude reads `artifacts/orchestration/epic-planner-state.json` beneath every live root returned by `Get-WorktreeItemLiveRoot`, through `Get-WorktreeRunCheckpointText`, composing the path with the shared join. Codex reads the same relative path at the repository root derived from `$PSScriptRoot`. An unreadable or unparseable checkpoint, or one whose `planner_worktrees` is absent or not a list, contributes no records.
- Candidate record: an object entry whose `branch` is a non-empty string.
- A candidate record names the target when the branch resolves to a live root equal to the command target (Claude: `Get-WorktreeItemLiveRoot -SessionRoot <root> -Branch <branch>` compared with `Test-WorktreeRunPathEqual`; Codex: `ConvertFrom-HookTargetWorktreePorcelain`), and, when `path` is present, `path` also matches the target through `Test-WorktreeRunRecordedPathMatchesTarget` with the main checkout as base root. A `path` that is not a safe relative value, or does not match, means the record does not name the target.
- Zero records name the target: no planner authorization. The gate continues exactly as today, and all deny text is byte-identical.
- Records from more than one planner checkpoint name the target, or the branch is checked out in more than one live root: refusal `AMBIGUOUS`.

### Decision order for a single matching record

The first failing step determines the refusal. Any git call that does not return an expected exit code yields `GIT_FAILED` at that step.

1. Eligibility: `purpose` is exactly `preparation` and `preparation_status` is exactly `prepared` or `fanned_in`. Otherwise `NOT_ELIGIBLE`.
2. In use, evaluated in the order U1, U2, U3, U4, U5. The first condition that holds yields `IN_USE`.
   - U1: the target root equals or encloses the session root passed to the gate, or equals the root that holds the matching planner checkpoint.
   - U2: the target is the main checkout root (`Get-WorktreeRunMainCheckoutRoot`).
   - U3: the target's record in `git worktree list --porcelain` carries a `locked` line (git's worktree lock). This holds regardless of any `-f` or `--force` flag on the command. Per D16 the Claude Code runtime locks a running child's isolation worktree.
   - U4: the target holds `artifacts/orchestration/orchestrator-state.json` that is unparseable, or whose `next_step` is not exactly `S5_atomic_execution`. An absent file does not satisfy U4.
   - U5: a live root's `artifacts/orchestration/epic-orchestrator-state.json` with `route_id` `epic` records the target through `features[].worktree_path`, or records a `features[].branch_name` equal to the record's `branch`. On Codex, only the repository-root epic checkpoint the gate already reads is consulted.
3. Clean: `git -C <target> status --porcelain=v1 --untracked-files=all` exits 0 with empty output. Non-empty output with exit 0 yields `DIRTY`; any non-zero exit yields `GIT_FAILED`.
4. Committed and pushed:
   - `git -C <target> rev-parse --verify HEAD` must exit 0 with a commit id; otherwise `GIT_FAILED`.
   - When the matching planner checkpoint's `integration_branch` is a non-empty string, `git -C <target> merge-base --is-ancestor <head> refs/remotes/origin/<integration_branch>` runs first. Exit 0 means pushed.
   - Otherwise, or on exit 1, `git -C <target> merge-base --is-ancestor <head> refs/remotes/origin/<branch>` runs. Exit 0 means pushed; exit 1 yields `NOT_PUSHED`.
   - Any exit code other than 0 or 1 from either check (including a missing ref) yields `GIT_FAILED`.
5. All steps pass: allow.

Git runs only after a record names the target. Under the existing gate suites' baseline mocks no record ever names a target, so no process is started there.

### Deny text

- Unrecorded target (zero records name it): every deny string of all three gates is byte-identical to the current string, including the `TARGET_WORKTREE_NOT_DERIVABLE` prefix logic and the diagnostics clause from `Get-EpicWorktreeGateDenyDiagnostics`.
- Refused record: the existing deny text is followed by one space and the sentence `Planner worktree: PLANNER_WORKTREE_<CODE>: <detail>.` On the Claude epic gate, the sentence follows the diagnostics clause. The gate token (`EPIC_WORKTREE_REMOVAL_BLOCKED` or `PARALLEL_WORKTREE_REMOVAL_BLOCKED`) still appears exactly once.
- Codes: `PLANNER_WORKTREE_NOT_ELIGIBLE`, `PLANNER_WORKTREE_DIRTY`, `PLANNER_WORKTREE_NOT_PUSHED`, `PLANNER_WORKTREE_IN_USE`, `PLANNER_WORKTREE_AMBIGUOUS`, `PLANNER_WORKTREE_GIT_FAILED`.
- For `PLANNER_WORKTREE_IN_USE`, `<detail>` begins with the condition identifier `U1`, `U2`, `U3`, `U4`, or `U5`, followed by one space and a description. For other codes, `<detail>` names the record's branch and the failing fact. `<detail>` contains no absolute path beyond the command target already present in the existing deny text.
- `Get-EpicWorktreeGateDenyDiagnostics` is not changed.

### Error handling and recovery

- On a planner refusal, the planner records the deny code in its checkpoint, leaves the worktree in place, and never detaches HEAD or uses `--force` to free the branch.
- A malformed entry never authorizes. The gate parses tolerantly and does not reject the command because of a malformed checkpoint beyond today's behavior.

## Inputs / Outputs

- Inputs:
  - `artifacts/orchestration/epic-planner-state.json` key `planner_worktrees` (new, optional) and existing key `integration_branch`.
  - The target worktree's `artifacts/orchestration/orchestrator-state.json` (U4) and live roots' `artifacts/orchestration/epic-orchestrator-state.json` (U5).
  - Local git state: `git worktree list --porcelain`, `git status`, `git rev-parse`, `git merge-base --is-ancestor`.
- Outputs: a PreToolUse allow, or a deny reason string as defined under `### Deny text`. Validator error strings as defined under `## API / CLI Surface`.
- Config keys and defaults: none added (D14).
- Versioning or backward-compatibility constraints: the key is optional and key-gated in both validators. A checkpoint without it validates byte-identically to today. Installed MCP ignores the key until the extension release that carries the TypeScript rule.

## API / CLI Surface

### Field shape (`planner_worktrees[]` entry)

| Field | Required | Rule |
| --- | --- | --- |
| `branch` | yes | String matching `^[A-Za-z0-9][A-Za-z0-9._/-]*$`, not containing `..`, not ending in `/`, `.`, or `.lock`; unique across entries. |
| `path` | no | When present: a non-empty string relative to the main checkout, with no drive prefix, no leading `/` or `\`, no `\` anywhere, no `:`, and no `.` or `..` segment. |
| `purpose` | yes | Exactly `preparation`. |
| `preparation_status` | yes | One of `preparing`, `prepared`, `fanned_in`, `removed`, `abandoned`. |
| `feature_folder` | yes | A string equal to some `features[].feature_folder` of the same checkpoint. |
| `recorded_at` | no | When present: a string with at least one non-whitespace character (ISO-8601 UTC by convention; not parsed). |

### Validator error strings (byte-identical in Python and TypeScript)

`N` is the 0-based entry index. Errors are appended immediately after the `max_parallel_features` check of `validate_epic_planner_state_text` and `validateEpicPlannerStateText`, in the order below for each entry, entries in list order.

1. `Epic planner checkpoint planner_worktrees must be a list when present.` When this fires, nothing further is checked.
2. `Epic planner checkpoint planner_worktrees[N] must be an object.` When this fires, no further check runs for that entry.
3. `Epic planner checkpoint planner_worktrees[N].branch must be a non-empty branch name.`
4. `Epic planner checkpoint planner_worktrees[N].branch must be unique: <branch>.` Reported on each entry after the first that carries a valid branch already seen.
5. `Epic planner checkpoint planner_worktrees[N].path must be a repository-relative path without a drive, a leading slash, a backslash, or dot segments.` Checked only when `path` is present.
6. `Epic planner checkpoint planner_worktrees[N].purpose must be preparation.`
7. `Epic planner checkpoint planner_worktrees[N].preparation_status must be one of: preparing, prepared, fanned_in, removed, abandoned.`
8. `Epic planner checkpoint planner_worktrees[N].feature_folder must name a features[] feature_folder.`
9. `Epic planner checkpoint planner_worktrees[N].recorded_at must be a non-empty string when present.` Checked only when `recorded_at` is present.

Entry points: Python `_validate_planner_worktrees(state, indexed_features)` in `scripts/dev_tools/validate_epic_planner_state.py`; TypeScript exported function in `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts`, called from `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`. The CLI (`scripts/dev_tools/validate_orchestration_artifacts.py epic-planner-state`) and MCP artifact type `epic-planner-state` are unchanged in signature.

### PowerShell functions

- Pure helper (`hook-planner-worktree-removal.ps1`): record parsing, eligibility, and `Get-PlannerWorktreeRemovalDecision` over already-collected facts, returning allow or a code plus detail, and the sentence formatter. No I/O, no StrictMode setting, no preference-variable assignment.
- Claude adapter (`enforce-worktree-removal-gate-planner.ps1`): `Get-PlannerWorktreeRemovalTargetDecision -WorktreePath -SessionRoot`, collecting facts through `Get-WorktreeItemLiveRoot`, `Get-WorktreeRunCheckpointText`, `Get-WorktreeRunMainCheckoutRoot`, and the new wrapper `Invoke-PlannerWorktreeGitExe -GitArgs`. The adapter never calls `Get-Location`; it uses the `-SessionRoot` the gate passes.
- Codex adapter functions in the new sibling `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` (D19), using `ConvertFrom-HookTargetWorktreePorcelain` and a git wrapper seam. `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` gains one guarded dot-source and one call. The sibling takes a bundle mirror and a Codex pack-manifest entry.

## Data & State

- `planner_worktrees` is append-and-update state owned by the epic planner. Status transitions: `prepared` on child completion, `fanned_in` after the integration merge and push, `removed` after the removal succeeds; `preparing` and `abandoned` are recordable and not gate-eligible.
- The gate never writes any checkpoint.
- No migration or backfill: no existing checkpoint carries the key.

## Constraints & Risks

Owner constraints:

- Anything pushed down is PowerShell or bash. No new Python is added; extending `scripts/dev_tools/validate_epic_planner_state.py` in place is permitted. TypeScript is used only for the MCP validator module.
- Pure logic lives in a host-neutral helper, and I/O lives in thin adapters with injected seams.
- Tests create no temporary files and perform no wall-clock waits.
- Test runs are parallel-only: Pester through `Invoke-PoshQCParallelTest`, pytest with `-n auto`, and Jest workers. No serial, single-process, shuffled, or reversed runs as gates.
- Evidence is append-only: no evidence file is back-dated, edited after the fact, or deleted.
- This item may merge before or after any of the sibling items #1156, #1157, #1158, #1159, #1160, #1162, and #1163. Shared files (both Claude gates, the Codex gate, the resolution sibling, the epic-plan skills, the epic-planner agents, the two validators) are re-read at execution start.

Technical constraints and risks:

- `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` caps `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, and `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` at 500 lines. Gate edits are limited to one guarded dot-source and one call.
- `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` are hash-pinned by `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` and are not edited.
- Existing gate suites now reach the planner branch on deny paths. All planner reads use already baseline-mocked seams, and git runs only after a record names the target. `Invoke-PoshQCLeakScan` must pass.
- Linux CI is case-sensitive and has no drive letters. Fixtures use synthetic forward-slash roots with no drive letter and no CRLF line endings.
- Security/privacy: no absolute host path is recorded in checkpoints, evidence, or fixtures. Validator rejection rows use a drive-only token that the rule rejects without any path join.

## Implementation Strategy

- New files:
  - `.claude/hooks/hook-planner-worktree-removal.ps1` and byte-identical `.codex/hooks/hook-planner-worktree-removal.ps1`.
  - `.claude/hooks/enforce-worktree-removal-gate-planner.ps1`.
  - `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts`.
  - Bundle mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-planner-worktree-removal.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-worktree-removal-gate-planner.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-planner-worktree-removal.ps1`.
  - Tests: `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1`, `tests/scripts/claude-hooks/enforce-worktree-removal-gate-planner.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.PlannerWorktree.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.PlannerWorktree.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-planner-worktree.Tests.ps1`, `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py` (a test module, not pushed down; permitted by D18), `extensions/drm-copilot/test/lib/validate/epic-planner-state-planner-worktrees.test.ts`, and the corpus directory `tests/fixtures/epic_planner_state_planner_worktrees/` of `{name, notes, checkpoint, expected_errors}` JSON files.
- Changed files:
  - Gates and mirrors: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1`.
  - Validators: `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, `extensions/drm-copilot/jest.config.cjs` (a `coverageThreshold` entry for the new module).
  - Documentation and mirrors: `.claude/skills/epic-plan/SKILL.md`, `.agents/skills/epic-plan/SKILL.md`, `.claude/agents/epic-planner.md`, `.codex/agents/epic-planner.toml`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-planner.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-planner.toml`.
  - Allow-set descriptions that currently enumerate the allow set exhaustively gain one sentence naming the planner branch: `.claude/skills/parallel-orchestrate/SKILL.md` (paragraph "**Worktree removal gate.**"), `.claude/rules/parallel-orchestration.md` (`## Enforcement`), and their mirrors `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`.
  - Pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
  - Pin: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` gains a byte-identity pin for `hook-planner-worktree-removal.ps1`.
- Skill and agent content (D12):
  - `## Preparation Worktree Records` in both epic-plan skills: record on child completion with `prepared` (branch read from the completion notification or `git worktree list --porcelain`), set `fanned_in` after merge and push, remove with a plain `git worktree remove` in its own Bash call without `--force`, then set `removed`; on a planner-gate deny, record the code and leave the worktree; never detach HEAD to free a branch; record no absolute path. The section states the D15 disclosure and that ignored files are deleted by the removal.
  - `.claude/skills/epic-plan/SKILL.md` `## Fan-In to the Integration Branch` step 4 and `.agents/skills/epic-plan/SKILL.md` `## Fan-In` step 5 point to the new section. No other shared section is rewritten.
  - `.claude/agents/epic-planner.md` `## Checkpoint Persistence` and `.codex/agents/epic-planner.toml` `## Checkpoint` list `planner_worktrees` and its field shape.
  - The `.DESCRIPTION` block of each of the three gates documents the planner branch, its cascade position, the refusal codes, and the honest disclosure.
- Dependency changes: none.
- Logging/telemetry: none beyond deny reason text.
- Rollout: no flag; inert until a checkpoint carries the key (D14). Registrations in `.claude/settings.json` and `.codex/config.toml` are unchanged.

## Non-Goals

- The parallel planner is not extended (D13). The parallel removal gate consumes the epic-planner branch only and does not read `artifacts/orchestration/parallel-planner-state.json`; no hook allow is added for parallel-planner scratch worktrees, so the #995 D5 rule stands for them.
- The pre-existing absolute `features[].worktree_path` requirement of the Codex launch binding (`_is_canonical_worktree_path` in `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`) is not changed (D17). Reason: it is an existing deviation from the never-encode-absolute-paths rule owned by the Codex launch-evidence contract, which `.codex/scripts/launch-epic-child-wave.ps1` and the launch-binding validators depend on; changing it alters Codex launch evidence and is unrelated to removal authorization. The new `planner_worktrees` record does not reuse `worktree_path` or `branch_name` and carries no absolute path.
- No new configuration knob (D14).
- No PowerShell validator for the epic-planner checkpoint, and no change to readiness validation.
- No change to `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.claude/skills/cleanup-merged-worktrees/SKILL.md`, the cleanup manifest, or hook registrations.

## Honest Disclosure

- The planner branch is a policy-level control, not a security control. Any writer in the same session can author a `planner_worktrees` record.
- The git checks bound the harm to removing a clean, unlocked worktree that is not the session or main checkout and whose `HEAD` commit is already reachable from a remote-tracking ref.
- The pushed check reads local remote-tracking refs only and never fetches. A stale ref makes the check more conservative.
- `git worktree remove` deletes ignored files without `--force`, including a child's gitignored checkpoint. This is accepted.
- U4 depends on the child's own checkpoint; a child that never wrote one is treated as not in use by U4 and is covered by U3 while the runtime holds its lock.
- On Codex, only the repository-root planner and epic checkpoints are read; a checkpoint in another worktree is not consulted.
- A hook cannot observe a removal performed outside the Bash tool surface.

## Acceptance Criteria

Issue AC mapping: issue AC1 maps to AC-1 to AC-4; issue AC2 maps to AC-5 to AC-8; issue AC3 maps to AC-5 to AC-21; issue AC4 maps to AC-22 to AC-25; issue AC5 maps to AC-26 to AC-28.

- [x] AC-1: `scripts/dev_tools/validate_epic_planner_state.py` validates `planner_worktrees` when present, in plain validation, emitting the error strings of `### Validator error strings` in the stated order, and returns byte-identical results for every checkpoint that lacks the key.
- [x] AC-2: `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts`, called from `validateEpicPlannerStateText`, produces the same error lists as Python for every file in `tests/fixtures/epic_planner_state_planner_worktrees/`, asserted by `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-state-planner-worktrees.test.ts`.
- [x] AC-3: The corpus includes accepting rows for every `preparation_status` value and rejecting rows for each error string, including a drive-prefixed `path`, a leading-slash `path`, a backslash `path`, a `..` segment `path`, a duplicate `branch`, an unknown `feature_folder`, and a non-list `planner_worktrees`.
- [x] AC-4: All existing epic-planner validator tests in Python and TypeScript pass unchanged.
- [x] AC-5: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` allows `git worktree remove` of a target whose branch is named by an eligible record (`prepared` and, separately, `fanned_in`) when no in-use condition holds, the worktree is clean, and `HEAD` is an ancestor of the integration remote-tracking ref; and also when it is an ancestor only of `refs/remotes/origin/<branch>`.
- [x] AC-6: `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` allows the same recorded, eligible, clean, pushed, not-in-use target.
- [x] AC-7: `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` allows the same recorded, eligible, clean, pushed, not-in-use target.
- [x] AC-8: The planner allow suites' allow cases fail before the change (deny) and pass after it, recorded under `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/evidence/regression-testing/` with `ExpectedExitCode`.
- [x] AC-9: Each gate denies a recorded target whose `git status --porcelain=v1 --untracked-files=all` output is non-empty, appending `Planner worktree: PLANNER_WORKTREE_DIRTY: <detail>.`, including when the command carries `--force`.
- [x] AC-10: Each gate denies an unrecorded target with deny text byte-identical to the pre-change text, asserted against literal expected strings for the Claude epic gate (with diagnostics clause), the Claude parallel gate, and the Codex gate.
- [x] AC-11: A target that equals or encloses the session root, or equals the root holding the planner checkpoint, is denied with `PLANNER_WORKTREE_IN_USE` and detail beginning `U1`.
- [x] AC-12: A target that is the main checkout root is denied with `PLANNER_WORKTREE_IN_USE` and detail beginning `U2`.
- [x] AC-13: A target whose porcelain record carries a `locked` line (fixture modeled on `locked claude agent <id> (pid N)`) is denied with `PLANNER_WORKTREE_IN_USE` and detail beginning `U3`, with and without `--force` on the command.
- [x] AC-14: A target holding an unparseable `artifacts/orchestration/orchestrator-state.json`, and separately one whose `next_step` is not `S5_atomic_execution`, is denied with `PLANNER_WORKTREE_IN_USE` and detail beginning `U4`; an absent file does not trigger U4.
- [x] AC-15: A target recorded by a live epic checkpoint through `features[].worktree_path`, and separately through `features[].branch_name`, is denied with `PLANNER_WORKTREE_IN_USE` and detail beginning `U5`.
- [x] AC-16: A target whose `HEAD` is an ancestor of neither remote-tracking ref is denied with `PLANNER_WORKTREE_NOT_PUSHED`.
- [x] AC-17: A recorded target with `purpose` other than `preparation`, or with `preparation_status` of `preparing`, `removed`, or `abandoned`, is denied with `PLANNER_WORKTREE_NOT_ELIGIBLE`.
- [x] AC-18: A branch named by records in more than one planner checkpoint, or checked out in more than one live root, is denied with `PLANNER_WORKTREE_AMBIGUOUS`.
- [x] AC-19: A non-zero `git status` exit, a failing `git rev-parse --verify HEAD`, and a `merge-base --is-ancestor` exit other than 0 or 1 each deny with `PLANNER_WORKTREE_GIT_FAILED`.
- [x] AC-20: On a refusal, the gate token appears exactly once, the planner sentence follows the diagnostics clause on the Claude epic gate, and a manifest allow still allows a target the planner check refused.
- [x] AC-21: A detached-HEAD target never matches a record, and a record whose `path` does not match the target does not name it.
- [x] AC-22: `.claude/skills/epic-plan/SKILL.md` and `.agents/skills/epic-plan/SKILL.md` contain `## Preparation Worktree Records` with the recording protocol of D12, and their Fan-In removal steps point to it.
- [x] AC-23: `.claude/agents/epic-planner.md` `## Checkpoint Persistence` and `.codex/agents/epic-planner.toml` `## Checkpoint` list `planner_worktrees` and its fields.
- [x] AC-24: The `.DESCRIPTION` block of each of the three removal gates documents the planner branch, its cascade position, the refusal codes, and the honest disclosure; `.claude/skills/parallel-orchestrate/SKILL.md` and `.claude/rules/parallel-orchestration.md` name the planner allow branch.
- [x] AC-25: `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` are unchanged, and their pinned hashes in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` still match.
- [x] AC-26: The validators reject a `path` carrying a drive, a leading slash, a backslash, a `:`, or a dot segment, and no field of the record carries an absolute host path.
- [x] AC-27: No test fixture, corpus file, or evidence file added by this item contains an absolute host path; the only drive-shaped values are the rejection-row tokens.
- [x] AC-28: The skill and agent text instructs recording the branch identity and, optionally, a repository-relative path, and never an absolute path.
- [x] AC-29: Every new or edited file under `.claude/hooks/`, `.codex/hooks/`, `.claude/skills/epic-plan/`, `.claude/skills/parallel-orchestrate/`, `.claude/rules/parallel-orchestration.md`, `.claude/agents/epic-planner.md`, `.agents/skills/epic-plan/`, and `.codex/agents/epic-planner.toml` is byte-identical to its bundle mirror; both pack manifests list the new hook files; `.claude/hooks/hook-planner-worktree-removal.ps1` and `.codex/hooks/hook-planner-worktree-removal.ps1` are byte-identical and pinned in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
- [x] AC-30: The push-down and contract tests listed in research section 6 pass, including `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness tests, `test_push_down_pack_manifest_dependency_closure.py`, `scripts/dev_tools/generate_codex_agent_variants.py --check`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_claude_rules_frontmatter.py`, `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `test_epic_skill_script_citations_shipped.py`, `test_single_pass_preflight_contracts.py`, `test_push_down_codex_and_agents_customizations.py`, `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, and `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`.
- [x] AC-31: Every existing gate suite listed in research section 7 passes unchanged, `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` passes with both Claude gates and the resolution sibling at or below 500 lines, and `Invoke-PoshQCLeakScan` passes.
- [x] AC-32: Each new PowerShell file has at least 85% line coverage; `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts` has at least 85% line and 75% branch coverage enforced by its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`; changed lines of `scripts/dev_tools/validate_epic_planner_state.py` have at least 85% line and 75% branch coverage measured with `--cov=scripts.dev_tools.validate_epic_planner_state`.
- [x] AC-33: Gate evidence comes from one Pester run through `Invoke-PoshQCParallelTest`, Python evidence from one `pytest -n auto` run, and TypeScript evidence from a normal Jest worker run; no gate evidence uses a serial, single-process, shuffled, or reversed run.
- [x] AC-34: New tests use no temporary files, no wall-clock waits, and no live git process; all git and file reads go through mocked seams.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)
