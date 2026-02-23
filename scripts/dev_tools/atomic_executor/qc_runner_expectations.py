"""Expectation-aware QC helpers for pytest and Jest execution."""

from __future__ import annotations

import subprocess
from typing import TYPE_CHECKING

from scripts.dev_tools.atomic_executor.pytest_expectations import (
    ResolvedTestExpectations,
    parse_jest_failure_output,
    parse_pytest_failure_output,
    split_jest_expected_ref,
)

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path


def matches_expected_ref(nodeid: str, expected_refs: set[str]) -> bool:
    """Return whether a pytest nodeid matches any expected reference prefix."""
    for expected_ref in expected_refs:
        if nodeid.startswith(expected_ref):
            return True
    return False


def jest_test_matches_expected(test_name: str, expected_refs: set[str]) -> bool:
    """Return whether a Jest test name matches any expected test pattern."""
    for expected_ref in expected_refs:
        _, test_pattern = split_jest_expected_ref(expected_ref)
        if test_pattern and test_pattern in test_name:
            return True
    return False


def jest_file_matches_expected(file_path: str, expected_refs: set[str]) -> bool:
    """Return whether a Jest file path matches any expected file reference."""
    for expected_ref in expected_refs:
        expected_file, _ = split_jest_expected_ref(expected_ref)
        if expected_file and expected_file == file_path:
            return True
    return False


def run_pytest_with_expectations(
    *,
    cmd: list[str],
    workspace: Path,
    resolve_executable: Callable[[list[str]], list[str]],
    expectations: ResolvedTestExpectations | None,
    env: dict[str, str] | None = None,
) -> None:
    """Run pytest and tolerate failures only when they match expected-fail refs."""
    if expectations is None:
        resolved_cmd = resolve_executable(cmd)
        subprocess.run(  # noqa: S603 - argv constructed from trusted constants
            resolved_cmd,
            cwd=workspace,
            check=True,
            capture_output=False,
            text=True,
            errors="replace",
            env=env,
        )
        return

    if expectations.missing_test_refs:
        missing_refs = ", ".join(expectations.missing_test_refs)
        raise RuntimeError(
            "Missing test reference for expectation-tagged tasks: " f"{missing_refs}"
        )

    resolved_cmd = resolve_executable(cmd)
    result = subprocess.run(  # noqa: S603 - argv constructed from trusted constants
        resolved_cmd,
        cwd=workspace,
        check=False,
        capture_output=True,
        text=True,
        errors="replace",
        env=env,
    )
    combined = (result.stdout or "") + (result.stderr or "")
    if result.returncode == 0:
        return

    summary = parse_pytest_failure_output(combined)
    if summary.has_collection_error:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)

    unexpected_failures: list[str] = []
    expected_pass_hits: list[str] = []

    for nodeid in summary.failed_nodeids:
        if matches_expected_ref(nodeid, expectations.expected_pass_refs):
            expected_pass_hits.append(nodeid)
            unexpected_failures.append(nodeid)
        elif matches_expected_ref(nodeid, expectations.expected_fail_refs):
            continue
        else:
            unexpected_failures.append(nodeid)

    if unexpected_failures or expected_pass_hits:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)


def run_jest_with_expectations(
    *,
    cmd: list[str],
    workspace: Path,
    resolve_executable: Callable[[list[str]], list[str]],
    expectations: ResolvedTestExpectations | None,
) -> None:
    """Run Jest and tolerate failures only when they match expected-fail refs."""
    if expectations is None:
        resolved_cmd = resolve_executable(cmd)
        subprocess.run(  # noqa: S603 - argv constructed from trusted constants
            resolved_cmd,
            cwd=workspace,
            check=True,
            capture_output=False,
            text=True,
            errors="replace",
        )
        return

    if expectations.missing_test_refs:
        missing_refs = ", ".join(expectations.missing_test_refs)
        raise RuntimeError(
            "Missing test reference for expectation-tagged tasks: " f"{missing_refs}"
        )

    resolved_cmd = resolve_executable(cmd)
    result = subprocess.run(  # noqa: S603 - argv constructed from trusted constants
        resolved_cmd,
        cwd=workspace,
        check=False,
        capture_output=True,
        text=True,
        errors="replace",
    )
    combined = (result.stdout or "") + (result.stderr or "")
    if result.returncode == 0:
        return

    summary = parse_jest_failure_output(combined)
    if summary.has_runtime_error:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)
    if not summary.failed_tests and not summary.failed_files:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)

    unexpected_failures: list[str] = []
    expected_pass_hits: list[str] = []

    if summary.failed_tests:
        for test_name in summary.failed_tests:
            if jest_test_matches_expected(
                test_name, expectations.expected_pass_jest_refs
            ):
                expected_pass_hits.append(test_name)
                unexpected_failures.append(test_name)
            elif jest_test_matches_expected(
                test_name, expectations.expected_fail_jest_refs
            ):
                continue
            else:
                unexpected_failures.append(test_name)
    else:
        for file_path in summary.failed_files:
            if jest_file_matches_expected(
                file_path, expectations.expected_pass_jest_refs
            ):
                expected_pass_hits.append(file_path)
                unexpected_failures.append(file_path)
            elif jest_file_matches_expected(
                file_path, expectations.expected_fail_jest_refs
            ):
                continue
            else:
                unexpected_failures.append(file_path)

    if unexpected_failures or expected_pass_hits:
        raise subprocess.CalledProcessError(result.returncode, cmd, output=combined)
