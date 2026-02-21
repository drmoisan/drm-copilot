Timestamp: 2026-02-20T21-29
Command: poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k "work_mode_marker_fallback_full"
EXIT_CODE: 1
Output Summary: 
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 23 items / 22 deselected / 1 selected

tests\scripts\dev_tools\test_potential_to_issue.py F                     [100%]

================================== FAILURES ===================================
_____________________ test_work_mode_marker_fallback_full _____________________

    def test_work_mode_marker_fallback_full() -> None:
        """Verify fallback-to-full issue bodies persist full marker above first section."""
        workspace = Path("/workspace")
        potential = workspace / "docs/features/potential/fallback-marker.md"
        fs = FakeFileSystem()
        fs.files[potential] = "\n".join(
            [
                "# Fallback Marker Feature",
                "- File: a.py",
                "- File: b.py",
                "- File: c.py",
                "- File: d.py",
                "## Problem / Why",
                "problem",
                "## Proposed Behavior",
                "behavior",
            ]
        )
        gh = FakeGhClient(
            mod.GhResult(["Created: https://example.com/issues/57"], 0), mod.GhResult([], 0)
        )
    
        outcome = mod.promote_potential(
            potential_path=str(potential),
            promotion_type="feature",
            fs=fs,
            gh=gh,
            workspace=workspace,
