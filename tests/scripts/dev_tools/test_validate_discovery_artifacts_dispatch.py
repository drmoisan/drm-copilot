"""Unit tests for the discovery-artifact CLI dispatcher and console-script wrappers.

Purpose:
    Exercise `_validate_from_args`, `main`, and the eight `main_<artifact>()`
    console-script wrappers end-to-end (argv -> dispatch -> exit code ->
    stdout/stderr), using in-memory stubs for file I/O and schema loading per
    the repository's no-temp-file, no-network unit-test policy.
"""

from __future__ import annotations

import argparse
import sys
from typing import TYPE_CHECKING, cast

import pytest

import scripts.dev_tools.validate_discovery_artifacts as validator
import scripts.dev_tools.validate_discovery_schema_artifacts as discovery_schema

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    from _pytest.monkeypatch import MonkeyPatch


def _stub_read_text(text: str) -> Callable[[Path], str]:
    """Return a typed `_read_text` replacement for monkeypatched CLI tests.

    Mirrors the `build_read_text_stub` pattern in
    `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`.
    """

    def _stub(_path: Path) -> str:
        return text

    return _stub


def test_validate_from_args_returns_unsupported_artifact_type(
    monkeypatch: MonkeyPatch,
) -> None:
    """An unrecognized artifact_type should report a specific error."""
    monkeypatch.setattr(validator, "_read_text", _stub_read_text("ignored"))

    validate_from_args = cast(
        "Callable[[argparse.Namespace], list[str]]",
        vars(validator)["_validate_from_args"],
    )
    errors = validate_from_args(
        argparse.Namespace(path="ignored", artifact_type="bogus")
    )

    assert errors == ["Unsupported artifact type: bogus"]


def test_main_profile_returns_zero_for_conforming_fixture(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A conforming profile fixture should exit 0 with a single stdout line."""
    monkeypatch.setattr(
        validator, "_read_text", _stub_read_text("legacy_source_path: /x\n")
    )

    exit_code = validator.main(["profile", "ignored.yaml"])

    assert exit_code == 0
    captured = capsys.readouterr()
    assert captured.out.strip() == "profile validation passed: ignored.yaml"


def test_main_profile_returns_one_for_missing_legacy_source_path(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A profile fixture missing the required field should exit 1 with detail."""
    monkeypatch.setattr(validator, "_read_text", _stub_read_text("other_key: value\n"))

    exit_code = validator.main(["profile", "ignored.yaml"])

    assert exit_code == 1
    captured = capsys.readouterr()
    assert "legacy_source_path" in captured.err


def _permissive_feature_contract_schema(
    _uri: str, _cache_dir: Path
) -> dict[str, object]:
    """Stand in for `load_schema` requiring `acceptance_criteria`."""
    return {"type": "object", "required": ["acceptance_criteria"]}


def test_main_feature_contract_returns_zero_for_conforming_fixture(
    monkeypatch: MonkeyPatch,
) -> None:
    """A conforming feature-contract fixture dispatched via the CLI should exit 0."""
    monkeypatch.setattr(
        validator,
        "_read_text",
        _stub_read_text(
            '{"$schema": "https://example.test/feature-contract.schema.json", '
            '"acceptance_criteria": []}'
        ),
    )
    # The real schema-loading call happens inside
    # validate_discovery_schema_artifacts._validate_against_schema, so that is
    # the module whose `load_schema` binding must be patched for the patch to
    # take effect (module-level name lookup is per-module, not per-importer).
    monkeypatch.setattr(
        discovery_schema, "load_schema", _permissive_feature_contract_schema
    )
    monkeypatch.setattr(validator, "load_schema", _permissive_feature_contract_schema)

    exit_code = validator.main(["feature-contract", "ignored.json"])

    assert exit_code == 0


def test_main_feature_contract_returns_one_for_non_conforming_fixture(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A feature-contract fixture missing `acceptance_criteria` should exit 1."""
    monkeypatch.setattr(
        validator,
        "_read_text",
        _stub_read_text(
            '{"$schema": "https://example.test/feature-contract.schema.json"}'
        ),
    )
    monkeypatch.setattr(
        discovery_schema, "load_schema", _permissive_feature_contract_schema
    )
    monkeypatch.setattr(validator, "load_schema", _permissive_feature_contract_schema)

    exit_code = validator.main(["feature-contract", "ignored.json"])

    assert exit_code == 1
    captured = capsys.readouterr()
    assert "acceptance_criteria" in captured.err


def test_main_all_returns_zero_when_path_conforms_to_at_least_one_type(
    monkeypatch: MonkeyPatch,
) -> None:
    """`all` should exit 0 when the path conforms to at least one type."""
    monkeypatch.setattr(
        validator, "_read_text", _stub_read_text("legacy_source_path: /x\n")
    )

    exit_code = validator.main(["all", "ignored.yaml"])

    assert exit_code == 0


def test_main_all_returns_one_with_aggregated_errors_when_nothing_conforms(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """`all` should exit 1 with per-type-prefixed errors when nothing conforms."""
    monkeypatch.setattr(validator, "_read_text", _stub_read_text(""))

    exit_code = validator.main(["all", "ignored.yaml"])

    assert exit_code == 1
    captured = capsys.readouterr()
    assert "profile: " in captured.err
    assert "feature-contract: " in captured.err


@pytest.mark.parametrize(
    ("wrapper_name", "artifact_type"),
    [
        ("main_profile", "profile"),
        ("main_feature_contract", "feature-contract"),
        ("main_coverage_ledger", "coverage-ledger"),
        ("main_runtime_scenario", "runtime-scenario"),
        ("main_parity_matrix", "parity-matrix"),
        ("main_unspecified_behavior", "unspecified-behavior"),
        ("main_product_decision", "product-decision"),
        ("main_evidence_reference", "evidence-reference"),
    ],
)
def test_main_artifact_wrappers_dispatch_with_correct_argv_prefix(
    wrapper_name: str, artifact_type: str, monkeypatch: MonkeyPatch
) -> None:
    """Each `main_<artifact>()` wrapper should call `main` with its artifact
    type as the first argv element, forwarding the remaining `sys.argv`."""
    captured_argv: list[list[str]] = []

    def _fake_main(argv: list[str] | None = None) -> int:
        captured_argv.append(list(argv) if argv is not None else [])
        return 0

    monkeypatch.setattr(validator, "main", _fake_main)
    monkeypatch.setattr(sys, "argv", ["prog", "some.path"])

    wrapper = cast("Callable[[], int]", vars(validator)[wrapper_name])
    exit_code = wrapper()

    assert exit_code == 0
    assert captured_argv == [[artifact_type, "some.path"]]
