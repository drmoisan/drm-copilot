# Code Review — Issue #523 (Remediation Cycle 1 Re-Audit, R4)

- Timestamp: 2026-10-01T11-15
- Review head: `d65fa64afcd2e1263bfdb228d00c7c09a1b69f58` (local `resume-523-r2`, tracking `bug/blocked-reason-premise-falsified-halt-523-r2`)
- Base: `origin/epic/orchestrator-state-contract-correctness-integration`
- Scope: full branch diff (`git diff origin/epic/orchestrator-state-contract-correctness-integration...HEAD`), 165 paths; 56 outside `docs/features/`

## Executive Summary

The change is small in production code (two new pure modules of 80 and 74 lines, three one-to-four-line edits in existing validators, one Jest threshold entry) and is supported by a substantial, well-structured test surface: unit tests per runtime, a committed 20-case cross-runtime parity corpus, a 9-stem back-compat corpus that pins full error lists captured before the change, a partition oracle, and documentation drift tests.

The remediation cycle 1 change is correct and minimal. The exact-count pin `Should -Be 499` was replaced with a bound on the durable policy (500-line cap) plus a non-vacuity lower bound (`Should -BeGreaterThan 0`), which prevents a missing or empty file from satisfying the cap. The rewritten comments state why the bound replaced the pin. The other seven `It` blocks in that file are unchanged.

No Blocking or Major findings. Three Minor and three Info items are recorded below; none requires remediation before merge.

- Blocking findings: 0
- Major findings: 0
- FAIL findings: 0
- Blocking PARTIAL findings: 0
- blocking_count: 0

## Cycle 1 Finding F1 — Resolution Check

| Item | Result |
|---|---|
| Pin removed | `git diff` shows `- $lineCount \| Should -Be 499` removed; `It` renamed to `the orchestrator-state module stays within the 500-line file cap`. |
| Replacement is non-vacuous | `Should -BeGreaterThan 0` precedes `Should -BeLessOrEqual 500`; `@(Get-Content ...).Count` is 0 for an empty or absent file, so the lower bound fails in that case. |
| Module unchanged by remediation | `OrchestratorState.psm1` remains 492 lines in both copies; no lines re-added. |
| Fail-before / pass-after | `r1-cap-test-before.md` `Passed=7 Failed=1`; `r1-cap-test-after.md` `Passed=8 Failed=0`. |
| Full-suite confirmation | Reviewer parse of the iteration 2 `pester-junit.xml`: row present and `Passed`; failing set equals the P0-T26 set. |
| Scope amendment recorded | `evidence/other/change-set-amendment-p7-t14.md` (`CHANGE-SET AMENDMENT:` line, numstat `8 6`). |

Verdict: RESOLVED.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/orchestrate/SKILL.md` (and bundle) | Preparation-mode bullet list, new `**Premise-falsified halt.**` bullet | The producer guidance for `premise_falsified` sits inside the preparation-mode section, but a premise-falsified halt arises during execution, which preparation mode does not perform. A reader of execution-phase guidance may not find it. | In a follow-up, add a one-line cross-reference from the execution or checkpoint section, or move the bullet to a general checkpoint-recording section while keeping the preparation-mode `"none"` statement in place. | The spec requires both statements (when to use `premise_falsified`; preparation terminal checkpoint stays `"none"`), and co-locating them satisfies AC-16. Discoverability is the only concern. | Diff hunk `@@ -137,6 +137,7 @@` |
| Minor | `.agents/skills/orchestrate/SKILL.md` (and bundle) | Bullet after "Do not edit production code, execute the plan, ..." | Same placement observation as above: the guidance follows a bullet that forbids executing the plan. | Same as above. | Same as above. | Diff hunk `@@ -128,6 +128,11 @@` |
| Minor | `.claude/lib/orchestrator-state/OrchestratorState.psm1` (and bundle) | Lines 97-99 | The grouped arrays are single lines of roughly 190 and 140 characters. Formatter and analyzer accept them, and the spec selected the compact form for line-budget reasons. | Optional: if headroom is later needed elsewhere, keep the compact form; otherwise consider wrapping each array across two lines (the file is at 492 of 500). | Readability of long literal lines; no correctness impact. | `evidence/qa-gates/poshqc-format-final.md`, `pssa-direct-final.md` |
| Info | `scripts/dev_tools/_orchestrator_state_blocked_reason.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts` | `classify_blocked_reason` / `classifyBlockedReason` error message | Python renders the rejected value with `repr` (`'halted'`), TypeScript with `String()` (`halted`). Both follow the spec, which fixes only the prefix `invalid blocked_reason: `. | None required. If a consumer later compares helper messages across runtimes, align the rendering at that time. | The helpers are not called by validators; validator messages are identical across runtimes. | spec.md Proposed Fix items 1 and 2 |
| Info | `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py` | Module docstring | Property-based tests are replaced by exhaustive parametrized enumeration because `hypothesis` is not a dependency. For a 12-member closed vocabulary, exhaustive enumeration covers the full input domain of valid values. | None. | Documented deviation with adequate substitute coverage. | Lines 9-11 |
| Info | Review environment | Raw coverage artifacts | The raw gitignored coverage files are in the executor worktree, not the review worktree. The reviewer confirmed identical code paths between the two heads and parsed the raw files directly. | None for this branch. | Recorded so later reviewers know where the figures were verified. | policy-audit 1.2 |

## Detailed Review

### Python

- `_orchestrator_state_blocked_reason.py`: immutable `frozenset` constants, a `Literal` alias for the class, and a pure classifier with a single raise path. The `isinstance(value, str)` guard precedes set membership, so unhashable values (list, dict) cannot raise `TypeError`. `value == "none"` before the `isinstance` check is safe for all JSON-decoded types.
- `validate_orchestrator_state.py`: the constant is imported (isort-ordered) and the membership condition gains `not isinstance(blocked_reason, str) or ...`. The message f-string and its list position are unchanged, which the back-compat corpus confirms. `set` to `frozenset` change: `evidence/other/python-constant-mutation-search.md` records no mutation site.

### TypeScript

- `orchestrator-state-blocked-reason.ts`: `ReadonlySet<string>` exports, `unknown` input narrowed by `typeof`, `RangeError` thrown with the spec prefix. No `any`. JSDoc present on every export.
- `orchestrator-state-core.ts`: local constant removed, imported, and re-exported with `export { VALID_BLOCKED_REASONS };`, so existing importers are unaffected (verified by the Jest identity case, which passed in the reviewer re-run).
- `jest.config.cjs`: per-file threshold added adjacent to the core entry, consistent with the map's no-`global` convention.

### PowerShell

- `$script:VALID_BLOCKED_REASONS` composed from the two grouped arrays; membership and readiness comparisons switched to case-sensitive operators. These are the only logic edits; `Export-ModuleMember`, completion checks, and hooks are untouched.
- Tests use `InModuleScope` to reach the private readiness function and the script-scoped arrays, with in-memory `[pscustomobject]` checkpoints. The ordinal-sort join helper gives a case-sensitive set comparison.

### Documentation

- The rules section is inserted at the specified anchor and contains the vocabulary table, partition definitions, enforcement-parity statement, `human_interaction` relationship, producer guidance, and the #484 extension point. `## Enforcement` is not edited.
- The `.agents` orchestrator-workflow enumeration appends the five members with definitions and a partition paragraph; the six documentation-only members and the `MUST be one of:` fragment are retained.
- All five repository / bundle pairs are byte-identical (reviewer `cmp`).

### Tests and Fixtures

- Parity readers in all three runtimes enforce name-equals-stem and a minimum case count, so an empty or unreadable corpus directory fails.
- The back-compat corpus was captured from unmodified validators (P1-T11 evidence) and hash-pinned before and after, which gives strong evidence for AC-13.
- No temporary files, no clock or timer use, no external processes.

## Verdict

APPROVE. No Blocking or Major findings. F1 is resolved. The three Minor items are documentation-placement and readability observations suitable for a follow-up.
