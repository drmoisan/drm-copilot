# Code Review: Orchestrator Remediation-Loop Control (#484)

---

**Review Date:** 2026-10-01 (artifact timestamp 2026-10-02T00-15)
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484`
**Feature Folder Selection Rule:** the only active folder whose suffix matches the issue number in the branch name (`-484`).
**Base Branch:** `epic/orchestrator-state-contract-correctness-integration` (merge-base `40faab4136d72512e20b50b5193a14dd4e78eaf2`, equal to the base tip)
**Head Branch:** `bug/orchestrator-remediation-loop-control-484-r2` @ `518f4e67`
**Review Type:** Initial review

---

## Executive Summary

The branch introduces a four-value review verdict and a five-value per-finding remediability class, records review outcomes and completed-attempt accounting under the existing `remediation_loop` checkpoint key, and enforces invariants R5-R11 in three validator runtimes with identical message text and error order. The change is additive and presence-gated: a checkpoint without the new keys produces the same full error list as before in every mode, which a back-compat corpus captured from the unmodified validators confirms in all three runtimes. Fifteen orchestration documents and their bundle copies adopt the halt, wait, and accounting contract, and the rules document receives the operator-authorized OD-484-1 edit.

The review covered the full diff against the merge-base (118 non-feature-folder files), with line-by-line reading of all production code in the three runtimes, the new test files, the parity and back-compat fixtures sampled for the required cases, and every document hunk. The implementation is consistent with the spec's message table, error-order rule, and module-split rule. No blocking or major finding was identified. Six minor, nit, or informational findings are recorded below; all are Non-blocking.

**What changed:**
- Python `scripts/dev_tools/_orchestrator_state_remediation_loop.py`: vocabulary constants, `derive_review_verdict`, `_validate_review_outcome(s)`, `_opens_remediation_review`, `_validate_remediation_accounting`; `_validate_remediation_loop` no longer returns early when `cycles` is not a list.
- TypeScript `orchestrator-state-remediation.ts` (cycle accounting R5-R7, R11; restructured entry; re-exports) and new `orchestrator-state-remediation-accounting.ts` (vocabulary, `deriveReviewVerdict`, R8-R10), split per the spec rule after the combined file measured 455 lines.
- PowerShell new `OrchestratorStateRemediationAccounting.psm1` (R5-R11, private verdict helper) imported by `OrchestratorStateReceipts.psm1`, whose early return was restructured; registrations in `core.json`, both run-settings files, and the manifest test.
- 41-case parity corpus, 11-case back-compat corpus with a captured expected file, ten new test files, one re-pinned test-support file (D9), and the document set.

**Top 3 risks:**
1. Producers may omit the new fields; R7 and R11 then do not apply. This is the spec's deliberate presence gate for back-compat, so enforcement depends on the orchestrator documents being followed.
2. Cross-runtime integer semantics differ outside the corpus: TypeScript accepts `2.0` as an integer (spec follow-up 7), and PowerShell accepts only `[int]`/`[long]`, so a JSON integer beyond the Int64 range is rejected by PowerShell and accepted by Python. Neither value is realistic for these fields.
3. Codex producers cannot validate the new #523 members through the pinned published MCP until a release containing #523 and #484 is published (spec follow-up 1, AC-6 write-up).

**PR readiness recommendation:** **Go** — all invariants are implemented identically in three runtimes with passing parity and back-compat corpora, clean toolchain results on the changed files, and coverage above threshold; remaining findings are Non-blocking.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (Non-blocking) | `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation-accounting.ts` | lines 64-95 (`isObject`, `pythonRepr`) | `pythonRepr` duplicates the local renderer in `orchestrator-state-human-interaction.ts` (the TSDoc says so), and `isObject` is duplicated in `orchestrator-state-remediation.ts` lines 78-80. | In a follow-up, extract both helpers into a shared module under `src/lib/validate/` and import them from all three files. | The general code-change policy prefers shared helpers over copies; a future rendering fix (for example the float follow-up) would otherwise need three edits. | Direct inspection of both files; TSDoc line 77 "Same body as the local renderer in `orchestrator-state-human-interaction.ts`". |
| Minor (Non-blocking) | `scripts/dev_tools/_orchestrator_state_remediation_loop.py` | lines 163, 210, 246-247 | New private helpers annotate parsed JSON as `dict[str, Any]` without a justification comment; `.claude/rules/python.md` asks to avoid `Any` unless unavoidable and commented. | Prefer `Mapping[str, object]` / `dict[str, object]` for new helpers, or add a one-line comment stating that the module follows the parsed-JSON convention used by `validate_orchestrator_state.py`. | The usage matches the module's and the core validator's pre-existing pattern and Pyright passes, so the risk is low; it is a consistency item. | `poetry run pyright` 0 errors; `validate_orchestrator_state.py` lines 120, 170, 180, 212 use the same pattern. |
| Info (Non-blocking) | `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation-accounting.ts` | lines 89, 90, 92, 93 | The boolean branches of `pythonRepr` are not covered by Jest; no case renders a boolean verdict or remediability value. | Optionally add one case with `"verdict": true` and one with `"remediability": false` in the Jest accounting suite (not in the parity corpus, which excludes booleans outside `candidate_applied` by spec). | The file still meets thresholds (98.19% lines, 95.56% branches); the branch is the Python-parity rendering of `True`/`False`. | `extensions/drm-copilot/coverage/lcov.info` LF 221 / LH 217, BRF 45 / BRH 43; `evidence/qa-gates/coverage-comparison-typescript.md`. |
| Info (Non-blocking) | `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | line 40 (sibling `Import-Module -Force`) | The `-Force` sibling import pattern removes and reloads the accounting module inside the receipts module scope, which drops a previously imported global command entry in a test session (deviation D5). The same mechanism is a plausible cause of the 38 pre-existing folder-scoped `OrchestratorStateIssueAdoption.Tests.ps1` failures (inference; not verified). | File a follow-up to make orchestrator-state test suites robust to import order (for example import order guidance or `-Global`-free reloading), covering D5 and the #509 folder-scoped failures together. | The production code follows the established sibling convention; the fragility shows only in test sessions, and the accounting suite already documents its required import order. | `evidence/other/plan-deviations.md` D5 and D10; reviewer re-run of six Pester suites together: 278 passed, 0 failed. |
| Info (Non-blocking) | `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts`; `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1` | `isStrictInteger` (lines 88-90); `Test-RemediationStrictInteger` (lines 53-75) | Integer acceptance differs from Python outside the corpus: TypeScript accepts float-formatted integers (`2.0`); PowerShell rejects integers that `ConvertFrom-Json` materializes as `[decimal]` or `[BigInteger]` (beyond Int64). | Add the PowerShell large-integer case to the existing cross-runtime rendering follow-up (spec follow-up 7). | Values for `completed_attempts` and `opened_by_review` are small non-negative integers in practice; the spec explicitly excludes floats from the corpus. | Direct inspection; spec `## Rollout & Follow-up` item 7. |
| Nit (Non-blocking) | `tests/scripts/dev_tools/test_orchestrator_state_remediation_accounting.py` | lines 52-145 | Helper and constant names are terse (`VC`, `vc`, `RR`, `r5`..`r11`) and the message builders have no docstrings. | Optional: add one-line docstrings to the message builders or a module comment mapping `rN` to the spec message IDs. | Names mirror the spec rule IDs and the file is close to the 500-line cap (494 lines), so the terse style is a reasonable trade-off. | Direct inspection; `wc -l` 494. |

No Blocker or Major findings. Blocking findings: 0.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `_validate_remediation_loop` keeps the per-cycle loop and its messages byte-identical, then appends review-outcome and accounting errors in the spec order (per-cycle, review outcomes, then per-cycle R5/R6/R11, then R7a or R7b). `test_error_order_across_families` and the `combined_legacy_and_new_errors_order` corpus case assert the order.
- R10 runs only when the outcome produced no R9 error (`if not errors:` on the outcome-local list), matching the spec's suppression rule.
- `derive_review_verdict` validates membership before deriving, so an invalid member raises regardless of position, and the validators call it only after R9d passes.
- `_is_strict_int` excludes `bool`, so `True`/`False` are rejected by R7a and R11 as the spec requires.

#### Typing and API notes

- `ReviewVerdict` is a `Literal`; `REVIEW_VERDICTS` and `REMEDIABILITY_CLASSES` are tuples in spec table order; `NON_REMEDIABLE_CLASSES` and `HALT_CLASSES` are frozensets. `__all__` lists every new public name.
- `dict[str, Any]` on new private helpers follows the module convention (Minor finding above).

#### Error handling and logging

- `ValueError("invalid remediability: ...")` is the only raise; no catch-all handlers; no logging, consistent with the module's pure-function contract.

### TypeScript implementation audit

#### What changed well

- The split moved the vocabulary with the R8-R10 code, so `orchestrator-state-remediation-accounting.ts` has no import back into its re-exporter; the public import surface used by callers is unchanged because `orchestrator-state-remediation.ts` re-exports every moved name, including `type ReviewVerdict`.
- `hasKey` uses `Object.prototype.hasOwnProperty.call`, so presence gating matches Python's `in` and is not confused by prototype properties.
- Messages render values through `pythonRepr`, matching Python's f-string output for `null`/absent (`None`) and strings.

#### Type safety and maintainability

- No `any`, no non-null assertions, no suppression comments. `REVIEW_VERDICTS` is `readonly ReviewVerdict[]`; the single widening `as readonly string[]` is needed for `includes` on an unknown string.
- Two duplicated helpers (Minor finding above).

#### Error handling and logging

- `deriveReviewVerdict` throws `RangeError` with the specified prefix; validators return string arrays and never throw on malformed input.

### PowerShell implementation audit

#### What changed well

- Every vocabulary comparison is case-sensitive (`-ccontains`, `-cnotcontains`, `-ceq`), matching the #523 correction; the case-variant tables in the Pester suite prove it.
- String checks precede membership checks for verdict and remediability (`-not ($verdict -is [string]) -or ...`), so a non-string value renders through `ConvertTo-PythonDisplayText` as Python does.
- Only the entry point is exported; helpers stay private and are tested through `InModuleScope`.
- `OrchestratorStateReceipts.psm1` grew by 7 lines (410 to 417), well below the cap, as spec Decision 4 intended.

#### API and safety notes

- All functions are advanced functions with `[CmdletBinding()]`, `[OutputType()]`, typed and validated parameters; approved verbs `Get` and `Test`.
- `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at module scope; sibling import with `-ErrorAction Stop`. PSScriptAnalyzer reports 0 findings.

#### Error handling and logging

- `Get-RemediationReviewVerdict` throws a terminating error beginning `invalid remediability: `; no `Write-Host`, no swallowed errors.

---

## Test Quality Audit

Each runtime has a unit suite for the helper and R5-R11, a parity reader over the shared 41-case corpus, and a back-compat reader over the 11-case corpus captured before any production edit. Expected messages in the unit suites are written from the spec table rather than imported, so the tests pin the specification. The reviewer re-ran the targeted suites in all three runtimes and they passed.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_orchestrator_state_remediation_accounting.py` — 122 cases: 32 subsets, duplicates, non-members, constants, drift guard against `NON_MECHANICAL_BLOCKED_REASONS`, R5-R11 tables, case variants, error order, back-compat shapes, halt integration (`validate_orchestrator_state_text` returns `[]`).
- `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py` — 85 cases; `MINIMUM_CORPUS_COUNT = 41`, name-equals-stem, discovery-count equality, and a check that the corpus contains all 12 new message patterns.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_backcompat.py` — 45 cases replaying full, unfiltered error lists in every Python mode.
- `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py` — 15 `test_docs_*` drift checks reading documents in place.
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-*.test.ts` — the same three roles in Jest; the accounting suite imports `NON_MECHANICAL_BLOCKED_REASONS` from `orchestrator-state-blocked-reason.ts`.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediation*.Tests.ps1` — the same three roles in Pester; the drift guard reads `$script:NON_MECHANICAL_BLOCKED_REASONS` from `OrchestratorState` via `InModuleScope`.
- `tests/fixtures/orchestrator_state_remediation_loop/*.json` — sampled: `halt_at_first_review_without_cycles` and `halt_with_blocked_reason_none_without_human_interaction` expect `[]`; `r11_opened_by_halt_outcome` and `r11_opened_by_awaiting_ci_outcome` expect the R11 message; `r7b_no_candidate_cycle_not_counted` expects `[]` with one true and one false cycle and `completed_attempts: 1`.
- `evidence/regression-testing/backcompat-byte-identity-comparison.md` — before and after runs equal (45/45, 34/34, 34/34) with fifteen matching hashes.
- `evidence/regression-testing/halt-integration-three-runtimes.md` — the halt-at-first-review checkpoint validates cleanly in all three runtimes.

### Quality assessment prompts

- **Determinism:** pure validators; exhaustive enumeration instead of random sampling; committed fixtures read in place; no clock or randomness.
- **Isolation:** one invariant per case; full ordered error lists compared, which also detects unexpected extra errors.
- **Speed:** 393 targeted Python tests in 1.16 s; 275 targeted Jest tests; 278 targeted Pester tests.
- **Diagnostics:** case ids name the rule and variant; corpus mismatches report the stem; subset failures report the subset and both verdicts.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials, tokens, or `.env` files in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | No process execution in production or tests. |
| Input validation at boundaries | ✅ PASS | Every new key is type-checked before use (string before membership, integer excluding boolean, list and object shape checks). |
| Error handling remains explicit | ✅ PASS | Validators return error lists; helpers raise specific errors with a fixed prefix; no broad catch. |
| Configuration / path handling is safe | ✅ PASS | The PowerShell sibling import resolves relative to `$PSScriptRoot`; tests resolve the corpus relative to the test file; no absolute host paths in any committed artifact. |
| No enforcement-hook change or Python leg | ✅ PASS | `git diff --name-status` over `.claude/hooks`, `.codex/hooks`, and their bundle copies is empty. |
| Cross-runtime parity of verdicts, classes, and halt members | ✅ PASS | Identical literals and order in all three runtimes; the four non-remediable classes equal #523's non-mechanical members other than `premise_falsified`, asserted by a drift guard in each runtime; no #523 file modified. |

---

## Research Log

No external research was required. The review relied on the spec, the research artifact in the feature folder, the branch diff, the executor's evidence, and check-only re-runs of the toolchain on the changed files.

---

## Verdict

The change is ready for normal PR flow into `epic/orchestrator-state-contract-correctness-integration`. The three validators implement R5-R11 with identical messages and order, the back-compat corpus proves unchanged behavior for checkpoints without the new keys, the documents describe the halt and wait branches and the completed-attempt accounting consistently across the `.claude`, `.agents`, and `.codex` surfaces with byte-identical bundle copies, and the operator-authorized rules edit is limited to the specified hunks.

The six findings are Non-blocking: two minor consistency items (duplicated TypeScript helpers, uncommented `Any`), three informational items suitable for the existing cross-runtime and test-robustness follow-ups, and one test-readability nit. Blocking findings: 0. `review-status: PASS`.
