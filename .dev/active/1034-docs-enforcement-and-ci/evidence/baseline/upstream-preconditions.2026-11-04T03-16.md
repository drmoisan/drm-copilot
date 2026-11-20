# Upstream Preconditions - Issue 1034

Timestamp: 2026-11-04T03-16
Command: git fetch origin; git merge-base origin/epic/documentation-estate-tooling-integration HEAD; git log --oneline MERGE_BASE..HEAD; test -f (seven upstream files); grep of Get-DocsCommandTable rows and New-DocsCommandContext members in .claude/lib/docs/Invoke-DocsCommand.ps1; grep -r ResolveRevision|ReadRevisionText over .claude and tests; gh pr list --head feature/docs-surface-analyzers-python-config-1022-r2 and --head feature/docs-surface-analyzers-python-config-1022 (state all); read route_id of artifacts/orchestration/orchestrator-state.json
EXIT_CODE: 1
Output Summary: BLOCKED. Precondition 2 FAIL (New-DocsCommandContext has no ResolveRevision or ReadRevisionText member; no test drives them). Precondition 3 FAIL (no `inventory` dispatch row; 1022 has no pull request and is not merged). Precondition 4 FAIL as a consequence of 3. Preconditions 1 and 5 PASS. Execution stops before P0-T3; no later task is checked.

## Derived Values

- MERGE_BASE: `06012704f6e86aa86d41f84b2e191fd40c2a5602` (equals the tip of `origin/epic/documentation-estate-tooling-integration` after fetch, merge of PR #1071).
- `git log --oneline MERGE_BASE..HEAD`: 0 commits (the branch is at the integration tip).

## Precondition Results

| # | Precondition | Result | Observation |
|---|---|---|---|
| 1 | 1020 including the D5 envelope schema merged | PASS | Present: `.claude/lib/docs/Invoke-DocsCommand.ps1`, `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1`, `DocsProfileCommands.psm1`, `schemas/docs/v1/docs-command-envelope.schema.json`, `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1`. |
| 2 | `ResolveRevision` and `ReadRevisionText` members in `New-DocsCommandContext`, with a 1020 test driving them through an injected process stand-in | FAIL | `New-DocsCommandContext` returns members `RepositoryRoot`, `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow`, `InvokeProcess` only. A recursive search of `.claude/` and `tests/` for `ResolveRevision` and `ReadRevisionText` returns no match, so no such test exists. 1023's `validate` takes the revision as the explicit `-Revision` option and does not resolve revisions through the context. |
| 3 | `check` (1021), `inventory` (1022) and `validate` (1023) rows merged | FAIL | `check` row present (options `Profile`, `Path`). `validate` row present (options `Profile`, `Mode`, `Revision`, `WriteReceipt`). `inventory` row ABSENT: only the anchor comment `# --- 1022: inventory ---` is present in `Get-DocsCommandTable`. No pull request exists for `feature/docs-surface-analyzers-python-config-1022-r2` or `feature/docs-surface-analyzers-python-config-1022`. |
| 4 | Branch contains the integration head carrying items 1 to 3 | FAIL | The branch contains the integration head (MERGE_BASE equals its tip), but that head does not carry item 3 (1022) or item 2 (context members). |
| 5 | Item worktree checkpoint selects `large` and is not terminal | PASS | `route_id` is `large`; `blocked_reason` is `none`; the checkpoint is not terminal. |

## Observed Anchor Text (informational, for P0-T3 on resume)

- Dispatcher anchor in `Get-DocsCommandTable`: `# --- 1034: surface-delta ---` (the plan's `# --- 900008: surface-delta ---` spelling is not the merged text).
- Init anchor in `Get-DocsInitTemplate` of `DocsProfileCommands.psm1`: `# --- 1034: docs workflow ---`.
- Receipt `artifact_kind` written by `DocsReceipt.psm1`: `docs-validation-receipt`.

## Required Upstream Action

- 1022 must merge its `inventory` row into `epic/documentation-estate-tooling-integration`.
- Precondition 2 requires either a 1020 amendment adding `ResolveRevision` and `ReadRevisionText` to `New-DocsCommandContext` (with a test through an injected process stand-in), or, per the plan, an epic update and a specification revision that reassigns ownership of those members (for example to this item); the latter changes this plan's file set and is a planner decision.
