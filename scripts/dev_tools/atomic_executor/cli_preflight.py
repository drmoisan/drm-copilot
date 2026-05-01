"""Preflight QC helpers for atomic executor CLI."""

from __future__ import annotations

import shutil
import subprocess
from dataclasses import dataclass
from typing import TYPE_CHECKING, cast

from scripts.dev_tools.atomic_executor.pytest_expectations import (
    ResolvedTestExpectations,
    parse_jest_failure_output,
    parse_pytest_failure_output,
    resolve_checked_test_expectations,
    split_jest_expected_ref,
)
from scripts.dev_tools.atomic_executor.qc_toolchain import (
    TOOLCHAIN_COMMANDS,
    QCToolchain,
)

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.atomic_executor.plan_parser import PlanParser

MISSING_EXECUTABLE_PREFIX = "Required executable not found on PATH:"


@dataclass(frozen=True)
class PreflightQCResult:
    """Result of a pre-flight QC run with captured output."""

    success: bool
    output: str
    failed_step: str | None = None
    toolchain: QCToolchain = QCToolchain.PYTHON


def resolve_plan_expectations(
    parser: PlanParser,
) -> ResolvedTestExpectations | None:
    """Resolve checked plan expectations for preflight gating."""
    plan = parser.parse()
    expectations = resolve_checked_test_expectations(plan)
    if (
        not expectations.expected_fail_refs
        and not expectations.expected_pass_refs
        and not expectations.expected_fail_jest_refs
        and not expectations.expected_pass_jest_refs
        and not expectations.missing_test_refs
    ):
        return None
    return expectations


def resolve_preflight_toolchains(parser: PlanParser) -> list[QCToolchain]:
    """Resolve toolchains to run during preflight and phase gates."""
    detected_attr = getattr(parser, "detected_qc_toolchains", None)
    if not callable(detected_attr):
        return [QCToolchain.PYTHON]

    detected_raw = detected_attr()
    if not isinstance(detected_raw, set):
        return [QCToolchain.PYTHON]
    detected = cast("set[QCToolchain]", detected_raw)
    if not detected:
        return [QCToolchain.PYTHON]

    ordering = {QCToolchain.PYTHON: 0, QCToolchain.TYPESCRIPT: 1}
    return sorted(detected, key=lambda tool: ordering.get(tool, 99))


def _resolve_executable(argv: list[str]) -> list[str]:
    """Resolve the executable for a command by validating PATH lookup."""
    if not argv:
        raise ValueError("Command argv must not be empty.")

    exe = shutil.which(argv[0])
    if not exe:
        raise FileNotFoundError(f"{MISSING_EXECUTABLE_PREFIX} {argv[0]}")

    return [exe, *argv[1:]]


def _matches_expected_ref(nodeid: str, expected_refs: set[str]) -> bool:
    """Check whether a failing nodeid matches any expected ref prefix."""
    return any(nodeid.startswith(expected_ref) for expected_ref in expected_refs)


def _jest_test_matches_expected(test_name: str, expected_refs: set[str]) -> bool:
    """Check whether a Jest test name matches any expected ref pattern."""
    for expected_ref in expected_refs:
        _, test_pattern = split_jest_expected_ref(expected_ref)
        if test_pattern and test_pattern in test_name:
            return True
    return False


def _jest_file_matches_expected(file_path: str, expected_refs: set[str]) -> bool:
    """Check whether a Jest file path matches any expected ref file path."""
    for expected_ref in expected_refs:
        expected_file, _ = split_jest_expected_ref(expected_ref)
        if expected_file and expected_file == file_path:
            return True
    return False


def run_preflight_qc_with_capture(
    workspace: Path,
    *,
    expectations: ResolvedTestExpectations | None = None,
    toolchain: QCToolchain = QCToolchain.PYTHON,
) -> PreflightQCResult:
    """Run full QC toolchain and capture combined output."""
    if toolchain is QCToolchain.PYTHON:
        steps = [
            ("black", ["poetry", "run", "black", "--check", "."]),
            ("ruff", ["poetry", "run", "ruff", "check"]),
            ("pyright", ["poetry", "run", "pyright"]),
            (
                "pytest",
                [
                    "poetry",
                    "run",
                    "pytest",
                    "--color=no",
                    "--cov=src/lexile_corpus_tuner",
                    "--cov=scripts/dev_tools",
                    "--cov-report=term-missing",
                ],
            ),
        ]
        test_step_name = "pytest"
        expected_refs = (
            set[str]()
            if expectations is None
            else expectations.expected_fail_refs | expectations.expected_pass_refs
        )
    elif toolchain is QCToolchain.TYPESCRIPT:
        steps = [
            ("format", TOOLCHAIN_COMMANDS[QCToolchain.TYPESCRIPT]["format"]),
            ("lint", TOOLCHAIN_COMMANDS[QCToolchain.TYPESCRIPT]["lint"]),
            ("typecheck", TOOLCHAIN_COMMANDS[QCToolchain.TYPESCRIPT]["typecheck"]),
            ("test-unit", TOOLCHAIN_COMMANDS[QCToolchain.TYPESCRIPT]["test-unit"]),
        ]
        test_step_name = "test-unit"
        expected_refs = (
            set[str]()
            if expectations is None
            else expectations.expected_fail_jest_refs
            | expectations.expected_pass_jest_refs
        )
    else:
        raise RuntimeError(f"Unsupported QC toolchain: {toolchain}")

    all_output: list[str] = []
    if expectations is not None and expectations.missing_test_refs:
        missing_refs = ", ".join(expectations.missing_test_refs)
        message = (
            "Missing test reference for expectation-tagged tasks: " f"{missing_refs}"
        )
        return PreflightQCResult(
            success=False,
            output=message,
            failed_step=f"{test_step_name}-collect",
            toolchain=toolchain,
        )

    for step_name, cmd in steps:
        all_output.append(f"=== {step_name.upper()} ===")

        if (
            toolchain is QCToolchain.PYTHON
            and step_name == "pytest"
            and expectations is not None
            and expected_refs
        ):
            all_output.append("=== PYTEST COLLECT ===")
            collect_cmd = [
                "poetry",
                "run",
                "pytest",
                "--collect-only",
                "--color=no",
                *sorted(expected_refs),
            ]
            try:
                resolved_collect_cmd = _resolve_executable(collect_cmd)
            except FileNotFoundError as exc:
                all_output.append(str(exc))
                return PreflightQCResult(
                    success=False,
                    output="\n\n".join(all_output),
                    failed_step="pytest-collect",
                    toolchain=toolchain,
                )
            collect_result = subprocess.run(  # noqa: S603
                resolved_collect_cmd,
                cwd=workspace,
                capture_output=True,
                text=True,
                errors="replace",
            )
            collect_output = (collect_result.stdout or "") + (
                collect_result.stderr or ""
            )
            all_output.append(
                collect_output.strip() if collect_output else "(no output)"
            )
            if collect_result.returncode != 0:
                return PreflightQCResult(
                    success=False,
                    output="\n\n".join(all_output),
                    failed_step="pytest-collect",
                    toolchain=toolchain,
                )

        try:
            resolved_cmd = _resolve_executable(cmd)
        except FileNotFoundError as exc:
            all_output.append(str(exc))
            return PreflightQCResult(
                success=False,
                output="\n\n".join(all_output),
                failed_step=step_name,
                toolchain=toolchain,
            )
        result = subprocess.run(  # noqa: S603
            resolved_cmd,
            cwd=workspace,
            capture_output=True,
            text=True,
            errors="replace",
        )
        combined = (result.stdout or "") + (result.stderr or "")
        all_output.append(combined.strip() if combined else "(no output)")

        if result.returncode != 0:
            if step_name != test_step_name or expectations is None:
                return PreflightQCResult(
                    success=False,
                    output="\n\n".join(all_output),
                    failed_step=step_name,
                    toolchain=toolchain,
                )

            if toolchain is QCToolchain.PYTHON:
                summary = parse_pytest_failure_output(combined)
                if summary.has_collection_error:
                    all_output.append(
                        "Pytest collection/import errors detected; failing QC."
                    )
                    return PreflightQCResult(
                        success=False,
                        output="\n\n".join(all_output),
                        failed_step=step_name,
                        toolchain=toolchain,
                    )

                unexpected_failures: list[str] = []
                expected_pass_hits: list[str] = []
                for nodeid in summary.failed_nodeids:
                    if _matches_expected_ref(nodeid, expectations.expected_pass_refs):
                        expected_pass_hits.append(nodeid)
                        unexpected_failures.append(nodeid)
                    elif _matches_expected_ref(nodeid, expectations.expected_fail_refs):
                        continue
                    else:
                        unexpected_failures.append(nodeid)

                if unexpected_failures:
                    all_output.append("Unexpected pytest failures detected.")
                    if expected_pass_hits:
                        all_output.append(
                            "Expected-pass override applied to: "
                            + ", ".join(expected_pass_hits)
                        )
                    return PreflightQCResult(
                        success=False,
                        output="\n\n".join(all_output),
                        failed_step=step_name,
                        toolchain=toolchain,
                    )

                all_output.append(
                    "Expected pytest failures allowed: "
                    + ", ".join(sorted(summary.failed_nodeids))
                )
            elif toolchain is QCToolchain.TYPESCRIPT:
                summary = parse_jest_failure_output(combined)
                if summary.has_runtime_error:
                    all_output.append("Jest runtime errors detected; failing QC.")
                    return PreflightQCResult(
                        success=False,
                        output="\n\n".join(all_output),
                        failed_step=step_name,
                        toolchain=toolchain,
                    )
                if not summary.failed_tests and not summary.failed_files:
                    all_output.append("Jest failures could not be parsed; failing QC.")
                    return PreflightQCResult(
                        success=False,
                        output="\n\n".join(all_output),
                        failed_step=step_name,
                        toolchain=toolchain,
                    )

                unexpected_failures: list[str] = []
                expected_pass_hits: list[str] = []

                if summary.failed_tests:
                    for test_name in summary.failed_tests:
                        if _jest_test_matches_expected(
                            test_name, expectations.expected_pass_jest_refs
                        ):
                            expected_pass_hits.append(test_name)
                            unexpected_failures.append(test_name)
                        elif _jest_test_matches_expected(
                            test_name, expectations.expected_fail_jest_refs
                        ):
                            continue
                        else:
                            unexpected_failures.append(test_name)
                else:
                    for file_path in summary.failed_files:
                        if _jest_file_matches_expected(
                            file_path, expectations.expected_pass_jest_refs
                        ):
                            expected_pass_hits.append(file_path)
                            unexpected_failures.append(file_path)
                        elif _jest_file_matches_expected(
                            file_path, expectations.expected_fail_jest_refs
                        ):
                            continue
                        else:
                            unexpected_failures.append(file_path)

                if unexpected_failures:
                    all_output.append("Unexpected Jest failures detected.")
                    if expected_pass_hits:
                        all_output.append(
                            "Expected-pass override applied to: "
                            + ", ".join(expected_pass_hits)
                        )
                    return PreflightQCResult(
                        success=False,
                        output="\n\n".join(all_output),
                        failed_step=step_name,
                        toolchain=toolchain,
                    )

                all_output.append(
                    "Expected Jest failures allowed: "
                    + ", ".join(sorted(summary.failed_tests or summary.failed_files))
                )

    return PreflightQCResult(
        success=True,
        output="\n\n".join(all_output),
        toolchain=toolchain,
    )


def build_preflight_qc_fix_prompt(
    workspace: Path,
    qc_output: str,
    *,
    toolchain: QCToolchain = QCToolchain.PYTHON,
) -> str:
    """Build prompt directing Copilot to fix pre-flight QC failures."""
    if toolchain is QCToolchain.PYTHON:
        command_lines = "\n".join(
            [
                "   - `poetry run black .`",
                "   - `poetry run ruff check`",
                "   - `poetry run pyright`",
                "   - `poetry run pytest --cov=src/lexile_corpus_tuner "
                "--cov=scripts/dev_tools --cov-report=term-missing`",
            ]
        )
    elif toolchain is QCToolchain.TYPESCRIPT:
        command_lines = "\n".join(
            [
                "   - `npm run format`",
                "   - `npm run lint`",
                "   - `npm run typecheck`",
                "   - `npm run test:unit`",
            ]
        )
    else:
        raise RuntimeError(f"Unsupported QC toolchain: {toolchain}")

    return (
        "# Pre-flight QC Fix Required\n\n"
        "The atomic executor detected baseline QC failures before task execution.\n"
        "You must fix these issues before the plan can proceed.\n\n"
        f"**Workspace:** `{workspace.as_posix()}`\n\n"
        "## Failed QC Output\n\n"
        "```\n"
        f"{qc_output}\n"
        "```\n\n"
        "## Your Instructions\n\n"
        "1. Analyze the QC failures above.\n"
        "2. Make the minimal code changes required to fix each issue.\n"
        "3. **Run the full QC toolchain yourself** to verify your fixes:\n"
        f"{command_lines}\n"
        "4. If any step fails, fix the issues and re-run from step 3.\n"
        "5. **Do NOT end your turn until all QC steps pass.**\n"
        "6. Once all checks pass, reply with a brief summary of what you fixed.\n\n"
        "**CRITICAL:** You must iterate until QC passes completely. "
        "The executor will verify QC independently after you yield control.\n"
    )
