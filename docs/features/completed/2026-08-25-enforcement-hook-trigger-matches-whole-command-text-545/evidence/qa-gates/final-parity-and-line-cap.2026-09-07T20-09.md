# Final QA — Parity and Line-Cap Verification ([P4-T5])

Timestamp: 2026-09-07T20-09
Task: [P4-T5]
Anchor used: **cycle-scope anchor** `783e4b7436498fb9dba5d11df7711bd541ef28ad`

**This task uses the cycle-scope anchor, not the feature-wide anchor.** The scope question here is
"what did this remediation cycle change", and the branch already carries the entire #545 change: the
`[P0-T3]` `git diff --stat` against `6dff80ed4596bec088d548b23013e6077e32c484` named 172 paths, 63
of them `.ps1`, so a six-file scope condition anchored there would fail on every possible executor
action and verify nothing. The cycle-scope anchor is the committed head of
`bug/enforcement-hook-trigger-matches-whole-command-text-545-r3` at the start of this cycle, so a
diff against it names exactly the files this plan's tasks touched. It does **not** substitute for the
feature-wide anchor used by `[P3-T2]`: a frozen literal deleted earlier in the feature does not
appear as a removed line against the cycle-scope anchor, so that check would pass vacuously if it
were re-anchored here.

## Command 1 — Claude pair byte comparison

Command: `cmp .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
EXIT_CODE: 0
Output: (nothing printed)

## Command 2 — Codex pair byte comparison

Command: `cmp .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`
EXIT_CODE: 0
Output: (nothing printed)

Both invocations exited 0 and printed nothing, which is what a byte-identical pair produces. `cmp`
is used without `-s`, so a difference would print a diagnostic line.

## SHA-256 of all four `validate-bash.ps1` copies

| # | Copy | SHA-256 |
|---|---|---|
| 1 | `.claude/hooks/validate-bash.ps1` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` |
| 3 | `.codex/hooks/validate-bash.ps1` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` |

The two Claude copies (rows 1 and 2) are **equal to each other**. The two Codex copies (rows 3 and
4) are **equal to each other**. The Claude and Codex values differ, as expected: the two runtimes'
hooks are distinct files, not mirrors of one another.

## Command 3 — six-path line counts

Command: `wc -l .claude/hooks/validate-bash.ps1 .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1 tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`
EXIT_CODE: 0

| # | File | Final lines | `[P0-T8]` baseline | Delta | At or under 500 |
|---|---|---|---|---|---|
| 1 | `.claude/hooks/validate-bash.ps1` | **420** | 402 | +18 | yes |
| 2 | `.codex/hooks/validate-bash.ps1` | **313** | 295 | +18 | yes |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | **420** | 402 | +18 | yes |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | **313** | 295 | +18 | yes |
| 5 | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | **118** | 82 | +36 | yes |
| 6 | `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | **79** | 45 | +34 | yes |

All six counts are at or under 500. Each hook copy gained the same 18 lines — a 13-line
`.DESCRIPTION` paragraph plus its blank separator, and the 4-line second `if` in the leg-1 inner
loop.

## Command 4 — `git status --porcelain` companion

EXIT_CODE: 0. Path count: 24. Seven modified tracked paths and seventeen untracked paths, the
untracked set being sixteen evidence artifacts of this cycle (fifteen files plus the untracked
`evidence/remediation-baseline/` directory) and the untracked remediation plan. The porcelain
companion is what makes any untracked path visible; a name-listing diff enumerates tracked changes
only.

Untracked paths, none of which is a PowerShell path:

```
?? .../evidence/qa-gates/batch-a-budget-reset.2026-09-07T19-38.md
?? .../evidence/qa-gates/batch-a-pair-parity.2026-09-07T19-43.md
?? .../evidence/qa-gates/batch-a-toolchain.2026-09-07T19-47.md
?? .../evidence/qa-gates/batch-b-budget-reset.2026-09-07T19-48.md
?? .../evidence/qa-gates/batch-b-pair-parity.2026-09-07T19-52.md
?? .../evidence/qa-gates/batch-b-toolchain.2026-09-07T19-59.md
?? .../evidence/qa-gates/batch-c-budget-reset.2026-09-07T20-03.md
?? .../evidence/qa-gates/final-poshqc-analyze.2026-09-07T20-05.md
?? .../evidence/qa-gates/final-poshqc-format.2026-09-07T20-04.md
?? .../evidence/qa-gates/final-poshqc-test.2026-09-07T20-08.md
?? .../evidence/qa-gates/r2-no-code-change.2026-09-07T20-02.md
?? .../evidence/regression-testing/fail-before-r1-claude.2026-09-07T19-41.md
?? .../evidence/regression-testing/fail-before-r1-codex.2026-09-07T19-51.md
?? .../evidence/regression-testing/pass-after-r1-claude.2026-09-07T19-44.md
?? .../evidence/regression-testing/pass-after-r1-codex.2026-09-07T19-55.md
?? .../evidence/remediation-baseline/
?? .../remediation-plan.2026-09-07T17-44.md
```

All paths above are prefixed
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/`.

## Command 5 — cycle-scope changed-file list

Command: `git diff --name-only 783e4b7436498fb9dba5d11df7711bd541ef28ad`
EXIT_CODE: 0

```
.claude/hooks/validate-bash.ps1
.codex/hooks/validate-bash.ps1
docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
```

Seven paths. Six are PowerShell, and the seventh is `spec.md`, the R-2 documentation amendment.

### Scope assertion

The PowerShell paths named by the cycle-scope diff are exactly:

| # | PowerShell path | In the permitted six-file set |
|---|---|---|
| 1 | `.claude/hooks/validate-bash.ps1` | yes |
| 2 | `.codex/hooks/validate-bash.ps1` | yes |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | yes |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | yes |
| 5 | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | yes |
| 6 | `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | yes |

**No PowerShell path outside the four `validate-bash.ps1` copies and the two changed test suites
appears**, in either the tracked diff or the untracked porcelain companion. Closure is not blocked
on scope. No tenth hook was touched, no policy file under `.claude/rules/` or `.github/instructions/`
was modified, and no `.py`, `.ts`, `.json`, or `.psd1` file was changed by this cycle.

Output Summary: Both canonical/bundle pairs re-verified byte-identical — `cmp` exited 0 and printed
nothing for each, the two Claude copies share SHA-256
`6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` and the two Codex copies share
`9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012`. All six line counts are at or
under 500 (420, 313, 420, 313, 118, 79) against `[P0-T8]` baselines of 402, 295, 402, 295, 82, 45.
The cycle-scope diff plus its porcelain companion name exactly six PowerShell paths, all inside the
permitted set, plus `spec.md`.
