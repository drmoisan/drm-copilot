# New Active Feature Folder IO Broad-Except Red Phase

Timestamp: 2026-03-14T15-48
Command: poetry run ruff check scripts/dev_tools/new_active_feature_folder_io.py extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py
EXIT_CODE: 0
Failure: Broad `except Exception:` remains present in `scripts/dev_tools/new_active_feature_folder_io.py` (line 182) and `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py` (line 183).
Output Summary:
- Ruff completed without diagnostics for the targeted files.
- Follow-up source inspection confirmed the broad catch remains in both copies of `default_issue_fetcher`.
- This artifact preserves the pre-remediation red evidence required before replacing the broad catch with explicit handling.
