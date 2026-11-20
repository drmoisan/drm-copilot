# Feature Audit: Pre-Implementation Gate False Positives (Issue #1160), Re-audit After Remediation Cycle 3

**Audit Date:** 2026-11-14
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `25cc3ffce7b3ab58c716b724451ca395fe9e4425` (PR #1174)
**Base:** `main`; merge base `eb73f1dff52e7175228a03740b53281c81e1c00c`

## Scope and Baseline

- Scope: the full branch diff `eb73f1dff..25cc3ffce`, 123 files, read through `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (regenerated at this head) and direct `git diff`.
- Baseline: the merge base on `main`; the merge-base classification decision reproduced by forcing stage 2 to confirm (stage 1 is unchanged in the diff); the Phase 0 artifacts `evidence/baseline/pester-gate.2026-11-10T04-19.md`, `powershell-static.2026-11-10T03-40.md`, and `contract-tests.2026-11-10T03-44.md`.
- Requirements source and work mode: `issue.md` marker `Work Mode: full-bug`, so the AC source is `spec.md` `## Acceptance Criteria` only.
- Review standard: owner directive OD-1 and decision D18 (policy-level standard for stage 2; obfuscation-only variants are non-blocking and out of scope).
- Review mode: concurrent; CI on PR #1174 at this head was queued during the review.
- Gate evidence read: `evidence/qa-gates/pester-gate.2026-11-14T01-28.md`, `contract-tests.2026-11-14T01-32.md`, `coverage-comparison.2026-11-14T01-33.md`, `powershell-static.2026-11-14T01-17.md`, `leak-scan.2026-11-14T01-31.md`, `parity-and-scope.2026-11-14T01-33.md`, `self-review.2026-11-14T01-35.md`, `evidence/regression-testing/fail-before-modelled-command.2026-11-14T00-57.md`, and `evidence/other/evidence-stamp-disclosure.2026-11-14T01-36.md`.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Source |
|---|---|---|
| AC-1 | Section 6.3 false-positive rows unclassified on both surfaces, with fail-before evidence | `spec.md` |
| AC-2 | Every existing denial (6.2 rows, D15 amended; ED-43 to ED-96 per D16 and D17) classified with byte-equal deny text on both surfaces | `spec.md` |
| AC-3 | Classification never widened; D2 non-goals unclassified; stage 2 only after a stage-1 hit | `spec.md` |
| AC-4 | Stage-2 fallbacks fail closed (including the D17 classes) | `spec.md` |
| AC-5 | Mention-host table getter returns exactly the D2 table (as amended by D16 and D17) | `spec.md` |
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
| AC-1 | PASS | FP-01 to FP-17 pass in both runners in the final gate (68 FP tests, 0 failed); fail-before `evidence/regression-testing/fail-before-classification.2026-11-11T04-52.md`. Reviewer probes: FP controls unclassified at head on both surfaces. |
| AC-2 | PASS | ED-01 to ED-96 pass in both runners with byte-equal deny text (384 ED tests, 0 failed). Reviewer probes: the sixteen F2 forms and ED-94 to ED-96 are classified at head on both surfaces. F3 concerns forms outside the listed rows. |
| AC-3 | PASS | NG rows pass (18 tests); D17 only adds confirmations; the stage-1 patterns are unchanged in both gate files. |
| AC-4 | PASS | Named fallback cases in `-commands.Tests.ps1` and the 36 classified cases of `-commands.Modelled.Tests.ps1` pass on both surfaces. |
| AC-5 | PASS | Table pin tests pass on both surfaces; reviewer reading of the getter matches the D2 table as amended by D16 and D17 (`ExecutingOption.rg` is `--pre`, `--hostname-bin`; every other entry unchanged). |
| AC-6 | PASS | Allow rows in both leg suites pass in the final gate; leg unchanged since cycle 1. |
| AC-7 | PASS | D5 and D14 rows in both leg suites pass. |
| AC-8 | PASS | Deny rows in both leg suites pass. |
| AC-9 | PASS | The three named suites are absent from the diff and pass in the final gate. |
| AC-10 | PASS | Mocked-seam cases in `-bookkeeping.Tests.ps1` pass. |
| AC-11 | PASS | `[]` rows in both leg suites pass. |
| AC-12 | PASS | Parser cases and suffix-ordering rows pass. |
| AC-13 | PASS | Unbalanced ED rows and the unbalanced leg row pass on both surfaces. |
| AC-14 | PASS | Both runners pass the same corpus; `Parity.Cases.ps1` is absent from the diff; reviewer probes of 62 commands give identical decisions on both surfaces. |
| AC-15 | PASS | Reviewer `sha256sum`: one digest across the four commands sibling copies and one across the four bookkeeping copies; 489 and 290 logical lines; parity suites pass. |
| AC-16 | PASS | Guarded dot-source lines unchanged since the first review; guard suites pass in the final gate. |
| AC-17 | PASS | Every listed suite passes unmodified in the final parallel gate (23215 tests, 0 failed), recorded in `evidence/qa-gates/pester-gate.2026-11-14T01-28.md`. |
| AC-18 | PASS | Reviewer `git diff --name-status <merge base>..HEAD` over the protected list: 0 paths; `config/preimplementation-gate.json` absent. |
| AC-19 | PASS | Contract files 130 passed and generator check exit 0 (`evidence/qa-gates/contract-tests.2026-11-14T01-32.md`); gate bundle copies byte-equal to their sources. |
| AC-20 | PASS | Six brief copies share one SHA256 and carry the D18 sentence; orchestrate copies share one SHA256; sibling header documents rules 1 to 6 and D18. |
| AC-21 | PASS | No `.py` file in the diff; no `python` token in the four sibling copies. |
| AC-22 | PASS | Reviewer parse of `artifacts/pester/powershell-coverage.xml`: commands sibling 99.01% (201 of 203) on both surfaces, bookkeeping sibling 100.00% on both surfaces; gate files 96.43% and 100.00%, unchanged. |
| AC-23 | PASS | Leak scan 0 failures with a non-vacuous control; new cases are pure string inputs. |
| AC-24 | PENDING-CI | CI at head `25cc3ffce` was queued at review time (`Change scope` and `docs-validation` passed). Not a blocking finding; checked off at S9 by the item's orchestrator run. |

## Findings Outside the Criterion Text

- F2 (second review): resolved. All sixteen F2 forms are classified at head on both surfaces, and the FP rows still clear.
- F3 (blocking, related to issue #1160, autonomous, contained scope): `Test-OrchestrationGateMentionHostRecord` reads the value of a value-taking global option as the subcommand of a subcommand-scoped host. Ordinary invocations such as `npm -w search run lint`, `npm --prefix search run lint`, `poetry -C search run pytest`, and `poetry --directory search run pytest` are classified at the merge base and unclassified at head on both surfaces. Detail in `code-review.2026-11-14T01-40.md` and `remediation-inputs.2026-11-14T01-40.md`.
- Out of scope under OD-1 / D18 (non-blocking): `npm help --viewer=browser --browser=prettier lint` and `ag --pager pytest x`.
- No finding unrelated to issue #1160 was identified.

## Summary

23 PASS, 1 pending CI, 0 FAIL. One blocking finding outside the criterion text.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/spec.md`
- Total AC items: 24
- Checked off (delivered): 23
- Remaining (unchecked): 1
- Items remaining: AC-24 (CI-dependent): CI is green on the PR head.

## Acceptance Criteria Check-off

AC-1 to AC-23 were already checked in `spec.md`; this review confirms each as PASS and makes no new check-off. AC-24 stays unchecked as pending CI. No item was unchecked. A remediation of F3 that amends the D2 subcommand rule must re-verify AC-1 to AC-5 and AC-14.
