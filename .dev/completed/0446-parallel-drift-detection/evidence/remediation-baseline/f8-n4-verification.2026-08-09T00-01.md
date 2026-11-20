# F8-N4 Verification — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P4-T7]
Finding remediated: **F8-N4** — `computed_at > at` was compared ordinally with no canonical-format
contract, a fail-open path in the epic's runtime backstop for its dominant failure mode.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`

EXIT_CODE: 1

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 1

Supplementary Command (authoritative per-file PowerShell coverage against the repository's declared
48-file denominator; the MCP invocation resolves its runsettings from the installed extension bundle
and measures a smaller denominator — see the [P0-T8] artifact's
`## Coverage-Denominator Divergence` section):
`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

Supplementary EXIT_CODE: 1 (same single pre-existing failure)

## Output Summary

### The extended seam table passes in both runtimes

`tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` passes with **24 of 24**
tests green, including the primary cross-runtime seam test that evaluates the PowerShell derivation
and the Python `unresolved_drift_item_keys` derivation over the **same 21-row** table. The table held
17 rows before this phase; [P4-T6] added exactly four. Both runtimes are evaluated over every row,
the fail-closed subset assertion ("PowerShell must never allow an item key Python reports as
unresolved") holds on all 21 rows, and exact key agreement holds on all 20 non-widened rows.

Each of the four added rows has the expected verdict **unresolved**, asserted directly by the new
`It` block `reports unresolved on every non-conforming-timestamp row of the shared table` as well as
indirectly through Python agreement, so a regression that made both runtimes fail open together
would still fail:

| Added row | Non-conforming side | Verdict in both runtimes |
| --- | --- | --- |
| colon-bearing `computed_at` against a hyphen-bearing `at` | `computed_at = 2026-01-02T00:00` | unresolved |
| colon-bearing `at` against a hyphen-bearing `computed_at` | `at = 2026-01-02T00:00` | unresolved |
| truncated `computed_at` | `computed_at = 2026-01-03T00` | unresolved |
| non-string `computed_at` | `computed_at = 20260103` (JSON number) | unresolved |

### Non-vacuity of the added rows

Three of the four rows discriminate the pre-fix behaviour from the post-fix behaviour: they were
**resolved** under the ungated ordinal comparison and are **unresolved** now. Verified by evaluating
a local reproduction of the pre-fix disjunct-(b) predicate against the post-fix helper over the same
four inputs:

| Added row | Pre-fix resolved | Post-fix resolved | Discriminating |
| --- | --- | --- | --- |
| colon-bearing `computed_at` | `True` | `False` | yes |
| colon-bearing `at` | `True` | `False` | yes |
| truncated `computed_at` | `True` | `False` | yes |
| non-string `computed_at` | `False` | `False` | no — already rejected by the pre-existing non-empty-string guard |

The fourth row is recorded as non-discriminating rather than claimed as a caught regression. It
documents the shape requirement for a non-string value, which the pre-existing guard already
rejected.

### PowerShell failed count is unchanged from [P0-T8]

- Pester counts this run: **2091 tests, 2081 passed, 1 failed, 9 skipped**.
- [P0-T8] counts: **2090 tests, 2080 passed, 1 failed, 9 skipped**.
- Failed count: **1 at [P0-T8], 1 now — unchanged.** Delta 0.
- The single failure is the same named pre-existing case,
  `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ::
  `allowed commands / allows gh pr create --body-file artifacts/pr_body_12.md when context exists`.
  It is the only `[-]` line in the run output. That suite reads the real gitignored
  `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam and fails whenever an
  orchestrated run is live. This cycle may not edit it.
- The passed count rose by 1 (2080 to 2081) because [P4-T6] added one `It` block. No previously
  passing test failed.
- Report-level coverage: LINE **94.97% (3722/3919)**, INSTRUCTION **94.61% (5092/5382)** over 48
  files. No `BRANCH` counter is emitted; the counter types present are exactly `CLASS`,
  `INSTRUCTION`, `LINE`, `METHOD`. No branch figure is invented.

### `_parallel_drift_shape.py` remains at 100% line and branch

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/_parallel_drift_shape.py` | **100.00% (51/51)** | **100.00% (26/26)** |

The module's measured surface grew with [P4-T1]'s addition — statements from 40 to 51 and branches
from 20 to 26 — and every added statement and arc is covered, so the figure is 100% on a larger
denominator rather than 100% on an unchanged one.

Every other feature module is unchanged at 100% line and branch, and
`validate_parallel_orchestrator_state.py` holds its cycle-entry figure:

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | 100.00% (94/94) | 100.00% (32/32) |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 100.00% (74/74) | 100.00% (10/10) |
| `scripts/dev_tools/parallel_drift_halt.py` | 100.00% (42/42) | 100.00% (6/6) |
| `scripts/dev_tools/parallel_drift_resolution.py` | 100.00% (15/15) | 100.00% (0/0) |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | 100.00% (41/41) | 100.00% (18/18) |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | 100.00% (44/44) | 100.00% (14/14) |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 97.62% (82/84) | 94.12% (32/34) |

Per-file LINE coverage of the two drift-gate PowerShell files, from the 48-file report:

| File | LINE | INSTRUCTION |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 94.25% (82/87) | 93.69% (104/111) |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | 100.00% (65/65) | 100.00% (104/104) |

Union of the two files: **147/152 = 96.71% LINE**, above the 96.53% single-file benchmark captured
before the Phase 1 split and above the 96.58% union measured at [P1-T11]. The helpers module's
measured surface grew from 59 to 65 lines with [P4-T3]'s addition; all six added lines are covered.

- Python repo-wide: **92.04% line (12795/13902)**, **84.14% branch (4296/5106)**. Cycle-entry floors
  were 92.02% line and 84.11% branch, so both rose.
- Python outcome: **3200 passed, 1 failed**. The [P3-T9] count was 3181 passed / 0 failed. The
  passed count rose by 19 with [P4-T4] and [P4-T5]'s new test file
  (`tests/scripts/dev_tools/test_parallel_drift_timestamps.py`, 20 collected cases, of which the
  parametrized matrix contributes the bulk).

### Anticipated intermediate Python failure — the bundled mirror is stale until [P7-T1]

The one Python failure is
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ::
test_bundled_claude_payload_contains_all_repo_runtime_contracts`.

It fails because [P4-T3] edited `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` and the
bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` has not
yet been refreshed. This is the plan's own anticipated intermediate state: the plan's
`## Wave-4 Concurrency Constraints` item 6 and [P7-T1]'s rationale both record that [P1-T7] mirrors
during Phase 1 while [P4-T3], [P5-T2], and [P5-T3] edit those files afterwards, which is exactly why
[P7-T1] exists and opens Phase 7. The mirror is re-established by [P7-T1] and the test is re-run
green by [P8-T4]. It is not a regression in feature behaviour and was not repaired out of plan order.

## How the Fix Closes the Fail-Open Path in Both Runtimes

The defect was a bare ordinal comparison of two strings whose shapes were never constrained.
Ordinally `-` is 0x2D and `:` is 0x3A, so a colon-bearing `computed_at` sorts **above** a
hyphen-bearing `at` that names the same instant — for example `2026-01-02T00:00` compares greater
than `2026-01-02T00-00`. Disjunct (b) therefore reported the drift resolved with no later diff, and
the Layer-2 gate released an item whose radius had not been re-recorded.

**Python.** `scripts/dev_tools/_parallel_drift_shape.py` now owns the constant
`CANONICAL_TIMESTAMP_RE = r"^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$"` and the pure predicate
`is_later_canonical_timestamp(candidate, reference)`, which returns `True` only when both values are
strings matching that pattern and the candidate is ordinally greater. `_is_drift_resolved` in
`scripts/dev_tools/parallel_drift_detection.py` now reads
`is_later_canonical_timestamp(radius.get("computed_at"), at)` in place of the `is_non_empty_string`
guard plus raw `>`. The module contains no raw `computed_at > at` comparison and no reference to
`is_non_empty_string` (the import was removed in the same task, so ruff reports zero diagnostics).

**PowerShell.** `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` now owns
`$script:CanonicalTimestampPattern = '^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$'` — character-identical to the
Python constant — and `Test-ParallelDriftGateCanonicalTimestamp`, which uses the case-sensitive
`-cmatch` so the literal `T` separator is required exactly as Python's case-sensitive `re.match`
requires it. `Test-ParallelDriftGateEventResolved` now gates the `CompareOrdinal` call on **both**
`$Radius.computed_at` and `$At` satisfying that pattern, and returns `$false` when either does not.

Both runtimes therefore treat a non-conforming timestamp on either side as **unresolved**, never as
resolved. The direction is deliberate: unresolved is the deny side, so a malformed timestamp holds
the gate closed instead of opening it.

## How the Seam Table Binds the Two Runtimes

The two implementations are not held together by two independent hardcoded expectation sets. They are
held together by one shared data table:

- `$script:ParityRows` in
  `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` is the single source of
  the 21 checkpoint states. Each row is a JSON literal.
- The primary `It` block pipes the concatenated JSON of **every** row into a Python harness that
  calls `unresolved_drift_item_keys` and returns one verdict per row, then evaluates the **same**
  rows through `Get-ParallelDriftGateUnresolvedState` and collects disagreements. Python's verdicts
  are computed at run time, not transcribed, so neither side carries a frozen expectation the other
  could drift away from.
- Two invariants are asserted per row: the fail-closed subset ("PowerShell must never allow an item
  key Python reports as unresolved") on all 21 rows, and exact key-set agreement on the 20 rows
  outside the one documented `Widened` narrowing.
- The four canonical-timestamp rows are `Widened = $false`, so they are held to exact agreement. A
  change to either runtime's pattern text, or to either runtime's treatment of a non-conforming
  value, breaks that agreement and fails this test.
- `tests/scripts/dev_tools/test_parallel_drift_timestamps.py` adds the second binding in the other
  direction: it asserts that the live output of `default_timestamp()` in
  `scripts/dev_tools/parallel_drift_detection_cli.py` matches `CANONICAL_TIMESTAMP_RE`, so the CLI's
  `TIMESTAMP_FORMAT` cannot diverge from the shape the predicate accepts. Without that test, changing
  `TIMESTAMP_FORMAT` would silently stop every resolution from clearing.

## Newly Discovered Observation — not remediated in this cycle

`ConvertFrom-Json` coerces a full ISO-8601 instant such as `2026-01-02T00:00:00Z` into a `[datetime]`
rather than leaving it a string. A checkpoint carrying such a value therefore reaches the PowerShell
helpers as a non-string, which `Test-ParallelDriftGateEventRecord` reports as a **malformed log**,
while Python's `json.load` keeps it a string and reports the item as **unresolved**. Both verdicts
deny, and PowerShell's is strictly the more conservative of the two, so the fail-closed subset
invariant the seam test asserts still holds. The divergence is in the `Malformed` flag only, in the
deny direction.

This was observed while constructing the [P4-T6] rows and is recorded here rather than repaired: this
cycle's `## Scope Contract` states that a finding discovered during execution opens a new remediation
cycle and does not extend this plan. The four added rows use the minute-precision colon-bearing form
`2026-01-02T00:00`, which both runtimes see as a string, so the rows pin the string comparison the
finding is about rather than the JSON coercion behaviour.
