# Task Check [P1-T1]

Timestamp: 2026-11-19T20-45
Plan: remediation-plan.2026-11-19T19-58.md
Command: git rm -q -f -- <two RETIRED-BRIEF-COPIES> <two IncomingRetiredAdds>; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1 tests/scripts/claude-runtime/documentation-workflow.CommitStage.Tests.ps1 tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1; env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_bash_command_shape_surfaces.py -q -p no:cacheprovider --no-cov
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: the retired trees are empty in the working tree and the index; the four brief copies keep their auto-merged text with one hash; Pester selection 275 passed, 1 failed (the expected CLR-PACK-MANIFESTS case); pytest selection 83 passed, 0 failed. EXIT_CODE is the Pester launcher's exit, which this task expects.

## Changed files (deleted from the working tree and the index)

- `.github/skills/execution-environment/SKILL.md` (modify/delete conflict, kept deleted)
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` (modify/delete conflict, kept deleted)
- `.github/skills/push-down-integration/SKILL.md` (IncomingRetiredAdds, deleted)
- `extensions/drm-copilot/resources/customizations/.github/skills/push-down-integration/SKILL.md` (IncomingRetiredAdds, deleted)

Kept: `.agents/skills/push-down-integration/SKILL.md`, `.claude/skills/push-down-integration/SKILL.md` and their two bundle copies.

Glob of both RETIRED-SKILL-TREES trees: no file. `git ls-files` under both trees: 0 entries. Remaining unmerged path: `extensions/drm-copilot/resources/customizations/pack-manifests/core.json` (P1-T2).

## Brief

BriefEdits: none (P0-T2 recorded every incoming fact `PresentInFour: yes` and `SixCopyWording: none`; authorized no-edit branch). LEDGER-STEP: not applied (`LedgerRegion: none`).

Hash of the four REMAINING-BRIEF-COPIES: a566b17e4fb95bde750603ccf1728eeb7ace83d1 (one value). Each fact of P0-T2 (a) is present in each copy (3 matches per copy).

## Selection and rule

- GUARD-SUITE file and the PowerShell members of BRIEF-PIN-TESTS (`documentation-workflow.CommitStage.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `test-cadence-wording.Tests.ps1`, `NestingDepthContract.Tests.ps1`) through the launcher `pester` suite with `-TestPath`.
- The pytest members of BRIEF-PIN-TESTS (`test_execution_environment_brief_contracts.py`, `test_discovery_documentation_contracts.py`, `test_single_pass_preflight_contracts.py`) plus `test_bash_command_shape_surfaces.py`, named by the task.

## Results

| Run | Exit | Result |
| --- | --- | --- |
| Pester selection (5 shards) | 1 | 275 passed, 1 failed; shard logs: 130/0, 21/1, 87/0, 9/0, 28/0 |
| pytest selection, first attempt | 75 | queue timeout (the machine lock was held by the Pester selection above); not a failure |
| pytest selection, re-run | 0 | 83 passed, 0 failed |

ExpectedFailure: CLR-PACK-MANIFESTS finds no retired path in any pack manifest (resolved by P1-T2). Its message: `extensions/drm-copilot/resources/customizations/pack-manifests/core.json: names the retired path` (the conflict hunk still holds the incoming side).

Passing among the selected: `CLR-SKILL-TREES-ABSENT finds no file under either retired tree`, `CLR-BRIEF-COUNT holds every count target in each remaining brief and contract copy`, `test_brief_copies_are_byte_identical`, `test_execution_environment_fact_is_unchanged_across_copies`, and every other selected test.
