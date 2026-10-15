# Repository Guard Before the Port (P1-T7, expect-fail)

Timestamp: 2026-09-29T18-00
Command: poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `1 failed, 4 passed in 0.30s`
- Exactly one line begins `FAILED `:
  `FAILED tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled`
- Its assertion message carries exactly the two violation lines:
  - `parallel-orchestrate | scripts/dev_tools/parallel_drift_detection_cli.py | not-in-bundle`
  - `parallel-remove | scripts/dev_tools/parallel_mutation_abandon_cli.py | not-in-bundle`
- PASSED: `test_ci_gate_parser_skills_invoke_bundled_parser`,
  `test_every_skill_folder_file_is_carried_by_skill_packs`,
  `test_known_unbundled_references_are_not_stale`,
  `test_published_root_folders_match_typescript_root_folders`

Defect reproduction: with no exception registered, the guard reports both unbundled Python CLIs.
