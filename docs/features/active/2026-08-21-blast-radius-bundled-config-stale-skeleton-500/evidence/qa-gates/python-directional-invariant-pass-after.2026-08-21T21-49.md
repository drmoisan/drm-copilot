Timestamp: 2026-08-21T21-49
Command: git checkout -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json && git status --short -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json && poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle
EXIT_CODE: 0
Output Summary: git status --short for the restored path produced no output, confirming a clean
restore. The rerun collected 1 item and reported "1 passed", confirming the new Python case passes
again once the bundled copy is restored.
