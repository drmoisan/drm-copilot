# Phase 0 — policy instruction reads (remediation cycle 1)

Timestamp: 2026-09-17T13-56

Task: `[P0-T1]` of `remediation-plan.2026-09-17T12-29.md`
Plan hash at dispatch: `86984a68e0f4acf484fcfc5c81c03640288d0d49`

Policy Order: the order defined by `.claude/skills/policy-compliance-order/SKILL.md`, extended by the
two repository-specific rule files this plan names. The seven paths were read in the listed order, each
resolved under the worktree root
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-accbbbab931643b40`.

Files read, one per line, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/tonality.md`
7. `.claude/rules/plan-acceptance-gates.md`

Read mechanism, recorded so a third party can re-verify:

- Paths 1, 2, 3, 5, and 6 were delivered verbatim into the executing session's context by the Claude Code
  standing-instruction loader, which loads `CLAUDE.md` and the path-scoped `.claude/rules/*.md` files whose
  `paths:` frontmatter matches the files in scope. Their full text was present in context before any task ran.
- Paths 4 and 7 were read explicitly with the `Read` tool in this task, because their `paths:` frontmatter did
  not cause an automatic load at session start.
- All seven paths were confirmed tracked with
  `git -C <worktree> ls-files -- CLAUDE.md .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/rules/powershell.md .claude/rules/quality-tiers.md .claude/rules/tonality.md .claude/rules/plan-acceptance-gates.md`,
  which returned all seven paths (EXIT_CODE 0).

Binding constraints carried forward from the reads into the remainder of this plan:

- `.claude/rules/general-code-change.md`: 500-line cap on any production, test, or reusable script file.
  Binds `[P1-T8]` and `[P2-T7]`.
- `.claude/rules/powershell.md` line 17: type checking is not applicable to PowerShell. This is why Phase 4
  carries no type-check step.
- `.claude/rules/powershell.md` line 40: per-batch cap of 3 production files and 3 test files. Binds the
  R-A / R-B / R-C batch split.
- `.claude/rules/powershell.md` line 64 and `.claude/rules/quality-tiers.md`: line coverage >= 85 percent
  uniform across tiers; Pester measures no branch coverage, so no branch figure is recorded anywhere in this
  remediation.
- `.claude/rules/general-unit-test.md`: no external dependency and no temporary file in a unit test. This is
  the rule that requires `[P1-T4]` and `[P1-T5]` to model the derivation rather than let the sibling suites
  reach the real filesystem after the pre-filter is removed.
- `.claude/rules/tonality.md`: professional, factual, neutral tone in every artifact this plan writes.
- `.claude/rules/plan-acceptance-gates.md`: gates G1 through G9, and the two classes no rule reaches — the
  general unobservable-success-output class and the task-ordering class. Both are the reason this plan's
  acceptance conditions are anchored to named console literals, JUnit node names, and paired tree captures.

Acceptance: the artifact exists and carries the field labels `Timestamp:`, `Policy Order:`, and an explicit
line-per-file list of the seven paths read. All three are present above.
