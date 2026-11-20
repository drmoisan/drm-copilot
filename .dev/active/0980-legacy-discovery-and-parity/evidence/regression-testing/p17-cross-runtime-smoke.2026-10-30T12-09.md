# P17-T5 Cross-runtime sentinel consumption smoke over one real filesystem store

Timestamp: 2026-10-30T12-09
Task: [P17-T5] Run the cross-runtime consumption smoke over one real filesystem store under SCRATCH.
Command: sh SCRATCH/issue-980-p17-smoke.sh (three steps below, logged to SCRATCH/issue-980-p17-smoke.log; the store root is SCRATCH/issue-980-p17-state, created before step one and deleted after step three)
EXIT_CODE: 0 (step one), 0 (tsc emit), 0 (step two), 0 (step three)
Output Summary: Run at 2026-10-30T12-08 UTC on the P17-T4 head with `git status --porcelain` empty. Session `p17-smoke-20261030T120845`. Step one (PowerShell, branch modules) recorded the fixture tool envelope as `allow`/`SENTINEL` with `state` `issued` and the fixture shell envelope as `deny`/`SHELL` through `Get-DiscoverySentinelDecision` over `Get-DiscoveryDefaultStore`, into the real store partition `sessions/<sha256(session)>/observations/`. Step two (Node, per-file `tsc` emit of extensions/drm-copilot/src under SCRATCH/issue-980-p17-out) called `consumeSentinelGrant` with `createNodeAuthorizationStoreIO()` and `resolveAuthorityLocation` over the same workspace root, user home and local application data root and the same `workspace_root` input: the first call returned `observed: true` with `observationRef` `observation-9d1e601211b5b2e4eebc`, `agentIdPresent` true and `agentType` `discovery-capability-sentinel`; the second call returned `observed: false`. Step three (PowerShell) ran `Get-DiscoveryCapabilityObservation` with the default store, this worktree's registration and handler bytes, the smoke session and the same location: `trusted_attribution` true, `forbidden_tools_denied` true, `probe.result` `denied`, `probe.sentinel_id` `observation-9d1e601211b5b2e4eebc`, `probe.evidence_ref` `observation-096157b85914eda38ead`. The attestation status is `unsupported` with the single finding "No active protected activation binds this workspace (missing)", because the smoke activates nothing; every control the task names holds. The store held exactly three files at the end: the two observation records and the `.consumed` latch beside the tool record, and no record was rewritten (step one reported `state` `issued`; the consumer writes only the latch).
Result: PASS

## Steps

| Step | Runtime | Command shape | Exit | Observed values |
| --- | --- | --- | --- | --- |
| 1 | PowerShell 7, branch `.claude/lib/discovery-validation` modules | `Resolve-DiscoveryAuthorityLocation` for this worktree as workspace root, platform `windows`, the user home and SCRATCH/issue-980-p17-state as local application data; `Get-DiscoverySentinelDecision` over `Get-DiscoveryDefaultStore` for the fixture tool and shell envelopes with the smoke session, this worktree as `cwd` and as the sentinel `workspace_root` input, the SHA-256 of `.claude/hooks/enforce-discovery-artifact-gate.ps1` as the handler hash and `[datetime]::UtcNow` as `Now` | 0 | tool: `allow`, `SENTINEL`, `observation-9d1e601211b5b2e4eebc`, `state` `issued`; shell: `deny`, `SHELL`, `observation-096157b85914eda38ead` |
| emit | `npx tsc -p tsconfig.json --outDir SCRATCH/issue-980-p17-out --sourceMap false` in extensions/drm-copilot | 0 | per-file CommonJS emit of the extension sources |
| 2 | Node, SCRATCH/issue-980-p17-smoke-step2.cjs loading `discovery-sentinel.js`, `discovery-authorization.js` and `discovery-authority-paths.js` from the emit | 0 | first `consumeSentinelGrant`: `observed` true, `observationRef` `observation-9d1e601211b5b2e4eebc`, `agentIdPresent` true, `agentType` `discovery-capability-sentinel`; second: `observed` false |
| 3 | PowerShell 7, `Get-DiscoveryCapabilityObservation -HostName claude-code` with the default store, the worktree registration and handler bytes (default `ReadBytes`), the smoke session and the same host environment | 0 | `trusted_attribution` true, `forbidden_tools_denied` true, `probe.result` `denied`, `probe.evidence_ref` `observation-096157b85914eda38ead`; status `unsupported` for the missing activation only |

Both runtimes resolved the same authority directory (`drm-copilot/discovery/workspaces/0a00160052dfcee84f12df9a9b8cfcdde1c2dedd8ace3ebd457a161fa9c1b2c3` under the state root), so the TypeScript scan found the PowerShell-written record by path, and the PowerShell probe read the TypeScript-written latch by path. The references equal the fixture's because the fixture tool-call identifiers were replayed; the session partition differs because the smoke session is fresh.

## Real-host pre-mortem rows closed

- Real store listing order, CRLF from `ConvertTo-Json` and the `.consumed` sibling: the Node consumer filtered the `.json` names and read the sibling by path; the PowerShell probe parsed the CRLF record text and the LF latch text.
- Shared digest for one input: the gate digest (PowerShell) matched the consumer digest (TypeScript) for `{workspace_root: <worktree>}`, otherwise the first consume would have reported `observed: false`.
- Shared partition and reference derivation: both sides derived the same session partition and the TypeScript lookup found the gate-derived reference.
- Latch content shape: the probe parsed only `observation_ref` from the millisecond-precision latch the consumer wrote.
- Handler hash after push-down: the probe compared the gate-recorded hash with the hash of the registered handler file in this worktree (equal); installed copies are covered by P17-T6 and P18-T5 mirror parity.

## Cleanup

SCRATCH/issue-980-p17-state was removed after step three (`STATE_REMOVED=yes`); the emit under SCRATCH/issue-980-p17-out is scratch and is not committed. No scratch path or host path is recorded in this file beyond the token `SCRATCH`.
