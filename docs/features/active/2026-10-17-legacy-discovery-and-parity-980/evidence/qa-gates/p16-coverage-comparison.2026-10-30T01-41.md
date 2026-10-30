# P16-T4 Coverage comparison for every production file the branch changed

Timestamp: 2026-10-30T01-41
Task: [P16-T4] Verify coverage for every changed file of the branch.
Command: poetry run python SCRATCH/issue-980-p16-compare.py FEATURE/evidence/qa-gates/p16-powershell-coverage.2026-10-30T01-29.xml (the helper reads the P16-T1 JSON, the P16-T2 extension coverage-summary.json and lcov.info, the P16-T3 coverage XML copy and the P0 baselines); git status --porcelain
EXIT_CODE: 0
Output Summary: 274 production files (185 Python, 50 TypeScript, 39 PowerShell), 0 failures. `PORCELAIN_EMPTY=True` (the working tree was clean when the helper ran). `P15_T20_ALL_LISTED=True` (the ten P15-T20 files are listed by name). 3 TypeScript modules are type-only and carry no executable statements; 1 PowerShell module manifest carries no executable code. 203 files are new since the P0 baseline and meet the 90% line floor; every other file meets 85% lines (and 75% branches where branches are measured) with no uncovered changed executable line. No coverage exclusion was added and no threshold was lowered.

## Inputs

- Inventory: `git diff --name-only --diff-filter=AM <merge base> HEAD -- '*.py' '*.ts' '*.psm1' '*.ps1' '*.psd1'`, production files only (tests, test support, `.Tests.ps1` suites and bundled `resources/` copies excluded). The merge base of origin/main and HEAD is the ref the plan names; its value at run time is recorded by the helper (`MERGE_BASE=52587a0eeaa04a0519801452235608a72b5eba5c`) for reproducibility and is not a citation.
- Python final: `p16-python-coverage.2026-10-30T00-42.json` (P16-T1). Python baseline: FEATURE/evidence/baseline/python-coverage.2026-10-18T03-51.json (P0-T2).
- TypeScript final: `p16-typescript-extension-coverage-summary.2026-10-30T01-40.json` and `p16-typescript-extension-lcov.2026-10-30T01-40.info` (P16-T2, the configuration with the per-file threshold map; every changed TypeScript production file is under extensions/drm-copilot/src). TypeScript baseline: FEATURE/evidence/baseline/typescript-extension-coverage-summary.2026-10-18T03-58.json (P0-T3).
- PowerShell final: `p16-powershell-coverage.2026-10-30T01-29.xml` (P16-T3, the single-process run). PowerShell baseline: FEATURE/evidence/baseline/powershell-coverage.2026-10-18T04-22.xml (P0-T4). Pester measures no branch coverage; the branch columns read n/a.
- Changed lines: `git diff -U0 <merge base> HEAD -- <file>`; a Python changed line is executable when it appears in `executed_lines` or `missing_lines`; a TypeScript changed line is executable when the lcov report carries a `DA` record for it; a PowerShell changed line is executable when the JaCoCo report carries a `line` element for it.

## Floors applied

- Every file: lines at least 85%; branches at least 75% for Python and TypeScript.
- New files (added since the merge base and absent at P0): lines at least 90%. Their uncovered lines are listed for transparency; no prior coverage exists for them to regress against.
- Pre-existing files (status M): no uncovered changed executable line (no regression on changed lines).
- "absent at P0": the file did not exist at the P0 baseline, so no P0 delta exists; the regression guard for those files is the changed-line check.

## Repair performed in this task

The first helper run reported two FAIL rows: `extensions/drm-copilot/src/mcp-handlers/discovery-handlers.ts` (the `handleDiscoveryCapabilitySentinel` body, 12 uncovered changed lines) and `extensions/drm-copilot/src/mcp-tools.ts` (the `discovery_capability_sentinel` dispatch case, 4 uncovered changed lines). Two focused tests were added to `extensions/drm-copilot/test/mcp-tools.discovery.test.ts` (the seam receives the raw tool input and the observation is surfaced; a service without the seam fails closed with `DISCOVERY_SENTINEL_UNAVAILABLE`), the P16-T2 loop was repeated (`p16-typescript-*.2026-10-30T01-40.md`) and the helper was re-run on the repeated loop's reports; the table below is that re-run.

## Per-file results

| File | Status since merge base | P0 baseline lines / branches | Final lines / branches | Delta lines / branches | Changed executable lines / covered | Uncovered changed lines | Floor class | Disposition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `.claude/hooks/discovery-capability-probe.ps1` | A | absent at P0 | 96.97% (32/33) / n/a (Pester measures no branches) | n/a (new since P0) | 33 / 32 | [23] | new | PASS |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | M | absent at P0 | 100.00% (33/33) / n/a (Pester measures no branches) | n/a (new since P0) | 23 / 23 | - | changed | PASS |
| `.claude/hooks/enforce-discovery-planning-gate.ps1` | A | absent at P0 | 100.00% (27/27) / n/a (Pester measures no branches) | n/a (new since P0) | 27 / 27 | - | new | PASS |
| `.claude/hooks/record-discovery-agent-start.ps1` | A | absent at P0 | 100.00% (38/38) / n/a (Pester measures no branches) | n/a (new since P0) | 38 / 38 | - | new | PASS |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | M | absent at P0 | 100.00% (32/32) / n/a (Pester measures no branches) | n/a (new since P0) | 20 / 20 | - | changed | PASS |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | M | absent at P0 | 100.00% (68/68) / n/a (Pester measures no branches) | n/a (new since P0) | 0 / 0 | - | changed | PASS |
| `.claude/lib/codex-routing/CodexDiscoveryRouting.psm1` | A | absent at P0 | 100.00% (68/68) / n/a (Pester measures no branches) | n/a (new since P0) | 68 / 68 | - | new | PASS |
| `.claude/lib/codex-routing/CodexTopology.psm1` | M | absent at P0 | 100.00% (112/112) / n/a (Pester measures no branches) | n/a (new since P0) | 3 / 3 | - | changed | PASS |
| `.claude/lib/discovery-validation/DiscoveryAuthority.psd1` | A | manifest | manifest (data file, no executable code; not measured by Pester) | n/a | 0 / 0 | - | n/a | N/A (module manifest) |
| `.claude/lib/discovery-validation/DiscoveryAuthority.psm1` | A | absent at P0 | 94.56% (139/147) / n/a (Pester measures no branches) | n/a (new since P0) | 147 / 139 | [77, 78, 79, 362, 393, 397, 444, 445] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1` | A | absent at P0 | 95.68% (177/185) / n/a (Pester measures no branches) | n/a (new since P0) | 185 / 177 | [171, 180, 182, 183, 184, 188, 247, 403] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryCapability.psm1` | A | absent at P0 | 99.43% (174/175) / n/a (Pester measures no branches) | n/a (new since P0) | 175 / 174 | [219] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` | A | absent at P0 | 93.48% (43/46) / n/a (Pester measures no branches) | n/a (new since P0) | 46 / 43 | [72, 73, 75] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryManifest.psm1` | A | absent at P0 | 93.94% (124/132) / n/a (Pester measures no branches) | n/a (new since P0) | 132 / 124 | [69, 108, 109, 122, 149, 213, 297, 298] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryObservation.psm1` | A | absent at P0 | 100.00% (65/65) / n/a (Pester measures no branches) | n/a (new since P0) | 65 / 65 | - | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryPayload.psm1` | A | absent at P0 | 100.00% (88/88) / n/a (Pester measures no branches) | n/a (new since P0) | 88 / 88 | - | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryPlanning.psm1` | A | absent at P0 | 97.69% (127/130) / n/a (Pester measures no branches) | n/a (new since P0) | 130 / 127 | [250, 257, 263] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryRootGrant.psm1` | A | absent at P0 | 100.00% (49/49) / n/a (Pester measures no branches) | n/a (new since P0) | 49 / 49 | - | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryStart.psm1` | A | absent at P0 | 97.86% (137/140) / n/a (Pester measures no branches) | n/a (new since P0) | 140 / 137 | [109, 129, 377] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1` | A | absent at P0 | 95.10% (97/102) / n/a (Pester measures no branches) | n/a (new since P0) | 102 / 97 | [263, 265, 266, 267, 271] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryStop.psm1` | A | absent at P0 | 97.04% (131/135) / n/a (Pester measures no branches) | n/a (new since P0) | 135 / 131 | [286, 312, 314, 315] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryToolRouting.psm1` | A | absent at P0 | 98.59% (70/71) / n/a (Pester measures no branches) | n/a (new since P0) | 71 / 70 | [200] | new | PASS |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | M | absent at P0 | 100.00% (78/78) / n/a (Pester measures no branches) | n/a (new since P0) | 56 / 56 | - | changed | PASS |
| `.codex/hooks/codex-agent-profile-attestation.ps1` | M | absent at P0 | 94.19% (81/86) / n/a (Pester measures no branches) | n/a (new since P0) | 6 / 6 | - | changed | PASS |
| `.codex/hooks/discovery-capability-probe.ps1` | A | absent at P0 | 96.43% (27/28) / n/a (Pester measures no branches) | n/a (new since P0) | 28 / 27 | [23] | new | PASS |
| `.codex/hooks/discovery-start-attestation.ps1` | A | absent at P0 | 100.00% (76/76) / n/a (Pester measures no branches) | n/a (new since P0) | 76 / 76 | - | new | PASS |
| `.codex/hooks/enforce-codex-model-routing.ps1` | M | absent at P0 | 100.00% (78/78) / n/a (Pester measures no branches) | n/a (new since P0) | 1 / 1 | - | changed | PASS |
| `.codex/hooks/enforce-discovery-artifact-gate.ps1` | A | absent at P0 | 100.00% (55/55) / n/a (Pester measures no branches) | n/a (new since P0) | 55 / 55 | - | new | PASS |
| `.codex/hooks/enforce-discovery-planning-gate.ps1` | A | absent at P0 | 100.00% (48/48) / n/a (Pester measures no branches) | n/a (new since P0) | 48 / 48 | - | new | PASS |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | M | absent at P0 | 92.82% (194/209) / n/a (Pester measures no branches) | n/a (new since P0) | 5 / 5 | - | changed | PASS |
| `.codex/hooks/validate-codex-subagent-routing.ps1` | M | absent at P0 | 100.00% (73/73) / n/a (Pester measures no branches) | n/a (new since P0) | 6 / 6 | - | changed | PASS |
| `.codex/hooks/validate-discovery-agent-output.ps1` | A | absent at P0 | 100.00% (56/56) / n/a (Pester measures no branches) | n/a (new since P0) | 56 / 56 | - | new | PASS |
| `.codex/scripts/Resolve-CodexTopology.ps1` | M | absent at P0 | 100.00% (46/46) / n/a (Pester measures no branches) | n/a (new since P0) | 7 / 7 | - | changed | PASS |
| `.github/hooks/discovery-agent-start.ps1` | A | absent at P0 | 100.00% (34/34) / n/a (Pester measures no branches) | n/a (new since P0) | 34 / 34 | - | new | PASS |
| `.github/hooks/discovery-agent-stop.ps1` | A | absent at P0 | 100.00% (39/39) / n/a (Pester measures no branches) | n/a (new since P0) | 39 / 39 | - | new | PASS |
| `.github/hooks/discovery-capability-probe.ps1` | A | absent at P0 | 96.43% (27/28) / n/a (Pester measures no branches) | n/a (new since P0) | 28 / 27 | [24] | new | PASS |
| `.github/hooks/discovery-planning.ps1` | A | absent at P0 | 100.00% (25/25) / n/a (Pester measures no branches) | n/a (new since P0) | 25 / 25 | - | new | PASS |
| `.github/hooks/discovery-pre-tool.ps1` | A | absent at P0 | 100.00% (30/30) / n/a (Pester measures no branches) | n/a (new since P0) | 30 / 30 | - | new | PASS |
| `extensions/drm-copilot/src/discovery-artifact-command-registration.ts` | A | absent at P0 | 100% (140/140) / 100% (28/28) | n/a (new since P0) | 140 / 140 | - | new | PASS |
| `extensions/drm-copilot/src/discovery-authority-paths.ts` | A | absent at P0 | 98.11% (364/371) / 97.4% (75/77) | n/a (new since P0) | 371 / 364 | [142, 143, 220, 221, 222, 223, 224] | new | PASS |
| `extensions/drm-copilot/src/discovery-authority-provider.ts` | A | absent at P0 | 100% (125/125) / 100% (23/23) | n/a (new since P0) | 125 / 125 | - | new | PASS |
| `extensions/drm-copilot/src/discovery-authority-record.ts` | A | absent at P0 | 99.23% (258/260) / 98.5% (66/67) | n/a (new since P0) | 260 / 258 | [221, 222] | new | PASS |
| `extensions/drm-copilot/src/discovery-authority.ts` | A | absent at P0 | 98.22% (387/394) / 96.15% (75/78) | n/a (new since P0) | 394 / 387 | [258, 259, 260, 261, 262, 317, 318] | new | PASS |
| `extensions/drm-copilot/src/discovery-authorization-binding.ts` | A | absent at P0 | 97.26% (249/256) / 95.55% (43/45) | n/a (new since P0) | 256 / 249 | [101, 102, 180, 181, 182, 183, 184] | new | PASS |
| `extensions/drm-copilot/src/discovery-authorization-record.ts` | A | absent at P0 | 99.14% (466/470) / 97.46% (77/79) | n/a (new since P0) | 470 / 466 | [316, 317, 321, 322] | new | PASS |
| `extensions/drm-copilot/src/discovery-authorization.ts` | A | absent at P0 | 96.66% (348/360) / 96.66% (58/60) | n/a (new since P0) | 360 / 348 | [304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315] | new | PASS |
| `extensions/drm-copilot/src/discovery-capabilities.ts` | A | absent at P0 | 100% (480/480) / 98.05% (101/103) | n/a (new since P0) | 480 / 480 | - | new | PASS |
| `extensions/drm-copilot/src/discovery-capability-record.ts` | A | absent at P0 | 99.37% (317/319) / 98.21% (55/56) | n/a (new since P0) | 319 / 317 | [166, 167] | new | PASS |
| `extensions/drm-copilot/src/discovery-command-registration.ts` | M | 90.65% / 78.18% | 100% (142/142) / 100% (27/27) | +9.35 / +21.82 | 78 / 78 | - | changed | PASS |
| `extensions/drm-copilot/src/discovery-finalization.ts` | A | absent at P0 | 99.29% (422/425) / 98.59% (70/71) | n/a (new since P0) | 425 / 422 | [385, 386, 387] | new | PASS |
| `extensions/drm-copilot/src/discovery-input-manifest.ts` | A | absent at P0 | 99.47% (379/381) / 98.79% (82/83) | n/a (new since P0) | 381 / 379 | [117, 118] | new | PASS |
| `extensions/drm-copilot/src/discovery-invocation-record.ts` | A | absent at P0 | 100% (217/217) / 100% (30/30) | n/a (new since P0) | 217 / 217 | - | new | PASS |
| `extensions/drm-copilot/src/discovery-invocation.ts` | A | absent at P0 | 99.33% (447/450) / 96% (48/50) | n/a (new since P0) | 450 / 447 | [257, 258, 259] | new | PASS |
| `extensions/drm-copilot/src/discovery-result.ts` | A | absent at P0 | 100% (386/386) / 97.05% (99/102) | n/a (new since P0) | 386 / 386 | - | new | PASS |
| `extensions/drm-copilot/src/discovery-root-grant.ts` | A | absent at P0 | 99.35% (309/311) / 98.48% (65/66) | n/a (new since P0) | 311 / 309 | [235, 236] | new | PASS |
| `extensions/drm-copilot/src/discovery-routing.ts` | A | absent at P0 | 98.48% (455/462) / 97.5% (78/80) | n/a (new since P0) | 462 / 455 | [242, 243, 244, 245, 246, 261, 262] | new | PASS |
| `extensions/drm-copilot/src/discovery-runtime.ts` | A | absent at P0 | 97.13% (339/349) / 95.38% (62/65) | n/a (new since P0) | 349 / 339 | [187, 190, 191, 192, 193, 194, 195, 196, 200, 201] | new | PASS |
| `extensions/drm-copilot/src/discovery-sentinel.ts` | A | absent at P0 | 98.64% (291/295) / 96.55% (56/58) | n/a (new since P0) | 295 / 291 | [218, 219, 229, 230] | new | PASS |
| `extensions/drm-copilot/src/discovery-service-types.ts` | A | type-only | type-only (0 executable statements) | n/a | 0 / 0 | - | n/a | N/A (type-only module) |
| `extensions/drm-copilot/src/discovery-workspace-command-registration.ts` | A | absent at P0 | 100% (264/264) / 100% (58/58) | n/a (new since P0) | 264 / 264 | - | new | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/classifier-claude.ts` | M | 100% / 100% | 100% (307/307) / 100% (40/40) | +0.00 / +0.00 | 55 / 55 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/classifier.ts` | M | 98.63% / 94.44% | 98.87% (352/356) / 95.34% (41/43) | +0.24 / +0.90 | 62 / 62 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts` | M | 98.08% / 87.71% | 98.1% (310/316) / 87.71% (50/57) | +0.02 / +0.00 | 2 / 2 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/mapping.ts` | M | 99.1% / 94.87% | 99.19% (246/248) / 95.12% (39/41) | +0.09 / +0.25 | 25 / 25 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/pipeline-render.ts` | M | 93.71% / 79.54% | 93.8% (348/371) / 77.77% (35/45) | +0.09 / -1.77 | 5 / 5 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/rewrites-rules.ts` | M | 100% / 100% | 100% (349/349) / 100% (14/14) | +0.00 / +0.00 | 25 / 25 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/rewrites.ts` | M | 100% / 100% | 100% (179/179) / 100% (19/19) | +0.00 / +0.00 | 2 / 2 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` | M | 98.87% / 95.31% | 98.97% (387/391) / 95.65% (66/69) | +0.10 / +0.34 | 38 / 38 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` | M | 97.99% / 86.66% | 97.99% (440/449) / 86.66% (39/45) | +0.00 / +0.00 | 1 / 1 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/validate/codex-discovery-routing.ts` | A | absent at P0 | 99.2% (251/253) / 96.66% (29/30) | n/a (new since P0) | 253 / 251 | [231, 232] | new | PASS |
| `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` | M | 97.4% / 94.73% | 97.87% (323/330) / 95.16% (59/62) | +0.47 / +0.43 | 63 / 63 | - | changed | PASS |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` | M | 95.68% / 94.16% | 95.7% (468/489) / 94.35% (117/124) | +0.02 / +0.19 | 2 / 2 | - | changed | PASS |
| `extensions/drm-copilot/src/mcp-discovery-authority-tool-definitions.ts` | A | absent at P0 | 100% (320/320) / 100% (1/1) | n/a (new since P0) | 320 / 320 | - | new | PASS |
| `extensions/drm-copilot/src/mcp-discovery-authorization-gate.ts` | A | absent at P0 | 99.56% (230/231) / 96.22% (51/53) | n/a (new since P0) | 231 / 230 | [118] | new | PASS |
| `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts` | M | 100% / 100% | 100% (385/385) / 100% (1/1) | +0.00 / +0.00 | 250 / 250 | - | changed | PASS |
| `extensions/drm-copilot/src/mcp-handlers/discovery-handlers.ts` | M | 100% / 100% | 100% (190/190) / 100% (27/27) | +0.00 / +0.00 | 166 / 166 | - | changed | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs-discovery-authority.ts` | A | absent at P0 | 100% (335/335) / 100% (50/50) | n/a (new since P0) | 335 / 335 | - | new | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs-discovery-shared.ts` | A | absent at P0 | 100% (124/124) / 100% (37/37) | n/a (new since P0) | 124 / 124 | - | new | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs-discovery.ts` | M | 100% / 96.87% | 100% (428/428) / 100% (41/41) | +0.00 / +3.13 | 323 / 323 | - | changed | PASS |
| `extensions/drm-copilot/src/mcp-tools.ts` | M | 94.73% / 88.4% | 95.87% (442/461) / 91.48% (86/94) | +1.14 / +3.08 | 100 / 100 | - | changed | PASS |
| `extensions/drm-copilot/src/repo-automation-execute-discovery.ts` | M | 97.13% / 83.87% | 100% (446/446) / 100% (49/49) | +2.87 / +16.13 | 341 / 341 | - | changed | PASS |
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` | M | type-only | type-only (0 executable statements) | n/a | 0 / 0 | - | n/a | N/A (type-only module) |
| `extensions/drm-copilot/src/repo-automation-service-discovery-agent.ts` | A | absent at P0 | 92.85% (338/364) / 91.66% (44/48) | n/a (new since P0) | 364 / 338 | [85, 86, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117] | new | PASS |
| `extensions/drm-copilot/src/repo-automation-service-discovery-identity.ts` | A | absent at P0 | 100% (101/101) / 100% (12/12) | n/a (new since P0) | 101 / 101 | - | new | PASS |
| `extensions/drm-copilot/src/repo-automation-service-discovery-types.ts` | A | type-only | type-only (0 executable statements) | n/a | 0 / 0 | - | n/a | N/A (type-only module) |
| `extensions/drm-copilot/src/repo-automation-service-discovery.ts` | A | absent at P0 | 99.17% (483/487) / 94.64% (53/56) | n/a (new since P0) | 487 / 483 | [151, 152, 153, 154] | new | PASS |
| `extensions/drm-copilot/src/repo-automation-service.ts` | M | 98.39% / 94.11% | 98.22% (442/450) / 93.18% (41/44) | -0.17 / -0.93 | 10 / 10 | - | changed | PASS |
| `extensions/drm-copilot/src/repo-automation-tool-names.ts` | M | 100% / 100% | 100% (47/47) / 100% (0/0) | +0.00 / +0.00 | 12 / 12 | - | changed | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/__init__.py` | A | absent at P0 | 100.00% (4/4) / 100.00% (0/0) | n/a (new since P0) | 4 / 4 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation.py` | A | absent at P0 | 97.92% (141/144) / 95.65% (44/46) | n/a (new since P0) | 144 / 141 | [298, 348, 353] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation_context.py` | A | absent at P0 | 98.40% (184/187) / 95.16% (59/62) | n/a (new since P0) | 187 / 184 | [53, 169, 383] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_models.py` | A | absent at P0 | 100.00% (180/180) / 100.00% (82/82) | n/a (new since P0) | 180 / 180 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_render_text.py` | A | absent at P0 | 95.74% (90/94) / 92.00% (46/50) | n/a (new since P0) | 94 / 90 | [107, 135, 139, 144] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_rules.py` | A | absent at P0 | 98.68% (149/151) / 96.05% (73/76) | n/a (new since P0) | 151 / 149 | [169, 265] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py` | A | absent at P0 | 100.00% (102/102) / 100.00% (30/30) | n/a (new since P0) | 102 / 102 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/activation_models.py` | A | absent at P0 | 100.00% (28/28) / 100.00% (4/4) | n/a (new since P0) | 28 / 28 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py` | A | absent at P0 | 100.00% (162/162) / 100.00% (58/58) | n/a (new since P0) | 162 / 162 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py` | A | absent at P0 | 99.29% (140/141) / 98.53% (67/68) | n/a (new since P0) | 141 / 140 | [203] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/__init__.py` | A | absent at P0 | 100.00% (3/3) / 100.00% (0/0) | n/a (new since P0) | 3 / 3 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_access.py` | A | absent at P0 | 100.00% (91/91) / 100.00% (30/30) | n/a (new since P0) | 91 / 91 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_syntax.py` | A | absent at P0 | 100.00% (115/115) / 100.00% (64/64) | n/a (new since P0) | 115 / 115 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/com_interop.py` | A | absent at P0 | 100.00% (121/121) / 100.00% (46/46) | n/a (new since P0) | 121 / 121 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/com_syntax.py` | A | absent at P0 | 100.00% (85/85) / 100.00% (42/42) | n/a (new since P0) | 85 / 85 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration.py` | A | absent at P0 | 100.00% (89/89) / 100.00% (32/32) | n/a (new since P0) | 89 / 89 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration_input.py` | A | absent at P0 | 98.53% (201/204) / 93.33% (84/90) | n/a (new since P0) | 204 / 201 | [324, 382, 386] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_declarations.py` | A | absent at P0 | 100.00% (174/174) / 100.00% (98/98) | n/a (new since P0) | 174 / 174 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_tokens.py` | A | absent at P0 | 98.98% (97/98) / 97.92% (47/48) | n/a (new since P0) | 98 / 97 | [149] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependencies.py` | A | absent at P0 | 100.00% (149/149) / 100.00% (62/62) | n/a (new since P0) | 149 / 149 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_dotnet.py` | A | absent at P0 | 100.00% (141/141) / 100.00% (72/72) | n/a (new since P0) | 141 / 141 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_inputs.py` | A | absent at P0 | 100.00% (174/174) / 100.00% (74/74) | n/a (new since P0) | 174 / 174 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_node.py` | A | absent at P0 | 100.00% (103/103) / 100.00% (52/52) | n/a (new since P0) | 103 / 103 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_python.py` | A | absent at P0 | 100.00% (156/156) / 100.00% (86/86) | n/a (new since P0) | 156 / 156 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_values.py` | A | absent at P0 | 100.00% (101/101) / 100.00% (68/68) | n/a (new since P0) | 101 / 101 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_inventory.py` | A | absent at P0 | 100.00% (137/137) / 100.00% (36/36) | n/a (new since P0) | 137 / 137 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_projects.py` | A | absent at P0 | 100.00% (126/126) / 100.00% (50/50) | n/a (new since P0) | 126 / 126 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py` | A | absent at P0 | 100.00% (100/100) / 100.00% (48/48) | n/a (new since P0) | 100 / 100 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/event_subscriptions.py` | A | absent at P0 | 100.00% (47/47) / 100.00% (28/28) | n/a (new since P0) | 47 / 47 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/filesystem_access.py` | A | absent at P0 | 100.00% (11/11) / 100.00% (0/0) | n/a (new since P0) | 11 / 11 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py` | A | absent at P0 | 100.00% (22/22) / 100.00% (2/2) | n/a (new since P0) | 22 / 22 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py` | A | absent at P0 | 100.00% (112/112) / 100.00% (46/46) | n/a (new since P0) | 112 / 112 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py` | A | absent at P0 | 100.00% (80/80) / 100.00% (22/22) | n/a (new since P0) | 80 / 80 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py` | A | absent at P0 | 100.00% (109/109) / 100.00% (24/24) | n/a (new since P0) | 109 / 109 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/__init__.py` | A | absent at P0 | 100.00% (0/0) / 100.00% (0/0) | n/a (new since P0) | 0 / 0 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_office.py` | A | absent at P0 | 100.00% (127/127) / 100.00% (34/34) | n/a (new since P0) | 127 / 127 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_patterns.py` | A | absent at P0 | 100.00% (16/16) / 100.00% (0/0) | n/a (new since P0) | 16 / 16 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_syntax.py` | A | absent at P0 | 100.00% (162/162) / 100.00% (92/92) | n/a (new since P0) | 162 / 162 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py` | A | absent at P0 | 100.00% (70/70) / 100.00% (18/18) | n/a (new since P0) | 70 / 70 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py` | A | absent at P0 | 100.00% (80/80) / 100.00% (38/38) | n/a (new since P0) | 80 / 80 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry_access.py` | A | absent at P0 | 100.00% (9/9) / 100.00% (0/0) | n/a (new since P0) | 9 / 9 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/solution_input.py` | A | absent at P0 | 100.00% (63/63) / 100.00% (34/34) | n/a (new since P0) | 63 / 63 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/source_text.py` | A | absent at P0 | 100.00% (145/145) / 100.00% (50/50) | n/a (new since P0) | 145 / 145 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_reference_syntax.py` | A | absent at P0 | 98.39% (61/62) / 97.37% (37/38) | n/a (new since P0) | 62 / 61 | [55] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_references.py` | A | absent at P0 | 98.12% (157/160) / 94.83% (55/58) | n/a (new since P0) | 160 / 157 | [257, 358, 392] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/ui_callbacks.py` | A | absent at P0 | 100.00% (164/164) / 100.00% (58/58) | n/a (new since P0) | 164 / 164 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/xml_input.py` | A | absent at P0 | 100.00% (101/101) / 100.00% (32/32) | n/a (new since P0) | 101 / 101 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/build_identity.py` | A | absent at P0 | 100.00% (225/225) / 100.00% (96/96) | n/a (new since P0) | 225 / 225 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/catalog.py` | A | absent at P0 | 100.00% (187/187) / 100.00% (86/86) | n/a (new since P0) | 187 / 187 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/claim_rules.py` | A | absent at P0 | 99.22% (127/128) / 97.22% (70/72) | n/a (new since P0) | 128 / 127 | [301] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/cli.py` | A | absent at P0 | 100.00% (147/147) / 100.00% (12/12) | n/a (new since P0) | 147 / 147 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/cli_arguments.py` | A | absent at P0 | 100.00% (182/182) / 100.00% (70/70) | n/a (new since P0) | 182 / 182 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/cli_commands.py` | A | absent at P0 | 100.00% (41/41) / 100.00% (10/10) | n/a (new since P0) | 41 / 41 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/completion_report.py` | A | absent at P0 | 100.00% (95/95) / 100.00% (24/24) | n/a (new since P0) | 95 / 95 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py` | A | absent at P0 | 100.00% (72/72) / 100.00% (46/46) | n/a (new since P0) | 72 / 72 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/configuration.py` | A | absent at P0 | 100.00% (123/123) / 100.00% (48/48) | n/a (new since P0) | 123 / 123 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/coverage_population.py` | A | absent at P0 | 98.26% (113/115) / 92.00% (46/50) | n/a (new since P0) | 115 / 113 | [238, 278] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/coverage_report.py` | A | absent at P0 | 100.00% (111/111) / 100.00% (26/26) | n/a (new since P0) | 111 / 111 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/coverage_rules.py` | A | absent at P0 | 100.00% (106/106) / 100.00% (62/62) | n/a (new since P0) | 106 / 106 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/coverage_scope_rules.py` | A | absent at P0 | 100.00% (142/142) / 100.00% (78/78) | n/a (new since P0) | 142 / 142 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/decision_rules.py` | A | absent at P0 | 100.00% (183/183) / 100.00% (76/76) | n/a (new since P0) | 183 / 183 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/dimension_rules.py` | A | absent at P0 | 100.00% (98/98) / 100.00% (32/32) | n/a (new since P0) | 98 / 98 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/doctor.py` | A | absent at P0 | 100.00% (142/142) / 100.00% (42/42) | n/a (new since P0) | 142 / 142 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/domain_profile.py` | A | absent at P0 | 99.51% (202/203) / 98.78% (81/82) | n/a (new since P0) | 203 / 202 | [89] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/domain_profile_models.py` | A | absent at P0 | 100.00% (55/55) / 100.00% (14/14) | n/a (new since P0) | 55 / 55 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py` | A | absent at P0 | 99.17% (119/120) / 97.37% (37/38) | n/a (new since P0) | 120 / 119 | [145] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py` | A | absent at P0 | 100.00% (50/50) / 100.00% (14/14) | n/a (new since P0) | 50 / 50 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py` | A | absent at P0 | 100.00% (108/108) / 100.00% (38/38) | n/a (new since P0) | 108 / 108 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/evidence_rules.py` | A | absent at P0 | 100.00% (110/110) / 100.00% (42/42) | n/a (new since P0) | 110 / 110 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/extension_inputs.py` | A | absent at P0 | 100.00% (187/187) / 100.00% (76/76) | n/a (new since P0) | 187 / 187 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/extension_results.py` | A | absent at P0 | 100.00% (122/122) / 100.00% (46/46) | n/a (new since P0) | 122 / 122 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/extension_validation.py` | A | absent at P0 | 100.00% (214/214) / 100.00% (102/102) | n/a (new since P0) | 214 / 214 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/findings.py` | A | absent at P0 | 100.00% (78/78) / 97.22% (35/36) | n/a (new since P0) | 78 / 78 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway.py` | A | absent at P0 | 99.31% (144/145) / 100.00% (36/36) | n/a (new since P0) | 145 / 144 | [320] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host.py` | A | absent at P0 | 96.24% (128/133) / 91.67% (11/12) | n/a (new since P0) | 133 / 128 | [193, 194, 215, 298, 299] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host_baseline.py` | A | absent at P0 | 96.30% (78/81) / 90.00% (27/30) | n/a (new since P0) | 81 / 78 | [98, 105, 189] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host_reads.py` | A | absent at P0 | 100.00% (34/34) / 100.00% (8/8) | n/a (new since P0) | 34 / 34 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host_store.py` | A | absent at P0 | 90.00% (27/30) / 83.33% (5/6) | n/a (new since P0) | 30 / 27 | [60, 82, 83] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py` | A | absent at P0 | 99.32% (146/147) / 97.50% (39/40) | n/a (new since P0) | 147 / 146 | [157] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gherkin.py` | A | absent at P0 | 99.32% (147/148) / 98.28% (57/58) | n/a (new since P0) | 148 / 147 | [257] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py` | A | absent at P0 | 98.53% (134/136) / 94.44% (34/36) | n/a (new since P0) | 136 / 134 | [97, 122] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/init_io.py` | A | absent at P0 | 97.86% (137/140) / 94.00% (47/50) | n/a (new since P0) | 140 / 137 | [200, 221, 271] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/init_models.py` | A | absent at P0 | 100.00% (30/30) / 100.00% (0/0) | n/a (new since P0) | 30 / 30 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py` | A | absent at P0 | 100.00% (178/178) / 100.00% (60/60) | n/a (new since P0) | 178 / 178 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/io.py` | A | absent at P0 | 100.00% (16/16) / 100.00% (2/2) | n/a (new since P0) | 16 / 16 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/migration_capture.py` | A | absent at P0 | 96.67% (116/120) / 90.91% (40/44) | n/a (new since P0) | 120 / 116 | [45, 76, 83, 119] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/migration_conversion.py` | A | absent at P0 | 100.00% (76/76) / 100.00% (26/26) | n/a (new since P0) | 76 / 76 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/migration_models.py` | A | absent at P0 | 100.00% (96/96) / 100.00% (22/22) | n/a (new since P0) | 96 / 96 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/migration_v1.py` | A | absent at P0 | 100.00% (131/131) / 100.00% (46/46) | n/a (new since P0) | 131 / 131 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/models.py` | A | absent at P0 | 100.00% (84/84) / 100.00% (36/36) | n/a (new since P0) | 84 / 84 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py` | A | absent at P0 | 99.04% (207/209) / 94.44% (51/54) | n/a (new since P0) | 209 / 207 | [243, 409] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py` | A | absent at P0 | 99.26% (135/136) / 97.22% (35/36) | n/a (new since P0) | 136 / 135 | [384] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py` | A | absent at P0 | 98.60% (211/214) / 96.88% (93/96) | n/a (new since P0) | 214 / 211 | [118, 158, 330] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/operation_grants.py` | A | absent at P0 | 96.15% (25/26) / 91.67% (11/12) | n/a (new since P0) | 26 / 25 | [75] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/operations.py` | A | absent at P0 | 100.00% (153/153) / 100.00% (38/38) | n/a (new since P0) | 153 / 153 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_entry_rules.py` | A | absent at P0 | 98.56% (137/139) / 94.64% (53/56) | n/a (new since P0) | 139 / 137 | [268, 321] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py` | A | absent at P0 | 100.00% (151/151) / 91.07% (51/56) | n/a (new since P0) | 151 / 151 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_models.py` | A | absent at P0 | 100.00% (35/35) / 100.00% (0/0) | n/a (new since P0) | 35 / 35 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py` | A | absent at P0 | 100.00% (45/45) / 100.00% (8/8) | n/a (new since P0) | 45 / 45 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py` | A | absent at P0 | 100.00% (104/104) / 100.00% (38/38) | n/a (new since P0) | 104 / 104 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py` | A | absent at P0 | 100.00% (99/99) / 98.00% (49/50) | n/a (new since P0) | 99 / 99 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parsing.py` | A | absent at P0 | 97.09% (200/206) / 97.67% (84/86) | n/a (new since P0) | 206 / 200 | [230, 231, 260, 261, 407, 408] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/path_models.py` | A | absent at P0 | 100.00% (98/98) / 100.00% (34/34) | n/a (new since P0) | 98 / 98 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py` | A | absent at P0 | 100.00% (161/161) / 100.00% (86/86) | n/a (new since P0) | 161 / 161 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/profile_models.py` | A | absent at P0 | 100.00% (173/173) / 100.00% (20/20) | n/a (new since P0) | 173 / 173 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/profile_v2.py` | A | absent at P0 | 100.00% (153/153) / 100.00% (36/36) | n/a (new since P0) | 153 / 153 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/protected_records.py` | A | absent at P0 | 96.40% (107/111) / 96.15% (50/52) | n/a (new since P0) | 111 / 107 | [108, 266, 269, 270] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/reference_links.py` | A | absent at P0 | 100.00% (93/93) / 97.06% (66/68) | n/a (new since P0) | 93 / 93 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/references.py` | A | absent at P0 | 98.84% (170/172) / 97.62% (82/84) | n/a (new since P0) | 172 / 170 | [200, 335] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/rendering.py` | A | absent at P0 | 100.00% (15/15) / 100.00% (2/2) | n/a (new since P0) | 15 / 15 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/report_models.py` | A | absent at P0 | 100.00% (138/138) / 100.00% (64/64) | n/a (new since P0) | 138 / 138 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/report_rendering.py` | A | absent at P0 | 100.00% (17/17) / 100.00% (4/4) | n/a (new since P0) | 17 / 17 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/repository_binding.py` | A | absent at P0 | 100.00% (49/49) / 100.00% (12/12) | n/a (new since P0) | 49 / 49 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/repository_reader.py` | A | absent at P0 | 100.00% (83/83) / 100.00% (24/24) | n/a (new since P0) | 83 / 83 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/resources.py` | A | absent at P0 | 100.00% (103/103) / 100.00% (34/34) | n/a (new since P0) | 103 / 103 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/revision_rules.py` | A | absent at P0 | 99.47% (186/187) / 98.15% (106/108) | n/a (new since P0) | 187 / 186 | [344] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/runtime_claim_rules.py` | A | absent at P0 | 97.83% (90/92) / 91.67% (55/60) | n/a (new since P0) | 92 / 90 | [109, 126] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/schema_validation.py` | A | absent at P0 | 100.00% (146/146) / 100.00% (60/60) | n/a (new since P0) | 146 / 146 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service.py` | A | absent at P0 | 99.18% (121/122) / 96.67% (29/30) | n/a (new since P0) | 122 / 121 | [304] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py` | A | absent at P0 | 95.50% (106/111) / 82.14% (23/28) | n/a (new since P0) | 111 / 106 | [92, 159, 231, 265, 326] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py` | A | absent at P0 | 100.00% (132/132) / 100.00% (26/26) | n/a (new since P0) | 132 / 132 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_finalization.py` | A | absent at P0 | 95.45% (42/44) / 87.50% (14/16) | n/a (new since P0) | 44 / 42 | [83, 85] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py` | A | absent at P0 | 99.17% (120/121) / 97.06% (33/34) | n/a (new since P0) | 121 / 120 | [113] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_mutations.py` | A | absent at P0 | 100.00% (96/96) / 100.00% (40/40) | n/a (new since P0) | 96 / 96 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_preparation.py` | A | absent at P0 | 95.00% (57/60) / 95.00% (19/20) | n/a (new since P0) | 60 / 57 | [66, 67, 133] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py` | A | absent at P0 | 100.00% (84/84) / 100.00% (28/28) | n/a (new since P0) | 84 / 84 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py` | A | absent at P0 | 97.33% (73/75) / 96.55% (56/58) | n/a (new since P0) | 75 / 73 | [211, 302] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_selection.py` | A | absent at P0 | 99.14% (115/116) / 98.00% (49/50) | n/a (new since P0) | 116 / 115 | [202] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_serialization.py` | A | absent at P0 | 100.00% (154/154) / 100.00% (56/56) | n/a (new since P0) | 154 / 154 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/snapshot.py` | A | absent at P0 | 100.00% (116/116) / 100.00% (28/28) | n/a (new since P0) | 116 / 116 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/snapshot_inventory_inputs.py` | A | absent at P0 | 100.00% (22/22) / 100.00% (14/14) | n/a (new since P0) | 22 / 22 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/snapshot_io.py` | A | absent at P0 | 100.00% (186/186) / 100.00% (88/88) | n/a (new since P0) | 186 / 186 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/snapshot_loading.py` | A | absent at P0 | 100.00% (204/204) / 98.31% (116/118) | n/a (new since P0) | 204 / 204 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/source_read_models.py` | A | absent at P0 | 100.00% (200/200) / 100.00% (72/72) | n/a (new since P0) | 200 / 200 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/source_reads.py` | A | absent at P0 | 100.00% (209/209) / 100.00% (104/104) | n/a (new since P0) | 209 / 209 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py` | A | absent at P0 | 98.68% (150/152) / 96.15% (50/52) | n/a (new since P0) | 152 / 150 | [181, 253] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py` | A | absent at P0 | 97.39% (112/115) / 93.75% (45/48) | n/a (new since P0) | 115 / 112 | [126, 143, 158] | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/validation.py` | A | absent at P0 | 100.00% (89/89) / 100.00% (44/44) | n/a (new since P0) | 89 / 89 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py` | A | absent at P0 | 100.00% (51/51) / 100.00% (22/22) | n/a (new since P0) | 51 / 51 | - | new | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/validation_operation.py` | A | absent at P0 | 100.00% (98/98) / 100.00% (22/22) | n/a (new since P0) | 98 / 98 | - | new | PASS |
| `scripts/dev-tools/Test-DiscoveryHostCapability.ps1` | A | absent at P0 | 95.24% (20/21) / n/a (Pester measures no branches) | n/a (new since P0) | 21 / 20 | [32] | new | PASS |
| `scripts/dev_tools/_codex_discovery_routing.py` | A | absent at P0 | 100.00% (70/70) / 100.00% (20/20) | n/a (new since P0) | 70 / 70 | - | new | PASS |
| `scripts/dev_tools/agentic_sync.py` | M | 87.22% / 62.50% | 98.02% (99/101) / 94.12% (32/34) | +10.80 / +31.62 | 9 / 9 | - | changed | PASS |
| `scripts/dev_tools/agentic_sync_artifacts.py` | A | absent at P0 | 100.00% (58/58) / 100.00% (2/2) | n/a (new since P0) | 58 / 58 | - | new | PASS |
| `scripts/dev_tools/agentic_sync_filesystem.py` | A | absent at P0 | 100.00% (33/33) / 100.00% (6/6) | n/a (new since P0) | 33 / 33 | - | new | PASS |
| `scripts/dev_tools/build_discovery_runtime.py` | A | absent at P0 | 100.00% (225/225) / 100.00% (102/102) | n/a (new since P0) | 225 / 225 | - | new | PASS |
| `scripts/dev_tools/codex_native_converter/classifier.py` | M | 92.94% / 88.64% | 96.88% (62/64) / 94.12% (32/34) | +3.93 / +5.48 | 13 / 13 | - | changed | PASS |
| `scripts/dev_tools/codex_native_converter/classifier_claude.py` | A | absent at P0 | 93.02% (40/43) / 90.00% (18/20) | n/a (new since P0) | 43 / 40 | [76, 77, 273] | new | PASS |
| `scripts/dev_tools/codex_native_converter/inventory.py` | M | 95.56% / 90.00% | 97.78% (44/45) / 95.00% (19/20) | +2.22 / +5.00 | 0 / 0 | - | changed | PASS |
| `scripts/dev_tools/codex_native_converter/mapping.py` | M | 93.75% / 87.50% | 96.36% (53/55) / 92.31% (24/26) | +2.61 / +4.81 | 7 / 7 | - | changed | PASS |
| `scripts/dev_tools/codex_native_converter/pipeline.py` | M | 94.57% / 83.33% | 95.74% (90/94) / 88.64% (39/44) | +1.18 / +5.30 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/codex_native_converter/rewrites.py` | M | 91.30% / 85.71% | 90.24% (37/41) / 80.00% (8/10) | -1.06 / -5.71 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/codex_native_converter/rewrites_detection.py` | A | absent at P0 | 100.00% (9/9) / 100.00% (4/4) | n/a (new since P0) | 9 / 9 | - | new | PASS |
| `scripts/dev_tools/discovery/__init__.py` | M | 100.00% / 100.00% | 100.00% (2/2) / 100.00% (0/0) | +0.00 / +0.00 | 1 / 1 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/__init__.py` | M | 100.00% / 100.00% | 100.00% (11/11) / 100.00% (4/4) | +0.00 / +0.00 | 3 / 3 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/cli.py` | M | 100.00% / 100.00% | 100.00% (19/19) / 100.00% (4/4) | +0.00 / +0.00 | 15 / 15 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | M | 96.83% / 90.91% | 100.00% (2/2) / 100.00% (0/0) | +3.17 / +9.09 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/emitter.py` | M | 100.00% / 100.00% | 100.00% (2/2) / 100.00% (0/0) | +0.00 / +0.00 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/inventory.py` | M | 100.00% / 100.00% | 100.00% (6/6) / 100.00% (0/0) | +0.00 / +0.00 | 6 / 6 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/models.py` | M | 100.00% / 100.00% | 100.00% (8/8) / 100.00% (0/0) | +0.00 / +0.00 | 8 / 8 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/pipeline.py` | M | 100.00% / 100.00% | 100.00% (4/4) / 100.00% (0/0) | +0.00 / +0.00 | 4 / 4 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/source_text.py` | M | 100.00% / 96.15% | 100.00% (8/8) / 100.00% (0/0) | +0.00 / +3.85 | 8 / 8 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/stack_cli.py` | M | 94.23% / 100.00% | 100.00% (7/7) / 100.00% (0/0) | +5.77 / +0.00 | 3 / 3 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_office.py` | M | 97.76% / 93.33% | 100.00% (52/52) / 100.00% (8/8) | +2.24 / +6.67 | 46 / 46 | - | changed | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_patterns.py` | M | 100.00% / 100.00% | 100.00% (8/8) / 100.00% (2/2) | +0.00 / +0.00 | 7 / 7 | - | changed | PASS |
| `scripts/dev_tools/discovery/completion_report.py` | M | 92.16% / 100.00% | 100.00% (65/65) / 100.00% (10/10) | +7.84 / +0.00 | 31 / 31 | - | changed | PASS |
| `scripts/dev_tools/discovery/coverage_report.py` | M | 95.00% / 100.00% | 100.00% (50/50) / 100.00% (8/8) | +5.00 / +0.00 | 24 / 24 | - | changed | PASS |
| `scripts/dev_tools/discovery/domain_profile.py` | M | 99.47% / 98.72% | 100.00% (2/2) / 100.00% (0/0) | +0.53 / +1.28 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/discovery/domain_profile_models.py` | M | 100.00% / 100.00% | 100.00% (2/2) / 100.00% (0/0) | +0.00 / +0.00 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/discovery/init_cli.py` | M | 100.00% / 100.00% | 100.00% (13/13) / 100.00% (0/0) | +0.00 / +0.00 | 3 / 3 | - | changed | PASS |
| `scripts/dev_tools/discovery/init_flow.py` | M | 100.00% / 100.00% | 100.00% (2/2) / 100.00% (0/0) | +0.00 / +0.00 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/discovery/init_models.py` | M | 100.00% / 100.00% | 100.00% (5/5) / 100.00% (0/0) | +0.00 / +0.00 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/discovery/io.py` | M | 100.00% / 100.00% | 100.00% (2/2) / 100.00% (0/0) | +0.00 / +0.00 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/discovery/parity_report.py` | M | 95.00% / 100.00% | 100.00% (50/50) / 100.00% (8/8) | +5.00 / +0.00 | 24 / 24 | - | changed | PASS |
| `scripts/dev_tools/discovery/profile_cli.py` | M | 100.00% / 100.00% | 100.00% (36/36) / 100.00% (6/6) | +0.00 / +0.00 | 3 / 3 | - | changed | PASS |
| `scripts/dev_tools/discovery/rendering.py` | M | 100.00% / 100.00% | 100.00% (2/2) / 100.00% (0/0) | +0.00 / +0.00 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/discovery_build_identity.py` | A | absent at P0 | 100.00% (101/101) / 100.00% (36/36) | n/a (new since P0) | 101 / 101 | - | new | PASS |
| `scripts/dev_tools/generate_acceptance_scenarios.py` | M | 100.00% / 100.00% | 100.00% (75/75) / 100.00% (0/0) | +0.00 / +0.00 | 24 / 24 | - | changed | PASS |
| `scripts/dev_tools/generate_codex_agent_variants.py` | M | 94.53% / 89.13% | 94.57% (122/129) / 89.13% (41/46) | +0.04 / +0.00 | 1 / 1 | - | changed | PASS |
| `scripts/dev_tools/push_down_codex_and_agents_customizations.py` | M | 98.04% / 85.71% | 98.17% (107/109) / 88.89% (16/18) | +0.13 / +3.17 | 7 / 7 | - | changed | PASS |
| `scripts/dev_tools/quality_tiers_contract.py` | M | 100.00% / 100.00% | 100.00% (191/191) / 100.00% (78/78) | +0.00 / +0.00 | 2 / 2 | - | changed | PASS |
| `scripts/dev_tools/resolve_codex_deployment.py` | M | 100.00% / 100.00% | 100.00% (83/83) / 100.00% (18/18) | +0.00 / +0.00 | 0 / 0 | - | changed | PASS |
| `scripts/dev_tools/resolve_codex_topology.py` | M | 100.00% / 100.00% | 100.00% (105/105) / 100.00% (36/36) | +0.00 / +0.00 | 6 / 6 | - | changed | PASS |
| `scripts/dev_tools/validate_discovery_artifacts.py` | M | 98.36% / 100.00% | 100.00% (103/103) / 100.00% (32/32) | +1.64 / +0.00 | 64 / 64 | - | changed | PASS |
| `scripts/dev_tools/validate_discovery_profile.py` | M | 100.00% / 100.00% | 100.00% (18/18) / 100.00% (6/6) | +0.00 / +0.00 | 16 / 16 | - | changed | PASS |
| `scripts/dev_tools/validate_discovery_schema_artifacts.py` | M | 100.00% / 100.00% | 100.00% (33/33) / 100.00% (2/2) | +0.00 / +0.00 | 19 / 19 | - | changed | PASS |

Result: PASS
