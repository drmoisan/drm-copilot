"""Focused tests for repository-bound epic preparation launch evidence."""

from __future__ import annotations

import hashlib
import json
from typing import TYPE_CHECKING, Any, cast

import pytest

from scripts.dev_tools.epic_planner_launch_evidence import (
    validate_epic_planner_launch_evidence,
)
from tests.scripts.dev_tools.epic_planner_launch_evidence_test_support import (
    LaunchEvidenceMemoryFileSystem,
    launch_evidence_fixture,
)

if TYPE_CHECKING:
    from scripts.dev_tools.epic_planner_readiness import EpicReadinessContext


def _files(context: EpicReadinessContext) -> dict[str, str]:
    """Return the mutable in-memory file map from a readiness context."""

    file_system = context.file_system
    assert isinstance(file_system, LaunchEvidenceMemoryFileSystem)
    return file_system.files


def _fixture() -> tuple[dict[str, Any], str, EpicReadinessContext, object]:
    """Adapt the focused evidence fixture to the readiness-test tuple shape."""

    state, context, _ = launch_evidence_fixture()
    return state, "", context, object()


def _feature(state: dict[str, Any], index: int = 0) -> dict[str, Any]:
    """Return one mutable feature from the fixture state."""

    return cast("list[dict[str, Any]]", state["features"])[index]


def _absolute(relative: str) -> str:
    """Resolve a fixture repository-relative path."""

    return f"C:/workspace/{relative}"


def _json_file(files: dict[str, str], path: str) -> dict[str, Any]:
    """Decode one mutable JSON fixture object."""

    return cast("dict[str, Any]", json.loads(files[path]))


def _write_json(files: dict[str, str], path: str, value: object) -> None:
    """Replace one JSON fixture with deterministic text."""

    files[path] = json.dumps(value)


def _receipt_path(state: dict[str, Any], index: int = 0) -> str:
    """Return the absolute receipt path for one feature."""

    return _absolute(cast("str", _feature(state, index)["launch_receipt_path"]))


def _status_path(state: dict[str, Any]) -> str:
    """Return the shared absolute wave status path."""

    return _absolute(cast("str", _feature(state)["launch_status_path"]))


def test_launch_evidence_accepts_sealed_completed_preparation_wave() -> None:
    """Accept receipts and final status emitted by the hardened launcher."""

    state, _, context, _ = _fixture()

    assert validate_epic_planner_launch_evidence(state, context) == []


@pytest.mark.parametrize(
    ("field", "replacement", "expected"),
    [
        ("issue_num", "pending:feature-101", ".issue_num must match the feature"),
        ("feature_folder", "docs/features/active/other", ".feature_folder"),
        ("delegation_id", "other", ".delegation_id"),
        ("deployment_agent", "orchestrator-c1", ".deployment_agent"),
        ("model", "gpt-5.6-luna", ".model must match"),
        ("model_reasoning_effort", "low", ".model_reasoning_effort"),
        ("execution_context", "epic_execution_child", ".execution_context"),
        ("branch_name", "feature/other", ".branch_name"),
        ("worktree_path", "/repo/worktrees/other", ".worktree_path"),
    ],
)
def test_receipt_fields_are_cross_bound_to_final_feature(
    field: str, replacement: object, expected: str
) -> None:
    """Reject receipt identity or deployment fields that drift from the feature."""

    state, _, context, _ = _fixture()
    files = _files(context)
    path = _receipt_path(state)
    receipt = _json_file(files, path)
    receipt[field] = replacement
    _write_json(files, path, receipt)

    errors = validate_epic_planner_launch_evidence(state, context)

    assert any(expected in error for error in errors)


@pytest.mark.parametrize(
    ("mutations", "expected"),
    [
        ({"schema_version": 1}, "schema 2 completed"),
        ({"state": "active"}, "schema 2 completed"),
        ({"exit_code": 1}, "exit_code must be 0"),
        ({"codex_session_id": ""}, "codex_session_id must be a non-empty"),
        ({"session_bound_at": "not-a-time"}, "session_bound_at must be"),
        ({"completed_at": "not-a-time"}, "completed_at must be"),
        (
            {
                "session_bound_at": "2026-07-11T09:00:00+00:00",
                "completed_at": "2026-07-10T09:00:00+00:00",
            },
            "completed_at must not precede",
        ),
    ],
)
def test_receipt_must_be_completed_and_session_bound(
    mutations: dict[str, object], expected: str
) -> None:
    """Reject incomplete or unsuccessful durable launch receipts."""

    state, _, context, _ = _fixture()
    files = _files(context)
    path = _receipt_path(state)
    receipt = _json_file(files, path)
    receipt.update(mutations)
    _write_json(files, path, receipt)

    errors = validate_epic_planner_launch_evidence(state, context)

    assert any(expected in error for error in errors)


def test_receipt_path_launch_id_and_spec_hash_are_immutable_bindings() -> None:
    """Reject path, launch identity, and launch-spec byte drift."""

    state, _, context, _ = _fixture()
    files = _files(context)
    path = _receipt_path(state)
    receipt = _json_file(files, path)
    receipt["receipt_path"] = (
        "C:/workspace/artifacts/orchestration/epic-child-launches/"
        "preparation/other.receipt.json"
    )
    receipt["launch_id"] = "other"
    receipt["spec_sha256"] = "0" * 64
    receipt["status_path"] = (
        "C:/workspace/artifacts/orchestration/epic-child-launches/"
        "preparation/other.status.json"
    )
    _write_json(files, path, receipt)

    errors = validate_epic_planner_launch_evidence(state, context)

    assert any("receipt_path must identify" in error for error in errors)
    assert any("launch_id must match the receipt filename" in error for error in errors)
    assert any("spec_sha256 does not match" in error for error in errors)
    assert any("exactly one specification launch" in error for error in errors)
    assert any("status_path must match the feature" in error for error in errors)


def test_launch_spec_entry_is_cross_bound_to_receipt_and_feature() -> None:
    """Reject a valid spec whose selected launch has drifted deployment fields."""

    state, _, context, _ = _fixture()
    files = _files(context)
    receipt = _json_file(files, _receipt_path(state))
    spec_path = cast("str", receipt["spec_path"])
    spec = _json_file(files, spec_path)
    launches = cast("list[dict[str, Any]]", spec["launches"])
    launches[0]["model"] = "gpt-5.6-luna"
    spec_text = json.dumps(spec)
    files[spec_path] = spec_text
    receipt["spec_sha256"] = hashlib.sha256(spec_text.encode("utf-8")).hexdigest()
    _write_json(files, _receipt_path(state), receipt)

    errors = validate_epic_planner_launch_evidence(state, context)

    assert any("specification launch.model must match" in error for error in errors)


@pytest.mark.parametrize("target", ["receipt", "status", "spec"])
def test_launch_evidence_files_are_required_and_valid_json(target: str) -> None:
    """Reject missing and malformed receipt, status, or specification evidence."""

    state, _, context, _ = _fixture()
    files = _files(context)
    receipt_path = _receipt_path(state)
    receipt = _json_file(files, receipt_path)
    paths = {
        "receipt": receipt_path,
        "status": _status_path(state),
        "spec": cast("str", receipt["spec_path"]),
    }
    path = paths[target]
    del files[path]

    missing = validate_epic_planner_launch_evidence(state, context)
    files[path] = "[]"
    malformed = validate_epic_planner_launch_evidence(state, context)

    assert any("requires" in error for error in missing)
    assert any("must be a JSON object" in error for error in malformed)


def test_shared_wave_status_must_record_exact_successful_session() -> None:
    """Reject failed, mismatched, or incomplete terminal status evidence."""

    state, _, context, _ = _fixture()
    files = _files(context)
    path = _status_path(state)
    status = _json_file(files, path)
    status.update({"schema_version": 1, "state": "failed", "failure": "boom"})
    status["wave_id"] = "other"
    launches = cast("dict[str, dict[str, Any]]", status["launches"])
    entry = launches["feature-101"]
    entry.update(
        {
            "state": "failed",
            "exit_code": 1,
            "receipt_path": (
                "C:/workspace/artifacts/orchestration/epic-child-launches/"
                "preparation/other.receipt.json"
            ),
            "codex_session_id": "other-session",
            "completed_at": "2026-07-10T09:31:00+00:00",
        }
    )
    _write_json(files, path, status)

    errors = validate_epic_planner_launch_evidence(state, context)

    assert any("schema 2 completed status" in error for error in errors)
    assert any("must not contain a failure" in error for error in errors)
    assert any("wave_id must match" in error for error in errors)
    assert any("completed with exit_code 0" in error for error in errors)
    assert any("receipt_path must match" in error for error in errors)
    assert any("codex_session_id must match" in error for error in errors)
    assert any("completed_at must match" in error for error in errors)


def test_features_must_share_one_status_with_each_launch_present() -> None:
    """Reject split status paths and a shared status missing one launch."""

    state, _, context, _ = _fixture()
    files = _files(context)
    status = _json_file(files, _status_path(state))
    cast("dict[str, object]", status["launches"]).pop("feature-101")
    _write_json(files, _status_path(state), status)
    _feature(state, 1)[
        "launch_status_path"
    ] = "artifacts/orchestration/epic-child-launches/preparation/other.json"

    errors = validate_epic_planner_launch_evidence(state, context)

    assert any("must contain launch_id" in error for error in errors)
    assert any("must share one launch_status_path" in error for error in errors)
