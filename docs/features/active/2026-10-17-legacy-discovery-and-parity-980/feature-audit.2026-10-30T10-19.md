# Feature Audit: legacy discovery and parity (#980), review cycle 1

---

**Audit Date:** 2026-10-30
**Feature Folder:** `docs/features/active/2026-10-17-legacy-discovery-and-parity-980`
**Base Branch:** `main`
**Head Branch:** `feature/legacy-discovery-and-parity-980`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 1 (prior audit `feature-audit.2026-10-29T13-16.md`)

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` now at `318ef3e934a13984bbd50ef29fd2b714aa98168b`; the branch has not been rebased since the prior review)
- **Head branch/commit:** `feature/legacy-discovery-and-parity-980` (commit `7d9191e9d7ff3084bc8ffc828d21fe402de1af22`)
- **Merge base:** `52587a0eeaa04a0519801452235608a72b5eba5c`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-30 10:18:57 UTC for head `7d9191e9d`; the summary budget truncated it after the context-file list at line 1244, so the diff inventory was taken from `git diff --name-status` against the merge base)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/**` (Phase 15 and 16 records under `qa-gates/`, `regression-testing/`, `other/`, `remediation-baseline/`)
  - Additional evidence: `artifacts/python/lcov.info`, `coverage/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, `artifacts/pester/powershell-coverage.xml`, source inspection of every Phase 15 module, and the companion `policy-audit.2026-10-30T10-19.md` and `code-review.2026-10-30T10-19.md`
- **Feature folder used:** `docs/features/active/2026-10-17-legacy-discovery-and-parity-980`
- **Requirements source:** `spec.md` and `user-story.md` (`## Acceptance Criteria`, 66 criteria each, identical text)
- **Work mode resolution note:** `issue.md` line 10 states `- Work Mode: full-feature`.
- **Scope note:** The audit covers the full branch diff. The executor's P16-T9 reconciliation and P16-T10 self-review were read as claims. The Evidence column names what this review verified itself; rows resting on executor evidence alone say so. The recorded user decisions (payload identity, root grants for read-only root calls, `unsupported` for hosts that cannot supply identity) are treated as the design to verify against, not re-opened.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md`: primary source (`## Acceptance Criteria`)
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/user-story.md`: primary source, identical text

### Acceptance criteria

Core framework
1. A reusable legacy discovery and parity framework exists in `drm-copilot`.
2. Core content contains no TaskMaster- or TMW-specific behavior.
3. Configuration is loaded from a local domain profile.
4. Repositories not using discovery remain unaffected.

Agents and skills
5. All required generic agents are implemented and validated.
6. All required generic skills are implemented and validated.
7. Agents cannot write outside authorized paths.
8. Every new agent has a SubagentStop output validator.
9. Agent and skill assets are available across supported ecosystems.

Schemas and artifacts
10. All required schemas exist and are versioned.
11. Valid examples pass validation.
12. Invalid examples fail with actionable messages.
13. Cross-artifact references are validated.
14. Extensions cannot bypass core required fields.

Initialization
15. A deterministic command initializes a consumer discovery workspace.
16. Initialization is idempotent.
17. Dry-run is supported.
18. Existing files are not silently overwritten.
19. The initialized workspace validates successfully.

Validation and reporting
20. Individual artifact validators exist.
21. A complete validation command exists.
22. Blocking failures return nonzero exit codes.
23. Markdown and JSON reports are generated.
24. Completion checks coverage, evidence, unresolved behavior, acceptance scenarios, and configured platform dimensions.

Hooks
25. Verified claims require evidence.
26. Unknown behavior requires an unresolved-behavior record.
27. Passed runtime scenarios require runtime evidence.
28. Completion fails for in-scope components without disposition.
29. Required platform dimensions cannot remain unspecified.
30. Implementation planning can be gated on discovery completion.

Analyzers
31. A generic repository/project inventory analyzer exists.
32. At least one meaningful C#/.NET analyzer exists.
33. Output is deterministic and machine-readable.
34. Findings include source references.
35. Facts are distinguished from inference.
36. Analyzer fixtures and tests exist.

CLI, extension, and MCP
37. Python is the authoritative implementation layer.
38. CLI commands are documented and tested.
39. MCP exposes appropriate discovery functions.
40. VS Code commands/wrappers are added where justified.
41. Wrappers do not duplicate business logic.
42. Workspace path safety is enforced.

Cross-ecosystem publishing
43. Canonical assets publish correctly to Claude Code.
44. Canonical assets publish correctly to Codex.
45. Canonical assets publish correctly to GitHub Copilot.
46. Publishing/conversion validation covers the assets.
47. Generated outputs contain no unsupported references.

Acceptance scenarios
48. Confirmed contracts generate linked acceptance scenarios.
49. Platform-mode tags are supported.
50. Offline/mobile tags are supported when configured.
51. Unresolved behavior does not become a false expected result.
52. Scenarios preserve contract and decision traceability.

Documentation
53. Architecture and ownership boundaries are documented.
54. A consumer setup guide exists.
55. Schema/status semantics are documented.
56. Extension-versus-local placement is documented.
57. A source/target repository workflow is documented.
58. TaskMaster/TMW appear only in a separated example/case study.

Quality
59. Applicable Python quality gates pass.
60. Applicable TypeScript quality gates pass.
61. Applicable PowerShell quality gates pass.
62. Applicable C# quality gates pass for any C# additions.
63. All tests pass.
64. Feature review reports no blocking defects.
65. Evidence is stored in canonical feature evidence locations.
66. Documentation and generated customization outputs are current.

---

## Acceptance Criteria Evaluation

`AC-MAP` below means `evidence/qa-gates/acceptance-criteria-status.2026-10-26T02-57.md`, `acceptance-criteria-status.2026-10-29T12-51.md` and the P16-T9 re-reconciliation recorded in `requirements-traceability.md`. Rows whose evaluation is unchanged from the prior audit and whose evidence was not touched by Phases 15 and 16 cite the prior audit's verification; rows touched by the remediation were re-verified by this review.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | A reusable legacy discovery and parity framework exists in `drm-copilot`. | PASS | `packages/discovery-runtime/` (185 production files), `schemas/discovery/v2/` (29 files), agents, skills, hooks on all three host surfaces | `git diff --name-status 52587a0ee HEAD` | Verified by inventory. The framework exists; its specialist path is inoperable until the code-review Blocker (sentinel consumption contract) is fixed, which this audit records under criterion 64. |
| 2 | Core content contains no TaskMaster- or TMW-specific behavior. | PASS | No match in core trees; `evidence/qa-gates/p16-source-neutrality.2026-10-30T01-55.md` | Prior audit grep; executor record | Unchanged since the prior audit. |
| 3 | Configuration is loaded from a local domain profile. | PASS | `domain_profile.py`, `profile_v2.py`; `HostServiceIO._binding` selects the active profile from the activation store (`gateway_host.py:203-220`) | Source inspection | |
| 4 | Repositories not using discovery remain unaffected. | PASS | Inactive workspaces: the gate allows every tool for a root envelope that is not a grantable discovery call (`DiscoveryAuthorization.psm1:278-280`) and for non-discovery agents (`:375`); `enforcement.md` "Inactive compatibility" | Source inspection | Re-verified after the payload-identity change. |
| 5 | All required generic agents are implemented and validated. | PASS | Four specialist agents plus `discovery-capability-sentinel` on `.claude/agents`, `.codex/agents`, `.github/agents`; `tests/scripts/dev_tools/test_discovery_agent_contracts.py` | AC-MAP; mirror parity (147/147 identical) | Executor evidence for the contract tests. |
| 6 | All required generic skills are implemented and validated. | PASS | Seventeen skill folders in `.claude/skills`, `.github/skills`, `.agents/skills` | AC-MAP | Executor evidence. |
| 7 | Agents cannot write outside authorized paths. | PASS | Identity comes from the hook payload (`DiscoveryPayload.psm1:224-268`); a specialist's generic mutation and shell tools are denied (`DiscoveryAuthorization.psm1:378-385`); controlled writes carry one WriteGrant per required output (`gateway_host.py:383-390`); a bound request without a consumed record is refused, never run as `local-user` (`repo-automation-service-discovery-identity.ts:60-65`); no `DRM_DISCOVERY_*` read site remains | Source inspection; `grep -rn DRM_DISCOVERY_ .claude .codex .github .agents extensions/drm-copilot/src packages scripts docs/engineering` (no output) | Prior PARTIAL resolved. |
| 8 | Every new agent has a SubagentStop output validator. | PASS | `.claude/hooks/validate-discovery-artifact-gate.ps1`, `.codex/hooks/validate-discovery-agent-output.ps1`, `.github/hooks/discovery-agent-stop.ps1`; `DiscoveryStop.psm1` attributes from the payload and blocks a specialist stop without an identifier (`IDENTITY`) or without a receipt | Source inspection; AC-MAP | The sentinel agent is observed, not validated, by design: it produces no output. |
| 9 | Agent and skill assets are available across supported ecosystems. | PASS | 147 branch-changed customization files compared by exact path with their bundled mirrors, 0 differences | `python -I <scratchpad>/mirror.py . 52587a0ee` | Verified. |
| 10 | All required schemas exist and are versioned. | PASS | 29 files under `schemas/discovery/v2/` including the new `host-observation` and `root-grant`; `SchemaCatalog.__post_init__` requires the complete set (`catalog.py:354-367`) | Source inspection | |
| 11 | Valid examples pass validation. | PASS | `examples/discovery/v2/` including `host-observation.example.yaml`, `root-grant.example.yaml`; `tests/schemas/discovery/test_v2_grant_schemas.py` | AC-MAP | Executor evidence. |
| 12 | Invalid examples fail with actionable messages. | PASS | `tests/fixtures/discovery_schemas/v2/{host-observation,root-grant}.invalid.yaml`; findings carry `next_action` | AC-MAP | |
| 13 | Cross-artifact references are validated. | PASS | `test_references.py`, `test_reference_uniqueness.py`, `test_references_reports.py` | AC-MAP | Unchanged. |
| 14 | Extensions cannot bypass core required fields. | PASS | `catalog.py:286-293` adds extension constraints only at the shared extension boundary of the plain copy | Source inspection | Re-verified after the cache change. |
| 15 | A deterministic command initializes a consumer discovery workspace. | PASS | `dev.discovery.init` → `drm_copilot_discovery.cli:main_init` (`pyproject.toml`) | Diff inspection | |
| 16 | Initialization is idempotent. | PASS | `test_initialization.py`, `test_initialization_conflicts.py` | AC-MAP | |
| 17 | Dry-run is supported. | PASS | `test_cli_dry_run.py` | AC-MAP | |
| 18 | Existing files are not silently overwritten. | PASS | `test_initialization_conflicts.py` | AC-MAP | |
| 19 | The initialized workspace validates successfully. | PASS | `test_public_*_workflow.py` | AC-MAP | |
| 20 | Individual artifact validators exist. | PASS | `dev.discovery.validate-*` entry points | Diff inspection | |
| 21 | A complete validation command exists. | PASS | `dev.discovery.validate-all` | Diff inspection | |
| 22 | Blocking failures return nonzero exit codes. | PASS | `OperationFailure(..., exit_code=3)`; `test_cli_errors.py`; refusal rows assert exit 2 with the refusing message (`test_gateway_host_main.py:284-288`) | Source inspection | |
| 23 | Markdown and JSON reports are generated. | PASS | `test_report_rendering.py`, `test_coverage_report.py`, `test_parity_report.py`, `test_completion_report.py` | AC-MAP | |
| 24 | Completion checks coverage, evidence, unresolved behavior, acceptance scenarios, and configured platform dimensions. | PASS | `test_completion_rules.py`, `test_dimension_rules.py` | AC-MAP | |
| 25 | Verified claims require evidence. | PASS | `test_evidence_rules.py`, `test_observation_claims.py` | AC-MAP | |
| 26 | Unknown behavior requires an unresolved-behavior record. | PASS | `test_migration_unknowns.py`, `test_decision_rules.py` | AC-MAP | |
| 27 | Passed runtime scenarios require runtime evidence. | PASS | `test_runtime_claims.py` | AC-MAP | |
| 28 | Completion fails for in-scope components without disposition. | PASS | `test_coverage_rules.py` | AC-MAP | |
| 29 | Required platform dimensions cannot remain unspecified. | PASS | `test_dimension_rules.py`, `test_profile_dimensions.py` | AC-MAP | |
| 30 | Implementation planning can be gated on discovery completion. | PASS | `.claude/hooks/enforce-discovery-planning-gate.ps1`, `DiscoveryPlanning.psm1` (now sharing `DiscoveryToolRouting.psm1`) | Source inspection | |
| 31 | A generic repository/project inventory analyzer exists. | PASS | `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/` | AC-MAP | |
| 32 | At least one meaningful C#/.NET analyzer exists. | PASS | `analyzer/dotnet_projects.py`, `dotnet_inventory.py`, `csharp_declarations.py` | AC-MAP | |
| 33 | Output is deterministic and machine-readable. | PASS | Schema-validated JSON outputs; ordering tests | AC-MAP | |
| 34 | Findings include source references. | PASS | `tests/discovery_runtime/analyzer/test_test_references.py` | AC-MAP | |
| 35 | Facts are distinguished from inference. | PASS | Observation-state fields; `test_observation_claims.py` | AC-MAP | |
| 36 | Analyzer fixtures and tests exist. | PASS | `tests/fixtures/discovery_analyzers/`, 36 analyzer test files | Diff inspection | |
| 37 | Python is the authoritative implementation layer. | PASS | TypeScript adapters forward to `python -m drm_copilot_discovery.gateway`; the Python host gateway enforces the dispatch latch and expiry itself (`gateway_host.py:270-302`) | Source inspection | Strengthened by the remediation. |
| 38 | CLI commands are documented and tested. | PASS | `docs/engineering/legacy-discovery-and-parity/cli-reference.md`; `test_cli_commands.py` | AC-MAP | |
| 39 | MCP exposes appropriate discovery functions. | PASS | `mcp-discovery-authority-tool-definitions.ts` including `discovery_capability_sentinel`; every controlled tool handler passes through `admitControlledToolCall` (`mcp-handlers/discovery-handlers.ts:62, 127`) | Source inspection | Exposure is complete; the sentinel-to-probe contract defect is recorded under criterion 64. |
| 40 | VS Code commands/wrappers are added where justified. | PASS | `discovery-command-registration.ts`; `extension.discovery-commands.test.ts` | AC-MAP | |
| 41 | Wrappers do not duplicate business logic. | PASS | TypeScript derives the operation and consumes grants; artifact semantics stay in Python | Source inspection | |
| 42 | Workspace path safety is enforced. | PASS | `relative-path` schema; `PathPolicy.resolve_read`; `gateway_host_reads.select_reads` re-checks the resolved target and refuses symlink and reparse observations; `test_gateway_host_reads.py`, `test_gateway_host_read_refusals.py` | Source inspection | Prior Minor (lexical check) resolved. |
| 43 | Canonical assets publish correctly to Claude Code. | PASS | Mirror parity 0 differences; `evidence/qa-gates/p16-mirror-and-publication-contracts.2026-10-30T01-55.md` | `python -I <scratchpad>/mirror.py . 52587a0ee` | |
| 44 | Canonical assets publish correctly to Codex. | PASS | Same; `.codex/agents/discovery-capability-sentinel.toml` mirrored | Same | |
| 45 | Canonical assets publish correctly to GitHub Copilot. | PASS | Same; `.github/hooks/discovery.json` in the documented version-1 shape (P15-T11) | Same | |
| 46 | Publishing/conversion validation covers the assets. | PASS | `tests/scripts/dev_tools/test_discovery_publication_contracts.py` (updated P16-T8); `p16-packaging-closure.2026-10-30T01-55.md` | AC-MAP | |
| 47 | Generated outputs contain no unsupported references. | PASS | `p16-repository-contracts.2026-10-30T01-55.md`, `p16-generator-check.2026-10-30T01-55.md` | AC-MAP | |
| 48 | Confirmed contracts generate linked acceptance scenarios. | PASS | `acceptance_generation.py`; `test_acceptance_generation.py` | AC-MAP | |
| 49 | Platform-mode tags are supported. | PASS | `test_acceptance_tags.py` | AC-MAP | |
| 50 | Offline/mobile tags are supported when configured. | PASS | `test_acceptance_tags.py`, `test_profile_dimensions.py` | AC-MAP | |
| 51 | Unresolved behavior does not become a false expected result. | PASS | `test_acceptance_rules.py`, `test_draft_scenarios.py` | AC-MAP | |
| 52 | Scenarios preserve contract and decision traceability. | PASS | `test_acceptance_decisions.py` | AC-MAP | |
| 53 | Architecture and ownership boundaries are documented. | PASS | `docs/engineering/legacy-discovery-and-parity/architecture.md` (updated P15-T23) | File inspection | |
| 54 | A consumer setup guide exists. | PASS | `consumer-onboarding.md`; `handoff.md` per-repository steps | File inspection | |
| 55 | Schema/status semantics are documented. | PASS | `artifacts-and-schemas.md` | File inspection | |
| 56 | Extension-versus-local placement is documented. | PASS | `architecture.md`, `maintainer-guide.md` | AC-MAP | |
| 57 | A source/target repository workflow is documented. | PASS | `workflow.md`, `running-the-workflow.md` | File inspection | |
| 58 | TaskMaster/TMW appear only in a separated example/case study. | PASS | `examples/taskmaster-tmw.md`; `p16-source-neutrality.2026-10-30T01-55.md` | Executor record | |
| 59 | Applicable Python quality gates pass. | PASS | Black, Ruff, Pyright clean; 15728 passed; `artifacts/python/lcov.info` 96.69% lines / 93.59% branches, all 185 changed production files at or above 90.00% lines | `python -I <scratchpad>/cov.py lcov artifacts/python/lcov.info …` | Coverage verified by this review. |
| 60 | Applicable TypeScript quality gates pass. | PASS | Format, lint, types, tests and builds green (`p16-typescript-*.2026-10-30T01-40.md`); `coverage/lcov.info` 98.20% / 93.37%, `extensions/drm-copilot/coverage/lcov.info` 97.04% / 93.64%; 47 executable changed files all at or above 92.86% lines and 77.78% branches; ten per-file thresholds added; no production exclude | `python -I <scratchpad>/cov.py lcov …` on both artifacts; `git diff 52587a0ee HEAD -- extensions/drm-copilot/jest.config.cjs` | Prior PARTIAL resolved. |
| 61 | Applicable PowerShell quality gates pass. | PASS | Format and analyzer clean; 12744 tests, 0 failed; canonical `artifacts/pester/powershell-coverage.xml` is a full run at 93.34%, every changed production file at or above 92.82% | `python -I <scratchpad>/cov.py jacoco artifacts/pester/powershell-coverage.xml …` | Prior Minor (partial canonical artifact) resolved. |
| 62 | Applicable C# quality gates pass for any C# additions. | PASS | Zero `.cs` files on the branch | `git diff --name-only 52587a0ee HEAD` filtered to `.cs` | Satisfied vacuously. |
| 63 | All tests pass. | PASS | Python 15728/0 failed, TS 5194 + 5177/0 failed, Pester 12734/0 failed | Executor records `p16-*-tests` | Executor evidence; not re-run. |
| 64 | Feature review reports no blocking defects. | FAIL | `code-review.2026-10-30T10-19.md` reports 1 Blocker: the sentinel observation consumption contract differs between `discovery-sentinel.ts:272-278` (latch only) and `DiscoveryCapability.psm1:162` (record `state`), so the probe reports `unsupported` on every host and `prepare_discovery_agent` cannot be granted | Source inspection of both files and the fixture `DiscoveryGate.TestSupport.ps1:208` | Left unchecked. |
| 65 | Evidence is stored in canonical feature evidence locations. | PASS | `validate_evidence_locations.py --root .` exits 0; 0 tracked paths under `artifacts/` in the branch diff | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`; `git diff --name-only 52587a0ee HEAD -- artifacts/` | Prior PARTIAL resolved. |
| 66 | Documentation and generated customization outputs are current. | PASS | Mirror parity 0 differences; six execution-environment brief copies hash `372462e3…`; `spec.md:6-7` and `user-story.md:5-6` carry the Phase 16 status (`Last Updated 2026-10-30T01-58`); `enforcement.md` `## Identity source` documents the decided design | `sha256sum`; file inspection | Prior PARTIAL resolved. `enforcement.md` `## Capability probe` describes the intended consumption behaviour that the Blocker breaks; the fix should keep the text or amend it. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 65 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (64)

**Top gaps preventing PASS:**

1. The capability probe requires the sentinel observation record to carry `state: consumed`, but the sentinel tool records consumption only as a `.consumed` latch; the probe therefore cannot report `supported`, and no root grant for `prepare_discovery_agent` can be issued on any host (criterion 64; code-review Blocker).
2. No host has been driven end to end since the identity redesign (`evidence/qa-gates/discovery-host-observations.2026-10-30T01-47.md`); the fixture suites prove each side's logic against hand-authored records, which is how the gap above escaped. This is recorded as context, not as a separate failing criterion.

**Recommended follow-up verification steps:**

1. Align the sentinel consumption contract on one side (rewrite the record as `consumed`, or read the latch in the probe), refresh the bundled mirrors, add a cross-language contract test that feeds the probe the TypeScript consumer's real output, and re-run the TypeScript and PowerShell loops.
2. From an orchestrator session on Claude Code, delegate `discovery-capability-sentinel` once and call `run_discovery_doctor`, then record the probe status and observation field names in a new `discovery-host-observations.<timestamp>.md` per the launch instructions in the P16-T7 record.
3. Re-run this review.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

No source-file checkbox was changed by this review. All 65 PASS criteria were already checked by the executor (P16-T9 re-reconciliation), and this review's evaluation agrees with each of them, including the four criteria (7, 60, 65, 66) the prior review evaluated PARTIAL. Criterion 64, "Feature review reports no blocking defects.", is FAIL and stays unchecked in both files.

### AC Status Summary

- Source: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md`, `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/user-story.md`
- Total AC items: 66 per source
- Checked off (delivered): 65 per source (all 65 evaluated PASS by this review)
- Remaining (unchecked): 1 per source
- Items remaining: "Feature review reports no blocking defects."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md` | 66 | 65 | 1 | Checkbox-backed; no change made by this review |
| `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/user-story.md` | 66 | 65 | 1 | Checkbox-backed; no change made by this review |
