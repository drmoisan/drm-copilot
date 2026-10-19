"""Immutable selected-read contracts; these values never authenticate a caller.

The host supplies ReadSelection independently of untrusted SourceReadRequest.
Constructing a selection is not authorization: wrappers must obtain it from their
trusted invocation boundary. No value here performs I/O or grants write access.
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, replace
from typing import Literal, cast

from drm_copilot_discovery.path_models import check_path_collisions, relative_path
from drm_copilot_discovery.repository_reader import RepositoryIdentity

ReadOperation = Literal["list", "read", "search"]


def bounded_integer(value: int, name: str, maximum: int) -> None:
    """Validate int value against int maximum; name:str labels errors.
    Return None, or raise ValueError for invalid bounds/types; pure.
    """
    if type(value) is not int or not 1 <= value <= maximum:
        raise ValueError(f"{name} must be an integer between 1 and {maximum}")


def require_digest(value: str) -> None:
    """Validate str value as lowercase SHA-256; return None or raise ValueError.
    Pure: no normalization or I/O.
    """
    if (
        not isinstance(cast("object", value), str)
        or len(value) != 64
        or any(character not in "0123456789abcdef" for character in value)
    ):
        raise ValueError("Expected an exact lowercase SHA-256 digest")


@dataclass(frozen=True, kw_only=True)
class ReadGrant:
    """Represent one host-authenticated str path and file/directory scope.
    Construct then call allows; immutable and pure, never creates authority.
    Exact files cannot authorize siblings or descendants.
    """

    path: str
    directory: bool = False

    def __post_init__(self) -> None:
        """Validate path and directory fields; raise ValueError without I/O."""
        relative_path(self.path)
        if type(self.directory) is not bool:
            raise ValueError("Read grant directory must be a boolean")

    def allows(self, path: str) -> bool:
        """Return bool membership for portable str path without alias normalization.
        Raise ValueError for unsafe spelling; no I/O or mutation.
        """
        relative_path(path)
        return path == self.path or (
            self.directory and path.startswith(self.path + "/")
        )


@dataclass(frozen=True, kw_only=True)
class SelectedManifest:
    """Bind one manifest path and immutable SHA-256 from the trusted host.
    Construct before inspection; authorizes bounded integrity reads only.
    The value is pure and grants neither output nor write permissions.
    """

    path: str
    sha256: str

    def __post_init__(self) -> None:
        """Validate path/digest inputs; reject nonmanifest names without I/O."""
        relative_path(self.path)
        require_digest(self.sha256)
        if not self.path.endswith("/manifest.json"):
            raise ValueError("Select an exact snapshot manifest.json path")


@dataclass(frozen=True, kw_only=True)
class ReadSelection:
    """Freeze host read grants and separately selected integrity manifests.
    Construct from typed tuples; use allows before any requested byte read.
    A manifest permits every integrity member read, but returned members still
    require grants and profile scope. Pure, immutable; never authenticates input.
    """

    grants: tuple[ReadGrant, ...]
    manifests: tuple[SelectedManifest, ...] = ()

    def __post_init__(self) -> None:
        """Freeze typed sequences; reject empty, excessive or aliased selections."""
        object.__setattr__(self, "grants", tuple(self.grants))
        object.__setattr__(self, "manifests", tuple(self.manifests))
        bounded_integer(len(self.grants), "selected grants", 10000)
        if len(self.manifests) > 1000:
            raise ValueError("Too many selected manifests")
        # Reject malformed host inputs before any reader can observe target bytes.
        if any(
            not isinstance(cast("object", item), ReadGrant) for item in self.grants
        ) or any(
            not isinstance(cast("object", item), SelectedManifest)
            for item in self.manifests
        ):
            raise ValueError("Selections require typed grants and manifests")
        check_path_collisions(item.path for item in self.grants)
        check_path_collisions(item.path for item in self.manifests)
        # Equivalent host selections must produce the same continuation identity.
        object.__setattr__(
            self, "grants", tuple(sorted(self.grants, key=lambda item: item.path))
        )
        object.__setattr__(
            self, "manifests", tuple(sorted(self.manifests, key=lambda item: item.path))
        )

    def allows(self, path: str) -> bool:
        """Return bool selection membership for str path, separately from profile.
        Pure; raise ValueError for invalid portable spelling.
        """
        return any(grant.allows(path) for grant in self.grants)


@dataclass(frozen=True, kw_only=True)
class SourceReadLimits:
    """Define finite independent traversal, input and output resource bounds.
    Construct once and inject into SourceReader; validation is pure.
    input_bytes counts freshness reads and every integrity payload. entries
    bounds metadata and queued paths; lines counts all decoded lines and
    line_bytes includes terminators. Every axis has a fixed hard ceiling.
    """

    entries: int = 10000
    depth: int = 64
    file_bytes: int = 1048576
    input_bytes: int = 8388608
    output_bytes: int = 65536
    lines: int = 10000
    line_bytes: int = 16384
    matches: int = 1000
    query_bytes: int = 256

    def __post_init__(self) -> None:
        """Validate finite limit fields, returning None or raising ValueError."""
        # Independent ceilings prevent a caller from making any axis unbounded.
        for name, maximum in (
            ("entries", 1000000),
            ("depth", 128),
            ("file_bytes", 16777216),
            ("input_bytes", 67108864),
            ("output_bytes", 1048576),
            ("lines", 1000000),
            ("line_bytes", 1048576),
            ("matches", 100000),
            ("query_bytes", 4096),
        ):
            bounded_integer(getattr(self, name), name, maximum)


@dataclass(frozen=True, kw_only=True)
class ReadCursor:
    """Bind a positive row offset to the complete inspection SHA-256.
    Return this immutable value on continuation; source_page rejects stale
    bindings. Construction is pure and does not grant read authority.
    """

    inspection_sha256: str
    offset: int

    def __post_init__(self) -> None:
        """Validate immutable digest/offset fields; raise ValueError without I/O."""
        require_digest(self.inspection_sha256)
        bounded_integer(self.offset, "cursor offset", 1000000)


@dataclass(frozen=True, kw_only=True)
class SourceReadRequest:
    """Request an operation within an independently supplied ReadSelection.

    Search is case-sensitive literal, single-line and nonoverlapping. Line
    numbers are one-based inclusive; page offsets refer to ordered result rows.
    Regex and multiline searches are rejected rather than interpreted.
    """

    operation: ReadOperation
    paths: tuple[str, ...]
    query: str | None = None
    regex: bool = False
    line_start: int = 1
    line_end: int | None = None
    page_size: int = 100
    cursor: ReadCursor | None = None

    def __post_init__(self) -> None:
        """Normalize path order, validate fields, or raise ValueError; no I/O."""
        if self.operation not in {"list", "read", "search"} or self.regex is not False:
            raise ValueError("Use list/read/search with regex disabled")
        if isinstance(self.paths, str):
            raise ValueError("Requested paths must be a sequence")
        bounded_integer(len(self.paths), "requested paths", 10000)
        object.__setattr__(self, "paths", check_path_collisions(self.paths))
        bounded_integer(self.line_start, "line_start", 1000000)
        bounded_integer(self.page_size, "page_size", 1000)
        if self.line_end is not None:
            bounded_integer(self.line_end, "line_end", 1000000)
            if self.line_end < self.line_start:
                raise ValueError("line_end must not precede line_start")
        if self.cursor is not None and not isinstance(
            cast("object", self.cursor), ReadCursor
        ):
            raise ValueError("Use a typed content-bound cursor")
        # Only the search operation accepts a query; no alternate language exists.
        if self.operation == "search":
            if (
                not isinstance(self.query, str)
                or not self.query
                or any(
                    character in self.query for character in "\r\n\v\f\x85\u2028\u2029"
                )
            ):
                raise ValueError("Search requires a nonempty single-line literal")
            try:
                bounded_integer(len(self.query.encode("utf-8")), "query bytes", 4096)
            except UnicodeError as error:
                raise ValueError("Search requires valid UTF-8 text") from error
        elif self.query is not None:
            raise ValueError("Only search accepts a query")


@dataclass(frozen=True, kw_only=True)
class SourceSpan:
    """Describe one line with one-based, end-exclusive Unicode character columns.
    Construct after decoding original bytes; immutable and pure. Equal columns
    represent an empty line, and line/column counters have finite ceilings.
    """

    line: int
    column_start: int
    column_end: int

    def __post_init__(self) -> None:
        """Validate ordered span fields; raise ValueError or return None, purely."""
        bounded_integer(self.line, "line", 1000000)
        bounded_integer(self.column_start, "column_start", 1048577)
        bounded_integer(self.column_end, "column_end", 1048577)
        if self.column_end < self.column_start:
            raise ValueError("Span end must not precede its start")


@dataclass(frozen=True, kw_only=True)
class SourceEvidence:
    """Separate observed bytes from configured pins and transported provenance.

    path is the original repository path for a validated imported member.
    workspace_path is always its selected local path. A working file has no
    proven revision; a manifest itself is local envelope metadata, not a member.
    """

    workspace_path: str
    path: str
    repository: RepositoryIdentity
    sha256: str
    size: int
    provenance: Literal["working-file", "snapshot-member", "snapshot-manifest"]
    manifest_sha256: str | None = None

    def __post_init__(self) -> None:
        """Validate provenance, path and digest fields; reject inconsistent claims."""
        relative_path(self.workspace_path)
        relative_path(self.path)
        require_digest(self.sha256)
        if not isinstance(cast("object", self.repository), RepositoryIdentity):
            raise ValueError("Source evidence requires a typed repository identity")
        if type(self.size) is not int or not 0 <= self.size <= 16777216:
            raise ValueError("Invalid source byte size")
        if self.provenance not in {
            "working-file",
            "snapshot-member",
            "snapshot-manifest",
        }:
            raise ValueError("Unsupported source provenance")
        if self.manifest_sha256 is not None:
            require_digest(self.manifest_sha256)
        # Only a fully validated member may attribute these bytes to a source pin.
        if self.provenance == "snapshot-member":
            if self.repository.revision is None or self.manifest_sha256 is None:
                raise ValueError(
                    "Snapshot members require source pin and manifest hash"
                )
        elif self.repository.revision is not None or self.path != self.workspace_path:
            raise ValueError("Working files and envelopes cannot claim pinned origins")
        if (self.provenance == "working-file") != (self.manifest_sha256 is None):
            raise ValueError("Manifest binding must agree with source provenance")


@dataclass(frozen=True, kw_only=True)
class SourceItem:
    """Retain one immutable file, line or literal-match observation.
    Construct with typed evidence and optional text/span, then page or encode.
    Spans require text. Construction validates shape without I/O or mutation.
    """

    evidence: SourceEvidence
    text: str | None = None
    span: SourceSpan | None = None

    def __post_init__(self) -> None:
        """Validate typed observation fields without reading bytes; return None."""
        if not isinstance(cast("object", self.evidence), SourceEvidence):
            raise ValueError("Source items require typed evidence")
        if self.text is not None and not isinstance(cast("object", self.text), str):
            raise ValueError("Source item text must be a string or None")
        if self.span is not None and (
            not isinstance(cast("object", self.span), SourceSpan) or self.text is None
        ):
            raise ValueError("A typed span requires observed text")


@dataclass(frozen=True, kw_only=True)
class SourceReadResult:
    """Represent a page of a complete, bounded, freshness-checked inspection.
    Construct through source_page and encode to deterministic UTF-8 JSON.
    Rows and cursor are immutable; counters are nonnegative and continuation
    binds this inspection. Construction and encoding perform no I/O.
    """

    operation: ReadOperation
    items: tuple[SourceItem, ...]
    total: int
    inspection_sha256: str
    next_cursor: ReadCursor | None
    input_bytes: int
    entries: int

    def __post_init__(self) -> None:
        """Freeze typed page rows and validate counters; raise ValueError on misuse."""
        object.__setattr__(self, "items", tuple(self.items))
        require_digest(self.inspection_sha256)
        # Total/counters are nonnegative because empty files and results are valid.
        if self.operation not in {"list", "read", "search"} or any(
            type(value) is not int or value < 0
            for value in (self.total, self.input_bytes, self.entries)
        ):
            raise ValueError("Invalid source result operation or counters")
        if self.total < len(self.items) or any(
            not isinstance(cast("object", item), SourceItem) for item in self.items
        ):
            raise ValueError("Invalid source result items")
        if self.next_cursor is not None and (
            not isinstance(cast("object", self.next_cursor), ReadCursor)
            or self.next_cursor.inspection_sha256 != self.inspection_sha256
            or self.next_cursor.offset >= self.total
        ):
            raise ValueError("Continuation must bind this result and remaining rows")

    def encode(self) -> bytes:
        """Return deterministic UTF-8 JSON bytes, including all pagination metadata."""
        return (
            json.dumps(
                asdict(self), sort_keys=True, ensure_ascii=False, separators=(",", ":")
            )
            + "\n"
        ).encode("utf-8")


def operation_without_cursor(request: SourceReadRequest) -> dict[str, object]:
    """Return dict[str, object] identity fields from a SourceReadRequest.
    Exclude page size/cursor so continuation shares identity; pure, no mutation.
    """
    document = cast("dict[str, object]", asdict(request))
    document.pop("cursor")
    document.pop("page_size")
    return document


def source_page(
    items: tuple[SourceItem, ...],
    request: SourceReadRequest,
    *,
    inspection_sha256: str,
    input_bytes: int,
    entries: int,
    output_bytes: int,
) -> SourceReadResult:
    """Return complete typed items fitting request pagination and output_bytes.

    The str digest binds prior inspection; int counters report observed reads.
    Raise ValueError for stale cursors and OSError for insufficient output space.
    Pure: never change items/request or perform I/O.
    """
    digest, offset = inspection_sha256, 0
    if request.cursor is not None:
        offset = request.cursor.offset
        if request.cursor.inspection_sha256 != digest or offset >= len(items):
            raise ValueError("Source continuation is stale or outside the result")
    result = SourceReadResult(
        operation=request.operation,
        items=(),
        total=len(items),
        inspection_sha256=digest,
        next_cursor=None,
        input_bytes=input_bytes,
        entries=entries,
    )
    if len(result.encode()) > output_bytes:
        raise OSError("Source output byte limit cannot hold result metadata")
    # Include JSON metadata and continuation bytes in every candidate page bound.
    for end in range(offset + 1, min(len(items), offset + request.page_size) + 1):
        cursor = (
            ReadCursor(inspection_sha256=digest, offset=end)
            if end < len(items)
            else None
        )
        candidate = replace(result, items=items[offset:end], next_cursor=cursor)
        if len(candidate.encode()) > output_bytes:
            if not result.items:
                raise OSError("Source output byte limit cannot hold one result row")
            break
        result = candidate
    return result
