# Code Review: legacy discovery and parity (#980)

---

**Review Date:** 2026-10-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-17-legacy-discovery-and-parity-980`
**Feature Folder Selection Rule:** The only active feature folder whose suffix matches the branch issue number (980).
**Base Branch:** `main` (`origin/main` at `52587a0eeaa04a0519801452235608a72b5eba5c`, which is also the merge base)
**Head Branch:** `feature/legacy-discovery-and-parity-980` at `c88235db0dacf1c0da1e540bec6bf7de559a7120`
**Review Type:** Initial review

---

## Executive Summary

The branch adds a reusable legacy-discovery and parity capability: an installable Python runtime (`packages/discovery-runtime`, wheel 2.0.0) that owns every artifact rule, v2 JSON schemas, thin TypeScript and MCP wrappers in the extension, native hook adapters for Claude Code, Codex and GitHub Copilot with byte-identical bundled mirrors, four specialist agents with Codex deployment variants, seventeen skills, documentation and examples. Outside the feature folder the diff touches 1,064 paths. The review read the Phase 12 host-principal authority surface in Python and TypeScript, the Phase 14 schema-registry change, every test changed during final QA, the coverage artifacts, the file-size policy inputs, mirror parity, and the six copies of the execution-environment brief.

The Python authority surface is careful. Every protected record is schema-validated before any field is read, every binding compares against trusted outer values, every refusal raises the same exit-3 `SERVICE_AUTHORITY` failure, and no path turns a host request into a `local-user` authority. One-use consumption in TypeScript latches exclusively before it rewrites the record, and Python admits only a record that is both `consumed` and latched, so a failure between the two steps fails closed. The registry change is safe in production. The defects lie outside that core: the identity on which every native control depends has no production supplier, the capability probe cannot detect this, and the TypeScript coverage evidence was not retained.

**What changed:**
Python: `gateway_host.py`, `gateway_host_baseline.py`, `gateway_host_store.py`, `protected_records.py`, `operation_grants.py`, `service.py`, `service_finalization.py` and the request rules implement the `--principal host` path; `catalog.py` now builds the referencing registry once in `__post_init__`. TypeScript: `discovery-authorization.ts`, `discovery-authorization-record.ts`, `mcp-discovery-authorization-gate.ts`, `discovery-authority-provider.ts`, `repo-automation-service-discovery*.ts` and `discovery-runtime.ts` prepare invocations, consume grants and transport the host identity. PowerShell: `DiscoveryAuthorization.psm1`, `DiscoveryStart.psm1`, `DiscoveryStop.psm1`, `DiscoveryCapability.psm1` and per-host hook entry points.

**Top 3 risks:**
1. On an unmodified host no component sets `DRM_DISCOVERY_*`. The tool gate then allows every call, the start hook denies every specialist start, and `prepare_discovery_agent` refuses. Specialist enforcement is therefore either inert or unusable, depending on whether the host honours the start denial. The P12-T12 proof supplied the values from SCRATCH launchers.
2. The capability probe reports `trusted_attribution: true` from an environment table it builds itself. It can therefore report `supported` on a host where the gate never attributes a specialist.
3. TypeScript coverage cannot be verified from a retained artifact, and 10 changed executable TypeScript files have no per-file threshold.

**PR readiness recommendation:** **Needs Revision**. Three autonomous blockers and one blocker that needs a user design decision remain (see the Findings Table).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1` (and `.codex`, `.github` adapters, `extensions/drm-copilot/src/discovery-authority-provider.ts`, `mcp-discovery-authorization-gate.ts`) | `DiscoveryAuthorization.psm1:385-389`; `discovery-authority-provider.ts:118-130`; `mcp-discovery-authorization-gate.ts:132-135`; `repo-automation-service-discovery-identity.ts:56-61` | The trusted host, session and agent identity is read only from `DRM_DISCOVERY_HOST`, `DRM_DISCOVERY_SESSION_ID`, `DRM_DISCOVERY_PARENT_*` and `DRM_DISCOVERY_AGENT_*` process environment values. No file in the repository sets them; a repository-wide search finds only readers, tests, the probe's synthetic table and the executor's memory note on the SCRATCH harness. Failure scenario on an unmodified host: the root's `prepare_discovery_agent` refuses with "Trusted host, session and parent agent identity are required."; the specialist's `SubagentStart` is denied `IDENTITY`; if the host still runs the specialist, its `PreToolUse` gate returns `allow` / `NOT_DISCOVERY_AGENT` for every tool, and its MCP calls without `invocation_ref` run as `local-user` in structural mode, with attribution `human` and no invocation-scoped grant. | Decide how a real host supplies the identity, for example by deriving the specialist identity from the hook envelope's agent fields and binding the MCP gate to a per-agent identity source, and record that decision in `enforcement.md`. Until then, qualify the `handoff.md` and `completion-report.md` statements that the chain was "observed on Claude Code, Codex and the Copilot Local harness" as harness-simulated events. | The specialist write controls, the stop receipt and the attribution of agent writes all depend on this input. The installed-host proof cannot show host behaviour, because the harness supplied the input itself. | `evidence/qa-gates/discovery-native-capabilities.2026-10-28T15-06.md` (Setup: synthetic sessions `smoke-*-p12`; Command line: `SCRATCH/issue-980-hook.sh … {root,agent}.env`); `.claude/agent-memory/atomic-executor/discovery-installed-smoke-harness.md:8`; `grep -rn DRM_DISCOVERY_ .claude .codex .github extensions/drm-copilot/src packages scripts` |
| Blocker | `.claude/lib/discovery-validation/DiscoveryCapability.psm1` (and mirrors) | lines 244-250 (`Get-DiscoveryCapabilityObservation`); lines 82-101 (`Get-DiscoverySentinelEnvironment`) | `trusted_attribution` and `forbidden_tools_denied` are computed by running the sentinel decision over an environment table the probe constructs (`DRM_DISCOVERY_AGENT_ID = "probe-…"`, `DRM_DISCOVERY_AGENT_ROLE = 'legacy-parity-analyst'`). The control is true whenever the module logic denies `Bash`, independent of whether the host places these values in its hook processes. Failure scenario: on a host that supplies no `DRM_DISCOVERY_*`, the probe reports `status: supported`, `doctor` reports `DISCOVERY_ENFORCEMENT_VERIFIED`, and the operator proceeds as the handoff instructs ("Proceed only on `supported`"), while the real gate allows every specialist tool call. | Bind `trusted_attribution` to evidence the host itself produces, for example the probing process's own host-supplied `DRM_DISCOVERY_HOST`/`SESSION_ID`, or a sentinel envelope delivered through the registered hook rather than evaluated in-process. Add a Pester case in which the probing process carries no host-supplied identity and the probe returns `unsupported`. | A capability control that cannot fail does not gate anything. The handoff makes `supported` the precondition for launching discovery roles. | Inspected source; `evidence/qa-gates/discovery-native-capabilities.2026-10-28T15-06.md` probe table |
| Blocker | `extensions/drm-copilot/coverage/lcov.info`; `coverage/lcov.info` | n/a | The canonical TypeScript coverage artifact `coverage/lcov.info` does not exist. `extensions/drm-copilot/coverage/lcov.info` is dated 2026-10-23T13:49Z, before every Phase 12 TypeScript change. The P14-T7 runs wrote json-summary output to unretained `SCRATCH/issue-980-p14-jest-{root,ext}` directories. 10 changed executable production files have no per-file threshold in `jest.config.cjs` or `jest.discovery-coverage.json` (`src/lib/codex-native-converter/{classifier-claude,classifier,inventory,mapping,pipeline-render,rewrites-rules,rewrites}.ts`, `src/lib/validate/{codex-topology-resolver,orchestrator-state-codex-model-routing}.ts`, `src/repo-automation-tool-names.ts`), so a passing Jest run proves nothing about their coverage. | Run `npm run test:unit:coverage` (root and extension) on the branch head, keep `lcov.info` at the canonical path, retain a per-file summary under `evidence/qa-gates/`, and verify all 47 changed TypeScript production files against 85% lines, 75% branches and no changed-line regression. | Coverage verification is mandatory for every language with changed files; the reviewer must not rerun coverage generation, and no retained artifact exists. | `ls coverage/lcov.info` (absent); `ls -la extensions/drm-copilot/coverage`; `evidence/qa-gates/p14-typescript-root-tests.2026-10-29T10-50.md` Command line |
| Blocker | `artifacts/coverage/issue-980-p7t3-coverage.json`, `artifacts/coverage/issue-980-p7t3-devtools-coverage.json` | n/a | `validate_evidence_locations.py --root .` exits 1 for these two files. They are gitignored, untracked and not in the branch diff; they are P7-T3 residue in this worktree. | Move any content still needed into `evidence/qa-gates/` and delete both files; re-run the validator to exit 0. | Evidence location policy treats every reported path as a failure. | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` |
| Major | `packages/discovery-runtime/src/drm_copilot_discovery/protected_records.py` | lines 290-295 (`decode_authorization`); `gateway_host.py:254-271` | Python admits a host request whenever the referenced grant is `consumed` with a latch, and it records nothing of its own use, nor does it check `expires_at`. One-use semantics therefore hold only because the TypeScript gateway client always consumes before it runs Python. Failure scenario: any process that can start `python -m drm_copilot_discovery.gateway --principal host` with the four identity options and a previously consumed `authorization_ref` is admitted again, indefinitely. Under the native gate such a process cannot be a specialist, because shell is denied. Given the identity-supplier blocker above, that gate is not a reliable second line. | Add a Python-side use latch (for example an exclusive `<ref>.json.used` marker created by the host composition before dispatch) or reject a grant whose `consumed_at` is older than a short window. Add a test that a second gateway call with the same grant refuses. | Defence in depth at the authority boundary; the Python layer is described as authoritative. | Inspected source |
| Minor | `tests/discovery_runtime/test_schema_validation.py` | `test_repeated_validations_through_one_catalog_are_independent`, `before`/`after` lines | `before` and `after` are both `catalog.registry().resolver().lookup(…).contents` on the shared registry, so they are the same dict object, and `after == before` cannot fail even if a validation mutated it. The docstring claims the registry "resolves unchanged schema contents afterwards". | Capture `before = copy.deepcopy(...)`, or compare against `catalog.schema(expected_kind="activation", expected_version="2.0.0")`, which returns an independent copy. Also assert that one registry object is returned across calls, to guard the once-per-catalog property. | The isolation test is the only proof of the sharing safety argument. The `shared == fresh` comparison does give real evidence, but only for one kind. | Inspected test; commit `a19da9f7e` |
| Minor | `tests/discovery_runtime/test_gateway_host_main.py` | lines 226-244 | The refusal matrix asserts only `code == 2` and that no repository resolution occurred. Moving the rows to an absolute root (commit `d6eb8d665`) was meant to make them reach the identity checks, but nothing proves they do: a regression that rejected the root again would still pass. | Assert the specific finding code or message of the identity refusal for each row. | A refusal test should identify which guard refused. | `git show d6eb8d665 -- tests/discovery_runtime/test_gateway_host_main.py` |
| Minor | `artifacts/pester/powershell-coverage.xml` | n/a | The canonical PowerShell coverage artifact reports 13638/21443 lines (63.60%), a partial run written at 2026-10-29T12:05Z. The retained full-run artifact reports 20003/21443 (93.28%). | Regenerate the canonical artifact from a full single-process run so automated readers see the correct figure. | Automated gates that read the canonical path would compute a false regression. | `evidence/qa-gates/p14-powershell-coverage.2026-10-29T12-14.xml` parsed by this review |
| Minor | `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host.py` | lines 312-327 (`_read_selection`) | The invocation-scope check is lexical (`path == root or path.startswith(root + "/")`). `PathPolicy.resolve_read` then checks only the configured input scope, so a symlink inside a selected path whose target lies outside the selected paths, but inside the configured input scope, passes both checks. Dot segments are already rejected by the `relative-path` schema. | Re-check the resolved target (`target.observations[-1]`) against `selected_paths`, or refuse symlinked components for host reads. | Invocation-scoped reads are narrower than workspace-configured reads by design. | Inspected source; `schemas/discovery/v2/common.schema.json:14-17` |
| Minor | `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md`, `user-story.md` | `spec.md:6-7`, `user-story.md:5-6` | The status lines still read "executor reconciliation complete with one escalated installed-host blocker" with `Last Updated 2026-10-26T02-54`. `completion-report.md` states both escalations are closed. | Update both status lines to the Phase 14 state. | The AC "Documentation and generated customization outputs are current." | Inspected files |
| Nit | `.claude/skills/execution-environment/SKILL.md` (and five byte-identical copies) | `## Test Runtime`, fourth bullet | "Share an expensive immutable fixture second, and give each test its own copy" reads as contradictory: a fixture that each test copies is not shared. | Reword, for example "Build an expensive immutable fixture once per session and hand each test its own copy where a test could mutate it." | Wording clarity in a brief that six surfaces inherit. | `sha256sum` of the six copies: all `82b744fa…` |
| Info | `extensions/drm-copilot/test/discovery-artifact-commands.test.ts`; `mcp-discovery-authority-tool-definitions.test.ts` | commit `c0975875e` | The two TypeScript tests updated for Phase 12 were strengthened. The first now asserts `--principal host` and all four identity options, and it adds a negative test that a process without a trusted identity is refused with `DISCOVERY_AGENT_IDENTITY_REQUIRED` and spawns nothing. The second makes `request_id` optional, matching the Phase 12 contract, and adds an assertion that it is still declared as a string. | None. | Confirms that no assertion was weakened. | `git show c0975875e` |
| Info | `tests/discovery_runtime/test_extension_inputs.py` | commit `69f35c239` | The parametrized test was split into a positive test and a negative test. The negative case now reaches the projection's own guard through a monkeypatched `repository_pins` seam, because `profile_v2` refuses that profile at construction; that refusal is asserted separately at `tests/discovery_runtime/test_profile_v2.py:272` (`PROFILE_BINDING`). | None. | Both guards remain tested; no assertion was removed. | `git show 69f35c239` |
| Info | `handoff.md`, `completion-report.md` | `## Built artifacts`; `## Backward compatibility and known limits` | The 1.1.22 extension and MCP package references are accurate historical evidence of the tested artifacts (user decision relayed 2026-10-29). Verified: the P14-T12 build (`732bf84ec`, 2026-10-29T12:28Z) recorded 1.1.22 from a tree that still carried it, and main's `9d017e305` (1.1.23, 09:48Z) entered the branch in a later rebase. `handoff.md` already requires a rebuild and re-digest from the merged head. | None. | Recorded for completeness; not a finding. | `git merge-base --is-ancestor 9d017e305 HEAD`; `evidence/other/discovery-host-packages.2026-10-29T12-26.md:9,14` |
| Info | `config/file-size-baseline.json` | whole file | The only change removes `scripts/dev_tools/agentic_sync.py: 819` (now 454 logical lines). The largest covered file on the branch is 500 logical lines; none is at or above 700. | None. | Tiered file-size policy satisfied. | Logical line counts over 696 covered files |

There are 4 Blocker findings: 3 are autonomous and 1 needs a human decision.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `protected_records.py` validates each record through the offline catalog with the exact kind and version before reading any field, and each binding failure names a distinct reason under the single `SERVICE_AUTHORITY` code.
- `HostServiceIO.authorize` refuses before any read when the mode, references, operation or workspace do not match (`gateway_host.py:345-356`). It resolves the grant only from an actual partition entry (`list_entries` membership, `gateway_host.py:257-259`) and never constructs a `local-user` authority. `writer()` refuses any authority for an invocation that the instance itself did not verify.
- `service._authority` keeps the two admission rules disjoint ("neither rule falls back to the other"). `finalize-agent` is refused for `local-user` both at admission and in `service_finalization.py:82`. `operation_grants.derive_grants` never expands a host grant set.
- The root-only `prepare-agent` route runs as `local-user`. It is refused for specialists at the native gate (`RootOnlyOperations`, `RootOnlyTools`), and the MCP layer refuses root-only tools for a trusted discovery role (`mcp-tools.ts:212-218`).
- `catalog.py` builds the registry once and verifies its full closure at construction. Sharing it is safe in production: `referencing.Registry` is immutable, and lookups and crawls return new objects. The resource contents are fresh plain dicts built inside `_registry`, and `schema()` returns its own independent copy from `to_plain_value`. The only consumer is `schema_validation.py:203`, which passes the registry to a fresh validator per call. Building the registry once also removes the per-call extension-schema mutation of a new dict (`catalog.py:211-217`). That code now runs once, against a dict private to the registry.

#### Typing and API notes

- Frozen keyword-only dataclasses carry the trusted values (`HostPrincipal`, `TrustedIdentity`, `WorkspaceBinding`). The `_shared_registry` field is excluded from init, comparison and repr. `cast` appears only on schema-validated JSON members.

#### Error handling and logging

- Every refusal raises `OperationFailure(…, exit_code=3)`, an unreadable record raises `OSError`, and `PermissionError` from a provider maps to `SERVICE_AUTHORITY` (`service.py:179-182`). No broad exception handler appears in the inspected modules.

### TypeScript implementation audit

#### What changed well

- `consume()` creates the `.consumed` latch exclusively before it rewrites the record, and maps a lost race to `AUTHORIZATION_CONSUMED` (`discovery-authorization.ts:423-462`). The staged rewrite is removed on publish failure.
- `consumeToolAuthorizationByBinding` filters in a fixed order (identity, workspace, tool/operation/input digest, live, validity window, uniqueness), and each refusal class is distinct, so a replay is never reported as a missing grant. A re-issued grant beside an expired one remains consumable.
- The MCP gate refuses a caller-supplied `authorization_ref` and an underivable operation, and it forwards only the consumed reference.

#### Type safety and maintainability

- Exported interfaces carry JSDoc. The inspected Phase 12 modules contain no new `any`, `@ts-ignore` or file-level `eslint-disable`. `jest.config.cjs` stays at 487 logical lines by moving discovery thresholds into `jest.discovery-coverage.json`.

#### Error handling and logging

- Refusals are typed `DiscoveryAuthorizationError` values with a code prefix, so the MCP summary names the class. `listEntries` treats only `ENOENT` as empty and reports any other failure.

### PowerShell implementation audit

#### What changed well

- `Get-DiscoveryPreToolDecision` evaluates in a documented order: envelope anomalies, attribution, role, tool family, root-only, caller identity fields, operation, workspace, activation, invocation and binding. It writes a one-use record only after all of them pass.
- The start decision denies nested specialists and ambiguous prepared invocations (`DiscoveryStart.psm1:285-311`).

#### API and safety notes

- Advanced functions with `CmdletBinding`, `OutputType` and `ValidateSet`. Store, clock, nonce and environment are injectable. The analyzer is clean.

#### Error handling and logging

- Dependency-load failures deny with the control prefix before the envelope is read. Only `DiscoveryAuthorization.psm1` and its mirrors reach 500 lines; the P13-T3 edit removed a comment line to return the file to that size.

---

## Test Quality Audit

The Python and PowerShell evidence was verified from artifacts. TypeScript evidence rests on executor records. The isolation runs (seeded Jest, reversed Python, three Pester seeds) are recorded under `evidence/regression-testing/p14-isolation*.2026-10-29T12-23.md`. A search of the new tests found no temporary files and no unmocked external processes.

### Reviewed test and QA artifacts

- `artifacts/python/lcov.info`: 96.70% lines (31988/33080) and 93.62% branches (11644/12438). 184 changed production files are present, none below 85% lines or 75% branches; the minimum is 90.24% (`rewrites.py`).
- `evidence/qa-gates/p14-powershell-coverage.2026-10-29T12-14.xml`: 93.28% lines (20003/21443). Every changed production PowerShell file is at or above 85%.
- `evidence/qa-gates/p14-coverage-comparison.2026-10-29T12-45.md`: Phase 12 population of 35 files. Its TypeScript inputs are SCRATCH summaries that are not retained.
- `evidence/qa-gates/discovery-native-capabilities.2026-10-28T15-06.md`: harness-driven host chain. It proves the module behaviour, not that an unmodified host supplies the identity.
- `evidence/other/p14-registry-timing.2026-10-29T12-45.md`: 327 registry builds and 348.58 s before the change, 1 build and 0.93 s after.

### Quality assessment prompts

- **Determinism:** Clocks, nonces, stores and process launch are injected; the process environment is restored in `finally`.
- **Isolation:** Each test targets one behaviour; the final-QA split of `test_extension_inputs.py` improved this.
- **Speed:** The full Python suite fell from 17965.16 s to 929.37 s after the registry correction.
- **Diagnostics:** Generally strong. Two refusal or isolation assertions need sharper failure identification (Minor findings above).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials in the inspected modules; protected records carry digests and references only. |
| No unsafe subprocess or command construction | ✅ PASS | The Python gateway is launched with an argument vector; tests patch `subprocess.Popen`. |
| Input validation at boundaries | ⚠️ PARTIAL | Schema validation precedes every field read. The trusted identity is taken from an environment input with no production supplier (Blocker). |
| Error handling remains explicit | ✅ PASS | Exit-3 refusals and typed TypeScript errors; latch-then-rewrite fails closed. |
| Configuration / path handling is safe | ⚠️ PARTIAL | `relative-path` rejects dot segments and absolute paths. The invocation-scope check for host reads is lexical (Minor). |
| One-use authorization | ⚠️ PARTIAL | Exclusive latch in TypeScript. Python re-admits a consumed grant on every call (Major). |
| No principal conversion | ⚠️ PARTIAL | Python never converts host to `local-user`, and a bound TypeScript request without a trusted agent identity is refused. A process without `DRM_DISCOVERY_*` is treated as root by the MCP gate, so on an unmodified host a specialist's unbound calls run as `local-user` (Blocker). |
| Root-only `prepare-agent` | ✅ PASS | Denied for specialists by the native gate and by the MCP root-only check whenever a discovery role is attributed. |

---

## Research Log

No external research was required. The review relied on repository source, git history and the feature evidence. One assumption is stated explicitly and was not verified: whether Claude Code, Codex or GitHub Copilot place custom `DRM_DISCOVERY_*` variables in hook or MCP server processes. Nothing in the repository configures them to do so.

---

## Verdict

The implementation quality of the Python and TypeScript authority code is high. It fails closed on each refusal class examined, consumes grants exactly once at the TypeScript layer, and never converts a host request into a `local-user` authority. The schema-registry correction is safe and well measured.

The branch is not ready for the normal PR flow. Three blockers can be resolved autonomously: retain the TypeScript coverage artifact and verify every changed TypeScript file, remove the two evidence-location residues, and make the capability probe's trusted-attribution control depend on host-supplied evidence. The fourth blocker needs a user decision: how an unmodified host supplies the trusted agent identity. Without it, the native discovery controls are either inert or unusable outside the test harness.
