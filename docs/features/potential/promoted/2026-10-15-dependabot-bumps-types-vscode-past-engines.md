# dependabot-bumps-types-vscode-past-engines (Issue #940)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/dependabot-bumps-types-vscode-past-engines/ (Issue #940)
- Work Mode: minor-audit

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #940
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/940
- Last Updated: 2026-10-15
## Summary

Every weekly Dependabot npm PR fails CI. The grouped updates (`groups: patterns: ["*"]`) bump `@types/vscode` above `engines.vscode`, and `vsce package` rejects that combination, so the Publish to Marketplace check fails.

## Environment

- OS/version: GitHub Actions (Dependabot PRs; Publish Extension workflow)
- Python version: n/a
- Command/flags used: `vsce package` in the Publish to Marketplace job
- Data source or fixture: `.github/dependabot.yml` on main f6915d42

## Steps to Reproduce

1. Let Dependabot open its weekly npm group PRs: #833 (`extensions/drm-copilot`) and #832 (root), both bumping `@types/vscode` from 1.138.0 to 1.140.0.
2. Observe Publish to Marketplace on #833 fail (run 38311531357).

## Expected Behavior

Dependabot PRs pass CI. `@types/vscode` only moves together with `engines.vscode`, as a deliberate change.

## Actual Behavior

```text
##[error]@types/vscode ^1.140.0 greater than engines.vscode ^1.138.0. Either upgrade engines.vscode or use an older @types/vscode version
##[error]Process completed with exit code 1.
```

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior (PR #833, Publish to Marketplace, run 38311531357). PR #832 passes CI but would still move the root `@types/vscode` ahead of the extension's `engines.vscode`. Earlier occurrences: #827 and #828.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Each weekly Dependabot run produces a failing PR, so dependency updates (including security-relevant ones) are not merged.

## Suspected Cause / Notes

- `.github/dependabot.yml` npm entries for `/` and `/extensions/drm-copilot` group all updates and ignore only `typescript` majors.
- `@types/vscode` must not exceed `engines.vscode`. Raising `engines.vscode` requires coordinated edits in three files and drops support for older VS Code versions, so it is a deliberate change, not a routine dependency bump.

## Proposed Fix / Validation Ideas

- [ ] Add `- dependency-name: "@types/vscode"` (all update types) to `ignore` in both the `/` and `/extensions/drm-copilot` npm entries.
- [ ] Add a test that parses `.github/dependabot.yml` and asserts both entries ignore `@types/vscode`.
- [ ] After merge, comment `@dependabot recreate` on #832 and #833, and confirm the recreated PRs no longer bump `@types/vscode` and pass all checks.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch