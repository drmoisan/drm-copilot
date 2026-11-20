# Shipped Gate Run Against This Plan Document

Timestamp: 2026-08-20T13-42
Task: [P12-T12]
Issue: #486
Working directory: worktree root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a61259d5432e08b89`

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md --workspace-root .`

EXIT_CODE: 0

## Full stderr text (verbatim, 2 lines)

```
PLAN GATE WARNING: [P2-T2] --cov argument value `tests/foo` is supplied space-separated; the ambiguous form can bind the following positional argument. Use the --cov=<module> form.
PLAN GATE WARNING: [P2-T2] --cov argument `tests/foo` contains a path separator but resolves to neither a tracked file nor a tracked directory; coverage may collect no data. Use the importable dotted form or a tracked directory.
```

## Full stdout text (verbatim, 1 line)

```
plan validation passed: docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md
```

Output Summary:

- Exit code 0. Zero blocking findings were emitted against this plan. The gate emitted exactly two `PLAN GATE WARNING: ` lines on stderr, both attributed to `[P2-T2]`, and the pre-existing success summary line on stdout unchanged.
- Warning count: 2. Every warning carries an explicit disposition below.

## Warning dispositions

### Warning 1

`PLAN GATE WARNING: [P2-T2] --cov argument value `tests/foo` is supplied space-separated; the ambiguous form can bind the following positional argument. Use the --cov=<module> form.`

Disposition: ACCEPTED AS A CORRECT DETECTION OF DOCUMENTED EXAMPLE TEXT — no plan change, no gate change.

Rationale: the flagged token comes from the Acceptance line of `[P2-T2]`, which reads in part `[("tests/foo", True)] for --cov tests/foo`. `[P2-T2]` is the task that implements `_cov_values`, and its acceptance criterion has to state the expected return value for the space-separated form in order to be checkable at all. The literal `--cov tests/foo` is therefore the deliberate negative example the helper is specified to recognise, not a command the plan intends anyone to run. The gate read the literal exactly as written and reported the exact shape it is designed to report; the finding is true of the text and carries no defect. G1 ships as a Warning rather than Blocking precisely so a plan that must quote a bad command form as an illustrative example is not prevented from validating. Suppressing the finding by rewording the acceptance line would remove the specification of the space-separated case, which would weaken the plan.

### Warning 2

`PLAN GATE WARNING: [P2-T2] --cov argument `tests/foo` contains a path separator but resolves to neither a tracked file nor a tracked directory; coverage may collect no data. Use the importable dotted form or a tracked directory.`

Disposition: ACCEPTED AS A CORRECT DETECTION OF DOCUMENTED EXAMPLE TEXT — no plan change, no gate change.

Rationale: the same `[P2-T2]` acceptance-line literal, evaluated by the second (repository-resolution) rule. `tests/foo` is an intentionally fictitious path: no such file or directory exists in the repository, which is exactly what makes it a safe illustrative value. The gate resolved it against the tracked file set, found no match, and reported it. As with Warning 1 the finding is true of the text, describes example text rather than an executable step, and is Warning severity by design.

## Blocking-finding check

No blocking finding was emitted. The gate exited 0 and the plan's own structural validation passed, so the plan document satisfies the gate that this feature ships. Both warnings land on the single plan task whose subject matter is the malformed `--cov` shapes themselves, which is the expected self-referential result and not a defect in either the gate or the plan.

## Confirmation re-run after the final plan check-offs

Timestamp: 2026-08-20T13-56

The same command was re-issued after the Phase 12 check-offs were written to the plan document, to confirm that flipping task checkboxes from `- [ ]` to `- [x]` does not change the gate result. Exit code 0 again; the same two `[P2-T2]` warnings on stderr and the same success line on stdout, byte-identical to the run recorded above.
