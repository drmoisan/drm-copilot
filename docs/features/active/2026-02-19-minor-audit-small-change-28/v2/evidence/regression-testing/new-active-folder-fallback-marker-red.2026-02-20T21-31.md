Timestamp: 2026-02-20T21-31
Command: poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k "work_mode_marker_fallback_issue_md_full"
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
________________ test_work_mode_marker_fallback_issue_md_full _________________

    def test_work_mode_marker_fallback_issue_md_full() -> None:
        """Verify minor-audit fallback issue.md persists full marker above first section."""
        fs = FakeFileSystem()
        workspace = Path("/workspace")
        _seed_feature_template(fs, workspace)
        potential_path = (
            workspace / "docs" / "features" / "potential" / "fallback-marker.md"
        )
        fs.write_text(
            potential_path,
            "\n".join(
                [
                    "- Issue: #31",
                    "- File: a.py",
                    "- File: b.py",
                    "- File: c.py",
                    "- File: d.py",
                    "## Problem / Why",
                    "problem",
                    "## Proposed Behavior",
                    "behavior",
                ]
            ),
        )
    
        result = mod.create_active_folder(
            feature_name="fallback-marker",
            feature_type="feature",
