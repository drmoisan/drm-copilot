# Baseline Python Push-Down Contract Tests — Issue #1093

Timestamp: 2026-11-06T23-56
Command: sh SCRATCH/issue-1093-pytest.sh baseline (per module: `poetry run pytest tests/scripts/dev_tools/<module>.py -q -p no:randomly -o addopts="" -rA`, from the item worktree root)
EXIT_CODE: 0
Output Summary: 106 passed, 0 failed across the five modules; each module exited 0.

| Module | Passed | Failed | Exit code |
|---|---|---|---|
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 14 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | 2 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | 18 | 0 | 0 |
| `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` | 10 | 0 | 0 |
| `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | 62 | 0 | 0 |

Named cases observed as PASSED: `test_every_skill_script_reference_is_bundled`, `test_every_skill_folder_file_is_carried_by_skill_packs`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`, `test_scanned_source_floor`.

Environment note: the item worktree's `.venv` held no project dependencies; `poetry -C <item worktree> install --no-interaction --no-root` populated it before this run without changing a tracked file.
