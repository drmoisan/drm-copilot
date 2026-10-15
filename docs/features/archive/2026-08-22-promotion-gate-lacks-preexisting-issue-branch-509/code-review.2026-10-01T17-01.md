# Code Review: Issue-adoption waiver for the routing-contract completion gate (#509), Remediation Cycle 1 Re-review

---

**Review Date:** 2026-10-01
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509`
**Feature Folder Selection Rule:** Folder suffix matches the canonical issue number 509 supplied by the caller and named in the branch.
**Base Branch:** `origin/epic/orchestrator-state-contract-correctness-integration` (tip `251c7a64`; merge base `bb03e697`)
**Head Branch:** `bug/promotion-gate-lacks-preexisting-issue-branch-exec-509` (`70c6df2f`)
**Review Type:** Re-review after remediation cycle 1
**Prior Review:** `code-review.2026-09-30T15-25.md`

---

## Executive Summary

The branch adds an optional `issue_adoption` checkpoint object that lets a completion checkpoint for a pre-existing GitHub issue satisfy the routing-contract gate without a `potential_to_issue` receipt. One pure resolver per runtime (Python authority, PowerShell port, TypeScript port) returns an ordered error list and a waiver set, and each runtime's routing-contract function consumes it at a single point between the receipt loop and the `local_execution_overrides` check. A 29-case JSON corpus read by one parity suite per runtime pins identical error text and ordering.

The prior review raised one Blocker (744-line test file), one Major (`globals()` test registration), two Minor findings (N1 whitespace parity, N2 docstring accuracy), and two Nits (N3 redundant operand, N4 terse helper names). Remediation cycle 1 changed only test files, two docstring/help lines, and feature-folder documents (`git diff 0aff3f47 HEAD`, excluding evidence: 10 files). The reviewer verified:

- **Blocker resolved.** The unit file is split into `test_orchestrator_state_issue_adoption.py` (462 lines; AC-6, AC-7, AC-9 grid) and `test_orchestrator_state_issue_adoption_waivers.py` (177 lines; AC-8, AC-11, AC-16), with shared constants and builders in `orchestrator_state_issue_adoption_test_support.py` (187 lines). The 39 collected function names are unchanged.
- **Major resolved.** `test_validate_orchestrator_state_issue_adoption.py` declares `test_valid_adoption_completes_without_potential_to_issue_receipt` and `test_adoption_error_fails_closed_before_local_execution_overrides` as ordinary functions (83- and 84-column `def` lines); the `globals()` block and its comment are removed; bodies and docstrings are unchanged; no suppression was added.
- **N2 resolved in code.** The Python docstring and both PowerShell help copies now state that messages interpolate only non-blank `waived_tools` entries and the route id. The residual sentence in `spec.md` line 230 is a non-blocking documentation follow-up.
- **N4 resolved.** Helper names are now descriptive (`duplicate_tool_error`, `non_waivable_tool_error`, `tool_not_required_error`, `tool_has_receipt_error`, `invalid_potential_record_error`, `build_adoption`, `build_state`, `run_resolver`).
- **Merge resolution correct.** `jest.config.cjs` keeps the #523 entry and both #509 entries (lines 77, 83, 87); all mirrored files in the diff are byte-identical to their sources.

Evidence reviewed: full branch diff, regenerated PR context (`artifacts/pr_context.summary.txt`, head `70c6df2f`), the feature-folder evidence tree (notably `evidence/other/rem1-handoff-notes.2026-10-01T16-51.md` and `test-renames.2026-10-01T16-38.md`), reviewer reruns of the Python and TypeScript toolchains and coverage, and CI `ci.yml` run 36895340615 on `70c6df2f` (`success`, 16 of 16 jobs, Pester 6275 tests with 0 failures).

**What changed (full branch):**
Python: new `_orchestrator_state_issue_adoption.py` (325 lines), `_orchestrator_state_route_gates.py` (381), `_orchestrator_state_promotion_tools.py` (95); `_orchestrator_state_routing.py` reduced from 595 to 265 lines. PowerShell: new `OrchestratorStateIssueAdoption.psm1` (375) and wiring in `OrchestratorStateRoutingContract.psm1` (438), each byte-identical to its bundled copy and registered in `core.json`, both runsettings files, and the manifest test. TypeScript: new `orchestrator-state-issue-adoption.ts` (295), wiring in `orchestrator-state-routing.ts` (467), and per-file Jest thresholds. Documentation across `.claude`, `.agents`, and `.codex` surfaces with bundled mirrors.

**Top 3 risks:**
1. Blank-string detection still uses each runtime's native whitespace definition (N1); values such as `"\u001f"` or `"﻿"` can be blank in one runtime and non-blank in another, and the corpus does not pin them. No potential entry records this follow-up yet.
2. `spec.md` line 230 still claims that no raw checkpoint value is rendered, which no longer matches the corrected module documentation; a future reader of the spec could be misled about the message contract.
3. The adoption record is a declaration, not proof (accepted design); the closed waivable set and the successful-receipt check bound what a fabricated record can waive.

**PR readiness recommendation:** **Ready** — no Blocker or Major findings remain; the open items are non-blocking follow-ups.

**Total FAIL plus blocking-PARTIAL findings: 0.** Blocking findings in the table below: 0.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved, non-blocking (was Blocker) | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | whole file | Prior 744-line file is now 462 lines; AC-8, AC-11, AC-16 cases moved to `test_orchestrator_state_issue_adoption_waivers.py` (177); shared helpers in `orchestrator_state_issue_adoption_test_support.py` (187). | None. | `.claude/rules/general-code-change.md` File Size Limit; spec AC-2. | Reviewer `wc -l`; collected function names diffed against `evidence/remediation-baseline/py-adoption-node-names.txt` (no difference); `rem1-file-size-gate.2026-10-01T16-48.md`. |
| Resolved, non-blocking (was Major) | `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py` | lines 150, 170 | `globals()` registration replaced by two ordinary `def test_...` functions with names under 88 columns. | None. | Simplicity first; descriptive `test_...` names; #512 precedent. | `grep "globals()"` exit 1; `ruff check .` pass; 4 tests pass; `test-renames.2026-10-01T16-38.md`. |
| Resolved, non-blocking (was Minor N2) | `scripts/dev_tools/_orchestrator_state_issue_adoption.py`; `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` (both copies) | line 24; help line 19 | Invariant sentence now matches behavior. | None. | Documentation accuracy. | `git diff 0aff3f47 HEAD -- .claude/lib scripts/dev_tools/_orchestrator_state_issue_adoption.py`; `cmp` of the PowerShell pair exit 0. |
| Resolved, non-blocking (was Nit N4) | `tests/scripts/dev_tools/orchestrator_state_issue_adoption_test_support.py` | lines 101-187 | Terse helpers renamed descriptively. | None. | Readability. | Rename record Table 3. |
| Minor, non-blocking | `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md` | line 230 | The spec still states "Messages interpolate only validated tool names and the route id. No raw checkpoint value is rendered", while the duplicate and cannot-be-waived messages interpolate raw non-blank `waived_tools` strings. Left unchanged by design in cycle 1. | Align the sentence with the corrected module wording in a later documentation edit owned by the orchestrator or planner. | Spec prose should match the delivered contract; no acceptance criterion depends on the sentence. | `rem1-handoff-notes.2026-10-01T16-51.md` Open follow-ups; reviewer grep. |
| Minor, non-blocking | `scripts/dev_tools/_orchestrator_state_issue_adoption.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`, `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` | blank-string helpers (`_is_non_blank_string`, `isNonBlankString`, `Test-AdoptionNonBlankString`) | N1 carried forward: runtime-specific whitespace sets can diverge for U+001C-U+001F and U+FEFF; not covered by the corpus. | Record a potential entry; add corpus fixtures and align on an explicit whitespace set, or document the accepted divergence in `.claude/rules/orchestrator-state.md`. | Cross-runtime parity is the stated invariant. | Code inspection; no matching entry under `docs/features/potential/`. |
| Nit, non-blocking | `scripts/dev_tools/_orchestrator_state_issue_adoption.py` | line 323 | N3 carried forward: `if errors or waived is None:` has a runtime-redundant second operand. | Keep with a short comment if it exists for Pyright narrowing; otherwise narrow `waived` explicitly. | Readability. | Code inspection. |
| Info, non-blocking | `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/spec.md` | Test Strategy (line 281) and Files/modules list (line 153) | The spec names a single unit file for every rule; the delivered tests are split across two files plus a support module. | None required; the rename record documents the move, and no acceptance criterion names the file for AC-8, AC-11, or AC-16 cases. | Traceability. | `test-renames.2026-10-01T16-38.md` Table 2. |
| Info, non-blocking | `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` | lines 35-36 | The PowerShell module declares its own `new_potential_entry` and `new_potential_bug_entry` literals. | None required; AC-14 constrains only Python and TypeScript; the parity corpus pins behavior. | Limited duplication. | Code inspection. |
| Info, non-blocking | `artifacts/pr_context.summary.txt` | Verification evidence section | The collector classifies nine expected-nonzero commands from the initial cycle as `fail`; none is a gate failure and no cycle-1 record is affected. | None. | Prevents misreading the PR context. | Reviewer read of the regenerated summary. |

No Blocker or Major findings remain.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The split commit `5a3278df` remains the first code commit and contains only the three routing modules and the identity test.
- `resolve_issue_adoption` takes the resolved `required_mcp_tools` list and the harvested receipt set; it never re-resolves the promotion type and does not import `_orchestrator_state_routing`.
- Cycle 1 changed one docstring line in production; the module stays at 113/113 statements and 46/46 branches.
- The test split keeps each test self-contained: the support module exposes immutable tuples, frozensets, and builders that return fresh dictionaries, so no state is shared between tests.

#### Typing and API notes

- `IssueAdoptionResult` is a frozen dataclass with `tuple[str, ...]` and `frozenset[str]` fields; keyword-only resolver parameters.
- The support module is fully annotated and passes Pyright; it follows the `*_test_support.py` convention so pytest does not collect it.

#### Error handling and logging

- Validation failures are returned as ordered strings; nothing is raised or logged.

### TypeScript implementation audit

#### What changed well

- No TypeScript source or test file changed in cycle 1. The integration merge touched only `jest.config.cjs`, where the conflict was resolved by keeping the #523 entry and both #509 entries.
- `resolveIssueAdoption` imports its promotion-entry constants from `./orchestrator-state-promotion-tools`; that #405 module is absent from the diff.

#### Type safety and maintainability

- No `any` and no suppression comments; one `items as string[]` assertion after an `every(isNonBlankString)` runtime check.
- Coverage: `orchestrator-state-issue-adoption.ts` 295/295 lines, 59/59 branches; `orchestrator-state-routing.ts` 448/467 lines, 98/106 branches.

#### Error handling and logging

- Structural boundary validation; no exceptions or logging.

### PowerShell implementation audit

#### What changed well

- Cycle 1 changed only the help invariant line, identically in both copies (shared SHA-256 `993acecd...f322` per `rem1-ps-bundle.2026-10-01T16-47.md`; reviewer `cmp` exit 0).
- Only case-sensitive operators and ordinal comparisons; the case-variant test passes in the unit and parity suites (CI 42/0 and 32/0 failures).

#### API and safety notes

- Advanced functions with `[CmdletBinding()]`, `[OutputType()]`, and parameter attributes; `Set-StrictMode -Version Latest`; only `Get-OrchestratorStateIssueAdoptionResult` exported.

#### Error handling and logging

- Module-scope fail-fast (`$ErrorActionPreference = 'Stop'`, sibling import with `-ErrorAction Stop`).

---

## Test Quality Audit

Automated coverage remains complete for the new behavior in all three runtimes. The cycle-1 changes were verified to be behavior-neutral for the test suite: the same 39 unit-test function names are collected, the two renamed regression tests keep their bodies and assertions, and the targeted run of the adoption, split, routing, and bundle suites passes (177 tests).

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` (31 collected), `test_orchestrator_state_issue_adoption_waivers.py` (8), `orchestrator_state_issue_adoption_test_support.py` (not collected).
- `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py` (4), including the two renamed tests.
- Parity suites in all three runtimes (29 fixtures, minimum-size guard 29).
- `evidence/qa-gates/rem1-file-size-gate.2026-10-01T16-48.md`, `rem1-py-coverage-delta.2026-10-01T16-44.md`, `rem1-ts-coverage.2026-10-01T16-47.md`, `rem1-doc-pair-identity.2026-10-01T16-47.md`, `rem1-ps-bundle.2026-10-01T16-47.md`, `evidence/regression-testing/py-split-node-names.2026-10-01T16-36.md`, `r2-no-dynamic-registration.2026-10-01T16-38.md`.
- CI run 36895340615 `poshqc-test-results` artifact (junit and coverage).

### Quality assessment prompts

- **Determinism:** Pure inputs, no clock or randomness, fixed grid enumeration, committed fixtures.
- **Isolation:** One rule per test; builders return new objects per call.
- **Speed:** 177 targeted Python tests in 0.70 s; `tests/scripts/dev_tools` in 49.39 s.
- **Diagnostics:** Assertions print observed error lists; the grid test prints the failing combination; parity failures name the fixture.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Fixtures and support module contain only example issue URLs and evidence strings. |
| No unsafe subprocess or command construction | ✅ PASS | No process execution in any new module or test helper. |
| Input validation at boundaries | ✅ PASS | Every field is type-checked before use in all three runtimes; unknown keys are ignored. |
| Error handling remains explicit | ✅ PASS | Adoption errors are appended in a fixed position; any error waives nothing. |
| Configuration / path handling is safe | ✅ PASS | `potential_record` is validated as a prefix/suffix string only and is never opened. |
| Fabricated-record exposure | ⚠️ PARTIAL (non-blocking, accepted design) | The record is a declaration, not proof, as `.claude/rules/orchestrator-state.md` states; the closed waivable set and the successful-receipt check limit what a fabricated record can waive. |

---

## Research Log

No external research was required. The review relied on repository policy files, the spec, the remediation inputs and plan, and the cycle-1 evidence records.

---

## Verdict

Both prior blocking findings are resolved and independently verified, as are N2 (in code) and N4. The production implementation is unchanged apart from two documentation lines and remains correct, consistent across runtimes, fully covered, and toolchain-clean. CI on the final head passed.

Blocking findings: 0. The branch is ready for normal PR flow into `epic/orchestrator-state-contract-correctness-integration`. N1, N3, and the `spec.md` line 230 sentence are non-blocking follow-ups.
