# Bundle-Parity Baseline — [P0-T6]

Timestamp: 2026-08-26T05-30

Task: [P0-T6]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`
Tree state: unmodified with respect to the declared write set. No production or test file had been
edited at the time of this run.

Command:

```text
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
```

EXIT_CODE: 1

## Baseline Counts

| Metric | Baseline value |
| --- | --- |
| Collected | 10 |
| Passed | 9 |
| Failed | 1 |
| Errors | 0 |
| Skipped | 0 |
| Wall time | 0.11 s |

Per-test outcome, from `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v --no-header -rN --tb=no`:

```text
test_bundled_claude_payload_contains_required_runtime_files          PASSED
test_bundled_claude_payload_contains_all_repo_runtime_contracts      FAILED
test_pack_manifests_are_outside_the_parity_scope                     PASSED
test_bundled_claude_payload_excludes_settings_local_json             PASSED
test_bundled_claude_payload_excludes_variant_subtree_from_parity     PASSED
test_variant_subtree_is_bundle_only_and_non_colliding                PASSED
test_bundled_agent_memory_scopes_are_well_formed                     PASSED
test_claude_legacy_variant_files_contain_corrected_gate_commands     PASSED
test_claude_legacy_variant_files_exclude_stale_gate_commands         PASSED
test_claude_modern_csharp_profile_retains_modern_gate_commands       PASSED

1 failed, 9 passed in 0.11s
```

## The One Failure Is Pre-Existing and Environmental

The failing test is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Its assertion
message:

```text
AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.default.json
```

The failure is not caused by anything in this plan's declared write set. Neither
`.claude/hooks/enforce-prd-feature-before-planner.ps1` nor its bundled mirror is implicated; the two
copies were confirmed identical in length by [P0-T2] and no edit had been made when this run
executed.

Diagnosis, recorded so a later phase does not have to re-derive it:

- The path named in the assertion is `.claude/state/powershell-batch-budget.default.json`.
- `.claude/state/` is gitignored. `git check-ignore -v` reports:

  ```text
  .gitignore:68:.claude/state/	.claude/state/powershell-batch-budget.default.json
  .gitignore:68:.claude/state/	.claude/state/python-batch-budget.default.json
  ```

- `git ls-files .claude/state/` returns nothing, so neither file is tracked.
- Both files exist in the working tree as local runtime state:

  ```text
  -rw-r--r-- 451 Aug 26 05:28 .claude/state/powershell-batch-budget.default.json
  -rw-r--r-- 251 Aug 26 05:18 .claude/state/python-batch-budget.default.json
  ```

- There is no `.claude/state` directory in the bundle at
  `extensions/drm-copilot/resources/claude-customizations/.claude/`.

The test's repo-side enumeration `list_scoped_files(REPO_ROOT)` walks the filesystem rather than the
git index, so a gitignored local state file that the toolchain writes at run time enters the
comparison set and is then reported as missing from the bundle. The timestamps show
`powershell-batch-budget.default.json` was written during this session's PoshQC runs
([P0-T3] through [P0-T5]).

This is recorded as the measured baseline, not as a defect introduced by this plan. It is
environment-dependent: the same test passes in a checkout where `.claude/state/` is empty.

## Consequence for Later Phases (recorded, not acted on)

[P2-T7] states an acceptance condition of
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
exiting 0, and [P4-T4] requires the whole file to exit 0 with zero failures. Against this baseline
neither condition is currently satisfiable in this working tree while the untracked
`.claude/state/*.json` files are present, regardless of what this plan changes.

Phase 0 is read-and-measure only, so no corrective action is taken here. The finding is escalated in
the Phase 0 completion report so the orchestrator can decide the disposition before [P2-T7] is
reached.

Output Summary: The bundle-parity baseline run exited 1 with 9 passed and 1 failed out of 10
collected tests, in 0.11 seconds. The single failure is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which asserts that
`.claude/state/powershell-batch-budget.default.json` is missing from the bundled payload. That path
is gitignored (`.gitignore` line 68), untracked, absent from the bundle by design, and is written
into the working tree by the PoshQC toolchain at run time; the test enumerates the filesystem rather
than the git index, so the local state file enters its comparison set. The failure is pre-existing
and environmental, is unrelated to this plan's declared write set, and is flagged because [P2-T7] and
[P4-T4] both state acceptance conditions that require this test to pass.
