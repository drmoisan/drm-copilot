# Code Review: legacy discovery and parity (#980), review cycle 1

---

**Review Date:** 2026-10-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-17-legacy-discovery-and-parity-980`
**Feature Folder Selection Rule:** The only active feature folder whose suffix matches the branch issue number (980).
**Base Branch:** `main` (merge base `52587a0eeaa04a0519801452235608a72b5eba5c`; `origin/main` is now at `318ef3e934a13984bbd50ef29fd2b714aa98168b`)
**Head Branch:** `feature/legacy-discovery-and-parity-980` at `7d9191e9d7ff3084bc8ffc828d21fe402de1af22`
**Review Type:** Re-review after remediation cycle 1 (prior review `code-review.2026-10-29T13-16.md`)

---

## Executive Summary

Remediation cycle 1 (plan Phases 15 and 16, 37 commits since `c88235db0`) replaces the environment-variable identity contract with payload-derived identity on all three host surfaces, adds one-use root grants for root calls, binds every specialist controlled call to its invocation, makes the capability probe read recorded host observations instead of deciding in-process, and closes the Python replay and expiry gap. This review read every Phase 15 production module in PowerShell, TypeScript and Python, the tests that cover them, the Phase 16 gate evidence, and the four canonical coverage artifacts. The review scope is the full branch diff (1,102 paths outside the feature folder).

Every finding of the prior review is resolved in code, not only in documentation. The payload module reads no environment value; the gate denies a declared discovery agent type without a usable identifier and allows other agents only so ordinary gates apply; the MCP gate admits a controlled call only through a consumed tool authorization (with `invocation_ref`) or a consumed root grant (without), and no path falls back to `local-user`; `prepare_discovery_agent` and `finalize_discovery_agent` refuse without their consumed record; the Python gateway latches each dispatch exclusively and refuses an expired grant before any further read; the content-keyed registry cache runs the dependency import check before any cache hit; the host read path re-checks the resolved target; the two weak assertions are strengthened; the canonical Pester artifact is a full run.

The remediation introduces one new Blocker. The sentinel observation is produced by the PowerShell gate with `state: "issued"`, consumed by the TypeScript sentinel tool, which writes only a sibling `.consumed` latch, and then read by the PowerShell probe, which requires the record's own `state` to read `consumed`. The two consumers of one record disagree on what consumption looks like, the test fixture on each side hands the reader the shape it expects, and no host was driven in this cycle. On every real host the probe reports `unsupported`, no root grant can be written for `prepare_discovery_agent`, and the feature cannot be used. The failure is closed, not open: nothing is granted that should be refused.

**What changed:**
PowerShell: `DiscoveryPayload.psm1` (payload-only principal), `DiscoveryAuthorization.psm1` (root grants, sentinel routing, first-call binding), `DiscoveryRootGrant.psm1`, `DiscoveryObservation.psm1`, `DiscoveryToolRouting.psm1`, `DiscoveryCapability.psm1` (observation evidence), `DiscoveryStart.psm1` (observational start), `DiscoveryStop.psm1` (payload-attributed stop), per-host hook entry points and the sentinel agent on three surfaces. TypeScript: `discovery-root-grant.ts`, `discovery-sentinel.ts`, `discovery-authorization-binding.ts`, `mcp-discovery-authorization-gate.ts` (routing by `invocation_ref`), `repo-automation-service-discovery*.ts`, `discovery-authority-provider.ts` (identity-free), per-file Jest thresholds. Python: `gateway_host.py` and `gateway_host_store.py` (`.used` latch), `protected_records.py` (expiry), `gateway_host_reads.py`, `catalog.py` (content-keyed cache), two new schemas.

**Top 3 risks:**
1. The capability probe cannot report `supported` on any host because `consumeSentinelGrant` never rewrites the observation record's `state`, while `Get-DiscoveryObservationEvidence` requires it (Blocker).
2. The probe, prepare and controlled-call chain has still not been observed on a real host; `discovery-host-observations.2026-10-30T01-47.md` records every host as "not exercised in this cycle" (Info; the user decision accepts fixture proof of the decision logic, and the Blocker is exactly the class of defect a live run would have caught).
3. Root grants accumulate under `root-grants/` and are decoded strictly on every root call, so one malformed file refuses every root call for the workspace (Minor).

**PR readiness recommendation:** **Needs Revision**. One autonomous Blocker remains (see the Findings Table).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/src/discovery-sentinel.ts`; `.claude/lib/discovery-validation/DiscoveryCapability.psm1` (and its two bundled mirrors under `extensions/drm-copilot/resources/`) | `discovery-sentinel.ts:252-295` (`consumeSentinelGrant`); `DiscoveryCapability.psm1:120-125` (`Get-DiscoverySessionObservation`), `:162` (`Get-DiscoveryObservationEvidence`) | The sentinel tool consumes its grant by creating `<observation>.json.consumed` and returns without rewriting the record (`discovery-sentinel.ts:272-278`); the record keeps `state: "issued"` as the gate wrote it (`DiscoveryObservation.psm1:138`). The probe reads only `*.json` entries and accepts a sentinel observation only when `[string]$candidate['state'] -ceq 'consumed'`; it never inspects the latch. Failure scenario on any host: the sentinel agent runs, both observations are recorded, the sentinel tool reports `observed: true`, and the probe still returns `status: unsupported` with "sentinel observation observation-… was not consumed by the sentinel tool (state issued)". `run_discovery_doctor` reports the deficiency, `Test-DiscoveryRootGrantPrecondition` (`DiscoveryRootGrant.psm1:126`) refuses the root grant for `prepare_discovery_agent` and every controlled root call with `CAPABILITY`, and no specialist can be prepared. The suites cannot see this: `Add-GateSentinelObservation` places a record with `state = 'consumed'` directly in the store (`DiscoveryGate.TestSupport.ps1:208`, "Records are placed directly in Files"), and `discovery-sentinel.test.ts:92` seeds `state: "consumed"` only to assert a replay refusal. | Choose one contract and apply it on both sides: either rewrite the observation as `consumed` after the latch, through the same staged `createExclusive` plus `publish` sequence `consume()` uses for tool authorizations (`discovery-authorization.ts:290-329`), or make `Get-DiscoveryObservationEvidence` treat the `.consumed` latch beside the record as consumption and drop the `state` test. Keep the bundled mirrors byte-identical. Add a cross-language contract test in the style of `tests/scripts/dev_tools/test_discovery_publication_contracts.py` that builds the record with `ConvertTo-DiscoveryHostObservationRecord`, applies the TypeScript consumer's exact effect, and asserts the probe reports `supported`. Where an orchestrator session is available, drive the sentinel once on Claude Code and record the probe status per `discovery-host-observations.2026-10-30T01-47.md`. | The probe is the precondition of every root grant except doctor, so a probe that cannot pass makes the whole specialist path unusable. The prior review's Blocker was a probe that could not fail; this is a probe that cannot pass. Both come from testing each side against a hand-written record instead of the other side's output. | Source inspection of the three files; `git grep -n "state" extensions/drm-copilot/src/discovery-sentinel.ts` shows reads only; `evidence/qa-gates/discovery-host-observations.2026-10-30T01-47.md` ("no host was driven by the executor") |
| Minor | `extensions/drm-copilot/src/discovery-root-grant.ts` | lines 228-245 (`consumeRootGrant` candidate scan) | Every root call lists `root-grants/` and decodes every `.json` strictly; `decodeRootGrant` throws `AUTHORIZATION_RECORD_INVALID` on any malformed entry, and consumed or expired grants are never removed. Failure scenario: a partially written grant (the PowerShell `WriteText` seam opens with `CreateNew` and then writes, so a concurrent reader can observe an empty file) or any stray file in the partition refuses every subsequent root call for the workspace, including doctor, until an operator deletes it; and the per-call cost grows with the session history. | Skip undecodable entries whose `grant_ref` does not match a candidate, or scope the scan by a name prefix derived from the request digest; prune grants past `expires_at` plus a grace period, or write grants to a per-session partition the stop hook can clear. | A diagnostic tool (`run_discovery_doctor`) should not be refused by an unrelated malformed record; the strict decode is right for the selected grant, not for every neighbour. | Source inspection; `DiscoveryAuthorization.psm1:178-185` (`WriteText`) |
| Nit | `.claude/lib/discovery-validation/DiscoveryCapability.psm1` | line 170 | The `SHELL` deny observation is matched by `agent_id` only; it is not checked against the registered handler hash or the TTL window the sentinel tool observation receives (lines 163-164). A stale shell denial recorded by an earlier handler build in the same session would still prove `forbidden_tools_denied`. | Apply the same handler-hash and `observed_at` checks to the shell candidate. | Both observations are evidence of the same control set and should be bounded alike. | Source inspection |
| Info | `.claude/lib/discovery-validation/DiscoveryPayload.psm1`; `DiscoveryAuthorization.psm1`; `extensions/drm-copilot/src/mcp-discovery-authorization-gate.ts`; `repo-automation-service-discovery-agent.ts`; `repo-automation-service-discovery-identity.ts` | `DiscoveryPayload.psm1:224-268`; `DiscoveryAuthorization.psm1:353-376`; `mcp-discovery-authorization-gate.ts:185-230`; `repo-automation-service-discovery-agent.ts:191-204, 303-310`; `repo-automation-service-discovery-identity.ts:53-73` | Prior Blocker (identity supplier) verified resolved. `Get-DiscoveryTrustedPrincipal` reads host, session, `agent_id`, `agent_type` and parent from the normalized envelope; the module header states and the code confirms no environment read. The gate denies an envelope with a discovery agent type and no usable identifier (`IDENTITY`) and allows other agents so ordinary gates apply. The MCP gate requires a consumed tool authorization when `invocation_ref` is present and a consumed root grant otherwise; `invocationOptions` throws `DISCOVERY_HOST_BINDING_REQUIRED` for a bound request without a record; prepare refuses without raw tool input or a grant; finalize refuses without the consumed record. `grep -rn DRM_DISCOVERY_` over every production tree returns nothing. | None. | Confirms the user decision is implemented as decided: payload identity, fail-closed, root grants for read-only root calls. | Source inspection; repository search |
| Info | `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host.py`; `protected_records.py`; `gateway_host_store.py` | `gateway_host.py:270-302`; `protected_records.py:314-319`; `gateway_host_store.py:75-83` | Prior Major (Python replay and expiry) verified resolved. `decode_authorization` refuses when `expires_at` is unreadable or at or before the injected clock, and when the `.used` latch exists and was not created by this process; `_verify` then creates the latch with mode `x` before any further read, mapping `FileExistsError` to the exit-3 refusal. The same process may re-authorize its own dispatch after capture (`_dispatched`). Tests: `test_a_second_dispatch_of_the_same_grant_is_refused`, `test_an_expired_grant_is_refused_before_any_read`. | None. | Defence in depth at the authoritative layer now holds without the TypeScript client. | Source inspection; `tests/discovery_runtime/test_gateway_host_refusals.py:192-240` |
| Info | `packages/discovery-runtime/src/drm_copilot_discovery/catalog.py` | lines 201-263 | The content-keyed registry cache calls `_require_schema_libraries()` before the cache lookup (`_registry`, line 256) and again in `registry()` (line 442), so a missing `jsonschema` or `referencing` fails even on a cache hit. The key covers every schema document and each extension's namespace, identifier and digest. `_build_registry` mutates only the plain copy produced by `to_plain_value`, never the catalog's documents. Reversed-order and seeded runs pass. | None. | Verified the review target named by the coordinator. | Source inspection; `evidence/regression-testing/p16-isolation-python-reversed.2026-10-30T01-45.md` |
| Info | `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host_reads.py` | lines 50-90 | Prior Minor (lexical invocation-scope check) verified resolved. `select_reads` requires the lexical selection check, the configured-scope resolve, no `symlink` or `reparse` stamp in any observation, and the resolved leaf made workspace-relative to lie within the selection. Tests cover each refusal and the Windows and POSIX root spellings. | None. | Closed as recommended. | `tests/discovery_runtime/test_gateway_host_reads.py`, `test_gateway_host_read_refusals.py` |
| Info | `tests/discovery_runtime/test_schema_validation.py`; `tests/discovery_runtime/test_gateway_host_main.py` | `test_schema_validation.py:401, 425-426`; `test_gateway_host_main.py:284-288` | Prior Minors (weak assertions) verified resolved. `before` is a `copy.deepcopy` of the resolver contents and the test asserts `catalog.registry() is registry`; the refusal matrix asserts the exact finding message per row and the `SERVICE_REQUEST` code. | None. | Both assertions can now fail. | Source inspection |
| Info | `extensions/drm-copilot/jest.config.cjs`; `extensions/drm-copilot/jest.discovery-coverage.json`; `coverage/lcov.info`; `extensions/drm-copilot/coverage/lcov.info` | whole files | Prior Blocker (TypeScript coverage) verified resolved. Both canonical artifacts exist and postdate the last TypeScript change; the ten previously unthresholded files carry 85/75 entries; the discovery host modules carry 90/75 entries in the sibling map; `collectCoverageFrom` excludes only `*.d.ts`; the map has no `global` key. This review parsed both artifacts: 47 executable changed files all at or above 92.86% lines and 77.78% branches; three type-only modules carry no executable statement. | None. | Coverage verification complete for TypeScript. | `python -I <scratchpad>/cov.py lcov …` output |
| Info | `artifacts/pester/powershell-coverage.xml`; `spec.md`; `user-story.md`; six copies of `execution-environment/SKILL.md` | n/a | Prior Minors and Nit verified resolved: the canonical Pester artifact is a full run (20188/21629, 93.34%); the status lines read the Phase 16 state with `Last Updated 2026-10-30T01-58`; the six brief copies hash `372462e3…` and the fourth `## Test Runtime` bullet now reads "build an expensive immutable fixture once per session and hand each test its own copy wherever a test could mutate it". | None. | Closed as recommended. | `sha256sum`; coverage parse |
| Info | `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/discovery-host-observations.2026-10-30T01-47.md`; `completion-report.md`; `handoff.md` | whole file; `completion-report.md:10, 34, 55`; `handoff.md:34, 50` | The P12-T12 claims are requalified as harness-simulated with launcher-exported identity, and the P16-T7 table records every host as "not exercised in this cycle" with the fixture suites cited as the source. The record is accurate and makes no unproven claim. The Blocker above is the kind of integration defect only a driven host (or a cross-language contract test) would expose. | Drive the sentinel once on Claude Code from an orchestrator session after the Blocker fix, following the launch instructions in that record. | Honest record; the gap is in integration testing, not in the documentation. | File inspection |
| Info | `config/file-size-baseline.json`; covered files | whole diff | Logical line counts over 721 added or modified covered files: maximum 531 (`extensions/drm-copilot/jest.config.cjs`), none at or above 700, none above 800; the baseline `files` map is empty. No Warning row is due under the 700-line advisory tier. | None. | Tiered file-size policy satisfied. | `python -I <scratchpad>/count.py . 52587a0ee` |

There is 1 Blocker finding, autonomous.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `DiscoveryPayload.psm1` is a pure normalizer: per-host key tables, typed anomalies, and a principal derived from the envelope alone. `IsRoot` is `agent_id` absent; a specialist needs both a grammar-conforming `agent_id` and a discovery `agent_type`.
- `Get-DiscoveryPreToolDecision` evaluates in the documented order (anomaly, sentinel, root, non-specialist, family, root-only, caller identity, operation, workspace, activation, invocation, `invocation_ref`, binding) and writes a record only after every check. A root call carrying `invocation_ref` or any identity field is denied before a grant is written.
- `DiscoveryRootGrant.psm1` requires a current `supported` attestation bound to the host, session and workspace before a prepare or controlled root grant; doctor is exempt so the probe can bootstrap.
- `DiscoveryObservation.psm1` records every sentinel envelope and denies with `STORE` when the observation cannot be written, so no unobserved sentinel call proceeds.
- `DiscoveryStart.psm1` now observes rather than denies a start without an agent identifier, leaving the binding to the first controlled call; `DiscoveryStop.psm1` attributes from the payload principal and blocks a stop without an identifier.

#### API and safety notes

- Advanced functions throughout; `SupportsShouldProcess` on both new writers; store, clock, nonce and environment injectable; analyzer clean; largest module 480 logical lines.

#### Error handling and logging

- Seam failures deny with `STORE`; anomalies deny with `ENVELOPE`; the sentinel decision denies `UNKNOWN_TOOL` for anything that is not the sentinel tool or the sentinel shell command.

#### Defect

- The probe's `state -ceq 'consumed'` requirement is not met by the only producer of consumption (Blocker).

### TypeScript implementation audit

#### What changed well

- `admitControlledToolCall` refuses caller-supplied `authorization_ref` and `root_grant_ref`, derives the operation with the adapter's rules, and routes by the presence of `invocation_ref`. Both branches require a seam on the service and throw when it is absent.
- `consumeRootGrant` filters in a fixed order (candidates by tool, operation and digest; live by state and latch; current by window; unique), latches exclusively, and returns host, session and parent from the record. `prepareDiscoveryInvocation` takes its context from that grant, never from the request.
- `createNodeDiscoveryAuthorityProvider` reads only `LOCALAPPDATA` and `XDG_STATE_HOME`; `DISCOVERY_ENVIRONMENT_KEYS` documents the two keys.
- `finalizeDiscoveryAgentOperation` requires the consumed record and binds `invocation_ref` to it.

#### Type safety and maintainability

- Strict record decoders for both new record kinds with exact key-set checks; no new `any`, `@ts-ignore` or file-level `eslint-disable` in the Phase 15 modules.

#### Error handling and logging

- Refusals carry their code in the message so the MCP summary names the class. `consumeSentinelGrant` reports `observed: false` rather than throwing, by design.

#### Defect

- `consumeSentinelGrant` does not rewrite the record it consumed (Blocker); `consumeRootGrant` decodes every neighbour strictly and never prunes (Minor).

### Python implementation audit

#### What changed well

- `HostServiceIO._verify` reads the invocation, start attestation and capability, confirms the grant is a real partition entry, decodes it with `latch_present`, `now` and `used_latch_present`, and then creates the `.used` latch before the baseline read. A re-authorization by the same process after capture is recognised through `_dispatched`.
- `InstalledHostStore.create_exclusive` opens with mode `x` and writes a fixed text; `HostStoreIO` is a Protocol with four methods.
- `select_reads` is pure over an injected resolver and handles Windows and POSIX roots through `PureWindowsPath` and `PurePosixPath`.
- `_registry` runs the import check before the cache lookup; the cache is module state keyed by the SHA-256 of the canonical schema bytes and extension pins.

#### Typing and API notes

- Frozen keyword-only dataclasses; `cast` at schema-validated boundaries; docstrings on every function.

#### Error handling and logging

- `FileExistsError` from the latch is mapped to the exit-3 refusal with cause; other `OSError` values propagate; no broad handler.

---

## Test Quality Audit

All four coverage artifacts were parsed by this review. Every changed production file of every language is present and above the floors (Python lowest 90.00% lines, TypeScript lowest executable 92.86% lines and 77.78% branches, PowerShell lowest 92.82% lines). The isolation runs (seeded Jest 1616, reversed Python with `test_catalog.py` last, Pester seeds 161, 262, 363) are recorded and green. A search of the discovery test trees found no temporary-file API and no unmocked process.

### Reviewed test and QA artifacts

- `artifacts/python/lcov.info`: 96.69% lines (32061/33160), 93.59% branches (11613/12408); 185 changed production files present.
- `extensions/drm-copilot/coverage/lcov.info`: 97.04% lines, 93.64% branches; 50 changed files present (3 type-only).
- `coverage/lcov.info`: 98.20% lines, 93.37% branches.
- `artifacts/pester/powershell-coverage.xml`: 93.34% lines (20188/21629); 38 changed production files present.
- `evidence/qa-gates/p16-coverage-comparison.2026-10-30T01-41.md`: 274 files, 0 uncovered changed executable lines; the per-file totals it cites agree with the canonical artifacts.
- `evidence/regression-testing/p16-isolation.2026-10-30T01-45.md`: all orders pass.

### Quality assessment prompts

- **Determinism:** Clocks, nonces, stores and environment are injected on every surface.
- **Isolation:** One behaviour per test; module-level cache state is exercised in reversed order.
- **Speed:** Python suite 661.48 s; discovery tree 156.30 s.
- **Diagnostics:** Refusal tests assert distinct messages; the two previously weak assertions are strengthened.
- **Integration seam:** The sentinel record is tested on each side against a fixture that already carries the other side's expected state (`DiscoveryGate.TestSupport.ps1:208`, `discovery-sentinel.test.ts:92`). No test crosses the TypeScript-to-PowerShell boundary with the real producer output, which is how the Blocker escaped.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Records carry digests and references only. |
| No unsafe subprocess or command construction | ✅ PASS | Argument-vector launch; hooks invoke no process. |
| Input validation at boundaries | ✅ PASS | Envelope anomalies typed; strict record decoders; schema validation before any field read in Python. |
| Error handling remains explicit | ✅ PASS | Exit-3 refusals; typed TypeScript errors; `STORE` denials. |
| Configuration / path handling is safe | ✅ PASS | Resolved-target re-check for host reads; `relative-path` schema rejects dot segments and absolute paths. |
| One-use authorization | ✅ PASS | TypeScript latch plus rewrite for tool authorizations; TypeScript latch for root and sentinel grants; Python `.used` latch and expiry. |
| No principal conversion | ✅ PASS | A bound request without a consumed record is refused `DISCOVERY_HOST_BINDING_REQUIRED`; a root controlled call needs a root grant; no `DRM_DISCOVERY_*` read site remains. |
| Root-only `prepare-agent` | ✅ PASS | Denied for specialists by the gate (`ROOT_ONLY`) and refused by the service without a root grant. |
| Capability probe correctness | ❌ FAIL | The probe cannot report `supported` on any host (Blocker). |

---

## Research Log

No external research was required. The review relied on repository source, git history and the feature evidence. The research record `research/2026-10-29T13-16-host-identity-sources-research.md` documents the host payload fields the design depends on; the user's decision to accept that research and the fixture proof of the decision logic is recorded in the coordinator's prompt and is not re-opened here. One assumption remains unverified by any artifact: that each host places `agent_id` and `agent_type` in a subagent's PreToolUse payload as the research states. The Blocker found here is independent of that assumption.

---

## Verdict

The remediation implements the decided design faithfully on all three surfaces, and every prior finding is closed in code with tests that can fail. The Python, TypeScript and PowerShell gates pass on independently parsed artifacts, mirrors are byte-identical, and file sizes are within policy.

The branch is not ready for the normal PR flow. One autonomous Blocker remains: the sentinel observation's consumption contract differs between `discovery-sentinel.ts` (latch only) and `DiscoveryCapability.psm1` (record `state`), so the capability probe cannot pass and no specialist can be prepared on any host. Align the contract on one side, mirror it, add a cross-language contract test over the real producer output, re-run the TypeScript and PowerShell loops, and re-run this review.
