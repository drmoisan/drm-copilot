# core-pack-manifest-missing-epic-orchestrate-files (Issue #279)

- Date captured: 2026-07-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/core-pack-manifest-missing-epic-orchestrate-files/ (Issue #279)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #279
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/279
- Last Updated: 2026-07-03
- Work Mode: minor-audit

## Summary

The `core` Claude-customization pack manifest does not list the six bundled files added by the `epic-orchestrate` feature (issue #275), so any manifest-scoped "Push Down Claude Customizations" run silently omits them from the destination repository.

## Environment

- OS/version: Windows, VS Code (Insiders)
- Extension version: drm-copilot 1.0.4
- Command/flags used: "Push Down Claude Customizations" (manifest/pack-scoped selection, not the no-selection "publish everything" mode)
- Data source or fixture: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

## Steps to Reproduce

1. Merge a feature that adds new bundled `.claude/` files (agent, skill, or hook) without adding their paths to `pack-manifests/core.json` or any other pack manifest.
2. Update the drm-copilot extension to the version containing that feature.
3. Run "Push Down Claude Customizations" with an explicit pack selection (e.g. a language pack such as `python`), not the no-selection full-publish mode.
4. Inspect the destination repository's `.claude/` tree for the newly added files.

## Expected Behavior

Every bundled `.claude/` file shipped by a merged feature is available for push-down, either via an existing pack manifest or its own registration, regardless of which packs the user selects.

## Actual Behavior

`computePublishedPaths()` (`extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts`) unions only the paths explicitly listed in the selected pack manifests plus `core` when any pack is selected. Because `pack-manifests/core.json` does not list the following six files added by the epic-orchestrate feature (issue #275), they are silently dropped from any manifest-scoped push-down:

- `.claude/agents/epic-orchestrator.md`
- `.claude/skills/epic-orchestrate/SKILL.md`
- `.claude/hooks/enforce-epic-merge-gate.ps1`
- `.claude/hooks/enforce-epic-wave-barrier.ps1`
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
- `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`

Verified via direct file/manifest cross-check: all six files exist on disk under `extensions/drm-copilot/resources/claude-customizations/.claude/` but do not appear in `pack-manifests/core.json`.

This also creates a latent broken-reference risk: `.claude/settings.json` **is** listed in `core.json` and registers hook entries pointing at the four missing hook script paths above, so a manifest-scoped push-down lands a `settings.json` that references hook files absent from the destination.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: Cross-check output confirming each of the six files is `on-disk` but `MISSING-FROM-core.json`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Acceptance Criteria

- [x] AC1: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists all six paths added by the epic-orchestrate feature (issue #275): `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, inserted in the file's existing alphabetical/grouped ordering (agents together, hooks together, skills together).
- [x] AC2: `packages/mcp-server/resources/claude-customizations/pack-manifests/core.json` is not hand-edited; it remains gitignored and is regenerated from the extension's `resources/` tree by `packages/mcp-server/prepack.cjs` (`cpSync`).
- [x] AC3: A new or extended automated test reads the real bundled `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, and `.claude/hooks/*.ps1` files on disk and the real `pack-manifests/*.json` files (not a hardcoded expected-file list) and asserts that every such bundled file appears in the union of `paths` across all pack manifests.
- [x] AC4: The test in AC3 would fail against the pre-fix `core.json` (the six paths listed in AC1 are absent from every manifest before the fix), and its assertions cover those six specific paths, either directly or as a natural consequence of the completeness check.
- [x] AC5: The full TypeScript toolchain (format -> lint -> type-check -> test with coverage) passes cleanly on `extensions/drm-copilot` after the change, with no coverage regression on changed lines.

## Suspected Cause / Notes

Root cause: the epic-orchestrate feature (issue #275, PR #277) added new bundled `.claude/` resources but never updated `pack-manifests/core.json` to register them. The feature's own review passes did not catch this because no existing test asserts pack-manifest completeness against the bundled file tree.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: add the six missing paths to `pack-manifests/core.json`; add or extend a test that fails when a bundled `.claude/agents|skills|hooks` file exists on disk but is absent from every pack manifest, to prevent recurrence.
- [x] Integration scenario to retest: push-down with an explicit non-core pack selection and confirm the six files land at the destination.
- [ ] Manual verification notes: n/a — covered by automated test.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
