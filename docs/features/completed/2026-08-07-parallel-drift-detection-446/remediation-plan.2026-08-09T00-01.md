# Remediation Plan — Cycle 1, F8 Radius Drift Detection (issue #446)

- Timestamp: 2026-08-09T00-01
- Epic: `parallel-orchestration`, wave 4, child F8
- Branch: `feature/parallel-drift-detection-446`
- Implementation commit under remediation: `bcf2de15`
- Base of the feature diff: `c939b5b8`
- Work mode: `full-feature`. Acceptance-criteria sources are the `## Acceptance Criteria` sections of
  `docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md` and
  `docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md`.
- Remediation inputs:
  `docs/features/active/2026-08-07-parallel-drift-detection-446/remediation-inputs.2026-08-09T00-01.md`
- Blocking count at cycle entry: 2 (F8-B1, F8-B2)
- Evidence root (non-overridable):
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/`. Cycle-entry baselines go
  to `evidence/remediation-baseline/`; the final QC pass goes to `evidence/qa-gates/`. No path under
  `artifacts/` is a valid evidence location.

## Scope Contract

This plan addresses exactly the findings listed below. A finding discovered during execution opens a
new remediation cycle; it does not extend this plan.

### Blocking, remediated by this cycle

| ID | Title | Phase |
| --- | --- | --- |
| F8-B1 | Derived resolution has no producer, so the Layer-2 drift gate has no release path | 2 |
| F8-B2 | Halt selection can select the drifting item | 3 |

### Non-blocking, in scope for this cycle

| ID | Title | Phase | Reason in scope |
| --- | --- | --- | --- |
| F8-N10 and reviewer item (e) | Hook and its Pester suite are each exactly 500 lines, zero headroom | 1 | The F8-N3 fix cannot land without a split |
| F8-N4 | `computed_at > at` compared ordinally with no canonical-format contract | 4 | Fail-open path in the epic's runtime backstop for its dominant failure mode (epic Open Risk 1) |
| F8-N3 | Any `remediation-inputs.*.md` opens the Layer-1 gate | 5 | Same fail-open rationale |
| F8-N1 | TypeScript Layer-2 drift-gate parity divergence has no durable repo-level record | 6 | Reviewer required a `docs/features/potential/` entry |
| F8-N2 | Layer-1 narrowing lacks a stated recovery action | 6 | One-sentence record |
| F8-N6 | `has_unresolved_drift(events, items)` widens the reconciled one-argument IC-6a contract | 6 | Cross-feature contract record for F6 |
| F8-N9 | US-4 disposition partly deflected | 6 | Follows from the F8-B2 fix |

### Explicitly out of scope — no task is planned for any of the following

- **F8-N5** — no run-time binding between the documented CLI surface in
  `.claude/skills/parallel-orchestrate/SKILL.md` `#### CLI Invocation` and `build_parser()`. Not
  planned in this cycle.
- **F8-N7** — no code appends the `mutations[]` entry or increments `recolor_generation`. Closes when
  F6 (issue #442) lands. Not planned.
- **F8-N8** — the cross-runtime seam test spawns `python` resolved from machine PATH without a
  recorded exception comment. Not planned.
- **Any TypeScript change**, including a parity port of the Layer-2 drift-gate dispatch into
  `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`.
- **Any edit to `.claude/rules/**`**, including `.claude/rules/parallel-orchestration.md`.
- **Any edit to `.github/instructions/**`.**
- **Any edit to `.claude/skills/orchestrate/SKILL.md`.**
- **Any edit to `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` or
  `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`.** Both read the real gitignored
  `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam and are recorded as
  pre-existing. Editing either to force a green PowerShell gate is prohibited.
- **F8-I1, F8-I2, F8-I3, F8-I4, F8-I5, F8-I6, F8-I7, F8-I8, F8-I9** — informational; recorded for the
  wave-4 integrator.

## Adjudicated Decisions — plan to these, do not re-litigate

1. **The drifting item must NEVER be halted.** Three independent statements in the authoritative
   requirement documents fix this: `spec.md` line 48 ("Halting the drifting item is not an option and
   must not be implemented or offered as a configuration"), `user-story.md` line 90 ("the drifting
   item is never the one halted"), and `user-story.md` lines 108-109 (Non-Goals: "Halting or
   unwinding the drifting item"). The exclusion takes precedence over the bare "halt the
   later-started item" phrasing of design section 7 step 5 wherever the two would conflict. It is
   independently necessary: the drifting item is mid-remediation on its own R1-R5 loop for the drift
   finding, so halting it would deadlock the very remediation that resolves the drift.
2. **`select_halted_item` keeps its `(a, b)` signature and its three tie-breaks unchanged.** The spec
   fixes that signature with no drifting-item parameter. The exclusion belongs at the call site,
   where the drifting key is already known.
3. **No schema field is added and no enum is extended.** `blast_radius` already carries `paths`,
   `modules`, `shared_surfaces`, `contracts`, `source`, and `computed_at` per invariant 9, and
   `source: observed` is an existing enum member. `.claude/rules/parallel-orchestration.md`
   `## Enum Ownership` binds F8 to consume, never extend.
4. **The resolution seam requests; it does not write.** It is shaped like the existing
   `request_requeue_via_recolor` seam and returns the `items[].blast_radius` update the
   `parallel-orchestrator` applies.

## Wave-4 Concurrency Constraints — binding on every shared-file task

F6 (issue #442) and F7 (issue #440) are executing concurrently against the same integration branch.

1. **`.claude/skills/parallel-orchestrate/SKILL.md`** — every edit is confined to the region under
   `## Radius Drift Detection (F8)` (heading at line 443). `## Mutation Protocol (F6)` and
   `## Enforcement Hooks (F7)` must remain byte-identical and in their original relative order
   (`## Mutation Protocol (F6)`, then `## Enforcement Hooks (F7)`, then
   `## Radius Drift Detection (F8)`, closing the file). No new `##` heading may be added; the file
   must still contain exactly sixteen `##` headings so
   `test_orchestrate_skill_first_thirteen_headings_match_required_layout` and
   `test_orchestrate_skill_reserved_wave_four_sections_close_the_file` continue to pass. Use `###`
   and `####` sub-headings only.
2. **`.claude/settings.json`** — append-only if touched at all. This cycle requires no change to it:
   the extracted PowerShell sibling module is dot-sourced by the registered hook, not registered as
   a hook of its own.
3. **`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`** — append-only. Exactly one
   `CodeCoverage.Path` entry is appended, with a citing comment, at the end of the existing list. No
   existing entry is reordered, reflowed, or removed. The bundled copy at
   `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` is updated
   to stay byte-identical.
4. **`scripts/dev_tools/validate_parallel_orchestrator_state.py`** — nothing may be added inside the
   comment-delimited `BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` /
   `END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` block, and its comment lines must not
   be touched. This cycle requires no change to this file; its diff against `c939b5b8` must remain
   exactly the two lines added by `bcf2de15`.
5. **F5-owned test artifacts** — `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
   and `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` must not be modified
   by this cycle. Both files were modified by `bcf2de15`, so they appear in
   `git diff --name-only c939b5b8..HEAD` by construction; the auditable range for this constraint is
   therefore `bcf2de15..HEAD`, as P7-T6 states.
6. Phase 7 is the confinement-verification phase and runs after every content change. It opens with
   P7-T1, which re-mirrors every `.claude/**` file this cycle modified after its last content change,
   because Phase 1's mirror task predates the Phase 4 and Phase 5 hook edits and SKILL.md is never
   mirrored by an earlier task.

## Non-Regression Benchmarks — remediation must not fall below these

Captured at commit `bcf2de15` and independently recomputed during review. Phase 0 re-captures them as
the cycle-entry baseline; Phase 8 compares against them.

| Surface | Metric | Benchmark |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | line / branch | 100.00% (94/94) / 100.00% (32/32) |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | line / branch | 100.00% (66/66) / 100.00% (6/6) |
| `scripts/dev_tools/parallel_drift_halt.py` | line / branch | 100.00% (42/42) / 100.00% (6/6) |
| `scripts/dev_tools/_parallel_drift_shape.py` | line / branch | 100.00% (40/40) / 100.00% (20/20) |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | line / branch | 100.00% (41/41) / 100.00% (18/18) |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | line / branch | 100.00% (44/44) / 100.00% (14/14) |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | line / branch | 97.62% (82/84) / 94.12% (32/34) |
| Python repo-wide | line / branch | 92.02% / 84.11% |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | line | 96.53% (139 covered, 5 missed) |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | instruction | 96.57% (197 covered, 7 missed) |
| Python suite | absolute test outcome | 3176 passed |
| PowerShell suite | absolute test outcome | 2080 passed / 1 failed / 9 skipped |

The two absolute suite-outcome rows are the floor, not a relative reference. If the Phase 0
re-capture does not reproduce these absolute counts, the discrepancy is recorded explicitly in the
P0-T9 artifact and the figures stated in this table remain the floor against which Phase 8 compares,
so a degraded re-capture cannot silently reset the floor.

All six new Python modules are at 100% line and 100% branch coverage, and the Layer-1 hook is at
96.53% line coverage. Remediation must not regress any of these figures. Every new module this cycle
creates must be under 500 lines and must meet line coverage >= 85% and branch coverage >= 75%; the
new Python modules are additionally expected to reach 100% line and branch coverage, consistent with
the surrounding six. PowerShell branch coverage is not emitted by Pester v5 or the PoshQC conversion
step (verified at the original baseline, recorded as F8-I2); INSTRUCTION coverage is the recorded
analogue and no branch figure may be invented.

## File-Size Facts at Cycle Entry

| File | Lines | Headroom |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 500 | 0 |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | 500 | 0 |
| `scripts/dev_tools/parallel_drift_detection.py` | 494 | 6 |
| `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` | 487 | 13 |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 412 | 88 |
| `tests/scripts/dev_tools/test_parallel_drift_detection.py` | 454 | 46 |
| `scripts/dev_tools/parallel_drift_halt.py` | 283 | 217 |
| `scripts/dev_tools/_parallel_drift_shape.py` | 241 | 259 |
| `tests/scripts/dev_tools/parallel_drift_test_support.py` | 119 | 381 |

Phase 1 exists because four of these files have too little headroom to absorb the changes Phases 2
through 5 require. The split is sequenced first, before any behavioural fix, so that no later task
has to choose between exceeding the 500-line cap and landing incompletely.

## Pre-Existing PowerShell Failure — recorded by name so the delta is auditable

`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ::
`allowed commands / allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
fails at `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142` with expected `'allow'`
and observed `'deny'`. Root cause: the suite exercises `.claude/hooks/enforce-pr-author-skill.ps1`,
which reads the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked
seam, so it fails whenever an orchestrated run is live. It failed identically in the original Phase 0
baseline (`evidence/baseline/powershell-test-baseline.2026-08-08T20-59.md`) and in the
post-implementation final QC (`evidence/qa-gates/powershell-test-final.2026-08-08T23-24.md`).

`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` shares the same unmocked
real-checkpoint dependency and is equally environment-dependent; it passed all six of its tests at
the original baseline. It is recorded here as a known-fragile, out-of-scope suite so that a failure
from it in this cycle is attributed correctly rather than read as a regression.

Neither file may be edited by this cycle.

---

### Phase 0 — Remediation-Entry Baseline Capture

- [x] [P0-T1] Read the policy files in this exact order — `CLAUDE.md`,
      `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
      `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`,
      `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/powershell.md`,
      `.claude/rules/parallel-orchestration.md`, `.claude/rules/quality-tiers.md`,
      `.claude/rules/tonality.md` — and write
      `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/remediation-baseline/phase0-instructions-read.2026-08-09T00-01.md`.
      Acceptance: the artifact exists and carries `Timestamp:`, `Policy Order:`, and an explicit
      list naming all ten files read, in the order above.
- [x] [P0-T2] Run `poetry run black --check .` from the repo root and write
      `evidence/remediation-baseline/python-format-baseline.2026-08-09T00-01.md`. Acceptance: the
      artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the
      unchanged-file count.
- [x] [P0-T3] Run `poetry run ruff check .` from the repo root and write
      `evidence/remediation-baseline/python-lint-baseline.2026-08-09T00-01.md`. Acceptance: the
      artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the
      diagnostic count.
- [x] [P0-T4] Run `poetry run pyright` from the repo root and write
      `evidence/remediation-baseline/python-typecheck-baseline.2026-08-09T00-01.md`. Acceptance: the
      artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the
      error/warning counts.
- [x] [P0-T5] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` from the repo
      root and write `evidence/remediation-baseline/python-test-baseline.2026-08-09T00-01.md`.
      Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an
      `Output Summary:` recording the passed/failed counts plus numeric repo-wide line and branch
      coverage and a per-file line/branch row for each of the six new drift modules and for
      `scripts/dev_tools/validate_parallel_orchestrator_state.py`.
- [x] [P0-T6] Run `mcp__drm-copilot__run_poshqc_format` against the worktree root and write
      `evidence/remediation-baseline/powershell-format-baseline.2026-08-09T00-01.md`. Acceptance:
      the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming any
      file the formatter would rewrite.
- [x] [P0-T7] Run `mcp__drm-copilot__run_poshqc_analyze` against the worktree root and write
      `evidence/remediation-baseline/powershell-analyze-baseline.2026-08-09T00-01.md`. Acceptance:
      the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the
      PSScriptAnalyzer diagnostic count by severity.
- [x] [P0-T8] Run `mcp__drm-copilot__run_poshqc_test` against the worktree root and write
      `evidence/remediation-baseline/powershell-test-baseline.2026-08-09T00-01.md`. Acceptance: the
      artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording
      the passed/failed/skipped counts, numeric report-level LINE and INSTRUCTION coverage, the
      per-file LINE coverage of `.claude/hooks/enforce-parallel-drift-gate.ps1`, an explicit
      statement that no `BRANCH` counter is emitted, and every observed failure named by file and
      test name with an explicit comparison against the two named pre-existing suites
      (`enforce-pr-author-skill.Tests.ps1` and `codex-pretooluse-integration.Tests.ps1`).
- [x] [P0-T9] Write `evidence/remediation-baseline/coverage-floor.2026-08-09T00-01.md` consolidating
      the cycle-entry coverage floors from the numbers captured in P0-T5 and P0-T8. Acceptance: the
      artifact carries `Timestamp:` and a table with one row per benchmark listed in this plan's
      `## Non-Regression Benchmarks` section, each row recording the value observed in this cycle's
      baseline run beside the stated benchmark, and a `Verdict:` line stating whether the observed
      values match the benchmarks. Acceptance additionally requires that, for any row whose observed
      value differs from the stated benchmark — including the two absolute suite-outcome rows
      (Python 3176 passed; PowerShell 2080 passed / 1 failed / 9 skipped) — the artifact carries a
      `Discrepancy:` line naming the difference and restating that the benchmark figure in this plan,
      not the re-captured value, remains the floor for Phase 8.
- [x] [P0-T10] Write `evidence/remediation-baseline/file-size-headroom.2026-08-09T00-01.md`
      recording the current line count of every file listed in this plan's
      `## File-Size Facts at Cycle Entry` table, measured on disk. Acceptance: the artifact carries
      `Timestamp:`, `Command:` (the line-count command used), `EXIT_CODE:`, `Output Summary:`, and
      one row per file with its measured line count and remaining headroom against the 500-line cap.
- [x] [P0-T11] Write `evidence/remediation-baseline/shared-file-reference.2026-08-09T00-01.md`
      recording the pre-remediation reference state of every shared file this cycle may touch:
      SHA-256 of `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/settings.json`,
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`,
      `scripts/dev_tools/validate_parallel_orchestrator_state.py`, and the four bundled mirrors under
      `extensions/drm-copilot/resources/`; the verbatim text of the `## Mutation Protocol (F6)` and
      `## Enforcement Hooks (F7)` sections; and the verbatim text of the F7 extension seam block.
      Acceptance: the artifact carries `Timestamp:`, `Command:` (the hashing command used),
      `EXIT_CODE:`, `Output Summary:`, and every listed hash and verbatim block, so Phase 7 can
      verify confinement against a recorded reference rather than against memory.

### Phase 1 — File-Size Headroom Split, Sequenced Before Every Behavioural Fix

This phase is a pure move plus wiring. No behaviour changes, no assertion is weakened, and no test is
deleted. It runs first because the Layer-1 hook and its Pester suite are each exactly 500 lines and
the Python CLI test suite has 13 lines of headroom, so the F8-N3, F8-N4, and F8-B2 fixes cannot land
without it.

- [x] [P1-T1] Create `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` and move into it,
      verbatim and in their existing order, the seven shape-and-derivation helpers currently at
      `.claude/hooks/enforce-parallel-drift-gate.ps1` lines 145-348 —
      `Test-ParallelDriftGateItemKey`, `Test-ParallelDriftGateText`,
      `Test-ParallelDriftGateEventRecord`, `Get-ParallelDriftGateLatestEventMap`,
      `Get-ParallelDriftGateItemRadiusMap`, `Test-ParallelDriftGateEventResolved`, and
      `Get-ParallelDriftGateUnresolvedState` — together with the `$script:ObservedRadiusSource`
      constant they alone read, following the structure of the existing sibling-module precedent
      `.claude/hooks/enforce-completion-helpers.ps1`. Acceptance: the new file exists, is under 500
      lines, defines exactly those seven functions and that one constant, carries a module-level
      comment-based help block naming the parent hook, is independently dot-sourceable, and each
      moved function body is byte-identical to its pre-move body.
- [x] [P1-T2] Reduce `.claude/hooks/enforce-parallel-drift-gate.ps1` to dot-source the new helpers
      module, following the precedent at `.claude/hooks/enforce-completion-consistency.ps1` lines
      44-47 (`$script:<Name>HelpersPath = Join-Path $PSScriptRoot '<file>'` then
      `. $script:<Name>HelpersPath`), placed immediately after the `param()` block and before the
      first remaining function definition, and update the `.NOTES` block to name the sibling module.
      Additionally update the `.DESCRIPTION` sentence that begins at
      `.claude/hooks/enforce-parallel-drift-gate.ps1` line 37 ("The cross-runtime seam test in ...")
      and carries the path literal on line 38, so it points at
      `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` — the file P1-T3
      moves that test into — rather than at the pre-split suite. Acceptance: the hook is under 500
      lines with at least 100 lines of headroom, contains none of the seven moved function
      definitions, contains the two dot-source lines, the `.NOTES` block names the sibling module, the
      `.DESCRIPTION` sentence names the post-split seam-test file and no longer names
      `enforce-parallel-drift-gate.Tests.ps1` as the seam test's home, and its remaining
      decision-path functions and entrypoint block are otherwise byte-identical to their pre-split
      form.
- [x] [P1-T3] Create `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` and
      move into it, verbatim, every test in
      `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` whose subject is one of the
      seven moved helpers, including the whole cross-runtime `Context` currently at lines 210-313 and
      its shared `$script:ParityRows` row table. That `Context` contains TWO `It` blocks, and both
      consume `$script:ParityRows`, so both move with the table: the primary cross-runtime seam test
      and `records the narrowing as strictly conservative on the widened-radius row` at lines 304-312.
      Moving the table without the second `It` orphans it. Acceptance: the new suite exists, is under
      500 lines with at least 100 lines of headroom, dot-sources only
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1`, contains both `It` blocks of the moved
      `Context` together with the `$script:ParityRows` table they share, and the sum of `It` blocks
      across the two suites equals the pre-split count in the single suite.
- [x] [P1-T4] Reduce `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` to the
      decision-path tests only, keeping the registered-hook-path assertion and every
      allow/deny-decision test. Acceptance: the file is under 500 lines with at least 100 lines of
      headroom, contains no test whose subject is one of the seven moved helpers, and no `It` block
      was deleted rather than moved.
- [x] [P1-T5] Append exactly one `CodeCoverage.Path` entry for
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` to the end of the existing list in
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, preceded by a two-line comment
      citing issue #446 remediation cycle 1 and the Coverage Exclusion Policy. Acceptance: the diff
      against `bcf2de15` shows only appended lines inside `CodeCoverage.Path`, no existing entry
      moved or reflowed, and the file still parses as a PowerShell data file.
- [x] [P1-T6] Update the bundled copy
      `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` so it is
      byte-identical to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Acceptance:
      SHA-256 of the two files is equal and
      `test_poshqc_bundled_module_files_match_repo_root_sources` passes.
- [x] [P1-T7] Mirror `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` and the reduced
      `.claude/hooks/enforce-parallel-drift-gate.ps1` into
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. Acceptance: SHA-256 of
      each source and its mirror is equal, and
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
- [x] [P1-T8] Add the path
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` to
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` beside the
      existing `enforce-parallel-drift-gate.ps1` entry. Acceptance: exactly one line is added, the
      file is valid JSON, and `test_bundled_claude_files_are_listed_in_some_pack_manifest` passes.
- [x] [P1-T9] Extract the halt-selection call-site tests from
      `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` (487 lines) into a new file
      `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py`, moving verbatim the tests
      whose subject is `_start_markers` or `_halted_item_keys`, including
      `test_evaluate_drift_halts_the_later_started_item_of_a_new_conflict` (currently at lines
      283-299) and `test_evaluate_drift_selects_one_halted_item_per_newly_conflicting_pair`
      (currently at lines 302-318). Removing lines 283-320 is 38 lines, which leaves 449 lines and
      only 51 lines of headroom, so the move alone is insufficient. The moved tests also depend on
      three fixtures the remaining tests still use — `_in_flight` (lines 111-129), `_checkpoint`
      (lines 130-145), and `_evaluate` (lines 168-190) — so additionally relocate those three fixtures
      into the existing `tests/scripts/dev_tools/parallel_drift_test_support.py` (currently 119 lines)
      and import them from both test files, which leaves roughly 369 lines in the reduced file.
      Acceptance: all three files —
      `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py`,
      `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py`, and
      `tests/scripts/dev_tools/parallel_drift_test_support.py` — are under 500 lines with at least 60
      lines of headroom each; no fixture is duplicated across the two test files (each of
      `_in_flight`, `_checkpoint`, and `_evaluate` is defined exactly once, in
      `parallel_drift_test_support.py`, and imported by both test files); the union of `def test_`
      names across the two test files equals the pre-split set; and
      `poetry run pytest tests/scripts/dev_tools/test_parallel_drift_detection_cli.py
      tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py` passes.
- [x] [P1-T10] Update the stale seam-test reference in
      `.claude/skills/parallel-orchestrate/SKILL.md` at line 682 — the sentence naming
      `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` as the home of the
      cross-runtime seam test — so it names
      `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1`, the file P1-T3 moves
      that test into. The edit is a single file-path substitution inside the region under
      `## Radius Drift Detection (F8)` and changes no other prose. Acceptance: a search of
      `.claude/skills/parallel-orchestrate/SKILL.md` for the literal
      `enforce-parallel-drift-gate.Tests.ps1` returns zero matches (it returns exactly one, at line
      682, before this task), the same search for
      `enforce-parallel-drift-gate-helpers.Tests.ps1` returns at least one match, the edited line
      remains inside `## Radius Drift Detection (F8)`, and the file still contains exactly sixteen
      `##` headings.
- [x] [P1-T11] Run `mcp__drm-copilot__run_poshqc_test` and
      `poetry run pytest --cov --cov-branch --cov-report=term-missing`, then write
      `evidence/remediation-baseline/split-parity.2026-08-09T00-01.md`. Acceptance: the artifact
      carries `Timestamp:`, `Command:` for both runs, `EXIT_CODE:` for both, and an `Output Summary:`
      showing the Python passed count is greater than or equal to the P0-T5 count with zero new
      failures, the PowerShell failed count is unchanged from P0-T8, per-file LINE coverage for both
      `.claude/hooks/enforce-parallel-drift-gate.ps1` and
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` each at or above 85%, and the six new
      Python modules still at 100% line and branch.

### Phase 2 — F8-B1: Observed-Radius Emission and the Resolution-Write Intent Seam

The Layer-2 gate is correctly strict and has no release. Both resolution disjuncts require an
affirmative write to `items[].blast_radius`; nothing writes it, the CLI discards the observed radius
it already builds at `scripts/dev_tools/parallel_drift_detection.py` lines 318-322, and no document
names an actor. This phase supplies the producer, the emitted value, and the documented actor and
trigger. It adds no schema field and no enum member.

- [x] [P2-T1] Create `scripts/dev_tools/parallel_drift_resolution.py` as a pure peer module of
      `parallel_drift_detection` holding `build_observed_radius(observed_paths, config, *,
      computed_at) -> BlastRadius`, which is exactly the existing library call
      `radius_from_observed_paths` guarded by `require_paths` and `require_text`, and relocate into
      this module's docstring the IC-1b prohibition on hand-constructing a `BlastRadius` (hand
      construction drops the module and shared-surface disjuncts). Acceptance: the module is under
      500 lines, imports no `datetime`, `os`, `pathlib`, `subprocess`, or `random`, calls
      `radius_from_observed_paths` and constructs no `BlastRadius` directly, and
      `poetry run pyright` reports zero errors for it.
- [x] [P2-T2] Add to `scripts/dev_tools/parallel_drift_resolution.py` a frozen dataclass
      `ResolutionWriteRequest` carrying `item_key: int` and `blast_radius: Mapping[str, object]`, and
      the single seam `request_resolution_write(*, item_key, observed_paths, config, computed_at) ->
      ResolutionWriteRequest`, which builds the radius through `build_observed_radius`, serializes it
      with `BlastRadius.to_dict()`, and returns the requested `items[].blast_radius` update for the
      `parallel-orchestrator` to apply. The seam requests and never writes, mirroring
      `request_requeue_via_recolor` in `scripts/dev_tools/parallel_drift_halt.py`. Acceptance: the
      returned `blast_radius` mapping carries exactly the six invariant-9 keys `paths`, `modules`,
      `shared_surfaces`, `contracts`, `source`, `computed_at`, with `source == "observed"`; the
      seam performs no filesystem, clock, or subprocess access; the dataclass is `frozen=True`; and
      no key outside those six is produced.
- [x] [P2-T3] Change `recompute_conflicts_with_observed` in
      `scripts/dev_tools/parallel_drift_detection.py` to obtain its in-memory observed radius from
      `build_observed_radius` instead of calling `radius_from_observed_paths` inline, dropping
      `radius_from_observed_paths` from that module's import list and shortening the now-relocated
      IC-1b rationale in its docstring. The file is 494 lines at cycle entry with only 6 lines of
      headroom and is edited again by P4-T2, so the reduction mechanism is stated rather than left
      implicit: the IC-1b prohibition paragraph that P2-T1 relocates into
      `scripts/dev_tools/parallel_drift_resolution.py`'s module docstring is DELETED from this
      module's docstring (not reworded in place) and replaced by a single cross-reference line naming
      the new module, and the `radius_from_observed_paths` import line is removed, for a net reduction
      of at least four lines. Acceptance: the module is under 500 lines and is at or below 490 lines
      after this task, so P4-T2 has headroom; the module contains no reference to
      `radius_from_observed_paths`; the relocated IC-1b paragraph appears in exactly one module
      docstring repo-wide; and
      `poetry run pytest tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py` passes
      with no test modified.
- [x] [P2-T4] Add an `observed_radius` key to the stdout payload built by `evaluate_drift` in
      `scripts/dev_tools/parallel_drift_detection_cli.py` (currently lines 283-292), populated from
      `request_resolution_write(...).blast_radius` when `escaped` is non-empty and `None` when the
      result is `no_escape`, and update the module docstring's `Stdout contract` block to document
      the new key beside the existing eight. Acceptance: the payload key set is exactly
      `result`, `item_key`, `at`, `computed_at`, `escaped_paths`, `newly_conflicting_pairs`,
      `halted_item_keys`, `drift_event`, `observed_radius`; `observed_radius` is `None` exactly when
      `result == "no_escape"`; and the module stays under 500 lines. Record the residual gap
      explicitly in the module docstring's `Stdout contract` block so a reaudit does not read it as a
      new finding: because `observed_radius` is `None` whenever `result == "no_escape"`, and
      `no_escape` is exactly the post-remediation state once remediation has narrowed the diff or
      widened the declared radius, the emitted-value path closes resolution only through the
      still-escaping invocation — the invocation made while the drift is still observable. That path
      is the realistic one and P2-T5 exercises it; an invocation made after the diff already stopped
      escaping emits no radius and cannot itself close the loop.
- [x] [P2-T5] Create `tests/scripts/dev_tools/test_parallel_drift_resolution.py` with a run-time
      seam test that closes the resolution loop: build a checkpoint whose item has an unresolved
      latest drift event, invoke `evaluate_drift` to obtain the emitted `observed_radius`, write that
      value verbatim into `items[].blast_radius`, and assert `unresolved_drift_item_keys` then
      returns an empty tuple for that item. The test passes only if `evaluate_drift` is invoked with
      `computed_at` strictly later than the event's `at`, because resolution disjunct (b) requires a
      strictly greater `computed_at`; the CLI defaults `computed_at` to `at`, so the test must pass an
      explicit later `computed_at` rather than rely on the default. Acceptance: the test asserts the
      item key is present in `unresolved_drift_item_keys` before the write and absent after it, passes
      an explicit `computed_at` strictly greater than the event's `at`, uses the CLI's emitted value
      rather than a hand-built radius, and passes.
- [x] [P2-T6] Add to `tests/scripts/dev_tools/test_parallel_drift_resolution.py` a second
      loop-closing test for the widening disjunct: extend the item's `blast_radius.paths` to cover
      every escaped path of the latest event and assert `unresolved_drift_item_keys` returns an empty
      tuple. Acceptance: the test asserts the same before-and-after transition through disjunct (a)
      and passes without touching `blast_radius.source`.
- [x] [P2-T7] Add to `tests/scripts/dev_tools/test_parallel_drift_resolution.py` a test asserting
      that `request_resolution_write` produces a radius equal to
      `radius_from_observed_paths(...).to_dict()` for the same inputs, so the seam cannot drift from
      the library. Acceptance: the test compares the seam's `blast_radius` against a direct library
      call and passes.
- [x] [P2-T8] Add the seventh step to the numbered list under
      `.claude/skills/parallel-orchestrate/SKILL.md` `#### Six-Step Procedure` and retitle that
      subsection to `#### Seven-Step Procedure`. Step 7 must name the actor
      (`parallel-orchestrator`), the trigger (the consuming remediation cycle exiting with
      `blocking_count == 0`), and the exact write: rebuild `items[].blast_radius` from the
      post-remediation diff through the library, with `source: observed` and a `computed_at` strictly
      later than the event's `at`, or extend `blast_radius.paths` to cover every escaped path; and it
      must state that no other write clears the derived unresolved state. Acceptance: the H4 reads
      `#### Seven-Step Procedure`, its numbered list has exactly seven items, item 7 names the actor,
      the trigger, and both writes, and a search of `.claude/` and `scripts/` for the literal
      `Six-Step Procedure` returns zero matches.
- [x] [P2-T9] Update `.claude/skills/parallel-orchestrate/SKILL.md` `#### Resolution Semantics` so
      the sentence "Both disjuncts are concrete, recordable parent actions that the existing R1
      through R5 remediation cycle already drives, so nothing deadlocks" cites step 7 as the producer
      instead of asserting the property without one, and document that the CLI emits `observed_radius`
      as the library-produced value the parent applies. Acceptance: the subsection names step 7 and
      the `observed_radius` payload key, and the claim of non-deadlock is stated as a consequence of
      the named producer.
- [x] [P2-T10] Update `.claude/skills/parallel-orchestrate/SKILL.md` `#### CLI Invocation` so the
      fenced JSON block lists `observed_radius` beside the existing eight keys and the surrounding
      prose describes it as the serialized observed `blast_radius` the parent writes back.
      Acceptance: the fenced JSON block in that subsection contains exactly the nine keys
      `evaluate_drift` returns, in the same spelling.
- [x] [P2-T11] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write
      `evidence/remediation-baseline/f8-b1-verification.2026-08-09T00-01.md`. Acceptance: the
      artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` showing
      `scripts/dev_tools/parallel_drift_resolution.py` at 100% line and branch coverage and the six
      pre-existing drift modules still at 100% line and branch coverage.

### Phase 3 — F8-B2: Exclude the Drifting Item from Halt Candidacy

`_halted_item_keys` at `scripts/dev_tools/parallel_drift_detection_cli.py` lines 374-408 forms pairs
as `(drifting, peer)` with no drifting-item exclusion, so the drifting item is halted whenever it is
the later starter — which `_start_rank`'s item-key tie-break makes true for roughly half of
same-minute cohort pairs. The fix is the exclusion at the call site; the comparator is unchanged.

- [x] [P3-T1] Add a `drifting_item_key` parameter to `_halted_item_keys` in
      `scripts/dev_tools/parallel_drift_detection_cli.py` and exclude that key from halt candidacy
      per pair: build the candidate list for each pair by dropping the drifting key, halt the single
      remaining candidate when one remains, and apply `select_halted_item` when two remain. Do not
      write a zero-candidate branch. Update the docstring to state the exclusion and its reason (the
      drifting item is mid-remediation on its own R1-R5 loop, so halting it would deadlock the
      remediation that resolves the drift). Acceptance: `_halted_item_keys` never returns
      `drifting_item_key` for any input; the call site in `evaluate_drift` passes `item_key`; the
      candidate count is provably 1 or 2 for every input because a canonical pair holds two distinct
      keys, so no zero-candidate branch is written and no branch arc is left unexercised (pairs are
      canonical distinct `(a, b)` per F3 invariant 15 and `select_halted_item` raises on duplicate
      keys, so dropping the drifting key always leaves exactly one or two candidates); and the module
      stays under 500 lines.
- [x] [P3-T2] Leave `select_halted_item` in `scripts/dev_tools/parallel_drift_halt.py` unchanged as a
      pure later-started comparator with its three tie-breaks, and add to its docstring one sentence
      stating that drifting-item exclusion is applied by the caller because the spec fixes this
      signature as `(a, b)` with no drifting-item parameter. Acceptance: the function body and
      signature are byte-identical to their `bcf2de15` form, only the docstring changed, and
      `poetry run pytest tests/scripts/dev_tools/test_parallel_drift_halt.py` passes with no test
      modified.
- [x] [P3-T3] Correct `test_evaluate_drift_halts_the_later_started_item_of_a_new_conflict` in
      `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py` so it asserts the peer is
      halted rather than the drifting item, keeping the same fixture in which the drifting item 446
      carries `worktree_created_at = "2026-08-08T09-00"` against peer 445 at `"2026-08-08T08-00"`.
      Acceptance: the test asserts `result["newly_conflicting_pairs"] == [[445, 446]]` and
      `result["halted_item_keys"] == [445]`, and passes.
- [x] [P3-T4] Correct `test_evaluate_drift_selects_one_halted_item_per_newly_conflicting_pair` in
      `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py` so the drifting item does
      not appear in `halted_item_keys`. Acceptance: the asserted `halted_item_keys` list contains one
      key per newly conflicting pair, excludes the drifting item key, and the test passes.
- [x] [P3-T5] Add a test to `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py`
      asserting the drifting item is never returned even when it is the later starter by both
      tie-breaks: one case where the drifting item carries the strictly later
      `worktree_created_at`, and one case where both timestamps are equal and the drifting item
      carries the larger `issue_num`. Acceptance: the test covers both cases and asserts the drifting
      item key is absent from `halted_item_keys` in each.
- [x] [P3-T6] Add a test to `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py`
      exercising the two-remaining-candidate branch of `_halted_item_keys` by passing a pair that
      does not contain the drifting key, so the comparator path stays covered. Acceptance: the test
      asserts the later-started member of that pair is returned, and branch coverage of
      `scripts/dev_tools/parallel_drift_detection_cli.py` remains 100%.
- [x] [P3-T7] Correct `test_recomputed_pair_feeds_halt_selection_and_yields_later_started_item` at
      `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py` lines 339-373 (line 374 is
      blank and is not part of the test) so the
      whole-path assertion routes halt selection through the exclusion-aware call site and asserts
      the peer 445 is halted rather than the drifting item 446. Acceptance: the test no longer
      asserts `halted == 446`, asserts the halted key is 445, feeds that key into
      `request_requeue_via_recolor`, and passes; the file stays under 500 lines.
- [x] [P3-T8] Replace the weakened wording in `.claude/skills/parallel-orchestrate/SKILL.md`
      `#### Halt the Later-Started Item` — "The drifting item is **never** halted by virtue of
      drifting" — with the requirement documents' absolute form: the drifting item is never the one
      halted, halting it is not an option, and it must not be implemented or offered as a
      configuration. State that the exclusion is applied at the call site before the later-started
      comparator runs, and retain the accurate observation that `select_halted_item` receives no
      drift information. Acceptance: the subsection contains no occurrence of the phrase
      "by virtue of drifting", states the prohibition unconditionally, and names the call-site
      exclusion.
- [x] [P3-T9] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write
      `evidence/remediation-baseline/f8-b2-verification.2026-08-09T00-01.md`. Acceptance: the
      artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating
      that no test asserts the drifting item is halted through `_halted_item_keys` or
      `evaluate_drift`; that the comparator-level assertion in
      `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls`
      (`tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py` lines 376-411, which
      asserts `results[0][2] == 446` by calling `select_halted_item` directly) is recorded as correct
      and unchanged, because `select_halted_item` receives no drift information and this plan tasks no
      change to it; and that `scripts/dev_tools/parallel_drift_detection_cli.py` and
      `scripts/dev_tools/parallel_drift_halt.py` remain at 100% line and branch coverage.

### Phase 4 — F8-N4: Canonical Timestamp Contract in Both Runtimes

`computed_at > at` is compared ordinally with no format contract. Ordinally `-` (0x2D) sorts below
`:` (0x3A), so a colon-bearing `computed_at` such as `2026-01-01T10:00:00Z` compares greater than a
hyphen-bearing `at` such as `2026-01-09T10-00` and resolves drift spuriously — a fail-open inversion.
The fix requires the canonical `yyyy-MM-ddTHH-mm` shape on both sides and treats a non-conforming
value as unresolved.

- [x] [P4-T1] Add to `scripts/dev_tools/_parallel_drift_shape.py` a module constant
      `CANONICAL_TIMESTAMP_RE` matching `^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$` and the pure predicate
      `is_later_canonical_timestamp(candidate: object, reference: object) -> bool`, which returns
      `True` only when both values are strings matching that pattern and `candidate` is ordinally
      greater than `reference`, and `False` otherwise. Acceptance: the module stays under 500 lines,
      the predicate returns `False` for a non-string, a blank string, and any value not matching the
      pattern on either side, and returns `True` only for a strictly greater conforming candidate.
- [x] [P4-T2] Change disjunct (b) in `_is_drift_resolved` at
      `scripts/dev_tools/parallel_drift_detection.py` lines 433-439 to use
      `is_later_canonical_timestamp(radius.get("computed_at"), at)` in place of the
      `is_non_empty_string` guard and the raw `>` comparison, and update the function and
      `unresolved_drift_item_keys` docstrings to state the canonical-format requirement and that a
      non-conforming value on either side is unresolved. This change leaves `is_non_empty_string`
      (imported at `scripts/dev_tools/parallel_drift_detection.py` line 54 and used only at line 437,
      the line this task rewrites) with no remaining use, which ruff reports as F401, so remove that
      name from the import statement in the same task rather than letting the final-QC loop restart on
      it. Acceptance: the module stays under 500 lines, contains no raw `computed_at > at` comparison,
      contains no reference to `is_non_empty_string` (neither import nor call), `poetry run ruff check
      scripts/dev_tools/parallel_drift_detection.py` reports zero diagnostics, and a checkpoint whose
      `computed_at` is `2026-01-01T10:00:00Z` against an event `at` of `2026-01-09T10-00` reports the
      item as unresolved.
- [x] [P4-T3] Add `Test-ParallelDriftGateCanonicalTimestamp` and the matching pattern constant to
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1`, and change
      `Test-ParallelDriftGateEventResolved` in that module to require both `$Radius.computed_at` and
      `$At` to satisfy the canonical pattern before the `CompareOrdinal` comparison runs. Acceptance:
      the module stays under 500 lines, the resolved verdict is `$false` whenever either value is
      non-conforming, and the pattern text is character-identical to `CANONICAL_TIMESTAMP_RE` in
      `scripts/dev_tools/_parallel_drift_shape.py`.
- [x] [P4-T4] Create `tests/scripts/dev_tools/test_parallel_drift_timestamps.py` covering
      `is_later_canonical_timestamp` over a parametrized matrix: strictly greater conforming pair,
      equal conforming pair, strictly lesser conforming pair, colon-bearing candidate against a
      conforming reference, colon-bearing reference against a conforming candidate, non-string on
      each side, and blank on each side. Acceptance: every case asserts the expected verdict, the
      colon-bearing cases assert `False`, and the file is under 500 lines.
- [x] [P4-T5] Add to `tests/scripts/dev_tools/test_parallel_drift_timestamps.py` a binding test
      asserting that the value produced by `default_timestamp()` in
      `scripts/dev_tools/parallel_drift_detection_cli.py` matches `CANONICAL_TIMESTAMP_RE`, so the
      CLI's `TIMESTAMP_FORMAT` and the resolution predicate cannot diverge. Acceptance: the test
      matches the live `default_timestamp()` output against the imported constant and passes.
- [x] [P4-T6] Extend the shared cross-runtime row table in
      `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` with rows covering a
      colon-bearing `computed_at` against a hyphen-bearing `at`, a colon-bearing `at` against a
      hyphen-bearing `computed_at`, a truncated `computed_at`, and a non-string `computed_at`.
      Acceptance: the table gains exactly those four rows, both runtimes are evaluated over every
      row, each new row's expected verdict is unresolved, and the existing subset assertion
      ("PowerShell must never allow an item key Python reports as unresolved") still holds on every
      row.
- [x] [P4-T7] Run `mcp__drm-copilot__run_poshqc_test` and
      `poetry run pytest --cov --cov-branch --cov-report=term-missing`, then write
      `evidence/remediation-baseline/f8-n4-verification.2026-08-09T00-01.md`. Acceptance: the
      artifact carries `Timestamp:`, `Command:` for both runs, `EXIT_CODE:` for both, and an
      `Output Summary:` stating that the extended seam table passes in both runtimes, that the
      PowerShell failed count is unchanged from P0-T8, and that
      `scripts/dev_tools/_parallel_drift_shape.py` remains at 100% line and branch coverage.

### Phase 5 — F8-N3: Fail-Closed Layer-1 Finding-Presence Narrowing

`Test-ParallelDriftFindingPresent` at `.claude/hooks/enforce-parallel-drift-gate.ps1` lines 102-111
returns `$true` for the first file whose name starts with `remediation-inputs.` and ends with `.md`,
so a finding written by an earlier unrelated remediation cycle opens the Layer-1 gate for drifted,
unsurfaced work. The narrowing stays presence-gating only: substring extraction plus ordinal
comparison, no path-glob matching, no diff computation, no git invocation, no content read. This
phase runs after Phase 1 because the hook had zero headroom at cycle entry.

- [x] [P5-T1] Extend the returned `OrderedDictionary` of `Get-ParallelDriftGateUnresolvedState` in
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` with a `LatestAt` member carrying the
      item-key-to-`at` map it already computes internally, so the decision path can read the current
      unresolved event's timestamp without a second derivation. Acceptance: the returned dictionary
      carries `Malformed`, `UnresolvedItemKeys`, and `LatestAt`; `LatestAt` is an empty map when
      `Malformed` is `$true`; and the existing `Malformed` and `UnresolvedItemKeys` values are
      unchanged for every row of the cross-runtime seam table.
- [x] [P5-T2] Add a mandatory `EventAt` parameter to `Test-ParallelDriftFindingPresent` in
      `.claude/hooks/enforce-parallel-drift-gate.ps1` and require the matched file name's embedded
      `yyyy-MM-ddTHH-mm` substring — extracted with `Substring` from the fixed offset after the
      `remediation-inputs.` prefix — to be ordinally greater than or equal to `EventAt` before the
      function reports `$true`. A name whose embedded substring is absent or non-conforming reports
      `$false`. Acceptance: the function performs no glob match, no git invocation, and no content
      read; it reports `$false` for a `remediation-inputs.<timestamp>.md` whose timestamp is
      ordinally less than `EventAt`; and it reports `$true` for one greater than or equal to it.
- [x] [P5-T3] Change the call site in `Invoke-ParallelDriftGateDecision` at
      `.claude/hooks/enforce-parallel-drift-gate.ps1` to pass the resolved item's latest drift-event
      `at`, read from the `LatestAt` member added in P5-T1, into
      `Test-ParallelDriftFindingPresent -EventAt`, and to deny fail-closed when no latest `at` is
      available for that item. Acceptance: the deny reason string still leads with
      `PARALLEL_DRIFT_GATE_BLOCKED:`, an item with an unresolved event and only a stale finding file
      is denied, and the hook stays under 500 lines.
- [x] [P5-T4] Add tests to
      `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` covering the narrowed
      presence check through the mocked finding-presence and checkpoint-read seams: a stale finding
      file whose embedded timestamp precedes the latest drift event's `at` denies; a finding file
      whose timestamp equals the event's `at` allows; a finding file whose timestamp follows the
      event's `at` allows; and a file name with a non-conforming embedded substring denies.
      Acceptance: all four cases are asserted through the existing seams with no temporary file
      created, and the suite stays under 500 lines.
- [x] [P5-T5] Add one paragraph to `.claude/skills/parallel-orchestrate/SKILL.md` under
      `#### Two-Layer Drift Gate` stating that the Layer-1 finding-presence check requires the
      matched `remediation-inputs.<yyyy-MM-ddTHH-mm>.md` file's embedded timestamp to be ordinally
      greater than or equal to the latest drift event's `at`, so a finding from an earlier
      remediation cycle does not open the gate, and that the check remains presence gating only.
      Acceptance: the subsection states the ordinal timestamp requirement, states that no glob match,
      git command, or content read is performed, and the edit stays inside
      `## Radius Drift Detection (F8)`.
- [x] [P5-T6] Run `mcp__drm-copilot__run_poshqc_test` and write
      `evidence/remediation-baseline/f8-n3-verification.2026-08-09T00-01.md`. Acceptance: the
      artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the
      four new narrowing cases as passing, the PowerShell failed count unchanged from P0-T8, and
      per-file LINE coverage of both `.claude/hooks/enforce-parallel-drift-gate.ps1` and
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` at or above 85%.

### Phase 6 — Records and Documentation Hygiene

- [x] [P6-T1] Create the durable repository-level record for the latent TypeScript parity divergence
      by writing the file directly from `docs/features/potential/template.md` to
      `docs/features/potential/2026-08-09-parallel-drift-gate-typescript-parity-divergence.md`,
      following the precedent `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`
      that `.claude/rules/parallel-orchestration.md` itself cites. The entry must record the missing
      Layer-2 drift-gate dispatch, the divergent error set (the Python validator emits
      `PARALLEL_DRIFT_GATE_VIOLATION:` where the TypeScript core emits nothing), the insertion point
      in `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` beside the
      existing key-gated `drift_events` dispatch and outside the F7 seam, and that the Python
      validator is authoritative in the interim. Acceptance: the file exists at that path, follows the
      section structure of `docs/features/potential/template.md`, and names all four items; no edit is
      made to `.claude/rules/parallel-orchestration.md` and no TypeScript file is changed.
- [x] [P6-T2] Add one sentence to `.claude/skills/parallel-orchestrate/SKILL.md`
      `#### Layer-1 Narrowing — a Documented Limitation` naming the operator's recovery action for a
      spurious Layer-1 deny: re-record the item's radius from the later observed diff, which
      satisfies both runtimes because it is disjunct (b), the one disjunct the hook evaluates.
      Acceptance: the subsection contains exactly one added sentence naming that recovery action, and
      the edit stays inside `## Radius Drift Detection (F8)`.
- [x] [P6-T3] Append an IC-6a amendment record to
      `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md`
      stating that the delivered export is `has_unresolved_drift(events, items) -> bool`, that the
      second argument is unavoidable because the resolution derivation reads each item's
      `blast_radius`, and that this widening follows directly from the IC-3a resolution-semantics
      deviation recorded in the same artifact, so F6's planner reads the delivered contract rather
      than the assumed one-argument form. Acceptance: the amendment is appended to the existing
      artifact with its own dated heading naming remediation cycle 1, no new reconciliation artifact
      is created, and the pre-existing IC-6a text is left in place rather than rewritten.
- [x] [P6-T4] Append a dated correction block to
      `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/qa-gates/acceptance-criteria-checkoff.2026-08-08T23-24.md`
      restating the US-4 disposition as a split: the "later-started item of the pair is halted"
      clause and the "the drifting item is never the one halted" clause are F8's own and are met once
      F8-B2 is fixed, while the "requeued into a future cohort" clause remains an F6 cross-feature
      dependency (IC-6b), so the criterion stays unchecked. Acceptance: the correction block names
      all three clauses and their distinct owners, states that the previous reason deflected the
      "never halted" clause to F6 in error, and states that the checkbox remains unchecked because
      the requeue clause is still unmet.
- [x] [P6-T5] Re-evaluate whether `user-story.md` line 88-90 can be checked and record the verdict in
      the P6-T4 correction block. Acceptance: the `## Acceptance Criteria` entry for US-4 in
      `docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md` remains `- [ ]`,
      that file is unmodified by this cycle, and the correction block states explicitly that the
      requeue-into-a-future-cohort clause depends on F6 and therefore leaves the checkbox unchecked.

### Phase 7 — Wave-4 Confinement and Mirror-Parity Verification

- [x] [P7-T1] Re-mirror every `.claude/**` file this cycle modified, after its last content change:
      copy `.claude/skills/parallel-orchestrate/SKILL.md`,
      `.claude/hooks/enforce-parallel-drift-gate.ps1`, and
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` to their counterparts under
      `extensions/drm-copilot/resources/claude-customizations/.claude/`. Rationale:
      `test_bundled_claude_payload_contains_all_repo_runtime_contracts` asserts byte-identical
      mirroring for every `.claude/**` file; P1-T7 mirrors the hooks during Phase 1, but P4-T3 edits
      the helpers module and P5-T2 and P5-T3 edit the hook afterwards, and no task ever mirrors
      SKILL.md although Phases 1, 2, 3, 5, and 6 all edit it. Acceptance: SHA-256 of each source equals
      its mirror, and `poetry run pytest
      tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
      tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` passes.
- [x] [P7-T2] Verify that every `.claude/skills/parallel-orchestrate/SKILL.md` edit made in Phases 1
      through 6 lies inside the region under `## Radius Drift Detection (F8)`, that
      `## Mutation Protocol (F6)` and `## Enforcement Hooks (F7)` are byte-identical to the text
      recorded in P0-T11, and that the three reserved sections appear in their original relative
      order with `## Radius Drift Detection (F8)` closing the file. Acceptance: the file contains
      exactly sixteen `##` headings, the two sibling sections match their recorded text exactly, and
      `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
      passes with that test file unmodified.
- [x] [P7-T3] Verify that `scripts/dev_tools/validate_parallel_orchestrator_state.py` is unchanged by
      this cycle: its diff against `c939b5b8` is still exactly the two lines added by `bcf2de15`, the
      dispatch call sits above the `BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION`
      comment, and the seam block is byte-identical to the text recorded in P0-T11 and still empty.
      Acceptance: the two-line diff and the empty, byte-identical seam block are both confirmed.
- [x] [P7-T4] Verify that `.claude/settings.json` is byte-identical to its `bcf2de15` state and that
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` differs from `bcf2de15` only by
      appended lines inside `CodeCoverage.Path`. Acceptance: SHA-256 of `.claude/settings.json`
      matches the value recorded in P0-T11, and the runsettings diff shows additions only with no
      existing entry moved, reflowed, or removed.
- [x] [P7-T5] Verify bundled-mirror parity by SHA-256 for every mirrored file this cycle touched:
      `.claude/hooks/enforce-parallel-drift-gate.ps1`,
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1`,
      `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/settings.json`, and
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, each against its counterpart
      under `extensions/drm-copilot/resources/`. Acceptance: each source and mirror pair has equal
      SHA-256, and `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
      lists both hook paths.
- [x] [P7-T6] Verify that no out-of-scope file was modified: `git diff --name-only c939b5b8..HEAD`
      contains no path under `.claude/rules/`, no path under `.github/instructions/`, no
      `.claude/skills/orchestrate/SKILL.md`, no `.ts` or `.tsx` path, no
      `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, and no
      `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`; and, against
      `bcf2de15..HEAD`, neither `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
      nor `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` appears. The
      second range is `bcf2de15..HEAD` because `c939b5b8..HEAD` already lists both F5 files —
      `bcf2de15` modified them — so a `c939b5b8`-based criterion could never pass. Acceptance: the
      `c939b5b8..HEAD` changed-path list is confirmed to contain none of the first five paths, and the
      `bcf2de15..HEAD` changed-path list is confirmed to contain neither F5 test artifact.
- [x] [P7-T7] Verify that every file this cycle created or modified is under 500 lines. Acceptance: a
      line-count listing of every path in `git diff --name-only c939b5b8..HEAD` that is a `.py`,
      `.ps1`, or `.psd1` file shows no value greater than 500, and the two files that were at exactly
      500 at cycle entry now show real headroom.
- [x] [P7-T8] Write
      `evidence/remediation-baseline/shared-file-edit-confinement.2026-08-09T00-01.md` recording the
      outcome of P7-T1 through P7-T7. Acceptance: the artifact carries `Timestamp:`, one section per
      verification task with the command used, its `EXIT_CODE:`, and its `Output Summary:`, and a
      `Verdict:` line stating whether every wave-4 concurrency constraint held.

### Phase 8 — Final QC Loop and Acceptance-Criteria Check-Off

Every command task in this phase is unconditional. `EXIT_CODE: SKIPPED` is not a permitted outcome.
If any step fails or rewrites a file, restart the affected language loop from its formatting step and
re-record the artifacts.

- [x] [P8-T1] Run `poetry run black .` from the repo root and write
      `evidence/qa-gates/python-format-final.2026-08-09T00-01.md`. Acceptance: the artifact carries
      `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming any file rewritten; if
      any file was rewritten, the loop restarts at this task after the rewrite.
- [x] [P8-T2] Run `poetry run ruff check .` from the repo root and write
      `evidence/qa-gates/python-lint-final.2026-08-09T00-01.md`. Acceptance: the artifact carries
      `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording zero diagnostics and
      zero `# noqa` suppressions added by this cycle.
- [x] [P8-T3] Run `poetry run pyright` from the repo root and write
      `evidence/qa-gates/python-typecheck-final.2026-08-09T00-01.md`. Acceptance: the artifact
      carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording zero errors
      and zero `# type: ignore` suppressions added by this cycle.
- [x] [P8-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` from the repo root
      and write `evidence/qa-gates/python-test-final.2026-08-09T00-01.md`. Acceptance: the artifact
      carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the
      passed/failed counts, numeric repo-wide line and branch coverage, and a per-file line/branch
      row for each of the seven Python production modules in this feature's scope
      (`parallel_drift_detection.py`, `parallel_drift_detection_cli.py`, `parallel_drift_halt.py`,
      `parallel_drift_resolution.py`, `_parallel_drift_shape.py`, `_parallel_drift_cli_io.py`,
      `_parallel_orchestrator_state_drift.py`).
- [x] [P8-T5] Run `mcp__drm-copilot__run_poshqc_format` against the worktree root and write
      `evidence/qa-gates/powershell-format-final.2026-08-09T00-01.md`. Acceptance: the artifact
      carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming any file
      rewritten; if any file was rewritten, the PowerShell loop restarts at this task.
- [x] [P8-T6] Run `mcp__drm-copilot__run_poshqc_analyze` against the worktree root and write
      `evidence/qa-gates/powershell-analyze-final.2026-08-09T00-01.md`. Acceptance: the artifact
      carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording zero
      PSScriptAnalyzer diagnostics for the two drift-gate PowerShell files.
- [x] [P8-T7] Run `mcp__drm-copilot__run_poshqc_test` against the worktree root and write
      `evidence/qa-gates/powershell-test-final.2026-08-09T00-01.md`. This step is expected to exit 1
      solely because of the named pre-existing failure
      `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ::
      `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` at line 142.
      Acceptance: the artifact carries `Timestamp:`, `Command:`, the observed `EXIT_CODE:`, and an
      `Output Summary:` that names every observed failure by file and test name, attributes the
      non-zero exit explicitly to the named pre-existing failure with its assertion site and its
      P0-T8 counterpart, reports the failed-count delta against P0-T8, and records numeric LINE and
      INSTRUCTION coverage plus per-file LINE coverage for
      `.claude/hooks/enforce-parallel-drift-gate.ps1` and
      `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1`. Recording a false zero failure count,
      or recording `EXIT_CODE: SKIPPED`, fails this task.
- [x] [P8-T8] Run `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
      and write `evidence/qa-gates/f5-surface-contract-final.2026-08-09T00-01.md`. Acceptance: the
      artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming the
      `RESERVED_HEADINGS`, `FILLED_RESERVED_HEADINGS`, sixteen-`##` layout, and reserved-section
      ordering assertions all pass against the amended SKILL.md.
- [x] [P8-T9] Run `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` and
      write
      `evidence/qa-gates/evidence-locations-final.2026-08-09T00-01.md`. Acceptance: the artifact
      carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming every
      artifact this cycle produced resolves under
      `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/<kind>/` and that no
      path under `artifacts/` was used for evidence.
- [x] [P8-T10] Write `evidence/qa-gates/coverage-delta.2026-08-09T00-01.md` comparing the P8-T4 and
      P8-T7 figures against the P0-T9 cycle-entry floors. Acceptance: the artifact carries
      `Timestamp:` and a table reporting, per surface, the cycle-entry value, the post-remediation
      value, and the changed-code coverage; it confirms that the six pre-existing new Python modules
      remain at 100% line and branch, that every module created this cycle meets line >= 85% and
      branch >= 75%, that `.claude/hooks/enforce-parallel-drift-gate.ps1` and its new sibling each
      meet line >= 85%, and that no benchmark regressed; and it records the PowerShell branch metric
      as not emitted by the toolchain rather than inventing a value. The two absolute suite-outcome
      rows (Python 3176 passed; PowerShell 2080 passed / 1 failed / 9 skipped) are compared against the
      figures stated in this plan's `## Non-Regression Benchmarks` section, not against the P0
      re-capture, so a degraded re-capture cannot lower the floor.
- [x] [P8-T11] Write `evidence/qa-gates/acceptance-criteria-checkoff.2026-08-09T00-01.md` per the
      `acceptance-criteria-tracking` skill, evaluating every entry of the `## Acceptance Criteria`
      sections of `spec.md` and `user-story.md` against the post-remediation state, with the F8-B1
      and F8-B2 fixes named as the evidence for the criteria they affect. Acceptance: the artifact
      carries `Timestamp:`, one section per criterion with its checkbox state and named test or
      artifact evidence, an explicit US-4 clause split naming the F8-owned clauses as met and the
      requeue clause as an outstanding F6 dependency, and a cross-feature dependency register; and
      `user-story.md` US-3, US-4, and US-6 remain `- [ ]` because their F6 dependencies are unmet.
- [x] [P8-T12] Write `evidence/qa-gates/remediation-cycle-summary.2026-08-09T00-01.md` recording the
      cycle disposition. Acceptance: the artifact carries `Timestamp:`, one row per finding named in
      this plan's `## Scope Contract` with its disposition (remediated, recorded, or explicitly out
      of scope), a `Blocking count:` line stating `0` only if both F8-B1 and F8-B2 are verified fixed
      with the named tests passing, and an explicit list of the out-of-scope findings F8-N5, F8-N7,
      and F8-N8 restating that no task was planned or executed for them.
