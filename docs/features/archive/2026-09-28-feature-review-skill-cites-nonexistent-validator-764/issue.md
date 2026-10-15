# feature-review-skill-cites-nonexistent-validator (Issue #764)

- Date captured: 2026-09-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/ (Issue #764)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #764
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/764
- Last Updated: 2026-09-28
- Work Mode: minor-audit

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

## Scope Consolidation (2026-09-29)

Per the 2026-09-29 comment on #764, part 2 (the `ROOT_FOLDERS` divergence) moved to #507 and is out of scope for this folder. This folder tracks only part 1: the citation of the nonexistent `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` in the feature-review skill and its bundled mirror.

Research (`research/research.2026-09-30T05-10.md`) found no implementation of the validator in the working tree or in git history (`git log -S "Test-ModifiedWorkflowNeedsGreenRun" -- scripts .claude/lib .claude/hooks` returns no commits). The selected fix is to delete the citation sentence; no new validator is created.

## Acceptance Criteria

- [x] AC-1: `.claude/skills/feature-review-workflow/SKILL.md` no longer cites `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1`; the `modified-workflow-needs-green-run` outcome bullet ends after "route it through the standard remediation handoff." and the trigger, evidence-definition, and Blocking-finding text of the rule is otherwise unchanged.
- [x] AC-2: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` receives the identical edit, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
- [x] AC-3: No file outside `docs/` cites `Test-ModifiedWorkflowNeedsGreenRun` after the change (`git grep -n "Test-ModifiedWorkflowNeedsGreenRun" -- ':!docs'` returns no matches), including the `.agents/`, `.github/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/` copies of the skill.
- [x] AC-4: No new validator script is added, and `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` and `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` pass after the change.
- [x] AC-5: The `ROOT_FOLDERS` divergence (part 2, tracked by #507) is not modified by this change: `scripts/dev_tools/push_down_claude_customizations.py` and `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` are absent from the branch diff against `origin/main`.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
