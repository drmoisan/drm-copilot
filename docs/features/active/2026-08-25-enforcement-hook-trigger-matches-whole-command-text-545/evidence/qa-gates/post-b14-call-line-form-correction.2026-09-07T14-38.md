# Post-B14 correction — the three `--force` call sites written on one physical line

Timestamp: 2026-09-07T14-38

Task: closes an AC-36 obligation carried by [P8-T1] and [P8-T10]; recorded separately so the closed
batch B14 gate record is not rewritten.

## Why the correction was made

[P12-T15] must "quote the post-change call line verbatim from the file" for each of the four
presence-only `Test-CommandLineFlag` call sites. As first written, the three `--force` call sites
used a backtick line continuation, so `-FlagName '--force'` sat on a second physical line. A verbatim
quotation of "the call line" would then have omitted the flag name, which is the one element the row
exists to record, and a single-line search for the call would have returned no match. The two
`--body-file` / `--body` call sites in `enforce-pr-author-skill-helpers.ps1` were already written on
one line each, so they needed no change.

Each `Test-CommandLineFlag` call and the `Get-CommandLineOperand` call beside it were joined onto one
physical line in three files. Nothing else changed: no parameter, no argument value, no control flow,
no reason string, and no documentation comment.

## The four call sites after the correction

| File | Function | Flag | Line | Call line, verbatim |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `Get-EpicWorktreeRemovalCommandPath` | `--force` | 164 | `    $hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'` |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `Get-ParallelWorktreeRemovalCommandPath` | `--force` | 94 | `    $hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'` |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | `Get-CodexWorktreeRemovalPath` | `--force` | 58 | `    $hasForce = Test-CommandLineFlag -CommandText $Command -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'` |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `Get-PrAuthorBypassReason` | `--body-file` | 189 | `    $hasBodyFile = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--body-file'` |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `Get-PrAuthorBypassReason` | `--body` | 190 | `    $hasInlineBody = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--body'` |

The Codex row is the fourth `--force` site and is outside [P12-T15]'s three-flag, four-line list,
which names Claude paths only; it is recorded here because [P8-T6] created it and the same
one-line form applies. The `--merge` call site that [P12-T15] also names belongs to [P9-T1] and does
not exist yet.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31`.

EXIT_CODE: 0

`git status --porcelain | wc -l` returned **27** both before and after the formatter. **Set-difference
count: 0.** The three edited files' SHA-256 values are unchanged across the formatter run, so the
formatter did not reflow the newly joined lines back.

## Stage 2 — linting

Command: `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root`.

EXIT_CODE: 0

Result: `ok: true`, equivalent to a repository-wide total of **0** diagnostics, equal to the [P0-T6]
baseline of 0. No line-length or style diagnostic was raised by the joined lines, the longest of
which is 138 characters.

## Stage 3 — Pester

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; results were
read out of `artifacts/pester/pester-junit.xml`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]`

EXIT_CODE: 4 (combined failed-test count)

Combined totals: **2245 tests, 4 failures, 0 errors, 0 skipped.**

| Suite | tests | failures |
| --- | --- | --- |
| `enforce-epic-worktree-removal-gate.Tests.ps1` | 46 | 0 |
| `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | 5 | 0 |
| `enforce-parallel-worktree-removal-gate.Tests.ps1` | 45 | 0 |
| `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` | 3 | 0 |
| `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` (Codex) | 5 | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | 43 | 0 |
| `hook-command-parser.AcceptanceCases.Tests.ps1` | 11 | 2 |

`hook-command-parser.AcceptanceCases.Tests.ps1` re-confirms **AT-1 PASS** and **AT-7 PASS** after the
correction; its two failures remain AT-2 and AT-4.

The four combined failures are: AT-2 and AT-4, known-red inventory rows 2 and 4, closed by [P9-T11];
`allows gh pr create --body-file artifacts/pr_body_12.md when context exists` in
`enforce-pr-author-skill.Tests.ps1`; and `allows every registered handler for every tool name its own
matcher admits` in `codex-pretooluse-integration.Tests.ps1`. The last two are the pre-existing
ambient-state-dependent baseline failures recorded in the appendix of the [P1-T13] inventory.

## Post-correction parity and size

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `0e6fe379251c3c97efdae30f9b7aecdeb0dd767c632f0e728d25d78a4ceba856` | 444 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `0e6fe379251c3c97efdae30f9b7aecdeb0dd767c632f0e728d25d78a4ceba856` | 444 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `47cad03cc3948827aaccd945d78f04b4e9c79ab70b2709cedb53cdb033caa5d3` | 313 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `47cad03cc3948827aaccd945d78f04b4e9c79ab70b2709cedb53cdb033caa5d3` | 313 |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | `91b1e722d76b120209dea80af7a9dac272f8b202f99389a7b20dc5cbe1a6c440` | 177 |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | `91b1e722d76b120209dea80af7a9dac272f8b202f99389a7b20dc5cbe1a6c440` | 177 |

All three pairs are hash-equal and every file is under the 500-line cap. These SHA-256 values
supersede the pre-correction values recorded in the batch B12, B13, and B14 gate artifacts; the line
counts fell by 3 in each file because six wrapped lines became three.

## Batch budget reset

The correction consumed 3 production files and 0 test files in the budget window the batch B14 reset
opened, which is at the production cap and under the test cap. Resolved session id:
`worktree-agent-a478b73e41951af31-e3281c7b`, cross-checked against the single file present in
`.claude/state/`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.claude/hooks/enforce-epic-worktree-removal-gate.ps1",
    ".../.claude/hooks/enforce-parallel-worktree-removal-gate.ps1",
    ".../.codex/hooks/enforce-epic-worktree-removal-gate.ps1"
  ],
  "testFiles": []
}
```

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files, so batch B15
opens clean for Phase 9.

Output Summary: the three `--force` `Test-CommandLineFlag` call sites were joined onto one physical
line each so [P12-T15] can quote them verbatim, and the three bundle mirrors were rewritten. Format
exited 0 with a set-difference count of **0** and no rewrite; analyze returned `ok: true`, equal to
**0** diagnostics and equal to the baseline; Pester over both hook test folders reports **2245 tests,
4 failures**, unchanged in composition from the batch B14 gate once the Codex folder's documented
ambient failure is included. **AT-1 and AT-7 still PASS.** All three canonical/bundle pairs are
hash-equal and all six files are under the 500-line cap. The closing batch-budget reset exited 0.
