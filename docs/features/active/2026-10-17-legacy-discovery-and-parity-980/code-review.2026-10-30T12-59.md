# Code Review: legacy discovery and parity (#980), review cycle 2

---

**Review Date:** 2026-10-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-17-legacy-discovery-and-parity-980`
**Feature Folder Selection Rule:** The only active feature folder whose suffix matches the branch issue number (980).
**Base Branch:** `main` (merge base `f7bef6ad16cf567de6462b736bbce7afd83e591a`, which is `origin/main`; the branch is rebased)
**Head Branch:** `feature/legacy-discovery-and-parity-980` at `b8f3b9ee752672753325617e1f417e7af1a69f76`
**Review Type:** Re-review after remediation cycle 2 (prior review `code-review.2026-10-30T10-19.md`)

---

## Executive Summary

Remediation cycle 2 (plan Phases 17 and 18, 16 commits from `3e7acb3e9`) addresses the single Blocker R5 of the prior review: the sentinel tool consumed its one-use grant by writing a `.consumed` latch beside the host observation, while the PowerShell probe required the record's own `state` to read `consumed`. The cycle chose the smaller of the two options the remediation inputs offered: the record stays immutable and the probe learns the latch. This review read the full cycle-2 diff (one production module plus its two mirrors, one shared fixture, three contract suites, the Pester test support, three per-host probe suites and one engineering document), the sentinel consumer it must agree with, the executor's Phase 17 and 18 evidence, and the three canonical coverage artifacts.

R5 is resolved end to end. `Get-DiscoverySessionObservation` now reads `"$directory/$name.consumed"` through the same `ReadText` seam it reads the record with and attaches the parsed latch as `consumed_latch` (`DiscoveryCapability.psm1:158-161`); `Get-DiscoveryObservationEvidence` accepts a sentinel observation only when `state` is `issued` and the latch is a hashtable whose `observation_ref` equals the record's, case-sensitively (`:204-207`). The TypeScript consumer writes exactly that: `io.createExclusive(`${path}${SENTINEL_CONSUMED_SUFFIX}`, canonicalJson({consumed_at, observation_ref}))` with `SENTINEL_CONSUMED_SUFFIX = ".consumed"` and no rewrite of the record (`discovery-sentinel.ts:42, 272-278`). Both sides derive the directory as `<authority>/sessions/<sha256(session_id)>/observations/` and the file name as `<observation_ref>.json` (fixture `relative_paths` and `latch.relative_path`; `test_relative_paths_partition_by_the_session_digest`; Pester case (a) asserts `Get-DiscoveryObservationDirectory` plus the ref equals the fixture path). The production `ReadText` seam returns `$null` for a missing path (`DiscoveryAuthorization.psm1:168-172`), so an absent latch is `latch absent`, not an exception. The executor also ran the gate, the emitted TypeScript consumer and the probe over one real filesystem store (`p17-cross-runtime-smoke.2026-10-30T12-09.md`): the probe reported `trusted_attribution` and `forbidden_tools_denied` true with the fixture references, and the store held exactly three files.

The fixture is produced from real code paths, not hand-written. The Pester contract suite rebuilds both records from the fixture envelopes through the gate's own normalizer, principal, tool routing and record builder and compares them key by key in the gate's key order with the fixture records; the Jest suite runs the real `consumeSentinelGrant` and asserts the latch text byte for byte and that nothing else was written; the Python suite validates both records against the committed schema and recomputes the input digest with the runtime's `canonical_json`. The hand-seeded `state = 'consumed'` in `Add-GateSentinelObservation` is gone; records are built by `Get-GateSentinelRecord` through the gate modules and the fixture latch is placed verbatim. The one remaining `state = 'consumed'` in test support (`DiscoveryCapability.Tests.ps1:160`) is the deliberate rejection case. The three `DiscoveryCapability.psm1` copies share SHA-256 `ab693926719639ee0b2c76ab863aa397f4d67edcf0e0dfcb77ce2fc4e9172487`.

No new Blocker, Major or Minor is introduced. One Nit (the latch's `consumed_at` is not validated) and one Info (catch-all in the latch reader, consistent with the module's existing reader pattern) are recorded with no remediation required. The prior Minor and Nit are deferred to issues #1007 and #1008 by user decision and are not findings of this review.

**What changed:**
PowerShell: `DiscoveryCapability.psm1` (new `Get-DiscoveryConsumedLatch`; `Get-DiscoverySessionObservation` attaches `consumed_latch`; `Get-DiscoveryObservationEvidence` requires `state issued` plus a matching latch) and its two bundled mirrors. Tests: `tests/fixtures/discovery_host/sentinel-consumption.json`; `DiscoverySentinelConsumption.Contract.Tests.ps1`; `discovery-sentinel.contract.test.ts`; `test_sentinel_consumption_fixture.py`; `DiscoveryGate.TestSupport.ps1` (`Get-GateSentinelRecord`, `NoLatch`, fixture-derived references); `DiscoveryCapability.Tests.ps1` (three new cases, matrix rows re-expressed); three per-host `discovery-capability.Tests.ps1`. Documentation: `enforcement.md` `## Protected records`, `## Capability probe`.

**Top 3 risks:**
1. No real host has yet been driven through the sentinel agent, doctor and prepare chain since the identity redesign (Info; the P17-T5 smoke covers the cross-runtime record contract over a real store, and the recorded user decision accepts fixture and smoke proof for this merge).
2. The probe reads only `observation_ref` from the latch; a latch written long after the observation would still count, bounded by the record's own `observed_at` TTL (Nit).
3. Root grants accumulate and are decoded strictly on every root call (deferred to #1007 by user decision; not evaluated here).

**PR readiness recommendation:** **Ready for PR**. No Blocker remains.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/discovery-validation/DiscoveryCapability.psm1` (and its two bundled mirrors); `extensions/drm-copilot/src/discovery-sentinel.ts` | `DiscoveryCapability.psm1:103-126` (`Get-DiscoveryConsumedLatch`), `:158-161`, `:204-207`; `discovery-sentinel.ts:42, 263, 272-278` | Prior Blocker R5 verified resolved end to end. Path: the probe reads `"$directory/$name.consumed"` where `$directory` is `Get-DiscoveryObservationDirectory` (`<session dir>/observations`) and `$name` is the `.json` entry; the consumer writes `${path}.consumed` where `path` is `${sessions}/${session}/observations/${name}`. Content: the consumer writes `canonicalJson({consumed_at, observation_ref})` (sorted keys, trailing newline); the probe parses it with `ConvertFrom-Json -AsHashtable` and compares `observation_ref` with `-ceq`. State: the probe now requires `state -ceq 'issued'`, which is what `ConvertTo-DiscoveryHostObservationRecord` writes and the consumer never changes. Failure scenario that no longer occurs: after the sentinel agent runs, the probe returned `unsupported` with "was not consumed … (state issued)"; the P17-T3 fail-before run reproduces exactly that message on the unchanged module, and the same suite passes after the fix. | None. | The three contract suites replay one fixture through the producer, the consumer and the reader, and the P17-T5 smoke exercised the same three roles over a real store with matching references. | `git diff 3e7acb3e9 HEAD -- .claude/lib/discovery-validation/DiscoveryCapability.psm1`; `p17-sentinel-contract-fail-before.2026-10-30T11-42.md`; `p17-cross-runtime-smoke.2026-10-30T12-09.md`; `sha256sum` of the three copies |
| Info | `tests/fixtures/discovery_host/sentinel-consumption.json`; `tests/scripts/claude-lib/discovery-validation/DiscoverySentinelConsumption.Contract.Tests.ps1`; `extensions/drm-copilot/test/discovery-sentinel.contract.test.ts`; `tests/discovery_runtime/test_sentinel_consumption_fixture.py` | `Contract.Tests.ps1:52-65, 93-102`; `contract.test.ts:73-87`; `test_sentinel_consumption_fixture.py:58-70, 84-92` | The shared fixture is produced from real code paths. Pester case (a) rebuilds each record from the fixture envelope through `ConvertFrom-DiscoveryHostPayloadText`, `Get-DiscoveryTrustedPrincipal`, `Resolve-DiscoveryToolName`, `Get-DiscoveryInputDigest` and `ConvertTo-DiscoveryHostObservationRecord` and asserts key set, key order and every value. The Jest suite asserts `io.files.get(latchPath)` equals `CONTRACT.latch.text` and `writtenPaths()` is exactly the latch path. Python recomputes `input_sha256` from the envelope's `tool_input` with `canonical_json` and asserts the records are schema-valid. The fixture's `consumed_at` `2026-10-22T12:00:00.000Z` is `new Date(consumer_now).toISOString()`, so the latch text is the consumer's exact output. | None. | Each side's output is pinned by the other side's test, which is the property the prior review asked for. | Source inspection of the three suites and the fixture |
| Info | `tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1`; `tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1`; `tests/scripts/{claude,codex,copilot}-hooks/discovery-capability.Tests.ps1` | `TestSupport.ps1:17-22, 183-218, 243-266`; `DiscoveryCapability.Tests.ps1:133, 145-176`; hook suites lines 56-57, 83 | The hand-seeded `state = 'consumed'` is gone from test support: `Add-GateSentinelObservation` builds both records with `Get-GateSentinelRecord` (gate modules, fixture clock, nonce and TTL, the real handler hash for the host) and places the fixture latch text verbatim unless `NoLatch`. The probe suites assert `$script:GateSentinelToolRef` and `$script:GateSentinelShellRef`, which are read from the fixture, instead of hand-chosen names. The remaining `-Tool @{ state = 'consumed' } -NoLatch` at line 160 is the deliberate rejection of a rewritten record. The "unconsumed sentinel grant" rows are re-expressed with `NoLatch`, not removed. Test support imports the gate modules without `-Force` so a suite that imported them already is unaffected; the P18-T3 single process ran all 466 Pester files together with 0 failures. | None. | The remediation inputs' "do not hand-write observation records" and "do not weaken or delete existing assertions" constraints are met. | `grep -rn "state = 'consumed'" tests` returns only line 160; `p18-powershell-junit.2026-10-30T12-41.xml` (contract suite 3/3, `DiscoveryCapability.Tests.ps1` 43/43, host suites 12/12, 12/12, 10/10) |
| Nit | `.claude/lib/discovery-validation/DiscoveryCapability.psm1` (and mirrors) | line 205 | The probe reads only `observation_ref` from the latch. `consumed_at` is parsed but not compared with `observed_at`, `expires_at` or the attestation window. Failure scenario: a latch written to the protected store long after the grant's `expires_at` (which the TypeScript consumer itself refuses to do, `discovery-sentinel.ts:265`) would still prove consumption; the record's own `observed_at` TTL check at line 209 still bounds the evidence to the attestation window. | Optional: require `consumed_at` to parse and to fall within `[observed_at, expires_at]`. No remediation required for this merge. | The latch lives in the MCP server's protected store and the only writer refuses expired grants; the exposure is a second-order hardening. | Source inspection |
| Info | `.claude/lib/discovery-validation/DiscoveryCapability.psm1` (and mirrors) | lines 120-125 | `Get-DiscoveryConsumedLatch` wraps the seam call and the JSON parse in `try { … } catch { $latch = $null }`. This is the same pattern the record read at lines 154-157 uses and the documented semantics of a reader that reports "no evidence" rather than refusing; the deficiency message names the resulting state (`latch absent`), so the outcome is visible to `run_discovery_doctor`. The unparseable-latch case is tested (`{not json`). | None. | Consistent with the module's established reader pattern; the catch is not in a decision path. | Source inspection; `DiscoveryCapability.Tests.ps1:166-176` |
| Info | `docs/engineering/legacy-discovery-and-parity/enforcement.md` | lines 74-76, 196-201 | `## Protected records` and `## Capability probe` now state that the sentinel tool writes the exclusive `.consumed` latch beside the record, that the record is never rewritten and keeps `state issued`, and that the probe proves consumption from the latch naming the same `observation_ref`. The text matches the code. | None. | The remediation inputs asked that the sentence stay accurate for the chosen contract. | File inspection |
| Info | `extensions/drm-copilot/src/discovery-root-grant.ts` (`consumeRootGrant`); `.claude/lib/discovery-validation/DiscoveryCapability.psm1:215` (`SHELL` match) | n/a | The prior review's Minor (strict decode of every root-grant neighbour, no pruning) and Nit (`SHELL` deny matched by `agent_id` only) are deferred to issues #1007 and #1008 by user decision (`evidence/other/p17-deferred-findings.2026-10-30T12-13.md`). Recorded here as deferred; not re-evaluated and not findings of this review. The cycle-2 diff does not touch `discovery-root-grant.ts` and leaves line 215 unchanged. | Carry both issue numbers in the PR description as the plan directs. | User decision recorded as final. | `p17-deferred-findings.2026-10-30T12-13.md`; `git diff 3e7acb3e9 HEAD --stat` |
| Info | `config/file-size-baseline.json`; covered files | whole diff | Logical line counts over 724 added or modified covered files on the branch: maximum 535 (`extensions/drm-copilot/jest.config.cjs`), none at or above 700, none above 800; `DiscoveryCapability.psm1` 468 (was 441). The baseline `files` map is empty and unchanged in cycle 2. No Warning row is due under the 700-line advisory tier. | None. | Tiered file-size policy satisfied. | `python -I <scratchpad>/count.py` |
| Info | `evidence/qa-gates/discovery-host-observations.2026-10-30T01-47.md`; `evidence/regression-testing/p17-cross-runtime-smoke.2026-10-30T12-09.md` | whole files | No live host has been driven through the sentinel agent since the identity redesign. The cycle-2 smoke replaces the hook invocation with direct calls to `Get-DiscoverySentinelDecision`, the emitted `consumeSentinelGrant` and `Get-DiscoveryCapabilityObservation` over one real store, which proves the record, path and latch contract across runtimes but not the host's payload field names. The recorded user decision accepts this for the merge. | After merge, run `discovery-capability-sentinel` once from an orchestrator session on Claude Code and call `run_discovery_doctor`, per the launch instructions in the P16-T7 record. | The remaining unverified assumption (host payload carries `agent_id` and `agent_type` for a subagent) is outside the cycle-2 scope and is not a code defect. | File inspection |

There are 0 Blocker findings. There are 0 Major findings. There are 0 Minor findings. There is 1 Nit finding, with no remediation required.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `Get-DiscoveryConsumedLatch` is a small advanced function with mandatory typed parameters that reads through the existing `Invoke-DiscoveryStoreSeam`/`ReadText` seam, so the probe hooks (which pass `Get-DiscoveryDefaultStore`) and the tests (which pass in-memory closures) exercise the same code.
- The latch is attached in `Get-DiscoverySessionObservation` as a reader-side key (`consumed_latch`), so `Get-DiscoveryObservationEvidence` stays pure over hashtables and never touches the store; the comment at line 159 states this.
- The three latch states (`present`, `absent`, `names another observation`) are derived once and the deficiency message carries both the record state and the latch state, which made the fail-before run self-explanatory and makes `doctor` output actionable.
- The acceptance condition is strict in both directions: a record rewritten as `consumed` is rejected even with a latch, which pins the "record is never rewritten" contract rather than tolerating either shape.
- Comment-based help on the new function and the two changed functions, and the module header, describe the contract in the same words as `enforcement.md`.

#### API and safety notes

- The new function is module-internal (not exported); the manifest's export list is unchanged, so the public surface of `DiscoveryCapability.psm1` is the same as in cycle 1.
- Analyzer clean; 468 logical lines.

#### Error handling and logging

- The catch-all in the latch reader mirrors the record reader and yields a named deficiency rather than a silent pass (Info above).

#### Defect

- None blocking. Nit: `consumed_at` in the latch is not validated.

### TypeScript implementation audit

#### What changed well

- No production TypeScript file changed in cycle 2, which is the right outcome of choosing option (b): the consumer was already correct, and the new Jest contract suite now pins its exact effect (`observed: true` result, byte-exact latch, no other write, replay refusal) against the shared fixture so a later change on either side fails a test.
- The suite imports `FIXTURE_DIRECTORY` and `LOCATION` from the existing test support and uses `MemoryStoreIO.writtenPaths()` to prove the write set, which is a stronger assertion than checking the latch alone.

#### Type safety and maintainability

- The fixture is typed through a local `SentinelConsumptionFixture` interface and one `as` cast at the JSON boundary; no `any`, no suppression.

#### Error handling and logging

- Unchanged.

#### Defect

- None.

### Python implementation audit

#### What changed well

- No production Python file changed. `test_sentinel_consumption_fixture.py` proves the fixture is a faithful capture of the committed v2 schema and of the runtime's `canonical_json` digest, which is the one place the Python runtime touches this contract.
- `_freeze` converts the fixture's plain containers into the runtime's immutable `JsonObject`/tuple shapes before digesting, so the digest is computed over the same value shape the runtime canonicalizes; the comment says why.

#### Typing and API notes

- Fully annotated; `cast` only on JSON loaded from the committed fixture.

#### Error handling and logging

- Not applicable (tests only).

---

## Test Quality Audit

All three canonical coverage artifacts were parsed by this review per changed production file. Every changed production file of every language is present and above the floors (Python lowest 90.00% lines / 80.00% branches, TypeScript lowest executable 92.86% lines / 77.78% branches, PowerShell lowest 92.82% lines). `DiscoveryCapability.psm1` is at 183/184 lines with every cycle-added executable line covered and the one missed line (264) pre-existing; `discovery-sentinel.ts` is at 291/295 lines and 57/59 branches. The retained Pester JUnit records 13091 tests, 0 failures, 10 pre-existing skips, with the contract suite at 3/3. A search of the new and changed test files found no temporary-file API, no process launch and no wall clock.

### Reviewed test and QA artifacts

- `artifacts/python/lcov.info` (2026-10-30T12:29Z): 96.69% lines (32105/33204), 93.62% branches (11673/12468); 185 changed production files present.
- `extensions/drm-copilot/coverage/lcov.info` (2026-10-30T12:24Z): 97.05% lines (61496/63367), 93.66% branches (9359/9993); 50 changed files present (3 type-only).
- `artifacts/pester/powershell-coverage.xml` (2026-10-30T12:37Z): 93.41% lines (20374/21812); 38 changed production files present.
- `evidence/qa-gates/p18-coverage-comparison.2026-10-30T12-43.md`: `DiscoveryCapability.psm1` 174/175 to 183/184, 11 changed executable lines, 0 uncovered; agrees with this review's parse.
- `evidence/qa-gates/p18-powershell-junit.2026-10-30T12-41.xml`: suite counts above.
- `evidence/regression-testing/p17-sentinel-contract-fail-before.2026-10-30T11-42.md`: case (b) fails on the unchanged module with the R5 message; cases (a) and (c) pass.
- `evidence/regression-testing/p17-cross-runtime-smoke.2026-10-30T12-09.md`: gate, emitted consumer and probe over one real store; three files; both controls true.

### Quality assessment prompts

- **Determinism:** The fixture pins every clock, nonce, hash and TTL; each suite injects them.
- **Isolation:** Fresh in-memory store per test; the fixture is read-only script state; test support imports modules without `-Force`.
- **Speed:** Python 750.66 s; Jest extension 140.78 s; Pester single process 938.76 s.
- **Diagnostics:** The Pester attribution case passes the probe's deficiency messages as `-Because`, which is how the fail-before run reported the exact defect text.
- **Integration seam:** The prior review's gap is closed: the TypeScript-to-PowerShell boundary is crossed with the real producer output in three suites and once over a real store.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | The fixture carries example digests and a placeholder handler hash (`c` × 64); the test support substitutes the real handler hash at run time. |
| No unsafe subprocess or command construction | ✅ PASS | No process launch in the new code or tests; the smoke used the executor's SCRATCH launcher outside the test population. |
| Input validation at boundaries | ✅ PASS | The latch must be a JSON object; `observation_ref` is compared case-sensitively; a record with any `state` other than `issued` is rejected. |
| Error handling remains explicit | ✅ PASS | Every rejection yields a deficiency naming the record state and latch state. |
| Configuration / path handling is safe | ✅ PASS | The latch path is derived from the record path, never from record content. |
| One-use authorization | ✅ PASS | Consumption is the exclusive `createExclusive` latch; the probe treats only a latch naming the record as consumption; replay refused in Jest. |
| No principal conversion | ✅ PASS | Unchanged from cycle 1; the cycle touched no identity path. |
| Root-only `prepare-agent` | ✅ PASS | Unchanged from cycle 1. |
| Capability probe correctness | ✅ PASS | The probe reports `supported` for exactly the records and latch the gate and consumer produce (contract suites, smoke) and `unsupported` for a missing, foreign or unparseable latch and for a rewritten record. |

---

## Research Log

No external research was required. The review relied on repository source, git history and the feature evidence. The one assumption the prior review left unverified by any artifact, that each host places `agent_id` and `agent_type` in a subagent's PreToolUse payload as the research states, is unchanged and outside the cycle-2 scope; the recorded user decision accepts fixture and smoke proof for this merge.

---

## Verdict

Remediation cycle 2 resolves the prior Blocker on the reader side with a 24-line function and two changed conditions, keeps the observation record immutable, mirrors the module byte-identically, and replaces the hand-authored test records with records built by the gate and a latch pinned to the consumer's exact output in one fixture shared by Python, TypeScript and Pester. The fail-before record proves the suite detected the defect; the Phase 18 gates and the canonical coverage artifacts show every touched language green and above the floors.

The branch is ready for the normal PR flow. No Blocker, Major or Minor remains; one Nit (latch `consumed_at` not validated) needs no remediation, and the two prior non-blocking items are deferred to issues #1007 and #1008 by user decision.
