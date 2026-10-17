# Code Review: plan-validator-accepts-bare-scratch-paths (Issue #932) — Re-review after Remediation Cycle 3 (exit gate)

- Review timestamp: 2026-10-16T07-38 (UTC)
- Branch / head: `bug/plan-validator-accepts-bare-scratch-paths-932` @ `990db511f1bd9d3f96d0470b8464257f01aeff4e`
- Base: `origin/main` @ `b6be46b5e`, merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- Scope: full branch diff (267 files), with the cycle-3 range `95d61f2a5..990db511f` read line by line. Companion artifacts: `policy-audit.2026-10-16T07-38.md`, `feature-audit.2026-10-16T07-38.md`.
- Prior review: `code-review.2026-10-16T05-25.md` (no Blocking finding; related N-3).

## Executive Summary

Cycle 3 resolves N-3 as specified in `remediation-inputs.2026-10-16T05-36.md`. The explicit whitespace class and a single normalizer are declared once per runtime in the command extractor module (`plan_gate_commands.py`, `plan-gate-commands.ts`), the G10 copies were removed, and G6 now normalizes the search literal, each tracked line, and each sliding window with the shared function in both runtimes. A new test pins the declaration count per module and the existing test still pins the TypeScript string to the Python string. Frozen NEL and byte-order-mark fixtures in both literal suites cover both directions of the divergence and were recorded red before the fix in the expected runtime only. The corpus A/B over 509 plans used discriminating probes in both runtimes and shows no G1-G9 result change.

The empty-needle tests added in `a1576c292` cover the previously unexecuted guard in `_plan_quotes_literal` / `planQuotesLiteral`; a reviewer mutation probe confirms the Python test fails when the guard is removed.

No Blocking finding exists. One related Non-blocking observation (N-4, Info) records the plan-quotation residual, which the rule file and spec now state accurately.

Reviewer verification performed: `black --check`, `ruff check`, `pyright` on 11 Python files (clean); Python plan-gate suites with branch coverage (203 passed); contract and Codex suites (634 passed); bundle node test (1 passed locally); `cmp` on both bundle copies (identical); `prettier --check` and `eslint` on 12 TypeScript/config files (clean); repository `lint` and `typecheck` scripts (exit 0); `npm run test:coverage` (271 suites, 4025 tests, exit 0); plan self-validation for all four plans (exit 0); `git merge-tree` against `origin/main` (no conflict); an in-memory mutation probe of the empty-needle guard.

## Cycle-3 Resolution Check

| Prior ID | Status | Evidence |
| --- | --- | --- |
| N-3 | Resolved | Shared declaration: `scripts/dev_tools/plan_gate_commands.py:336-362` (`PLAN_WHITESPACE_CLASS`, `_PLAN_WHITESPACE_RUN_RE`, `normalize_plan_whitespace`) and `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts:279-307` (`PLAN_WHITESPACE_CLASS`, `PLAN_WHITESPACE_RUN_RE`, `normalizePlanWhitespace`). G6 use: `plan_gate_discrimination.py:262-263` (window join), `:278-279` (literal), `:287` (single-line test); `plan-gate-rules.ts:395-397`, `:421-422`, `:431`. G10 use: `plan_gate_scratch.py:91,141,153`; `plan-gate-scratch.ts:87,126,161`. Declaration count: `test_whitespace_class_declared_once_per_runtime` expects 1 in each extractor module and 0 in `plan_gate_scratch.py`, `plan_gate_discrimination.py`, `plan-gate-scratch.ts`, `plan-gate-rules.ts`. String parity: `test_whitespace_class_matches_typescript` reads `plan-gate-commands.ts` and asserts ASCII. Fixtures: `test_g6_normalization_uses_plan_whitespace_class` (`nel-only-line`, `bom-only-line`, `nel-joined-line`, `bom-joined-line`) and the matching jest case. Red evidence: Python NEL nodes failed and byte-order-mark nodes passed (`python-red-rc3.2026-10-16T06-25.md`); jest byte-order-mark elements failed and NEL elements passed (`ts-red-rc3.2026-10-16T06-25.md`). Corpus A/B: `g6-whitespace-corpus-ab-rc3.2026-10-16T07-16.md` (`PROBE_PYTHON_DIFFERS: True`, `PROBE_TYPESCRIPT_DIFFERS: True`, 509 plans, 0 differing per runtime, 1175 findings before and after). Docs: `.claude/rules/plan-acceptance-gates.md:153` and its bundle copy (`cmp` identical) state "declared once per runtime", "G6 uses the same class", and keep the fence-pattern residual sentence; `spec.md` NFR-2 note updated; asserted by `test_rule_file_states_g6_whitespace_alignment`. |
| Fence-pattern residual, U-2, U-3, CR-6, CR-7 | Declined by orchestrator | Unchanged. |

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Info (Non-blocking, related) | `scripts/dev_tools/plan_gate_discrimination.py`; `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` | `plan_gate_discrimination.py:249-253`; `plan-gate-rules.ts:347-352,373-378` | N-4. The G5 plan-quotation exoneration still normalizes plan text with each runtime's native whitespace class (`str.split()` and `/\s+/`). A plan that contains the literal's words joined by NEL, an information separator, or the byte-order mark outside the originating command span can be exonerated in one runtime and not the other. | No action required for this item; the residual is documented. If full alignment is wanted later, replace both calls with `normalize_plan_whitespace` / `normalizePlanWhitespace` and add one fixture per direction. | The code is unchanged since the merge base and outside the N-3 scope (single-line test and window join). The rule file and NFR-2 note state the residual accurately, and `test_rule_file_states_g6_whitespace_alignment` asserts the sentence. The input is plan text the author controls, and the cycle-1 corpus scan found such characters in one documentation file only. | Rule file: "the plan-quotation exoneration, which reads the plan text rather than a tracked file, keeps each runtime's native class". Severity: Non-blocking. Remediability: autonomous. |

## Unrelated Observations (not introduced by this item)

- U-2 (unchanged). Running jest from the repository root prints "Coverage data ... was not found" lines for pre-existing per-file threshold keys; the package script run used here exits 0. Unrelated because it depends on the invocation directory and concerns threshold keys that pre-date the branch; `jest.config.cjs` is unchanged by cycle 3. Previously declined.
- U-3 (unchanged). `issue.md:5` records the promotion path without the folder's date prefix; produced by the promotion tooling and shared by most active `issue.md` files. Previously declined.
- The untracked `SCRATCH/` directory at the worktree root is executor state, not part of the branch, and is not a finding.

## Design and Correctness Notes

- Placement: the extractor module is the lowest common dependency of G6 (`plan_gate_discrimination.py`, `plan-gate-rules.ts`) and G10 (`plan_gate_scratch.py`, `plan-gate-scratch.ts`) and imports neither, so the move adds no import edge and avoids the cycle that placing the class in `plan_gate_discrimination.py` would have created with `plan_gate_scratch.py`.
- Empty-literal semantics: `normalize_plan_whitespace("")` returns `""`, and `"".split(" ")` returns a single empty element in both Python and JavaScript, so `len(words) < 2` returns false in both runtimes, as before. A single-word literal likewise returns false. The `words[0] ?? ""` fallback in TypeScript remains unreachable after the length check; it is pre-existing and accounts for the one partial branch in `plan-gate-rules.ts` at line 426.
- Candidate lookup: the first word passed to `files_containing` / `filesContaining` is now the first class-delimited word, so a literal whose first word contains NEL is searched as one token in both runtimes; before the change Python split it and TypeScript did not.
- Window filter: `_window_join` / `windowJoin` now normalize first and drop empty results, which is equivalent to the previous blank-line filter under the shared class and removes the remaining use of native `strip()` / `trim()` in G6.
- `plan_gate_scratch.py` still compiles its own `_WHITESPACE_RUN_RE` from the imported class for the leading-character test; the class string itself is declared once, which is what the declaration-count test checks. A compiled regex is not a second declaration.
- Removing the `PLAN_WHITESPACE_CLASS` export from `plan-gate-scratch.ts` is not a breaking change: the export was introduced on this branch in cycle 2 and has no consumer outside the branch; `npm run typecheck` passes.
- Empty-needle tests: the Python and TypeScript cases use the literal `' '` with `-F`, which is checkable, absent from the stub tree, and normalizes to an empty needle. Removing the guard would make `"" in remainder` / `remainder.includes("")` true and suppress the expected finding; the reviewer's in-memory Python mutation probe confirmed the test fails in that case. In Python the case executes the guard at `plan_gate_discrimination.py:251-252`, which the cycle-3 baseline reported unexecuted (baseline line 251).

## Positive Observations

- The declaration-count test fixes the location of the class as well as its value, so a future second copy fails a test rather than drifting silently.
- Each fixture direction was recorded failing in exactly the runtime that previously diverged, which shows the four cases are discriminating rather than incidental.
- The corpus A/B reports discriminating probes for both runtimes separately before reporting zero differing plans.
- No `any`, no suppression, no new dependency, no changed file over 500 lines, and no temporary-file API in tests.
