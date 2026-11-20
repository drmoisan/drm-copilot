# Policy Compliance Audit: legacy discovery and parity (issue #980), review cycle 1

---

**Audit Date:** 2026-10-30  
**Code Under Test:** Full branch diff `52587a0eeaa04a0519801452235608a72b5eba5c..7d9191e9d7ff3084bc8ffc828d21fe402de1af22` (merge base with `origin/main` to `feature/legacy-discovery-and-parity-980` HEAD; `origin/main` has advanced to `318ef3e93`, and the branch has not been rebased since the prior review). Outside the feature folder: 1,102 paths (859 added, 239 modified, 4 deleted). By extension: 438 `.py`, 126 `.ts`, 104 `.ps1`, 51 `.psm1`, 102 `.json`, 152 `.md`, 54 `.toml`, 47 `.yaml`/`.yml`, 1 `.cjs`, 1 `.sh` (converter fixture data), and C#/VB project fixtures with no `.cs` source. Since the prior review head `c88235db0` (Phases 15 and 16, 37 commits): 3 new PowerShell modules (`DiscoveryObservation`, `DiscoveryRootGrant`, `DiscoveryToolRouting`), 3 new TypeScript modules (`discovery-authorization-binding`, `discovery-root-grant`, `discovery-sentinel`), 1 new Python module (`gateway_host_reads`), 2 new v2 schemas (`host-observation`, `root-grant`), the sentinel agent on three host surfaces, and the per-file threshold entries.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 438 files (185 production files in the coverage artifact) | 15734 collected | ✅ 15728 pass, 0 fail, 6 skipped (executor record `p16-python-tests.2026-10-30T00-42.md`) | 94.11% lines, 88.78% branches (P0-T2) | 96.69% lines (32061/33160), 93.59% branches (11613/12408) parsed by this review from `artifacts/python/lcov.info`; the executor's JSON report reads 93.62% branches (11659/12454) | Lowest changed production file 90.00% lines / 83.33% branches (`gateway_host_store.py`, 27/30); 0 of 185 changed files below 85% lines or 75% branches |
| TypeScript | 126 files (50 production, all under `extensions/drm-copilot/src/`) | 5177 extension + 5194 root | ✅ 10371 pass, 0 fail (executor records `p16-typescript-*-tests.2026-10-30T01-40.md`) | extension 97.41% lines, 92.65% branches; root 97.98% / 92.35% (P0-T3) | extension 97.04% lines (61352/63223), 93.64% branches (9333/9967) from `extensions/drm-copilot/coverage/lcov.info`; root 98.20% (67200/68434), 93.37% (9973/10681) from `coverage/lcov.info`, both parsed by this review | Lowest changed executable file 92.86% lines (`repo-automation-service-discovery-agent.ts`, 338/364); lowest branches 77.78% (`lib/codex-native-converter/pipeline-render.ts`, 35/45); 0 of 47 executable changed files below 85% lines or 75% branches; 3 type-only modules report 0 executable statements (see 1.2.1) |
| PowerShell | 155 files (38 production files in the coverage population) | 12744 | ✅ 12734 pass, 0 fail, 10 pre-existing skips (executor record `p16-powershell-tests.2026-10-30T01-29.md`) | 92.62% lines (P0, 17730/19142) | 93.34% lines (20188/21629), parsed by this review from the canonical `artifacts/pester/powershell-coverage.xml` (full single-process run) | Lowest changed production file 92.82% lines (`.codex/hooks/record-subagent-routing-attestation.ps1`, 194/209); 0 of 38 changed files below 85% lines; no branch metric under Pester |
| Bash | 1 file (test fixture `tests/fixtures/codex_native_converter/native_surfaces/.claude/lib/bash/parallel-common.sh`) | No bats tests | N/A (fixture data, not executed) | N/A (no coverage) | N/A (no coverage) | N/A |
| JSON | 102 files | N/A | ✅ schema and contract validation (executor record `p16-repository-contracts.2026-10-30T01-55.md`) | N/A (config files) | N/A (config files) | N/A |
| C# | 0 `.cs` files (project fixtures only) | N/A | N/A | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/typescript-extension-coverage-summary.2026-10-18T03-58.json`, `typescript-root-coverage-summary.2026-10-18T03-55.json`
- TypeScript post-change coverage artifact: `coverage/lcov.info` (2026-10-29T21:40Z) and `extensions/drm-copilot/coverage/lcov.info` (2026-10-29T21:38Z), both newer than the last TypeScript source change on the branch (commit `876448b2c`); retained copies `evidence/qa-gates/p16-typescript-{root,extension}-lcov.2026-10-30T01-40.info`
- Python baseline coverage artifact: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/python-coverage.2026-10-18T03-51.json`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (2026-10-29T20:42Z); retained copy `evidence/qa-gates/p16-python-coverage.2026-10-30T00-42.json`
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/powershell-coverage.2026-10-18T04-22.xml`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (2026-10-29T21:30Z, full single-process run, 20188/21629 lines); retained copy `evidence/qa-gates/p16-powershell-coverage.2026-10-30T01-29.xml`
- Per-language comparison summary: section 1.2.1.

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

Missing artifact paths for this audit: none. Every coverage artifact required by the Coverage Verification procedure exists for head `7d9191e9d` and was parsed.

---

## Executive Summary

This audit re-examines the full feature-versus-base diff after remediation cycle 1 (plan Phases 15 and 16). The four blocking findings of the 2026-10-29T13-16 review are resolved in code: identity is derived from the hook payload alone (`DiscoveryPayload.psm1`, no `DRM_DISCOVERY_*` read site remains in any production tree), every unbound controlled call fails closed in the MCP gate, the TypeScript coverage artifacts exist at the canonical paths with per-file thresholds for the ten previously unthresholded files, and the evidence-location validator exits 0. The Major (Python one-use latch and expiry) and every Minor are resolved; each is verified in section 8.

One new blocking finding is introduced by the remediation. The capability probe now derives `trusted_attribution` from the sentinel tool observation, but it requires the observation record's `state` member to read `consumed` (`DiscoveryCapability.psm1:162`), while the TypeScript consumer of that grant records consumption only as a sibling `.consumed` latch and never rewrites the record (`discovery-sentinel.ts:272-278`). The Pester fixture seeds `state = 'consumed'` directly into the store, so the suites cannot observe the mismatch, and no host was driven in this cycle (`evidence/qa-gates/discovery-host-observations.2026-10-30T01-47.md`). On every real host the probe therefore reports `unsupported`, and because a root grant for `prepare_discovery_agent` requires a current `supported` attestation (`DiscoveryRootGrant.psm1:96-133`), no specialist can be prepared. The control fails closed, so no unsafe write results, but the feature is inoperable as shipped.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (via `.claude/rules/python.md`, `python-suppressions.md`)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- ✅ TypeScript: `.claude/rules/typescript.md`, `typescript-suppressions.md`, `architecture-boundaries.md`
- N/A Bash: shfmt + shellcheck + bats (the only `.sh` file is converter fixture data)
- ✅ JSON: schema and contract validation per executor record `evidence/qa-gates/p16-repository-contracts.2026-10-30T01-55.md`

Toolchain results are taken from the executor's Phase 16 records and cross-checked against the coverage artifacts this review parsed. The review ran check-only commands; it did not re-run the full suites.

**Temporary artifacts cleanup:**
- ✅ `validate_evidence_locations.py --root .` exits 0; the two P7-T3 residue files reported by the prior review are gone, and `git diff --name-only <merge base> HEAD -- artifacts/` lists 0 tracked paths.
- ✅ The review scripts used for this audit live only in the session scratchpad.
- ✅ The executor's SCRATCH harness scripts are not committed.

---

## Rejected Scope Narrowing

No scope narrowing was detected. The coordinator's prompt relays three user decisions as final (identity from the hook payload, root grants for read-only controlled calls without `invocation_ref`, `unsupported` for hosts that cannot supply identity). These settle design questions the prior review raised as `human_decision_required`; they do not narrow the file, language or coverage scope, and this audit evaluates the implementation of those decisions over the full branch diff.

---

## Evidence Location Compliance

Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0, no finding printed).

| Path | Status | Canonical replacement |
|---|---|---|
| (none) | PASS | n/a |

A scan of the branch diff (`git diff --name-only 52587a0ee HEAD -- artifacts/`) found no tracked file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. The Phase 15 and 16 evidence is under `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/{qa-gates,regression-testing,other,remediation-baseline}/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `evidence/regression-testing/p16-isolation.2026-10-30T01-45.md`: seeded Jest (seed 1616, extension and root), reversed Python order over the 12 Phase 15 modules, Pester seeds 161, 262, 363, all green. The content-keyed registry cache is module state, and `test_catalog.py` ran last in the reversed order without effect. |
| **Isolation** - Each test targets single behavior | ✅ PASS | New suites mirror modules one-to-one (`tests/discovery_runtime/test_gateway_host_reads.py`, `test_gateway_host_read_refusals.py`, `tests/scripts/claude-lib/discovery-validation/Discovery{Observation,RootGrant,ToolRouting}.Tests.ps1`, `extensions/drm-copilot/test/discovery-{root-grant,sentinel}.test.ts`). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Full Python run 661.48 s (P14: 929.37 s); `tests/discovery_runtime` 156.30 s after the content-keyed cache (`evidence/other/p15-registry-cache-timing.2026-10-30T00-11.md`). |
| **Determinism** - Consistent results | ✅ PASS | Clocks, nonces and stores are injected on every surface (`Get-DiscoveryPreToolDecision -Now -Nonce -Store`, `ConsumeRootGrantOptions.now`, `HostServiceIO(clock=...)`). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names, for example `test_a_second_dispatch_of_the_same_grant_is_refused`, `test_a_resolved_target_outside_the_selection_is_refused`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** Python 94.11% lines / 88.78% branches; TypeScript extension 97.41% / 92.65%; TypeScript root 97.98% / 92.35%; PowerShell 92.62% lines.<br>**Command:** recorded in `evidence/baseline/python-tests.2026-10-18T03-51.md`, `typescript-extension-tests.2026-10-18T03-58.md`, `typescript-root-tests.2026-10-18T03-55.md`, `powershell-tests.2026-10-18T04-21.md`<br>**Timestamp:** 2026-10-18 03:51 to 04:22 |
| **No Coverage Regression** | ✅ PASS | Python 94.11% to 96.69% lines (+2.58), 88.78% to 93.59% branches (+4.81). TypeScript extension 97.41% to 97.04% lines (-0.37, above the floor), 92.65% to 93.64% branches (+0.99); root 97.98% to 98.20% (+0.22), 92.35% to 93.37% (+1.02). PowerShell 92.62% to 93.34% (+0.72). Changed-line regression: the executor's per-file comparison (`evidence/qa-gates/p16-coverage-comparison.2026-10-30T01-41.md`) reports 0 uncovered changed executable lines over 274 files; this review confirmed the per-file totals it cites against the canonical artifacts for every changed production file. |
| **New Code Coverage ≥90%** | ✅ PASS | Python: lowest changed production file 90.00% lines (`gateway_host_store.py`). TypeScript: lowest changed executable file 92.86% lines (`repo-automation-service-discovery-agent.ts`). PowerShell: lowest changed production file 92.82%. All parsed by this review. |
| **Comprehensive Coverage** | ✅ PASS | `changed files measured: 185; not in artifact: 0` (Python), `50; 0` (TypeScript extension artifact), `38; 0` (PowerShell). |
| **Positive Flows** - Valid inputs | ✅ PASS | For example `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` "allows a root prepare with a one-use root grant bound to this session"; `tests/discovery_runtime/test_gateway_host.py` admits a fully bound host request. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `test_gateway_host_refusals.py` (expired grant, replayed grant, unknown reference, foreign workspace), `test_gateway_host_read_refusals.py`, `extensions/drm-copilot/test/mcp-discovery-authority-tools.gate.test.ts`, the seven `unsupported` probe cases in `DiscoveryCapability.Tests.ps1`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Expiry at the clock instant (`decode_authorization`, `expires <= now`), ambiguous root grants (`AUTHORIZATION_AMBIGUOUS`), a Codex-shaped observation without `agent_id`. |
| **Error Handling** - Error paths | ✅ PASS | Store write failures deny with `STORE` on every PowerShell path; `AUTHORITY_LOCKED` maps to `AUTHORIZATION_CONSUMED` in both TypeScript consumers. |
| **Concurrency** - If applicable | ✅ PASS | Latch races are tested in `discovery-root-grant.test.ts` and `discovery-sentinel.test.ts`; the Python `.used` latch replay is tested in `test_a_second_dispatch_of_the_same_grant_is_refused`. |
| **State Transitions** - If applicable | ⚠️ PARTIAL | Tool-authorization `issued` to `consumed` is tested end to end (the consumer rewrites the record). The sentinel observation's `issued` to `consumed` transition is tested on each side against a fixture that already carries the other side's expected state, so the cross-language transition is untested; see section 8. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 94.11% lines -> Post-change: 96.69% lines. Change: +2.58% lines, +4.81% branches (88.78% to 93.59%). New/changed-code coverage: lowest changed production file 90.00% lines / 83.33% branches; 0 of 185 changed files below 85% lines or 75% branches. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (2026-10-29T20:42Z), `evidence/qa-gates/p16-python-tests.2026-10-30T00-42.md`.
- TypeScript: Baseline: 97.41% lines -> Post-change: 97.04% lines (extension); root 97.98% -> 98.20%. Change: -0.37% lines / +0.99% branches (extension), +0.22% / +1.02% (root). New/changed-code coverage: lowest changed executable file 92.86% lines, lowest branches 77.78%; 0 of 47 executable changed files below 85% lines or 75% branches. Three changed modules (`discovery-service-types.ts`, `repo-automation-service-contract.ts`, `repo-automation-service-discovery-types.ts`) contain only `interface`, `type` and `import type` declarations (a search for exported functions, constants or classes returns none); they report 0 executable statements covered in the extension artifact and are absent from the root artifact, which the type-only clarification in `.claude/rules/general-unit-test.md` permits. The ten files the prior review listed as unthresholded now carry entries in `extensions/drm-copilot/jest.config.cjs` (85/75), and `jest.discovery-coverage.json` carries the discovery host modules (90/75); `collectCoverageFrom` is `["src/**/*.ts", "!src/**/*.d.ts"]` with no production exclude. Disposition: PASS. Evidence: `coverage/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, `evidence/qa-gates/p16-typescript-{root,extension}-tests.2026-10-30T01-40.md`.
- PowerShell: Baseline: 92.62% lines -> Post-change: 93.34% lines. Change: +0.72% lines (no branch metric under Pester). New/changed-code coverage: lowest changed production file 92.82% lines; 0 of 38 changed files below 85%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (full run, 20188/21629), `evidence/qa-gates/p16-powershell-tests.2026-10-30T01-29.md`.
- C#: N/A - out of scope (zero `.cs` files changed).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `test_gateway_host_main.py:286` now asserts the refusing finding message per row; `test_schema_validation.py:401,425-426` deep-copies `before` and asserts one registry object. Refusal tests assert distinct messages (`"expired before dispatch"`, `"already dispatched by the runtime"`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Separated phases in the inspected tests. |
| **Document Intent** | ✅ PASS | Docstrings and `It` names state the scenario and the expected decision. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | A search of the discovery test trees (Python, TypeScript, Pester) for `tmp_path`, `tempfile`, `mkdtemp`, `os.tmpdir`, `New-TemporaryFile`, `TestDrive`, `$env:TEMP` and `GetTempPath` returns no match. `evidence/qa-gates/p16-test-io.2026-10-30T01-55.md` classifies the nine token hits as non-I/O. |
| **Use Mocks/Stubs** | ✅ PASS | In-memory store hashtables (`Get-GateStore`), `MemoryService`, in-memory `AuthorizationStoreIO`, injected clocks. |
| **Environment Stability** | ✅ PASS | No production module reads `DRM_DISCOVERY_*`; the authority provider reads only `LOCALAPPDATA` and `XDG_STATE_HOME` for the state root. Tests inject `env`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the independent re-review for head `7d9191e9d`. Outstanding items are listed in section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` (#980), `spec.md`, `user-story.md`, `requirements-traceability.md`, `remediation-inputs.2026-10-29T13-16.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-10-17T22-38.md` Phases 0 to 16; `research/2026-10-29T13-16-host-identity-sources-research.md`. |
| **Document the plan** | ✅ PASS | 156 of 156 plan tasks checked; Phases 15 and 16 recorded with per-task evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Routing tables moved to one module (`DiscoveryToolRouting.psm1`) shared by the gate and the planning gate; the TypeScript gate derives the operation with the same rules (`mcp-discovery-authorization-gate.ts:80-120`). |
| **Reusability** | ✅ PASS | One `Get-DiscoveryPreToolDecision` serves all three hosts; 147 of 147 branch-changed customization files are byte-identical to their bundled mirrors (exact-path comparison by this review). |
| **Extensibility** | ✅ PASS | Per-host envelope key tables (`DiscoveryPayload.psm1:41-45`) and the root-grant schema admit new hosts and tools without changing the decision code. |
| **Separation of concerns** | ⚠️ PARTIAL | Pure decision modules are separate from the store seams. The one shared record contract between the TypeScript sentinel consumer and the PowerShell probe is not defined in one place and the two sides disagree on it (section 8). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | `DiscoveryRootGrant.psm1` 165 lines, `DiscoveryObservation.psm1` 218 lines, `gateway_host_reads.py` 91 lines, each with one concern. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts over all 721 added or modified covered files: maximum 531 (`extensions/drm-copilot/jest.config.cjs`), then 500 (`mutation_plan.py`, `analyzer/dependency_inputs.py`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`). No file at or above 700. `config/file-size-baseline.json` changed only by removing the `agentic_sync.py: 819` entry; `files` is empty. |
| **Public vs internal** | ✅ PASS | Underscore-prefixed helpers (`_registry`, `_build_registry`, `_verify`); `Export-ModuleMember` lists on every module. |
| **No circular dependencies** | ✅ PASS | `evidence/qa-gates/p16-architecture-boundaries.2026-10-30T01-55.md`, `p16-typescript-*-architecture.2026-10-30T01-40.md`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-DiscoveryTrustedPrincipal`, `consumeRootGrant`, `select_reads`, `Test-DiscoveryRootGrantPrecondition`. |
| **Docs/docstrings** | ✅ PASS | Contract docstrings and comment-based help on every inspected function. |
| **Comment why, not what** | ✅ PASS | For example `catalog.py:259` ("Build and verify only on a cache miss; a hit is already fully verified."), `gateway_host.py:277-278`. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black .`; `npm run format:check` (root and extension); `Invoke-PoshQCFormat`<br>**Result:** no change (`p16-python-format.2026-10-30T00-42.md`, `p16-typescript-*-format.2026-10-30T01-40.md`, `p16-powershell-format.2026-10-30T01-29.md`) |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check .`; `npm run lint`; `Invoke-PoshQCAnalyze`<br>**Result:** no findings (`p16-python-lint`, `p16-typescript-*-lint`, `p16-powershell-analyze`) |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright`; `npm run typecheck`<br>**Result:** 0 errors (`p16-python-types`, `p16-typescript-*-types`); N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch`; `node run-jest.cjs --coverage`; `Invoke-PoshQCTest -Root .`<br>**Result:** all suites green; coverage artifacts retained at the canonical paths and under `evidence/qa-gates/` |
| **Full toolchain loop** | ✅ PASS | Phase 16 records one clean cycle per language after the P16-T4 test repair. |
| **Explicit reporting** | ✅ PASS | Commands and results in `evidence/qa-gates/p16-*.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | `completion-report.md` paragraph 10 lists every remediation item; commit messages name the plan task. |
| **Design choices explained** | ✅ PASS | `docs/engineering/legacy-discovery-and-parity/enforcement.md` `## Identity source` (per-host identity table) and `## Capability probe` document the decided design. |
| **Update supporting documents** | ✅ PASS | `spec.md:6-7` and `user-story.md:5-6` now carry the Phase 16 status with `Last Updated 2026-10-30T01-58`; the six execution-environment brief copies hash identically (`372462e3…`). |
| **Provide next steps** | ✅ PASS | `handoff.md` qualifies the P12-T12 runs as harness-simulated (lines 34, 50) and `discovery-host-observations.2026-10-30T01-47.md` gives the orchestrator launch procedure. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black .`<br>**Result:** unchanged (`p16-python-format.2026-10-30T00-42.md`) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** clean (`p16-python-lint.2026-10-30T00-42.md`) |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors (`p16-python-types.2026-10-30T00-42.md`) |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch`<br>**Result:** 15728 passed, 6 skipped, 661.48 s; 96.69% / 93.59% confirmed from `artifacts/python/lcov.info` |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Full annotations; `cast` only on schema-validated JSON members (`gateway_host.py:342-343, 384-398`). |
| **Dataclasses for value objects** | ✅ PASS | `HostPrincipal`, `WorkspaceBinding`, `TrustedIdentity` frozen keyword-only. |
| **Protocols/ABCs for interfaces** | ✅ PASS | `HostStoreIO` Protocol gained `exists` and `create_exclusive`. |
| **Avoid utility classes** | ✅ PASS | `gateway_host_reads.py` exposes module functions. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `FileExistsError` from the `.used` latch is mapped to the exit-3 refusal (`gateway_host.py:296-301`); other `OSError` values propagate. |
| **Logging over print** | ✅ PASS | No `print` in production modules. |
| **Invariants at construction** | ✅ PASS | `SchemaCatalog.__post_init__` still verifies identities and closure; the library check runs before any cache hit (`catalog.py:256-258`). |

---

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .`<br>**Result:** no change (`p16-powershell-format.2026-10-30T01-29.md`) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** no findings (`p16-powershell-analyze.2026-10-30T01-29.md`) |
| **Fix all findings** | ✅ PASS | No open analyzer findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Modules declare PowerShell 7+, the repository requirement. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]`, `[OutputType()]`, `SupportsShouldProcess` on `Write-DiscoveryRootGrant` and `Write-DiscoveryHostObservation`. |
| **Parameter validation** | ✅ PASS | `ValidateSet` on hosts and decisions; mandatory parameters declared. |
| **Avoid global state** | ✅ PASS | Store, clock, nonce and environment injected; module tables are read through accessors. |
| **Error handling** | ✅ PASS | Seam failures deny with `STORE`; anomalies deny with `ENVELOPE`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest PowerShell production file 480 logical lines (`DiscoveryAuthorization.psm1`); none at or above 700. |
| **Approved verbs** | ✅ PASS | Analyzer clean. |
| **Comment why** | ✅ PASS | For example `DiscoveryAuthorization.psm1:358` ("Sentinel envelopes are observed before any grant path; root calls take the grant path."). |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | No change. |
| **Step 2: Analyze** | ✅ PASS | No findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 12744 tests, 0 failed, 10 pre-existing skips; single-process coverage 93.34%. |
| **Rerun loop if needed** | ✅ PASS | One clean pass recorded. |

---

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | **Command:** `npm run format:check`<br>**Result:** clean (`p16-typescript-{root,extension}-format.2026-10-30T01-40.md`) |
| **Linting with ESLint** | ✅ PASS | **Command:** `npm run lint`<br>**Result:** clean |
| **Type checking with TSC** | ✅ PASS | **Command:** `npm run typecheck`<br>**Result:** clean |
| **Testing with Jest** | ✅ PASS | **Command:** `node run-jest.cjs --coverage`<br>**Result:** extension 5177 / root 5194 passed; every per-file threshold met |
| **Coverage artifact** | ✅ PASS | `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` present and current. |
| **Coverage configuration** | ✅ PASS | No production path excluded; per-file entries for all ten previously unthresholded files; the map carries no `global` key. |
| **Suppressions** | ✅ PASS | No `@ts-ignore`, `@ts-nocheck` or file-level `eslint-disable` in the inspected Phase 15 modules. |

---

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | **Command:** `poetry run python -m scripts.dev_tools.format_json`<br>**Result:** no drift (`p16-repository-contracts.2026-10-30T01-55.md`) |
| **Schema validation** | ✅ PASS | **Command:** `poetry run python -m scripts.dev_tools.validate_json`<br>**Result:** valid; `tests/schemas/discovery/test_v2_grant_schemas.py` covers the two new schemas |
| **Required $schema** | ✅ PASS | `host-observation.schema.json` and `root-grant.schema.json` carry `$schema` and `$id`; `SchemaCatalog` enforces both. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Strict loader. |
| **Deterministic key order** | ✅ PASS | Canonical JSON digests shared by `Get-DiscoveryInputDigest` and `computeInputDigest`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | All Python tests use Pytest. |
| **Coverage expectation** | ✅ PASS | 96.69% lines and 93.59% branches repo-wide; lowest changed file 90.00%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One refusal per test in `test_gateway_host_read_refusals.py`. |
| **Mocking sparingly** | ✅ PASS | `monkeypatch` on single seams. |
| **Organization** | ✅ PASS | `tests/discovery_runtime/` mirrors the package. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_an_expired_grant_is_refused_before_any_read`. |
| **Docstrings/comments** | ✅ PASS | Present. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch`<br>**Result:** 15728 passed, 6 skipped |
| **No Alternative Test Runners** | ✅ PASS | Only Pytest. |

---

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `Describe`/`Context`/`It` with `-ForEach` matrices. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7+ per repository rule. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One control per `It` in the observation-evidence matrix. |
| **Test Behavior Over Implementation** | ⚠️ PARTIAL | The probe suites feed records built by the test fixture (`Add-GateSentinelObservation`, "Records are placed directly in Files") rather than records produced by the gate's writer and the TypeScript consumer, so they assert the probe's reading of a shape the producer never writes (section 8). |
| **Mocking Used Sparingly** | ✅ PASS | In-memory store hashtables. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/discovery-validation/DiscoveryRootGrant.Tests.ps1`<br>**Code file:** `.claude/lib/discovery-validation/DiscoveryRootGrant.psm1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Used throughout. |
| **Logical Grouping** | ✅ PASS | Grouped by lifecycle event and decision family. |
| **Docstrings/Comments** | ✅ PASS | `It` names state the expected decision. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** 12744 tests, 0 failed |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### `DiscoveryCapability.psm1` (probe from host observations)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `DiscoveryCapability.Tests.ps1` "observation evidence" matrix (7 cases) | Negative | 154-172 | ✅ |
| Per-host probe suites "proves attribution from the recorded sentinel observation pair" | Positive | 264-378 | ✅ (against a fixture-seeded `state = 'consumed'`) |

**Coverage:** 174/175 lines (99.43%).

**Not covered:** The record shape the TypeScript consumer leaves behind (`state: "issued"` plus a `.consumed` latch). No test feeds that shape to `Get-DiscoveryObservationEvidence`.

---

### `gateway_host.py` / `protected_records.py` (dispatch latch and expiry)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_a_second_dispatch_of_the_same_grant_is_refused` | Negative | `gateway_host.py:276-302` | ✅ |
| `test_an_expired_grant_is_refused_before_any_read` | Negative | `protected_records.py:314-317` | ✅ |

**Coverage:** 128/133 and 107/111 lines.

**Not covered:** `gateway_host.py:298-299` (the `FileExistsError` branch when two processes race the latch; the replay test reaches the `used_latch_present` refusal first).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 15734 Python + 5194 TS root + 5177 TS extension + 12744 Pester | ✅ |
| Tests Passed | 15728 + 5194 + 5177 + 12734 (100% of non-skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 661.48 s Python; Pester single process 2026-10-30T00:51 to 01:06 UTC; Jest runs 01:35 to 01:40 UTC | ✅ |
| Average Time per Test | about 42 ms Python | ✅ Fast |
| Discovery Time | not recorded separately | ✅ |
| Functions/Classes Tested | 185/185 changed Python, 50/50 changed TypeScript, 38/38 changed PowerShell production files present in coverage | ✅ |
| Test File Size | maximum 500 logical lines (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`) | ✅ PASS |
| Code Coverage (if applicable) | Python 96.69% / 93.59%; TypeScript extension 97.04% / 93.64%, root 98.20% / 93.37%; PowerShell 93.34% | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black .` | unchanged | ✅ |
| Ruff Linting | `poetry run ruff check` | clean | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest` | 15728 passed, 6 skipped | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | no change | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | no findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 12744 / 0 failed | ✅ |

**Notes:**
The review re-ran no suite. It parsed the four canonical coverage artifacts, ran `validate_evidence_locations.py`, measured logical line counts over 721 covered files, compared 147 branch-changed customization files with their bundled mirrors by exact path (0 differences), hashed the six execution-environment brief copies, searched every production tree for `DRM_DISCOVERY_` (0 matches), and read the Phase 15 modules on all three language surfaces.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Sentinel consumption contract mismatch (FAIL, autonomous):** `Get-DiscoveryObservationEvidence` accepts a sentinel tool observation only when `[string]$candidate['state'] -ceq 'consumed'` (`.claude/lib/discovery-validation/DiscoveryCapability.psm1:162`) and `Get-DiscoverySessionObservation` reads only `*.json` entries (lines 120-125). `consumeSentinelGrant` records consumption by creating `<observation>.json.consumed` and returns without rewriting the record (`extensions/drm-copilot/src/discovery-sentinel.ts:272-294`); the record keeps `state: "issued"` as the gate wrote it (`DiscoveryObservation.psm1:138`). The tool-authorization consumer, by contrast, latches and then rewrites the record as `consumed` (`discovery-authorization.ts:290-329`). Consequence on every host: after the sentinel agent runs, the probe reports `unsupported` with "sentinel observation … was not consumed by the sentinel tool (state issued)", `doctor` reports the deficiency, and `Test-DiscoveryRootGrantPrecondition` refuses the root grant for `prepare_discovery_agent` and every controlled root call. The fixture `Add-GateSentinelObservation` (`tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1:208`) writes `state = 'consumed'` directly, and `discovery-sentinel.test.ts:92` seeds `state: "consumed"` only to prove a replay refusal, so neither side's tests exercise the other side's output. No host was driven in this cycle (`evidence/qa-gates/discovery-host-observations.2026-10-30T01-47.md`). Remediation: make one side match the other (either rewrite the observation record as `consumed` through the staged publish the tool-authorization consumer uses, or let the probe treat the `.consumed` latch as consumption), keep the two bundled mirrors identical, and add a cross-language contract test that feeds the probe the exact record and latch the TypeScript consumer leaves behind.
- **Root-grant partition growth and strict decode (non-blocking):** `consumeRootGrant` decodes every `.json` under `root-grants/` strictly on each root call and never removes consumed or expired grants (`discovery-root-grant.ts:228-245`); a single malformed or partially written file refuses every root call for the workspace with `AUTHORIZATION_RECORD_INVALID`, and the per-call cost grows with the session history. Recorded in the code review as Minor.
- **Shell observation not bounded (non-blocking):** the `SHELL` deny observation is matched by `agent_id` only (`DiscoveryCapability.psm1:170`), without the handler-hash and TTL checks the sentinel tool observation receives. Recorded as Nit.

### Prior findings verified resolved

- Identity supplier (prior Blocker): `Get-DiscoveryTrustedPrincipal` derives host, session, agent and role from the normalized envelope; `Get-DiscoveryPreToolDecision` routes root envelopes to one-use root grants and denies a declared discovery agent type without a usable identifier (`IDENTITY`); `admitControlledToolCall` requires a tool authorization for `invocation_ref` calls and a root grant otherwise, with no `local-user` fallback; `prepareDiscoveryAgentOperation` refuses without raw tool input or a grant; `finalizeDiscoveryAgentOperation` refuses without the consumed record. Repository search for `DRM_DISCOVERY_` over `.claude`, `.codex`, `.github`, `.agents`, `extensions/drm-copilot/src`, `packages`, `scripts` and `docs/engineering` returns no match.
- Probe self-attestation (prior Blocker): `Get-DiscoverySentinelEnvironment` is deleted; attribution is read from recorded observations. The replacement carries the new mismatch above.
- TypeScript coverage artifact (prior Blocker): present and parsed; ten per-file entries added.
- Evidence locations (prior Blocker): validator exits 0.
- Python grant replay and expiry (prior Major): `.used` latch created exclusively on acceptance (`gateway_host.py:294-302`), `expires_at` compared with the injected clock (`protected_records.py:314-317`), both tested.
- Isolation assertion, exit-code-only refusal rows, canonical Pester XML, symlink re-check, status lines, brief wording (prior Minors and Nit): all resolved and verified in sections 1.3, 2.6 and the coverage table.

### Approved Exceptions

**None.** No exceptions needed. The three type-only TypeScript modules reporting 0 executable statements fall under the type-only clarification in `.claude/rules/general-unit-test.md`, which is not an exception.

### Removed/Skipped Tests

**None.** No assertion was weakened; the P15-T19 change strengthened `test_schema_validation.py`, and the P16-T4 repair added two tests to `extensions/drm-copilot/test/mcp-tools.discovery.test.ts`. The 6 Python and 10 Pester skips are pre-existing and unchanged.

---

## 9. Summary of Changes

### Commits in This PR/Branch

218 commits from `52587a0ee` to `7d9191e9d`. The 37 remediation-cycle commits examined in detail include:

1. **ec7694e05** - feat(discovery): derive the trusted principal from the hook payload alone (P15-T3)
2. **7f92493d6** - feat(discovery): decide root grants, specialist binding and first-call start in the gate (P15-T6)
3. **591c88c19** - feat(discovery): observational start hooks and payload-attributed stops (P15-T7)
4. **3b16cb73f** - feat(discovery): add the capability sentinel agent on every host surface (P15-T9)
5. **8769cb584** - feat(discovery): prove capability attribution from host observations (P15-T10)
6. **cc78ac101** - feat(discovery): take TypeScript identity from host records only (P15-T12 to P15-T15)
7. **b43043100** - feat(discovery): latch each host dispatch once and refuse expired grants (P15-T16)
8. **76356ed38** - feat(discovery): re-check resolved read targets against the invocation scope (P15-T17)
9. **11293cf10** - perf(discovery): share one verified registry across catalogs built from identical bytes (P15-T18)
10. **dbc8cfa94** - test(discovery): gate the ten unthresholded TypeScript files (P15-T20)

### Files Modified

1. **.claude/lib/discovery-validation/** (3 NEW, 8 MODIFIED) and bundled mirrors
   - Payload-derived principal, root grants, observations, tool routing, observational start, payload-attributed stop.
2. **extensions/drm-copilot/src/** (3 NEW, 15 MODIFIED)
   - Root-grant and sentinel consumers, binding consumer, gate routing by `invocation_ref`, identity-free authority provider.
3. **packages/discovery-runtime/src/drm_copilot_discovery/** (1 NEW, 6 MODIFIED)
   - `.used` dispatch latch, expiry check, resolved-target re-check, content-keyed registry cache, two new schemas.
4. **schemas/discovery/v2/**, **examples/discovery/v2/** (2 NEW each)
5. **extensions/drm-copilot/jest.config.cjs**, **jest.discovery-coverage.json** (MODIFIED)
6. **docs/engineering/legacy-discovery-and-parity/** (4 MODIFIED), **.claude/skills/execution-environment/SKILL.md** and five copies

---

## 10. Compliance Verdict

### Overall Status: ❌ NON-COMPLIANT

Python, TypeScript, PowerShell, file-size, mirror-parity, evidence-location, test-isolation and toolchain policies are met on independently parsed evidence, and every finding of the prior review is resolved in code. The branch is non-compliant on one item introduced by the remediation: the sentinel observation's consumption contract differs between the TypeScript consumer and the PowerShell probe, so the capability probe cannot report `supported` on any host and no specialist can be prepared.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan, research and remediation inputs present.
- ⚠️ Design Principles: one cross-language record contract defined in two places and inconsistent.
- ✅ Module & File Structure: maximum 531 logical lines; baseline empty.
- ✅ Naming, Docs, Comments: complete.
- ✅ Toolchain Execution: one clean cycle per language with retained coverage.
- ✅ Summarize & Document: status lines, design documentation and handoff current.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright, Pytest clean.
- ✅ Python Design & Typing: frozen dataclasses, Protocol seam.
- ✅ Error Handling: exit-3 refusals; latch race mapped.

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyzer clean.
- ✅ PowerShell Design & Safety: injected seams, `ShouldProcess` on writers.
- ✅ Structure & Naming: approved verbs, at most 480 lines.
- ✅ Toolchain: 12744 tests green.

**For TypeScript:**
- ✅ Tooling: Prettier, ESLint, TSC, Jest clean.
- ✅ Coverage artifact present; per-file thresholds complete; no production exclude.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: isolation runs green.
- ✅ Coverage & Scenarios: every language parsed and above floor.
- ✅ Test Structure: the two weak assertions are strengthened.
- ✅ External Dependencies: no temp files or real processes.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest, 96.69% / 93.59%.
- ✅ Test Style & Structure: focused tests.
- ✅ Naming & Readability: descriptive.
- ✅ Toolchain: green.

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC.
- ⚠️ Test Style & Structure: probe suites assert against a fixture-authored record shape the producer does not write.
- ✅ Naming & Readability: `*.Tests.ps1`.
- ✅ Toolchain: green.

---

### Metrics Summary

- ✅ 38,833 of 38,833 non-skipped tests passing across Python, TypeScript and Pester (executor records)
- ✅ 185 of 185 changed Python, 50 of 50 changed TypeScript and 38 of 38 changed PowerShell production files measured
- ✅ Python 96.69% lines / 93.59% branches; TypeScript extension 97.04% / 93.64%, root 98.20% / 93.37%; PowerShell 93.34% lines
- ✅ Proper file organization: tests mirror source trees
- ✅ All format, lint and type checks passing
- ✅ Test execution time: Python 661.48 s
- ❌ One Blocker: sentinel consumption contract mismatch between `discovery-sentinel.ts` and `DiscoveryCapability.psm1`

---

### Recommendation

**Needs revision**

Align the sentinel observation consumption contract between the TypeScript consumer and the PowerShell probe, add a cross-language contract test over the real producer output, re-run the PowerShell and TypeScript loops, and, where an orchestrator session is available, drive the sentinel once on Claude Code and record the probe status per `discovery-host-observations.2026-10-30T01-47.md`. Re-run this review afterwards.

---

## Appendix A: Test Inventory

### Complete Test List

The full inventory is the JUnit output retained by the executor (`evidence/qa-gates/p16-powershell-junit.2026-10-30T01-29.xml` and the Phase 16 Python and Jest records); this review inspected these tests directly:

- `tests/discovery_runtime/test_gateway_host_refusals.py::test_a_second_dispatch_of_the_same_grant_is_refused`
- `tests/discovery_runtime/test_gateway_host_refusals.py::test_an_expired_grant_is_refused_before_any_read`
- `tests/discovery_runtime/test_gateway_host_read_refusals.py::test_a_symlinked_read_inside_the_selection_is_refused`
- `tests/discovery_runtime/test_gateway_host_main.py::test_main_refuses_incomplete_or_misplaced_host_identity`
- `tests/discovery_runtime/test_schema_validation.py::test_repeated_validations_through_one_catalog_are_independent`
- `tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1` "observation evidence" matrix
- `extensions/drm-copilot/test/discovery-sentinel.test.ts` consumption and replay cases

---

## Appendix B: Toolchain Commands Reference

Commands run by this review (check-only):

```bash
git diff --name-status 52587a0eeaa04a0519801452235608a72b5eba5c HEAD -- . ':!docs/features'
git diff 52587a0eeaa04a0519801452235608a72b5eba5c HEAD -- extensions/drm-copilot/jest.config.cjs jest.config.cjs config/file-size-baseline.json config/poshqc-coverage.json pyproject.toml
git diff --name-only 52587a0eeaa04a0519801452235608a72b5eba5c HEAD -- artifacts/
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
python -I <scratchpad>/cov.py lcov artifacts/python/lcov.info . 52587a0ee .py
python -I <scratchpad>/cov.py lcov extensions/drm-copilot/coverage/lcov.info . 52587a0ee .ts extensions/drm-copilot/
python -I <scratchpad>/cov.py lcov coverage/lcov.info . 52587a0ee .ts
python -I <scratchpad>/cov.py jacoco artifacts/pester/powershell-coverage.xml . 52587a0ee .ps1,.psm1
python -I <scratchpad>/count.py . 52587a0ee      # logical line counts
python -I <scratchpad>/mirror.py . 52587a0ee     # exact-path bundled mirror parity
sha256sum <six execution-environment SKILL.md copies>
```

Repository commands the executor ran (records under `evidence/qa-gates/p16-*`):

**For Python:**
```bash
poetry run black .
poetry run ruff check
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**For PowerShell:**
```powershell
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

**For TypeScript:**
```bash
npm run format:check
npm run lint
npm run typecheck
node run-jest.cjs --coverage --runInBand --coverageReporters=lcov --coverageReporters=json-summary
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-10-30  
**Policy Version:** Current (as of audit date)
