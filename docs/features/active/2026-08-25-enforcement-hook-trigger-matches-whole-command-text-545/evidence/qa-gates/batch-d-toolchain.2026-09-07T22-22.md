# Batch D — toolchain gate

Task: `[P4-T7]` (procedure and acceptance as `[P1-T8]`)
Timestamp: 2026-09-07T22-22

Scope of the gate: the two `validate-bash.ps1` Claude copies and the one edited suite —
`.claude/hooks/validate-bash.ps1`,
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`, and
`tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`.

## TOOLCHAIN_SUBSTITUTION

`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime guard refuses them.
Format is `mcp__drm-copilot__run_poshqc_format`, lint is `mcp__drm-copilot__run_poshqc_analyze`, and
Pester is `mcp__drm-copilot__run_poshqc_test`, with per-suite and per-case results read from
`artifacts/pester/pester-junit.xml` rather than from the tool's exit code. The `workspace_root` for
every MCP call is `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`.

---

## Stage 1 — format

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
and no `scan_folders`.
EXIT_CODE: 0

The formatter exits 0 whether or not it rewrote a file, so the exit code alone gates nothing. Two
independent observations are recorded instead.

### Observation A — `git status --porcelain` before and after

Command: `git status --porcelain | sort`, run immediately before and immediately after the
formatter.

| Capture | Line count |
|---|---|
| before | 56 |
| after | 56 |

Set-difference command: `comm -13 <before> <after>`, that is, paths present after and absent
before.

**Set-difference count: 0.** The formatter introduced no newly-modified path.

Before capture, verbatim:

```
 M .claude/hooks/enforce-epic-merge-gate.ps1
 M .claude/hooks/enforce-parallel-abandon-gate.ps1
 M .claude/hooks/enforce-pr-author-skill-helpers.ps1
 M .claude/hooks/hook-command-scanner.ps1
 M .claude/hooks/validate-bash.ps1
 M .codex/hooks/enforce-epic-merge-gate.ps1
 M .codex/hooks/hook-command-scanner.ps1
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T20-45.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1
 M tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
 M tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1
 M tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
 M tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
 M tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
 M tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
 M tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
```

plus 34 untracked evidence artifacts under
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/`,
totalling 56 lines. The after capture is byte-identical to the before capture.

### Observation B — SHA-256 of the three in-scope files, before and after

| File | SHA-256 before | SHA-256 after | Changed |
|---|---|---|---|
| `.claude/hooks/validate-bash.ps1` | `21654b66f67a2796fadd584073e5f19840e6dd6229ec1b242a1c12fe79311676` | `21654b66f67a2796fadd584073e5f19840e6dd6229ec1b242a1c12fe79311676` | no |
| `extensions/…/claude-customizations/.claude/hooks/validate-bash.ps1` | `21654b66f67a2796fadd584073e5f19840e6dd6229ec1b242a1c12fe79311676` | `21654b66f67a2796fadd584073e5f19840e6dd6229ec1b242a1c12fe79311676` | no |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | `e74af058d163d25d7808dfaaae4857450f2701aa30767ba9059a0549d9518126` | `e74af058d163d25d7808dfaaae4857450f2701aa30767ba9059a0549d9518126` | no |

`diff` of the before and after `sha256sum` captures produced no output. The two `validate-bash.ps1`
copies remain equal to each other, so copy-set parity survived the formatter.

---

## Stage 2 — lint

Command: `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root` and no
`scan_folders`.
EXIT_CODE: 0

Result value recorded verbatim: **`ok: true`**.

The analyzer reports no diagnostic count on a clean run, so `ok: true` is the asserted value per
standing constraint 10.

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

### Per-suite counts for the batch-D suites

| Suite | tests | failures | errors |
|---|---|---|---|
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 16 | 0 | 0 |
| `tests/scripts/claude-hooks/validate-bash.Tests.ps1` | 26 | 0 | 0 |
| `tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1` | 37 | 0 | 0 |
| `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | 8 | 0 | 0 |

The two Codex `validate-bash` suites are recorded to show the Codex runtime is unaffected: R-2.d is
Claude-only and `.codex/hooks/validate-bash.ps1` was not edited.

### Every folder-wide failure, named

| # | Suite | It name | Classification |
|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | tolerated row 1 |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` | tolerated row 2 |

The only folder-wide failures are the two tolerated names. No other failure and no error.

---

## Line-cap check

Command: `wc -l` over the three in-scope files.
EXIT_CODE: 0

| File | `wc -l` | Cap |
|---|---|---|
| `.claude/hooks/validate-bash.ps1` | 442 | 500 |
| `extensions/…/claude-customizations/.claude/hooks/validate-bash.ps1` | 442 | 500 |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 147 | 500 |

All three are at or under 500, with 58 lines of headroom on the two production copies.

**Recorded divergence from a plan prediction, benign.** Standing constraint 4 predicted 434 for
`.claude/hooks/validate-bash.ps1` (420 + the 14-line code block of Edit 6). The observed value is
442. The 8-line difference is the rest of Edit 6, which the plan also directs: one blank separator
line after the inserted `foreach` block, and the seven lines of the `.DESCRIPTION` extension Edit 6
requires ("Extend the function's `.DESCRIPTION` by two sentences naming the new leg and its
ordering"). The 434 figure in constraint 4 accounts for the code block only. The cap is 500, so the
divergence changes no gate. Recorded here rather than inferred.

---

## Output Summary

Stage 1 format exited 0 and rewrote nothing: porcelain set-difference 0, all three in-scope SHA-256
values unchanged. Stage 2 analyze recorded `ok: true`. Stage 3 test recorded 2408 tests, 2 failures,
0 errors, with both failures being the two tolerated names and per-suite `failures`/`errors` of 0
for all four `validate-bash` suites. **Restarts from stage 1: 0.** No stage failed and no stage
rewrote a file, so the loop completed in a single pass.
