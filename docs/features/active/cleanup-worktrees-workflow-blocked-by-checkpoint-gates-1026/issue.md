# cleanup-worktrees-workflow-blocked-by-checkpoint-gates (Issue #1026)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/ (Issue #1026)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1026
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1026
- Last Updated: 2026-10-30
- Work Mode: full-bug

## Summary

The `cleanup-merged-worktrees` workflow cannot run its own documented automation, because checkpoint-based gates treat every cleanup write as unauthorized feature implementation. A cleanup run is a sanctioned, non-feature workflow with its own integrity record (the manifest), but no gate recognizes it, so worktrees that hold uncommitted lessons are stranded.

## Environment

- OS/version: not recorded
- Python version: not applicable
- Command/flags used: the `cleanup-merged-worktrees` skill, `cleanup-worktrees.sh --preserve` and `--apply`, from a main session on `main`
- Data source or fixture: a main session whose checkout has no `artifacts/orchestration/orchestrator-state.json`, after a feature or parallel run closed and its checkpoint was archived

## Steps to Reproduce

The documented workflow has four steps:

1. Write a manifest, `artifacts/orchestration/cleanup-worktrees-manifest.json` (`tool: cleanup-merged-worktrees`, `schema_version: 1`), with `preserved_files[]` and `removals[]` records.
2. Run `cleanup-worktrees.sh --preserve`, which stages the `preserved_files[]` findings onto a `documentationandmemories` consolidation branch in its own worktree.
3. Commit, push, and delegate PR creation to `Agent(pr-author)`. The operator merges.
4. Run `--apply`, and use manifest-authorized `git worktree remove <path>` for each `SAFE_TO_DELETE` worktree.

The skill states that a cleanup run "is neither a per-feature orchestration, nor an epic integration, nor a parallel run, so it writes none of the three checkpoints".

## Expected Behavior

All four steps run from the agent with no shell-escape steps, and a manifest-authorized `SAFE_TO_DELETE` removal is reachable end to end.

## Actual Behavior

From a main session with no `orchestrator-state.json`:

- Writing the manifest with Write is denied: `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.`
- Because no manifest can be written, `--preserve` has nothing to stage, and the worktree-removal gates (`enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`) can never authorize a `SAFE_TO_DELETE` removal.
- `git commit` and `git push` of the consolidation branch are denied by the same gate.
- PR creation is unreachable. The skill requires validating `orchestrator-state.json` with `--require-pr-creation-ready` before delegating to `Agent(pr-author)`, and forbids the delegation when that fails. `enforce-pr-author-skill.ps1` independently re-validates the same checkpoint and denies with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`. A cleanup run has no such checkpoint by definition.
- Only `--apply` itself still works, because its git calls run inside the script.
- Writing helper scripts to the session scratchpad is also denied for some file types (`.py`, `.ps1`), although the scratchpad is outside the repository.

Result: every worktree holding uncommitted lessons is stranded. The agent can neither preserve the content nor remove the worktree, and the only way forward is for the human to run the steps outside the agent with the shell-escape prefix.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `PREIMPLEMENTATION_GATE_BLOCKED`, `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The preimplementation gate, the PR-author preflight, and the skill's own PR step all assume that every write, commit, or PR belongs to a feature orchestration with a per-feature checkpoint.

Related defect, filed separately: the `--preserve` regression for `modified` records (see the sibling bug on `--preserve` copying an older snapshot over a newer `main`). Related: the target-worktree resolver family (#1009, #1010, #1011), which fixes other cases of a gate evaluating the wrong checkpoint.

## Proposed Fix / Validation Ideas

Required changes, all runtimes in parity (Claude hooks, Codex hooks, bundled copies):

1. **Recognized cleanup context for the preimplementation gate.** Allow these targets without a per-feature checkpoint:
   - writing exactly `artifacts/orchestration/cleanup-worktrees-manifest.json` whose content parses with `tool == "cleanup-merged-worktrees"` and `schema_version == 1`;
   - Write, Edit, `git add`, `git commit` and `git push` confined to the consolidation worktree on branch `documentationandmemories`, where every staged path is under the documentation/memory allowlist the skill already uses for editorial triage (`.claude/agent-memory/**`, `docs/**`, `**/*.md`);
   - scratchpad writes outside the repository.

   Any other path or branch still requires a checkpoint.
2. **A cleanup PR-readiness check** that replaces the orchestrator-state preflight for consolidation PRs. Both the skill's step 4 and `enforce-pr-author-skill.ps1` use it. It validates a fresh manifest (24-hour bound) with a matching `run_id`, that the head branch is `documentationandmemories`, that the branch diff against the base touches only allowlisted documentation/memory paths, and the existing body-file and receipt checks, unchanged. The orchestrator-state preflight stays mandatory for every other PR.
3. **Skill text:** update `cleanup-merged-worktrees/SKILL.md` steps 3 and 4 and the Sanctioned Removal Manifest section to name the cleanup context and the cleanup PR-readiness check, and remove the requirement to validate a per-feature `orchestrator-state.json` the run cannot have.
4. **Execution-environment brief:** update it in all of its byte-identical copies.

Acceptance:

- [x] Pester (and bats, where the script is tested) cases: manifest write allowed with no checkpoint, and a manifest write with the wrong `tool` or `schema_version` still denied.
- [x] Commit and push in the consolidation worktree allowed when limited to allowlisted paths, and denied when any non-allowlisted path is staged.
- [x] Consolidation PR creation allowed by the cleanup readiness check with no orchestrator checkpoint; a non-consolidation PR still requiring the orchestrator preflight.
- [x] A manifest-authorized `SAFE_TO_DELETE` removal reachable end to end.
- [x] An end-to-end test reproduces the full workflow from a main session with no `orchestrator-state.json`: report, manifest, preserve, commit, push, PR (via pr-author), apply, manifest-authorized removal, with no shell-escape steps.
- [x] No relaxation outside the cleanup context: feature work without a checkpoint is still denied exactly as today.

Language note: the cleanup-context recognition lives in enforcement hooks and libs, so PowerShell (hooks must not use Python). Any new script is PowerShell or bash.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
