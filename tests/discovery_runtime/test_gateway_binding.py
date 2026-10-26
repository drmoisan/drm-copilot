"""Exercise the gateway entrypoint's outer repository binding without files or Git."""

from __future__ import annotations

import io
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from types import ModuleType
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import gateway
from drm_copilot_discovery.gateway_local import LocalServiceIO
from drm_copilot_discovery.repository_reader import LocalGitReader

from tests.discovery_runtime.gateway_test_support import (
    NOW,
    REQUEST,
    MemoryExecutor,
    result_for,
)
from tests.discovery_runtime.test_activation_store import ConfigurationCase
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
from tests.discovery_runtime.test_doctor import IDENTITY

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.repository_reader import RepositoryReader


@pytest.mark.parametrize("with_repository", [False, True])
def test_main_binds_one_outer_reader_to_the_fixed_service(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    with_repository: bool,
) -> None:
    """The real entrypoint reaches only its fixed import and exact trusted ports.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. with_repository
    (bool): whether to bind a repository reader. Returns None; memory-only effects;
    AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    executor = MemoryExecutor(result_for())
    module = ModuleType("drm_copilot_discovery.service")
    module.__dict__["execute"] = executor
    monkeypatch.setitem(sys.modules, module.__name__, module)
    factories: list[RepositoryReader | None] = []

    def create(
        root: str, repository: RepositoryReader | None, principal: str, author: str
    ) -> LocalServiceIO:
        """Bind storage to the exact outer repository reader. root (str):
        trusted absolute canonical workspace. repository (RepositoryReader | None):
        exact optional repository reader. principal (str): explicit outer principal;
        host is unavailable. author (str): explicit author selected by outer options.
        Returns LocalServiceIO; memory-only effects; AssertionError on mismatch.
        """
        assert root == case.disk.root and principal == "local-user"
        assert author == "test-user"
        factories.append(repository)
        return LocalServiceIO(
            activation=case.service,
            repository=repository,
            principal="local-user",
            author_id=author,
            identity=lambda: IDENTITY,
        )

    class FixedDatetime:
        """Replace only the trusted entrypoint clock for deterministic forwarding."""

        @staticmethod
        def now(zone: object) -> datetime:
            """Return a fixed UTC instant without reading the wall clock. zone (object):
            expected UTC clock zone. Returns datetime; memory-only effects;
            AssertionError on mismatch.
            """
            assert zone is timezone.utc
            return NOW

    bindings: list[tuple[str, str | None]] = []

    def bind(root: str, repository_id: str | None) -> RepositoryReader | None:
        """Record the outer binding request; return a reader only for an explicit id.

        root (str): trusted workspace. repository_id (str | None): outer option.
        Returns RepositoryReader | None; memory-only effects; Git is never run.
        """
        bindings.append((root, repository_id))
        if repository_id is None:
            return None
        return LocalGitReader(
            workspace_root=root, repository_id=repository_id, run=forbidden_git
        )

    def forbidden_git(argv: tuple[str, ...], *, output_limit: int) -> bytes:
        """Reject Git execution during binding. argv (tuple[str, ...]) and
        output_limit (int) are the attempted call. Raises AssertionError always.
        """
        raise AssertionError((argv, output_limit))

    monkeypatch.setattr(gateway, "installed_local_io", create)
    monkeypatch.setattr(gateway, "installed_repository", bind)
    monkeypatch.setattr("drm_copilot_discovery.gateway.datetime", FixedDatetime)
    arguments = [
        "--workspace-root",
        case.disk.root,
        "--principal",
        "local-user",
        "--author-id",
        "test-user",
    ]
    if with_repository:
        arguments.extend(("--repository-id", "consumer-repository"))
    output, errors = io.StringIO(), io.StringIO()

    code = gateway.main(
        arguments, stdin=io.BytesIO(REQUEST), stdout=output, stderr=errors
    )

    assert code == 0 and not errors.getvalue()
    assert len(factories) == 1 and len(executor.calls) == 1
    assert (factories[0] is not None) == with_repository
    expected_id = "consumer-repository" if with_repository else None
    assert bindings == [(case.disk.root, expected_id)]
    assert executor.calls[0][2] is factories[0]
    assert executor.calls[0][1].initialization.repository is factories[0]
    assert output.getvalue() == executor.result.to_json()


def test_main_reports_a_binding_read_failure_as_service_io(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A failed configured-repository derivation is an I/O refusal with exit 2.
    monkeypatch (pytest.MonkeyPatch): test-local restoration of the binding seam.
    Returns None; memory-only effects; AssertionError on mismatch.
    """

    # The outer root must be absolute on the current platform to reach the binding.
    workspace = Path(Path.cwd().anchor, "workspace").as_posix()

    def fail(root: str, repository_id: str | None) -> RepositoryReader | None:
        """Raise the modeled read failure for root (str), repository_id (str | None)."""
        assert root == workspace and repository_id is None
        raise PermissionError("private-state-path")

    monkeypatch.setattr(gateway, "installed_repository", fail)
    output, errors = io.StringIO(), io.StringIO()

    code = gateway.main(
        ["--workspace-root", workspace, "--principal", "local-user"],
        stdin=io.BytesIO(REQUEST),
        stdout=output,
        stderr=errors,
    )

    document = json.loads(output.getvalue())
    # Unknown operation/mode context always carries the fixed exit 2 envelope.
    assert code == 2 and document["exit_code"] == 2
    assert document["findings"][0]["code"] == "SERVICE_IO"
    assert "private-state-path" not in output.getvalue() + errors.getvalue()
