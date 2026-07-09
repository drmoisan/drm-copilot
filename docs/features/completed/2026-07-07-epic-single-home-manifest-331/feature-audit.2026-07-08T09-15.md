# Feature Audit: epic-single-home-manifest (Issue #331)

**Audit Date:** 2026-07-08
**Feature Folder:** `docs/features/active/2026-07-07-epic-single-home-manifest-331/`
**Base Branch:** `main`
**Head Branch:** `feature/epic-single-home-manifest-331`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (merge base `ee65d6e9e99b86bdbd7d00dcc47fc90db39ff56b`)
- **Head branch/commit:** `feature/epic-single-home-manifest-331` @ `732a607d60ea2b9e8072b3cf594caf2b810f1e09`
- **Merge base:** `ee65d6e9e99b86bdbd7d00dcc47fc90db39ff56b`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-07-epic-single-home-manifest-331/evidence/**`
  - Coverage artifacts: `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`
- **Feature folder used:** `docs/features/active/2026-07-07-epic-single-home-manifest-331/`
- **Requirements source:** `spec.md` and `user-story.md` (full-feature mode; both carry the six canonical AC verbatim)
- **Work mode resolution note:** `issue.md` contains `- Work Mode: full-feature`; per the workflow contract this resolves AC sources to `spec.md` and `user-story.md`.
- **Scope note:** Audit scope is the full branch diff `ee65d6e..732a607` against `main`, not any plan/task subset. 65 files changed (+3516/-341).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-07-epic-single-home-manifest-331/spec.md` — primary
- `docs/features/active/2026-07-07-epic-single-home-manifest-331/user-story.md` — co-authoritative (identical six criteria)

### Acceptance criteria (verbatim)

1. `new_active_feature_folder(type=epic)` scaffolds only `docs/features/epics/<epic-slug>/{epic.md, epic-status.md}`; no `active/` epic folder and no `initiative.md`.
2. The epic-orchestrate skill documents the single-home layout, `epic.md` as merged source, DAG keyed by `issue_num`, generated-only `epic-status.md`, and the optional intent block; the active→completed path workaround text is removed.
3. `epic_wave_computation.py` and `validate_epic_orchestrator_state.py` resolve the DAG by `issue_num`, accept `feature_folder` in `active/` or `completed/`, validate the intent block only when present, and remain byte-identical on legacy manifests (regression tests prove it).
4. New/changed logic has tests; the drm-copilot toolchain (format → lint → type-check → tests) passes in order.
5. Push-down tooling updated/run so consumer repos can pick up the change.
6. Change description records the deferred per-consumer migration (incl. TaskMaster epic #260).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Epic scaffolds only single home; no active/ folder, no initiative.md | PASS | `new_active_feature_folder_flow.py` L131-133 routes `epic` to `docs/features/epics/<slug>/`; `flow.ts` parity; templates add `docs/features/templates/epic/epic.md` (+79) and `epic-status.md` (+20) and retire `initiative.md` (-43, also in extension resources); tests `test_new_active_feature_folder_part2.py` and TS `flow/io/docs.test.ts` assert no `active/` epic folder and no `initiative.md`. | `git diff --stat`; Read of flow.py | Child scaffolding unchanged (FR-2). |
| 2 | Skill documents single-home layout; workaround text removed | PASS | `.claude/skills/epic-orchestrate/SKILL.md` (+/-75) now states at L166 "no active→completed path-drift workaround is needed" (issue_num-keyed phrasing replacing the removed workaround); byte-identical mirror updated and enforced. | `grep` of SKILL.md; `parity-resource-contract.*` (exit 0) | Mirror parity gate green. |
| 3 | Validators resolve by issue_num, accept active/+completed hints, presence-gated intent, byte-identical on legacy | PASS | `_epic_orchestrator_state_resolution.py` (+288) union-index resolver + `_normalize_folder_hint` (active/completed prefixes) + `validate_intent_block` (key-gated); consumed across four checks in `validate_epic_orchestrator_state.py`; `epic_wave_computation.py` unchanged (already key-agnostic) with green legacy regression. | `pytest test_validate_epic_orchestrator_state.py -v`; `pytest test_epic_wave_computation.py -v` (both exit 0) | Legacy fixtures unchanged; byte-identical proven by regression evidence. |
| 4 | New/changed logic tested; toolchain passes in order | PASS | Python: black/ruff/pyright/pytest all exit 0 (`final-py-*`, 1309 passed). TypeScript: format/lint/typecheck/test:coverage all exit 0 (`final-ts-*`, 1568 passed). Reviewer independently confirmed `black --check` exit 0 on changed Python. Coverage meets uniform gate on all changed files. | `poetry run black --check`; feature `final-*` evidence | Independent spot-verification performed. |
| 5 | Push-down tooling updated/run | PASS | `evidence/qa-gates/pushdown.2026-07-07T21-08.md` records `push_down_claude_customizations --destination <scratch>` exit 0; `parity-pack-manifest.*` (pack-manifest completeness) exit 0; epic-orchestrate skill already listed in `pack-manifests/core.json`. | `python -m scripts.dev_tools.push_down_claude_customizations ...`; `npm run test -- claude-pack-manifest-completeness` | FR-7 satisfied. |
| 6 | Change description records deferred migration (incl. #260) | PASS | `spec.md` "Deferred follow-up: migration of existing epics" and Non-Goals explicitly defer #260; `user-story.md` Non-Goals; `evidence/other/migration-deferral-note.2026-07-07T21-08.md`. | Read of spec.md L54-57, L421-426 | Deferral is explicit and traceable. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 6 criteria
- **PARTIAL:** 0
- **UNVERIFIED:** 0
- **FAIL:** 0

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Optional housekeeping unrelated to the ACs: relocate/remove the untracked `artifacts/research/2026-07-07T19-00-epic-folder-structure-research.md` so the whole-tree evidence-location validator returns to zero (see policy audit).
2. Per the spec, per-consumer migration (TaskMaster epic #260) is a deferred follow-up tracked outside this feature.

---

## Acceptance Criteria Check-off

All six criteria evaluate to PASS. They were already checked off as `- [x]` in both authoritative source files by the executor during delivery; the reviewer confirms the checked state is correct and leaves them checked. No source-file checkbox change was required in this audit because every item was already `[x]` and every item independently verifies as PASS.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 6 (per file)
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-07-epic-single-home-manifest-331/spec.md` | 6 | 6 | 0 | Checkbox-backed; all pre-checked and verified PASS |
| `docs/features/active/2026-07-07-epic-single-home-manifest-331/user-story.md` | 6 | 6 | 0 | Checkbox-backed; all pre-checked and verified PASS |
