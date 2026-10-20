"""Retain parity rule outcomes independently from bounded diagnostic collection."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.references import ArtifactRecord
    from drm_copilot_discovery.repository_reader import RepositoryIdentity


@dataclass(frozen=True, kw_only=True)
class ParityDimensionOutcome:
    """Retain one authored classification and its actual rule decisions.

    name/pointer (str) identify a dimension and its matrix-relative location.
    required (bool) records inherited applicability obligations; applicability
    and verification (str | None) retain authored values without promotion.
    disposition_valid (bool) retains rationale/approval checks. proof_valid
    (bool | None) is None when no result claims execution. consistent/valid
    (bool) retain conflict and combined checks. Constructed by parity rules;
    no graph authority, mutation, I/O or independent evidence assessment exists.
    """

    name: str
    pointer: str
    required: bool
    applicability: str | None
    verification: str | None
    disposition_valid: bool
    proof_valid: bool | None
    consistent: bool
    valid: bool


@dataclass(frozen=True, kw_only=True)
class ParityEntryOutcome:
    """Separate an authored parity state from checked validity and completeness.

    matrix (ArtifactRecord) and pointer (str) identify the authored row. source
    (ArtifactRecord | None), target (RepositoryIdentity | None) and client_id
    (str | None) retain resolved ownership; None indicates missing authority.
    authored_state (str | None) never grants proof. required (bool | None) is
    unknown without a resolved obligation. The four optional bool checks retain
    approval, implementation, evidence and verification decisions; None means
    that check was not required/performed. dimensions is a tuple of immutable
    ParityDimensionOutcome values. duplicate invalidates every competing row.

    valid means every applicable present-claim check passed. complete requires
    valid plus a completed state, current required approval and target proof,
    or approved retirement. These internal results come from one assessment;
    caller-created instances never authorize reports, publication or execution.
    """

    matrix: ArtifactRecord
    pointer: str
    source: ArtifactRecord | None
    target: RepositoryIdentity | None
    client_id: str | None
    authored_state: str | None
    required: bool | None = None
    approval_valid: bool | None = None
    implementation_valid: bool | None = None
    evidence_valid: bool | None = None
    verification_valid: bool | None = None
    dimensions: tuple[ParityDimensionOutcome, ...] = ()
    duplicate: bool = False
    valid: bool = False
    complete: bool = False


@dataclass(frozen=True)
class ParityValidation:
    """Return retained outcomes and bounded diagnostics from one parity check.

    findings (tuple[Finding]) remains the first positional field. entries
    (tuple[ParityEntryOutcome]) defaults to empty for existing callers. Empty
    outcomes do not establish completeness or an empty source population.
    Diagnostic truncation cannot turn retained failed checks into success.
    Instances provide no I/O, publication, mutation or caller authority.
    """

    findings: tuple[Finding, ...]
    entries: tuple[ParityEntryOutcome, ...] = ()
