"""Tests for the parallel-run manifest contract, invariants M1 through M7.

Covers frontmatter extraction under all three line endings, the ``mode`` and
``max_concurrency`` default accessors, the S1 item table including
``issue_num`` uniqueness and the full ``blast_radius`` shape, and the
prohibited-key rejections. Manifest documents are rendered in-process from
dictionaries with ``yaml.safe_dump``; no temporary file is created.
"""

from __future__ import annotations

from typing import cast

import pytest
import yaml

from scripts.dev_tools._parallel_state_common import (
    BLAST_RADIUS_LIST_FIELDS,
    VALID_ITEM_STATES,
    VALID_KINDS,
    VALID_MODES,
    VALID_SOURCES,
)
from scripts.dev_tools.parallel_manifest_contract import (
    DEFAULT_MAX_CONCURRENCY,
    DEFAULT_MODE,
    manifest_max_concurrency,
    manifest_mode,
    parse_manifest_frontmatter,
    validate_parallel_manifest_text,
)

LINE_ENDINGS = ("\n", "\r\n", "\r")

# Sentinel meaning "delete this key" in a parametrized field matrix, so the
# absent-key case shares one test body with the malformed-value cases.
ABSENT = object()

# Prefix marking an item field that lives inside the ``blast_radius`` block.
RADIUS_FIELD_PREFIX = "blast_radius."

# Every accepted member of every per-item enum, as ``(field, value)`` pairs, so
# one test asserts that no enum member is rejected by the item table.
ITEM_ENUM_MEMBERS: list[tuple[str, str]] = (
    [("kind", value) for value in VALID_KINDS]
    + [("state", value) for value in VALID_ITEM_STATES]
    + [(f"{RADIUS_FIELD_PREFIX}source", value) for value in VALID_SOURCES]
)


def build_blast_radius() -> dict[str, object]:
    """Return a minimally valid, planner-declared blast-radius block."""

    return {
        "paths": ["scripts/dev_tools/**"],
        "modules": ["scripts"],
        "shared_surfaces": [],
        "contracts": [],
        "source": "declared",
        "computed_at": "2026-08-07T10-00",
    }


def build_valid_manifest() -> dict[str, object]:
    """Return a minimally valid manifest frontmatter mapping.

    Both optional keys (``mode`` and ``max_concurrency``) are omitted so the
    builder doubles as the absent-optional-key case for invariants M3 and M4.
    """

    return {
        "parallel": "wave-one",
        "created_at": "2026-08-07T10-00",
        "items": [
            {
                "issue_num": 444,
                "feature_folder": "2026-08-07-parallel-schema-validators-444",
                "kind": "feature",
                "state": "admitted",
                "blast_radius": build_blast_radius(),
            },
            {
                "issue_num": 445,
                "feature_folder": "2026-08-07-parallel-cohort-scheduler-445",
                "kind": "bug",
                "state": "admitted",
                "blast_radius": build_blast_radius(),
            },
        ],
    }


def render_manifest(mapping: dict[str, object], *, line_ending: str = "\n") -> str:
    """Render a frontmatter mapping as a manifest document."""

    body = yaml.safe_dump(mapping, sort_keys=False)
    document = f"---\n{body}---\n\n# Parallel run\n"
    return document.replace("\n", line_ending)


def validate(mapping: dict[str, object], *, line_ending: str = "\n") -> list[str]:
    """Render a manifest mapping and return the validator's error list."""

    return validate_parallel_manifest_text(
        render_manifest(mapping, line_ending=line_ending)
    )


def set_or_delete(mapping: dict[str, object], key: str, value: object) -> None:
    """Assign a manifest key, or delete it when the absent sentinel is given."""

    if value is ABSENT:
        mapping.pop(key, None)
    else:
        mapping[key] = value


def item_at(mapping: dict[str, object], index: int) -> dict[str, object]:
    """Return one ``items[]`` entry of a builder-produced manifest."""

    return cast("list[dict[str, object]]", mapping["items"])[index]


def radius_of(mapping: dict[str, object], index: int) -> dict[str, object]:
    """Return one item's ``blast_radius`` block of a builder manifest."""

    return cast("dict[str, object]", item_at(mapping, index)["blast_radius"])


def set_item_field(mapping: dict[str, object], field: str, value: object) -> None:
    """Assign a plain or ``blast_radius``-nested field on the first item."""

    # The dotted form is the only nesting the item table has, so one prefix
    # test is enough to route the assignment to the right mapping.
    if field.startswith(RADIUS_FIELD_PREFIX):
        radius_of(mapping, 0)[field[len(RADIUS_FIELD_PREFIX) :]] = value
    else:
        item_at(mapping, 0)[field] = value


@pytest.mark.parametrize("line_ending", LINE_ENDINGS)
def test_invariant_m1_parses_every_line_ending(line_ending: str) -> None:
    """A valid manifest authored with LF, CRLF, or CR validates cleanly."""

    assert validate(build_valid_manifest(), line_ending=line_ending) == []


@pytest.mark.parametrize(
    ("document", "expected"),
    [
        (
            "parallel: wave-one\n",
            "Parallel manifest must open with a '---' frontmatter fence.",
        ),
        ("", "Parallel manifest must open with a '---' frontmatter fence."),
        (
            "---\nparallel: wave-one\n",
            "Parallel manifest frontmatter block is not terminated by '---'.",
        ),
        ("---\nscalar\n---\n", "Parallel manifest frontmatter must be a mapping."),
        ("---\n---\n", "Parallel manifest frontmatter must be a mapping."),
    ],
)
def test_invariant_m1_rejects_malformed_frontmatter(
    document: str, expected: str
) -> None:
    """Each malformed frontmatter form yields exactly one literal error."""

    assert validate_parallel_manifest_text(document) == [expected]


def test_invariant_m1_rejects_unparseable_yaml() -> None:
    """Malformed YAML yields exactly one prefixed parse error."""

    errors = validate_parallel_manifest_text("---\n\tparallel: [1\n---\n")

    assert len(errors) == 1
    assert errors[0].startswith("Parallel manifest frontmatter is not valid YAML: ")


def test_parse_manifest_frontmatter_returns_the_mapping() -> None:
    """A well-formed document parses into its frontmatter mapping."""

    document = render_manifest(build_valid_manifest())
    mapping, errors = parse_manifest_frontmatter(document)

    assert errors == []
    assert mapping is not None
    assert mapping["parallel"] == "wave-one"


@pytest.mark.parametrize("slug", ["", "   ", 5, None, ["wave-one"], ABSENT])
def test_invariant_m2_rejects_a_blank_absent_or_non_string_slug(slug: object) -> None:
    """A blank, absent, or non-string slug is rejected."""

    mapping = build_valid_manifest()
    set_or_delete(mapping, "parallel", slug)

    assert "Parallel manifest parallel must be a non-empty string." in validate(mapping)


@pytest.mark.parametrize("mode", VALID_MODES)
def test_invariant_m3_accepts_every_mode_member(mode: str) -> None:
    """Each declared mode enum member validates cleanly."""

    mapping = build_valid_manifest()
    mapping["mode"] = mode

    assert validate(mapping) == []


def test_invariant_m3_rejects_an_out_of_enum_mode() -> None:
    """A mode outside the enum yields the shared enum error."""

    mapping = build_valid_manifest()
    mapping["mode"] = "ajar"

    assert (
        "Parallel manifest mode must be one of closed, open; found: 'ajar'."
        in validate(mapping)
    )


@pytest.mark.parametrize("key", ["mode", "max_concurrency"])
def test_invariants_m3_and_m4_absent_optional_keys_yield_no_error(key: str) -> None:
    """An absent optional key is the documented authoring shape."""

    mapping = build_valid_manifest()

    assert key not in mapping
    assert validate(mapping) == []


@pytest.mark.parametrize(
    ("mapping", "expected"),
    [
        ({}, DEFAULT_MODE),
        ({"mode": "open"}, "open"),
        ({"mode": "closed"}, "closed"),
        ({"mode": 3}, DEFAULT_MODE),
        ({"mode": None}, DEFAULT_MODE),
    ],
)
def test_invariant_m3_accessor_resolves_mode(
    mapping: dict[str, object], expected: str
) -> None:
    """The accessor returns a declared string mode, else the default 'closed'."""

    assert manifest_mode(mapping) == expected


@pytest.mark.parametrize("concurrency", [1, 2, 4, 8, 32])
def test_invariant_m4_accepts_in_range_concurrency(concurrency: int) -> None:
    """Concurrency values inside the 1..32 bound validate cleanly."""

    mapping = build_valid_manifest()
    mapping["max_concurrency"] = concurrency

    assert validate(mapping) == []


@pytest.mark.parametrize("concurrency", [0, -1, 33, 100, "4", 1.5, True, None])
def test_invariant_m4_rejects_out_of_bound_concurrency(concurrency: object) -> None:
    """Out-of-range, non-integer, and boolean concurrency values are rejected."""

    mapping = build_valid_manifest()
    mapping["max_concurrency"] = concurrency

    assert (
        f"Parallel manifest max_concurrency must be an integer from 1 through 32; "
        f"found: {concurrency!r}." in validate(mapping)
    )


@pytest.mark.parametrize(
    ("mapping", "expected"),
    [
        ({}, DEFAULT_MAX_CONCURRENCY),
        ({"max_concurrency": 7}, 7),
        ({"max_concurrency": 1}, 1),
        ({"max_concurrency": "4"}, DEFAULT_MAX_CONCURRENCY),
        ({"max_concurrency": True}, DEFAULT_MAX_CONCURRENCY),
        ({"max_concurrency": 1.5}, DEFAULT_MAX_CONCURRENCY),
    ],
)
def test_invariant_m4_accessor_resolves_concurrency(
    mapping: dict[str, object], expected: int
) -> None:
    """The accessor returns a declared integer cap, else the default four."""

    assert manifest_max_concurrency(mapping) == expected


@pytest.mark.parametrize("created_at", ["", "   ", 20260807, None, ABSENT])
def test_invariant_m5_rejects_a_blank_absent_or_non_string_created_at(
    created_at: object,
) -> None:
    """A blank, absent, or non-string creation timestamp is rejected."""

    mapping = build_valid_manifest()
    set_or_delete(mapping, "created_at", created_at)

    assert "Parallel manifest created_at must be a non-empty string." in validate(
        mapping
    )


def test_invariant_m6_accepts_an_empty_items_list() -> None:
    """A manifest authored before any item is admitted is valid."""

    mapping = build_valid_manifest()
    mapping["items"] = []

    assert validate(mapping) == []


@pytest.mark.parametrize("items", [{"444": {}}, "444", 4, None, ABSENT])
def test_invariant_m6_rejects_a_non_list_or_absent_items_value(items: object) -> None:
    """A non-list or absent items value yields one collection-level error."""

    mapping = build_valid_manifest()
    set_or_delete(mapping, "items", items)

    assert "Parallel manifest items must be a list." in validate(mapping)


def test_invariant_m6_rejects_a_non_object_item() -> None:
    """A scalar entry in items yields one entry-shape error."""

    mapping = build_valid_manifest()
    cast("list[object]", mapping["items"])[0] = "444"

    assert "Parallel manifest items[0] must be an object." in validate(mapping)


@pytest.mark.parametrize("issue_num", [0, -3, "444", None, True])
def test_invariant_m6_rejects_a_non_positive_issue_num(issue_num: object) -> None:
    """The primary key must be a positive, non-boolean integer."""

    mapping = build_valid_manifest()
    item_at(mapping, 0)["issue_num"] = issue_num

    assert (
        f"Parallel manifest items[0] issue_num must be a positive integer; "
        f"found: {issue_num!r}." in validate(mapping)
    )


def test_invariant_m6_rejects_duplicate_issue_numbers() -> None:
    """Two items sharing a primary key are rejected."""

    mapping = build_valid_manifest()
    item_at(mapping, 1)["issue_num"] = 444

    assert "Parallel manifest has duplicate items[].issue_num: 444." in validate(
        mapping
    )


def test_invariant_m6_rejects_a_blank_feature_folder() -> None:
    """An item with no resolvable folder hint is rejected."""

    mapping = build_valid_manifest()
    item_at(mapping, 0)["feature_folder"] = "  "

    assert "Parallel manifest items[0] feature_folder must be a non-empty string." in (
        validate(mapping)
    )


@pytest.mark.parametrize(("field", "value"), ITEM_ENUM_MEMBERS)
def test_invariant_m6_accepts_every_item_enum_member(field: str, value: str) -> None:
    """Each declared member of each per-item enum validates cleanly."""

    mapping = build_valid_manifest()
    set_item_field(mapping, field, value)

    assert validate(mapping) == []


@pytest.mark.parametrize(
    ("field", "value", "expected"),
    [
        (
            "kind",
            "chore",
            "Parallel manifest items[0] kind must be one of feature, bug; "
            "found: 'chore'.",
        ),
        (
            "state",
            "queued",
            "Parallel manifest items[0] state must be one of proposed, admitted, "
            "prepared, scheduled, in_flight, merged, withdrawn, blocked; "
            "found: 'queued'.",
        ),
        (
            "blast_radius.source",
            "guessed",
            "Parallel manifest items[0] blast_radius.source must be one of "
            "derived, declared, observed; found: 'guessed'.",
        ),
    ],
)
def test_invariant_m6_rejects_out_of_enum_item_values(
    field: str, value: str, expected: str
) -> None:
    """Each per-item enum rejects a non-member with its literal enum error."""

    mapping = build_valid_manifest()
    set_item_field(mapping, field, value)

    assert expected in validate(mapping)


def test_invariant_m6_rejects_a_non_object_blast_radius() -> None:
    """A non-object radius yields exactly one shape error for that item."""

    mapping = build_valid_manifest()
    item_at(mapping, 0)["blast_radius"] = ["scripts/**"]

    assert "Parallel manifest items[0] blast_radius must be an object." in validate(
        mapping
    )


@pytest.mark.parametrize("field", BLAST_RADIUS_LIST_FIELDS)
def test_invariant_m6_rejects_a_malformed_radius_collection(field: str) -> None:
    """Each radius collection must be a list of non-empty strings."""

    mapping = build_valid_manifest()
    radius_of(mapping, 0)[field] = ["", "scripts/**"]

    assert (
        f"Parallel manifest items[0] blast_radius.{field} must be a list of "
        f"non-empty strings." in validate(mapping)
    )


def test_invariant_m6_rejects_a_blank_radius_timestamp() -> None:
    """A radius with no computation timestamp is rejected."""

    mapping = build_valid_manifest()
    radius_of(mapping, 0)["computed_at"] = ""

    assert (
        "Parallel manifest items[0] blast_radius.computed_at must be a "
        "non-empty string." in validate(mapping)
    )


@pytest.mark.parametrize("key", ["depends_on", "integration_branch"])
def test_invariant_m7_rejects_top_level_prohibited_keys(key: str) -> None:
    """Run-level ordering and integration-branch keys are rejected at the root.

    There is no fan-in merge in a parallel run and no declared ordering, so
    neither key may appear as a run-level field.
    """

    mapping = build_valid_manifest()
    mapping[key] = "value"

    assert f"Parallel manifest carries prohibited key '{key}' at <root>." in validate(
        mapping
    )


def test_invariant_m7_rejects_item_level_depends_on() -> None:
    """A per-item dependency declaration is rejected with its path."""

    mapping = build_valid_manifest()
    item_at(mapping, 1)["depends_on"] = [444]

    assert "Parallel manifest carries prohibited key 'depends_on' at items[1]." in (
        validate(mapping)
    )


def test_invariant_m7_rejects_deeply_nested_depends_on() -> None:
    """A dependency key nested inside the radius block is still rejected."""

    mapping = build_valid_manifest()
    radius_of(mapping, 0)["depends_on"] = [445]

    assert (
        "Parallel manifest carries prohibited key 'depends_on' at "
        "items[0].blast_radius." in validate(mapping)
    )


def test_invariant_m7_permits_a_nested_integration_branch() -> None:
    """A nested integration_branch is legitimate child data, not a run field."""

    mapping = build_valid_manifest()
    item_at(mapping, 0)["integration_branch"] = "feature/child"

    assert validate(mapping) == []
