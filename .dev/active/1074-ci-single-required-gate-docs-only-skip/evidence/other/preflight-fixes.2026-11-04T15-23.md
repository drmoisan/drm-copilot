# Preflight Fixes (Issue #1074)

Timestamp: 2026-11-04T15-23
Plan: docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/plan.2026-11-04T09-46.md

Every fix below edits task text or plan preamble only. No task was added, removed, or reordered.

## Fixes

1. `## Conventions`, Evidence-location note | evidence path spelling | The note said the plan writes proof evidence to `evidence/regression-testing/` against the spec. `spec.md` AC-40 to AC-43 and the spec's manual validation steps name `evidence/other/` without ambiguity, so the note now states that the Phase 7 proof artifacts go to `<FEATURE>/evidence/other/`.
2. `## Pre-Mortem`, Evidence bullet | evidence path spelling | "proof runs to `evidence/regression-testing/`" became "the config check and the proof runs to `evidence/other/`".
3. [P7-T1], [P7-T3], [P7-T4], [P7-T6] | evidence path spelling | `<FEATURE>/evidence/regression-testing/proof-{a-full-run,b-gate-red,c-revert-green,d-docs-only}.<timestamp>.md` became `<FEATURE>/evidence/other/...` with the same file names, matching spec AC-40 to AC-43. The asserted contents are unchanged.
4. `## Pre-Mortem`, File size bullet | incorrect stated fact | The bullet said no edited file is near the 500-line guidance tier. `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` has 485 physical lines (`wc -l`), and [P4-T3] adds about 11 context entries, 4 tokens, and an absence assertion. The bullet now states the count and that [P4-T3] keeps the module at or below 500 lines.
5. [P4-T3] | validator-blind defect (acceptance at risk from the task's own edit) | Added the 485-line starting count and the instruction to write the additions compactly so the module meets the existing [P6-T9] limit of 500 lines. The [P6-T9] assertion is unchanged.
6. [P3-T1] | anchor | Research heading cited as `### 3.3 Proposed job text`; the heading is `### 3.3 Proposed job text (for the planner, not final)`.
7. [P3-T3] | anchor | Research heading cited as `## 6. Tests That Pin ci.yml or _poshqc.yml`; the heading carries backticks around `ci.yml` and `_poshqc.yml`. Corrected to the exact heading.
8. [P5-T1] | anchor | Research heading cited as `## 8. Ruleset Runbook`; the heading is `## 8. Ruleset Runbook (manual, owner or coordinator, after merge)`.
9. [P4-T4] | anchor | README heading cited as `### The run-heavy input`; the heading in `.github/workflows/README.md` is ``### The `run-heavy` input``.
10. [P4-T2] | validator-blind defect (changed-behavior test dispositions) | Named the other tests that read the brief copies and their dispositions: `test_execution_environment_fact_is_unchanged_across_copies` (`test_discovery_documentation_contracts.py`) and `test_copilot_bundle_copies_match_canonical` (`test_single_pass_preflight_contracts.py`), both unchanged because byte identity is preserved; `cleanup-merged-worktrees.SkillText.Tests.ps1`, unchanged because it reads only `## Hook Execution Context`.
11. [P4-T5] | validator-blind defect (changed-behavior test dispositions) | Named `test_atomic_plan_contract_matches_bundled_mirror` (`test_evidence_timestamp_contracts.py`) as unchanged because the two edited copies stay byte-identical, and recorded that no test under `tests/` pins the edited sentence (search token `aggregating required check`), so the other readers are unchanged because unaffected.
12. [P4-T6] | validator-blind defect (changed-behavior test dispositions) | Added `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`, `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`, and `tests/scripts/dev_tools/test_evidence_timestamp_contracts.py` to the pytest command so the tests named in fixes 10 and 11 are run. The acceptance (`EXIT_CODE: 0`, zero failed) is unchanged; [P6-T6] re-runs the same command.

## Preflight Probes (read-only, no tree change)

- Ruleset 15241672 read-only GET (output kept under `SCRATCH`): 20 `required_status_checks` contexts, each with `integration_id` 15368, equal to the [P0-T3] expected set; `bypass_actors` present.
- Pester over `tests/scripts/ci` and `tests/scripts/workflows` at the branch head (coverage off): 284 tests, 284 passed, 0 failed, so the zero-failure gates of [P3-T3] and [P6-T3] have no pre-existing host failure on the Linux Codespace.
- `actionlint .github/workflows/ci.yml`: exit 0, no output.
- pytest over the [P4-T6] file set including the three added files, run with the main checkout's virtual environment: 167 passed. The worktree `.venv` contains only pip, so `poetry run pytest` in this worktree needs `poetry install` first (environment micro-action, not a plan change).
