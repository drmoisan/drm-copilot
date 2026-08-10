"""Validate the parallel-run manifest and resolve its documented defaults.

Purpose:
    Enforce the repository contract for the frontmatter of
    ``docs/features/parallel/<slug>/parallel.md`` -- spec invariants M1 through
    M7 -- and expose the two default-resolving accessors that every consumer of
    the manifest uses instead of reading ``mode`` and ``max_concurrency``
    directly.

Flow:
    Split the document on any of the three line terminators, take the leading
    ``---`` fenced block, parse it with ``yaml.safe_load``, then check run
    identity (``parallel``, ``mode``, ``max_concurrency``, ``created_at``),
    scan for prohibited keys, and delegate the ``items`` collection to
    ``scripts/dev_tools/_parallel_state_common.py`` so the manifest, planner,
    and orchestrator surfaces share one item-shape implementation.

Invariants and constraints:
    Validation is a library call, not an MCP artifact type (spec decision
    3.2-A), so this module registers no CLI subcommand. ``mode`` and
    ``max_concurrency`` are optional in the manifest: their absence is the
    documented authoring shape and contributes zero errors, while the accessors
    supply ``closed`` and ``4``. No JSON Schema file is authored or imported;
    enforcement is this module's logic plus the prose rules. Every error string
    begins with the literal prefix ``Parallel manifest`` and ends with a period,
    so the TypeScript parity port has one shape to mirror.

Raises and side effects:
    None anywhere in this module. Every function is pure: it raises nothing,
    performs no I/O, and reads but never mutates its arguments.
"""

from __future__ import annotations

import re
from typing import cast

import yaml

from scripts.dev_tools._parallel_state_common import (
    VALID_MODES,
    enum_error,
    in_bounded_range,
    is_integer,
    is_non_empty_string,
    scan_prohibited_keys,
    validate_items,
)

# Literal context prefix for every error this module and its helpers emit.
CONTEXT = "Parallel manifest"

# The fence line that opens and closes a YAML frontmatter block.
FRONTMATTER_FENCE = "---"

# Documented default run mode when the manifest omits ``mode`` (invariant M3).
DEFAULT_MODE = "closed"

# Documented default fan-out when the manifest omits ``max_concurrency``
# (invariant M4, design sections 11 and 13.4).
DEFAULT_MAX_CONCURRENCY = 4

# Inclusive bounds on a present ``max_concurrency`` (invariant M4, A7).
MIN_CONCURRENCY = 1
MAX_CONCURRENCY = 8

# Keys the manifest rejects at any nesting level (invariant M7). Ordering is
# never declared in a parallel run; it is derived from blast-radius overlap.
MANIFEST_DEEP_PROHIBITED_KEYS: tuple[str, ...] = ("depends_on",)

# Keys the manifest rejects at the document root only (invariant M7). A nested
# ``integration_branch`` is legitimate child data; a run-level one is not,
# because each parallel item opens its own pull request against ``main``.
MANIFEST_TOP_LEVEL_PROHIBITED_KEYS: tuple[str, ...] = ("integration_branch",)

# Matches each of the three line terminators a manifest may be authored with.
# The alternation is ordered so ``\r\n`` is consumed as one terminator rather
# than as a carriage return followed by an empty line (precedent: commit
# b845c505, which fixed the same defect in the plan validator).
LINE_ENDING_PATTERN = re.compile(r"\r\n|\n|\r")


def split_source_lines(text: str) -> list[str]:
    """Split manifest text into lines under any of the three line endings.

    Args:
        text (str): Raw manifest document text, authored with LF, CRLF, or CR
            terminators. Mixed terminators within one document are tolerated.

    Returns:
        list[str]: The source lines with their terminators removed. An empty
        document yields a single empty line, which fails the opening-fence
        check like any other non-fence first line.

    Raises:
        None.

    Side Effects:
        None.
    """

    return LINE_ENDING_PATTERN.split(text)


def extract_frontmatter_body(text: str) -> tuple[str | None, list[str]]:
    """Extract the leading YAML frontmatter body (invariant M1).

    Args:
        text (str): Raw manifest document text.

    Returns:
        tuple[str | None, list[str]]: The frontmatter body joined with newlines
        and an empty error list on success; ``(None, [<error>])`` when the
        document does not open with a fence or the block is never closed. The
        body excludes both fence lines and may be empty, which the caller
        rejects as a non-mapping.

    Raises:
        None.

    Side Effects:
        None.
    """

    lines = split_source_lines(text)
    if not lines or lines[0].strip() != FRONTMATTER_FENCE:
        return None, [
            f"{CONTEXT} must open with a '{FRONTMATTER_FENCE}' frontmatter fence."
        ]

    # Scan forward for the first closing fence: everything between the two
    # fences is the YAML body, and a document with no second fence has an
    # unterminated block rather than an empty one.
    for index in range(1, len(lines)):
        if lines[index].strip() == FRONTMATTER_FENCE:
            return "\n".join(lines[1:index]), []

    return None, [
        f"{CONTEXT} frontmatter block is not terminated by " f"'{FRONTMATTER_FENCE}'."
    ]


def parse_manifest_frontmatter(
    text: str,
) -> tuple[dict[str, object] | None, list[str]]:
    """Parse manifest frontmatter into a mapping (invariant M1).

    Isolates the untyped ``yaml.safe_load`` boundary so every other function in
    this module works against a narrowed mapping.

    Args:
        text (str): Raw manifest document text.

    Returns:
        tuple[dict[str, object] | None, list[str]]: The parsed mapping and an
        empty error list on success; ``(None, [<error>])`` for a missing,
        unterminated, unparseable, or non-mapping frontmatter block. A single
        error is returned in each failure case, because no field check is
        meaningful without a mapping to read fields from.

    Raises:
        None.

    Side Effects:
        None.
    """

    body, errors = extract_frontmatter_body(text)
    if body is None:
        return None, errors

    try:
        parsed = yaml.safe_load(body)
    except yaml.YAMLError as exc:
        return None, [f"{CONTEXT} frontmatter is not valid YAML: {exc}."]

    if not isinstance(parsed, dict):
        return None, [f"{CONTEXT} frontmatter must be a mapping."]
    return cast("dict[str, object]", parsed), []


def manifest_mode(mapping: dict[str, object]) -> str:
    """Resolve the run mode declared by a manifest mapping (invariant M3).

    Args:
        mapping (dict[str, object]): A parsed manifest frontmatter mapping.

    Returns:
        str: The declared ``mode`` when the key carries a string, otherwise
        ``closed``. A present but non-string value also resolves to the
        default so this accessor always satisfies its return type; the
        malformed value is reported separately by
        ``validate_parallel_manifest_text``.

    Raises:
        None.

    Side Effects:
        None.
    """

    mode = mapping.get("mode")
    return mode if isinstance(mode, str) else DEFAULT_MODE


def manifest_max_concurrency(mapping: dict[str, object]) -> int:
    """Resolve the fan-out cap declared by a manifest mapping (invariant M4).

    Args:
        mapping (dict[str, object]): A parsed manifest frontmatter mapping.

    Returns:
        int: The declared ``max_concurrency`` when the key carries a
        non-boolean integer, otherwise ``4``. A present but non-integer value
        also resolves to the default so this accessor always satisfies its
        return type; the malformed value is reported separately by
        ``validate_parallel_manifest_text``.

    Raises:
        None.

    Side Effects:
        None.
    """

    concurrency = mapping.get("max_concurrency")
    if is_integer(concurrency):
        return cast("int", concurrency)
    return DEFAULT_MAX_CONCURRENCY


def _validate_identity(mapping: dict[str, object]) -> list[str]:
    """Validate run identity fields against invariants M2 through M5.

    The ``mode`` and ``max_concurrency`` checks are presence-gated because both
    keys are optional: absence is the documented authoring shape that the
    accessors resolve, so it must contribute no error.

    Args:
        mapping (dict[str, object]): A parsed manifest frontmatter mapping.

    Returns:
        list[str]: One error per violated condition, in schema field order.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    if not is_non_empty_string(mapping.get("parallel")):
        errors.append(f"{CONTEXT} parallel must be a non-empty string.")

    mode = mapping.get("mode")
    if "mode" in mapping and mode not in VALID_MODES:
        errors.append(enum_error(CONTEXT, "mode", VALID_MODES, mode))

    concurrency = mapping.get("max_concurrency")
    if "max_concurrency" in mapping and not in_bounded_range(
        concurrency, MIN_CONCURRENCY, MAX_CONCURRENCY
    ):
        errors.append(
            f"{CONTEXT} max_concurrency must be an integer from "
            f"{MIN_CONCURRENCY} through {MAX_CONCURRENCY}; found: {concurrency!r}."
        )

    if not is_non_empty_string(mapping.get("created_at")):
        errors.append(f"{CONTEXT} created_at must be a non-empty string.")
    return errors


def validate_parallel_manifest_text(text: str) -> list[str]:
    """Validate a parallel-run manifest document against invariants M1 to M7.

    Args:
        text (str): Raw manifest document text, authored with LF, CRLF, or CR
            line endings.

    Returns:
        list[str]: Validation errors for a malformed manifest; an empty list
        when the manifest is valid. A frontmatter failure returns a
        single-element list. An empty ``items`` list is valid: a manifest may
        be authored before any item is admitted (schema S1).

    Raises:
        None.

    Side Effects:
        None; the input text is parsed into a fresh object that is never
        written back.
    """

    mapping, parse_errors = parse_manifest_frontmatter(text)
    if mapping is None:
        return parse_errors

    errors: list[str] = []
    errors.extend(_validate_identity(mapping))
    errors.extend(
        scan_prohibited_keys(
            mapping,
            CONTEXT,
            deep_keys=MANIFEST_DEEP_PROHIBITED_KEYS,
            top_level_keys=MANIFEST_TOP_LEVEL_PROHIBITED_KEYS,
        )
    )
    # The manifest carries `kind` on every item, unlike the orchestrator
    # checkpoint, so the shared item validator is asked to require it (S1).
    errors.extend(validate_items(mapping.get("items"), CONTEXT, require_kind=True))
    return errors
