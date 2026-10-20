"""Exercise finite review regressions with deterministic memory collaborators."""

from __future__ import annotations

import io
from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import gateway_local
from drm_copilot_discovery.activation_store import ActivationStore
from drm_copilot_discovery.configuration import LOCATOR_PATH
from drm_copilot_discovery.doctor import inspect_doctor
from drm_copilot_discovery.gateway_local import LocalServiceIO
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.report_models import ReportBudget
from drm_copilot_discovery.service_contracts import DiscoveryResult

from tests.discovery_runtime.gateway_test_support import (
    MemoryDeadline,
    MemoryProcess,
    invoke,
)
from tests.discovery_runtime.gateway_test_support import (
    fixed_deadline as fixed_deadline,
)
from tests.discovery_runtime.gateway_test_support import (
    installed_schema as installed_schema,
)
from tests.discovery_runtime.test_activation_store import ConfigurationCase
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
from tests.discovery_runtime.test_doctor import IDENTITY, doctor_request

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.configuration import ConfigurationSelection


def test_unexpected_serializer_failure_refuses_replacement(
    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject an unexpected post-executor serialization failure without disclosure.

    config_catalog (SchemaCatalog) is the verified fixture; monkeypatch
    (pytest.MonkeyPatch) restores the serializer seam. Return None; assertions
    fail on wrong behavior. Only memory collaborators and streams are touched.
    """

    def fail(self: DiscoveryResult) -> str:
        """Raise a synthetic RuntimeError after a valid result; never perform I/O."""
        assert self.runtime == IDENTITY
        raise RuntimeError("private-serialization-marker")

    monkeypatch.setattr(DiscoveryResult, "to_json", fail)

    code, raw, errors, executor = invoke(config_catalog, validate_wire=False)

    assert code == 3 and raw == "" and len(executor.calls) == 1
    assert errors == "Discovery result failed unexpectedly; no replacement emitted.\n"
    assert "private-" not in raw + errors


@pytest.mark.parametrize("stage", ["before-write", "after-write", "flush"])
def test_unexpected_emission_failure_never_retries_json(
    config_catalog: SchemaCatalog, stage: str
) -> None:
    """Keep partial stdout unchanged after an unexpected write or flush failure.

    config_catalog (SchemaCatalog) supplies validation; stage (str) selects the
    memory fault. Return None; assertion failures expose a retry or disclosure.
    No external stream is used.
    """

    class FailedStream(io.StringIO):
        """Retain one proposed fragment, then fail at the selected memory boundary.

        Construct empty, allow at most one write, then inspect calls and bytes.
        No disk stream or process exists.
        """

        calls = 0

        def write(self, text: str) -> int:
            """Consume text (str), then return its length or raise RuntimeError.

            Only this instance's call count and optional partial buffer change.
            """
            self.calls += 1
            if stage == "after-write":
                super().write(text[:9])
            if stage != "flush":
                raise RuntimeError("private-output-marker")
            return super().write(text)

        def flush(self) -> None:
            """Raise RuntimeError at the selected memory flush; never touch disk."""
            raise RuntimeError("private-flush-marker")

    stream = FailedStream()

    code, raw, errors, executor = invoke(
        config_catalog, output=stream, validate_wire=False
    )

    assert code == 3 and stream.calls == 1 and len(executor.calls) == 1
    assert errors == "Discovery result failed unexpectedly; no replacement emitted.\n"
    assert "private-" not in raw + errors
    # A failed flush keeps the document; a failed write keeps only its prefix.
    if stage == "flush":
        assert raw.endswith("\n")
    else:
        assert len(raw) == (0 if stage == "before-write" else 9)


@pytest.mark.parametrize("completion", ["pending", "already-exited", "exit-race"])
def test_git_deadline_cancels_a_pending_bounded_read(
    monkeypatch: pytest.MonkeyPatch,
    fixed_deadline: list[MemoryDeadline],
    completion: str,
) -> None:
    """Cancel a pending pipe only after a finite deadline was armed.

    monkeypatch (pytest.MonkeyPatch) restores native seams; fixed_deadline
    (list[MemoryDeadline]) contains manual timers; completion (str) controls a
    child-exit race. Return None; failures raise AssertionError. No clock, thread
    or native process runs, and no elapsed-time claim is made.
    """
    process = MemoryProcess(b"")
    reads: list[int] = []

    def raced_kill() -> None:
        """Model an exit race: mark completion, then raise ProcessLookupError."""
        process.finished = True
        raise ProcessLookupError("synthetic completed child")

    class PendingPipe(io.BytesIO):
        """Pause one bounded read until manual deadline cancellation releases it.

        The read records capacity, fires the armed callback, then models EOF.
        Its owner is the isolated MemoryProcess; all effects stay in memory.
        """

        def read(self, size: int | None = -1) -> bytes:
            """Read with size (int | None) only after deadline registration.

            Return empty bytes after cancellation; AssertionError reports an
            unbounded or uncancelled read. No actual waiting occurs.
            """
            assert size == 5
            reads.append(size)
            assert len(fixed_deadline) == 1 and fixed_deadline[0].started
            if completion == "already-exited":
                process.finished = True
            fixed_deadline[0].fire()
            assert process.killed or process.finished
            return b""

    process.stdout = PendingPipe()
    if completion == "exit-race":
        monkeypatch.setattr(process, "kill", raced_kill)

    def which(name: str) -> str:
        """Resolve name (str, exactly git); return the fixed in-memory path.

        AssertionError rejects other executables; no host PATH is inspected.
        """
        assert name == "git"
        return "/trusted/git"

    def start(argv: tuple[str, ...], **options: object) -> MemoryProcess:
        """Accept argv (tuple[str, ...]) and fixed options (object values).

        Return the isolated process; AssertionError rejects shell dispatch.
        No native executable starts.
        """
        assert argv == ("/trusted/git", "--version") and options["shell"] is False
        return process

    monkeypatch.setattr("drm_copilot_discovery.gateway_local.shutil.which", which)
    monkeypatch.setattr(
        "drm_copilot_discovery.gateway_local.subprocess.Popen",
        start,
    )

    with pytest.raises(OSError, match="timed out"):
        gateway_local.run_local_git(("git", "--version"), output_limit=4)

    assert reads == [5] and process.finished
    assert fixed_deadline[0].cancelled and fixed_deadline[0].joined
    assert process.killed == (completion == "pending")


@pytest.mark.parametrize("selected", [False, True])
@pytest.mark.parametrize("ample", [False, True])
def test_doctor_reserves_path_text_before_measurement_or_observation(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    selected: bool,
    ample: bool,
) -> None:
    """Reject the original 4095-character path before excess text work.

    config_catalog (SchemaCatalog) is immutable; monkeypatch (pytest.MonkeyPatch)
    restores counters/policy; selected (bool) uses an explicit profile; ample
    (bool) chooses sufficient work. Return None; assertions check actual input
    retention and no effects. Only the in-memory doctor composition runs.
    """
    case = ConfigurationCase(config_catalog)
    long_path = "/".join(("x" * 127,) * 32)
    case.service.candidate_paths = () if selected else (long_path,)
    measurements: list[int] = []
    original = ReportBudget.text

    def measured(self: ReportBudget, value: str) -> None:
        """Measure value (str) with the real budget and record long-path visits.

        Return None; budget errors propagate. Only counters and the test list
        change; observation occurs before any possible native I/O.
        """
        if (
            value == long_path
            and self.limits.document_bytes == 8192
            and self.limits.artifact_records == (10000 if ample else 32)
        ):
            measurements.append(self.work_left)
        original(self, value)

    monkeypatch.setattr(ReportBudget, "text", measured)
    monkeypatch.setattr(
        "drm_copilot_discovery.doctor.ParseLimits",
        lambda: ParseLimits(
            document_bytes=8192, artifact_records=10000 if ample else 32
        ),
    )
    ports = LocalServiceIO(
        activation=case.service,
        repository=None,
        principal="local-user",
        author_id="test-user",
        identity=lambda: IDENTITY,
    )

    result = inspect_doctor(
        io=ports,
        request=doctor_request(case, long_path if selected else None),
        runtime=IDENTITY,
    )

    assert result.input_manifest is not None
    assert (
        not case.disk.store.calls and not case.registry.writes and not case.revocations
    )
    if ample:
        assert measurements and result.exit_code == (2 if selected else 0)
        assert result.input_manifest.missing_paths == (LOCATOR_PATH, long_path)
    else:
        assert result.exit_code == 3 and not measurements
        assert result.input_manifest.missing_paths == ()
    assert result.summary["receipt_ref"] is None
    assert [
        (finding.severity, finding.pointer)
        for finding in result.findings
        if finding.code == "DISCOVERY_ENFORCEMENT_UNAVAILABLE"
    ] == [("warning", "/summary/deployment")]


def test_locator_selected_path_is_charged_before_reading(
    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Budget a locator-selected path before its bytes can be requested.

    config_catalog (SchemaCatalog) supplies immutable schemas; monkeypatch
    (pytest.MonkeyPatch) restores selection/policy. Return None; assertions catch
    bypasses. The synthetic selected state and all observations stay in memory.
    """
    case = ConfigurationCase(config_catalog)
    original = case.service.select()
    long_path = "/".join(("x" * 127,) * 32)

    def selected(self: ActivationStore, **options: object) -> ConfigurationSelection:
        """Return a synthetic long selection via options (object keyword values).

        Assert the exact memory store and profile option; no reads or writes occur.
        """
        assert self.registry is case.registry and options == {"profile_path": None}
        return replace(original, profile_path=long_path, profile_bytes=b"")

    monkeypatch.setattr(ActivationStore, "select", selected)
    monkeypatch.setattr(
        "drm_copilot_discovery.doctor.ParseLimits",
        lambda: ParseLimits(document_bytes=8192, artifact_records=32),
    )
    ports = LocalServiceIO(
        activation=case.service,
        repository=None,
        principal="local-user",
        author_id="test-user",
        identity=lambda: IDENTITY,
    )

    result = inspect_doctor(io=ports, request=doctor_request(case), runtime=IDENTITY)

    assert result.exit_code == 3 and not case.disk.store.calls
    assert not case.registry.writes and not case.revocations
