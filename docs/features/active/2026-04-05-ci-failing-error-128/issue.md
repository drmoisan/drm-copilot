# ci-failing-error (Issue #128)

- Date captured: 2026-04-05
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-failing-error/ (Issue #128)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #128
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/128
- Last Updated: 2026-04-05
- Work Mode: minor-audit

## Summary

The `extensions/drm-copilot` Jest suite fails in Linux CI because bundled script paths are resolved incorrectly when the tests use Windows-style mocked `fsPath` values such as `C:/extension`. The shared runtime produces hybrid paths like `/home/runner/.../C:/extension/...`, which breaks assertions that verify commands run bundled extension resources.

## Environment

- OS/version: GitHub Actions hosted Linux runner (`ubuntu-latest` behavior; log paths are rooted under `/home/runner/work/...`)
- Python version: Not material to the repro; the failure happens during Jest assertions before any bundled Python script logic runs
- Command/flags used: `npm --prefix extensions/drm-copilot run test`
- Data source or fixture: Jest command/runtime tests with mocked `extensionUri.fsPath = "C:/extension"` and workspace root `C:/workspace` in `extensions/drm-copilot/test/*.test.ts`

## Steps to Reproduce

1. On a Linux host or in GitHub Actions, run `npm --prefix extensions/drm-copilot run test` from the repository root.
2. Let the extension Jest suite execute tests that assert bundled script execution uses the mocked extension install root `C:/extension`.
3. Observe failures in tests such as `helloPython`, `helloPowerShell`, `collectCommitContext`, and `newPotentialEntry` where the spawned argv contains `/home/runner/work/.../C:/extension/...` instead of the expected `C:/extension/...` path.

## Expected Behavior

Bundled resource paths should remain rooted at the mocked extension install directory, for example `C:/extension/resources/templates/hello_python.py`, regardless of whether the Jest host is Windows or Linux. The extension test suite should pass in CI with the same bundled-path assertions that pass on Windows-oriented fixtures.

## Actual Behavior

CI reports multiple failing extension tests because the resolved script path is prefixed with the Linux checkout directory. Representative failures include:

- expected `C:/extension/resources/templates/hello_python.py`
- received `/home/runner/work/drm-copilot/drm-copilot/extensions/drm-copilot/C:/extension/resources/templates/hello_python.py`

The run ends with `Test Suites: 7 failed, 3 passed, 10 total`, `Tests: 18 failed, 118 passed, 136 total`, and exit code `1`.

## Acceptance Criteria

- [x] Windows-style absolute extension roots such as `C:/extension` remain absolute when bundled script paths are resolved on POSIX hosts.
- [x] Bundled command and repo-automation script invocations continue to target extension resources rather than workspace-relative copies.
- [x] Regression coverage verifies the Windows-style mocked `fsPath` scenario and the extension Jest suite no longer fails with checkout-prefixed hybrid paths.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

	`FAIL test/extension.test.ts`

	`Expected: "C:/extension/resources/templates/hello_python.py"`

	`Received: "/home/runner/work/drm-copilot/drm-copilot/extensions/drm-copilot/C:/extension/resources/templates/hello_python.py"`

	`FAIL test/repo-automation-service.test.ts`

	`Expected: "C:/extension/resources/templates/collect_commit_context.py"`

	`Received: "/home/runner/work/drm-copilot/drm-copilot/extensions/drm-copilot/C:/extension/resources/templates/collect_commit_context.py"`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The likely fault is in `extensions/drm-copilot/src/command-runtime.ts`, where `resolveBundledScriptPath()` currently uses `path.resolve(extensionRoot, bundledRelativePath).replace(/\\/g, "/")`. On a POSIX host, Node treats a Windows-style string such as `C:/extension` as a relative path instead of an absolute drive path, so `path.resolve()` anchors it under the current working directory and produces `/home/runner/.../C:/extension/...`.

This shared helper is used by both the command layer and the repo-automation service, which explains why the same malformed prefix appears in `extensions/drm-copilot/test/extension.test.ts` and `extensions/drm-copilot/test/repo-automation-service.test.ts`. The issue may be limited to cross-platform test execution with Windows-style fixtures, but it currently breaks CI and masks whether bundled-path handling remains stable across hosts.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add focused coverage for `resolveBundledScriptPath()` with both POSIX and Windows-style `extensionRoot` inputs, plus command/service call sites that consume the resolved path.
- [ ] Integration scenario to retest: rerun `npm --prefix extensions/drm-copilot run test` on Linux CI after the fix and confirm the bundled-path assertions in `test/extension.test.ts`, `test/repo-automation-service.test.ts`, and other `C:/extension` fixture suites no longer prepend the checkout root.
- [ ] Manual verification notes: capture the logged `resolved script path` emitted by `executeBundledScriptFromExtensionRoot()` and confirm it always points inside the extension install root rather than the repo checkout directory or workspace root.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch