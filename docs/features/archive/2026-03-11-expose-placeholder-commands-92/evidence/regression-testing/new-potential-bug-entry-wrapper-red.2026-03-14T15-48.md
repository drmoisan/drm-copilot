# New Potential Bug Entry Wrapper Red Phase

Timestamp: 2026-03-14T15-48
Command: poetry run pytest tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py -k main_invokes_bundled_entrypoint_and_returns_zero
EXIT_CODE: 1
Failure: AttributeError: module 'ext_npbe_main_test' has no attribute 'importlib'
Output Summary:
- Pytest executed the targeted wrapper-delegation regression test.
- Result: 1 failed in 0.07s.
- The current template does not expose the dynamic import boundary required by the planned thin-wrapper contract.
