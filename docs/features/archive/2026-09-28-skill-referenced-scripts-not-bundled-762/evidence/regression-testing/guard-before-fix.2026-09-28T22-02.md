# Repository Guard Before Fix (P1-T11) [expect-fail]

Timestamp: 2026-09-28T22-02
Command: poetry run pytest -v tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `2 failed, 3 passed in 0.29s`. Exactly two lines begin `FAILED `, naming the two expected tests; the first failure lists exactly one violation line; the other three B6 tests PASSED. This is the fail-before evidence for AC2, AC3, and AC6.

```text
test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled FAILED
test_skill_bundle_contract_repo.py::test_ci_gate_parser_skills_invoke_bundled_parser FAILED
test_skill_bundle_contract_repo.py::test_every_skill_folder_file_is_carried_by_skill_packs PASSED
test_skill_bundle_contract_repo.py::test_known_unbundled_references_are_not_stale PASSED
test_skill_bundle_contract_repo.py::test_published_root_folders_match_typescript_root_folders PASSED
FAILED tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled
FAILED tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_ci_gate_parser_skills_invoke_bundled_parser
```

First failure, violation lines (verbatim, the only one):

```text
E         cleanup-merged-worktrees | scripts/bash/cleanup-worktrees.sh | not-in-bundle
```

Second failure message:

```text
E       AssertionError: Skills not invoking .claude/lib/ci-gate/Invoke-CiGateParser.ps1: ['orchestrate', 'epic-orchestrate']; got {'orchestrate': (), 'epic-orchestrate': ()}
```
