# Feature Audit: legacy discovery and parity (#980)

---

**Audit Date:** 2026-10-29
**Feature Folder:** `docs/features/active/2026-10-17-legacy-discovery-and-parity-980`
**Base Branch:** `main`
**Head Branch:** `feature/legacy-discovery-and-parity-980`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `52587a0eeaa04a0519801452235608a72b5eba5c`, `origin/main`)
- **Head branch/commit:** `feature/legacy-discovery-and-parity-980` (commit `c88235db0dacf1c0da1e540bec6bf7de559a7120`)
- **Merge base:** `52587a0eeaa04a0519801452235608a72b5eba5c`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-29 13:04:05 UTC for head `c88235db0`; the summary budget truncated it after the context-file list, so the diff inventory was taken from `git diff --name-status` against the merge base)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/**`
  - Additional evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/p14-powershell-coverage.2026-10-29T12-14.xml`, source inspection of the Phase 12 and Phase 14 modules, and the companion `policy-audit.2026-10-29T13-16.md` and `code-review.2026-10-29T13-16.md`
- **Feature folder used:** `docs/features/active/2026-10-17-legacy-discovery-and-parity-980`
- **Requirements source:** `spec.md` and `user-story.md` (`## Acceptance Criteria`, 66 criteria each, identical text)
- **Work mode resolution note:** `issue.md` line 10 states `- Work Mode: full-feature`.
- **Scope note:** The audit covers the full branch diff. The executor's self-review (`evidence/qa-gates/self-review.2026-10-29T12-53.md`) and acceptance mapping (`evidence/qa-gates/acceptance-criteria-status.2026-10-29T12-51.md`) were read as claims. This review verified independently the items named in the Evidence column. Criteria marked PASS on executor evidence alone say so.

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

`AC-MAP` below means `evidence/qa-gates/acceptance-criteria-status.2026-10-26T02-57.md` together with `acceptance-criteria-status.2026-10-29T12-51.md`. Both artifacts exist and were read.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | A reusable legacy discovery and parity framework exists in `drm-copilot`. | PASS | `packages/discovery-runtime/` (182 source files), `schemas/discovery/v2/`, agents, skills, hooks in all three host surfaces | `git diff --name-status 52587a0ee HEAD` | Verified by inventory. |
| 2 | Core content contains no TaskMaster- or TMW-specific behavior. | PASS | No match in `packages/discovery-runtime/src`, `schemas/discovery`, `extensions/drm-copilot/src` or discovery skills | `grep -rn "TaskMaster\|TMW" packages/discovery-runtime/src schemas/discovery extensions/drm-copilot/src .claude/skills/*discovery*` | Verified; no output. |
| 3 | Configuration is loaded from a local domain profile. | PASS | `domain_profile.py`, `profile_v2.py`; `HostServiceIO._binding` selects the active profile from the activation store | Source inspection; AC-MAP | |
| 4 | Repositories not using discovery remain unaffected. | PASS | Inactive workspaces: every discovery hook allows with no output (`enforcement.md` "Inactive compatibility"); `Get-DiscoveryPreToolDecision` returns `NOT_DISCOVERY_AGENT` for non-discovery processes | Source inspection; AC-MAP | |
| 5 | All required generic agents are implemented and validated. | PASS | `.claude/agents/{legacy-parity-analyst,migration-coverage-reviewer,requirements-reconciler,runtime-characterization-analyst}.md`, Codex variants, Copilot `.agent.md` | AC-MAP; `tests/scripts/dev_tools/test_discovery_agent_contracts.py` | Executor evidence. |
| 6 | All required generic skills are implemented and validated. | PASS | Seventeen skill folders in `.claude/skills`, `.github/skills`, `.agents/skills` | AC-MAP; `tests/scripts/dev_tools/test_discovery_workflow_contracts.py` | Executor evidence. |
| 7 | Agents cannot write outside authorized paths. | PARTIAL | When `DRM_DISCOVERY_*` is present, the native gate denies shell and generic mutation and the Python host path writes only invocation grant rows (`operation_grants.py:76-86`). No production component supplies `DRM_DISCOVERY_*`, and the P12-T12 proof exported it from SCRATCH launchers. On an unmodified host the gate allows every call and unbound MCP calls run as `local-user` | `grep -rn DRM_DISCOVERY_ .claude .codex .github extensions/drm-copilot/src packages scripts`; source inspection of `DiscoveryAuthorization.psm1:385-389`, `mcp-discovery-authorization-gate.ts:132-135` | Code-review Blocker (identity supplier). Already checked in source files; see Check-Off section. |
| 8 | Every new agent has a SubagentStop output validator. | PASS | `.claude/hooks/validate-discovery-artifact-gate.ps1`, `.codex/hooks/validate-discovery-agent-output.ps1`, `.github/hooks/discovery-agent-stop.ps1`, registered for the four agents | AC-MAP; mirror parity check | Its operation on a real host depends on the same identity input as AC 7. |
| 9 | Agent and skill assets are available across supported ecosystems. | PASS | 109 discovery files compared with bundled mirrors, 0 differences | `python -I <scratchpad>/mirror.py .` | Verified. |
| 10 | All required schemas exist and are versioned. | PASS | 27 files under `schemas/discovery/v2/`; `SchemaCatalog.__post_init__` requires the complete fixed v1/v2 set | Source inspection `catalog.py:279-289` | |
| 11 | Valid examples pass validation. | PASS | `examples/discovery/v2/` (25 files); `tests/schemas/discovery/` | AC-MAP | Executor evidence. |
| 12 | Invalid examples fail with actionable messages. | PASS | `tests/fixtures/discovery_schemas/`; findings carry `next_action` (`protected_records.py:66-71`) | AC-MAP | |
| 13 | Cross-artifact references are validated. | PASS | `test_references.py`, `test_reference_uniqueness.py`, `test_references_reports.py` | AC-MAP | |
| 14 | Extensions cannot bypass core required fields. | PASS | `catalog.py:211-217` adds extension constraints only at the shared extension boundary; `test_extension_validation_limits.py` | Source inspection; AC-MAP | |
| 15 | A deterministic command initializes a consumer discovery workspace. | PASS | `dev.discovery.init` → `drm_copilot_discovery.cli:main_init` (`pyproject.toml`) | AC-MAP | |
| 16 | Initialization is idempotent. | PASS | `test_initialization.py`, `test_initialization_conflicts.py` | AC-MAP | |
| 17 | Dry-run is supported. | PASS | `test_cli_dry_run.py` | AC-MAP | |
| 18 | Existing files are not silently overwritten. | PASS | `test_initialization_conflicts.py` | AC-MAP | |
| 19 | The initialized workspace validates successfully. | PASS | `test_public_*_workflow.py` | AC-MAP | |
| 20 | Individual artifact validators exist. | PASS | `dev.discovery.validate-*` entry points (`pyproject.toml`) | Diff inspection | |
| 21 | A complete validation command exists. | PASS | `dev.discovery.validate-all` | Diff inspection | |
| 22 | Blocking failures return nonzero exit codes. | PASS | `OperationFailure(..., exit_code=3)`; `test_cli_errors.py` | Source inspection; AC-MAP | |
| 23 | Markdown and JSON reports are generated. | PASS | `test_report_rendering.py`, `test_coverage_report.py`, `test_parity_report.py`, `test_completion_report.py` | AC-MAP | |
| 24 | Completion checks coverage, evidence, unresolved behavior, acceptance scenarios, and configured platform dimensions. | PASS | `test_completion_rules.py`, `test_dimension_rules.py` | AC-MAP | |
| 25 | Verified claims require evidence. | PASS | `test_evidence_rules.py`, `test_observation_claims.py` | AC-MAP | |
| 26 | Unknown behavior requires an unresolved-behavior record. | PASS | `test_migration_unknowns.py`, `test_decision_rules.py` | AC-MAP | |
| 27 | Passed runtime scenarios require runtime evidence. | PASS | `test_runtime_claims.py` | AC-MAP | |
| 28 | Completion fails for in-scope components without disposition. | PASS | `test_coverage_rules.py` | AC-MAP | |
| 29 | Required platform dimensions cannot remain unspecified. | PASS | `test_dimension_rules.py`, `test_profile_dimensions.py` | AC-MAP | |
| 30 | Implementation planning can be gated on discovery completion. | PASS | `.claude/hooks/enforce-discovery-planning-gate.ps1`, `DiscoveryPlanning.psm1`; `enforcement.md` "The planning prerequisite" | AC-MAP | |
| 31 | A generic repository/project inventory analyzer exists. | PASS | `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/`; `tests/discovery_runtime/analyzer/` | AC-MAP | |
| 32 | At least one meaningful C#/.NET analyzer exists. | PASS | `analyzer/dotnet_projects.py`, `dotnet_inventory.py`, C# declaration tests | AC-MAP | |
| 33 | Output is deterministic and machine-readable. | PASS | JSON outputs validated by schemas; deterministic ordering tests | AC-MAP | |
| 34 | Findings include source references. | PASS | `tests/discovery_runtime/analyzer/test_test_references.py` | AC-MAP | |
| 35 | Facts are distinguished from inference. | PASS | Observation-state fields in schemas; `test_observation_claims.py` | AC-MAP | |
| 36 | Analyzer fixtures and tests exist. | PASS | `tests/fixtures/discovery_analyzers/` (10 files), 36 analyzer test files | Diff inspection | |
| 37 | Python is the authoritative implementation layer. | PASS | TypeScript adapters forward requests to `python -m drm_copilot_discovery.gateway`; all artifact rules live in the Python package | Source inspection | |
| 38 | CLI commands are documented and tested. | PASS | `docs/engineering/legacy-discovery-and-parity/cli-reference.md`; `test_cli_commands.py` | AC-MAP | |
| 39 | MCP exposes appropriate discovery functions. | PASS | `mcp-discovery-authority-tool-definitions.ts`; tests updated in `c0975875e` | Source inspection | |
| 40 | VS Code commands/wrappers are added where justified. | PASS | `discovery-command-registration.ts`; `extension.discovery-commands.test.ts` | AC-MAP | |
| 41 | Wrappers do not duplicate business logic. | PASS | The TypeScript layer assembles requests, consumes grants and transports identity; artifact semantics stay in Python | Source inspection | |
| 42 | Workspace path safety is enforced. | PASS | `relative-path` schema rejects absolute paths and dot segments; `PathPolicy.resolve_read`; `test_path_policy.py`, `test_path_resolution.py` | Source inspection | Code review notes a Minor gap in invocation-scoped host reads (symlinks). |
| 43 | Canonical assets publish correctly to Claude Code. | PASS | Mirror parity 0 differences; `evidence/qa-gates/p14-mirror-and-publication-contracts.2026-10-29T12-49.md` | `python -I <scratchpad>/mirror.py .` | |
| 44 | Canonical assets publish correctly to Codex. | PASS | Same; Codex agent variants under `.codex/agents/` | Same | |
| 45 | Canonical assets publish correctly to GitHub Copilot. | PASS | Same; `.github/hooks/discovery.json` and hook scripts | Same | |
| 46 | Publishing/conversion validation covers the assets. | PASS | `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`; converter fixtures | AC-MAP | |
| 47 | Generated outputs contain no unsupported references. | PASS | `p14-repository-contracts.2026-10-29T12-49.md` (zero drift) | AC-MAP | |
| 48 | Confirmed contracts generate linked acceptance scenarios. | PASS | `acceptance_generation.py`; `test_acceptance_generation.py` | AC-MAP | |
| 49 | Platform-mode tags are supported. | PASS | `test_acceptance_tags.py` | AC-MAP | |
| 50 | Offline/mobile tags are supported when configured. | PASS | `test_acceptance_tags.py`, `test_profile_dimensions.py` | AC-MAP | |
| 51 | Unresolved behavior does not become a false expected result. | PASS | `test_acceptance_rules.py`, `test_draft_scenarios.py` | AC-MAP | |
| 52 | Scenarios preserve contract and decision traceability. | PASS | `test_acceptance_decisions.py` | AC-MAP | |
| 53 | Architecture and ownership boundaries are documented. | PASS | `docs/engineering/legacy-discovery-and-parity/architecture.md` | File inspection | |
| 54 | A consumer setup guide exists. | PASS | `consumer-onboarding.md`; `handoff.md` per-repository steps | File inspection | |
| 55 | Schema/status semantics are documented. | PASS | `artifacts-and-schemas.md` | File inspection | |
| 56 | Extension-versus-local placement is documented. | PASS | `architecture.md`, `maintainer-guide.md` | AC-MAP | |
| 57 | A source/target repository workflow is documented. | PASS | `workflow.md`, `running-the-workflow.md` | File inspection | |
| 58 | TaskMaster/TMW appear only in a separated example/case study. | PASS | `docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md` and `handoff.md`; criterion 2 search found no core occurrence | grep as in row 2 | |
| 59 | Applicable Python quality gates pass. | PASS | Black, Ruff, Pyright clean; 15668 passed; `artifacts/python/lcov.info` 96.70% lines / 93.62% branches, all 184 changed production files at or above 90.24% lines | `python -I <scratchpad>/lcov.py artifacts/python/lcov.info …` | Coverage verified by this review. |
| 60 | Applicable TypeScript quality gates pass. | PARTIAL | Format, lint, types, tests and builds green per `p14-typescript-*.2026-10-29T10-50.md`. The canonical coverage artifact is absent, the extension `lcov.info` predates Phase 12, and 10 changed executable files have no per-file threshold | `ls coverage/lcov.info extensions/drm-copilot/coverage/lcov.info` | Code-review Blocker. Already checked in source files. |
| 61 | Applicable PowerShell quality gates pass. | PASS | Format and analyzer clean; 12615 tests, 0 failed; retained full-run coverage 93.28% lines, every changed production file at or above 85% | `python -I <scratchpad>/jacoco.py evidence/qa-gates/p14-powershell-coverage.2026-10-29T12-14.xml …` | The canonical `artifacts/pester/powershell-coverage.xml` holds a partial run (Minor). |
| 62 | Applicable C# quality gates pass for any C# additions. | PASS | Zero `.cs` files on the branch; only project-file fixtures | `git diff --name-only 52587a0ee HEAD` filtered to `.cs` returned 0 | Not applicable in substance; criterion satisfied vacuously. |
| 63 | All tests pass. | PASS | Python 15668/0 failed, TS 5126 + 5109/0 failed, Pester 12605/0 failed | Executor records `p14-*-tests` | Executor evidence; not re-run. |
| 64 | Feature review reports no blocking defects. | FAIL | This review reports 4 Blocker findings | `code-review.2026-10-29T13-16.md` Findings Table | Left unchecked. |
| 65 | Evidence is stored in canonical feature evidence locations. | PARTIAL | `validate_evidence_locations.py --root .` exits 1 for two gitignored issue-980 files under `artifacts/coverage/`; no tracked violation | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | Code-review Blocker. Already checked in source files. |
| 66 | Documentation and generated customization outputs are current. | PARTIAL | Generated outputs current (mirror parity; six brief copies identical at `82b744fa…`). `spec.md` and `user-story.md` status lines still report "one escalated installed-host blocker" (`Last Updated 2026-10-26T02-54`); `enforcement.md` does not state who supplies `DRM_DISCOVERY_*` | `sha256sum` of the six copies; file inspection | Already checked in source files. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 61 criteria
- **PARTIAL:** 4 criteria (7, 60, 65, 66)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (64)

**Top gaps preventing PASS:**

1. No production component supplies the `DRM_DISCOVERY_*` identity that the native gate, start and stop hooks, MCP gate and `prepare_discovery_agent` require, and the capability probe's trusted-attribution control cannot detect its absence (criteria 7 and 64).
2. The TypeScript coverage artifact for the branch head was not retained, and 10 changed executable TypeScript files have no per-file threshold (criteria 60 and 64).
3. Evidence-location residue under `artifacts/coverage/`, and stale status lines in `spec.md` and `user-story.md` (criteria 65 and 66).

**Recommended follow-up verification steps:**

1. After the identity-supplier decision, repeat the installed-host smoke inside an unmodified Claude Code, Codex and Copilot session, without exporting `DRM_DISCOVERY_*` from a launcher. Record whether the probe reports `supported` and whether a specialist's `Bash` call is denied.
2. Run `npm run test:unit:coverage` in the root and the extension on the remediated head, retain the per-file summary under `evidence/qa-gates/`, and re-run this review.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

No source-file checkbox was changed by this review. All 61 PASS criteria were already checked by the executor. Criterion 64, "Feature review reports no blocking defects.", is FAIL and stays unchecked in both files. Criteria 7, 60, 65 and 66 are evaluated PARTIAL here but were already checked by the executor. The tracking protocol only adds check marks; it does not let a reviewer clear them. This review therefore records the discrepancy for the remediation cycle rather than editing those lines. The remediation should either resolve each gap or restore the boxes to unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md`, `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/user-story.md`
- Total AC items: 66 per source
- Checked off (delivered): 65 per source (61 evaluated PASS by this review; 4 evaluated PARTIAL)
- Remaining (unchecked): 1 per source
- Items remaining: "Feature review reports no blocking defects."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md` | 66 | 65 checked (61 PASS, 4 PARTIAL per this review) | 1 | Checkbox-backed; no change made by this review |
| `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/user-story.md` | 66 | 65 checked (61 PASS, 4 PARTIAL per this review) | 1 | Checkbox-backed; no change made by this review |
