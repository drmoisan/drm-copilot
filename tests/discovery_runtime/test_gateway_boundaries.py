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
from drm_copilot_discovery.mutation_io import GuardedMutationWriter
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.path_policy import workspace_identity
from drm_copilot_discovery.report_models import ReportBudget
from drm_copilot_discovery.service_contracts import DiscoveryResult

from tests.discovery_runtime.gateway_test_support import (
    MemoryDeadline,
    MemoryProcess,
    invoke,
    memory_io,
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


@pytest.mark.parametrize(
    "trusted,spelling",
    [
        pytest.param("C:/Work/Repo", r"c:\work\REPO", id="windows-drive"),
        pytest.param("//server/share/Repo", r"\\SERVER\SHARE\repo", id="windows-unc"),
        pytest.param("/Work/Repo", "/Work/Repo", id="posix-exact"),
    ],
)
def test_local_root_identity_accepts_equivalent_spelling(
    config_catalog: SchemaCatalog, trusted: str, spelling: str
) -> None:
    """Accept one root identity through pre-capture, capture and writer checks.

    config_catalog (SchemaCatalog) supplies schemas; trusted and spelling (str)
    model equivalent supported roots. Return None; AssertionError reports lost
    identity or effects. All ports and captures are memory-only.
    """
    case, local, baseline = memory_io(config_catalog)
    local.initialization.workspace_root = trusted
    request = replace(doctor_request(case), workspace_root=spelling)
    baseline = replace(baseline, workspace_root=spelling)
    before = tuple(case.disk.store.calls)

    initial = local.authorize(request, baseline=None)
    captured = local.authorize(request, baseline=baseline)
    writer = local.writer(baseline, authority=captured)

    assert workspace_identity(spelling) == workspace_identity(trusted)
    assert initial == captured and captured.principal == "local-user"
    assert captured.grants == () and captured.invocation is None
    assert isinstance(writer, GuardedMutationWriter)
    assert tuple(case.disk.store.calls) == before
    assert not case.registry.writes and not case.revocations


@pytest.mark.parametrize("boundary", ["request", "baseline", "writer"])
@pytest.mark.parametrize(
    "trusted,candidate",
    [
        pytest.param("C:/Work/Repo", "C:/Work/Other", id="different-root"),
        pytest.param("C:/Work/Repo", "D:/Work/Repo", id="different-drive"),
        pytest.param("C:/Work/Repo", "C:/Work/Repo-sibling", id="sibling-prefix"),
        pytest.param(
            "//server/share/Repo", "//server/other/Repo", id="different-share"
        ),
        pytest.param(
            "//server/share/Repo", "//other/share/Repo", id="different-server"
        ),
        pytest.param("/Work/Repo", "/work/Repo", id="posix-case"),
        pytest.param("/Work/Repo", r"/Work\Repo", id="posix-backslash"),
        pytest.param("C:/Work/Repo", "Work/Repo", id="relative"),
        pytest.param("C:/Work/Repo", ".", id="current-directory"),
        pytest.param("C:/Work/Repo", "C:Work/Repo", id="drive-relative"),
        pytest.param("C:/Work/Repo", r"\Work\Repo", id="root-relative"),
        pytest.param("C:/Work/Repo", r"\\?\C:\Work\Repo", id="device-extended"),
        pytest.param("C:/Work/Repo", r"\\.\C:\Work\Repo", id="device-dot"),
        pytest.param("C:/Work/Repo", "C:/Work/./Repo", id="dot-component"),
        pytest.param("C:/Work/Repo", "C:/Work/Other/../Repo", id="parent-component"),
        pytest.param("C:/Work/Repo", "C:/Work/CON", id="reserved-component"),
        pytest.param("C:/Work/Repo", "C:/Work/Repo.", id="trailing-dot"),
    ],
)
def test_local_root_identity_rejects_nonmatching_roots(
    config_catalog: SchemaCatalog, trusted: str, candidate: str, boundary: str
) -> None:
    """Deny a foreign or unsupported root independently at all three guards.

    config_catalog (SchemaCatalog) supplies schemas; trusted/candidate (str)
    select the root pair; boundary (str) selects exactly one guard. Return None;
    assertion failures expose authorization or I/O. No external resources run.
    """
    case, local, baseline = memory_io(config_catalog)
    local.initialization.workspace_root = trusted
    request = replace(doctor_request(case), workspace_root=trusted)
    baseline = replace(baseline, workspace_root=trusted)
    authority = local.authorize(request, baseline=None)
    before = tuple(case.disk.store.calls)

    with pytest.raises(PermissionError, match="authority"):
        if boundary == "request":
            local.authorize(replace(request, workspace_root=candidate), baseline=None)
        elif boundary == "baseline":
            local.authorize(
                request, baseline=replace(baseline, workspace_root=candidate)
            )
        else:
            local.writer(
                replace(baseline, workspace_root=candidate), authority=authority
            )

    assert tuple(case.disk.store.calls) == before
    assert not case.registry.writes and not case.revocations


@pytest.mark.parametrize("root", ["relative", r"/Work\Repo", "C:/Work/CON"])
def test_workspace_identity_rejects_an_invalid_trusted_root(
    config_catalog: SchemaCatalog, root: str
) -> None:
    """Reject invalid trusted configuration through the public API and adapter.

    config_catalog (SchemaCatalog) supplies schemas; root (str) is unsupported.
    Return None; AssertionError reports accepted invalid identity. All state is
    isolated in memory and no writer is obtained.
    """
    case, local, _ = memory_io(config_catalog)
    local.initialization.workspace_root = root
    before = tuple(case.disk.store.calls)

    with pytest.raises(PathPolicyError):
        workspace_identity(root)
    with pytest.raises(PermissionError, match="authority"):
        local.authorize(doctor_request(case), baseline=None)

    assert tuple(case.disk.store.calls) == before
    assert not case.registry.writes and not case.revocations
