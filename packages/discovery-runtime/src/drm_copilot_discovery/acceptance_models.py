"""Bound immutable acceptance data without establishing semantic readiness.

Generation supplies repository ownership and final validated ready membership.
These values enforce identity, consistency and resource limits without I/O,
source mutation, rule evaluation or implementation-test authority.
"""

from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from typing import Literal, TypeAlias, cast

from drm_copilot_discovery.findings import Finding, finding_key
from drm_copilot_discovery.models import (
    JsonObject,
    JsonValue,
    ParseLimits,
    canonical_json,
    to_plain_value,
)
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
from drm_copilot_discovery.repository_reader import RepositoryIdentity

AcceptanceKind: TypeAlias = Literal["legacy-characterization", "target-acceptance"]


def _identifier(value: object, budget: ReportBudget) -> None:
    """Check value (object) as an identifier within budget (ReportBudget).

    Returns None; ValueError rejects spelling/types and ReportLimitError rejects
    work excess before scanning. Only the local budget changes; no I/O occurs.
    """
    if type(value) is not str or not value:
        raise ValueError("Acceptance identity requires nonempty identifiers")
    budget.work(len(value))
    if not "a" <= value[0] <= "z":
        raise ValueError("Acceptance identity requires lowercase identifiers")
    separator = False
    # A single pass rejects adjacent/trailing separators without regex backtracking.
    for character in value:
        if "a" <= character <= "z" or "0" <= character <= "9":
            separator = False
        elif character in "._-" and not separator:
            separator = True
        else:
            raise ValueError("Acceptance identity contains an invalid identifier")
    if separator:
        raise ValueError("Acceptance identity cannot end in a separator")


@dataclass(frozen=True, kw_only=True)
class AcceptanceIdentity:
    """Identify one criterion coordinate independently of mutable source content.

    Args:
        source_repository_id (str): Stable source namespace, never its revision.
        kind (AcceptanceKind): Legacy observation or target requirement.
        feature_id (str): Source feature identity.
        criterion_id (str): Explicit source or approved criterion identity.
        client_id (str | None): Target client; legacy values require None.
        platform_id (str | None): Actual platform; required for target values.
        mode_id (str): Actual configured operating mode.
        linked_scenario (tuple[str, str] | None): Existing source repository and
            scenario ID, distinct from this value's generated scenario ID.

    Construction checks immutable types/spelling under finite default limits.
    key/scenario_id apply the caller's limits before encoding. No I/O or graph
    validation occurs; invalid coordinates raise ValueError.
    """

    source_repository_id: str
    kind: AcceptanceKind
    feature_id: str
    criterion_id: str
    client_id: str | None
    platform_id: str | None
    mode_id: str
    linked_scenario: tuple[str, str] | None = None

    def __post_init__(self) -> None:
        """Validate constructor fields under ParseLimits; return None.

        Raises ValueError for invalid identity or resource excess. Does not
        change fields or establish source/target proof.
        """
        self.key(limits=ParseLimits())

    def key(self, *, limits: ParseLimits) -> JsonObject:
        """Return the canonical structured key bounded by limits (ParseLimits).

        All eight fields are explicit, including null coordinates. ValueError
        rejects malformed fields/limits; ReportLimitError rejects excess before
        scanning or copying. Only local budget state changes.
        """
        budget = ReportBudget(limits)
        raw = {
            "source_repository_id": self.source_repository_id,
            "kind": self.kind,
            "feature_id": self.feature_id,
            "criterion_id": self.criterion_id,
            "client_id": self.client_id,
            "platform_id": self.platform_id,
            "mode_id": self.mode_id,
            "linked_scenario": self.linked_scenario,
        }
        budget.check(raw)
        if type(self.kind) is not str or self.kind not in (
            "legacy-characterization",
            "target-acceptance",
        ):
            raise ValueError("Acceptance kind is unsupported")
        # Legacy and target ownership have different explicit coordinate contracts.
        if self.kind == "legacy-characterization":
            if self.client_id is not None:
                raise ValueError("Legacy acceptance cannot select a target client")
        elif self.client_id is None or self.platform_id is None:
            raise ValueError("Target acceptance requires client and platform")
        # Validate every identity-bearing scalar before constructing a frozen key.
        for value in (
            self.source_repository_id,
            self.feature_id,
            self.criterion_id,
            self.mode_id,
        ):
            _identifier(value, budget)
        # Only client/platform coordinates permit explicit absence.
        for value in (self.client_id, self.platform_id):
            if value is not None:
                _identifier(value, budget)
        if self.linked_scenario is not None:
            if (
                type(self.linked_scenario) is not tuple
                or len(self.linked_scenario) != 2
            ):
                raise ValueError("Linked scenario requires an immutable identity pair")
            # Both coordinates preserve the existing scenario's qualified identity.
            for value in self.linked_scenario:
                _identifier(value, budget)
        return JsonObject(tuple(cast("dict[str, JsonValue]", raw).items()))

    def scenario_id(self, *, limits: ParseLimits) -> str:
        """Hash this bounded key using limits (ParseLimits); return str scenario ID.

        Uses canonical UTF-8 JSON including its LF and the complete SHA-256.
        Propagates ValueError/resource errors; no I/O or mutation occurs.
        """
        return "scn-" + sha256(canonical_json(self.key(limits=limits))).hexdigest()


def acceptance_tags(
    identity: AcceptanceIdentity,
    *,
    limits: ParseLimits,
    mobile_applicable: bool = False,
) -> tuple[str, ...]:
    """Return sorted exact tags for identity under limits (ParseLimits).

    mobile_applicable (bool) must come from generation's configured, explicitly
    applicable, unwaived assessment. This function validates data, not that proof.
    Invalid arguments raise ValueError; prospective capacity excess raises
    ReportLimitError. It performs no I/O or input mutation.
    """
    if type(identity) is not AcceptanceIdentity or type(mobile_applicable) is not bool:
        raise ValueError(
            "Acceptance tags require an identity and boolean applicability"
        )
    scenario = identity.scenario_id(limits=limits)
    pairs = (
        ("feature", identity.feature_id),
        ("scenario", scenario),
        ("client", identity.client_id),
        ("platform", identity.platform_id),
        ("mode", identity.mode_id),
    )
    budget = ReportBudget(limits)
    budget.work(7)
    size = 0
    # Reserve concatenations and the complete tag array before allocating strings.
    for prefix, value in pairs:
        if value is not None:
            budget.spend(len(prefix) + len(value) + 4)
            size += 1
    if identity.mode_id == "offline":
        budget.spend(10)
        size += 1
    if mobile_applicable:
        budget.spend(9)
        size += 1
    budget.spend(2 + max(0, size - 1))
    # Valid identifiers already fit the tag alphabet; lossy escaping is forbidden.
    tags = ["@" + prefix + "_" + value for prefix, value in pairs if value is not None]
    if identity.mode_id == "offline":
        tags.append("@offline")
    if mobile_applicable:
        tags.append("@mobile")
    budget.work(size * max(1, size.bit_length()))
    result = tuple(sorted(tags))
    ReportBudget(limits).check(result)
    return result


@dataclass(frozen=True, kw_only=True)
class AcceptanceSpecification:
    """Keep a bounded normalized document beside immutable repository ownership.

    Args:
        repository (RepositoryIdentity): Captured source or target owner/pin.
        identity (AcceptanceIdentity): Stable coordinate used by both IDs.
        document (JsonObject): Immutable normalized acceptance document.
        limits (ParseLimits): Root-derived finite resource policy.

    Construction checks consistency and bounds, not schema or semantic proof.
    Generation validates the whole batch. Serialization detaches the document;
    repository ownership stays separate because the schema has no such field.
    No I/O or mutation of caller values occurs.
    """

    repository: RepositoryIdentity
    identity: AcceptanceIdentity
    document: JsonObject
    limits: ParseLimits

    def __post_init__(self) -> None:
        """Check typed fields, identity and bounds; return None.

        Raises ValueError/ReportLimitError for malformed or inconsistent data.
        Does not certify readiness, approve decisions or mutate inputs.
        """
        budget = ReportBudget(self.limits)
        if (
            type(self.repository) is not RepositoryIdentity
            or type(self.identity) is not AcceptanceIdentity
            or type(self.document) is not JsonObject
        ):
            raise ValueError("Acceptance specification requires immutable typed values")
        budget.check(self.document)
        budget.work(len(self.document))
        values = dict(self.document.members)
        key = self.identity.key(limits=self.limits)
        scenario = self.identity.scenario_id(limits=self.limits)
        expected: dict[str, JsonValue] = {
            "artifact_kind": "acceptance-specification",
            "schema_version": "2.0.0",
            "id": scenario,
            "scenario_id": scenario,
        }
        # The linked discriminator/source namespace live in the carrier and refs.
        for name, value in key.members:
            if name not in ("source_repository_id", "linked_scenario"):
                expected[name] = value
        # Reject mismatched projection fields instead of silently repairing content.
        for name, value in expected.items():
            if values.get(name) != value:
                raise ValueError("Acceptance document differs from its identity")
        if (
            self.identity.kind == "legacy-characterization"
            and self.repository.id != self.identity.source_repository_id
        ):
            raise ValueError("Legacy acceptance requires source repository ownership")
        budget.check(self.repository.to_dict())

    def to_dict(self) -> dict[str, object]:
        """Return a detached document dictionary; no arguments or side effects.

        Rechecks limits before allocation; resource excess raises ReportLimitError.
        This projection does not serialize the separate ownership carrier.
        """
        ReportBudget(self.limits).check(self.document)
        return cast("dict[str, object]", to_plain_value(self.document))

    def to_json(self) -> str:
        """Return canonical document JSON with LF; no arguments or side effects.

        Rechecks encoded-byte capacity before serialization; excess raises
        ReportLimitError. Identity/provenance fields remain exactly as supplied.
        """
        ReportBudget(self.limits).check(self.document)
        return canonical_json(self.document).decode("utf-8")


def _finding_fields(finding: Finding) -> dict[str, object]:
    """Project finding (Finding) without copying its unbounded child sequences.

    Returns a fixed-size dictionary for prospective budgeting. No I/O, input
    mutation or additional validation occurs; caller verifies the exact type.
    """
    return {
        "code": finding.code,
        "severity": finding.severity,
        "artifact_path": finding.artifact_path,
        "pointer": finding.pointer,
        "related_ids": finding.related_ids,
        "related_paths": finding.related_paths,
        "message": finding.message,
        "next_action": finding.next_action,
    }


def _encoded(value: JsonObject, budget: ReportBudget, factor: int = 1) -> bytes:
    """Encode value (JsonObject) after reserving budget and factor (int) work.

    Returns canonical bytes. factor covers later hash/comparison/sort traversals;
    resource excess raises ReportLimitError before encoding. Only budget mutates.
    """
    before = budget.bytes_left
    budget.check(value)
    budget.work((before - budget.bytes_left + 1) * factor)
    return canonical_json(value)


@dataclass(frozen=True, kw_only=True)
class AcceptanceGeneration:
    """Normalize one bounded generation result without creating proof authority.

    Args:
        specifications (tuple[AcceptanceSpecification, ...]): Generated candidates.
        ready (tuple[AcceptanceSpecification, ...]): Final rule-validated subset.
        findings (tuple[Finding, ...]): Complete retained diagnostics.
        limits (ParseLimits): Root-derived aggregate policy.

    Construction rejects collisions and inconsistent ready membership, deduplicates
    identical candidates, and sorts by canonical identity. Blocking findings
    forbid ready output. Only local fields are normalized; no graph assessment,
    I/O, writes or implementation acceptance is performed.
    """

    specifications: tuple[AcceptanceSpecification, ...]
    ready: tuple[AcceptanceSpecification, ...]
    findings: tuple[Finding, ...]
    limits: ParseLimits

    def __post_init__(self) -> None:
        """Check aggregate capacities and membership, then normalize local tuples.

        Returns None. Invalid types, collisions or false ready membership raise
        ValueError; exhaustion raises ReportLimitError before aggregate copying.
        Caller-owned values are immutable and remain unchanged.
        """
        budget = ReportBudget(self.limits)
        # Reject arbitrary iterable hooks before lengths or aggregate traversal.
        if any(
            type(value) is not tuple
            for value in (self.specifications, self.ready, self.findings)
        ):
            raise ValueError("Acceptance generation requires immutable tuples")
        total = len(self.specifications) + len(self.ready) + len(self.findings)
        if (
            total > self.limits.artifact_records
            or len(self.findings) > self.limits.findings
        ):
            raise ReportLimitError()
        budget.work(total * (8 + max(1, total.bit_length())))
        by_key: dict[bytes, tuple[AcceptanceSpecification, bytes]] = {}
        by_id: dict[str, bytes] = {}
        # Reserve all candidate traversal/encoding before retaining lookup entries.
        for item in self.specifications:
            if type(item) is not AcceptanceSpecification:
                raise ValueError(
                    "Acceptance generation contains an invalid specification"
                )
            budget.check(item.repository.to_dict())
            key_object = item.identity.key(limits=self.limits)
            key = _encoded(key_object, budget, 4 + total.bit_length())
            content = _encoded(item.document, budget, 3)
            identifier = item.identity.scenario_id(limits=self.limits)
            prior = by_key.get(key)
            if prior is not None and (
                prior[1] != content or prior[0].repository != item.repository
            ):
                raise ValueError(
                    "Acceptance identity has conflicting content or ownership"
                )
            if identifier in by_id and by_id[identifier] != key:
                raise ValueError("Acceptance scenario ID collision")
            by_key[key] = (item, content)
            by_id[identifier] = key
        ready_keys: set[bytes] = set()
        # Membership uses canonical bytes, avoiding recursive dataclass equality scans.
        for item in self.ready:
            if type(item) is not AcceptanceSpecification:
                raise ValueError("Acceptance ready subset contains an invalid value")
            key_object = item.identity.key(limits=self.limits)
            key = _encoded(key_object, budget, 3)
            content = _encoded(item.document, budget, 2)
            prior = by_key.get(key)
            if (
                prior is None
                or prior[1] != content
                or prior[0].repository != item.repository
                or item.document.get("readiness") != "ready"
                or key in ready_keys
            ):
                raise ValueError(
                    "Acceptance ready subset differs from generated records"
                )
            ready_keys.add(key)
        # Findings are bounded before hashing/sorting or inspecting authority.
        for finding in self.findings:
            if type(finding) is not Finding:
                raise ValueError("Acceptance generation contains an invalid finding")
            before = budget.bytes_left
            budget.check(_finding_fields(finding))
            budget.work((before - budget.bytes_left) * (2 + total.bit_length()))
            if finding.severity == "error" and ready_keys:
                raise ValueError("Blocking findings forbid ready acceptance output")
        keys = sorted(by_key)
        # Reuse the canonical candidate instance in both public result tuples.
        object.__setattr__(
            self, "specifications", tuple(by_key[key][0] for key in keys)
        )
        # Filtering preserves the same deterministic identity order for ready values.
        object.__setattr__(
            self, "ready", tuple(by_key[key][0] for key in keys if key in ready_keys)
        )
        object.__setattr__(
            self, "findings", tuple(sorted(set(self.findings), key=finding_key))
        )
