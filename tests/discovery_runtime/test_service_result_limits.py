"""Count direct-carrier callbacks and prospective complete-result work."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import service_serialization, snapshot
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.report_models import ReportLimitError, bounded_object
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.service_contracts import (
    ServiceArtifact,
    ServiceAuthority,
    ServiceRequestError,
    ServiceRuntimeError,
)
from drm_copilot_discovery.snapshot import InputManifest, SnapshotFile

from tests.discovery_runtime.test_service_failures import result

if TYPE_CHECKING:
    from typing import Literal


class EqualityToken:
    """Count untrusted object equality locally without granting enum membership.

    Construct once per control, pass to a public boundary, then inspect calls.
    Equality returns True to expose premature dispatch; no external effects.
    """

    def __init__(self) -> None:
        """Initialize local calls (int); return None without I/O or errors."""
        self.calls = 0

    def __eq__(self, other: object) -> bool:
        """Count comparison with other (object); return True, mutating calls only."""
        self.calls += 1
        return True


class EqualityString(str):
    """Count string-subclass equality at exact-string public boundaries.

    Instances carry a local calls counter; normal str storage remains immutable.
    No I/O or authority occurs. A zero counter proves rejection precedes equality.
    """

    def __init__(self, value: str) -> None:
        """Initialize calls for str value; return None without external effects."""
        self.calls = 0

    def __eq__(self, other: object) -> bool:
        """Count comparison with other (object); return True, changing calls only."""
        self.calls += 1
        return True


@pytest.mark.parametrize("subclass", [False, True])
@pytest.mark.parametrize(
    "field",
    ["principal", "code", "request-operation", "request-mode", "operation", "mode"],
)
def test_enum_boundaries_reject_or_redact_before_equality(
    field: str, subclass: bool
) -> None:
    """Vary field (str)/subclass (bool); require zero callbacks; return None."""
    token = EqualityString("structural") if subclass else EqualityToken()
    value = result()
    # Malformed request-error context is redacted; other carriers reject it.
    if field.startswith("request-"):
        error = ServiceRequestError(value.findings, **{field[8:]: cast("None", token)})
        assert getattr(error, field[8:]) is None
    else:
        with pytest.raises(ValueError):
            if field == "principal":
                ServiceAuthority(
                    principal=cast("Literal['local-user']", token),
                    author_or_agent="operator",
                    invocation=None,
                    grants=(),
                    read_selection=None,
                )
            elif field == "code":
                ServiceRuntimeError(code=cast("Literal['RUNTIME_CORRUPT']", token))
            else:
                replace(value, **{field: token})
    assert token.calls == 0


@pytest.mark.parametrize(
    "field",
    [
        "path",
        "missing",
        "source-pin",
        "target-pin",
        "summary",
        "finding",
        "artifact",
        "content",
        "aggregate-content",
    ],
)
def test_aggregate_work_rejects_before_projection_hash_or_encoding(
    field: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Count field (str) work rejection through MonkeyPatch; return None, no I/O."""
    text = "a" * 4096
    manifest = InputManifest(
        files=(SnapshotFile(path="input.json", content=b"x", category="artifact"),)
    )
    value = result(context=True)
    # Every variation retains valid immutable inputs before instrumentation begins.
    if field == "path":
        manifest = InputManifest(
            files=(SnapshotFile(path=text, content=b"x", category="artifact"),)
        )
    elif field == "missing":
        manifest = replace(manifest, missing_paths=(text,))
    elif field in ("source-pin", "target-pin"):
        manifest = replace(
            manifest,
            **{
                (
                    "source_repositories"
                    if field == "source-pin"
                    else "target_repositories"
                ): (
                    RepositoryIdentity(id=text, revision="a" * 40),
                )
            },
        )
    elif field == "summary":
        summary = dict(value.summary.members)
        summary["message"] = text
        value = replace(value, summary=bounded_object(summary, limits=ParseLimits()))
    elif field == "finding":
        value = replace(value, findings=(replace(value.findings[0], message=text),))
    elif field == "artifact":
        value = replace(
            value,
            artifacts=(
                ServiceArtifact(
                    path="output.json",
                    kind="validation-report",
                    status="created",
                    sha256="a" * 64,
                    content=text,
                ),
            ),
        )
    elif field in ("content", "aggregate-content"):
        count, size = (2, 4000) if field == "aggregate-content" else (1, 16384)
        # Two individually bounded streams must still share one aggregate budget.
        manifest = InputManifest(
            files=tuple(
                SnapshotFile(
                    path=f"input-{index}.json", content=b"x" * size, category="artifact"
                )
                for index in range(count)
            )
        )
    value = replace(value, input_manifest=manifest)
    calls: list[str] = []

    def project(self: InputManifest) -> dict[str, object]:
        """Count projection of self; raise AssertionError instead of copying."""
        calls.append("projection")
        raise AssertionError("Rejected work must precede manifest projection")

    def digest(payload: object) -> str:
        """Count hashing payload (object); raise AssertionError without hashing."""
        calls.append("hash")
        raise AssertionError("Rejected work must precede hashing")

    def encode(payload: object) -> bytes:
        """Count encoding payload (object); raise AssertionError without allocation."""
        calls.append("encoding")
        raise AssertionError("Rejected work must precede encoding")

    monkeypatch.setattr(InputManifest, "to_dict", project)
    monkeypatch.setattr(snapshot, "_digest", digest)
    monkeypatch.setattr(service_serialization, "canonical_json", encode)
    with pytest.raises(ReportLimitError):
        service_serialization.result_document(
            value, limits=ParseLimits(document_bytes=65536, artifact_records=256)
        )
    assert calls == []


def test_small_manifest_preserves_digest_and_both_roles_with_sufficient_work() -> None:
    """Check actual accepted projection under finite limits; return None, no I/O."""
    owner = RepositoryIdentity(id="combined", revision="a" * 40)
    manifest = InputManifest(
        files=(
            SnapshotFile(path="é.json", content=b"original\r\n", category="artifact"),
        ),
        missing_paths=("missing.json",),
        source_repositories=(owner,),
        target_repositories=(owner,),
    )
    value = replace(result(context=True), input_manifest=manifest)
    actual = service_serialization.result_document(
        value, limits=ParseLimits(artifact_records=1024)
    )
    expected = bounded_object(manifest.to_dict(), limits=ParseLimits())
    assert actual["input_manifest"] == expected
    assert actual["runtime"] is not None
    assert value.input_manifest is manifest
