# Issue #191 — Acceptance Criteria Update Mirror

Timestamp: 2026-06-16T20-39
PostedAs: body

This mirror records the acceptance-criteria check-off applied to the local feature `issue.md` (`## Acceptance Criteria` section) for Issue #191. The update was applied to the local feature `issue.md` file body. It was not posted to the GitHub issue by this executor run (no GitHub posting was performed); the canonical local source `issue.md` is the body of record for this minor-audit feature folder.

## Acceptance Criteria — final state (all satisfied)

- [x] A new VS Code task patch-bumps both package manifests in one run.
  - Evidence: Implementation P1-T7 (mcp-server manifest bump via `Invoke-NpmExe` with `version patch --no-git-tag-version` in `packages/mcp-server`) and P1-T8 (extension manifest bump delegated to `Publish-DrmCopilotExtension.ps1 -VersionBump patch`). Verified by `evidence/qa-gates/poshqc-test.md` (test "requests the patch bump with the expected npm wrapper arguments and uses the derived post-bump version", suite passing 7/7).

- [x] The task publishes the extension to the Marketplace via the existing script.
  - Evidence: Implementation P1-T8 (`Invoke-PublishScript -ScriptPath <Publish-DrmCopilotExtension.ps1> -Publish -VersionBump patch -Tag`). Verified by `evidence/qa-gates/poshqc-test.md` (happy-path and publish-failure tests).

- [x] The task creates and pushes a `mcp-server-v<version>` tag to trigger npm publish.
  - Evidence: Implementation P1-T9 (`Invoke-GitExe` annotated tag create + push) and P1-T4/P1-T14 (`Get-McpServerTagName` derivation). Verified by `evidence/qa-gates/poshqc-test.md` (test "calls the git tag wrapper with the derived mcp-server-v0.0.2 tag on a confirmed run").

- [x] The task is gated behind a `yes`/`no` confirmation input.
  - Evidence: Implementation P1-T5 (case-sensitive `-cne 'yes'` guard returning 2), P1-T16 (`FullReleaseConfirm` pickString input, options [no, yes], default no), P1-T17 (task passes `${input:FullReleaseConfirm}`). Verified by `evidence/qa-gates/poshqc-test.md` (guard tests for no/YES/Yes) and `evidence/qa-gates/tasks-json-validate.md`.

- [x] The npm workflow publishes with `--provenance`.
  - Evidence: Implementation P1-T18 (job-level `permissions: { id-token: write, contents: read }`) and P1-T19 (publish step `npm publish --provenance --access public`, `NODE_AUTH_TOKEN` preserved). Verified by `evidence/qa-gates/actionlint.md` (actionlint 1.7.11, exit 0, zero findings).

- [x] Pester tests cover the new release script's guard and orchestration logic.
  - Evidence: Implementation P1-T11–P1-T15 (`tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`, 7 tests). Verified by `evidence/qa-gates/poshqc-test.md` (608 total tests pass, new suite 7/7) and `evidence/qa-gates/coverage-delta.md` (new-code line coverage 88.0% >= 85%).
