# Code Review: enforcement-hooks-must-not-invoke-python (#475)

**Review Date:** 2026-08-15
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475`
**Feature Folder Selection Rule:** Sole active feature folder whose issue-number suffix (475) matches the caller-declared canonical issue and whose scoping docs constitute the branch's material scoping-doc changes.
**Base Branch:** `main` (merge-base `b1a86fd3`)
**Head Branch:** `worktree-agent-afc9f4fd25ec235a5` (head `116a56fb`)
**Review Type:** Initial review

**Template source:** bundled MCP template asset content read from `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (the identical asset served by `resolve_policy_audit_template_asset`, selector `code-review-template`; the MCP tool surface was not available in this session, so the bundled asset file was read directly).

---

## Executive Summary

This branch removes all four Python invocation sites from the enforcement-hook surface and replaces them with a single portable PowerShell implementation per gate: a complete-parity port of the 85-check orchestrator-state completion inventory (12 new `.claude/lib` modules, including PowerShell ports of the two codex resolvers), a shared discovery-validation module with a fail-closed PowerShell 7.4+ version floor, an `$ArtifactType` dispatch that fixes defect D-1 for epic/parallel checkpoints, and an AST-based structural guard with zero allowlist entries. Scope is 119 files, +20805/−521, dominated by new modules, their tests, byte-identical bundle mirrors, and evidence documents.

Implementation quality is high. The review independently re-executed the guard suite (27/27 with repository scans), the full `claude-lib` + `claude-hooks` Pester trees (1677/1677), re-parsed the coverage XML (all changed/new files >= 85% line, lowest 91.38%), byte-compared all 17 mirrors (identical), and audited every deleted line in the two gate files (all deletions are Python-leg removals, doc-comment removals, or refactors into the new modules; zero check or error-string removals). Error-string spot-checks against the Python validators matched exactly, including the two model-routing gate templates and the empty-list completion keys.

**What changed:**
Three hooks and two library modules modified; twelve library modules, twenty-one test suites, and one test helper added; the runsettings coverage-target list extended additively by twelve entries; `core.json` gains twelve registrations; all `.claude` changes mirrored byte-identically into the bundle. The six hooks that mention `python` without invoking it are byte-unchanged, and `.claude/settings.json` is unchanged.

**Top 3 risks:**
1. The pinned routing-matrix constants (PD-1) can drift from `config/orchestration-routing.json` in the window between a config edit and the next test run; the config-parity Pester test bounds this risk to test-time detection, which is the same bound the existing `ModelRouting.psm1` pattern accepts.
2. PowerShell branch coverage is unmeasurable with the current Pester JaCoCo instrument, so the 75% branch floor is unenforced for the entire PowerShell surface, including the 12 new gate modules; line coverage (95.92% suite, 99.31% new-code) is the only measured dimension.
3. Three files sit at exactly the 500-line cap (`DiscoveryValidation.psm1`, the guard helper, the guard suite); any future edit forces a split, which for the guard pair risks divergence between helper and suite if done carelessly.

**PR readiness recommendation:** **Go** — zero blockers and zero majors; all gates re-verified green by this review; the two minor findings are pre-existing or cosmetic and do not warrant holding the merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `artifacts/pester/powershell-coverage.xml` (instrument output) | n/a | The Pester 5 JaCoCo exporter emits no `BRANCH` counters, so the repository's 75% PowerShell branch-coverage floor is unenforceable for this branch and every other; the 12 new gate modules ship with no measured branch dimension. | File a potential entry to track adoption of a branch-capable PowerShell coverage instrument; until then the gap should stay visible in audits rather than being silently accepted. | A policy floor that no instrument can measure provides no protection; the gap predates this feature (baseline XML equally lacks the counter) but this feature adds 1015 new production lines under it. | `grep -c BRANCH artifacts/pester/powershell-coverage.xml` = 0 (this review); `evidence/qa-gates/coverage-delta.2026-08-15T19-18.md` "Branch Coverage — Instrument Limitation" |
| Minor | `docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/**` | filenames | Evidence timestamps mix timezone bases: site-verification artifacts are stamped in UTC (`...T20-15` through `...T23-30`) while baseline and final artifacts are stamped in local time (`...T18-21` through `...T19-21`), so filename order contradicts execution order (e.g., the baseline appears later than the final gates). | Standardize on one timezone base for evidence timestamps in future runs; no rewrite of this run's artifacts is needed because task-ID cross-references make the ordering recoverable. | Chronological ordering by filename is the first tool an auditor reaches for; a mixed base forces content-level reconstruction. | `completion-wiring-verify.2026-08-15T23-30.md` (UTC, per appendix generation time 23:30 UTC) vs `final-poshqc-test.2026-08-15T18-30.md` (local, same wall-clock window) |
| Info | `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | whole file | Three files are at exactly the 500-line cap. | None required now; plan the split boundary (e.g., fixture extraction) before the next functional edit to these files. | At-cap files convert the next small edit into a structural change. | Line counts verified by this review (500/500/500) |
| Info | `docs/features/active/.../research/2026-08-15T15-30-full-parity-check-inventory-and-bash-json-research.md` | section 2.5 | Prose states "7 of 85 fully or substantially present" while its own parenthetical enumerates six row IDs; the recount (6 pre-existing + 79 ported = 85) is recorded as authoritative on the parity artifact. | None; the discrepancy is recorded where the spec directs. Do not edit the research artifact retroactively. | Verified by this review: the parenthetical lists exactly six IDs and the family totals (57+25+3) reconcile to 85. | `parity-coverage.2026-08-15T18-30.md` "Authoritative Recount"; research artifact line 190 |
| Info | `artifacts/orchestration/orchestrator-state.json` | `local_execution_overrides[0]` | LEO-1 (batch-budget state-file deletion at phase boundaries) evaluated and agreed as sanctioned: it is the hook's own documented remedy (`enforce-powershell-batch-budget.ps1:136-137`), each phase respected the 3/3 cap independently, no cap-raise env vars were used, and the record is fully declared with approver and binding condition. The completion-gate failure it causes was correctly left standing rather than the record being deleted. | None; the orchestrator reconciles the standing item at run completion. | A declared, remedy-conformant override with the gate failure honestly left standing is the intended behavior of the override mechanism. | Checkpoint `local_execution_overrides` record; `self-gating-audit.2026-08-15T18-50.md` "The Standing local_execution_overrides Item" |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The dispatch design in `validate-orchestrator-output.ps1` is the strongest piece: `Test-OrchestratorCheckpointStructure` reuses the existing `Get-OrchestratorStateCheckpoint` load contract instead of duplicating it, the PD-3 rationale is documented at the definition site (lines 152-196), and the default branch fails closed naming the unsupported type — an unrecognized type can never read as a clean pass.
- The parity port is decomposed by check family into modules that each stay well under the cap and each own an exported `Get-*Error` surface, with the aggregation module (`OrchestratorStateUnconditional.psm1`, 28 lines of covered code) composing them under Python's key-gated semantics. Reuse constraints are enforced structurally: U6.C5/U6.M4 call the single `ModelRouting.psm1` formulas, U6.X5/U6.T10 call the single resolver ports, and the M3 gate invokes the same per-entry validators with `Add-OrchestratorStateErrorOnce` pinning PD-2's single emission.
- The guard's detection model is AST-based with two narrowly documented carve-outs (scriptblock-parameter invocation; dot-sourced sibling loads), which is why the six incidental hooks produce zero findings without modification — the design avoided the substring-guard failure mode the issue explicitly warned about.
- The Phase 16 coverage recovery was done the right way: additive sibling suites driving the real, unmocked seam, with the 15 pinned `Mock` registrations and 11 `Should -Invoke` assertions left untouched at their pinned line numbers.

#### API and safety notes

- All new public functions are advanced functions with `[CmdletBinding()]`, `[OutputType()]`, and mandatory-parameter attributes; seams are typed `[scriptblock]` parameters with production defaults, matching the repo's minimal-DI ladder.
- The pinned routing-matrix module performs no disk read at validation time (PD-1), and its constants are pinned by a config-parity test that reads `config/orchestration-routing.json` at test time only — the same pattern and rationale as `ModelRouting.psm1:33-39`.
- The version floor is enforced at the point of failure with an actionable message naming PowerShell 7.4+, `Test-Json -SchemaFile` Draft 2020-12, and issue #475, and is tested through an injectable version seam rather than `$PSVersionTable` mutation.

#### Error handling and logging

- Fail-closed direction is preserved at every boundary: missing checkpoint, invalid JSON, non-object root, unsupported artifact type, and sub-7.4 host all yield deny verdicts with the load or version error as output. The four verdict prefixes are unchanged and the `MODEL_ROUTING_BLOCKED` routing token (`model_routing_receipts|complexity_assessments`) is guaranteed by the ported error strings (spot-verified against the Python templates).
- The deletion audit of the two gate files confirms strictness moved in one direction only: the completion gate enforces 79 more checks after this change than before it, and the reconciliation record shows those checks firing against the live checkpoint and being honored.

---

## Test Quality Audit

The verification evidence is unusually complete: per-phase QA gates with recorded hashes, a fail-before guard scan (5 findings at `b1a86fd3`), zero-finding scans over both the repo tree and the bundle mirror tree, a row-by-row parity mapping artifact, a hash-baselined self-gating audit, and a numeric coverage-delta artifact. This review re-executed rather than trusted where practical.

### Reviewed test and QA artifacts

- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` — re-executed by this review: 27/27 including both repository-scan assertions and the allowlist-staleness assertion; fixture `It`s prove each detection and non-detection class.
- `tests/scripts/claude-lib/**` + `tests/scripts/claude-hooks/**` — re-executed by this review: 1677/1677; includes the 85-row parity fixtures, dispatch/D-1 regression fixtures, both-layers U6.H proof, PD-2 single-emission assertions, and the 26 preserved seam references.
- `artifacts/pester/powershell-coverage.xml` — re-parsed by this review; per-file numbers match the coverage-delta evidence exactly (53/58, 56/61, suite 5098/5315).
- `evidence/qa-gates/self-gating-audit.2026-08-15T18-50.md` — corroborated by this review's independent line-level deletion audit of `validate-orchestrator-output.ps1`, `OrchestratorState.psm1`, and `OrchestratorStateCompletion.psm1` (zero check/threshold/error-string removals) and by the additive-only runsettings diff.
- `evidence/regression-testing/guard-scan-fail-before.2026-08-15T19-53.md` — fail-before evidence for the guard (EXIT_CODE 1, 5 findings at the pre-change tree), satisfying the fail-before requirement without PATH manipulation.
- `evidence/other/parity-coverage.2026-08-15T18-30.md` — spot-checked: named `It`s exist in the named files (U6.X11, C6.10 sampled), family totals reconcile with inventory section 2.5, and the two exact-template spot-checks against `_orchestrator_state_model_routing_gate.py` matched byte-for-byte.

### Quality assessment prompts

- **Determinism:** In-memory JSON fixtures; no PATH mutation, live interpreter probes, or temp files anywhere in the change (SD-3, constraint sweep); config read only at test time in the parity-pinning suite.
- **Isolation:** One inventory row or one behavior per `It`; seam mocks confined to their function boundary with `-ParameterFilter` scoping.
- **Speed:** Full suite 101.6s for 2740 tests; guard suite 1.65s.
- **Diagnostics:** Exact-string assertions produce precise failure diffs; the repository scan reports its finding list via `-Because`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection: constants are routing-matrix and enum data; no credentials, tokens, or endpoints. |
| No unsafe subprocess or command construction | PASS | The change removes subprocess invocations; no `Invoke-Expression`, no `Start-Process`, no dynamic command construction added (the guard itself now enforces this class repo-tree-wide). |
| Input validation at boundaries | PASS | Checkpoint and document inputs validated fail-closed (exists/parse/root-type) before any per-field logic; discovery schema resolution restricted to `file://` URIs with all other schemes rejected into the specified error family. |
| Error handling remains explicit | PASS | Every failure path produces a specific error string; deletion audit found zero broadened catches. |
| Configuration / path handling is safe | PASS | Module paths resolved relative to `$PSScriptRoot` so the pack travels; no validation-time read of repo-only config (PD-1); schema paths resolved locally from `schemas/discovery/v1/`. |

---

## Research Log

No external research was required. All conclusions derive from repository state: the branch diff, the Python validator sources under `scripts/dev_tools/`, the feature-folder documents and evidence, the live hook and checkpoint, and independent tool executions recorded in the findings and the policy audit.

---

## Verdict

The change is ready for normal PR flow under the recorded stop condition (parent session rebases onto `main`, then PR authoring). The binding requirement — complete parity with no gate weakening anywhere — is satisfied and was verified against the highest-risk failure mode: the self-gating audit's claim of zero accommodation changes was independently corroborated by a line-level deletion audit of the gate files, exact-template error-string comparisons against the Python sources, and an additive-only check of the coverage-target configuration. The three deliberate deviations (PD-1, PD-2, PD-3) are sound engineering decisions, each owner-visible, each tested. The two Minor findings (branch-coverage instrument gap; mixed timestamp bases) are pre-existing or cosmetic and are recorded for follow-up rather than remediation of this branch. Zero blocking findings.
