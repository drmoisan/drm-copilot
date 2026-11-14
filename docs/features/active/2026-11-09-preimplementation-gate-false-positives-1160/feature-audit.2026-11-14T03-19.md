# Feature Audit: Pre-Implementation Gate False Positives (Issue #1160), Re-audit After Remediation Cycle 4

**Audit Date:** 2026-11-14
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `9cc48a9f4f0bd2ea914572776f5a7c4d7cc038d4` (PR #1174)
**Base:** `main`; merge base `f9e817b2ace9875b24f3df8ad27b97a4065a435e`

## Scope and Baseline

- Scope: the full branch diff `f9e817b2a..9cc48a9f4`, 148 files, read through `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (regenerated at this head) and direct `git diff`.
- Baseline: the merge base on `main`; the merge-base classification decision reproduced by forcing stage 2 to confirm (stage 1 is unchanged in the diff); the Phase 0 artifacts `evidence/baseline/pester-gate.2026-11-10T04-19.md`, `powershell-static.2026-11-10T03-40.md`, and `contract-tests.2026-11-10T03-44.md`.
- Requirements source and work mode: `issue.md` marker `Work Mode: full-bug`, so the AC source is `spec.md` `## Acceptance Criteria` only.
- Review standard: owner directive OD-1 and decision D18 (policy-level standard for stage 2; obfuscation-only variants are non-blocking and out of scope).
- Review mode: concurrent; CI on PR #1174 at this head was queued during the review.
- Gate evidence read: `evidence/qa-gates/pester-gate.2026-11-14T03-08.md`, `contract-tests.2026-11-14T03-12.md`, `coverage-comparison.2026-11-14T03-10.md` (including its `## Correction`), `powershell-static.2026-11-14T02-52.md`, `leak-scan.2026-11-14T03-10.md`, `parity-and-scope.2026-11-14T03-14.md`, `self-review.2026-11-14T03-15.md`, and `evidence/regression-testing/fail-before-subcommand-position.2026-11-14T02-34.md`.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Source |
|---|---|---|
| AC-1 | Section 6.3 false-positive rows unclassified on both surfaces, with fail-before evidence | `spec.md` |
| AC-2 | Every existing denial (6.2 rows, D15 amended; ED-43 to ED-120 per D16, D17, and D19) classified with byte-equal deny text on both surfaces | `spec.md` |
| AC-3 | Classification never widened; D2 non-goals unclassified; stage 2 only after a stage-1 hit | `spec.md` |
| AC-4 | Stage-2 fallbacks fail closed (including the D17 classes) | `spec.md` |
| AC-5 | Mention-host table getter returns exactly the D2 table (as amended by D16 and D17; D19 changes only the lookup) | `spec.md` |
| AC-6 | Agent-memory staging and committing allow with no checkpoint and default configuration | `spec.md` |
| AC-7 | Mixed bookkeeping forms per D5 as amended by D14 | `spec.md` |
| AC-8 | Non-exempt and unsafe staging still denies with unchanged text | `spec.md` |
| AC-9 | #539 exemption suites pass without modification | `spec.md` |
| AC-10 | Configuration absent: seam returns null, default root applies | `spec.md` |
| AC-11 | Configuration `[]` disables the leg with no suffix | `spec.md` |
| AC-12 | Invalid configuration disables the leg and appends the suffix | `spec.md` |
| AC-13 | Unparseable commands keep fail-closed behavior and text | `spec.md` |
| AC-14 | Claude and Codex parity; `$script:SharedGateFunction` unchanged | `spec.md` |
| AC-15 | Four-copy SHA256 identity and fewer than 500 lines for both siblings | `spec.md` |
| AC-16 | Guarded loading of both siblings | `spec.md` |
| AC-17 | Existing gate suites pass without modification in the parallel gate | `spec.md` |
| AC-18 | Protected files unchanged; no `config/preimplementation-gate.json` | `spec.md` |
| AC-19 | Push-down consistency, manifests, contract tests, generator check | `spec.md` |
| AC-20 | Documentation in six brief copies, two orchestrate copies, and file headers | `spec.md` |
| AC-21 | No Python in the hook path | `spec.md` |
| AC-22 | New siblings at least 90% line coverage; changed gate lines not below baseline | `spec.md` |
| AC-23 | Test hygiene: seams mocked, no temporary files, leak scan clean | `spec.md` |
| AC-24 | CI green on the PR head (CI-dependent) | `spec.md` |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC-1 | PASS | FP-01 to FP-17 pass in both runners in the final gate (68 FP tests, 0 failed); fail-before `evidence/regression-testing/fail-before-classification.2026-11-11T04-52.md`. Reviewer probes: all 17 FP rows unclassified at head on both surfaces, including the subcommand-scoped rows FP-07, FP-08, FP-11, FP-12, and FP-13. |
| AC-2 | PASS | ED-01 to ED-120 pass in both runners with byte-equal deny text (480 ED tests, 0 failed). Reviewer probes: 0 mismatches over the 120 ED rows on both surfaces, plus 37 further classified runner invocations of the F3 class. |
| AC-3 | PASS | NG rows pass (18 tests); D19 only turns host records into non-host records, so it only adds confirmations; every probe classified at head is classified at the merge base; the stage-1 patterns are unchanged in both gate files. |
| AC-4 | PASS | Named fallback cases in `-commands.Tests.ps1` and the Modelled suite pass on both surfaces; the D19 bare-host arm fails closed (reviewer probe `echo pytest \| npm` classified). |
| AC-5 | PASS | Table pin tests pass on both surfaces; `Get-OrchestrationGateMentionHostTable` is unchanged in cycle 4 (diff touches only `Test-OrchestrationGateMentionHostRecord` and comments). |
| AC-6 | PASS | Allow rows in both leg suites pass in the final gate; leg unchanged since cycle 1. |
| AC-7 | PASS | D5 and D14 rows in both leg suites pass. |
| AC-8 | PASS | Deny rows in both leg suites pass. |
| AC-9 | PASS | The three named suites are absent from the diff and pass in the final gate. |
| AC-10 | PASS | Mocked-seam cases in `-bookkeeping.Tests.ps1` pass. |
| AC-11 | PASS | `[]` rows in both leg suites pass. |
| AC-12 | PASS | Parser cases and suffix-ordering rows pass. |
| AC-13 | PASS | Unbalanced ED rows and the unbalanced leg row pass on both surfaces. |
| AC-14 | PASS | Both runners pass the same corpus; `Parity.Cases.ps1` is absent from the diff; reviewer probes of 200 commands give identical decisions on both surfaces. |
| AC-15 | PASS | Reviewer `sha256sum`: one digest across the four commands sibling copies and one across the four bookkeeping copies; 489 and 290 logical lines; parity suites pass. |
| AC-16 | PASS | Guarded dot-source lines unchanged since the first review; guard suites pass in the final gate. |
| AC-17 | PASS | Every listed suite passes unmodified in the final parallel gate (23685 tests, 0 failed), recorded in `evidence/qa-gates/pester-gate.2026-11-14T03-08.md`. |
| AC-18 | PASS | No gate file or protected file changed in cycle 4; the non-feature-folder file set equals the third review's set; `config/preimplementation-gate.json` absent. |
| AC-19 | PASS | Contract files 130 passed and generator check exit 0 (`evidence/qa-gates/contract-tests.2026-11-14T03-12.md`); gate bundle copies byte-equal to their sources (`cmp`). |
| AC-20 | PASS | Six brief copies share one SHA256 and carry `decision D19` and the D18 sentence once each; orchestrate copies share one SHA256; sibling header documents rules 1 to 6, D18, and D19. |
| AC-21 | PASS | No `.py` file in the diff; no `python` token in the four sibling copies. |
| AC-22 | PASS | Reviewer parse of `artifacts/pester/powershell-coverage.xml`: commands sibling 99.00% (199 of 201) on both surfaces, bookkeeping sibling 100.00% on both surfaces; gate files 96.43% and 100.00%, unchanged. |
| AC-23 | PASS | Leak scan 0 failures with a non-vacuous control; new rows and cases are pure string inputs. |
| AC-24 | PENDING-CI | CI at head `9cc48a9f4` was queued at review time (`Change scope` and the Windows extension tests passed). Not a blocking finding; checked off at S9 by the item's orchestrator run. |

## Findings Outside the Criterion Text

- F3 (third review): resolved across the class. Every subcommand-scoped host (`git`, `npm`, `pip`, `pip3`, `poetry`) with any option before its subcommand is classified at head on both surfaces, including options outside the plan's list; detail in `code-review.2026-11-14T03-19.md`.
- D17, D18, and D19 are recorded in `spec.md` under `## Decisions`; D19 states cause, rule, class covered, bound and cost, FP analysis, and AC reading.
- Out of scope under OD-1 / D18 (non-blocking, carried): N3 `npm help --viewer=browser --browser=prettier lint` and N4 `ag --pager pytest x`. No new construct needed this disposition.
- New informational notes: N6 (the D19 bare-host arm has no driving test; it fails closed) and N7 (one header comment line at 128 characters).
- No finding unrelated to issue #1160 was identified.

## Summary

23 PASS, 1 pending CI, 0 FAIL. No blocking finding.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/spec.md`
- Total AC items: 24
- Checked off (delivered): 23
- Remaining (unchecked): 1
- Items remaining: AC-24 (CI-dependent): CI is green on the PR head.

## Acceptance Criteria Check-off

AC-1 to AC-23 were already checked in `spec.md`; this review re-verified each as PASS after the D19 change (including AC-1 to AC-5 and AC-14, which the third review named for re-verification) and makes no new check-off. AC-24 stays unchecked as pending CI. No item was unchecked.
