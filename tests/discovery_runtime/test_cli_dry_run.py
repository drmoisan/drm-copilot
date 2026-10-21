"""Verify CLI composition and selected real report plans with isolated memory ports."""

from __future__ import annotations

import io
import json
import sys
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import cli, service
from drm_copilot_discovery.cli import CliPorts, run_cli
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.service_contracts import (
    DiscoveryResult,
    ServiceArtifact,
    ServiceRuntimeError,
)

from tests.discovery_runtime.cli_test_support import CLI_WRAPPERS, invoke, memory_ports
from tests.discovery_runtime.gateway_test_support import NOW, MemoryExecutor, result_for
from tests.discovery_runtime.gateway_test_support import (
    installed_schema as installed_schema,
)
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence
    from datetime import datetime
    from typing import NoReturn, TextIO

    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.service_contracts import ServiceIO

    from tests.discovery_runtime.test_service import MemoryService


@pytest.mark.parametrize("with_repository", [False, True])
def test_canonical_identity_and_same_reader_reach_service(
    service_io: MemoryService, with_repository: bool
) -> None:
    """Bind one canonical root before IDs; retain exact reader/provider identity.

    service_io (MemoryService) isolates ports; with_repository (bool) selects an
    explicit reader. Return None after call/order/ID assertions; no real I/O.
    """
    executor = MemoryExecutor(result_for())
    events: list[object] = []

    def resolve(selected: str) -> str:
        """Record selected (str); return canonical memory root, no external I/O."""
        events.append(selected)
        return service_io.disk.root

    def create(root: str, repository: RepositoryReader | None) -> ServiceIO:
        """Record root (str) and repository (RepositoryReader | None) in memory.

        Return ServiceIO without writes; assertion failures identify bad wiring.
        """
        events.append((root, repository))
        return service_io

    ports = replace(
        memory_ports(service_io, executor), resolve_workspace=resolve, create_io=create
    )
    args = ("--repository-id", "consumer-repository") if with_repository else ()
    first = invoke(ports, argv=("--workspace-root", "alias-one", *args))
    second = invoke(ports, argv=("--workspace-root", "alias-two", *args))
    assert first == second == (0, executor.result.to_json(), "")
    assert len(events) == 4 and events[0] == "alias-one" and events[2] == "alias-two"
    expected = service_io.repository if with_repository else None
    assert events[1] == events[3] == (service_io.disk.root, expected)
    assert executor.calls[0][1] is service_io and executor.calls[0][2] is expected
    assert executor.calls[0][0] == executor.calls[1][0]
    request = cast("JsonObject", executor.calls[0][0])
    assert request["workspace_root"] == service_io.disk.root
    assert request["invocation_ref"] is None and request["authorization_ref"] is None


@pytest.mark.parametrize("exit_code", [0, 1, 2, 3])
def test_typed_service_exit_and_exact_json_survive(
    service_io: MemoryService, exit_code: int
) -> None:
    """Retain exit_code (int) from a typed result using service_io (MemoryService).

    Return None after exact serialization/exit assertions; memory streams only.
    """
    executor = MemoryExecutor(result_for(exit_code))
    code, raw, errors = invoke(memory_ports(service_io, executor))
    assert code == exit_code and raw == executor.result.to_json()
    assert raw.endswith("\n") and not raw.endswith("\n\n")
    assert bool(errors) is bool(exit_code) and len(executor.calls) == 1


@pytest.mark.parametrize("argv,code", [(("--help",), 0), (("--principal", "host"), 2)])
def test_help_and_unsupported_authority_never_call_providers(
    service_io: MemoryService, argv: tuple[str, ...], code: int
) -> None:
    """Refuse provider work for help/invalid argv with explicit local authority.

    service_io (MemoryService) supplies unused ports; argv (tuple[str, ...]) and
    code (int) select expected behavior. Return None; only memory output changes.
    """

    def forbidden(*values: object) -> NoReturn:
        """Reject any provider values (object); raise AssertionError, no effects."""
        raise AssertionError(values)

    executor = MemoryExecutor(result_for())
    ports = replace(
        memory_ports(service_io, executor),
        resolve_workspace=forbidden,
        repository_factory=forbidden,
        create_io=forbidden,
    )
    actual, raw, _ = invoke(ports, argv=argv)
    assert actual == code and raw and not executor.calls
    # Invalid arguments retain their original diagnostic alongside the fixed anchor.
    if code == 2:
        findings = json.loads(raw)["findings"]
        assert findings[0]["code"] == "CLI_ARGUMENTS" and findings[0]["pointer"] == ""
        assert findings[1]["code"] == "CLI_REQUEST" and findings[1]["pointer"] == "/"


@pytest.mark.parametrize("boundary", ["root", "canonical", "reader", "io", "runtime"])
def test_preexecution_failures_are_redacted_and_do_not_execute(
    service_io: MemoryService, boundary: str
) -> None:
    """Refuse boundary (str) failure using service_io (MemoryService) without effects.

    Return None after typed pre-execution envelope assertions; all ports are memory
    seams and failure text never reaches output.
    """
    executor = MemoryExecutor(result_for())

    def fail(*values: object) -> NoReturn:
        """Reject provider values (object) with the chosen typed error; no effects."""
        assert values
        if boundary == "runtime":
            raise ServiceRuntimeError(code="RUNTIME_CORRUPT")
        raise OSError("private-path")

    def invalid_root(selected: str) -> str:
        """Return an empty str for selected (str) root to test builder refusal.

        Selection is deliberately unresolved; no provider or external I/O occurs.
        """
        return ""

    ports = memory_ports(service_io, executor)
    # Only root resolution/build errors are invocation failures; provider errors are 3.
    if boundary in ("root", "canonical"):
        ports = replace(
            ports,
            resolve_workspace=fail if boundary == "root" else invalid_root,
        )
    elif boundary == "reader":
        ports = replace(ports, repository_factory=fail)
    else:
        ports = replace(ports, create_io=fail)
    code, raw, errors = invoke(ports, argv=("--repository-id", "consumer-repository"))
    assert code == (2 if boundary in ("root", "canonical") else 3)
    assert json.loads(raw)["runtime"] is None and not executor.calls
    assert "private-path" not in raw + errors


def test_unexpected_execution_failure_cannot_invent_empty_effects(
    service_io: MemoryService,
) -> None:
    """Keep unknown effects after executor failure using service_io (MemoryService).

    Return None after fixed stderr/no-JSON assertions. One test-owned memory write
    models an unreported effect; no external I/O occurs.
    """

    def fail(*args: object, **ports: object) -> NoReturn:
        """Record args/ports (object) then raise ValueError after a memory effect."""
        assert args and ports["io"] is service_io
        service_io.disk.store.put("unreported.txt", b"effect")
        raise ValueError("private-execution-detail")

    code, raw, errors = invoke(memory_ports(service_io, fail))
    assert code == 3 and not raw and "private-execution-detail" not in errors
    assert service_io.disk.store.files["unreported.txt"] == b"effect"


@pytest.mark.parametrize("failure", ["short", "write", "flush", "serialize"])
def test_output_failure_never_retries_json(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch, failure: str
) -> None:
    """Retain truthful output failure after service execution; never append JSON.

    service_io (MemoryService) supplies ports; monkeypatch (pytest.MonkeyPatch)
    restores serialization and failure (str) selects the stream fault. Return None;
    only memory streams/counters change.
    """

    class Broken(io.StringIO):
        """Track attempts (int) per stream and inject the selected memory fault.
        Construct fresh for each output attempt. write counts calls before its
        chosen short/error result; flush may fail. No external I/O occurs.
        """

        attempts = 0

        def write(self, text: str) -> int:
            """Write text (str) once; return count or raise OSError, memory only."""
            self.attempts += 1
            if failure == "write":
                raise OSError("private-output-detail")
            return super().write(text[:1] if failure == "short" else text)

        def flush(self) -> None:
            """Return None or raise OSError for selected flush failure; no real I/O."""
            if failure == "flush":
                raise OSError("private-output-detail")

    def reject(result: DiscoveryResult) -> NoReturn:
        """Reject result (DiscoveryResult) before writing; raise ValueError only."""
        assert result.runtime is not None
        raise ValueError("private-serialization-detail")

    if failure == "serialize":
        monkeypatch.setattr(DiscoveryResult, "to_json", reject)
    executor = MemoryExecutor(result_for())
    output, errors = Broken(), io.StringIO()
    code = run_cli(
        "doctor",
        (),
        ports=memory_ports(service_io, executor),
        stdout=output,
        stderr=errors,
        limits=ParseLimits(),
    )
    assert code == 3 and output.attempts == (0 if failure == "serialize" else 1)
    assert len(executor.calls) == 1 and "private-" not in errors.getvalue()
    # A broken diagnostic stream must preserve the failure exit without retrying JSON.
    if failure == "write":
        assert (
            run_cli(
                "doctor",
                (),
                ports=memory_ports(service_io, executor),
                stdout=Broken(),
                stderr=Broken(),
                limits=ParseLimits(),
            )
            == 3
        )


@pytest.mark.parametrize(
    "directory,repository", [(True, False), (True, True), (False, False)]
)
def test_installed_entry_binds_fixed_local_user_and_one_reader(
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
    directory: bool,
    repository: bool,
) -> None:
    """Exercise fixed installed adapters with all external effects substituted.

    service_io (MemoryService) supplies ports; monkeypatch (pytest.MonkeyPatch)
    restores adapters; directory/repository (bool) select root/reader controls.
    Return None after principal, clock and reader identity assertions; memory only.
    """
    roots: list[str] = []
    readers: list[RepositoryReader | None] = []
    executor = MemoryExecutor(result_for())

    def resolve(path: Path, *, strict: bool) -> Path:
        """Record path (Path)/strict (bool); return memory root without real I/O."""
        assert strict
        roots.append(str(path))
        return Path(service_io.disk.root)

    def create(
        root: str, reader: RepositoryReader | None, principal: str, author: str
    ) -> ServiceIO:
        """Bind root (str), reader (RepositoryReader | None) and local identity.

        principal/author (str) must be local-user. Return ServiceIO; record only
        memory references and raise AssertionError for incorrect wiring.
        """
        assert root == service_io.disk.root and principal == author == "local-user"
        readers.append(reader)
        return service_io

    class FixedClock:
        """Return the fixed UTC instant without observing machine time."""

        @staticmethod
        def now(zone: object) -> datetime:
            """Validate zone (object); return fixed datetime, no side effects."""
            assert zone is NOW.tzinfo
            return NOW

    def is_directory(path: Path) -> bool:
        """Return configured bool for path (Path) without filesystem metadata I/O."""
        return directory

    output, errors = io.StringIO(), io.StringIO()
    monkeypatch.setattr(Path, "resolve", resolve)
    monkeypatch.setattr(Path, "is_dir", is_directory)
    monkeypatch.setattr(cli, "installed_local_io", create)
    monkeypatch.setattr(cli, "datetime", FixedClock)
    monkeypatch.setattr(service, "execute", executor)
    monkeypatch.setattr(
        sys,
        "argv",
        [
            "dev.discovery.doctor",
            *(["--repository-id", "consumer-repository"] if repository else []),
        ],
    )
    monkeypatch.setattr(sys, "stdout", output)
    monkeypatch.setattr(sys, "stderr", errors)
    code = cli.main_doctor()
    assert roots == ["."] and code == (0 if directory else 2)
    # Only a valid selected directory may construct I/O or invoke the executor.
    if directory:
        assert len(readers) == len(executor.calls) == 1
        assert (
            executor.calls[0][2] is readers[0]
            and (readers[0] is not None) == repository
        )
    else:
        assert not readers and not executor.calls


@pytest.mark.parametrize("command", CLI_WRAPPERS)
def test_every_console_wrapper_uses_its_fixed_command(
    monkeypatch: pytest.MonkeyPatch, command: str
) -> None:
    """Exercise command (str) wrapper through the fixed composition seam.

    monkeypatch (pytest.MonkeyPatch) restores process/seam references. Return None
    after exact command/argv/ports assertions; no provider or external I/O occurs.
    """

    def record(
        name: str,
        argv: Sequence[str],
        *,
        ports: CliPorts,
        stdout: TextIO,
        stderr: TextIO,
        limits: ParseLimits,
    ) -> int:
        """Check name/argv (str/Sequence[str]), ports and streams; return exit 1.

        ports (CliPorts), stdout/stderr (TextIO), limits (ParseLimits) stay trusted;
        assertion failures expose wiring errors. No provider or stream is invoked.
        """
        assert name == command and tuple(argv) == ("--help",)
        assert isinstance(ports, CliPorts) and limits == ParseLimits()
        assert stdout is sys.stdout and stderr is sys.stderr
        return 1

    monkeypatch.setattr(cli, "run_cli", record)
    monkeypatch.setattr(sys, "argv", ["entry", "--help"])
    wrapper = cast("Callable[[], int]", vars(cli)["main_" + command.replace("-", "_")])
    assert wrapper() == 1


def test_process_argument_copy_is_bounded(monkeypatch: pytest.MonkeyPatch) -> None:
    """Reject oversized process argv before copying; monkeypatch restores globals.

    monkeypatch (pytest.MonkeyPatch) installs tiny ParseLimits/memory streams.
    Return None after a fixed invocation refusal, with no provider effects.
    """
    calls: list[object] = []

    def forbidden(*values: object, **options: object) -> NoReturn:
        """Record provider values/options (object); raise AssertionError on any call.

        Only the local call marker changes; no external I/O is permitted.
        """
        calls.append((values, options))
        raise AssertionError("Oversized arguments must not reach providers")

    output, errors = io.StringIO(), io.StringIO()
    monkeypatch.setattr(Path, "resolve", forbidden)
    monkeypatch.setattr(cli, "installed_local_io", forbidden)
    monkeypatch.setattr(service, "execute", forbidden)
    monkeypatch.setattr(cli, "ParseLimits", lambda: ParseLimits(artifact_records=1))
    monkeypatch.setattr(sys, "argv", ["entry", "--help", "extra"])
    monkeypatch.setattr(sys, "stdout", output)
    monkeypatch.setattr(sys, "stderr", errors)
    assert cli.main_doctor() == 2
    findings = json.loads(output.getvalue())["findings"]
    assert findings[0]["code"] == "CLI_LIMIT" and not calls
    assert findings[0]["pointer"] == "" and findings[1]["pointer"] == "/"


@pytest.mark.parametrize("dry_run", [True, False])
def test_validate_all_default_pair_uses_real_planner(
    service_io: MemoryService, dry_run: bool
) -> None:
    """Preserve default paired publication and no-effect dry runs through real service.

    service_io (MemoryService) captures effects; dry_run (bool) selects proposal or
    write. Return None after exact pair/status assertions; no external I/O occurs.
    """
    before = dict(service_io.disk.store.files)
    code, raw, errors = invoke(
        memory_ports(service_io, service.execute),
        "validate-all",
        (
            "--repository-id",
            "consumer-repository",
            *(("--dry-run",) if dry_run else ()),
        ),
    )
    result = json.loads(raw)
    assert code == 0 and not errors, result["findings"]
    # Both paths construct the guarded writer; dry-run uses only its freshness reads.
    assert len(result["artifacts"]) == 2 and service_io.writer_calls == 1
    # Both canonical views must remain paired even though the envelope format is JSON.
    assert {Path(item["path"]).suffix for item in result["artifacts"]} == {
        ".json",
        ".md",
    }
    # A dry-run pair stays planned; actual guarded publication reports created files.
    assert {item["status"] for item in result["artifacts"]} == {
        "planned" if dry_run else "created"
    }
    assert (service_io.disk.store.files == before) is dry_run


def test_failed_report_publication_keeps_selected_gate_failure(
    service_io: MemoryService,
) -> None:
    """Retain a real failed completion gate while publishing its diagnostic pair.

    service_io (MemoryService) records actual guarded effects. Return None after
    exit 1 and paired-file assertions; no external I/O or success authority occurs.
    """
    code, raw, errors = invoke(
        memory_ports(service_io, service.execute),
        "completion-report",
        (
            "--repository-id",
            "consumer-repository",
            "--mode",
            "discovery-complete",
            "--format",
            "both",
            "--write",
        ),
    )
    result = json.loads(raw)
    assert code == 1 and errors and result["summary"]["validation_result"] == "fail"
    assert len(result["artifacts"]) == 2 and service_io.writer_calls == 1
    # Every reported effect must correspond to an actual memory file.
    assert all(
        item["path"] in service_io.disk.store.files for item in result["artifacts"]
    )


def test_partial_service_failure_retains_reported_effects(
    service_io: MemoryService,
) -> None:
    """Forward typed partial effects unchanged with service_io (MemoryService).

    Return None after exit-3/exact-envelope assertions. The injected executor is
    only a transport control; it claims no real plan or publication verification.
    """
    expected = replace(
        result_for(3),
        artifacts=(
            ServiceArtifact(
                path="reports/part.json",
                kind="validation-report",
                status="created",
                sha256="c" * 64,
            ),
        ),
    )
    executor = MemoryExecutor(expected)
    code, raw, errors = invoke(memory_ports(service_io, executor))
    assert code == 3 and raw == expected.to_json() and errors
    assert json.loads(raw)["artifacts"][0]["status"] == "created"
