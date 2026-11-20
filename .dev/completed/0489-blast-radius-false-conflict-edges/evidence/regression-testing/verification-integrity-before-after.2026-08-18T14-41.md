# Verification-Integrity Before/After Regression Evidence (Issue #489)

Timestamp: 2026-08-18T14-41

## Scope

Records the measured before-state and after-state conflict edge sets and cohort
partitions for the `verification-integrity` parallel run (items 485, 486, 487),
demonstrated against a committed fixture rather than against the gitignored
working-tree checkpoint `artifacts/orchestration/parallel-orchestrator-state.json`.

Fixture path:
`tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json`

The fixture holds the three recorded `blast_radius` blocks verbatim
(485 = 184/6/1/40, 486 = 125/3/2/45, 487 = 140/4/1/10 for
paths/modules/shared_surfaces/contracts), a `pre_fix_config` block equal to the
pre-change committed truth table, and a `post_fix_config` block equal to the
ratified content.

## Before state (pre-fix config, raw recorded radii)

- Edge set: `[(485, 486), (485, 487), (486, 487)]` — the complete K3 triangle.
- Cohort partition: `[[485], [486], [487]]` — fully serial execution of three
  thematically unrelated items.

Every edge above except `(486, 487)` was produced by citations that were
evidence of a mandated read or by token shapes that were never write claims:
policy-rule and tier-map citations, `artifacts/**` subtree claims,
directory-shaped tokens, corpus-spanning `docs/features/` globs, and letterless
contract tokens.

## After state (committed `config/blast-radius.json`, normalized radii)

Radii re-filtered through `normalize_declared_radius(radius, config)`:

| Item | paths | modules | shared_surfaces | contracts |
| --- | --- | --- | --- | --- |
| 485 | 184 -> 125 | 6 -> 0 | 1 -> 0 | 40 -> 34 |
| 486 | 125 -> 92 | 3 -> 0 | 2 -> 1 | 45 -> 41 |
| 487 | 140 -> 95 | 4 -> 0 | 1 -> 0 | 10 -> 10 |

- Edge set: `[(486, 487)]`.
- Surviving overlap: `extensions/drm-copilot/src/mcp-tools.ts` — a genuine
  path-level conflict; both items edit that file.
- Reported reason detail:
  `extensions/drm-copilot/src/mcp-tools.ts ~ extensions/drm-copilot/src/mcp-tools.ts`
- Cohort partition: `[[485, 486], [487]]` — two cohorts, with 485 and 486
  concurrent.

The contention relation itself is unchanged. `scripts/dev_tools/_blast_radius_conflicts.py`,
`scripts/dev_tools/_blast_radius_glob.py`, `scripts/dev_tools/_blast_radius_thresholds.py`,
and `scripts/dev_tools/parallel_cohort_computation.py` carry zero diff on this
branch, so the change in the edge set comes entirely from the evidence fed to
the frozen relation.

## Python regression run

Timestamp: 2026-08-18T14-41
Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_verification_integrity.py -v`
EXIT_CODE: 0
Output Summary: 6 passed in 0.49s. Before-state cases:
`test_fixture_radii_load_at_recorded_sizes`,
`test_before_state_yields_complete_conflict_triangle`,
`test_before_state_colours_into_three_serial_cohorts`. After-state cases:
`test_after_state_yields_only_the_genuine_conflict_edge`,
`test_after_state_surviving_edge_cites_the_shared_mcp_tool_surface`,
`test_after_state_colours_into_two_cohorts`. Zero failures.

## Pester regression run

Timestamp: 2026-08-18T14-41
Command: `pwsh -NoProfile -Command 'Import-Module Pester -Force; $c = New-PesterConfiguration; $c.Filter.FullName = "Verification-integrity regression (issue #489)*"; $c.Run.Path = "tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1"; $c.Output.Verbosity = "Detailed"; $c.Run.PassThru = $true; $r = Invoke-Pester -Configuration $c'`
EXIT_CODE: 0
Output Summary: Tests Passed: 3, Failed: 0, Skipped: 0, Inconclusive: 0,
NotRun: 67 (the NotRun count is the rest of the parity file, excluded by the
FullName filter). Cases: `Before state / reports contention for all three pairs
under the pre-fix config`; `After state / reports only the genuine 486-487
conflict after normalization`; `After state / cites the shared MCP tool surface
as the surviving path overlap`. Cohort assertions are Python-side only; the
PowerShell port carries no cohort computation.

## Evidence-location verification

Command: `git diff main --name-only | pwsh -Command '$input | Select-String -Pattern "^artifacts/"'`
EXIT_CODE: 0
Output Summary: zero matches. No evidence for this feature resolves to an
`artifacts/`-rooted path; every artifact is under
`docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/`.
