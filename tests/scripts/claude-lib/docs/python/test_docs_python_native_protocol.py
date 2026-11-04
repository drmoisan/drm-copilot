"""Tests for docs_python_native.protocol: validation, dispatch and response bytes."""

import io
import json
from collections.abc import Callable, Sequence
from typing import Any

import pytest
from docs_python_native.protocol import (
    EXIT_FLOOR,
    EXIT_INTERNAL,
    EXIT_INVALID,
    EXIT_OK,
    Request,
    main,
)


def _request(**overrides: object) -> dict[str, object]:
    request: dict[str, object] = {
        "protocol_version": 1,
        "analyzers": ["python-public-api", "python-architecture"],
        "source_roots": ["src"],
        "console_scripts": [],
        "files": [
            {"path": "src/pkg/b.py", "text": "def f():\n    pass\n"},
            {"path": "src/pkg/a.py", "text": "x = (\n"},
        ],
        "limits": {"max_files": 50000, "max_file_bytes": 1048576},
    }
    request.update(overrides)
    return request


def _run(
    data: bytes,
    *,
    version_info: Sequence[object] = (3, 13, 0),
    run: Callable[[Request], dict[str, object]] | None = None,
) -> tuple[int, Any, bytes]:
    stdout = io.BytesIO()
    if run is None:
        code = main(io.BytesIO(data), stdout, version_info=version_info)
    else:
        code = main(io.BytesIO(data), stdout, version_info=version_info, run=run)
    raw = stdout.getvalue()
    response: Any = json.loads(raw)
    return code, response, raw


def _encode(value: object) -> bytes:
    return json.dumps(value).encode("utf-8")


class TestValidRequest:
    def test_round_trip_reports_status_facts_and_sorted_files(self) -> None:
        code, response, raw = _run(_encode(_request()))
        assert code == EXIT_OK
        assert response["protocol_version"] == 1
        files = response["files"]
        assert [f["path"] for f in files] == ["src/pkg/a.py", "src/pkg/b.py"]
        assert files[0]["status"] == "parse-error" and files[0]["facts"] == []
        assert files[1]["status"] == "ok"
        kinds = sorted(fact["kind"] for fact in files[1]["facts"])
        assert kinds == ["architecture-component", "public-symbol"]
        assert all(byte < 0x80 for byte in raw)

    def test_import_diagnostics_are_reported_under_each_selected_analyzer(self) -> None:
        request = _request(
            files=[{"path": "src/m.py", "text": "from click import *\n"}]
        )
        _code, response, _raw = _run(_encode(request))
        files = response["files"]
        diagnostics = files[0]["diagnostics"]
        assert [(d["analyzer_id"], d["code"], d["blocking"]) for d in diagnostics] == [
            ("python-architecture", "PYTHON_IMPORT_STAR_FRAMEWORK", False),
            ("python-public-api", "PYTHON_IMPORT_STAR_FRAMEWORK", False),
        ]

    def test_all_four_analyzers_dispatch(self) -> None:
        request = _request(
            analyzers=[
                "python-cli",
                "python-http",
                "python-public-api",
                "python-architecture",
            ],
            console_scripts=[
                {
                    "name": "t",
                    "table": "project.scripts",
                    "path": "pyproject.toml",
                    "target": "m:app",
                }
            ],
            files=[
                {
                    "path": "src/m.py",
                    "text": (
                        "import typer\napp = typer.Typer()\n@app.command()\ndef go():\n"
                        "    pass\n"
                    ),
                }
            ],
        )
        code, response, _raw = _run(_encode(request))
        assert code == EXIT_OK
        files = response["files"]
        declarations = sorted(f["declaration"] for f in files[0]["facts"])
        assert declarations == ["m", "m.app", "m.go", "t go"]


class TestInvalidRequest:
    @pytest.mark.parametrize(
        "data",
        [
            b"{not json",
            b"\xff\xfe",
            b'{"protocol_version": 1, "protocol_version": 1}',
            b'{"x": NaN}',
            b"[]",
        ],
    )
    def test_malformed_bytes_are_invalid(self, data: bytes) -> None:
        code, response, _raw = _run(data)
        assert code == EXIT_INVALID
        error = response["error"]
        assert error["code"] == "request-invalid"

    @pytest.mark.parametrize(
        "overrides",
        [
            {"protocol_version": 2},
            {"protocol_version": True},
            {"extra": 1},
            {"analyzers": []},
            {"analyzers": ["python-cli", "python-cli"]},
            {"analyzers": ["config-files"]},
            {"analyzers": "python-cli"},
            {"source_roots": [1]},
            {"console_scripts": [{"name": "a"}]},
            {
                "console_scripts": [
                    {"name": "a", "table": "t", "path": "p", "target": 1}
                ]
            },
            {
                "console_scripts": [
                    {"name": "a", "table": "t", "path": "p", "target": "m:f", "x": 1}
                ]
            },
            {"files": [{"path": "a.py"}]},
            {"files": [{"path": "a.py", "text": "", "extra": 1}]},
            {"files": [{"path": "a.py", "text": ""}, {"path": "a.py", "text": ""}]},
            {"limits": {"max_files": 1}},
            {"limits": {"max_files": 1, "max_file_bytes": 1, "extra": 1}},
            {"limits": {"max_files": 0, "max_file_bytes": 1}},
            {"limits": {"max_files": True, "max_file_bytes": 1}},
            {"limits": {"max_files": 50001, "max_file_bytes": 1}},
            {"limits": {"max_files": 50000, "max_file_bytes": 10}},
            {"limits": {"max_files": 1, "max_file_bytes": 1048576}},
        ],
    )
    def test_each_request_defect_is_invalid(self, overrides: dict[str, object]) -> None:
        request = _request(**overrides)
        code, response, _raw = _run(_encode(request))
        assert code == EXIT_INVALID, overrides
        error = response["error"]
        assert "def f" not in str(error["message"])


class TestFailures:
    def test_injected_analyzer_exception_is_internal_error(self) -> None:
        def failing(_request: Request) -> dict[str, object]:
            raise KeyError("secret source text")

        code, response, _raw = _run(_encode(_request()), run=failing)
        assert code == EXIT_INTERNAL
        error = response["error"]
        assert error["code"] == "internal-error"
        assert "secret" not in str(error["message"])

    def test_interpreter_below_floor(self) -> None:
        code, response, _raw = _run(_encode(_request()), version_info=(3, 10, 14))
        assert code == EXIT_FLOOR
        error = response["error"]
        assert error["code"] == "version-below-floor"
