# cleanup-worktrees-dirty-triage-procedure - Plan

- **Issue:** #584
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-28T18-43
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** minor-audit

## Minimal-Audit Mode Declaration

This is a **minimal-audit** plan per `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`.

- Sole requirements source: `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/issue.md`,
  specifically its explicit `## Acceptance Criteria` section (the 10-step
  procedure, steps 1-10). No other section of `issue.md` is treated as an AC source.
- `spec.md` and `user-story.md` are NOT required for this feature. Their presence in
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/` would be an
  integrity failure under minor-audit mode; Phase 0 verifies their continued absence.
- Exactly 3 phases: Phase 0 (baseline capture), Phase 1 (constrained small-path
  implementation via cherry-pick + AC verification), Phase 2 (final QC loop).
- The sole production-file change is delivered via
  `git cherry-pick -x 00663e1151d0777e8e74d468b89bacd61c5c45b8`, not fresh authorship.
  Phase 1 verifies the resulting content against each AC step; it does not re-author or
  "improve" the cherry-picked text.
- The change is Markdown-only (`.claude/skills/cleanup-merged-worktrees/SKILL.md`); no
  test file applies and no language-specific toolchain (Python/PowerShell/TypeScript/C#)
  applies. Phase 2 still performs positive git-based verification in place of a
  format/lint/type-check/test loop, per the short-path minimal plan contract.

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- No language-specific policy applies: the sole changed file is a Markdown skill
  definition, not Python/PowerShell/TypeScript/C# source or test code.

**All work must comply with these policies; do not duplicate their content here.**

## Evidence Location

All evidence artifacts for this feature live under
`docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/<kind>/`
(`baseline/`, `qa-gates/`, `other/`) per `evidence-and-timestamp-conventions`. No
`artifacts/baselines/`, `artifacts/qa/`, or `artifacts/coverage/` paths are used anywhere
in this plan.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, and
  `.claude/rules/general-unit-test.md` in that order, and write the policy-read evidence
  artifact to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/baseline/phase0-instructions-read.2026-08-28T18-43.md`
  with fields `Timestamp:`, `Policy Order:` (numbered list of the 3 files above, in
  order), and an explicit statement that no language-specific rule file
  (`.claude/rules/python.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`,
  `.claude/rules/csharp.md`) applies because the sole in-scope file is
  `.claude/skills/cleanup-merged-worktrees/SKILL.md` (Markdown).
  - Acceptance: the artifact file exists at the path above and contains all three
    required fields plus the explicit no-language-toolchain statement.

- [x] [P0-T2] Read
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/issue.md`
  and confirm it contains an explicit `## Acceptance Criteria` heading
  line, then run
  `dir docs\features\active\2026-08-28-cleanup-worktrees-dirty-triage-procedure-584` (or
  `ls docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584`) and
  confirm the listing contains no `spec.md` and no `user-story.md`. Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/baseline/phase0-ac-source-integrity.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording (a) the
  exact line number of the `## Acceptance Criteria` heading in `issue.md`, and (b) the
  directory listing showing only `issue.md` and `plan.2026-08-28T18-43.md` present.
  - Acceptance: the artifact confirms both the heading's presence and the absence of
    `spec.md`/`user-story.md`; if either check fails, this task is marked BLOCKED, not
    complete.

- [x] [P0-T3] Run `git rev-parse HEAD` and `git status --porcelain` from the repository
  root and write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/baseline/baseline-git-state.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the HEAD
  SHA (expected `b0eaa58f6c82d27ad40fc7b327cf1401c9161549`, matching the fast-forward to
  `origin/main` performed before this plan was requested) and confirming
  `git status --porcelain` produced no output (clean working tree).
  - Acceptance: the artifact records the HEAD SHA and an empty porcelain-status output;
    a non-matching SHA or non-empty status is recorded as a discrepancy in the same
    artifact rather than silently proceeding.

- [x] [P0-T4] Run `git cat-file -t 00663e1151d0777e8e74d468b89bacd61c5c45b8` and write the
  result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/baseline/baseline-cherry-pick-source-reachable.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the literal
  output `commit`.
  - Acceptance: `EXIT_CODE: 0` and `Output Summary:` records the literal token `commit`;
    any other output blocks Phase 1 from starting.

- [x] [P0-T5] Run
  `grep -c "Dirty Worktree Triage Procedure" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  and confirm the command's own exit behavior on zero matches (grep exits 1 with no
  matches, printing `0` only under `-c` with `--include-zero`/GNU grep's `-c` default of
  printing `0`); record the printed count. Also run
  `sed -n '4,11p' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -c "^  - "`,
  `sed -n '/^## When to Use This Skill/,/^## /p' .claude/skills/cleanup-merged-worktrees/SKILL.md | sed '1d;$d' | grep -c "^- "`
  (the `sed '1d;$d'` drops the printed range's first line, which is the `## When to Use
  This Skill` heading itself, and its last line, which is the next `## ` heading that
  terminates the range — a plain `awk '/start/,/end/'` range keeps both boundary lines,
  and here the start pattern is also a valid match for the end pattern
  `/^## /`, so the naive form self-terminates on the heading line and undercounts),
  `sed -n '/^## Prohibited Shortcuts/,/^## /p' .claude/skills/cleanup-merged-worktrees/SKILL.md | sed '1d;$d' | grep -c "^- "`
  (same fix, same reason), and
  `awk '/^## Cross-References/,0' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -c "^- "`
  (unaffected — its range end is `0`, meaning "to end of file", not a second heading
  match, so it does not self-terminate), plus
  `wc -l .claude/skills/cleanup-merged-worktrees/SKILL.md`. Write all six results to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/baseline/baseline-skill-md-section-counts.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:` (one line per command), `EXIT_CODE:` (one per command),
  and `Output Summary:` recording each numeric result. Confirm the
  `"Dirty Worktree Triage Procedure"` count is `0` (the section does not yet exist),
  the allowed-tools bullet count is `6`, the "When to Use This Skill" bullet count is
  `4`, the "Prohibited Shortcuts" bullet count is `5`, the "Cross-References" bullet
  count is `3`, and the total line count is `132`.
  - Acceptance: all six baseline numbers are recorded and match the expected values
    above; a mismatch is recorded as a discrepancy and blocks Phase 1 from starting
    until reconciled.

### Phase 1 — Constrained Small-Path Implementation (Cherry-Pick + AC Verification)

- [x] [P1-T1] From the repository root, on the current branch
  (`feature/cleanup-worktrees-dirty-triage-procedure-584`), run
  `git cherry-pick -x 00663e1151d0777e8e74d468b89bacd61c5c45b8`. Do not resolve any
  reported conflict by rewriting content beyond what the cherry-pick itself proposes; a
  conflict blocks this task rather than being edited around. Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/cherry-pick-execution.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the
  command's printed summary line (e.g. the new commit SHA it reports).
  - Acceptance: `EXIT_CODE: 0` with no `CONFLICT` markers reported by the command.

- [x] [P1-T2] Run `git status --porcelain` and `git diff --name-only --diff-filter=U`
  immediately after P1-T1. Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/cherry-pick-clean-tree.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` confirming
  `git status --porcelain` shows no output and `git diff --name-only --diff-filter=U`
  lists no files (no unmerged paths remain).
  - Acceptance: both commands report a clean state; any non-empty output blocks the
    remaining Phase 1 tasks.

- [x] [P1-T3] Verify AC step 1 (re-verify current state before analyzing). Run
  `grep -n "possibly live" .claude/skills/cleanup-merged-worktrees/SKILL.md`. Write the
  result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step1.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` citing the matched
  line number(s) and the surrounding sentence, confirming it describes re-running
  `git status --porcelain` and pausing on recent worktree-index activity before treating
  a worktree as abandoned.
  - Acceptance: at least one match is found and cited by line number; a zero-match
    result is recorded as a FAIL for this step, not silently passed.

- [x] [P1-T4] Verify AC step 2 (check committed-but-unmerged commits). Run
  `grep -n "committed-but-unmerged" .claude/skills/cleanup-merged-worktrees/SKILL.md`.
  Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step2.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` citing the matched
  line number(s), confirming the surrounding text distinguishes working-tree dirt from
  committed-but-unmerged commits reachable via a `git log`-style comparison against
  `main`.
  - Acceptance: at least one match is found and cited by line number; zero matches is a
    FAIL for this step.

- [x] [P1-T5] Verify AC step 3 (determine whether equivalent content already exists on
  main, by topic not just path). Run
  `grep -n "grep broadly" .claude/skills/cleanup-merged-worktrees/SKILL.md`. Write the
  result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step3.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` citing the matched
  line number(s), confirming the surrounding text describes topic-based cross-checking
  (not solely same-path checking via `git show main:<path>`).
  - Acceptance: at least one match is found and cited by line number; zero matches is a
    FAIL for this step.

- [x] [P1-T6] Verify AC step 4 (feature-folder doc snapshots — check whether the feature
  is fully closed on main). Run
  `grep -n "fully closed" .claude/skills/cleanup-merged-worktrees/SKILL.md`. Write the
  result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step4.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` citing the matched
  line number(s), confirming the surrounding text describes diffing an already-closed
  feature's draft against main rather than assuming supersession.
  - Acceptance: at least one match is found and cited by line number; zero matches is a
    FAIL for this step.

- [x] [P1-T7] Verify AC step 5 (four-way classification of non-superseded content). Run
  `grep -n "DEAD_ONE_OFF" .claude/skills/cleanup-merged-worktrees/SKILL.md`,
  `grep -n "ALREADY_SOLVED_ELSEWHERE" .claude/skills/cleanup-merged-worktrees/SKILL.md`,
  `grep -n "STALE_OR_CONTRADICTED" .claude/skills/cleanup-merged-worktrees/SKILL.md`, and
  `grep -n "GENUINELY_NEW" .claude/skills/cleanup-merged-worktrees/SKILL.md`. Write the
  result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step5.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:` (one line per command), `EXIT_CODE:` (one per command),
  and `Output Summary:` citing the matched line number for each of the four labels.
  - Acceptance: all four labels are found with a cited line number each; any label with
    zero matches is a FAIL for this step (partial matches do not pass).

- [x] [P1-T8] Verify AC step 6 (handle non-memory dirty content, e.g. stale build
  artifacts). Run
  `grep -n "packages.config" .claude/skills/cleanup-merged-worktrees/SKILL.md`. Write
  the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step6.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` citing the matched
  line number(s), confirming the surrounding text describes diffing a representative
  sample of non-documentation dirty content (e.g. stale build-artifact files) against
  main before treating it as disposable.
  - Acceptance: at least one match is found and cited by line number; zero matches is a
    FAIL for this step.

- [x] [P1-T9] Verify AC step 7 (recognize orphaned non-worktree directories). Run
  `grep -n "misfire" .claude/skills/cleanup-merged-worktrees/SKILL.md`. Write the result
  to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step7.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` citing the matched
  line number(s), confirming the surrounding text describes plain filesystem removal
  (not `git worktree remove`) for orphaned, no-longer-registered worktree directories.
  - Acceptance: at least one match is found and cited by line number; zero matches is a
    FAIL for this step.

- [x] [P1-T10] Verify AC step 8 (parallelize the triage, structured verdicts). Run
  `grep -n "SAFE_TO_DELETE" .claude/skills/cleanup-merged-worktrees/SKILL.md`. Write the
  result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step8.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` citing the matched
  line number(s), confirming the surrounding text describes fanning out concurrent,
  per-worktree investigation passes that each return a structured
  `SAFE_TO_DELETE`/`PRESERVE`-style verdict with citations.
  - Acceptance: at least one match is found and cited by line number; zero matches is a
    FAIL for this step.

- [x] [P1-T11] Verify AC step 9 (route PRESERVE findings through consolidation, or
  promote to a follow-up issue). Run
  `grep -n "PRESERVE" .claude/skills/cleanup-merged-worktrees/SKILL.md` and
  `grep -n "follow-up issue" .claude/skills/cleanup-merged-worktrees/SKILL.md`. Write the
  result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step9.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:` (one line per command), `EXIT_CODE:` (one per command),
  and `Output Summary:` citing matched line numbers for both, confirming the surrounding
  text distinguishes routing process-lesson `PRESERVE` findings through the
  `documentationandmemories` consolidation flow from promoting unresolved product-scope
  findings to a real follow-up issue.
  - Acceptance: both tokens are found with cited line numbers; zero matches on either is
    a FAIL for this step.

- [x] [P1-T12] Verify AC step 10 (post-apply origin-branch follow-up, confirmed
  manually). Run `grep -n "post-prune" .claude/skills/cleanup-merged-worktrees/SKILL.md`.
  Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-step10.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` citing the matched
  line number(s), confirming the surrounding text describes an explicit,
  user-confirmed follow-up step diffing deleted local branches against `git branch -r`
  after `--apply` completes.
  - Acceptance: at least one match is found and cited by line number; zero matches is a
    FAIL for this step.

- [x] [P1-T13] Verify the new section heading and its forward-pointer both exist. Run
  `grep -c "Dirty Worktree Triage Procedure" .claude/skills/cleanup-merged-worktrees/SKILL.md`
  and `grep -n "Dirty Worktree Triage Procedure" .claude/skills/cleanup-merged-worktrees/SKILL.md`.
  Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-heading-and-forward-pointer.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:` (one line per command), `EXIT_CODE:` (one per command),
  and `Output Summary:` recording the total occurrence count and each matched line
  number, confirming the count is at least `2` — one occurrence as the new `##` section
  heading, and at least one more occurrence as a forward-pointer added to step 6 of the
  existing "End-to-End Workflow" section.
  - Acceptance: total occurrence count is `>= 2` with each occurrence's line number
    cited and classified (heading vs. forward-pointer); a count of `0` or `1` is a FAIL.

- [x] [P1-T14] Verify the frontmatter `allowed-tools` list grew relative to the P0-T5
  baseline of `6`. Run
  `sed -n '4,20p' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -c "^  - "`
  (adjust the upper line bound if the frontmatter closing `---` moved; confirm the bound
  by first running `grep -n "^---$" .claude/skills/cleanup-merged-worktrees/SKILL.md` to
  locate the second `---` line). Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-frontmatter-tools-count.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:` (both commands), `EXIT_CODE:` (both), and
  `Output Summary:` recording the new count and confirming it is strictly greater than
  the P0-T5 baseline of `6`.
  - Acceptance: new count `> 6`; a count of `6` or less is a FAIL.

- [x] [P1-T15] Verify the "When to Use This Skill" bullet count increased by exactly `1`
  relative to the P0-T5 baseline of `4`. Run
  `awk '/^## When to Use This Skill/,/^## /' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -c "^- "`.
  Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-when-to-use-count.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the new
  count and confirming it equals `5`.
  - Acceptance: new count `== 5`; any other value is a FAIL.

- [x] [P1-T16] Verify the "Prohibited Shortcuts" bullet count increased by exactly `1`
  relative to the P0-T5 baseline of `5`. Run
  `sed -n '/^## Prohibited Shortcuts/,/^## /p' .claude/skills/cleanup-merged-worktrees/SKILL.md | sed '1d;$d' | grep -c "^- "`
  (the P0-T5 fixed form; the naive `awk '/start/,/end/'` form self-terminates on the
  heading line and must not be used here). The net growth is `+1` rather than the `+2`
  originally expected, because the cherry-picked commit expands one existing bullet (the
  `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS` exclusion, to additionally cover the new triage
  verdict) rather than adding a fully separate second new bullet; this is confirmed
  correct, already-authored content and is not a defect to fix in
  `.claude/skills/cleanup-merged-worktrees/SKILL.md`. Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-prohibited-shortcuts-count.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the new
  count and confirming it equals `6`.
  - Acceptance: new count `== 6`; any other value is a FAIL.

- [x] [P1-T17] Verify the "Cross-References" bullet count increased by exactly `1`
  relative to the P0-T5 baseline of `3`. Run
  `awk '/^## Cross-References/,0' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -c "^- "`.
  Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-cross-references-count.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the new
  count and confirming it equals `4`.
  - Acceptance: new count `== 4`; any other value is a FAIL.

- [x] [P1-T18] Verify the pre-existing deterministic classification/refusal behavior
  wording was not altered by the cherry-pick. Run
  `grep -c "BLOCKED-DIRTY" .claude/skills/cleanup-merged-worktrees/SKILL.md`,
  `grep -c "NOT_MERGED" .claude/skills/cleanup-merged-worktrees/SKILL.md`, and
  `grep -c "HAS_UNIQUE_RESIDUALS" .claude/skills/cleanup-merged-worktrees/SKILL.md`.
  Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/other/ac-verify-existing-terms-unchanged.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:` (one line per command), `EXIT_CODE:` (one per command),
  and `Output Summary:` recording each count, confirming all three terms are still
  present at least once (the cherry-pick added consistency-fix references to them rather
  than removing the originals).
  - Acceptance: all three counts are `>= 1`; a `0` count for any term is a FAIL and
    indicates the cherry-pick altered existing behavior description, which is out of
    scope per the "Constraints & Risks" section of `issue.md`.

### Phase 2 — Final QC Loop

- [x] [P2-T1] Confirm no language-specific toolchain applies to this change. Run
  `git diff --stat main...HEAD -- .claude/skills/cleanup-merged-worktrees/SKILL.md` and
  confirm the only path listed is `.claude/skills/cleanup-merged-worktrees/SKILL.md`
  (extension `.md`). Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/qa-gates/final-qc-toolchain-applicability.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the listed
  path and explicitly stating that no Python/PowerShell/TypeScript/C# format, lint,
  type-check, or test command applies because `.claude/rules/python.md`,
  `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, and
  `.claude/rules/csharp.md` scope only to their respective file extensions, none of which
  match `.md`.
  - Acceptance: the artifact exists and records the affirmative determination above; this
    is a positive command-based finding, not a `SKIPPED` task.

- [x] [P2-T2] Run `git status --porcelain -- .claude` and confirm the output is empty
  (zero lines). Because `[P1-T1]`'s `git cherry-pick -x` creates a commit directly, the
  change to `.claude/skills/cleanup-merged-worktrees/SKILL.md` is already committed by
  Phase 2, so `git status --porcelain -- .claude` correctly reports no modified-tracked-
  file line for it; `[P2-T4]`'s ref-anchored `git diff --stat main...HEAD -- .claude/skills/cleanup-merged-worktrees/SKILL.md`
  is the task that confirms the change actually landed in commit history. Write the
  result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/qa-gates/final-qc-claude-scope-status.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the empty
  output.
  - Acceptance: output is exactly empty (zero lines); any line under `.claude` (for
    example an uncommitted stray modification) is a FAIL.

- [x] [P2-T3] Run `git status --porcelain` and confirm (a) zero lines carry a
  modified/added/deleted/renamed status code for a tracked file (no line starting with
  ` M`, `M `, `A `, ` A`, `D `, ` D`, `R `, or `AM`/`MM`-style combinations), and (b)
  every remaining line matches exactly one of these five pre-existing untracked entries,
  already documented as non-blocking in `[P0-T3]`/`[P1-T2]`:
  `?? claude-session.stderr.log`, `?? claude-session.stdout.log`,
  `?? docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/`
  (this feature's own folder, including the evidence artifacts this plan creates),
  `?? docs/features/potential/promoted/2026-08-28-cleanup-worktrees-dirty-triage-procedure.md`,
  and `?? orchestration-kickoff.md`. Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/qa-gates/final-qc-full-repo-status.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the full
  output classified line-by-line against the two conditions above.
  - Acceptance: zero modified-tracked-file lines, and every remaining line is one of the
    five permitted untracked entries listed above (no `scripts/bash/**` change and no
    other unintended file, tracked or untracked, appears); any other line is a FAIL.

- [x] [P2-T4] Run
  `git diff --stat main...HEAD -- .claude/skills/cleanup-merged-worktrees/SKILL.md` and
  confirm the summary line reports `1 file changed, 136 insertions(+), 4 deletions(-)`.
  Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/qa-gates/final-qc-diff-shape.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the exact
  summary line printed.
  - Acceptance: the printed summary line matches
    `1 file changed, 136 insertions(+), 4 deletions(-)` exactly; any other insertion or
    deletion count is a FAIL and is reported rather than rationalized away.

- [x] [P2-T5] Run `wc -l .claude/skills/cleanup-merged-worktrees/SKILL.md` and confirm
  the resulting line count is `132 + 136 - 4 = 264`. Write the result to
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/qa-gates/final-qc-line-count.2026-08-28T18-43.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the printed
  line count and confirming it equals `264`.
  - Acceptance: line count `== 264`; any other value is a FAIL.

- [x] [P2-T6] Compile a final AC-checkoff summary evidence artifact at
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/qa-gates/final-qc-ac-checkoff-summary.2026-08-28T18-43.md`
  listing, for each of the 10 AC steps in `issue.md`, the corresponding Phase 1
  verification artifact path (P1-T3 through P1-T12) and its PASS/FAIL outcome, plus the
  Phase 1 section/frontmatter/existing-terms verification outcomes (P1-T13 through
  P1-T18). This artifact does not modify `issue.md` itself; checklist state in `issue.md`
  is reconciled separately by the feature-review/policy-audit stage against this
  evidence trail.
  - Acceptance: the artifact lists all 16 Phase 1 verification tasks (P1-T3 through
    P1-T18) with an explicit PASS or FAIL per task and a path to its underlying evidence
    artifact; the overall final-QC outcome is PASS only if every listed task is PASS.

## Test Plan

- Unit: N/A — Markdown-only skill-definition change; no executable code is introduced or
  modified.
- Integration: N/A — no runtime behavior change to `scripts/bash/cleanup-worktrees.sh` or
  its libraries; Phase 2 (P2-T2, P2-T3) positively confirms those scripts are untouched.
- Manual/CLI: Phase 1 (P1-T3 through P1-T18) performs grep/awk-based content verification
  of the cherry-picked `SKILL.md` against each of the 10 `issue.md` AC steps plus the
  supporting frontmatter/section changes.
- Coverage evidence: N/A — no language with a mandatory coverage policy is touched by
  this change.

## Open Questions / Notes

- The cherry-pick source commit `00663e1151d0777e8e74d468b89bacd61c5c45b8` is reachable
  only via the shared local git object database (confirmed via `git cat-file -t` in
  P0-T4); it is not reachable from any branch visible in this worktree and was never
  pushed to a remote. If P0-T4 fails (object not found), Phase 1 cannot proceed and this
  plan must be revised with an alternate delivery mechanism.
- All grep-based tokens used in Phase 1 (`possibly live`, `committed-but-unmerged`,
  `grep broadly`, `fully closed`, `DEAD_ONE_OFF`, `ALREADY_SOLVED_ELSEWHERE`,
  `STALE_OR_CONTRADICTED`, `GENUINELY_NEW`, `packages.config`, `misfire`,
  `SAFE_TO_DELETE`, `PRESERVE`, `follow-up issue`, `post-prune`,
  `Dirty Worktree Triage Procedure`, `BLOCKED-DIRTY`) are quoted verbatim in this plan
  and are drawn directly from `issue.md`'s AC prose or from the explicit "Note for
  feature-review / AC checkoff" paragraph in `issue.md`, which the same author wrote to
  describe the actual content of the target commit. `BLOCKED-DIRTY` is confirmed absent
  from the baseline file (verified by direct search of
  `.claude/skills/cleanup-merged-worktrees/SKILL.md` during plan authoring), so it is a
  literal the cherry-pick is expected to introduce, not pre-existing content; `NOT_MERGED`
  and `HAS_UNIQUE_RESIDUALS` (P1-T18) are pre-existing baseline literals (already present
  in the `Report Line Contract` and `When to Use This Skill` sections) and are asserted
  as unchanged-content checks rather than newly-created-content checks.
