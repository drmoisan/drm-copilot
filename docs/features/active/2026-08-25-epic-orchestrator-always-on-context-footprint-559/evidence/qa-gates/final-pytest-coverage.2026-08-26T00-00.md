# Final QA — Pytest with Coverage (Issue #559)

Timestamp: 2026-08-26T00-47
Task: [P6-T4] — stage 4 of the Phase 6 QA loop (test), run on the **EXCEPTION branch**

## Command:

```
poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

The coverage argument uses the importable dotted form with `=`, per rules G1 through G4 of
`.claude/rules/plan-acceptance-gates.md`. It is byte-identical to the `[P0-T6]` baseline command,
so the before and after figures compare like against like.

EXIT_CODE: 1

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

## Branch selection — why a non-zero exit code is the accepted outcome here

`[P6-T4]` is a two-branch task. The branch is selected by the verdict recorded at `[P0-T11]` in
`docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md`.

That artifact carries two readings, both preserved:

| Reading | Timestamp | Verdict | Status |
|---|---|---|---|
| Original `Known Baseline Failure:` block | 2026-08-25T23-44 | `ABSENT` | Accurate when taken; superseded |
| `Superseding Observation:` block | 2026-08-26T00-19 | **`PRESENT`** | **OPERATIVE** |

The operative verdict is **PRESENT**. The original `ABSENT` reading was a true observation of a
transient pre-hook condition: Phase 0 performed no Write or Edit, so the repository's own
`Write|Edit` PreToolUse hook `.claude/hooks/enforce-python-batch-budget.ps1` had not yet fired and
had not yet created its state file. The file's own birth timestamp (2026-08-25 23:48:01) falls in
Phase 1, eight minutes after the baseline reading.

Because the operative verdict is `PRESENT`, the **exception branch** of `[P6-T4]` applies: exactly
one failure is permitted, and only if that failure is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Any second failure fails the
task. The strict `EXIT_CODE: 0` branch does not apply.

## The single tolerated failure — named explicitly

Exactly one test failed. It is named here in full rather than reported only as a count, because
`[P6-T4]` states that a summary reporting a non-zero failure count without naming the failing test
does not satisfy the task.

| Field | Value |
|---|---|
| Test function | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` |
| Module | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` |
| Full node ID | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` |
| Assertion site | `tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120` |
| Tolerated | Yes — this is the exact test the exception branch permits |

Failure text as emitted:

```
>           assert (
E           AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
E           assert WindowsPath('.claude/state/python-batch-budget.default.json') in [WindowsPath('.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md'), ...]

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
```

Short-summary line:

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

The failure names `.claude/state/python-batch-budget.default.json`, which is precisely the untracked
path the `[P0-T11]` superseding observation predicted it would name.

### Cause, and why it is out of scope

`list_scoped_files` enumerates the filesystem rather than consulting git. A gitignored, untracked,
machine-local state file therefore enters the repo-side set and has no bundled counterpart, so the
byte-identity contract reports it as missing from the bundle. The file is written by this
repository's own PreToolUse hook and is ignored by `.gitignore` line 68 (`.claude/state/`).

This defect is **out of scope** for issue #559. No task in this plan fixes it. No gitignored file
was created, deleted, moved, or otherwise mutated to obtain this result — deleting the file is
rejected as a remedy per extraction note 4 of the plan, both because it mutates the developer's
environment outside this change's scope and because the registered hook regenerates it on the next
Write or Edit regardless. It is recorded as a follow-up observation by `[P6-T14]`.

## No second failure

The exception branch is satisfied only if there is no second failure. Verified:

| Metric | Value |
|---|---|
| Total failures | 1 |
| Failures that are the tolerated test | 1 |
| Failures other than the tolerated test | **0** |
| Errors | 0 |
| Collection errors | 0 |

The `short test summary info` section contains exactly one `FAILED` line and zero `ERROR` lines.

## Numeric test results

Final pytest summary line:

```
================= 1 failed, 4150 passed, 5 skipped in 11.04s ==================
```

| Metric | Baseline (`[P0-T6]`) | Post-change (`[P6-T4]`) | Delta |
|---|---|---|---|
| Passed | 4136 | 4150 | +14 |
| Failed | 0 | 1 | +1 (the tolerated failure) |
| Errors | 0 | 0 | 0 |
| Skipped | 5 | 5 | 0 |
| Total collected | 4141 | 4156 | +15 |
| Wall time | 14.62 s | 11.04 s | — |

The collected-test count rises by exactly 15, which reconciles exactly against the two test files
this change adds: 8 tests in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` plus 7 tests
in `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`. All 15 pass. The one
failure is a test that passed at baseline only because the state file did not yet exist on disk, so
`4136 + 15 = 4151` collected of which one now fails, leaving 4150 passed.

The five skips are unchanged and are the pre-existing parametrized fixture skips in
`tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231`, unrelated to this change.

## Numeric coverage headline — `scripts.dev_tools`

A numeric coverage headline is mandatory on both branches of `[P6-T4]`. Reported TOTAL row:

```
TOTAL                                                               15014   1104    93%
```

| Metric | Baseline (`[P0-T6]`) | Post-change (`[P6-T4]`) | Delta |
|---|---|---|---|
| Measured modules | 181 | 181 | 0 |
| Statements | 15014 | 15014 | 0 |
| Missed statements | 1104 | 1104 | 0 |
| Covered statements | 13910 | 13910 | 0 |
| Total line coverage (as reported) | 93% | **93%** | 0 |
| Total line coverage (exact, 13910 / 15014) | 92.65% | **92.65%** | **+0.00 pp** |
| Uniform policy floor (line) | 85% | 85% | — |
| Margin above floor | +7.65 pp | +7.65 pp | 0 |

Coverage is unchanged to the statement. The signed delta is **+0.00 percentage points**, which is
the expected result and is analysed in full at `[P6-T6]`: this change writes no file under `src` or
`scripts/dev_tools`, and `pyproject.toml` sets the coverage source to exactly those two roots, so
neither the numerator nor the denominator can move.

Branch coverage was not requested by this task's command and is therefore not measured here, exactly
as at baseline. Coverage LCOV was written to `artifacts/python/lcov.info` by the repository's
standing coverage configuration; that path is a tooling output of the existing pytest configuration,
not an evidence artifact of this plan, and it is not under any forbidden evidence path.

## Loop control

| Property | Value |
|---|---|
| Loop iteration | 1 |
| Files changed by this stage | 0 |
| Restart triggered | No |

No change was made in response to this run — the sole failure is the out-of-scope environmental
failure the exception branch exists to tolerate, and fixing it is explicitly excluded — so the
`[P6-T4]` restart condition was not met and the loop proceeds to `[P6-T5]`.

Output Summary: PASS on the EXCEPTION branch. `poetry run pytest --cov=scripts.dev_tools
--cov-report=term-missing` exited 1 on loop iteration 1 with 1 failed, 4150 passed, 0 errors, 5
skipped. The single failure is
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
named explicitly and tolerated under the operative `PRESENT` verdict of `[P0-T11]` recorded in
`evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md`; it names the untracked, gitignored
path `.claude/state/python-batch-budget.default.json` and is out of scope. There is no second
failure and no error. Total line coverage for `scripts.dev_tools` is 93% as reported (92.65% exact:
13910 of 15014 statements), identical to baseline for a signed delta of +0.00 percentage points, and
7.65 percentage points above the uniform 85% line floor.
