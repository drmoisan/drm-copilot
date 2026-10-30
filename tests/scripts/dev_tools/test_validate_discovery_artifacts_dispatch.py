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
from collections.abc import Sequence
from pathlib import Path
from typing import TYPE_CHECKING, cast, overload

import pytest
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError

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
    """Use monkeypatch (MonkeyPatch) to isolate reads; return None after refusal.

    An unknown kind preserves its specific diagnostic without filesystem I/O.
    """
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
    """With monkeypatch (MonkeyPatch) and capsys (CaptureFixture[str]), assert exit 0.

    Return None; only memory reads and captured stdout occur.
    """
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(profile_text()))

    exit_code = validator.main(["profile", "ignored.yaml"])

    assert exit_code == 0
    captured = capsys.readouterr()
    assert captured.out.strip() == "profile validation passed: ignored.yaml"


def test_main_profile_returns_one_for_missing_authoritative_profile_contract(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Use monkeypatch (MonkeyPatch), capsys (CaptureFixture[str]) for invalid input.

    Return None after checking exit 1 and retained diagnostics; no disk I/O.
    """
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
    """Use monkeypatch (MonkeyPatch) for a valid legacy contract; return None.

    Assert selected-kind success using memory input and installed schema reads.
    """
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
    """Use monkeypatch (MonkeyPatch), capsys (CaptureFixture[str]) for missing fields.

    Return None after checking authoritative diagnostics; input remains in memory.
    """
    document = cast("dict[str, object]", json.loads(fixture_text("feature-contract")))
    del document["acceptance_criteria"]
    monkeypatch.setattr(
        validator, "_read_text", build_read_text_stub(json.dumps(document))
    )

    exit_code = validator.main(["feature-contract", "ignored.json"])

    assert exit_code == 1
    assert "acceptance_criteria" in capsys.readouterr().err


def test_main_all_refuses_file_probing_before_reading(
    monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Use monkeypatch (MonkeyPatch), capsys (CaptureFixture[str]) for ambiguous all.

    Return None after exit 2 and migration guidance; no read or validator runs.
    """
    reads: list[Path] = []

    def read(path: Path) -> str:
        """Record path (Path); return valid text so an accidental read is observable."""
        reads.append(path)
        return profile_text()

    monkeypatch.setattr(validator, "_read_text", read)

    exit_code = validator.main(["all", "ignored.yaml"])

    assert exit_code == 2
    assert reads == []
    assert "validate-all --workspace-root ROOT" in capsys.readouterr().err


def test_direct_all_dispatch_is_an_actionable_refusal(
    monkeypatch: MonkeyPatch,
) -> None:
    """Use monkeypatch (MonkeyPatch) for direct Namespace dispatch; return None.

    Assert fixed selection guidance instead of per-type probing; no real I/O.
    """
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(""))
    dispatch = cast(
        "Callable[[argparse.Namespace], list[str]]",
        vars(validator)["_validate_from_args"],
    )
    assert dispatch(argparse.Namespace(path="ignored", artifact_type="all")) == [
        "Select one artifact kind or use validate-all --workspace-root ROOT"
    ]


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
    """Check wrapper_name/artifact_type (str) using monkeypatch (MonkeyPatch).

    Return None after fixed-command/exit checks; installed entry owns process argv.
    No actual service or filesystem operation runs.
    """
    calls: list[tuple[str, Sequence[str] | None]] = []

    def installed(command: str, argv: Sequence[str] | None = None) -> int:
        """Record command (str), argv (Sequence[str] | None); return typed exit 3."""
        calls.append((command, argv))
        return 3

    monkeypatch.setattr(validator, "run_installed_cli", installed)
    monkeypatch.setattr(sys, "argv", ["prog", "some.path"])

    wrapper = cast("Callable[[], int]", vars(validator)[wrapper_name])
    exit_code = wrapper()

    assert exit_code == 3
    assert calls == [("validate-" + artifact_type, None)]


@pytest.mark.parametrize(
    "arguments",
    [["all", "--workspace-root", "repo"], ["profile", "--help"], ["feature-contract"]],
)
def test_canonical_kind_route_forwards_exact_flags(
    arguments: list[str], monkeypatch: MonkeyPatch
) -> None:
    """Forward arguments (list[str]) through monkeypatch (MonkeyPatch); return None.

    Fixed installed routing retains the exit and argument values without I/O.
    """
    calls: list[tuple[str, Sequence[str] | None]] = []

    def installed(command: str, argv: Sequence[str] | None = None) -> int:
        """Record command (str), argv (Sequence[str] | None); return exit 1.

        Only the local call list changes; no I/O occurs.
        """
        calls.append((command, argv))
        return 1

    monkeypatch.setattr(validator, "run_installed_cli", installed)
    assert validator.main(arguments) == 1
    assert calls == [("validate-" + arguments[0], tuple(arguments[1:]))]


@pytest.mark.parametrize(
    "arguments", [[], ["unknown", "input"], ["profile", "input", "--write"]]
)
def test_legacy_argument_errors_do_not_read(
    arguments: list[str], monkeypatch: MonkeyPatch
) -> None:
    """Reject arguments (list[str]) with monkeypatch (MonkeyPatch); return None.

    Expected SystemExit(2) occurs before input reads or installed execution.
    """
    reads: list[Path] = []

    def read(path: Path) -> str:
        """Record path (Path), return empty text; memory effect only."""
        reads.append(path)
        return ""

    monkeypatch.setattr(validator, "_read_text", read)
    with pytest.raises(SystemExit) as error:
        validator.main(arguments)
    assert error.value.code == 2
    assert reads == []


@pytest.mark.parametrize("arguments", ["secret", 42, [None], ["\ud800"]])
def test_malformed_arguments_are_redacted(
    arguments: object, capsys: pytest.CaptureFixture[str]
) -> None:
    """Reject malformed arguments (object), capture with capsys (CaptureFixture[str]).

    Return None after exit 2 and fixed stderr; no callback, read or source echo.
    """
    assert validator.main(cast("list[str]", arguments)) == 2
    captured = capsys.readouterr()
    assert captured.out == ""
    assert (
        captured.err == "Invalid discovery arguments; use an explicit kind and --help\n"
    )


@pytest.mark.parametrize("process", [False, True])
def test_argument_count_refusal_precedes_text_measurement(
    process: bool, monkeypatch: MonkeyPatch
) -> None:
    """Use process (bool) and monkeypatch (MonkeyPatch) for invalid counts.

    Return None after ValueError; neither excessive explicit input nor absent
    process executable begins token measurement or performs I/O.
    """
    measured: list[str] = []

    def measure(_self: ReportBudget, value: str) -> None:
        """Record value (str) for _self (ReportBudget); return None.

        Only the local list changes; text is not traversed.
        """
        measured.append(value)

    monkeypatch.setattr(ReportBudget, "text", measure)
    monkeypatch.setattr(sys, "argv", [])
    arguments = None if process else ("",) * (ParseLimits().artifact_records + 1)
    with pytest.raises(ValueError, match="argument count"):
        validator.compatibility_arguments(arguments)
    assert measured == []


@pytest.mark.parametrize("length", [3, 4])
def test_argument_text_work_is_reserved_before_scan(
    length: int, monkeypatch: MonkeyPatch
) -> None:
    """Check length (int) against a counted budget using monkeypatch (MonkeyPatch).

    Return None; short capacity raises ReportLimitError before text traversal,
    while sufficient capacity returns the exact token. No external effects.
    """
    measured: list[str] = []
    original = ReportBudget.text

    def limits() -> ParseLimits:
        """Return the fixed small ParseLimits policy without I/O or mutation."""
        return ParseLimits(artifact_records=1)

    def measure(budget: ReportBudget, value: str) -> None:
        """Count value (str) for budget (ReportBudget), then measure; return None."""
        measured.append(value)
        original(budget, value)

    monkeypatch.setattr(validator, "ParseLimits", limits)
    monkeypatch.setattr(ReportBudget, "text", measure)
    token = "x" * length
    # Four characters exceed prepaid work; three retain the complete exact token.
    if length == 4:
        with pytest.raises(ReportLimitError):
            validator.compatibility_arguments([token])
        assert measured == []
    else:
        assert validator.compatibility_arguments([token]) == (token,)
        assert measured == [token]


def test_process_arguments_are_captured_without_mutation(
    monkeypatch: MonkeyPatch,
) -> None:
    """Use monkeypatch (MonkeyPatch) for process argv; return None after exact capture.

    The executable is excluded, authored Unicode preserved, and no I/O occurs.
    """
    arguments = ["command", "--input", "résumé.json"]
    monkeypatch.setattr(sys, "argv", arguments)
    assert validator.compatibility_arguments(None) == ("--input", "résumé.json")
    assert arguments == ["command", "--input", "résumé.json"]


@pytest.mark.parametrize(
    ("arguments", "legacy"),
    [
        ([], False),
        (["--help"], False),
        (["--workspace-root", "repo"], False),
        (["--input=one.json"], True),
        (["--output", "report.json"], True),
        (["--input", "one", "--help"], True),
    ],
)
def test_report_route_uses_only_explicit_options(
    arguments: list[str], legacy: bool
) -> None:
    """Classify arguments (list[str]) against legacy (bool); return None without I/O.

    Filenames cannot infer a workspace or authorize a different artifact kind.
    """
    assert validator.report_arguments(arguments, input_flags=("--input",)) == (
        tuple(arguments),
        legacy,
    )


def test_report_mixed_routes_refuse_before_callbacks() -> None:
    """Assert mixed-route ValueError; return None without callbacks or I/O."""
    with pytest.raises(ValueError, match="separately"):
        validator.report_arguments(
            ["--input", "one", "--workspace-root", "repo"], input_flags=("--input",)
        )


def test_selected_file_reader_preserves_utf8_and_errors(
    monkeypatch: MonkeyPatch,
) -> None:
    """Use monkeypatch (MonkeyPatch) for Path reads; return None after exact contracts.

    UTF-8 and original OSError identity are retained without filesystem access.
    """
    failure = OSError("sentinel")
    calls: list[tuple[Path, str | None]] = []

    def read(path: Path, encoding: str | None = None) -> str:
        """Record path (Path), encoding (str | None); return text or raise OSError.

        Only the local call list changes; no filesystem read occurs.
        """
        calls.append((path, encoding))
        if path.name == "bad":
            raise failure
        return "retained"

    monkeypatch.setattr(Path, "read_text", read)
    selected = cast("Callable[[Path], str]", vars(validator)["_read_text"])
    assert selected(Path("good")) == "retained"
    with pytest.raises(OSError) as error:
        selected(Path("bad"))
    assert error.value is failure
    assert calls == [(Path("good"), "utf-8"), (Path("bad"), "utf-8")]


def test_changing_sequence_length_cannot_expand_reserved_capture() -> None:
    """Return None after counted length/index checks; no external I/O occurs.

    A valid Sequence changes its advertised bound after the first observation.
    Capture must use that first prepaid count without extra length or item reads.
    """

    class ChangingArguments(Sequence[str]):
        """Observe one call's bound/index reads while supplying exact empty tokens.

        This memory-only sequence grows its advertised length on repeat reads.
        Counters belong to one instance; capture must neither reread the bound
        nor visit unreserved indexes. Slices are deliberately unavailable.
        """

        def __init__(self) -> None:
            """Initialize local counters; return None without external effects."""
            self.length_reads = 0
            self.index_reads: list[int] = []

        def __len__(self) -> int:
            """Count each observation; return int 1, then an excessive record count."""
            self.length_reads += 1
            return 1 if self.length_reads == 1 else ParseLimits().artifact_records + 1

        @overload
        def __getitem__(self, index: int) -> str:
            """Describe exact int lookup returning str without external effects."""
            ...

        @overload
        def __getitem__(self, index: slice) -> Sequence[str]:
            """Describe slice lookup; the concrete test seam rejects every slice."""
            ...

        def __getitem__(self, index: int | slice) -> str | Sequence[str]:
            """Count index (int), return empty str; slice raises AssertionError.

            Only local observations change; there is no I/O or external state.
            """
            if isinstance(index, slice):
                raise AssertionError("capture must use prepaid integer indexes")
            self.index_reads.append(index)
            return ""

    arguments = ChangingArguments()
    assert validator.compatibility_arguments(arguments) == ("",)
    assert arguments.length_reads == 1
    assert arguments.index_reads == [0]
