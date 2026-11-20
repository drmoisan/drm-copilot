# fix-csharp-push-down-pack-name (Issue #256)

- Date captured: 2026-06-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/fix-csharp-push-down-pack-name/ (Issue #256)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #256
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/256
- Last Updated: 2026-06-27
- Work Mode: minor-audit

## Summary

The "drm-copilot: Push Down Claude Customizations" command fails with `Pack manifest is missing for pack 'csharp'` whenever the C# language pack is selected, because the command handler forwards the literal pack name `csharp` while the bundled manifests are variant-qualified (`csharp-modern.json`, `csharp-legacy.json`).

## Environment

- OS/version: Windows 11, VS Code Insiders
- Python version: n/a (defect is in the TypeScript extension command handler)
- Command/flags used: Command Palette → "drm-copilot: Push Down Claude Customizations", C# pack selected
- Data source or fixture: Installed extension `danmoisan.drm-copilot-1.0.0`

## Steps to Reproduce

1. Run "drm-copilot: Push Down Claude Customizations".
2. Leave the C# pack selected in the multi-select QuickPick (all packs default-picked).
3. Choose any C# variant (modern or legacy) and any memory mode.

## Expected Behavior

The C# pack publishes using the chosen variant; the command completes and writes a summary artifact.

## Actual Behavior

The command throws and a modal dialog reports `Pack manifest is missing for pack 'csharp': .../resources/claude-customizations/pack-manifests/csharp.json`. No entry is written to the output channel.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `Pack manifest is missing for pack 'csharp': c:/Users/DanMoisan/.vscode-insiders/extensions/danmoisan.drm-copilot-1.0.0/resources/cl...`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

C# is one of four selectable packs; selecting it makes the command unusable.

## Acceptance Criteria

- [x] AC1: When the C# pack is selected in the "Push Down Claude Customizations" QuickPick and the modern variant is chosen, the pack name forwarded to the service is `csharp-modern` (not the literal `csharp`).
- [x] AC2: When the C# pack is selected and the legacy variant is chosen, the pack name forwarded to the service is `csharp-legacy`.
- [x] AC3: When the C# pack is not selected, the forwarded pack names are unchanged for `python`, `powershell`, and `typescript`, and no C# variant prompt is shown.
- [x] AC4: Selecting the C# pack and completing the prompts no longer raises `Pack manifest is missing for pack 'csharp'`; the variant-qualified manifest (`csharp-modern.json` or `csharp-legacy.json`) is resolved.
- [x] AC5: A failure thrown by the push-down service is written to the command output channel before being surfaced to the user, so future failures are diagnosable from the output window.
- [x] AC6: Unit tests cover AC1–AC5 and the existing TypeScript toolchain (format → lint → type-check → test) passes with no coverage regression on changed lines.

## Suspected Cause / Notes

- The QuickPick item maps `{ label: "C#", pack: "csharp" }` in `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts`.
- The selected pack name `csharp` is forwarded unchanged through the service to `loadPackManifests`, which looks for `csharp.json`. Only `csharp-modern.json` and `csharp-legacy.json` exist.
- `loadPackManifests` in `extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts` throws `ManifestError` for the missing manifest.
- The variant prompt result (`csharpVariant`) is forwarded separately and only routes source reads; it is never used to translate the pack name to `csharp-modern` / `csharp-legacy`.
- The command handler invokes the service without a `try/catch`, so the error surfaces as a modal but is not logged to the output channel.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: in the command handler, after the variant is chosen, replace the selected `csharp` pack name with `csharp-${csharpVariant}` before forwarding to the service. Add a guard that the variant is resolved whenever `csharp` is selected.
- [x] Integration scenario to retest: run the push-down command with the C# pack selected for both modern and legacy variants and confirm the correct manifest loads.
- [x] Manual verification notes: confirm non-C# packs (python, powershell, typescript) still forward unchanged.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
