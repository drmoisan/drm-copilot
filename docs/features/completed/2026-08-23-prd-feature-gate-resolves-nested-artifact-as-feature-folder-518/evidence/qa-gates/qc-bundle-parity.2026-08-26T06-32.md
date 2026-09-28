# Final QC Step 4, Bundle Parity — [P4-T4]

Timestamp: 2026-08-26T06-32

Task: [P4-T4]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`
Position in the consecutive pass: step 4 of 4, run immediately after [P4-T3] with no file edited
between them.

Command:

```text
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
```

EXIT_CODE: 0

Raw output:

```text
..........                                                               [100%]
10 passed in 0.10s
```

## Counts

| Metric | Value |
| --- | --- |
| Collected | 10 |
| **Passed** | **10** |
| **Failed** | **0** |
| Errors | 0 |
| Skipped | 0 |
| Wall time | 0.10 s |

Zero failures, which is the condition [P4-T4] states. The test file was executed unmodified; it is not
in the declared write set and was not edited by this plan.

The test that directly gates this change is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which compares UTF-8 text for every
file under `.claude/**` between the repository and the bundled payload. It passing confirms that
`.claude/hooks/enforce-prd-feature-before-planner.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
are textually identical after the [P2-T7] mirror copy. That identity was independently confirmed at
[P2-T7] by comparing file hashes, and the two copies report identical line counts in [P2-T8].

## Comparison Against the [P0-T6] Baseline, and the Environmental Failure That Was Cleared

| Run | EXIT_CODE | Passed | Failed |
| --- | --- | --- | --- |
| [P0-T6] baseline | 1 | 9 | 1 |
| [P4-T4] final QC | **0** | **10** | **0** |

The baseline was **not** green. [P0-T6] recorded 9 passed and 1 failed with
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` asserting
`Repo file missing from bundle: .claude\state\powershell-batch-budget.default.json`, and its artifact
explicitly escalated that both [P2-T7] and [P4-T4] state acceptance conditions that were not
satisfiable in that working tree regardless of what this plan changed.

The cause was environmental, not a parity regression. The test's repo-side enumeration
`list_scoped_files(REPO_ROOT)` walks the filesystem rather than the git index, and `.claude/state/` is
gitignored at `.gitignore` line 68 with no counterpart in the bundle, so a local runtime state file
written by the toolchain entered the comparison set and was reported as missing from the bundle. Its
exclusion list covers `.claude/settings.local.json` and `.claude/agent-memory/**` but not
`.claude/state/**`.

The disposition taken during [P2-T7] was to delete the two untracked, gitignored state files
`.claude/state/powershell-batch-budget.default.json` and `.claude/state/python-batch-budget.default.json`.
Both are regenerable local tool state. Deleting them changed no committed content and produced no
diff, as [P3-T5] verified, and it restored the condition the test expects. The state directory was
confirmed empty immediately before this run and immediately after it, so no toolchain step in the
consecutive pass recreated either file.

The improvement from 9 passed to 10 passed is therefore attributable to clearing that environmental
condition, while the parity assertion itself is satisfied by the [P2-T7] mirror copy.

Output Summary: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
exited 0 as step 4 of the final QC consecutive pass, with 10 passed and 0 failed out of 10 collected in
0.10 seconds. The test file was run unmodified. `test_bundled_claude_payload_contains_all_repo_runtime_contracts`
passes, confirming the self-hosted hook and its bundled mirror are textually identical. The [P0-T6]
baseline was 9 passed and 1 failed because two untracked, gitignored `.claude/state/*.json` runtime
files entered the test's filesystem-based comparison set; those were removed during [P2-T7], the state
directory was confirmed empty before and after this run, and the suite is now fully green. No file was
edited between [P4-T3] and this run.
