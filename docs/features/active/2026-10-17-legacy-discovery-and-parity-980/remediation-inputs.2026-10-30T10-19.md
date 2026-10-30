# Remediation Inputs — feature review cycle 1, 2026-10-30T10-19 (issue #980)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Timestamp: 2026-10-30T10-19
Branch: `feature/legacy-discovery-and-parity-980`, head `7d9191e9d7ff3084bc8ffc828d21fe402de1af22`
Base for diffs: `52587a0eeaa04a0519801452235608a72b5eba5c` (merge base with `origin/main`; `origin/main` is at `318ef3e93`, so a rebase is also due before the PR)
Source artifacts:
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/policy-audit.2026-10-30T10-19.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/code-review.2026-10-30T10-19.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/feature-audit.2026-10-30T10-19.md`

Every finding of the 2026-10-29T13-16 review (R1 to R4, the Major and the Minors) is verified resolved in code. One new blocking finding was introduced by the remediation; it is confined to two production files, their mirrors and tests.

## Blocking findings

### R5 — Sentinel observation consumption contract differs between the TypeScript consumer and the PowerShell probe

Remediability: autonomous
Remediability-Evidence: The producer, the consumer and the reader of the record are all in the branch diff with existing tests and mirrors; the fix is a one-sided alignment plus a contract test, and the user's design decisions already fix which records carry identity, so no further decision is needed.

- Files: `extensions/drm-copilot/src/discovery-sentinel.ts` lines 252-295 (`consumeSentinelGrant`); `.claude/lib/discovery-validation/DiscoveryCapability.psm1` lines 120-125 (`Get-DiscoverySessionObservation`) and 162 (`Get-DiscoveryObservationEvidence`), with its mirrors `extensions/drm-copilot/resources/lib/discovery-validation/DiscoveryCapability.psm1` and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/discovery-validation/DiscoveryCapability.psm1`; tests `tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1` line 208 (`Add-GateSentinelObservation`), `tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1` line 133, `extensions/drm-copilot/test/discovery-sentinel.test.ts` line 92; documentation `docs/engineering/legacy-discovery-and-parity/enforcement.md` `## Capability probe`.
- Problem: The gate writes the sentinel tool observation with `state: "issued"` (`DiscoveryObservation.psm1:138`). `consumeSentinelGrant` records consumption only by creating `<observation>.json.consumed` and returns without rewriting the record. The probe reads only `*.json` entries and accepts a sentinel observation only when the record's own `state` reads `consumed`; it never inspects the latch. The tool-authorization consumer (`discovery-authorization.ts:290-329`) latches and then rewrites the record, which is why the same probe logic works for that record kind and not for this one.
- Failure scenario on any host: the sentinel agent runs, both observations are recorded, `discovery_capability_sentinel` reports `observed: true`, and the probe returns `status: unsupported` with "sentinel observation … was not consumed by the sentinel tool (state issued)". `run_discovery_doctor` reports the deficiency, `Test-DiscoveryRootGrantPrecondition` (`DiscoveryRootGrant.psm1:126`) refuses the root grant for `prepare_discovery_agent` and every controlled root call with `CAPABILITY`, and no specialist can be prepared. The failure is closed (nothing unsafe is admitted), and the feature is unusable.
- Why the suites did not catch it: `Add-GateSentinelObservation` places a record with `state = 'consumed'` directly in the store ("Records are placed directly in Files"), and `discovery-sentinel.test.ts` seeds `state: "consumed"` only to assert a replay refusal. No test feeds the probe the record and latch the TypeScript consumer leaves behind, and no host was driven in this cycle (`evidence/qa-gates/discovery-host-observations.2026-10-30T01-47.md`).
- Expected behavior: after the sentinel agent's two calls, `Get-DiscoveryCapabilityObservation` for that session returns `status: supported` with `trusted_attribution` and `forbidden_tools_denied` true, `probe.result` `denied` and `probe.evidence_ref` naming the shell observation, using records exactly as the gate wrote them and as the TypeScript consumer left them. Either (a) `consumeSentinelGrant` rewrites the observation as `consumed` with `consumed_at` after the latch, through the same staged `createExclusive` plus `publish` sequence `consume()` uses, and the `host-observation` schema admits `consumed_at`; or (b) `Get-DiscoverySessionObservation` reports the `.consumed` latch beside each record and `Get-DiscoveryObservationEvidence` treats the latch as consumption and drops the `state` test. Option (b) changes fewer files and keeps the record immutable; either is acceptable. The fixture must then build the record through `ConvertTo-DiscoveryHostObservationRecord` and apply the consumer's exact effect rather than hand-writing `state`.
- Verification: a cross-language contract test (for example a new case in `tests/scripts/dev_tools/test_discovery_publication_contracts.py` or a Pester case that consumes a fixture record through the TypeScript consumer's recorded effect) that fails on the current head and passes after the fix; the `DiscoveryCapability.Tests.ps1` "unconsumed sentinel grant" case re-expressed in the chosen contract; PoshQC format, analyze and the full Pester run; Prettier, ESLint, TSC and both Jest loops with retained `lcov.info`; mirror parity for `DiscoveryCapability.psm1` and, if touched, `DiscoveryObservation.psm1`; logical line count at or below 500 for each touched file. Where an orchestrator session is available, follow the launch instructions in `discovery-host-observations.2026-10-30T01-47.md` once on Claude Code and record the probe status in a new `discovery-host-observations.<timestamp>.md`.

## Non-blocking items (fix inside the cycle when they touch the same files)

- `extensions/drm-copilot/src/discovery-root-grant.ts:228-245`: every root call decodes every `.json` under `root-grants/` strictly and nothing prunes consumed or expired grants; one malformed or partially written file refuses every root call for the workspace, including doctor. Skip undecodable neighbours that are not the selected grant, or prune past `expires_at` (code review, Minor).
- `.claude/lib/discovery-validation/DiscoveryCapability.psm1:170`: apply the handler-hash and `observed_at` TTL checks to the `SHELL` deny observation as the sentinel tool observation receives them (code review, Nit).
- `docs/engineering/legacy-discovery-and-parity/enforcement.md` `## Capability probe`: keep the sentence "The sentinel tool consumes its one-use sentinel grant" accurate for whichever contract is chosen.

## Do not do

- Do not lower any coverage threshold, add a coverage exclusion for a production path, or add a `config/file-size-baseline.json` entry.
- Do not weaken or delete existing assertions; re-express the "unconsumed sentinel grant" case in the chosen contract instead of removing it.
- Do not edit policy files under `.claude/rules/` or `.github/instructions/`.
- Do not re-open the recorded user decisions (payload identity, root grants for read-only root calls without `invocation_ref`, `unsupported` for hosts that cannot supply identity).
- Do not hand-write observation records in the new contract test; produce them through the gate's writer and the consumer.
- Keep bundled mirrors byte-identical, and keep every touched covered file at or below 500 logical lines.

## Exit gate

A reaudit by `feature-review` shows no blocking finding for R5, the cross-language contract test exists and passes, and criterion 64 is re-evaluated against the new head. If an orchestrator-driven Claude Code run is recorded, its probe status is cited in the reaudit; its absence is not itself blocking under the recorded user decision.
