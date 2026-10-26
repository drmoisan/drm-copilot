# P11-T7 Independent installed runtime verification

Timestamp: 2026-10-23T14-13
Task: [P11-T7] Verify independent installed runtime and actual native host controls.
Command: `poetry run python -m scripts.dev_tools.build_discovery_runtime` (wheel and `_build_manifest.json`), `node SCRATCH/issue-980-p10t2-build.cjs` (VSIX and npm tarball), `SCRATCH/issue-980-install.sh`, `SCRATCH/issue-980-install-mcp.sh`, `SCRATCH/issue-980-smoke-workspace.sh`, `SCRATCH/issue-980-smoke-layout.sh`, `SCRATCH/issue-980-console-sweep.sh`, `SCRATCH/issue-980-smoke-console.sh`, `SCRATCH/issue-980-mcp-run.sh mcp-calls-{1,4}.json`; logs under `SCRATCH/logs/p11t7-*.log`, raw outputs under `SCRATCH/install/work/`
EXIT_CODE: 0 for the build, install, layout and sweep steps; the operational smoke exits are listed per step below
Output Summary: The exact wheel `drm_copilot_discovery-2.0.0-py3-none-any.whl` (SHA-256 `19e7dd456d854f02503cbfe36cc1b175b1582ee25ce0506beff4c2977121ccdd`, installed runtime identity build `41962c07af41d7d073b4f85755b3b8131892c1ebb728f9c083869f4fe77a0a0d`, policy `22ea1fc0d8481000e0706006dbf26480c82024651b66b68ea6779db37e3168dc`, policy version 2), the standalone MCP package `@danmoisan/drm-copilot-mcp@1.1.22` (tarball SHA-256 `1e1709064ff100e3972738397f8ea1ea6e1690932bf91535b099aa42166eae2a`) and the extension VSIX (SHA-256 `a3bf8eedd136b8fe23911e259d232d4eccd1a4db3b3aa58f829f0f132acbd52a`) were built from the final sources of this task and installed into issue-scoped locations under `SCRATCH/install/` with no checkout on any import path. All 31 console entries answer `--help` with exit 0 and the package ships its 40 resource files (33 schemas, 6 templates). The operational console smoke, the gateway module and the 42 standalone MCP tools behave as the public contracts state: positives exit 0, honest failures exit 1 and refusals exit 2 with typed findings. The native-host controls are recorded separately in `discovery-native-capabilities.2026-10-23T13-49.md`; that record also lists the six installed-host defects this smoke found and repaired and the one explicit blocker (the installed Python runtime cannot mint a completion receipt).
Result: PASS (installed behavior has no checkout dependency) with the receipt-path blocker carried to the handoff

## Isolation of the installed interpreter

- `SCRATCH/install/venv` and `SCRATCH/install/workspace/.venv` were created with `python -I -m venv --clear` from the repository interpreter and received only the wheel (`pip install --no-cache-dir <wheel>`, exit 0). The installed package resolves from `…/venv/Lib/site-packages/drm_copilot_discovery/__init__.py`.
- `sys.path` of the isolated interpreter contains only the base Python installation (`python313.zip`, `DLLs`, `Lib`, the installation root) and the venv (`venv`, `venv/Lib/site-packages`); `WORKTREE_ON_PATH=False`. The sweep's `CHECKOUT_ON_PATH=True` line is a false positive of its `'repos' in path` heuristic, which matches the scratchpad folder name; the printed path list holds no checkout entry.
- Every console and gateway process was started with `-I` from `SCRATCH/install/work`, never from the checkout.

## Console entry sweep (31 entries)

`dev.discovery.{init, configure, profile, inventory, dotnet, vsto, new-contract, new-scenario, update-artifact, link-evidence, validate-profile, validate-feature-contract, validate-coverage-ledger, validate-runtime-scenario, validate-parity-matrix, validate-unspecified-behavior, validate-product-decision, validate-evidence-reference, validate-decisions, validate-all, validate, coverage-report, parity-report, completion-report, generate-acceptance, generate-acceptance-scenarios, snapshot-export, snapshot-import, import-inventory, migrate, doctor}` (the `ENTRY` lines of `SCRATCH/logs/p11t7-console-sweep.log`): 31 of 31 exit 0 on `--help` with fixed help text. Resources enumerated through `importlib.resources`: 40 files, 33 `*.schema.json`, 6 templates.

## Operational console smoke (fresh Git workspace `SCRATCH/install/workspace`)

| Step | Command (installed entry) | Exit | Observed |
| --- | --- | --- | --- |
| doctor-before | `dev.discovery.doctor` | 0 | runtime verified, configuration active (from the earlier activation of the same workspace), native capability unavailable for the local-user principal by contract |
| init-dry-run / init-write / init-repeat | `dev.discovery.init --system-id legacy-orders --role legacy-source --repository-id legacy-orders --production-root src --test-root tests [--dry-run]` | 0 / 0 / 0 | planned structure; written once; repeat never overwrites |
| profile-complete | `SCRATCH/issue-980-complete-profile.py` | 0 | profile set to `configured` with the `orders-target` modernization target bound to client `browser` |
| configure-activate | `dev.discovery.configure --activate --profile docs/migration/discovery/domain-profile.yaml` | 0 | protected activation written |
| doctor-after / validate-profile | `doctor`, `validate-profile` | 0 / 0 | configuration active; profile valid |
| inventory-dry-run / inventory-write | `dev.discovery.inventory [--write]` | 0 / 1 | the dry run plans the pinned inventory; the write is refused `REPORT_RESULT` because a validation report written by an earlier non-dry-run `validate_discovery_artifacts` call no longer agrees with the recomputed inputs (honest stale-report refusal; a re-validation rewrites the report) |
| validate-structural / validate-discovery-complete | `dev.discovery.validate-all --mode structural --dry-run`, `--mode discovery-complete --dry-run` | 0 / 1 | structural passes; discovery-complete fails honestly with `ACCEPTANCE_SCOPE` (zero features) and `COVERAGE_INVENTORY` |
| coverage-report / completion-report / parity-report | `dev.discovery.{coverage,completion,parity}-report` | 0 / 1 / 0 | completion fails honestly on the same incomplete workspace |
| generate-acceptance | `dev.discovery.generate-acceptance --kind legacy-characterization --output-format markdown` | 2 | typed `SERVICE_SELECTOR` (no captured feature); before the `references.py` repair this step exited 3 with "Discovery CLI failed; no replacement result was emitted" once a validation report existed |
| validate-decisions / validate-dispatch | `validate-decisions`, `validate --mode structural --dry-run` | 0 / 0 | |
| snapshot-export-negative / migrate-dry | `snapshot-export` without selection, `migrate` with invalid options | 2 / 2 | `SERVICE_SELECTION`, `CLI_ARGUMENTS` |
| gateway-doctor / gateway-validate | `python -I -m drm_copilot_discovery.gateway --workspace-root <canonical> --principal local-user --repository-id legacy-orders` with the service-request documents | 0 / 0 | one JSON result each |
| validate-all without `--repository-id` | `dev.discovery.validate-all --mode structural --dry-run` | 0 | no findings: the repository reader is derived from the activated profile (new `repository_binding.py`); before the repair every pinned-source rule failed `REVISION_CONTENT_UNAVAILABLE`/`REVISION_SOURCE_HASH` |

## Standalone MCP server over stdio (`out/mcp-server.js` from the installed tarball)

`initialize` (protocol 2025-06-18, server `drmCopilotExtension` 1.1.22), `tools/list` → 42 tools. Root principal (no `DRM_DISCOVERY_*` context): `run_discovery_doctor` ok with the `context-missing` projection; `validate_discovery_artifacts` (all, structural) "Operation passed." with the two report artifacts; `validate_discovery_artifacts` (discovery-complete) `isError` exit 1 `ACCEPTANCE_SCOPE`; `run_discovery_repo_inventory` (dry run) "Operation passed." with the planned inventory snapshot; `run_discovery_report` (coverage) "Operation passed." writing `reports/coverage-report.json`; `read_discovery_source` (list `src`) "Operation passed."; `prepare_discovery_agent` refused "Trusted host, session and parent agent identity are required." The host-principal calls (doctor projection, prepare, finalize, agent-scoped read) are in the native-capabilities record.

## Extension commands

The VSIX was built (`npm run compile`, `vsce package`) and is not launched headlessly; the justified extension command surface is proven by the extension's own Jest suites run on the final sources (`extension.discovery-commands.test.ts` and the MCP tool suites, in the 312-suite run below).

## Toolchain reruns on the final sources of this task

- Python: `black --check .` 946 files unchanged; `ruff check .` clean; `pyright` (whole project) 0 errors; targeted suites for the repaired modules pass (`test_repository_binding.py`, `test_gateway.py`, `test_cli_dry_run.py`, `test_cli_errors.py`, `test_gateway_local.py`, `test_gateway_factory.py`: 240 passed; `test_references_reports.py`, `test_references.py`, `test_reference_uniqueness.py`, `test_service_selection.py`, `test_acceptance_generation.py`, `test_completion_projection.py`, `test_evidence_linking.py`, `test_agent_output.py`, `test_service_mutation_guards.py`: 228 passed). The complete `tests` population with branch coverage is recorded in `p11t7-python-tests.2026-10-26T02-32.md` (15504 passed, 6 skipped, 96.68% lines, 93.61% branches, threshold check passed).
- TypeScript (extension): `prettier --write` on the touched files (no further change), `eslint` clean, `tsc --noEmit` clean, `node run-jest.cjs --coverage --randomize --seed=980` 312 suites / 4997 tests passed, lines 97.15% (59775/61525), branches 93.53% (9056/9682), every per-file threshold satisfied.
- PowerShell: PoshQC format (no file changed), PSScriptAnalyzer no findings, full Pester stage in the CI shape 12138 passed / 0 failed / 10 pre-existing skips, line coverage 93.13% (19520/20959 over 240 files); the probe, capability, authority and authorization suites also ran in a single process (143 passed) after the last PowerShell change.
- Wheel rebuild after every Python change regenerated `_build_manifest.json`; the installed doctor verified the new identity each time (the attestations were re-probed against the final identity before the final hook chain).

## Deviations recorded for the handoff

- Receipt path blocker (see the native-capabilities record): `finalize-agent` and agent-scoped `read-source` are refused by the installed Python runtime for both principals, so no completion receipt exists on an installed host; the receipt-dependent stop and stale-receipt controls are unit-proven only.
- The P10-T2/P10-T3 package digests are superseded by the artifacts built in this task (listed above); P11-T8 and P11-T10 reconcile the publication record.
- The smoke left the real protected partition `3d76e8e68160b575e68916fe61ec243997655af4410f70818620db74edd7279c` and the matching Codex routing attestations on the host; `SCRATCH/issue-980-clean-host-state.ps1` removes them after the evidence is committed.
