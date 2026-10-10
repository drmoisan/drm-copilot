# Feature Audit: Hook pre-existing imports fail open (#786, bundled #792)

---

**Audit Date:** 2026-10-10
**Feature Folder:** `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786`
**Base Branch:** `origin/epic/enforcement-hook-precision-integration`
**Head Branch:** `origin/bug/hook-preexisting-imports-fail-open-exec-786` (`76559b6df`)
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/enforcement-hook-precision-integration` (commit `86e457a003be0c60b65e01156e4cccd6495dfd1a`)
- **Head branch/commit:** `bug/hook-preexisting-imports-fail-open-exec-786` (commit `76559b6df0c93b85973cadb1d46ffe49c5778ded`)
- **Merge base:** `86e457a003be0c60b65e01156e4cccd6495dfd1a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated 2026-10-10 10:48 UTC, Head SHA `76559b6df`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/**`
  - Additional evidence: reviewer check-only commands (Appendix B of `policy-audit.2026-10-10T06-50.md`)
- **Feature folder used:** `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; per the acceptance-criteria tracking rules, `spec.md` is the only AC source. `user-story.md` is intentionally absent (spec header).
- **Scope note:** The branch carries a merge of the epic integration branch (`956700942`); the merge base equals the current tip of the PR base, so the diff is the branch's own work. The spec header names `bug/hook-preexisting-imports-fail-open-786`; the pushed branch is `bug/hook-preexisting-imports-fail-open-exec-786`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md` — only source (27 checkbox items, `## Acceptance Criteria`)

### Acceptance criteria

1. AC-1: Regression-first evidence (per-hook import-failure tests run on the unmodified integration branch; failures recorded under `evidence/baseline/`).
2. AC-2: Mechanical enumeration (research Q3 AST script on repository and mirror roots; FR-9.2 reconciliation recorded under `evidence/other/`).
3. AC-3: `hook-dependency-guard.ps1` at every FR-1.1 path, byte-identical, import-free, listed in both core pack manifests and in `$script:SharedModuleNames`.
4. AC-4: Helper unit tests pass for both production copies and cover the listed behaviours.
5. AC-5: Every script-scope import and dot-source in its own single-statement `try`; every guarded `Import-Module` uses `-ErrorAction Stop`; verified by the AC-11 structural test.
6. AC-6: Claude PreToolUse per-edge tests assert a deny with the existing leading token naming the dependency; the entry point returns exit 0 with the deny JSON and calls no HookPayload function.
7. AC-7: Codex PreToolUse per-edge tests assert a deny with the existing leading token naming the dependency.
8. AC-8: SubagentStop per-edge tests on both surfaces assert exit 2 with a stderr reason naming the dependency; existing exit-1 paths unchanged.
9. AC-9: Nested failures reported as the enclosing top-level edge.
10. AC-10: Helper bootstrap flag set without a function call; structural test asserts bootstrap `try` and tail check.
11. AC-11: Structural completeness test (registration discovery, AST closure, repository and mirror roots, named exemptions only, including the 2026-10-09 handler exemptions that passed their proof).
12. AC-12: No `$script:<Name>ImportFailure` or `Import guard (issue #690)` remains except the named-exemption variables; updated `*.WorktreeResolution.Tests.ps1` pass; merge-gate dependency path calls nothing from `-authorization.ps1`.
13. AC-13: Runtime imports pre-loaded under a guard; lazy branch skipped; pre-load failure blocks; FR-7.3 deviation recorded.
14. AC-14: Mermaid D2 exemption holds while a `HookPayload.psm1` failure denies.
15. AC-15: Codex D3 absent skip and present-failure deny, on each hook performing the conditional dot-source.
16. AC-16: `validate-bash.ps1` denies with `HOOK_DEPENDENCY_LOAD_FAILED:`; other tokens unchanged.
17. AC-17: With all dependencies loaded, every pre-existing hook suite passes with no assertion changes other than the AC-12 variable-reset updates.
18. AC-18: #792 guard discovers registered hooks and walks the transitive closure; fails on the listed write forms.
19. AC-19: #792 guard proven able to fail through a text seam, with allowed forms not reported.
20. AC-20: Hook entry-point scripts outside the #792 guard's scope.
21. AC-21: Diagnostics to `[Console]::Error.WriteLine`; #792 guard passes after rebase.
22. AC-22: #792 guard runs over both surfaces and both mirror roots; mirror findings equal repository findings.
23. AC-23: Every changed hook/lib/script file byte-identical to its mirror; parity, manifest, and legacy contract suites pass.
24. AC-24: Line coverage >= 85% for each changed or created PowerShell production file, bootstrap `exit 2` lines listed as known uncovered; no changed line loses coverage.
25. AC-25: Every changed or created PowerShell file at most 500 lines; near-cap files re-measured.
26. AC-26: No hook or helper invokes Python; no-Python guard files unmodified and pass; discovery helper is a new test-support file.
27. AC-27: PowerShell toolchain passes in a single pass (format, analyze with zero errors and warnings on changed files, Pester).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 regression-first | PASS | `evidence/baseline/regression-first-summary.md`, `evidence/regression-testing/fail-before-*.md` | evidence inspection | Recorded before commit `261c77ffb` (first production change). |
| 2 | AC-2 enumeration | PASS | `evidence/other/hook-dependency-enumeration-repo.md`, `-mirror.md`, `hook-dependency-reconciliation.md` | evidence inspection | |
| 3 | AC-3 helper copies | PASS | sha1 `88bf9f82...` identical for all four copies; no `Import-Module`, dot-source, or stream write; listed in both `core.json` (lines 65, 49) and in `$script:SharedModuleNames` | `sh <SCRATCHPAD>/checks.sh` (sha1sum, grep) | Reviewer-verified. |
| 4 | AC-4 helper tests | PASS | `tests/scripts/{claude,codex}-hooks/hook-dependency-guard.Tests.ps1` pass in the full run | JUnit in `final-pester-coverage.md` | Codex copy coverage attribution is AC-24's concern, not test outcome. |
| 5 | AC-5 single-statement guards | PASS | S2, S3 rows of `hook-dependency-guard-completeness.Tests.ps1` pass on repository and mirror roots | `p9-structural.md` | Spot-checked in `enforce-feature-folder-order.ps1`, `enforce-epic-wave-barrier.ps1`, `validate-orchestrator-output.ps1`. |
| 6 | AC-6 Claude PreToolUse per edge, no HookPayload call | PARTIAL | B1 rows assert deny, token, dependency, and `Read-ClaudeHookRawPayload`/`Resolve-ClaudeHookToolInput` invoked 0 times for every non-exempt edge. For the exempt `feature-folder-resolution.ps1` edges of H1, H4, H5, H6 the FailClosed rows assert deny with the existing token naming the dependency, but the entry point reads the payload first. | `hook-dependency-failure.Claude.Tests.ps1:27-28, 143-157`; `enforce-epic-wave-barrier.ps1:360-366` | The 2026-10-09 amendment did not extend to AC-6. Needs operator decision. |
| 7 | AC-7 Codex PreToolUse per edge | PASS | `hook-dependency-failure.Codex.Tests.ps1` B1 rows pass | `p7-codex-suites.md` | |
| 8 | AC-8 SubagentStop exit 2 | PASS | B1 SubagentStop rows assert exit 2 and stderr; `validate-orchestrator-output.ps1` EAP moved after guards; exit-1 paths unchanged (diff adds no change to `Write-Error`/`exit 1` lines of the six validators) | `git diff -U0 ... -- <six validators>` | H7/H8 conversion applies only to dependency-failure paths. |
| 9 | AC-9 nested failures | PASS | SpecialCases nested rows | `p6-special-cases.md` | |
| 10 | AC-10 bootstrap | PASS | B2 rows per hook; S1 rows; C8 fresh-runspace row asserts exit 2 | `p6-special-cases.md`, `p9-structural.md` | |
| 11 | AC-11 structural completeness with named exemptions | PASS | `HookImportFailureExemptions.Helpers.ps1` lists D2, D3, H1 to H6 (H2 on both surfaces), each with justification; H7/H8 absent; F1 to F8 fixtures pass | file inspection; `p9-structural.md`, `p9-exemption-guard.md` | Each listed handler has a FAIL-CLOSED proof (Notes below). |
| 12 | AC-12 #690 remnants | PASS | Remaining `ImportFailure` variables under `.claude/hooks` and its mirror are exactly the six H1 to H6 names; H7 and H8 variables removed; no `Import guard (issue #690)` comment; merge-gate resolution file no longer defines or calls the authorization deny | reviewer grep (`checks.sh`, "690 REMNANTS"); `git diff` of `enforce-epic-merge-gate-resolution.ps1` | |
| 13 | AC-13 runtime pre-loads | PASS | Pre-loads present with `-Global` (RS-10); FR-7.3 disproved in full-run context and recorded | `deviations.md` [P10-T1] | Deviation recorded as required. |
| 14 | AC-14 mermaid D2 | PASS | SpecialCases D2 rows | `p6-special-cases.md` | |
| 15 | AC-15 Codex D3 | PASS | Codex suite D3 rows on both hooks | `p7-codex-suites.md` | |
| 16 | AC-16 validate-bash token | PASS | `HOOK_DEPENDENCY_LOAD_FAILED:` prefix in both copies | reviewer grep; B1 rows | |
| 17 | AC-17 no assertion changes | PASS | Pre-existing test diffs consist of variable-reset or arrange-side `Add-HookDependencyFailure` updates, plus the seven H7/H8 changes recorded in `handler-conversions.md`, for which the Change Log takes precedence over AC-17 | `git diff -U0 --diff-filter=M ... -- tests/` | See conversion detail below. |
| 18 | AC-18 #792 discovery and detection | PASS | N1, N3, N4 rows | `p9-stdout-guard.md` (25 passed) | |
| 19 | AC-19 #792 can fail | PASS | N4 (12 forms), N5 (6 allowed forms), N6 synthetic transitive offender | `p9-stdout-guard.md` | |
| 20 | AC-20 entry scripts out of scope | PASS | N7, N8 | `p9-stdout-guard.md` | |
| 21 | AC-21 stderr diagnostics, guard passes | PASS | N1 passes on repository roots after the epic merge | `p9-stdout-guard.md` | |
| 22 | AC-22 mirror roots | PASS | N1 on mirror roots; N2 mirror equals repository | `p9-stdout-guard.md` | |
| 23 | AC-23 mirror parity | PASS | 57 of 57 changed hook files equal to their mirrors; pytest guards 33 passed; legacy contracts pass | reviewer `cmp` loop; `final-pytest-guards.md`; `final-mirror-parity.md` | |
| 24 | AC-24 per-file line coverage >= 85% | FAIL | Full run: `.codex/hooks/enforce-epic-child-worktree-binding.ps1` 74.70, `enforce-epic-planning-only.ps1` 82.25, `hook-dependency-guard.ps1` 57.89, `validate-bash.ps1` 80.25; changed lines uncovered at `hook-dependency-guard.ps1:103-111`, `validate-bash.ps1:305-306`, `enforce-orchestration-preimplementation-gate.ps1:467-468` (non-bootstrap) | `final-pester-coverage.md`; reviewer parse of `artifacts/pester/powershell-coverage.xml` | Attribution cause asserted by the executor, not verified by this review. |
| 25 | AC-25 500-line cap | PASS | Max 500 (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and mirror) | reviewer `wc -l` | Zero headroom on that file. |
| 26 | AC-26 no Python | PASS | Added hook lines matching `python|poetry|py -m` are 12 string-literal reason prefixes; no invocation. No-Python guard files unmodified (`git diff --stat` empty); guard suite 32 passed; `HookDependencyGraph.Helpers.ps1` is a new file | `checks.sh`; `p9-no-python.md` | Plan check [P9-T7] (c) is stricter than AC-26 and is a plan defect, not an AC gap. Newly checked off. |
| 27 | AC-27 toolchain single pass | PASS | QC pass 4: Formatted 0, PSSA 0 findings on 92 files, Pester 9495 passed and 0 failed | `final-poshqc-format.md`, `final-poshqc-analyze.md`, `final-pester-coverage.md` | AC-27 names format, analyze, and Pester; per-file coverage is evaluated under AC-24. Newly checked off. |

### Operator decision 2026-10-09: exemptions and conversions

| Handler | Upstream | Decision | Proof result | Reviewer assessment |
|---|---|---|---|---|
| H1 `enforce-feature-folder-order.ps1` | #565 | EXEMPT | FAIL-CLOSED (4/4 rows) | Sound. BF-1 correctly decided: resolver functions are called only after the plan-path gate and the failure check; non-plan writes are never subject to a resolver-dependent check. |
| H2 preimplementation-gate modes (both surfaces) | #565 | EXEMPT | FAIL-CLOSED (8/8) | Sound. The `feature-folder-resolution-import` failure precedes every resolver call in both readiness predicates. |
| H3 `enforce-prd-feature-before-planner-helpers.ps1` | #565 | EXEMPT | FAIL-CLOSED (2/2) | Sound. `$null` work mode causes `PRD_FEATURE_BLOCKED:`. |
| H4 `enforce-epic-wave-barrier.ps1` | #565 | EXEMPT | FAIL-CLOSED (2/2) | Sound. Unconditional deny before payload parsing in the decision function. |
| H5 `enforce-parallel-drift-gate.ps1` | #565 | EXEMPT | FAIL-CLOSED (2/2) | Sound. Same shape as H4. |
| H6 `enforce-parallel-cohort-barrier.ps1` | #565 | EXEMPT | FAIL-CLOSED (2/2) | Sound. Same shape as H4. |
| H7 `validate-orchestrator-output.ps1` resolver imports | #787 | CONVERT | FAIL-OPEN | Correct. `Write-Error` then `exit 1` does not block a SubagentStop; no `exit 2` in either file. |
| H8 `validate-orchestrator-output.ps1` Layer 2 import | #840 | CONVERT | FAIL-OPEN | Correct on the cited code path. The runtime proof row did not reach the epic leg (a host-state `TARGET_WORKTREE_AMBIGUOUS` block was observed); the decision rests on the cited exit-1 tail. |
| #850 `WorktreeItemResolution.psm1` guard | #850 | migrated with #690 | n/a | Correct. It recorded into `$script:EpicMergeGateResolutionImportFailure` and denied through the #690 function; it now records through the helper next to the run-resolver guard. |

### Converted-handler assertion changes (H7, H8)

Seven test lines changed, recorded in `evidence/other/handler-conversions.md`:

| File:line | Before | After | Reason |
|---|---|---|---|
| `validate-orchestrator-output-resolution.Tests.ps1:226` | reset `$script:OrchestratorOutputResolverImportFailure` | reset `$script:HookDependencyFailures` | H7 handler variable removed; failure now recorded by the helper. |
| `validate-orchestrator-output-resolution.Tests.ps1:230` | `Message` contains `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` | `ExitCode` is 2 | Dependency failure now blocks through the helper (exit 2 per D1). |
| `validate-orchestrator-output-resolution.Tests.ps1:231` | `Message` contains `RESOLVER_IMPORT_FAILED` | `Reason` starts with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` | Helper reason replaces the #787 code `RESOLVER_IMPORT_FAILED`. |
| `validate-orchestrator-output-resolution.Tests.ps1:232` | `Message` contains `WorktreeRunResolution.psm1` | `Reason` contains `WorktreeRunResolution.psm1` | Result shape changed from `Message` to `Reason`. |
| `validate-orchestrator-output.WaveBarrier.Tests.ps1:242` | reset `$script:OrchestratorOutputWaveBarrierImportFailure` | reset `$script:HookDependencyFailures` | H8 handler variable removed. |
| `validate-orchestrator-output.WaveBarrier.Tests.ps1:246` | `Message` starts with `EPIC_WAVE_BARRIER_UNEVALUABLE:` | `ExitCode` is 2 | Dependency failure now blocks through the helper; the leading token becomes `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and is no longer asserted (code review, Minor). |
| `validate-orchestrator-output.WaveBarrier.Tests.ps1:247` | `Message` contains `OrchestratorStateEpicWaveBarrier.psm1` | `Reason` contains `OrchestratorStateEpicWaveBarrier.psm1` | Result shape changed. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 25 criteria
- **PARTIAL:** 1 criterion (AC-6)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (AC-24)

**Top gaps preventing PASS:**

1. AC-24: four changed Codex files below 85% line coverage and changed lines reported uncovered in the standard full run (blocking; uniform policy gate).
2. AC-6: named-exemption edges H1, H4, H5, H6 acquire the payload before denying (blocking; requires an operator decision on the AC text or the handler placement).

**Recommended follow-up verification steps:**

1. After remediation, re-run `Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` in-repo and re-record per-file coverage and the coverage comparison under `evidence/qa-gates/`.
2. After the AC-6 decision, re-run the B1 and FailClosed suites and record the outcome.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

Newly checked off in `spec.md` by this review: AC-26 and AC-27. AC-1 to AC-5 and AC-7 to AC-23 and AC-25 were already checked and are confirmed PASS. AC-6 and AC-24 remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md`
- Total AC items: 27
- Checked off (delivered): 25
- Remaining (unchecked): 2
- Items remaining: AC-6 (named-exemption edges acquire the payload before denying); AC-24 (four Codex files below 85% line coverage; changed lines uncovered in the full run)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md` | 27 | 25 | 2 | Checkbox-backed; AC-26 and AC-27 checked off by this review. |
