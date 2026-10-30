"""Parse bounded solution-text declarations without resolving project identities.

Only literal Project declarations are extracted. Configuration sections, GUID
semantics, solution-folder ownership and project activation remain unevaluated.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import cast

_GUID = r"\{[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\}"
_ENTRY = re.compile(
    rf'^\s*Project\("(?P<type>{_GUID})"\)\s*=\s*"(?P<name>[^"]+)",'
    rf'\s*"(?P<path>[^"]+)",\s*"(?P<id>{_GUID})"\s*$'
)


class SolutionInputError(ValueError):
    """Retain a portable parser rejection code without leaking decoding details."""

    def __init__(self, code: str, message: str) -> None:
        """Store code/message (str); return None, without I/O or input mutation."""
        self.code = code
        super().__init__(message)


@dataclass(frozen=True, kw_only=True)
class SolutionEntry:
    """Retain literal solution fields and their actual single-line declaration anchor.

    GUIDs and paths describe source text, not resolved identity or reachable files.
    """

    line: int
    name: str
    path: str
    project_type: str
    project_id: str

    def __post_init__(self) -> None:
        """Validate declared fields; return None or raise ValueError, without I/O.

        line must be a positive int; names/paths must be nonblank str and GUID text
        must match the solution grammar. Constructor fields remain unmodified.
        """
        # Keep scalar invariants independent from later declaration projection.
        if type(self.line) is not int or self.line < 1:
            raise ValueError("Solution anchors must be positive integers")
        # Empty names or paths cannot represent a usable literal declaration.
        if any(
            type(value) is not str or not value.strip()
            for value in (self.name, self.path)
        ):
            raise ValueError("Solution names and paths must be nonblank strings")
        # GUID syntax is validated without assigning language or folder semantics.
        if any(
            type(value) is not str or re.fullmatch(_GUID, value) is None
            for value in (self.project_type, self.project_id)
        ):
            raise ValueError("Solution GUIDs must match literal GUID syntax")


def parse_solution(
    content: bytes, *, max_bytes: int, max_entries: int
) -> tuple[SolutionEntry, ...]:
    """Return ordered literal project declarations from retained solution bytes.

    content (bytes) accepts UTF-8 or BOM-marked UTF-16/32. max_bytes/max_entries
    (int) are positive budgets capped at 64 MiB/100000. Invalid parameters raise
    ValueError; decoding, header, block syntax or budget errors raise
    SolutionInputError. Returns tuple[SolutionEntry, ...] without partial output.
    No path resolution, I/O, external process, or input mutation occurs.
    """
    # Bound caller configuration before allocating decoding or declaration state.
    for value, ceiling in ((max_bytes, 67108864), (max_entries, 100000)):
        if type(value) is not int or not 1 <= value <= ceiling:
            raise ValueError("Solution limits must be positive bounded integers")
    if not isinstance(cast("object", content), bytes):
        raise ValueError("Solution input must be retained bytes")
    if len(content) > max_bytes:
        raise SolutionInputError("input-limit", "Solution bytes exceed their limit.")
    # Only explicit BOMs select wide encodings; undecodable bytes fail closed.
    encoding = "utf-8-sig"
    if content.startswith((b"\xff\xfe\x00\x00", b"\x00\x00\xfe\xff")):
        encoding = "utf-32"
    elif content.startswith((b"\xff\xfe", b"\xfe\xff")):
        encoding = "utf-16"
    try:
        text = content.decode(encoding)
    except UnicodeError as exc:
        raise SolutionInputError(
            "solution-encoding", "Solution encoding is unsupported."
        ) from exc
    # Solution records use physical CR/LF boundaries; other Unicode stays literal.
    lines = re.split(r"\r\n|\r|\n", text)
    # Require a supported header before any project declaration can become a fact.
    if not any(
        line.startswith("Microsoft Visual Studio Solution File, Format Version ")
        for line in lines[:3]
    ):
        raise SolutionInputError(
            "solution-header", "Solution format header is missing."
        )
    results: list[SolutionEntry] = []
    in_project = False
    # Reject incomplete/nested blocks instead of presenting a truncated inventory.
    for number, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped == "EndProject":
            if not in_project:
                raise SolutionInputError("solution-project", "Unexpected EndProject.")
            in_project = False
        elif re.match(r"Project\b", stripped):
            match = _ENTRY.fullmatch(line)
            if (
                in_project
                or match is None
                or not match["name"].strip()
                or not match["path"].strip()
            ):
                raise SolutionInputError(
                    "solution-project", "Solution project declaration is malformed."
                )
            if len(results) >= max_entries:
                raise SolutionInputError(
                    "declaration-limit", "Solution declarations exceed their limit."
                )
            results.append(
                SolutionEntry(
                    line=number,
                    name=match["name"],
                    path=match["path"],
                    project_type=match["type"],
                    project_id=match["id"],
                )
            )
            in_project = True
    if in_project:
        raise SolutionInputError(
            "solution-project", "Solution project block is incomplete."
        )
    return tuple(results)
