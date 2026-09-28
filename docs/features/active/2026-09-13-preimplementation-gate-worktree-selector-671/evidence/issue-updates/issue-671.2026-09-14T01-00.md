# POSTING BLOCKED — Issue #671 Update Mirror

Timestamp: 2026-09-17T08-32
Task: [P7-T2]
PostedAs: unknown
Reason not posted: the executor was instructed not to commit or push, and issue updates belong to the orchestrator. This file holds the exact text intended for issue #671.

---

## Intended update text

**Status: implementation landed on the feature branch; 3 of 24 acceptance criteria remain open pending a plan and spec revision.**

### Change

The issue #539 staging exemption now accepts one repository selector between `git` and the subcommand, under the Lexical Absolute-Canonical Selector (LACS) rule, conditions L1-L8. `git -C <absolute-worktree-root> add|commit ... <exempt-pathspec>` is exempt. Relative, `.`/`..`-bearing, UNC, repeated, attached, globbed, and colon-bearing selectors are still denied. Everything after the subcommand is unchanged, and the helpers module stays pure string logic.

- New constant `$script:OrchestrationSelectorOptionName`, new predicate `Test-ExemptOrchestrationSelector` (six `Write-Debug` diagnostic tokens), and a selector absorption in the prologue of `Test-ExemptOrchestrationSegmentToken`. An `Accepted widening` comment records the nested-subdirectory escape: seven Markdown test fixtures under the `resolve_execute_plan_prompt` fixture tree.
- Applied identically on four surfaces: `.claude/hooks/`, `.codex/hooks/`, and both bundled payload trees. All four copies share SHA256 `5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1` and are 433 lines each.
- The gate files, modes files, and `hook-command-invocation.ps1` are byte-unchanged (empty `git diff --merge-base main`).

### Executed evidence

- Fail-before (executed): `git -C C:/some/worktree add|commit ...` returned `False`.
- Pass-after (executed): the same rows returned `True`, and all other rows were unchanged.
- New parity suite: the SHA256 identity and 500-line cap across the four helpers copies both pass.
- Retained guards: 45 D4 deny rows and 8 allow rows per suite pass, with zero assertion reversals.
- Coverage: repository line coverage is 95.41% (baseline 95.48%); canonical helpers per-file coverage is 92.72%; changed-line coverage is 29/33 instrumented lines (87.88%).
- Analyzer: 0 findings on the four helpers copies and the three test files.

### Open items (require a plan and spec revision)

1. Spec rows `LACS L3a` (`git -C C:/repo/wt`) and `LACS L3b` (`git -C C:/repo/wt -- ...`) carry no `add`/`commit`, so the gate trigger never classifies them and the gate allows them whatever the exemption does. The new predicate rejects both, but the gate-level deny assertions fail in both suites.
2. Spec row `LACS L8` (`git -C "" ...`) exposes a **pre-existing fail-open**. An empty quoted token fails parameter binding at helpers line 221 (no `[AllowEmptyString()]`). Under the default `Continue` preference, that error ends only the enclosing `if` statement, and `Test-ExemptOrchestrationStagingCommand` returns `True`. Confirmed at gate level with a not-ready checkpoint: `git commit -m "" -- src/foo.ts` and `git add -- src/foo.ts ""` both return **allow**. The plan does not permit editing line 221.
3. As a result of items 1 and 2, the full PowerShell test step reports 6 attributable failures (3 per suite), so the single-pass toolchain criterion and the changed-line coverage criterion remain open.
