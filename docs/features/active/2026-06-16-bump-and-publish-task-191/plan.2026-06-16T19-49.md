# bump-and-publish-task - Plan

- **Issue:** #191
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-16T20-12
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** minor-audit

## Required References

Comply with the following policies; do not duplicate their content here.

- Repository tone and communication policy: `.github/copilot-instructions.md`
- General code change policy: `.claude/rules/general-code-change.md`
- General unit test policy: `.claude/rules/general-unit-test.md`
- PowerShell toolchain, wrapper seams, and mocking rules: `.claude/rules/powershell.md`
- CI workflow authoring (pwsh exit-code handling): `.claude/rules/ci-workflows.md`
- GitHub Actions instructions: `.github/instructions/github-actions.instructions.md`
- Module rigor tiers and coverage thresholds: `.claude/rules/quality-tiers.md`
- Evidence and timestamp conventions: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

**All work must comply with these policies; do not duplicate their content here.**

## Sole Requirements Source

The sole requirements source for this minor-audit plan is `docs/features/active/2026-06-16-bump-and-publish-task-191/issue.md`. The acceptance criteria source is the `## Acceptance Criteria` section of that file (the only acceptance-criteria checklist present in `issue.md`). `spec.md` and `user-story.md` are not required for this minor-audit work mode.

## Languages In Scope

- **PowerShell** — new production script `scripts/dev-tools/Invoke-FullRelease.ps1` and its Pester tests. Coverage policy applies (line >= 85%, branch >= 75% per `.claude/rules/quality-tiers.md`).
- **GitHub Actions (YAML)** — provenance amendment to `.github/workflows/publish-mcp-npm.yml`. No coverage gate; validated by `actionlint` and policy review.
- **JSONC** — `.vscode/tasks.json` input + task addition. No coverage gate; validated structurally.

## Evidence Location Invariant

All evidence artifacts for this plan MUST be written under the canonical location `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/<kind>/`. Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation. Any caller-supplied non-canonical evidence path is rejected and replaced with the canonical path, recorded as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied> replaced with <canonical>`.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in the required order (`.github/copilot-instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/ci-workflows.md`, `.github/instructions/github-actions.instructions.md`, `.claude/rules/quality-tiers.md`) and record a Phase 0 read-evidence artifact.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and the explicit list of files read.

- [x] [P0-T2] Capture the baseline PowerShell format state by running `mcp__drm-copilot__run_poshqc_format` against the repository and record the result.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/baseline/poshqc-format.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T3] Capture the baseline PowerShell analyzer state by running `mcp__drm-copilot__run_poshqc_analyze` against the repository and record the result.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/baseline/poshqc-analyze.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Capture the baseline PowerShell Pester state and coverage by running `mcp__drm-copilot__run_poshqc_test` against the repository and record the numeric coverage headline.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/baseline/poshqc-test.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with baseline numeric line-coverage and branch-coverage percentages.

- [x] [P0-T5] Record the current manifest versions and the expected post-bump versions for both packages so later tasks can assert exact values.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/baseline/manifest-versions.md` exists and records that `extensions/drm-copilot/package.json` is `0.0.2` (expected patch bump `0.0.3`) and `packages/mcp-server/package.json` is `0.0.1` (expected patch bump `0.0.2`), with `Timestamp:`.

- [x] [P0-T6] Normalize the acceptance-criteria heading in docs/features/active/2026-06-16-bump-and-publish-task-191/issue.md from "## Acceptance Criteria (early draft)" to the exact "## Acceptance Criteria" required for minor-audit AC tracking; do not modify the six criterion items.
  - Acceptance: `issue.md` contains an "## Acceptance Criteria" heading retaining the same six checklist items unchanged.

### Phase 1 — Constrained Small-Path Implementation

- [x] [P1-T1] Create `scripts/dev-tools/Invoke-FullRelease.ps1` with a `[CmdletBinding()]` param block exposing a mandatory `[string]$ConfirmToken` parameter, mirroring the header and structure of `scripts/dev-tools/Invoke-MarketplacePublish.ps1`.
  - Acceptance: File exists, declares `[CmdletBinding()]` and `[Parameter(Mandatory = $true)] [string]$ConfirmToken`, and includes a comment-based help block describing the combined-release behavior.

- [x] [P1-T2] Add a `Write-StderrLine` helper and wrapper-seam functions `Invoke-GitExe` (param `[string[]]$GitArgs`), `Invoke-NpmExe` (param `[string[]]$NpmArgs`), and `Invoke-PublishScript` (param `[string]$ScriptPath`) to `scripts/dev-tools/Invoke-FullRelease.ps1`, per the wrapper-function seam pattern in `.claude/rules/powershell.md`.
  - Acceptance: Each wrapper splats its array into the external executable (or invokes the publish script) and returns/propagates `$LASTEXITCODE`; no external executable is called outside these wrappers; parameter names are not `Args`.

- [x] [P1-T3] Add a `Get-NpmVersion` function to `scripts/dev-tools/Invoke-FullRelease.ps1` that reads a `package.json` path and returns its `version` string by JSON parse (no external call).
  - Acceptance: Function takes a `[string]$ManifestPath`, returns the `version` field as a string, and throws a clear error when the file is missing or the field is absent.

- [x] [P1-T4] Add a `Get-McpServerTagName` function to `scripts/dev-tools/Invoke-FullRelease.ps1` that constructs the tag name `mcp-server-v<version>` from a supplied version string.
  - Acceptance: Given input `0.0.2`, the function returns exactly `mcp-server-v0.0.2`; the function is pure (no external calls).

- [x] [P1-T5] Add an `Invoke-FullReleaseGuarded` function to `scripts/dev-tools/Invoke-FullRelease.ps1` that returns `2` when `$ConfirmToken -cne 'yes'` (writing a stderr message) and otherwise proceeds, taking `[string]$ConfirmToken` and `[string]$RepoRoot`.
  - Acceptance: Non-`'yes'` token causes return code `2` with a stderr message and no bump/publish/tag wrapper is invoked; the guard uses case-sensitive comparison (`-cne`).

- [x] [P1-T6] Extend `Invoke-FullReleaseGuarded` to resolve and verify both manifest paths and the publish script path, returning `1` with a stderr message when the publish script `scripts/powershell/Publish-DrmCopilotExtension.ps1` is missing.
  - Acceptance: Missing publish script returns `1` and writes a stderr message; the function resolves `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json` relative to `$RepoRoot`.

- [x] [P1-T7] Extend `Invoke-FullReleaseGuarded` to patch-bump the mcp-server manifest via `Invoke-NpmExe` with `version patch --no-git-tag-version` executed in `packages/mcp-server`, then derive the new mcp version via `Get-NpmVersion` and the tag name via `Get-McpServerTagName`.
  - Acceptance: On confirmation the mcp-server manifest is bumped (smallest increment, no git tag) using the npm wrapper, and the new version + derived `mcp-server-v<version>` tag name are captured for subsequent steps.

- [x] [P1-T8] Extend `Invoke-FullReleaseGuarded` to publish the extension by delegating to the publish script via `Invoke-PublishScript` with `-Publish -VersionBump patch -Tag` (the extension manifest patch bump is performed by the delegated script), propagating its exit code.
  - Acceptance: On confirmation the extension publish is delegated to `Publish-DrmCopilotExtension.ps1` through the wrapper seam; a non-zero publish exit code is returned by `Invoke-FullReleaseGuarded` and stops the run before tag push.

- [x] [P1-T9] Extend `Invoke-FullReleaseGuarded` to create and push the `mcp-server-v<version>` git tag via `Invoke-GitExe`, returning `0` only when tag creation and push both succeed.
  - Acceptance: On confirmation the function calls `Invoke-GitExe` to create the annotated tag and to push it; failures propagate a non-zero return code with a stderr message; success returns `0`.

- [x] [P1-T10] Add the dot-source guard `if ($MyInvocation.InvocationName -ne '.')` entry point to `scripts/dev-tools/Invoke-FullRelease.ps1` that resolves the repo root and calls `Invoke-FullReleaseGuarded`, exiting with its return code.
  - Acceptance: When dot-sourced the script defines functions without executing the entry point; when run directly it resolves repo root from `$PSScriptRoot` and exits with the guarded return code. File remains under 500 lines.

- [x] [P1-T11] Create `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` that dot-sources the script under test and mocks the wrapper seams (`Invoke-GitExe`, `Invoke-NpmExe`, `Invoke-PublishScript`) with signatures matching production named parameters.
  - Acceptance: File exists at the mirrored path, dot-sources the production script, registers wrapper mocks before the code under test resolves them, and uses no temp files, no real git/npm calls, and no network access.

- [x] [P1-T12] Add a Pester `It` to `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` asserting the confirmation guard returns `2` and invokes no bump/publish/tag wrapper for a non-`'yes'` token (including `'YES'` and `'Yes'`).
  - Acceptance: Test passes; asserts return code `2` and zero invocations of `Invoke-NpmExe`, `Invoke-PublishScript`, and `Invoke-GitExe`.

- [x] [P1-T13] Add a Pester `It` to `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` asserting that on confirmation the mcp-server manifest bump is requested with the expected npm wrapper arguments (`version patch --no-git-tag-version`) and that `Get-NpmVersion` returns the expected post-bump version.
  - Acceptance: Test passes using a fake/stubbed manifest read so the asserted post-bump version is deterministic; asserts the npm wrapper is called with the exact patch-bump arguments in `packages/mcp-server`.

- [x] [P1-T14] Add a Pester `It` to `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` asserting `Get-McpServerTagName` derives `mcp-server-v0.0.2` from input `0.0.2` and that the git tag wrapper is called with that exact tag name on a confirmed run.
  - Acceptance: Test passes; asserts both the pure tag-name derivation and the `Invoke-GitExe` tag arguments contain `mcp-server-v0.0.2`.

- [x] [P1-T15] Add a Pester `It` to `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` asserting that a missing publish script returns `1` and writes an error (not silently ignored), with no tag push attempted.
  - Acceptance: Test passes; asserts return code `1`, a non-empty stderr/error message, and zero invocations of `Invoke-GitExe` push.

- [x] [P1-T16] Add the `FullReleaseConfirm` input (yes/no `pickString`, default `no`) to the `inputs` array in `.vscode/tasks.json`, mirroring the existing `MarketplacePublishConfirm` input.
  - Acceptance: A new input with `"id": "FullReleaseConfirm"`, options `["no", "yes"]`, default `"no"`, and a description noting Marketplace and npm versions are immutable is present and the JSON remains valid.

- [x] [P1-T17] Add a new task entry to `.vscode/tasks.json` that runs `pwsh -File scripts/dev-tools/Invoke-FullRelease.ps1 -ConfirmToken ${input:FullReleaseConfirm}`, modeled on the `Publish: Marketplace VSIX (patch + tag)` task entry.
  - Acceptance: A task labeled `Publish: Full Release (bump both + Marketplace + npm tag)` (or equivalent) exists, uses `command: pwsh` with the `-NoLogo -NoProfile -ExecutionPolicy Bypass -File` args, sets `cwd` to `${workspaceFolder}`, passes `${input:FullReleaseConfirm}`, and the JSON remains valid.

- [x] [P1-T18] Add `permissions: { id-token: write, contents: read }` to the `publish` job in `.github/workflows/publish-mcp-npm.yml`.
  - Acceptance: The `publish` job declares `permissions:` with `id-token: write` and `contents: read`; YAML remains valid.

- [x] [P1-T19] Change the npm publish step in `.github/workflows/publish-mcp-npm.yml` to run `npm publish --provenance --access public`, complying with `.claude/rules/ci-workflows.md` exit-code handling for any deliberately-failing nested command (none expected here).
  - Acceptance: The publish step `run:` is `npm publish --provenance --access public`; the existing `NODE_AUTH_TOKEN` env is preserved; YAML remains valid.

### Phase 2 — Final QC Loop

- [x] [P2-T1] Run PowerShell formatting via `mcp__drm-copilot__run_poshqc_format` and record the result; if it changes files, re-run before proceeding.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/poshqc-format.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; final state is a clean pass with no further file changes.

- [x] [P2-T2] Run PowerShell linting via `mcp__drm-copilot__run_poshqc_analyze` and record the result; restart the loop from formatting if it reports findings or changes files.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/poshqc-analyze.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; final state has zero analyzer findings.

- [x] [P2-T3] Run PowerShell tests with coverage via `mcp__drm-copilot__run_poshqc_test` and record numeric post-change coverage; restart the loop from formatting if it fails or changes files.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/poshqc-test.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing post-change numeric line-coverage and branch-coverage percentages; all tests pass.

- [x] [P2-T4] Verify coverage thresholds and no-regression by comparing baseline (P0-T4) and post-change (P2-T3) coverage and reporting new/changed-code coverage for `scripts/dev-tools/Invoke-FullRelease.ps1`.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/coverage-delta.md` exists and records baseline coverage, post-change coverage, and new/changed-code coverage; line coverage >= 85%, branch coverage >= 75%, and no regression on changed lines. If any required value is unavailable, the outcome is remediation-required, not PASS.

- [x] [P2-T5] Lint the amended workflow with `actionlint` (or the repo-configured GitHub Actions linter) and record the result.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/actionlint.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; `.github/workflows/publish-mcp-npm.yml` reports zero findings.

- [x] [P2-T6] Validate `.vscode/tasks.json` structurally (JSON parse / schema validation) and record the result.
  - Acceptance: `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/tasks-json-validate.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the file parses successfully and includes the new input and task.

- [x] [P2-T7] Update the acceptance-criteria checkboxes in `docs/features/active/2026-06-16-bump-and-publish-task-191/issue.md` to mark each satisfied criterion in the `## Acceptance Criteria` section, citing the evidence artifact that satisfies it, and mirror the update per the acceptance-criteria-tracking convention.
  - Acceptance: Each criterion in `issue.md` is checked only when supported by a Phase 1 implementation task and Phase 2 evidence artifact; an issue-update mirror is written to `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/issue-updates/issue-191.<timestamp>.md` with `Timestamp:` and `PostedAs:`.

## Test Plan

- Unit (PowerShell/Pester): `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` covers the confirmation guard (non-`yes` rejection), mcp-server patch-bump arguments and derived version, `mcp-server-v<version>` tag derivation and push arguments, and missing-publish-script reporting. All wrapper seams are mocked; no temp files, no real git/npm, no network.
- Static (GitHub Actions): `actionlint` over `.github/workflows/publish-mcp-npm.yml`.
- Structural (JSONC): `.vscode/tasks.json` parse/schema validation.
- Coverage evidence:
  - Baseline: `evidence/baseline/poshqc-test.md`.
  - Post-change: `evidence/qa-gates/poshqc-test.md`.
  - Comparison: `evidence/qa-gates/coverage-delta.md`.

## Open Questions / Notes

- Final production script name is at the implementer's discretion but must remain under `scripts/dev-tools/`; this plan uses `Invoke-FullRelease.ps1`.
- The extension manifest patch bump is performed by the delegated `Publish-DrmCopilotExtension.ps1 -VersionBump patch`; the new script directly bumps only the mcp-server manifest, satisfying the shared-cadence requirement that both packages bump on every release.
- Certificate-based local signing is out of scope per `issue.md`.
