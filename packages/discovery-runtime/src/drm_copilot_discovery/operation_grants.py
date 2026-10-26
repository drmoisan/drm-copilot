"""Derive exact write grants and attribution from an authenticated ServiceAuthority.

The local-user principal derives its grants from its own accepted planned
changes; a nonempty provider grant set must match them exactly. The host
principal never derives: every change must be a row of the grants the verified
invocation carries, and nothing is expanded. Attribution follows the principal:
``human`` for local-user, ``agent`` for host. No function here reads or writes.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.path_models import WriteGrant

if TYPE_CHECKING:
    from drm_copilot_discovery.mutation_plan import MutationChange
    from drm_copilot_discovery.service_contracts import ServiceAuthority, ServiceRequest


def _refuse() -> OperationFailure:
    """Return the fixed exit-3 authority failure; perform no I/O."""
    return OperationFailure("SERVICE_AUTHORITY", exit_code=3)


def attribution(authority: ServiceAuthority) -> JsonObject:
    """Return the trusted attribution of authority (ServiceAuthority) as a JsonObject.

    The authenticated identifier and principal decide attribution, never request
    data: a local-user is a ``human`` author and a host principal is an ``agent``.
    """
    kind = "human" if authority.principal == "local-user" else "agent"
    return JsonObject((("kind", kind), ("id", authority.author_or_agent)))


def derive_grants(
    authority: ServiceAuthority,
    request: ServiceRequest,
    changes: tuple[MutationChange, ...],
) -> tuple[WriteGrant, ...]:
    """Return the exact grants for changes under authority and request; never expand.

    authority (ServiceAuthority) is the authenticated provider context, request
    (ServiceRequest) the parsed request and changes (tuple[MutationChange, ...])
    the accepted planned changes. A local-user with no host marker derives the
    exact rows; nonempty provider grants must equal them. A host authority must
    carry its invocation, the request must name that invocation and a consumed
    authorization, and every change must be one of the invocation's grant rows.
    Raises OperationFailure("SERVICE_AUTHORITY", exit_code=3) otherwise; no I/O.
    """
    exact = tuple(
        WriteGrant(
            artifact_kind=change.artifact_kind,
            artifact_id=change.artifact_id,
            path=change.path,
        )
        for change in changes
    )
    # The principal selects the derivation rule; neither rule can mint a root grant.
    if authority.principal == "local-user":
        if (
            authority.invocation is not None
            or request.invocation_ref is not None
            or request.authorization_ref is not None
        ):
            raise _refuse()
        if authority.grants and (
            len(authority.grants) != len(exact) or set(authority.grants) != set(exact)
        ):
            raise _refuse()
        return authority.grants or exact
    if authority.principal != "host":
        raise _refuse()
    if (
        authority.invocation is None
        or request.invocation_ref != authority.invocation.invocation_id
        or request.authorization_ref is None
    ):
        raise _refuse()
    granted = set(authority.grants)
    # Every change must already be granted; the host receives no derived row.
    if any(grant not in granted for grant in exact):
        raise _refuse()
    return exact
