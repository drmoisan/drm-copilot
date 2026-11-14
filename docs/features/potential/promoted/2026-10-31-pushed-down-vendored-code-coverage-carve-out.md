# pushed-down-vendored-code-coverage-carve-out (Issue #1049)

- Date captured: 2026-10-31
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pushed-down-vendored-code-coverage-carve-out/ (Issue #1049)

- Issue: #1049
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1049
- Last Updated: 2026-10-31
## Problem / Why

The push-down copies hooks, skills, agents, libraries and rules into destination repositories. It does not copy the Pester tests that cover them: `extensions/drm-copilot/resources/` contains no `*.Tests.ps1` files, and the push-down source does not reference tests. A destination repository therefore receives PowerShell production code without its suite.

The pushed-down rule `general-unit-test.md` states that no production file may be excluded from coverage and lists the only permitted exclusions (build output, tests and test infrastructure, non-production config, `node_modules`). A destination that enforces that rule must cover the pushed-down hooks, and at least one destination has done so by recreating a Pester suite locally. Those recreated tests duplicate coverage already established upstream, drift from the hooks on every push-down, and can fail for reasons unrelated to the destination's own code.

Packages and plugins conventionally ship without their tests, and consumers do not hold vendored code to their own coverage targets. The rule has no vendored-code category, so a destination cannot exempt pushed-down files without violating it.

## Proposed Behavior

1. Add a vendored-code exception to the pushed-down coverage rules (`general-unit-test.md` and its mirrors): files written by the push-down and unchanged since may be excluded from the destination's coverage measurement. The exception covers only paths on the push-down's recorded file list, never a directory glob such as `.claude/**`.
2. The push-down records a content hash for every file it writes (a manifest in the destination, written at push time).
3. A destination check recomputes the hashes. A file whose hash differs from the manifest, or that is absent from it, is treated as destination-owned code and returns to the coverage denominator. A local hook added by the destination is covered by default.
4. The destination's coverage configuration generates its exclusion list from the manifest instead of hand-maintaining paths.
5. Document the policy for destination maintainers: pushed-down code is tested upstream, a modified copy is owned and tested locally, and recreated duplicate tests may be removed.

## Acceptance Criteria (early draft)

- [ ] The pushed-down coverage rules define the vendored-code exception with the hash-verified, exact-path conditions.
- [ ] The push-down writes a manifest of path and content hash for every file it writes.
- [ ] A destination check fails closed: a changed or unlisted file is not exempt.
- [ ] The exclusion list used by the destination's coverage tooling is derived from the manifest.
- [ ] A destination-added hook under `.claude/hooks/` stays in the coverage denominator.
- [ ] The feature-review rule that treats a production-path exclusion as Blocking recognizes manifest-derived entries and still blocks hand-written ones.
- [ ] The destination documentation states the ownership policy and the removal of recreated duplicate tests.

## Constraints & Risks

- A blanket directory exclusion hides destination edits and local additions from coverage. The exact-path and hash conditions are required.
- Environment-specific regressions in a destination (case-sensitive paths, different worktree layout) are no longer caught by locally recreated tests. The upstream Linux hook-suite job covers part of this; the remainder is a residual risk to record.
- The change edits rules that are also in this repository's own enforcement. This repository keeps its tests and is not exempt; the exception applies to destination repositories only.
- Scope overlaps with the shared agent-harness layer epic (#1018, push-down consolidation). Sequence it after that work or as one of its children to avoid editing the same push-down code twice.
- No new Python; the manifest writer and the check are PowerShell or bash, and the push-down itself is TypeScript.

## Test Conditions to Consider

- [x] Unit coverage areas: manifest generation (paths, hashes, ordering); the destination check (unchanged, modified, added, removed file); exclusion-list derivation.
- [x] Integration scenarios: push to a scratch destination, run its coverage configuration, modify one hook and confirm it re-enters the denominator.
- [ ] CLI/API examples

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/pushed-down-vendored-code-coverage-carve-out/` folder from the template
