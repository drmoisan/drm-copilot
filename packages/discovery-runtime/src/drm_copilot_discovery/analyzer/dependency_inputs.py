"""Bound and sanitize dependency declarations before format-specific projection."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal, cast

from drm_copilot_discovery.analyzer.dependency_values import (
    DependencyValue as DependencyValue,
)
from drm_copilot_discovery.analyzer.dependency_values import (
    Ecosystem as Ecosystem,
)
from drm_copilot_discovery.analyzer.dependency_values import (
    dependency_value as dependency_value,
)
from drm_copilot_discovery.analyzer.dependency_values import (
    safe_identifier as safe_identifier,
)

DependencyKind = Literal["declaration", "locked-package", "declared-lock-edge"]
_CODES = frozenset(
    {
        "dependency-limit",
        "dependency-malformed",
        "dependency-encoding",
        "dependency-unsupported",
        "dependency-redacted",
        "dependency-ambiguous",
        "dependency-binding-unresolved",
    }
)
_MESSAGES = {
    "dependency-limit": "Dependency input or output exceeds its configured limit.",
    "dependency-malformed": "Dependency input has an invalid selected structure.",
    "dependency-encoding": "Dependency input must use valid UTF-8.",
    "dependency-unsupported": "Dependency syntax or format is unsupported.",
    "dependency-redacted": "Unsupported dependency values were redacted.",
    "dependency-ambiguous": "Dependency declaration precedence is unresolved.",
    "dependency-binding-unresolved": "Dependency binding and execution are unresolved.",
}
_MARKERS = frozenset(
    {
        "python_version",
        "python_full_version",
        "os_name",
        "sys_platform",
        "platform_release",
        "platform_system",
        "platform_version",
        "platform_machine",
        "platform_python_implementation",
        "implementation_name",
        "implementation_version",
        "extra",
    }
)
_LOCATIONS = {
    "json": frozenset(
        {
            "",
            "/dependencies",
            "/devDependencies",
            "/optionalDependencies",
            "/peerDependencies",
            "/packages",
        }
    ),
    "xml": frozenset(
        {"PackageReference", "PackageVersion", "Version", "VersionOverride", "package"}
    ),
    "text": frozenset(
        {"requirements", "options.install_requires", "options.extras_require"}
    ),
}


class DependencyInputError(ValueError):
    """Fixed parser failure with a public str code and no retained input.

    Construct when validation fails and propagate to the adapter; the code selects
    a constant message. Instances never perform I/O or retain parser exceptions.
    """

    def __init__(self, code: str) -> None:
        """Bind code (str) to its fixed message; return None with local mutation.

        Raises ValueError for an unknown code; raw parser text is never accepted.
        """
        if code not in _CODES:
            raise ValueError("Unknown dependency diagnostic code")
        self.code = code
        super().__init__(_MESSAGES[code])


@dataclass(frozen=True)
class DependencyLimits:
    """Immutable independent capacities for one bounded parser invocation.

    Pass this carrier to DependencyBudget before decoding. All fields are positive
    exact ints, excluding bool: max_bytes counts input bytes; max_nodes counts
    traversal/index work; max_depth bounds nesting; max_candidates counts records;
    max_text_bytes counts selected UTF-8 work plus quoted retained ASCII strings;
    max_lines counts physical CRLF/CR/LF lines. Construction validates without I/O.
    Full Analysis output accounting belongs to the integration layer.
    """

    max_bytes: int = 1_048_576
    max_nodes: int = 100_000
    max_depth: int = 64
    max_candidates: int = 10_000
    max_text_bytes: int = 1_048_576
    max_lines: int = 100_000

    def __post_init__(self) -> None:
        """Validate this carrier's six int capacities; return None without mutation.

        Raises ValueError for bool, noninteger or nonpositive capacity values.
        """
        values = (
            self.max_bytes,
            self.max_nodes,
            self.max_depth,
            self.max_candidates,
            self.max_text_bytes,
            self.max_lines,
        )
        # Validate every independent capacity, including bool's integer subtype.
        if any(type(value) is not int or value <= 0 for value in values):
            raise ValueError("Dependency limits must be positive integers")


@dataclass(frozen=True)
class DependencyAnchor:
    """Immutable source container identity without untrusted keys or locations.

    Construct from an accepted parser's str format/location before collecting a
    candidate. occurrence is a positive int in normalized traversal order; line
    is a positive parser-reported XML/physical-text int or None for JSON. Validate
    once, then share immutable values; no source reads or other I/O occur.
    """

    format: Literal["json", "xml", "text"]
    location: str
    occurrence: int = 1
    line: int | None = None

    def __post_init__(self) -> None:
        """Validate this anchor's format/location/occurrence/line; return None.

        Raises ValueError for invalid types, locations or spans; has no side effects.
        """
        if (
            self.format not in _LOCATIONS
            or self.location not in _LOCATIONS[self.format]
        ):
            raise ValueError("Dependency anchor must name a supported container")
        if type(self.occurrence) is not int or self.occurrence < 1:
            raise ValueError("Dependency occurrence must be a positive integer")
        if self.line is not None and (type(self.line) is not int or self.line < 1):
            raise ValueError("Dependency line must be a positive integer or null")
        if self.format == "json" and self.line is not None:
            raise ValueError("JSON dependency anchors have no line claim")
        if self.format != "json" and self.line is None:
            raise ValueError("Text and XML dependency anchors require a line")


@dataclass(frozen=True)
class DependencyCandidate:
    """Immutable sanitized syntax fact without binding or execution claims.

    DependencyBudget normally constructs this carrier after reserving costs.
    kind/ecosystem/name/role identify declaration syntax; version and requested
    remain distinct DependencyValues; owner is an optional safe package name.
    anchor supplies source location, operation and condition_present describe
    syntax, and extras/markers are immutable safe-name tuples. Direct construction
    enforces the same invariants without I/O, evaluation or global mutation.
    """

    kind: DependencyKind
    ecosystem: Ecosystem
    name: str | None
    version: DependencyValue
    role: str
    anchor: DependencyAnchor
    requested: DependencyValue = DependencyValue("missing")
    owner: str | None = None
    operation: str = "reference"
    condition_present: bool = False
    extras: tuple[str, ...] = ()
    markers: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        """Validate this carrier's typed fields; return None without side effects.

        Raises ValueError when metadata is mutable, unsafe or structurally invalid.
        """
        if self.kind not in {"declaration", "locked-package", "declared-lock-edge"}:
            raise ValueError("Unknown dependency candidate kind")
        # Direct construction cannot bypass the collector's identifier allowlist.
        if any(
            value != safe_identifier(value, ecosystem=self.ecosystem)
            for value in (self.name, self.owner)
        ):
            raise ValueError("Dependency candidate identifiers must be sanitized")
        if safe_identifier(self.role) != self.role or not self.role:
            raise ValueError("Dependency role must be a safe identifier")
        if not isinstance(
            cast("object", self.version), DependencyValue
        ) or not isinstance(cast("object", self.requested), DependencyValue):
            raise ValueError("Dependency versions must be sanitized values")
        if not isinstance(cast("object", self.anchor), DependencyAnchor):
            raise ValueError("Dependency candidate requires a validated anchor")
        if (
            self.operation not in {"reference", "include", "update", "remove"}
            or type(self.condition_present) is not bool
        ):
            raise ValueError(
                "Dependency operation or condition classification is invalid"
            )
        if type(self.extras) is not tuple or type(self.markers) is not tuple:
            raise ValueError("Dependency extras and markers must be immutable tuples")
        # Extras are literal identifiers; marker names belong to a finite vocabulary.
        if any(not item or safe_identifier(item) != item for item in self.extras):
            raise ValueError("Dependency extras must be sanitized identifiers")
        if any(item not in _MARKERS for item in self.markers):
            raise ValueError("Dependency marker names must be recognized")


@dataclass(frozen=True)
class DependencyResult:
    """Immutable snapshot of sanitized candidates, diagnostics and parser usage.

    Obtain from DependencyBudget.result after parsing. candidates preserves parser
    order; diagnostics contains fixed codes; consumed_nodes counts reserved
    traversal/index operations and consumed_text_bytes counts selected UTF-8 work
    plus quoted retained ASCII strings. Counters are nonnegative exact ints.
    Validation has no I/O; snapshots remain unchanged by later collector mutation
    and never supply Analysis rows, IDs, source provenance or resolved binding.
    """

    candidates: tuple[DependencyCandidate, ...] = ()
    diagnostics: tuple[str, ...] = ()
    consumed_nodes: int = 0
    consumed_text_bytes: int = 0

    def __post_init__(self) -> None:
        """Validate this snapshot's tuples and int counters; return None.

        Raises ValueError for malformed fields; performs no external mutation.
        """
        # Validate tuple members without trusting type hints at the public boundary.
        if type(self.candidates) is not tuple or any(
            not isinstance(cast("object", item), DependencyCandidate)
            for item in self.candidates
        ):
            raise ValueError(
                "Dependency results require immutable sanitized candidates"
            )
        # Diagnostics carry fixed codes only, never parser-owned messages.
        if type(self.diagnostics) is not tuple or any(
            code not in _CODES for code in self.diagnostics
        ):
            raise ValueError("Dependency results require fixed diagnostic codes")
        # Usage counters cannot silently accept bool or negative values.
        if any(
            type(value) is not int or value < 0
            for value in (self.consumed_nodes, self.consumed_text_bytes)
        ):
            raise ValueError("Dependency usage must be nonnegative integers")


class DependencyBudget:
    """One-invocation mutable collector with independent prospective reservations.
    Construct with DependencyLimits, decode retained bytes, reserve traversal work,
    then add candidates/note diagnostics and obtain immutable result snapshots.
    Internal counters track nodes, records and selected/retained text bytes.
    Exhaustion or invalid encoding poisons result access; no partial success can
    escape. Mutation is local, without I/O, concurrency or global state. Consumers
    separately account for complete Analysis rows and aggregate input documents.
    """

    def __init__(self, limits: DependencyLimits) -> None:
        """Initialize local state from limits (DependencyLimits); return None.

        Raises ValueError for an invalid carrier; performs no external I/O.
        """
        if not isinstance(cast("object", limits), DependencyLimits):
            raise ValueError("Dependency budget requires validated limits")
        self.limits = limits
        self._nodes = self._text = self._records = 0
        self._failed = False
        self._candidates: list[DependencyCandidate] = []
        self._diagnostics: set[str] = set()

    def reserve(
        self, *, nodes: int = 0, candidates: int = 0, text_bytes: int = 0
    ) -> None:
        """Reserve nodes, candidates and text_bytes (nonnegative exact ints).

        Units are traversal/index operations, retained records and UTF-8/quoted
        ASCII bytes respectively. Return None; mutate counters only after all
        bounds pass. Raise ValueError for invalid types or DependencyInputError
        on exhaustion, which permanently poisons result access.
        """
        # Check all units before mutating any independent counter.
        if any(
            type(value) is not int or value < 0
            for value in (nodes, candidates, text_bytes)
        ):
            raise ValueError("Dependency reservations must be nonnegative integers")
        if (
            self._failed
            or self._nodes + nodes > self.limits.max_nodes
            or self._records + candidates > self.limits.max_candidates
            or self._text + text_bytes > self.limits.max_text_bytes
        ):
            self._failed = True
            raise DependencyInputError("dependency-limit")
        self._nodes += nodes
        self._records += candidates
        self._text += text_bytes

    def decode(self, content: bytes) -> str:
        """Decode content (bytes) after input-byte and physical-line checks.

        Return str with an optional UTF-8 BOM removed. Raise ValueError for an
        invalid type or fixed DependencyInputError for limits/encoding failures;
        such failures poison this collector. No source reads occur.
        """
        if not isinstance(cast("object", content), bytes):
            raise ValueError("Dependency input must be retained bytes")
        self.reserve()
        if len(content) > self.limits.max_bytes:
            self._failed = True
            raise DependencyInputError("dependency-limit")
        lines = (
            content.count(b"\n")
            + content.count(b"\r")
            - content.count(b"\r\n")
            + bool(content and not content.endswith((b"\r", b"\n")))
        )
        if lines > self.limits.max_lines:
            self._failed = True
            raise DependencyInputError("dependency-limit")
        try:
            return content.decode("utf-8-sig")
        except UnicodeDecodeError:
            self._failed = True
            raise DependencyInputError("dependency-encoding") from None

    def note(self, code: str) -> None:
        """Record code (str) once and reserve its quoted ASCII cost; return None.

        Mutates local diagnostics/counters. Raise ValueError for an unknown code
        or DependencyInputError when the prospective text reservation fails.
        """
        if code not in _CODES:
            raise ValueError("Unknown dependency diagnostic code")
        if code not in self._diagnostics:
            self.reserve(text_bytes=len(code) + 2)
        self._diagnostics.add(code)

    def _reserve_text(self, value: str) -> None:
        """Reserve value (str) UTF-8 cost without allocating encoded bytes.

        Return None; update local counters only after prospective checks. Raise
        fixed DependencyInputError on capacity/surrogate failure and poison
        result access. Character work stops at the remaining byte capacity.
        """
        remaining = self.limits.max_text_bytes - self._text
        if len(value) > remaining:
            self._failed = True
            raise DependencyInputError("dependency-limit")
        size = 0
        # Count scalar widths before allocation; reject invalid Unicode directly.
        for character in value:
            point = ord(character)
            if 0xD800 <= point <= 0xDFFF:
                self._failed = True
                raise DependencyInputError("dependency-encoding")
            # Unicode scalar ranges have fixed UTF-8 widths, independent of codecs.
            size += (
                1
                if point < 0x80
                else 2 if point < 0x800 else 3 if point < 0x10000 else 4
            )
            if size > remaining:
                self._failed = True
                raise DependencyInputError("dependency-limit")
        self.reserve(text_bytes=size)

    def add(
        self,
        *,
        kind: DependencyKind,
        ecosystem: Ecosystem,
        name: str | None,
        version: str | None,
        role: str,
        anchor: DependencyAnchor,
        requested: str | None = None,
        owner: str | None = None,
        operation: str = "reference",
        condition_present: bool = False,
        extras: tuple[str, ...] = (),
        markers: tuple[str, ...] = (),
    ) -> None:
        """Reserve, sanitize and append one candidate; return None.

        Args: kind (DependencyKind) and ecosystem (Ecosystem) select syntax;
        name/version/requested/owner (str | None) are untrusted names/references;
        role (str) is a group; anchor (DependencyAnchor) is a closed location;
        operation (str) and condition_present (bool) describe syntax; extras and
        markers (tuple[str, ...]) are names only, never condition expressions.
        Callers first reserve traversal work. Raise ValueError for invalid fields
        or DependencyInputError for bounds/encoding failures. Mutate only local
        counters/output after checks; raw plus retained text costs are distinct
        from complete Analysis serialization, which integration accounts for.
        """
        if type(extras) is not tuple or type(markers) is not tuple:
            raise ValueError("Dependency extras and markers must be immutable tuples")
        self.reserve(candidates=1, nodes=len(extras) + len(markers))
        # Bound selected scalar work before encoding or constructing output values.
        for value in (name, version, requested, owner, role, *extras, *markers):
            if value is not None:
                if not isinstance(cast("object", value), str):
                    raise ValueError("Dependency selected values must be text or null")
                self._reserve_text(value)
        safe_name = safe_identifier(name, ecosystem=ecosystem)
        safe_owner = safe_identifier(owner, ecosystem=ecosystem)
        safe_role = safe_identifier(role) or "redacted"
        # Filter metadata without retaining unknown marker names or unsafe extras.
        safe_extras = tuple(sorted({item for item in extras if safe_identifier(item)}))
        safe_markers = tuple(sorted(set(markers) & _MARKERS))
        safe_version, safe_requested = dependency_value(version), dependency_value(
            requested
        )
        # Retained values are ASCII allowlisted; quotes count toward encoded text cost.
        retained = (
            kind,
            ecosystem,
            safe_name,
            safe_owner,
            safe_role,
            operation,
            anchor.format,
            anchor.location,
            safe_version.kind,
            safe_version.value,
            safe_requested.kind,
            safe_requested.value,
            *safe_extras,
            *safe_markers,
        )
        # Charge all retained strings before candidate construction or append.
        self.reserve(
            text_bytes=sum(len(value) + 2 for value in retained if value is not None)
        )
        candidate = DependencyCandidate(
            kind,
            ecosystem,
            safe_name,
            safe_version,
            safe_role,
            anchor,
            safe_requested,
            safe_owner,
            operation,
            condition_present,
            safe_extras,
            safe_markers,
        )
        if (
            safe_name != name
            or safe_owner != owner
            or safe_role != role
            or len(safe_extras) != len(set(extras))
            or len(safe_markers) != len(set(markers))
            or candidate.version.kind not in {"missing", "literal", "constraint", "tag"}
            or candidate.requested.kind
            not in {"missing", "literal", "constraint", "tag"}
        ):
            self.note("dependency-redacted")
        self._candidates.append(candidate)

    def result(self) -> DependencyResult:
        """Return a DependencyResult snapshot of this collector without mutation.

        No arguments or I/O. Raise DependencyInputError after limits/encoding
        failures, preserving the rule that incomplete parsing cannot succeed.
        """
        if self._failed:
            raise DependencyInputError("dependency-limit")
        return DependencyResult(
            tuple(self._candidates),
            tuple(sorted(self._diagnostics)),
            self._nodes,
            self._text,
        )
