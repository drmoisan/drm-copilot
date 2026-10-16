# codex-ci-green-gate-parity-and-parser-uncovered-line (Issue #891)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-ci-green-gate-parity-and-parser-uncovered-line/ (Issue #891)
- Origin: issue #841 (PR #877), spec follow-up candidates and code-review Info rows; parallel run bug-burndown-2026-10-08

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #891
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/891
- Last Updated: 2026-10-11
## Summary

Issue #841 fixed the vacuous CI gate (an empty check list read as green) and added the epic-child rule and `-RequireWorkflow CI` to the Claude orchestrate skill's S9 CI Green Gate. The Codex orchestrate skill `.agents/skills/orchestrate/SKILL.md` and its bundled mirror did not receive the same change, so a Codex-run orchestration can still treat an epic-child PR with no checks as green. Separately, one executable line of `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` has been uncovered since before #841.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: Codex orchestrate S9 CI Green Gate; Pester coverage for `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
- Data source or fixture: main at 2ef8d361

## Steps to Reproduce

1. Read `.agents/skills/orchestrate/SKILL.md:453-458` (`## CI Green Gate`).
2. Compare with `.claude/skills/orchestrate/SKILL.md:294` (epic-child rule) and `:296` (`-RequireWorkflow CI`).
3. Run the Pester coverage for `Invoke-CiGateParser.ps1` and read the uncovered lines.

## Expected Behavior

- Both orchestrate surfaces apply the same CI Green Gate rules, including the epic-child guard and the required-workflow check through `Invoke-CiGateParser`.
- `Invoke-CiGateParser.ps1` has no uncovered executable lines, or the remaining line is tested through the injected clock.

## Actual Behavior

- `.agents/skills/orchestrate/SKILL.md:453-458` says only "observe the live PR head SHA and required GitHub checks"; it contains no `-RequireWorkflow`, no epic-child rule and no reference to `Invoke-CiGateParser`. The bundled mirror `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md:453` is identical.
- `.claude/lib/ci-gate/Invoke-CiGateParser.ps1:338`: `[ScriptBlock]$NowProvider = { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') },` is the only uncovered executable line (97.83% file coverage); it was uncovered at baseline (then line 270). A similar default appears at script level on line 104; its coverage was not recorded.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/code-review.2026-10-10T09-52.md:30`: "Codex S9 (`.agents/skills/orchestrate/SKILL.md`) still lacks the epic-child guard; recorded in the spec as a follow-up candidate, explicitly out of scope."
- Snippet: `spec.md:58`: "Codex parity for CR-1 in `.agents/skills/orchestrate/SKILL.md` (its CI Green Gate does not reference the parser; follow-up candidate)." Also `spec.md:253`, `:258-260`.
- Snippet: `code-review.2026-10-10T09-52.md:44`: "The default `$NowProvider` delegate in the `Invoke-CiGateParser` param block is the only uncovered executable line (97.83% file coverage). It was uncovered at baseline (line 270)."
- PR #877 states "Follow-ups: None recorded in the PR context", so neither item is tracked elsewhere.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. The Codex surface retains the defect #841 fixed for Claude: an epic-child PR (which gets no CI under `ci.yml` triggers) can be reported green. The uncovered line is Low on its own.

## Suspected Cause / Notes

- #841 scoped the change to the Claude surface; Codex parity was listed as a follow-up candidate but not filed.
- The uncovered line is the production default of an injected clock; tests always pass their own provider.

## Proposed Fix / Validation Ideas

- [ ] Port the epic-child rule and the `Invoke-CiGateParser -RequireWorkflow CI` step into `.agents/skills/orchestrate/SKILL.md` and its bundled mirror.
- [ ] Unit coverage areas: a contract test asserting both orchestrate surfaces reference the parser and the epic-child rule; a Pester case that invokes `Invoke-CiGateParser` without `-NowProvider` and asserts an ISO-8601 UTC timestamp format.
- [ ] Integration scenario to retest: a Codex-run orchestration against an epic-child PR with zero checks reports not-green.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch