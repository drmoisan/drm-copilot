# Cross-Runtime Parity Fixture Run

Timestamp: 2026-08-20T14-32
Task: [P10-T8]
Issue: #486

## Commands

Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py -q`

EXIT_CODE: 0

Command: `node run-jest.cjs test/lib/validate/plan-gate-parity.test.ts` (from `extensions/drm-copilot`)

EXIT_CODE: 0

## Fixtures Compared

Eight shared fixtures are declared with identical plan text and identical expected finding strings in both parity files:

| Fixture | Rule | Channel | Stub configuration |
| --- | --- | --- | --- |
| `PARITY_G1` | G1 | blocking | empty tracked tree |
| `PARITY_G2` | G2 | blocking | `scripts/dev_tools/foo.py` reported as a tracked file |
| `PARITY_G3` | G3 | warning | empty tracked tree |
| `PARITY_G4` | G4 | warning | empty tracked tree |
| `PARITY_G5` | G5 | `G5_SEVERITY` (warning) | empty tracked tree |
| `PARITY_G6` | G6 | warning | `pinned` matches `docs/design.md`, whose committed text wraps the literal |
| `PARITY_G1_APOSTROPHE` | G1 | blocking | empty tracked tree; `--cov` value carries a single-quote character |
| `PARITY_G5_APOSTROPHE` | G5 | `G5_SEVERITY` (warning) | empty tracked tree; literal carries a single-quote character |

Fixture declarations live in `tests/scripts/dev_tools/test_plan_gate_parity.py` and `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`.

## Direct Byte Comparison

Beyond the two independent assertion suites, the two runtimes were executed against the same eight fixtures and their emitted strings were diffed directly. The Python side ran `evaluate_plan_gates` under `poetry run python`; the TypeScript side ran `evaluatePlanGates` from the `npx tsc -p ./` emit under Node. Both dumps were serialised to JSON and compared field by field.

```
G5_SEVERITY py='warning' ts='warning' match=True
fixtures compared: 8 finding strings compared: 8 mismatches: 0
```

The throwaway comparison drivers were written to the session scratchpad only; no comparison script was added to the repository, and the `extensions/drm-copilot/out` emit directory (git-ignored) was removed after the comparison.

## Apostrophe Rendering

Both runtimes render an apostrophe-bearing value bare between backticks with no surrounding quote characters:

- `[P1-T1] --cov argument \`scripts/dan's_tools/foo.py\` names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dan's_tools.foo.`
- `[P1-T1] search literal \`the planner's cohort\` is absent from the tracked tree and is not quoted in the plan; the search returns zero matches whatever the executor does. Quote the exact literal the task will create, or assert a literal that exists.`

This is the class the repository's known `pythonRepr` quote-selection divergence would have broken. Neither runtime formats a value through `repr()`, `!r`, or a `pythonRepr` helper; `test_no_repr_formatting_in_gate_messages` asserts the Python module carries neither `!r` nor `repr(`, and `renders offending values without pythonRepr formatting` asserts no `pythonRepr(` call in any of the three TypeScript gate modules.

## Task-Pattern Parity

`test_extractor_task_pattern_matches_validator_pattern` asserts `PLAN_GATE_TASK_RE.pattern == PLAN_TASK_RE.pattern`, and `declares the same task pattern as the validator` asserts `PLAN_GATE_TASK_PATTERN.source === PLAN_TASK_RE.source`. Both pass, so neither extractor drifted from its validator's task-line contract despite declaring the pattern locally to avoid an import cycle.

Output Summary: Parity holds. 8 of 8 fixtures matched; 8 of 8 emitted finding strings were byte-identical across the two runtimes; `G5_SEVERITY` is `warning` in both. No string mismatch was found, so no remediation was required. Python parity suite: 4 passed, 0 failed, EXIT_CODE 0. TypeScript parity suite: 3 passed, 0 failed, EXIT_CODE 0.
