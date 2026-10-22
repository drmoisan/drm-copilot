"""Prove doctor projects gateway capability observations without granting anything."""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.doctor import (
    CapabilityObservation,
    CapabilityObserving,
    capability_findings,
    inspect_doctor,
)
from drm_copilot_discovery.gateway_local import LocalServiceIO
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.service_contracts import validate_service_result

from tests.discovery_runtime.test_activation_store import ConfigurationCase
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
from tests.discovery_runtime.test_doctor import IDENTITY, doctor_request

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.doctor import CapabilityStatus


@pytest.mark.parametrize(
    ("status", "reasons", "attestation_ref"),
    [
        ("verified", (), None),
        ("supported", (), None),
        ("supported", ("x",), "attestation-alpha"),
        ("unsupported", (), None),
        ("unsupported", (" ",), None),
    ],
)
def test_contradictory_capability_observations_are_rejected(
    status: str, reasons: tuple[str, ...], attestation_ref: str | None
) -> None:
    """An observation that contradicts its own status never reaches doctor. status
    (str): claimed capability status. reasons (tuple[str, ...]): claimed deficiency
    reasons. attestation_ref (str | None): claimed protected reference. Returns
    None; memory-only effects; AssertionError on mismatch.
    """
    with pytest.raises(ValueError, match="apability"):
        CapabilityObservation(
            status=cast("CapabilityStatus", status),
            reasons=reasons,
            attestation_ref=attestation_ref,
        )


def test_capability_findings_explain_each_state() -> None:
    """Supported, unsupported and absent observations project to distinct findings.
    Returns None; memory-only effects; AssertionError on mismatch.
    """
    verified = capability_findings(
        CapabilityObservation(status="supported", attestation_ref="attestation-alpha")
    )
    unsupported = capability_findings(
        CapabilityObservation(
            status="unsupported", reasons=("hooks disabled", "probe allowed")
        )
    )

    assert [(item.code, item.severity) for item in verified] == [
        ("DISCOVERY_ENFORCEMENT_VERIFIED", "info")
    ]
    assert "attestation-alpha" in verified[0].message
    assert [item.code for item in unsupported] == [
        "DISCOVERY_ENFORCEMENT_UNAVAILABLE"
    ] * 2
    assert [item.message for item in unsupported] == [
        "Native discovery capability is unavailable: hooks disabled.",
        "Native discovery capability is unavailable: probe allowed.",
    ]
    # No observation and an explicit missing observation share the generic warning.
    assert capability_findings(None) == capability_findings(
        CapabilityObservation(status="missing")
    )
    assert capability_findings(None)[0].code == "DISCOVERY_ENFORCEMENT_UNAVAILABLE"


def test_doctor_reports_verified_capability_from_gateway_observation(
    config_catalog: SchemaCatalog,
) -> None:
    """A gateway-supplied supported observation replaces the unavailability warning.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)
    io = LocalServiceIO(
        activation=case.service,
        repository=None,
        principal="local-user",
        author_id="test-user",
        identity=lambda: IDENTITY,
    )
    observation = CapabilityObservation(
        status="supported", attestation_ref="attestation-alpha"
    )

    result = inspect_doctor(
        io=io, request=doctor_request(case), runtime=IDENTITY, capability=observation
    )

    validate_service_result(result, catalog=case.service.catalog, limits=ParseLimits())
    assert [item.code for item in result.findings] == ["DISCOVERY_ENFORCEMENT_VERIFIED"]
    assert "native capability verified" in str(result.summary["message"])
    # The local CLI principal itself never observes native capability.
    assert isinstance(io, CapabilityObserving)
    assert io.capability_observation() is None
