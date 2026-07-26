# Phase 0 — Git Baseline (Remediation Cycle 2, RE-RESOLVED AFTER REBASE)

- **Issue:** #415
- **Task:** [P0-T2] (re-run)
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Supersedes:** `phase0-git-baseline.2026-07-26T14-37.md` (recorded a pre-rebase SHA)

Timestamp: 2026-07-26T15-17

## Why This Artifact Exists

The earlier cycle-2 execution session recorded `37d0ecb46c222ddd3f20d1e26e5742ecf26acd73` as the
baseline HEAD. The branch was subsequently rebased onto `origin/main` (which had advanced 21
commits for issues #421, #422, #423, #426) and force-pushed, so that SHA no longer exists on the
branch. The plan deliberately pins no HEAD SHA, so [P0-T2] is re-run here and the observed values
are re-recorded. The prior artifact is retained unmodified as an audit record.

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

### Observed `git rev-parse HEAD` (verbatim)

```
bb12591b048bbf00ffe5a55d91a5287e85231a84
```

This is commit `bb12591b fix(codex-hooks): treat an empty live branch as unset on detached HEAD (#415)` —
the committed cycle-2 [P1-T1]/[P1-T2] work produced by the interrupted earlier session.

### BASELINE SHA consumed by [P7-T6]

```
21fc8c3b7f549723097efe4d8dc0e1404dca1867
```

Recorded correction, with justification. [P7-T6] defines its diff argument as
"the observed baseline HEAD SHA recorded at P0-T2 **(the cycle-2 delta)**", and the plan header
(line 13) defines the branch reference point as the **pre-implementation** baseline. The current
`git rev-parse HEAD` (`bb12591b`) is mid-cycle-2: it already contains the C1 hook fix, its bundle
mirror, and the new test suite. Using `bb12591b` as the diff argument would silently exclude that
implementation surface from the [P7-T6] scope assertion, which is the opposite of what the task
verifies.

`21fc8c3b` is the pre-implementation point on the rebased branch and is the exact post-rebase
equivalent of the pre-rebase `37d0ecb4` recorded at 14-37: both are the docs-only commit
`docs(415): clear cycle-2 remediation plan preflight`, whose sole changed path is
`docs/.../remediation-plan.2026-07-26T18-10.md` (verified with `git show --stat --name-only 21fc8c3b`).
`git diff 21fc8c3b --name-only` therefore yields exactly the cycle-2 implementation delta, which is
what [P7-T6] asserts against.

Both values are recorded so the audit trail carries the literal observation and the value actually
consumed downstream.

### `git status --porcelain` (observed, verbatim)

```
```

Empty. The working tree is clean at re-baseline; all prior cycle-2 work is committed at `bb12591b`.
No source, test, configuration, or documentation file is dirty.

### `.codex/config.toml` cleanliness (Hard Constraint 3)

Both diff commands produced **empty output** with exit code 0:

- `git diff --stat -- .codex/config.toml` → no working-tree diff.
- `git diff fb483b8468204e4385b5583c3b3ec4c0a987eede --stat -- .codex/config.toml` → no diff versus merge-base.

`.codex/config.toml` is clean after the rebase and must remain unmodified, unstaged, and uncommitted
for the remainder of this plan. Re-verified at [P7-T6](c).

### `.codex/state/`

Does not exist in the working tree. No `.codex/state/*` file can be staged.

### `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD`

```
242 files changed, 20721 insertions(+), 1378 deletions(-)
```

The count grew from the 14-37 record (105 files / 10170 insertions) because the rebase brought the
21 upstream `main` commits into the merge-base..HEAD range. The merge-base
`fb483b8468204e4385b5583c3b3ec4c0a987eede` is unchanged and structurally immune to the rebase.

### Rebase scope-overlap check (this plan's file scope)

Upstream `main` advanced across issues #421, #422, #423, #426. Paths in this plan's scope were
checked against the rebased tree:

| Plan-scope path | Touched by the 21 upstream commits |
|---|---|
| `.codex/hooks/enforce-epic-child-worktree-binding.ps1` | no |
| `.codex/hooks/enforce-epic-planning-only.ps1` | no |
| bundle mirrors of both hooks | no |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | no |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | no |
| `.codex/config.toml` | no |
| `tests/scripts/codex-hooks/**` | no |

The only bundled Codex/agents paths the upstream commits touched are the bundle **skill**
documents `.../codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md` and
`.../general-unit-test/SKILL.md`, which are outside this plan's scope.

Toolchain-relevant upstream change: the repository's TypeScript test runner moved from Vitest to
Jest, and `.claude/rules/general-code-change.md` / `.claude/rules/general-unit-test.md` now name
Jest. RD-6 scopes the cycle-2 delta to PowerShell only, so no TypeScript test command is invoked by
this plan; the policy files were re-read post-rebase (recorded in `phase0-instructions-read.md`).

EXIT_CODE: 0
