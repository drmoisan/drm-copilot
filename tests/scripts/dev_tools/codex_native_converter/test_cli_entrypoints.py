"""Tests for the converter CLI helper and entrypoint surface."""

from __future__ import annotations

import runpy
from pathlib import Path
from typing import Any, cast

import pytest
import typer

from scripts.dev_tools.codex_native_converter import cli
from scripts.dev_tools.codex_native_converter.engine import ConversionRunResult
from scripts.dev_tools.codex_native_converter.models import (
    RunOptions,
    ValidationFinding,
)
from scripts.dev_tools.codex_native_converter.reporting import ReportSetPaths

# Pyright correctly enforces private-module access. These tests intentionally
# exercise the private helpers that dominate package coverage, so they route
# through an Any-typed alias to keep the production module surface unchanged.
CLI_HELPERS = cast("Any", cli)


def _fixture_root(fixture_name: str) -> Path:
    """Resolve one committed converter fixture root."""

    return (
        Path(__file__).resolve().parents[4]
        / "tests"
        / "fixtures"
        / "codex_native_converter"
        / fixture_name
    )


def _build_result(*, blocking: bool, wrote_destination: bool) -> ConversionRunResult:
    """Construct one converter result value for CLI tests."""

    report_root = Path("virtual/report-root")
    findings = (
        ValidationFinding(
            code="blocking-test-finding",
            severity="error",
            blocking=True,
            source_path="source/runtime.md",
            target_path="AGENTS.md",
            message="Synthetic blocking finding for CLI tests.",
            recommended_action="Keep the test harness deterministic.",
        ),
    )

    return ConversionRunResult(
        mapping_records=(),
        validation_findings=findings if blocking else (),
        report_paths=ReportSetPaths(
            conversion_report=report_root / "conversion-report.md",
            mapping_catalog=report_root / "mapping-catalog.json",
            validation_results=report_root / "validation-results.json",
            proposed_tree_root=report_root / "proposed-tree",
        ),
        generated_output={},
        wrote_destination=wrote_destination,
    )


def test_resolve_source_ecosystem_rejects_unsupported_value() -> None:
    """Reject unsupported source ecosystems with the documented CLI message."""

    with pytest.raises(typer.BadParameter, match="source_ecosystem must be"):
        CLI_HELPERS._resolve_source_ecosystem("unsupported")


# This test covers the shared review/apply option normalizer because the final
# coverage target was dominated by uncovered CLI validation branches.
def test_resolve_run_options_validates_inputs_and_sets_default_artifact_root() -> None:
    """Validate required inputs and default the artifact root beneath source_root."""

    fixture_root = _fixture_root("github_copilot")

    with pytest.raises(typer.BadParameter, match="source_root must point"):
        CLI_HELPERS._resolve_run_options(
            mode="review",
            source_root=fixture_root / "missing",
            source_ecosystem="github-copilot",
            selected_paths=[],
            destination_root=None,
            artifact_root=None,
            enable_repo_prompts=False,
        )

    with pytest.raises(typer.BadParameter, match="apply mode requires"):
        CLI_HELPERS._resolve_run_options(
            mode="apply",
            source_root=fixture_root,
            source_ecosystem="github-copilot",
            selected_paths=[],
            destination_root=None,
            artifact_root=None,
            enable_repo_prompts=False,
        )

    result = CLI_HELPERS._resolve_run_options(
        mode="review",
        source_root=fixture_root,
        source_ecosystem="github-copilot",
        selected_paths=[fixture_root / ".github"],
        destination_root=None,
        artifact_root=None,
        enable_repo_prompts=True,
    )

    assert result.mode == "review"
    assert result.source_root == fixture_root.resolve()
    assert result.artifact_root == (
        fixture_root.resolve() / "artifacts" / "codex-native-converter"
    )
    assert result.selected_paths == (fixture_root / ".github",)
    assert result.enable_repo_prompts is True


def test_print_run_summary_reports_pass_and_blocking_failures(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Print the documented pass and fail summary formats."""

    CLI_HELPERS._print_run_summary(
        _build_result(blocking=False, wrote_destination=False)
    )
    pass_output = capsys.readouterr().out

    assert "Artifact root: virtual/report-root" in pass_output
    assert "Validation outcome: pass" in pass_output

    CLI_HELPERS._print_run_summary(
        _build_result(blocking=True, wrote_destination=False)
    )
    fail_output = capsys.readouterr().out

    assert "Validation outcome: fail (1 blocking findings)" in fail_output


# This test covers the review command body because direct invocation keeps the
# assertions deterministic without invoking external processes.
def test_review_command_builds_run_options_and_prints_summary(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Build review-mode options and print the required summary lines."""

    fixture_root = _fixture_root("github_copilot")
    captured: dict[str, RunOptions] = {}

    def _fake_run_review_mode(run_options: RunOptions) -> ConversionRunResult:
        captured["run_options"] = run_options
        return _build_result(blocking=False, wrote_destination=False)

    monkeypatch.setattr(cli, "run_review_mode", _fake_run_review_mode)

    cli.review(
        source_root=fixture_root,
        source_ecosystem="github-copilot",
        selected_path=[fixture_root / ".github"],
        artifact_root=Path("virtual/review-artifacts"),
        enable_repo_prompts=True,
    )

    run_options = captured["run_options"]
    assert run_options.mode == "review"
    assert run_options.source_root == fixture_root.resolve()
    assert run_options.artifact_root == Path("virtual/review-artifacts").resolve()
    assert run_options.destination_root is None
    assert run_options.enable_repo_prompts is True
    assert "Validation outcome: pass" in capsys.readouterr().out


# This test covers both apply command branches because the CLI must exit nonzero
# when apply mode finds blocking validation failures and writes no destination.
def test_apply_command_reports_success_and_exits_on_blocking_failures(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Run the apply command through both success and blocking-exit branches."""

    fixture_root = _fixture_root("github_copilot")
    destination_root = Path("virtual/destination")
    captured: list[RunOptions] = []

    def _fake_run_apply_mode(run_options: RunOptions) -> ConversionRunResult:
        captured.append(run_options)
        return _build_result(
            blocking=len(captured) > 1,
            wrote_destination=len(captured) == 1,
        )

    monkeypatch.setattr(cli, "run_apply_mode", _fake_run_apply_mode)

    cli.apply(
        source_root=fixture_root,
        source_ecosystem="github-copilot",
        destination_root=destination_root,
        selected_path=[],
        artifact_root=Path("virtual/apply-artifacts"),
        enable_repo_prompts=False,
    )

    first_run_options = captured[0]
    assert first_run_options.mode == "apply"
    assert first_run_options.destination_root == destination_root.resolve()
    assert "Validation outcome: pass" in capsys.readouterr().out

    with pytest.raises(typer.Exit) as exit_info:
        cli.apply(
            source_root=fixture_root,
            source_ecosystem="github-copilot",
            destination_root=destination_root,
            selected_path=[],
            artifact_root=Path("virtual/apply-artifacts"),
            enable_repo_prompts=False,
        )

    assert exit_info.value.exit_code == 1
    assert "Validation outcome: fail (1 blocking findings)" in capsys.readouterr().out


def test_main_delegates_to_typer_app(monkeypatch: pytest.MonkeyPatch) -> None:
    """Delegate the console-script entry point to the Typer application."""

    calls: list[str] = []

    def _fake_app() -> None:
        calls.append("called")

    monkeypatch.setattr(cli, "app", _fake_app)

    cli.main()

    assert calls == ["called"]


def test_module_main_delegates_to_cli_main(monkeypatch: pytest.MonkeyPatch) -> None:
    """Delegate package module execution to the CLI entry point."""

    calls: list[str] = []

    def _fake_main() -> int:
        calls.append("called")
        return 0

    monkeypatch.setattr(cli, "main", _fake_main)

    with pytest.raises(SystemExit) as exit_info:
        runpy.run_module(
            "scripts.dev_tools.codex_native_converter", run_name="__main__"
        )

    assert exit_info.value.code == 0
    assert calls == ["called"]
