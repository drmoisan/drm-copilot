"""Parse bounded discovery JSON/YAML without I/O or permissive fallback paths."""

from __future__ import annotations

import hashlib
import json
import math
from typing import TYPE_CHECKING, Literal, NoReturn, Protocol, cast

import yaml
from yaml.events import (
    AliasEvent,
    CollectionEndEvent,
    CollectionStartEvent,
    Event,
    MappingStartEvent,
    ScalarEvent,
)
from yaml.nodes import MappingNode, Node, ScalarNode, SequenceNode

from drm_copilot_discovery.findings import (
    Finding,
    FindingCollector,
    child_pointer,
    validate_finding_path,
)
from drm_copilot_discovery.models import JsonObject, ParsedDocument, ParseLimits

if TYPE_CHECKING:
    from collections.abc import Iterator

    from drm_copilot_discovery.models import JsonValue

_YAML_PREFIX = "tag:yaml.org,2002:"
_SCALAR_TAGS = frozenset(
    _YAML_PREFIX + tag for tag in ("str", "int", "float", "bool", "null")
)


class _ObjectPairs(list[tuple[str, object]]):
    """Preserve JSON members until duplicate and escaped-key collision checks."""


class _DiscoveryLoader(yaml.SafeLoader):
    """Compose YAML nodes only; the discovery visitor controls safe scalar conversion.

    No application constructors, merge expansion, or object deserialization are
    invoked. Each parse owns and disposes its loader without global registration.
    """


class _YamlApi(Protocol):
    """Narrow untyped PyYAML composition APIs without changing their implementation."""

    def parse(self, stream: str, *, Loader: type[yaml.SafeLoader]) -> Iterator[Event]:
        """Yield syntax events without constructing application objects."""
        ...

    def compose(self, stream: str, *, Loader: type[yaml.SafeLoader]) -> Node | None:
        """Return one syntactic node graph after the independent preflight budget."""
        ...


class _ScalarConstructor(Protocol):
    """Describe the two safe-loader methods used at the scalar conversion boundary."""

    def construct_object(self, node: ScalarNode) -> object:
        """Convert a previously whitelisted scalar tag into an untrusted value."""
        ...

    def dispose(self) -> None:
        """Release parser-local internal state without changing global constructors."""
        ...


_YAML = cast("_YamlApi", yaml)


class _LimitReached(Exception):
    """Stop bounded traversal immediately after its actionable finding is recorded."""


def _is_sequence(value: object) -> bool:
    """Recognize decoder arrays without leaking untyped list element annotations."""
    return type(value) is list or isinstance(value, SequenceNode)


class _DocumentReader:
    """Normalize one bounded node graph while collecting independent field defects.

    Parser-owned counters and ancestor identities prevent excessive expansion and
    cycles. It returns no partial graph when findings contain any blocking error.
    """

    def __init__(self, *, limits: ParseLimits, artifact_path: str | None) -> None:
        """Set finite policy and diagnostic context; allocate no external resources."""
        if artifact_path is not None:
            validate_finding_path(artifact_path)
        self.limits = limits
        self.path = artifact_path
        self.collector = FindingCollector(limit=limits.findings)
        self.records = 0
        self.nodes = 0
        self.ancestors: set[int] = set()
        self.scalar_loader = cast("_ScalarConstructor", _DiscoveryLoader(""))

    def error(self, code: str, message: str, pointer: str = "") -> None:
        """Collect a stable blocking defect with a local correction instruction."""
        self.collector.add(
            Finding(
                code=code,
                artifact_path=self.path,
                pointer=pointer,
                message=message,
                next_action="Correct this field and validate the document again.",
            )
        )

    def stop(self, code: str, message: str, pointer: str = "") -> NoReturn:
        """Record a resource violation before halting further traversal allocation."""
        self.error(code, message, pointer)
        raise _LimitReached

    def preflight(self, text: str, *, format: Literal["json", "yaml"]) -> None:
        """Reject excessive source nesting before recursive decoder construction."""
        depth = 0
        mappings = tokens = 0
        if format == "yaml":
            # Event parsing resolves grammar without constructing alias-expanded data.
            for event in _YAML.parse(text, Loader=_DiscoveryLoader):
                if isinstance(event, CollectionStartEvent):
                    depth += 1
                elif isinstance(event, CollectionEndEvent):
                    depth -= 1
                if depth > self.limits.nesting_depth:
                    self.stop(
                        "DOCUMENT_DEPTH",
                        "Document nesting exceeds the configured limit.",
                    )
                mappings += isinstance(event, MappingStartEvent)
                tokens += isinstance(
                    event, (CollectionStartEvent, ScalarEvent, AliasEvent)
                )
                self.check_source_budget(mappings, tokens)
            return
        quoted = escaped = primitive = False
        # Count JSON delimiters only outside strings; grammar remains json.loads-owned.
        for char in text:
            if quoted:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == '"':
                    quoted = False
                continue
            elif char == '"':
                quoted = True
                tokens += 1
                primitive = False
            elif char in "[{":
                depth += 1
                mappings += char == "{"
                tokens += 1
                primitive = False
                if depth > self.limits.nesting_depth:
                    self.stop(
                        "DOCUMENT_DEPTH",
                        "Document nesting exceeds the configured limit.",
                    )
            elif char in "]}":
                depth -= 1
                primitive = False
            elif char in ",: \t\r\n":
                primitive = False
            elif not primitive:
                tokens += 1
                primitive = True
            self.check_source_budget(mappings, tokens)

    def check_source_budget(self, mappings: int, tokens: int) -> None:
        """Bound decoder allocation; key tokens add at most one per value node."""
        if mappings > self.limits.artifact_records:
            self.stop(
                "DOCUMENT_RECORDS",
                "Structural mapping count exceeds the configured limit.",
            )
        if tokens > 2 * self.limits.expanded_nodes:
            self.stop(
                "DOCUMENT_NODES",
                "Source token count exceeds the configured node budget.",
            )

    def scalar(self, value: object, pointer: str) -> JsonValue:
        """Accept only finite JSON scalars and valid Unicode, without coercion."""
        if isinstance(value, ScalarNode):
            if value.tag not in _SCALAR_TAGS:
                self.error(
                    "DOCUMENT_VALUE_TYPE",
                    "YAML value is not a JSON-compatible scalar.",
                    pointer,
                )
                return None
            try:
                # Exclude timestamp, binary, object and custom constructors.
                value = self.scalar_loader.construct_object(value)
            except (ValueError, TypeError, KeyError, yaml.YAMLError):
                self.error(
                    "DOCUMENT_VALUE_TYPE",
                    "YAML scalar has an invalid tagged value.",
                    pointer,
                )
                return None
        if isinstance(value, str):
            try:
                value.encode("utf-8")
            except UnicodeError:
                self.error(
                    "DOCUMENT_ENCODING",
                    "String contains invalid Unicode scalar values.",
                    pointer,
                )
                return None
            return value
        if type(value) is float and not math.isfinite(value):
            self.error("DOCUMENT_NONFINITE", "JSON numbers must be finite.", pointer)
            return None
        if value is None or isinstance(value, (bool, int, float)):
            return value
        self.error("DOCUMENT_VALUE_TYPE", "Value is not JSON-compatible.", pointer)
        return None

    def mapping_items(
        self, value: _ObjectPairs | MappingNode, pointer: str
    ) -> list[tuple[str, object]]:
        """Preserve first values and diagnose every duplicate or unsupported key."""
        result: list[tuple[str, object]] = []
        seen: set[str] = set()
        pairs = value.value if isinstance(value, MappingNode) else value
        # Detect semantic key collisions before constructing any dictionary.
        for raw_key, child in pairs:
            if isinstance(raw_key, Node):
                if raw_key.tag == _YAML_PREFIX + "merge":
                    self.error(
                        "DOCUMENT_MERGE", "YAML merge keys are not permitted.", pointer
                    )
                    continue
                if (
                    not isinstance(raw_key, ScalarNode)
                    or raw_key.tag != _YAML_PREFIX + "str"
                ):
                    self.error(
                        "DOCUMENT_KEY_TYPE", "Object keys must be strings.", pointer
                    )
                    continue
                key = raw_key.value
            else:
                key = raw_key
            if not isinstance(key, str):
                self.error("DOCUMENT_KEY_TYPE", "Object keys must be strings.", pointer)
                continue
            try:
                key.encode("utf-8")
            except UnicodeError:
                self.error(
                    "DOCUMENT_ENCODING", "Object key contains invalid Unicode.", pointer
                )
                continue
            if key in seen:
                self.error(
                    "DOCUMENT_DUPLICATE_KEY",
                    "Object key occurs more than once.",
                    child_pointer(pointer, key),
                )
                continue
            seen.add(key)
            result.append((key, child))
        return result

    def visit(self, value: object, pointer: str = "", depth: int = 1) -> JsonValue:
        """Validate each expanded occurrence before constructing its immutable value."""
        self.nodes += 1
        if self.nodes > self.limits.expanded_nodes:
            self.stop(
                "DOCUMENT_NODES",
                "Expanded value count exceeds the configured limit.",
                pointer,
            )
        is_mapping = isinstance(value, (_ObjectPairs, MappingNode))
        is_sequence = _is_sequence(value) and not is_mapping
        if not is_mapping and not is_sequence:
            return self.scalar(value, pointer)
        if depth > self.limits.nesting_depth:
            self.stop(
                "DOCUMENT_DEPTH",
                "Expanded nesting exceeds the configured limit.",
                pointer,
            )
        if id(value) in self.ancestors:
            self.error("DOCUMENT_CYCLE", "YAML aliases must not form a cycle.", pointer)
            return None
        if isinstance(value, Node) and value.tag != _YAML_PREFIX + (
            "map" if is_mapping else "seq"
        ):
            self.error(
                "DOCUMENT_VALUE_TYPE",
                "YAML collection is not JSON-compatible.",
                pointer,
            )
            return None
        if is_mapping:
            self.records += 1
            if self.records > self.limits.artifact_records:
                self.stop(
                    "DOCUMENT_RECORDS",
                    "Structural mapping count exceeds the configured limit.",
                    pointer,
                )
        self.ancestors.add(id(value))
        try:
            if isinstance(value, (_ObjectPairs, MappingNode)):
                members: list[tuple[str, JsonValue]] = []
                # Normalize in key order so limits and diagnostic locations are stable.
                for key, child in sorted(self.mapping_items(value, pointer)):
                    members.append(
                        (key, self.visit(child, child_pointer(pointer, key), depth + 1))
                    )
                return JsonObject(tuple(members))
            children = (
                value.value
                if isinstance(value, SequenceNode)
                else cast("list[object]", value)
            )
            # Repeated alias occurrences consume budget independently.
            return tuple(
                self.visit(child, child_pointer(pointer, index), depth + 1)
                for index, child in enumerate(children)
            )
        finally:
            self.ancestors.remove(id(value))


def parse_document(
    content: bytes | str,
    *,
    format: Literal["json", "yaml"],
    artifact_path: str | None = None,
    limits: ParseLimits | None = None,
) -> ParsedDocument:
    """Return a normalized immutable object or deterministic bounded findings.

    Args:
        content: UTF-8 bytes or Unicode text, with an optional UTF-8 BOM.
        format: Explicit JSON or YAML syntax; no heuristic fallback is attempted.
        artifact_path: Trusted workspace-relative diagnostic path, never opened.
        limits: Root-owned finite policy; input fields cannot alter these limits.

    Returns:
        ParsedDocument with no partial value on malformed or over-limit input.
    Raises:
        ValueError: If the caller selects an unsupported format or unsafe path.
    Side Effects:
        None; no files, network, external constructors or global loader mutations.
    """
    if format not in ("json", "yaml"):
        raise ValueError("Document format must be json or yaml")
    reader = _DocumentReader(
        limits=limits or ParseLimits(), artifact_path=artifact_path
    )
    value: JsonObject | None = None
    digest: str | None = None
    try:
        try:
            raw = content.encode("utf-8") if isinstance(content, str) else content
            if len(raw) > reader.limits.document_bytes:
                reader.stop(
                    "DOCUMENT_BYTES",
                    "Document exceeds the configured UTF-8 byte limit.",
                )
            digest = hashlib.sha256(raw).hexdigest()
            text = raw.decode("utf-8-sig")
        except UnicodeError:
            reader.stop("DOCUMENT_ENCODING", "Document must contain valid UTF-8 text.")
        reader.preflight(text, format=format)
        # Contain untyped decoder outputs before traversing their nodes.
        decoded: object = (
            cast("object", json.loads(text, object_pairs_hook=_ObjectPairs))
            if format == "json"
            else _YAML.compose(text, Loader=_DiscoveryLoader)
        )
        normalized = reader.visit(decoded)
        if not isinstance(normalized, JsonObject):
            reader.error("DOCUMENT_ROOT", "Document root must be an object.")
        elif not reader.collector.findings:
            value = normalized
    except _LimitReached:
        pass
    except json.JSONDecodeError as error:
        reader.error(
            "DOCUMENT_SYNTAX",
            f"Invalid JSON syntax at line {error.lineno}, column {error.colno}.",
        )
    except yaml.MarkedYAMLError as error:
        mark = error.problem_mark
        location = f" at line {mark.line + 1}, column {mark.column + 1}" if mark else ""
        reader.error("DOCUMENT_SYNTAX", f"Invalid YAML syntax{location}.")
    except (yaml.YAMLError, ValueError, RecursionError):
        reader.error(
            "DOCUMENT_SYNTAX", "Document syntax or numeric representation is invalid."
        )
    finally:
        reader.scalar_loader.dispose()
    return ParsedDocument(
        value=value,
        findings=reader.collector.findings,
        source_sha256=digest,
        format=format,
    )
