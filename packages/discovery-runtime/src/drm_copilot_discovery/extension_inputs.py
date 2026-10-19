"""Hash bounded analyzer inputs without including generated discovery outputs.

This projection supplements the complete snapshot; it never replaces its freshness
checks. Canonical JSON is UTF-8 with ensure_ascii=False and a trailing newline.
Source and local pinned bytes have independent document_bytes reservations.
"""

from __future__ import annotations

import hashlib
import json
from typing import cast

from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import InventoryCapture
from drm_copilot_discovery.coverage_scope_rules import inventory_configuration_digest
from drm_copilot_discovery.models import (
    JsonObject,
    JsonValue,
    ParseLimits,
    canonical_json,
)
from drm_copilot_discovery.path_models import path_contains
from drm_copilot_discovery.path_policy import FILE_KEYS
from drm_copilot_discovery.repository_reader import RepositoryFile
from drm_copilot_discovery.snapshot import VERSIONS, repository_pins


class _Budget:
    """Reserve resources for one pure input projection or manifest digest.

    Construct from ParseLimits, check existing immutable values, then reserve
    each projected allocation before constructing it. Bytes count canonical UTF-8
    including JSON escapes; nodes and records count structural values and maps;
    work_left bounds character-based path comparisons. Limits remain fixed while
    counters decrease; an overflow aborts the operation without partial output.
    Each operation owns its instance. Only these private counters mutate; no I/O,
    source access, caller mutation or shared state is permitted. Source and pin
    payload-byte reservations belong to the projection helpers, not this class.
    """

    def __init__(self, limits: ParseLimits) -> None:
        """Initialize counters from exact positive validated ParseLimits integers.

        limits (ParseLimits) supplies finite capacities. Returns None; raises
        ValueError for invalid policy. No I/O or caller mutation occurs.
        """
        self.limits = ParseLimits(
            document_bytes=limits.document_bytes,
            nesting_depth=limits.nesting_depth,
            artifact_records=limits.artifact_records,
        )
        self.bytes = limits.document_bytes - 1
        self.nodes = limits.expanded_nodes
        self.records = limits.artifact_records
        self.work_left = limits.expanded_nodes

    def spend(self, size: int) -> None:
        """Reserve size (int) canonical UTF-8 bytes before allocation.

        Returns None; raises ValueError on overflow. Only this counter changes.
        """
        if size > self.bytes:
            raise ValueError("Extension input exceeds the canonical byte limit")
        self.bytes -= size

    def work(self, amount: int) -> None:
        """Reserve amount (int) path/traversal operations before executing them.

        Returns None; raises ValueError on overflow; changes only this counter.
        """
        if amount > self.work_left:
            raise ValueError("Extension input exceeds the traversal work limit")
        self.work_left -= amount

    def mappings(self, amount: int) -> None:
        """Reserve amount (int) newly projected mappings before constructing them.

        Returns None; raises ValueError on structural overflow; no I/O occurs.
        """
        if amount > min(self.records, self.nodes):
            raise ValueError("Extension input exceeds the record limit")
        self.records -= amount
        self.nodes -= amount

    def text(self, value: str) -> None:
        """Count value (str) exactly as a canonical JSON string without encoding.

        Returns None; raises ValueError on overflow or invalid Unicode. Escaped
        controls, quotes, backslashes, BMP and supplementary scalars are counted.
        """
        if len(value) + 2 > self.bytes:
            raise ValueError("Extension input exceeds the canonical byte limit")
        self.spend(2)
        # Reject before encoding while accounting for canonical escape expansion.
        for character in value:
            code = ord(character)
            if 0xD800 <= code <= 0xDFFF:
                raise ValueError("Extension input contains invalid Unicode")
            if character in '\\"\b\f\n\r\t':
                self.spend(2)
            elif code < 32:
                self.spend(6)
            else:
                self.spend(
                    1 if code < 128 else 2 if code < 2048 else 3 if code < 65536 else 4
                )

    def check(self, value: JsonValue, depth: int = 0) -> None:
        """Reserve immutable value (JsonValue) recursively before serialization.

        depth (int) is the internal current depth. Returns None; raises ValueError
        for resource or JSON failures. This method allocates no container copies.
        """
        if depth > self.limits.nesting_depth or self.nodes < 1:
            raise ValueError("Extension input exceeds the structural limit")
        self.nodes -= 1
        # Check collection cardinality before descending into existing children.
        if isinstance(value, (JsonObject, tuple)):
            if len(value) > self.nodes:
                raise ValueError("Extension input exceeds the structural limit")
            self.spend(2 + max(0, len(value) - 1))
            if isinstance(value, JsonObject):
                if self.records < 1:
                    raise ValueError("Extension input exceeds the record limit")
                self.records -= 1
                # Keys and colons contribute bytes even though keys are not nodes.
                for key, child in value.members:
                    self.text(key)
                    self.spend(1)
                    self.check(child, depth + 1)
            else:
                # Array order is authored data and must never be normalized here.
                for child in value:
                    self.check(child, depth + 1)
        elif isinstance(value, str):
            self.text(value)
        else:
            # Bound arbitrary integer conversion before asking JSON to render it.
            if (
                type(value) is int
                and (value.bit_length() * 30103 // 100000 + 1 + (value < 0))
                > self.bytes
            ):
                raise ValueError("Extension input exceeds the canonical byte limit")
            try:
                encoded = json.dumps(value, allow_nan=False)
            except (ValueError, TypeError):
                raise ValueError(
                    "Extension input contains an invalid JSON scalar"
                ) from None
            self.spend(len(encoded))


def _under(path: str, roots: tuple[str, ...]) -> bool:
    """Match path (str) to exact component-boundary roots (tuple[str, ...]).

    Returns bool without normalization, I/O or mutation; inputs are validated paths.
    """
    # Prefix siblings do not grant configured source or output membership.
    return any(path == root or path.startswith(root + "/") for root in roots)


def _selection(
    capture: InventoryCapture, budget: _Budget
) -> tuple[tuple[str, ...], tuple[str, ...]]:
    """Validate output separation before returning directory and exact-file filters.

    capture (InventoryCapture) supplies configuration; budget (_Budget) bounds
    comparisons. Returns two path tuples; raises ValueError for overlap or invalid
    manifest placement. No filesystem access or authority expansion occurs.
    """
    profile = capture.profile
    artifacts = profile.artifacts.data
    # All configuration was budgeted before these finite view/index allocations.
    directories = (
        tuple(
            cast("str", value)
            for key, value in artifacts.members
            if key not in FILE_KEYS
        )
        + profile.evidence_roots
    )
    # File outputs use exact names rather than directory-prefix exclusions.
    exact = tuple(
        cast("str", value) for key, value in artifacts.members if key in FILE_KEYS
    )
    manifests = profile.analyzers.extension_result_manifests
    inventory = profile.artifacts["inventory"]
    protected = (
        profile.production_roots + profile.test_roots + profile.project_entry_points
    )
    paths = directories + exact
    # Reserve the complete comparison product before normalization allocates keys.
    budget.work(
        sum(len(path) for path in paths) * len(protected)
        + sum(len(path) for path in protected) * len(paths)
    )
    # A malformed output root must not erase a production/test/entrypoint input.
    for output in paths:
        if any(
            path_contains(output, source) or path_contains(source, output)
            for source in protected
        ):
            raise ValueError(
                "Extension outputs overlap configured production or test inputs"
            )
    # Every configured manifest is validated before it can exclude captured data.
    budget.work(sum(len(path) + len(inventory) for path in manifests))
    # Only explicitly declared inventory children can be treated as manifests.
    for path in manifests:
        if not path_contains(inventory, path, strict=True):
            raise ValueError("Extension manifests must be inside artifacts.inventory")
    return directories, exact + manifests


def _input_rows(
    capture: InventoryCapture, budget: _Budget
) -> tuple[tuple[JsonObject, ...], set[str]]:
    """Project selected input metadata after prospective path/content reservations.

    capture (InventoryCapture) and budget (_Budget) provide immutable inputs and
    counters. Returns rows plus inspected local paths. Raises ValueError for scope,
    category or resource failures; never reads source files or changes the capture.
    """
    profile = capture.profile
    directories, exact = _selection(capture, budget)
    roots = profile.production_roots + profile.test_roots + profile.documentation_roots
    entries = profile.project_entry_points
    compare = directories + exact + roots + entries
    # Bound whole-capture classification rather than repeating uncharged root scans.
    budget.work(
        sum(len(item.path) for item in capture.inputs) * len(compare)
        + sum(map(len, compare)) * len(capture.inputs)
    )
    result: list[JsonObject] = []
    inspected: set[str] = set()
    remaining = profile.limits.document_bytes
    # Generated artifacts never enter the projection, even as excluded rows.
    for item in capture.inputs:
        if item.path in exact or _under(item.path, directories):
            continue
        entry = item.path in entries
        category = (
            "source"
            if entry or _under(item.path, profile.production_roots)
            else (
                "test"
                if _under(item.path, profile.test_roots)
                else (
                    "documentation"
                    if _under(item.path, profile.documentation_roots)
                    else None
                )
            )
        )
        if category is None or (
            item.file is not None and item.file.category != category
        ):
            raise ValueError(
                "Extension input is outside its configured source category"
            )
        size = len(item.file.content) if item.file is not None else None
        if size is not None:
            if size > remaining or size > profile.analyzers.max_file_bytes:
                raise ValueError(
                    "Extension selected source bytes exceed the configured limit"
                )
            remaining -= size
        values = (
            item.path,
            category,
            entry,
            item.status,
            item.sha256,
            size,
            item.rationale,
        )
        budget.check(values)
        budget.spend(110)
        budget.mappings(1)
        record = row(
            path=item.path,
            category=category,
            entry_point=entry,
            status=item.status,
            sha256=item.sha256,
            size=size,
            rationale=item.rationale,
        )
        result.append(record)
        if item.status == "inspected":
            inspected.add(item.path)
    return tuple(result), inspected


def _pinned_rows(
    capture: InventoryCapture, inspected: set[str], budget: _Budget
) -> tuple[JsonObject, ...]:
    """Describe exact retained local Git bytes without inventing missing objects.

    capture (InventoryCapture), inspected (set[str]) and budget (_Budget) select
    bounded local objects. Returns sorted descriptors. Raises ValueError for
    invalid/duplicate pins or limits; reads only immutable retained bytes.
    """
    profile = capture.profile
    result: list[JsonObject] = []
    seen: set[str] = set()
    remaining = profile.limits.document_bytes
    # Each supplied pin is examined once, independent of the source input count.
    for source in capture.repository_files:
        if not isinstance(cast("object", source), RepositoryFile):
            raise ValueError("Extension pins require retained RepositoryFile objects")
        budget.work(len(source.path) + len(source.repository.id) + 1)
        if (
            source.repository.id != profile.repository.id
            or source.path not in inspected
        ):
            continue
        if (
            source.repository.revision != profile.repository.revision
            or source.path in seen
        ):
            raise ValueError(
                "Extension local pin identity is conflicting or duplicated"
            )
        size = len(source.content)
        if size > remaining:
            raise ValueError("Extension retained pin bytes exceed the configured limit")
        remaining -= size
        budget.check(
            (source.path, source.repository.id, source.repository.revision, size)
        )
        budget.spend(180)
        budget.mappings(2)
        seen.add(source.path)
        result.append(
            row(
                repository=row(
                    id=source.repository.id, revision=source.repository.revision
                ),
                path=source.path,
                sha256=source.sha256,
                size=size,
            )
        )
    return tuple(sorted(result, key=lambda value: cast("str", value["path"])))


def extension_input_projection(capture: InventoryCapture) -> JsonObject:
    """Return an output-independent immutable description of analyzer input bytes.

    capture (InventoryCapture) must contain a configured profile and retained
    source/test/documentation inputs. Returns JsonObject with no raw source bytes.
    Raises ValueError for malformed scope, pins or resource exhaustion. Selected
    source bytes and local pin bytes each use document_bytes independently; text,
    record/depth/node and traversal budgets precede projection allocation. No I/O
    occurs. Missing Git objects, checkout state and absent paths are not invented.
    """
    if not isinstance(cast("object", capture), InventoryCapture):
        raise ValueError("Extension projection requires an InventoryCapture")
    profile = capture.profile
    profile.require_configured()
    budget = _Budget(profile.limits.parse_limits())
    if (
        max(len(capture.inputs), len(capture.repository_files), len(capture.exclusions))
        > profile.limits.source_files
    ):
        raise ValueError("Extension input exceeds the configured source count")
    budget.check(profile.document)
    budget.check(capture.exclusions)
    budget.spend(512)
    inputs, inspected = _input_rows(capture, budget)
    pins = _pinned_rows(capture, inspected, budget)
    sources, targets = repository_pins(profile)
    role_rows: list[tuple[JsonObject, ...]] = []
    known: dict[str, str | None] = {}
    # Repository roles are sets; profile-owned opaque arrays retain authored order.
    for values in (sources, targets):
        entries: list[JsonObject] = []
        seen: set[str] = set()
        # Charge each descriptor before copying, then sort only the bounded rows.
        for item in values:
            if item.id in seen or (
                item.id in known and known[item.id] != item.revision
            ):
                raise ValueError(
                    "Extension repository roles contain conflicting identities"
                )
            budget.check((item.id, item.revision))
            budget.spend(30)
            budget.mappings(1)
            seen.add(item.id)
            known[item.id] = item.revision
            entries.append(row(id=item.id, revision=item.revision))
        role_rows.append(
            tuple(sorted(entries, key=lambda item: cast("str", item["id"])))
        )
    budget.mappings(2)
    result = row(
        projection_version=1,
        versions=JsonObject(VERSIONS),
        profile=profile.document,
        scan_configuration_sha256=inventory_configuration_digest(profile),
        inputs=inputs,
        exclusions=capture.exclusions,
        source_repositories=role_rows[0],
        target_repositories=role_rows[1],
        repository_files=pins,
    )
    # Recheck exact final structural counts before any caller serializes this graph.
    _Budget(profile.limits.parse_limits()).check(result)
    return result


def extension_input_digest(capture: InventoryCapture) -> str:
    """Hash capture (InventoryCapture) through the complete bounded projection.

    Returns a lowercase SHA-256 str over canonical_json bytes. Projection errors
    propagate as ValueError; no I/O, capture mutation or completion claim occurs.
    """
    return hashlib.sha256(
        canonical_json(extension_input_projection(capture))
    ).hexdigest()


def extension_manifest_digest(document: JsonObject) -> str:
    """Hash document (JsonObject), excluding only its root manifest_sha256 field.

    Returns lowercase SHA-256 str using canonical_json; this is not schema
    acceptance. Standard ParseLimits defaults bound UTF-8 bytes, depth, records
    and nodes before copying/serializing. Raises ValueError for type/resource
    failures; nested same-named fields and all other members remain significant.
    """
    if not isinstance(cast("object", document), JsonObject):
        raise ValueError("Extension manifest hashing requires a JsonObject")
    _Budget(ParseLimits()).check(document)
    # Omit exactly one root field; never drop nested checksums or capture metadata.
    members = tuple(
        (key, value) for key, value in document.members if key != "manifest_sha256"
    )
    return hashlib.sha256(canonical_json(JsonObject(members))).hexdigest()
