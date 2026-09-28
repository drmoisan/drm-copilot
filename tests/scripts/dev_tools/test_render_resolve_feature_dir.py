"""Unit tests for ``resolve_feature_dir`` in scripts/dev_tools/pr_context/render.py.

Issue #622 moved class ``TestResolveFeatureDir`` here from ``test_render.py``
unchanged, because the 500-line cap on test files required that file to shrink.
"""

from pathlib import Path

import pytest

from scripts.dev_tools.pr_context.render import resolve_feature_dir


class TestResolveFeatureDir:
    def test_resolve_feature_dir_direct_exact_match(
        self, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """resolve_feature_dir returns direct path when exact match exists."""
        from scripts.dev_tools.pr_context import render

        base = mem_fs_path / "features"
        direct = base / "my-feature"

        def mock_directory_exists(path: Path) -> bool:
            return path == direct

        monkeypatch.setattr(render, "directory_exists", mock_directory_exists)
        result = resolve_feature_dir(base, "my-feature")
        assert result == direct

    def test_resolve_feature_dir_base_does_not_exist(
        self, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """resolve_feature_dir returns None when base directory doesn't exist."""
        from scripts.dev_tools.pr_context import render

        base = mem_fs_path / "missing"

        def mock_directory_exists(path: Path) -> bool:
            return False

        monkeypatch.setattr(render, "directory_exists", mock_directory_exists)
        result = resolve_feature_dir(base, "feature")
        assert result is None

    def test_resolve_feature_dir_no_subdirectories(self, mem_fs_path: Path) -> None:
        """resolve_feature_dir returns None when base has no subdirectories."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        result = resolve_feature_dir(base, "missing-feature")
        assert result is None

    def test_resolve_feature_dir_skips_files(self, mem_fs_path: Path) -> None:
        """resolve_feature_dir skips files and only checks directories."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "file.txt").write_text("not a directory")
        (base / "my-feature-file").write_text("also not a directory")
        result = resolve_feature_dir(base, "feature")
        assert result is None

    def test_resolve_feature_dir_strong_pattern_match(self, mem_fs_path: Path) -> None:
        """resolve_feature_dir returns strong pattern match."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "other-thing").mkdir()
        (base / "my-feature-impl").mkdir()
        result = resolve_feature_dir(base, "feature")
        assert result == base / "my-feature-impl"

    def test_resolve_feature_dir_multiple_strong_matches_returns_first(
        self, mem_fs_path: Path
    ) -> None:
        """resolve_feature_dir returns first strong match when multiple exist."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "zoo-feature-impl").mkdir()
        (base / "alpha-feature-beta").mkdir()
        (base / "feature-gamma").mkdir()
        result = resolve_feature_dir(base, "feature")
        # Should return alphabetically first: alpha-feature-beta
        assert result == base / "alpha-feature-beta"

    def test_resolve_feature_dir_weak_match_when_no_strong(
        self, mem_fs_path: Path
    ) -> None:
        """resolve_feature_dir returns weak match when no strong match exists."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "unrelated").mkdir()
        (base / "myfeatureimpl").mkdir()  # Contains "feature" but no delimiter
        result = resolve_feature_dir(base, "feature")
        assert result == base / "myfeatureimpl"

    def test_resolve_feature_dir_multiple_weak_matches_returns_first(
        self, mem_fs_path: Path
    ) -> None:
        """resolve_feature_dir returns first weak match when multiple exist."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "zoofeaturething").mkdir()
        (base / "alphafeaturebeta").mkdir()
        result = resolve_feature_dir(base, "feature")
        # Should return alphabetically first: alphafeaturebeta
        assert result == base / "alphafeaturebeta"

    def test_resolve_feature_dir_prefers_strong_over_weak(
        self, mem_fs_path: Path
    ) -> None:
        """resolve_feature_dir prefers strong match over weak match."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "weakfeaturematch").mkdir()  # Weak: contains but no delimiters
        (base / "strong-feature-match").mkdir()  # Strong: has delimiters
        result = resolve_feature_dir(base, "feature")
        assert result == base / "strong-feature-match"

    def test_resolve_feature_dir_no_matches(self, mem_fs_path: Path) -> None:
        """resolve_feature_dir returns None when no matches exist."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "unrelated").mkdir()
        (base / "another").mkdir()
        result = resolve_feature_dir(base, "missing")
        assert result is None

    def test_resolve_feature_dir_pattern_with_underscore_delimiter(
        self, mem_fs_path: Path
    ) -> None:
        """resolve_feature_dir matches pattern with underscore delimiters."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "my_feature_impl").mkdir()
        result = resolve_feature_dir(base, "feature")
        assert result == base / "my_feature_impl"

    def test_resolve_feature_dir_pattern_at_start(self, mem_fs_path: Path) -> None:
        """resolve_feature_dir matches pattern at start of name."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "feature-impl").mkdir()
        result = resolve_feature_dir(base, "feature")
        assert result == base / "feature-impl"

    def test_resolve_feature_dir_pattern_at_end(self, mem_fs_path: Path) -> None:
        """resolve_feature_dir matches pattern at end of name."""
        base = mem_fs_path / "features"
        base.mkdir(parents=True)
        (base / "impl-feature").mkdir()
        result = resolve_feature_dir(base, "feature")
        assert result == base / "impl-feature"
