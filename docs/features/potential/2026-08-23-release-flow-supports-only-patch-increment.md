# release-flow-supports-only-patch-increment (Potential)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Draft

## Problem / Why

The release automation can only produce a patch release. Every task that bumps a version hardcodes
the literal `patch` in its `npm version` call, and no script exposes a parameter to select the
increment:

- `scripts/dev-tools/Invoke-FullRelease.ps1:284` — extension bump, `@('--prefix', $extensionDir, 'version', 'patch', '--no-git-tag-version')`
- `scripts/dev-tools/Invoke-FullRelease.ps1:289` — mcp-server bump, same literal
- `scripts/dev-tools/Invoke-MarketplacePublish.ps1:216` — extension-only bump, same literal

The entire parameter block of `Invoke-FullRelease.ps1` is a single `[string]$ConfirmToken`
(lines 44-47). There is no increment knob to pass, so a minor or major release cannot be produced by
the supported path at all.

The consequence is not a broken release; it is that any non-patch release must be performed by hand,
outside the tooling that exists to make releases repeatable. That happened for 1.1.0 on 2026-08-23:
the release was a minor bump, so the task would have produced 1.0.28, and both manifests were bumped
manually with `npm version minor --no-git-tag-version` instead. Removing the need for that manual
path is the point of this entry — see the risk note below on the two files no gate protects.

Semantic versioning is already the declared contract. `extensions/drm-copilot/CHANGELOG.md` states
the project "adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)". A tool that can
only ever increment the third component cannot express the first two, so the tooling contradicts the
declared versioning policy for any release that is not a backward-compatible bug fix.

Terminology note: this entry uses the SemVer names `major`, `minor`, and `patch`. "Micro" in the
originating request maps to `patch`, which is the token `npm version` accepts.

## Proposed Behavior

Add an increment selector, defaulting to `patch` so every existing invocation is unchanged.

1. **`Invoke-FullRelease.ps1` gains an `-Increment` parameter** with
   `[ValidateSet('major', 'minor', 'patch')]` and a default of `'patch'`, threaded into both
   `npm version` calls in place of the literal. Both manifests must receive the SAME increment in a
   single run: version lockstep is existing policy (`README.md:403`, "keep
   `packages/mcp-server/package.json` and `extensions/drm-copilot/package.json` version values
   aligned before tagging"), and a per-package increment would break it.
2. **`Invoke-FullReleaseFlow.ps1` accepts and forwards `-Increment`** to `Invoke-FullRelease.ps1`,
   since it is the end-to-end orchestrator and would otherwise remain patch-only.
3. **A `ReleaseIncrement` `pickString` input in `.vscode/tasks.json`**, offering `patch` (default),
   `minor`, and `major`, wired into the tasks that bump: "Release: Open Full Version-Bump PR",
   "Release: Automate Full Release Flow", and "Release: Open Extension Version-Bump PR". There is an
   established precedent for exactly this control — `PotentialPromotionType` and `PotentialWorkMode`
   are already `pickString` inputs in the same file — so this adds no new mechanism.
4. **The commit message stays derived, not templated.** `Invoke-FullRelease.ps1:325` builds
   `"release: bump extension to $newExtVersion and mcp-server to $newMcpVersion"` from the resulting
   versions, so it remains correct for any increment with no change.
5. **`Invoke-ReleaseTagPush.ps1` needs no change.** It reads the merged manifests and derives
   `v<ext-version>` and `mcp-server-v<mcp-version>` via its `Get-ExtensionTagName` and
   `Get-McpServerTagName` helpers, so it is already increment-agnostic. Confirming that rather than
   modifying it is part of the work.

One design question to settle at spec time rather than now: whether `Invoke-MarketplacePublish.ps1`
should also gain the parameter. It bumps the extension manifest only and does not touch the Codex
pins, so using it for a joint release already breaks lockstep. The options are to give it the same
parameter, or to leave it patch-only and document it as extension-only. Do not assume the first.

## Acceptance Criteria (early draft)

- [ ] `Invoke-FullRelease.ps1` accepts `-Increment` constrained to `major|minor|patch`, defaulting to `patch`.
- [ ] An out-of-set value (for example `-Increment 'mayor'`) is rejected before any file is modified, leaving the working tree untouched.
- [ ] Both manifests receive the same increment in one run; no code path bumps them to different values.
- [ ] `Invoke-FullReleaseFlow.ps1` accepts `-Increment` and forwards it; invoked without it, its behavior is identical to today.
- [ ] A `ReleaseIncrement` `pickString` input exists in `.vscode/tasks.json` with `patch` as the default, wired into every task that bumps a version.
- [ ] All six version-bearing files are updated consistently for a `minor` and for a `major` run, including both `.codex/config.toml` MCP pins.
- [ ] `Invoke-ReleaseTagPush.ps1` is confirmed unchanged and still derives both tag names from the merged manifests.
- [ ] Every existing caller that passes no `-Increment` produces the same result as before the change.

## Constraints & Risks

- **Backward compatibility is the hard constraint.** `patch` must remain the default. The parameter is additive; any change to the no-argument behavior is a regression.
- **The two Codex pins are the real hazard, and no gate protects them.** A version bump must also rewrite `@danmoisan/drm-copilot-mcp@<version>` in `.codex/config.toml` and in `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`. `Set-CodexMcpVersionPin` (`Invoke-FullRelease.ps1:145-193`) does this and throws unless each config contains exactly one matching entry. No CI check validates the pins, so a bump path that skips them silently ships a Codex config pointing at the previous release. Any new increment path must route through that function, not around it. This is the strongest argument for closing the gap: it removes the hand-editing that can miss them.
- **Lockstep must not become selectable.** Resist any interface allowing a different increment per package; that would create the version skew the release policy forbids.
- **Publishing is immutable and must not be touched.** Publication is tag-triggered CI, and both registries reject re-publishing a version. This change alters only how the next version number is computed; it must not touch `publish-extension.yml`, `publish-mcp-npm.yml`, or the tag-push step.
- **A major bump raises a downstream-consumer question this entry does not answer.** Going from `1.x` to `2.0.0` signals a breaking change to installed extensions and to anything depending on `@danmoisan/drm-copilot-mcp`. Enabling the mechanism is in scope; deciding when a major release is warranted is not.
- **`extensions/drm-copilot/CHANGELOG.md` is abandoned** — its last entry is `0.0.1`, and 28 releases have shipped without one. A minor or major release is a more defensible place to reinstate the practice than a patch, but that is a separate decision and no gate requires it.

## Test Conditions to Consider

- [ ] Unit coverage areas: six Pester suites already cover these scripts — `Invoke-FullRelease.Tests.ps1`, `Invoke-FullReleaseFlow.Tests.ps1`, `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`, `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, `Invoke-MarketplacePublish.Tests.ps1`, and `Invoke-ReleaseTagPush.Tests.ps1`. Extend them rather than adding a parallel suite. The scripts already expose `Invoke-NpmExe`, `Invoke-GitExe`, and `Invoke-GhExe` mock seams, so the increment token can be asserted without running npm.
- [ ] Assert the exact argument array reaching `Invoke-NpmExe` for each of the three increments, including that both package directories receive the same token in one run.
- [ ] Assert the default: invoking with no `-Increment` still passes `patch`.
- [ ] Assert rejection of an out-of-set value, and that no file was written when it is rejected.
- [ ] Integration scenarios: a full dry run for `minor` and for `major` verifying all six files, with a specific assertion on both Codex pins, since nothing else catches those.
- [ ] Verify the derived commit message and the two derived tag names are correct for a `minor` and a `major` result.
- [ ] CLI/API examples: `Invoke-FullRelease.ps1 -ConfirmToken yes -Increment minor`, and the `ReleaseIncrement` task input defaulting to `patch`.
- [ ] Guard against the gate-that-cannot-fail class per `.claude/rules/plan-acceptance-gates.md`: every assertion above must be shown to fail when the increment is wired incorrectly. A test that passes whether or not the token is threaded through asserts nothing.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/release-flow-supports-only-patch-increment/` folder from the template
