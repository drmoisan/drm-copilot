# Policy Compliance Audit: Current Codex model routing (#977)

**Audit Date:** 2026-10-17T19-07 UTC
**Code Under Test:** Complete main...HEAD diff, 290 paths, 4678 insertions / 583 deletions; 42 changed Python, TypeScript and PowerShell source/test paths, including independently measured bundled mirrors.
**Base Branch:** main
**Merge Base:** f1408d0040e11432f3efbf4f7b6af4115c0b1f3d; committed 2026-10-17T12:17:11-05:00.
**Head:** c9902b54ffdb146b5039d5b7aaf4c1145afe5066.
**Template:** Copied through MCP resolve_policy_audit_template_asset(asset=template), then populated with the required sections retained and usage instructions removed.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 10 | 7336 full; 142 review contracts | PASS; 6 baseline skips | 94.1117% line; 88.7837% branch | 94.1117% line; 88.7837% branch | Resolver 100% line/branch; generator 94.5312% line, 89.1304% branch |
| TypeScript | 11 | 4105 in 281 suites | PASS | 97.4117% line; 92.6564% branch | 97.4117% line; 92.6573% branch | Changed routing lines 100%; file 95.6879% line, 94.1667% branch |
| PowerShell | 21 | 11310 full; 10 baseline skips | PASS | 92.2321% line | 92.6236% line | New command method 90% line; source/actual bundled hook 92.6471%; resolvers 100% |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: evidence/baseline/typescript-test.2026-10-17T17-34.md and SCRATCH/issue-977-baseline-jest/coverage-summary.json.
- TypeScript post-change coverage artifact: evidence/qa-gates/typescript-test.2026-10-17T18-39.md and SCRATCH/issue-977-qa-gates-jest/coverage-summary.json.
- PowerShell baseline coverage artifact: evidence/baseline/powershell-test.2026-10-17T17-52.md and evidence/baseline/powershell-bundle-coverage.2026-10-17T17-39.md.
- PowerShell post-change coverage artifact: evidence/qa-gates/powershell-test.2026-10-17T18-30.md, evidence/qa-gates/powershell-bundle-coverage.2026-10-17T18-18.md and artifacts/pester/powershell-coverage.xml.
- Per-language comparison summary: Section 1.2.1 and evidence/qa-gates/coverage-and-size.2026-10-17T18-32.md.

## Executive Summary

This is the refreshed review after the 18-47 audit set. All prior audit/receipt evidence is preserved. No source, test, configuration, generated-profile or bundled-code file changed after the prior reviewed implementation head; the eleven intervening paths are feature Markdown only. Complete earlier toolchain and raw coverage evidence therefore remains applicable to the entire current feature-vs-base scope. No duplicate broad suite was required solely for this documentation continuation.

Fresh live reads show draft PR #978 is OPEN at remote head 6b7572ae6fcfe863d13609fe9452d5f769715209, with all 26 checks passing. The local reviewed head c9902b54ffdb146b5039d5b7aaf4c1145afe5066 contains the acceptance check-off continuation and is not yet the verified PR head. evidence/qa-gates/ci-initial.2026-10-17T19-05.md expressly limits its proof to the earlier head.

Local VSIX evidence records package/install success, 676 matching resource files and matching installed compiled server. Fresh MCP validation still applies legacy expectations to receipts 11-16. Updating installed files has not refreshed the running provider. No reload/install/source edits were performed by this reviewer.

Local implementation, toolchain and coverage gates PASS. Final operational readiness is BLOCKED by an installed-runtime mismatch (R1, external_dependency) and final-head CI (R2, awaiting_ci). No autonomous blocking finding was identified.

The canonical PR summary and appendix both record 2026-10-17 19:06:08 UTC and the reviewed head. The supplied base was verified with git merge-base main HEAD. Feature selection follows the primary changed scoping documents and branch issue suffix 977. Full feature-vs-base scope was retained; no narrowing request was supplied.

Policy sources: AGENTS.md, general-code-change, general-unit-test, Python and suppressions, PowerShell, TypeScript and suppressions; required feature-review shared skills; execution-environment. Spec Implementation Strategy explicitly authorizes the five current routing skill sources and their mirrors. No unrelated provider, dependency, topology, reasoning effort or receipt schema change was found.

## 1. General Unit Test Policy Compliance

PASS: new command and persistence tests use memory streams, named I/O/input/head/clock delegates and mocked repository boundaries. They create no temporary files or external processes. Behavior coverage includes malformed JSON, invalid HEAD, exact diagnostic JSON/exit status, exclusive stream modes, BOM-free UTF8, disposal, durable-flush errors and consume-once authorization. Existing profile, hash, topology, ceiling and model-unavailability assertions remain.

Isolation evidence inspected: reversed changed Python modules 119 passed; shuffled full Jest seed 977 passed 4105; shuffled Pester file seeds 977/1977/2977 each passed 337; fresh full configured Pester process passed 11310 with 10 baseline skips. Latest evidence/regression-testing/isolation-*.md records orders and seeds.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 94.1117% line, 88.7837% branch. Post-change: 94.1117% line, 88.7837% branch. Change: 0.0000 pp, no preserved covered-line loss. Disposition: PASS. New/changed-code coverage: resolver 100%, generator 94.5312% line / 89.1304% branch (literal/prose-only changes). Evidence: evidence/qa-gates/coverage-and-size.2026-10-17T18-32.md.
- TypeScript: Baseline: 97.4117% line, 92.6564% branch. Post-change: 97.4117% line, 92.6573% branch. Change: line 0.0000 pp, branch +0.0009 pp; changed routing 7/7 lines covered. Disposition: PASS. New/changed-code coverage: 100% changed routing lines. Evidence: evidence/qa-gates/coverage-and-size.2026-10-17T18-32.md.
- PowerShell: Baseline: 92.2321% line. Post-change: 92.6236% line. Change: +0.3915 pp; actual source/bundle hook 103/192 to 189/204; no preserved covered-line loss. Disposition: PASS. New/changed-code coverage: new method 90%, changed hook range 77.3585% (improved from 2.4390%, no covered-line loss). Evidence: evidence/qa-gates/coverage-and-size.2026-10-17T18-32.md.

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Simplicity and separation | PASS | Literal policy updates, existing resolver boundaries, narrowly defaulted test seams |
| Reuse and compatibility | PASS | Shared existing generator, no new public command, added delegates preserve defaults and existing calls |
| Physical size <=500 | PASS | Complete size inventory; independent source counts: resolver 255, generator 295, hook 426, TypeScript validator 487; new tests 136 and 226 |
| Dependencies and suppressions | PASS | No dependency manifests changed; no new suppressions in source delta |
| Explicit failures | PASS | Existing diagnostics and rejection semantics retained |
| Ordered toolchain | PASS | Complete final language evidence and independent review Python/TypeScript order |
| Authorized policy changes | PASS | Specification explicitly permits exactly five routing skills plus bundle mirrors |

## 3. Language-Specific Code Change Policy Compliance

Python PASS: TypedDict profile/receipt contracts and typed generator signatures remain; no new Any or interface. TypeScript PASS: readonly typed profile maps and exact receipt checks remain; production and test compilers pass. PowerShell PASS: advanced functions, approved verbs, named parameters and original CreateNew/Write/None or Open/ReadWrite/None stream modes; default durable Flush(true) and finally disposal preserved.

Older template PowerShell 5.1 compatibility is N/A under authoritative PowerShell 7+ rules. C# and Bash are N/A because neither has changed files. JSON routing policy and corpus are parsed by passing generator/resolver/parity contracts; no schema changes.

## 4. Language-Specific Unit Test Policy Compliance

PASS: Pytest, Jest and Pester v5 remain the established frameworks. New tests use existing codex-hooks layout and descriptive scenario names. Exact input/receipt/profile behavior is asserted without executable mocks. The approved bounded addendum covers actual imported source and actual bundled file; it does not measure rewritten source or extracted functions.

## 5. Test Coverage Detail

Governing floors: 85% line for changed production files and language totals; 75% branch where measured; 90% for new methods. CLAUDE.md declares no numerical override. Production coverage excludes tests.

| Target | Line coverage | Branch coverage | Verdict |
|---|---|---|---|
| Python repository | 16798/17849 (94.1117%) | 5723/6446 (88.7837%) | PASS |
| Python resolver | 83/83 (100%) | 18/18 (100%) | PASS |
| Python generator | 121/128 (94.5312%) | 41/46 (89.1304%) | PASS |
| TypeScript repository | 51900/53279 (97.4117%) | 7748/8362 (92.6573%) | PASS |
| TypeScript routing file | 466/487 (95.6879%) | 113/120 (94.1667%) | PASS |
| PowerShell repository | 17730/19142 (92.6236%) | N/A: Pester does not measure branches | PASS |
| Source resolver and both actual bundle copies | 68/68 (100%) each | N/A | PASS |
| Source hook and actual bundled hook | 189/204 (92.6471%) each | N/A | PASS |
| New command method, source and bundle | 36/40 (90%) each | N/A | PASS |

Raw Python baseline/final JSON, Jest summary and Pester XML were independently inspected and match the evidence. Changed executable routing ranges are 7/7 covered; hook ranges improve from 1/41 to 41/53, with no preserved covered-line losses. Overall hook and new-method thresholds pass independently. Python prose/model-data changes do not add instrumented executable ranges.

## 6. Test Execution Metrics

| Population | Baseline | Final | Independent review |
|---|---|---|---|
| Python | 7335 pass; 6 skip | 7336 pass; 6 skip; 86.36s | 142 contracts pass; 0.73s |
| TypeScript | 4104 pass; 281 suites | 4105 pass; 281 suites; 5.947s coverage | 4105 pass; 2.308s |
| PowerShell | 11271 pass; 10 skip | 11310 pass; 10 skip; 681.729s | Full run/XML inspected |
| Actual bundled PowerShell | Separately measured | 28 tests per resolver; 86 hook tests; no failures | Actual-target measurement evidence inspected |

## 7. Code Quality Checks

| Check | Result | Status |
|---|---|---|
| Black | 620 files unchanged | PASS |
| Ruff | All checks passed | PASS |
| Pyright | 0 errors/warnings/informations | PASS |
| Prettier | All matched files formatted | PASS |
| ESLint | Exit 0 | PASS |
| Both TSC populations | Exit 0 | PASS |
| Generator --check | Exit 0 | PASS |
| Full final PoshQC format/analyze/test evidence | Exit 0, no analyzer findings | PASS |
| Installed Codex receipt validator | Requires former models | FAIL: external_dependency |
| Required final PR-head CI | Earlier PR head has 26 pass; current local check-off head not yet reverified | PARTIAL: awaiting_ci |

Earlier plan/addendum EOF nits were repaired. At this reviewed head, git diff --check main...HEAD reports one extra blank EOF line in local-vsix-readiness.2026-10-17T18-54.md. Its EXIT_CODE field is mixed prose instead of a canonical integer; it was assessed as contextual operational evidence, with fresh direct MCP output independently proving R1. These are nonblocking evidence-document nits, reported to the coordinator. No implementation fixes were made during review.

## 8. Gaps and Exceptions

### Identified Gaps

R1 (Blocking): installed MCP still requires gpt-5.6-terra for current Sol receipts. Remediability: external_dependency. Spec Constraints & Risks explicitly requires a matching installed validator before authoritative completion. Branch code changes alone cannot update the installed runtime.

R2 (Blocking): SPEC-08, STORY-05 and the seeded CI condition await the required resulting-head CI re-verification. Remediability: awaiting_ci. The item's orchestrator checked these sources at the authorized S9 initial-green step; 16/16 source boxes are now checked, while only 13 criteria are fully verified and three remain conditional pending check-off push re-verification. This intermediate checkbox state is not evidence of final completion.

SearchScope: artifacts/pr_context.summary.txt, artifacts/orchestration/orchestrator-state.json and this feature's evidence folder.
SearchPatterns: CI status (HEAD), ci_gate, final PR-head, CI-dependent.
SearchResult: ci-initial evidence and live gh reads establish 26 passing checks at remote 6b7572ae6fcfe863d13609fe9452d5f769715209; no success record yet binds the local reviewed check-off head c9902b54ffdb146b5039d5b7aaf4c1145afe5066. Three criteria remain conditional. No final-head conclusion relies on file dates.

### Approved Exceptions

The checkpoint bootstrap_exception and review-977 receipt explicitly record user authorization and actual host identity for the current model migration. Historical records remain preserved. This does not certify final checkpoint validity; the coordinator owns truthful current-launch reconciliation and completion validation against the matching installed runtime.

The modified-workflow-needs-green-run rule is N/A: no changed paths in .github/workflows, scripts/benchmarks or .github/actions. No test was removed. Six Python and ten Pester skips match baseline; old failed intermediate runs are retained and superseded by complete final passes.

## 9. Summary of Changes

Policy, twelve base aliases, sixty generated variants, forced epic personas, current Python/PowerShell/TypeScript defaults, bundled mirrors and asserting tests use the approved current models. Topology, effort, ceilings, aliases, exact profile/hash and receipt shapes remain. The bounded addendum adds defaulted seams and memory-only persistence/command tests.

Progress commit: 564baabe676295fabbbeb243976a3c0ac583feff. Review head: c9902b54ffdb146b5039d5b7aaf4c1145afe5066. Executor baseline used the prior ancestor; this review independently covers the supplied current merge base and full diff.

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Local implementation and mandatory language coverage: PASS. Operational readiness: HALT_NON_REMEDIABLE because R1 is external_dependency, with R2 awaiting_ci. No autonomous blocker exists; remediation inputs are required, remediation plan and planner handoff are prohibited for this disposition. Draft PR/CI preparation can proceed under coordinator ownership; merge and DONE must wait.

## Appendix A: Test Inventory

Python independently rerun: test_resolve_codex_deployment.py, test_generate_codex_agent_variants.py, test_validate_orchestrator_state_codex_model_routing.py, test_validate_orchestrator_state_codex_topology.py, test_validate_epic_planner_state.py, test_epic_planner_launch_evidence.py, test_codex_full_migration_inventory.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_codex_agent_wrapper_contracts.py and test_codex_handoff_contract_parity.py; all under tests/scripts/dev_tools.
TypeScript: all 281 suites and 4105 tests, including exact-model rejection and epic launch/profile checks.
PowerShell: full configured 410 containers; new subagent-attestation-command/persistence.Tests.ps1 and preserved profile/provenance suites; actual bundles measured separately.
Full changed inventory: artifacts/pr_context.appendix.txt and evidence/qa-gates/execution-summary.2026-10-17T18-43.md.

## Appendix B: Toolchain Commands Reference

Independent review commands, in order per language:

- Python: poetry run black --check .; poetry run ruff check .; poetry run pyright; poetry run pytest --no-cov followed by the eleven exact tests/scripts/dev_tools paths listed in Appendix A.
- TypeScript at extension root: npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; npm run lint; npm run typecheck; node run-jest.cjs.
- Freshness: poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check.
- Scope: git merge-base main HEAD; git diff main...HEAD over source/test/config/skill scopes; git diff --check main...HEAD; git diff --name-only main...HEAD -- .github/workflows scripts/benchmarks .github/actions.
- Active-model search: rg -n 'gpt-5\\.6-(terra|luna|sol)' over .codex/agents, active routing hook/policy/skills, PowerShell resolver, Python resolver/generator and TypeScript model validator; no matches.
- Coverage: json.loads baseline/final Python and Jest summaries; ElementTree Pester LINE counters; canonical changed-line comparison and actual-bundle measurements.
- Complete executor commands: latest evidence/qa-gates/{python,typescript,powershell}-{format,lint,typecheck,test}.*.md and powershell-bundle-coverage.*.md. Full Python/Pester and actual-bundle evidence were inspected and reused. Unchanged executable files justify avoiding duplicate broad coverage runs.
- Installed MCP: validate_orchestration_artifacts with artifact_type=orchestrator-state, artifact_path=artifacts/orchestration/orchestrator-state.json, require_codex_model_routing=true, require_codex_topology=true freshly returned these exact errors:

~~~text
Checkpoint codex_model_routing_receipts[11].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[12].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[13].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[14].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[15].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[16].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[11].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[12].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[13].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[14].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[15].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
Checkpoint codex_model_routing_receipts[16].model must be 'gpt-5.6-terra', found 'gpt-6.1-sol'.
~~~

A supplemental optional require_model_routing=true invocation also reported generic model_routing_receipts absent for atomic-executor, atomic-planner, commit-steward, feature-review, orchestrator-c3, prd-feature and task-researcher. That provider-generic flag is separate from governing Codex validation; coordinator owns any final generic checkpoint requirements. It does not change the approved model equivalence.


Current review-only checks: git diff --stat 9f7432dedd5456167e04595bf73bd6f27aa5d4cf..HEAD; git diff --name-only 9f7432dedd5456167e04595bf73bd6f27aa5d4cf..HEAD -- . ':!docs/features/active/2026-10-17-current-codex-model-routing-977'; gh pr view 978 --json headRefOid,state,isDraft,url; gh pr checks 978 --json name,state,bucket; fresh MCP Codex topology/model validation. Earlier ordered language runs in this same review task are reused after verifying no executable drift. Initial CI and local VSIX documents were read in full. The older audit set remains authoritative evidence for its historical head only.
Coordinator continuation after the reviewed committed head corrected local-vsix-readiness to integer EXIT_CODE: 0 for package/install/file verification with separate MCP_VALIDATION_OK: false and preserved exact rejection. EOF whitespace was trimmed. Reviewer read the corrected fields and git diff --check main now passes; no source or test changes occurred. These nonblocking documentation corrections do not clear R1/R2.
