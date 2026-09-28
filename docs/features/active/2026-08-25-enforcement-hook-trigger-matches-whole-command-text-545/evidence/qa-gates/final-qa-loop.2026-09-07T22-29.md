# Final QA loop — format, lint, test

Task: `[P5-T1]`
Timestamp: 2026-09-07T22-29

## TOOLCHAIN_SUBSTITUTION

`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime guard refuses them.
Format is `mcp__drm-copilot__run_poshqc_format`, lint is `mcp__drm-copilot__run_poshqc_analyze`, and
Pester is `mcp__drm-copilot__run_poshqc_test`. Per-suite and per-case results are read from
`artifacts/pester/pester-junit.xml`, never from the tool's exit code, per standing constraint 10.
There is no type-check stage for PowerShell, so the loop is format, lint, test.
`workspace_root` for every MCP call is
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`.

**Restarts from stage 1: 0.** No stage failed and no stage rewrote a file, so all three stages
completed in a single pass.

---

## Stage 1 — format

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
and no `scan_folders`.
EXIT_CODE: 0

The formatter exits 0 whether or not it rewrote a file, so two write-detecting observations are
recorded instead of relying on the exit code.

### `git status --porcelain` before and after

Command: `git status --porcelain | sort`, immediately before and immediately after the formatter.

| Capture | Line count |
|---|---|
| before | 58 |
| after | 58 |

Set-difference command: `comm -13 <before-sorted> <after-sorted>` — paths present after and absent
before.

**Set-difference count: 0.** No path became modified as a result of the formatter. The two captures
are byte-identical: 22 tracked modifications and 36 untracked evidence artifacts under the feature
folder's `evidence/` tree.

### SHA-256 of all twenty-one touched PowerShell files, before and after

`diff` of the before and after `sha256sum` captures produced no output (exit 0), and `comm -12`
over the two sorted captures reports **21 identical rows out of 21**. Every value below is
therefore identical before and after.

Seven canonical production files (standing constraint 4):

| # | File | SHA-256 before | SHA-256 after | Changed |
|---|---|---|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` | `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b` | same | no |
| 2 | `.codex/hooks/hook-command-scanner.ps1` | `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b` | same | no |
| 3 | `.claude/hooks/enforce-epic-merge-gate.ps1` | `05feec2ae5ca73a8ea25314d4e7ca3219e3d023e1bbe8d2076e3905e5961d0e5` | same | no |
| 4 | `.codex/hooks/enforce-epic-merge-gate.ps1` | `d87b543798a17508cccdbd7fcdeba2f8f77b2b67504024922e6fb83f3726aac3` | same | no |
| 5 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | `827e81b951406df75eb8fa4a7a030063e9e0e6af116a8f8f4eef68946f266fed` | same | no |
| 6 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `b809a8b34ea1bb53ac4bd91e5bdb3cee8253379c3c95a58c93d3d9ef702fd54b` | same | no |
| 7 | `.claude/hooks/validate-bash.ps1` | `21654b66f67a2796fadd584073e5f19840e6dd6229ec1b242a1c12fe79311676` | same | no |

Seven bundle mirrors:

| # | File | SHA-256 before | SHA-256 after | Changed |
|---|---|---|---|---|
| 8 | `extensions/…/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b` | same | no |
| 9 | `extensions/…/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | `d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b` | same | no |
| 10 | `extensions/…/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | `05feec2ae5ca73a8ea25314d4e7ca3219e3d023e1bbe8d2076e3905e5961d0e5` | same | no |
| 11 | `extensions/…/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | `d87b543798a17508cccdbd7fcdeba2f8f77b2b67504024922e6fb83f3726aac3` | same | no |
| 12 | `extensions/…/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | `827e81b951406df75eb8fa4a7a030063e9e0e6af116a8f8f4eef68946f266fed` | same | no |
| 13 | `extensions/…/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `b809a8b34ea1bb53ac4bd91e5bdb3cee8253379c3c95a58c93d3d9ef702fd54b` | same | no |
| 14 | `extensions/…/claude-customizations/.claude/hooks/validate-bash.ps1` | `21654b66f67a2796fadd584073e5f19840e6dd6229ec1b242a1c12fe79311676` | same | no |

Seven edited test suites (`[P1-T2]`, `[P2-T2]`, `[P2-T3]`, `[P3-T2]`, `[P3-T3]`, `[P4-T2]`):

| # | File | SHA-256 before | SHA-256 after | Changed |
|---|---|---|---|---|
| 15 | `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | `11058f0d1d5a6e68b8008af35977d0e474fde96a42bb4b9fb25d5e726d07dbac` | same | no |
| 16 | `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` | `fb3cba44270d0908cf125bb0ad484c7cfa1f250a49921e8e15e22207b5a9df62` | same | no |
| 17 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `380037a159e7c2cdbd306223129d38f70b853200ecf91d3d0cd50483da1f081f` | same | no |
| 18 | `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | `e0166d648d9431f7baedfc0a572fe2c341f2b8d00a9b0bacf73f77f654bbc322` | same | no |
| 19 | `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `14f1a23076aa4a3cb6284cc74efaaac66fe9f48ca114effb818e96a6562c2a33` | same | no |
| 20 | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `1116d1972e8d1855b17f2e6b5df2ee743d9cb908ac7eedf3b8706473d72aa3b1` | same | no |
| 21 | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | `e74af058d163d25d7808dfaaae4857450f2701aa30767ba9059a0549d9518126` | same | no |

Copy-set parity is visible in the table: rows 1, 2, 8, and 9 share one hash; rows 3 and 10 share
one; rows 4 and 11 share one; rows 5 and 12 share one; rows 6 and 13 share one; rows 7 and 14 share
one.

---

## Stage 2 — lint

Command: `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root` and no
`scan_folders`.
EXIT_CODE: 0

Result value recorded verbatim: **`ok: true`**.

---

## Stage 3 — test

Command: `mcp__drm-copilot__run_poshqc_test` with
`scan_folders=["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]`.
EXIT_CODE: 2
ExpectedExitCode: 2

The runner exits with the folder-wide failed-test count, which is 2 because of the two tolerated
pre-existing failures, one per folder.

### Folder-wide totals

| tests | failures | errors |
|---|---|---|
| 2408 | 2 | 0 |

### The fourteen named suites

Every row records `failures` 0 and `errors` 0.

| # | Suite | tests | failures | errors |
|---|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | 47 | 0 | 0 |
| 2 | `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` | 46 | 0 | 0 |
| 3 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 12 | 0 | 0 |
| 4 | `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 7 | 0 | 0 |
| 5 | `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 7 | 0 | 0 |
| 6 | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 22 | 0 | 0 |
| 7 | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 16 | 0 | 0 |
| 8 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 56 | 0 | 0 |
| 9 | `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1` | 13 | 0 | 0 |
| 10 | `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` | 24 | 0 | 0 |
| 11 | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | 0 | 0 |
| 12 | `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 3 | 0 | 0 |
| 13 | `tests/scripts/claude-hooks/validate-bash.Tests.ps1` | 26 | 0 | 0 |
| 14 | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 43 | 0 | 0 |

No `<testsuite>` element anywhere in the run carries a non-zero `errors` attribute.

### Every folder-wide failure, named

| # | Suite | It name | Classification |
|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | tolerated row 1 |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` | tolerated row 2 |

Both folder-wide failures are tolerated rows. Neither is change-caused, neither reproduces on a
clean CI checkout, and neither is fixed by this cycle. There is no third failure.

---

## Output Summary

The loop completed in a single pass with **0 restarts from stage 1**. Stage 1 format exited 0 and
rewrote nothing: porcelain set-difference 0 and all twenty-one SHA-256 values identical before and
after. Stage 2 analyze recorded `ok: true`. Stage 3 test recorded 2408 tests, 2 failures, 0 errors,
with all fourteen named suites at `failures` 0 / `errors` 0 and both folder-wide failures being the
two tolerated rows.
