# Code Review: plan-validator-accepts-bare-scratch-paths (Issue #932) — Re-review after Remediation Cycle 2

- Review timestamp: 2026-10-16T05-25 (UTC)
- Branch / head: `bug/plan-validator-accepts-bare-scratch-paths-932` @ `95d61f2a5fcdef6cbb25e8152dac60cb4ca3daf9`
- Base: `origin/main`, merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- Scope: full branch diff (208 files), with the cycle-2 range `64fb37f2b..95d61f2a5` read line by line. Companion artifacts: `policy-audit.2026-10-16T05-25.md`, `feature-audit.2026-10-16T05-25.md`.
- Prior review: `code-review.2026-10-16T03-15.md` (no Blocking finding; related N-1, N-2; unrelated U-1 to U-3, of which U-1 was reclassified as related by the orchestrator).

## Executive Summary

Cycle 2 resolves N-1, N-2, and U-1 as specified in `remediation-inputs.2026-10-16T03-19.md`. Each G10 module now declares one explicit whitespace class with an identical pattern string and uses it for the blank-line test, the continuation test, and normalization; the class is exactly the set on which Python `str.isspace()` and the JavaScript `\s` class agree, which the reviewer confirmed over every code point. A Python test pins the TypeScript string to the Python string, and both suites carry frozen fixtures for NEL, U+001F, the byte-order mark, and U+00A0. The G6 cross-line check now splits tracked text with `split_plan_lines`, with form-feed and U+2028 fixtures in both suites and a 508-plan corpus A/B showing no G1-G9 result change.

No Blocking finding exists. One related Non-blocking finding (N-3) is recorded: the G6 normalization step in the same function still uses the native whitespace classes.

Reviewer verification performed: `black --check`, `ruff check`, `pyright` on 11 Python files (clean); Python plan-gate suites with branch coverage (196 passed); contract and Codex suites (634 passed); bundle node test (1 passed locally); `prettier --check` and `eslint` on 11 TypeScript/config files (clean); repository `lint` and `typecheck` scripts (exit 0); `npm run test:coverage` (271 suites, 4023 tests, exit 0); plan self-validation for all three plans (exit 0); a Python and Node probe of whitespace classification (results quoted below).

## Cycle-2 Resolution Check

| Prior ID | Status | Evidence |
| --- | --- | --- |
| N-1 | Resolved | `PLAN_WHITESPACE_CLASS` at `scripts/dev_tools/plan_gate_scratch.py:79-81` and `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts:77`; used at `plan_gate_scratch.py:100,150,162` and `plan-gate-scratch.ts:90,107,179`. Probe: both engines report the class as `0009-000d 0020 00a0 1680 2000-200a 2028 2029 202f 205f 3000` (24 code points); Python `isspace()` additionally has `001c-001f 0085`, JavaScript `\s` additionally has `feff`, so the class is the exact intersection. Fixtures: `tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py` (`nel-led`, `unit-separator-led`, `bom-led`, `nbsp-led`, `space-then-nel`, four `*-inline`), `plan-gate-scratch.test.ts:271-315`. String parity: `test_whitespace_class_matches_typescript`. Docs: `.claude/rules/plan-acceptance-gates.md:153` (bundle copy byte-identical by `cmp`), `spec.md` detection-contract items 4 and 6 and NFR-2 note; asserted by `test_rule_file_states_g10_whitespace_alignment`. |
| N-2 | Resolved | `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts:268` reads "The Python `split_plan_lines` yields no trailing empty line". |
| U-1 | Resolved | `scripts/dev_tools/plan_gate_discrimination.py:278-279` uses `split_plan_lines`; the literal check no longer calls `splitlines()`. The three remaining `splitlines()` calls (`:131,140,149`) parse git command output (path lists), not tracked file text, and are outside U-1. Fixtures: `test_g6_window_split_ignores_form_feed_and_line_separator` (2 params) and `plan-gate-discrimination-literals.test.ts:143-172`; red evidence `evidence/regression-testing/python-red-rc2.2026-10-16T04-19.md`. Corpus A/B: `evidence/regression-testing/g1-g9-corpus-ab-rc2.2026-10-16T05-08.md` (508 plans, 0 differing, 1175 findings before and after, probe discriminates). |
| CR-6, CR-7 | Declined by orchestrator | Unchanged. |

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Low (Non-blocking, related) | `scripts/dev_tools/plan_gate_discrimination.py`; `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` | `plan_gate_discrimination.py:258,280`; `plan-gate-rules.ts:345-350,394,429` | N-3. G6 whitespace normalization in `_has_cross_line_presence` and `_window_join` still uses Python `str.split()` / `str.strip()`, while the TypeScript twins use `/\s+/` and `trim()`. Cycle 2 aligned line splitting in this function but not normalization, so the same NEL / information-separator / byte-order-mark divergence N-1 removed from G10 remains in G6. | Either apply one explicit shared whitespace class to the G6 normalizers in both runtimes with a frozen fixture, or state the G6 normalization residual in the rule-file parity paragraph (bundle copy byte-identical) and the NFR-2 note. | The item modified this function in cycle 2 and the defect is the parity class this cycle addressed for G10; it can change a G5/G6 outcome between runtimes for a tracked file containing one of those characters. Practical incidence is low (the cycle-1 corpus scan found such characters in one documentation file). | Reviewer probe: Python `"a\x85b".split()` returns `['a', 'b']`; Node `"a\u0085b".split(/\s+/)` returns `["ab"]`. Severity: Non-blocking. Remediability: autonomous. |

## Unrelated Observations (not introduced by this item)

- U-2 (re-observed). Running jest from the repository root (`npx --prefix extensions/drm-copilot jest --config extensions/drm-copilot/jest.config.cjs --coverage`) printed 93 "Coverage data ... was not found" lines for per-file threshold keys and exited 1, although all 271 suites passed. The repository script `npm --prefix extensions/drm-copilot run test:coverage`, which runs with the package directory as working directory, printed none and exited 0, as did the executor's run from `extensions/drm-copilot/`. Unrelated because the behaviour depends on the invocation directory, affects threshold keys that pre-date the branch (for example the `src/lib/pr-context/` entries for issue #574), and `jest.config.cjs` is unchanged by cycle 2. The orchestrator's prior decline of U-2 still covers it.
- U-3. `issue.md:5` records the promotion path without the folder's date prefix; promotion-tooling output, declined.
- The untracked `SCRATCH/` directory at the worktree root is orchestrator state, not part of the branch, and is not a finding.

## Design and Correctness Notes

- Fence residual (documented, not a finding): both G10 modules keep the command extractor's fence pattern `^\s*` plus three backticks (`plan_gate_scratch.py:57`, `plan-gate-scratch.ts:62`), so a fence line led by NEL, an information separator, or the byte-order mark can be recognized differently by the two runtimes. The rule file paragraph states this and notes it applies to G1 through G9 as well, which is accurate: the extractor's `_FENCE_RE` / `FENCE_RE` (`plan_gate_commands.py:26`, `plan-gate-commands.ts:63`) are unchanged since the merge base.
- The definition and namespace regexes contain no `\s`; the definition pattern uses `[ \t]*`, and Python compiles it with `re.ASCII`, so `\b` agrees with JavaScript's non-Unicode `\b`. A byte-order mark or NEL kept verbatim in the normalized line therefore matches identically in both runtimes, as the `*-inline` fixtures confirm.
- The Python continuation test checks the leading character with `_WHITESPACE_RUN_RE.match(line)` (class followed by `+`), while TypeScript uses a dedicated single-character `LEADING_WHITESPACE_RE`. The two are equivalent for a prefix test; a dedicated Python constant would mirror the TypeScript structure more literally but is not required.
- The blank-line test now calls the normalizer (`normalizeWhitespace(line) === ""`, `not _normalize_whitespace(line)`), which allocates a joined string per line. G10 remains a single linear pass (NFR-3); the cost is not material for plan-sized inputs.
- The G6 splitter change drops a trailing empty element in Python that TypeScript keeps; an empty line contributes nothing to the single-line test or to `_window_join` / `windowJoin`, so results are unaffected, which the corpus A/B confirms.

## Positive Observations

- The whitespace class is written entirely with escapes and the parity test asserts the TypeScript string is ASCII, so a raw invisible character cannot enter either module unnoticed.
- The fixtures include both directions of the original divergence (characters Python treats as whitespace and JavaScript does not, and the reverse for the byte-order mark) and one positive non-ASCII member.
- The corpus A/B for the G6 splitter used a discriminating probe (`PROBE_DIFFERS: True`) before reporting zero differing plans.
- No `any`, no suppression, no new dependency, and no changed file over 500 lines.
