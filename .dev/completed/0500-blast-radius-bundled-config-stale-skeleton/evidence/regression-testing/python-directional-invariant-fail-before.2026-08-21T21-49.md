Timestamp: 2026-08-21T21-49
Command: git show fb30a9a58b8422e610a09b07361421e97367807a:extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json > extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json && poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 1 failed. AssertionError: "config/blast-radius.json separator-free shared_surfaces
entries ['package-lock.json', 'poetry.lock', 'quality-tiers.yml'] are missing from
extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json separator-free
shared_surfaces; every portable separator-free self-hosted surface must reach the bundled copy."
This demonstrates the new Python case is falsifiable: with the bundled copy reverted to the
merge-base state, the directional invariant fails and names the three missing self-hosted
separator-free entries.

Note: see `evidence/other/timestamp-clock-convention.2026-08-22T03-37.md` for why this artifact's local-time stamp sorts before the UTC-stamped Phase 0 baselines it postdates.
