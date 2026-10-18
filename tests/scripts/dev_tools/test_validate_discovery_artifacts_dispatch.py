"""Unit tests for the discovery-artifact CLI dispatcher and console-script wrappers.

Purpose:
    Exercise `_validate_from_args`, `main`, and the eight `main_<artifact>()`
    console-script wrappers end-to-end (argv -> dispatch -> exit code ->
    stdout/stderr), using in-memory stubs for file I/O and schema loading per
    the repository's no-temp-file, no-network unit-test policy.

    Shared builders (such as `build_read_text_stub`) live in
    `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py`.
"""

from __future__ import annotations

import argparse
import json
import sys
from typing import TYPE_CHECKING, cast

import pytest

import scripts.dev_tools.validate_discovery_artifacts as validator
from tests.discovery_runtime.test_profile_v2 import profile_text
from tests.scripts.dev_tools.test_validate_discovery_schema_artifacts import (
    fixture_text,
)
from tests.scripts.dev_tools.validate_orchestration_artifacts_test_support import (
    build_read_text_stub,
)

if TYPE_CHECKING:
    from collections.abc import Callable

    from _pytest.monkeypatch import MonkeyPatch


def test_validate_from_args_returns_unsupported_artifact_type(
    monkeypatch: MonkeyPatch,
) -> None:
    """An unrecognized artifact_type should report a specific error."""
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub("ignored"))

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
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(profile_text()))

    exit_code = validator.main(["profile", "ignored.yaml"])

    assert exit_code == 0
    captured = capsys.readouterr()
    assert captured.out.strip() == "profile validation passed: ignored.yaml"


def test_main_profile_returns_one_for_missing_authoritative_profile_contract(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A profile fixture missing the required field should exit 1 with detail."""
    monkeypatch.setattr(
        validator, "_read_text", build_read_text_stub("other_key: value\n")
    )

    exit_code = validator.main(["profile", "ignored.yaml"])

    assert exit_code == 1
    captured = capsys.readouterr()
    assert "Expected exact schema_version 2.0.0" in captured.err


def test_main_feature_contract_returns_zero_for_conforming_fixture(
    monkeypatch: MonkeyPatch,
) -> None:
    """A real frozen feature contract dispatched through the CLI exits zero."""
    monkeypatch.setattr(
        validator,
        "_read_text",
        build_read_text_stub(fixture_text("feature-contract")),
    )

    assert validator.main(["feature-contract", "ignored.json"]) == 0


def test_main_feature_contract_returns_one_for_non_conforming_fixture(
    monkeypatch: MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """The authoritative expected schema retains missing-acceptance diagnostics."""
    document = cast("dict[str, object]", json.loads(fixture_text("feature-contract")))
    del document["acceptance_criteria"]
    monkeypatch.setattr(
        validator, "_read_text", build_read_text_stub(json.dumps(document))
    )

    exit_code = validator.main(["feature-contract", "ignored.json"])

    assert exit_code == 1
    assert "acceptance_criteria" in capsys.readouterr().err


def test_main_all_returns_zero_when_path_conforms_to_at_least_one_type(
    monkeypatch: MonkeyPatch,
) -> None:
    """`all` should exit 0 when the path conforms to at least one type."""
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(profile_text()))

    exit_code = validator.main(["all", "ignored.yaml"])

    assert exit_code == 0


def test_main_all_returns_one_with_aggregated_errors_when_nothing_conforms(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """`all` should exit 1 with per-type-prefixed errors when nothing conforms."""
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(""))

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
