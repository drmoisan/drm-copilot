# Measurement Driver Deleted, and No Sweep Was Added — [P6-T6]

Timestamp: 2026-08-26T13-35
Task: [P6-T6]
Command: `rm -f scripts/dev_tools/_tmp_plan_gate_corpus_driver.py`, then `git status --porcelain -- scripts/dev_tools`, then `git diff --name-only main -- .github/workflows scripts/dev_tools`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

The driver path deleted is `scripts/dev_tools/_tmp_plan_gate_corpus_driver.py`. It was created by [P6-T2], used by [P6-T2], [P6-T3], and [P6-T4], and is deleted here. It was never staged and never committed.

Each command below was issued as a bare, separate invocation and its exit code captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between any command and its capture.

## `git status --porcelain -- scripts/dev_tools`

EXIT_CODE: 0

```text
```

The output is **empty**. It contains no entry for `scripts/dev_tools/_tmp_plan_gate_corpus_driver.py`, no entry for `scripts/dev_tools/_tmp_plan_gate_regression_driver.py`, and no entry for anything else.

The porcelain span is the one that can see an untracked path. Neither driver was ever tracked, so a name-listing diff against `main` could not have reported either one whether it was present or absent; this span is what makes their absence observable. Had a deletion failed, this output would carry a `??` line naming the surviving driver.

## `git diff --name-only main -- .github/workflows scripts/dev_tools`

EXIT_CODE: 0

```text
scripts/dev_tools/plan_gate_commands.py
scripts/dev_tools/plan_gate_discrimination.py
scripts/dev_tools/plan_gate_observability.py
```

Three paths. **Neither driver path appears, and no path under `.github/workflows` appears at all.**

The three listed paths are exactly the shipped modules this feature amends or creates:

- `scripts/dev_tools/plan_gate_commands.py` — gained the `task_text` field ([P1-T2]).
- `scripts/dev_tools/plan_gate_discrimination.py` — gained the rule-group invocation ([P2-T5]).
- `scripts/dev_tools/plan_gate_observability.py` — the new rule module ([P2-T1] through [P2-T4]).

## Both driver paths are absent

| Driver path | Created by | Deleted by | In `git status --porcelain`? | In `git diff --name-only main`? |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/_tmp_plan_gate_regression_driver.py` | [P5-T2] | [P5-T6] | No | No |
| `scripts/dev_tools/_tmp_plan_gate_corpus_driver.py` | [P6-T2] | [P6-T6] | No | No |

Neither throwaway driver survives in the working tree, and neither appears in the branch diff against `main`. The [P5-T6] evidence records the same two spans for the regression driver at the point of its deletion; this artifact re-runs both spans after the second deletion, so the joint absence is observed rather than inferred from two separate single-driver checks.

## No sweep was added

The second recorded span is scoped to `.github/workflows` as well as to `scripts/dev_tools`, precisely so it can report an added workflow file. **It reports none: no path under `.github/workflows` appears in the branch diff against `main`.**

This matters because the acceptance-gate rule set has no corpus sweep and this feature adds none. The scope-of-invocation clause of `.claude/rules/plan-acceptance-gates.md` records that the plan validator only ever runs against the single artifact it is pointed at, that no CI job, test, or scheduled task sweeps the committed plan corpus, and that this is the argument against a grandfathering list, an exemption marker, a per-plan suppression comment, and an allowlist file. Adding a sweep here would have invalidated that argument and created a need for the suppression surface the rule set deliberately does not have.

The corpus measurement of [P6-T3] was a one-off run of a throwaway driver, taken to fix four severity constants and then deleted. It is not a recurring gate, and nothing in the branch diff schedules it to run again. [P6-T7] records the absence of the suppression surface itself.

## Output Summary

`scripts/dev_tools/_tmp_plan_gate_corpus_driver.py` was deleted. `git status --porcelain -- scripts/dev_tools` exited 0 and produced empty output, containing neither driver path. `git diff --name-only main -- .github/workflows scripts/dev_tools` exited 0 and listed exactly three paths — `plan_gate_commands.py`, `plan_gate_discrimination.py`, and `plan_gate_observability.py` — containing neither driver path and no added workflow file. Both throwaway drivers are absent from the working tree and from the branch diff, and no corpus sweep was added.
