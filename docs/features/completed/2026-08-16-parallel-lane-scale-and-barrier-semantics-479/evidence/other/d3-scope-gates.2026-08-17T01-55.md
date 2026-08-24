# D3 Scope Gates (Issue #479, [P3-T10], AC30 and AC31)

Timestamp: 2026-08-17T01-55

Note on file registration: the new files this feature adds
(`scripts/dev_tools/parallel_lane_assertion.py`, three test modules, and thirteen M8 fixtures)
were registered with `git add -N` (intent-to-add) before these gates ran, so `git grep` and
`git diff --name-only` see them. Without that step both commands silently skip untracked files
and every gate below would pass vacuously.

---

## Gate (a): the diagnostic is imported by no cohort-computation, validation, or mutation module

Command: `git grep -n "parallel_lane_assertion" -- scripts/dev_tools`

EXIT_CODE: 0

Output Summary:

```
scripts/dev_tools/parallel_lane_assertion.py:440:        prog="parallel_lane_assertion",
```

The ONLY occurrence anywhere under `scripts/dev_tools` is the module's own argparse `prog`
value, inside the module itself. `git grep -l "parallel_lane_assertion" -- scripts/dev_tools`
lists exactly one file: `scripts/dev_tools/parallel_lane_assertion.py`. No cohort-computation
module, no validator, no helper, and no mutation module imports or names it.

Repo-wide (tracked) references, for completeness: `.claude/rules/parallel-orchestration.md`
(the M8 prose naming the consumer), `.claude/skills/parallel-plan/SKILL.md` (the advisory
invocation), the feature's own artifacts, the module, and its test module. No production
consumer exists.

---

## Gate (b): no cohort-computation change, and no M8 logic in any checkpoint validator

Command: `git diff --name-only $(git merge-base origin/main HEAD)`

EXIT_CODE: 0

Output Summary:

- `scripts/dev_tools/parallel_cohort_computation.py` is **absent** from the name-only diff
  (`grep -c` over the diff reports 0). The cohort computation is untouched.
- `git grep -n "expected_conflict_components\|M8" -- scripts/dev_tools/validate_parallel_orchestrator_state.py scripts/dev_tools/validate_parallel_planner_state.py scripts/dev_tools/_parallel_state_common.py scripts/dev_tools/_parallel_state_structures.py scripts/dev_tools/_parallel_state_records.py`
  returns **zero matches** (exit 1). Neither checkpoint validator nor any of their three helper
  modules carries M8 or `expected_conflict_components` logic. The only Python change in those
  two validators is the `MAX_CONCURRENCY` constant (D2), which is unrelated to D3.

---

## Gate (c): no TypeScript surface for D3

Command: `git grep -n "expected_conflict_components" -- extensions/drm-copilot/src`

EXIT_CODE: 1

Output Summary: **zero matches**. No TypeScript manifest port is created and no TypeScript
checkpoint validator gained M8 or `expected_conflict_components` logic. The only TypeScript
change in this feature is D2's `MAX_CONCURRENCY` constant in the two core validators.

---

## AC disposition

- **AC30** — satisfied: `parallel_cohort_computation.py` is unmodified, and the diagnostic is
  imported by no cohort-computation, validation, or mutation module.
- **AC31** — satisfied: no TypeScript manifest port exists, and neither checkpoint validator
  (Python or TypeScript) changed for D3.
