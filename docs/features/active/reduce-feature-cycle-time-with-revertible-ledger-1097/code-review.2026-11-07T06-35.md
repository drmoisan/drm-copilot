# Code Review: Stage Timing, Stage B, Cycle 2 Re-review (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `51d3886485956df68a68a38e920c7c3687ec4462`)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `9c63d1eb8eff7c33f6cf7b03fb4e587a69716f2a`
**Review Type:** Re-review of PR B after remediation cycle 2 (prior head `d854f13c3`)

---

## Executive Summary

The branch adds the `stage_timing` writer protocol to the orchestrate skill, the orchestrator agent, and the orchestrator-state rule in every copy; a PowerShell report module (`StageTiming.psm1`, 438 logical lines) and its entry script (36); two fixtures; and tests in Pester (43 new cases), Python (16 parametrized cases), and Jest (3 cases). Evidence reviewed: the PR-context artifacts, the full diff, the cycle 2 diff from `d854f13c3`, the plan and gate records, `artifacts/pester/`, `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, and the module changes in full.

Cycle 2 closed the prior Blocker and all four Minor items. The full Jest suite ran once with coverage (328 suites, 5287 tests, 0 failures; 97.06% lines and 93.67% branches repo-wide) and the artifact is on disk. The module now converts a positive integer `issue-num` to its decimal string and rejects 0, negatives, fractions, and booleans with an updated reason; the skill states both forms in all four copies; and the one-line stage-timing paragraph is split into bullets. Six new Pester cases execute every previously unexecuted arm, and `StageTiming.psm1` is at 168 of 168 covered lines.

No Blocker or Major finding remains. Three Nit items are carried forward and one new Nit is recorded; none blocks.

**What changed well:**
The integer conversion sits before the existing string check, so the string rule and the blank rule are unchanged and the new rule adds one branch. The integer test pairs a string-form file and an integer-form file for one issue, which would fail if the conversion produced a different type or value. The skill edit changed text only, and the four copies remain byte-identical to their sources.

**Top 3 risks:**
1. The writer protocol is prose for an LLM session. Nothing checks that a committed `stage-timing` file has well-formed entries until the report runs; malformed entries are reported as skipped.
2. Two entries with the same stage and attempt are summed without a report (carried Nit).
3. No CI result exists for the head; CI on the PR head remains the merge authority.

**PR readiness recommendation:** **Ready.** Open the PR for stage B.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Nit | `scripts/dev-tools/StageTiming.psm1` | module `.DESCRIPTION` and `Get-StageTimingSummary` help | The cycle 2 edit lengthened two help lines past the width used elsewhere in the file (one line holds the integer clause and the `stage_timing` clause together). The formatter and analyzer accept them. | Re-wrap the two help lines when the file is next edited. | Readability only. | Diff of `850fbb55f` |
| Nit | `scripts/dev-tools/StageTiming.psm1` | `Get-StageTimingSummary` | Two entries with the same stage and the same `attempt` are summed without a report (carried from the prior review). | Report a repeated attempt number as a skipped entry, or note that attempts are not checked. | The skill defines `attempt` as one more than earlier entries, so a repeat signals a writer defect. | Prior probe: two `attempt` 1 entries total 0:20:00 with 2 attempts |
| Nit | `scripts/dev-tools/StageTiming.psm1` | `ConvertTo-StageTimingInstant` | A time with no zone designator is read as UTC (carried). | State this in the help text or require the designator. | The skill asks for ISO-8601 UTC strings, so the leniency hides a writer error. | Prior probe: `2026-01-01T00:00:00` parses |
| Nit | `tests/scripts/dev-tools/StageTiming.Tests.ps1` | whole file | No property-based test exists for the median (carried). | None required: `scripts/dev-tools` is T4, which has no property-test density gate. | Recorded for completeness. | `quality-tiers.yml` check reports OK |

No file reaches the 700-line advisory tier (438, 410, 304, 167, and the smaller files), so no `Warning` row applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No change in cycle 2. `test_stage_timing_checkpoint_key.py` covers plain mode, completion and PR modes, a control that removes a required key, and three portable-handoff properties.

#### Typing and API notes

- No production Python changed. Test helpers are annotated and the docstrings carry Args and Returns.

#### Error handling and logging

- No change.

### PowerShell implementation audit

#### What changed well

- The integer guard is `($issue -is [long] -or $issue -is [int]) -and $issue -ge 1`, followed by an invariant-culture string conversion. `ConvertFrom-Json` yields `int` or `long` for whole numbers, `double` for `1.5`, and `bool` for `true`, so fractions and booleans fall through to the existing non-string rejection. The conversion is culture-independent.
- The reason text changed from `issue-num is missing or blank` to `issue-num is missing, blank, or not a string or a positive integer`; the existing blank-file test was updated to a shared script variable, so the string is stated once in the tests.
- The new `STR-ISSUE-ROWS-ORDER-SHORTER-ID-FIRST` case pins the numeric-length ordering of issue rows in both input orders.

#### API and safety notes

- All functions use `CmdletBinding` and `OutputType`; three of nine are exported. Nothing writes, so ShouldProcess does not apply. The format and lint gate at 06:11 reports exit 0.
- Coverage: `StageTiming.psm1` 168 of 168 lines and `Get-StageTimingReport.ps1` 7 of 7, read from `artifacts/pester/powershell-coverage.xml`.

#### Error handling and logging

- The only throw is the absent root. Other defects become skip lines, never silent drops, except the repeated attempt number (Nit).

### TypeScript implementation audit

#### What changed well

- No change in cycle 2. The test reads the committed back-compat checkpoint read-only, adds the key in memory, and compares error lists with and without it for three shapes in plain and `requireComplete` modes. The control removes `last_updated` and expects the exact error text.

#### Typing and API notes

- No `any`, no assertion, no suppression. `unknown` is narrowed before use.

#### Error handling and logging

- The fixture loader throws a specific error if the base checkpoint is not an object.

### Documentation audit

- The four orchestrate skill copies state `issue-num` as "a string of decimal digits, or an integer of 1 or more; both are read as the same issue". The module help states the same rule. The rule file `orchestrator-state.md` lines that mention a string `issue_num` describe a different key (`issue_num` in the issue-adoption record) and need no change.

---

## Test Quality Audit

43 new Pester cases pass within the recorded gate of 14591 tests. Module line coverage is 100% (168 of 168), and the entry script is 100% (7 of 7). The reviewer did not re-run suites, under the owner's rule of one parallel run per gate. Test discrimination was checked by reading the fixtures: the integer case would yield two issues rather than one if the conversion failed; the non-positive case asserts the exact reason string for four distinct values; the missing-property cases assert distinct reasons for `stage`, `attempt`, and `started_at`. No source file was edited and no mutant run was made, so the evidence for mutation sensitivity is these readings and the coverage figure.

### Reviewed test and QA artifacts

- `artifacts/pester/pester-junit.xml` — 14591 tests, 0 failures, 0 errors, 10 disabled; all six new case names present.
- `artifacts/pester/powershell-coverage.xml` — root LINE 23618 of 25137; `StageTiming.psm1` 168 of 168; `Get-StageTimingReport.ps1` 7 of 7.
- `artifacts/python/lcov.info` — LH 32270 of LF 33367, BRH 11722 of BRF 12516, equal to `stage-b-python-test.2026-11-07T05-52.md`; no Python path changed in cycle 2.
- `extensions/drm-copilot/coverage/lcov.info` — LH 61859 of LF 63730, BRH 9388 of BRF 10022, equal to `stage-b-typescript-coverage.2026-11-07T06-17.md`.
- `evidence/qa-gates/self-review.2026-11-07T06-19.md` — reports no FAIL row; consistent with this review.

### Quality assessment prompts

- **Determinism:** the module reads no clock; tests use fixed time strings.
- **Isolation:** in-memory inputs; the script test reads committed fixtures.
- **Speed:** the Pester gate took 302.36 seconds across 8 shards.
- **Diagnostics:** the TypeScript and Python assertions carry the shape name with the error list.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected. |
| No unsafe subprocess or command construction | N/A | No process is started. |
| Input validation at boundaries | ✅ PASS | JSON parse failures, wrong shapes, bad times, and non-positive or fractional `issue-num` become skip lines. |
| Error handling remains explicit | ✅ PASS | One `throw`; the JSON catch returns a reason. |
| Configuration / path handling is safe | ✅ PASS | `-LiteralPath`; the module writes nothing. |

---

## Research Log

No external research was required.

---

## Verdict

**Ready.** No Blocker, Major, or Minor finding remains. The prior Blocker (F1) and all four prior Minor items are closed. Four Nit items are recorded and fit the first stage that touches these files. CI on the PR head remains the merge authority.
