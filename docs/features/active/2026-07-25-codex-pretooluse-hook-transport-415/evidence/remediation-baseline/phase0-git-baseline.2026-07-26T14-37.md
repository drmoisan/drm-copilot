# Phase 0 — Git Baseline (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P0-T2]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`

Timestamp: 2026-07-26T14-37

## Commands and Exit Codes

Command: `git rev-parse --abbrev-ref HEAD`
EXIT_CODE: 0

Command: `git rev-parse HEAD`
EXIT_CODE: 0

Command: `git status --porcelain`
EXIT_CODE: 0

Command: `git diff --stat -- .codex/config.toml`
EXIT_CODE: 0

Command: `git diff fb483b8468204e4385b5583c3b3ec4c0a987eede --stat -- .codex/config.toml`
EXIT_CODE: 0

Command: `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD`
EXIT_CODE: 0

Supplementary (existence check, not a plan-mandated command): `ls -d .codex/state`
EXIT_CODE: 2 (`ls: cannot access '.codex/state': No such file or directory`)

## Output Summary

### Branch

```
bug/codex-pretooluse-hook-transport-415
```

### BASELINE SHA (observed, recorded verbatim from `git rev-parse HEAD`)

```
37d0ecb46c222ddd3f20d1e26e5742ecf26acd73
```

This observed value is the `<BASELINE_SHA>` consumed by [P7-T6] to compute the cycle-2 delta
(`git diff 37d0ecb46c222ddd3f20d1e26e5742ecf26acd73 --name-only`). No SHA is pinned in the plan
document; committing the cycle-2 plan itself moved HEAD, which is why the value is re-resolved here.

### `git status --porcelain` (observed, verbatim)

```
 M docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/remediation-baseline/phase0-instructions-read.md
 M docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md
```

Both modifications are cycle-2 execution artifacts produced moments earlier by [P0-T1]
(the appended cycle-2 policy-read record) and by the [P0-T1] plan check-off. No source,
test, or configuration file is dirty at baseline. The cycle-2 documentation artifacts
(`remediation-inputs.2026-07-26T18-10.md`, `remediation-plan.2026-07-26T18-10.md`) were already
committed at `37d0ecb4` prior to execution, as the plan anticipated.

### `.codex/config.toml` cleanliness (Hard Constraint 3)

Both diff commands produced **empty output** with exit code 0:

- `git diff --stat -- .codex/config.toml` → no working-tree diff.
- `git diff fb483b8468204e4385b5583c3b3ec4c0a987eede --stat -- .codex/config.toml` → no diff versus merge-base.

`.codex/config.toml` is therefore clean at cycle-2 start and must remain unmodified, unstaged, and
uncommitted for the remainder of this plan. This confirmation is re-verified at [P7-T6](c).

### `.codex/state/`

Does not exist in the working tree. No `.codex/state/*` file can be staged.

### `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD` (cycle-1 delta, pre-existing)

105 files changed, 10170 insertions(+), 1332 deletions(-).

Non-documentation surface in the merge-base..HEAD delta:

- `.codex/hooks/` — 9 modified hooks plus the new `codex-pretooluse-file-mapping.ps1` (474 lines).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` — the corresponding bundle mirrors, plus removal of the orphaned `enforce-pr-author-skill.ps1` (500 lines deleted).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` — 1 insertion.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundle mirror — 13 insertions each.
- `tests/scripts/codex-hooks/` — 7 test files (6 new, 1 extended) plus `legacy-codex-hook-contracts.Tests.ps1`.
- `tests/scripts/dev_tools/test_codex_and_agents_pack_manifest_completeness.py` — 1 deletion.
- `.gitignore` — 1 insertion.

Notably **absent** from this delta: `.codex/config.toml` (unchanged, per the two checks above),
`.codex/hooks/enforce-epic-child-worktree-binding.ps1`, and `.codex/hooks/enforce-epic-planning-only.ps1`
— the two files the cycle-2 C1/A1 fixes will touch. Preflight confirmed no non-docs file changed since
the CI failure commit `06473a63`, so the fail-before condition still reproduces at `37d0ecb4`.

EXIT_CODE: 0
