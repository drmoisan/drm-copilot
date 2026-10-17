# Code Review: plan-validator-accepts-bare-scratch-paths (Issue #932) — Re-review after Remediation Cycle 1

- Review timestamp: 2026-10-16T03-15 (UTC)
- Branch / head: `bug/plan-validator-accepts-bare-scratch-paths-932` @ `b752fc1f7825f858f5311dafce92b99fe935c46d`
- Base: `origin/main`, merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- Scope: full branch diff (155 files), with the cycle-1 range `a2f2c0332..b752fc1f7` read line by line. Companion artifacts: `policy-audit.2026-10-16T03-15.md`, `feature-audit.2026-10-16T03-15.md`.
- Prior review: `code-review.2026-10-16T01-52.md` (CR-1 Blocking; CR-2 to CR-7 Non-blocking).

## Executive Summary

Cycle 1 resolves CR-1 through CR-5 as specified. The change is small and keeps the two runtimes in step: each runtime now has one exported line splitter used by both the command extractor and G10, the continuation predicates contain only reachable conditions, and new fixtures in both suites freeze the indented-heading, indented-task-line, form-feed, and U+2028 behaviour. The ESLint configuration gap is closed without touching `jest.config.cjs`. No regression was found: the full jest run (271 suites, 4020 tests), 183 Python plan-gate tests, and 634 contract/Codex tests pass, and a corpus scan shows no existing plan whose G1-G9 line numbers change under the new splitter.

No Blocking finding remains. Two related Non-blocking documentation findings (N-1, N-2) are new in cycle 1. CR-6 and CR-7 are declined by the orchestrator and are not re-raised.

Reviewer verification performed: `black --check`, `ruff check`, `pyright` on 9 Python files (clean); Python plan-gate suites with branch coverage (183 passed); contract and Codex suites (634 passed); `prettier --check` and `eslint` on 10 TypeScript/config files (clean); `eslint --print-config` for `jest.config.cjs`; repository `lint` script (exit 0); both `tsc --noEmit` projects (exit 0); full `jest --coverage` (271 suites, 4020 tests); plan self-validation for both plans (exit 0); a Python and Node probe of whitespace classification (results quoted below).

## Cycle-1 Resolution Check

| Prior ID | Status | Evidence |
| --- | --- | --- |
| CR-1 (Blocking) | Resolved | `extensions/drm-copilot/eslint.config.mjs:18-31` adds `files: ["**/*.cjs"]`, `sourceType: "commonjs"`, globals `module`, `require`, `__dirname`, `process`; reviewer ESLint over the seven `[P3-T6]` paths exit 0; `jest.config.cjs` unchanged since `a2f2c0332`; `[P3-T6]` checked at `plan.2026-10-15T15-45.md:203`; evidence `evidence/regression-testing/ts-lint-phase3.2026-10-16T02-54.md`. The trailing-space fix on the closing `);` line is a formatting-only change. |
| CR-2 | Resolved | `plan_gate_scratch.py:72-83` and `plan-gate-scratch.ts:80-92` keep only the blank, leading-whitespace, and fence conditions; docstrings state the column-0 rule. Stop fixture ids renamed (`test_plan_gate_scratch.py:98-101`); absorb fixtures added in both runtimes (`test_plan_gate_scratch.py:103-114,305-318`; `plan-gate-scratch.test.ts:230-251`). |
| CR-3 | Resolved | `.claude/rules/plan-acceptance-gates.md:15,17,292`; `test_plan_gate_scratch_docs.py:140-152` asserts the new phrases and the absence of the superseded ones; bundle copy byte-identical (`cmp`). The H1 `(G1 through G6)` is intentional per `.claude/rules/plan-acceptance-gates.md:45`. |
| CR-4 | Resolved (splitting); residual documented | `split_plan_lines` (`plan_gate_commands.py:292-327`) and `splitPlanLines` (`plan-gate-commands.ts:263-276`) split on `\r\n|\n|\r` only, used by both extractors and both G10 modules. Fixtures: `test_plan_gate_commands.py:303-359`, `test_plan_gate_scratch.py:115-126,321-334`, `plan-gate-commands.test.ts:247-278`, `plan-gate-scratch.test.ts:253-269`. Residual whitespace-class divergence documented at `.claude/rules/plan-acceptance-gates.md:153`, with one gap (N-1). |
| CR-5 | Resolved | `.claude/rules/plan-acceptance-gates.md:169`; `spec.md:237`; ordering asserted by `test_plan_gate_scratch_docs.py:155-169`. |
| CR-6 | Declined by orchestrator | Run rule "Delete nothing". |
| CR-7 | Declined by orchestrator | Original plan `P1-T5` prohibits `it.each`. |

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Low (Non-blocking, related) | `.claude/rules/plan-acceptance-gates.md` and bundle copy; `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md` | rule `:153`; `spec.md` NFR-2 note (`:211`); code `plan_gate_scratch.py:81`, `plan-gate-scratch.ts:88` | N-1. The parity-residual sentence attributes the remaining divergence to whitespace normalization only. The continuation test diverges for the same characters: Python uses `line[:1].isspace()` and `line.strip()`, TypeScript uses `/^\s/` and `trim()`. A physical line that begins with NEL or an information separator continues the logical line in Python and ends it in TypeScript (and the reverse for a leading byte-order mark), so the two runtimes report different message text. | Extend the residual sentence in the rule file (and bundle copy, byte-identical) and the NFR-2 note to name the continuation test as a second affected step, or align the continuation test on an explicit shared whitespace set in both runtimes. | NFR-2 and the rule file present the residual as the complete list of known divergences; it is currently incomplete. | Reviewer probe: Python `bare_scratch_definitions("- SCRATCH means the session scratchpad.\n\x85continued text")` returns `[(1, '- SCRATCH means the session scratchpad. continued text')]`; Node `/^\s/.test("\x85a")` is `false`, `/^\s/.test("﻿a")` is `true`; Python `"\x85a"[:1].isspace()` is `True`, `"﻿a"[:1].isspace()` is `False`. |
| Info (Non-blocking, related) | `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` | `:268-272` | N-2. The body comment in `splitPlanLines` still explains the trailing-element drop by reference to Python `str.splitlines()`; since cycle 1 the Python counterpart is `split_plan_lines`, which does not call `splitlines()`. | Reword the comment to name `split_plan_lines` (the JSDoc at `:256-258` already does). | A comment that names the superseded counterpart misleads the next maintainer about which function must stay in parity. | File inspection at head `b752fc1f7`. |

## Unrelated Observations (not introduced by this item)

- U-1. `scripts/dev_tools/plan_gate_discrimination.py:277` splits tracked repository files with `str.splitlines()` while `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts:428` uses `/\r\n|\n|\r/`. Unrelated because the code exists identically at the merge base (`:275` and `:428`), is not touched by this branch, and concerns the G1-G9 wrapped-literal check over repository source files rather than plan text or G10.
- U-2. The full jest run prints `Coverage data for ./src/lib/validate/orchestration-handoff-validation.ts was not found` and five similar lines for other per-file threshold entries. Unrelated because those entries pre-date the branch (for example `semantic-mcp-identity.ts` is present in the merge-base `jest.config.cjs`) and the run exits 0.
- U-3. `issue.md:5` records the promotion path without the folder's date prefix; this is promotion-tooling output shared by many active `issue.md` files, carried over from the prior review.
- The untracked `SCRATCH/` directory at the worktree root is orchestrator state, not part of the branch, and is not a finding.

## Design and Correctness Notes

- Shared splitter: the Python implementation (`_LINE_BREAK_RE.split` plus trailing-empty drop) and the TypeScript implementation produce identical lists for the frozen cases `""`, `"a\n"`, `"a\r\nb\rc\n\n"`, and `"a\fb c"` in both suites.
- Extractor behaviour change: the Python extractor previously used `str.splitlines()`, so G1-G9 line numbers could differ from TypeScript for plans containing `\v`, `\f`, `\x1c`-`\x1e`, NEL, U+2028, or U+2029. A reviewer scan of `docs/**/*.md` found one such file, a completed feature-audit, and no plan or remediation-plan, so no recorded G1-G9 result changes.
- Import graph: `plan_gate_scratch.py` and `plan-gate-scratch.ts` now import only the splitter from the extractor modules; the extractor modules do not import G10, so the graph remains acyclic.
- The ESLint `**/*.cjs` block also applies to any other `.cjs` file in the package; it only adds globals and sets `sourceType`, and the repository `lint` script scope (`src`, `test`) is unchanged.

## Positive Observations

- Each cycle-1 test was recorded failing before the fix (`evidence/regression-testing/python-red-rc1.2026-10-16T02-45.md`, `ts-red-rc1.2026-10-16T02-46.md`).
- No `any`, no suppression, no new dependency, and no changed file over 500 lines.
- The documentation tests assert both the presence of the corrected sentences and the absence of the superseded ones.
