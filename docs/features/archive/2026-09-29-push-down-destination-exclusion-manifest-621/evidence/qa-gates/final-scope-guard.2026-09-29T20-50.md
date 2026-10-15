# Final scope guard — [P9-T1] (AC-24, US-22)

Anchor note (ANCHOR_DRIFT): `origin/epic/push-down-payload-correctness-integration` advanced after Phase 0. The [P0-T2] artifact pinned it at `9438bdf5253e10903e2e74eab5cf51df988e0466`; it now resolves to `57fe96c2` (PR #779, issue #763, merged into the integration branch after Phase 0). `git merge-base HEAD origin/epic/push-down-payload-correctness-integration` still returns `9438bdf5253e10903e2e74eab5cf51df988e0466`, so the two-dot diff against the moved ref also reports files that #763 changed on the integration branch and that this branch never touched. The literal command is recorded below with its output; the branch-scoped result is taken against the pinned [P0-T2] anchor SHA, which equals the merge base, and is cross-checked with the three-dot form. This anchor substitution applies to every anchored diff in Phases 9 to 11 of this run.

## Command 1 (literal plan command)

Timestamp: 2026-09-29T20-50
Command: git diff origin/epic/push-down-payload-correctness-integration --name-only -- .claude/hooks .claude/lib scripts/dev_tools/push_down_copilot_customizations.py scripts/dev_tools/push_down_claude_filesystem.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts package.json package-lock.json extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json
EXIT_CODE: 0
Output Summary: five paths, all introduced by #763 on the integration branch after the Phase 0 anchor (confirmed by `git diff 9438bdf5..origin/epic/push-down-payload-correctness-integration --name-only`, which lists the same five paths):
- .claude/hooks/enforce-parallel-abandon-gate.ps1
- .claude/lib/bash/abandon-parallel-item.sh
- .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1
- .claude/lib/parallel-drift/ParallelDrift.psm1
- .claude/lib/parallel-drift/ParallelDriftHalt.psm1
`git log --oneline origin/epic/push-down-payload-correctness-integration..HEAD -- .claude/hooks .claude/lib` prints nothing: no commit on this branch touches these paths.

## Command 2 (branch-scoped, pinned Phase 0 anchor)

Timestamp: 2026-09-29T20-50
Command: git diff 9438bdf5253e10903e2e74eab5cf51df988e0466 --name-only -- .claude/hooks .claude/lib scripts/dev_tools/push_down_copilot_customizations.py scripts/dev_tools/push_down_claude_filesystem.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts package.json package-lock.json extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json
EXIT_CODE: 0
Output Summary: empty output.

## Command 3 (three-dot cross-check)

Timestamp: 2026-09-29T20-50
Command: git diff origin/epic/push-down-payload-correctness-integration...HEAD --name-only -- .claude/hooks .claude/lib scripts/dev_tools/push_down_copilot_customizations.py scripts/dev_tools/push_down_claude_filesystem.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts package.json package-lock.json extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json
EXIT_CODE: 0
Output Summary: empty output.

## Command 4 (porcelain companion)

Timestamp: 2026-09-29T20-50
Command: git status --porcelain -- .claude/hooks .claude/lib scripts/dev_tools/push_down_copilot_customizations.py scripts/dev_tools/push_down_claude_filesystem.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts package.json package-lock.json extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json
EXIT_CODE: 0
Output Summary: empty output.

Out-of-plan local change recorded, not deleted: the executor memory directory `.claude/agent-memory/atomic-executor/` may hold uncommitted executor-memory edits; it lies outside the guarded paths and is never staged.

Result: this branch changes none of the non-goal paths. PASS against the pinned anchor; the literal-ref form is non-empty only because of the upstream #763 merge.
