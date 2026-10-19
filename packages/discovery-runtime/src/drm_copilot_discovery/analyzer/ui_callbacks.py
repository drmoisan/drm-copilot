"""Observe a finite WPF XAML dialect without loading controls or executing code.

Only literal declarations become facts. Conventional retained .xaml.cs files and
simple lexical class/member names support inferred relevance, never bound targets.
Resources, templates, property elements and foreign/custom subtrees are opaque.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.csharp_declarations import declaration_candidates
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError, decode_source
from drm_copilot_discovery.analyzer.findings import (
    diagnostic,
    pinned_matches,
    row,
    source_reference,
    stable_id,
    tool,
)
from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture
from drm_copilot_discovery.analyzer.source_text import Detection
from drm_copilot_discovery.analyzer.xml_input import XmlInputError, parse_xml
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.path_models import relative_path

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryInput
    from drm_copilot_discovery.repository_reader import RepositoryFile

_WPF = "{http://schemas.microsoft.com/winfx/2006/xaml/presentation}"
_CLASS = "{http://schemas.microsoft.com/winfx/2006/xaml}Class"
_ROOTS = frozenset({_WPF + "Window", _WPF + "Page", _WPF + "UserControl"})
_EVENTS = {
    "Window": frozenset({"Loaded", "Unloaded", "Closing", "Closed"}),
    "Page": frozenset({"Loaded", "Unloaded"}),
    "UserControl": frozenset({"Loaded", "Unloaded"}),
    "Button": frozenset({"Click"}),
    "CheckBox": frozenset({"Checked", "Unchecked", "Indeterminate"}),
    "RadioButton": frozenset({"Checked", "Unchecked"}),
    "TextBox": frozenset({"TextChanged"}),
    "ComboBox": frozenset({"SelectionChanged"}),
    "ListBox": frozenset({"SelectionChanged"}),
}
_ELEMENTS = frozenset(_EVENTS) | frozenset(
    "Grid StackPanel DockPanel WrapPanel Canvas Border "
    "ScrollViewer ContentControl".split()
)
_NAME = re.compile(r"[A-Za-z_][A-Za-z_0-9]*\Z")
_CLASS_NAME = re.compile(r"[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)*\Z")


def callback_candidates(
    path: str,
    content: bytes,
    *,
    max_bytes: int = 67108864,
    max_elements: int = 100000,
    max_depth: int = 64,
    max_candidates: int = 100000,
) -> tuple[Detection, ...]:
    """Return literal class/event declarations from relative str path and bytes.

    Positive int byte/element/depth limits default to 64 MiB/100000/64 and use
    parse_xml's hard ceilings. int max_candidates permits 0..100000. Invalid
    configuration raises ValueError; unsafe XML, dialect or names raise
    XmlInputError; candidate exhaustion raises SourceScanError. Only ASCII names
    (handler <=128, qualified class <=512 characters) are supported. No I/O or
    caller mutation occurs; anchors are parser-reported containing-element lines,
    not physical opening-tag lines. Multiline tags/bare CR retain parser precision.
    """
    relative_path(path)
    if type(max_candidates) is not int or not 0 <= max_candidates <= 100000:
        raise ValueError("UI candidate limit must be between 0 and 100000")
    nodes = parse_xml(
        content, max_bytes=max_bytes, max_elements=max_elements, max_depth=max_depth
    )
    if nodes[0].tag not in _ROOTS:
        raise XmlInputError("ui-dialect", "Only supported WPF roots are inspected.")
    class_name = nodes[0].attribute(_CLASS) or ""
    if class_name and (len(class_name) > 512 or not _CLASS_NAME.fullmatch(class_name)):
        raise XmlInputError("ui-class", "The declared class name is unsupported.")
    results: list[Detection] = []
    active: list[bool] = []
    # Parent-first flags make unsupported subtrees opaque without ancestor rescans.
    for index, node in enumerate(nodes):
        name = node.tag.removeprefix(_WPF)
        allowed = node.tag.startswith(_WPF) and name in _ELEMENTS
        active.append(allowed and (node.parent is None or active[node.parent]))
        if not active[-1]:
            continue
        # Examine literal attributes once; sorted parser attributes stabilize order.
        for attribute, value in node.attributes:
            is_class = index == 0 and attribute == _CLASS and bool(class_name)
            if not is_class and attribute not in _EVENTS.get(name, ()):
                continue
            if not is_class and (len(value) > 128 or not _NAME.fullmatch(value)):
                raise XmlInputError(
                    "ui-handler", "The declared handler is unsupported."
                )
            if len(results) >= max_candidates:
                raise SourceScanError(
                    "ui-candidate-limit", "UI candidates exceed limits."
                )
            results.append(
                Detection(
                    path,
                    node.line,
                    "ui_class" if is_class else "ui_callback",
                    value,
                    "class" if is_class else "handler",
                    (
                        ("ordinal", index),
                        ("end_line", node.line),
                        ("element", name),
                        ("attribute", "x:Class" if is_class else attribute),
                        ("class_name", class_name),
                    ),
                )
            )
    return tuple(results)


def _failure(code: str, path: str | None, *, blocking: bool = True) -> JsonObject:
    """Return fixed str code/path diagnostic with bool severity; no I/O or leaks."""
    return diagnostic(
        code,
        path,
        "Inspect supported WPF declarations and captured inputs/limits. "
        "Class, namespace, method binding and runtime execution remain unresolved.",
        analyzer="ui-callbacks",
        blocking=blocking,
    )


class _Run:
    """Own bounded private indexes and output for one immutable capture analysis.

    Construct from InventoryCapture, then inspect selected markup. Pin and input
    bytes, scan/index units, result rows and serialized-text reservations have
    independent limits. Only private counters/collections mutate; no I/O occurs.
    SourceScanError aborts aggregate exhaustion without releasing partial results.
    """

    def __init__(self, capture: InventoryCapture) -> None:
        """Index bounded capture inputs/pins; return None or raise SourceScanError.

        capture (InventoryCapture) has validated path/count semantics. Every retained
        pin is charged before indexing; duplicate identities remain distinct.
        """
        self.capture = capture
        self.limit = min(capture.profile.limits.artifact_records, 100000)
        self.input_left = self.output_left = capture.profile.limits.document_bytes
        self.scan_left = 2 * self.limit
        self.maximum = min(capture.profile.analyzers.max_file_bytes, 67108864)
        # Captured path uniqueness permits one direct conventional-file lookup.
        self.paths = {item.path: item for item in capture.inputs}
        self.pins: dict[str, list[RepositoryFile]] = {}
        self.components: list[JsonObject] = []
        self.findings: list[JsonObject] = []
        self.relationships: list[JsonObject] = []
        self.diagnostics: list[JsonObject] = []
        pin_bytes = capture.profile.limits.document_bytes
        if len(capture.repository_files) > capture.profile.limits.source_files:
            raise SourceScanError("analysis-work-limit", "UI pin count exceeds limits.")
        # A single retained-pin pass bounds lookup work independently of input work.
        for source in capture.repository_files:
            pin_bytes -= len(source.content)
            if pin_bytes < 0:
                raise SourceScanError(
                    "analysis-work-limit", "UI pin bytes exceed limits."
                )
            self.pins.setdefault(source.path, []).append(source)

    def reserve(self, count: int, cost: int) -> None:
        """Reserve int count rows at int cost bytes each; return None, mutate budgets.

        SourceScanError precedes any projected allocation when either bound fails.
        """
        if count > self.limit:
            raise SourceScanError("analysis-limit", "UI rows exceed limits.")
        if count * cost > self.output_left:
            raise SourceScanError("analysis-text-limit", "UI output exceeds limits.")
        self.limit -= count
        self.output_left -= count * cost

    def local(self, item: InventoryInput) -> InventoryCapture:
        """Return one-item capture with only its indexed pins; pure, no byte copies.

        item (InventoryInput) belongs to this run. Accepted pinned_matches retains
        exact repository/revision/path/byte comparison with aggregate linear work.
        """
        return InventoryCapture(
            profile=self.capture.profile,
            inputs=(item,),
            repository_files=tuple(self.pins.get(item.path, ())),
        )

    def payload(self, item: InventoryInput) -> tuple[bytes, int]:
        """Charge item bytes and conservative parse/index work; return bytes/int cap.

        item (InventoryInput) must retain a file. Raises SourceScanError for absent
        or exhausted data before parsing. Each selected file is requested once;
        scan reservations bound tokens/nodes and resulting index entries together.
        """
        if item.file is None:
            raise SourceScanError("input-unreadable", "UI input is unavailable.")
        content = item.file.content
        units = min(max(1, len(content)), 100000)
        if len(content) > self.input_left or 2 * units > self.scan_left:
            raise SourceScanError("analysis-work-limit", "UI scan exceeds limits.")
        self.input_left -= len(content)
        self.scan_left -= 2 * units
        return content, units

    def code(
        self, path: str, cost: int
    ) -> tuple[JsonObject | None, dict[str, int], dict[tuple[str, str], int]]:
        """Index a retained conventional path once; return provenance/class/method maps.

        path (str) is derived from markup path, never x:Class. cost (int) reserves
        diagnostic text. Absent/excluded paths return empty maps; unavailable or
        invalid code adds fixed diagnostics. Resource errors propagate. Namespace,
        partial/generic scope, signatures and preprocessing remain unbound.
        """
        item = self.paths.get(path)
        if item is None or item.status == "excluded":
            return None, {}, {}
        self.reserve(1, cost)
        try:
            content, units = self.payload(item)
            candidates = declaration_candidates(
                path, decode_source(content, max_bytes=self.maximum), max_tokens=units
            )
        except SourceScanError as error:
            if error.code == "analysis-work-limit":
                raise
            self.diagnostics.append(_failure(error.code, path))
            return None, {}, {}
        classes: dict[str, int] = {}
        methods: dict[tuple[str, str], int] = {}
        # Count names without collapsing overloads, duplicate classes or partials.
        for candidate in candidates:
            if candidate.detection_kind == "type" and candidate.symbol_kind == "class":
                classes[candidate.symbol] = classes.get(candidate.symbol, 0) + 1
            elif (
                candidate.detection_kind == "member"
                and candidate.symbol_kind == "method"
            ):
                key = (str(dict(candidate.extra)["declaring_type"]), candidate.symbol)
                methods[key] = methods.get(key, 0) + 1
        local = self.local(item)
        pinned = pinned_matches(local, item)
        if not pinned:
            self.diagnostics.append(_failure("source-revision-unverified", path))
        return (
            row(source=source_reference(local, item), pinned=pinned),
            classes,
            methods,
        )

    def inspect(self, item: InventoryInput) -> None:
        """Inspect one markup input and append reserved rows; return None, no I/O.

        item (InventoryInput) is selected .xaml/.xml; per-file errors are fixed
        diagnostics. Aggregate SourceScanError propagates to discard partial output.
        """
        cost = 8192 + 12 * (
            len(item.path)
            + len(self.capture.profile.repository.id)
            + len(self.capture.profile.repository.revision or "")
        )
        self.reserve(3, cost)
        record_capacity = self.limit // 2
        text_capacity = self.output_left // (2 * cost)
        exhausted = (
            "analysis-limit"
            if record_capacity <= text_capacity
            else "analysis-text-limit"
        )
        try:
            content, units = self.payload(item)
            candidates = callback_candidates(
                item.path,
                content,
                max_bytes=self.maximum,
                max_elements=units,
                max_depth=min(self.capture.profile.limits.nesting_depth, 128),
                max_candidates=min(record_capacity, text_capacity),
            )
        except (SourceScanError, XmlInputError) as error:
            # Aggregate budget failures discard every prior projected result.
            if error.code == "analysis-work-limit":
                raise
            if error.code == "ui-candidate-limit":
                raise SourceScanError(
                    exhausted, "UI candidates exceed limits."
                ) from error
            self.diagnostics.append(_failure(error.code, item.path))
            return
        self.reserve(2 * len(candidates), cost)
        local = self.local(item)
        source, pinned = source_reference(local, item), pinned_matches(local, item)
        component_id = stable_id(
            "component",
            row(
                repository=source["repository"], path=item.path, analyzer="ui-callbacks"
            ),
        )
        self.components.append(
            row(
                component_id=component_id,
                component_type="ui-markup-file",
                source=source,
                analyzer=tool("ui-callbacks"),
                classification="detected",
                confidence="high" if pinned else "low",
                properties=(),
                extensions=row(),
            )
        )
        self.diagnostics.append(
            _failure("ui-binding-unresolved", item.path, blocking=False)
        )
        if not pinned:
            self.diagnostics.append(_failure("source-revision-unverified", item.path))
        # A filename convention proposes relevance only when markup has declarations.
        code, classes, methods = (
            self.code(item.path + ".cs", cost)
            if candidates and item.path.lower().endswith(".xaml")
            else (None, {}, {})
        )
        # Every occurrence keeps its own element/event anchor and unresolved target.
        for candidate in candidates:
            metadata = dict(candidate.extra)
            name = str(metadata["class_name"]).rsplit(".", 1)[-1]
            count = classes.get(name, 0)
            member_count = methods.get((name, candidate.symbol), 0)
            is_class = candidate.detection_kind == "ui_class"
            # Only a unique simple-name candidate is relevant; it still is not bound.
            status = (
                "missing-class"
                if not name or count == 0
                else (
                    "ambiguous"
                    if count > 1 or (not is_class and member_count > 1)
                    else (
                        "missing-method"
                        if not is_class and member_count == 0
                        else "unique-candidate"
                    )
                )
            )
            anchor = JsonObject(
                source.members
                + (("line_range", row(start=candidate.line, end=candidate.line)),)
            )
            identity = row(
                component=component_id,
                ordinal=metadata["ordinal"],
                attribute=metadata["attribute"],
            )
            extension = row(
                **{
                    "drm.ui-callbacks": row(
                        **metadata,
                        anchor="containing-element",
                        line_semantics="parser-reported",
                        binding="unresolved",
                        execution="unverified",
                        dialect="wpf",
                        interpretation="declaration",
                    )
                }
            )
            self.findings.append(
                row(
                    finding_id=stable_id("finding", identity),
                    component_id=component_id,
                    kind=candidate.detection_kind,
                    source=anchor,
                    analyzer=tool("ui-callbacks"),
                    classification="detected",
                    confidence="high" if pinned else "low",
                    properties=(row(name="symbol", value=candidate.symbol),),
                    extensions=extension,
                )
            )
            self.relationships.append(
                row(
                    relationship_id=stable_id("relationship", identity),
                    from_component_id=component_id,
                    to_component_id=None,
                    target_description=candidate.symbol,
                    kind=(
                        "possible-code-behind"
                        if is_class
                        else "possible-handler-method"
                    ),
                    source=anchor,
                    analyzer=tool("ui-callbacks"),
                    classification="inferred",
                    confidence=(
                        "medium"
                        if pinned and code is not None and code["pinned"]
                        else "low"
                    ),
                    extensions=row(
                        **{
                            "drm.ui-callbacks": row(
                                match_status=status,
                                code_candidate=code,
                                binding="unresolved",
                                preprocessing="not-evaluated",
                                execution="unverified",
                            )
                        }
                    ),
                )
            )


class UiCallbackAnalyzer:
    """Describe finite WPF declarations and inferred retained code relevance.

    Call analyze with an immutable InventoryCapture; no other analyzer selection,
    installed UI framework, compiler, source read or runtime action is required.
    Private per-call budgets prevent partial results after aggregate exhaustion.
    """

    identifier = "ui-callbacks"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return source-bound Analysis from InventoryCapture without I/O or mutation.

        Invalid capture types raise ValueError before indexing. Resource failures
        return one blocking diagnostic; unsupported files remain uninterpreted.
        """
        if not isinstance(cast("object", capture), InventoryCapture):
            raise ValueError("UI analysis requires a validated immutable capture")
        try:
            state = _Run(capture)
            # Capture ordering and exclusion decisions remain authoritative.
            for item in capture.inputs:
                if item.status != "excluded" and item.path.lower().endswith(
                    (".xaml", ".xml")
                ):
                    state.inspect(item)
        except SourceScanError as error:
            return Analysis(diagnostics=(_failure(error.code, None),))
        return Analysis(
            components=tuple(state.components),
            findings=tuple(state.findings),
            relationships=tuple(state.relationships),
            diagnostics=tuple(state.diagnostics),
        )
