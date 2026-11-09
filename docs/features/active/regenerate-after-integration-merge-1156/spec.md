# regenerate-after-integration-merge — Spec

- **Issue:** #1156
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09T21-35
- **Status:** Draft
- **Version:** 0.2
- **Research:** `docs/features/active/regenerate-after-integration-merge-1156/research/research.2026-11-09T21-35.md`

## Overview

Today, when a feature branch merges the integration branch (epic fan-in, early start) or `origin/main` (standalone S9, parallel main sync) and the merge conflicts, the orchestrator converts the conflict into a synthetic Blocking finding and runs the full R1-R5 remediation loop. That loop counts against the three-attempt remediation limit even when the only conflicted content is generated or derived output that a deterministic command can rebuild on the merged tree.

This feature adds a repository-declared regeneration command. When every path that both sides of a merge changed matches the repository's declared generated-path patterns, the orchestrator takes a regenerate path: it runs the command on the merged tree, verifies idempotency and confinement, verifies that every non-generated path in the result equals one already-reviewed parent, runs the local unit gate, commits, and re-runs CI. The regenerate path records a delta review outcome and consumes no remediation attempt. In every other case the existing remediation loop runs unchanged. After each feature merges into an epic integration branch, the epic orchestrator runs the same command on the integration tip, commits any diff, and verifies CI before the next feature syncs.

- Target users/personas and primary use cases: the epic orchestrator operator and repository owner, whose epics contain several features that each touch the same generated artifacts (counts, inventories, generated code).
- Success metrics or expected impact: a merge whose only overlapping changes are declared generated paths completes without a planner, preflight, or full re-review cycle, and leaves `remediation_loop.completed_attempts` unchanged. A repository without a declaration behaves exactly as today.

## Behavior

### Main flow: feature-side regenerate path

1. At each point where today's procedure would convert a merge conflict into a synthetic Blocking finding (orchestrate S9 step 6 for a non-mergeable PR, epic `## Merge-Conflict Handling (Fan-In)`, epic early-start step 7, parallel `## Per-Item Merge-Conflict Handling` after the issue #643 project-file resolver escalates), the orchestrator first checks whether `config/orchestration-regeneration.json` exists in the feature worktree. When it does not exist, the orchestrator does not invoke the entry point, and today's procedure runs unchanged.
2. When the file exists, the orchestrator fetches the incoming branch and invokes `pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1 -Mode Merge -MergeRef <remote-tracking ref> -Trigger <integration_sync or main_sync>` from the feature worktree root.
3. The entry point reads and validates the config, performs `git merge --no-commit --no-ff` of the ref, derives the classifier input set, classifies, and either completes the preparation steps below or restores the worktree and reports a fallback.
4. Preparation steps (in order): resolve conflicted generated paths to the feature side, run the command (run 1), check confinement, stage run-1 output, run the command again (run 2) and the optional idempotency check, check idempotency, run the delta verification, run the declared unit gate when declared.
5. On success the entry point leaves the merge in progress with all results staged and emits one JSON object. The orchestrator then runs the standard local unit gate when the entry point reported `unit_gate: "not_run"`, writes the evidence file, commits the merge with `git commit -F`, pushes, appends the `regeneration_events[]` entry and the delta `review_outcomes[]` entry with `head_sha` equal to the pushed head, and re-runs S9 on the new head.

### Alternate flow: fallback

Any classifier decision other than `regenerate`, and any failure in the preparation steps, the orchestrator-run unit gate, or the commit, ends the regenerate attempt. The entry point (or, after it has exited, the orchestrator) runs `git merge --abort`, the orchestrator appends a `regeneration_events[]` entry with `outcome: "fell_back"`, and today's procedure runs unchanged from its first step (fresh merge, synthetic Blocking finding, R1-R5). The fallback cycle consumes an attempt exactly as today; the regenerate attempt itself consumes none.

### Epic integration-tip flow

1. After the epic orchestrator records a child's `merge_status: "merged"`, and when the integration worktree contains a valid `config/orchestration-regeneration.json`, it fetches and fast-forwards the integration worktree, then invokes the entry point with `-Mode Tip`.
2. In `Tip` mode the entry point runs the command twice with confinement and idempotency checks, without staging and without committing, and reports the changed paths.
3. When the changed-path list is non-empty and the result is applied, the epic orchestrator runs `git add -- <changed paths>` and `git commit -F <message file>`, admitted by the new preimplementation allowance, and pushes.
4. Whether or not a regeneration commit was made, the epic orchestrator dispatches CI on the integration branch with `gh workflow run CI --ref <integration branch>`, locates the run with `gh run list --commit <tip> --workflow CI`, polls every 30 seconds for at most 90 minutes, and appends an `integration_regenerations[]` entry.
5. The epic orchestrator does not merge another child and does not launch another wave until the integration tip has a completed `CI` run with conclusion `success`.
6. When the `Tip` result is not applied, the entry point has restored every path it changed, no regeneration commit is made, CI dispatch and verification still run, and later child syncs reach the feature-side classifier as usual.

### Epic main sync

During `## Epic Integration Branch Lifecycle` step 3, when the merge of `origin/main` into the integration branch conflicts and the integration worktree holds a valid config, the epic orchestrator invokes `-Mode Merge -Trigger main_sync`. On success it commits during the in-progress merge (already admitted by the gate because `MERGE_HEAD` exists), pushes, and runs the same CI dispatch and verification before the wave launches. On fallback, today's step 3 conflict resolution runs unchanged.

### Child-side verification before sync

In epic mode, when the child's feature worktree holds a valid config, a child about to merge the integration branch (fan-in conflict handling or early-start step 7) first confirms with `gh run list --commit <integration tip> --workflow CI` that the tip has a completed run with conclusion `success`, polling every 30 seconds for at most 90 minutes. On timeout the child follows the existing wait branch with `blocked_reason: "awaiting_ci"`. Without a valid config the child does not wait.

### Error handling and recovery

- The entry point never leaves a partially regenerated tree: every failure branch after the merge started calls `git merge --abort` (`Merge` mode) or restores the paths it changed (`Tip` mode) before it exits.
- No branch uses `git reset --hard`.
- A present but invalid config never applies partially; it yields `config_invalid` and the validator errors are recorded under the checkpoint's `artifact_errors`.

## Inputs / Outputs

### Config file

Path: `config/orchestration-regeneration.json`, relative to the worktree root. It is repository-local: it is never placed in `extensions/drm-copilot/resources/config/`, so push-down never publishes it, and each destination repository authors its own. This repository does not add the file in this item (D11).

Version 1 shape:

- `version` (required): JSON integer `1`.
- `regeneration` (required key, value an object or `null`):
  - `command` (required): non-empty array of non-empty strings; argv executed with no shell from the worktree root.
  - `paths` (required): non-empty array of declared path patterns.
  - `idempotency_check` (optional): non-empty array of non-empty strings; argv that must exit 0 after run 2.
  - `unit_gate` (optional): non-empty array whose every element is a non-empty array of non-empty strings; each element is one argv run in order and each must exit 0. Absent means the standard parallel gates of `## Test Isolation Checks` in the execution-environment brief, run by the orchestrator.

Validation rules (each violation produces one error string naming the key path; errors accumulate; any error yields `config_invalid`):

1. Text that does not parse as a JSON object.
2. `version` absent, or not the JSON integer `1` (a string, boolean, or fractional value is rejected).
3. `regeneration` present with a value that is neither an object nor `null`.
4. A key inside `regeneration` other than `command`, `paths`, `idempotency_check`, `unit_gate`.
5. `command` absent, not an array, empty, or holding an element that is not a string or is empty or whitespace-only.
6. `paths` absent, not an array, empty, or holding a non-string element.
7. A `paths` entry that is empty, begins with a forward slash, contains a backslash, begins with a drive letter followed by a colon, contains an empty segment, a `.` segment, or a `..` segment, or contains a square bracket character.
8. `idempotency_check` present and not a non-empty array of non-empty strings.
9. `unit_gate` present and not a non-empty array of non-empty arrays of non-empty strings.

Default-off: file absent, `regeneration` key absent, or `regeneration: null` means no configuration (reason `no_config`), and behavior equals today's behavior.

### Entry point

`pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1` with parameters:

- `-Mode` (required): `Merge` or `Tip`.
- `-MergeRef` (required for `Merge`, rejected for `Tip`): the remote-tracking ref to merge.
- `-Trigger` (required for `Merge`): `integration_sync` or `main_sync`.
- `-ConfigPath` (optional): relative path of the config file; default `config/orchestration-regeneration.json`.

Output: exactly one JSON object on stdout with keys `mode`, `trigger`, `decision`, `reason`, `unmatched_paths`, `config_errors`, `feature_head_sha`, `merge_head_sha`, `merge_base_sha`, `command_exit_code`, `confined`, `idempotent`, `unit_gate`, `delta_check`, `changed_paths`, `outcome`, `at`, `event`, `review_outcome`, and `evidence_text`. In `Tip` mode `merge_head_sha`, `merge_base_sha`, `review_outcome`, and `delta_check` are `null` or `not_run` as applicable.

Exit codes: `0` regenerate path prepared (`Merge`) or result applied (`Tip`); `3` fall back or not applied (worktree restored); `1` git or process failure (worktree restored); `2` usage error (no git call made).

### Checkpoint and evidence outputs

- Per-feature checkpoint, tolerated top-level list `regeneration_events[]` (shape in Data & State).
- Per-feature checkpoint, one `remediation_loop.review_outcomes[]` entry per completed regenerate path.
- Epic checkpoint, tolerated top-level list `integration_regenerations[]`.
- Evidence: a new file in the feature folder's `evidence/qa-gates/` directory named `regeneration-delta.` followed by the UTC write timestamp and `.md`. It contains the lines `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (classifier reason, confined, idempotent, unit-gate result, delta result), the UTC time from the injected clock, and no absolute path. A later pass writes a new file; no existing evidence file is edited or deleted.

### Backward compatibility

- Every new key is tolerated and unvalidated by the Python, TypeScript, and PowerShell checkpoint validators; no member of `REQUIRED_STATE_KEYS` is added and no validator code changes.
- `remediation_path` stays `light` or `full`; no new value is introduced.
- The portable handoff projection drops the new keys, as it drops `review_mode`.

## API / CLI Surface

### Pure functions (host-neutral, no I/O)

- `.claude/lib/regeneration/RegenerationConfig.psm1`: `ConvertFrom-RegenerationConfigText -Text <string>` returns `{ Config, Errors }` where `Config` is the parsed `regeneration` object or `$null`; `Get-RegenerationConfigError -Document <object>` returns the list of rule violations above.
- `.claude/lib/regeneration/RegenerationClassifier.psm1`:
  - `Get-RegenerationChangedPath -OursListing <string> -TheirsListing <string>` takes NUL-separated `git diff --name-only -z --no-renames` outputs and returns the ordinal-sorted, de-duplicated intersection with empty entries removed.
  - `Test-RegenerationPathMatch -Path <string> -Pattern <string[]>` applies the glob semantics below.
  - `Get-RegenerationPathDecision -ChangedPath <string[]> -MergeBaseCount <int> -Config <object> -ConfigError <string[]>` returns `{ Decision, Reason, UnmatchedPath }`.
- `.claude/lib/regeneration/RegenerationDelta.psm1`: confinement decision, idempotency decision, delta decision, and the builders for the `regeneration_events[]` entry, the delta review outcome, the `integration_regenerations[]` entry, and the evidence text. Builders take the timestamp as an argument.

### Classifier rule order (first match wins)

| Order | Condition | Decision | Reason |
|---|---|---|---|
| 1 | `Config` is `$null` | `remediation_loop` | `no_config` |
| 2 | `ConfigError` non-empty | `remediation_loop` | `config_invalid` |
| 3 | `MergeBaseCount` is not exactly 1 | `remediation_loop` | `multiple_merge_bases` |
| 4 | `ChangedPath` empty | `remediation_loop` | `empty_set` |
| 5 | Any path matches no declared pattern | `remediation_loop` | `unmatched_path` (with `UnmatchedPath` ordinal-sorted) |
| 6 | Otherwise | `regenerate` | `all_match` |

`UnmatchedPath` is empty for every reason except `unmatched_path`.

### Glob semantics

Matching delegates to `Test-GlobMatch` in `.claude/lib/blast-radius/BlastRadiusGlob.psm1`: whole-string, ordinal, case-sensitive; a single-star wildcard and a question-mark wildcard do not cross a forward slash; a double-star wildcard crosses forward slashes; character classes are unsupported. In addition, a pattern that begins with a double-star segment followed by a forward slash also matches the remainder of the pattern at the repository root (the same rule as the mechanically-mergeable matcher of issue #643). A candidate path containing a backslash never matches. A candidate that differs from a pattern only by letter case does not match.

### Classifier input derivation (I/O adapter)

1. `git merge-base --all HEAD MERGE_HEAD`; the line count is `MergeBaseCount`.
2. With exactly one base B: `git diff --name-only -z --no-renames B HEAD` (ours) and `git diff --name-only -z --no-renames B MERGE_HEAD` (theirs).
3. `ChangedPath` is `Get-RegenerationChangedPath` of the two listings. It contains every conflicted and every auto-merged path. Merge-output text such as auto-merge lines is never parsed.

### Idempotency and confinement (`Merge` mode)

1. Resolve each conflicted path (`git diff --name-only -z --diff-filter=U`) with `git checkout --ours -- <paths>` and `git add -- <paths>`. Then `git diff --name-only -z` and `git ls-files --others --exclude-standard -z` must both be empty; otherwise the attempt fails.
2. Run 1: the declared `command`. C1 is the union of unstaged changes and untracked files. Confined means every path in C1 matches a declared pattern. Not confined is a failure. Stage C1 with `git add -A -- <C1 paths>`.
3. Run 2: the declared `command` again, then `idempotency_check` when declared. C2 is the union of unstaged changes and untracked files. Idempotent means C2 is empty and `idempotency_check`, when declared, exits 0.
4. A non-zero exit from either command run is a failure and is reported in `command_exit_code`.

### Idempotency and confinement (`Tip` mode)

Preconditions: no merge in progress and an empty `git status` listing. Run 1, then a snapshot of each path in C1 with its blob id from `git hash-object`. Confinement as above. Run 2 and the optional `idempotency_check`. Idempotent means the changed-path set and every blob id after run 2 equal the run-1 snapshot. The entry point does not stage. On a not-applied result it restores tracked changed paths with `git checkout -- <paths>` and removes untracked paths it created with `git clean -f -q -- <paths>`.

### Delta verification

With P1 = feature head (`HEAD`), P2 = incoming tip (`MERGE_HEAD`), B = merge base, and H = the staged result:

- For every path in `git diff --cached --name-only -z --no-renames P1` that matches no declared pattern, the path is in `diff(B, P2)`.
- For every path in `git diff --cached --name-only -z --no-renames P2` that matches no declared pattern, the path is in `diff(B, P1)`.

Both relations holding is `delta_check: "pass"`; either violated is `"fail"` and a fallback. Together with classifier rule 5, this shows every non-generated path in the result equals the content of one already-reviewed parent.

### Merge-gate consistency check

New byte-identical helper `enforce-epic-merge-gate-regeneration.ps1` in `.claude/hooks/` and `.codex/hooks/`, dot-sourced by `.claude/hooks/enforce-epic-merge-gate.ps1` and `.codex/hooks/enforce-epic-merge-gate.ps1` and evaluated immediately after the review guard returns no denial. It applies only when the last `remediation_loop.review_outcomes[]` entry has `review_kind` exactly `regeneration_delta` (ordinal). It then requires a `regeneration_events[]` entry whose `head_sha` equals that outcome's `head_sha` and which records `outcome: "regenerated"`, `idempotent: true`, `confined: true`, `unit_gate: "pass"`, and `delta_check: "pass"`. Otherwise it denies with `EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: <detail>`. It runs no process.

### Preimplementation allowance

New function `Get-EpicRegenerationAllowance` in a new byte-identical file `hook-epic-regeneration.ps1` in `.claude/hooks/` and `.codex/hooks/`, called from `Get-OrchestrationEpicScopeDecision` in `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, only when the readiness failure is exactly `'merge-in-progress'`. It admits a Bash command only when all of the following hold:

1. The worktree HEAD is the epic `integration_branch`.
2. The command is a single `git add` with optional `--` followed by one or more paths, or a single `git commit` whose options are drawn only from `-m`, `--message`, `-F`, `--file`, and `--trailer`, optionally followed by `--` and paths.
3. Every named path, and for a `git commit` without paths every staged path read through the injected reader, matches a pattern of a valid regeneration config read from the integration worktree through an injected config reader.
4. No named path contains a backslash, an asterisk, a question mark, a square bracket, a `.` or `..` segment, or a leading forward slash.

It never admits Write or Edit, `git commit -a`, `--all`, `--amend`, `--no-verify`, or a chained command. When the config is absent or invalid, it admits nothing. Every other existing deny is unchanged.

### Agent grant

`.claude/agents/epic-orchestrator.md` gains one Bash tool grant for the command prefix `pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1` followed by any arguments, written in the same form as the existing `Invoke-CiGateParser.ps1` grant (D12). No generic command route is granted.

## Data & State

### `regeneration_events[]` entry (per-feature checkpoint)

`{ at, trigger, feature_head_sha, merge_head_sha, merge_base_sha, classifier: { decision, reason, unmatched_paths }, command_exit_code, confined, idempotent, unit_gate, delta_check, head_sha, evidence_path, outcome }`

- `at`: ISO-8601 UTC with `Z` from the injected clock.
- `trigger`: `integration_sync` or `main_sync`.
- `unit_gate`, `delta_check`: `pass`, `fail`, or `not_run`.
- `head_sha`: the pushed commit for `outcome: "regenerated"`, otherwise `null`.
- `outcome`: `regenerated` or `fell_back`. A fallback is recorded, so the audit trail shows why the loop ran.

### Delta review outcome (per-feature checkpoint)

`{ verdict: "PASS", findings: [], head_sha: <pushed head>, review_kind: "regeneration_delta", evidence_path: <relative evidence file path> }`, appended to `remediation_loop.review_outcomes[]`. `review_kind` and `evidence_path` are tolerated extra keys.

### `integration_regenerations[]` entry (epic checkpoint)

`{ trigger, after_feature_issue_num, merge_commit_sha, regeneration_commit_sha, command_exit_code, confined, idempotent, outcome, ci_run_id, ci_conclusion, verified_at }`; `trigger` is `post_feature_merge` or `main_sync`; `after_feature_issue_num` is `null` for `main_sync`; `regeneration_commit_sha` is `null` when no diff was committed; `outcome` is `applied` or `not_applied`.

### Invariants

- No `remediation_loop.cycles[]` entry is written by the regenerate path, so invariant R7 (`completed_attempts` equals the count of cycles with `candidate_applied: true`) holds without change.
- Evidence and checkpoint lists are append-only.
- No migration or backfill is required.

## Constraints & Risks

- Default-off: every new config knob defaults to today's behavior. A repository without the config file, or with `regeneration` absent or `null`, observes no new git call, no new wait, and no new deny.
- No remediation attempt is consumed by the regenerate path, whether it succeeds or falls back; the three-attempt termination guard is otherwise unchanged.
- Codex behavior equals today's behavior: Codex orchestrators do not run the regenerate path, and the `.codex/hooks/` twins are inert for checkpoints without the new keys. `.agents/skills/orchestrate/SKILL.md` and `.agents/skills/epic-orchestrate/SKILL.md` are not edited.
- Honest disclosure: the merge-gate consistency check and the preimplementation allowance are policy-level controls, not security controls. A writer in the same session can author `regeneration_events[]` and a delta outcome; the controls prove internal consistency, not origin. The `review/verdict` status description continues to name the last full review's audit file.
- Waits: the child-side and epic-side CI waits poll every 30 seconds for at most 90 minutes, and apply only when a valid config exists.
- Repositories with a nondeterministic or out-of-pattern generator always fall back and gain no benefit; they gain no new risk.
- File size: `.claude/hooks/enforce-epic-merge-gate-review.ps1` is not edited; `.claude/hooks/hook-epic-fan-in.ps1` is not edited; new logic lives in new files; entry-file edits are one guarded dot-source and one call each (D13 for the line budget of `.claude/hooks/enforce-epic-merge-gate.ps1`).
- Sibling items #1157, #1158, #1159, #1160, #1161, #1162, and #1163 may edit the same files. This spec assumes no merge order. Whichever item merges after another that moved a pinned digest in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` recomputes the digest after merging `origin/main` and records a dated combined re-baseline comment.

## Implementation Strategy

- Implementation scope: three pure PowerShell modules and one thin adapter under `.claude/lib/regeneration/`; two new hook helpers with Codex twins; one-call edits to the two merge-gate entry files and the two epic-scope gate files; documentation edits to skills, agents, and the rules file; two corpus fixtures; mirrors and manifests.
- Adapter seams in `Invoke-RegenerationPath.ps1`: `Invoke-RegenerationGitExe -GitArgs` (all git calls), `Invoke-RegenerationProcess -Argv` (declared command, idempotency check, and unit gate), a config-text reader, and a clock supplied as a `-UtcNow` scriptblock. The adapter emits one JSON object and follows the fact-request pattern of `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1`.
- Dependency changes: none. `.claude/lib/blast-radius/BlastRadiusGlob.psm1` is reused.
- Logging/telemetry: the JSON result, the checkpoint lists, and the evidence file.
- Rollout: default-off; a repository opts in by committing its own config file.

### Concrete write paths

New:

- `.claude/lib/regeneration/RegenerationConfig.psm1`
- `.claude/lib/regeneration/RegenerationClassifier.psm1`
- `.claude/lib/regeneration/RegenerationDelta.psm1`
- `.claude/lib/regeneration/Invoke-RegenerationPath.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/RegenerationConfig.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/RegenerationClassifier.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/RegenerationDelta.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1`
- `.claude/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `.codex/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `.claude/hooks/hook-epic-regeneration.ps1`
- `.codex/hooks/hook-epic-regeneration.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-epic-regeneration.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-epic-regeneration.ps1`
- `tests/scripts/claude-lib/regeneration/RegenerationConfig.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/RegenerationClassifier.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/RegenerationDelta.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1`
- `tests/scripts/claude-hooks/hook-epic-regeneration.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1`
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`
- `tests/fixtures/orchestrator_state_remediation_loop/regeneration_event_tolerated_accepted.json`
- `tests/fixtures/orchestrator_state_remediation_loop/regeneration_after_completed_cycle_accepted.json`

Edited:

- `.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/epic-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
- `.claude/agents/orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`
- `.claude/agents/epic-orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md`
- `.claude/rules/orchestrator-state.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
- `.claude/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
- `.codex/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewGuard.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`
- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

## Decisions

- **D1 — Config location and default-off.** Decision: repository-local `config/orchestration-regeneration.json`, version 1, validated by a pure function; absent, missing key, or `null` means today's behavior. Rationale: push-down reads only bundle config, so the file is never published to other repositories. Rejected: a `regeneration` key in `config/orchestration-routing.json`, because it is byte-mirrored and appended into destinations by the routing merge.
- **D2 — Classifier contract and glob semantics.** Decision: pure `Get-RegenerationPathDecision` over the both-sides-changed set with the first-match rule order and `Test-GlobMatch` semantics plus the root-level double-star rule; the missing `## Merge-Conflict Remediation` section of the orchestrate skill is created to hold it. Rationale: deterministic, fail-closed, reuses an existing pure glob engine, and repairs a dangling reference. Rejected: parsing localizable auto-merge output text.
- **D3 — Checkpoint recording outside `cycles[]`.** Decision: tolerated top-level `regeneration_events[]`; no cycle entry. Rationale: R7 and the three-attempt guard hold by construction with no validator change. Rejected: a `remediation_path: "regenerate"` cycle, which needs a three-runtime contract change, a `plan_path`, and a new R7 exclusion.
- **D4 — Delta review shape.** Decision: a deterministic merge-delta verification recorded as a `PASS` review outcome with `review_kind: "regeneration_delta"` and a qa-gates evidence file. Rationale: proves every non-generated path equals an already-reviewed parent. Rejected: a narrowed `feature-review` (violates its scope invariant) and `staged-review` (non-canonical evidence location, re-judges reviewed changes).
- **D5 — Concurrent review, CI join, cross-check, and review/verdict.** Decision: append sentences to rule 7 (delta outcome is the new review for the new head) and rule 11 (the CI cross-check applies to `feature-review` outcomes only); no code change to review/verdict. Rationale: avoids false synthetic Blocking findings while keeping pinned wording. Rejected: rewriting the pinned rule sentences.
- **D6 — Merge-gate acceptance.** Decision: a key-gated consistency check in a new helper denying with `REVIEW_GATE_REGENERATION_UNVERIFIED`. Rationale: makes acceptance of regenerate evidence explicit while staying inert for every existing checkpoint. Rejected: editing `enforce-epic-merge-gate-review.ps1`, which sits one line below the advisory size tier.
- **D7 — Epic post-merge regeneration and CI before the next sync.** Decision: epic orchestrator runs `Tip` mode after each child merge, commits via a narrow new preimplementation allowance, dispatches and verifies CI, and children verify the tip's CI before syncing. Rationale: the parent cannot pause a running child, so the guarantee rests on durable GitHub state. Rejected: committing from inside a script, which would bypass the gate.
- **D8 — Parallel main sync.** Decision: adopt by reference; the child orchestrator applies the orchestrate skill's regenerate path before writing a synthetic finding, after the issue #643 resolver. Rationale: the delta outcome must live in the child checkpoint that the merge guard and the join read. Rejected: parent-level regeneration.
- **D9 — Idempotency definition.** Decision: run the command twice; idempotent when the second run leaves no diff relative to the first run's staged output (`Merge`) or blob-id snapshot (`Tip`), plus an optional exit-0 check; confinement to declared patterns; every failure aborts or restores. Rationale: a mechanical, git-observable definition that never stages on the integration branch from inside a script. Rejected: single-run regeneration and `git reset --hard` recovery.
- **D10 — Language, placement, seams, runtime scope.** Decision: PowerShell 7 modules under `.claude/lib/regeneration/`, thin adapter with git, process, config-reader, and clock seams; Claude runtime only, Codex hook twins inert. Rationale: owner language policy and testability without I/O. Rejected: new Python and a Codex orchestrator implementation in this item.
- **D11 — No self-hosted declaration.** Decision: this repository does not add `config/orchestration-regeneration.json` in this item; tests use in-memory config text. Rationale: this repository and the sibling runs keep today's default-off behavior. Rejected: declaring the Codex variant generator as this repository's regeneration command now.
- **D12 — Entry-point invocation.** Decision: `pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1`, granted to `epic-orchestrator` as one prefix grant. Rationale: follows the existing `Invoke-CiGateParser.ps1` precedent in the same tool list. Rejected: a generic command route or an `sh` launcher.
- **D13 — Merge-gate entry-file line budget.** Decision: `.claude/hooks/enforce-epic-merge-gate.ps1` stays at or under the 500-line bound pinned by `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`; its one added dot-source and one added call are offset by collapsing three existing single-statement brace blocks to the one-line form, and the bound is not raised. Rationale: the file is at the bound today, and the collapse changes no statement. Rejected: raising the pinned bound.
- **D14 — Evidence path function.** Decision: `RegenerationDelta.psm1` also exports pure `Get-RegenerationEvidencePath`, which returns the `evidence/qa-gates/regeneration-delta.<timestamp>.md` path under a feature folder for the delta outcome's `evidence_path`. Rationale: the file-name rule needs a tested implementation. Rejected: leaving the name to skill prose only.

## Acceptance Criteria

### Config (issue AC1)

- [ ] [AC1] `Get-RegenerationConfigError` returns an empty list for a valid version 1 document and returns one error naming the key path for each violation of validation rules 1 through 9 in `## Inputs / Outputs`, with errors accumulating in rule order; a Pester case per rule fails if that rule is not enforced.
- [ ] [AC1] For config text that is absent, lacks the `regeneration` key, or sets `regeneration` to `null`, the classifier returns `remediation_loop` with reason `no_config`, and the adapter test asserts that the entry point makes no `git merge` call, runs no declared command, and exits 3.
- [ ] [AC1] For a present but invalid config, the entry point returns reason `config_invalid` with the validator errors in `config_errors`, makes no `git merge` call, runs no declared command, and exits 3.
- [ ] [AC1] The orchestrate skill's `## Merge-Conflict Remediation` section and the rules-file section `## Regeneration-Path Scope and Backward Compatibility` document `version`, `command`, `paths`, `idempotency_check`, and `unit_gate` with their validation rules and the default-off rule, pinned by `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`.
- [ ] [AC1] Neither `config/orchestration-regeneration.json` nor `extensions/drm-copilot/resources/config/orchestration-regeneration.json` exists in the repository after this item, asserted by the skill-contract test (D11).

### Classifier (issue AC2)

- [ ] [AC2] `Get-RegenerationPathDecision` applies the first-match rule order in `## API / CLI Surface`, with a Pester case for each of: all-match (`regenerate`, `all_match`), partial-match (`unmatched_path`, with the unmatched paths ordinal-sorted), no config (`no_config`), empty set (`empty_set`), config invalid (`config_invalid`), and merge-base count of 0 and of 2 (`multiple_merge_bases`); a case with both no config and an empty set returns `no_config`, proving first-match order.
- [ ] [AC2] `Test-RegenerationPathMatch` cases fail if: a root-level path is not matched by a pattern that begins with a double-star segment followed by a slash and that path; a single-star wildcard matches across a slash; a case variant matches; a candidate containing a backslash matches.
- [ ] [AC2] `Get-RegenerationChangedPath` returns the ordinal-sorted, de-duplicated intersection of two NUL-separated listings with empty entries removed; cases cover disjoint listings (empty result), overlapping listings, and trailing NUL terminators.
- [ ] [AC2] The classifier module performs no I/O: its tests run with no git, process, or file-system mock and no temporary file.

### Regenerate path (issue AC3)

- [ ] [AC3] Adapter tests with mocked `Invoke-RegenerationGitExe` and `Invoke-RegenerationProcess` assert the `Merge`-mode call order: config read, `git merge --no-commit --no-ff`, `git merge-base --all`, the ours and theirs `--no-renames` diffs, conflict resolution with `git checkout --ours` and `git add`, run 1, confinement, `git add -A`, run 2, `idempotency_check` when declared, the cached delta diffs against each parent, the declared unit-gate argvs in order; and exit 0 with `outcome` ready for commit.
- [ ] [AC3] Each failure branch exits 3 (or 1 for a git or process failure), calls `git merge --abort` exactly once, and makes no `git commit` call: non-zero run 1, non-zero run 2, run-1 output outside the declared patterns, non-empty C2, non-zero `idempotency_check`, a delta violation on either side, a non-zero declared unit-gate argv, and a non-empty tree after conflict resolution. A test per branch fails if the abort is missing.
- [ ] [AC3] The delta decision returns `pass` when every non-generated path changed relative to each parent is in the other parent's diff from the base, and `fail` for a one-sided violation in each direction; a generated path changed relative to both parents does not cause `fail`.
- [ ] [AC3] `Tip` mode applies the blob-id snapshot idempotency rule, makes no `git add` and no `git commit` call, and on a not-applied result restores tracked paths with `git checkout --` and removes created untracked paths with `git clean -f -q --`; a test fails if any of these calls is missing or extra.
- [ ] [AC3] The `regeneration_events[]` builder, delta review outcome builder, and evidence-text builder produce the exact shapes in `## Data & State`, the evidence text contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` lines, uses the injected clock value, and contains no drive letter or leading-slash absolute path.
- [ ] [AC3] The orchestrate skill states that after a successful `Merge` result the orchestrator runs the standard parallel unit gates when `unit_gate` is `not_run`, writes a new evidence file (never editing an existing one), commits with `git commit -F`, pushes, appends the event and the delta outcome with `head_sha` equal to the pushed head, and re-runs S9; and that a failure after the entry point exits runs `git merge --abort` and falls back. Pinned by the skill-contract test.

### Attempt accounting (issue AC4)

- [ ] [AC4] The regenerate path writes no `remediation_loop.cycles[]` entry and does not change `completed_attempts`, whether it succeeds or falls back; the orchestrate skill and `.claude/agents/orchestrator.md` `### Remediation Loop Checkpoint Shape` state this, pinned by the skill-contract test.
- [ ] [AC4] `tests/fixtures/orchestrator_state_remediation_loop/regeneration_event_tolerated_accepted.json` (a `regeneration_events` entry, a delta `PASS` outcome, no cycles, `completed_attempts: 0`) and `tests/fixtures/orchestrator_state_remediation_loop/regeneration_after_completed_cycle_accepted.json` (one completed cycle, `completed_attempts: 1`, plus a regeneration event and delta outcome) carry `expected_errors: []` and pass in the Python, TypeScript, and PowerShell parity suites.
- [ ] [AC4] The termination guard (halt at `completed_attempts` equal to 3 with a non-`PASS` latest verdict), the pinned sentence "CI-failure and merge-conflict cycles are never light", and the pinned remediation-docs literals remain present verbatim, proven by the existing `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1` and `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py` passing unmodified.

### Epic integration-tip regeneration (issue AC5)

- [ ] [AC5] The epic-orchestrate skill states the integration-tip flow in `## Behavior` (fast-forward, `Tip` mode, `git add` and `git commit -F` of changed paths, push, `gh workflow run CI --ref` on the integration branch even with no diff, `gh run list --commit` lookup, 30-second polling for at most 90 minutes, `integration_regenerations[]` append) and that no further child merge or wave launch occurs until the tip has a successful completed `CI` run; pinned by the skill-contract test.
- [ ] [AC5] The epic-orchestrate skill states the child-side check: with a valid config, a child about to merge the integration branch confirms a successful completed `CI` run on the tip, polling 30 seconds for at most 90 minutes, and on timeout follows the wait branch with `blocked_reason: "awaiting_ci"`; without a valid config it does not wait. Pinned by the skill-contract test.
- [ ] [AC5] `Get-EpicRegenerationAllowance` tests admit `git add -- <path>` and `git commit -F <file>` on the integration branch for paths matching the config patterns, and deny each of: a path outside the patterns, a path with a backslash, asterisk, question mark, square bracket, `.` or `..` segment, or leading slash; `git commit -a`, `--all`, `--amend`, `--no-verify`; a chained command; Write and Edit; a HEAD other than the integration branch; an absent or invalid config; and a readiness failure other than `'merge-in-progress'`.
- [ ] [AC5] `.claude/agents/epic-orchestrator.md` contains the Bash grant for the `Invoke-RegenerationPath.ps1` prefix in the same form as the `Invoke-CiGateParser.ps1` grant and no other new grant, asserted by the skill-contract test.
- [ ] [AC5] The epic main-sync flow (lifecycle step 3) states that a conflicting merge with a valid config runs `Merge` mode with trigger `main_sync`, commits during the in-progress merge, and dispatches and verifies CI before the wave launches, and that a fallback runs today's step unchanged; pinned by the skill-contract test.

### Documentation, schema, and gates (issue AC6)

- [ ] [AC6] `.claude/skills/orchestrate/SKILL.md` contains a `## Merge-Conflict Remediation` section (repairing the S9 step 6 reference) holding capture, classification, the regenerate path, and the unchanged fallback; `## Concurrent Review and CI (review_mode)` rule 7 keeps its pinned sentence and gains an appended sentence that the delta outcome is the new review for the new head; rule 11 gains a sentence limiting the CI cross-check to `feature-review` outcomes. Pinned by the skill-contract test and by `tests/scripts/claude-runtime/concurrent-review-skill-contract.Tests.ps1` passing unmodified.
- [ ] [AC6] `.claude/skills/parallel-orchestrate/SKILL.md` `## Per-Item Merge-Conflict Handling` states that the child applies the regenerate path first, after the issue #643 resolver, and only a fallback writes the synthetic Blocking finding; pinned by the skill-contract test.
- [ ] [AC6] `.claude/rules/orchestrator-state.md` gains the section `## Regeneration-Path Scope and Backward Compatibility` documenting `regeneration_events[]`, `integration_regenerations[]`, `review_kind`, the tolerated-and-unvalidated status, the Claude-only scope, and the policy-level disclosure, and the `## Invariants (remediation_loop.review_outcomes)` section remains equal to the `.agents/skills/orchestrator-state/SKILL.md` copy (existing `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py` passes).
- [ ] [AC6] `tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1` show: a delta outcome at the live head with a matching complete event is allowed; a delta outcome with no matching event, or with an event whose `idempotent`, `confined`, `unit_gate`, `delta_check`, or `outcome` field differs from the required value, is denied with `EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED:`; a delta outcome at a stale ancestor with a code change is still denied with `REVIEW_GATE_HEAD_STALE`; and the helper invokes no process.
- [ ] [AC6] Every new or edited `.claude/` file listed in `### Concrete write paths` has a byte-identical bundle copy, the new lib and hook files appear in both `pack-manifests/core.json` files, and the existing push-down contract, pack-manifest completeness, and dependency-closure tests pass.
- [ ] [AC6] The `PINNED_FROZEN_SURFACE_HASHES` entries for `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` are re-baselined in place with a dated comment, and the test that reads them passes.
- [ ] [AC6] The execution-environment brief is updated identically in `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` (new epic regeneration allowance, regeneration merge-gate check, integration-tip CI dispatch), so that the listed copies remain byte-identical to one another and every existing test that compares them passes.

### Regression (issue AC7)

- [ ] [AC7] For checkpoints without `regeneration_events`, `review_kind`, and `integration_regenerations`, existing merge-gate decisions are unchanged: green-CI standalone merge (issue #997), epic-child CI verification (issue #1130), the concurrent review guard, and the fan-in and merged-feature follow-up allowances of the preimplementation gate, proven by the existing suites `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewGuard.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCi.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`, and `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1` passing in the single parallel Pester gate.
- [ ] [AC7] New regression cases appended to `tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewGuard.Tests.ps1` show that a checkpoint carrying `regeneration_events` but no `review_kind` on its last outcome receives the same decision as the same checkpoint without `regeneration_events`, and that sequential (no `review_mode`) child-CI and green-CI decisions are unchanged.
- [ ] [AC7] New regression cases appended to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1` show that, with no regeneration config in the integration worktree, every command and tool denied or allowed today on the integration branch receives the same decision.
- [ ] [AC7] The three-attempt limit is unchanged for checkpoints without the new keys: the existing remediation-loop corpus fixtures and parity suites pass unmodified.

## Non-Functional Requirements

- Language: pushed-down logic is PowerShell 7. No new Python file is added; editing `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` in place is permitted. Enforcement hooks invoke no Python.
- Separation: classification, validation, confinement, idempotency, delta, and builders are pure functions in host-neutral modules with unit tests; all I/O is in `Invoke-RegenerationPath.ps1` behind the injected git, process, config-reader, and clock seams.
- Tests: no temporary files, no real git repositories, no wall-clock waits; mocks on wrapper functions only; module import and removal paired in `BeforeAll` and `AfterAll`.
- Test gates are parallel-only: one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, and Jest through its normal parallel workers. No serial, shuffled, or reversed runs.
- Coverage: the new lib and hook files meet the repository line-coverage threshold, read from the single parallel gate's coverage output.
- Evidence is append-only and written under the feature folder's `evidence/` subdirectories.
- File size: no file above 800 lines; new logic in new files; `.claude/hooks/enforce-epic-merge-gate-review.ps1` and `.claude/hooks/hook-epic-fan-in.ps1` are not edited.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (skills, agents, rules file, execution-environment brief, bundle mirrors)
- [ ] Telemetry/logging added or updated (JSON result, checkpoint lists, evidence file)
- [ ] Toolchain pass completed (format → lint → type-check → test)
