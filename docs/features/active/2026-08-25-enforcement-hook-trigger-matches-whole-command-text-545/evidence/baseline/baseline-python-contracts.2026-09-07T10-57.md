# Phase 0 — Baseline Python Contract Suites

Timestamp: 2026-09-07T10-57

Task: [P0-T11]

Command:
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -p no:cacheprovider --no-header -q`

Supplementary commands (per-module runs, for the per-module counts):
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider --no-header -q`
`poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -p no:cacheprovider --no-header -q`
`poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -p no:cacheprovider --no-header -q`

EXIT_CODE: 0

Every exit code below was captured without a pipe, so it is the pytest process's own status and not
a downstream filter's.

## No coverage argument, and why

No `--cov` argument is used. This change adds and modifies no Python production file, so there is no
Python changed-code denominator and no Python coverage gate has a subject here. The Python obligation
for this change is that these three modules pass.

## `.claude/state/` observation, taken immediately before the run

```
$ ls -la .claude/state/
total 4
drwxr-xr-x 1 DanMoisan 197121 0 Sep  7 06:51 ./
drwxr-xr-x 1 DanMoisan 197121 0 Sep  7 06:51 ../

$ find .claude/state
.claude/state
```

**`.claude/state/` EXISTS in this checkout and is EMPTY.** The recursive `find` returns the directory
itself and no entry beneath it: zero files, zero subdirectories.

This differs from the plan preamble, which records the directory as absent at authoring time. The
observation above is taken at execution time and supersedes the authoring-time note for this
execution. The plan anticipates both states and requires the executor to record what it observes.

The consequence for `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is that the
case **passes** at baseline, and the mechanism is now observed rather than assumed: that test
enumerates the repository `.claude` tree from the filesystem and excludes only
`.claude/settings.local.json` and `.claude/agent-memory/**`, so an empty `.claude/state/` contributes
no file to the enumeration and therefore no unmirrored path. The case will start failing once the
batch-budget hook writes `powershell-batch-budget.<session_id>.json` into that directory, which
happens on the first `Write` or `Edit` of a `.ps1`, `.psm1`, or `.psd1` file — that is [P1-T2]. The
failure is open issue #510 and is not caused by this change.

## Per-module results

| Module | Passed | Failed | Exit code |
| --- | --- | --- | --- |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | **11** | **0** | 0 |
| `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | **1** | **0** | 0 |
| `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` | **10** | **0** | 0 |
| Combined run | **22** | **0** | 0 |

Per-module summary lines, verbatim:

```
11 passed in 0.19s
1 passed in 0.05s
10 passed in 0.06s
```

Combined-run summary line, verbatim:

```
22 passed in 0.28s
```

11 + 1 + 10 = 22, so the per-module counts reconcile with the combined run.

## Baseline dispositions carried forward

- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` **passes** at baseline, with
  `.claude/state/` present and empty. Any later failure of this case must be checked against the
  contents of `.claude/state/` before it is attributed to this change.
- `test_poshqc_bundled_parity.py` holds a single case and it passes, consistent with the [P0-T8]
  finding that the two `pester.runsettings.psd1` copies are textually identical at baseline.
- `test_parallel_abandon_token_seam.py` passes with 10 cases; it parses both
  `enforce-parallel-abandon-gate.ps1` and `scripts/dev_tools/parallel_mutation_abandon_cli.py` at run
  time, so it is the constraint that pins both token literals to their single-assignment form.

Output Summary: All three Python contract modules pass at baseline with exit code 0.
`test_push_down_claude_resource_contracts.py` 11 passed / 0 failed;
`test_poshqc_bundled_parity.py` 1 passed / 0 failed; `test_parallel_abandon_token_seam.py` 10 passed
/ 0 failed; combined 22 passed / 0 failed. `.claude/state/` was observed immediately before the run:
it **exists and is empty**, which is why
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes at baseline.
