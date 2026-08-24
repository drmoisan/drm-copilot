# Remediation Inputs — Pack-Manifest Completeness (Issue #334)

- Cycle: 2
- Entry timestamp: 2026-07-09T15-57
- Trigger: New finding discovered during Cycle 1 execution (Scope-change Rule). Not an extension of the
  Cycle 1 plan; tracked here as a discrete follow-up cycle.

## Blocking Finding

- Severity: Blocking
- Failing test: `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
- Check that would fail in CI: `drm-copilot-extension-tests` (required).

## Root Cause

`claude-pack-manifest-completeness.test.ts` asserts that every bundled `.claude` agent, skill, and hook
file is referenced by a `pack-manifests/*.json` `paths` array (excluding a fixed set of pre-existing
exceptions). Cycle 1 mirrored three new files into the bundle but did not register them in any pack
manifest, so `computePublishedPaths()` would silently drop them from a manifest-scoped push-down and
the completeness test fails.

## Required Change (minimal)

Add these three bundled paths to the `paths` array of the core pack manifest
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (where the existing
orchestration hooks, skills, and `.claude/settings.json` are already registered):

- `.claude/hooks/persist-session-id.ps1`
- `.claude/skills/identify-session-id/SKILL.md`
- `.claude/skills/show-my-agent-tree/SKILL.md`

Do NOT add entries to the test's `PRE_EXISTING_UNRELATED_EXCEPTIONS` set (that would mask the
regression). Do NOT modify `.claude/**` sources or the bundled `.claude` payload. Manifests are outside
the `.claude/**` byte-parity scope, so this change does not affect the Python contract test.

## Verification

- `cd extensions/drm-copilot && npm run test` passes (Jest, including claude-pack-manifest-completeness).
- Full TypeScript toolchain (format -> lint -> type-check -> test) clean.
- Full Python toolchain remains clean (no manifest impact on `.claude` parity).
- Re-run S9 CI gate against the new PR head SHA: all required checks green.
