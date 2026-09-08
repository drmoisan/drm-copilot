# codex-preimplementation-gate-modes-module-unregistered (Potential)

- Date captured: 2026-09-07
- Author: drmoisan
- Status: Draft
- Source: issue #545 specification, design decision D11.6, follow-up 1 of 2
- Specification: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`

## Problem / Why

`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` is a production PowerShell
module of 477 lines that was added by issue #554. It is **not** a member of
`$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.

That list is the single registration point through which the Codex contract suite subjects a shared
module to four checks. Because the module is absent from it, all four are unenforced for this file:

1. **Byte identity against its bundle mirror.** The mirror
   `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
   exists, but no test compares the two. A canonical-side edit that is not mirrored, or a mirror-side
   edit that is not back-ported, produces a silent divergence between what the repository holds and
   what a push-down installs.
2. **Parse.** Nothing asserts that the file parses, so a syntax error introduced in it is not caught
   by the contract suite.
3. **The 500-line cap.** At 477 lines the file has 23 lines of headroom and nothing reports when that
   headroom is consumed.
4. **Pack-manifest membership.** Nothing asserts that the file is listed in
   `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, so a
   packaging omission would not be reported by test.

This gap is **pre-existing and is not caused by the issue #545 change**. Issue #545 rewires nine
enforcement hooks through a shared command parser; it neither adds nor modifies
`enforce-orchestration-preimplementation-gate-modes.ps1`, and it does not change
`$script:SharedModuleNames` other than the single-line append the plan permits for the parser
siblings. D11.6 records this item explicitly so it is not silently absorbed into that change, and
requires that it be filed separately rather than folded in.

## Proposed Behavior

Register `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` in
`$script:SharedModuleNames` so the existing Codex contract suite applies its four checks to it,
and remediate whatever those checks then report.

Because the four checks are currently unenforced, the registration should be treated as a discovery
step rather than a formality: the byte-identity check in particular may report an existing
canonical-versus-mirror divergence that has accumulated since issue #554, and the pack-manifest check
may report a missing entry. Both outcomes are remediation work in their own right and are the reason
this is a separate item rather than a one-line edit.

## Acceptance Criteria (early draft)

- [ ] `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` is a member of
      `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
- [ ] The byte-identity check passes for the canonical file and its bundle mirror, or the divergence
      it reports is remediated and the check then passes.
- [ ] The parse check passes for the file.
- [ ] The 500-line cap check passes for the file.
- [ ] The pack-manifest membership check passes for the file, or the missing manifest entry is added
      and the check then passes.
- [ ] The change adds no Python leg to any enforcement hook.

## Constraints & Risks

- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` was at 494 of 500 lines at the
  time issue #545 was planned, and issue #545 appends parser entries to the same list. The line
  budget in that file is therefore tight, and a new scenario for this work belongs in a new test
  file rather than in that suite.
- If the byte-identity check reports an existing divergence, the correct resolution is not
  automatic: it requires determining which side is authoritative before overwriting either.
- The registration is a test-side edit; it does not by itself change runtime behaviour of the hook.

## Test Conditions to Consider

- [ ] The four existing contract checks are observed passing for the newly registered module.
- [ ] A deliberate one-byte divergence between canonical and mirror is observed failing the
      byte-identity check, confirming the registration is load-bearing rather than inert.
- [ ] The pack manifest is confirmed to list the file.

## Next Step

- [ ] Promote to GitHub issue (bug template — this is an unenforced-contract gap, not a new feature)
- [ ] Create `docs/features/active/<feature-name>/` folder from the template
