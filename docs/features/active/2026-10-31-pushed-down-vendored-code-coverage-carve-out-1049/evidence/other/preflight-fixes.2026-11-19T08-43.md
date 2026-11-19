# Preflight Fixes - plan revision 2.1

Timestamp: 2026-11-19T08-43
Plan: docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/plan.2026-10-31T14-03.md
Command: env -u VIRTUAL_ENV poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan docs/features/active/2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049/plan.2026-10-31T14-03.md
EXIT_CODE: 0
Output Summary: Single-pass preflight of revision 2.1. Two trivial defects fixed in task text and preamble; no task added, removed or reordered. Branch Python CLI and installed MCP validator both pass after the fixes. No substantive defect.

## Gate mismatches of the 2026-11-19 Phase 0 run

- `DestinationManifestFileEntry`: exported by `extensions/drm-copilot/src/lib/push-down/push-down-destination-manifest.ts` on HEAD (HEAD contains `origin/epic/shared-agent-harness-layer-integration`, ancestry check exit 0); [P0-T1] now names it. Resolved.
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: 554 logical lines on HEAD, equal to the [P0-T3] planning count; the [P2-T4] cap is now 580, which leaves room for the planned seam, help and call site. Resolved.

## Fixes

1. Preamble, `Execution precondition` bullet | stale heading citation | The sentence cited spec `## Rule Change` as the place that lists `DestinationManifestEntry`; the name is listed under spec `### Ownership` in `## Destination Manifest Schema`. The citation now names that heading. The asserted symbol is unchanged.
2. [P3-T4] acceptance | unsatisfiable observation whose correction keeps the assertion's meaning | The acceptance compared the whole `git status --porcelain` listing with the twelve generator outputs and the four [P3-T3] files, but the uncommitted [P3-T1] and [P3-T2] source edits and the Phase 3 task-check evidence files would also be listed, so the condition could fail on correct work. It now records the listing immediately before and after the three write-mode generator runs and asserts that no path new or changed between the two listings is outside the twelve outputs. The asserted property (the generator writes only its declared outputs) is unchanged; the four [P3-T3] files remain verified by the six-copy hash check of the same acceptance.

## Self-check of the fixes

- Neither fix adds a line-number citation, a commit identifier, a placeholder search token, or an absolute path (G11 and G12 pass on re-validation).
- The fix prose is factual and uses no hyperbole or informal wording.
