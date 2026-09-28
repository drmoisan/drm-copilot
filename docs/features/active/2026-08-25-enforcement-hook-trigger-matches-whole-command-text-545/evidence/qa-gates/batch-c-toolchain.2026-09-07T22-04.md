# Batch C toolchain gate — [P3-T10]

Timestamp: 2026-09-07T22-04

Task: `[P3-T10]` — run the batch-C toolchain gate with the `[P1-T8]` procedure: format, then
analyze, then the two hook-test folders, in that order, restarting from format if any stage
fails or rewrites a file. A fourth stage re-runs the abandon token seam module.

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session, so no
PoshQC stage was run as a direct shell command. The substitute route for the PowerShell stages
is the bundled MCP function set: `mcp__drm-copilot__run_poshqc_format`,
`mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test`, all with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`.
Per-suite and per-case test results are read from `artifacts/pester/pester-junit.xml` rather
than from the test runner's exit code. Stage 5 is a Python test run and required no
substitution: `poetry run pytest` executed directly.

EXIT_CODE: 0 for the format, analyze, and seam-module stages. The two PowerShell test stages
each exited 1, which is the folder-wide failed-test count and equals the one tolerated failure
in each folder.

---

## Stage 1 — Format

Command: `mcp__drm-copilot__run_poshqc_format` with the workspace root above and no
`scan_folders` argument.

EXIT_CODE: 0 (`ok: true`)

The formatter exits 0 whether or not it rewrote a file, so two independent observations
establish that it rewrote nothing.

### Observation 1 — `git status --porcelain` before and after

Command: `git status --porcelain | sort` immediately before and immediately after the
formatter, compared with `comm -13`.

**Set-difference count (paths present after and absent before): 0.**

The before capture held 47 lines: the modified tracked files of batches A, B, and C plus the
untracked evidence artifacts under the feature folder's `evidence/` tree. The after capture is
identical, so `comm -13` produced no lines and the formatter introduced no newly modified path.

### Observation 2 — SHA-256 of the four batch-C copies, before and after

| File | Before | After |
|---|---|---|
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | `827e81b951406df75eb8fa4a7a030063e9e0e6af116a8f8f4eef68946f266fed` | `827e81b951406df75eb8fa4a7a030063e9e0e6af116a8f8f4eef68946f266fed` |
| `extensions/…/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | `827e81b951406df75eb8fa4a7a030063e9e0e6af116a8f8f4eef68946f266fed` | `827e81b951406df75eb8fa4a7a030063e9e0e6af116a8f8f4eef68946f266fed` |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `b809a8b34ea1bb53ac4bd91e5bdb3cee8253379c3c95a58c93d3d9ef702fd54b` | `b809a8b34ea1bb53ac4bd91e5bdb3cee8253379c3c95a58c93d3d9ef702fd54b` |
| `extensions/…/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `b809a8b34ea1bb53ac4bd91e5bdb3cee8253379c3c95a58c93d3d9ef702fd54b` | `b809a8b34ea1bb53ac4bd91e5bdb3cee8253379c3c95a58c93d3d9ef702fd54b` |

All four digests are unchanged across the formatter run, and each canonical file still equals
its mirror, so `[P3-T7]`'s parity result survives the format stage.

## Stage 2 — Analyze

Command: `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root` and no
`scan_folders` argument.

EXIT_CODE: 0

Result value: **`ok: true`**.

## Stage 3 — Tests, Claude hook folder

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

ExpectedExitCode: 1

Folder totals: `tests=1541 failures=1 errors=0`.

| Suite | tests | failures | errors |
|---|---|---|---|
| `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 7 | 0 | 0 |
| `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 22 | 0 | 0 |

The single folder-wide failure is
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` It
`allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, which is
tolerated row 1. There is no other failure in the folder.

## Stage 4 — Tests, Codex hook folder

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

ExpectedExitCode: 1

Folder totals: `tests=863 failures=1 errors=0`.

The single folder-wide failure is
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` It
`allows every registered handler for every tool name its own matcher admits`, which is tolerated
row 2. There is no other failure in the folder. Batch C edits no Codex file; this folder is run
because the batch gate procedure covers both hook-test folders and would surface any
cross-runtime regression.

## Stage 5 — Abandon token seam module

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -p no:cacheprovider --no-header -q`

EXIT_CODE: 0

Summary line: **`10 passed in 0.06s`**, so the module reports **`10 passed`**.

That equals the `[P0-T8]` figure of `10 passed` for the same module. A lower number would mean
Edit 4 broke the token-count invariant asserted by
`test_hook_states_each_token_exactly_once`, which requires each of the two token literals to
appear exactly once in the whole file text of `.claude/hooks/enforce-parallel-abandon-gate.ps1`,
counting comments. It did not: the raw-scan leg reconstructs both accepted spellings from
`$script:AbandonDispositionToken` by splitting it, and references the confirmation token only
through `$script:AbandonConfirmToken`.

## `wc -l` inventory — four edited copies and two edited suites

| File | `wc -l` | At or under 500 |
|---|---|---|
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 353 | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | 353 | yes |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 260 | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 260 | yes |
| `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 100 | yes |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 327 | yes |

## Output Summary

All five stages passed on the first attempt. **No restart from stage 1 was required; the restart
count is 0.** Format rewrote nothing, evidenced by a porcelain set-difference count of 0 and
four unchanged SHA-256 digests rather than by its exit code alone. Analyze reported `ok: true`.
Both PowerShell test folders report `errors` 0 and exactly one failure each, and both failures
are the named tolerated rows. The seam module reports `10 passed` with `EXIT_CODE: 0`, equal to
the `[P0-T8]` baseline, so the token-count invariant holds. All six inventoried files are at or
under 500 lines.
