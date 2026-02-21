Timestamp: 2026-02-20T21-29
Command: poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k "work_mode_marker_minor_audit"
EXIT_CODE: 1
Output Summary: 
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 22 items / 21 deselected / 1 selected

tests\scripts\dev_tools\test_potential_to_issue.py F                     [100%]

================================== FAILURES ===================================
______________________ test_work_mode_marker_minor_audit ______________________

    def test_work_mode_marker_minor_audit() -> None:
        """Verify minor-audit issue bodies persist marker above first section heading."""
        workspace = Path("/workspace")
        potential = workspace / "docs/features/potential/minor-marker.md"
        fs = FakeFileSystem()
        fs.files[potential] = "\n".join(
            [
                "# Minor Marker Feature",
                "- File: scripts/dev_tools/potential_to_issue.py",
                "- Risk: low",
                "## Problem / Why",
                "problem",
                "## Proposed Behavior",
                "behavior",
            ]
        )
        gh = FakeGhClient(
            mod.GhResult(["Created: https://example.com/issues/56"], 0), mod.GhResult([], 0)
        )
    
        outcome = mod.promote_potential(
            potential_path=str(potential),
            promotion_type="feature",
            fs=fs,
            gh=gh,
            workspace=workspace,
            work_mode="minor-audit",
        )
