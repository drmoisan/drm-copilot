# epic-orchestrate — Spec

- **Issue:** #275
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-02T20-30
- **Status:** Draft
- **Version:** 0.2

## Overview

The repository has a working single-feature orchestrator (`.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`) that runs one feature end-to-end: change-budget routing, delegation to `atomic-planner`/`atomic-executor`/`feature-review`/`pr-author`, a remediation loop, and an S9 CI-green gate before DONE. It has no concept of an epic — a set of features with dependencies, some of which can run concurrently. `config/orchestration-routing.json` has no `epic` route, and no agent is authorized to spawn a nested full orchestration.

This spec defines `epic-orchestrate`: a new `epic-orchestrator` agent that schedules a dependency graph of child features across parallel, isolated git worktrees (using the existing `Agent` tool's `isolation: "worktree"` and `run_in_background: true` primitives only), fans results back together via a shared epic integration branch, and drives a final integration-to-`main` PR. Every design decision the two research artifacts (`research/orchestration-mechanics.research.md`, `research/concurrency-and-hardening.research.md`) were commissioned to inform is resolved below as a committed decision, not left open for the atomic-planner to invent.

Scope confirmed Claude-only for this pass: no Codex-native (`.codex/`, `.agents/`) or Copilot-native (`.github/`) equivalents are built now. Out of scope: cross-machine/cross-runner parallelism, and automatic epic decomposition (the manifest below is assumed to already exist for a given epic run).

## Behavior

### 1. Delegation authorization for nested orchestration

- New `.claude/agents/epic-orchestrator.md`, distinct from `.claude/agents/orchestrator.md`. `orchestrator.md` does not call itself; only `epic-orchestrator.md` is authorized to delegate `Agent(orchestrator)`.
- `.claude/settings.json` `permissions.allow` gains `"Agent(epic-orchestrator)"` (so the top-level `orchestrator` persona, which runs as the main session per `"agent": "orchestrator"`, can delegate to it) and `epic-orchestrator.md`'s own frontmatter `tools:` list carries `"Agent(orchestrator)"` and `"Agent(pr-author)"`.
- The top-level `orchestrator`'s Change Budget Routing section (`.claude/agents/orchestrator.md`, `.claude/skills/orchestrate/SKILL.md`) gains a third routing outcome: **Epic path** — the objective names or references an epic manifest (`docs/features/epics/<epic-slug>/epic-plan.md`) or explicitly requests multi-feature/epic orchestration. On this outcome the orchestrator delegates to `Agent(epic-orchestrator)` with the manifest path, instead of running change-budget/small/large routing itself.
- A new `.claude/skills/epic-orchestrate/SKILL.md` frames work for the `epic-orchestrator` persona, parallel to how `.claude/skills/orchestrate/SKILL.md` frames work for `orchestrator`. It documents the epic checkpoint handling, wave computation, integration-branch lifecycle, wave barrier, merge-conflict handling, worktree cleanup, and documentation-maintenance procedures defined in this spec, so the procedure is not re-derived ad hoc on each run.
- Nested single-feature runs are validated identically to top-level runs by adding a `SubagentStop` matcher block `"orchestrator"` in `.claude/settings.json` that runs the existing `.claude/hooks/validate-orchestrator-output.ps1` unmodified (default parameters). This closes a gap the research confirmed: `orchestrator` normally *is* the main session and never stops as a subagent, so no `SubagentStop` matcher exists for it today; in epic mode it runs nested (non-main-session) and must be validated the same way `pr-author` already is.
- The generic catch-all `SubagentStop` matcher (`.claude/settings.json:150`) gains `orchestrator` and `epic-orchestrator` appended to its `|`-delimited agent-name list, so both get the baseline completion-artifact-path check every other agent gets.

### 2. Epic dependency manifest

**Format decision: Markdown with YAML frontmatter**, at `docs/features/epics/<epic-slug>/epic-plan.md`. This is chosen over pure JSON because:
- Every other planning artifact in this repository (`issue.md`, `spec.md`, `plan.<ts>.md`) is Markdown with a light structured header, so the convention is consistent and the file remains readable/diffable by a human authoring the epic manifest by hand (decomposition is out of scope — a human or `prd-feature`-style process authors this file before the epic run starts).
- The frontmatter carries the only fields that must be parsed deterministically (`epic`, `integration_branch`, `features[]` with `depends_on[]`); the Markdown body below the frontmatter carries free-text epic narrative (goal, scope, non-goals) that is not machine-parsed, avoiding the need to invent a JSON schema for prose content.

Frontmatter schema (YAML):

```yaml
---
epic: epic-orchestrate-275
integration_branch: epic/epic-orchestrate-275-integration
created_at: 2026-07-02T19-13
features:
  - feature_folder: 2026-07-02-child-a-300
    issue_num: 300
    depends_on: []
  - feature_folder: 2026-07-02-child-b-301
    issue_num: 301
    depends_on: [2026-07-02-child-a-300]
  - feature_folder: 2026-07-02-child-c-302
    issue_num: 302
    depends_on: [2026-07-02-child-a-300]
  - feature_folder: 2026-07-02-child-d-303
    issue_num: 303
    depends_on: [2026-07-02-child-b-301, 2026-07-02-child-c-302]
---
```

- `feature_folder` is the canonical identifier: the exact active-feature-folder basename (matching the vocabulary already used by the per-feature checkpoint's `feature-folder` field), not a separately invented slug.
- `depends_on` is an array of `feature_folder` values that must each already exist as another entry in `features[]`. A `depends_on` entry that does not resolve to a defined `feature_folder`, or a duplicate `feature_folder` value, is a malformed manifest and is rejected before epic kickoff (synthetic Blocking finding; the epic-orchestrator does not guess).

**Wave assignment is computed deterministically by longest-path layering over the dependency DAG**, not by an arbitrary valid topological order (a plain topological sort admits multiple valid orderings; longest-path layering is the one deterministic function of the manifest alone):

```
wave(f) = 0                                   if depends_on(f) is empty
wave(f) = 1 + max(wave(d) for d in depends_on(f))   otherwise
```

Computed via memoized recursion with cycle detection: a `feature_folder` encountered while still being resolved (i.e., appears in its own dependency chain) indicates a cycle in the manifest, which is rejected as a malformed manifest before kickoff. For the example above: wave 0 = `{child-a}`, wave 1 = `{child-b, child-c}`, wave 2 = `{child-d}`. Within a wave, feature ordering for emission into checkpoint arrays is lexicographic by `feature_folder`, purely for deterministic serialization — wave *membership* itself has no ties to break since it is a pure function of the DAG.

### 3. Epic integration branch lifecycle

1. Before wave 1, `epic-orchestrator` creates the integration branch off the tip of `main`: `git fetch origin main`, `git checkout -b epic/<epic-slug>-integration origin/main`, `git push -u origin epic/<epic-slug>-integration`.
2. Before starting each wave, `epic-orchestrator` runs `git fetch origin epic/<epic-slug>-integration` so the wave's child worktrees branch off the current remote tip, not a stale local ref.
3. Each child feature's worktree/branch (created via `Agent(orchestrator, isolation: "worktree", run_in_background: true)`) is branched from `origin/<integration_branch>`, not `origin/main`. This requires the per-feature orchestration's branch-setup step to honor an epic-mode override: when the delegation prompt carries the epic-mode kickoff parameter (below), the child's own `orchestrator` instance branches from `origin/<integration_branch>` instead of `origin/main`.
4. Each child feature's PR base branch is the integration branch, not `main`. This is an **explicit epic-mode override**, not a reliance on `pr-base-branch-merge-base`'s ancestry heuristic. Research confirmed that skill's merge-base algorithm would likely resolve the integration branch correctly by ancestry once the branch is created per step 3, but the epic-mode override is committed instead because (a) it gives the base-branch-verification hook (§ Hooks, item c) a fixed, checkpoint-recorded expected value to check against rather than requiring the hook to reimplement merge-base ancestry resolution in PowerShell, and (b) it removes any ambiguity if the integration branch and `main` later share history in ways that complicate ancestor selection. Non-epic (standalone) orchestration is unchanged and continues to resolve its PR base branch via `pr-base-branch-merge-base` exactly as today.
5. At epic completion (every feature in the final wave has `merge_status: "merged"`), `epic-orchestrator` drives a final PR merging `epic/<epic-slug>-integration` into `main`. This final PR is driven directly by `epic-orchestrator` itself (it delegates PR authoring to `Agent(pr-author)` and refreshes context via `mcp__drm-copilot__collect_pr_context`, exactly as `orchestrator` does) rather than via a nested nested `Agent(orchestrator)` call, because there is no code-change/atomic-plan content for this PR — it is a pure integration merge. `epic-orchestrator` runs the same S9 CI-green procedure (`scripts/orchestration/Invoke-CiGateParser.ps1`) directly against this PR and records the result under the epic checkpoint's `epic_merge_pr` object (schema below), then executes `gh pr merge --merge` once green, gated by the same merge-gate hook used for child features (§ Hooks, item b).

### 4. Merge-on-green extension to per-feature orchestration

- **Kickoff parameter:** when `epic-orchestrator` delegates a child feature to `Agent(orchestrator)`, the prompt includes a literal line (parallel in form to the existing "Canonical issue number..." convention):

  > `Epic mode: true. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json. PR base branch MUST be <integration_branch>, not main; pass --base <integration_branch> to gh pr create.`

- **Checkpoint field names (per-feature `artifacts/orchestration/orchestrator-state.json`):** on reading this line, the child's own `orchestrator` records, at its first checkpoint write:
  - top-level `epic_mode: true` (boolean; absent/`false` for standalone orchestration — unchanged behavior),
  - top-level `epic_context: { epic_feature_folder, integration_branch, epic_checkpoint_path }`.
- **S9 change:** `.claude/skills/orchestrate/SKILL.md` `## Step S9 — CI Green Gate` gains a new step 6, inserted after the existing step 5 (which sets `step9_status: "passed"`) and before the standalone "DONE is not written..." sentence:

  > 6. If the checkpoint's `epic_mode` is `true`, execute `gh pr merge --merge <PR>` merging the feature branch into `epic_context.integration_branch` (already the PR's base branch per the epic-mode `--base` override applied at S8). On success, record `epic_merge: { merge_commit_sha, target_branch, merged_at }` in the checkpoint. On failure due to merge conflict (non-mergeable PR), do not retry blindly: convert the conflict into a synthetic Blocking finding per "Merge-Conflict Remediation" below and re-enter the standard R1–R5 remediation loop; do not proceed to DONE.

- **Checkpoint Schema — CI Gate Fields change:** a new bullet is added after the existing `step9_status` bullet, documenting the `epic_merge` object (`merge_commit_sha`, `target_branch`, `merged_at`), following the existing "top-level object with named sub-fields" pattern used for `ci_gate`.
- **PR Creation Gate change:** a new condition 7 is added after the existing six, following the existing "additive condition" annotation convention:

  > 7. `epic_mode` is `false`, OR (`epic_mode` is `true` AND the integration-branch merge (`gh pr merge --merge`) has completed and `epic_merge.merge_commit_sha` is recorded in the checkpoint).

  This condition gates only the "report work complete" point of the gate (mirroring condition 6's own dependency on S9 output); it does not gate PR creation itself, which still happens before CI is observed, per the existing S8→S9 ordering.
- Standalone (non-epic) orchestration is unchanged: `epic_mode` is absent or `false`, S9 step 6 is a no-op, and condition 7 is trivially satisfied.

### 5. Merge-conflict handling (fan-in)

**Design decision: the merge-conflict remediation loop runs inside the child feature's own orchestrator instance (the same one that executes S9 step 6), reusing the existing R1–R5 loop unmodified**, not a new loop owned by `epic-orchestrator`. This directly satisfies the requirement that the loop be reused unmodified and keeps the merge-conflict-resolution work (which needs `Bash(git *)`, `Edit`, `Write` inside the conflicted worktree) scoped to the agent that already has unrestricted tool access there (`atomic-executor`, confirmed by research to already carry an unscoped `"Bash(git *)"` wildcard and unscoped `Edit`/`Write`).

Procedure, triggered by S9 step 6's merge failure:

1. **Synthetic-finding source:** the child's `atomic-executor` (delegated by the child's own `orchestrator`) runs `git fetch origin <integration_branch>`, `git merge --no-commit origin/<integration_branch>`, and on non-zero exit captures `git diff --name-only --diff-filter=U` (the conflicted file list) plus the raw conflict-marker (`<<<<<<<`/`=======`/`>>>>>>>`) content of each conflicted file.
2. This is written as `remediation-inputs.<timestamp>.md` in the **child feature's own active folder** (not the epic folder), with severity `Blocking`, a title naming the conflicting branches, and the conflicted-file list plus marker excerpts — the same shape the existing "Remediation Loop — CI-Failure Handling" section already uses for a CI-check failure, substituting the conflict-detection output for `gh run view --log-failed`.
3. The existing R1–R5 remediation loop (`.claude/skills/orchestrate/SKILL.md` "Remediation Loop (R1–R5)") processes this finding exactly as it processes a local blocking finding: `atomic-planner` (R1) plans the resolution, `atomic-executor` performs preflight (R2) and then resolves the conflict markers, stages, and commits (R3), and `feature-review` re-audits (R4). No new loop is introduced.
4. The child's own `remediation_pass` counter is shared with local-finding and CI-failure passes (cap 3), unmodified.
5. On the third conflict pass without resolution, the child's `orchestrator` records **a new checkpoint status field**, `step9_status: "blocked_conflict_loop_limit"` (parallel to the existing `blocked_ci_loop_limit`), does not write DONE, and halts. It reports this status to `epic-orchestrator` (via its final subagent output message), which mirrors it into the epic checkpoint's per-feature `merge_status: "blocked_conflict_loop_limit"` field (§ Epic-Level Checkpoint Schema).

Feasibility of this design was confirmed in `research/concurrency-and-hardening.research.md` §6: no new tool grant is required, and the CI-failure-to-synthetic-finding pattern is already productionized. No `scope_change`/`exception`/`halt` fallback under the Autonomous-Execution Mandate is required for this mechanism.

### 6. Epic-level checkpoint

New artifact `artifacts/orchestration/epic-orchestrator-state.json`, distinct from the per-feature checkpoint. Full schema:

```jsonc
{
  "objective": "<epic objective text>",
  "route_id": "epic",
  "epic_feature_folder": "<epic-slug>",
  "epic_manifest_path": "docs/features/epics/<epic-slug>/epic-plan.md",
  "epic_status_doc_path": "docs/features/epics/<epic-slug>/epic-status.md",
  "integration_branch": "epic/<epic-slug>-integration",
  "completed_steps": ["epic_manifest_parsed", "integration_branch_created", "wave_0_launched", "..."],
  "next_step": "wave_1_launch",
  "last_updated": "<iso8601>",
  "current_wave": 1,
  "waves": [
    { "wave_number": 0, "feature_folders": ["2026-07-02-child-a-300"] },
    { "wave_number": 1, "feature_folders": ["2026-07-02-child-b-301", "2026-07-02-child-c-302"] },
    { "wave_number": 2, "feature_folders": ["2026-07-02-child-d-303"] }
  ],
  "features": [
    {
      "feature_folder": "2026-07-02-child-a-300",
      "issue_num": 300,
      "depends_on": [],
      "wave_number": 0,
      "worktree_path": "<abs-or-repo-relative-path>",
      "branch_name": "feature/2026-07-02-child-a-300",
      "pr_number": 401,
      "pr_url": "https://github.com/drmoisan/drm-copilot/pull/401",
      "merge_status": "merged",
      "merge_commit_sha": "<sha>",
      "conflict_remediation_pass": 0,
      "worktree_created_at": "<iso8601>",
      "pr_opened_at": "<iso8601>",
      "ci_green_at": "<iso8601>",
      "merge_confirmed_at": "<iso8601>",
      "worktree_removed_at": "<iso8601>"
    }
  ],
  "epic_merge_pr": {
    "pr_number": 410,
    "pr_url": "https://github.com/drmoisan/drm-copilot/pull/410",
    "ci_gate": { "head_sha": "<sha>", "pr_pipeline_run_id": "<id>", "pr_pipeline_run_url": "<url>", "conclusion": "success", "verified_at": "<iso8601>" },
    "merge_commit_sha": "<sha>",
    "merged_at": "<iso8601>"
  },
  "delegation_receipts": [{ "agent_name": "orchestrator" }, { "agent_name": "pr-author" }],
  "skill_receipts": [{ "skill": "epic-orchestrate", "required": true, "evidence": "read:.claude/skills/epic-orchestrate/SKILL.md" }],
  "mcp_call_receipts": [{ "tool": "validate_orchestration_artifacts", "ok": true, "evidence": "epic-orchestrator-state validator exit 0" }],
  "human_interaction": { "requirements": [] }
}
```

`merge_status` enum: `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merge_conflict`, `blocked_conflict_loop_limit`, `merged`, `worktree_removed`.

The top-level `objective`, `completed_steps`, `next_step`, and `last_updated` fields are carried deliberately so the existing structural checks in `.claude/hooks/validate-orchestrator-output.ps1` (which require exactly these four fields, per research) apply unmodified when that hook is reused for the `epic-orchestrator` `SubagentStop` matcher (§ Hooks, item a).

Every field needed to re-derive state durably on resume (`worktree_path`, `branch_name`, `pr_number`, `merge_status`) is re-derivable from `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid` — the checkpoint is a cache of that durable state, not the source of truth, consistent with the requirement that resume not depend on in-memory completion notifications.

**Registration with the validation surface** (mechanics confirmed in `research/orchestration-mechanics.research.md` §2):
1. Add `"epic-orchestrator-state"` to the `enum` array in `extensions/drm-copilot/src/mcp-tool-definitions.ts:388-394` (and update the tool `description` at line 381 and the `require_complete` description at line 405 to mention it).
2. Add a dispatch branch for `"epic-orchestrator-state"` in `scripts/dev_tools/validate_orchestration_artifacts.py` (`_validate_from_args`, alongside the existing `if args.artifact_type == "orchestrator-state"` branch) and in the TS port `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` (`validateArtifact`'s `switch`). Both changes are required because the live MCP tool is served by the TS port, while the Python CLI remains the direct/test entrypoint.
3. The actual validator logic lives in a **new sibling Python module**, `scripts/dev_tools/validate_epic_orchestrator_state.py`, exposing `validate_epic_orchestrator_state_text(text, *, require_complete=False)`, following the existing sibling-module convention (`validate_orchestrator_state.py`, `validate_policy_audit_artifact.py`, `validate_orchestration_review_artifacts.py`) rather than folding epic-checkpoint logic into `validate_orchestrator_state_text`, because the required-key/status shape is structurally different from the per-feature `REQUIRED_STATE_KEYS`.

This module validates:
- Presence of the four baseline fields plus `route_id == "epic"`, `epic_feature_folder`, `integration_branch`, `waves[]`, `features[]`.
- `features[].feature_folder` uniqueness; every `depends_on` entry resolves to another `features[].feature_folder`.
- `merge_status` enum membership.
- **Wave-barrier ordering invariant** (the retrospective backstop, § Hooks item e): for every feature `f` with non-empty `depends_on`, each dependency `d` must appear in `features[]` with `merge_status` in `{merged, worktree_removed}` and a non-null `merge_confirmed_at` timestamp that is chronologically `<=` `f.worktree_created_at` (when both are non-null). A violation appends the error string `EPIC_WAVE_BARRIER_VIOLATION: <f> started before dependency <d> merged`, following the existing validator convention of returning error-string lists rather than raising or exiting.
- Consistency between `waves[].feature_folders` and each feature's own `wave_number`.
- Under `require_complete=True`: every feature's `merge_status` is `merged` or `worktree_removed`, and `epic_merge_pr.merge_commit_sha` is non-empty.

### 7. Wave barrier

Wave-barrier enforcement is a **two-layer design** (research confirmed no single hook mechanism can validate a whole batch of concurrent `Agent` calls, since `PreToolUse` hooks fire per call with no cross-call/conversation-state visibility):

- **Layer 1 — per-call deterrent**, a new `PreToolUse` hook on the existing `Agent` matcher (§ Hooks, item added beyond the five named in the objective, justified below).
- **Layer 2 — retrospective backstop**, the wave-barrier ordering invariant inside `validate_epic_orchestrator_state_text`, enforced at `epic-orchestrator` `SubagentStop` time (§ Hooks, item e).

Both are required; neither alone closes the gap. The per-call hook is a strong deterrent against the common failure mode (launching wave N+1 while wave N has not actually merged); the retrospective validator is the structural backstop that blocks the `epic-orchestrator` run from completing if checkpoint timestamps ever show a wave started before its dependencies were durably confirmed merged, regardless of what the per-call hook did or didn't catch in a given batch.

### 8. Routing and receipts

New `epic` route in `config/orchestration-routing.json` (and its byte-identical mirror `extensions/drm-copilot/resources/config/orchestration-routing.json`), following the identical object shape already used by `small`/`large`/`remediation`:

```json
"epic": {
  "description": "Epic path for scheduling a dependency graph of child features across parallel worktrees with fan-in via a shared integration branch.",
  "requires_pr_gate": true,
  "required_agents": ["orchestrator", "pr-author"],
  "required_skills": [
    "epic-orchestrate",
    "orchestrate",
    "feature-promotion-lifecycle",
    "atomic-plan-contract",
    "acceptance-criteria-tracking",
    "evidence-and-timestamp-conventions",
    "pr-context-artifacts",
    "pr-base-branch-merge-base"
  ],
  "required_mcp_tools": ["collect_pr_context", "validate_orchestration_artifacts"]
}
```

`required_agents` lists only the agents `epic-orchestrator` itself directly delegates to (`orchestrator`, repeated per child feature, and `pr-author` for the final integration-to-`main` PR) — the deeper delegation chain inside each nested `orchestrator` run (`atomic-planner`, `atomic-executor`, `feature-review`) is validated under that child's own per-feature checkpoint and its own `small`/`large` route contract, not under the epic route. `requires_pr_gate: true` is set because the epic route drives at least one PR (the final integration PR) through the PR Creation Gate. `MANDATORY_ROUTE_PHASES` is left without an `"epic"` entry (research confirmed a route absent from that map imposes no mandatory-phase requirement by default), matching the current behavior for `large` and `remediation`.

The three receipt arrays (`delegation_receipts[]`, `skill_receipts[]`, `mcp_call_receipts[]`) documented in `.claude/skills/orchestrate/SKILL.md` "Routing-Contract Receipt Emission" are already generic across routes (confirmed by research); `epic-orchestrator` populates them with the exact shapes shown in the § 6 schema example, with no route-specific receipt-shape change required.

### 9. Worktree cleanup

After a child feature's `epic_merge.merge_commit_sha` is recorded (S9 step 6 succeeds) and `epic-orchestrator` mirrors that into its own checkpoint's `merge_status: "merged"` and `merge_confirmed_at`, `epic-orchestrator` (running from the main repository checkout, not any child worktree) issues `git worktree remove <worktree_path>`, gated by the new `enforce-epic-worktree-removal-gate.ps1` hook (§ Hooks, item d). On success it sets `merge_status: "worktree_removed"` and `worktree_removed_at`.

### 10. Context handoff to dependent features

When `epic-orchestrator` kicks off a feature that has a non-empty `depends_on`, the delegation prompt to `Agent(orchestrator)` includes one literal citation line per dependency, appended after the epic-mode kickoff line from § 4:

> `Upstream context for <feature_folder>: depends on <dep_feature_folder> (spec: docs/features/active/<dep_feature_folder>/spec.md — or docs/features/completed/<dep_feature_folder>/spec.md if already promoted to completed; plan: docs/features/active/<dep_feature_folder>/plan.<ts>.md; merged as PR #<dep_pr_number>, commit <dep_merge_commit_sha>, into <integration_branch>).`

`epic-orchestrator` resolves the concrete `<dep_...>` values from its own checkpoint's `features[]` records for each dependency before emitting the line, so the dependent feature's own `orchestrator`/`atomic-planner` is told exactly which upstream artifacts are relevant rather than being expected to rediscover prior design decisions from the diff alone.

## Hooks and Validators

Five hooks named in the objective, plus one additional per-call deterrent hook justified in § 7. All new/extended hooks follow the uniform contract confirmed by research: `PreToolUse` hooks read `$env:CLAUDE_TOOL_INPUT`, `SubagentStop` hooks read `$env:CLAUDE_HOOK_INPUT`; both emit `hookSpecificOutput.{hookEventName, permissionDecision, permissionDecisionReason}` and fail closed on unreadable/ambiguous state (deny, not allow).

**(a) `SubagentStop` matcher `"epic-orchestrator"` reusing `.claude/hooks/validate-orchestrator-output.ps1`.**
The existing script's top-level `param()` block is extended with two optional parameters, `-CheckpointPath` (default unchanged: `artifacts/orchestration/orchestrator-state.json`) and `-ArtifactType` (default unchanged: `orchestrator-state`), threaded into `Invoke-RoutingContractValidation`'s default `$Invoker`, which currently hardcodes the literal `orchestrator-state` in its `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete` call; this becomes `... $ArtifactType $Path --require-complete`. Two `.claude/settings.json` `SubagentStop` blocks are added:
- matcher `"orchestrator"` → `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1` (defaults; validates the per-feature checkpoint for nested runs, § 1).
- matcher `"epic-orchestrator"` → `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state` (validates the epic checkpoint, including the wave-barrier retrospective check inside `validate_epic_orchestrator_state_text`, § 6).

This is genuine reuse of one script file with a parameterized seam, not a fork.

**(b) New `.claude/hooks/enforce-epic-merge-gate.ps1`.**
Registered as an additional entry in the existing `"Bash"` `PreToolUse` matcher block. Regex-matches `gh pr merge` (with a `--merge` flag, mirroring `enforce-pr-author-skill.ps1`'s command-text-matching pattern) against `CLAUDE_TOOL_INPUT.command`. Decision logic, checkpoint-only (no live `gh` shell-out — see design-decision note below):
1. Read `artifacts/orchestration/orchestrator-state.json` (relative to the Bash call's working directory, which is the child feature's worktree in the child-merge case). If it exists, `epic_mode == true`, and `step9_status == "passed"` → allow.
2. Else read `artifacts/orchestration/epic-orchestrator-state.json` (the final-PR case, run from the main checkout). If it exists and `epic_merge_pr.ci_gate.conclusion == "success"` and the command's PR argument (or the current branch's PR) matches `epic_merge_pr.pr_number` → allow.
3. Otherwise deny with reason `EPIC_MERGE_GATE_BLOCKED`.
A missing or unreadable checkpoint denies (fails closed), per the uniform hook contract. **Design decision:** the gate trusts the on-disk checkpoint rather than shelling out live to `gh pr view` for a real-time head-SHA check. This accepts the same non-adversarial, policy-level-not-cryptographic posture the repository already accepts for `enforce-pr-author-skill.ps1`'s own receipt mechanism, and matches the precedent that no existing hook in this repository shells out to `gh` directly. This also means: standalone (non-epic) orchestration, which never sets `epic_mode: true` and never populates `epic_merge_pr`, is structurally prevented from invoking `gh pr merge --merge` at all — consistent with "standalone orchestration is unchanged" (it stops at "PR opened, CI green").

**(c) Extension of `.claude/hooks/enforce-pr-author-skill.ps1`** (not a new file — the objective permits either; this repository's existing five-ordered-check structure for `gh pr create`/`gh pr edit` is the natural home for a sixth check, since the base-branch requirement is, per research, "structurally identical" to the existing `--body-file` receipt check).
A new sixth ordered check, `Test-EpicBaseBranchOverride`: when the resolved checkpoint (`artifacts/orchestration/orchestrator-state.json`, read via the existing `Get-CheckpointFileContent`-style seam) has `epic_mode == true`, the command text for `gh pr create` MUST contain `--base <epic_context.integration_branch>` with the exact branch value recorded in the checkpoint. A missing `--base`, or a `--base` value that does not match `epic_context.integration_branch`, is denied with reason `EPIC_BASE_BRANCH_MISMATCH`. When `epic_mode` is absent or `false`, this check is a no-op (existing standalone behavior is unchanged).

**(d) New `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`.**
Registered as an additional entry in the existing `"Bash"` matcher block. Regex-matches `git worktree remove` against `CLAUDE_TOOL_INPUT.command`, extracts the target worktree path argument, reads `artifacts/orchestration/epic-orchestrator-state.json`, and finds the `features[]` record whose `worktree_path` matches. Allows only when that record's `merge_status` is `merged` or `worktree_removed`. Denies with reason `EPIC_WORKTREE_REMOVAL_BLOCKED` when the checkpoint is unreadable, no matching record exists, or `merge_status` is anything else — fail-closed, following the `enforce-orchestration-preimplementation-gate.ps1` precedent of treating an unreadable/no-match checkpoint as deny.

**(e) New retrospective wave-barrier validator, inside `scripts/dev_tools/validate_epic_orchestrator_state.py`** (not a separate script — it is the `require_complete`-independent ordering check described in § 6, invoked at `epic-orchestrator` `SubagentStop` time via hook (a)'s parameterized `Invoke-RoutingContractValidation` call). This generalizes `enforce-checkpoint-monotonic.ps1`'s `Get-OutOfOrderPair` ordering-check logic from the single-feature `completed_steps` array to per-dependency-edge wave-event ordering, as confirmed feasible by research.

**Additional hook beyond the five named in the objective — new `.claude/hooks/enforce-epic-wave-barrier.ps1` (Layer 1 deterrent, § 7).**
Registered as an additional entry in the existing `"Agent"` `PreToolUse` matcher block (which already fires on every `Agent` tool call and already supports whole-payload JSON matching, per `enforce-orchestration-preimplementation-gate.ps1`'s precedent). Fires when `CLAUDE_TOOL_INPUT.subagent_type == "orchestrator"` and the serialized prompt contains the epic-mode kickoff marker (`Epic mode: true`). Resolves the target `feature_folder` from the prompt text (same regex-scan technique `enforce-prd-feature-before-planner.ps1` already uses to resolve a feature folder from `.prompt`), reads `artifacts/orchestration/epic-orchestrator-state.json`, looks up that feature's `depends_on`, and denies with reason `EPIC_WAVE_BARRIER_BLOCKED` unless every dependency's `merge_status` is `merged` or `worktree_removed`. This hook is named explicitly here because it is required to make § 7's two-layer design concrete and hook-enforced, per the hardening requirement that critical invariants must not be prose-only.

## Merge-Conflict-as-Remediation-Finding — Summary

Restated for traceability against the objective's exact wording:
- **Synthetic-finding format:** `remediation-inputs.<timestamp>.md` in the child feature's active folder, severity `Blocking`, naming the conflicting branches and carrying the conflicted-file list (`git diff --name-only --diff-filter=U`) and conflict-marker excerpts, in place of a CI-failure log.
- **New checkpoint status field:** per-feature (child) `step9_status: "blocked_conflict_loop_limit"`, mirrored into the epic checkpoint's `features[].merge_status: "blocked_conflict_loop_limit"`.
- **R1–R5 loop reuse:** confirmed unmodified — same delegation sequence, same `remediation_pass` counter and cap of 3, same exit-gate semantics. No new loop, no new tool grant.

## Documentation Maintenance

**Decision: `epic-plan.md` (the manifest) and `epic-status.md` (a separate, epic-orchestrator-maintained status document) are kept distinct.** `epic-plan.md`'s frontmatter is treated as the human-authored, largely static input (feature list, `depends_on` edges) — automatic epic decomposition is explicitly out of scope, so this file is not repeatedly rewritten by the orchestrator. `epic-orchestrator` instead maintains `docs/features/epics/<epic-slug>/epic-status.md`, updated at each of the following boundaries (not only at final completion):
- Epic kickoff — initial status table seeded from the manifest (one row per feature: wave, status `not_started`).
- Each time a feature's `merge_status` changes (`worktree_created`, `pr_open`, `ci_green`, `merge_conflict`, `merged`, `worktree_removed`) — the corresponding row is updated in place.
- Each wave transition (`current_wave` increments).
- Final integration PR opened, green, and merged.

Each row records: `feature_folder`, `issue_num`, `wave_number`, `merge_status`, PR link (`pr_url`), `merge_commit_sha`, and the four lifecycle timestamps from the epic checkpoint. `epic-status.md` is a human-readable projection of the epic checkpoint's `features[]` array; the checkpoint JSON remains the durable, machine-authoritative source, and `epic-status.md` is regenerated from it, not hand-edited.

## Bundled Mirror Parity

Research corrected the scope of this requirement beyond the issue draft's framing: the dynamic byte-for-byte parity test (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts`) enumerates **the entire `.claude/` tree** via `rglob("*")` (excluding only `.claude/settings.local.json` and `.claude/agent-memory/**`), not only `.claude/agents/**` and `.claude/skills/**`. Every new or modified file below therefore requires a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/.claude/...` at the same relative path, verified via `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`:

- `.claude/agents/epic-orchestrator.md` (new)
- `.claude/skills/epic-orchestrate/SKILL.md` (new)
- `.claude/skills/orchestrate/SKILL.md` (modified: S9 step 6, checkpoint-schema bullet, PR Creation Gate condition 7)
- `.claude/agents/orchestrator.md` (modified: epic-mode routing outcome)
- `.claude/hooks/validate-orchestrator-output.ps1` (modified: `-CheckpointPath`/`-ArtifactType` params)
- `.claude/hooks/enforce-pr-author-skill.ps1` (modified: `Test-EpicBaseBranchOverride`)
- `.claude/hooks/enforce-epic-merge-gate.ps1` (new)
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (new)
- `.claude/hooks/enforce-epic-wave-barrier.ps1` (new)
- `.claude/settings.json` (modified: hook wiring, `Agent(epic-orchestrator)` permission)

`packages/mcp-server/resources/claude-customizations/` is gitignored and has no automated test (confirmed by research: `packages/mcp-server/.gitignore:3` ignores `resources/`; it is populated only by `packages/mcp-server/prepack.cjs`'s `cpSync` at pack time). This mirror is verified per file with `cmp` as a manual pre-publish step for every file in the list above, and is not part of this feature's per-commit toolchain loop — it is a release-time verification, performed before any npm publish that includes this change.

## Inputs / Outputs

- **Inputs:** `docs/features/epics/<epic-slug>/epic-plan.md` (manifest, human-authored); the epic-mode kickoff line and upstream-context citation lines threaded into `Agent(orchestrator)` delegation prompts; `CLAUDE_TOOL_INPUT`/`CLAUDE_HOOK_INPUT` payloads consumed by the new/extended hooks.
- **Outputs:** `artifacts/orchestration/epic-orchestrator-state.json` (epic checkpoint); `docs/features/epics/<epic-slug>/epic-status.md` (human-readable status projection); per-child-feature `artifacts/orchestration/orchestrator-state.json` checkpoints carrying `epic_mode`/`epic_context`/`epic_merge`; hook allow/deny decisions with named reason codes (`EPIC_MERGE_GATE_BLOCKED`, `EPIC_BASE_BRANCH_MISMATCH`, `EPIC_WORKTREE_REMOVAL_BLOCKED`, `EPIC_WAVE_BARRIER_BLOCKED`, `EPIC_WAVE_BARRIER_VIOLATION`).
- **Config keys and defaults:** `config/orchestration-routing.json`'s new `"epic"` route (default absent for all other routes, unchanged). `epic_mode` defaults to absent/`false` on the per-feature checkpoint (standalone behavior unchanged).
- **Versioning / backward-compatibility constraints:** existing per-feature checkpoints without `epic_mode`/`epic_context`/`epic_merge` continue to validate exactly as before (all new fields are additive and keyed-presence-gated, following the pattern already established for `remediation_loop` and `human_interaction` in `.claude/rules/orchestrator-state.md`). `validate-orchestrator-output.ps1`'s new parameters default to the existing per-feature path/artifact-type, so every existing caller of that hook is unaffected.

## API / CLI Surface

- `gh pr create --base <integration_branch> --body-file artifacts/pr_body_<N>.md` — epic-mode PR creation (verified by hook item c).
- `gh pr merge --merge <PR>` — epic-mode merge-on-green (verified by hook item b).
- `git worktree remove <worktree_path>` — post-merge cleanup (verified by hook item d).
- `git worktree list --porcelain`, `git branch`, `gh pr view --json state,mergedAt,headRefOid` — durable-state re-derivation calls used by resume logic and by the validators' fail-closed checks.
- `python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state <path> --require-complete` — new CLI invocation form, parallel to the existing `orchestrator-state` form.
- `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: "epic-orchestrator-state"` — new MCP-level invocation.

## Data & State

- **Data flow:** `epic-orchestrator` parses `epic-plan.md`, computes waves, creates the integration branch, and for each wave launches concurrent `Agent(orchestrator, isolation: "worktree", run_in_background: true)` calls carrying the epic-mode kickoff line and upstream-context citations. Each child `orchestrator` runs its full small/large route, then (in epic mode) merges on green and reports back. `epic-orchestrator` durably records progress in `epic-orchestrator-state.json` and reflects it in `epic-status.md`, then advances to the next wave only once the wave-barrier invariant holds.
- **Data transformations and invariants:** wave assignment is a pure function of the manifest's `depends_on` edges (§ 2). The wave-barrier ordering invariant (§ 6) is checked both preventively (hook item added beyond the five) and retrospectively (hook item e). Checkpoint-integrity is policy-level, not cryptographic (documented explicitly, not silently assumed).
- **Caching or persistence details:** `epic-orchestrator-state.json` and per-feature checkpoints are the only new persistent state; both are fully re-derivable from `git`/`gh` on resume, per the durable-state requirement.
- **Migration or backfill requirements:** none. This is new state; no existing checkpoint needs migration.

## Constraints & Risks

- This repository is merge-commit-only (squash/rebase disabled repo-wide); every merge in this design uses `gh pr merge --merge`.
- The `Agent` tool's `isolation: "worktree"` and `run_in_background` are the only sanctioned concurrency primitives; no new worktree/background mechanism is introduced.
- The merge-gate and worktree-removal-gate hooks are policy-level checks that trust the on-disk checkpoint (§ Hooks item b design-decision note); this is an accepted, explicitly documented risk consistent with the same posture already accepted for `enforce-pr-author-skill.ps1`.
- Per-call wave-barrier deterrence cannot, by construction, validate an entire batch of concurrent `Agent` calls as a whole; the retrospective validator is the structural backstop that closes this gap (§ 7).
- Bundle-mirror parity for `extensions/drm-copilot/resources/claude-customizations/` is test-enforced and covers the entire `.claude/` tree, not only `.claude/agents/**`/`.claude/skills/**` (§ Bundled Mirror Parity). `packages/mcp-server/resources/claude-customizations/` has no automated gate and must be manually verified with `cmp` before any npm publish including this change.
- `scripts/dev_tools/validate_orchestrator_state.py` (approx. 471 lines per research) and `validate_epic_orchestrator_state.py` (new) must each stay under the repository's 500-line file-size limit; the epic validator is a new sibling module specifically to avoid growing the existing file past that limit.

## Implementation Strategy

- **Markdown / config (no dedicated toolchain beyond repo-wide review):**
  - `.claude/agents/epic-orchestrator.md` (new) — frontmatter tools: `Agent(orchestrator)`, `Agent(pr-author)`, `Read`, `Grep`, `Glob`, `Write(docs/features/epics/**)`, `Edit(docs/features/epics/**)`, `Write(artifacts/orchestration/**)`, `Edit(artifacts/orchestration/**)`, `Bash(git *)`, `Bash(gh *)`, `mcp__drm-copilot__collect_pr_context`, `mcp__drm-copilot__validate_orchestration_artifacts`; skills: `policy-compliance-order`, `epic-orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `evidence-and-timestamp-conventions`; `memory: project`; `hooks.SubagentStop` matcher `"epic-orchestrator"`.
  - `.claude/skills/epic-orchestrate/SKILL.md` (new) — epic procedure (manifest parsing, wave computation, integration-branch lifecycle, wave barrier, merge-conflict handling, cleanup, documentation maintenance).
  - `.claude/skills/orchestrate/SKILL.md` (edit) — S9 step 6, `ci_gate`-adjacent `epic_merge` bullet, PR Creation Gate condition 7.
  - `.claude/agents/orchestrator.md` (edit) — Change Budget Routing gains the epic-path outcome delegating to `Agent(epic-orchestrator)`.
  - `config/orchestration-routing.json` + byte-identical mirror `extensions/drm-copilot/resources/config/orchestration-routing.json` — add the `epic` route.
  - `.claude/settings.json` + mirrored copy — new `SubagentStop` blocks (`orchestrator`, `epic-orchestrator`), catch-all matcher list update, new `Bash`-matcher hook entries (items b, c-extension, d), new `Agent`-matcher hook entry (deterrent), `Agent(epic-orchestrator)` permission.
- **PowerShell (PoshQC format / analyze / Pester):**
  - `.claude/hooks/validate-orchestrator-output.ps1` — add `-CheckpointPath`/`-ArtifactType` parameters.
  - `.claude/hooks/enforce-pr-author-skill.ps1` — add `Test-EpicBaseBranchOverride` as a sixth ordered check.
  - `.claude/hooks/enforce-epic-merge-gate.ps1` (new).
  - `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (new).
  - `.claude/hooks/enforce-epic-wave-barrier.ps1` (new).
- **Python (Black / Ruff / Pyright / Pytest):**
  - `scripts/dev_tools/validate_epic_orchestrator_state.py` (new) — `validate_epic_orchestrator_state_text(text, *, require_complete=False)`.
  - `scripts/dev_tools/validate_orchestration_artifacts.py` — add the `epic-orchestrator-state` dispatch branch and CLI subparser.
- **TypeScript (Prettier / ESLint / TSC / Vitest):**
  - `extensions/drm-copilot/src/mcp-tool-definitions.ts` — add `"epic-orchestrator-state"` to the `artifact_type` enum.
  - `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` — add the matching `switch` branch.
- **Dependency changes:** none. No new packages.
- **Logging/telemetry additions:** named hook reason codes only (listed in Inputs/Outputs); no new telemetry sinks.
- **Rollout plan:** no feature flags; `epic_mode` absence preserves today's standalone behavior exactly. Epic mode is opt-in per-run via the `epic-orchestrate` route selection at the top-level orchestrator.

## Definition of Done

- [x] AC1: `.claude/agents/epic-orchestrator.md` exists, is distinct from `.claude/agents/orchestrator.md`, and its `tools:` frontmatter includes `Agent(orchestrator)`; `orchestrator.md` does not delegate to itself.
- [ ] AC2: `docs/features/epics/<epic-slug>/epic-plan.md`'s YAML-frontmatter schema (`epic`, `integration_branch`, `features[].{feature_folder,issue_num,depends_on}`) is documented and a wave-computation implementation derives wave numbers via the longest-path-layering function in § 2, rejecting cycles and unresolved `depends_on` references before kickoff.
- [x] AC3: The integration-branch lifecycle in § 3 (create off `main`, per-wave fetch-before-branch, PR base override, final integration-to-`main` PR) is implemented and documented in `.claude/skills/epic-orchestrate/SKILL.md`.
- [x] AC4: `.claude/skills/orchestrate/SKILL.md` carries S9 step 6, the `epic_merge` checkpoint bullet, and PR Creation Gate condition 7 exactly as specified in § 4; standalone (`epic_mode` absent/`false`) behavior is unchanged.
- [x] AC5: A fan-in merge conflict is converted to a `remediation-inputs.<timestamp>.md` Blocking finding and processed by the unmodified R1–R5 loop (§ 5); the third unresolved pass records `step9_status: "blocked_conflict_loop_limit"` on the child checkpoint and `merge_status: "blocked_conflict_loop_limit"` on the epic checkpoint, and halts without writing DONE.
- [x] AC6: `artifacts/orchestration/epic-orchestrator-state.json`'s schema (§ 6) is defined; `scripts/dev_tools/validate_epic_orchestrator_state.py` implements shape and wave-barrier-ordering validation; `"epic-orchestrator-state"` is registered in `extensions/drm-copilot/src/mcp-tool-definitions.ts`'s enum and dispatched in both `validate_orchestration_artifacts.py` and its TS port.
- [x] AC7: The wave barrier is enforced by both the per-call `enforce-epic-wave-barrier.ps1` deterrent and the retrospective ordering check inside `validate_epic_orchestrator_state_text`, invoked at `epic-orchestrator` `SubagentStop` time via the parameterized `validate-orchestrator-output.ps1`.
- [x] AC8: `config/orchestration-routing.json` and its byte-identical mirror carry the `epic` route exactly as specified in § 8 (`required_agents: [orchestrator, pr-author]`, `requires_pr_gate: true`).
- [x] AC9: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` denies `git worktree remove` unless the epic checkpoint's matching `features[]` record has `merge_status` in `{merged, worktree_removed}`.
- [x] AC10: Dependent-feature kickoff prompts include the upstream-context citation line from § 10 for every non-empty `depends_on` entry.
- [x] AC11: `.claude/hooks/enforce-epic-merge-gate.ps1` denies any `gh pr merge --merge` unless the epic-mode/CI-green checkpoint conditions in § Hooks item b hold; `.claude/hooks/enforce-pr-author-skill.ps1`'s new `Test-EpicBaseBranchOverride` denies `gh pr create` under `epic_mode: true` unless `--base` matches `epic_context.integration_branch`.
- [x] AC12: `docs/features/epics/<epic-slug>/epic-status.md` is created at epic kickoff and updated at every wave boundary and merge-status transition, per § Documentation Maintenance.
- [x] AC13: Every file listed under § Bundled Mirror Parity has a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/`, verified by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; the `packages/mcp-server/resources/claude-customizations/` mirror is verified per file with `cmp` before any npm publish including this change.
- [ ] AC14: All four quality toolchains pass with no coverage regression (Python: Black/Ruff/Pyright/Pytest; PowerShell: PoshQC format/analyze/Pester; TypeScript: Prettier/ESLint/TSC/Vitest), and existing tests continue to pass.
- [x] Acceptance criteria documented and mapped to tests or demos
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [x] Edge cases and error handling covered by tests
- [x] Docs updated (README, docs/features/active/... links)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Affected Test Files

Python (Pytest):
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` (new) — shape validation, `depends_on` reference/cycle rejection, wave-barrier ordering pass/violation, `require_complete` gating.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` — add `epic-orchestrator-state` dispatch tests.

TypeScript (Vitest):
- `tests/lib/validate/orchestration-artifacts.test.ts` (or existing equivalent) — add `epic-orchestrator-state` enum/dispatch tests.
- `tests/mcp-tool-definitions.test.ts` (or existing equivalent) — enum membership test for the new artifact type.

PowerShell (Pester):
- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` — `-CheckpointPath`/`-ArtifactType` parameterization tests, default-preserves-existing-behavior test.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — `Test-EpicBaseBranchOverride` allow/deny matrix.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` (new).
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` (new).
- `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1` (new).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — no change needed; the dynamic parity test catches new/modified `.claude/**` files automatically once physically mirrored.

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: wave/topological-sort (longest-path-layering) computation including cycle rejection; epic checkpoint schema validation; merge-conflict-to-remediation-finding conversion; worktree-cleanup gating logic; wave-barrier per-call and retrospective checks.
- [ ] Integration scenarios: multi-wave epic with a diamond dependency chain (wave 0 → wave 1 fan-out → wave 2 fan-in); a fan-in merge conflict exercising the R1–R5 loop to both resolution and to `blocked_conflict_loop_limit`; a resumed `epic-orchestrator` run after a session restart (durable-state re-derivation from `git`/`gh`, not in-memory notifications).
- [ ] CLI/API examples: `gh pr merge --merge`, `git worktree remove`, `gh pr view --json state,mergedAt,headRefOid` re-derivation calls used by the wave barrier and checkpoint resume logic.
