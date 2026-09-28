# Phase 0 — Cycle-2 Remediation Documents Read

Timestamp: 2026-09-07T20-54
Task: [P0-T2]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)
Cycle: 2 of a hard cap of 3

## Documents Read (all four, feature-folder root)

1. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-inputs.2026-09-07T20-45.md`
   — 327 lines. Cycle-2 entry inputs. Blocking count 1 (R-2). Names the root cause, the four
   instances, the required test additions per suite, the acceptance-criteria impact, and the
   "Do Not Do" list.
2. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/code-review.2026-09-07T20-45.md`
   — 178 lines. Re-audit closing cycle 1. Verdict: No-Go pending remediation of R-2. Findings table
   carries four Blocking rows (one per instance), one Medium (C-2, `rm -rfv`), two Low (C-3 orphaned
   pattern constant, C-4 the 500-line file), two Informational.
3. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/policy-audit.2026-09-07T20-45.md`
   — 506 lines. Overall verdict PARTIAL, remediation required for G-1 (the same finding as R-2).
   Records the coverage provenance (CI run `34158596238`), the toolchain substitutions used by the
   reviewer, and the per-file coverage table for the 18 changed production files.
4. `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/feature-audit.2026-09-07T20-45.md`
   — 265 lines. AC inventory of 37 items: 35 PASS, 1 FAIL (AC-09), 1 UNVERIFIED (AC-22). Blocking
   findings 1. Recommendation No-Go pending remediation of R-2.

## The Four R-2 Instance Identifiers

| Identifier | Regressing command | Fix location | Copies |
|---|---|---|---|
| **R-2.a** | `bash -c "gh pr merge --merge 688"` | `enforce-epic-merge-gate.ps1` scope filter, both runtimes | 4 (Claude + Codex, canonical + bundle) |
| **R-2.b** | `bash -c "python … --disposition abandon"` | `enforce-parallel-abandon-gate.ps1`, Claude only | 2 |
| **R-2.c** | `bash -c "gh pr edit 42 --body 'x'"` | `enforce-pr-author-skill-helpers.ps1`, Claude only | 2 |
| **R-2.d** | `bash -c "cd /x && head f"` | `validate-bash.ps1` `Get-CdChainedReadCommandMatch`, Claude only | 2 |

Shared root cause: `ConvertTo-CommandLineToken` collapses a balanced quoted span into ONE token, so
on a segment the scanner reads raw (wrapper-led, live substitution, or unbalanced) every token-based
flag read reports the flag absent. A call site that reads absence as **out of scope** fails open. A
call site that reads absence as **missing authorization** is already fail-closed and is correct.

## The Three Prohibitions This Cycle Carries

1. **No change to `Test-CommandLineFlag` or `Get-CommandLineFlagValue`.** Both iterate
   `@($resolved.Segment.Tokens)` unconditionally in `hook-command-invocation.ps1` (line 449 and
   line 400 respectively). Adding a raw-containment fallback inside either function would silently
   change every call site, including the six that are correctly fail-closed today, and would make
   `Get-CommandLineFlagValue` return a value it cannot parse from a nested command line. The fix
   belongs at the call sites. A shared helper is permitted only as a new, separately named
   predicate, which is what Edit 1 introduces as `Test-CommandLineSegmentRawScan`.
2. **No fix for follow-ups F-1 through F-7**, filed at
   `docs/features/potential/2026-09-07-issue-545-feature-review-follow-ups.md`. No task in this
   cycle addresses any of them. F-3 (the orphaned `$script:CdChainedReadCommandPattern` constant,
   also recorded as code-review finding C-3) closes incidentally through R-2.d and needs no separate
   task. Code-review C-2 (`rm -rfv`) and C-4 (the 500-line file) are follow-up candidates, not
   cycle-2 work.
3. **No attempt to fix the two ambient-state failures.** Both were independently confirmed not
   change-caused and neither reproduces on a clean CI checkout:
   - `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` It
     `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
   - `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` It
     `allows every registered handler for every tool name its own matcher admits`

## Additional constraints recorded from the documents read

- Frozen literals must not change: the six `Get-BlockedBashPattern` literals, the five
  preimplementation trigger patterns, the promotion hook's four forbidden tokens plus its two `gh`
  expressions and its `$ghApiIssuesPostPattern` declaration line,
  `$script:CdChainedReadCommandPattern` at `validate-bash.ps1` line 222, and the two abandon token
  constants at `enforce-parallel-abandon-gate.ps1` lines 41 and 42.
- Neither abandon token literal may be restated anywhere in
  `.claude/hooks/enforce-parallel-abandon-gate.ps1`, including in a comment, because
  `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` asserts a whole-file count of
  exactly 1 per token.
- Do not widen the wrapper carve-out set. AC-05 pins membership at exactly fourteen.
- Do not weaken, delete, or reverse any existing test assertion.
- Do not modify any file under `.github/instructions/` or `.claude/rules/`.
- Do not re-check AC-09 until every one of the four instances is both fixed and pinned by a
  decision-surface test on every applicable side. AC-22 closes on the PR body and is not this
  cycle's work.

## Command

Command: cat <each of the four cycle-2 review artifact paths listed above>
EXIT_CODE: 0

## Output Summary

All four cycle-2 review artifacts were located in the feature-folder root and read in full. The
blocking count is 1: R-2, with four enumerated instances sharing one root cause. The four instance
identifiers R-2.a, R-2.b, R-2.c, and R-2.d are restated above, together with the three prohibitions
this cycle carries. No document was modified.
