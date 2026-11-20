# Portable Hook Validation Residuals (Potential)

- Date captured: 2026-08-15
- Author: atomic-executor (issue #475, `[P13-T2]`)
- Status: Draft

## Scope Statement — No Check Family Is Deferred

This entry is the rescoped successor to the pre-promotion potential entry for issue #475
(`docs/features/potential/promoted/2026-08-15-enforcement-hooks-must-not-invoke-python.md`).

**NO completion-validator check family is deferred by issue #475.** The complete-parity port
of the orchestrator-state completion validator covers all 85 rows of the authoritative
inventory (U family 57, C family 25, M family 3), measured row by row in
`docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/other/parity-coverage.2026-08-15T18-30.md`:
85/85 mapped to an implementing module and an asserting test, 0 unmapped, 0 deferred.

The four documented divergences (U1 load-error message text, PD-1 pinned routing-matrix
constants, PD-2 single emission, PD-3 epic/parallel structural dispatch) are deviations
with stated resolutions, implemented as the spec records them. **PD-3 in particular is
defined fail-closed behavior in a region where Python parity is undefined** — under the
hook's flag pair the Python surface performs zero checkpoint checks for
`epic-orchestrator-state` and `parallel-orchestrator-state` (argparse exit 2), so there is
no check list to port and nothing to defer. PD-3 maps to no inventory row. No artifact of
this feature describes the epic/parallel structural check, or any check family, as deferred.

The two items below are residuals recorded for future consideration. Neither is a deferred
check family.

## Problem / Why

### Residual 1 — Defect D-2: avoided, not redesigned

The discovery-artifact gates deny on non-empty validator output
(`.claude/hooks/enforce-discovery-artifact-gate.ps1:183-184`,
`.claude/hooks/validate-discovery-artifact-gate.ps1:217-218`). That is a fragile contract:
any validator that writes a progress line, a warning, or any other non-error text to its
output stream on a **successful** validation would be read as a denial.

Issue #475 **avoided** this defect rather than redesigning it. The shared PowerShell
implementation `.claude/lib/discovery-validation/DiscoveryValidation.psm1` was given an
explicit contract — success returns `ExitCode = 0` with **empty** `Output`; failure returns
`ExitCode = 1` with one error string per line — and that contract is asserted directly by
unit tests and by hook-level allow-verdict tests. The deny-on-non-empty-output logic in both
hooks is unchanged.

The residual is the underlying design: the hooks still infer a verdict from output emptiness
rather than from an explicit verdict field or exit code alone. A future change could replace
the emptiness inference with an explicit verdict contract. Until then, any new or replaced
validator implementation wired into these seams must uphold the empty-success-output
contract, and its tests must assert it.

### Residual 2 — PowerShell 7.4+ floor for `Test-Json -SchemaFile`

`DiscoveryValidation.psm1` validates the seven discovery artifact schema types with
`Test-Json -SchemaFile`. All seven schemas under `schemas/discovery/v1/*.json` declare JSON
Schema **Draft 2020-12** (verified 7 of 7). Draft 2020-12 support in `Test-Json -SchemaFile`
requires **PowerShell 7.4 or later**. The repository standard recorded in
`.claude/rules/powershell.md` is "PowerShell 7+", which is below that floor;
`.claude/rules/**` was not modified by issue #475.

The module therefore performs a runtime version check through an injectable version seam and
**fails closed** on PowerShell < 7.4 with a single actionable error naming the required
version, the `Test-Json -SchemaFile` Draft 2020-12 reason, and issue #475. It does not fail
obscurely with a raw parameter error and it does not silently degrade to partial validation.
The floor and its reason are also stated in the module's comment-based help, which is the
destination-visible surface: the module ships to destinations inside the `.claude/**`
payload, the pushed-down pack carries only `config/` and `pack-manifests/` alongside
`.claude/**`, and no pack README exists to carry the statement.

The residual is the operational consequence for destination repositories: a destination
running PowerShell 7.0 through 7.3 will have the discovery-artifact gates block, with the
actionable upgrade message, until PowerShell is upgraded to 7.4+. Draft-2020-12-free
alternatives were assessed and rejected during specification.

## Proposed Behavior

- Residual 1: replace the deny-on-non-empty-output inference in both discovery gates with an
  explicit verdict contract (for example a structured result object or an exit-code-only
  decision), so a validator that emits informational output on success cannot be misread as
  a denial.
- Residual 2: decide whether the repository standard in `.claude/rules/powershell.md` should
  be raised to 7.4+, or whether destination-side tooling should detect and report the floor
  ahead of hook execution rather than at hook-execution time.

## Acceptance Criteria (early draft)

- [ ] The discovery gates derive their verdict from an explicit signal rather than from
      output emptiness, and the change is covered by hook-level allow and deny tests.
- [ ] The PowerShell version floor for destination repositories is either raised in the
      repository standard or surfaced by destination-side tooling before hook execution.

## Constraints & Risks

- Changing the discovery-gate verdict contract touches two enforcement hooks and their
  26 existing `Invoke-DiscoveryValidatorExe` seam references (15 `Mock` registrations plus
  11 `Should -Invoke` assertions). The seam name and the `@{ ExitCode; Output }` return shape
  are load-bearing for those tests.
- Raising the repository PowerShell standard is a policy change under `.claude/rules/**` and
  is out of scope for any agent that is not explicitly authorized to modify policy documents.
- Neither residual affects parity: the 85-row inventory is fully covered and no check family
  is deferred.

## Test Conditions to Consider

- [ ] A validator that emits informational output on a successful validation yields an ALLOW
      verdict under the redesigned contract (the D-2 case that the current contract avoids
      rather than handles).
- [ ] The version-floor check remains deterministic through the injectable seam, with no
      `$PSVersionTable` mutation and no dependence on ambient host state.
- [ ] Destination-simulation coverage for PowerShell 7.3 (below floor) and 7.4 (at floor).

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/<feature-name>/` folder from the template
