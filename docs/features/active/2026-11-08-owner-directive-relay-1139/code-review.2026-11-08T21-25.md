# Code Review: Owner-Directive Relay (#1139) - Re-review after Remediation Cycle 1 and the Third Main Sync

---

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-owner-directive-relay-1139`
**Feature Folder Selection Rule:** Named by the caller; matches issue #1139 and branch `feature/owner-directive-relay`.
**Base Branch:** `main` (`origin/main` at merge base `5698f7de2` after the third sync merge 38ee3c0e7)
**Head Branch:** `feature/owner-directive-relay` at `38ee3c0e7`
**Review Type:** Re-review (remediation cycle 1), full branch diff from the merge base

---

## Executive Summary

The branch adds a key-gated owner-directive check: the pure module `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` (378 lines) applies rules B1-B8 and R1-R10 to the checkpoint text, and `.claude/hooks/validate-orchestrator-output.ps1` calls it only when a top-level `owner_directives` or `owner_directive_records` property is present. A new `owner-directives` skill (six byte-identical copies), pointer sentences, a rule section, a brief bullet, and a one-line digest re-pin complete the change.

Cycle 1 changed `ConvertFrom-OwnerDirectiveDateText` only: a function-local, case-sensitive pattern `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]+)?)?(Z|[+-][0-9]{2}:[0-9]{2})?\z` is matched before the unchanged invariant-culture `TryParse`, and text outside it returns `$null`, so B7 and R9 report it with their existing strings. The bundle copy is byte-identical. Tests added 8 B7 reject rows, 3 B7 accept rows, 3 R9 rows, and 2 calendar-invalid rows. Evidence reviewed: PR context at 38ee3c0e7, cycle-1 evidence (baseline reference, bundle parity, two static loops, two gate runs, self-review), the coverage and JUnit artifacts (parsed independently), and direct and mutant probes of the date helper.

**What changed:**
One new PowerShell module and one new hook helper plus a 6-line call site; documentation across 26 skill, agent, rule, and brief files (including mirrors and bundle copies); four new and two edited Pester files; one Python literal. Cycle 1: 6 production lines in the module (and bundle copy), 46 test lines.

**Top 3 risks:**
1. The third `origin/main` sync merge (38ee3c0e7, PR #1143) resolved one digest conflict; the pins equal the merged file digests, and the reviewer re-ran the full Pester (20693 tests) and pytest (16560 tests) gates at 38ee3c0e7 with 0 failures. CI on the PR head remains authoritative.
2. Strict shape rejects lowercase `z`/`t` and basic-format offsets (`+0530`); no documented writer emits these, and the documentation examples use `...Z`.
3. Same-session forgery and the Codex/Python/TypeScript enforcement gaps are inherent and disclosed; origin rests on the coordinator procedure.

**PR readiness recommendation:** **Go** - no Blocker, Major, or Minor finding remains; F1 is closed.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` | `ConvertFrom-OwnerDirectiveDateText`, lines 90-112 | F1 (prior Minor) closed: non-ISO values now return `$null` and produce B7 or R9. | None. | Shape guard precedes `TryParse`; callers unchanged. | Reviewer probe at 38ee3c0e7: the three observed values plus date-only, space separator, trailing line feed, non-ASCII digit, leading space all yield B7; non-ISO `decided_at` yields R9; ISO accept forms yield no error. |
| Info | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1`, `...Records.Tests.ps1` | cycle-1 rows | New rows discriminate the change. | None. | A test that cannot fail would not pin the fix. | Mutant with the shape guard disabled: 8 non-ISO rows give 0 errors (head 1). Mutant with the TryParse-failure return disabled: 2 calendar-invalid rows give 0 errors (head 1). |
| Info | `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` | shape pattern | Case-sensitive; extended offsets only. Lowercase `z` and `+0530` are rejected. | None required. | Matches the remediation design and documented examples; stricter than RFC 3339, which no document claims. | Probe rows `2026-11-08T10:00:00z`, `+0530` yield B7. |
| Info | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` | whole file | Bundle copy byte-identical. | None. | Push-down payload matches the root module. | Reviewer `sha256sum`: both `cf9cc6eef6ee...a1e8c`. |
| Info | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1` | split token | D1: `('Start-' + 'Process')` in the AST forbidden-command list. | None. | Accepted in the prior review; data in an assertion, precedent on main. | grep of `tests/scripts` |
| Info | `.claude/rules/orchestrator-state.md` | new section | D2: additions to a rules-folder contract document. | None. | Accepted in the prior review; unchanged by cycle 1. | `git log -- .claude/rules/orchestrator-state.md` |

No Blockers, Major, or Minor findings. No covered file is at or above 700 logical lines (largest: FailClosed tests 510, expectations module 457, hook 413), so no file-size Warning applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The single Python edit is the epic-orchestrate digest in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (numstat 1/1), verified in the prior review; cycle 1 touched no Python file.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- Not applicable; no Python logic changed.

### PowerShell implementation audit

#### What changed well

- The shape guard is anchored with `^` and `\z` (no trailing line feed admitted), uses ASCII digit classes and `-cnotmatch`, and is a local value, so behavior is culture- and host-independent.
- `TryParse` keeps the invariant culture with `AssumeUniversal` and `AdjustToUniversal`; the AST row asserting UTC styles still passes.
- The helper comment now states the accepted shape and both rejection cases.
- Parsing with `JsonDocument`, ordinal last-definition-wins property reads, error ordering, R7 counting, and the `finally` disposal are unchanged from the prior review.

#### API and safety notes

- One exported function; no new function in cycle 1. Under `.claude/hooks/` and `.codex/hooks/` only `validate-orchestrator-output.ps1` and its bundle copy changed on the branch, and not in cycle 1.

#### Error handling and logging

- Every error path returns a block with `Repairable = $true`; no silent catch.

---

## Test Quality Audit

The four new suites assert each B and R rule against its exact spec string. Cycle 1 adds B7 reject rows for the three observed non-ISO values on each of `recorded_at` and `expires_at`, plus space-separator and date-only rows; B7 accept rows for minute-only, fractional, and zone-less ISO forms; R9 rows for the three values on `decided_at`; and calendar-invalid in-shape rows. Merged JUnit shows 14/3/3/2 rows, 0 failed. Module coverage is 100% (151/151), reproduced by the reviewer.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1` - B1-B8, purity AST row; 74 tests.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1` - R1-R10 including R9 non-ISO; 53 tests.
- `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1` - 22 tests.
- `tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1` - 56 tests.
- `evidence/qa-gates/pester.2026-11-08T21-25.md` - full parallel gate, 0 failures, coverage comparison.
- `evidence/qa-gates/pester.2026-11-08T20-31.md` - gate run 1, coverage drop that led to the calendar-invalid It.

### Quality assessment prompts

- **Determinism:** fixed literals, no clock, culture restored in `finally`.
- **Isolation:** one rule and one value per row.
- **Speed:** full gate 635.61 s on 8 workers.
- **Diagnostics:** exact-string assertions with `-Because` text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected; fixture texts and session ids are synthetic. |
| No unsafe subprocess or command construction | ✅ PASS | The module starts no process and calls no clock, file, or import command (AST row). |
| Input validation at boundaries | ✅ PASS | Whole-string anchored ISO shape check before parsing; ordinal top-level key gate in hook and module. |
| Error handling remains explicit | ✅ PASS | Rejection returns `$null`, reported as B7 or R9; throw converted to a repairable block; import failure fails closed. |
| Configuration / path handling is safe | ✅ PASS | Import path built from `$PSScriptRoot`; no path handling changed in cycle 1. |
| No directive-based allow path | ✅ PASS | No added `Ok = $true` line; the new branch can only return a block. |

---

## Research Log

No external research was required. The ISO 8601 extended form and RFC 3339 case allowance were assessed from the pattern and the repository documents.

---

## Verdict

The change is ready for normal PR flow. F1 is closed: the date helper accepts only the ISO 8601 extended date-time shape, the bundle copy is identical, and the new rows were shown by mutant probes to fail without the change. No blocking finding. The S9 CI green gate on the PR head remains the authoritative confirmation of the full suites.
