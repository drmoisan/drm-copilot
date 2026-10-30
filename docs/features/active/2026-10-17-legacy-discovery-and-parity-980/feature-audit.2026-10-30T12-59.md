# Feature Audit: legacy discovery and parity (#980), review cycle 2

---

**Audit Date:** 2026-10-30
**Feature Folder:** `docs/features/active/2026-10-17-legacy-discovery-and-parity-980`
**Base Branch:** `main`
**Head Branch:** `feature/legacy-discovery-and-parity-980`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 2 (prior audit `feature-audit.2026-10-30T10-19.md`)

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` at `f7bef6ad16cf567de6462b736bbce7afd83e591a`; the branch is rebased onto it, so the merge base equals `origin/main`)
- **Head branch/commit:** `feature/legacy-discovery-and-parity-980` (commit `b8f3b9ee752672753325617e1f417e7af1a69f76`, 237 commits ahead of the merge base)
- **Merge base:** `f7bef6ad16cf567de6462b736bbce7afd83e591a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-30 12:59:10 UTC for head `b8f3b9ee7`; the summary budget truncated it after the context-file list at line 1246, so the diff inventory was taken from `git diff --name-status f7bef6ad HEAD`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/**` (Phase 17 and 18 records under `qa-gates/`, `regression-testing/`, `other/`, `remediation-baseline/`)
  - Additional evidence: `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, `artifacts/pester/powershell-coverage.xml` (each parsed per changed production file), `evidence/qa-gates/p18-powershell-junit.2026-10-30T12-41.xml`, the full cycle-2 diff (`git diff 3e7acb3e9 HEAD`), `extensions/drm-copilot/src/discovery-sentinel.ts`, and the companion `policy-audit.2026-10-30T12-59.md` and `code-review.2026-10-30T12-59.md`
- **Feature folder used:** `docs/features/active/2026-10-17-legacy-discovery-and-parity-980`
- **Requirements source:** `spec.md` and `user-story.md` (`## Acceptance Criteria`, 66 criteria each, identical text)
- **Work mode resolution note:** `issue.md` line 10 states `- Work Mode: full-feature`.
- **Scope note:** The audit covers the full branch diff against the resolved base. Remediation cycle 2 changed one production module (and its two mirrors), one fixture, three contract suites, Pester test support, three probe suites and one engineering document; rows whose evidence was not touched by the cycle cite the prior audit's verification and were spot-checked for regression by confirming the cycle-2 diff does not touch their files. Rows touched by the cycle (39, 59, 60, 61, 63, 64, 66) were re-verified by this review. The coordinator's instruction that the prior Minor and Nit are deferred to issues #1007 and #1008 is a recorded user decision and is applied as such.

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

`AC-MAP` below means `evidence/qa-gates/acceptance-criteria-status.2026-10-26T02-57.md`, `acceptance-criteria-status.2026-10-29T12-51.md`, `acceptance-criteria-status.2026-10-30T12-46.md` and the reconciliation recorded in `requirements-traceability.md`. `Prior audit` means `feature-audit.2026-10-30T10-19.md`, whose verification stands for rows the cycle-2 diff does not touch (the cycle changed no file under `packages/`, `schemas/`, `examples/`, `.claude/agents`, `.claude/skills`, `.codex/`, `.github/agents`, `.github/hooks` or `extensions/drm-copilot/src`).

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | A reusable legacy discovery and parity framework exists in `drm-copilot`. | PASS | `packages/discovery-runtime/` (185 production files), `schemas/discovery/v2/`, agents, skills, hooks on all three host surfaces; the specialist path's precondition (the capability probe) now passes on the records the gate and consumer produce | `git diff --name-status f7bef6ad HEAD`; code review Info rows | The prior audit's caveat (probe inoperable) is removed by cycle 2. |
| 2 | Core content contains no TaskMaster- or TMW-specific behavior. | PASS | Prior audit; `p16-source-neutrality.2026-10-30T01-55.md`; cycle 2 adds no core content | Prior audit grep | Unchanged. |
| 3 | Configuration is loaded from a local domain profile. | PASS | Prior audit (`domain_profile.py`, `profile_v2.py`, `gateway_host.py:203-220`) | Prior audit | Unchanged. |
| 4 | Repositories not using discovery remain unaffected. | PASS | Prior audit (`DiscoveryAuthorization.psm1:278-280, 375`; `enforcement.md` "Inactive compatibility") | Prior audit | Unchanged. |
| 5 | All required generic agents are implemented and validated. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 6 | All required generic skills are implemented and validated. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 7 | Agents cannot write outside authorized paths. | PASS | Prior audit (payload identity, denied generic tools, WriteGrants, no `local-user` fallback) | Prior audit | Unchanged; the cycle touched no identity or authorization path. |
| 8 | Every new agent has a SubagentStop output validator. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 9 | Agent and skill assets are available across supported ecosystems. | PASS | Prior audit (147 mirrors identical); cycle 2: three `DiscoveryCapability.psm1` copies share SHA-256 `ab693926…2487` | `sha256sum` of the three copies | Re-verified for the one mirrored file the cycle changed. |
| 10 | All required schemas exist and are versioned. | PASS | Prior audit; the fixture records validate against the committed `host-observation` schema (`test_records_are_schema_valid_host_observations`) | Prior audit; `p18-python-tests.2026-10-30T12-32.md` | No schema changed in cycle 2 (the latch is a store sibling, not a schema member). |
| 11 | Valid examples pass validation. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 12 | Invalid examples fail with actionable messages. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 13 | Cross-artifact references are validated. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 14 | Extensions cannot bypass core required fields. | PASS | Prior audit (`catalog.py:286-293`) | Prior audit | Unchanged. |
| 15 | A deterministic command initializes a consumer discovery workspace. | PASS | Prior audit | Prior audit | Unchanged. |
| 16 | Initialization is idempotent. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 17 | Dry-run is supported. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 18 | Existing files are not silently overwritten. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 19 | The initialized workspace validates successfully. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 20 | Individual artifact validators exist. | PASS | Prior audit | Prior audit | Unchanged. |
| 21 | A complete validation command exists. | PASS | Prior audit | Prior audit | Unchanged. |
| 22 | Blocking failures return nonzero exit codes. | PASS | Prior audit | Prior audit | Unchanged. |
| 23 | Markdown and JSON reports are generated. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 24 | Completion checks coverage, evidence, unresolved behavior, acceptance scenarios, and configured platform dimensions. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 25 | Verified claims require evidence. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 26 | Unknown behavior requires an unresolved-behavior record. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 27 | Passed runtime scenarios require runtime evidence. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 28 | Completion fails for in-scope components without disposition. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 29 | Required platform dimensions cannot remain unspecified. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 30 | Implementation planning can be gated on discovery completion. | PASS | Prior audit | Prior audit | Unchanged. |
| 31 | A generic repository/project inventory analyzer exists. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 32 | At least one meaningful C#/.NET analyzer exists. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 33 | Output is deterministic and machine-readable. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 34 | Findings include source references. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 35 | Facts are distinguished from inference. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 36 | Analyzer fixtures and tests exist. | PASS | Prior audit | Prior audit | Unchanged. |
| 37 | Python is the authoritative implementation layer. | PASS | Prior audit (`gateway_host.py:270-302`) | Prior audit | Unchanged. |
| 38 | CLI commands are documented and tested. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 39 | MCP exposes appropriate discovery functions. | PASS | Prior audit (tool definitions include `discovery_capability_sentinel`; every controlled handler passes `admitControlledToolCall`); the sentinel tool's consumption effect is now what the probe reads (`discovery-sentinel.ts:272-278`, `DiscoveryCapability.psm1:158-161, 204-207`), proved by `discovery-sentinel.contract.test.ts`, `DiscoverySentinelConsumption.Contract.Tests.ps1` and the P17-T5 smoke | Source inspection of both files and the three suites | The prior audit's note (contract defect under criterion 64) is resolved. |
| 40 | VS Code commands/wrappers are added where justified. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 41 | Wrappers do not duplicate business logic. | PASS | Prior audit | Prior audit | Unchanged. |
| 42 | Workspace path safety is enforced. | PASS | Prior audit | Prior audit | Unchanged. |
| 43 | Canonical assets publish correctly to Claude Code. | PASS | Prior audit; `p18-mirror-and-publication-contracts.2026-10-30T12-43.md` (0 byte differences, generator check 0, 77 contract tests passed); three-copy hash by this review | `sha256sum`; executor record | Re-verified for the changed mirror. |
| 44 | Canonical assets publish correctly to Codex. | PASS | Same as 43; `tests/scripts/codex-hooks/discovery-capability.Tests.ps1` 12/12 in the P18-T3 JUnit | Same | |
| 45 | Canonical assets publish correctly to GitHub Copilot. | PASS | Same as 43; `tests/scripts/copilot-hooks/discovery-capability.Tests.ps1` 10/10 in the P18-T3 JUnit | Same | |
| 46 | Publishing/conversion validation covers the assets. | PASS | Prior audit; `p18-mirror-and-publication-contracts.2026-10-30T12-43.md` | Executor record | |
| 47 | Generated outputs contain no unsupported references. | PASS | Prior audit; generator check exit 0 in `p18-mirror-and-publication-contracts.2026-10-30T12-43.md` | Executor record | |
| 48 | Confirmed contracts generate linked acceptance scenarios. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 49 | Platform-mode tags are supported. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 50 | Offline/mobile tags are supported when configured. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 51 | Unresolved behavior does not become a false expected result. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 52 | Scenarios preserve contract and decision traceability. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 53 | Architecture and ownership boundaries are documented. | PASS | Prior audit | Prior audit | Unchanged. |
| 54 | A consumer setup guide exists. | PASS | Prior audit | Prior audit | Unchanged. |
| 55 | Schema/status semantics are documented. | PASS | Prior audit | Prior audit | Unchanged. |
| 56 | Extension-versus-local placement is documented. | PASS | Prior audit; AC-MAP | Prior audit | Unchanged. |
| 57 | A source/target repository workflow is documented. | PASS | Prior audit | Prior audit | Unchanged. |
| 58 | TaskMaster/TMW appear only in a separated example/case study. | PASS | Prior audit | Prior audit | Unchanged. |
| 59 | Applicable Python quality gates pass. | PASS | Black, Ruff, Pyright clean; 15795 passed, 6 skipped (`p18-python-{format,lint,types,tests}.2026-10-30T12-32.md`); canonical `artifacts/python/lcov.info` 96.69% lines / 93.62% branches, all 185 changed production files at or above 90.00% lines and 80.00% branches | `python -I <scratchpad>/perfile.py` over `artifacts/python/lcov.info` | Coverage verified by this review. |
| 60 | Applicable TypeScript quality gates pass. | PASS | Clean root install, format, lint, types, tests green (`p18-typescript-extension-*.2026-10-30T12-25.md`, `p18-typescript-root-install.2026-10-30T12-25.md`); canonical `extensions/drm-copilot/coverage/lcov.info` 97.05% / 93.66%; 47 executable changed files all at or above 92.86% lines and 77.78% branches; no root-package `.ts` file is on the branch; no exclude or threshold change in cycle 2 | `python -I <scratchpad>/tslow.py`; `git diff 3e7acb3e9 HEAD --stat` | Coverage verified by this review. |
| 61 | Applicable PowerShell quality gates pass. | PASS | Format and analyzer clean; 13091 tests, 0 failed, 10 pre-existing skips (`p18-powershell-{format,analyze,tests}.2026-10-30T12-41.md`; JUnit read by this review); canonical `artifacts/pester/powershell-coverage.xml` is a full run at 93.41%, every changed production file at or above 92.82%, `DiscoveryCapability.psm1` 183/184 with all 11 cycle-added executable lines covered | `python -I <scratchpad>/perfile.py` over the canonical XML | Coverage verified by this review. |
| 62 | Applicable C# quality gates pass for any C# additions. | PASS | Zero `.cs` files on the branch | `git diff --name-only f7bef6ad HEAD` filtered to `.cs` | Satisfied vacuously. |
| 63 | All tests pass. | PASS | Python 15795/0 failed, TS extension 5239/0 failed, Pester 13081/0 failed; the three new contract suites are in the populations (Pester contract 3/3 in the JUnit; Jest and Python records name the new files) | Executor records `p18-*-tests`; JUnit read by this review | Executor evidence cross-checked against the JUnit; suites not re-run. |
| 64 | Feature review reports no blocking defects. | PASS | `code-review.2026-10-30T12-59.md` reports 0 Blocker, 0 Major, 0 Minor and 1 Nit (no remediation required); `policy-audit.2026-10-30T12-59.md` is COMPLIANT. R5 is resolved end to end (probe reads the `.consumed` latch the consumer writes, at the path and with the content the consumer uses; fixture produced from real code paths; hand-seeded `consumed` state removed; mirrors byte-identical; fail-before run recorded; cross-runtime smoke green). The prior Minor and Nit are deferred to issues #1007 and #1008 by user decision. | This review's two companion artifacts | Checked off in both source files by this review. |
| 65 | Evidence is stored in canonical feature evidence locations. | PASS | `validate_evidence_locations.py --root .` exits 0 at head `b8f3b9ee7`; 0 tracked paths under `artifacts/` in the branch diff; 32 cycle-2 evidence files under `evidence/{qa-gates,regression-testing,other,remediation-baseline}/` | `python -I scripts/dev_tools/validate_evidence_locations.py --root .`; `git diff --name-only f7bef6ad HEAD -- artifacts/` | Re-verified at the new head. |
| 66 | Documentation and generated customization outputs are current. | PASS | Three `DiscoveryCapability.psm1` copies identical; `enforcement.md` `## Protected records` (lines 74-76) and `## Capability probe` (lines 196-201) state the latch contract as implemented; `spec.md:6-7` and `user-story.md:5-6` carry the cycle-2 status (`Last Updated 2026-10-30T12-13`); `completion-report.md` and `handoff.md` requalified (P17-T7, P18-T8) | `sha256sum`; file inspection | The prior audit's note (`## Capability probe` must match the chosen contract) is resolved. |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 66 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

None. The one failing criterion of the prior audit (64) passes: the blocking finding R5 is resolved in code and proved by a shared fixture produced from real code paths, a fail-before record, three contract suites and a cross-runtime smoke over a real store, and this review's code review and policy audit report no blocking defect.

**Recommended follow-up verification steps:**

1. Proceed to the PR flow; carry issues #1007 (root-grant strict decode and pruning) and #1008 (`SHELL` observation bounding) in the PR description as the plan directs, and run the exact-head CI gate.
2. After merge, from an orchestrator session on Claude Code, delegate `discovery-capability-sentinel` once and call `run_discovery_doctor`; record the probe status and the observation field names in a new `discovery-host-observations.<timestamp>.md` per the launch instructions in the P16-T7 record. This is the first live-host confirmation of the host payload field assumption; the recorded user decision does not make it a merge precondition.
3. Optionally, under #1008 or a sibling, validate the latch's `consumed_at` against the attestation window (code review Nit).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

This review checked off one criterion in each source file: criterion 64, "Feature review reports no blocking defects.", changed from `- [ ]` to `- [x]` at `spec.md:789` and `user-story.md:120`; the criterion text was not modified. The other 65 criteria were already checked by the executor (P16-T9 and P18-T6 reconciliations), and this review's evaluation agrees with each of them. The two unchecked items that remain in `spec.md` (line 800, "Telemetry/logging added or updated (if applicable)", and line 815, "Applicable complete language/repository quality loops, coverage and isolation checks, and final full feature review.") are in the Definition of Done and Seeded Test Conditions checklists, not in `## Acceptance Criteria`; they are the executor's to maintain and are left as they are.

### AC Status Summary

- Source: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md`, `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/user-story.md`
- Total AC items: 66 per source
- Checked off (delivered): 66 per source (65 previously by the executor, 1 by this review)
- Remaining (unchecked): 0 per source
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md` | 66 | 66 | 0 | Checkbox-backed; criterion 64 checked off by this review at line 789 |
| `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/user-story.md` | 66 | 66 | 0 | Checkbox-backed; criterion 64 checked off by this review at line 120 |
