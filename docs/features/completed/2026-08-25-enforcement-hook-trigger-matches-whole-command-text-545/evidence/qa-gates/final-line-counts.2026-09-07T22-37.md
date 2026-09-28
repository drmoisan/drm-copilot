# Final QA — line-cap inventory

Task: `[P5-T6]`
Timestamp: 2026-09-07T22-37

Cap: 500 lines on every touched file, per standing constraint 4.

## Commands

Command (the `[P0-T11]` command, re-run verbatim):
`wc -l .claude/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-scanner.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-parallel-abandon-gate.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/validate-bash.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
EXIT_CODE: 0

Command: the same `wc -l` count over the seven bundle mirrors.
EXIT_CODE: 0

Command: the same `wc -l` count over the seven test suites edited by `[P1-T2]`, `[P2-T2]`,
`[P2-T3]`, `[P3-T2]`, `[P3-T3]`, and `[P4-T2]`.
EXIT_CODE: 0

Before-counts for the mirrors and the suites were read with
`git show 26dba29533ba70f6cd80d14ac3c87ac24ca82aca:<path> | wc -l`, the cycle-scope anchor, so the
"before" column is the state the cycle opened in rather than an inferred value. Before-counts for
the eight canonical files are the `[P0-T11]` recorded values.

## Eight canonical files (the `[P0-T11]` command)

| File | Before (`[P0-T11]`) | After | Delta | Cap |
|---|---|---|---|---|
| `.claude/hooks/hook-command-scanner.ps1` | 450 | 483 | +33 | 500 |
| `.codex/hooks/hook-command-scanner.ps1` | 450 | 483 | +33 | 500 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 472 | 486 | +14 | 500 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 174 | 186 | +12 | 500 |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 331 | 353 | +22 | 500 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 240 | 260 | +20 | 500 |
| `.claude/hooks/validate-bash.ps1` | 420 | 442 | +22 | 500 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | **500** | 0 | 500 |

`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` still reads exactly **500**,
unchanged from `[P0-T11]`. It has zero headroom, R-2 does not touch it, and no task in this plan
touched it. It does not appear in the `[P5-T4]` changed-file set.

Tightest headroom among the files this cycle edits: `.claude/hooks/enforce-epic-merge-gate.ps1` at
486, leaving 14 lines.

Recorded divergence from a plan prediction, benign: standing constraint 4 predicted 434 for
`.claude/hooks/validate-bash.ps1`, being 420 plus the 14-line code block of Edit 6. The observed
value is 442. The extra 8 lines are the remainder of Edit 6, which the plan also directs — one blank
separator after the inserted `foreach` block and the seven-line `.DESCRIPTION` extension Edit 6
requires. The 434 figure accounts for the code block only. The cap is 500, so the divergence changes
no gate.

## Seven bundle mirrors

| File | Before | After | Delta | Cap |
|---|---|---|---|---|
| `extensions/…/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | 450 | 483 | +33 | 500 |
| `extensions/…/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | 450 | 483 | +33 | 500 |
| `extensions/…/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 472 | 486 | +14 | 500 |
| `extensions/…/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 174 | 186 | +12 | 500 |
| `extensions/…/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | 331 | 353 | +22 | 500 |
| `extensions/…/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 240 | 260 | +20 | 500 |
| `extensions/…/claude-customizations/.claude/hooks/validate-bash.ps1` | 420 | 442 | +22 | 500 |

Every mirror count equals its canonical count, before and after, which is copy-set parity visible in
the line inventory as well as in the `cmp -s` and SHA-256 checks.

## Seven test suites edited by this cycle

| File | Before | After | Delta | Cap |
|---|---|---|---|---|
| `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | 347 | 387 | +40 | 500 |
| `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` | 321 | 361 | +40 | 500 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 133 | 174 | +41 | 500 |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 86 | 106 | +20 | 500 |
| `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 69 | 100 | +31 | 500 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 281 | 327 | +46 | 500 |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 118 | 147 | +29 | 500 |

## Verdict

Twenty-two files inventoried: 8 from the `[P0-T11]` command, 7 mirrors, and 7 test suites. Every
recorded count is at or under 500. No count moved except by the deltas shown, each of which is
attributable to a stated edit. The largest post-change count among the files this cycle edits is 486
and the overall largest is 500, which is
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` at its unchanged pre-existing value.

## Output Summary

All twenty-two counts are at or under the 500-line cap.
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` still reads exactly 500, unchanged
from `[P0-T11]`, confirming no task in this plan touched the file with zero headroom. Before and
after counts are recorded side by side, so every count that moved is visible rather than inferred.
The only divergence from a plan prediction is `validate-bash.ps1` at 442 rather than the predicted
434, explained above and benign against a cap of 500.

TOOLCHAIN_SUBSTITUTION: not applicable. This task runs no PowerShell toolchain stage; all commands
are `wc` and `git show` run through the Bash tool.
