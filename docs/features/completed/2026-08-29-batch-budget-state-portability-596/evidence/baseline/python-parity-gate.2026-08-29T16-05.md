# [P0-T17] Python push-down parity gate baseline

Timestamp: 2026-08-29T20-55

Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`

EXIT_CODE: 0

Output Summary: The parity-gate node **passed** at baseline with exit code 0 (`1 passed in 0.12s`).
The known issue #510 failure did **not** occur in this worktree, because `.claude/state/` does not
exist here: the worktree is freshly created and the batch-budget hooks have not yet run in it. That
is exactly the condition `spec.md:753-754` describes as the state a fresh checkout and CI are in.
Because the observed exit code is 0, no `ExpectedExitCode:` is recorded (an absent expectation
defaults to 0) and there is no assertion message to quote.

## Verbatim output

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 1 item

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .    [100%]

============================== 1 passed in 0.12s ==============================
```

## Why the expected #510 failure did not appear

The plan's stated expectation for this baseline was a failure naming a file under `.claude/state/`.
That failure did not occur. The mechanism is understood and is recorded here rather than treated as
an anomaly.

`list_scoped_files` (lines 34 through 43 of the test file) enumerates with `rglob("*")` against the
filesystem rather than the git index and applies no ignore filter, so a git-ignored runtime state
file under `.claude/state/` is enumerated as a repository runtime file and has no bundle mirror,
which produces the #510 failure. The failure therefore requires `.claude/state/` to exist.

Corroborating observation, taken immediately after the pytest run:

Command: `pwsh -NoProfile -Command "Test-Path -LiteralPath '.claude/state'"`

```
False
```

`.claude/state/` is absent in this worktree, so the enumeration finds no ignored state file and the
node passes. `.claude/state/` is gitignored (`.gitignore:68`) and `git worktree add` does not create
it; the [P0-T5] porcelain capture likewise shows no `.claude/state/` entry. See [P0-T18] for the full
state-directory inventory.

## Status of issue #510

Issue #510 remains open and out of scope. No task in this plan edits
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. The condition is latent rather
than absent: it will surface in this worktree as soon as a `Write` or `Edit` on a `.ps1` or `.py`
file triggers the batch-budget PreToolUse hook, which recreates `.claude/state/`. That is precisely
why [P6-T5] removes the directory before re-running this same node, and why [P7-T13] re-verifies its
absence after the QA loop converges.

Should the failure appear at [P6-T5] or [P7-T13] despite the removal, it is pre-existing and
unrelated to this feature, as `spec.md:756-758` records under Non-Goals.

## Baseline value for later comparison

Baseline result: **pass**, exit code 0, `1 passed`. [P6-T5] asserts the same node exits 0 and quotes
`1 passed`, so the after-state gate matches this baseline rather than inverting it.
