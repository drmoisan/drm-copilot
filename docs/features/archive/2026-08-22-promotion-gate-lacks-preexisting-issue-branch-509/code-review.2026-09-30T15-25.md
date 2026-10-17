# Code Review: Issue-adoption waiver for the routing-contract completion gate (#509)

---

**Review Date:** 2026-09-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509`
**Feature Folder Selection Rule:** Folder suffix matches the canonical issue number 509 supplied by the caller and named in the branch.
**Base Branch:** `origin/epic/orchestrator-state-contract-correctness-integration` (tip `d008424e`; merge base `815a962f`)
**Head Branch:** `bug/promotion-gate-lacks-preexisting-issue-branch-exec-509` (`8920a1f6`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds an optional `issue_adoption` checkpoint object that allows a completion checkpoint for a pre-existing GitHub issue to satisfy the routing-contract gate without a `potential_to_issue` receipt. The change is implemented as one pure resolver per runtime (Python authority, PowerShell port, TypeScript port) that returns an ordered error list and a waiver set, and each runtime's routing-contract function consumes it at a single point between the receipt loop and the `local_execution_overrides` check. A 29-case JSON corpus is read by one parity suite in each runtime, which pins identical error text and ordering. The oversized Python routing module was first split into three modules in a separate commit with an identity test for every re-exported name.

Evidence reviewed: the full branch diff, the regenerated PR context (`artifacts/pr_context.summary.txt`, head `8920a1f6`), the feature-folder evidence tree, reviewer reruns of the Python and TypeScript toolchains and the bundle tests, and the CI runs 36725543249, 36732800820 (`_poshqc.yml`), and 36732813941 (`ci.yml`), all confirmed `success` with `gh run view`. Production quality is high and consistent across runtimes. The blocking issues are in the Python test files: one exceeds the 500-line limit, and one registers two tests through `globals()`.

**What changed:**
Python: new `_orchestrator_state_issue_adoption.py` (325 lines), `_orchestrator_state_route_gates.py` (381), `_orchestrator_state_promotion_tools.py` (95); `_orchestrator_state_routing.py` reduced from 595 to 265 lines with an `__all__` re-export block and the adoption wiring (lines 246-260). PowerShell: new `OrchestratorStateIssueAdoption.psm1` (375) and wiring in `OrchestratorStateRoutingContract.psm1` (lines 61, 416-425), each byte-identical to its bundled copy and registered in `core.json`, both runsettings files, and the manifest test. TypeScript: new `orchestrator-state-issue-adoption.ts` (295), wiring in `orchestrator-state-routing.ts` (lines 446-461), and two per-file Jest thresholds. Documentation across `.claude`, `.agents`, and `.codex` surfaces with bundled mirrors.

**Top 3 risks:**
1. `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` is 744 lines, which violates the 500-line limit and leaves spec AC-2 unmet.
2. The `globals()` test registration in `test_validate_orchestrator_state_issue_adoption.py` hides two AC-5/AC-9 tests from static analysis and text search; a later refactor could drop them without a lint or type signal.
3. Blank-string detection uses each runtime's native whitespace definition (Python `str.strip`, JavaScript `String.prototype.trim`, .NET `IsNullOrWhiteSpace`), which differ for a few code points (for example U+001C-U+001F and U+FEFF). The corpus does not cover these inputs, so cross-runtime parity for them is not pinned.

**PR readiness recommendation:** **Needs Revision** — production code is ready, but the 744-line test file (AC-2) and the `globals()` registration must be corrected before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | whole file (744 lines) | File exceeds the 500-line limit for test code. | Split into two files by concern, for example `test_orchestrator_state_issue_adoption_schema.py` (AC-6 and AC-7 cases, helpers) and `test_orchestrator_state_issue_adoption_waivers.py` (AC-8, AC-9 grid, AC-11, AC-16), each under 500 lines; move the shared message builders and `_adoption`/`_state`/`_resolve` helpers into a small test-support module under `tests/scripts/dev_tools/`. Preserve test names or record renames. Rerun Black, Ruff, Pyright, pytest, and the dotted-module coverage command. | `.claude/rules/general-code-change.md` File Size Limit; spec AC-2 requires every created test file below 500 lines. | `wc -l` = 744; `evidence/qa-gates/file-size-gate.2026-09-30T15-10.md` Result FAIL; plan P8-T17 unchecked. |
| Major | `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py` | lines 150-205 | Two test bodies are private functions registered by assigning into `globals()` under names longer than 88 columns, to avoid Ruff E501 without a `noqa`. | Declare both as ordinary `def test_...() -> None:` functions with names that fit in 88 columns (for example `test_valid_adoption_completes_without_potential_to_issue_receipt` and `test_adoption_error_fails_closed_before_local_execution_overrides`), delete the `globals()` block, and update the plan and evidence references to the new names. | Simplicity-first and "descriptive `test_...` function names" (`.claude/rules/general-code-change.md`, `.claude/rules/python.md`). The pattern circumvents a lint rule through dynamic namespace mutation; `def test_` search, IDE navigation, and Pyright do not see the registered names. The #512 precedent (PR #799) resolved the same E501 conflict by shortening the name. | Lines 195-205 of the file; `evidence/other/handoff-notes.2026-09-30T15-15.md` Deviations section. |
| Minor | `scripts/dev_tools/_orchestrator_state_issue_adoption.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`, `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` | `_is_non_blank_string` (line 120), `isNonBlankString` (line 109), `Test-AdoptionNonBlankString` (line 60) | Blank detection relies on runtime-specific whitespace sets, so values such as `"\u001f"` or `"﻿"` for `evidence`, `verified_at`, or a `waived_tools` entry can be blank in one runtime and non-blank in another. | Add corpus fixtures for these code points and align behavior (for example by stripping an explicit ASCII whitespace set in all three runtimes), or document the accepted divergence in `.claude/rules/orchestrator-state.md`. Can be a follow-up. | Parity is the stated invariant of the change; the corpus currently covers only ASCII space and empty strings. | Code inspection of the three helpers. |
| Minor | `scripts/dev_tools/_orchestrator_state_issue_adoption.py` | module docstring line 24; PowerShell help line 19 | The invariant "Messages interpolate only validated tool names and the route id" is not literal: the duplicate and cannot-be-waived messages interpolate the raw non-blank string from `waived_tools`. | Reword the invariant to "Messages interpolate only non-blank `waived_tools` strings and the route id", or restrict interpolation to closed-set names. | Documentation accuracy; the behavior matches the spec's message templates. | Lines 208-217 (Python), 238-242 (PowerShell). |
| Nit | `scripts/dev_tools/_orchestrator_state_issue_adoption.py` | line 323 | `if errors or waived is None:` — `waived is None` always implies a non-empty `errors`, so the second operand is redundant at runtime. | Keep if it exists for Pyright narrowing; otherwise simplify to `if errors:` and narrow `waived` explicitly. | Readability. | Code inspection. |
| Nit | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | lines 81-122 | Public helper names `e8dup`, `e8cannot`, `e8notreq`, `e8receipt`, `e9` are terse and unprefixed. | Rename with a leading underscore and a descriptive form (for example `_duplicate_tool_error`) during the AC-2 split. | Readability; avoids accidental import surface. | Code inspection. |
| Info | `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` | lines 35-36 | The PowerShell module declares its own `new_potential_entry` and `new_potential_bug_entry` literals. | None required; AC-14 constrains only Python and TypeScript, and `OrchestratorStateRoutingContract.psm1` already declares the same constants. A shared PowerShell constants module could be a later cleanup. | Duplication is limited and pinned by the parity corpus. | Lines 35-36; `OrchestratorStateRoutingContract.psm1` lines 64-65. |
| Info | branch scope | merge `127635e9` | The branch carries PR #799 (#512) content from main that is not yet on the epic base: `tests/scripts/dev_tools/test_blast_radius_config_parity.py` (rename, 499 lines) and the #512 feature folder. | None for #509; the reviewer checked the inherited Python file (Black, Ruff, Pyright, 20 tests pass). The PR into the epic branch will include these paths. | Keeps the PR description accurate. | `git log origin/epic/...HEAD`; PR context "PRs in range: #799". |
| Info | `evidence/qa-gates/ps-test-mcp.2026-09-30T15-06.md` | whole file | The local MCP Pester run reported 2 failures in unchanged hook tests that read gitignored local checkpoints; CI on the same head reports 0 failures. | None; recorded for traceability. | Environment-conditional, not a regression. | CI run 36732800820 junit `failures="0"`. |

No other Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The split commit `5a3278df` contains only the three routing modules and the identity test; the unmodified routing-contract and preparation-route suites pass at that commit (`evidence/regression-testing/py-split-at-commit.2026-09-30T14-16.md`, 62 passed).
- `resolve_issue_adoption` takes the already-resolved `required_mcp_tools` list and the harvested receipt set, so it never re-resolves the promotion type and has no dependency on `_orchestrator_state_routing` (no import cycle).
- The fail-closed invariant is enforced at a single return point, and the fixed 96-case grid test asserts it across field-validity combinations.
- Presence gating uses `ISSUE_ADOPTION_KEY not in state`, so an explicit `null` value is distinguished from an absent key (rule 1 applies to `null`).

#### Typing and API notes

- `IssueAdoptionResult` is a frozen dataclass with `tuple[str, ...]` and `frozenset[str]` fields; the resolver uses keyword-only parameters typed as `Collection[str]`.
- `__all__` in `_orchestrator_state_routing.py` preserves the import surface of all nine importers; `_receipt_agents`, `_receipt_skills`, and `_mcp_tools` remain defined there.
- `Any` is limited to `dict[str, Any]` for parsed checkpoints, matching the existing module.

#### Error handling and logging

- Validation failures are returned as ordered strings; nothing is raised or logged, consistent with the validator contract.

### TypeScript implementation audit

#### What changed well

- `resolveIssueAdoption` imports `FEATURE_PROMOTION_ENTRY_TOOL` and `BUG_PROMOTION_ENTRY_TOOL` from `./orchestrator-state-promotion-tools`; the #405 module is not modified.
- `Object.prototype.hasOwnProperty.call` implements presence gating equivalently to Python.
- The wiring in `validateRoutingContract` mirrors Python exactly: skip waived tools in the receipt loop, then append adoption errors.

#### Type safety and maintainability

- No `any` and no suppression comments. One `items as string[]` assertion follows an `every(isNonBlankString)` runtime check.
- `jest.config.cjs` gains per-file thresholds for both the new file and `orchestrator-state-routing.ts`; the routing entry did not previously exist, which the handoff notes record as a spec discrepancy resolution.

#### Error handling and logging

- Boundary validation is structural (`isPlainObject`, `Array.isArray`, `typeof`); no exceptions or logging.

### PowerShell implementation audit

#### What changed well

- Only case-sensitive operators and ordinal `StringComparison`/`StringComparer` are used; the case-variant test (`Potential_To_Issue`) passes in both the unit and parity suites.
- `verified_at` is presence-only, which accommodates `ConvertFrom-Json` coercing ISO-8601 strings to `System.DateTime`.
- Only `Get-OrchestratorStateIssueAdoptionResult` is exported; helpers stay private.

#### API and safety notes

- Advanced functions with `[CmdletBinding()]`, `[OutputType()]`, `Mandatory`, `AllowNull`, and `AllowEmptyCollection` attributes; approved verbs; `Set-StrictMode -Version Latest`.
- The C6.15 row is added to the parity inventory header, and the header text states that declared-list equality is unchanged.

#### Error handling and logging

- Module-scope fail-fast (`$ErrorActionPreference = 'Stop'`, sibling import with `-ErrorAction Stop`); results returned as hashtables of string arrays.

---

## Test Quality Audit

Automated coverage is complete for the new behavior in all three runtimes (100% line coverage for each new module; 100% branch coverage in Python and TypeScript). Regression evidence includes a recorded fail-before run (`evidence/regression-testing/py-regression-expect-fail.2026-09-30T14-17.md`, 3 failed, 1 passed) and a pass-after run. No end-to-end orchestration against a real pre-existing issue was performed; the spec does not require one.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` — 39 unit tests covering rules 1-9, waivers, the fixed-grid invariant, presence gating, and case sensitivity; complete but 744 lines.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py` — 4 full-validator and routing-contract regression tests; two use `globals()` registration.
- `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1` — 29-fixture corpus with a minimum-size guard (29) in each runtime.
- `tests/scripts/dev_tools/test_orchestrator_state_routing_split.py` — 33 identity and `__all__` assertions.
- `evidence/qa-gates/poshqc-local/powershell-coverage.xml` — CI coverage for the new PowerShell module (112/112 lines).
- `evidence/qa-gates/py-coverage-delta.2026-09-30T15-11.md`, `ts-coverage-delta.2026-09-30T15-10.md`, `ps-coverage-delta.2026-09-30T15-12.md` — baseline versus post-change figures with no regression.

### Quality assessment prompts

- **Determinism:** Pure inputs, no clock or randomness, fixed grid enumeration, committed fixtures.
- **Isolation:** One rule per test; parity cases are independent per fixture.
- **Speed:** Each new Python file runs in under 0.1 s; the Jest validate directory runs in 1.3 s.
- **Diagnostics:** Assertions print observed error lists; the grid test prints the failing combination; parity failures name the fixture.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Fixtures contain only example issue URLs and evidence strings. |
| No unsafe subprocess or command construction | ✅ PASS | No process execution in any new module. |
| Input validation at boundaries | ✅ PASS | Every field is type-checked before use in all three runtimes; unknown keys are ignored. |
| Error handling remains explicit | ✅ PASS | Adoption errors are appended in a fixed position; any error waives nothing. |
| Configuration / path handling is safe | ✅ PASS | `potential_record` is validated as a prefix/suffix string only and is never opened. |
| Fabricated-record exposure | ⚠️ PARTIAL | The record is a declaration, not proof, as `.claude/rules/orchestrator-state.md` now states; the closed waivable set and the successful-receipt check limit what a fabricated record can waive. This is the accepted design, not a defect. |

---

## Research Log

No external research was required. The review relied on repository policy files, the spec, and the research artifact `research/research.2026-09-29T15-15.md`.

---

## Verdict

The production implementation is correct, consistent across Python, PowerShell, and TypeScript, fully covered, and toolchain-clean; documentation and bundled mirrors are synchronized and the bundle tests pass. The change is not ready for merge because of two test-side defects: the 744-line unit test file violates the 500-line limit (spec AC-2), and two regression tests are registered through `globals()` instead of ordinary `def` declarations.

After the test file is split below 500 lines and the two tests are declared normally with names that fit in 88 columns, followed by a Python toolchain rerun and a CI run on the new head, the branch would be ready for normal PR flow into the epic integration branch. The Minor whitespace-parity finding can be handled as a follow-up.
