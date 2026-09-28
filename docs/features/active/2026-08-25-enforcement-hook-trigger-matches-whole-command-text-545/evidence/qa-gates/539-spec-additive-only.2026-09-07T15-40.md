# [P11-T6] Issue #539 spec annotation — additive-only inspection

Timestamp: 2026-09-07T15-40

Command: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md`

EXIT_CODE: 0

## Output Summary

The diff for the issue #539 specification contains four hunks and no other change. Counting body lines only (hunk headers excluded), the diff carries 5 added lines and 3 removed lines. All three removed lines are markdown table rows that were re-emitted on the same line with appended text; each row's original cell text is preserved verbatim inside its replacement. The remaining two additions are pure insertions of new lines. No line was deleted outright and no line's original text was altered, rewritten, or reordered.

Result: **the hunk set contains additions only**, with no deleted or modified line other than a table row extended by appended text on the same line.

### The five annotated locations

| # | Task | Location in `539/spec.md` | Form of the annotation |
| --- | --- | --- | --- |
| 1 | [P11-T1] | `### D4 — Normative fail-closed rule table`, rule row `14` (`Anything between the command name and the subcommand`) — post-change line 128 | Same-line append inside the Rule cell |
| 2 | [P11-T2] | Post-fix decision table, the `allow-by-non-match` row (`bare git -C ../x add docs/... / --git-dir / --work-tree where the trigger regex does not match the line`) — post-change line 150 | Same-line append inside the Decision cell |
| 3 | [P11-T3] | Post-fix decision table, the heredoc row (`Heredoc/message body containing the literal git add`) — post-change line 153 | Same-line append inside the Decision cell |
| 4 | [P11-T4] | `### D8 — Whole-command-text over-match: out of scope, with reason` — new paragraph inserted after post-change line 186 | Pure insertion (new paragraph plus blank line) |
| 5 | [P11-T5] | `## Rollout & Follow-up`, the `Known deferrals recorded, not fixed here:` bullet — new nested sub-bullet inserted after post-change line 280 | Pure insertion (new nested bullet) |

### Hunk-by-hunk accounting

| Hunk header | Added body lines | Removed body lines | Classification |
| --- | --- | --- | --- |
| `@@ -125,7 +125,7 @@` | 1 | 1 | Table row 14 extended on the same line; original text preserved verbatim as the leading portion of the cell |
| `@@ -147,10 +147,10 @@` | 2 | 2 | Two decision-table rows extended on the same line; original decision text preserved verbatim as the leading portion of each cell |
| `@@ -185,6 +185,8 @@` | 2 | 0 | Pure insertion: the D8 supersession paragraph and its preceding blank line |
| `@@ -276,4 +278,5 @@` | 1 | 0 | Pure insertion: the nested sub-bullet under the known-deferrals bullet |
| **Total** | **5** | **3** | additions only, per the criterion above |

### Verification commands and their observed results

- `grep -c '^@@' <diff>` -> `4` hunks.
- `grep -c '^+[^+]' <diff>` -> `5` added body lines.
- `grep -c '^-[^-]' <diff>` -> `3` removed body lines.
- `grep -n '^-[^-]' <diff>` -> the three removed lines are the D4 row 14 line, the `allow-by-non-match` row line, and the heredoc row line, and no others.

### Scope note

No file other than `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md` appears in this diff, because the diff is path-restricted to that file. No hook, rule file, or instruction file was touched by Phase 11.

TOOLCHAIN_SUBSTITUTION: not applicable. This task runs `git` only; no PowerShell toolchain stage is invoked.
