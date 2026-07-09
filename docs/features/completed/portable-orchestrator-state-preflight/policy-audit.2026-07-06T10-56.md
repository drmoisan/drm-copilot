# Policy Compliance Audit — portable-orchestrator-state-preflight

- **Issue:** none (tracked locally; no GitHub issue by scope decision)
- **Feature:** portable-orchestrator-state-preflight
- **Reviewed range:** `75eac1a..12f259a` (`git diff 75eac1a..HEAD`; equivalently `git show 12f259a`)
- **Base (resolved):** `75eac1a2b03307ca2e4235fa85f18074d298c65d` (branch tip immediately before the feature commit)
- **Head (resolved):** `12f259a4896ef667dbfd80dddb86677301780dc5` on branch `drm-copilot-wt-2026-07-05-18-24`
- **Timestamp:** 2026-07-06T10-56
- **Reviewer:** feature-review agent
- **Template note:** The MCP tool `mcp__drm-copilot__resolve_policy_audit_template_asset` was not available in this environment. This artifact reproduces the canonical major sections mandated by `policy-audit-template-usage`; no template instruction block is present.

## Executive Summary

The feature makes two pushed-down enforcement hooks portable by adding capability detection that routes orchestrator-state validation to the authoritative Python CLI when `scripts.dev_tools` is importable and to two new self-contained PowerShell modules otherwise. The change is well-structured, fails closed on all inspected paths, preserves the injectable `$Invoker` seam, preserves the exact block-reason strings, and mirrors the Python reference constants exactly. The PowerShell toolchain evidence (format, analyze, tests) is clean and coverage is verifiable from artifacts and meets thresholds.

One Blocking policy finding was identified: `.claude/hooks/enforce-pr-author-skill.ps1` is 553 lines, exceeding the 500-line hard limit in `general-code-change.md`. This is a pre-existing violation (baseline 508 lines) that the change worsened by +45 lines. Remediation inputs are emitted.

Overall verdict: **PARTIAL** — one Blocking file-size policy violation; all other gates PASS.

## Rejected Scope Narrowing

None. The caller prompt reinforced full feature-vs-base scope and explicitly instructed that no changed-language gate be treated as waived. No scope-narrowing instruction was detected. The full branch diff `75eac1a..12f259a` was audited.

## Evidence Location Compliance

**PASS.** `scripts/dev_tools/validate_evidence_locations.py --root .` exited `0`. No files in the branch diff are written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All feature evidence resides under the canonical `docs/features/active/portable-orchestrator-state-preflight/evidence/<kind>/` tree (kinds: `baseline`, `qa-gates`, `other`).

## Work-Mode Acceptance-Criteria Resolution

- `issue.md` is absent from the feature folder, so no `- Work Mode:` marker exists. Per the fail-closed rule, work mode resolves to `full-feature`.
- `full-feature` names `spec.md` and `user-story.md` as AC sources. `user-story.md` is also absent.
- The only present AC source is `spec.md` `## Acceptance Criteria` (AC1–AC7), which the caller identified as authoritative. This audit uses `spec.md` AC1–AC7 as the AC inventory and records the absence of `issue.md`/`user-story.md` as a documented assumption (see Gaps and Exceptions).

## Languages With Changed Files (scope)

| Language | Changed files (production) | Coverage-bearing | Coverage verdict |
|---|---|---|---|
| PowerShell | 2 hooks modified, 2 `.psm1` modules added, 1 `.psd1` settings modified; 5 test files added | Yes | PASS |
| JSON | `extensions/.../pack-manifests/core.json` (manifest membership) | No (config/manifest; verified by Pester manifest test) | N/A |
| Markdown | `spec.md`, `plan.md`, evidence `*.md` | No (docs) | N/A |

## 1. General Unit Test Policy Compliance

**PASS.** New Pester suites accompany every new production module and the two rewired hooks:
- `tests/.../orchestrator-state/OrchestratorState.Tests.ps1` (222 lines)
- `tests/.../orchestrator-state/OrchestratorStateCompletion.Tests.ps1` (184 lines)
- `tests/.../orchestrator-state/OrchestratorState.Manifest.Tests.ps1` (52 lines)
- `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` (52 lines)
- `validate-orchestrator-output.Tests.ps1` (32 lines) and `.model-routing.Tests.ps1` (52 lines)

Tests follow the injectable-seam contract: they mock the `$Invoker`/probe seam rather than the `python` executable, consistent with `powershell.md` mocking rules. Test file locations mirror the production tree under `tests/`. Determinism requirements (no network, no wall-clock, mock the injected seam) are respected in the inspected suites. The junit results record the new suites executing (`OrchestratorState*` describe blocks present in `artifacts/pester/pester-junit.xml`).

## 2. General Code Change Policy Compliance

**FAIL (one item).**

| Item | Verdict | Evidence |
|---|---|---|
| Fail-fast / explicit error handling | PASS | Both modules fail closed on missing file, empty content, invalid JSON, non-object root, missing keys, invalid statuses; try/catch narrows JSON parse and re-reports as structured error. |
| Separation of concerns | PASS | Pure checkpoint logic in `.psm1` modules; I/O (file read) isolated in `Get-OrchestratorStateCheckpoint`; hooks retain thin wiring. |
| Reusability / no copy-paste | PARTIAL | The `Test-PythonOrchestratorValidatorAvailable` probe (~28 lines incl. doc comment) is duplicated verbatim in both hooks. See code-review finding CR-2. |
| Naming | PASS | Approved verbs and descriptive nouns; PascalCase functions; `camelCase`/`$script:` constants pinned to Python names. |
| **File size limit (<= 500 lines)** | **FAIL** | `.claude/hooks/enforce-pr-author-skill.ps1` = **553 lines** > 500. Baseline (75eac1a) = 508 (already over); this change added net +45 lines. Blocking per `general-code-change.md` File Size Limit. Other production files under limit: `validate-orchestrator-output.ps1` 368; `OrchestratorState.psm1` 379; `OrchestratorStateCompletion.psm1` 243. |
| Dependencies | PASS | No new external dependencies; portable modules use only built-in cmdlets and the sibling `ModelRouting.psm1`. |

## 3. Language-Specific Code Change Policy Compliance (PowerShell)

**PASS (with the file-size FAIL noted in Section 2).**
- Advanced functions with `[CmdletBinding()]`, `[OutputType(...)]`, and `[Parameter(Mandatory=$true)]` throughout.
- `Set-StrictMode -Version Latest` set in both modules; strict-mode-safe field access via `Get-OrchestratorStateField`.
- No `Invoke-Expression`, no plaintext secrets, no hard-coded credentials.
- Design seam: the injectable `[scriptblock] $Invoker` default is preserved; capability detection is a narrowly scoped probe function (injectable/mizable seam), consistent with the "injectable delegate" seam guidance.
- PSScriptAnalyzer: `run_poshqc_analyze` evidence reports `{"ok":true}`, 0 errors / 0 warnings across the full PowerShell surface (`evidence/qa-gates/final-analyze.md`).
- Format: `run_poshqc_format` evidence reports `{"ok":true}`, no modification (`evidence/qa-gates/final-format.md`).

## 4. Language-Specific Unit Test Policy Compliance (PowerShell)

**PASS.** Pester v5 suites use `Describe`/`Context`/`It`; one behavior per `It`; Arrange–Act–Assert structure. Rejection conditions are individually asserted (missing keys, step pending/blocked, blocked_reason set, non-empty override list, missing/invalid JSON, delegated-agent without receipt). Mocking targets the injected seam, never the `python` executable, satisfying the external-executable mocking rule.

## 5. Test Coverage Detail

**PASS (PowerShell).** Verified by inspecting existing coverage artifacts (no regeneration performed).

| File | Tier | Line coverage | Source artifact | Verdict |
|---|---|---|---|---|
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` (new) | — | 100.00% (79/79 line; 106/106 instr) | `artifacts/pester/orchestrator-state-coverage.xml` | PASS (>= 85% line) |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` (new) | — | 100.00% (50/50 line; 71/71 instr) | `artifacts/pester/orchestrator-state-coverage.xml` | PASS (>= 85% line) |
| `.claude/hooks/enforce-pr-author-skill.ps1` (modified) | — | 91.20% (114/125 line; 143/158 instr) | `artifacts/pester/powershell-coverage.xml` | PASS (>= 85%, no regression vs claimed baseline 89.57%) |
| `.claude/hooks/validate-orchestrator-output.ps1` (modified) | — | 89.42% (93/104 line; 165/182 instr) | `artifacts/pester/powershell-coverage.xml` | PASS (>= 85%, no regression vs claimed baseline 87.23%) |
| Repo-wide PowerShell (canonical artifact) | — | 93.24% (1021/1095 line) | `artifacts/pester/powershell-coverage.xml` | PASS (>= 85%) |

Notes:
- The two new modules are covered in the scoped artifact `orchestrator-state-coverage.xml`, not in the canonical `powershell-coverage.xml` (whose `CodeCoverage.Path` batch did not emit them in the inspected run). Both artifacts were produced during execution; per the evidence-verification model both were inspected. The runsettings change adds the two module paths to the coverage list so future full runs include them.
- Branch coverage: the Pester JaCoCo/CoverageGutters report emits LINE and INSTRUCTION (command) counters, not a report-level BRANCH counter. Instruction/command coverage is used as the branch proxy, consistent with the existing `ModelRouting.psm1` precedent. New modules at 100% instruction; hooks at 90.5% / 90.7% instruction — all above the 75% branch floor.

## 6. Test Execution Metrics

**PASS.** `evidence/qa-gates/final-test.md` (EXIT_CODE 0): full suite 1063 tests, 0 failures, 0 errors (baseline 1035; +28 new tests). Scoped new-module run: 21 tests, 177/177 commands executed. Repo-wide line coverage 93.24% (no regression vs baseline 92.93%).

## 7. Code Quality Checks

- Fail-closed semantics verified on all inspected paths (missing/empty/invalid/non-object checkpoint; missing keys; invalid statuses; invalid blocked_reason; not-ready readiness; unreceipted delegated agent).
- PS/Python parity verified for the base-presence constants (`REQUIRED_STATE_KEYS`, `STEP_STATUS_KEYS`, `VALID_STEP_STATUS`, `VALID_BLOCKED_REASONS`) — byte-identical to `scripts/dev_tools/validate_orchestrator_state.py` lines 54–104.
- PS/Python parity verified for PR-creation readiness against `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` (steps 5–8 not pending/blocked; `blocked_reason` in {none/absent}; override lists empty-when-present; identical error strings).
- PS/Python parity verified for the model-routing existence gate against `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` (`_DELEGATING_AGENTS` set identical; delegated-agent derivation from `delegation_receipts[].agent_name` + delegating `next_step`; superset existence check; sorted deterministic error ordering).
- Block-reason strings preserved and unchanged: `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (`enforce-pr-author-skill.ps1:414`) and `MODEL_ROUTING_BLOCKED:` (`validate-orchestrator-output.ps1:349`); both decision-mapping lines are outside the diff.
- Injectable `$Invoker` seam preserved in both hooks; the portable-module import guard (`Get-Command ... -ErrorAction SilentlyContinue`) avoids reloading and resetting a test-injected mock.

## 8. Gaps and Exceptions

- **G-1 (Blocking):** File-size violation — `enforce-pr-author-skill.ps1` = 553 lines > 500 (pre-existing 508, worsened +45). See Section 2 / remediation inputs.
- **G-2 (Non-blocking):** Probe duplication — `Test-PythonOrchestratorValidatorAvailable` duplicated verbatim across both hooks. Extracting it into the portable lib module would also reduce the size overage in G-1.
- **G-3 (Non-blocking, documented Non-Goal):** The portable completion gate (`Test-OrchestratorStateCompletionReadiness`) performs base-presence + model-routing existence checks only. It does not reproduce the Python `--require-complete` deep completion/CI/phase/per-receipt checks. This is intentional per `spec.md` Non-Goals (Option A). In a consumer repo the completion gate is therefore presence-level, weaker than the drm-copilot Python path for those deep checks, though still fail-closed for the checks it performs. Documented and accepted; recorded so operators understand consumer-repo enforcement depth.
- **G-4 (Assumption):** `issue.md` and `user-story.md` are absent. Work mode fell back to `full-feature`; AC source is `spec.md` AC1–AC7 only (caller-confirmed authoritative).
- **G-5 (Informational):** Evidence markdown files carry a timestamp (`2026-07-06T14-03`) later than the commit time (`10:47`); this is a provenance inconsistency in the committed evidence text. The underlying coverage/test artifacts (`artifacts/pester/*`, mtime ~10:41–10:42) were independently inspected and substantiate the coverage and test-count claims, so the numeric conclusions stand regardless.

## 9. Summary of Changes

- New portable modules: `OrchestratorState.psm1` (PR-creation readiness + base presence, 379 lines), `OrchestratorStateCompletion.psm1` (completion presence + model-routing existence gate, 243 lines).
- Capability-detection rewiring of the default `$Invoker` in both hooks (Python CLI when importable, portable module otherwise).
- `core.json` manifest membership for both modules (push-down shipping).
- `pester.runsettings.psd1` adds both modules to the coverage path list.
- 5 new/changed Pester test files.

## 10. Compliance Verdict

**PARTIAL — Remediation required.** One Blocking policy violation (file-size limit, G-1). All other audited gates PASS: unit-test policy, PowerShell language policy (format/lint), coverage (all changed files and repo-wide above threshold), evidence locations, fail-closed behavior, PS/Python parity, block-reason and seam preservation. The `modified-workflow-needs-green-run` rule does not fire (no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths in the diff).

## Appendix A: Test Inventory

| Test file | Focus |
|---|---|
| `OrchestratorState.Tests.ps1` | Readiness accept/reject; base presence; fail-closed load errors |
| `OrchestratorStateCompletion.Tests.ps1` | Completion presence; model-routing existence gate; fail-closed |
| `OrchestratorState.Manifest.Tests.ps1` | `core.json` lists both modules (AC4) |
| `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | Capability-detection seam routes Python vs portable; preflight block reason |
| `validate-orchestrator-output.Tests.ps1` / `.model-routing.Tests.ps1` | Completion routing seam; `MODEL_ROUTING_BLOCKED:` preservation |

## Appendix B: Toolchain Commands Reference

Commands referenced or verified for this audit (check-only; no regeneration performed by the reviewer):

- Diff scope: `git diff 75eac1a..HEAD` / `git show 12f259a`
- Format (evidence): `mcp__drm-copilot__run_poshqc_format` → `evidence/qa-gates/final-format.md` (exit 0)
- Analyze (evidence): `mcp__drm-copilot__run_poshqc_analyze` → `evidence/qa-gates/final-analyze.md` (exit 0, 0/0)
- Test + coverage (evidence + artifacts): `mcp__drm-copilot__run_poshqc_test` → `evidence/qa-gates/final-test.md` (exit 0); artifacts `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/orchestrator-state-coverage.xml`, `artifacts/pester/pester-junit.xml`
- Evidence-location gate: `python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0)
- Parity references: `scripts/dev_tools/validate_orchestrator_state.py`, `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`, `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`
