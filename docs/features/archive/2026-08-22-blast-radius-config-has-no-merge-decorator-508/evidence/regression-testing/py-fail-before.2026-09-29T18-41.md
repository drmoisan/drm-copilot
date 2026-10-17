# Python Fail-Before (P1-T5) [expect-fail]

Timestamp: 2026-09-29T18-41
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py
Command actually executed: the same command with `-p no:cacheprovider` appended (no pytest cache write), output captured to a session scratch log.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Result line: `2 failed in 0.25s`
- Outcome A (`2 failed`):
  - FAILED tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py::test_ac08_push_carries_destination_overlay_entries_across_two_pushes
    - Fails at line 129, the containment assertion `assert '"Directory.Build.props"' in text` (the composed text is the bare derived base: shared_surfaces `["config/blast-radius.json"]`, modules `{"config": ["config/**"]}`). Not an import or fixture error; the two-push equality assertion before it passed.
  - FAILED tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py::test_ac11_source_side_overlay_is_not_published
    - Fails at line 140, `assert not fs.is_file(OVERLAY)`: `is_file(WindowsPath('/dest/config/blast-radius.local.json'))` is True.

Re-run after `poetry run black` reformatted the new test file (ruff E501 fix, no behavior change): same outcome, `2 failed in 0.20s`, same two node IDs.

AC11_FAIL_BEFORE: published from CONFIG_PUBLISH_ROOT
The #507 config enumeration (BundleConfigFileSystem answering `list_files(source_root / "config")` from `<BUNDLE>/config`) delivers `CONFIG_PUBLISH_ROOT/config/blast-radius.local.json` to the destination, so the P4-T4 exclusion is the AC11 fix. SOURCE_ROOT_EQUALS_REPO_ROOT is `yes` (P0-T9); P4-T4 runs the AC11 case as its acceptance gate.
