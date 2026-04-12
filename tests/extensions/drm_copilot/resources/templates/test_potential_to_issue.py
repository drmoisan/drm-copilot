"""Tests for the extension-bundled potential_to_issue.py wrapper template."""

from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path
from typing import TYPE_CHECKING, cast
from unittest.mock import MagicMock, patch

import pytest

if TYPE_CHECKING:
    from types import ModuleType

# Workspace root is five levels above this file:
# tests/extensions/drm_copilot/resources/templates/<this file>
ROOT = Path(__file__).resolve().parents[5]
BUNDLED_SCRIPTS_DIR = ROOT / "extensions" / "drm-copilot" / "resources" / "scripts"
BUNDLED_RUNTIME_PATH = BUNDLED_SCRIPTS_DIR / "dev_tools" / "potential_to_issue.py"

_TEMPLATE_PATH = (
    ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "templates"
    / "potential_to_issue.py"
)


def _load_module_from_path(module_name: str, file_path: Path) -> ModuleType:
    """Load a Python module directly from a file path for wrapper import tests.

    Args:
        module_name: Unique name to register in sys.modules for this load.
        file_path: Absolute path to the .py file to load.

    Returns:
        The loaded module object.

    Raises:
        AssertionError: If a module spec cannot be created for the given path.
    """
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    if spec is None or spec.loader is None:
        raise AssertionError(f"Unable to load module spec for {file_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules.pop(module_name, None)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


def _load_bundled_runtime_module(module_name: str) -> ModuleType:
    """Load the bundled runtime module with its local scripts directory on sys.path.

    Args:
        module_name: Unique module name used for the temporary import.

    Returns:
        The loaded bundled runtime module.

    Raises:
        AssertionError: If the runtime module cannot be loaded from disk.
    """
    scripts_dir = str(BUNDLED_SCRIPTS_DIR)
    if scripts_dir not in sys.path:
        sys.path.insert(0, scripts_dir)
    _ = module_name
    return _load_module_from_path("dev_tools.potential_to_issue", BUNDLED_RUNTIME_PATH)


def _clear_bundled_runtime_modules(module_name: str) -> None:
    """Remove temporary bundled runtime imports after each direct module test."""
    sys.modules.pop(module_name, None)
    sys.modules.pop("dev_tools.potential_to_issue", None)
    sys.modules.pop("dev_tools.potential_to_issue_content", None)
    sys.modules.pop("dev_tools.prompt_mode_contract", None)


class FakeFileSystem:
    """In-memory filesystem fake for bundled runtime promotion tests."""

    def __init__(self) -> None:
        """Initialize in-memory file content, directory, and move tracking."""
        self.files: dict[Path, str] = {}
        self.dirs: set[Path] = set()
        self.moves: list[tuple[Path, Path]] = []

    def resolve_path(self, path_str: str) -> Path:
        """Resolve fake paths without touching the local filesystem."""
        return Path(path_str)

    def exists(self, path: Path) -> bool:
        """Return whether the fake path currently exists in memory."""
        return path in self.files

    def read_text(self, path: Path) -> str:
        """Read fake file content from in-memory storage."""
        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        """Persist fake file content in memory."""
        self.files[path] = content

    def write_lines(self, path: Path, lines: list[str]) -> None:
        """Persist line collections as newline-joined fake file content."""
        self.files[path] = "\n".join(lines)

    def ensure_dir(self, path: Path) -> None:
        """Track fake directory creation requests."""
        self.dirs.add(path)

    def move(self, src: Path, dest: Path) -> None:
        """Move fake file content and record the requested destination."""
        if src not in self.files:
            raise FileNotFoundError(src)
        self.files[dest] = self.files[src]
        del self.files[src]
        self.moves.append((src, dest))
        self.dirs.add(dest.parent)


class FakeGhClient:
    """Deterministic gh client fake for bundled runtime promotion tests."""

    def __init__(
        self,
        create_result: object | list[object],
        view_result: object | None = None,
        label_result: object | None = None,
        authenticated: bool = True,
    ) -> None:
        """Capture fake gh results and record all runtime client calls."""
        self.create_results: list[object] = (
            list(cast("list[object]", create_result))
            if isinstance(create_result, list)
            else [create_result]
        )
        self.view_result = view_result
        self.label_result = label_result
        self.authenticated = authenticated
        self.calls: list[tuple[str, tuple[str, ...]]] = []
        self.ensure_label_calls: list[str] = []

    def is_authenticated(self) -> bool:
        """Return the preconfigured authentication state."""
        return self.authenticated

    def issue_create(self, title: str, body: str, promotion_type: str) -> object:
        """Record issue-create requests and return the configured fake result."""
        self.calls.append(("create", (title, body, promotion_type)))
        if len(self.create_results) > 1:
            return self.create_results.pop(0)
        return self.create_results[0]

    def ensure_label(self, label: str) -> object:
        """Record label-ensure requests and return the configured fake result."""
        self.ensure_label_calls.append(label)
        self.calls.append(("ensure_label", (label,)))
        if self.label_result is None:
            raise AssertionError("label_result must be configured for ensure_label")
        return self.label_result

    def issue_view(self, issue_number: str) -> object:
        """Record issue-view requests and return the configured fake result."""
        self.calls.append(("view", (issue_number,)))
        if self.view_result is None:
            raise AssertionError("view_result must be configured for issue_view")
        return self.view_result


def _create_gh_result(module: ModuleType, output: list[str], exit_code: int) -> object:
    """Instantiate the bundled runtime's GhResult dataclass.

    Args:
        module: Loaded bundled runtime module.
        output: Fake gh output lines.
        exit_code: Fake gh exit code.

    Returns:
        The runtime module's GhResult instance.
    """
    gh_result_type = module.GhResult
    return gh_result_type(output, exit_code)


def _build_feature_potential_content(feature_name: str) -> str:
    """Return minimal feature content for bundled runtime promotion tests."""
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


def test_imports_bundled_module() -> None:
    """Verify the wrapper imports successfully and exposes a ``main`` entrypoint."""
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_pti_imports",
            _TEMPLATE_PATH,
        )
        assert hasattr(module, "main")
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_imports", None)


def test_ensure_path_adds_scripts_dir_to_sys_path() -> None:
    """Verify _ensure_bundled_scripts_import_path inserts the scripts dir at index 0.

    When the computed scripts directory is absent from sys.path the function must
    insert it at position 0 so that bundled modules are resolved before any
    conflicting names on the wider path.
    """
    # Derive the scripts dir the same way the wrapper does at runtime.
    expected_scripts_dir = str(_TEMPLATE_PATH.resolve().parent.parent / "scripts")
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_pti_ensure_adds",
            _TEMPLATE_PATH,
        )
        # Remove the scripts dir from sys.path so the guard branch fires.
        sys.path[:] = [p for p in sys.path if p != expected_scripts_dir]

        module._ensure_bundled_scripts_import_path()

        assert (
            expected_scripts_dir in sys.path
        ), f"Expected {expected_scripts_dir!r} to be added to sys.path"
        assert (
            sys.path[0] == expected_scripts_dir
        ), "Scripts dir must be prepended (index 0) for correct import precedence"
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_ensure_adds", None)


def test_ensure_path_skips_duplicate_entry() -> None:
    """Verify _ensure_bundled_scripts_import_path does not duplicate an existing entry.

    When the scripts dir is already present in sys.path the function must leave
    sys.path unchanged so that no duplicate entry is introduced.
    """
    expected_scripts_dir = str(_TEMPLATE_PATH.resolve().parent.parent / "scripts")
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_pti_ensure_skip",
            _TEMPLATE_PATH,
        )
        # Guarantee the scripts dir IS present so the guard branch is skipped.
        if expected_scripts_dir not in sys.path:
            sys.path.insert(0, expected_scripts_dir)

        count_before = sys.path.count(expected_scripts_dir)
        module._ensure_bundled_scripts_import_path()
        count_after = sys.path.count(expected_scripts_dir)

        assert (
            count_after == count_before
        ), "sys.path must not gain a duplicate entry for the scripts dir"
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_ensure_skip", None)


def test_main_invokes_bundled_entrypoint_and_returns_zero() -> None:
    """Verify main() imports the bundled module, invokes its main, and returns 0.

    The bundled ``dev_tools.potential_to_issue`` module is mocked to avoid
    exercising real CLI argument parsing.  The test asserts on the return value and
    on the single call to the bundled entrypoint.
    """
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_pti_main_test",
            _TEMPLATE_PATH,
        )
        # Build a mock bundled module whose .main attribute is separately trackable.
        mock_bundled = MagicMock()
        mock_bundled.main = MagicMock()

        # Patch importlib.import_module on the importlib object the wrapper holds so
        # that the bundled module is never actually imported or executed.
        with patch.object(module.importlib, "import_module", return_value=mock_bundled):
            result = module.main()

        assert result == 0, "main() must always return 0 on success"
        mock_bundled.main.assert_called_once()
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_main_test", None)


def test_bundled_runtime_feature_missing_label_recovers_and_moves_file() -> None:
    """Verify the bundled runtime recovers from the missing feature-label failure."""
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_missing_label")
        workspace = Path("/workspace")
        potential = workspace / "docs/features/potential/missing-feature-label.md"
        fs = FakeFileSystem()
        fs.files[potential] = _build_feature_potential_content("Missing Feature Label")

        create_results = [
            _create_gh_result(module, ["could not add label: 'feature' not found"], 1),
            _create_gh_result(module, ["Created: https://example.com/issues/321"], 0),
        ]
        view_result = _create_gh_result(
            module,
            [
                '{"number":321,"title":"t","url":"https://example.com/issues/321","author":{"login":"me"},"updatedAt":"2024-04-05T00:00:00Z"}',
            ],
            0,
        )
        label_result = _create_gh_result(module, ["feature label ensured"], 0)
        gh = FakeGhClient(
            create_results,
            view_result=view_result,
            label_result=label_result,
        )

        outcome = module.promote_potential(
            potential_path=str(potential),
            promotion_type="feature",
            fs=fs,
            gh=gh,
            workspace=workspace,
        )

        assert outcome.exit_code == 0
        expected_destination = (
            workspace / "docs/features/potential/promoted/missing-feature-label.md"
        )
        assert outcome.destination == expected_destination
        create_calls = [call for call in gh.calls if call[0] == "create"]
        assert len(create_calls) == 2
        assert gh.ensure_label_calls == ["feature"]
        assert (potential, expected_destination) in fs.moves
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_runtime_missing_label", None)
        sys.modules.pop("dev_tools.potential_to_issue", None)
        sys.modules.pop("dev_tools.potential_to_issue_content", None)
        sys.modules.pop("dev_tools.prompt_mode_contract", None)


def test_bundled_runtime_feature_existing_label_uses_single_issue_create_attempt() -> (
    None
):
    """Verify the bundled runtime preserves the existing-label single-create path."""
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_existing_label")
        workspace = Path("/workspace")
        potential = workspace / "docs/features/potential/existing-feature-label.md"
        fs = FakeFileSystem()
        fs.files[potential] = _build_feature_potential_content("Existing Feature Label")

        create_result = _create_gh_result(
            module,
            ["Created: https://example.com/issues/322"],
            0,
        )
        view_result = _create_gh_result(
            module,
            [
                '{"number":322,"title":"t","url":"https://example.com/issues/322","author":{"login":"me"},"updatedAt":"2024-04-05T00:00:00Z"}',
            ],
            0,
        )
        label_result = _create_gh_result(module, ["feature label ensured"], 0)
        gh = FakeGhClient(
            create_result,
            view_result=view_result,
            label_result=label_result,
        )

        outcome = module.promote_potential(
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
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_runtime_existing_label", None)
        sys.modules.pop("dev_tools.potential_to_issue", None)
        sys.modules.pop("dev_tools.potential_to_issue_content", None)
        sys.modules.pop("dev_tools.prompt_mode_contract", None)


def test_bundled_runtime_real_gh_client_wraps_subprocess_calls() -> None:
    """Verify RealGhClient resolves gh once and builds each gh subprocess call."""
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_real_gh")
        subprocess_results = [
            MagicMock(returncode=0),
            MagicMock(stdout="created\n", stderr="warning\n", returncode=0),
            MagicMock(stdout="label ensured\n", stderr="", returncode=0),
            MagicMock(stdout='{"number":123}\n', stderr="", returncode=0),
        ]

        with (
            patch.object(module.shutil, "which", return_value="/usr/bin/gh"),
            patch.object(
                module.subprocess,
                "run",
                side_effect=subprocess_results,
            ) as run_mock,
        ):
            client = module.RealGhClient()

            assert client.is_authenticated() is True
            assert client.issue_create("Title", "Body", "feature").output == [
                "created",
                "warning",
            ]
            assert client.ensure_label("feature").output == ["label ensured"]
            assert client.issue_view("123").output == ['{"number":123}']

        assert run_mock.call_args_list[0].args[0] == ["/usr/bin/gh", "auth", "status"]
        assert run_mock.call_args_list[1].args[0] == [
            "/usr/bin/gh",
            "issue",
            "create",
            "--title",
            "Title",
            "--body-file",
            "-",
            "--label",
            "feature",
        ]
        assert run_mock.call_args_list[1].kwargs["input"] == "Body"
        assert run_mock.call_args_list[2].args[0] == [
            "/usr/bin/gh",
            "label",
            "create",
            "feature",
            "--color",
            module.FEATURE_LABEL_COLOR,
            "--description",
            module.FEATURE_LABEL_DESCRIPTION,
        ]
        assert run_mock.call_args_list[3].args[0] == [
            "/usr/bin/gh",
            "issue",
            "view",
            "123",
            "--json",
            "number,title,url,author,updatedAt",
        ]
    finally:
        sys.path[:] = original_sys_path
        _clear_bundled_runtime_modules("ext_pti_runtime_real_gh")


def test_bundled_runtime_real_gh_client_reports_missing_or_unresolved_path() -> None:
    """Verify RealGhClient fails fast when gh cannot be found or later becomes unset."""
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_real_gh_guard")

        with patch.object(module.shutil, "which", return_value=None):
            with pytest.raises(FileNotFoundError, match="gh CLI not found"):
                module.RealGhClient()

        client = module.RealGhClient(gh_path="gh")
        client.gh_path = None

        assert client.is_authenticated() is False
        with pytest.raises(RuntimeError, match="gh CLI path was not resolved"):
            client._run(["issue", "create"])
    finally:
        sys.path[:] = original_sys_path
        _clear_bundled_runtime_modules("ext_pti_runtime_real_gh_guard")


def test_bundled_runtime_rejects_invalid_inputs_and_preconditions() -> None:
    """Verify bundled promotion validation fails before any gh side effects."""
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_validation")
        workspace = Path("/workspace")
        potential = workspace / "docs/features/potential/preconditions.md"
        fs = FakeFileSystem()
        success_result = _create_gh_result(
            module, ["Created: https://example.com/1"], 0
        )

        with pytest.raises(module.PromotionError, match="Invalid promotion type"):
            module.promote_potential(str(potential), promotion_type="invalid")
        with pytest.raises(module.PromotionError, match="Invalid work mode"):
            module.promote_potential(str(potential), work_mode="invalid")

        unauthenticated = FakeGhClient(success_result, authenticated=False)
        with pytest.raises(module.PromotionError, match="not authenticated"):
            module.promote_potential(str(potential), fs=fs, gh=unauthenticated)
        with pytest.raises(module.PromotionError, match="Potential file not found"):
            module.promote_potential(
                str(potential),
                fs=fs,
                gh=FakeGhClient(success_result),
                workspace=workspace,
            )

        fs.files[potential] = "   \n"
        with pytest.raises(module.PromotionError, match="Potential file is empty"):
            module.promote_potential(
                str(potential),
                fs=fs,
                gh=FakeGhClient(success_result),
                workspace=workspace,
            )

        fs.files[potential] = _build_feature_potential_content("Normalization Error")
        with patch.object(
            module,
            "normalize_requested_work_mode",
            side_effect=ValueError("unsupported mode"),
        ):
            with pytest.raises(module.PromotionError, match="unsupported mode"):
                module.promote_potential(
                    str(potential),
                    fs=fs,
                    gh=FakeGhClient(success_result),
                    workspace=workspace,
                )
    finally:
        sys.path[:] = original_sys_path
        _clear_bundled_runtime_modules("ext_pti_runtime_validation")


def test_bundled_runtime_minor_audit_uses_default_checklist_on_relpath_failure() -> (
    None
):
    """Verify the minor-audit path falls back to the absolute path.

    The runtime should also inject the default evidence checklist when the source
    markdown omits the checklist section.
    """
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_minor_audit")
        workspace = Path("/workspace")
        potential = workspace / "docs/features/potential/minor-audit.md"
        fs = FakeFileSystem()
        fs.files[potential] = _build_feature_potential_content("Minor Audit Branch")
        create_result = _create_gh_result(
            module,
            ["Created: https://example.com/issues/401"],
            0,
        )
        gh = FakeGhClient(create_result, view_result=_create_gh_result(module, [], 0))

        with (
            patch.object(module.os.path, "relpath", side_effect=ValueError),
            patch.object(
                module,
                "build_minor_audit_body",
                return_value="minor audit body",
            ) as build_minor_audit_body,
        ):
            outcome = module.promote_potential(
                str(potential),
                fs=fs,
                gh=gh,
                workspace=workspace,
                work_mode="minor-audit",
            )

        assert outcome.exit_code == 0
        assert build_minor_audit_body.call_args.args[6] == (
            "- [ ] Baseline\n- [ ] End-state\n- [ ] Targeted verification"
        )
        assert build_minor_audit_body.call_args.args[7] == potential.as_posix()
    finally:
        sys.path[:] = original_sys_path
        _clear_bundled_runtime_modules("ext_pti_runtime_minor_audit")


def test_bundled_runtime_bug_failure_returns_exit_code_message_without_move() -> None:
    """Verify the bug path returns a fallback error line when gh emits no output."""
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_bug_failure")
        workspace = Path("/workspace")
        potential = workspace / "docs/features/potential/runtime-bug.md"
        fs = FakeFileSystem()
        fs.files[potential] = "# Runtime Bug\n"
        gh = FakeGhClient(_create_gh_result(module, [], 9))

        with (
            patch.object(
                module,
                "normalize_requested_work_mode",
                return_value="full-bug",
            ),
            patch.object(
                module, "build_bug_body", return_value="bug body"
            ) as build_bug_body,
        ):
            outcome = module.promote_potential(
                str(potential),
                promotion_type="bug",
                fs=fs,
                gh=gh,
                workspace=workspace,
            )

        assert outcome.exit_code == 9
        assert outcome.destination is None
        assert outcome.messages[-1] == "gh CLI exited with code 9"
        assert fs.moves == []
        assert build_bug_body.call_args.args[0] == "full-bug"
    finally:
        sys.path[:] = original_sys_path
        _clear_bundled_runtime_modules("ext_pti_runtime_bug_failure")


def test_bundled_runtime_parse_args_and_main_exit_paths(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Verify CLI parsing plus main success and user-facing error exits."""
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_cli")
        monkeypatch.setattr(
            sys,
            "argv",
            [
                "potential_to_issue.py",
                "--potential-path",
                "potential.md",
                "--promotion-type",
                "bug",
                "--work-mode",
                "full-bug",
            ],
        )

        args = module.parse_args()

        assert args == argparse.Namespace(
            potential_path="potential.md",
            promotion_type="bug",
            work_mode="full-bug",
        )
        assert module._resolve_workspace() == Path.cwd()

        monkeypatch.setattr(
            module,
            "parse_args",
            lambda: argparse.Namespace(
                potential_path="potential.md",
                promotion_type="feature",
                work_mode="full",
            ),
        )

        def _return_outcome(
            potential_path: str,
            promotion_type: str = "feature",
            *,
            fs: object | None = None,
            gh: object | None = None,
            workspace: Path | None = None,
            work_mode: str = "full",
            emit: object | None = None,
        ) -> object:
            del potential_path, promotion_type, fs, gh, workspace, work_mode, emit
            return module.PromotionOutcome(exit_code=7, messages=[])

        monkeypatch.setattr(module, "promote_potential", _return_outcome)

        with pytest.raises(SystemExit, match="7"):
            module.main()

        def _raise_promotion_error(
            potential_path: str,
            promotion_type: str = "feature",
            *,
            fs: object | None = None,
            gh: object | None = None,
            workspace: Path | None = None,
            work_mode: str = "full",
            emit: object | None = None,
        ) -> object:
            del potential_path, promotion_type, fs, gh, workspace, work_mode, emit
            raise module.PromotionError("bad input")

        monkeypatch.setattr(module, "promote_potential", _raise_promotion_error)
        with patch.object(module, "print") as print_mock:
            with pytest.raises(SystemExit, match="1"):
                module.main()

        print_mock.assert_called_once_with("bad input")
    finally:
        sys.path[:] = original_sys_path
        _clear_bundled_runtime_modules("ext_pti_runtime_cli")


def test_bundled_runtime_is_missing_label_failure_detects_known_fragment() -> None:
    """Verify _is_missing_label_failure returns True for the known error fragment."""
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_label_detect")

        # Positive: output contains the expected fragment for 'feature' label.
        assert module._is_missing_label_failure(
            ["could not add label: 'feature' not found"], "feature"
        )

        # Negative: output does not contain the fragment.
        assert not module._is_missing_label_failure(
            ["Created: https://example.com/issues/1"], "feature"
        )

        # Negative: fragment for a different label should not match 'feature'.
        assert not module._is_missing_label_failure(
            ["could not add label: 'bug' not found"], "feature"
        )

        # Positive: case-insensitive match.
        assert module._is_missing_label_failure(
            ["Could Not Add Label: 'epic' not found"], "epic"
        )
    finally:
        sys.path[:] = original_sys_path
        _clear_bundled_runtime_modules("ext_pti_runtime_label_detect")


def test_bundled_runtime_ensure_label_failure_skips_retry_and_propagates_error() -> (
    None
):
    """Verify recovery skips retry when ensure_label itself fails.

    When the first issue_create fails with a missing-label error and
    ensure_label also fails (non-zero exit), the retry is not attempted
    and the original create failure propagates to the outcome.
    """
    original_sys_path = list(sys.path)

    try:
        module = _load_bundled_runtime_module("ext_pti_runtime_ensure_fail")
        workspace = Path("/workspace")
        potential = workspace / "docs/features/potential/ensure-fail.md"
        fs = FakeFileSystem()
        fs.files[potential] = _build_feature_potential_content("Ensure Fail")

        # First create fails with missing-label error; ensure_label also fails.
        create_result = _create_gh_result(
            module, ["could not add label: 'feature' not found"], 1
        )
        label_result = _create_gh_result(module, ["label create failed"], 1)
        gh = FakeGhClient(
            create_result,
            label_result=label_result,
        )

        outcome = module.promote_potential(
            potential_path=str(potential),
            promotion_type="feature",
            fs=fs,
            gh=gh,
            workspace=workspace,
        )

        # Outcome should propagate the original create failure.
        assert outcome.exit_code == 1
        assert outcome.destination is None

        # Ensure label was attempted exactly once.
        assert gh.ensure_label_calls == ["feature"]

        # Only one create call; retry was not attempted.
        create_calls = [call for call in gh.calls if call[0] == "create"]
        assert len(create_calls) == 1

        # File should not have been moved.
        assert fs.moves == []
    finally:
        sys.path[:] = original_sys_path
        _clear_bundled_runtime_modules("ext_pti_runtime_ensure_fail")
