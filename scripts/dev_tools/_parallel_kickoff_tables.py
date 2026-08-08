"""Markdown table primitives for the parallel kickoff contract.

Purpose:
    Hold the table-parsing helpers used by
    ``scripts/dev_tools/parallel_kickoff_contract.py`` so that neither module
    exceeds the repository's 500-line file-size limit.

Responsibilities:
    Parse pipe-delimited Markdown rows, enforce the strict header/separator
    table contract, and parse the optional integrity section. The module knows
    nothing about kickoff sections, headings, or the invocation grammar; those
    remain in the contract module that imports these helpers.

Scope boundaries:
    This module is a private helper (``_``-prefixed, following the existing
    ``_parallel_state_common``/``_parallel_state_structures`` convention) and
    imports nothing from the contract module, so the dependency direction is
    one-way and free of import cycles.
"""

from __future__ import annotations

import re

# The optional integrity section pins the run-level head commit of the
# ``parallel/<slug>-plan`` plan-home branch. Git accepts abbreviated object
# names, so the field tolerates 7 through 64 hexadecimal characters.
INTEGRITY_COMMIT_RE = re.compile(
    r"^(?:-\s*)?planning_commit:\s*`?(?P<commit>[0-9a-fA-F]{7,64})`?\s*$"
)

HASH_HEADERS = {"plan-hash", "plan_hash", "git-blob-sha", "git_blob_sha"}


def _parse_cells(line: str) -> list[str] | None:
    """Parse one pipe-delimited Markdown table row.

    Purpose:
        Convert a single table line into trimmed cell values, and signal a
        non-table line so callers can report it precisely.

    Args:
        line (str): One raw document line, with or without surrounding space.

    Returns:
        list[str] | None: Trimmed, backtick-stripped cell values, or ``None``
        when the line is not a pipe-delimited row.

    Raises:
        None.

    Side Effects:
        None.
    """

    stripped = line.strip()
    if not stripped.startswith("|") or not stripped.endswith("|"):
        return None
    return [cell.strip().strip("`") for cell in stripped[1:-1].split("|")]


def _is_separator(cells: list[str]) -> bool:
    """Return whether every cell is a Markdown table separator.

    Purpose:
        Distinguish a genuine header/body separator row from a data row, so a
        table missing its separator is rejected instead of silently treating
        the first data row as the separator.

    Args:
        cells (list[str]): Parsed cell values from one candidate row.

    Returns:
        bool: ``True`` when the row is non-empty and every cell is a dash run
        with optional alignment colons.

    Raises:
        None.

    Side Effects:
        None.
    """

    return bool(cells) and all(re.fullmatch(r":?-{3,}:?", cell) for cell in cells)


def table_rows(
    lines: list[str], expected_headers: tuple[str, ...]
) -> tuple[list[list[str]], list[str]]:
    """Parse a strict Markdown table with exact ordered headers.

    Purpose:
        Enforce the table contract shared by the item-summary table: exact
        ordered headers, a valid separator row, a fixed cell count per row,
        and at least one data row.

    Args:
        lines (list[str]): Body lines of the section holding the table.
        expected_headers (tuple[str, ...]): Required header cells, in order.

    Returns:
        tuple[list[list[str]], list[str]]: Accepted data rows paired with one
        error string per contract violation.

    Raises:
        None.

    Side Effects:
        None.
    """

    nonempty = [line for line in lines if line.strip()]
    if len(nonempty) < 2:
        return [], ["Parallel kickoff table is missing its header or separator row."]
    headers = _parse_cells(nonempty[0])
    separator = _parse_cells(nonempty[1])
    errors: list[str] = []
    # Header order is part of the contract because the row parser reads cells
    # positionally rather than by name.
    if headers != list(expected_headers):
        errors.append(
            "Parallel kickoff item table headers must be: "
            + " | ".join(expected_headers)
        )
    if (
        separator is None
        or len(separator) != len(expected_headers)
        or not _is_separator(separator)
    ):
        errors.append("Parallel kickoff table separator row is invalid.")
    rows: list[list[str]] = []
    # Collect the data rows, reporting and skipping any row whose shape does
    # not match the header width so later positional reads stay safe.
    for line in nonempty[2:]:
        cells = _parse_cells(line)
        if cells is None or len(cells) != len(expected_headers):
            errors.append(f"Parallel kickoff table row is invalid: {line}")
            continue
        rows.append(cells)
    if not rows:
        errors.append("Parallel kickoff item table must contain at least one item row.")
    return rows, errors


def _parse_integrity_table(
    table_lines: list[str],
) -> tuple[dict[str, str], list[str]]:
    """Parse the optional per-item plan-hash table.

    Purpose:
        Enforce the two-column integrity table contract: exact ``plan-path``
        header, an accepted hash-column header, a valid separator row, a full
        Git object hash per row, and no repeated plan path.

    Args:
        table_lines (list[str]): Pipe-delimited lines of the integrity table,
            in document order, header row first.

    Returns:
        tuple[dict[str, str], list[str]]: Plan path to lowercased hash, paired
        with one error string per contract violation.

    Raises:
        None.

    Side Effects:
        None.
    """

    plan_hashes: dict[str, str] = {}
    errors: list[str] = []
    header = _parse_cells(table_lines[0])
    # Reject a wrong header outright; without a trusted header the remaining
    # rows cannot be attributed to plan paths, so no row parsing is attempted.
    if (
        header is None
        or len(header) != 2
        or header[0] != "plan-path"
        or header[1] not in HASH_HEADERS
    ):
        errors.append(
            "Parallel kickoff integrity table headers must be plan-path and plan-hash."
        )
    elif len(table_lines) < 2:
        errors.append("Parallel kickoff integrity table is missing its separator row.")
    else:
        separator = _parse_cells(table_lines[1])
        if separator is None or len(separator) != 2 or not _is_separator(separator):
            errors.append("Parallel kickoff integrity table separator row is invalid.")
        # Record each plan-path/hash pair, rejecting malformed rows and
        # flagging a repeated plan path because a duplicate would make the
        # recorded hash for that plan ambiguous.
        for line in table_lines[2:]:
            cells = _parse_cells(line)
            if (
                cells is None
                or len(cells) != 2
                or not re.fullmatch(r"[0-9a-fA-F]{40,64}", cells[1])
            ):
                errors.append(
                    f"Parallel kickoff integrity table row is invalid: {line}"
                )
                continue
            if cells[0] in plan_hashes:
                errors.append(
                    f"Parallel kickoff integrity repeats plan path: {cells[0]!r}."
                )
            plan_hashes[cells[0]] = cells[1].lower()
    return plan_hashes, errors


def parse_integrity(lines: list[str]) -> tuple[str | None, dict[str, str], list[str]]:
    """Parse the optional run-level commit and per-item plan-hash fields.

    Purpose:
        Extract the head commit of the ``parallel/<slug>-plan`` plan-home
        branch and the per-item plan hashes from the optional ``## Integrity``
        section, so a caller can bind the kickoff to committed content.

    Args:
        lines (list[str]): Body lines of the ``## Integrity`` section. An
            absent section is passed as an empty list and yields no errors.

    Returns:
        tuple[str | None, dict[str, str], list[str]]: Lowercased plan-home head
        commit or ``None``, plan path to lowercased hash, and one error string
        per contract violation.

    Raises:
        None.

    Side Effects:
        None.
    """

    commit: str | None = None
    errors: list[str] = []
    table_lines: list[str] = []
    # Sort the section into its two permitted line shapes. Anything that is
    # neither the commit field nor a table row is an error rather than being
    # ignored, so a malformed integrity claim cannot pass silently.
    for line in lines:
        if not line.strip():
            continue
        match = INTEGRITY_COMMIT_RE.fullmatch(line.strip())
        if match:
            if commit is not None:
                errors.append(
                    "Parallel kickoff integrity has duplicate planning_commit fields."
                )
            commit = match.group("commit").lower()
        elif line.strip().startswith("|"):
            table_lines.append(line)
        else:
            errors.append(f"Parallel kickoff integrity line is invalid: {line}")
    plan_hashes: dict[str, str] = {}
    # The hash table is optional even when the commit field is present.
    if table_lines:
        plan_hashes, table_errors = _parse_integrity_table(table_lines)
        errors.extend(table_errors)
    return commit, plan_hashes, errors
