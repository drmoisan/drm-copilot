# Pre-Change Plan-Gate Output for the Fixed Parity Fixture Set — [P0-T13]

Timestamp: 2026-08-26T08-02
Task: [P0-T13]
Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6b0c3b38073271d8`
EXIT_CODE: 0

This artifact is the fixed reference the byte-identity assertion in [P4-T7] compares against. Its purpose is to record what G1 through G6 produce for the parity fixture set **before** G7, G8, G8b, and G9 exist, so that a new rule leaking onto the blocking channel is detectable.

## Test run

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6b0c3b38073271d8
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 4 items

tests\scripts\dev_tools\test_plan_gate_parity.py ....                    [100%]

============================== 4 passed in 0.09s ==============================
```

**4 passed, 0 failed.** The `0 failed` is established by the result line naming no failed count and by the exit code of 0 together.

## The eight expected strings, copied verbatim

Source: `tests/scripts/dev_tools/test_plan_gate_parity.py`, lines 71-114. Each is reproduced below exactly as the file declares it, including the implicit string concatenation across source lines.

### `_EXPECTED_G1` (line 71)

```
[P1-T1] --cov argument `scripts/dev_tools/foo.py` names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dev_tools.foo.
```

### `_EXPECTED_G2` (line 76)

```
[P1-T1] --cov argument `scripts/dev_tools/foo` names a tracked module file path; coverage.py accepts only directories or importable names. Use --cov=scripts.dev_tools.foo.
```

### `_EXPECTED_G3` (line 81)

```
[P1-T1] --cov argument `scripts/dev_tools/missing` contains a path separator but resolves to neither a tracked file nor a tracked directory; coverage may collect no data. Use the importable dotted form or a tracked directory.
```

### `_EXPECTED_G4` (line 87)

```
[P1-T1] --cov argument value `tests.foo` is supplied space-separated; the ambiguous form can bind the following positional argument. Use the --cov=<module> form.
```

### `_EXPECTED_G5` (line 92)

```
[P1-T1] search literal `pinned items occupy` is absent from the tracked tree and is not quoted in the plan; the search returns zero matches whatever the executor does. Quote the exact literal the task will create, or assert a literal that exists.
```

### `_EXPECTED_G6` (line 98)

```
[P1-T1] search literal `pinned items occupy` is present only across adjacent lines of a tracked file and matches no single line; a line-oriented search returns zero matches. Search a shorter single-line token.
```

### `_EXPECTED_G1_APOSTROPHE` (line 104)

```
[P1-T1] --cov argument `scripts/dan's_tools/foo.py` names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dan's_tools.foo.
```

### `_EXPECTED_G5_APOSTROPHE` (line 109)

```
[P1-T1] search literal `the planner's cohort` is absent from the tracked tree and is not quoted in the plan; the search returns zero matches whatever the executor does. Quote the exact literal the task will create, or assert a literal that exists.
```

## The two context-free blocking strings

Of the eight, exactly **two** are placed on the blocking channel when `evaluate_plan_gates` is called with no repository context:

1. **`_EXPECTED_G1`**
2. **`_EXPECTED_G1_APOSTROPHE`**

Both are G1 findings. G1 is the only Blocking rule that is context-free: it decides a `--cov` value from its text alone, because a `.py` suffix proves a filesystem path without any repository lookup. G2 is also Blocking but requires the repository seam to establish that the value plus `.py` is a tracked file, so with no context it does not run. G3, G5, and G6 likewise require the seam. G4 is context-free but ships on the warning channel, so it appears in warnings rather than in blocking.

### Verification, not assertion

The split above was measured rather than assumed. Each of the six parity fixtures was evaluated with no context and both channels printed:

```
$ poetry run python -c "import sys; sys.path.insert(0,'.'); import tests.scripts.dev_tools.test_plan_gate_parity as t; from scripts.dev_tools.plan_gate_discrimination import evaluate_plan_gates; [print('FIXTURE',n,'BLOCKING',evaluate_plan_gates(p).blocking,'WARNINGS',evaluate_plan_gates(p).warnings) for n,p in [('PARITY_G1',t.PARITY_G1),('PARITY_G2',t.PARITY_G2),('PARITY_G3',t.PARITY_G3),('PARITY_G4',t.PARITY_G4),('PARITY_G5',t.PARITY_G5),('PARITY_G6',t.PARITY_G6),('PARITY_G1_APOSTROPHE',t.PARITY_G1_APOSTROPHE),('PARITY_G5_APOSTROPHE',t.PARITY_G5_APOSTROPHE)]]"

FIXTURE PARITY_G1 BLOCKING ['[P1-T1] --cov argument `scripts/dev_tools/foo.py` names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dev_tools.foo.'] WARNINGS []
FIXTURE PARITY_G2 BLOCKING [] WARNINGS []
FIXTURE PARITY_G3 BLOCKING [] WARNINGS []
FIXTURE PARITY_G4 BLOCKING [] WARNINGS ['[P1-T1] --cov argument value `tests.foo` is supplied space-separated; the ambiguous form can bind the following positional argument. Use the --cov=<module> form.']
FIXTURE PARITY_G5 BLOCKING [] WARNINGS []
FIXTURE PARITY_G6 BLOCKING [] WARNINGS []
FIXTURE PARITY_G1_APOSTROPHE BLOCKING ["[P1-T1] --cov argument `scripts/dan's_tools/foo.py` names a filesystem path; coverage.py accepts only directories or importable names. Use --cov=scripts.dan's_tools.foo."] WARNINGS []
FIXTURE PARITY_G5_APOSTROPHE BLOCKING [] WARNINGS []
```

The measured result matches the plan's statement exactly: two fixtures produce a blocking finding, and the two strings are byte-identical to `_EXPECTED_G1` and `_EXPECTED_G1_APOSTROPHE` as declared in the test file. The four fixtures whose rule requires the repository seam — `PARITY_G2`, `PARITY_G3`, `PARITY_G5`, `PARITY_G6` — produce an **empty** blocking channel, which is the condition [P4-T7] additionally asserts.

The command was written as a single-line `-c` invocation. A multi-line `-c` is a silent no-op on this platform, exiting 0 having executed nothing, which would have made this verification read as a pass while measuring nothing.

## How [P4-T7] uses this artifact

[P4-T7] asserts that the blocking-channel strings produced across the six parity fixtures with no context are byte-identical to the two strings listed in this section. Because G7, G8, and G8b are context-free and will run unconditionally after Phase 2 and Phase 3, a defect that placed any of them on the blocking channel would add a third string and break that comparison. The empty blocking channel recorded for the four seam-requiring fixtures is the second half of the same guard.

## Output Summary

`poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py` reported **4 passed, 0 failed**, exit 0. All eight expected constants — `_EXPECTED_G1`, `_EXPECTED_G2`, `_EXPECTED_G3`, `_EXPECTED_G4`, `_EXPECTED_G5`, `_EXPECTED_G6`, `_EXPECTED_G1_APOSTROPHE`, and `_EXPECTED_G5_APOSTROPHE` — are reproduced verbatim above from lines 71-114 of the test file. Exactly two of them, `_EXPECTED_G1` and `_EXPECTED_G1_APOSTROPHE`, are placed on the blocking channel with no repository context supplied; this was measured by direct evaluation rather than asserted, and the four seam-requiring fixtures were confirmed to produce an empty blocking channel.
