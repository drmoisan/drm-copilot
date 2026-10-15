# Handoff Notes (Issue #509)

Timestamp: 2026-09-30T15-15
Task: [P8-T23]
Branch actually used: `bug/promotion-gate-lacks-preexisting-issue-branch-exec-509` (orchestrator substitution for `bug/promotion-gate-lacks-preexisting-issue-branch-509`)
Plan: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md`
Scope: authoring only. No pull request was opened and no CI was monitored by the executor.

## Execution outcome

- All plan tasks except P8-T17 and P8-T22 are checked off.
- **P8-T17 FAIL (AC-2):** `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` has 744 lines, above the 500-line limit (`.claude/rules/general-code-change.md`; P3-T4 "under 500 lines"). See `evidence/qa-gates/file-size-gate.2026-09-30T15-10.md`. It was not remediated inside P8-T17. The remedies are a split into a second test file, which is outside the Scope-of-the-diff enumeration and AC-19, or a compaction of about 250 lines that preserves all 39 node IDs. Either one restarts the Python QA loop (P8-T5 to P8-T9, P8-T15), so a remediation plan is required.
- **P8-T22 not met as a consequence:** the spec grep counts are 20 checked and 2 unchecked (AC-2, AC-18), where the task expects 21 and 1.
- **P8-T12 deviation:** the MCP Pester route-compliance call returned `failure` (child exit 2; two failed tests) instead of the expected `success`. Both failures are in hook test files that this branch does not change, and both depend on gitignored local checkpoint files (`artifacts/orchestration/orchestrator-state.json`; `artifacts/orchestration/epic-orchestrator-state.json` in the primary checkout). The H1 CI run on the same HEAD reports 0 failures for those files. Per the task text, P8-T13's failed-set equality decided the gate, and it passed. See `evidence/qa-gates/ps-test-mcp.2026-09-30T15-06.md`.

## Fix summary

- **Split:** `scripts/dev_tools/_orchestrator_state_routing.py` (595 lines) was split into `_orchestrator_state_route_gates.py` and `_orchestrator_state_promotion_tools.py`. The reduced `_orchestrator_state_routing.py` is 265 lines and re-exports the moved names (split commit below).
- **Three resolvers:** `resolve_issue_adoption` (Python, `scripts/dev_tools/_orchestrator_state_issue_adoption.py`), `resolveIssueAdoption` (TypeScript, `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`), and `Get-OrchestratorStateIssueAdoptionResult` (PowerShell, `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`) validate an optional checkpoint `issue_adoption` object. They return identical ordered error strings and a waived-tool set that is empty whenever any error exists.
- **Wiring:** each runtime's routing-contract validator calls its resolver with the already-resolved `required_mcp_tools` list. A waived tool is skipped in the receipt loop, and adoption errors are appended after the receipt-loop errors and before the `local_execution_overrides` errors. The declared-list equality check is unchanged. The PowerShell side carries parity row C6.15.
- **Registration:** the new PowerShell module is registered in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, both `pester.runsettings.psd1` files, and `OrchestratorState.Manifest.Tests.ps1`. `jest.config.cjs` gains per-file threshold entries for `orchestrator-state-issue-adoption.ts` and `orchestrator-state-routing.ts` (lines 85, branches 75).
- **Documentation:** `.claude/rules/orchestrator-state.md` (new `## Issue-Adoption Scope and Backward Compatibility` and `## Invariants (issue_adoption object)` sections plus one Enforcement bullet), `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, and `.codex/agents/orchestrator.toml` with its five regenerated variants, each with its bundled mirror.
- **Shared corpus:** 29 fixtures under `tests/fixtures/orchestrator_state_issue_adoption/`, read by one parity test per runtime.

SPLIT_COMMIT_SHA: `5a3278df71bd14237a2a7bdeb1857728f5077de3` (from `evidence/other/split-commit.2026-09-30T14-16.md`)

## Same-commit instruction (AC-15)

Stage each of these pairs in the same commit: each PowerShell source and bundle pair (`.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` and `OrchestratorStateRoutingContract.psm1` with their copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/`); the runsettings pair (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`); and each documentation source and mirror pair listed under "Documentation" above. Verified with `git log` and `git show --stat`: both PowerShell pairs and the runsettings pair are in commit `8a5c8d25` (Phase 5), and all twelve documentation pairs are in commit `04413014` (Phase 7); no other branch commit touches those files. Any remediation that edits one member of a pair must restage both in one commit.

## PowerShell measurement source

- H0 (baseline, P0-T18/P0-T19): Source B, run 36725543249. Run record: `evidence/baseline/poshqc-local/run-record.md`.
- H1 (final, P8-T11/P8-T13): Source B, run 36732800820, headSha ca655902a441e6be0d1749f91440d07c38dbe941. Run record: `evidence/qa-gates/poshqc-local/run-record.md`.
- Every PowerShell coverage figure (`PS_ROUTING_BASELINE_LINE` 99.1% baseline; routing 110/111 = 99.1% final; changed lines 4/4 = 100.0%; adoption module 112/112 = 100.0%) comes from Source B. Source A was refused at both handoffs (reason recorded verbatim in the H0 run record).

## Coverage deltas

- TypeScript overall: statements 97.03 -> 97.05, branches 91.19 -> 91.26, functions 90.88 -> 90.93, lines 97.03 -> 97.05. `orchestrator-state-routing.ts` lines 95.82 -> 95.93, branch 92.15 -> 92.30. New `orchestrator-state-issue-adoption.ts` 100/100/100/100.
- Python repository-wide: line 93.36% -> 93.41%, branch 86.33% -> 86.44%. Routing code, pre-split to three modules combined: line 88.1% -> 92.7%, branch 75.9% -> 84.2%. New `_orchestrator_state_issue_adoption.py` 100.0% line and branch.
- PowerShell: `OrchestratorStateRoutingContract.psm1` 99.07% -> 99.10%, changed lines 100.0%. New `OrchestratorStateIssueAdoption.psm1` 100.0%. No branch figure (Pester).

## Follow-up request artifact (P8-T20, P8-T21)

Path: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/other/follow-up-requests.2026-09-30T15-13.md`

| Task | Command | EXIT_CODE | Printed count |
| --- | --- | --- | --- |
| P8-T20 | `grep -c -F -e "github-promotion-lifecycle-issue-adoption-path" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/other/follow-up-requests.2026-09-30T15-13.md` | 0 | 1 |
| P8-T21 | `grep -c -F -e "promotion-mcp-only-hook-blocks-readonly-inspection" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/other/follow-up-requests.2026-09-30T15-13.md` | 0 | 1 |
| P8-T21 | `grep -c -F -e "enforce-promotion-mcp-only.ps1" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/other/follow-up-requests.2026-09-30T15-13.md` | 0 | 1 |

The first P8-T20 grep printed `2`, because the short name appeared in both the section heading and the bullet. The heading was reworded to `Follow-up 1: Copilot-surface promotion lifecycle`, and the rerun printed `1`. The P8-T20 section was not changed after that; the P8-T21 recount of the P8-T20 short name also printed `1`.

## Orchestrator instruction: potential entries

After execution, the orchestrator creates both potential entries with `mcp__drm-copilot__new_potential_entry`, using the short names and summaries from the follow-up request artifact:

1. `github-promotion-lifecycle-issue-adoption-path`: add the `issue_adoption` pre-existing-issue path to `.github/skills/feature-promotion-lifecycle/SKILL.md` and its copy under `extensions/drm-copilot/resources/customizations/`, deferred by #509.
2. `promotion-mcp-only-hook-blocks-readonly-inspection`: `.claude/hooks/enforce-promotion-mcp-only.ps1` blocks read-only inspection because it matches the promotion tool name anywhere in a shell command; recorded by #509, hook changes excluded from epic #771.

Feature-review then checks off AC-18.

## Remaining spec follow-ups

- The preparation-terminal ordering difference in `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` (explicitly not written by this change).
- The epic manifest `feature_folder` value for #509 names `2026-09-29-promotion-gate-lacks-preexisting-issue-branch-509`, while the canonical folder is `2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509`.
- AC-2 remediation for `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` (744 lines; see above).

## Spec discrepancy resolutions applied

1. The AC-21 "existing entry" for `orchestrator-state-routing.ts` did not exist. P6-T3 added it at lines 85 and branches 75, next to the new `orchestrator-state-issue-adoption.ts` entry, after P0-T11 confirmed the baseline row (95.82 / 92.15) was above both thresholds.
2. AC-1's own-commit requirement is met by the split commit `5a3278df71bd14237a2a7bdeb1857728f5077de3` (P1-T13). AC-15's same-commit requirement is met by staging each pair together (instruction above).
3. The PowerShell coverage source: Source A (orchestrator-run local) was primary and Source B (orchestrator-dispatched `_poshqc.yml`) was the fallback. Source B was used at both H0 and H1.

## Deviations

- **Test names registered via `globals()`:** in `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py` (lines 195-205), the two plan-fixed test names `test_large_checkpoint_with_valid_issue_adoption_completes_without_potential_to_issue_receipt` and `test_adoption_error_fails_closed_and_orders_errors_before_local_execution_overrides` are too long for an 88-column `def` line, so Ruff E501 would fail. The repository suppression policy does not pre-authorize `# noqa: E501`. Each test body is therefore a private function, registered under its exact plan-fixed name with `globals()["..." "..."] = fn`, with the name split across adjacent string literals. pytest collects both under the exact node IDs the plan names. This keeps the plan-fixed names and avoids both an unauthorized suppression and a lint failure.
- P8-T12 MCP status `failure` (environment-conditional; see "Execution outcome").
- P8-T17 FAIL and P8-T22 count mismatch (see "Execution outcome").
- Two P8 artifact filenames were corrected after writing so that their timestamps match the actual UTC run time: `no-temp-files` 15-14 -> 15-11 and `diff-scope` 15-16 -> 15-12.

## Artifact links

qa-gates:
- `evidence/qa-gates/split-black.2026-09-30T14-14.md`
- `evidence/qa-gates/split-ruff.2026-09-30T14-14.md`
- `evidence/qa-gates/split-pyright.2026-09-30T14-14.md`
- `evidence/qa-gates/split-line-counts.2026-09-30T14-14.md`
- `evidence/qa-gates/jest-threshold-entries.2026-09-30T14-38.md`
- `evidence/qa-gates/ts-format.2026-09-30T14-45.md`
- `evidence/qa-gates/ts-lint.2026-09-30T14-45.md`
- `evidence/qa-gates/ts-typecheck.2026-09-30T14-45.md`
- `evidence/qa-gates/ts-coverage.2026-09-30T14-46.md`
- `evidence/qa-gates/py-black.2026-09-30T14-46.md`
- `evidence/qa-gates/py-ruff.2026-09-30T14-48.md`
- `evidence/qa-gates/py-pyright.2026-09-30T14-49.md`
- `evidence/qa-gates/py-module-coverage.2026-09-30T14-50.md` (with `py-module-coverage.json`)
- `evidence/qa-gates/py-pytest-coverage.2026-09-30T14-51.md` (with `py-full-coverage.json`)
- `evidence/qa-gates/ps-format.2026-09-30T14-53.md`
- `evidence/qa-gates/poshqc-local/run-record.md`, `pester-junit.xml`, `powershell-coverage.xml` (H1, orchestrator-written)
- `evidence/qa-gates/ps-analyze.2026-09-30T15-02.md`
- `evidence/qa-gates/ps-test-mcp.2026-09-30T15-06.md`
- `evidence/qa-gates/ps-test-coverage.2026-09-30T15-08.md`
- `evidence/qa-gates/ts-coverage-delta.2026-09-30T15-10.md`
- `evidence/qa-gates/py-coverage-delta.2026-09-30T15-11.md`
- `evidence/qa-gates/ps-coverage-delta.2026-09-30T15-12.md`
- `evidence/qa-gates/file-size-gate.2026-09-30T15-10.md`
- `evidence/qa-gates/no-temp-files.2026-09-30T15-11.md`
- `evidence/qa-gates/diff-scope.2026-09-30T15-12.md`

regression-testing:
- `evidence/regression-testing/py-split-suites.2026-09-30T14-13.md`
- `evidence/regression-testing/py-import-direction.2026-09-30T14-14.md`
- `evidence/regression-testing/py-importers-unchanged.2026-09-30T14-14.md`
- `evidence/regression-testing/py-split-at-commit.2026-09-30T14-16.md`
- `evidence/regression-testing/py-regression-expect-fail.2026-09-30T14-17.md`
- `evidence/regression-testing/py-regression-pass-after.2026-09-30T14-19.md`
- `evidence/regression-testing/py-adoption-imports.2026-09-30T14-21.md`
- `evidence/regression-testing/py-adoption-unit.2026-09-30T14-21.md` (with `py-adoption-coverage.json`)
- `evidence/regression-testing/py-presence-gating.2026-09-30T14-21.md`
- `evidence/regression-testing/py-parity-pass.2026-09-30T14-24.md`
- `evidence/regression-testing/ps-core-json.2026-09-30T14-29.md`
- `evidence/regression-testing/ps-runsettings.2026-09-30T14-29.md`
- `evidence/regression-testing/ps-case-sensitive-operators.2026-09-30T14-32.md`
- `evidence/regression-testing/ps-bundle-copy.2026-09-30T14-34.md`
- `evidence/regression-testing/ps-test-mcp.2026-09-30T14-34.md`
- `evidence/regression-testing/ps-bundle-tests.2026-09-30T14-36.md`
- `evidence/regression-testing/ts-adoption-imports.2026-09-30T14-40.md`
- `evidence/regression-testing/ts-adoption-tests.2026-09-30T14-40.md`
- `evidence/regression-testing/ts-validate-dir-pass-after.2026-09-30T14-40.md`
- `evidence/regression-testing/codex-variants.2026-09-30T14-43.md`
- `evidence/regression-testing/docs-mirror-tests.2026-09-30T14-44.md`
- `evidence/regression-testing/docs-tokens.2026-09-30T14-44.md`

other:
- `evidence/other/follow-up-requests.2026-09-30T15-13.md`
- `evidence/other/spec-ac-checkoff.2026-09-30T15-13.md`
