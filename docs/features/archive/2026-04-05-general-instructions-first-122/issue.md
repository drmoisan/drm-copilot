# general-instructions-first (Issue #122)

- Date captured: 2026-04-05
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/general-instructions-first/ (Issue #122)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #122
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/122
- Last Updated: 2026-04-05T13-27
- Work Mode: minor-audit

## Summary

The bundled `drm-copilot: Sync AGENTS.md from Instructions` command does not guarantee that instruction files whose names begin with `general` are emitted before language-specific instruction sections in the generated `AGENTS.md`. The generated order should place the general instruction files first so the consolidated guidance matches the repository policy precedence.

## Environment

- OS/version: Windows 11 / VS Code Insiders
- PowerShell version: 7.x
- Command/flags used: `drm-copilot: Sync AGENTS.md from Instructions`
- Data source or fixture: repository `.github/instructions/*.instructions.md` files

## Steps to Reproduce

1. Run `drm-copilot: Sync AGENTS.md from Instructions` in the repo.
2. Inspect the generated `AGENTS.md` source-file order and the corresponding section order.
3. Observe that general instruction files are not consistently grouped ahead of language-specific instruction files.

## Expected Behavior

Any discovered instruction files whose basenames begin with `general` should appear before language-specific instruction files in the generated `AGENTS.md` output, while preserving deterministic ordering within each group.

## Actual Behavior

The sync output does not enforce the required precedence for `general*.instructions.md` files relative to language-specific instruction files.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: Compare the generated order of `general-code-change.instructions.md` and `general-unit-test.instructions.md` against language-specific sections such as Python, PowerShell, C#, and TypeScript.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

- The sync script likely relies on simple path ordering instead of a grouping rule for `general*` basenames.
- The root script and bundled template must stay byte-identical after the fix.
- Pester coverage should lock in the required ordering behavior.

## Proposed Fix / Validation Ideas

- [x] Update the sync ordering logic so `general*.instructions.md` files sort before language-specific instruction files.
- [x] Add or update Pester tests that verify the grouped ordering contract.
- [x] Keep the bundled template mirror in sync with the root script.
- [x] Regenerate `AGENTS.md` and verify the output order reflects the new precedence.

## Acceptance Criteria

- [x] The sync command emits discovered instruction files whose basenames start with `general` before language-specific instruction files in generated `AGENTS.md` output.
- [x] Ordering remains deterministic within the `general` group and within the remaining language-specific group.
- [x] The bundled template at `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` remains byte-identical to `scripts/dev-tools/sync-agents-from-instructions.ps1`.
- [x] Pester tests cover the ordering rule and pass.
- [x] Running the sync script regenerates `AGENTS.md` with the expected grouped order.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch