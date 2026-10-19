"""Bound and sanitize dependency declarations before format-specific projection."""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Literal, cast

Ecosystem = Literal["node", "python", "dotnet"]
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
_NAME = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]{0,127}\Z")
_NPM_NAME = re.compile(r"(?:@[a-z0-9][a-z0-9._-]{0,63}/)?[a-z0-9][a-z0-9._-]{0,127}\Z")
_VERSION = re.compile(r"v?\d+(?:\.[0-9A-Za-z*]+)*(?:[-+][0-9A-Za-z.-]+)*\Z", re.ASCII)
_TERM = re.compile(
    r"[<>=!~^]{0,3}(?:v?\d+(?:\.[0-9A-Za-z*xX]+)*(?:[-+][0-9A-Za-z.-]+)*|[xX*])\Z",
    re.ASCII,
)
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
    """Expose a fixed code/message without embedding untrusted parser details."""

    def __init__(self, code: str) -> None:
        """Accept a fixed code; reject unknown codes; retain no input."""
        if code not in _CODES:
            raise ValueError("Unknown dependency diagnostic code")
        self.code = code
        super().__init__(_MESSAGES[code])


@dataclass(frozen=True)
class DependencyLimits:
    """Independent positive capacities; defaults bound a single retained document."""

    max_bytes: int = 1_048_576
    max_nodes: int = 100_000
    max_depth: int = 64
    max_candidates: int = 10_000
    max_text_bytes: int = 1_048_576
    max_lines: int = 100_000

    def __post_init__(self) -> None:
        """Reject bool/noninteger/nonpositive capacities without allocating input."""
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


def safe_identifier(
    value: str | None, *, ecosystem: Ecosystem = "python"
) -> str | None:
    """Return an allowlisted identifier or None; reject wrong types without I/O."""
    if ecosystem not in {"node", "python", "dotnet"}:
        raise ValueError("Unknown dependency ecosystem")
    if value is None:
        return None
    if not isinstance(cast("object", value), str):
        raise ValueError("Dependency identifier must be text or null")
    pattern = _NPM_NAME if ecosystem == "node" else _NAME
    return value if len(value) <= 214 and pattern.fullmatch(value) else None


@dataclass(frozen=True)
class DependencyValue:
    """A safe version/tag or a fixed classification with no retained target value."""

    kind: str
    value: str | None = None

    def __post_init__(self) -> None:
        """Reject noncanonical kind/value combinations; never normalize raw targets."""
        if self.kind not in {
            "literal",
            "constraint",
            "tag",
            "missing",
            "dynamic",
            "url",
            "vcs",
            "local",
            "workspace",
            "alias",
            "unsupported",
        }:
            raise ValueError("Unknown dependency value classification")
        if self.kind in {"literal", "constraint", "tag"}:
            if (
                not isinstance(self.value, str)
                or _version_kind(self.value) != self.kind
            ):
                raise ValueError(
                    "Dependency version does not match its safe classification"
                )
        elif self.value is not None:
            raise ValueError("Redacted dependency values must be null")


def _version_kind(value: str) -> str | None:
    """Classify bounded literal/range/tag grammar, returning None for unsafe text."""
    if not value or len(value) > 256:
        return None
    if _VERSION.fullmatch(value):
        return "literal"
    if value in {"latest", "next", "alpha", "beta", "stable"}:
        return "tag"
    # Splitting follows an ASCII-only grammar; no URL or variable can survive it.
    if re.fullmatch(r"[0-9A-Za-z.*+<>=!~^|,()\[\] -]+", value):
        terms = re.split(r"[ ,|()\[\]]+", value.strip(" ,|()[]"))
        # Every term must be finite version syntax; one unsafe term rejects the value.
        if terms and all(_TERM.fullmatch(term) for term in terms):
            return "constraint"
    return None


def dependency_value(value: str | None) -> DependencyValue:
    """Sanitize a raw version/reference to an immutable value; reject wrong types."""
    if value is None or value == "":
        return DependencyValue("missing")
    if not isinstance(cast("object", value), str):
        raise ValueError("Dependency value must be text or null")
    kind = _version_kind(value)
    if kind is not None:
        return DependencyValue(kind, value)
    # Only fixed prefixes are inspected; redacted values never enter IDs or hashes.
    lower = value[:32].lower()
    prefixes = (
        ("workspace:", "workspace"),
        ("npm:", "alias"),
        ("git", "vcs"),
        ("hg+", "vcs"),
        ("svn+", "vcs"),
        ("file:", "local"),
        ("link:", "local"),
        ("./", "local"),
        ("../", "local"),
        ("/", "local"),
        ("\\", "local"),
    )
    # Preserve reference categories without retaining any corresponding argument.
    for prefix, classification in prefixes:
        if lower.startswith(prefix):
            return DependencyValue(classification)
    if re.match(r"[a-z]:[\\/]", lower):
        return DependencyValue("local")
    if re.match(r"[a-z][a-z0-9+.-]*://", lower):
        return DependencyValue("url")
    if "$" in value or "%" in value or "{" in value:
        return DependencyValue("dynamic")
    return DependencyValue("unsupported")


@dataclass(frozen=True)
class DependencyAnchor:
    """An honest closed container anchor; occurrence distinguishes its declarations."""

    format: Literal["json", "xml", "text"]
    location: str
    occurrence: int = 1
    line: int | None = None

    def __post_init__(self) -> None:
        """Reject dynamic locations, invalid ordinals, or fabricated JSON line spans."""
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
    """Syntax facts with unresolved binding, execution and effective precedence."""

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
        """Validate sanitized construction; reject mutable or unsafe metadata."""
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
    """Immutable parser output without Analysis rows, identities or provenance."""

    candidates: tuple[DependencyCandidate, ...] = ()
    diagnostics: tuple[str, ...] = ()
    consumed_nodes: int = 0
    consumed_text_bytes: int = 0

    def __post_init__(self) -> None:
        """Reject mutable payloads, unknown diagnostics and invalid usage counters."""
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
    """Reserve work and output before append; exhaustion invalidates results."""

    def __init__(self, limits: DependencyLimits) -> None:
        """Bind limits and empty counters; reject invalid limits; allocate no I/O."""
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
        """Reserve nonnegative work; reject invalid or exhausted capacities."""
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
        """Return UTF-8 after byte/physical-line checks; raise fixed input errors."""
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
        """Reserve and deduplicate fixed codes; reject unknown or exhausted input."""
        if code not in _CODES:
            raise ValueError("Unknown dependency diagnostic code")
        if code not in self._diagnostics:
            self.reserve(text_bytes=len(code) + 2)
        self._diagnostics.add(code)

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
        """Reserve raw selected text, sanitize and append one candidate; return None.

        Callers reserve traversal nodes before iteration and construct only closed
        anchors. Invalid types raise ValueError; exhaustion discards result access.
        Raw references/conditions must never be passed as roles or anchor locations.
        Text usage sums raw selected UTF-8 and quoted retained ASCII string bytes;
        full Analysis serialization has a separate integration-owned budget.
        """
        if type(extras) is not tuple or type(markers) is not tuple:
            raise ValueError("Dependency extras and markers must be immutable tuples")
        self.reserve(candidates=1, nodes=len(extras) + len(markers))
        # Bound selected scalar work before encoding or constructing output values.
        for value in (name, version, requested, owner, role, *extras, *markers):
            if value is not None:
                if not isinstance(cast("object", value), str):
                    raise ValueError("Dependency selected values must be text or null")
                if len(value) > self.limits.max_text_bytes - self._text:
                    self._failed = True
                    raise DependencyInputError("dependency-limit")
                try:
                    encoded_size = len(value.encode("utf-8"))
                except UnicodeEncodeError:
                    self._failed = True
                    raise DependencyInputError("dependency-encoding") from None
                self.reserve(text_bytes=encoded_size)
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
        """Return a snapshot; raise after any exhaustion or decoding failure."""
        if self._failed:
            raise DependencyInputError("dependency-limit")
        return DependencyResult(
            tuple(self._candidates),
            tuple(sorted(self._diagnostics)),
            self._nodes,
            self._text,
        )
