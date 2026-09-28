# Remediation Cycle 1 Summary — F8 Radius Drift Detection (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P8-T12]
Plan: `docs/features/active/2026-08-07-parallel-drift-detection-446/remediation-plan.2026-08-09T00-01.md`
Remediation inputs: `remediation-inputs.2026-08-09T00-01.md`
Implementation commit under remediation: `bcf2de15`. Base of the feature diff: `c939b5b8`.
Epic: `parallel-orchestration`, wave 4, child F8.

Plan execution: **80 of 80 tasks complete** across Phases 0 through 8.

## Blocking count: 0

Both Blocking findings are verified fixed with their named tests passing.

- **F8-B1** — verified by `evidence/remediation-baseline/f8-b1-verification.2026-08-09T00-01.md`
  (`EXIT_CODE: 0`). Named tests passing:
  `test_applying_the_emitted_observed_radius_resolves_the_recorded_drift`,
  `test_widening_the_declared_radius_resolves_the_recorded_drift`, and
  `test_request_resolution_write_serializes_the_library_radius_unchanged`, all in
  `tests/scripts/dev_tools/test_parallel_drift_resolution.py`.
- **F8-B2** — verified by `evidence/remediation-baseline/f8-b2-verification.2026-08-09T00-01.md`
  (`EXIT_CODE: 0`). Named tests passing:
  `test_the_drifting_item_is_never_halted_even_when_it_started_later` and
  `test_halted_item_keys_applies_the_comparator_to_a_pair_without_the_drifter`, both in
  `tests/scripts/dev_tools/test_parallel_drift_detection_cli_halt.py`, plus the corrected
  `test_evaluate_drift_halts_the_later_started_item_of_a_new_conflict`,
  `test_evaluate_drift_selects_one_halted_item_per_newly_conflicting_pair`,
  `test_recomputed_pair_feeds_halt_selection_and_yields_later_started_item`, and
  `test_main_prints_the_detection_result_as_json`.

Both are corroborated by the final QC pass: [P8-T4] reports 3201 passed / 0 failed with all seven
in-scope Python modules at 100% line and 100% branch coverage.

## Disposition of Every Finding in the Plan's Scope Contract

### Blocking, remediated by this cycle

| ID | Title | Disposition |
| --- | --- | --- |
| F8-B1 | Derived resolution has no producer, so the Layer-2 drift gate has no release path | **Remediated** (Phase 2). New peer module `scripts/dev_tools/parallel_drift_resolution.py` supplies `build_observed_radius` and the request-only seam `request_resolution_write`; `evaluate_drift` emits a ninth payload key `observed_radius`; SKILL.md `#### Seven-Step Procedure` step 7 names the actor, the trigger, and both writes. No schema field added, no enum extended. |
| F8-B2 | Halt selection can select the drifting item | **Remediated** (Phase 3). The drifting key is dropped from each pair's candidate list at the call site `halted_item_keys` in `scripts/dev_tools/parallel_drift_detection_cli.py` before any selection runs. `select_halted_item` keeps its `(a, b)` signature and body byte-identical to `bcf2de15`; only its docstring changed. No zero-candidate branch was written, so branch coverage stays at 100%. |

### Non-blocking, in scope for this cycle

| ID | Title | Disposition |
| --- | --- | --- |
| F8-N10 and reviewer item (e) | Hook and its Pester suite each exactly 500 lines, zero headroom | **Remediated** (Phase 1). Seven helpers moved verbatim to `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1`; Pester suite split; Python CLI test suite split with three fixtures relocated. The hook is now 359 lines and its suite 386. Evidence: `evidence/remediation-baseline/split-parity.2026-08-09T00-01.md`. |
| F8-N4 | `computed_at > at` compared ordinally with no canonical-format contract | **Remediated** (Phase 4) in **both** runtimes. Python gained `CANONICAL_TIMESTAMP_RE` and `is_later_canonical_timestamp`; PowerShell gained `Test-ParallelDriftGateCanonicalTimestamp` with a character-identical pattern, gating the `CompareOrdinal` call on both sides conforming. Four rows added to the shared cross-runtime seam table. Evidence: `evidence/remediation-baseline/f8-n4-verification.2026-08-09T00-01.md`. |
| F8-N3 | Any `remediation-inputs.*.md` opens the Layer-1 gate | **Remediated** (Phase 5). `Get-ParallelDriftGateUnresolvedState` now surfaces `LatestAt`; `Test-ParallelDriftFindingPresent` takes a mandatory `EventAt` and requires the file name's embedded timestamp to be ordinally at or after it; the call site passes the current event's `at` and denies fail-closed when none is available. Presence gating only — verified by grep that no glob match, git invocation, diff computation, or finding-file content read exists in the hook or its helpers. Evidence: `evidence/remediation-baseline/f8-n3-verification.2026-08-09T00-01.md`. |
| F8-N1 | TypeScript Layer-2 drift-gate parity divergence has no durable repo-level record | **Recorded** (Phase 6). `docs/features/potential/2026-08-09-parallel-drift-gate-typescript-parity-divergence.md`, written from `docs/features/potential/template.md`, naming the missing dispatch, the divergent error set, the insertion point outside the F7 seam, and Python's interim authority. No `.claude/rules/**` edit and no TypeScript change. |
| F8-N2 | Layer-1 narrowing lacks a stated recovery action | **Recorded** (Phase 6). One sentence added under SKILL.md `#### Layer-1 Narrowing — a Documented Limitation` naming the recovery action: re-record the item's radius from the later observed diff, which satisfies both runtimes because it is disjunct (b). |
| F8-N6 | `has_unresolved_drift(events, items)` widens the reconciled one-argument IC-6a contract | **Recorded** (Phase 6). IC-6a amendment appended to `evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md` under its own dated heading, stating the delivered two-argument signature, why the second argument is unavoidable, and that the widening follows from the IC-3a resolution-semantics deviation. |
| F8-N9 | US-4 disposition partly deflected | **Recorded** (Phase 6). Dated correction block appended to `evidence/qa-gates/acceptance-criteria-checkoff.2026-08-08T23-24.md` splitting US-4 into three clauses with two owners, stating that the previous reason deflected the "never halted" clause to F6 in error, and that the checkbox stays unchecked because the requeue clause is still unmet. `user-story.md` is unmodified. |

## Explicitly Out of Scope — no task was planned and none was executed

The plan's `## Scope Contract` lists these as out of scope. **No task was planned for any of them, and
no task was executed against any of them.** Restated individually as required:

- **F8-N5** — no run-time binding between the documented CLI surface in
  `.claude/skills/parallel-orchestrate/SKILL.md` `#### CLI Invocation` and `build_parser()`.
  **No task was planned or executed for F8-N5.**
- **F8-N7** — no code appends the `mutations[]` entry or increments `recolor_generation`. Closes when
  F6 (issue #442) lands. **No task was planned or executed for F8-N7.**
- **F8-N8** — the cross-runtime seam test spawns `python` resolved from machine PATH without a
  recorded exception comment. **No task was planned or executed for F8-N8.**

Also out of scope and untouched, verified by [P7-T6] over both the committed range and this cycle's
working-tree changes: any TypeScript change including the Layer-2 parity port; any edit to
`.claude/rules/**`; any edit to `.github/instructions/**`; any edit to
`.claude/skills/orchestrate/SKILL.md`; and any edit to
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` or
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`.

The informational findings **F8-I1 through F8-I9** remain recorded for the wave-4 integrator; none was
actioned.

## Final Gate Results

| Gate | Command | EXIT_CODE |
| --- | --- | --- |
| Python format | `poetry run black .` | 0 — no file rewritten |
| Python lint | `poetry run ruff check .` | 0 — zero diagnostics, zero `# noqa` added |
| Python type check | `poetry run pyright` | 0 — zero errors, zero `# type: ignore` added |
| Python test | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 0 — 3201 passed / 0 failed |
| PowerShell format | `mcp__drm-copilot__run_poshqc_format` | 0 — no file rewritten |
| PowerShell analyze | `mcp__drm-copilot__run_poshqc_analyze` | 0 — zero diagnostics |
| PowerShell test | `mcp__drm-copilot__run_poshqc_test` | **1** — one failure, the named pre-existing `enforce-pr-author-skill.Tests.ps1:142` case; failed-count delta against [P0-T8] is **0** |
| F5 surface contracts | `poetry run pytest tests/.../test_parallel_orchestrator_surface_contracts.py` | 0 — 36 passed |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | 0 |

Both language loops completed in a **single clean pass**; no step failed or rewrote a file, so neither
loop restarted.

## Non-Regression Verdict

Recorded in full in `evidence/qa-gates/coverage-delta.2026-08-09T00-01.md`. **No benchmark regressed.**

- Python suite: floor 3176 passed, observed **3201 passed / 0 failed** — cleared by 25.
- PowerShell suite: floor 2080 passed / 1 failed / 9 skipped, observed **2089 / 1 / 9** — failed count
  unchanged, and the one failure is the named pre-existing case.
- All six pre-existing new Python modules remain at 100% line and 100% branch; two of them hold 100% on
  a larger measured denominator.
- The one new Python module is at 100% line; the one new PowerShell module at 100% line and instruction.
- Union of the two drift-gate `.ps1` files: **96.97% LINE (160/165)** against the 96.53% single-file
  benchmark. Compared as a union because Phase 1's split moved 59 measurable lines to the sibling.
- Python repo-wide rose to 92.04% line / 84.14% branch from 92.02% / 84.11%.
- PowerShell branch coverage is not emitted by the toolchain; no value was invented.

## Acceptance Criteria

21 total across `spec.md` (12) and `user-story.md` (9); **18 checked, 3 unchecked**, all three F6
cross-feature dependencies. After the US-4 correction, **no F8-owned clause of any acceptance criterion
is outstanding.** Full detail in `evidence/qa-gates/acceptance-criteria-checkoff.2026-08-09T00-01.md`.

## Newly Discovered Observation — opens a new cycle, not remediated here

`ConvertFrom-Json` coerces a full ISO-8601 instant such as `2026-01-02T00:00:00Z` into a `[datetime]`,
so a checkpoint carrying such a timestamp reaches the PowerShell helpers as a non-string and is reported
as a **malformed log**, while Python's `json.load` keeps it a string and reports the item as
**unresolved**. Both verdicts deny and PowerShell's is strictly the more conservative, so the seam
test's fail-closed subset invariant still holds; the divergence is in the `Malformed` flag only, in the
deny direction. Observed while constructing the [P4-T6] rows and recorded in
`evidence/remediation-baseline/f8-n4-verification.2026-08-09T00-01.md`. Per this plan's
`## Scope Contract`, a finding discovered during execution opens a new remediation cycle and does not
extend this plan, so it was recorded rather than fixed.
