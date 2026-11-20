# Code Review: Devcontainer current baseline (#1082)

Review Date: 2026-11-05T07-24 UTC
Reviewer: independent feature-review worker
Feature Folder: docs/features/active/2026-11-04-devcontainer-current-baseline-1082
Base Branch: main; merge base df65c30ccc98f89f9808e84ca393c8d75c805641
Head Branch: bug/devcontainer-current-baseline-1082 @184098c31a93bcac6e4473674e55e9713b57d734
Review Type: complete feature-vs-base re-review after CI closure
Template: MCP code-review-template, copied before completing this artifact.

## Executive Summary

Reviewed all 292 changed paths, including the earlier unmerged container commits. The implementation replaces separately seeded source with a live local bind, isolates four Linux dependency directories, installs the requested pinned environment, shares setup/verification, migrates PoshQC to Pester 6.2 and synchronizes host/CI/docs/bundles. All 78 changed paths outside feature documentation match the retained tested snapshot byte-for-byte.

No implementation blocker or Major finding was identified. CI-1 is CLOSED after 26 unfiltered checks and both workflow runs succeeded at the current head. PR readiness is GO at that head, subject to renewed S9 verification after the review/AC metadata commit.

Remaining limitations: runtime validation was amd64 and used the Codespaces configuration locally rather than hosted provisioning. The upcoming metadata head still requires exact-head S9 validation.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | Four changed workflows; spec.md AC12 | CI-1 closure | All 26 checks pass and both workflows succeeded at 184098c31a93bcac6e4473674e55e9713b57d734; prior awaiting_ci finding CLOSED | Commit metadata and repeat exact-head S9 verification | Required workflows have current green evidence; future heads require their own gate | CI41984585912; extension41984585939; ci-green-before-checkoff07-22 |
| Warning | tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | whole file | 766 logical lines reaches the 700-line advisory tier | Consider a coherent split in future maintenance | Non-blocking advisory; below 800 hard limit | Independent 51-file sweep; baseline unchanged |
| Info | .devcontainer/post-create.sh | line 175 | Full main-base changed Bash coverage is 122/123; missing-lock skip-message line uncovered | Use full-base metrics in PR/audits; no new test required solely for this log line | Added block 13/14 = 92.8571%; file 101/118 = 85.5932%; thresholds pass | Actual final Cobertura mapped to main; provenance evidence |
| Info | installed MCP provider; scripts/powershell/PoshQC | Pester import | Cached provider imports Pester 5; ok=true receipts establish invocation only | Keep invocation and native Pester 6 evidence distinct | Current source/bundle parity and real native 6 reports establish feature behavior | MCP receipts 04-45; final native JaCoCo/JUnit and source binding |

## Implementation Audit

### Python implementation audit

Only two contract-test modules change. New functions/parameters are typed; parsed JSON casts retain defined shapes. No production API, Any, suppression or broad exception boundary is introduced. Static contracts check exact pins/mounts and retained real runtime evidence confirms installation. Independent Black, Ruff, Pyright and 55 tests pass.

### PowerShell implementation audit

Installation and presence/import boundaries agree on PSSA 1.25 and Pester >=6.2,<7. JaCoCo replaces the removed coverage selection while preserving paths, configured roots, shards, merge and completeness consumers. Canonical and bundled files/settings are byte-identical.

Test changes preserve exact Should -Invoke count/scope/filter assertions. Configuration mock type removal is confined to fake configurations. Dependency-failure fixtures retain native cmdlets outside the selected error. Per-test committed/synthetic fixture readers preserve null isolation outside approved paths. Reset-EpicStateProbeModuleBinding removes only stale fixture-root scope instances and uses ShouldProcess and explicit errors. Three touched-suite seeds, complete serial and complete concurrent runs pass. No orchestration production behavior is changed.

### Bash and container implementation audit

workspace.sh separates exact Git trust, mount-root ownership and broken-venv recovery. Four volume-nocopy mounts prevent host dependencies from entering Linux dependency trees. Cleanup retains mounted roots; source/data/old workspace volume remain. GIT_CONFIG_* disables fsmonitor only in the local container environment, avoiding .git/config mutation.

Verifier definitions are source-safe, normalize native formats and Codex setup warnings, reject missing/failed/unreadable/unsupported probes, collect errors and return nonzero before completion. Numeric inputs are bounded before arithmetic. Python supports later selected-minor patches, Git is a minimum and other tools are exact pins.

Both Dockerfiles select the same authorized base/pins and preserve supporting tools. Codex native optional packages are installed; system update/credential-store settings contain no authentication values. Empty user-state directories have vscode ownership. Full feature-inclusive local and Codespaces-mode lifecycle/repeat evidence exists. Windows bind traversal latency remains documented.

### Workflow and documentation audit

Four workflow changes update Poetry/Pester selections without changing jobs, matrices, conditions or accounting. No modified step intentionally invokes a failing nested command. Actionlint passes; actual current-head CI now satisfies the independent workflow requirement. Consumer package engines and Python 3.11/3.12 compatibility jobs are unchanged. Root/container guides and six execution-environment mirrors agree. Floating Git/GitHub CLI features no longer override image pins.

## Test Quality Audit

Inspected retained actual Python coverage JSON/JUnit, shell Cobertura/TAP, Pester merged JaCoCo/JUnit, baselines, final source mapping, lifecycle/preservation, contracts/parity, isolation and native format/analyzer receipts. Policy audit and independent provenance identify them.

Full results: Python 16,099 passed / 6 existing skips; Bats 799 passed; Pester 14,288 passed / 10 existing skips across 507 files with all 271 configured production files retained. Final line coverage: Python 96.7123%, PowerShell 93.7821%, Bash 95.1829% production / 89.0860% raw. Python branches 93.6561%. Full-base changed Bash 122/123; PS 3/3; new helper 16/16. All governing thresholds pass. Focused Pester baseline and complete final cohort are not presented as a like-for-like gain.

Independent checks pass: ordered Python Black/Ruff/Pyright/55 tests; Bash shfmt/ShellCheck/syntax/38 tests; full local runtime verifier. Unit boundaries use in-memory seams; real builds/probes are integration evidence. No new skip or weakened assertion found. Historical failures are retained and excluded from final passing results.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in changed configuration | PASS | Empty user-state directories; system settings have no authentication values |
| Safe commands / boundary checks | PASS | Quoted paths, fixed tool list, bounded numeric inputs |
| Failure propagation | PASS | Cleanup/probe errors return nonzero; verifier precedes setup banner |
| Path/configuration preservation | PASS | Four volume-nocopy mounts, exact trust, retained old volume and host-state evidence |
| Fixture isolation | PASS | Null/path boundaries, scoped module reset, serial/shuffled/cohort checks |
| Workflow runtime | PASS | Exact-head CI and extension workflows completed successfully; all26 unfiltered checks pass |

## Research Log

No additional external research was required. Feature research is secondary release-selection evidence; actual builds/runtime results and independent verifier establish local behavior. No external availability claim is inferred from memory.

## Verdict

PASS. PR #1083 is ready at the reviewed head with all 26 checks passing. No autonomous or external blocker remains. Commit/push the review/AC metadata and renew the final exact-head S9 gate before merge or DONE. No remediation inputs/plan or planner delegation is needed for this review.

## CI Closure and Historical Review

CI closure verified against 184098c31a93bcac6e4473674e55e9713b57d734: all 26 unfiltered PR checks pass (zero skipped, failed or pending). CI run41984585912 and extension run41984585939 are completed/success at that exact head, independently confirmed with gh run view. The CI run includes successful changed build, quality, security and PoshQC jobs. Evidence: evidence/qa-gates/ci-green-before-checkoff.2026-11-05T07-22.md. CI-1 is CLOSED. The prior 06-53 AWAITING_CI artifacts remain immutable history; manual run41984047891 at the earlier head was cancelled and is excluded.

The item's orchestrator checked AC12 after observing this green gate. This review is PASS at the reviewed head and metadata working state. The ensuing review/AC metadata commit must be pushed and receive complete renewed exact-head S9 verification before overall DONE. If only active-feature metadata changes after a qualifying green run, the modified-workflow predecessor-head allowance applies; the policy audit explicitly leaves ci_gate.conclusion == "success" and ci_gate.head_sha == final PR head as S9 obligations. This is not an assertion about CI on an unseen future commit.

No source/test file changed since the independent full-main inspection and native verified snapshot. The seven newly added branch paths are prior review/evidence artifacts; full main-base scope is now292 paths, with the same78 implementation/configuration/documentation paths outside the feature folder. Full-main coverage remains Bash122/123 and PowerShell3/3; no source fix or new test was introduced during review.
