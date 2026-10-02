# agents-skills-cite-rule-missing-from-agents-feature-review-workflow (Issue #795)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/agents-skills-cite-rule-missing-from-agents-feature-review-workflow/ (Issue #795)
- Related: #764

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #795
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/795
- Last Updated: 2026-09-30
## Summary

Two `.agents` skills cite the feature-review policy rule `modified-workflow-needs-green-run` and point readers at `.agents/skills/feature-review-workflow/SKILL.md`, but that file does not define the rule. The rule exists only in the `.claude` copy of the skill. Found during #764 preparation.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: `git grep -n modified-workflow-needs-green-run -- .agents .claude/skills`
- Data source or fixture: `.agents/skills/` and `.claude/skills/` at main ae7c7779

## Steps to Reproduce

1. Open `.agents/skills/benchmark-baselines/SKILL.md` line 39 and `.agents/skills/ci-workflows/SKILL.md` line 40. Each cites `modified-workflow-needs-green-run` and refers to `.agents/skills/feature-review-workflow/SKILL.md`.
2. Search `.agents/skills/feature-review-workflow/SKILL.md` for `modified-workflow-needs-green-run`.
3. Search `.claude/skills/feature-review-workflow/SKILL.md` for the same string.

## Expected Behavior

A rule cited by a skill is defined in the skill it references, so Codex sessions that load only `.agents` content can resolve it.

## Actual Behavior

Step 2 finds no match. Step 3 finds the rule at `.claude/skills/feature-review-workflow/SKILL.md:68` (heading `### modified-workflow-needs-green-run`). The two citing skills are `benchmark-baselines` and `ci-workflows`; the missing rule is `modified-workflow-needs-green-run`. Verified by `grep` on main at ae7c7779.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `.agents/skills/benchmark-baselines/SKILL.md:39`, `.agents/skills/ci-workflows/SKILL.md:40`. The same rule is also cited in `.claude/agents/orchestrator.md`, `.claude/rules/benchmark-baselines.md`, `.claude/rules/ci-workflows.md`, and `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, which resolve against the `.claude` copy and are not affected.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

The `.agents` copy of `feature-review-workflow` was not updated when the rule was added to the `.claude` copy. Issue #764 separately records that the `.claude` rule cites a validator script that does not exist, so the rule text should be reviewed before it is copied.

## Proposed Fix / Validation Ideas

- [ ] Add the rule to `.agents/skills/feature-review-workflow/SKILL.md`, after resolving the nonexistent-validator citation tracked in #764.
- [ ] Add a check that every rule name cited in an `.agents` skill is defined in the skill it references.
- [ ] Re-run the Codex translation or parity check if one covers this skill pair.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
