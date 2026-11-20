"""Unit tests for scripts/dev_tools/plan_progress_report.py.

These tests intentionally avoid filesystem temp directories per repo policy.
Instead, they focus on pure functions and use monkeypatching when filesystem
methods would otherwise be required.
"""

from pathlib import Path

import pytest  # noqa: TCH002 - pytest required at runtime for fixtures

from scripts.dev_tools import plan_progress_report as plan_progress_report_module
from scripts.dev_tools.plan_progress_report import (
    PlanProgressRow,
    build_report_rows,
    count_checkboxes,
    discover_plan_files,
    fallback_issue_from_feature_dir,
    parse_primary_issue,
    render_markdown_table,
    resolve_feature_and_type,
)


class TestCountCheckboxes:
    def test_counts_unchecked_and_total(self) -> None:
        markdown = """
### Phase 1
- [ ] Task A
- [x] Task B
- [X] Task C
""".strip()

        unchecked, total = count_checkboxes(markdown)
        assert (unchecked, total) == (1, 3)

    def test_ignores_non_list_checkbox_like_text(self) -> None:
        markdown = """
This is not a task: [ ]
And neither is this: [x]
""".strip()

        unchecked, total = count_checkboxes(markdown)
        assert (unchecked, total) == (0, 0)


class TestParsePrimaryIssue:
    def test_parses_plain_issue_line(self) -> None:
        markdown = """
# Feature - Plan

- Issue: #77
""".strip()

        assert parse_primary_issue(markdown) == "#77"

    def test_parses_bold_issue_line(self) -> None:
        markdown = """
# Feature - Plan

- **Issue:** #92
""".strip()

        assert parse_primary_issue(markdown) == "#92"

    def test_returns_empty_when_missing(self) -> None:
        assert parse_primary_issue("# Plan\n(no issue line)") == ""


class TestResolveFeatureAndType:
    def test_non_version_folder_uses_parent_as_feature(self) -> None:
        active_root = Path("/repo/docs/features/active")
        plan_path = Path("/repo/docs/features/active/feat-77/plan.md")

        feature, plan_type = resolve_feature_and_type(
            plan_path, active_root=active_root
        )
        assert feature == "feat-77"
        assert plan_type == "base"

    def test_version_folder_uses_parent_feature_and_type_is_version_dir(self) -> None:
        active_root = Path("/repo/docs/features/active")
        plan_path = Path(
            "/repo/docs/features/active/feat-73/v2/plan.2026-01-07T16-59.md"
        )

        feature, plan_type = resolve_feature_and_type(
            plan_path, active_root=active_root
        )
        assert feature == "feat-73"
        assert plan_type == "v2"

    def test_rejects_plan_outside_active_root(self) -> None:
        """A plan path outside the active root raises ValueError."""
        active_root = Path("/repo/docs/features/active")
        plan_path = Path("/repo/docs/features/completed/feat-1/plan.md")

        with pytest.raises(ValueError, match="plan_path is not under active_root"):
            resolve_feature_and_type(plan_path, active_root=active_root)

    def test_plan_directly_under_active_root_is_base_type(self) -> None:
        """A plan file directly under the active root uses its own name and base."""
        active_root = Path("/repo/docs/features/active")
        plan_path = Path("/repo/docs/features/active/plan.md")

        feature, plan_type = resolve_feature_and_type(
            plan_path, active_root=active_root
        )

        assert (feature, plan_type) == ("plan.md", "base")


class TestReadAndGenerate:
    """Plan reading and report composition, with disk reads replaced by recorders."""

    def test_read_plan_docs_reads_each_path_as_utf8(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Each plan is read once with UTF-8 and paired with its path in order."""
        # Arrange: serve text per path and record the requested encoding.
        reads: list[tuple[Path, str | None]] = []

        def fake_read_text(self: Path, encoding: str | None = None) -> str:
            """Record the read and return text derived from the file name."""
            reads.append((self, encoding))
            return f"text of {self.name}"

        monkeypatch.setattr(Path, "read_text", fake_read_text)
        first = Path("/repo/docs/features/active/a/plan.md")
        second = Path("/repo/docs/features/active/b/plan.md")

        # Act
        docs = plan_progress_report_module.read_plan_docs([first, second])

        # Assert
        assert docs == [(first, "text of plan.md"), (second, "text of plan.md")]
        assert reads == [(first, "utf-8"), (second, "utf-8")]

    def test_generate_report_composes_discovery_reading_and_rendering(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """The report renders rows built from the discovered and read plans."""
        active_root = Path("/repo/docs/features/active")
        plan_path = Path("/repo/docs/features/active/feat-9/plan.md")
        seen: dict[str, object] = {}

        def fake_discover(root: Path) -> list[Path]:
            """Record the scanned root and return one plan path."""
            seen["discover"] = root
            return [plan_path]

        def fake_read(paths: list[Path]) -> list[tuple[Path, str]]:
            """Record the paths and return one incomplete plan."""
            seen["read"] = paths
            return [(plan_path, "- Issue: #9\n- [ ] Todo\n- [x] Done\n")]

        monkeypatch.setattr(
            plan_progress_report_module, "discover_plan_files", fake_discover
        )
        monkeypatch.setattr(plan_progress_report_module, "read_plan_docs", fake_read)

        report = plan_progress_report_module.generate_plan_progress_report(
            active_root=active_root
        )

        assert seen == {"discover": active_root, "read": [plan_path]}
        assert "| feat-9 | #9 | base | 1/2 | [plan]" in report


class TestMain:
    """The CLI entry point, with report generation and disk writes replaced."""

    def _patch_io(
        self, monkeypatch: pytest.MonkeyPatch, calls: dict[str, object]
    ) -> None:
        """Replace report generation and disk writes with recorders.

        Args:
            monkeypatch: Fixture used to replace the module and Path seams.
            calls: Mapping that receives the recorded arguments.
        """

        def fake_generate(*, active_root: Path, report_path: Path | None = None) -> str:
            """Record the generation arguments and return a fixed report."""
            calls["generate"] = (active_root, report_path)
            return "REPORT"

        def fake_mkdir(
            self: Path, parents: bool = False, exist_ok: bool = False
        ) -> None:
            """Record the directory creation request."""
            calls["mkdir"] = (self, parents, exist_ok)

        def fake_write_text(self: Path, data: str, encoding: str | None = None) -> int:
            """Record the write and report the written length."""
            calls["write"] = (self, data, encoding)
            return len(data)

        monkeypatch.setattr(
            plan_progress_report_module, "generate_plan_progress_report", fake_generate
        )
        monkeypatch.setattr(Path, "mkdir", fake_mkdir)
        monkeypatch.setattr(Path, "write_text", fake_write_text)

    def test_main_writes_report_to_out_path(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """main renders the active root report to --out and returns 0."""
        calls: dict[str, object] = {}
        self._patch_io(monkeypatch, calls)
        out = Path("artifacts/custom/progress.md")

        result = plan_progress_report_module.main(
            ["--active-root", "docs/features/active", "--out", str(out)]
        )

        assert result == 0
        assert calls["generate"] == (Path("docs/features/active"), out)
        assert calls["mkdir"] == (out.parent, True, True)
        assert calls["write"] == (out, "REPORT", "utf-8")

    def test_main_prefers_feature_over_active_root(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """--feature, when given, replaces --active-root as the scanned root."""
        calls: dict[str, object] = {}
        self._patch_io(monkeypatch, calls)

        result = plan_progress_report_module.main(
            ["--feature", "docs/features/active/feat-3", "--active-root", "elsewhere"]
        )

        assert result == 0
        assert calls["generate"] == (
            Path("docs/features/active/feat-3"),
            Path("artifacts/active_plan_progress.md"),
        )


class TestBuildReportRows:
    def test_excludes_complete_plans(self) -> None:
        active_root = Path("/repo/docs/features/active")
        plan_path = Path("/repo/docs/features/active/feat-77/plan.md")
        markdown = "- Issue: #77\n- [x] Done\n"

        rows = build_report_rows([(plan_path, markdown)], active_root=active_root)
        assert rows == []

    def test_excludes_plans_without_any_checkboxes(self) -> None:
        active_root = Path("/repo/docs/features/active")
        plan_path = Path("/repo/docs/features/active/feat-77/plan.md")
        markdown = "- Issue: #77\n(no tasks)\n"

        rows = build_report_rows([(plan_path, markdown)], active_root=active_root)
        assert rows == []

    def test_includes_incomplete_plan_and_renders_issue(self) -> None:
        active_root = Path("/repo/docs/features/active")
        plan_path = Path(
            "/repo/docs/features/active/2026-01-07-atomic-executor-77/plan.md"
        )
        markdown = """
# Plan

- Issue: #77
- [ ] Todo
- [x] Done
""".strip()

        rows = build_report_rows([(plan_path, markdown)], active_root=active_root)
        assert len(rows) == 1
        assert rows[0].feature == "2026-01-07-atomic-executor-77"
        assert rows[0].issue == "#77"
        assert rows[0].plan_type == "base"
        assert rows[0].plan_path == plan_path
        assert (rows[0].unchecked, rows[0].total) == (1, 2)


class TestRenderMarkdownTable:
    def test_renders_header_only_when_empty(self) -> None:
        table = render_markdown_table([])
        assert "| feature | issue | type | remaining | plan |" in table
        assert table.count("\n") >= 1

    def test_renders_rows(self) -> None:
        rows = [
            PlanProgressRow(
                feature="feat",
                issue="#1",
                plan_type="base",
                plan_path=Path("/repo/docs/features/active/feat/plan.md"),
                unchecked=2,
                total=5,
            )
        ]
        table = render_markdown_table(rows)
        assert "| feat | #1 | base | 2/5 | [plan]" in table

    def test_renders_relative_plan_links_when_report_path_provided(self) -> None:
        rows = [
            PlanProgressRow(
                feature="feat",
                issue="#1",
                plan_type="base",
                plan_path=Path("/repo/docs/features/active/feat/plan.md"),
                unchecked=2,
                total=5,
            )
        ]
        report_path = Path("/repo/artifacts/active_plan_progress.md")

        table = render_markdown_table(rows, report_path=report_path)
        assert "[plan](../docs/features/active/feat/plan.md)" in table


class TestDiscoverPlanFiles:
    def test_includes_plan_dash_variants(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Ensure plan discovery includes plan-*.md without touching disk."""

        active_root = Path("/repo/docs/features/active")
        plan = Path("/repo/docs/features/active/feat/plan.md")
        plan_dot = Path("/repo/docs/features/active/feat/plan.2026-01-01T00-00.md")
        plan_dash = Path("/repo/docs/features/active/feat/v1/plan-20260106-1731.md")

        # Route by glob pattern to simulate Path.rglob behavior.
        def fake_rglob(self: Path, pattern: str) -> list[Path]:
            if pattern == "plan.md":
                return [plan]
            if pattern == "plan.*.md":
                return [plan_dot]
            if pattern == "plan-*.md":
                return [plan_dash]
            return []

        monkeypatch.setattr(Path, "rglob", fake_rglob)

        discovered = discover_plan_files(active_root)
        assert discovered == sorted([plan, plan_dot, plan_dash])


class TestFallbackIssueFromFeatureDir:
    @pytest.mark.parametrize(
        ("feature", "expected"),
        [
            ("2026-01-07-atomic-executor-77", "#77"),
            ("1016-foo-bar", "#1016"),
            ("0042-foo", "#42"),
            ("2026-01-07-atomic-executor", ""),
            ("notes-feature", ""),
        ],
    )
    def test_delegates_issue_extraction_to_the_parser(
        self, feature: str, expected: str
    ) -> None:
        """Issue-first and trailing-issue names yield the issue; others none."""
        assert fallback_issue_from_feature_dir(feature) == expected


class TestParseArgs:
    def test_active_root_default_is_the_default_active_area(self) -> None:
        """The --active-root default is the default root's active area."""
        args = plan_progress_report_module._parse_args(  # type: ignore[reportPrivateUsage]
            []
        )
        assert args.active_root == Path(".dev/active")
