# P11-T7 Native host capability smoke (installed packages, real host events)

Timestamp: 2026-10-23T13-49
Task: [P11-T7] Verify independent installed runtime and actual native host controls.
Command: `SCRATCH/issue-980-smoke-probes.sh`, `SCRATCH/issue-980-mcp-run.sh mcp-calls-{1,2,3,4}.json`, `SCRATCH/issue-980-smoke-hooks.sh <host> <agent-id>`, `SCRATCH/issue-980-smoke-disabled.sh`, `SCRATCH/issue-980-gateway-one.sh request-finalize.json <principal>`; logs under `SCRATCH/logs/p11t7-smoke-*.log`, `SCRATCH/logs/p11t7-mcp-*.log`, raw hook and probe outputs under `SCRATCH/install/work/`
EXIT_CODE: 0 for every positive control; the expected non-zero exits of every negative control are listed below
Output Summary: Every advertised supported-host control was exercised against the installed packages only (wheel `19e7dd456d854f02503cbfe36cc1b175b1582ee25ce0506beff4c2977121ccdd`, npm tarball `1e1709064ff100e3972738397f8ea1ea6e1690932bf91535b099aa42166eae2a`, VSIX `a3bf8eedd136b8fe23911e259d232d4eccd1a4db3b3aa58f829f0f132acbd52a`, runtime identity build `41962c07af41d7d073b4f85755b3b8131892c1ebb728f9c083869f4fe77a0a0d` / policy `22ea1fc0d8481000e0706006dbf26480c82024651b66b68ea6779db37e3168dc`) with the published probes, hooks and MCP server running as real processes over the real protected store. Positive proof: probe supported and persisted for Claude Code, Codex and GitHub Copilot; host doctor verified by attestation; agent prepared; specialist start attested; read and controlled MCP tools allowed; stop blocked without a receipt. Negative proof: untrusted workspace, missing session context, deactivated workspace, repeat start, nested start, unattributed start, shell and generic write, and a non-host prepare are all refused with typed reasons. Six installed-host defects were found and repaired during the smoke (listed below with their tests). One required installed-host check remains blocked and is reported as an explicit blocker: the installed Python runtime refuses `finalize-agent` and agent-scoped `read-source`, so no completion receipt can be minted and the receipt-dependent stop and stale-receipt controls are proven only by unit tests.
Result: PASS with one explicit blocker (receipt path), see "Blocker"

## Setup

- Smoke workspace: `SCRATCH/install/workspace` (its own Git repository, `src/Orders/OrderService.cs`, `tests/Orders/OrderServiceTests.cs`), initialized, completed, activated and inventoried through the installed console; protected workspace partition `3d76e8e68160b575e68916fe61ec243997655af4410f70818620db74edd7279c` under the real `<LocalAppData>/drm-copilot/discovery/workspaces/` store (PowerShell resolves the store from the platform folder, not from an environment override, so the smoke used the real host store and the partition is removed at the end of the task).
- Host layouts: pushed from the installed npm package resources (`claude-customizations/.claude/{hooks,lib,agents,settings.json}` → `.claude/`, `codex-and-agents-customizations/.codex/{hooks,agents,scripts,config.toml}` plus `lib/{discovery-validation,codex-routing}` → `.codex/`, `customizations/.github/{hooks,agents}` → `.github/`); 71 Claude hooks, 48 Codex hooks, 6 Copilot hooks.
- Interpreter: `SCRATCH/install/workspace/.venv` created with `-I -m venv` and the exact wheel; `sys.path` holds only the base Python installation and the venv (`WORKTREE_ON_PATH=False`); the console sweep's `CHECKOUT_ON_PATH=True` is a false positive of its `'repos' in path` heuristic matching the scratchpad folder name, the printed `sys.path` contains no checkout entry.
- Sessions: one protected session per host (`smoke-claude-code`, `smoke-codex`, `smoke-github-copilot`), plus `smoke-untrusted` and `smoke-disabled`; parent `root-smoke`.

## Probe (capability attestation)

| Host | Probe | Exit | status | Persisted attestation | Notes |
| --- | --- | --- | --- | --- | --- |
| Claude Code | `.claude/hooks/discovery-capability-probe.ps1` | 0 | supported | `sessions/<sha256(smoke-claude-code)>/capability-attestation.json` → `capability-b21d1d64fac880e4a261` | three hashed handlers, seven controls true, sentinel `Bash` denied through the real adapter |
| Codex | `.codex/hooks/discovery-capability-probe.ps1` | 0 | supported | `capability-d09776a7b0654eb9c336` | same |
| GitHub Copilot | `.github/hooks/discovery-capability-probe.ps1` | 0 | supported | `capability-712ecdfca212ac266164` | same |
| Copilot, `-WorkspaceTrusted $false` | same | 1 | unsupported | persisted as unsupported | "Native control workspace_trusted is not available." |
| Claude Code while deactivated | same | 1 | unsupported | persisted as unsupported | "No active protected activation binds this workspace (inactive)." |

The attestation runtime block reproduces the installed identity exactly (`policy_version` as the integer 2).

## Host doctor through the installed MCP server (42 tools listed)

| Context | Finding |
| --- | --- |
| host `claude-code`, session `smoke-claude-code` | `DISCOVERY_ENFORCEMENT_VERIFIED` "Native discovery capability verified by attestation capability-b21d1d64fac880e4a261." |
| host `codex`, session `smoke-codex` | verified by `capability-d09776a7b0654eb9c336` |
| host `github-copilot`, session `smoke-github-copilot` | verified by `capability-712ecdfca212ac266164` |
| host `github-copilot`, session `smoke-untrusted` | two warnings: `(harness-unsupported)` and `(trust-missing)` |
| no `DRM_DISCOVERY_*` context | one warning: `(context-missing): no trusted session context was supplied by the host.` |
| deactivated workspace | one warning: `(activation-unavailable): protected activation could not be read: Protected activation is absent or deactivated for this workspace.` |

## Prepare (root operation)

`prepare_discovery_agent` for `inventory-legacy-system` (selected `legacy-orders`, paths `src`, `tests`, one `inventory-snapshot` expected output, `standalone`, `C1`) prepared `legacy-parity-analyst` invocations `invocation-e96ce0eedb3fb87a0962a5e7d0e13c92` (Claude Code, deployment agent `legacy-parity-analyst`), `invocation-98bb3a2b4d7f51e92040484716b76cc8` (Codex, deployment agent `legacy-parity-analyst-c1`, model `gpt-6-luna`, effort `low`) and `invocation-63146c0361e417dc918e04b59c5ed283` (GitHub Copilot, deployment agent `legacy-parity-analyst`), each writing the protected `invocation.json`, topology and model receipts, required-output manifest and the diagnostic mirror. Negative: under the untrusted session the prepare is refused `DISCOVERY_ENFORCEMENT_UNAVAILABLE: The host does not provide the required discovery controls: the host reported its harness as unsupported.`; without a host context it is refused `Trusted host, session and parent agent identity are required.`

## Start, tool and stop hooks as real processes

Each hook was launched with `pwsh -NoProfile -NonInteractive -File` from the pushed layout, the envelope on stdin and the `DRM_DISCOVERY_*` attribution in the process environment; the Codex `SubagentStart` envelope carries `model` and `turn_id`, the Copilot envelopes use camelCase keys.

| Event | Claude Code | Codex | GitHub Copilot |
| --- | --- | --- | --- |
| ordinary agent start (`atomic-planner`) | skipped (exit 0, no output) | left to the ordinary routing attestation, which blocks `MODEL_ROUTING_ATTESTATION_BLOCKED` without a routing receipt (exit 0) | skipped (exit 0, no output) |
| specialist start (`legacy-parity-analyst[-c1]`) | attested (exit 0, no output; start-attestation written, invocation started) | attested (exit 0) | attested (exit 0) |
| second specialist start, same session | denied `no prepared protected invocation binds agent type … to parent root-smoke in this session` | denied (same reason) | denied (same reason) |
| `Bash` as the attested agent | deny `shell, terminal, exec and evaluation tools are not available to discovery role legacy-parity-analyst (Bash)` | deny (same) | deny (same) |
| `Read` of a source file | allow | allow (silent) | allow |
| `Write` under the inventory root | deny `generic file mutation tool Write is not available … draft mutations go through the controlled discovery tools` | deny (same) | deny (same) |
| `mcp__drm-copilot__run_discovery_repo_inventory` | allow (grant recorded) | allow (silent) | allow |
| `mcp__drm-copilot__read_discovery_source` | allow (grant recorded) | allow (silent) | allow |
| specialist start launched by the attested agent | denied `nested specialists are not attested` | denied (same) | denied (same) |
| stop without a completion receipt | blocked, exit 2: `invocation … was not finalized through finalize_discovery_agent; no output authority exists for this stop` | `{"decision":"block", …}` same reason | `{"decision":"block", …}` same reason |
| start without a parent agent in the environment | denied `the launch context could not be attributed: the native host attested no parent agent for this launch` | denied (same) | denied (same) |
| controlled MCP tool before any start | deny `no started protected invocation is bound to agent … in this session` (Claude Code and Codex observed) | | |

Observation: the Codex ordinary routing hook creates one exclusive routing attestation per transcript and agent; replaying a start with an already used agent id in the same session fails with a raw `Open` exception at exit 2 instead of a typed denial. The clean chain above used unique ids; the pre-existing ordinary hook behavior is recorded here and not changed.

## Disabled and unsupported fail-closed cases

`dev.discovery.configure --deactivate` (exit 0, one confirmed effect, authority invalidated) → probe unsupported "No active protected activation binds this workspace (inactive)." → console doctor "configuration inactive" → MCP doctor `(activation-unavailable)` and `validate_discovery_artifacts` refused `SERVICE_PROFILE` → `configure --activate --profile docs/migration/discovery/domain-profile.yaml` (exit 0) → doctor "configuration active" again. Untrusted workspace: probe unsupported, doctor deficiencies, prepare refused (table above).

## Blocker: completion receipt path unavailable in the installed Python runtime

- `finalize_discovery_agent` through the MCP server as the attested agent (`DRM_DISCOVERY_AGENT_ID=agent-final-1`, role `legacy-parity-analyst`) fails `Result is not a finalize-agent agent-output result for this invocation.`; the installed gateway itself answers the `finalize-agent` request with `SERVICE_IO` exit 3 as `local-user` (the `LocalServiceIO` authority refuses `prepare-agent`/`finalize-agent`) and `SERVICE_FAILURE` exit 3 as `host` (`installed_local_io` raises "Native host capability is unavailable"). `read_discovery_source` with the invocation reference fails `SERVICE_IO` exit 3 for the same reason.
- Consequence: no `validation-receipt` can be minted on an installed host, so the "valid controlled output" stop and the "stale receipt block" controls could not be observed end to end. They are proven only in process by `tests/scripts/claude-lib/discovery-validation/DiscoveryStop.Tests.ps1` (receipt mismatch, stale inputs, output_valid false) and `extensions/drm-copilot/test/discovery-finalization*.test.ts`.
- Classification: an explicit required installed-host check that did not pass. It is carried to the handoff as a blocker; no manual or user QA substitution is claimed.

## Installed-host defects found by this smoke and repaired in this task

| # | Defect observed on the installed host | Repair | Tests |
| --- | --- | --- | --- |
| 1 | `Get-DiscoveryTrustedHostEnvironment` compared omitted `[string]` parameters with `$null`; an omitted value arrives as `""`, so the probe reported `AUTHORITY_STATE_ROOT_MISSING` | `[string]::IsNullOrEmpty` defaults in `DiscoveryAuthority.psm1` and both mirrors | `DiscoveryAuthority.Tests.ps1` "applies the host defaults when the state roots are omitted or empty" |
| 2 | No component wrote `sessions/<session>/capability-attestation.json`; the doctor stayed "not verified" and prepare could never proceed | `Write-DiscoveryCapabilityAttestation` in `DiscoveryCapability.psm1` (exclusive first write, replacement on re-probe), `ReplaceText` seam in `Get-DiscoveryDefaultStore`, called from the three probes; exported from `DiscoveryAuthority.psd1`; mirrors updated | `DiscoveryCapability.Tests.ps1` "capability attestation persistence" (4 tests incl. the start-time `Get-DiscoveryCapabilityMismatch` round trip), the three `discovery-capability.Tests.ps1` persistence tests, `DiscoveryAuthorization.Tests.ps1` seam list |
| 3 | The probes emitted `policy_version` as a string; the TypeScript assessment compares the runtime canonically against the integer the runtime reports (`runtime-mismatch`) | integer `policy_version` in the three probes' `Get-DiscoveryProbeRuntime` (caller JSON and default) | `claude-hooks/discovery-capability.Tests.ps1` type assertions; entrypoint key-order tests unchanged |
| 4 | `DiscoveryServiceBase.runDiscoveryDoctor` projected the capability only with an injected provider; production never injects one, so every installed doctor reported the generic warning | the doctor uses the same lazily created Node provider as prepare/finalize; `missingContextAssessment` answers `context-missing` before any protected path is resolved | `repo-automation-service-discovery.test.ts` "projects the lazily created host provider without an injected one"; existing projection matrix |
| 5 | `buildInvocationDeployment` always named the routed Codex variant (`legacy-parity-analyst-c1`) as `agent_name`; Claude Code and Copilot publish one profile per role, so `Find-DiscoveryPreparedInvocation` never matched and every specialist start was denied | `agent_name` is the routed variant for `codex` and the role for the other hosts | `discovery-routing.test.ts` "names the profile each host launches" |
| 6 | Without `--repository-id` the console and the MCP tools ran with no repository reader and every pinned-source rule failed `REVISION_CONTENT_UNAVAILABLE`/`REVISION_SOURCE_HASH` on a correctly configured workspace; `references.index_references` raised `KeyError` once a validation report had been written (`generate-acceptance` exit 3 "no replacement result") | `repository_binding.py` derives the Git repository from the activated locator and profile when no explicit id is given (explicit id wins and reads nothing); `index_references` indexes only catalog-described kinds, so derived reports neither break nor join the graph | `test_repository_binding.py` (10 cases), `test_gateway.py` binding tests, `test_cli_dry_run.py` identity test, `test_references_reports.py` (5 cases); installed `validate-all --mode structural --dry-run` without `--repository-id` exits 0, `generate-acceptance` returns to its typed `SERVICE_SELECTOR` exit 2 |

## Host state created by the smoke

The real protected partition `3d76e8e68160b575e68916fe61ec243997655af4410f70818620db74edd7279c` under `<LocalAppData>/drm-copilot/discovery/workspaces/` and the Codex routing attestations under `<UserProfile>/.codex/authority/epic-entry/3d76e8e68160b575e68916fe61ec243997655af4410f70818620db74edd7279c/` belong to the smoke workspace only and are removed after this task's evidence is recorded; everything else lives under `SCRATCH`.
