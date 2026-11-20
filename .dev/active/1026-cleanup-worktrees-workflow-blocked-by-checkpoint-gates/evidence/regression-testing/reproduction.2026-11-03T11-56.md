# Issue 1026 reproduction on current main

Timestamp: 2026-11-03T11-56
Command: sh SCRATCH/issue-1026-repro.sh (dot-sources .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 and .claude/hooks/hook-docs-only-diff.ps1 from this branch, base main 715241396, and calls Invoke-OrchestrationPreimplementationGateDecision with -CheckpointRaw '{}' and with a ready checkpoint; calls Get-DocsOnlyDiffTextViolation with two diff texts)
EXIT_CODE: 0
Output Summary: four of the issue's blockers still occur on main; git push and --apply do not block; the PR-author hook now partly allows consolidation PRs (issue 901 docs-only exemption) but denies any branch that touches .claude/agent-memory/.

## Method

- Injecting `{}` as the checkpoint reproduces the no-checkpoint case: `Test-OrchestrationReady` rejects `{}` the same way it rejects an absent file (empty raw text, parsed as null).
- Live confirmation: in this session, whose root has no `artifacts/orchestration/orchestrator-state.json` and whose gate hooks are byte-identical to main (`git diff 715241396 HEAD` over the gate files was empty), a Write of `SCRATCH/issue-1026-repro.ps1` was denied with `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json ...`.

## Results (no ready checkpoint)

| Operation | Decision | Hook file and function |
|---|---|---|
| Write `artifacts/orchestration/cleanup-worktrees-manifest.json` | deny | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `Test-ImplementationPath` (the `.json` extension leg; the manifest is not in `$script:CheckpointPaths`) |
| Write SCRATCH `.ps1` | deny | same, `Test-ImplementationPath` (extension leg applies to paths outside every worktree) |
| Write SCRATCH `.py` | deny | same |
| Write SCRATCH `.sh` | allow | not an implementation extension |
| Write `.claude/agent-memory/x/y.md`, `docs/research/y.md` | allow | `.md` is not an implementation extension |
| `git add .claude/agent-memory/x/y.md` | deny | `Test-ImplementationCommand` (index 0, git staging) with `Test-ExemptOrchestrationStagingCommand` in `enforce-orchestration-preimplementation-gate-helpers.ps1` (exempt trees are only `docs/features/{epics,parallel,active,potential}/` and `artifacts/orchestration/`) |
| `git add docs/research/y.md` | deny | same |
| `git add docs/features/potential/y.md` | allow | exempt bookkeeping tree |
| `git commit -F msg.txt` | deny | `Test-ImplementationCommand` (git staging leg) |
| `git push -u origin documentationandmemories` | allow | not classified as implementation; the issue's push claim does not reproduce |

Control with a ready checkpoint: the manifest Write and `git add .claude/agent-memory/x/y.md` are both allowed, so the denials depend only on the checkpoint.

## PR creation

- `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `Get-PrAuthorBypassReason`: when the checkpoint preflight fails, `Get-PrAuthorDocsOnlyExemption` (`.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, issue 901) exempts a `gh pr create` whose diff lists only `docs/` paths.
- `Get-DocsOnlyDiffTextViolation` (`.claude/hooks/hook-docs-only-diff.ps1`): a `docs/research/y.md` diff returns no violation; a diff with `docs/research/y.md` and `.claude/agent-memory/x/y.md` returns `DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: '.claude/agent-memory/x/y.md' is outside docs/.` A consolidation PR carrying agent-memory lessons, which the skill names as in scope, is therefore still denied with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md`, End-to-End Workflow step 4, still requires validating `artifacts/orchestration/orchestrator-state.json` with `--require-pr-creation-ready` and prohibits delegation when that fails.

## Not reproduced

- `git push`: allowed by the preimplementation gate.
- `--apply` and the `--preserve` staging: their git calls run inside the script, which no hook sees. `--preserve` stages but does not commit, so the agent's `git commit` is the denied step.
- Manifest-authorized removal: `enforce-parallel-worktree-removal-gate.ps1` already has the sanctioned-removal manifest branch (issue 635, `CleanupWorktreeManifest.psm1`); it is blocked only because the manifest cannot be written.

## Scope

Still broken, in scope: manifest write, scratch `.ps1`/`.py` writes outside every worktree, commit of allowlisted documentation/memory paths in the consolidation worktree, PR creation for a consolidation branch carrying `.claude/agent-memory/` paths, and the skill step 4 text. The fix must keep Codex twins (`.codex/hooks/`) and bundled copies in parity.
