Timestamp: 2026-02-20T21-30
Command: poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k "work_mode_marker_minor_issue_md"
EXIT_CODE: 1
Output Summary: 
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 43 items / 42 deselected / 1 selected

tests\scripts\dev_tools\test_new_active_feature_folder.py F              [100%]

================================== FAILURES ===================================
____________________ test_work_mode_marker_minor_issue_md _____________________

    def test_work_mode_marker_minor_issue_md() -> None:
        """Verify minor-audit issue.md persists marker above first section heading."""
        fs = FakeFileSystem()
        workspace = Path("/workspace")
        _seed_feature_template(fs, workspace)
        potential_path = workspace / "docs" / "features" / "potential" / "minor-marker.md"
        fs.write_text(
            potential_path,
            "\n".join(
                [
                    "- Issue: #30",
                    "- File: scripts/dev_tools/new_active_feature_folder.py",
                    "- Risk: low",
                    "## Problem / Why",
                    "problem",
                    "## Proposed Behavior",
                    "intent",
                ]
            ),
        )
    
        result = mod.create_active_folder(
            feature_name="minor-marker",
            feature_type="feature",
            workspace=workspace,
            fs=fs,
            work_mode="minor-audit",
        )
