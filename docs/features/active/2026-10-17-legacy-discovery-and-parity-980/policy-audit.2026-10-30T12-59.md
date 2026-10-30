# Policy Compliance Audit: legacy discovery and parity (issue #980), review cycle 2

---

**Audit Date:** 2026-10-30  
**Code Under Test:** Full branch diff `f7bef6ad16cf567de6462b736bbce7afd83e591a..b8f3b9ee752672753325617e1f417e7af1a69f76` (merge base with `origin/main`, which is `origin/main` itself because the branch was rebased before this cycle, to `feature/legacy-discovery-and-parity-980` HEAD; 237 commits). Outside the feature folder: 1,106 paths (863 added, 239 modified, 4 deleted). By extension: 439 `.py`, 127 `.ts`, 109 `.ps1`, 51 `.psm1`, 103 `.json`, 152 `.md`, 54 `.toml`, 48 `.yaml`/`.yml`, 1 `.cjs`, 1 `.sh` (converter fixture data), and C#/VB project fixtures with no `.cs` source. Remediation cycle 2 (plan Phases 17 and 18, 16 commits from `3e7acb3e9` to HEAD) changed one production file, `.claude/lib/discovery-validation/DiscoveryCapability.psm1`, and its two bundled mirrors; the other ten changed files are a shared fixture, three contract test suites (Python, TypeScript, Pester), Pester test support, three per-host probe suites and one engineering document.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 439 files (185 production files; cycle 2 added only `tests/discovery_runtime/test_sentinel_consumption_fixture.py`) | 15801 collected | ✅ 15795 pass, 0 fail, 6 pre-existing skips (executor record `p18-python-tests.2026-10-30T12-32.md`) | 94.11% lines, 88.78% branches (P0-T2) | 96.69% lines (32105/33204), 93.62% branches (11673/12468), parsed by this review from the canonical `artifacts/python/lcov.info` (2026-10-30T12:29Z) and equal to the retained `p18-python-coverage.2026-10-30T12-32.json` | Lowest changed production file 90.00% lines (`gateway_host_store.py`, 27/30); lowest branches 80.00% (`codex_native_converter/rewrites.py`, 8/10); 0 of 185 changed files below 85% lines or 75% branches |
| TypeScript | 127 files (50 production, all under `extensions/drm-copilot/src/`; no root-package `.ts` file on the branch; cycle 2 added only `test/discovery-sentinel.contract.test.ts`) | 5239 extension | ✅ 5239 pass, 0 fail, 323 suites (executor record `p18-typescript-extension-tests.2026-10-30T12-25.md`) | extension 97.41% lines, 92.65% branches (P0-T3) | 97.05% lines (61496/63367), 93.66% branches (9359/9993), parsed by this review from the canonical `extensions/drm-copilot/coverage/lcov.info` (2026-10-30T12:24Z); the retained `coverage-summary.json` rounds the same counts to 97.04% / 93.65% | Lowest changed executable file 92.86% lines (`repo-automation-service-discovery-agent.ts`, 338/364); lowest branches 77.78% (`lib/codex-native-converter/pipeline-render.ts`, 35/45); 0 of 47 executable changed files below 85% lines or 75% branches; `discovery-sentinel.ts` 98.64% / 96.61%; 3 type-only modules report 0 executable statements (see 1.2.1) |
| PowerShell | 160 files (38 production files in the coverage population; cycle 2 changed `DiscoveryCapability.psm1`) | 13091 | ✅ 13081 pass, 0 fail, 10 pre-existing skips (executor record `p18-powershell-tests.2026-10-30T12-41.md`; JUnit `p18-powershell-junit.2026-10-30T12-41.xml` read by this review) | 92.62% lines (P0, 17730/19142) | 93.41% lines (20374/21812), parsed by this review from the canonical `artifacts/pester/powershell-coverage.xml` (2026-10-30T12:37Z, full single-process run) | Lowest changed production file 92.82% lines (`.codex/hooks/record-subagent-routing-attestation.ps1`, 194/209); `DiscoveryCapability.psm1` 99.46% (183/184; the one missed line, 264, is the pre-existing Codex TOML `matcher` branch, and all 11 executable lines the cycle added are covered); 0 of 38 changed files below 85%; no branch metric under Pester |
| Bash | 1 file (test fixture `tests/fixtures/codex_native_converter/native_surfaces/.claude/lib/bash/parallel-common.sh`) | No bats tests | N/A (fixture data, not executed) | N/A (no coverage) | N/A (no coverage) | N/A |
| JSON | 103 files | N/A | ✅ schema and contract validation (executor record `p18-mirror-and-publication-contracts.2026-10-30T12-43.md`, 77 passed) | N/A (config files) | N/A (config files) | N/A |
| C# | 0 `.cs` files (project fixtures only) | N/A | N/A | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/typescript-extension-coverage-summary.2026-10-18T03-58.json`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (2026-10-30T12:24Z, newer than the last TypeScript source change on the branch, commit `01602ca2a` at 2026-10-30T10:54Z); retained copies `evidence/qa-gates/p18-typescript-extension-lcov.2026-10-30T12-25.info` and `p18-typescript-extension-coverage-summary.2026-10-30T12-25.json`. The root `coverage/lcov.info` (2026-10-29T21:40Z) predates the rebase; it is not required because no root-package `.ts` file is in the branch diff.
- Python baseline coverage artifact: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/python-coverage.2026-10-18T03-51.json`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (2026-10-30T12:29Z, newer than the last Python source change on the branch, commit `7d523797f` at 2026-10-30T10:54Z); retained copy `evidence/qa-gates/p18-python-coverage.2026-10-30T12-32.json`
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/powershell-coverage.2026-10-18T04-22.xml`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (2026-10-30T12:37Z, newer than the fix commit `a44507cdb` at 2026-10-30T12:07Z; full single-process run, 20374/21812 lines); retained copy `evidence/qa-gates/p18-powershell-coverage.2026-10-30T12-41.xml`
- Per-language comparison summary: section 1.2.1.

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

Missing artifact paths for this audit: none. Every coverage artifact required by the Coverage Verification procedure exists for head `b8f3b9ee7`, postdates the last source change of its language, and was parsed by this review.

---

## Executive Summary

This audit re-examines the full feature-versus-base diff after remediation cycle 2 (plan Phases 17 and 18), which addressed the single blocking finding R5 of the 2026-10-30T10-19 review set. R5 is resolved in code, end to end. The probe module `DiscoveryCapability.psm1` now reads the exclusive `<record>.json.consumed` latch beside each host observation through the same `ReadText` seam it uses for the record (`Get-DiscoveryConsumedLatch`, lines 103-126; attached as `consumed_latch` at line 160) and accepts a sentinel tool observation only when the record's `state` is `issued` as the gate writes it and the latch names the record's own `observation_ref` (line 205-207). That is exactly what `consumeSentinelGrant` leaves behind (`discovery-sentinel.ts:263, 272-278`): the latch at `${path}.consumed` containing `canonicalJson({consumed_at, observation_ref})`, and the record untouched. The path derivation agrees on both sides (`<authority>/sessions/<sha256(session)>/observations/<observation_ref>.json` plus `.consumed`), confirmed by the shared fixture's `relative_paths` and `latch.relative_path`, by the Python path test, and by the cross-runtime smoke over one real filesystem store (`evidence/regression-testing/p17-cross-runtime-smoke.2026-10-30T12-09.md`, where the PowerShell gate wrote, the emitted TypeScript consumer latched, and the PowerShell probe reported `trusted_attribution` and `forbidden_tools_denied` true).

The fixture is no longer hand-written. `tests/fixtures/discovery_host/sentinel-consumption.json` carries two PreToolUse envelopes; the Pester contract suite rebuilds both records from those envelopes through `ConvertFrom-DiscoveryHostPayloadText`, `Get-DiscoveryTrustedPrincipal`, `Resolve-DiscoveryToolName` and `ConvertTo-DiscoveryHostObservationRecord` and compares them key by key and in key order with the fixture records; the Jest contract suite runs the real `consumeSentinelGrant` over the fixture records and asserts the latch text byte for byte and that no other path was written; the Python suite validates both records against the committed `host-observation` schema and recomputes the input digest with the runtime's `canonical_json`. `Add-GateSentinelObservation` builds its records through the same gate modules and no longer seeds `state = 'consumed'`; the only remaining `state = 'consumed'` in test support is the deliberate rejection case (`DiscoveryCapability.Tests.ps1:160`), which proves a rewritten record without a latch is refused. The fail-before run (`p17-sentinel-contract-fail-before.2026-10-30T11-42.md`) shows the contract suite failing on the unchanged module with the R5 message and passing after the fix. The three `DiscoveryCapability.psm1` copies share SHA-256 `ab693926…2487` (hashed by this review).

No new blocking finding is introduced by the cycle-2 diff. The Minor (`consumeRootGrant` strict decode of every root-grant neighbour, no pruning) and the Nit (`SHELL` deny observation matched by `agent_id` only) of the prior review are deferred to issues #1007 and #1008 by user decision (`evidence/other/p17-deferred-findings.2026-10-30T12-13.md`); they are recorded as deferred, not as findings. Two observations on the new code are classified Nit and Info in the code review with no remediation required.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (via `.claude/rules/python.md`, `python-suppressions.md`)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- ✅ TypeScript: `.claude/rules/typescript.md`, `typescript-suppressions.md`, `architecture-boundaries.md`
- N/A Bash: shfmt + shellcheck + bats (the only `.sh` file is converter fixture data)
- ✅ JSON: schema and contract validation per executor record `evidence/qa-gates/p18-mirror-and-publication-contracts.2026-10-30T12-43.md`

Toolchain results are taken from the executor's Phase 18 records and cross-checked against the canonical coverage artifacts and the retained JUnit file this review parsed. The review ran check-only commands; it did not re-run the suites.

**Temporary artifacts cleanup:**
- ✅ `validate_evidence_locations.py --root .` exits 0 (run by this review at head `b8f3b9ee7`); `git diff --name-only f7bef6ad HEAD -- artifacts/` lists 0 tracked paths.
- ✅ The review scripts used for this audit live only in the session scratchpad.
- ✅ The executor's SCRATCH harness, emit directory and smoke store are not committed (`p17-cross-runtime-smoke.2026-10-30T12-09.md` `## Cleanup`).

---

## Rejected Scope Narrowing

No scope narrowing was detected. The coordinator's prompt asks the review to focus on the resolution of R5 and on the cycle-2 diff, and states as a user decision that the prior Minor and Nit are deferred to issues #1007 and #1008 and that cycle-1 findings need not be re-litigated unless regressed. These instructions prioritize attention and settle the disposition of two previously reported non-blocking items; they do not narrow the file, language or coverage scope. This audit evaluated coverage, file size, evidence locations, mirror parity and the toolchain over the full branch diff against the resolved base, and verified that the cycle-2 diff does not regress any cycle-1 resolution (the cycle touched no file those resolutions live in).

---

## Evidence Location Compliance

Command: `python -I scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0, no finding printed).

| Path | Status | Canonical replacement |
|---|---|---|
| (none) | PASS | n/a |

A scan of the branch diff (`git diff --name-only f7bef6ad HEAD -- artifacts/`) found no tracked file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. The Phase 17 and 18 evidence is under `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/{qa-gates,regression-testing,other,remediation-baseline}/`. The retained Pester JUnit and coverage copies carry `hostname="REDACTED"` and repository-relative paths; the TypeScript coverage summary keys are repository-relative.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The cycle-1 isolation runs stand (`evidence/regression-testing/p16-isolation.2026-10-30T01-45.md`). The three new suites hold no mutable shared state: the Jest contract suite builds a fresh `MemoryStoreIO` per test; the Pester contract suite reads the committed fixture once in `BeforeAll` and builds a new in-memory store per `It`; `Add-GateSentinelObservation` mutates only the store the caller passes, which `Get-GateStore` creates per call. `DiscoveryGate.TestSupport.ps1:19-22` imports the gate modules without `-Force` at dot-source time so that a suite that imported them already is unaffected. The P18-T3 single process ran all 466 Pester files in one session with 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behaviour per `It`/`it`/`test_`: record rebuild, attribution with latch, no-latch rejection (Pester); consumption result, exact latch text and no rewrite, replay refusal (Jest); schema validity, digest, path partition, latch shape, issued state (Python). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Python 750.66 s for 15801 tests (under the 20-minute guard); Jest extension 140.78 s; Pester single process 938.76 s. |
| **Determinism** - Consistent results | ✅ PASS | The fixture pins `gate_now`, `consumer_now`, `nonce`, `handler_sha256` and `ttl_seconds`; the Pester suite injects `-Now` and `-TtlSeconds`; the Jest suite passes `now: new Date(CONTRACT.consumer_now)`. No wall clock, randomness or process. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Names state the contract: "writes exactly the pinned latch text beside the tool record and never rewrites the record", "rejects a record rewritten as consumed without the consumer latch", `test_tool_record_is_issued_and_never_rewritten_as_consumed`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** Python 94.11% lines / 88.78% branches; TypeScript extension 97.41% / 92.65%; PowerShell 92.62% lines.<br>**Command:** recorded in `evidence/baseline/python-tests.2026-10-18T03-51.md`, `typescript-extension-tests.2026-10-18T03-58.md`, `powershell-tests.2026-10-18T04-21.md`<br>**Timestamp:** 2026-10-18 03:51 to 04:22 |
| **No Coverage Regression** | ✅ PASS | Python 94.11% to 96.69% lines (+2.58), 88.78% to 93.62% branches (+4.84). TypeScript extension 97.41% to 97.05% lines (-0.36, above the floor), 92.65% to 93.66% branches (+1.01). PowerShell 92.62% to 93.41% (+0.79). Against the cycle-1 figures (96.69/93.59, 97.04/93.64, 93.34) no total is lower. Changed-line regression: the one production file the cycle changed moved from 174/175 to 183/184 lines with all 11 added executable lines covered (`p18-coverage-comparison.2026-10-30T12-43.md`, confirmed by this review's parse of the canonical XML: missed line 264 only). |
| **New Code Coverage ≥90%** | ✅ PASS | Python: lowest changed production file 90.00% lines. TypeScript: lowest changed executable file 92.86% lines. PowerShell: lowest changed production file 92.82%; `DiscoveryCapability.psm1` 99.46%. All parsed by this review from the canonical artifacts. |
| **Comprehensive Coverage** | ✅ PASS | `changed production files: 185; measured: 185; not in artifact: []` (Python), `50; 50; []` (TypeScript extension), `38; 38; []` (PowerShell). |
| **Positive Flows** - Valid inputs | ✅ PASS | Pester "proves attribution from the fixture records beside the consumer latch" (`TrustedAttribution`, `ForbiddenDenied`, `SentinelRef`, `ShellRef`, 0 deficiencies); Jest "consumes the gate-built tool record and reports the fixture result"; per-host probe suites "proves attribution from the recorded sentinel observation pair" now against gate-built records. |
| **Negative Flows** - Invalid inputs | ✅ PASS | No latch (`latch absent`), record rewritten as `consumed` without latch, latch naming another observation (`latch names another observation`), unparseable latch (treated as absent), replay refusal in Jest; the seven pre-existing `unsupported` probe cases re-expressed with `NoLatch`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | "accepts a later valid observation when an earlier sentinel observation is rejected" now asserts exactly one deficiency naming the rejected reference; the Jest suite asserts `writtenPaths()` equals the single latch path. |
| **Error Handling** - Error paths | ✅ PASS | `Get-DiscoveryConsumedLatch` returns `$null` for an unreadable or non-object latch, which the evidence derivation reports as `latch absent` (tested with `{not json`). |
| **Concurrency** - If applicable | ✅ PASS | Unchanged from cycle 1: latch races in `discovery-sentinel.test.ts` (`AUTHORITY_LOCKED` maps to `observed: false`). |
| **State Transitions** - If applicable | ✅ PASS | The cycle-1 PARTIAL is resolved: the `issued` record plus `.consumed` latch transition is now tested across the language boundary with the producer's output (Pester rebuild from envelopes), the consumer's exact effect (Jest latch text pinned in the fixture) and the reader (Pester evidence derivation), and once over a real filesystem store (P17-T5 smoke). |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 94.11% lines -> Post-change: 96.69% lines. Change: +2.58% lines, +4.84% branches (88.78% to 93.62%). New/changed-code coverage: lowest changed production file 90.00% lines / lowest branches 80.00%; 0 of 185 changed files below 85% lines or 75% branches. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (2026-10-30T12:29Z), `evidence/qa-gates/p18-python-tests.2026-10-30T12-32.md`, `p18-python-coverage.2026-10-30T12-32.json`.
- TypeScript: Baseline: 97.41% lines -> Post-change: 97.05% lines (extension package; no root-package `.ts` file is on the branch). Change: -0.36% lines / +1.01% branches. New/changed-code coverage: lowest changed executable file 92.86% lines, lowest branches 77.78%; 0 of 47 executable changed files below 85% lines or 75% branches; `discovery-sentinel.ts` 98.64% lines / 96.61% branches. Three changed modules (`discovery-service-types.ts`, `repo-automation-service-contract.ts`, `repo-automation-service-discovery-types.ts`) contain no exported function, constant, class or enum (a search for `export (function|const|class|let|enum|async)` returns none); they report 0 executable statements covered, which the type-only clarification in `.claude/rules/general-unit-test.md` permits. `collectCoverageFrom` is `["src/**/*.ts", "!src/**/*.d.ts"]` with no production exclude, and `extensions/drm-copilot/jest.config.cjs`, `jest.discovery-coverage.json`, `pyproject.toml` and `config/poshqc-coverage.json` are unchanged since the cycle-2 start. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` (2026-10-30T12:24Z), `evidence/qa-gates/p18-typescript-extension-tests.2026-10-30T12-25.md`, `p18-typescript-extension-lcov.2026-10-30T12-25.info`.
- PowerShell: Baseline: 92.62% lines -> Post-change: 93.41% lines. Change: +0.79% lines (no branch metric under Pester). New/changed-code coverage: lowest changed production file 92.82% lines; `DiscoveryCapability.psm1` 99.46% with every cycle-added line covered; 0 of 38 changed files below 85%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (full run, 20374/21812), `evidence/qa-gates/p18-powershell-tests.2026-10-30T12-41.md`, `p18-powershell-coverage.2026-10-30T12-41.xml`.
- C#: N/A - out of scope (zero `.cs` files changed).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | The Pester attribution case passes the joined deficiency messages as `-Because`, so a failure names the probe's reason (this is how the fail-before run reported "was not consumed by the sentinel tool (state issued)"); rejection cases assert the exact `(state …, latch …)` text. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Separated phases in all three new suites. |
| **Document Intent** | ✅ PASS | File headers in all three suites state the producer, consumer and reader roles and that the only file read is the committed fixture. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | A search of the new and changed test files for `tmp_path`, `tempfile`, `mkdtemp`, `os.tmpdir`, `New-TemporaryFile`, `TestDrive`, `$env:TEMP` and `GetTempPath` returns no match. The cross-runtime smoke used a SCRATCH store that was created and removed inside the executor's session and is not a test. |
| **Use Mocks/Stubs** | ✅ PASS | In-memory store hashtables with `ReadText`/`ListEntries` closures (Pester), `MemoryStoreIO` (Jest), no mocking in Python. |
| **Environment Stability** | ✅ PASS | Fixture-pinned clock, nonce and handler hash; `Resolve-DiscoveryAuthorityLocation` called with explicit platform, home and local-application-data values. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the independent re-review for head `b8f3b9ee7`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-10-30T10-19.md` (R5 with two acceptable options and a verification list); the plan's `## Revision: remediation cycle 2`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-10-17T22-38.md` Phases 17 and 18; `evidence/remediation-baseline/phase17-instructions-read.2026-10-30T11-31.md`. |
| **Document the plan** | ✅ PASS | 171 of 171 plan tasks checked, including P17-T1 to P17-T7 and P18-T1 to P18-T8, each with per-task evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Option (b) of the remediation inputs was taken: the record stays immutable and the reader learns the latch; one new 24-line function and two changed lines in the evidence derivation. |
| **Reusability** | ✅ PASS | `Get-DiscoveryConsumedLatch` reads through the existing `Invoke-DiscoveryStoreSeam`/`ReadText` seam; the fixture is shared by three runtimes; `Get-GateSentinelRecord` is reused by every probe suite. |
| **Extensibility** | ✅ PASS | The latch is attached as a reader-side key (`consumed_latch`), so other one-use record kinds can reuse the same reader without a schema change. |
| **Separation of concerns** | ✅ PASS | The cycle-1 PARTIAL is resolved: the one cross-language contract (record shape, path, digest, latch text) is now defined in one fixture and replayed by the producer, consumer and reader tests. `Get-DiscoveryObservationEvidence` stays pure over the hashtables it receives; store access stays in `Get-DiscoverySessionObservation`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | `DiscoveryCapability.psm1` 468 logical lines (was 441); new test files 118, 100 and 99 lines; test support 279. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts by this review over all 724 added or modified covered files on the branch: maximum 535 (`extensions/drm-copilot/jest.config.cjs`), then 500 (`mutation_plan.py`, `analyzer/dependency_inputs.py`, `enforcement-hooks-no-python-invocation.Tests.ps1`). No file at or above 700; none above 800. `config/file-size-baseline.json` changed on the branch only by emptying the `files` map (the `agentic_sync.py: 819` entry was removed); no entry was added or increased, and the file is unchanged in cycle 2. |
| **Public vs internal** | ✅ PASS | `Get-DiscoveryConsumedLatch` is module-internal (not in the `Export-ModuleMember` list at line 463); the manifest exports are unchanged. |
| **No circular dependencies** | ✅ PASS | Cycle 2 changed no module import; the cycle-1 architecture records stand (`p16-architecture-boundaries.2026-10-30T01-55.md`, `p16-typescript-extension-architecture.2026-10-30T01-40.md`). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-DiscoveryConsumedLatch`, `consumed_latch`, `Get-GateSentinelRecord`, `Get-FixtureRecordFromEnvelope`, `storeWithFixtureRecords`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on the new function and updated help on the two changed functions and the module header; docstrings on every Python test; file-level JSDoc on the Jest suite. |
| **Comment why, not what** | ✅ PASS | `DiscoveryCapability.psm1:159` ("The latch is the consumption marker; it is attached here so the evidence derivation never touches the store."), `:203`; `DiscoveryGate.TestSupport.ps1:17-18` explains the no-`-Force` import. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check .`; `npm run format:check` (extension); `Invoke-PoshQCFormat`<br>**Result:** no change (`p18-python-format.2026-10-30T12-32.md`, `p18-typescript-extension-format.2026-10-30T12-25.md`, `p18-powershell-format.2026-10-30T12-41.md`) |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check .`; `npm run lint`; `Invoke-PoshQCAnalyze`<br>**Result:** no findings (`p18-python-lint`, `p18-typescript-extension-lint`, `p18-powershell-analyze`) |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright`; `npm run typecheck`<br>**Result:** 0 errors (`p18-python-types`, `p18-typescript-extension-types`); N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch`; `node run-jest.cjs --coverage --runInBand`; `Invoke-PoshQCTest -Root .`<br>**Result:** 15795 / 5239 / 13081 passed, 0 failed; coverage artifacts at the canonical paths and under `evidence/qa-gates/` |
| **Full toolchain loop** | ✅ PASS | Phase 18 records one clean cycle per touched language with no fix and no restart (`p18-powershell-tests`: "One clean pass with no fix and no restart"). |
| **Explicit reporting** | ✅ PASS | Commands, exit codes and results in `evidence/qa-gates/p18-*.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | `completion-report.md` and `handoff.md` requalified for cycle 2 (P17-T7, P18-T8); each commit names its plan task. |
| **Design choices explained** | ✅ PASS | `docs/engineering/legacy-discovery-and-parity/enforcement.md` `## Protected records` and `## Capability probe` now state that the record is never rewritten and the probe proves consumption from the latch (lines 74-76, 196-201). |
| **Update supporting documents** | ✅ PASS | `spec.md:6-7` and `user-story.md:5-6` carry the cycle-2 status with `Last Updated 2026-10-30T12-13`; the three `DiscoveryCapability.psm1` copies hash identically. |
| **Provide next steps** | ✅ PASS | `handoff.md` and `p17-deferred-findings.2026-10-30T12-13.md` name issues #1007 and #1008 for the orchestrator's PR description. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** 979 files unchanged (`p18-python-format.2026-10-30T12-32.md`) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check .`<br>**Result:** clean (`p18-python-lint.2026-10-30T12-32.md`) |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors (`p18-python-types.2026-10-30T12-32.md`) |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch`<br>**Result:** 15795 passed, 6 skipped, 750.66 s; 96.69% / 93.62% confirmed from `artifacts/python/lcov.info` |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | No Python production file changed in cycle 2. The new test module is fully annotated; `cast` is used only on JSON loaded from the committed fixture. |
| **Dataclasses for value objects** | ✅ PASS | Unchanged (`HostPrincipal`, `WorkspaceBinding`, `TrustedIdentity`). |
| **Protocols/ABCs for interfaces** | ✅ PASS | Unchanged (`HostStoreIO`). |
| **Avoid utility classes** | ✅ PASS | The new test module exposes functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | Unchanged from cycle 1 (`gateway_host.py:296-301`). |
| **Logging over print** | ✅ PASS | No `print` in production modules. |
| **Invariants at construction** | ✅ PASS | Unchanged (`SchemaCatalog.__post_init__`). |

---

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .`<br>**Result:** 1241 files already formatted (`p18-powershell-format.2026-10-30T12-41.md`) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** no findings (`p18-powershell-analyze.2026-10-30T12-41.md`) |
| **Fix all findings** | ✅ PASS | No open analyzer findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Modules and suites declare PowerShell 7+, the repository requirement. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `Get-DiscoveryConsumedLatch` has `[CmdletBinding()]`, `[OutputType([hashtable])]` and mandatory typed parameters. |
| **Parameter validation** | ✅ PASS | `[Parameter(Mandatory = $true)]` on `Store` and `Path`. |
| **Avoid global state** | ✅ PASS | The store is passed explicitly; no script-scoped mutable state was added to the module. |
| **Error handling** | ✅ PASS | The latch read is wrapped in `try`/`catch` returning `$null`, matching the record-read pattern at lines 154-157 for an evidence path where an unreadable sibling is "no evidence" by design (see the code review Info row). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest PowerShell production file 480 logical lines (`DiscoveryAuthorization.psm1`); `DiscoveryCapability.psm1` 468; none at or above 700. |
| **Approved verbs** | ✅ PASS | `Get-` on the new function; analyzer clean. |
| **Comment why** | ✅ PASS | Lines 159 and 203 explain why the latch is attached in the reader and what the three latch states mean. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | No change. |
| **Step 2: Analyze** | ✅ PASS | No findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 13091 tests, 0 failed, 10 pre-existing skips; single-process coverage 93.41%. |
| **Rerun loop if needed** | ✅ PASS | One clean pass recorded. |

---

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | **Command:** `npm run format:check`<br>**Result:** clean (`p18-typescript-extension-format.2026-10-30T12-25.md`) |
| **Linting with ESLint** | ✅ PASS | **Command:** `npm run lint`<br>**Result:** clean |
| **Type checking with TSC** | ✅ PASS | **Command:** `npm run typecheck`<br>**Result:** clean |
| **Testing with Jest** | ✅ PASS | **Command:** `node run-jest.cjs --coverage --runInBand`<br>**Result:** 323 suites, 5239 passed; every per-file threshold met |
| **Coverage artifact** | ✅ PASS | `extensions/drm-copilot/coverage/lcov.info` present (2026-10-30T12:24Z) and newer than the last TypeScript source change. |
| **Coverage configuration** | ✅ PASS | No production path excluded; per-file threshold map unchanged in cycle 2; no `global` key. |
| **Suppressions** | ✅ PASS | No `@ts-ignore`, `@ts-nocheck` or `eslint-disable` in the new contract suite; no TypeScript production file changed in cycle 2. |

---

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | **Command:** `poetry run python -m scripts.dev_tools.format_json`<br>**Result:** no drift in cycle 1 (`p16-repository-contracts.2026-10-30T01-55.md`); the one JSON file added in cycle 2 is the two-space-indented fixture read by three test suites |
| **Schema validation** | ✅ PASS | **Command:** `poetry run pytest tests/discovery_runtime/test_sentinel_consumption_fixture.py`<br>**Result:** both fixture records validate against `host-observation` (`test_records_are_schema_valid_host_observations`) |
| **Required $schema** | ✅ PASS | Both fixture records carry `$schema` `urn:drm-copilot:discovery:2.0.0:host-observation`. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Strict loaders in all three runtimes. |
| **Deterministic key order** | ✅ PASS | The fixture's `input_sha256` is recomputed by Python `canonical_json` and by TypeScript `computeInputDigest` (the Jest suite would report `observed: false` on a digest mismatch), and the Pester suite asserts the gate's key order. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `test_sentinel_consumption_fixture.py` uses `pytest.mark.parametrize`. |
| **Coverage expectation** | ✅ PASS | 96.69% lines and 93.62% branches repo-wide; lowest changed file 90.00%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Five tests, one assertion group each (schema validity, digest, path partition, latch shape, issued state). |
| **Mocking sparingly** | ✅ PASS | None used. |
| **Organization** | ✅ PASS | `tests/discovery_runtime/` beside `test_tool_authorization_fixture.py`, the existing fixture-replay sibling. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_tool_record_is_issued_and_never_rewritten_as_consumed`. |
| **Docstrings/comments** | ✅ PASS | Module and per-test docstrings present. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch`<br>**Result:** 15795 passed, 6 skipped |
| **No Alternative Test Runners** | ✅ PASS | Only Pytest. |

---

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `Describe`/`It`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7+ per repository rule. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One control per `It`; the matrix rows name the control and the expected text. |
| **Test Behavior Over Implementation** | ✅ PASS | The cycle-1 PARTIAL is resolved: the probe suites now feed records built by the gate's own normalizer, principal, tool routing and record builder (`Get-GateSentinelRecord`) and the consumer's exact latch text from the fixture, not a hand-authored shape. The hand-seeded `state = 'consumed'` fixture is gone; the remaining `state = 'consumed'` override at `DiscoveryCapability.Tests.ps1:160` is the deliberate rejection case. |
| **Mocking Used Sparingly** | ✅ PASS | In-memory store hashtables; real gate modules. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/discovery-validation/DiscoverySentinelConsumption.Contract.Tests.ps1`<br>**Code file:** `.claude/lib/discovery-validation/DiscoveryCapability.psm1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `DiscoverySentinelConsumption.Contract.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Used throughout. |
| **Logical Grouping** | ✅ PASS | Contract suite separate from the probe suites; per-host probe suites unchanged in structure. |
| **Docstrings/Comments** | ✅ PASS | Suite header and `It` names state the contract. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** 13091 tests, 0 failed (JUnit read by this review: contract suite 3/3, `DiscoveryCapability.Tests.ps1` 43/43, host probe suites 12/12, 12/12, 10/10) |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### `DiscoveryCapability.psm1` (probe from host observations, cycle-2 change)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `DiscoverySentinelConsumption.Contract.Tests.ps1` "proves attribution from the fixture records beside the consumer latch" | Positive (cross-runtime contract) | 103-126, 148-164, 194-224 | ✅ |
| `DiscoverySentinelConsumption.Contract.Tests.ps1` "reports the pair without the latch as not consumed" | Negative | 205-207 (`latch absent`) | ✅ |
| `DiscoveryCapability.Tests.ps1` "rejects a record rewritten as consumed without the consumer latch" | Negative | 207 (`state consumed, latch absent`) | ✅ |
| `DiscoveryCapability.Tests.ps1` "rejects a latch naming another observation and treats an unparseable latch as absent" | Negative | 120-125, 205 | ✅ |
| `DiscoveryCapability.Tests.ps1` "accepts a later valid observation when an earlier sentinel observation is rejected" | Edge | 199-212 | ✅ |
| Per-host probe suites "proves attribution from the recorded sentinel observation pair" | Positive (gate-built records) | 264-420 | ✅ |

**Coverage:** 183/184 lines (99.46%); the missed line 264 is the pre-existing Codex TOML `matcher` branch of `Get-DiscoveryHostRegistration`.

**Not covered:** Nothing in the cycle-2 change. The latch's `consumed_at` member is not validated by the probe (Nit in the code review; no test needed for the chosen contract).

---

### `discovery-sentinel.ts` (consumer, unchanged in cycle 2, newly contract-tested)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `discovery-sentinel.contract.test.ts` "consumes the gate-built tool record and reports the fixture result" | Positive | 252-295 | ✅ |
| `discovery-sentinel.contract.test.ts` "writes exactly the pinned latch text beside the tool record and never rewrites the record" | Contract | 272-278 | ✅ |
| `discovery-sentinel.contract.test.ts` "refuses a second consumption once the latch exists" | Negative | 263, 267-268 | ✅ |

**Coverage:** 291/295 lines (98.64%), 57/59 branches (96.61%).

**Not covered:** Four lines in the pre-existing error-rethrow branches (`listObservations` non-authorization error, `createExclusive` non-lock error).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 15801 Python + 5239 TS extension + 13091 Pester | ✅ |
| Tests Passed | 15795 + 5239 + 13081 (100% of non-skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 750.66 s Python; 140.78 s Jest extension; 938.76 s Pester single process | ✅ |
| Average Time per Test | about 47 ms Python | ✅ Fast |
| Discovery Time | not recorded separately | ✅ |
| Functions/Classes Tested | 185/185 changed Python, 50/50 changed TypeScript, 38/38 changed PowerShell production files present in coverage | ✅ |
| Test File Size | maximum 500 logical lines (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`) | ✅ PASS |
| Code Coverage (if applicable) | Python 96.69% / 93.62%; TypeScript extension 97.05% / 93.66%; PowerShell 93.41% | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 979 unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | clean | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest --cov --cov-branch` | 15795 passed, 6 skipped | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | no change | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | no findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 13091 / 0 failed | ✅ |

**Notes:**
The review re-ran no suite. It parsed the three canonical coverage artifacts per changed production file, read the retained Pester JUnit, ran `validate_evidence_locations.py`, measured logical line counts over 724 covered files, hashed the three `DiscoveryCapability.psm1` copies, searched the test trees for hand-seeded `consumed` state and for temporary-file APIs, and read the cycle-2 diff in full (`git diff 3e7acb3e9 HEAD`).

---

## 8. Gaps and Exceptions

### Identified Gaps

- None blocking. The cycle-2 change set introduces no coverage, exclusion, file-size, temporary-file, order-dependence or mirror-parity policy breach, and the R5 contract is proved on both sides and across the boundary.
- **Latch content beyond `observation_ref` is not validated (Nit, no remediation required):** `Get-DiscoveryObservationEvidence` reads only `observation_ref` from the latch; `consumed_at` is not checked against the attestation window. The record's own `observed_at` TTL bounds the evidence, and the latch lives in the protected store the MCP server writes, so the exposure is limited to a latch written far after the observation. Recorded in the code review.
- **Catch-all in the latch reader (Info):** `Get-DiscoveryConsumedLatch` returns `$null` on any exception. This matches the existing record-read pattern in the same function family and is the documented "no evidence" semantics of a reader that must never refuse; it is not a silent failure in a decision path, because the deficiency message names the latch state.

### Deferred by user decision (not findings of this review)

- `extensions/drm-copilot/src/discovery-root-grant.ts:228-245`: strict decode of every `root-grants/` neighbour and no pruning (prior Minor) deferred to issue #1007.
- `.claude/lib/discovery-validation/DiscoveryCapability.psm1:215`: `SHELL` deny observation matched by `agent_id` only (prior Nit) deferred to issue #1008.

### Prior findings verified resolved

- R5 (prior Blocker, sentinel consumption contract): resolved in `DiscoveryCapability.psm1` lines 103-126, 158-161 and 203-207; mirrored byte-identically; proved by the fail-before run, the three contract suites and the cross-runtime smoke. Detailed in the Executive Summary and the code review.
- Cycle-1 resolutions (identity supplier, probe self-attestation, TypeScript coverage artifacts, evidence locations, Python latch and expiry, the Minors and Nit): not re-litigated; the cycle-2 diff touches none of the files those resolutions live in, so no regression is possible from this cycle.

### Approved Exceptions

**None.** No exceptions needed. The three type-only TypeScript modules reporting 0 executable statements fall under the type-only clarification in `.claude/rules/general-unit-test.md`, which is not an exception.

### Removed/Skipped Tests

**None.** The "unconsumed sentinel grant" cases were re-expressed with `NoLatch` rather than removed, as the remediation inputs required; the "accepts a later valid observation" case gained two assertions; three new cases were added. The 6 Python and 10 Pester skips are pre-existing and unchanged.

---

## 9. Summary of Changes

### Commits in This PR/Branch

237 commits from `f7bef6ad` to `b8f3b9ee7`. The 16 cycle-2 commits examined in full:

1. **b32f10d59** - docs(discovery): record the cycle-2 preflight fixes for Phases 17 and 18
2. **e16a69114** - docs(discovery): record the cycle-2 remediation baseline (P17-T1)
3. **3aeaabad0** - test(discovery): pin the sentinel consumption contract in a shared fixture (P17-T2)
4. **52055c210** - test(discovery): prove the sentinel consumption defect with the shared fixture (P17-T3)
5. **a44507cdb** - fix(discovery): prove sentinel consumption from the .consumed latch in the probe (P17-T4)
6. **526616a67** - docs(discovery): record the cross-runtime sentinel consumption smoke (P17-T5)
7. **6be90cc6b** - chore(discovery): mirror the corrected probe module into the bundles (P17-T6)
8. **3f25c54de** - docs(discovery): document the latch consumption contract and the deferred findings (P17-T7)
9. **743ec9d69** to **b8f3b9ee7** - docs(discovery): Phase 18 gate records, coverage comparison, parity, AC reconciliation, self-review, handoff (P18-T1 to P18-T8)

### Files Modified

1. **.claude/lib/discovery-validation/DiscoveryCapability.psm1** (MODIFIED, +69/-11 logical) and its two bundled mirrors under `extensions/drm-copilot/resources/`
   - `Get-DiscoveryConsumedLatch` added; `Get-DiscoverySessionObservation` attaches `consumed_latch`; `Get-DiscoveryObservationEvidence` requires `state issued` plus a latch naming the record.
2. **tests/fixtures/discovery_host/sentinel-consumption.json** (NEW) and its three replays: `tests/discovery_runtime/test_sentinel_consumption_fixture.py`, `extensions/drm-copilot/test/discovery-sentinel.contract.test.ts`, `tests/scripts/claude-lib/discovery-validation/DiscoverySentinelConsumption.Contract.Tests.ps1` (NEW)
3. **tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1**, **DiscoveryCapability.Tests.ps1**, three per-host **discovery-capability.Tests.ps1** (MODIFIED)
   - Records built from the fixture envelopes through the gate modules; `NoLatch` switch; three new rejection cases.
4. **docs/engineering/legacy-discovery-and-parity/enforcement.md** (MODIFIED)
5. Feature folder: plan, spec and user-story status lines, completion report, handoff, traceability and 32 evidence records.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

Python, TypeScript, PowerShell, file-size, mirror-parity, evidence-location, test-isolation and toolchain policies are met on independently parsed evidence. The blocking finding of the prior review is resolved in code with a shared fixture produced from real code paths, a fail-before record, three contract suites and one real-store smoke. The two cycle-2 observations (latch `consumed_at` not validated; catch-all in the latch reader) are Nit and Info with no remediation required. The two prior non-blocking items are deferred to issues #1007 and #1008 by user decision.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation inputs, plan revision and baseline present.
- ✅ Design Principles: one cross-language contract defined once in a fixture and replayed by producer, consumer and reader.
- ✅ Module & File Structure: maximum 535 logical lines; baseline map empty and unchanged.
- ✅ Naming, Docs, Comments: complete.
- ✅ Toolchain Execution: one clean cycle per touched language with retained coverage.
- ✅ Summarize & Document: status lines, design documentation, deferrals and handoff current.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright, Pytest clean.
- ✅ Python Design & Typing: no production change; typed test module.
- ✅ Error Handling: unchanged.

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyzer clean.
- ✅ PowerShell Design & Safety: advanced function, injected store, no new module state.
- ✅ Structure & Naming: approved verbs, at most 480 lines.
- ✅ Toolchain: 13091 tests green.

**For TypeScript:**
- ✅ Tooling: Prettier, ESLint, TSC, Jest clean.
- ✅ Coverage artifact present and current; per-file thresholds unchanged; no production exclude.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: new suites hold no shared mutable state; single-process run green.
- ✅ Coverage & Scenarios: every language parsed and above floor; state transition now tested across the boundary.
- ✅ Test Structure: failure messages carry the probe's reason.
- ✅ External Dependencies: no temp files or real processes.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest, 96.69% / 93.62%.
- ✅ Test Style & Structure: focused, parametrized.
- ✅ Naming & Readability: descriptive.
- ✅ Toolchain: green.

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC.
- ✅ Test Style & Structure: probe suites assert against gate-built records and the consumer's exact effect.
- ✅ Naming & Readability: `*.Tests.ps1`.
- ✅ Toolchain: green.

---

### Metrics Summary

- ✅ 34,115 of 34,115 non-skipped tests passing across Python, TypeScript extension and Pester (executor records; Pester JUnit read by this review)
- ✅ 185 of 185 changed Python, 50 of 50 changed TypeScript and 38 of 38 changed PowerShell production files measured
- ✅ Python 96.69% lines / 93.62% branches; TypeScript extension 97.05% / 93.66%; PowerShell 93.41% lines
- ✅ Proper file organization: tests mirror source trees
- ✅ All format, lint and type checks passing
- ✅ Test execution time: Python 750.66 s
- ✅ Zero Blockers; zero Majors; one Nit and one Info on the cycle-2 code, no remediation required

---

### Recommendation

**Approve**

The branch meets the repository's policy gates on independently parsed evidence, and the blocking finding of the prior review is resolved end to end. Proceed to the PR flow; carry issues #1007 and #1008 in the PR description as the plan directs. A one-time run of `discovery-capability-sentinel` followed by `run_discovery_doctor` on a real Claude Code host remains the recommended first post-merge check, as recorded in `handoff.md`; the recorded user decision does not make it a precondition.

---

## Appendix A: Test Inventory

### Complete Test List

The full inventory is the JUnit output retained by the executor (`evidence/qa-gates/p18-powershell-junit.2026-10-30T12-41.xml`, read by this review, and the Phase 18 Python and Jest records); this review inspected these tests directly:

- `tests/scripts/claude-lib/discovery-validation/DiscoverySentinelConsumption.Contract.Tests.ps1` (3 cases: record rebuild from envelopes, attribution beside the latch, no-latch rejection)
- `tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1` "observation evidence" matrix and the three cycle-2 cases (rewritten record, foreign latch, unparseable latch, later valid observation)
- `tests/scripts/{claude,codex,copilot}-hooks/discovery-capability.Tests.ps1` "proves attribution from the recorded sentinel observation pair" and "an unconsumed sentinel grant"
- `extensions/drm-copilot/test/discovery-sentinel.contract.test.ts` (3 cases)
- `tests/discovery_runtime/test_sentinel_consumption_fixture.py` (5 test functions, 8 cases with parametrization)

---

## Appendix B: Toolchain Commands Reference

Commands run by this review (check-only):

```bash
git merge-base HEAD origin/main                      # f7bef6ad = origin/main
git log --oneline 3e7acb3e9..HEAD                    # 16 cycle-2 commits
git diff 3e7acb3e9 HEAD -- . ':!docs/features'       # cycle-2 code diff, read in full
git diff --name-status f7bef6ad HEAD -- . ':!docs'   # branch inventory
sha256sum <three DiscoveryCapability.psm1 copies>
python -I scripts/dev_tools/validate_evidence_locations.py --root .
python -I <scratchpad>/perfile.py . <status.txt>     # per-file parse of the three canonical coverage artifacts
python -I <scratchpad>/cov.py <evidence/qa-gates>    # parse of the retained P18 coverage copies
python -I <scratchpad>/count.py . <covered.txt>      # logical line counts over 724 covered files
grep -o '<testsuite …' evidence/qa-gates/p18-powershell-junit.2026-10-30T12-41.xml
```

Repository commands the executor ran (records under `evidence/qa-gates/p18-*`):

**For Python:**
```bash
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json
poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --min-line 85 --min-branch 75
```

**For PowerShell:**
```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

**For TypeScript:**
```bash
npm ci
npm run format:check
npm run lint
npm run typecheck
node run-jest.cjs --coverage --runInBand --coverageReporters=lcov --coverageReporters=json-summary
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-10-30  
**Policy Version:** Current (as of audit date)
