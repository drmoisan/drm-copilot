# Code Review: Devcontainer current baseline (#1082)

Review Date: 2026-11-05T06-53 UTC
Reviewer: independent feature-review worker
Feature Folder: docs/features/active/2026-11-04-devcontainer-current-baseline-1082
Base Branch: main; merge base df65c30ccc98f89f9808e84ca393c8d75c805641
Head Branch: bug/devcontainer-current-baseline-1082 @71350a287101906f3f1aeef7dba4cf039aeba07b
Review Type: initial complete feature-vs-base review
Template: MCP code-review-template, copied before completing this artifact.

## Executive Summary

Reviewed all 285 changed paths, including the earlier unmerged container commits. The implementation replaces separately seeded source with a live local bind, isolates four Linux dependency directories, installs the requested pinned environment, shares setup/verification, migrates PoshQC to Pester 6.2 and synchronizes host/CI/docs/bundles. All 78 changed paths outside feature documentation match the retained tested snapshot byte-for-byte.

No autonomous implementation blocker or Major finding was identified. CI-1 is blocking and classified awaiting_ci. Local verification passes; affected workflow runner execution and final-head AC12 remain unverified. Normal PR creation and CI may proceed; merge readiness remains blocked.

Remaining risks: actual runner execution of four modified workflows; final PR-head checks; runtime validation was amd64 and used the Codespaces configuration locally rather than hosted provisioning. No additional platform claim is made.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | .github/workflows/_build-check.yml, _quality-checks.yml, _security-scan.yml, _poshqc.yml; spec.md | version/import hunks; AC12 | CI-1: no qualifying green workflow run or final PR-head checks; Remediability: awaiting_ci | Run affected workflows through normal PR CI; record URL, SHA and conclusion; complete S9/AC12 | modified-workflow-needs-green-run and explicit CI-dependent criterion | gh run list returned []; fresh context CI unavailable; AC12 unchecked |
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

Four workflow changes update Poetry/Pester selections without changing jobs, matrices, conditions or accounting. No modified step intentionally invokes a failing nested command. Actionlint passes but does not satisfy CI-1. Consumer package engines and Python 3.11/3.12 compatibility jobs are unchanged. Root/container guides and six execution-environment mirrors agree. Floating Git/GitHub CLI features no longer override image pins.

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
| Workflow runtime | UNVERIFIED | CI-1 awaiting_ci; no branch runs returned |

## Research Log

No additional external research was required. Feature research is secondary release-selection evidence; actual builds/runtime results and independent verifier establish local behavior. No external availability claim is inferred from memory.

## Verdict

AWAITING_CI. Proceed to the ready-for-review PR and CI; do not merge or report overall completion until affected workflows have qualifying successful runs and S9/AC12 bind the exact final PR head. No autonomous implementation finding requires planning. Wait-only remediation inputs exist; REMEDIATION_PLAN: NONE.
# Current CI Coordination Update

The orchestrator reports workflow_dispatch run 41984047891 in progress at the exact reviewed head 71350a287101906f3f1aeef7dba4cf039aeba07b: https://github.com/drmoisan/drm-copilot/actions/runs/41984047891. The earlier empty-run search is retained as historical evidence. This pending run is not a green result; CI-1 and AC12 remain awaiting_ci.
