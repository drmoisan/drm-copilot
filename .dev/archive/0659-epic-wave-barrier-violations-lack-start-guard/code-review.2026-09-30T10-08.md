# Code Review: epic-wave-barrier-violations-lack-start-guard (Issue #659)

- Timestamp: 2026-09-30T10-08
- Branch: `bug/epic-wave-barrier-violations-lack-start-guard-659` at `bcc1e260`
- Base: `origin/main` (merge base `a24a1ce3`)
- Scope: full branch diff; production files `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` (added), `scripts/dev_tools/validate_epic_orchestrator_state.py`, `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`; tests, fixture, skill document and mirror, frozen-surface expectations.

## Executive Summary

The change is small, correct against the issue's consolidated requirements, and structured for parity: one committed fixture drives both runtimes, and the Python and TypeScript implementations are line-for-line equivalent. The predicate is fail-closed as the issue requires, the status case takes precedence over the timing case so exactly one error is emitted per edge, and the Python status term now checks `isinstance(..., str)` before set membership, which closes a latent `TypeError` on the barrier path and aligns with the TypeScript `typeof` check.

No blocking findings. Five non-blocking findings are listed below.

## Correctness Review

- **Start predicate.** Python `feature_has_started` returns True when `worktree_created_at` is a string, otherwise `merge_status != "not_started"`. TypeScript `hasStarted` is `typeof worktree_created_at === "string" || merge_status !== "not_started"`. For JSON-parsed input the two agree on every value class: absent key (`None` / `undefined`), `null`, strings, numbers, lists, and objects.
- **Guard placement.** The guard runs after the existing non-string folder and non-list `depends_on` skip and before the edge loop, in both runtimes. An unstarted dependent is skipped entirely, which satisfies AC-1 and AC-6.
- **One error per edge.** The previous `status_violation or timing_violation` produced one error per edge with a single message; the new `if` / `elif` keeps the one-per-edge count (AC-2) and selects the accurate message (AC-4). Precedence is exercised by the `status-and-timing-on-one-edge` case.
- **Message rendering.** `{dependency}` (Python `str()`) and `${String(dependency)}` (TypeScript) agree for strings and integers, which are the reference forms the resolver supports; the `integer-issue-number-reference` case asserts this.
- **Relocation.** The removed private `_validate_wave_barrier_ordering` had no other callers. `MERGED_STATUSES` moved to the helper and is re-imported by the validator, where `_validate_completion` still uses it, so no behavior outside the barrier changed.
- **Circular import.** The helper imports only `_epic_orchestrator_state_resolution`; the validator imports the helper. No cycle.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` | whole file | The new fixture is not Prettier-formatted; `prettier --check` and the repository root `npm run format:check` both report it. | Run Prettier on the fixture before merge. | The root script covers `tests/**/*.json`. It already fails on more than 100 pre-existing fixtures and is not run in CI, so this is not a gate regression, but a new file should not add to the backlog. | Reviewer run of `npx --prefix extensions/drm-copilot prettier --check ...` (exit 1, one warning) and `npm run format:check` (exit 2). |
| Advisory | `.claude/skills/epic-orchestrate/SKILL.md` and bundled mirror | Layer 2 bullet, line 244 | The rewritten bullet keeps the sentence stating that Layer 2 is enforced at `SubagentStop` through `validate-orchestrator-output.ps1`. The executor's own follow-up 2 shows that the hook performs only a structural check. | File follow-up 2 as a potential entry; correct the sentence in that change (with a digest re-baseline). | Out of scope for this issue per the plan, but the edited bullet now documents behavior in more detail while retaining an inaccurate enforcement claim. | `evidence/other/follow-ups.md` section 2; `.claude/hooks/validate-orchestrator-output.ps1` lines 267-270 as cited there. |
| Advisory | `evidence/other/follow-ups.md` | both entries | Both follow-ups carry disposition "not filed". Follow-up 1 is a real Python-versus-TypeScript divergence: a list or object `merge_status` raises in `_validate_merge_status_enum` while the TypeScript port returns an error. | Promote both follow-ups to potential entries so they are tracked. | Unrecorded follow-ups are lost when the feature folder moves to `completed/`. | `scripts/dev_tools/validate_epic_orchestrator_state.py` line 238 and line 321. |
| Advisory | `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts` | end of file | The Python suite has a direct test of the skip paths (non-string folder, non-list `depends_on`, unresolved reference); the Jest suite has no counterpart. TypeScript lines 290-291 (the non-string folder / non-list `depends_on` `continue`) remain uncovered. | Add a matching Jest case in a later change. | The lines are pre-existing and outside the changed hunks, so coverage gates pass; the gap is in parity of test intent, not in delivered behavior. | `extensions/drm-copilot/coverage/lcov.info` DA 290 and 291 with hit count 0. |
| Advisory | `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` | whole file | The file is 491 lines, 9 below the 500-line limit. | Plan the next change to this file with a split (for example a wave-barrier sibling module mirroring the Python helper). | The plan declared a TypeScript split out of scope for this minor-audit; the next edit will likely exceed the limit. | `wc -l` output; `evidence/qa-gates/line-counts.md`. |

## Design and Maintainability

- The helper module follows the existing `_epic_orchestrator_state_*.py` sibling-delegate convention and documents why it does not reuse the parallel orchestrator's `_has_started` (different treatment of an absent `merge_status`). This explanation prevents a well-meaning future consolidation from changing the semantics without notice.
- The shared fixture is the single source of expected strings for both runtimes; the fixture count assertion (14) and the name-uniqueness assertion prevent silent case loss.
- The frozen-surface digest re-baseline includes a dated rationale comment consistent with the previous re-baseline entries.
- `VALID_MERGE_STATUS` remains in the validator while `MERGED_STATUSES` moved to the helper. The split is workable because the helper needs only the merged subset, but a future reader looks in two files for the status vocabulary. No action required.

## Test Quality

- Arrange-Act-Assert comments are present in every test, and every Python assertion has a descriptive message.
- The TypeScript suite narrows fixture data with runtime guards (`requireObject`, `requireArray`, `requireString`) instead of type assertions, which keeps the ESLint `no-unsafe-*` rules satisfied without casts.
- Both suites read only the committed fixture, which the unit-test policy permits; no temporary files are created.
- Fail-before evidence confirms that the new tests detect the defect: 13 of 15 Python items and 14 of 16 Jest tests failed against the unchanged production code.

## Verification Performed by the Reviewer

- `poetry run black --check`, `ruff check`, `pyright` on the five changed Python files: clean.
- `poetry run pytest` on the wave-barrier, validator, and surface-contract suites: 93 passed.
- `npm test --prefix extensions/drm-copilot -- <two validate suites> --coverage=false`: 47 passed.
- Suppression scan of the zero-context diff (`noqa`, `type: ignore`, `pyright: ignore`, `eslint-disable`, `ts-ignore`, `ts-expect-error`, `pragma: no cover`, `istanbul ignore`, `c8 ignore`): no match.
- Coverage re-derived from both lcov artifacts; values match `evidence/qa-gates/coverage-delta.md`.
- Trial merge against current `origin/main`: clean.
