# P15-T22 — Mirror parity of every Phase 15 native file

Task: [P15-T22] Publish every changed native file to its mirrors and registrations.
Branch: feature/legacy-discovery-and-parity-980
Issue: #980

## Scope

Native files edited or added by P15-T3 through P15-T11, taken from the branch
history of `.claude/lib`, `.claude/hooks`, `.claude/agents`, `.codex`, `.github/hooks`,
`.github/agents` and `schemas/discovery`:

- Eleven `.claude/lib/discovery-validation` modules (DiscoveryAuthority.psd1,
  DiscoveryAuthorization, DiscoveryCapability, DiscoveryObservation, DiscoveryPayload,
  DiscoveryPlanning, DiscoveryRootGrant, DiscoveryStart, DiscoveryStartRecord,
  DiscoveryStop, DiscoveryToolRouting), each mirrored to
  `extensions/drm-copilot/resources/lib/discovery-validation/` (the Codex shared
  library published as `.codex/lib/discovery-validation/`) and to
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/discovery-validation/`.
- Five `.claude/hooks`, five `.codex/hooks` and six `.github/hooks` files (including
  `discovery.json`), each mirrored to its bundle.
- The three `discovery-capability-sentinel` agent files, each mirrored to its bundle.
- `.claude/settings.json` and `.codex/config.toml` (unchanged in Phase 15; compared
  for completeness).
- The three changed v2 schemas (host-observation, root-grant, tool-authorization),
  compared against the staged copies under
  `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/`.

## Changes made in this task

- `tests/scripts/dev_tools/test_discovery_publication_contracts.py`: `SHARED_HELPERS`
  gains `DiscoveryObservation.psm1`, `DiscoveryRootGrant.psm1` and
  `DiscoveryToolRouting.psm1`. Both pack manifests already listed the three modules,
  the sentinel agent files and every hook, so no manifest entry was added.
- `extensions/drm-copilot/resources/lib/discovery-validation/DiscoveryValidation.psm1`
  removed. Decision recorded: this compatibility module is Claude-only
  (`CLAUDE_ONLY_HELPERS`); the Codex manifest never listed a
  `.codex/lib/discovery-validation/DiscoveryValidation.psm1` path, and the copy had
  been introduced by the Phase 15 mirror step (first appearing at the P15-T4 commit),
  so it was a stray file rather than a registration. The SCRATCH mirror script now
  skips it for the shared library.
- Schemas: the pack manifests carry no schema entries by design (schemas publish
  through the discovery runtime resource staging, `build_discovery_runtime
  --stage-only`, which P15-T12 to P15-T15 regenerated), so no schema entry was
  added to a manifest; the staged copies are compared below instead.
- Codex core manifest: the repository has no generator that writes
  `pack-manifests/core.json`; the manifest is maintained directly and its closure is
  verified by `test_codex_core_manifest_closure.py`, which passes below. The
  generator check named by the plan (`generate_codex_agent_variants --check`) was run.

## Byte comparison

Timestamp: 2026-10-30T00:23Z
Command: `sh SCRATCH/issue-980-p15t22-cmp.sh` (`cmp -s` of each source against each mirror listed above)
EXIT_CODE: 0
Output Summary: `PAIRS=46 CMP_STATUS=0 (0 = every mirror byte-identical)`; every pair printed `SAME`; no `DIFF` line; the stray-file check printed nothing.

## Suites

Timestamp: 2026-10-30T00:22Z
Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py tests/scripts/dev_tools/test_discovery_publication_contracts.py -p no:cacheprovider -q`
EXIT_CODE: 0
Output Summary: `82 passed in 1.04s` (before this task the same set reported `1 failed, 36 passed` on the publication suite alone, failing `test_native_hooks_and_helpers_are_published_and_listed` on the shared-library inventory).

Timestamp: 2026-10-30T00:22Z
Command: `pwsh` Pester over `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` (through SCRATCH/issue-980-pester.sh)
EXIT_CODE: 0
Output Summary: `Tests Passed: 3, Failed: 0, Skipped: 0`

Timestamp: 2026-10-30T00:22Z
Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
EXIT_CODE: 0
Output Summary: empty output (no drift).

Timestamp: 2026-10-30T00:22Z
Command: `poetry run black`, `poetry run ruff check`, `poetry run pyright` on tests/scripts/dev_tools/test_discovery_publication_contracts.py
EXIT_CODE: 0 (each)
Output Summary: `1 file left unchanged.`; `All checks passed!`; `0 errors, 0 warnings, 0 informations`.

Result: PASS
