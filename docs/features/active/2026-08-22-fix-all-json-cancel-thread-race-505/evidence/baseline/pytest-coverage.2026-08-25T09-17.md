# Baseline — Pytest with Repository-Wide Coverage

- **Task:** [P0-T10]
- **Issue:** #505

Timestamp: 2026-08-25T09-17

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`

EXIT_CODE: 1

## Test Counts

| Outcome | Count |
| --- | --- |
| passed | 4116 |
| failed | 1 |
| skipped | 5 |

Terminal summary line: `1 failed, 4116 passed, 5 skipped in 27.19s`

## Coverage (read from `artifacts/python/coverage.json`, key `totals`)

| Metric | JSON key | Baseline value (percent) |
| --- | --- | --- |
| Repository line coverage | `totals.percent_statements_covered` | **92.6086956521739** |
| Repository branch coverage | `totals.percent_branches_covered` | **85.19664967225054** |

Supporting raw counters from the same `totals` object: `num_statements` 14950, `missing_lines`
1105, `num_branches` 5492, `num_partial_branches` 559.

The terminal `TOTAL` row's `Cover` column reads `91%`. That figure is **not** recorded as either
coverage percentage. It is the rounded value of `totals.percent_covered` (90.61735642305058), which
is the combined statements-plus-branches ratio, and the plan's Toolchain section explicitly forbids
deriving either headline figure from it. Both figures above come from the two named JSON keys.

Both baseline figures clear the uniform thresholds in `.claude/rules/quality-tiers.md`: line
coverage 92.61 >= 85, branch coverage 85.20 >= 75.

## Pre-Existing Failure (present at baseline, unrelated to this change)

One test fails on the unmodified tree at commit `d5e3a462f51c1dd1612b4f2009aaea4552a35ec7`:

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
E   AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
```

The failure asserts that a repository runtime-contract file
(`.claude/state/python-batch-budget.default.json`) is absent from the bundled push-down payload
under `extensions/drm-copilot/resources/`. It is a push-down payload-parity defect. It touches no
file in this change's write set, no file in its read-only set, and no `fix_all` module. It is
recorded here as the baseline state so the Phase 6 final QC comparison is made against a known
starting point rather than against an assumed-green tree.

**Consequence for Phase 6, recorded now and not actioned here:** [P6-T4] requires `EXIT_CODE: 0` and
zero failures from the same command. That acceptance condition cannot be met while this pre-existing
failure persists, and the failure is outside this fix's scope. The condition is flagged for the
Phase 6 executor rather than resolved in Phase 0. Phases 0 through 3 are the scope of this
execution; no attempt is made here to repair the push-down payload.

Output Summary: Baseline pytest run over the full suite: **4116 passed, 1 failed, 5 skipped**, exit
code 1. Repository-wide **line coverage 92.6086956521739 percent**
(`totals.percent_statements_covered`) and **branch coverage 85.19664967225054 percent**
(`totals.percent_branches_covered`), both read from `artifacts/python/coverage.json` and both above
the 85 and 75 thresholds. The single failure,
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, is pre-existing on the unmodified
tree, is a push-down bundled-payload parity defect concerning
`.claude/state/python-batch-budget.default.json`, and is unrelated to the `fix_all` cancel-race fix.
The five skips are pre-existing parametrized parity cases in
`test_parallel_manifest_bash_parity.py` that declare no accessor expectation.

**See the CORRECTION section below.** The attribution in the preceding paragraph and in the
"Pre-Existing Failure" section is superseded. The observed failure was real, but it was not a defect
in `main`.

---

## CORRECTION — appended 2026-08-25T09-53 (attribution of the observed failure was wrong)

Timestamp: 2026-08-25T09-53

The observed failure recorded above is retained verbatim and is **not** rewritten: the run genuinely
produced it. What was wrong is the **attribution**. The failure was not a pre-existing push-down
payload-parity defect in `main`. It was caused by gitignored, untracked local state written by this
agent session's own PreToolUse hook.

### Corrected attribution (verified)

1. **The named path is gitignored and untracked.** `.claude/state/` is ignored at `.gitignore` line
   68. `git check-ignore -v .claude/state/python-batch-budget.default.json` reports
   `.gitignore:68:.claude/state/`, exit code 0. `git ls-files .claude/state/` returns no output, so
   the file was never tracked and has no git history.
2. **It was written by this session, not by any commit.** The file was produced by this session's
   `enforce-python-batch-budget` PreToolUse hook (observed mtime 2026-08-25 09:40, during the
   Phases 0-3 run), after the baseline command above was executed.
3. **The test enumerates the filesystem, not the git index.** `test_push_down_claude_resource_contracts.py`
   walks `.claude` on disk, so **any** gitignored local file under `.claude/` fails it. A clean
   checkout — including CI, which never runs this repository's PreToolUse hooks — does not have the
   file and therefore does not see this failure.
4. **Verified by removing the local file and rerunning.** Command:
   `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`.
   Result: `10 passed in 0.14s`, EXIT_CODE 0. The whole module passes.

### Consequence for Phase 6 (supersedes the paragraph above)

The "Consequence for Phase 6" paragraph above is **withdrawn**. The full suite is **not** blocked by
a defect in `main`, and [P6-T4]'s `EXIT_CODE: 0` / zero-failures acceptance condition **is
achievable**. The operational requirement is only that the gitignored local file
`.claude/state/python-batch-budget.default.json` be deleted before a full-suite run if the hook has
recreated it. Deleting it is safe: it is untracked, gitignored, hook-regenerated local state. It must
**not** be added to the repository, and neither the test nor `.gitignore` may be modified to
accommodate it.

### Out-of-scope observation (recorded, not actioned)

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
enumerates `.claude` files from the **filesystem** rather than from the set of git-tracked files.
That makes it sensitive to any gitignored local file placed under `.claude/`, so locally generated
hook state produces a failure that is not reproducible in a clean checkout or in CI. This is recorded
as an observation only. It is outside the scope of issue #505 and is not actioned by this change.
