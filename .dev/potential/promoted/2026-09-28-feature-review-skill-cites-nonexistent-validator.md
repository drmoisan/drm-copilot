# feature-review-skill-cites-nonexistent-validator (Issue #764)

- Date captured: 2026-09-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/feature-review-skill-cites-nonexistent-validator/ (Issue #764)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #764
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/764
- Last Updated: 2026-09-28
## Summary

`.claude/skills/feature-review-workflow/SKILL.md` (rule `modified-workflow-needs-green-run`) states that "the supporting validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` implements the trigger-path and evidence-presence logic". No such file exists in the repository (`scripts/feature-review/` does not exist). Found by the skill-bundle audit for issue #762. The skill does not invoke the path, so it is not a bundling violation, but the citation is false and a reviewer that tries to run it fails.

A related divergence was observed in the same audit: the repository CLI `scripts/dev_tools/push_down_claude_customizations.py` publishes `ROOT_FOLDERS = (".claude",)`, while the extension push-down (`extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`) publishes `[".claude", "config"]`, so the two push-down paths deliver different payloads.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: feature-review of a branch that modifies `.github/workflows/**`
- Data source or fixture: `.claude/skills/feature-review-workflow/SKILL.md` line 75

## Steps to Reproduce

1. Open `.claude/skills/feature-review-workflow/SKILL.md`, section `modified-workflow-needs-green-run`.
2. Look for `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1`.
3. The file does not exist.

## Expected Behavior

Either the validator exists (and is bundled with the skill, for example under `.claude/lib/`), or the sentence is removed. The Python and TypeScript push-down paths publish the same root folders.

## Actual Behavior

The skill cites a nonexistent script; the two push-down implementations disagree on `ROOT_FOLDERS`.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `ls scripts/feature-review/` -> No such file or directory

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

The validator was likely planned in an earlier feature and never landed.

## Proposed Fix / Validation Ideas

- [ ] Remove or correct the citation.
- [ ] Align the Python `ROOT_FOLDERS` with the TypeScript constant, or document why they differ.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
