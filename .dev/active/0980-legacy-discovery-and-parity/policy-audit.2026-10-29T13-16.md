# Policy Compliance Audit: legacy discovery and parity (issue #980)

---

**Audit Date:** 2026-10-29  
**Code Under Test:** Full branch diff `52587a0eeaa04a0519801452235608a72b5eba5c..c88235db0dacf1c0da1e540bec6bf7de559a7120` (`origin/main` merge base to `feature/legacy-discovery-and-parity-980` HEAD). Outside the feature folder: 1,064 paths (821 added, 239 modified, 4 deleted). By extension: 434 `.py`, 117 `.ts`, 105 `.ps1`, 42 `.psm1`, 98 `.json`, 149 `.md`, 52 `.toml`, 44 `.yaml`/`.yml`, 1 `.sh` (test fixture), and C#/VB project fixtures with no `.cs` source. Principal production areas: `packages/discovery-runtime/src/drm_copilot_discovery/` (182 added files), `extensions/drm-copilot/src/` (27 added, 20 modified), `.claude/`, `.codex/`, `.github/`, `.agents/` discovery hooks, libraries, agents and skills with their bundled mirrors under `extensions/drm-copilot/resources/`, `schemas/discovery/v2/`, `scripts/dev_tools/`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 434 files (184 production files in the coverage artifact) | 15674 collected | ✅ 15668 pass, 0 fail, 6 skipped | 94.11% lines, 88.78% branches (P0-T2) | 96.70% lines, 93.62% branches (`artifacts/python/lcov.info`, parsed by this review) | Lowest changed production file 90.24% lines (`scripts/dev_tools/codex_native_converter/rewrites.py`); 0 changed files below 85% lines or 75% branches |
| TypeScript | 117 files (47 production) | 5109 extension + 5126 root | ✅ 10235 pass, 0 fail (executor records) | extension 97.41% lines, 92.65% branches; root 97.98% / 92.35% (P0-T3) | extension 97.13% / 93.58%; root 98.22% / 93.3% (executor records only; canonical artifact absent) | 97.13% lines minimum over the 13 executable Phase 12 files (executor record from an unretained SCRATCH summary, unverified by this review); 0% verified for the 10 changed executable files without per-file thresholds |
| PowerShell | 147 files (35 production files in the coverage population) | 12615 | ✅ 12605 pass, 0 fail, 10 pre-existing skips | 92.62% lines (P0, 17730/19142) | 93.28% lines (20003/21443), parsed by this review from the retained full-run artifact | Every changed production PowerShell file at or above 85% lines in the retained full-run artifact |
| Bash | 1 file (test fixture `tests/fixtures/codex_native_converter/native_surfaces/.claude/lib/bash/parallel-common.sh`) | No bats tests | N/A (fixture data, not executed) | N/A (no coverage) | N/A (no coverage) | N/A |
| JSON | 98 files | N/A | ✅ schema and contract validation (executor record) | N/A (config files) | N/A (config files) | N/A |
| C# | 0 `.cs` files (project fixtures only) | N/A | N/A | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/typescript-extension-coverage-summary.2026-10-18T03-58.json`, `typescript-root-coverage-summary.2026-10-18T03-55.json`
- TypeScript post-change coverage artifact: **absent.** `coverage/lcov.info` does not exist; `extensions/drm-copilot/coverage/lcov.info` is dated 2026-10-23T13:49Z and predates every Phase 12 TypeScript change; the P14-T7 run wrote json-summary output to `SCRATCH/issue-980-p14-jest-root` and `SCRATCH/issue-980-p14-jest-ext`, which are not retained.
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/powershell-coverage.2026-10-18T04-22.xml`
- PowerShell post-change coverage artifact: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p14-powershell-coverage.2026-10-29T12-14.xml` (full run, 93.28%). The canonical path `artifacts/pester/powershell-coverage.xml` holds a partial run (13638/21443 lines, 63.60%) written at 2026-10-29T12:05Z; see section 8.
- Per-language comparison summary: section 1.2.1.

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

Missing artifact paths for this audit: `coverage/lcov.info` (TypeScript), and a retained TypeScript per-file coverage artifact for head `c88235db0`.

---

## Executive Summary

This audit covers the full feature-versus-base diff for issue #980: a new installable Python runtime (`drm_copilot_discovery` 2.0.0), v2 discovery schemas, thin TypeScript and MCP wrappers in the extension, native discovery hooks for Claude Code, Codex and GitHub Copilot with bundled mirrors, eight agents and seventeen skills, documentation, and the Phase 12 host-principal completion path and Phase 14 schema-registry correction.

The Python, PowerShell and file-size gates pass on independently parsed evidence. Four findings block the review:

1. **TypeScript coverage artifact absent** (autonomous). The canonical artifact does not exist, the extension `lcov.info` predates Phase 12, and 10 changed executable TypeScript production files have no per-file Jest threshold, so their coverage cannot be verified.
2. **Evidence location violations** (autonomous). `validate_evidence_locations.py --root .` exits 1 for two issue-980 coverage files under `artifacts/coverage/`.
3. **Capability probe self-attests trusted attribution** (autonomous). `Get-DiscoveryCapabilityObservation` computes `trusted_attribution` from a synthetic `DRM_DISCOVERY_*` table that it builds itself (`.claude/lib/discovery-validation/DiscoveryCapability.psm1:246-250`). The control therefore cannot fail on a host that never supplies those values, and the probe can report `supported` where the tool gate attributes no specialist.
4. **No production supplier of the trusted agent identity** (human decision required). The native tool gate, the start hook, the stop hook, the MCP authorization gate and `prepare_discovery_agent` all take the host, session and agent identity only from `DRM_DISCOVERY_*` process environment values. No file in the repository sets those values, and the P12-T12 installed-host proof exported them from SCRATCH launcher scripts. The repository therefore contains no mechanism by which an unmodified host supplies them. Choosing that mechanism is a design decision.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (via `.claude/rules/python.md`, `python-suppressions.md`)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- ✅ TypeScript: `.claude/rules/typescript.md`, `typescript-suppressions.md`, `architecture-boundaries.md`
- N/A Bash: shfmt + shellcheck + bats (the only `.sh` file is converter fixture data)
- ✅ JSON: schema and contract validation per executor record `evidence/qa-gates/p14-repository-contracts.2026-10-29T12-49.md`

Toolchain results are taken from the executor's Phase 14 records and cross-checked against the coverage artifacts this review parsed. The review ran check-only commands; it did not re-run the full suites.

**Temporary artifacts cleanup:**
- ❌ Two worktree-local issue-980 coverage files remain under `artifacts/coverage/` (`issue-980-p7t3-coverage.json`, `issue-980-p7t3-devtools-coverage.json`); they are gitignored and not in the branch diff, but the evidence-location validator reports them.
- ✅ Ongoing tooling scripts added by the branch (`scripts/dev_tools/build_discovery_runtime.py`, `discovery_build_identity.py`, `agentic_sync_artifacts.py`, `agentic_sync_filesystem.py`, `scripts/dev-tools/Test-DiscoveryHostCapability.ps1`) are tested; the review scripts used for this audit live only in the session scratchpad.
- The executor's SCRATCH harness scripts (`SCRATCH/issue-980-*.sh`, `issue-980-mcp-client.cjs`) are not committed.

---

## Rejected Scope Narrowing

No scope narrowing was detected. The coordinator relayed a user decision on review item 5 ("The 1.1.22 references in handoff.md and completion-report.md are accurate historical evidence of the artifacts that were tested ... Do not raise it as a finding."). That decision settles one judgment question; it does not narrow the file, language or coverage scope. The audit scope remains the full branch diff.

---

## Evidence Location Compliance

Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 1).

| Path | Status | Canonical replacement |
|---|---|---|
| `artifacts/coverage/issue-980-p7t3-coverage.json` | FAIL (gitignored, untracked, not in the branch diff) | `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/` |
| `artifacts/coverage/issue-980-p7t3-devtools-coverage.json` | FAIL (gitignored, untracked, not in the branch diff) | `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/` |

A scan of the branch diff found no tracked file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. Both violations are local residue from P7-T3. Remediation is to move any needed content into the feature evidence folder and delete the two files.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `evidence/regression-testing/p14-isolation.2026-10-29T12-23.md`: seeded Jest (seed 1414), reversed Python order over 25 modules, Pester seeds 141, 242, 343, all green. The TypeScript identity tests that set `DRM_DISCOVERY_*` restore every key in a `finally` block (`extensions/drm-copilot/test/discovery-artifact-commands.test.ts`, `withIdentityEnvironment`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | Tests mirror production modules one-to-one in `tests/discovery_runtime/test_<module>.py` and `extensions/drm-copilot/test/<module>.test.ts`; the parametrized refusal matrices target one guard each. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The Phase 14 registry correction reduced the full Python run from 17965.16 s to 929.37 s (`evidence/other/p14-registry-timing.2026-10-29T12-45.md`). Root Jest 130.9 s for 5126 tests. |
| **Determinism** - Consistent results | ✅ PASS | Clocks and nonces are injected (`DiscoveryAuthorityProvider.now`/`nonce`; Python `Clock`); subprocess seams are monkeypatched (`tests/discovery_runtime/test_gateway_local.py:352`, `test_gateway_boundaries.py:185`). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive test names and docstrings, for example `test_repository_roles_reject_a_conflicting_local_identity`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** Python 94.11% lines / 88.78% branches; TypeScript extension 97.41% / 92.65%; TypeScript root 97.98% / 92.35%; PowerShell 92.62% lines.<br>**Command:** recorded in `evidence/baseline/python-tests.2026-10-18T03-51.md`, `typescript-extension-tests.2026-10-18T03-58.md`, `typescript-root-tests.2026-10-18T03-55.md`, `powershell-tests.2026-10-18T04-21.md`<br>**Timestamp:** 2026-10-18 03:51 to 04:22 |
| **No Coverage Regression** | ❌ FAIL | Python 94.11% to 96.70% lines (+2.59) and 88.78% to 93.62% branches (+4.84); PowerShell 92.62% to 93.28% (+0.66). TypeScript: the executor reports extension 97.41% to 97.13% lines (-0.28, still above the floor) and 93.58% branches, but no retained artifact exists to verify it, and no changed-line data exists for the 10 changed executable files outside the Phase 12 population. |
| **New Code Coverage ≥90%** | ⚠️ PARTIAL | Python: every changed production file at or above 90.24% lines in `artifacts/python/lcov.info`. PowerShell: every changed production file at or above 85% lines in the retained full-run artifact. TypeScript: the executor's comparison (`evidence/qa-gates/p14-coverage-comparison.2026-10-29T12-45.md`) covers 16 Phase 12 files from a SCRATCH summary that this review cannot read. |
| **Comprehensive Coverage** | ✅ PASS | Every production module in `packages/discovery-runtime/src/drm_copilot_discovery/` appears in the Python artifact; `changed production files not in artifact: 0` for Python and PowerShell. |
| **Positive Flows** - Valid inputs | ✅ PASS | For example, `tests/discovery_runtime/test_gateway_host.py` admits a fully bound host request; `test_repository_roles_retain_related_pins`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `tests/discovery_runtime/test_gateway_host_refusals.py`, `test_protected_records.py`, `test_service_host_admission.py`, `extensions/drm-copilot/test/discovery-authorization.binding.test.ts`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Parse-limit, path-collision and result-limit suites (`test_parsing_limits.py`, `test_path_collisions.py`, `test_service_result_limits.py`). |
| **Error Handling** - Error paths | ✅ PASS | Exit-code and finding-code assertions across `test_service_failures.py`, `test_cli_errors.py`. |
| **Concurrency** - If applicable | ✅ PASS | The authorization latch race is tested (`AUTHORITY_LOCKED` mapped to `AUTHORIZATION_CONSUMED` in `discovery-authorization.ts:436-445`, with test coverage recorded at 97.56% lines for that file). |
| **State Transitions** - If applicable | ✅ PASS | Invocation `prepared` to `started`, authorization `issued` to `consumed`, activation and deactivation are covered by the start, authorization and activation suites. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 94.11% lines -> Post-change: 96.70% lines. Change: +2.59% lines, +4.84% branches (88.78% to 93.62%). New/changed-code coverage: lowest changed production file 90.24% lines; 0 of 184 changed files below 85% lines or 75% branches. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (2026-10-29T12:44Z), `evidence/qa-gates/p14-python-tests.2026-10-29T12-45.md`.
- TypeScript: Baseline: 97.41% lines -> Post-change: 97.13% lines (executor record). Change: -0.28% lines, +0.93% branches. New/changed-code coverage: 97.13% lines minimum over the 13 executable Phase 12 files per the executor record, which this review cannot verify because the canonical artifact is absent; 10 changed executable files carry no per-file Jest threshold (`src/lib/codex-native-converter/classifier-claude.ts`, `classifier.ts`, `inventory.ts`, `mapping.ts`, `pipeline-render.ts`, `rewrites-rules.ts`, `rewrites.ts`, `src/lib/validate/codex-topology-resolver.ts`, `src/lib/validate/orchestrator-state-codex-model-routing.ts`, `src/repo-automation-tool-names.ts`). Disposition: FAIL. Evidence: absence of `coverage/lcov.info`; `extensions/drm-copilot/coverage/lcov.info` dated 2026-10-23; `evidence/qa-gates/p14-typescript-root-tests.2026-10-29T10-50.md` (coverage directory `SCRATCH/issue-980-p14-jest-root`).
- PowerShell: Baseline: 92.62% lines -> Post-change: 93.28% lines. Change: +0.66% lines (no branch metric under Pester). New/changed-code coverage: every changed production file at or above 85% lines. Disposition: PASS. Evidence: `evidence/qa-gates/p14-powershell-coverage.2026-10-29T12-14.xml`.
- C#: N/A - out of scope (zero `.cs` files changed).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ⚠️ PARTIAL | Most refusal tests assert finding codes. Two weak spots: `tests/discovery_runtime/test_gateway_host_main.py:243` asserts only exit code 2, so it cannot tell which check refused; `tests/discovery_runtime/test_schema_validation.py` `after == before` compares one shared object with itself. Both are recorded in the code review as non-blocking. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange, act and assert phases are separated by blank lines in the inspected tests (for example `test_repository_roles_retain_related_pins`). |
| **Document Intent** | ✅ PASS | Each inspected test carries a docstring or JSDoc stating the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | A search of the new Python, TypeScript and Pester discovery tests found no `tmp_path`, `tempfile`, `mkdtemp`, `os.tmpdir` or `New-TemporaryFile`. The only `subprocess.Popen` references are monkeypatched seams. |
| **Use Mocks/Stubs** | ✅ PASS | In-memory protected stores (`MemoryService`, injected `AuthorizationStoreIO`), injected clocks and nonces, and a mocked `child_process.spawn` in extension tests. |
| **Environment Stability** | ✅ PASS | Process environment mutation in `discovery-artifact-commands.test.ts` is restored in `finally`. `test_gateway_host_main.py` uses `Path(__file__).resolve().parent` as an absolute root and reads no file under it. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the independent policy review for head `c88235db0`. Outstanding items are listed in section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` (#980), `spec.md`, `user-story.md`, `requirements-traceability.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-10-17T22-38.md` Phases 0 to 14; research under `research/`. |
| **Document the plan** | ✅ PASS | 122 of 122 plan tasks checked; Phase 12 to 14 revisions recorded in the plan. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Python owns artifact semantics; TypeScript and PowerShell layers are thin adapters, as the spec requires. |
| **Reusability** | ✅ PASS | One `DiscoveryAuthorization.psm1` and related modules are shared by all three hosts' hooks; the bundled copies are byte-identical. |
| **Extensibility** | ✅ PASS | Analyzer plugin registry, domain extension schemas with namespace pinning, and versioned v1/v2 catalogs. |
| **Separation of concerns** | ⚠️ PARTIAL | Pure decoding (`protected_records.py`) is separate from I/O seams (`gateway_host_store.py`). The trust boundary, however, depends on a process-environment input that no component in the branch produces; see section 8. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One concern per module (for example `operation_grants.py` at 86 lines, `service_finalization.py` at 110 lines). |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts (content split on `\r\n`, `\n`, `\r`; trailing terminator not counted) over all 696 added or modified covered files: maximum 500 (`mutation_plan.py`, `analyzer/dependency_inputs.py`, `DiscoveryAuthorization.psm1` and its two mirrors, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`). No file at or above 700 lines. `config/file-size-baseline.json` changed only by removing the `scripts/dev_tools/agentic_sync.py: 819` entry (now 454 lines); no entry was added or increased. |
| **Public vs internal** | ✅ PASS | Internal helpers are underscore-prefixed (`_verify`, `_binding`, `_read_selection`); the package declares its CLI entry points in `pyproject.toml`. |
| **No circular dependencies** | ✅ PASS | Architecture stages passed (`evidence/qa-gates/p14-architecture-boundaries.2026-10-29T12-49.md`, `p14-typescript-*-architecture.2026-10-29T10-50.md`). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `decode_authorization`, `consumeToolAuthorizationByBinding`, `Get-DiscoveryPreToolDecision`. |
| **Docs/docstrings** | ✅ PASS | Every inspected Python function carries a contract docstring; TS exports carry JSDoc; PowerShell functions carry comment-based help. |
| **Comment why, not what** | ✅ PASS | For example `gateway_host.py:257` ("The grant must be an actual partition entry, never a path the request spells."). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black .`; `npm run format:check` (root and extension); `Invoke-PoshQCFormat`<br>**Result:** Black 972 files unchanged; Prettier clean; PoshQC no change (`p14-python-format.2026-10-29T12-45.md`, `p14-typescript-*-format.2026-10-29T10-50.md`, `p14-powershell-format.2026-10-29T12-14.md`) |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check .`; `npm run lint`; `Invoke-PoshQCAnalyze`<br>**Result:** no findings (`p14-python-lint`, `p14-typescript-*-lint`, `p14-powershell-analyze`) |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright`; `npm run typecheck`<br>**Result:** 0 errors (`p14-python-types.2026-10-29T12-45.md`, `p14-typescript-*-types.2026-10-29T10-50.md`); N/A for PowerShell |
| **4. Testing** | ⚠️ PARTIAL | **Command:** `poetry run pytest --cov --cov-branch`; `node run-jest.cjs --coverage`; `Invoke-PoshQCTest -Root .`<br>**Result:** all suites green; TypeScript coverage output not retained (section 1.2.1) |
| **Full toolchain loop** | ✅ PASS | Phase 14 records one clean cycle per language after the registry correction and rebase. |
| **Explicit reporting** | ✅ PASS | Commands and results are recorded in `evidence/qa-gates/p14-*.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | `completion-report.md`, `handoff.md`, commit messages. |
| **Design choices explained** | ⚠️ PARTIAL | `docs/engineering/legacy-discovery-and-parity/enforcement.md` documents the host-principal path but does not state which component places `DRM_DISCOVERY_*` in the hook and MCP processes. |
| **Update supporting documents** | ⚠️ PARTIAL | `spec.md` and `user-story.md` status lines still read "one escalated installed-host blocker" with `Last Updated 2026-10-26T02-54`, while `completion-report.md` states both escalations are closed. |
| **Provide next steps** | ✅ PASS | `handoff.md` publication prerequisites and per-repository steps. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black .`<br>**Result:** 972 files unchanged (`p14-python-format.2026-10-29T12-45.md`) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** clean (`p14-python-lint.2026-10-29T12-45.md`) |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors (`p14-python-types.2026-10-29T12-45.md`) |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch`<br>**Result:** 15668 passed, 6 skipped, 929.37 s; 96.70% / 93.62% confirmed from `artifacts/python/lcov.info` |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Full annotations; `cast` is used at JSON boundaries after schema validation (`gateway_host.py:254, 303, 366-385`). |
| **Dataclasses for value objects** | ✅ PASS | `HostPrincipal`, `WorkspaceBinding`, `TrustedIdentity` are frozen keyword-only dataclasses. |
| **Protocols/ABCs for interfaces** | ✅ PASS | `HostStoreIO`, `RepositoryReader` and `ServiceIO` seams. |
| **Avoid utility classes** | ✅ PASS | Pure helpers are module functions (`protected_records.py`, `operation_grants.py`). |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `OperationFailure("SERVICE_AUTHORITY", exit_code=3)` for every authority refusal; `PermissionError` mapped to `SERVICE_AUTHORITY` in `service.py:179-182`. |
| **Logging over print** | ✅ PASS | No `print` in the inspected production modules; results travel as structured service results. |
| **Invariants at construction** | ✅ PASS | `SchemaCatalog.__post_init__` verifies identities, dialects, namespaces and full reference closure. |

---

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .`<br>**Result:** no change (`p14-powershell-format.2026-10-29T12-14.md`) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** no findings (`p14-powershell-analyze.2026-10-29T12-14.md`) |
| **Fix all findings** | ✅ PASS | No open analyzer findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The hooks declare PowerShell 7+ (`.claude/hooks/enforce-discovery-artifact-gate.ps1` `.NOTES`), which is the repository requirement in `.claude/rules/powershell.md`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on the inspected functions (`Get-DiscoveryPreToolDecision`, `Get-DiscoveryCapabilityObservation`). |
| **Parameter validation** | ✅ PASS | `ValidateSet` on decision and host names; mandatory parameters declared. |
| **Avoid global state** | ✅ PASS | Store, clock, nonce and environment are injected parameters with real-host defaults. |
| **Error handling** | ✅ PASS | Dependency failures and envelope anomalies deny with the control prefix. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Maximum 500 logical lines (`DiscoveryAuthorization.psm1` and mirrors); none at or above 700. |
| **Approved verbs** | ✅ PASS | PSScriptAnalyzer `PSUseApprovedVerbs` clean per the analyzer record. |
| **Comment why** | ✅ PASS | For example `DiscoveryAuthorization.psm1:399` ("Family routing: only read-only natives and controlled discovery tools proceed."). |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | No change. |
| **Step 2: Analyze** | ✅ PASS | No findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 12615 tests, 0 failed, 10 pre-existing skips; three shards complete with merged coverage 93.28%. |
| **Rerun loop if needed** | ✅ PASS | Pass 1 failed on the stale baseline entry; P14-T8 removed it and pass 2 is clean. |

---

### Section 3C: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | **Command:** `npm run format:check`<br>**Result:** clean (`p14-typescript-{root,extension}-format.2026-10-29T10-50.md`) |
| **Linting with ESLint** | ✅ PASS | **Command:** `npm run lint`<br>**Result:** clean |
| **Type checking with TSC** | ✅ PASS | **Command:** `npm run typecheck`<br>**Result:** clean |
| **Testing with Jest** | ✅ PASS | **Command:** `node run-jest.cjs --coverage`<br>**Result:** root 5126 / extension 5109 passed |
| **Coverage artifact** | ❌ FAIL | `coverage/lcov.info` absent; extension `lcov.info` stale (2026-10-23). |
| **Suppressions** | ✅ PASS | No new file-level `eslint-disable`, `@ts-ignore` or `@ts-nocheck` found in the inspected Phase 12 modules. |

---

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | **Command:** `poetry run python -m scripts.dev_tools.format_json`<br>**Result:** no drift recorded in `p14-repository-contracts.2026-10-29T12-49.md` |
| **Schema validation** | ✅ PASS | **Command:** `poetry run python -m scripts.dev_tools.validate_json`<br>**Result:** valid; the discovery schemas are additionally verified by `SchemaCatalog` closure checks and `tests/schemas/discovery/` |
| **Required $schema** | ✅ PASS | Discovery schemas carry `$schema` and `$id` (enforced at catalog construction, `catalog.py:291-295`). |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | All schemas parse through the strict loader. |
| **Deterministic key order** | ✅ PASS | Canonical JSON for protected records (`canonicalJson` in `discovery-authorization.ts:433`). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | All Python tests use Pytest with function-scoped fixtures and `monkeypatch`. |
| **Coverage expectation** | ✅ PASS | 96.70% lines and 93.62% branches repo-wide; every changed production file at or above 90.24% lines. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | The final-QA split of `test_repository_roles_retain_pins_and_reject_conflicting_local_identity` into two single-behavior tests (commit `69f35c239`) improves focus. |
| **Mocking sparingly** | ✅ PASS | `monkeypatch` replaces one seam per test (`repository_pins`, `installed_repository`, `subprocess.Popen`). |
| **Organization** | ✅ PASS | `tests/discovery_runtime/` mirrors `packages/discovery-runtime/src/drm_copilot_discovery/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_main_refuses_incomplete_or_misplaced_host_identity`, `test_repeated_validations_through_one_catalog_are_independent`. |
| **Docstrings/comments** | ✅ PASS | Docstrings state purpose and expected outcome. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch`<br>**Result:** 15668 passed, 6 skipped |
| **No Alternative Test Runners** | ✅ PASS | Only Pytest. |

---

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `Describe`/`Context`/`It` with `BeforeAll` in `tests/scripts/claude-lib/discovery-validation/*.Tests.ps1`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>`config/poshqc-coverage.json` adds `.github/hooks` to the coverage population. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7+ per repository rule. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One decision class per `It` in the authorization and start suites. |
| **Test Behavior Over Implementation** | ✅ PASS | Tests assert decision, code and reason outputs. |
| **Mocking Used Sparingly** | ✅ PASS | Injected in-memory store hashtables replace the filesystem. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/discovery-validation/DiscoveryAuthorization.Tests.ps1`<br>**Code file:** `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1`<br>Structure mirrors the code location. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new Pester files end in `.Tests.ps1` (support files end in `.TestSupport.ps1`). |
| **Describe/Context/It Structure** | ✅ PASS | Inspected suites use one `Describe` per module and `Context` per decision family. |
| **Logical Grouping** | ✅ PASS | Grouped by lifecycle event (start, tool, stop, probe). |
| **Docstrings/Comments** | ✅ PASS | `It` names state expected decisions. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** 12615 tests, 0 failed |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### `gateway_host.py` (host-principal composition)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `tests/discovery_runtime/test_gateway_host.py` admission cases | Positive | 330-397 | ✅ |
| `tests/discovery_runtime/test_gateway_host_refusals.py` refusal matrix | Negative | 345-356, 258-259, 312-322 | ✅ |
| `tests/discovery_runtime/test_gateway_host_main.py::test_main_refuses_incomplete_or_misplaced_host_identity` | Negative | gateway option parsing | ✅ |

**Coverage:** at or above 90% lines (the Python artifact reports no changed file below 90.24%).

**Not covered:** None identified by this review.

---

### `catalog.py` (schema-registry correction)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_repeated_validations_through_one_catalog_are_independent` | Edge Case | 300-306, 353-363 | ✅ |

**Coverage:** 168/168 lines, 82/82 branches per `p14-coverage-comparison.2026-10-29T12-45.md`.

**Not covered:** None. The isolation assertion `after == before` is weak; see code review.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 15674 Python + 5126 TS root + 5109 TS extension + 12615 Pester | ✅ |
| Tests Passed | 15668 + 5126 + 5109 + 12605 (100% of non-skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 929.37 s Python; 130.9 s TS root; Pester recorded in `p14-powershell-tests.2026-10-29T12-14.md` | ✅ Fast relative to baseline 17965.16 s |
| Average Time per Test | about 59 ms Python, 26 ms TS root | ✅ Fast |
| Discovery Time | not recorded separately | ✅ |
| Functions/Classes Tested | 184/184 changed Python production files present in coverage | ✅ |
| Test File Size | maximum 499 logical lines (`tests/discovery_runtime/test_parity_clients.py`) | ✅ PASS |
| Code Coverage (if applicable) | Python 96.70% lines, 93.62% branches; PowerShell 93.28% lines; TypeScript unverified | ❌ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black .` | 972 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check` | clean | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest` | 15668 passed, 6 skipped | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | no change | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | no findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 12615 / 0 failed | ✅ |

**Notes:**
The review re-ran no suite. It parsed `artifacts/python/lcov.info` and the retained Pester coverage XML, ran `validate_evidence_locations.py`, measured logical line counts, compared bundled mirrors (109 discovery files, 0 differences), and hashed the six execution-environment brief copies (all `82b744fa…`).

---

## 8. Gaps and Exceptions

### Identified Gaps

- **TypeScript coverage artifact (FAIL, autonomous):** `coverage/lcov.info` is absent and the extension `lcov.info` predates Phase 12. Produce the canonical artifact for the branch head with `npm run test:unit:coverage`, retain a per-file copy under `evidence/qa-gates/`, and verify every changed TypeScript production file against 85% lines and 75% branches, including the 10 files without per-file thresholds.
- **Evidence locations (FAIL, autonomous):** remove `artifacts/coverage/issue-980-p7t3-coverage.json` and `artifacts/coverage/issue-980-p7t3-devtools-coverage.json`, then re-run `validate_evidence_locations.py --root .` to exit 0.
- **Capability probe self-attestation (FAIL, autonomous):** `Get-DiscoveryCapabilityObservation` sets `trusted_attribution` from a sentinel decision evaluated over `Get-DiscoverySentinelEnvironment`, a table the probe constructs itself. The control is true whenever the module logic denies `Bash`, regardless of whether the host supplies `DRM_DISCOVERY_*` to its hook processes. Bind the control to the host-supplied attribution of the probing process, and add a test in which a process without host-supplied identity values reports `unsupported`.
- **Trusted identity supplier (FAIL, human decision required):** `Get-DiscoveryPreToolDecision` returns `allow` / `NOT_DISCOVERY_AGENT` when the process carries no `DRM_DISCOVERY_AGENT_ID` and `DRM_DISCOVERY_AGENT_ROLE` (`DiscoveryAuthorization.psm1:385-389`); the MCP gate treats a process without them as a root principal (`mcp-discovery-authorization-gate.ts:132-135`) and then runs the call as `local-user` in structural mode when no `invocation_ref` is supplied (`repo-automation-service-discovery-identity.ts:56-61`). No file in the repository sets these variables. The P12-T12 proof (`evidence/qa-gates/discovery-native-capabilities.2026-10-28T15-06.md`) ran hooks as `pwsh -File` processes and the MCP server through `SCRATCH/issue-980-mcp-client.cjs` with the values exported by the harness. Whether an unmodified Claude Code, Codex or Copilot host supplies them is not shown by any artifact. A design decision is required on how a real host supplies the identity (for example from the hook envelope's agent fields, or from a per-agent MCP launch). Until then, the claims in `handoff.md` and `completion-report.md` that the chain was "observed on Claude Code, Codex and the Copilot Local harness" should be qualified as harness-simulated host events.
- **Canonical Pester artifact inconsistent (non-blocking):** `artifacts/pester/powershell-coverage.xml` reports 63.60% lines (a partial run) while the retained full-run artifact reports 93.28%. Regenerate the canonical artifact from a full run so automated readers see the correct figure.
- **Stale status lines (non-blocking):** `spec.md` line 7 and `user-story.md` line 5.

### Approved Exceptions

**None.** No exceptions needed. The user decision relayed on 2026-10-29 confirms that the 1.1.22 artifact references in `handoff.md` and `completion-report.md` are accurate historical evidence; this review verified that the P14-T12 build (`732bf84ec`, 2026-10-29T12:28Z) recorded `extension 1.1.22` and `@danmoisan/drm-copilot-mcp 1.1.22` from a tree that still carried 1.1.22, and that main's release commit `9d017e305` (1.1.23) entered the branch through the later rebase.

### Removed/Skipped Tests

**None.** All planned tests implemented. The 6 Python and 10 Pester skips are pre-existing and unchanged. The final-QA change to `test_extension_inputs.py` split one parametrized test into two and moved the conflicting-identity case behind a pin seam, because `profile_v2` now refuses that profile at construction (`PROFILE_BINDING`, asserted at `tests/discovery_runtime/test_profile_v2.py:272`). No assertion was removed.

---

## 9. Summary of Changes

### Commits in This PR/Branch

181 commits from `52587a0ee` to `c88235db0`. The final-QA and Phase 12 to 14 commits examined in detail:

1. **a19da9f7e** - perf(discovery): build the schema registry once per catalog (P14-T3, P14-T4)
2. **d6eb8d665** - test(discovery): close Phase 12 coverage gaps found by the P13-T4 comparison
3. **c0975875e** - wip(discovery): P13-T1 static stages and P13-T2 TypeScript loop with two stale-test corrections
4. **69f35c239** - wip(discovery): P13-T1 Python loop static stages and extension-inputs test update
5. **5ad797b15** - wip(discovery): P12-T12 installed-host receipt smoke, seven repairs and evidence
6. **251fa3a16** - feat(discovery): admit verified host authority and derive exact grants
7. **9410f8840** - feat(discovery): implement the finalize-agent route for verified host invocations
8. **b86eba202** - feat(discovery): consume one native authorization per controlled tool call
9. **32660d07a** - feat(discovery): decode and bind protected host records in Python
10. **da6ee2c74** - fix(ci): drop the stale agentic_sync file-size baseline entry (P14-T8)

### Files Modified

1. **packages/discovery-runtime/** (NEW)
   - Installable Python runtime, 182 source files, v1/v2 schema catalogs, gateway, service, analyzers.
2. **extensions/drm-copilot/src/** (27 NEW, 20 MODIFIED)
   - Discovery runtime launcher, authority provider, authorization consumer, MCP gate and tool definitions, VS Code commands.
3. **.claude/, .codex/, .github/, .agents/** and bundled mirrors (NEW/MODIFIED)
   - Discovery hooks, PowerShell libraries, four agents with Codex variants, seventeen skills, the execution-environment brief with the new `## Test Runtime` section.
4. **schemas/discovery/v2/**, **docs/engineering/legacy-discovery-and-parity/**, **examples/discovery/v2/** (NEW)
5. **config/file-size-baseline.json** (MODIFIED)
   - Removed the `agentic_sync.py` entry; `files` is now empty.

---

## 10. Compliance Verdict

### Overall Status: ❌ NON-COMPLIANT

Python, PowerShell, file-size, mirror-parity, test-isolation and toolchain policies are met. The branch is non-compliant on four items: the TypeScript coverage artifact is absent, the evidence-location validator fails, the capability probe's trusted-attribution control cannot fail, and no component supplies the trusted agent identity on which every native discovery control depends.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and research present.
- ⚠️ Design Principles: trust boundary depends on an unsupplied environment input.
- ✅ Module & File Structure: maximum 500 logical lines; baseline entry removed only.
- ✅ Naming, Docs, Comments: complete.
- ⚠️ Toolchain Execution: TypeScript coverage output not retained.
- ⚠️ Summarize & Document: stale status lines; identity supplier undocumented.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright, Pytest clean.
- ✅ Python Design & Typing: frozen dataclasses, typed seams.
- ✅ Error Handling: exit-3 refusals throughout.

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyzer clean.
- ✅ PowerShell Design & Safety: injected seams, fail-closed dependencies.
- ✅ Structure & Naming: approved verbs, at most 500 lines.
- ✅ Toolchain: 12615 tests green.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: isolation runs green.
- ❌ Coverage & Scenarios: TypeScript coverage unverifiable.
- ⚠️ Test Structure: two weak assertions (non-blocking).
- ✅ External Dependencies: no temp files or real processes.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest, 96.70% / 93.62%.
- ✅ Test Style & Structure: focused tests.
- ✅ Naming & Readability: descriptive.
- ✅ Toolchain: green.

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC.
- ✅ Test Style & Structure: one decision per `It`.
- ✅ Naming & Readability: `*.Tests.ps1`.
- ✅ Toolchain: green.

---

### Metrics Summary

- ✅ 38,508 of 38,508 non-skipped tests passing across Python, TypeScript and Pester (executor records)
- ✅ 184 of 184 changed Python production files measured
- ✅ Python 96.70% lines / 93.62% branches; PowerShell 93.28% lines
- ❌ TypeScript coverage not verifiable from a retained artifact
- ✅ Proper file organization: tests mirror source trees
- ✅ All format, lint and type checks passing
- ✅ Test execution time: Python 929.37 s (down from 17965.16 s)

---

### Recommendation

**Needs revision**

Address the three autonomous findings (TypeScript coverage artifact, evidence-location residue, probe self-attestation) and obtain a user decision on the trusted-identity supplier before the feature is declared complete. Re-run this review afterwards.

---

## Appendix A: Test Inventory

### Complete Test List

The full inventory is the JUnit output retained by the executor; this review inspected these tests directly:

- `tests/discovery_runtime/test_schema_validation.py::test_repeated_validations_through_one_catalog_are_independent`
- `tests/discovery_runtime/test_gateway_host_main.py::test_main_refuses_incomplete_or_misplaced_host_identity`
- `tests/discovery_runtime/test_gateway_host_main.py::test_local_user_options_still_compose_the_local_ports`
- `tests/discovery_runtime/test_extension_inputs.py::test_repository_roles_retain_related_pins`
- `tests/discovery_runtime/test_extension_inputs.py::test_repository_roles_reject_a_conflicting_local_identity`
- `extensions/drm-copilot/test/discovery-artifact-commands.test.ts` › createDiscoveryArtifact direct invocation drafts a feature contract under a grant
- `extensions/drm-copilot/test/discovery-artifact-commands.test.ts` › createDiscoveryArtifact refuses a granted draft from a process without a trusted agent identity
- `extensions/drm-copilot/test/mcp-discovery-authority-tool-definitions.test.ts` › finalize_discovery_agent requires exactly workspace_root and invocation_ref
- `extensions/drm-copilot/test/mcp-discovery-authority-tool-definitions.test.ts` › finalize_discovery_agent still declares request_id as an optional string property

---

## Appendix B: Toolchain Commands Reference

Commands run by this review (check-only):

```bash
git diff --name-status 52587a0eeaa04a0519801452235608a72b5eba5c HEAD -- . ':!docs/features'
git diff 52587a0eeaa04a0519801452235608a72b5eba5c HEAD -- config/file-size-baseline.json pyproject.toml extensions/drm-copilot/jest.config.cjs config/poshqc-coverage.json
git merge-base --is-ancestor 9d017e305 HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
python -I <scratchpad>/lcov.py artifacts/python/lcov.info <name-status list> .py
python -I <scratchpad>/jacoco.py artifacts/pester/powershell-coverage.xml <name-status list>
python -I <scratchpad>/jacoco.py docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p14-powershell-coverage.2026-10-29T12-14.xml <name-status list>
python -I <scratchpad>/count.py <covered-file list>   # logical line counts
python -I <scratchpad>/mirror.py .                     # bundled mirror parity
sha256sum <six execution-environment SKILL.md copies>
```

Repository commands the executor ran (records under `evidence/qa-gates/p14-*`):

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
node run-jest.cjs --coverage
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-10-29  
**Policy Version:** Current (as of audit date)
