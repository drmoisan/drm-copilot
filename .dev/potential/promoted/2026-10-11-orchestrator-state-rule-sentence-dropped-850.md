# orchestrator-state-rule-sentence-dropped-850 (Issue #898)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestrator-state-rule-sentence-dropped-850/ (Issue #898)
- Origin: issue #850 (PR #857), epic #852 enforcement-hook-precision, wave 1; plan decision D4

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #898
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/898
- Last Updated: 2026-10-11
## Summary

The #850 spec included a one-sentence documentation alignment in `.claude/rules/orchestrator-state.md` stating which per-feature checkpoint the merge gate consults for an explicit pull request number. The plan dropped it because the file is a policy document that agents may not modify without operator approval. The sentence is absent on main, and the #850 spec's risk mitigation still claims "`orchestrator-state.md` updated". An operator decision is needed.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: n/a (documentation)
- Data source or fixture: main at 2ef8d361; `.claude/rules/orchestrator-state.md` and its mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`

## Steps to Reproduce

1. Read `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md:48` and `research/research.2026-10-08T14-00.md:354`.
2. Search `.claude/rules/orchestrator-state.md` and its bundled mirror for the described content ("live worktree", "records that number").
3. Read `.claude/rules/orchestrator-state.md:238`.

## Expected Behavior

`.claude/rules/orchestrator-state.md` documents the #850 merge-gate behavior for an explicit pull request number, or the #850 spec records that the alignment was not made.

## Actual Behavior

- The search returns no match in either copy; no #850 commit touches the rule file (its last commits are 60603c277 for #849, 16909c7a5 for #798 and 2114d13d8 for #484).
- The nearest existing text, `orchestrator-state.md:238`, covers only standalone authorizations: "The gate consults the array only for a `gh pr merge --merge` command that names an explicit pull request number..." It does not say which worktree's checkpoint is read.
- `spec.md:284` says "Mitigation: documented as an accepted behavior change with its remedy; `orchestrator-state.md` updated." This is inaccurate.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- The spec does not contain a verbatim draft of the sentence. The intended content, quoted verbatim from the sources:
  - `spec.md:48`: "Documentation alignment: `.claude/rules/orchestrator-state.md` (one sentence stating which per-feature checkpoint the merge gate consults for an explicit pull request number) and the pr-author handoff text in `.claude/skills/orchestrate/SKILL.md` ... with their bundled mirrors."
  - `research/research.2026-10-08T14-00.md:354`: "`.claude/rules/orchestrator-state.md` (and its bundle mirror): one sentence stating that, for an explicit PR number, the per-feature checkpoint consulted by the merge gate is the live worktree whose checkpoint records that number in `pr_gate.pr_number` or a `standalone_merge_authorizations` entry."
- Where it was dropped: `plan.2026-10-08T13-54.md:85`: "**D4 — `.claude/rules/orchestrator-state.md` is not edited.** The file is a policy document under `.claude/rules/`, and the policy-compliance hard constraint prohibits modifying those documents. ... The epic orchestrator should obtain an explicit user decision before any edit to that file." Also `policy-audit.2026-10-09T01-12.md:161` (Gap G-4) and PR #857 body: "The spec lists a one-sentence alignment to `.claude/rules/orchestrator-state.md` as in scope. **It was not applied.**"

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low. Runtime behavior is correct; the rule file omits how the merge gate selects the checkpoint for an explicit PR number, which affects operators diagnosing a merge-gate denial.

## Suspected Cause / Notes

- The policy-compliance constraint correctly prevented an agent edit; no follow-up was filed to obtain the operator decision.

## Proposed Fix / Validation Ideas

- [ ] Operator decision: approve adding the research.md:354 sentence (adjusted as needed) to `.claude/rules/orchestrator-state.md` and its bundled mirror, or decline.
- [ ] If approved, apply the edit to both copies and keep the bundle byte-parity test green.
- [ ] Correct `spec.md:284` of the #850 folder to state the actual outcome.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch