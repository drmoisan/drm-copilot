"""Reserve renderer text and encoding work before retaining escaped output."""

from __future__ import annotations

import json
import math
from typing import cast

from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError


def utf8_path_size(value: str, *, limit: int) -> int:
    """Return UTF-8 bytes for path value (str) without allocating encoded data.

    limit (int) is a nonnegative remaining byte capacity. Invalid argument types
    or Unicode scalars raise ValueError; excess raises ReportLimitError before
    encoding. The linear scalar scan changes no input and performs no I/O.
    """
    if type(value) is not str or type(limit) is not int or limit < 0:
        raise ValueError("Path measurement requires text and nonnegative capacity")
    if len(value) > limit:
        raise ReportLimitError()
    size = 0
    # UTF-8 widths are determined directly so rejection needs no encoded copy.
    for character in value:
        code = ord(character)
        if 0xD800 <= code <= 0xDFFF:
            raise ValueError("Rendered path contains invalid Unicode")
        size += 1 if code < 128 else 2 if code < 2048 else 3 if code < 65536 else 4
        if size > limit:
            raise ReportLimitError()
    return size


def _plain(value: object) -> object:
    """Detach premeasured JSON value (object) for json.dumps; return JSON data.

    Called only after AcceptanceTextOutput.json has reserved copies and sorting.
    Malformed values fail there first; no input mutation, I/O or assessment occurs.
    """
    if type(value) in (dict, JsonObject):
        mapping = cast("dict[str, object] | JsonObject", value)
        members = mapping.members if type(mapping) is JsonObject else mapping.items()
        # Direct immutable pairs avoid repeated linear Mapping lookups.
        return {key: _plain(child) for key, child in members}
    if type(value) is tuple:
        # Preserve authored sequence order while detaching nested objects.
        return [_plain(child) for child in cast("tuple[object, ...]", value)]
    return value


class AcceptanceTextOutput:
    """Account for one complete bundle's bytes, nodes and operation work.

    Initialize with ParseLimits, then reserve fixed syntax and compact ASCII JSON
    before serialization. budget counts aggregate retained path/content bytes;
    work counts node visits, character traversals and comparison upper bounds.
    Only local counters mutate. Exhaustion exposes no partial bundle or I/O.
    """

    def __init__(self, limits: ParseLimits) -> None:
        """Initialize limits (ParseLimits); return None without I/O.

        Invalid policy raises ValueError; only this local budget is created.
        """
        self.budget = ReportBudget(limits)
        # Every physical LF is measured explicitly; no implicit JSON LF is needed.
        self.budget.bytes_left = limits.document_bytes

    def fixed(self, value: str) -> str:
        """Reserve fixed ASCII value (str); return it without copying.

        Raises ReportLimitError before excess retention; only local counters
        change. Callers supply static syntax or already validated identifier text.
        """
        self.budget.work(4 * len(value))
        self.budget.spend(len(value))
        return value

    def measure(self, value: object, depth: int = 1) -> None:
        """Reserve compact ensure_ascii JSON for value (object); return None.

        depth (int) is the current nesting level. Exact JSON scalars, tuples,
        dicts and JsonObject are supported. Invalid values raise ValueError;
        capacity raises ReportLimitError before serialization. No I/O occurs.
        """
        budget = self.budget
        if depth > budget.limits.nesting_depth or budget.nodes_left < 1:
            raise ReportLimitError()
        budget.nodes_left -= 1
        budget.work(4)
        # Container counts and sort/lookup work are reserved before child copies.
        if type(value) in (dict, JsonObject):
            mapping = cast("dict[str, object] | JsonObject", value)
            if budget.records_left < 1 or 2 * len(mapping) > budget.nodes_left:
                raise ReportLimitError()
            budget.records_left -= 1
            budget.spend(2 + max(0, len(mapping) - 1) + len(mapping))
            budget.work(4 * len(mapping))
            members = (
                mapping.members if type(mapping) is JsonObject else mapping.items()
            )
            # Reserve key comparisons independently from value traversal.
            for key, child in members:
                if type(key) is not str:
                    raise ValueError("Rendered JSON requires string keys")
                budget.work(4 * len(key) * max(1, len(mapping).bit_length()))
                self.measure(key, depth + 1)
                self.measure(child, depth + 1)
        elif type(value) is tuple:
            sequence = cast("tuple[object, ...]", value)
            if len(sequence) > budget.nodes_left:
                raise ReportLimitError()
            budget.spend(2 + max(0, len(sequence) - 1))
            # The depth ceiling also bounds malformed cyclic internal containers.
            for child in sequence:
                self.measure(child, depth + 1)
        elif type(value) is str:
            budget.work(20 * len(value))
            budget.spend(2)
            # Include DEL and supplementary surrogate-pair escapes exactly.
            for character in value:
                code = ord(character)
                if 0xD800 <= code <= 0xDFFF:
                    raise ValueError("Rendered text contains invalid Unicode")
                if character in '\\"\b\f\n\r\t':
                    budget.spend(2)
                elif code < 32 or code >= 127:
                    budget.spend(6 if code < 65536 else 12)
                else:
                    budget.spend(1)
        elif type(value) is int:
            if value.bit_length() > 63:
                raise ReportLimitError()
            budget.spend(len(str(value)))
        elif type(value) is float:
            if not math.isfinite(value):
                raise ValueError("Rendered JSON requires finite numbers")
            budget.spend(len(str(value)))
        elif value is None or type(value) is bool:
            budget.spend(4 if value is None or value is True else 5)
        else:
            raise ValueError("Rendered JSON requires immutable JSON values")

    def json(self, value: object) -> str:
        """Return measured compact ASCII JSON for value (object).

        ValueError/ReportLimitError propagate before encoding; only budget
        counters mutate. The returned literal cannot introduce a physical line.
        """
        before = self.budget.bytes_left
        self.measure(value)
        # At most 13 traversals: two encoder passes, two block copies, seven
        # Markdown copies, final encoding and file decoding. Candidate-block joins
        # occur on shorter paths. Reserve 16 independently of input scanning.
        self.budget.work(16 * (before - self.budget.bytes_left))
        return json.dumps(
            _plain(value),
            ensure_ascii=True,
            allow_nan=False,
            sort_keys=True,
            separators=(",", ":"),
        )

    def block(self, value: object) -> str:
        """Return a fixed fenced JSON block for value (object).

        Reserves syntax before concatenation; propagates ValueError and
        ReportLimitError. No caller mutation or I/O occurs.
        """
        prefix, suffix = self.fixed("```json\n"), self.fixed("\n```\n\n")
        return prefix + self.json(value) + suffix
