# Code Review: Round-2 review nits and evidence timestamps (#903)

---

**Review Date:** 2026-10-13
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903`
**Base Branch:** `origin/main` (`fd81a43b4`)
**Head Branch:** `bug/round-2-review-nits-and-evidence-timestamps-903` (`fcd493fa1`)
**Review Type:** Initial review

**Total blocking findings: 1** (CR-A, Blocker).

---

## Executive Summary

The branch implements issue #903 P7 (UTC write-time evidence stamps documented in six `evidence-and-timestamp-conventions` copies and six `atomic-plan-contract` copies) and the P8 review-note fixes across Python, PowerShell, and TypeScript. Production behavior changes are confined to the six items the issue names: #797 CR-1, #565 CR-8, #565 CR-2, #736 O-4, #732 CR-2, and #732 CR-6, plus the #732 CR-3 refactor. Every root copy is byte-identical to its bundle mirror (reviewer `cmp` over 17 pairs), and the Claude and Codex targets and feature-folder-resolution copies are byte-identical to each other.

Evidence reviewed: the full `origin/main...HEAD` diff of all production files, the new and changed test rows, the CI coverage XML for baseline run 38386628228 and final run 38410234897 (re-read per line by this reviewer), the CI junit files, and the feature-folder evidence. Reviewer reruns: black and ruff on the eight changed Python files (clean), targeted pytest (188 passed, `_blast_radius_token_shapes` 100% line and branch), and `validate_evidence_locations.py` (exit 0).

**What changed:**
- `enforce-orchestration-preimplementation-gate-targets.ps1` (4 copies): identifier-boundary `GIT_*` relocation regex, `git`-absent guard returning `git-command-word-missing`, rename to `New-OrchestrationTargetResult` with a justified suppression, 120-column wraps, and the new pure `Resolve-OrchestrationEpicTargetOutcome`.
- `enforce-orchestration-preimplementation-gate-epic-scope.ps1` (4 copies): tail delegates to the shared outcome function with an injected readiness predicate.
- `enforce-orchestration-preimplementation-gate-modes.ps1` (4 copies): bare-hash fallback disabled when a cited folder matches no record.
- `feature-folder-resolution.ps1` (4 copies): trim set extended with `)`, `]`, `>`, `*`, `_`.
- `enforce-completion-consistency.ps1` (2 copies): `Invoke-CompletionConsistencyEntryPoint` fails closed.
- `_blast_radius_token_shapes.py` and `BlastRadiusTokenShape.psm1`: reject non-ASCII extensions before lower-casing.

**Top 3 risks:**
1. Measured changed-line coverage regression on the Codex targets copy (lines 356 and 370), which the repository coverage policy does not permit (CR-A).
2. The CI coverage instrument does not attribute the Codex epic-scope deny path to `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206-207`, although a Codex suite in the same job drives that path in-process; the cause is not determined (CR-B).
3. #565 CR-8 tightens behavior: a prompt citing a renamed folder with only a bare `#<n>` is now denied as `target-record`. This is intended and documented, but it can surprise operators until they use the keyed `issue_num:` form.

**PR readiness recommendation:** **Needs Revision** — the implementation is sound and CI is green, but one changed-line coverage regression must be closed before the PR is opened.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | lines 356, 370 (`Get-OrchestrationEpicTargetDenyReason` target-ambiguous and fall-through returns) | Both statements were covered at baseline (lines 318 and 327, `ci` 1) and are uncovered at head (`ci` 0) after the CR-4 wrap. The Claude copy's same lines are covered. Per-file coverage drops 100.0% -> 98.16%. | Add surface-parameterized rows to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` (U25 extension or a new row) that assert the exact reason text for `-ReasonCode 'target-ambiguous'` and for an unrecognized code. The Codex leg of that suite already attributes coverage to the Codex copy (lines 360 and 364). | Violates the uniform "no regression on changed lines" gate and the general unit-test rule that changes must not reduce coverage for changed lines. | Reviewer awk over `artifacts/scratch-903/ci-baseline-903/powershell-coverage.xml` (318 ci=1, 327 ci=1) and `ci-final2-903/powershell-coverage.xml` (356 ci=0, 370 ci=0); `evidence/qa-gates/ps-coverage.2026-10-13T14-28.md` |
| Minor | `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | lines 206-207 | Deny-outcome return is reported uncovered. Not a regression: the replaced baseline statements (202-217) were also `ci` 0, and the file rose from 78.33% to 89.09%. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1` runs in the Windows coverage job and asserts deny decisions through this path, yet no hits are attributed. | Cover in the same remediation if a row can attribute hits (for example a direct `Get-OrchestrationEpicScopeDecision` call from a suite that dot-sources the Codex file), or record a plan exemption; open an operator follow-up on the attribution anomaly. | The plan's P12-T24 rule calls this blocking, but repository policy does not, because there is no regression and the file is above 85%. | `evidence/qa-gates/ps-coverage.2026-10-13T14-28.md`; reviewer awk (206 ci=0, 207 ci=0); junit shows the Codex suite (14 tests) in `pester-junit.xml` |
| Minor | `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/plan.2026-10-11T10-39.md` | P12-T24, P12-T28 | Both plan tasks remain unchecked because their acceptance failed. | Re-run both after the CR-A remediation and check them off. | Plan completion is a precondition of the pr-author gate. | `plan.2026-10-11T10-39.md` lines 373, 379 |
| Nit | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (and 3 copies) | `Resolve-OrchestrationEpicTargetOutcome`, foreach body | `$scope = $evaluation.Scope` is assigned, then `& $ReadinessFailure $evaluation.Scope` re-reads the property. | Pass `$scope` to the predicate. | Readability only; no behavior change. | Diff inspection |
| Nit | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (and 3 copies) | lines 409, 474 | The CR-8 edit extends two lines already over 120 characters. CR-4's 120-column rule applies to the targets file only, and the analyzer is clean. | Wrap the next time the modes file is edited; it is at 496 lines, so a split may be needed first. | Consistency with the targets-file wrapping. | Diff inspection |
| Nit | `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/other/preflight-clearance.2026-10-11T16-17.md` | `Timestamp:` row | Row carries a `(UTC)` suffix; the new P7 rule says the value is written without a zone suffix. The file predates the skill edit, and the rule forbids renaming existing evidence. | No action. | Recorded for completeness. | Reviewer comparison of every evidence filename stamp with its `Timestamp:` row |
| Info | `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` and three EpicStateIsolation suites | whole files | #737 F-1/F-2 withheld; the four files have no net diff from `origin/main`. Every Discovery finding carried the F-2 literal; F-1 was withheld with it without isolated evidence that F-1 alone raises findings. | When Operator Follow-up 10 is picked up, evaluate F-1 separately from F-2. | F-1 may be deliverable independently. | `evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md`; `git diff --stat origin/main...HEAD` over the four paths is empty |
| Info | `.claude/hooks/enforce-completion-consistency.ps1` | line 484 | The tail call is uncovered because the dot-source guard returns before it; the logic is in the covered `Invoke-CompletionConsistencyEntryPoint`. | No action. | Same shape as the pre-existing tail line. | `evidence/qa-gates/ps-coverage.2026-10-13T14-28.md` |

One Blocker. No Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `is_file_shaped_component` adds `if not extension.isascii(): return False` before `extension.lower()`, which closes the Kelvin-sign (U+212A lower-cases to `k`) acceptance without changing `FILE_EXTENSION_PATTERN_TEXT`, so the PowerShell parity test that reads the pattern text stays valid.
- `npm_token_guard_test_support.py` moves detection helpers out of the test module, so the test module drops from over 500 lines and test-to-test imports are avoided.
- `test_evidence_timestamp_contracts.py` extracts the named section first and checks fragments as substrings, so a failure names the missing fragment.

#### Typing and API notes

- No new public Python production API. Test-support functions are annotated.

#### Error handling and logging

- No change.

### TypeScript implementation audit

#### What changed well

- `subagent-tree-command-test-support.ts` replaces a host-specific user path with `C:\Users\example\repos\drm-copilot`; the quick-pick test moves the type alias below imports and adds the `// Assert` marker.

#### Type safety and maintainability

- No suppressions added; `tsc -p tsconfig.jest.json --noEmit` clean.

#### Error handling and logging

- Not applicable (test-only).

### PowerShell implementation audit

#### What changed well

- `Resolve-OrchestrationEpicTargetOutcome` removes the duplicated epic-scope tail from both surfaces and is pure; the readiness predicate is injected, which is what lets U25 test all five outcomes without file I/O. Deny-reason text is byte-identical (U25 asserts the session-root string exactly).
- The relocation check now uses `(?<![A-Za-z0-9_])(?:GIT_DIR|...)(?![A-Za-z0-9_])`, which admits `legit_dir` and `MY_GIT_DIR` while `$env:GIT_DIR` still denies; the standalone-word residual (U11d) is recorded and fails closed.
- `Get-OrchestrationGitSelectorTarget` no longer computes `IndexOf(...) + 1 = 0` when `git` is absent; it returns a named rule instead of scanning from token 0.
- `Invoke-CompletionConsistencyEntryPoint` converts any read or evaluation exception into a deny with `COMPLETION_CONSISTENCY_BLOCKED`, which removes a fail-open path at the hook tail.

#### API and safety notes

- `New-OrchestrationTargetResult` uses an approved verb and carries a justified `PSUseShouldProcessForStateChangingFunctions` suppression. No residual `Get-OrchestrationTargetResult` reference exists outside `docs/` (one match in the gitignored `artifacts/scratch-903/` copy).
- #565 CR-8: `$(if ($IssueNumber -or @($selection.Remaining).Count -gt 0) { $IssueNumber } else { $FallbackIssueNumber })` keeps the bare-hash fallback only when no folder is cited. M8fe/M8fp pin the new deny; M8, M8h, M8m still pass.

#### Error handling and logging

- Fail-closed behavior preserved or strengthened in every changed decision path.

---

## Test Quality Audit

CI run 38410234897 (workflow_dispatch on `17a6497e4`) concluded success on all 17 jobs; later commits change only the feature folder. Per-row junit results for every named row are recorded in `evidence/qa-gates/ps-rows.2026-10-13T14-25.md` and pass on Windows and Linux.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1` — U11b/U11c/U11d/U24/U25 on both surfaces; U25 does not cover the `target-ambiguous` or fall-through reason strings (CR-A).
- `tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1` — three O-4 rows (throwing reader, benign payload, default reader).
- `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` — five contract tests; fail-before recorded in `evidence/regression-testing/p7-contracts-fail-before.2026-10-13T11-17.md`.
- `evidence/qa-gates/ps-coverage.2026-10-13T14-28.md` — per-file and per-changed-line coverage; values for the four flagged lines confirmed by reviewer.
- `evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md` — withhold decision and flagged-suite ownership.

### Quality assessment prompts

- **Determinism:** No clock, sleep, random, or temporary-file use in new tests.
- **Isolation:** Each data row targets one predicate or outcome.
- **Speed:** Edited Pester files run in under 1s each except the pre-existing integration suite.
- **Diagnostics:** `-Because` text and pytest assertion messages name expected and observed values.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; #846 CR-6 removes a host-specific path. |
| No unsafe subprocess or command construction | ✅ PASS | No new process invocation; no hook gains a Python invocation (AC-45 suites pass). |
| Input validation at boundaries | ✅ PASS | Non-ASCII extension rejection; `git`-absent guard; identifier-boundary regex. |
| Error handling remains explicit | ✅ PASS | Completion-consistency entry point fails closed. |
| Configuration / path handling is safe | ✅ PASS | Trim set extension is suffix-only; mirrors byte-identical. |

---

## Research Log

No external research was required. Behavior was verified from the diff, the CI coverage and junit XML files under the gitignored `artifacts/scratch-903/`, and reviewer reruns.

---

## Verdict

The implementation is correct and consistent across surfaces and mirrors, and the toolchain passes in CI. The change is not ready for the PR flow until CR-A is fixed: two changed lines in the Codex targets copy lost coverage that existed at baseline. The fix is limited to new test rows in an existing surface-parameterized suite and does not require production changes.

**Total blocking findings: 1.**
