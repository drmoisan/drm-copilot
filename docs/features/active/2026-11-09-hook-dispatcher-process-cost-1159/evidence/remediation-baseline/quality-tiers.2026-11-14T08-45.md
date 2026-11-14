# Remediation cycle 2 — cycle start and tier-classification baseline ([P0-T1])

Timestamp: 2026-11-14T08-45
Command: env -u VIRTUAL_ENV poetry -C <worktree root> run python -m scripts.dev_tools.check_quality_tiers --repo-root <worktree root>
EXIT_CODE: 1
Output Summary: QT008 reproduced (finding F1). One QT line printed; no other QT finding. One new project root established by branch-added paths.

## Cycle start

- Cycle-start head: 8b3759ea547870b0bae11a0379d0df25a000b3a1 (branch feature/hook-dispatcher-process-cost-1159)
- Merge base (origin/main fetched, merge-base of origin/main and HEAD): 2c8dee6dd3a82f210561d9efe623767ae902de51

## QT lines printed

- `QT008: discovered project '.claude/lib/hook-dispatch' has no entry` — marked for [P1-T1]. Matches the CI evidence of the inputs file (F1); no QT finding beyond the CI evidence.

## Project roots from branch-added paths (rules R1 to R5)

Derived from `git diff --name-status --diff-filter=A <merge base> HEAD`, paths outside `docs/`.

| Added path(s) | Rule | Root | Entry on the branch | Disposition |
|---|---|---|---|---|
| `.claude/lib/hook-dispatch/HookDispatch.psm1`, `HookDispatchRunner.psm1` | R4 | `.claude/lib/hook-dispatch` | none | new root, marked for [P1-T1] |
| `.claude/hooks/invoke-pretooluse-dispatch.ps1`, `pretooluse-dispatch.json` | R5 | `.claude/hooks` | present | existing root |
| `.codex/hooks/hook-dispatch.ps1`, `invoke-pretooluse-dispatch.ps1`, `pretooluse-dispatch.json` | R5 | `.codex/hooks` | present | existing root |
| `scripts/dev-tools/HookProcessCost.psm1`, `Measure-HookProcessCost.ps1` | R3 (R2 not met: no same-stem `.psd1`) | `scripts/dev-tools` | present (folder exists at the merge base) | existing root |
| `extensions/drm-copilot/resources/...` bundle copies | excluded root / not a project marker | none | n/a | no root |
| `tests/...` files | excluded root | none | n/a | no root |

Only `.claude/lib/hook-dispatch` is a new project root.
