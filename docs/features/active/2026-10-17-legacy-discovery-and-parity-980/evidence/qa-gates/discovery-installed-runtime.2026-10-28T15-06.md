# P12-T12 Installed runtime verification of the Phase 12 packages

Timestamp: 2026-10-28T15-06
Task: [P12-T12] Observe the completion-receipt path on every supported host.
Command: `SCRATCH/issue-980-p12t11-wheel.sh` (P10-T3 build sequence: `build_discovery_runtime --check`, `--stage-only`, `--check`, build, determinism rerun), `SCRATCH/issue-980-p12t11-packages.sh` (`npm run compile`, `vsce package`, `npm run build`, `npm pack` into `SCRATCH/stage/`), `SCRATCH/issue-980-reinstall-wheel.sh`, `SCRATCH/issue-980-smoke-layout.sh`, the probe, hook, MCP-client and gateway launchers named in `discovery-native-capabilities.2026-10-28T15-06.md`, `SCRATCH/issue-980-p12t12-static2.sh`, `SCRATCH/issue-980-p12t12-pytests2.sh`, `SCRATCH/issue-980-p12t12-ts-static.sh`, `node run-jest.cjs <six suites>`, PoshQC format/analyze and `SCRATCH/issue-980-p12t12-{pssa,pester}.sh`; logs `SCRATCH/issue-980-p12t12-*.log`
EXIT_CODE: 0 for every build, install, layout, static and test stage listed below; the operational exits are in the native-capabilities record
Output Summary: The wheel `drm_copilot_discovery-2.0.0-py3-none-any.whl` (SHA-256 `dca943beac79dab5486cd27adbd96ca3d207d755d73af8e8068aee728e10c096`, installed runtime identity build `2b7d5215b1dd41cdea87424fedb7c7b0f1b25697989675d1ee87bcf832db3b4d`, policy `aa2349b3f387f27175c27e9a2de9477b50490ce5ba03345b3054b412ffe48958`, policy version 2), the standalone MCP package `@danmoisan/drm-copilot-mcp@1.1.22` (tarball SHA-256 `7cc66e5e08a9bbff710c51d5234a30a6851761f2b0042c041b5cfe0737d9a40b`) and the extension VSIX 1.1.22 (SHA-256 `bc33e8055b35742d115e6f2a58c08928b3cef423379cf98a9ca56574c36381ce`) were rebuilt from the final sources of this task after the seven installed-host repairs, installed into the issue-scoped locations under `SCRATCH/install/` with no checkout on any import path, and exercised through the published probes, hooks, MCP server and gateway module as real processes. The complete completion-receipt chain passed on Claude Code, Codex and the Copilot Local harness against this build; the P11-T7 receipt-path blocker is closed. These digests supersede the P12-T11 digests (wheel `59652fe9…`, VSIX `834cb081…`, npm `1bebefbc…`), which were built before the repairs; the handoff `## Built artifacts` table was updated.
Result: PASS

## Build and install sequence

| Step | Command | Exit | Observed |
| --- | --- | --- | --- |
| wheel check (stale) | `build_discovery_runtime --check` | 1 | expected: the staged manifest predates the repaired sources |
| wheel stage / check / build / determinism rerun | `--stage-only`, `--check`, build, `--stage-only` | 0 / 0 / 0 / 0 | `_build_manifest.json` regenerated (build `2b7d5215…`, policy `aa2349b3…`, resource manifest `64574adb…`, wheel `dca943be…`); the rerun reproduced the same identity |
| wheel reinstall | `pip install --force-reinstall --no-deps <wheel>` into `SCRATCH/install/venv` and `SCRATCH/install/workspace/.venv` | 0 / 0 | installed `dev.discovery.doctor` reports build `2b7d5215…`, policy `aa2349b3…`, policy version 2 |
| extension compile / VSIX | `npm run compile`, `vsce package` | 0 / 0 | `SCRATCH/stage/drm-copilot.vsix` `bc33e805…` |
| MCP build / pack | `npm run build`, `npm pack` | 0 / 0 | `SCRATCH/stage/danmoisan-drm-copilot-mcp-1.1.22.tgz` `7cc66e5e…` |
| MCP install / layouts | `npm install --prefix SCRATCH/install/mcp <tgz>`, `issue-980-smoke-layout.sh` | 0 / 0 | server `out/mcp-server.js` from the installed tarball (`drmCopilotExtension` 1.1.22); `.claude/`, `.codex/`, `.github/` of the smoke workspace replaced from the installed resources |
| probes against the final identity | three `discovery-capability-probe.ps1` runs with `SCRATCH/smoke/runtime.json` | 0 / 0 / 0 | supported; attestations `capability-33629883f41f0616dc27`, `capability-4296338b6d96588972de`, `capability-5b2b611cec9b7a19bb66` |

The wheel was rebuilt three times during the task (after repairs 1 and 6, and after repair 7); the host packages twice (after repairs 2/3 and after repair 5). Every rebuild was followed by a reinstall, a doctor identity check, a layout re-push and a re-probe before the next host chain; only chains taken on the final build are counted as evidence in the native-capabilities record.

## Operational observation

Recorded in `discovery-native-capabilities.2026-10-28T15-06.md`: the receipt chain, the negative controls, the gateway refusals, the seven repaired defects and the host-state cleanup.

## Toolchain on the touched files and suites (full loops repeat in Phase 13)

- Python: `black` (`profile_v2.py`, `agent_output.py`, `service.py`, `test_profile_v2.py`, `test_agent_output_manifest.py`, `test_service_finalization.py`) unchanged after formatting; `ruff check` clean; `pyright` 0 errors. Test stage 1 (`test_agent_output_manifest.py`, `test_agent_output.py`, `test_validation_modes.py`, `test_profile_v2.py`, `test_service_finalization.py`, `test_public_host_workflow.py`, before repair 7 and the manifest-test fix): 156 passed, 1 failed (the superseded second manifest test, rewritten and passing alone: 2 passed). Test stage 2 (the same suites plus every `test_service*.py` and `test_gateway*.py`, after repair 7): in progress at the quota checkpoint of 2026-10-28T15-17Z (eighth of ten dot rows, no failure printed); the final count is appended here when the stage completes, and [P12-T12] stays unchecked until then.
- TypeScript (extension): `prettier --write` on the ten touched files (no change), `eslint` clean, `tsc --noEmit` clean for the source and Jest projects; Jest `repo-automation-service-discovery`, `discovery-authorization.binding`, `mcp-tool-inputs-discovery-authority`, `repo-automation-service-discovery-agent`, `discovery-host-workflow`, `discovery-routing`: 6 suites, 193 tests passed.
- PowerShell: PoshQC format (no file changed) and analyze clean; `Invoke-ScriptAnalyzer` on `DiscoveryAuthorization.psm1` and its test: 0 findings; Pester `DiscoveryAuthorization.Tests.ps1` 125 passed, 0 failed; the two resource mirrors are byte-identical to `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1`.

## Deviations recorded for the handoff

- The handoff `## Known installed-host limit` section still describes the P11-T7 blocker; [P12-T13] replaces it with the host-principal documentation.
- The smoke's real protected partition `073304a4b125135a4f7677597e9f1c59aab77313f65c5519aa4d5fb6e140b30e` and the Codex routing attestations under `<UserProfile>/.codex/authority/epic-entry/073304a4…/` were removed after the observations were recorded.
