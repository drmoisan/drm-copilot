"""Read bounded configuration declarations without exporting any setting values.

JSON grammar belongs to the accepted document parser, XML to the secure parser,
and INI to strict ConfigParser. The INI locator mirrors only section/key anchors;
it never evaluates interpolation or substitutes for grammar validation.
"""

from __future__ import annotations

import configparser
import re
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.analyzer.xml_input import XmlInputError, parse_xml
from drm_copilot_discovery.findings import child_pointer
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.parsing import parse_document

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.xml_input import XmlNode
    from drm_copilot_discovery.models import JsonValue

ConfigurationFormat = Literal["json", "xml", "ini"]
_SETTINGS_NS = "{http://schemas.microsoft.com/VisualStudio/2004/01/settings}"


class ConfigurationInputError(ValueError):
    """Expose a fixed code/message while containing source-bearing parser errors.

    Parsers use this error only after selecting a constant code. No source text,
    exception representation, values or conditions enter its public attributes.
    """

    def __init__(self, code: str) -> None:
        """Store fixed str code; return None, without I/O or source interpolation."""
        self.code = code
        super().__init__("Configuration input is invalid, unsupported or over budget.")


@dataclass(frozen=True, kw_only=True)
class ConfigurationKey:
    """Retain only an identifier, structural address and declaration classification.

    Parser helpers construct these immutable values after checking allocation.
    line is a real XML element/INI declaration anchor, never a fabricated JSON
    location. origin_pointer identifies the declared default for inherited keys.
    No values or raw conditions are retained; construction performs no I/O.
    """

    name: str
    pointer: str
    kind: str
    line: int | None = None
    conditional: bool = False
    origin_pointer: str | None = None


class _Keys:
    """Own one bounded declaration buffer; reject before allocating another row.

    Parsing passes sanitized fields to add. Count and encoded-text budgets bound
    records and every constructed path. Twelve bytes per Unicode character bound
    compact UTF-8 JSON with ensure_ascii either true or false, including surrogate
    pair escapes; 128 bytes per record cover fixed fields. Overflow returns no tuple.
    """

    def __init__(self, limit: int, text_limit: int) -> None:
        """Bind positive int record/text limits; allocate an empty list, return None."""
        self.limit = limit
        self.remaining = text_limit
        self.values: list[ConfigurationKey] = []

    def reserve(self, cost: int) -> None:
        """Charge prospective int cost; return None or fixed error before allocation.

        Only this private budget is mutated. No source text or I/O is involved.
        """
        if cost > self.remaining:
            raise ConfigurationInputError("configuration-text-limit")
        self.remaining -= cost

    def address(self, parent: str, part: str | int) -> str:
        """Return escaped address only after charging prospective text allocation.

        parent (str) and part (str | int) are structural segments. Fixed error
        rejects expansion before child_pointer allocates it; no external effects.
        """
        segment = str(part)
        length = (
            len(parent) + 1 + len(segment) + segment.count("~") + segment.count("/")
        )
        self.reserve(12 * length)
        return child_pointer(parent, part)

    def add(
        self,
        name: str,
        pointer: str,
        kind: str,
        *,
        line: int | None = None,
        conditional: bool = False,
        origin_pointer: str | None = None,
    ) -> ConfigurationKey:
        """Append value-free fields and return ConfigurationKey; mutate this buffer.

        name/pointer/kind (str), line (int | None), conditional (bool) and
        origin_pointer (str | None) describe declarations, never values.
        ConfigurationInputError rejects excess allocation; no external I/O occurs.
        """
        if len(self.values) >= self.limit:
            raise ConfigurationInputError("configuration-limit")
        self.reserve(
            128
            + 12 * (len(name) + len(pointer) + len(kind) + len(origin_pointer or ""))
        )
        value = ConfigurationKey(
            name=name,
            pointer=pointer,
            kind=kind,
            line=line,
            conditional=conditional,
            origin_pointer=origin_pointer,
        )
        self.values.append(value)
        return value


def _json_walk(value: JsonValue, pointer: str, keys: _Keys) -> None:
    """Traverse immutable value/pointer into bounded keys; return None, no I/O.

    JsonValue value already passed depth/node limits. str pointer is RFC6901;
    _Keys keys receives identifiers only. ConfigurationInputError rejects output
    overflow. Scalar values and array items themselves never become findings.
    """
    # Object keys are declarations; arrays supply address segments only.
    if isinstance(value, JsonObject):
        # Accepted parsing already sorts keys and bounds recursive depth.
        for name, child in value.members:
            address = keys.address(pointer, name)
            keys.add(name, address, "json-key")
            _json_walk(child, address, keys)
    elif isinstance(value, tuple):
        # Preserve actual array indexes when nested objects contain settings keys.
        for index, child in enumerate(value):
            _json_walk(child, keys.address(pointer, index), keys)


def _json(content: bytes, limits: ParseLimits, keys: _Keys) -> None:
    """Validate retained bytes under ParseLimits; append keys or raise fixed error.

    keys (_Keys) receives no parser findings, messages or values. Returns None;
    ConfigurationInputError rejects malformed/root/budget failures. No I/O occurs.
    """
    parsed = parse_document(content, format="json", limits=limits)
    if parsed.value is None:
        # Choose fixed categories without copying source-derived error locations.
        codes = {finding.code for finding in parsed.findings}
        if codes & {
            "DOCUMENT_BYTES",
            "DOCUMENT_DEPTH",
            "DOCUMENT_RECORDS",
            "DOCUMENT_NODES",
        }:
            code = "configuration-limit"
        elif "DOCUMENT_ROOT" in codes:
            code = "configuration-json-root"
        else:
            code = "configuration-json-invalid"
        raise ConfigurationInputError(code)
    _json_walk(parsed.value, "", keys)


def _xml_attribute(nodes: tuple[XmlNode, ...], index: int) -> str | None:
    """Select a recognized declaration attribute, never arbitrary XML metadata.

    nodes (immutable XmlNode tuple) and index (int) locate a parsed element.
    Return key/name/Name or None. Only documented placements under supported
    roots qualify; nested value payloads are not reinterpreted as configuration.
    No I/O, evaluation, exceptions or mutation occur.
    """
    node = nodes[index]
    if node.parent is None:
        return None
    parent = nodes[node.parent]
    grand = nodes[parent.parent] if parent.parent is not None else None
    root = nodes[0].tag
    # Distinct root grammars prevent XML value payloads from masquerading as keys.
    if root in {"SettingsFile", _SETTINGS_NS + "SettingsFile"}:
        prefix = _SETTINGS_NS if root.startswith("{") else ""
        if (
            node.tag == prefix + "Setting"
            and parent.tag == prefix + "Settings"
            and parent.parent == 0
        ):
            return "Name"
    elif root == "settings":
        if node.tag == "setting" and node.parent == 0:
            return "name"
    else:
        container = parent.parent == 0 or (
            grand is not None and grand.tag == "location" and grand.parent == 0
        )
        if container and node.tag in {"add", "remove"}:
            if parent.tag == "appSettings":
                return "key"
            if parent.tag == "connectionStrings":
                return "name"
        if (
            node.tag == "setting"
            and grand is not None
            and grand.tag in {"userSettings", "applicationSettings"}
        ):
            ancestor = nodes[grand.parent] if grand.parent is not None else None
            if grand.parent == 0 or (
                ancestor is not None
                and ancestor.tag == "location"
                and ancestor.parent == 0
            ):
                return "name"
    return None


def _xml(content: bytes, limits: ParseLimits, keys: _Keys) -> None:
    """Extract supported XML keys with real element lines and inherited conditions.

    content (bytes), limits (ParseLimits) and keys (_Keys) remain local memory.
    Returns None. Fixed ConfigurationInputError contains every parser/root/key
    failure; only key records and private traversal metadata are allocated.
    """
    nodes: tuple[XmlNode, ...] | None = None
    try:
        nodes = parse_xml(
            content,
            max_bytes=limits.document_bytes,
            max_elements=limits.artifact_records,
            max_depth=limits.nesting_depth,
        )
    except XmlInputError:
        nodes = None
    if nodes is None:
        # Raise outside the handler so even exception context contains no values.
        raise ConfigurationInputError("configuration-xml-invalid")
    if nodes[0].tag not in {
        "configuration",
        "settings",
        "SettingsFile",
        _SETTINGS_NS + "SettingsFile",
    }:
        raise ConfigurationInputError("configuration-xml-root")
    pointers: list[str] = []
    conditional: list[bool] = []
    siblings: dict[int | None, int] = {}
    # Element-child indexes avoid copying arbitrary tag namespaces or attributes.
    for index, node in enumerate(nodes):
        ordinal = siblings.get(node.parent, 0)
        siblings[node.parent] = ordinal + 1
        prefix = pointers[node.parent] if node.parent is not None else ""
        pointer = keys.address(prefix, ordinal)
        pointers.append(pointer)
        inherited = conditional[node.parent] if node.parent is not None else False
        conditioned = (
            inherited
            or node.attribute("Condition") is not None
            or node.attribute("condition") is not None
            or node.tag == "location"
        )
        conditional.append(conditioned)
        attribute = _xml_attribute(nodes, index)
        if attribute is None:
            continue
        name = node.attribute(attribute)
        if name is None or not name.strip():
            raise ConfigurationInputError("configuration-xml-key")
        kind = "xml-key-removal" if node.tag == "remove" else "xml-key"
        keys.add(
            name,
            keys.address(pointer, "@" + attribute),
            kind,
            line=node.line,
            conditional=conditioned,
        )


class _IniParser(configparser.ConfigParser):
    """Keep strict stdlib grammar while removing overlapping option backtracking.

    Fixed delimiters make the negated class consume each name character once.
    ConfigParser trims names/values itself. Both locator and parser use OPTCRE;
    defaults, continuations, comments and duplicate handling stay in ConfigParser.
    """

    OPTCRE = re.compile(r"(?P<option>[^=:]*)(?P<vi>[=:])(?P<value>.*)$")

    def __init__(self) -> None:
        """Configure fixed strict/no-interpolation grammar; return None without I/O."""
        super().__init__(interpolation=None, strict=True, empty_lines_in_values=True)

    def optionxform(self, optionstr: str) -> str:
        """Return str optionstr unchanged; no I/O or external side effects."""
        return optionstr


def _ini(content: bytes, keys: _Keys) -> None:
    """Validate strict case-preserving INI and locate explicit/default/inherited keys.

    content (bytes) is UTF-8 with optional BOM; keys (_Keys) bounds output.
    Returns None. Fixed ConfigurationInputError replaces all encoding, missing
    section, grammar and allocation failures; parser values never leave memory.
    """
    text = ""
    failure: str | None = None
    try:
        text = content.decode("utf-8-sig")
    except UnicodeError:
        failure = "configuration-encoding"
    if failure is not None:
        raise ConfigurationInputError(failure)
    if "\x00" in text:
        raise ConfigurationInputError("configuration-encoding")
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    if text.count("\n") >= 100000:
        raise ConfigurationInputError("configuration-limit")
    lines = text.split("\n")
    parser = _IniParser()
    section: str | None = None
    option: str | None = None
    indentation = 0
    explicit: dict[str, set[str]] = {}
    defaults: dict[str, ConfigurationKey] = {}
    declarations = 0
    # Locate only grammar tokens; indented continuations cannot create new keys.
    for number, line in enumerate(lines, 1):
        stripped = line.strip()
        if not stripped or stripped.startswith(("#", ";")):
            continue
        current_indent = len(line) - len(line.lstrip())
        if option is not None and current_indent > indentation:
            continue
        indentation = current_indent
        header = parser.SECTCRE.match(stripped)
        if header is not None:
            # The fixed stdlib header expression requires this named str group.
            section = cast("str", header.group("header"))
            option = None
            keys.add(
                section,
                keys.address("/section_declarations", declarations),
                "ini-section",
                line=number,
            )
            declarations += 1
            explicit.setdefault(section, set())
        elif section is not None:
            match = parser.OPTCRE.match(stripped)
            if match is not None:
                # OPTCRE requires the option group whenever its match succeeds.
                option = cast("str", match.group("option")).rstrip()
                default = section == parser.default_section
                prefix = "/defaults" if default else keys.address("/sections", section)
                key = keys.add(
                    option,
                    keys.address(prefix, option),
                    "ini-default-key" if default else "ini-key",
                    line=number,
                )
                explicit[section].add(option)
                if default:
                    defaults[option] = key
    try:
        parser.read_file(lines, source="<configuration>")
    except configparser.MissingSectionHeaderError:
        failure = "configuration-ini-section-required"
    except configparser.Error:
        failure = "configuration-ini-invalid"
    if failure is not None:
        # Do not return source-bearing ConfigParser exceptions, including context.
        raise ConfigurationInputError(failure)
    # Check the locator against parser-owned names without inspecting their values.
    if set(defaults) != set(parser.defaults()):
        raise ConfigurationInputError("configuration-ini-anchors")
    # Reject locator drift before constructing any inherited declaration paths.
    for name in parser.sections():
        if explicit[name] | set(defaults) != set(parser.options(name)):
            raise ConfigurationInputError("configuration-ini-anchors")
        # Inherited keys point back to actual default declarations, never new lines.
        for option, origin in defaults.items():
            if option not in explicit[name]:
                keys.add(
                    option,
                    keys.address(keys.address("/sections", name), option),
                    "ini-inherited-key",
                    line=origin.line,
                    origin_pointer=origin.pointer,
                )


def parse_configuration(
    content: bytes,
    *,
    format: ConfigurationFormat,
    max_bytes: int,
    max_keys: int,
    max_depth: int = 64,
    max_text_bytes: int | None = None,
) -> tuple[ConfigurationKey, ...]:
    """Return bounded identifiers/locations only from one retained configuration.

    content (bytes), format (json/xml/ini), max_bytes/max_keys/max_depth (int)
    select fixed parsing and finite bounds. max_text_bytes (int | None) separately
    bounds constructed paths and retained identifier text. Its default is four
    times max_bytes, capped at 64 MiB, allowing fixed output overhead for short
    input. Twelve bytes per Unicode character cover compact UTF-8
    JSON with either ensure_ascii setting, including surrogate-pair escapes;
    128 bytes per key cover fixed fields. Raises ValueError for invalid caller
    limits; ConfigurationInputError contains all selected-input failures. No I/O,
    interpolation, condition evaluation or external resource loading occurs.
    """
    limits = ParseLimits(
        document_bytes=max_bytes, artifact_records=max_keys, nesting_depth=max_depth
    )
    if max_keys > 100000 or format not in {"json", "xml", "ini"}:
        raise ValueError("Configuration format and key budget must be supported")
    text_limit = (
        min(4 * max_bytes, 67108864) if max_text_bytes is None else max_text_bytes
    )
    if type(text_limit) is not int or not 1 <= text_limit <= 67108864:
        raise ValueError("Configuration text budget must be between 1 and 67108864")
    if len(content) > max_bytes:
        raise ConfigurationInputError("configuration-limit")
    keys = _Keys(max_keys, text_limit)
    # Fixed format dispatch cannot execute a configured parser or module name.
    if format == "json":
        _json(content, limits, keys)
    elif format == "xml":
        _xml(content, limits, keys)
    else:
        _ini(content, keys)
    return tuple(keys.values)
