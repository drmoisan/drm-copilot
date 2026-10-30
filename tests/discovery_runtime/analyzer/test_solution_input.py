"""Test solution-text declarations using bounded in-memory byte sequences."""

from __future__ import annotations

from dataclasses import FrozenInstanceError, replace
from typing import cast

import pytest
from drm_copilot_discovery.analyzer.solution_input import (
    SolutionEntry,
    SolutionInputError,
    parse_solution,
)

HEADER = "Microsoft Visual Studio Solution File, Format Version 12.00\n"
GUID = "{11111111-2222-3333-4444-555555555555}"


def solution(path: str = "src\\Example App.csproj", *, count: int = 1) -> str:
    """Return synthetic solution text for path (str) and duplicate count (int).

    Returns str; no resolution, I/O or shared mutation. Caller supplies small counts.
    """
    return HEADER + (
        f'Project("{GUID}") = "État", "{path}", "{GUID}"\nEndProject\n' * count
    )


def parse(content: bytes, **limits: int) -> tuple[SolutionEntry, ...]:
    """Parse content (bytes) with local budgets overridden by limits (int kwargs).

    Returns tuple[SolutionEntry, ...]; propagates parser errors without I/O.
    """
    options = {"max_bytes": 8192, "max_entries": 20}
    options.update(limits)
    return parse_solution(content, **options)


@pytest.mark.parametrize("encoding", ["utf-8", "utf-8-sig", "utf-16", "utf-32"])
@pytest.mark.parametrize("newline", ["\n", "\r\n"])
def test_solution_bytes_preserve_literal_fields_and_duplicate_anchors(
    encoding: str, newline: str
) -> None:
    """Given encoding/newline (str), preserve literal text and duplicate entries.

    Returns None; assertions detect data loss. No I/O or project-path evaluation.
    """
    entries = parse(solution(count=2).replace("\n", newline).encode(encoding))
    assert [entry.line for entry in entries] == [2, 4]
    assert entries[0].path == "src\\Example App.csproj"
    assert entries[0].name == "État"
    assert entries[0].project_type == entries[0].project_id == GUID
    assert replace(entries[0], line=4) == entries[1]


@pytest.mark.parametrize(
    "path",
    [
        "../Peer/Peer.csproj",
        "C:\\Elsewhere\\App.fsproj",
        "$(Root)/App.vbproj",
        "**/*.csproj",
        "https://invalid.invalid/App.csproj",
    ],
)
def test_foreign_parent_expression_and_wildcard_paths_stay_inert(path: str) -> None:
    """Retain path (str) literally, without resolving it or requiring a local file.

    Returns None; assertion failure reveals transformation. No I/O or shared state.
    """
    assert parse(solution(path).encode())[0].path == path


@pytest.mark.parametrize(
    "text,code",
    [
        ("", "solution-header"),
        ("Other Format\n", "solution-header"),
        (HEADER + 'Project("bad") = "bad"\n', "solution-project"),
        (HEADER + "EndProject\n", "solution-project"),
        (solution().removesuffix("EndProject\n"), "solution-project"),
        (
            solution().replace("EndProject\n", solution().removeprefix(HEADER)),
            "solution-project",
        ),
        (solution().replace('"État"', '" "'), "solution-project"),
        (solution().replace('"src\\Example App.csproj"', '" "'), "solution-project"),
        (solution().replace("Project(", "Project ("), "solution-project"),
    ],
)
def test_malformed_solution_does_not_return_partial_entries(
    text: str, code: str
) -> None:
    """Reject text (str) with expected code (str), never a partial declaration tuple.

    Returns None; SolutionInputError is required. No I/O or external fixture state.
    """
    with pytest.raises(SolutionInputError) as caught:
        parse(text.encode())
    assert caught.value.code == code


def test_unknown_bytes_are_not_decoded_by_machine_locale() -> None:
    """Fail explicitly on bytes outside the accepted encoding set.

    Returns None; requires SolutionInputError. Takes no arguments; no I/O.
    """
    with pytest.raises(SolutionInputError) as caught:
        parse(b"\xffunmarked-byte")
    assert caught.value.code == "solution-encoding"


def test_sections_are_retained_as_uninterpreted_surrounding_text() -> None:
    """Ignore configuration/global sections without claiming evaluated semantics.

    Returns None; asserts project detection remains intact. No arguments or I/O.
    """
    text = solution().replace(
        "EndProject",
        "ProjectSection(Unresolved) = preProject\n"
        " X = Y\nEndProjectSection\nEndProject",
    )
    assert len(parse((text + "Global\nEndGlobal\n").encode())) == 1
    assert parse(HEADER.encode()) == ()


@pytest.mark.parametrize(
    "limits,code",
    [({"max_bytes": 1}, "input-limit"), ({"max_entries": 1}, "declaration-limit")],
)
def test_byte_and_declaration_budgets_fail_closed(
    limits: dict[str, int], code: str
) -> None:
    """For limits (dict[str,int]), require code (str) before excess allocation.

    Returns None; expected SolutionInputError. No I/O or partial results.
    """
    with pytest.raises(SolutionInputError) as caught:
        parse(solution(count=2).encode(), **limits)
    assert caught.value.code == code


@pytest.mark.parametrize(
    "limits",
    [
        {"max_bytes": 0},
        {"max_bytes": 67108865},
        {"max_entries": 0},
        {"max_entries": True},
        {"max_entries": 100001},
    ],
)
def test_invalid_limits_cannot_disable_bounding(limits: dict[str, int]) -> None:
    """Reject malformed limits (dict[str,int]); return None after expected ValueError.

    Uses only in-memory values and no external configuration.
    """
    with pytest.raises(ValueError, match="positive bounded integers"):
        parse(HEADER.encode(), **limits)


@pytest.mark.parametrize("field", ["path", "name"])
def test_retained_byte_contract_and_frozen_result_are_enforced(field: str) -> None:
    """Reject implicit encoding and mutation of a parsed solution record.

    field (str) selects an immutable text field. Returns None;
    ValueError/FrozenInstanceError are required. No I/O or shared mutation.
    """
    with pytest.raises(ValueError, match="retained bytes"):
        parse(cast("bytes", cast("object", HEADER)))
    entry = parse(solution().encode())[0]
    with pytest.raises(FrozenInstanceError):
        setattr(entry, field, "other")


@pytest.mark.parametrize(
    "changes",
    [
        {"line": 0},
        {"line": True},
        {"name": ""},
        {"path": None},
        {"project_type": "bad"},
        {"project_id": 1},
    ],
)
def test_solution_entry_invariants(changes: dict[str, object]) -> None:
    """Reject changes (dict[str,object]) to typed immutable result invariants.

    Returns None after expected ValueError; no I/O or shared mutation.
    """
    entry = parse(solution().encode())[0]
    with pytest.raises(ValueError):
        replace(entry, **changes)


@pytest.mark.parametrize(
    "path", ["", "abc", " Ωé ", "A012" * 15, "../x", "\\x", "a/b c"]
)
def test_literal_path_round_trip(path: str) -> None:
    """Generated path (str) survives parsing at the exact byte/entry boundary.

    Returns None; assertions expose normalization or truncation. No I/O or mutation.
    """
    literal = "root/" + path
    content = solution(literal).encode()
    assert parse(content, max_bytes=len(content), max_entries=1)[0].path == literal


@pytest.mark.parametrize("newline", ["\n", "\r\n", "\r"])
@pytest.mark.parametrize(
    "separator", ["\v", "\f", "\x1c", "\x1d", "\x1e", "\x85", "\u2028", "\u2029"]
)
def test_unicode_comment_separators_preserve_physical_anchor(
    separator: str, newline: str
) -> None:
    """Keep separator (str) inside a comment on one physical newline (str) record.

    Returns None; assertions detect shifted source anchors. No I/O or mutation.
    """
    text = (
        HEADER
        + "# inert comment"
        + separator
        + "still the same comment\n"
        + solution().removeprefix(HEADER)
    )
    entries = parse(text.replace("\n", newline).encode())
    assert len(entries) == 1
    assert entries[0].line == 3


@pytest.mark.parametrize("newline", ["\n", "\r\n", "\r"])
@pytest.mark.parametrize(
    "separator", ["\v", "\f", "\x1c", "\x1d", "\x1e", "\x85", "\u2028", "\u2029"]
)
def test_unicode_separators_in_quoted_path_remain_literal(
    separator: str, newline: str
) -> None:
    """Round-trip separator (str) in a quoted path with physical newline (str).

    Returns None; assertions detect text loss or false line breaks. No I/O.
    """
    literal = "src/App" + separator + "Name.csproj"
    entries = parse(solution(literal).replace("\n", newline).encode())
    assert len(entries) == 1
    assert entries[0].path == literal
    assert entries[0].line == 2
