# Baseline — Git State (cycle 2)

Timestamp: 2026-09-07T20-55
Task: [P0-T3]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)
Working branch: `bug/enforcement-hook-trigger-matches-whole-command-text-545-r4`

Command: git rev-parse HEAD; git merge-base --is-ancestor 26dba29533ba70f6cd80d14ac3c87ac24ca82aca HEAD; git status --porcelain; git diff --stat 6dff80ed4596bec088d548b23013e6077e32c484 -- .
EXIT_CODE: 0

## 1. `git rev-parse HEAD`

```
459d245f893f3337d61496b2602830e381d1d7a3
```

Observed value equals the required 40-character string `459d245f893f3337d61496b2602830e381d1d7a3`,
the commit that added this plan. **Acceptance check 1: PASS.**

## 2. `git merge-base --is-ancestor 26dba29533ba70f6cd80d14ac3c87ac24ca82aca HEAD`

```
EXIT_CODE: 0   (no output; the command is a predicate)
```

Exit 0 confirms the cycle-scope anchor `26dba29533ba70f6cd80d14ac3c87ac24ca82aca` is reachable from
HEAD. It is HEAD's parent. **Acceptance check 2: PASS.**

Neither check failed, so the `BLOCKED` branch of this task was not taken.

## 3. `git status --porcelain`

Line count: **3**

```
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T20-45.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/phase0-instructions-read.2026-09-07T20-52.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/phase0-remediation-documents-read.2026-09-07T20-54.md
```

All three entries are accounted for and none is drift:

- The ` M` entry is the plan file itself, modified by the `[P0-T1]` and `[P0-T2]` check-offs.
  Committing it would move HEAD and break this task's own HEAD pin, so it is deliberately left
  uncommitted.
- The two `??` entries are the `[P0-T1]` and `[P0-T2]` evidence artifacts written earlier in this
  phase.

No source file, hook, test suite, or settings file is modified at baseline.

## 4. `git diff --stat 6dff80ed4596bec088d548b23013e6077e32c484 -- .` (feature-wide anchor)

Final summary line:

```
 207 files changed, 30440 insertions(+), 350 deletions(-)
```

The feature-wide anchor `6dff80ed4596bec088d548b23013e6077e32c484` is the epic base
(`origin/epic/cleanup-merged-worktrees-hardening-integration`). This `--stat` is the whole-feature
summary. The cycle-scope anchor `26dba29533ba70f6cd80d14ac3c87ac24ca82aca` was NOT substituted here;
it is reserved for the changed-file scope assertion in `[P5-T4]`.

The count of 207 exceeds the 202 recorded by the cycle-1 exit audit at head `85a3c344` because the
audit's figure predates the five cycle-2 artifacts added since: the four `…2026-09-07T20-45.md`
review documents and the remediation plan itself. The diff also includes the uncommitted worktree
state, which at this point carries the two Phase 0 artifacts.

## Output Summary

HEAD is `459d245f893f3337d61496b2602830e381d1d7a3` as required. The cycle-scope anchor
`26dba29533ba70f6cd80d14ac3c87ac24ca82aca` is confirmed reachable from HEAD (exit 0). The working
tree carries 3 porcelain entries, all of them expected Phase 0 output plus the deliberately
uncommitted plan file; no production or test source is dirty. The feature-wide `--stat` against
`6dff80ed` reports 207 files changed, 30440 insertions, 350 deletions. Both acceptance checks pass;
execution proceeds.
