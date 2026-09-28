# Push-down parity — eleven mirrored files

Timestamp: 2026-09-07T19-42

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v`; `pwsh -NoProfile -Command "(Get-FileHash -Algorithm SHA256 <ten PowerShell paths>).Hash"`; `pwsh -NoProfile -Command "(Get-FileHash -Algorithm SHA256 <twelve documentation paths>).Hash"`

EXIT_CODE: 1

## Output Summary

Eleven adjacent digest pairs, all equal. Five PowerShell production files (the [P8-T10] hash
command):

```text
89893D40F8F5C34889B19C051F8232289776C8D3B808039EF84E1615B27BB4B9
89893D40F8F5C34889B19C051F8232289776C8D3B808039EF84E1615B27BB4B9
88608CABF3AC49FB68F126BDB88BC2AA9068A7F20629D105DDF5DCE0040B7D97
88608CABF3AC49FB68F126BDB88BC2AA9068A7F20629D105DDF5DCE0040B7D97
0DD3D9978E9338BBDD506E7CEB982A2FF732048B0B0D7B2773360EE1100CC845
0DD3D9978E9338BBDD506E7CEB982A2FF732048B0B0D7B2773360EE1100CC845
AA10179DC5881371C6A8D6032798913B0FC68E99506675F1F51CFA829456C23F
AA10179DC5881371C6A8D6032798913B0FC68E99506675F1F51CFA829456C23F
65CDE49B2984ABBB569F4EE2DCB6D025899F7B64EA4DCA6C599B7E2FFBD49603
65CDE49B2984ABBB569F4EE2DCB6D025899F7B64EA4DCA6C599B7E2FFBD49603
```

```text
PAIR-EQUAL 89893D40F8F5C348...  .claude/lib/blast-radius/BlastRadius.psm1
PAIR-EQUAL 88608CABF3AC49FB...  .claude/lib/blast-radius/BlastRadiusConflict.psm1
PAIR-EQUAL 0DD3D9978E9338BB...  .claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1
PAIR-EQUAL AA10179DC5881371...  .claude/lib/project-file-merge/ProjectFileMerge.psm1
PAIR-EQUAL 65CDE49B2984ABBB...  .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1
```

Six documentation files (the rule file, two agent files, three skill files):

```text
8C31DA69A734805550B878CC83776F5FCFF8FD00CBEFD84B01B4C0BD7C962BB5
8C31DA69A734805550B878CC83776F5FCFF8FD00CBEFD84B01B4C0BD7C962BB5
BB127A6EFD19C7D4CB30E64E1A2185ADA15234471103028CD845C703782845A7
BB127A6EFD19C7D4CB30E64E1A2185ADA15234471103028CD845C703782845A7
F09F0A3C11FB6D6DA2F097E87AE61EA5862C67870A16C05C802B6D59D09FEFEE
F09F0A3C11FB6D6DA2F097E87AE61EA5862C67870A16C05C802B6D59D09FEFEE
1EACAFD5F1B5C7519D6951DF789FAFE835F30953FDD840E75E06E00045401251
1EACAFD5F1B5C7519D6951DF789FAFE835F30953FDD840E75E06E00045401251
FD0EF472761064C271F001D6418E6B12BB423838D7A86386DE809B32DB114511
FD0EF472761064C271F001D6418E6B12BB423838D7A86386DE809B32DB114511
235DEB99EB76725CB377D63AAF0691917A28B1E9E8311AF3117A16004DBB4488
235DEB99EB76725CB377D63AAF0691917A28B1E9E8311AF3117A16004DBB4488
```

```text
PAIR-EQUAL 8C31DA69A7348055...  .claude/rules/parallel-orchestration.md
PAIR-EQUAL BB127A6EFD19C7D4...  .claude/agents/parallel-orchestrator.md
PAIR-EQUAL F09F0A3C11FB6D6D...  .claude/agents/parallel-planner.md
PAIR-EQUAL 1EACAFD5F1B5C751...  .claude/skills/parallel-orchestrate/SKILL.md
PAIR-EQUAL FD0EF472761064C2...  .claude/skills/parallel-plan/SKILL.md
PAIR-EQUAL 235DEB99EB76725C...  .claude/skills/parallel-add/SKILL.md
```

All eleven adjacent pairs are equal.

## pytest result

```text
1 failed, 10 passed in 0.24s
```

The two node IDs the task names:

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_planner_review_resources_exist_and_are_byte_identical PASSED [ 27%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts FAILED [ 18%]
```

`test_planner_review_resources_exist_and_are_byte_identical` passed.
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` failed with a sole message naming a
path under `.claude/state/`:

```text
AssertionError: Repo file missing from bundle: .claude\state\current-session-id
```

That is the constraint C4 alternative the task permits, and it is the same node, count, and path
class recorded by [P0-T7]. Because `list_scoped_files` sorts paths and `.claude/agents`,
`.claude/lib`, `.claude/rules`, and `.claude/skills` all sort before `.claude/state`, a mirror defect
introduced by this plan would have surfaced before the exempted assertion; the eleven equal digest
pairs above are the independent confirmation that none exists.
