"""Validate the parallel-run manifest and resolve its documented defaults.

Purpose:
    Enforce the repository contract for the frontmatter of
    ``docs/features/parallel/<slug>/parallel.md`` -- spec invariants M1 through
    M8 -- and expose the two default-resolving accessors that every consumer of
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
MAX_CONCURRENCY = 32

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


def _declared_issue_nums(items: object) -> set[int]:
    """Collect the positive-integer ``issue_num`` values a manifest declares.

    Purpose:
        Supply the resolution target for invariant M8's membership check
        without re-running the M6 item validation, so a malformed item is
        reported once by M6 and simply contributes no resolvable key here.

    Args:
        items (object): The manifest's ``items`` value, of any shape. A
            non-list, or an entry that is not a mapping or carries a
            non-positive-integer ``issue_num``, contributes nothing.

    Returns:
        set[int]: Every well-formed ``issue_num``. Empty when ``items`` is
        absent, malformed, or holds no well-formed entry.

    Raises:
        None.

    Side Effects:
        None.
    """

    if not isinstance(items, list):
        return set()
    declared: set[int] = set()
    # Accept only entries whose primary key is already well formed; a malformed
    # entry is M6's to report, and admitting it here would produce a second,
    # confusing error from M8 for the same defect.
    for entry in cast("list[object]", items):
        if not isinstance(entry, dict):
            continue
        issue_num = cast("dict[str, object]", entry).get("issue_num")
        if (
            isinstance(issue_num, int)
            and not isinstance(issue_num, bool)
            and issue_num > 0
        ):
            declared.add(issue_num)
    return declared


def _validate_component_members(
    members: object, position: str, declared: set[int], claimed: set[int]
) -> list[str]:
    """Validate one component's ``members`` list against invariant M8.

    Args:
        members (object): The component's ``members`` value, of any shape.
        position (str): The component's error-message prefix, already carrying
            the context and the component index.
        declared (set[int]): Every ``issue_num`` the manifest's ``items``
            collection declares, used as the resolution target.
        claimed (set[int]): Keys already claimed by an earlier component.
            MUTATED: each newly accepted key is added, so the caller's running
            set enforces the no-duplicate-membership rule across components.

    Returns:
        list[str]: One error per violated member condition, in member order.

    Raises:
        None.

    Side Effects:
        Adds every accepted key to ``claimed``.
    """

    if not isinstance(members, list) or not members:
        return [f"{position} members must be a non-empty list of positive integers."]

    errors: list[str] = []
    # Walk the declared members in order so the message sequence reproduces the
    # document. Each member is subjected to three successive gates and the
    # first failure ends that member's checks: an unusable value cannot be
    # resolved, and an unresolved key cannot meaningfully duplicate another.
    for index, member in enumerate(cast("list[object]", members)):
        slot = f"{position} members[{index}]"
        if not isinstance(member, int) or isinstance(member, bool) or member <= 0:
            errors.append(f"{slot} must be a positive integer; found: {member!r}.")
            continue
        if member not in declared:
            errors.append(
                f"{slot} does not resolve to an items[] issue_num; found: {member!r}."
            )
            continue
        if member in claimed:
            errors.append(
                f"{slot} repeats issue_num {member}, "
                f"already claimed by an earlier component."
            )
            continue
        claimed.add(member)
    return errors


def _validate_expected_conflict_components(mapping: dict[str, object]) -> list[str]:
    """Validate the optional ``expected_conflict_components`` key (M8).

    Purpose:
        Enforce the shape of the manifest's lane-grouping ASSERTION. The field
        is a diagnostic input only: nothing here feeds cohort computation,
        overrides a derived conflict edge, or influences scheduling.

    Args:
        mapping (dict[str, object]): A parsed manifest frontmatter mapping.

    Returns:
        list[str]: One error per violated condition, in document order. An
        EMPTY list when the key is absent, so a manifest that predates M8
        validates byte-identically to before.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Key-gated: absence is the overwhelmingly common shape and must cost the
    # caller nothing, so the whole invariant is skipped rather than defaulted.
    if "expected_conflict_components" not in mapping:
        return []

    components = mapping["expected_conflict_components"]
    if not isinstance(components, list):
        return [f"{CONTEXT} expected_conflict_components must be a list."]

    errors: list[str] = []
    declared = _declared_issue_nums(mapping.get("items"))
    claimed: set[int] = set()
    # Validate each component in place and thread one `claimed` set through the
    # whole traversal, so cross-component duplicate membership is decided in a
    # single pass without a second walk.
    for index, component in enumerate(cast("list[object]", components)):
        position = f"{CONTEXT} expected_conflict_components[{index}]"
        if not isinstance(component, dict):
            errors.append(f"{position} must be an object.")
            continue
        entry = cast("dict[str, object]", component)
        # Field order follows the documented authoring order: the optional
        # diagnostic label first, then the required membership list.
        if "name" in entry and not is_non_empty_string(entry["name"]):
            errors.append(f"{position} name must be a non-empty string.")
        errors.extend(
            _validate_component_members(
                entry.get("members"), position, declared, claimed
            )
        )
    return errors


def validate_parallel_manifest_text(text: str) -> list[str]:
    """Validate a parallel-run manifest document against invariants M1 to M8.

    Args:
        text (str): Raw manifest document text, authored with LF, CRLF, or CR
            line endings.

    Returns:
        list[str]: Validation errors for a malformed manifest; an empty list
        when the manifest is valid. A frontmatter failure returns a
        single-element list. An empty ``items`` list is valid: a manifest may
        be authored before any item is admitted (schema S1). Invariant M8 is
        key-gated, so a manifest without ``expected_conflict_components``
        produces exactly the list it produced before M8 existed.

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
    # M8 runs last because its membership check resolves against the same
    # `items` collection the previous call validated.
    errors.extend(_validate_expected_conflict_components(mapping))
    return errors
