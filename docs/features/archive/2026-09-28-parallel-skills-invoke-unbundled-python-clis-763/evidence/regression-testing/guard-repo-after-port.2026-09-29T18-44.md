# Repository Guard After the Port (P6-T1)

Timestamp: 2026-09-29T18-44
Command: poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
EXIT_CODE: 0
Output Summary:
- `5 passed in 0.43s`; no FAILED line.
- PASSED: `test_every_skill_script_reference_is_bundled`,
  `test_ci_gate_parser_skills_invoke_bundled_parser`,
  `test_every_skill_folder_file_is_carried_by_skill_packs`,
  `test_known_unbundled_references_are_not_stale`,
  `test_published_root_folders_match_typescript_root_folders`.
- Pass-after for the P1-T7 fail-before reproduction: with the registry empty, the guard now finds no
  unbundled reference.
