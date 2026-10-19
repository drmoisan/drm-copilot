"""Extract bounded Python dependency declarations without executing configuration.

Only requirements lines and explicit setup.cfg install/extras lists are supported.
Markers retain recognized variable names, never values or evaluated applicability.
All results use the shared sanitized carrier; paths and includes remain inert.
"""

from __future__ import annotations

import configparser
import re
from typing import TYPE_CHECKING, Literal

from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyAnchor,
    DependencyBudget,
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
    safe_identifier,
)

if TYPE_CHECKING:
    from collections.abc import Iterator

_NAME = re.compile(r"([A-Za-z0-9][A-Za-z0-9._-]*)(?:\[([^\]]*)\])?(.*)\Z")
_CONSTRAINT = re.compile(
    r"(==|!=|<=|>=|~=|<|>)\s*" r"([0-9]+(?:\.[0-9A-Za-z*]+)*(?:[-+][0-9A-Za-z.-]+)?)\Z"
)
_REFERENCE = re.compile(
    r"(?:[A-Za-z][A-Za-z0-9+.-]*://|git\+|hg\+|svn\+|git@|file:|"
    r"\.{1,2}/|/|\\|[A-Za-z]:[\\/])"
)
_MARKER = re.compile(
    r"([a-z_]+)\s*(?:==|!=|<=|>=|~=|<|>|not\s+in\b|in\b)\s*"
    r"(?:'[^'\r\n]*'|\"[^\"\r\n]*\")"
)
_MARKER_NAMES = frozenset(
    "python_version python_full_version os_name sys_platform platform_release "
    "platform_system platform_version platform_machine platform_python_implementation "
    "implementation_name implementation_version extra".split()
)
_SECTION = re.compile(r"\[([^\]]+)\]\Z")
_CONJUNCTION = re.compile(r"\s+(?:and|or)\s+")


class _IniParser(configparser.ConfigParser):
    """Validate one bounded INI document with disjoint equals-only option matching.

    The caller reserves input work/storage before constructing this local parser.
    ConfigParser still owns duplicate detection, continuation grouping and value
    trimming. OPTCRE (re.Pattern[str]) forbids equals in the option group, so
    whitespace cannot be repartitioned between repetitions. Default metadata is
    unused: this class only reads, never serializes. No I/O or shared state changes.
    """

    OPTCRE = re.compile(r"(?P<option>[^=]+)(?P<vi>=)(?P<value>.*)$")


def _lines(text: str) -> Iterator[tuple[int, str]]:
    """Yield (int, str) physical lines from text (str); no errors or side effects."""
    # Only CR/LF delimit source lines; Unicode separators are not physical anchors.
    for number, match in enumerate(re.finditer(r"[^\r\n]*(?:\r\n|\r|\n|$)", text), 1):
        if match.start() != match.end():
            yield number, match.group().rstrip("\r\n")


def _uncomment(line: str) -> str:
    """Trim unquoted comments from line (str); return str, no errors/side effects."""
    quote = ""
    # Quoted marker values and URL fragments must not acquire comment semantics.
    for index, char in enumerate(line):
        # Quotes change the active delimiter only outside another quoted value.
        if char in "\"'":
            if not quote:
                quote = char
            elif quote == char:
                quote = ""
        elif char == "#" and not quote and (index == 0 or line[index - 1].isspace()):
            return line[:index].strip()
    return line.strip()


def _markers(condition: str, budget: DependencyBudget) -> tuple[str, ...]:
    """Retain variable names from a finite quoted-comparison conjunction grammar.

    condition (str) is transient text; budget (DependencyBudget) bounds scans and
    names. Return tuple[str, ...]; raise DependencyInputError on unsupported,
    malformed or exhausted input. Mutates budget only; never evaluates values.
    """
    budget.reserve(nodes=len(condition) + 1)
    remaining = condition.strip()
    names: set[str] = set()
    offset = 0
    # Consume by offsets to avoid repeated suffix copying on long conjunctions.
    while offset < len(remaining):
        match = _MARKER.match(remaining, offset)
        if match is None or match[1] not in _MARKER_NAMES:
            raise DependencyInputError("dependency-unsupported")
        budget.reserve(nodes=1)
        names.add(match[1])
        offset = match.end()
        separator = _CONJUNCTION.match(remaining, offset)
        # Only a conjunction may extend the expression after a complete comparison.
        if separator is not None:
            offset = separator.end()
        elif remaining[offset:].strip():
            raise DependencyInputError("dependency-unsupported")
        else:
            break
    if not names:
        raise DependencyInputError("dependency-malformed")
    return tuple(sorted(names))


def _version(value: str) -> str | None:
    """Return safe str/None from value (str); no evaluation or side effects.

    Raise DependencyInputError for unsupported bounded constraint syntax.
    """
    if not value:
        return None
    if len(value) > 256:
        raise DependencyInputError("dependency-unsupported")
    clauses: list[str] = []
    # Every clause must be recognized before whitespace normalization can join text.
    for clause in value.split(","):
        match = _CONSTRAINT.fullmatch(clause.strip())
        if match is None:
            raise DependencyInputError("dependency-unsupported")
        clauses.append(match[1] + match[2])
    return ",".join(clauses)


def _requirement(
    value: str, *, line: int, location: str, role: str, budget: DependencyBudget
) -> None:
    """Add one sanitized declaration at a physical line, never a resolved target.

    value (str) is raw text; line (int) is its positive physical position;
    location (str) is a closed list anchor; role (str) is its safe group identifier.
    budget (DependencyBudget) owns work and immutable output. Return None; raise
    DependencyInputError for malformed/unsupported/exhausted input. Mutates budget
    only; failure discards caller results and never follows reference targets.
    """
    budget.reserve(nodes=len(value) + 1)
    value = _uncomment(value)
    if not value:
        return
    # Options, escaping and dynamic setup directives are outside the finite grammar.
    if value.startswith(("-", "attr:")) or value.endswith("\\"):
        raise DependencyInputError("dependency-unsupported")
    if location != "requirements" and value.startswith("file:"):
        raise DependencyInputError("dependency-unsupported")
    body, separator, condition = value.partition(";")
    markers = _markers(condition, budget) if separator else ()
    body = body.strip()
    extras: tuple[str, ...] = ()
    name: str | None = None
    # Recognize target syntax before package names so credentials never become names.
    if _REFERENCE.match(body):
        version = body
    else:
        match = _NAME.fullmatch(body)
        if match is None or safe_identifier(match[1]) is None:
            raise DependencyInputError("dependency-malformed")
        name = match[1]
        if match[2] is not None:
            budget.reserve(nodes=len(match[2]) + 1)
            # Retain explicit extra names only after their bounded text scan is charged.
            extras = tuple(part.strip() for part in match[2].split(","))
            # Refuse the entire list if any extra is not a safe identifier.
            if any(safe_identifier(extra) is None for extra in extras):
                raise DependencyInputError("dependency-malformed")
        tail = match[3].strip()
        # Direct references use shared redaction; ordinary tails must be constraints.
        if tail.startswith("@"):
            version = tail[1:].strip()
            if not _REFERENCE.match(version):
                raise DependencyInputError("dependency-unsupported")
        else:
            version = _version(tail)
    # Physical line is also a deterministic occurrence within each closed container.
    budget.add(
        kind="declaration",
        ecosystem="python",
        name=name,
        version=version,
        role=role,
        anchor=DependencyAnchor("text", location, occurrence=line, line=line),
        condition_present=bool(separator),
        extras=extras,
        markers=markers,
    )


def _ini(text: str, budget: DependencyBudget) -> None:
    """Validate strict INI then locate only explicit dependency lists; no I/O.

    text (str) is bounded input; budget (DependencyBudget) owns work/results.
    Return None; raise DependencyInputError for malformed, ambiguous, unsupported
    or exhausted input. Mutates budget only; no inheritance, expansion or I/O.
    """
    # Bound the parser's second scan and normalized value storage before allocation.
    budget.reserve(nodes=len(text) + 1, text_bytes=4 * len(text))
    parser = _IniParser(interpolation=None, strict=True, empty_lines_in_values=False)
    failed = False
    try:
        parser.read_string(text.replace("\r\n", "\n").replace("\r", "\n"))
    except configparser.Error:
        failed = True
    if failed:
        raise DependencyInputError("dependency-malformed")
    if parser.defaults():
        raise DependencyInputError("dependency-ambiguous")
    section, location, role = "", "", ""
    indentation: int | None = None
    # Locate raw values only after ConfigParser accepts duplicate and INI structure.
    for number, raw in _lines(text):
        budget.reserve(nodes=1)
        stripped = raw.strip()
        if not stripped:
            location = ""
            indentation = None
            continue
        if stripped.startswith(("#", ";")):
            continue
        depth = len(raw) - len(raw.lstrip())
        header = _SECTION.fullmatch(stripped)
        # Explicit unindented headers reset list ownership; defaults stay forbidden.
        if header is not None:
            budget.reserve(nodes=1)
            if depth or header[1] == "DEFAULT":
                raise DependencyInputError("dependency-ambiguous")
            section, location = header[1], ""
            indentation = None
            continue
        if indentation is not None and depth > indentation:
            # A nonselected option owns its continuations even if they resemble keys.
            if location:
                _requirement(
                    stripped, line=number, location=location, role=role, budget=budget
                )
            continue
        key, separator, value = stripped.partition("=")
        if not separator:
            raise DependencyInputError("dependency-unsupported")
        key = key.strip().lower()
        location, role, indentation = "", "", depth
        # Only these explicit setuptools lists carry dependency declarations.
        if section == "options" and key == "install_requires":
            location, role = "options.install_requires", "install"
        elif section == "options.extras_require":
            if safe_identifier(key) is None:
                raise DependencyInputError("dependency-unsupported")
            location, role = "options.extras_require", key
        if location:
            _requirement(
                value, line=number, location=location, role=role, budget=budget
            )


def parse_python_dependencies(
    content: bytes,
    *,
    format: Literal["requirements", "setup-cfg"],
    limits: DependencyLimits,
) -> DependencyResult:
    """Return immutable sanitized Python declarations from captured bytes.

    Args:
        content (bytes): Captured UTF-8 bytes, optionally BOM-prefixed. CR/LF
            delimit physical source anchors; referenced inputs remain inert.
        format (Literal["requirements", "setup-cfg"]): Select requirements lines
            or explicit setuptools install/extras lists in strict configuration.
        limits (DependencyLimits): Positive byte, line, work, candidate and text
            capacities. Work includes character scans and declarations; text
            includes decoded input, conservative INI storage and shared carriers.
            Both formats are flat; no recursive depth traversal is performed.

    Returns:
        DependencyResult: Immutable sanitized declarations, fixed diagnostics and
            consumed work/text counters. Markers retain names/presence only;
            target values are redacted. Source order and physical anchors persist.

    Raises:
        DependencyInputError: Fixed malformed, encoding, unsupported, ambiguous or
            limit failure. Failure discards the whole population, including prefixes.
        ValueError: Invalid caller format or non-byte input, using fixed messages.

    No includes, expansion, package loading, marker evaluation, filesystem,
    process/network access or writes occur; input bytes and limits are unchanged.
    """
    if format not in {"requirements", "setup-cfg"}:
        raise ValueError("Unsupported Python dependency format")
    budget = DependencyBudget(limits)
    text = budget.decode(content)
    # Charge the full scan and transient text before indexing or regex allocation.
    budget.reserve(nodes=len(text) + 1, text_bytes=len(content))
    if "\x00" in text:
        raise DependencyInputError("dependency-encoding")
    # Both finite formats share byte/work limits and never follow referenced inputs.
    if format == "setup-cfg":
        _ini(text, budget)
    else:
        # Preserve source order and physical anchors without materializing all lines.
        for line, value in _lines(text):
            _requirement(
                value, line=line, location="requirements", role="direct", budget=budget
            )
    return budget.result()
