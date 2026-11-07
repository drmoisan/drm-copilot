# Code Review: Stage Timing, Stage B (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `51d3886485956df68a68a38e920c7c3687ec4462`)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `d854f13c3da7d3d97873cb4b8adab47e3a8fa7dc`
**Review Type:** First review of PR B (stage A merged as PR #1100)

---

## Executive Summary

The branch adds the `stage_timing` writer protocol to the orchestrate skill, the orchestrator agent, and the orchestrator-state rule in every copy; a PowerShell report module (`StageTiming.psm1`, 434 logical lines) and its entry script (36); two fixtures; and tests in Pester (34 cases), Python (16 parametrized cases), and Jest (3 cases). Evidence reviewed: the PR-context artifacts, the full diff, the plan and gate records, `artifacts/pester/`, `artifacts/python/lcov.info`, the two production files in full, the Jest test in full, and direct probes of the module and the script.

The design is sound. Only `Read-StageTimingEvidence` touches the file system and it writes nothing; summary and format functions are pure; every skip carries a reason; the report states that its figures are wall-clock and that the merge stage is not captured. The eight mirrored text copies are byte-identical to their sources. The tolerated-key tests include a control that proves the validator ran.

One blocking policy gap: the Jest gate ran a 24-suite subset with coverage off, so the TypeScript change has no coverage artifact and no full-suite result (F1, also in the policy audit). Four Minor and three Nit findings do not block.

**What changed well:**
The report skips a malformed file or entry with a reason instead of failing the run. The entry script's default root is resolved in the body so the line is measured, a fix made after the first gate showed the entry at 83.33%. The Python tests exercise the real portable-handoff builders and prove the archive hash binds the key.

**Top 3 risks:**
1. The only TypeScript test of the stage has never run inside a coverage-enabled full Jest run, so a cross-suite interaction would first appear in CI.
2. The writer protocol is prose for an LLM session. Nothing checks that a committed `stage-timing` file has well-formed entries until the report runs; malformed entries are only reported as skipped.
3. A writer that copies `issue-num` from the checkpoint as a JSON number has its whole file skipped. The skip is visible in the report, but the recorded data is lost to the medians.

**PR readiness recommendation:** **Not ready** until F1 is closed. No other Blocker.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/test/lib/validate/orchestrator-state-stage-timing.test.ts` | Jest gate | `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` are absent. The recorded gate ran `--testPathPattern "test/lib/validate/orchestrator-state" --coverage=false`, a 24-suite subset, so no full Jest result exists either. | Run `node run-jest.cjs --coverage` once in `extensions/drm-copilot` (Jest runs in parallel by default), record the result under `evidence/qa-gates/`, and leave the artifact in place. | A language with a changed file needs a coverage artifact; the TypeScript toolchain stage is the full suite. | `ls` of both paths; `evidence/qa-gates/stage-b-typescript-test.2026-11-07T05-48.md` |
| Minor | `scripts/dev-tools/StageTiming.psm1` | `ConvertTo-StageTimingInstant`, line 81 | The non-string and blank return has no test. This is the one unexecuted line of 166 and is reachable through an entry with no `started_at`. | Add a skipped-entry case with a missing `started_at` to `StageTiming.Tests.ps1`. | The branch is real input handling and nothing would report its removal. | `powershell-coverage.xml` line 81 `mi="1"`; probe: a missing `started_at` reports `started_at is not an ISO-8601 time` |
| Minor | `scripts/dev-tools/StageTiming.psm1` | `ConvertTo-StageTimingRecord`, lines 163, 169, 175 | The property-absent arm (`else { $null }`) of three reads is unexecuted: a missing `stage`, `attempt`, or `started_at` property. Line 327 (a stage with only open entries) is also half covered. | Add one case per missing property, and one issue with only an open entry for a stage. | Same rationale; each arm produces a distinct skip reason. | Coverage lines 163, 169, 175, 327 with `mi="1"` |
| Minor | `scripts/dev-tools/StageTiming.psm1` | `ConvertFrom-StageTimingText`, `issue-num` check | A JSON number for `issue-num` skips the whole file as "missing or blank". The checkpoint's own `issue-num` may be read as a number by a writer. | State the string requirement beside the example in the skill, or accept an integer and convert it. | A silent loss of data from the medians, with only a skip line. | Probe: `issue-num` 1097 as a number prints `issue-num is missing or blank` |
| Minor | `.claude/skills/orchestrate/SKILL.md` | `## Checkpoint Handling`, item 6 | The paragraph is a single long line that holds the writer protocol, the evidence file rules, the handoff behavior, and the report command. | Split into short bullets when the file is next edited. | Four copies carry the same line, so any edit is made four times. | Diff inspection |
| Nit | `scripts/dev-tools/StageTiming.psm1` | `Get-StageTimingSummary` | Two entries with the same stage and the same `attempt` are summed without a report. | Report a repeated attempt number as a skipped entry, or note that attempts are not checked. | The skill defines `attempt` as one more than earlier entries, so a repeat signals a writer defect. | Probe: two `attempt` 1 entries total 0:20:00 with 2 attempts |
| Nit | `scripts/dev-tools/StageTiming.psm1` | `ConvertTo-StageTimingInstant` | A time with no zone designator is read as UTC. | State this in the help text or require the designator. | The skill asks for ISO-8601 UTC strings, so the leniency hides a writer error. | Probe: `2026-01-01T00:00:00` parses |
| Nit | `tests/scripts/dev-tools/StageTiming.Tests.ps1` | whole file | No property-based test exists for the median. | None required: `scripts/dev-tools` is T4, which has no property-test density gate. | Recorded for completeness. | `quality-tiers.yml` check reports OK |

No file reaches the 700-line advisory tier (434, 327, 304, 167, and the smaller files), so no `Warning` row applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `test_stage_timing_checkpoint_key.py` covers plain mode, completion and PR modes, a control that removes a required key, and three portable-handoff properties: the archived source bytes keep the key and stay hash bound, an archive without the key fails the source hash, and the destination projection omits the key. These are the behaviors the second `[B]` criterion names.

#### Typing and API notes

- No production Python changed. Test helpers are annotated and the docstrings carry Args and Returns.

#### Error handling and logging

- No change.

### PowerShell implementation audit

#### What changed well

- One module function does I/O, and it uses `-LiteralPath` and returns names relative to the root with forward slashes, in ordinal order, so output is deterministic.
- Per issue only the file with the greatest leaf name counts, which matches the skill's statement that a re-written file carries a newer stamp and the report prefers it.
- A one-element list is kept as a list; a comment explains why statements, not an if-expression, assign it.
- Stage order comes from the earliest `started_at` across issues, with an ordinal tie-break, so the report does not depend on file order.

#### API and safety notes

- All functions use `CmdletBinding` and `OutputType`; three of nine are exported. Nothing writes, so ShouldProcess does not apply. PSScriptAnalyzer reports 0 findings on six files and the formatter reports no difference.
- Probe results: the entry script on the fixtures prints both labels, S4 median 0:13:20 and S5 median 0:20:00; on the default root it prints the labels and the no-data line; on an absent root it throws `Stage timing evidence root not found`. Minute-precision times parse; a zone-less time is read as UTC.

#### Error handling and logging

- The only throw is the absent root. Other defects become skip lines, never silent drops, except the repeated attempt number (Nit).

### TypeScript implementation audit

#### What changed well

- The test reads the committed back-compat checkpoint read-only, adds the key in memory, and compares error lists with and without it for three shapes in plain and `requireComplete` modes. The control removes `last_updated` and expects the exact error text, so a validator that returned early would fail.

#### Typing and API notes

- No `any`, no assertion, no suppression. `unknown` is narrowed before use.

#### Error handling and logging

- The fixture loader throws a specific error if the base checkpoint is not an object.

---

## Test Quality Audit

34 Pester cases pass within the recorded gate of 14582 tests. New-module line coverage is 99.42% (172 of 173). The reviewer did not re-run suites, under the owner's rule of one parallel run per gate. Test discrimination was checked by reading the fixtures and by direct-call probes that reproduce them; no source file was edited and no mutant run was made, so mutation sensitivity of the Pester cases is UNVERIFIED beyond the coverage figures and the probes above.

### Reviewed test and QA artifacts

- `artifacts/pester/pester-junit.xml` — 14582 tests, 0 failures, 0 errors, 10 disabled.
- `artifacts/pester/powershell-coverage.xml` — root LINE 23615 of 25135; `StageTiming.psm1` 165 of 166; `Get-StageTimingReport.ps1` 7 of 7.
- `artifacts/python/lcov.info` — LH 32270 of LF 33367, BRH 11722 of BRF 12516, equal to `stage-b-python-test.2026-11-07T05-52.md`.
- `evidence/qa-gates/stage-b-typescript-test.2026-11-07T05-48.md` — a subset run with coverage off.
- `evidence/qa-gates/self-review.2026-11-07T05-53.md` — reports no FAIL row; it does not mention the absent TypeScript artifact.

### Quality assessment prompts

- **Determinism:** the module reads no clock; tests use fixed time strings.
- **Isolation:** in-memory inputs; the script test reads committed fixtures.
- **Speed:** the Pester gate took 318.02 seconds across 8 shards.
- **Diagnostics:** the TypeScript and Python assertions carry the shape name with the error list.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected. |
| No unsafe subprocess or command construction | N/A | No process is started. |
| Input validation at boundaries | ✅ PASS | JSON parse failures, wrong shapes, and bad times become skip lines. |
| Error handling remains explicit | ✅ PASS | One `throw`; the JSON catch returns a reason. |
| Configuration / path handling is safe | ✅ PASS | `-LiteralPath`; the module writes nothing. |

---

## Research Log

No external research was required.

---

## Verdict

**Not ready.** One Blocker (F1): the TypeScript change has no coverage artifact and no full Jest run. The four Minor and three Nit findings do not block and fit the first stage that touches these files.
