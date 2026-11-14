# Preflight Fixes - Issue 1034 Remediation Cycle 3

Timestamp: 2026-11-07T04-46
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T04-16.md

Single-pass preflight of the whole plan. No task was added, removed or reordered. Each fix edits text only and keeps the meaning of what is asserted.

## Method

- The design of `## Design: Reader, View and Candidate Test`, with the N14 removal, was built in a scratch copy under SCRATCH and not in the worktree.
- Head and prototype were compared over every command of Groups F4, W, F5, D, C and R, the F4 action 3 controls, and the 247 derived rows of `## Comparison Set` (110 multi-line, 56 positional, 81 payload).
- Every F4, W and F5 row differs from the prototype at head and denies on the prototype. Groups D, C and R and the controls keep their stated results. The three existing suites pass 335 of 335 on the prototype.
- A trial merge tree of `EPIC_REF` shows conflicts in the two listed paths only.

## Fixes

1. `## Integration Merge: Effect on This Item`, stale test name. The upstream side renamed the `CLI_SUITE` row. The citation now reads 'exposes the same member names as the in-memory context, the four InvokeProcess parameters and the Operation seam'.
2. `## Comparison Set`, `Listed` bullet, elided literal. The `Top-level controls` of `### F5 results` abbreviate payloads as `'...'` and a heredoc as `bash <<EOF`, which cannot run as written. The bullet now states the expansion, so a third party derives the same rows.
3. `## Comparison Set`, stand-in paragraph, host detail. `python`, `node` and `pwsh` on Windows start children through the Windows search path, which does not run an extensionless script, so an extensionless stand-in would leave the real `gh` reachable. The paragraph now requires a `.cmd` form and removes the real tools from `PATH`, which enforces its existing statement that the stand-ins touch no network or repository.
4. [P3-T6], acceptance wording conflict. `## Comparison Set` records a row with a missing interpreter as `not observed`, while the acceptance required every F5 row to be `agree`. `ksh` is absent on this host, so the row `if true; then ksh -c 'gh pr merge 12'; fi` could meet only one of the two. The acceptance now admits `not observed` under that rule. P3-T2 and P3-T7 still assert the hook's deny for the row.
5. [P1-T2], literal formatting of a command. `git diff --numstat` reports 8 deleted lines in `.claude/lib/docs/Invoke-DocsCommand.ps1` against the prior merge base. They are the whitespace-only realignment of the `New-DocsCommandContext` return table, recorded as the T11 plan deviation in `policy-audit.2026-11-07T04-16.md`. With `-w` the same check reports 0 deleted, and it still fails for any removed or changed content.
