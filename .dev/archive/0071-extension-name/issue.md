# extension-name (Issue #71)

- Date captured: 2026-03-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/extension-name/ (Issue #71)
- Issue: #71
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/71
- Last Updated: 2026-03-03
- Work Mode: minor-audit

## Summary

The extension was scaffolded with a feature-derived name (`extension-name`) instead of the canonical extension name (`drm-copilot`).
This creates naming drift across extension metadata and can break packaging/publishing expectations that rely on a stable extension identifier.

## Environment

- OS/version: Windows (current dev environment)
- Python version: Not captured at report time
- Command/flags used: Extension scaffolding flow (name input accepted as feature slug)
- Data source or fixture: Repository scaffold templates and generated extension manifest/config files

## Steps to Reproduce

1. Run the extension scaffolding/promotion workflow for a new feature using a short feature slug as input.
2. Generate the extension project and inspect extension metadata (for example, manifest/package name fields and related docs).
3. Observe that the generated extension name is the feature slug (`extension-name`) rather than the intended canonical name (`drm-copilot`).

## Expected Behavior

The generated extension metadata should consistently use `drm-copilot` as the extension name, independent of feature slug or issue title.

## Actual Behavior

The scaffolded output uses `extension-name` (feature-derived) as the extension name.
No runtime exception is required to reproduce; the defect is visible in generated naming metadata and any downstream artifacts that read from it.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: N/A yet (to add from generated manifest and/or scaffold output)

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Likely a variable mapping issue in the scaffolding pipeline where `${short-name}` or feature identifier is incorrectly reused as extension identity.
The extension identity appears to be coupled to feature naming instead of a fixed canonical value (`drm-copilot`).
Files to inspect first: extension scaffold templates, promotion/scaffold scripts, and generated extension manifest fields.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas
- [ ] Integration scenario to retest
- [ ] Manual verification notes

- Unit coverage areas: add/extend tests validating name resolution so extension identity is `drm-copilot` even when feature slug differs.
- Integration scenario to retest: run end-to-end scaffolding with at least two distinct feature slugs and verify generated extension name remains `drm-copilot`.
- Manual verification notes: inspect generated `package.json`/manifest and README references for consistent `drm-copilot` naming.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch