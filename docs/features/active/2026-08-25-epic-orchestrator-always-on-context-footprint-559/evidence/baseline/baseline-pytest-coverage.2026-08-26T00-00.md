# Baseline — Pytest with Coverage (Issue #559)

Timestamp: 2026-08-25T23-40
Task: [P0-T6] (with a `Known Baseline Failure:` block appended by [P0-T11])

## Command:

```
poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

The coverage argument uses the importable dotted form with `=`, per rules G1 through G4 of
`.claude/rules/plan-acceptance-gates.md`. Data collection is confirmed non-empty: the term
report lists 181 measured `scripts/dev_tools` modules and a non-zero statement count.

EXIT_CODE: 0

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

## Session Header

```
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3
configfile: pyproject.toml
testpaths: tests
plugins: anyio-4.12.1, cov-7.0.0
```

## Numeric Test Results

| Metric | Baseline value |
|---|---|
| Passed | 4136 |
| Failed | 0 |
| Errors | 0 |
| Skipped | 5 |
| Exit code | 0 |
| Wall time | 14.62 s |

Final pytest summary line:

```
====================== 4136 passed, 5 skipped in 14.62s =======================
```

The five skips are all in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231`
and are pre-existing parametrized skips for manifest M1 fixtures that declare no accessor
expectation:

```
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
```

## Numeric Coverage Results — `scripts.dev_tools`

Reported TOTAL row:

```
TOTAL                                                               15014   1104    93%
```

| Metric | Baseline value |
|---|---|
| Measured modules | 181 |
| Statements | 15014 |
| Missed statements | 1104 |
| Covered statements | 13910 |
| Total line coverage (as reported) | 93% |
| Total line coverage (exact, 13910 / 15014) | 92.65% |
| Uniform policy floor (line) | 85% |
| Margin above floor | +7.65 percentage points |

Branch coverage was not requested by this task's command and is therefore not measured in this
artifact. The command as stated in the approved plan carries `--cov-report=term-missing` without
`--cov-branch`; the plan's own final-QA coverage-delta task is where the post-change comparison
against this baseline is made, and it compares like against like.

Coverage LCOV was additionally written to `artifacts/python/lcov.info` by the repository's
standing coverage configuration. That path is a tooling output of the existing pytest
configuration, not an evidence artifact written by this plan, and it is not under
`artifacts/baseline/`, `artifacts/qa/`, or any other forbidden evidence path.

Output Summary: PASS. `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing`
exited 0 at baseline with 4136 passed, 0 failed, 0 errors, and 5 skipped. Total line coverage
for `scripts.dev_tools` is 93% as reported (92.65% exact: 13910 of 15014 statements), which is
7.65 percentage points above the uniform 85% line floor. The five skips are pre-existing
parametrized fixture skips unrelated to this change.

---

## Known Baseline Failure:

Task: [P0-T11]
Timestamp: 2026-08-25T23-44

### Command:

```
poetry run pytest
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 0

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

### (a) Verdict

ABSENT

The test `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, did **not** fail at
baseline on this worktree. It was collected and it passed.

The verdict was confirmed a second time by running the single node directly rather than
inferring it from the absence of a failure line in the full-suite output:

```
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" -v
-> EXIT=0

tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED [100%]
============================== 1 passed in 0.08s ==============================
```

### (b) Untracked repository path named by the failure

Not applicable. The verdict in (a) is `ABSENT`, so the failure named no path. Field (b) of this
block is required by `[P0-T11]` only when (a) is `PRESENT`.

The path the execution directive anticipated, `.claude/state/python-batch-budget.default.json`,
was checked directly against this worktree and does not exist here:

```
ls -la .claude/state/python-batch-budget.default.json
ls: cannot access '.claude/state/python-batch-budget.default.json': No such file or directory
-> LS_EXIT=2
```

That absence is the reason
the anticipated failure did not reproduce: the defect the directive describes — that
`list_scoped_files` enumerates the filesystem rather than consulting git, so a gitignored,
untracked, machine-local state file enters the repo-side set with no bundled counterpart —
requires such a file to be present on disk. No file matching that description exists in this
worktree, so the repo-side set and the bundled set agree and the byte-identity contract holds.

Per `[P0-T11]`, that defect is out of scope. No task in this plan fixes it. No gitignored file
was created, deleted, moved, or otherwise mutated by this task; the verdict was established by
running the suite and by a read-only existence check.

### (c) Full baseline pass, fail, and skip counts

Final pytest summary line:

```
======================= 4136 passed, 5 skipped in 5.28s =======================
```

| Metric | Baseline value |
|---|---|
| Passed | 4136 |
| Failed | 0 |
| Errors | 0 |
| Skipped | 5 |
| Exit code | 0 |
| Wall time | 5.28 s |

The counts are identical to the `[P0-T6]` coverage-enabled run above, which is the expected
result: the two commands differ only in coverage instrumentation and select the same test set.
Only the wall time differs (5.28 s uninstrumented against 14.62 s instrumented), which is the
expected cost of coverage tracing and carries no signal about test outcomes.

### Consequence for [P2-T13]

`[P2-T13]` branches on this verdict. Because this artifact records `ABSENT`, the strict branch
applies at `[P2-T13]`: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
must exit 0 with no exception permitted. The one-permitted-failure branch is not available.

Output Summary: ABSENT. The anticipated bundled-payload failure
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` did not reproduce on this
worktree; `poetry run pytest` exited 0 with 4136 passed, 0 failed, 5 skipped. The untracked
file `.claude/state/python-batch-budget.default.json` that would trigger it does not exist here.
The strict branch of `[P2-T13]` therefore applies.

---

## Superseding Observation:

Timestamp: 2026-08-26T00-19

**The `Known Baseline Failure:` block above is preserved verbatim and is not rewritten.** Its
`ABSENT` verdict was accurate at the moment it was taken (2026-08-25T23-44). It is superseded
here because it was not the steady state of this worktree, and the divergence is explained by
evidence rather than asserted.

### What was observed

`.claude/state/python-batch-budget.default.json` **exists in this worktree now**:

```
stat -c '%n size=%s birth=%w mtime=%y' .claude/state/python-batch-budget.default.json
-> STAT_EXIT=0

.claude/state/python-batch-budget.default.json size=380 birth=2026-08-25 23:48:01.431378200 -0400 mtime=2026-08-25 23:49:13.851072500 -0400
```

| Property | Observed value |
|---|---|
| Size | 380 bytes |
| Created | 2026-08-25 23:48:01 -0400 |
| Last modified | 2026-08-25 23:49:13 -0400 |

### Git status of the file — gitignored and untracked

```
git ls-files --error-unmatch .claude/state/python-batch-budget.default.json
-> TRACKED_EXIT=1        (not tracked)

git check-ignore -v .claude/state/python-batch-budget.default.json
-> IGNORE_EXIT=0
.gitignore:68:.claude/state/	.claude/state/python-batch-budget.default.json
```

The ignoring rule is `.gitignore` line 68, `.claude/state/`, which ignores the whole directory.

### The writer is this repository's own PreToolUse hook

The file is written by `.claude/hooks/enforce-python-batch-budget.ps1`, which composes the path
at its line 190:

```
$stateFile = Join-Path -Path $stateDir -ChildPath ("python-batch-budget.$SessionId.json")
```

That hook is registered in `.claude/settings.json` under the `"matcher": "Write|Edit"` PreToolUse
block (settings line 128 for the matcher, line 136 for the hook command). It therefore fires on
the **first Write or Edit any agent performs** in a fresh worktree, and creates the file as a
side effect.

### Why the original reading was unrepresentative

The `[P0-T11]` baseline ran at approximately 23:40, during Phase 0, which is a read-and-measure
phase that performs no source Write or Edit. No `Write|Edit` PreToolUse hook had yet fired in
this worktree, so the state file had not yet been created. The file's own birth timestamp,
23:48:01, falls in Phase 1 — the first phase that authors files — and is eight minutes after the
baseline reading. The `ABSENT` verdict was thus a true observation of a transient pre-hook
condition, not of the worktree's steady state. Any phase from Phase 1 onward runs with the file
present.

This matches the defect `[P0-T11]` itself describes: `list_scoped_files` enumerates the
filesystem rather than consulting git, so a gitignored, untracked, machine-local state file
enters the repo-side set and has no bundled counterpart.

### Scope — nothing was mutated

No gitignored file was created, deleted, moved, or otherwise mutated to produce this observation.
It was established by `stat`, `git ls-files`, `git check-ignore`, and by reading the hook and
settings files. Deleting the file is **rejected** as a remedy, per extraction note 4 of the plan:
it is a mutation of the developer's environment outside this change's scope, and the registered
hook regenerates it on the next Write or Edit regardless. The underlying `list_scoped_files`
defect remains out of scope for this plan.

### OPERATIVE VERDICT

The operative verdict for downstream branch selection is **PRESENT**.

This supersedes the `### Consequence for [P2-T13]` subsection of the preserved block above, which
concluded that the strict branch applied. It does not apply. The **exception branch** applies,
under which exactly one failure is permitted and only if that failure is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`; any second failure fails the
task outright.

The three tasks this verdict governs are:

| Task | Effect of the PRESENT verdict |
|---|---|
| `[P2-T13]` | Exception branch: exactly one tolerated failure, named above, and no other. |
| `[P3-T18]` | Exception branch: same single tolerated failure. Every test in `test_epic_run_kickoff_discovery_contract.py` must still pass, including `test_discovery_fix_is_mirrored_into_bundled_payload`. |
| `[P6-T4]` | Exception branch on the same terms. |

Both readings remain legible above: the original `ABSENT` observation with its own timestamp, and
this `PRESENT` correction with its own. A later auditor can reconstruct why the two differ.

Output Summary: SUPERSEDED to PRESENT. `.claude/state/python-batch-budget.default.json` (380
bytes, created 2026-08-25T23:48:01) exists in this worktree, is untracked, and is gitignored by
`.gitignore:68`. It is written by the repository's own `Write|Edit` PreToolUse hook
`.claude/hooks/enforce-python-batch-budget.ps1` registered in `.claude/settings.json`, so it
regenerates as soon as any agent performs a Write or Edit. The Phase 0 baseline at ~23:40 preceded
any such hook firing, which is why it correctly read the file as absent. The operative verdict for
`[P2-T13]`, `[P3-T18]`, and `[P6-T4]` is PRESENT, selecting the one-tolerated-failure exception
branch in each.
