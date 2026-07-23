"""Tests for the Python rewrite of potential-to-issue tooling."""

from __future__ import annotations

import sys
from pathlib import Path
from types import SimpleNamespace
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import potential_to_issue as mod

if TYPE_CHECKING:
    from collections.abc import Iterable


class FakeFileSystem(mod.FileSystem):
    """In-memory filesystem fake used to isolate promotion tests from disk IO."""

    def __init__(self) -> None:
        """Initialize in-memory file, directory, and move tracking structures."""
        self.files: dict[Path, str] = {}
        self.dirs: set[Path] = set()
        self.moves: list[tuple[Path, Path]] = []

    def resolve_path(self, path_str: str) -> Path:
        """Resolve fake paths without touching the local filesystem."""
        return Path(path_str)

    def exists(self, path: Path) -> bool:
        """Return whether a fake file path exists in memory."""
        return path in self.files

    def read_text(self, path: Path) -> str:
        """Read in-memory text content for a fake file path."""
        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        """Write in-memory text content for a fake file path."""
        self.files[path] = content

    def write_lines(self, path: Path, lines: Iterable[str]) -> None:
        """Persist line collections as newline-joined in-memory text."""
        self.files[path] = "\n".join(lines)

    def ensure_dir(self, path: Path) -> None:
        """Track directory creation requests in memory."""
        self.dirs.add(path)

    def move(self, src: Path, dest: Path) -> None:
        """Move fake file content from source path to destination path."""
        if src not in self.files:
            raise FileNotFoundError(src)
        self.files[dest] = self.files[src]
        del self.files[src]
        self.moves.append((src, dest))
        self.dirs.add(dest.parent)


class FakeGhClient(mod.GhClient):
    """Deterministic gh client fake for promotion workflow testing."""

    def __init__(
        self,
        create_result: mod.GhResult | list[mod.GhResult],
        view_result: mod.GhResult | None = None,
        label_result: mod.GhResult | None = None,
        authenticated: bool = True,
    ) -> None:
        """Initialize fake gh responses and call tracking state."""
        self.create_results = (
            create_result if isinstance(create_result, list) else [create_result]
        )
        self.view_result = view_result
        self.label_result = label_result or mod.GhResult([], 0)
        self.authenticated = authenticated
        self.calls: list[tuple[str, tuple[str, ...]]] = []
        self.ensure_label_calls: list[str] = []

    def is_authenticated(self) -> bool:
        """Return preconfigured authentication status."""
        return self.authenticated

    def issue_create(self, title: str, body: str, promotion_type: str) -> mod.GhResult:
        """Record issue-create invocations and return configured result."""
        self.calls.append(("create", (title, body, promotion_type)))
        if len(self.create_results) > 1:
            return self.create_results.pop(0)
        return self.create_results[0]

    def ensure_label(self, label: str) -> mod.GhResult:
        """Record label-ensure requests and return configured result."""
        self.ensure_label_calls.append(label)
        self.calls.append(("ensure_label", (label,)))
        return self.label_result

    def issue_view(self, issue_number: str) -> mod.GhResult:
        """Record issue-view invocation and return configured view result."""
        self.calls.append(("view", (issue_number,)))
        return self.view_result or mod.GhResult([], 0)


def _build_feature_potential_content(feature_name: str) -> str:
    """Return minimal feature content for potential-to-issue promotion tests."""
    return "\n".join(
        [
            f"# {feature_name}",
            "## Problem / Why",
            "why",
            "## Proposed Behavior",
            "behave",
            "## Acceptance Criteria (early draft)",
            "criteria",
            "## Constraints & Risks",
            "risk",
            "## Test Conditions to Consider",
            "tests",
        ]
    )


def test_get_feature_name_variants() -> None:
    """Verify feature name extraction from headings and filename fallbacks."""
    assert (
        mod.get_feature_name("# My Feature Name\n## Section", Path("test.md"))
        == "My Feature Name"
    )
    assert mod.get_feature_name("# Feature (Potential)\n", Path("test.md")) == "Feature"
    assert mod.get_feature_name("No heading", Path("feature-name.md")) == "feature-name"
    assert mod.get_feature_name("No heading", Path("my-feature")) == "my-feature"
    assert (
        mod.get_feature_name("#   Feature Name (Potential)  \n", Path("test.md"))
        == "Feature Name"
    )
    assert (
        mod.get_feature_name("# First Feature\n## Second\n# Third", Path("test.md"))
        == "First Feature"
    )
    assert (
        mod.get_feature_name("# Bug Title (Potential Bug)\n", Path("test.md"))
        == "Bug Title"
    )


def test_get_feature_path_variants() -> None:
    """Verify feature-path normalization across punctuation and spacing cases."""
    assert mod.get_feature_path("My Feature Name") == "My_Feature_Name"
    assert mod.get_feature_path("Feature: (v2.0) @ Test!") == "Feature_v20__Test"
    assert mod.get_feature_path("Feature   Name") == "Feature_Name"
    assert mod.get_feature_path("my-feature-name") == "my-feature-name"
    assert mod.get_feature_path("Feature v2 Update") == "Feature_v2_Update"
    assert mod.get_feature_path("A") == "A"


def test_get_section_variants() -> None:
    """Verify markdown section extraction for common and edge-case layouts."""
    content = "## Problem / Why\nabc\n## Proposed Behavior\ndef"
    assert mod.get_section(content, "Problem / Why") == "abc"

    multi_line = "## Problem / Why\nline1\nline2\nline3\n## Next Section\nother"
    assert mod.get_section(multi_line, "Problem / Why") == "line1\nline2\nline3"

    assert mod.get_section(content, "NonExistent") == ""

    end_section = "## Problem / Why\nabc\n## Last Section\nfinal content"
    assert mod.get_section(end_section, "Last Section") == "final content"

    trimmed = "## Problem / Why\n  abc  \n  def  \n## Next"
    assert mod.get_section(trimmed, "Problem / Why") == "abc  \n  def"

    special_heading = "## Acceptance Criteria (early draft)\ncontent here\n## Next"
    assert (
        mod.get_section(special_heading, "Acceptance Criteria (early draft)")
        == "content here"
    )

    empty_section = "## Problem / Why\n\n## Proposed Behavior\ndef"
    assert mod.get_section(empty_section, "Problem / Why") == ""

    windows_endings = "## Problem / Why\r\nabc\r\n## Proposed Behavior\r\ndef"
    assert mod.get_section(windows_endings, "Problem / Why") == "abc"


def test_promote_potential_success_updates_metadata_and_moves_file() -> None:
    """Verify successful promotion updates metadata and archives the source file."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/sample.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Feature Title",
            "## Problem / Why",
            "why",
            "## Proposed Behavior",
            "behave",
            "## Acceptance Criteria (early draft)",
            "criteria",
            "## Constraints & Risks",
            "risk",
            "## Test Conditions to Consider",
            "tests",
        ]
    )

    create_result = mod.GhResult(["Created: https://example.com/issues/123"], 0)
    view_result = mod.GhResult(
        [
            '{"number":123,"title":"t","url":"https://example.com/issues/123","author":{"login":"me"},"updatedAt":"2024-01-02T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result)
    messages: list[str] = []

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        emit=messages.append,
    )

    assert outcome.exit_code == 0
    assert outcome.destination is not None
    assert (
        outcome.destination == workspace / "docs/features/potential/promoted/sample.md"
    )
    assert len(gh.calls) == 2
    assert (potential, outcome.destination) in fs.moves

    promoted_content = fs.files[outcome.destination]
    lines = promoted_content.splitlines()
    assert lines[0] == "# Feature Title (Issue #123)"
    assert "- Issue: #123" in lines
    assert "- Issue URL: https://example.com/issues/123" in lines
    assert "- Last Updated: 2024-01-02" in lines
    assert (
        "- Status: Promoted -> docs/features/active/Feature_Title/ (Issue #123)"
        in lines
    )
    assert any(line.startswith("Moved potential file") for line in messages)


def test_promote_potential_failure_does_not_move_file() -> None:
    """Verify failed issue creation leaves source content and path unchanged."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/sample.md"
    fs = FakeFileSystem()
    original_content = "# Feature Title\n## Problem / Why\nwhy"
    fs.files[potential] = original_content

    create_result = mod.GhResult(["line1", "line2"], 1)
    gh = FakeGhClient(create_result)
    messages: list[str] = []

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        emit=messages.append,
    )

    assert outcome.exit_code == 1
    assert fs.moves == []
    assert fs.files[potential] == original_content
    assert gh.calls
    verb, (title, body, label) = gh.calls[0]
    assert verb == "create"
    assert title == "Feature: Feature Title"
    assert label == "feature"
    assert "## Problem / Why\nwhy" in body
    assert "## Proposed Behavior\n(not provided in potential file)" in body
    assert "## Acceptance Criteria\n(not provided in potential file)" in body
    assert "## Constraints & Risks\n(not provided in potential file)" in body
    assert "## Test Conditions\n(not provided in potential file)" in body
    assert potential.relative_to(workspace).as_posix() in body
    assert "line1" in messages and "line2" in messages


def test_promote_potential_feature_missing_label_recovers_and_moves_file() -> None:
    """Verify feature promotion recovers from a missing-label create failure."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/missing-feature-label.md"
    fs = FakeFileSystem()
    fs.files[potential] = _build_feature_potential_content("Missing Feature Label")

    create_results = [
        mod.GhResult(["could not add label: 'feature' not found"], 1),
        mod.GhResult(["Created: https://example.com/issues/321"], 0),
    ]
    view_result = mod.GhResult(
        [
            '{"number":321,"title":"t","url":"https://example.com/issues/321","author":{"login":"me"},"updatedAt":"2024-04-05T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_results, view_result=view_result)

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    assert outcome.exit_code == 0
    assert outcome.destination == (
        workspace / "docs/features/potential/promoted/missing-feature-label.md"
    )
    create_calls = [call for call in gh.calls if call[0] == "create"]
    assert len(create_calls) == 2
    assert gh.ensure_label_calls == ["feature"]
    assert all(call[1][2] == "feature" for call in create_calls)
    assert (potential, outcome.destination) in fs.moves


# fmt: off
def test_promote_potential_feature_existing_label_uses_single_issue_create_attempt(
) -> None:
# fmt: on
    """Verify existing feature labels stay on the single create path."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/existing-feature-label.md"
    fs = FakeFileSystem()
    fs.files[potential] = _build_feature_potential_content("Existing Feature Label")

    create_result = mod.GhResult(["Created: https://example.com/issues/322"], 0)
    view_result = mod.GhResult(
        [
            '{"number":322,"title":"t","url":"https://example.com/issues/322","author":{"login":"me"},"updatedAt":"2024-04-05T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result=view_result)

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    assert outcome.exit_code == 0
    create_calls = [call for call in gh.calls if call[0] == "create"]
    assert len(create_calls) == 1
    assert create_calls[0][1][2] == "feature"
    assert gh.ensure_label_calls == []


def test_promote_potential_bug_builds_issue_body_from_bug_sections() -> None:
    """Verify bug promotion renders all bug sections into the created issue body."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/sample-bug.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Sample Bug (Potential Bug)",
            "## Summary",
            "summary details",
            "## Environment",
            "- OS: Linux",
            "## Steps to Reproduce",
            "1. step one",
            "## Expected Behavior",
            "expected results",
            "## Actual Behavior",
            "actual results",
            "## Impact / Severity",
            "medium",
            "## Logs / Screenshots",
            "screenshot attached",
        ]
    )

    create_result = mod.GhResult(["Created: https://example.com/issues/200"], 0)
    view_result = mod.GhResult(
        [
            '{"number":200,"title":"Bug title","url":"https://example.com/issues/200","author":{"login":"me"},"updatedAt":"2024-02-01T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result)

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    assert outcome.exit_code == 0
    verb, (title, body, label) = gh.calls[0]
    assert verb == "create"
    assert title == "Bug: Sample Bug"
    assert label == "bug"
    assert "## Summary\nsummary details" in body
    assert "## Environment\n- OS: Linux" in body
    assert "## Steps to Reproduce\n1. step one" in body
    assert "## Expected Behavior\nexpected results" in body
    assert "## Actual Behavior\nactual results" in body
    assert "## Impact / Severity\nmedium" in body
    assert "## Logs / Screenshots\nscreenshot attached" in body
    assert "## Source\nFrom: docs/features/potential/sample-bug.md" in body


def test_promote_potential_bug_missing_sections_use_placeholders() -> None:
    """Verify missing bug sections are filled with placeholder text."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/placeholder-bug.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(["# Placeholder Bug", "## Summary", "only summary"])

    create_result = mod.GhResult(["Created: https://example.com/issues/300"], 0)
    gh = FakeGhClient(create_result)

    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    _, (_, body, _) = gh.calls[0]
    assert "## Summary\nonly summary" in body
    assert "## Environment\n(not provided in potential file)" in body
    assert "## Steps to Reproduce\n(not provided in potential file)" in body
    assert "## Expected Behavior\n(not provided in potential file)" in body
    assert "## Actual Behavior\n(not provided in potential file)" in body
    assert "## Impact / Severity\n(not provided in potential file)" in body
    assert "## Logs / Screenshots\n(not provided in potential file)" in body


def test_promote_potential_normalizes_smart_punctuation_in_issue_body_and_title() -> (
    None
):
    """Verify smart punctuation is normalized in generated issue title/body."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/smart.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# “Curly” Feature (Potential Bug)",
            "## Summary",
            (
                "Title uses “smart” quotes and an en dash – "
                "plus non-breaking space\u00a0here."
            ),
            "## Environment",
            "- OS: “Windows”\u00a0",
            "## Steps to Reproduce",
            "1. step one with “quote”",
            "## Expected Behavior",
            "expected with em dash — and quote “",
            "## Actual Behavior",
            "actual with smart apostrophe ’",
            "## Impact / Severity",
            "medium",
            "## Logs / Screenshots",
            "none",
        ]
    )

    create_result = mod.GhResult(["Created: https://example.com/issues/400"], 0)
    view_result = mod.GhResult(
        [
            '{"number":400,"title":"t","url":"https://example.com/issues/400","author":{"login":"me"},"updatedAt":"2024-03-01T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result)

    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    verb, (title, body, label) = gh.calls[0]
    assert verb == "create"
    assert label == "bug"

    assert "Curly" in title and "“" not in title and "”" not in title
    assert "smart" in body and "“" not in body and "”" not in body
    assert "–" not in body and "—" not in body
    assert "\u00a0" not in body


def test_promote_potential_raises_on_missing_file() -> None:
    """Verify promotion raises when potential path cannot be found."""
    fs = FakeFileSystem()
    with pytest.raises(mod.PromotionError):
        mod.promote_potential(
            "/missing.md", fs=fs, gh=FakeGhClient(mod.GhResult([], 0))
        )


def test_promote_potential_rejects_invalid_promotion_type() -> None:
    """Verify invalid promotion types are rejected with a PromotionError."""
    fs = FakeFileSystem()
    invalid_path = Path("/workspace/tmp/file.md")
    fs.files[invalid_path] = "# Title"
    with pytest.raises(mod.PromotionError):
        mod.promote_potential(
            str(invalid_path),
            promotion_type="invalid",
            fs=fs,
            gh=FakeGhClient(mod.GhResult([], 0)),
        )


def test_promote_potential_checks_authentication_before_proceeding() -> None:
    """Verify that promotion succeeds when gh is authenticated."""
    content = (
        "# Test Feature (Potential)\n"
        "- Author: test\n"
        "- Date: 2024-01-01\n"
        "- Status: potential\n"
        "\n"
        "## Problem / Why\n"
        "Test problem\n"
        "\n"
        "## Proposed Behavior\n"
        "Test behavior\n"
        "\n"
        "## Acceptance Criteria (early draft)\n"
        "Test criteria\n"
        "\n"
        "## Constraints & Risks\n"
        "Test constraints\n"
        "\n"
        "## Test Conditions to Consider\n"
        "Test conditions\n"
    )

    fs = FakeFileSystem()
    potential_path = Path("docs/features/potential/test.md")
    fs.files[potential_path] = content

    create_result = mod.GhResult(["Created: https://example.com/issues/123"], 0)
    view_result = mod.GhResult(
        ['{\n  "number": 123,\n  "updatedAt": "2024-01-01T00:00:00Z"\n}'],
        0,
    )
    gh = FakeGhClient(create_result, view_result, authenticated=True)

    outcome = mod.promote_potential(
        str(potential_path),
        fs=fs,
        gh=gh,
        workspace=Path("/fake/workspace"),
    )

    assert outcome.exit_code == 0
    assert gh.calls[0][0] == "create"
    assert "Test problem" in gh.calls[0][1][1]


def test_promote_potential_fails_fast_when_not_authenticated() -> None:
    """Verify that promotion fails with clear message when gh is not authenticated."""
    content = "# Test Feature\n## Problem / Why\nTest problem\n"

    fs = FakeFileSystem()
    potential_path = Path("docs/features/potential/test.md")
    fs.files[potential_path] = content

    create_result = mod.GhResult(["should not be called"], 1)
    gh = FakeGhClient(create_result, authenticated=False)

    with pytest.raises(
        mod.PromotionError,
        match="GitHub CLI is not authenticated. Run 'gh auth login' first.",
    ):
        mod.promote_potential(
            str(potential_path),
            fs=fs,
            gh=gh,
            workspace=Path("/fake/workspace"),
        )

    assert (
        len(gh.calls) == 0
    ), "No gh commands should be executed when not authenticated"


def test_real_gh_client_invokes_subprocess(monkeypatch: pytest.MonkeyPatch) -> None:
    """Verify RealGhClient uses subprocess calls for auth/create/view operations."""
    calls: list[list[str]] = []

    def fake_which(name: str) -> str:
        """Return deterministic fake gh executable path for monkeypatched lookup."""
        return "/usr/bin/gh"

    class DummyCompleted:
        """Simple completed-process stand-in for subprocess monkeypatching."""

        def __init__(self, code: int, stdout: str = "", stderr: str = "") -> None:
            """Capture return code and output fields used by client logic."""
            self.returncode = code
            self.stdout = stdout
            self.stderr = stderr

    def fake_run(args: list[str], **kwargs: object) -> DummyCompleted:
        """Capture subprocess args and return deterministic completion values."""
        calls.append(list(args))
        if "auth" in args:
            return DummyCompleted(0, "ok", "")
        return DummyCompleted(0, "output", "")

    monkeypatch.setattr(mod.shutil, "which", fake_which)
    monkeypatch.setattr(mod.subprocess, "run", fake_run)

    client = mod.RealGhClient()
    assert client.is_authenticated() is True
    create = client.issue_create("Title", "Body", "feature")
    ensure_label = client.ensure_label("feature")
    view = client.issue_view("5")
    assert create.exit_code == 0 and ensure_label.exit_code == 0 and view.exit_code == 0
    assert any("issue" in call for call in calls)
    assert any(call[:3] == ["/usr/bin/gh", "label", "create"] for call in calls)


def test_real_gh_client_raises_when_missing(monkeypatch: pytest.MonkeyPatch) -> None:
    """Verify RealGhClient fails fast when gh executable cannot be resolved."""

    def missing(_: str) -> None:
        """Return None to simulate an unresolved gh executable path."""
        return None

    monkeypatch.setattr(mod.shutil, "which", missing)
    with pytest.raises(FileNotFoundError):
        mod.RealGhClient()


def test_real_filesystem_round_trip() -> None:
    """Verify fake filesystem round-trip semantics without temp filesystem usage."""
    fs = FakeFileSystem()
    target = Path("/virtual/nested/file.txt")
    fs.ensure_dir(target.parent)
    fs.write_text(target, "content")
    assert fs.read_text(target) == "content"
    dest = target.parent / "moved.txt"
    fs.move(target, dest)
    assert fs.read_text(dest) == "content"


def test_parse_args_and_main_paths(monkeypatch: pytest.MonkeyPatch) -> None:
    """Verify argument parsing and main success-path exit behavior."""
    potential = Path("/virtual/p.md")
    args = [
        "prog",
        "--potential-path",
        str(potential),
        "--promotion-type",
        "epic",
        "--work-mode",
        "minor-audit",
    ]
    monkeypatch.setattr(sys, "argv", args)
    parsed = mod.parse_args()
    assert parsed.potential_path == str(potential)
    assert parsed.promotion_type == "epic"
    assert parsed.work_mode == "minor-audit"

    fake_args = SimpleNamespace(
        potential_path=str(potential), promotion_type="feature", work_mode="full"
    )

    def fake_parse_args() -> SimpleNamespace:
        """Provide deterministic parsed arguments for main-path testing."""
        return fake_args

    def fake_promote(
        potential_path: str, promotion_type: str, work_mode: str
    ) -> mod.PromotionOutcome:
        """Return a successful promotion outcome for main-path testing."""
        assert work_mode in {"full", "minor-audit", "full-feature", "full-bug"}
        return mod.PromotionOutcome(0, [], None)

    monkeypatch.setattr(mod, "parse_args", fake_parse_args)
    monkeypatch.setattr(mod, "promote_potential", fake_promote)
    with pytest.raises(SystemExit) as exc:
        mod.main()
    assert exc.value.code == 0


def test_main_exits_on_promotion_error(monkeypatch: pytest.MonkeyPatch) -> None:
    """Verify main exits with non-zero status on promotion failures."""
    fake_args = SimpleNamespace(
        potential_path=str(Path("/virtual/p.md")),
        promotion_type="feature",
        work_mode="full",
    )

    def fake_parse_args() -> SimpleNamespace:
        """Provide deterministic parsed args for failure-path testing."""
        return fake_args

    monkeypatch.setattr(mod, "parse_args", fake_parse_args)

    def raise_error(**kwargs: object) -> object:
        """Raise PromotionError to exercise main error handling."""
        raise mod.PromotionError("boom")

    monkeypatch.setattr(mod, "promote_potential", raise_error)
    with pytest.raises(SystemExit) as exc:
        mod.main()
    assert exc.value.code == 1


def test_promote_potential_minor_audit_adds_required_issue_sections() -> None:
    """Verify minor-audit mode emits required issue section headings."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/minor.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Minor Audit Feature",
            "- File: scripts/dev_tools/potential_to_issue.py",
            "- File: tests/scripts/dev_tools/test_potential_to_issue.py",
            "- Risk: low",
            "## Problem / Why",
            "problem",
            "## Proposed Behavior",
            "intent",
            "## Acceptance Criteria (early draft)",
            "- [ ] done",
            "## Constraints & Risks",
            "low integration risk",
            "## Test Conditions to Consider",
            "verify this",
        ]
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/55"], 0), mod.GhResult([], 0)
    )
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
    )
    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    assert "## Implementation Intent" in body
    assert "## Verification Steps" in body
    assert "## Evidence Checklist" in body


def test_promote_potential_bug_honors_explicit_minor_audit() -> None:
    """Verify bug promotions honor explicit minor-audit selection."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/bug-minor.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Bug Minor Audit",
            "## Problem / Why",
            "problem",
            "## Proposed Behavior",
            "behavior",
            "## Acceptance Criteria (early draft)",
            "criteria",
            "## Constraints & Risks",
            "constraints",
            "## Test Conditions to Consider",
            "tests",
        ]
    )
    messages: list[str] = []
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/58"], 0), mod.GhResult([], 0)
    )
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
        emit=messages.append,
    )
    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    # After the branch reorder a bug promotion routes to the bug body even in
    # minor-audit mode, so the body carries bug headings (not the minor-audit
    # "Implementation Intent" section) while still recording the selected mode.
    assert "## Summary" in body
    assert "## Implementation Intent" not in body
    assert any("Selected mode: minor-audit" in m for m in messages)
    assert not any("Fallback reason:" in m for m in messages)


def test_promote_potential_bug_minor_audit_uses_bug_body() -> None:
    """Verify a bug potential in minor-audit mode renders the bug-headed body (AC-3)."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/minor-bug.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Minor Audit Bug",
            "## Summary",
            "summary details",
            "## Environment",
            "- OS: Linux",
            "## Steps to Reproduce",
            "1. step one",
            "## Expected Behavior",
            "expected results",
            "## Actual Behavior",
            "actual results",
            "## Logs / Screenshots",
            "screenshot attached",
            "## Impact / Severity",
            "medium",
        ]
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/401"], 0),
        mod.GhResult([], 0),
    )

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
    )

    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    # The bug body must lead with the minor-audit marker and carry authored
    # bug-section content, not the minor-audit/feature-oriented placeholders.
    assert body.splitlines()[0] == "- Work Mode: minor-audit"
    assert "## Summary\nsummary details" in body
    assert "## Environment\n- OS: Linux" in body
    assert "## Steps to Reproduce\n1. step one" in body
    assert "## Expected Behavior\nexpected results" in body
    assert "## Actual Behavior\nactual results" in body
    assert "## Logs / Screenshots\nscreenshot attached" in body
    assert "## Impact / Severity\nmedium" in body
    assert "## Implementation Intent" not in body
    assert "## Verification Steps" not in body
    assert "(not provided in potential file)" not in body


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

    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    lines = body.splitlines()
    first_section_index = lines.index("## Problem / Why")
    assert first_section_index > 0
    assert lines[first_section_index - 1] == "- Work Mode: minor-audit"


def test_work_mode_marker_honors_explicit_minor_audit() -> None:
    """Verify explicit minor-audit requests persist a minor-audit marker."""
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
        work_mode="minor-audit",
    )

    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    lines = body.splitlines()
    first_section_index = lines.index("## Problem / Why")
    assert first_section_index > 0
    assert lines[first_section_index - 1] == "- Work Mode: minor-audit"


def test_promote_potential_persists_explicit_selected_work_mode() -> None:
    """Verify explicit selection persists as minor-audit."""
    test_work_mode_marker_honors_explicit_minor_audit()


def test_promote_potential_minor_audit_honors_explicit_user_selection() -> None:
    """Verify explicit minor-audit selection is honored."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/not-eligible.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Not Eligible",
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
    messages: list[str] = []
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/77"], 0), mod.GhResult([], 0)
    )
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
        emit=messages.append,
    )
    assert outcome.exit_code == 0
    assert any("Selected mode: minor-audit" in m for m in messages)
    assert not any("Fallback reason:" in m for m in messages)


def test_promote_potential_full_mode_preserves_existing_body_contract() -> None:
    """Verify legacy full alias preserves the full-feature body contract."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/full-mode.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Full Mode",
            "## Problem / Why",
            "problem",
            "## Proposed Behavior",
            "behavior",
            "## Acceptance Criteria (early draft)",
            "criteria",
            "## Constraints & Risks",
            "constraints",
            "## Test Conditions to Consider",
            "tests",
        ]
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/99"], 0), mod.GhResult([], 0)
    )
    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="full",
    )
    body = gh.calls[0][1][1]
    assert "- Work Mode: full-feature" in body
    assert "## Proposed Behavior" in body
    assert "## Implementation Intent" not in body


def test_promote_potential_full_alias_normalizes_bug_to_full_bug() -> None:
    """Verify legacy full alias normalizes to full-bug for bug promotions."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/full-bug-mode.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Full Bug Mode",
            "## Summary",
            "summary",
            "## Expected Behavior",
            "expected",
            "## Actual Behavior",
            "actual",
        ]
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/100"], 0),
        mod.GhResult([], 0),
    )

    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="full",
    )

    body = gh.calls[0][1][1]
    assert "- Work Mode: full-bug" in body
    assert "## Summary" in body
    assert "## Proposed Behavior" not in body


def test_promote_potential_body_omits_token_like_secret_strings() -> None:
    """Verify generated issue bodies do not include token-like secret substrings."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/security.md"
    fs = FakeFileSystem()
    fs.files[potential] = (
        "# Security\n"
        "## Problem / Why\n"
        "no tokens\n"
        "## Proposed Behavior\n"
        "no tokens\n"
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/12"], 0), mod.GhResult([], 0)
    )
    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
    )
    body = gh.calls[0][1][1]
    assert "ghp_" not in body
    assert "xoxb-" not in body
    assert "AIza" not in body
