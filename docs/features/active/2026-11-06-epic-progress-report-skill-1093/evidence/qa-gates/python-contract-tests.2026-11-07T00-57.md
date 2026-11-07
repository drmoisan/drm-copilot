# QA Gate: Python Push-Down Contract Tests — Issue #1093

Timestamp: 2026-11-07T00-57
Command: sh SCRATCH/issue-1093-pytest.sh final (per module: `poetry run pytest tests/scripts/dev_tools/<module>.py -q -p no:randomly -o addopts="" -rA`, from the item worktree root; the five modules of P0-T7, unchanged)
EXIT_CODE: 0
Output Summary: 106 passed, 0 failed across the five modules; each module exited 0; all seven named cases passed.

| Module | Passed | Failed | Exit code |
|---|---|---|---|
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 14 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | 2 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | 18 | 0 | 0 |
| `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` | 10 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | 62 | 0 | 0 |

Named cases observed as PASSED:

- `test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled`
- `test_skill_bundle_contract_repo.py::test_every_skill_folder_file_is_carried_by_skill_packs`
- `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- `test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest`
- `test_push_down_pack_manifest_dependency_closure.py::test_claude_manifest_powershell_dependency_closure`
- `test_push_down_pack_manifest_dependency_closure.py::test_every_psscriptroot_occurrence_is_recognized`
- `test_push_down_pack_manifest_dependency_closure.py::test_scanned_source_floor`

These counts equal the P0-T7 baseline (106 passed), now with the skill folder, its six `core.json` entries, and the six bundle copies in the tree.
