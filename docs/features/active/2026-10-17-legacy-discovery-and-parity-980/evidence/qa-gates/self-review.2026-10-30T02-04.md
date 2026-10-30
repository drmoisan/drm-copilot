# P16-T10 Complete checklist self-review on the remediated tree (remediation cycle 1)

Timestamp: 2026-10-30T02-04
Task: [P16-T10] Rewrite the complete checklist self-review on the remediated tree.
Command: the three templates under `docs/features/templates/policy_audit/` (`policy-audit`, `code-review`, `feature-audit`) walked against `git diff <merge base of origin/main and HEAD> HEAD` (8467 changed paths, 216 commits) and the evidence tree under `evidence/`; one row per review finding of `remediation-inputs.2026-10-29T13-16.md` (R1 to R4, the Major, each Minor) and the user-directed catalog cache; a sweep of this plan's Phase 15 and 16 text and the four cycle documents for wording that violates the rule it enforces (`grep` for host paths, `DanMoisan`, `AppData` and `/tmp/` over the four documents and the plan's revision section)
EXIT_CODE: 0 (every evidence command cited below exited as recorded in its own artifact; the sweep greps matched no host path)
Output Summary: 123 checklist rows: 121 PASS, 2 N/A, 0 FAIL, counted by each row's leading status with the findings table excluded (counter `SCRATCH/issue-980-p14-review-count.py`; the same counter gave 118 PASS, 3 N/A, 0 FAIL for the P14-T15 self-review), plus 13 review-finding rows each PASS and naming its closing task and existing evidence. Four multi-item acceptance rows also carry N/A sub-items: C# gates (no C# additions), the independent re-review, telemetry and the final-review seeded condition. Final evidence is the Phase 16 set on the remediated tree; Phase 15 task records are cited for the behavior they introduced, and earlier records only where the behavior they prove is unchanged since. No row is FAIL and no blocking row is unverified. The sweep found no host path in the plan's Phase 15 and 16 text or in the four cycle documents; one Info observation is recorded on the review documents' own citation form.
Result: PASS

Row values are PASS, FAIL or N/A. A row marked N/A states why the item does not apply.

## Part A: policy-audit checklist

### Scope and coverage metrics

| Row | Status | Evidence |
| --- | --- | --- |
| Code under test listed | PASS | 8467 changed paths from the merge base (216 commits): `packages/discovery-runtime`, `extensions/drm-copilot`, `tests/discovery_runtime`, `tests/scripts`, `scripts/dev_tools`, `schemas/discovery`, customizations under `.claude`, `.codex`, `.github`, `.agents`, docs and evidence; 724 branch code files counted in `p16-file-size.2026-10-30T01-55.md`; 274 production files tabulated in `p16-coverage-comparison.2026-10-30T01-41.md` |
| Coverage metrics by language, baseline and post-change | PASS | Python baseline 94.11% lines / 88.78% branches (`baseline/python-tests.2026-10-18T03-51.md`) → final 96.69% / 93.62% (`p16-python-tests.2026-10-30T00-42.md`); TypeScript extension 97.41% / 92.65% → 97.04% / 93.63%, root 97.98% / 92.35% → final root run recorded in `p16-typescript-root-tests.2026-10-30T01-40.md`; PowerShell 92.62% lines → 93.34% lines, no branch metric (`p16-powershell-tests.2026-10-30T01-29.md`) |
| New or changed code coverage | PASS | `p16-coverage-comparison.2026-10-30T01-41.md`: 274 production files (185 Python, 50 TypeScript, 39 PowerShell), 0 failures; 203 new files at least 90% lines; every changed executable line of a pre-existing file covered after the P16-T4 repair (two focused tests for the sentinel dispatch) |
| Coverage evidence checklist (baseline and post-change artifacts, comparison) | PASS | baselines under `evidence/baseline/`; post-change `p16-python-coverage.2026-10-30T00-42.json`, `p16-typescript-{root,extension}-lcov.2026-10-30T01-40.info`, `p16-typescript-{root,extension}-coverage-summary.2026-10-30T01-40.json`, `p16-powershell-coverage.2026-10-30T01-29.xml`; the comparison above (R1 closed: the TypeScript reports are retained under the feature evidence) |
| Policy documents evaluated | PASS | `remediation-baseline/phase15-instructions-read.2026-10-29T17-53.md` (cycle entry); the tiered file-size policy applied in `p16-file-size.2026-10-30T01-55.md` |
| Temporary artifacts cleanup | PASS | every helper lives under `SCRATCH` (outside the repository) and no scratch file is tracked; `git status --porcelain` empty at the start and end of P16-T8 and at each task commit; the P15-T19 probe was deleted after its record; the evidence-location validator exits 0 (`p16-evidence-locations.2026-10-30T01-55.md`) |

### 1.1 Core principles

| Row | Status | Evidence |
| --- | --- | --- |
| Independence | PASS | `regression-testing/p16-isolation.2026-10-30T01-45.md`: seeded Jest (1616) in both projects, reversed Python over the 12 Phase 15 modules with `test_catalog.py` last, three Pester seeds (161, 262, 363) over 25 suites, and the CI-shaped single process (`p16-powershell-single-process.2026-10-30T01-29.md`) agree |
| Isolation | PASS | one behavior per test; suites mirror modules; the Phase 15 tests pass payload fixtures through injected seams and read protected records from in-memory stores only |
| Fast execution | PASS | the full Python population runs in 661.48 s with branch coverage (929.37 s in Phase 14; the discovery runtime tree 304.69 s → 156.30 s, `other/p15-registry-cache-timing.2026-10-30T00-11.md`); Jest suites in about five minutes per project; Pester 12744 tests in the CI shape |
| Determinism | PASS | injected clocks (`HostServiceIO(clock=...)`, `gateway.utc_now`), nonces, stores and seams; no `DRM_DISCOVERY_*` or other process-environment read remains on the identity path (`git grep -c DRM_DISCOVERY -- .claude/lib .claude/hooks .codex/hooks .github/hooks docs/engineering` prints no line); forbidden-I/O scan `HITS=9`, all classified non-I/O (`p16-test-io.2026-10-30T01-55.md`) |
| Readability and maintainability | PASS | descriptive `test_*` and `It` names with docstrings, Arrange-Act-Assert layout, shared test-support modules (`discovery-grant-test-support.ts`, `gateway_host_test_support.py`, `DiscoveryGate.TestSupport.ps1`) |

### 1.2 Coverage and scenarios

| Row | Status | Evidence |
| --- | --- | --- |
| Baseline coverage documented | PASS | Phase 0 baselines; the P15-T18 before-timing in `other/p15-registry-cache-timing.2026-10-30T00-11.md` |
| No coverage regression | PASS | repository totals at or above baseline in every language; every changed line of pre-existing files covered (`p16-coverage-comparison.2026-10-30T01-41.md`) |
| New code coverage >= 90% | PASS | every file new since P0 at least 90% lines (203 files) |
| Comprehensive coverage | PASS | per-file table in `p16-coverage-comparison.2026-10-30T01-41.md`, including the ten P15-T20 files and every Phase 15 module by name |
| Positive flows | PASS | the public host workflow (`test_public_host_workflow.py`, `discovery-host-workflow.test.ts`), the installed console sweep (`discovery-installed-runtime.2026-10-30T01-47.md`), the root-grant and sentinel happy paths (`discovery-root-grant.test.ts`, `discovery-sentinel.test.ts`, `DiscoveryRootGrant.Tests.ps1`, `DiscoveryObservation.Tests.ps1`) |
| Negative flows | PASS | refused, expired, replayed and unbound paths: `DISCOVERY_HOST_BINDING_REQUIRED`, `AUTHORIZATION_*` classes, the Python "already dispatched" and "expired before dispatch" refusals (`p15t16-verification.2026-10-29T23-45.md`), the read-scope refusals (`p15t17-verification.2026-10-29T23-56.md`), the probe `unsupported` cases, the isolation-assertion probe that fails on a mutated registry (`regression-testing/p15-isolation-assertion.2026-10-30T00-14.md`) |
| Edge cases | PASS | binding with zero or several prepared invocations, `agent_id` present without a discovery agent type, observation without `agent_id`, stale observation, handler-hash mismatch, symlink and alias read targets, identical-content catalogs versus extension catalogs |
| Error handling | PASS | typed `SERVICE_*`, `AUTHORIZATION_*`, `FINALIZATION_*`, `DISCOVERY_*` findings with exit 1/2/3 mapping; fixed option-refusal strings in the gateway; `CatalogError` before any cached registry hit |
| Concurrency | PASS | exclusive-create latches for root grants, sentinel grants, consumed authorizations and the Python `.used` dispatch latch (`HostStoreIO.create_exclusive`); the registry cache holds immutable `referencing.Registry` values keyed by content |
| State transitions | PASS | prepared → started (at the first controlled call) → finalized; grant issued → consumed; authorization consumed → used (`DiscoveryStart.Tests.ps1`, `DiscoveryStop.Tests.ps1`, `discovery-invocation*.test.ts`, `test_gateway_host*.py`) |
| Per-language comparison | PASS | section "Scope and coverage metrics" above |

### 1.3 to 1.5 Structure, environment, audit

| Row | Status | Evidence |
| --- | --- | --- |
| Clear failure messages | PASS | `Should -Be ... -Because`, pytest messages, Jest structured `expect`; service refusals prefix their code into the message |
| Arrange-Act-Assert | PASS | pattern applied in every Phase 15 and 16 suite |
| Document intent | PASS | docstrings on every test and helper, `It` names, intent comments on loops and branches |
| Avoid external dependencies | PASS | no network, process or database in unit tests; Git, the filesystem and the clock are injected seams |
| Use mocks and stubs | PASS | in-memory stores and recorded fakes; the registry counter delegates to the real builder; no blanket mock of code under test (the sentinel dispatch tests mock only the service seam) |
| Environment stability | PASS | no temporary files (scan `HITS=9`, all classified non-I/O), no PATH, profile or environment-variable reads on the identity path |
| Pre-submission review | PASS | this record |

### 2 General code change policy

| Row | Status | Evidence |
| --- | --- | --- |
| Clarify the objective | PASS | issue #980, `spec.md`, `user-story.md`, the review set `*.2026-10-29T13-16.md`, `research/2026-10-29T13-16-host-identity-sources-research.md`; the plan's `## Revision: remediation cycle 1` records the user's decisions |
| Read existing change plans | PASS | `plan.2026-10-17T22-38.md`, preflighted for Phases 15 and 16 (`other/preflight-fixes.2026-10-29T17-51.md`) |
| Document the plan | PASS | the plan and task-scoped commit messages (216 commits) |
| Simplicity first | PASS | identity read from the payload envelope; one content-keyed dictionary for the registry cache; the dispatch latch is one exclusive create beside the consumed record |
| Reusability | PASS | shared PowerShell modules (`DiscoveryToolRouting`, `DiscoveryRootGrant`, `DiscoveryObservation`), shared TypeScript modules (`discovery-root-grant.ts`, `discovery-sentinel.ts`, `discovery-authorization-binding.ts`), the shared Python read selector (`gateway_host_reads.py`) |
| Extensibility | PASS | optional service seams (`consumeDiscoveryRootGrant?`, `discoveryCapabilitySentinel?`), keyword parameters with defaults (`HostServiceIO(clock=...)`, `_count_registry_builds(name=...)`), protocols unchanged |
| Separation of concerns | PASS | gate decisions without I/O, store access through seams, host adapters thin; `select_reads` is pure with an injected resolver |
| Cohesive modules | PASS | one purpose per module; the Phase 15 additions went to new modules rather than into near-limit files |
| At or below the 800-line hard limit | PASS | `FileSizePolicy.RepoGate.Tests.ps1` passes (no baseline entries); no branch code file above 800 logical lines, none at or above 700; the one file between 501 and 699 is `extensions/drm-copilot/jest.config.cjs` at 531, the user-directed exception recorded in the plan's File-size decision (`p16-file-size.2026-10-30T01-55.md`); every Phase 15 production and test file at or below 500 (`DiscoveryAuthorization.psm1` 479, `gateway_host.py` 486, `discovery-authorization.ts` 360 after the splits) |
| Public versus internal | PASS | `_`-prefixed helpers (`_require_schema_libraries`, `_registry_key`, `_build_registry`, `_REGISTRY_CACHE`), explicit module exports and `DiscoveryAuthority.psd1` export list |
| No circular dependencies | PASS | TypeScript module-boundary suites pass (`p16-architecture-boundaries.2026-10-30T01-55.md`); PowerShell modules import siblings with `-ErrorAction Stop` in a fixed order |
| Descriptive names | PASS | `test_identical_content_shares_one_registry_and_different_content_does_not`, `consumeToolAuthorizationByBinding`, `Get-DiscoveryObservationEvidence` |
| Docs and docstrings | PASS | every new function and class documented; `enforcement.md` `## Identity source` and `## Capability probe`; architecture, maintainer guide and CLI reference updated (`other/p15-execution-environment-check.2026-10-30T00-28.md`) |
| Comment why, not what | PASS | intent comments on the cache miss, the exclusion of the Claude-only compatibility module from the shared library, the probe-only mutation in the isolation probe |
| Formatting, linting, type checking, testing | PASS | Black 976 unchanged, Ruff clean, Pyright 0 errors, Pytest 15728 passed; Prettier, ESLint, tsc clean, Jest 5177 and 5194 passed; PoshQC format no change, PSScriptAnalyzer no findings, Pester 12744 passed |
| Full toolchain loop | PASS | each loop restarted after every change: the TypeScript loop repeated after the P16-T4 test addition (`p16-typescript-*.2026-10-30T01-40.md` supersede `*.2026-10-30T00-48.md`); the Python and PowerShell loops ran after the last Phase 15 commit |
| Explicit reporting | PASS | per-step artifacts with `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary` |
| Summarize changes | PASS | `requirements-traceability.md` (Phase 15 and 16 entry), commit bodies |
| Design choices explained | PASS | the plan's `## Revision: remediation cycle 1` decisions and design facts; `other/p15-mirror-parity.2026-10-30T00-23.md` records the stray-copy decision; `p16-powershell-tests.2026-10-30T01-29.md` records the canonical-file restoration |
| Update supporting documents | PASS | `handoff.md` digests and requalified host claims (P15-T23, P16-T6), `completion-report.md`, `issue.md`, `spec.md` and `user-story.md` status (P16-T9), the brief wording (P15-T21) |
| Provide next steps | PASS | `handoff.md` and `completion-report.md` list the review- and CI-dependent items and the orchestrator launch instructions for a host observation (`discovery-host-observations.2026-10-30T01-47.md`) |

### 3A Python, 3B PowerShell, 3C Bash, 3D JSON

| Row | Status | Evidence |
| --- | --- | --- |
| Black, Ruff, Pyright, Pytest | PASS | as above |
| Strong typing | PASS | Pyright strict clean; `cast("JsonValue", payload)` at the canonical-JSON boundary; typed `Callable` resolver seam in `gateway_host_reads.py`; 0 new `noqa` or `type: ignore` lines in the Phase 15 modules (the first draft's `noqa: F401` was replaced by `importlib.import_module`) |
| Dataclasses for value objects | PASS | frozen dataclasses throughout; `SchemaCatalog` stays frozen with `_shared_registry` set through `object.__setattr__` |
| Protocols for interfaces | PASS | `ServiceIO`, `RepositoryReader`, `GitCommand`, `InstalledBuildStore`, `HostStoreIO` |
| Avoid utility classes | PASS | module functions; no static-only classes |
| Specific exceptions | PASS | typed `OperationFailure`, `ServiceRuntimeError`, `PathPolicyError`, `CatalogError`; broad handlers only at entry points with the pre-authorized form |
| Logging over print | PASS | results emitted as JSON documents through stream seams |
| Invariants at construction | PASS | `__post_init__` checks; the catalog verifies identities at construction and obtains its registry through the content-keyed cache, whose builder verifies metaschemas and closure once per content |
| PowerShell format, analyze, fix findings | PASS | `p16-powershell-{format,analyze}.2026-10-30T01-29.md` (1216 files already formatted; no findings) |
| PowerShell 7 compatibility | PASS | `#Requires -Version 7`; PSScriptAnalyzer compatibility rules in the repository settings |
| Advanced functions, parameter validation | PASS | `[CmdletBinding()]`, `[Parameter(Mandatory)]`, `[OutputType()]` on exported functions (`ConvertTo-DiscoveryObservationInstant` typed `[datetime]`) |
| Avoid global state | PASS | injected stores and payloads; `$script:` only for constants; the environment-table helpers are removed |
| PowerShell error handling | PASS | fail-closed hooks (`exit 2` with reason), `-ErrorAction Stop` imports, observational start that never claims a deny |
| PowerShell cohesive and at or below the 800-line hard limit | PASS | largest touched module `DiscoveryAuthorization.psm1` at 479 logical lines after the P15-T4 split; no PowerShell branch file above 500 |
| Approved verbs | PASS | `Get-`, `Write-`, `Test-`, `Resolve-`, `ConvertTo-`, `Invoke-`, `Add-` only |
| PowerShell toolchain loop | PASS | format → analyze → test in one clean pass on the remediated tree |
| Bash (3C) | N/A | the branch changes no `.sh` production script |
| JSON formatting and schema validation (3D) | PASS | `tests/schemas` population passes with the two new v2 kinds (`test_v2_grant_schemas.py`); `.github/hooks/discovery.json` in the documented version-1 shape (P15-T11) |

### 4A and 4B Unit-test policies

| Row | Status | Evidence |
| --- | --- | --- |
| Use Pytest; no alternative runner | PASS | all Python tests under `tests/` run by Pytest |
| Coverage expectation | PASS | 96.69% lines / 93.62% branches repository; new code at least 90% |
| Focused tests, mocking sparingly, organization | PASS | mirror layout (`tests/discovery_runtime/test_gateway_host_reads.py` for `gateway_host_reads.py`); seams rather than mocks of the unit under test |
| Naming and docstrings | PASS | descriptive names with contract docstrings |
| Use Pester v5; PoshQC configuration | PASS | run through `Invoke-PoshQCTest` in the CI shape (`p16-powershell-tests.2026-10-30T01-29.md`) |
| Focused, behavior over implementation, mocking sparingly | PASS | in-memory store seams; payload fixtures |
| Organization and file naming (`*.Tests.ps1` mirroring the script) | PASS | `tests/scripts/claude-lib/discovery-validation/<Module>.Tests.ps1`, `tests/scripts/<host>-hooks/<hook>.Tests.ps1` |
| Describe/Context/It structure, grouping, comments | PASS | every Phase 15 suite |
| Use `Invoke-PoshQCTest`; no alternative runner | PASS | CI-shape stage and shards (`p16-powershell-shards.2026-10-30T01-29.md`) |

### 5 to 7 Coverage detail, execution metrics, quality checks

| Row | Status | Evidence |
| --- | --- | --- |
| Per-module coverage detail | PASS | `p16-coverage-comparison.2026-10-30T01-41.md`, `p16-powershell-coverage.2026-10-30T01-29.xml`, the retained lcov reports |
| Test execution metrics | PASS | Python 15728 passed / 6 skipped / 0 failed in 661.48 s; Jest 5177 and 5194 passed; Pester 12744 tests / 10 skipped / 0 failed; test files at or below 500 logical lines |
| Code quality checks | PASS | all formatters, linters and type checkers clean on the remediated tree |

## Part B: code-review checklist

### Findings table

| Severity | File | Finding | Recommendation | Evidence |
| --- | --- | --- | --- | --- |
| Info | `extensions/drm-copilot/jest.config.cjs` | 531 logical lines after the ten user-directed per-file entries; between the 500 guidance tier and the 700 advisory tier | none; recorded by the plan's File-size decision | `other/p15-jest-thresholds.2026-10-30T00-17.md`, `p16-file-size.2026-10-30T01-55.md` |
| Info | `extensions/drm-copilot/resources/lib/discovery-validation/DiscoveryValidation.psm1` | a Phase 15 mirror step had copied the Claude-only compatibility module into the Codex shared library; removed in P15-T22 | none; the mirror script now skips it | `other/p15-mirror-parity.2026-10-30T00-23.md` |
| Info | `artifacts/pester/powershell-coverage.xml` | the shard runs overwrite the canonical file after the single-process run; the full-run copy was restored to the canonical path | none; the CI job shapes write separate artifacts | `p16-powershell-tests.2026-10-30T01-29.md` |
| Info | `extensions/drm-copilot/src/mcp-tools.ts`, `src/mcp-handlers/discovery-handlers.ts` | the sentinel dispatch case and handler body were uncovered after P15-T15; two focused tests added in P16-T4 | none; covered 100% of changed lines after the repair | `p16-coverage-comparison.2026-10-30T01-41.md` |
| Info | `policy-audit.2026-10-29T13-16.md`, `code-review.2026-10-29T13-16.md`, `remediation-inputs.2026-10-29T13-16.md` | the review documents cite line positions (`DiscoveryCapability.psm1 lines 82-101`, `protected_records.py:290-295`) and commit identifiers (`732bf84ec`, `9d017e305`) while the plan contract (G11, G12) requires symbol, heading or ref citations in plans | none for this cycle: the rule governs plan documents, the review artifacts are inputs, and every closing task cites symbols and headings | the sweep described in `Command:` |
| Info | `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/**` | thirteen seed memory files have no root counterpart (pre-existing) | none; carried from P10-T1 | `p16-generator-check.2026-10-30T01-55.md` |

No Blocker, Major, Minor or Warning findings. The findings of the independent review are closed as tabulated below.

### Review findings of 2026-10-29T13-16 (one row each)

| Finding | Severity | Closing task | Status | Evidence |
| --- | --- | --- | --- | --- |
| R1 TypeScript coverage artifact absent; ten files without per-file thresholds | Blocking | P15-T20, P16-T2, P16-T4 | PASS | `other/p15-jest-thresholds.2026-10-30T00-17.md`; `p16-typescript-{root,extension}-lcov.2026-10-30T01-40.info` and `-coverage-summary.2026-10-30T01-40.json`; `p16-coverage-comparison.2026-10-30T01-41.md` (50 TypeScript files, 0 failures) |
| R2 Evidence-location validator exits nonzero | Blocking | P15-T2, P16-T8 | PASS | `qa-gates/p15-evidence-locations.2026-10-29T17-54.md`; `p16-evidence-locations.2026-10-30T01-55.md` (exit 0) |
| R3 Capability probe attests from its own synthetic environment | Blocking | P15-T10, P15-T11, P16-T7 | PASS | `p15t10-verification.2026-10-29T22-18.md` (`Get-DiscoverySentinelEnvironment` removed; status derived from recorded observations), `p15t11-verification.2026-10-29T22-23.md`; `discovery-host-observations.2026-10-30T01-47.md` |
| R4 No production supplier of the trusted agent identity | Blocking (human decision) | P15-T3 to P15-T9, P15-T12 to P15-T16, P15-T23 (decision: identity from the host hook payload only) | PASS | Set P and Set Q suites in the Phase 16 populations; `p15t7-verification.2026-10-29T21-50.md`, `p15t8-verification.2026-10-29T21-52.md`, `other/p15-sentinel-agent.2026-10-29T21-57.md`, `p15t12-t15-verification.2026-10-29T23-17.md`, `p15t16-verification.2026-10-29T23-45.md`; `enforcement.md` `## Identity source`; requalified `handoff.md` and `completion-report.md` |
| Python re-admits a consumed grant and ignores `expires_at` | Major | P15-T16 | PASS | `p15t16-verification.2026-10-29T23-45.md` (`.used` latch, expiry refusal, replay test) |
| `after == before` compares one object with itself | Minor | P15-T19 | PASS | `regression-testing/p15-isolation-assertion.2026-10-30T00-14.md` (probe fails on the mutated registry) |
| Identity-refusal finding not asserted per row | Minor | P15-T16 | PASS | `p15t16-verification.2026-10-29T23-45.md` (`test_gateway_host_main.py` rows assert the message) |
| Partial `powershell-coverage.xml` | Minor | P16-T3 | PASS | `p16-powershell-tests.2026-10-30T01-29.md` (canonical file equals the full-run copy, 93.34%) |
| Resolved read target not re-checked against `selected_paths` | Minor | P15-T17 | PASS | `p15t17-verification.2026-10-29T23-56.md` |
| Stale status lines | Minor | P15-T23, P16-T9 | PASS | `spec.md` and `user-story.md` status and `Last Updated 2026-10-30T01-58` |
| Shared-fixture bullet wording | Minor | P15-T21 | PASS | `other/p15-brief-wording.2026-10-30T00-19.md` (six identical SHA-256) |
| `handoff.md` and `completion-report.md` host-observation claims | Minor (R4 qualification) | P15-T23, P16-T7 | PASS | both documents state harness-simulated host events and point to `discovery-host-observations.2026-10-30T01-47.md`; `## Built artifacts` records updated only by the P16-T6 rebuild |
| Catalog cache (user-directed) | n/a | P15-T18, P15-T19 | PASS | `other/p15-registry-cache-timing.2026-10-30T00-11.md` (304.69 s → 156.30 s, identical bytes share one registry, extension content does not) |

### Implementation audit

| Row | Status | Evidence |
| --- | --- | --- |
| Python: what changed well, typing and API, error handling | PASS | `decode_authorization` gains `now` and `used_latch_present` with distinct refusals; `HostServiceIO` creates the `.used` latch exclusively and counts the service's two authorize calls as one dispatch; `select_reads` refuses link observations and out-of-selection targets; the public API (`registry()`, `schema`, `load_catalog`, `utc_now`) is extended without breaking callers |
| TypeScript: type safety, maintainability, error handling | PASS | strict exports, no suppressions added, `exactOptionalPropertyTypes` respected; the provider carries no identity; `admitControlledToolCall` branches on `invocation_ref` presence; refusals carry their code in the message |
| PowerShell: API and safety, error handling | PASS | advanced functions, exclusive writes for root grants and observations, fail-closed gate, observational start; `Get-DiscoveryHostRegistration` reads the documented Copilot shape |
| C# | N/A | no C# additions on the branch (conditional applicability recorded) |

### Test quality audit

| Row | Status | Evidence |
| --- | --- | --- |
| Reviewed test and QA artifacts | PASS | the 12 Phase 15 Python modules, the 25 Phase 15 Pester suites, the Phase 15 TypeScript suites and `test/mcp-tools.discovery.test.ts` (P16-T4); evidence under `evidence/qa-gates`, `evidence/regression-testing`, `evidence/other`, `evidence/remediation-baseline` |
| Determinism, isolation, speed, diagnostics | PASS | sections 1.1 and 1.3 above |

### Security and correctness checks

| Row | Status | Evidence |
| --- | --- | --- |
| No secrets in code | PASS | no credential literal; no identity in environment variables |
| No unsafe subprocess or command construction | PASS | the only process seam is `gateway_local.run_local_git` (`shutil.which`, fixed argv, no shell, pre-authorized `S603`); hooks invoke no external process |
| Input validation at boundaries | PASS | bounded JSON parsing, relative-path policy with link refusal, fixed outer option tables with fixed refusal strings; protected records validated through the catalog before any field is read; request JSON selects only which partition is checked, never a value used afterwards |
| Error handling remains explicit | PASS | typed findings; broad handlers only at entry points with the pre-authorized form |
| Configuration and path handling is safe | PASS | canonical workspace checks, protected store outside the workspace, no absolute paths in artifacts (`SCRATCH` token; the P16-T3 retained XML and JSON files are made repository-relative and redacted) |
| Research log | PASS | `research/2026-10-29T13-16-host-identity-sources-research.md` is the cycle's research record; its `### 6.1 Identity source per host` table is reproduced in `enforcement.md` |

## Part C: feature-audit checklist

| Row | Status | Evidence |
| --- | --- | --- |
| Work mode resolved from `issue.md` | PASS | `- Work Mode: full-feature`; AC sources `spec.md` and `user-story.md` (66 items each) |
| AC inventory preserved verbatim | PASS | both files carry the 66 criteria unchanged; 65 checked in each after P16-T9 |
| Requirements and AC traceability | PASS | `requirements-traceability.md` (Phase 15 and 16 entry), `acceptance-criteria-status.2026-10-30T01-58.md`, the plan's coverage table |
| Source-authority separation | PASS | the Python runtime is the only authority for service rules; TypeScript and PowerShell adapters hold no business rule; identity is carried by protected records, not by request JSON |
| Installed proof | PASS | rebuilt wheel installed and verified (`discovery-installed-runtime.2026-10-30T01-47.md`: 31 console entries, 36 schemas, shared registry); the host observation table records that no host was driven in this cycle and cites the fixture suites (`discovery-host-observations.2026-10-30T01-47.md`); no record claims real-host coverage from a launcher that exported identity |
| Native grants | PASS | one-use root grants and tool authorizations consumed by tool, operation and digest or by `invocation_ref` and digest; replay refused in TypeScript (`AUTHORIZATION_CONSUMED`) and in Python ("already dispatched by the runtime") |
| All existing asserting tests | PASS | every behavior change named its asserting tests (Sets A to R); the complete populations pass on the remediated tree |
| Evidence completeness | PASS | every accepted Phase 15 and 16 task has a canonical artifact with the required fields under `evidence/<kind>/`; the evidence-location validator exits 0; no artifact names a host path |
| Architecture | PASS | `p16-architecture-boundaries.2026-10-30T01-55.md` |
| File size | PASS | see the "At or below the 800-line hard limit" row |
| Isolation | PASS | `regression-testing/p16-isolation.2026-10-30T01-45.md` |
| Coverage | PASS | 85/75 floors everywhere; the comparison above |
| Identity source (Phase 15) | PASS | payload-only identity with fail-closed unbound calls, documented in `enforcement.md` `## Identity source`; `DRM_DISCOVERY_*` has no read site in hooks, modules, clients or `docs/engineering` |
| Capability probe (Phase 15) | PASS | status derived from recorded observations only; `unsupported` without them; per-host support table in `enforcement.md` `## Capability probe` |
| Catalog cache (Phase 15) | PASS | content-keyed, library check before every cache hit, isolation assertion able to fail |
| Mirrors and brief (Phase 15) | PASS | 46 byte-identical pairs; six identical brief copies; the npm prepack copies carry the P15-T21 SHA-256 (`discovery-host-packages.2026-10-30T01-47.md`) |
| Cycle-document sweep | PASS | no host path, `AppData` or `/tmp/` token in the plan's Phase 15 and 16 text or in the four cycle documents; the only match of the case-insensitive `DanMoisan` grep is the package name `@danmoisan/drm-copilot-mcp`; the review documents' line-position and commit-identifier citations are recorded as Info above |

### Acceptance-criteria evaluation (66 criteria of `spec.md`; `user-story.md` carries the same text)

| Category | Criteria | Status | Evidence |
| --- | --- | --- | --- |
| Core framework (4) | framework exists; no TaskMaster/TMW in core; profile-loaded configuration; non-discovery repositories unaffected | PASS | package and contracts; `p16-source-neutrality.2026-10-30T01-55.md`; inactive-workspace allow paths |
| Agents and skills (5) | agents; skills; authorized writes only; SubagentStop validator per agent; assets across ecosystems | PASS | publication contracts; the payload-attributed tool gate and its denials (AC-07 re-evaluated in `acceptance-criteria-status.2026-10-30T01-58.md`); stop validators and their suites |
| Schemas and artifacts (5) | all checked | PASS | `tests/schemas` with the two new kinds; validation results unchanged by the cache |
| Initialization (5) | all checked | PASS | P3 evidence; installed `init` |
| Validation and reporting (5) | individual and complete validators; nonzero exits; reports; completion checks | PASS | console smoke exits; reports written |
| Hooks (6) | evidence, unknown records, runtime evidence, disposition, dimensions, planning gate | PASS | completion rules and planning gate hook |
| Analyzers (6) | all checked | PASS | P4 evidence |
| CLI, extension and MCP (6) | Python authoritative; CLI; MCP; VS Code; thin wrappers; path safety | PASS | installed console sweep (31 entries), MCP tools including the sentinel, commands, path-policy and read re-check suites |
| Cross-ecosystem publishing (5) | Claude, Codex, Copilot; conversion validation; no unsupported references | PASS | `p16-generator-check`, `p16-mirror-and-publication-contracts`, `p16-packaging-closure` |
| Acceptance scenarios (5) | all checked | PASS | P5 evidence |
| Documentation (6) | architecture; setup; semantics; placement; workflow; case study only | PASS | documentation contracts (32 passed after P15-T23) |
| Quality (8) | Python, TypeScript, PowerShell gates; C# for C# additions; all tests pass; feature review reports no blocking defects; canonical evidence; current docs and generated outputs | PASS, PASS, PASS, N/A (no C# additions), PASS, N/A (independent re-review pending; this self-review reports no blocking finding and does not substitute for it), PASS, PASS | records above |
| Definition of Done (7) | AC mapped; behavior in all documented environments; tests; edge cases; docs; telemetry; toolchain | PASS except telemetry N/A (no telemetry surface) | records above |
| Seeded test conditions (12) | schema through publishing; quality loops and final review | PASS for the eleven implementation conditions; the final full feature review is pending with the independent re-review (N/A for this self-review) | P2 to P16 evidence |

## Gaps and escalation

None. No FAIL row remains. The independent re-review (AC-64) and exact-head CI are the orchestrator's continuation and are not claimed here. No planned test was removed or skipped; the 6 Python and 10 Pester skips are pre-existing environment-conditional cases. The only cycle item the executor could not perform is a live host observation, which requires a non-isolated delegation by the orchestrator; the record states that and gives the instructions.

## Verdict

PASS. The self-review has zero FAIL rows and no unverified blocking row on the remediated tree, and every review-finding row cites existing evidence.
