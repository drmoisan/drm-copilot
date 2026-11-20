# citation-test-fail-before

Timestamp: 2026-11-08T14-04
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --no-cov tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
Fail-before run on the pre-fix tree (focused run, debugging evidence, not a gate): 1 failed, 4 passed.
Only failing test: tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py::test_every_epic_surface_citation_is_shipped.
Reported path: scripts/dev_tools/epic_wave_computation.py (cited by one Claude and one Codex surface set).
