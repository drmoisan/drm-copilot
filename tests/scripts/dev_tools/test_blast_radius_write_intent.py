"""Unit, property, and fixture tests for write-intent extraction (issue #722).

Covers rules W1 through W6 of ``scripts/dev_tools/_blast_radius_write_intent.py``,
the strict readers of ``write_intent_extraction`` and ``path_roots``, the
token-level filter applied in normalization, the extractor selector shared by
derivation and validation, and the flag-absent identity with current
extraction. The eight committed fixtures under
``tests/fixtures/blast_radius/write-intent`` drive the end-to-end cases.

The write-intent names are imported from the write-intent module itself rather
than through the facade, so a missing module surfaces as a collection error
naming it. No temporary file is created and no external process is started.
"""

from __future__ import annotations

import copy
import itertools
import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._blast_radius_write_intent import (
    PLACEHOLDER_STEMS,
    READ_VERBS,
    WRITE_VERBS,
    config_path_roots,
    config_write_intent_extraction,
    extract_write_intent_contracts,
    extract_write_intent_plan_paths,
    is_read_task_title,
    select_plan_paths,
    select_write_intent_path_entries,
)
from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    SchedulingItem,
    decide_pair,
    derive_blast_radius,
    extract_plan_paths,
    normalize_declared_radius,
    schedule_conflict_edges,
    validate_blast_radius,
)

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

REPO_ROOT = Path(__file__).resolve().parents[3]
WRITE_INTENT_DIR = REPO_ROOT / "tests" / "fixtures" / "blast_radius" / "write-intent"
COMPUTED_AT = "2026-09-27T00-00"
TRACKED_FILE_COUNT = 1000
FOLDER_GLOB = "docs/features/active/demo-feature-1/**"

WRITE_INTENT_STEMS: tuple[str, ...] = (
    "write-intent-glob-mention",
    "write-intent-command-span",
    "write-intent-read-task",
    "write-intent-root-anchoring",
    "write-intent-spec-contracts-only",
    "write-intent-placeholder-stem",
    "write-intent-shared-surface-read-citation",
    "write-intent-flag-absent-matches-current",
)

# The B33 vocabularies. The Pester twin reads the Python module source and pins
# the PowerShell constants to it, so the two runtimes are compared directly.
EXPECTED_READ_VERBS = ("Read", "Verify", "Confirm", "Inspect", "Review", "Baseline")
EXPECTED_WRITE_VERBS = (
    "Fix Write Update Edit Add Create Delete Remove Rename Author Append Replace"
).split()
EXPECTED_PLACEHOLDER_STEMS = tuple("abcdefghijklmnopqrstuvwxyz") + tuple(
    "foo bar baz example sample placeholder".split()
)


def make_config(**overrides: object) -> dict[str, object]:
    """Build the B31 shared write-intent truth table with optional overrides."""
    config: dict[str, object] = {
        "version": 1,
        "shared_surfaces": ["poetry.lock", "config/blast-radius.json"],
        "shared_surface_globs": [],
        "mandate_reads": [".claude/rules/**", ".github/copilot-instructions.md"],
        "mergeable_paths": [],
        "write_intent_extraction": True,
        "path_roots": ["src", "config", "docs", "tests", ".claude"],
        "modules": {"config": ["config/**"]},
        "over_breadth_fraction": 0.25,
    }
    config.update(overrides)
    return config


def task(title: str, number: int = 1) -> str:
    """Render one canonical unchecked plan task line."""
    return f"- [ ] [P1-T{number}] {title}"


def derive(
    plan_text: str,
    config: Mapping[str, object],
    spec_text: str = "",
    folder: str = "demo-feature-1",
) -> BlastRadius:
    """Derive a radius for a demo feature folder."""
    return derive_blast_radius(
        plan_text, spec_text, folder, config, computed_at=COMPUTED_AT
    )


def load_fixture(stem: str) -> Mapping[str, object]:
    """Read one committed write-intent fixture."""
    text = (WRITE_INTENT_DIR / f"{stem}.json").read_text(encoding="utf-8")
    return cast("Mapping[str, object]", json.loads(text))


def records(value: object) -> list[Mapping[str, object]]:
    """Narrow a fixture array of objects for the type checker."""
    return cast("list[Mapping[str, object]]", value)


def case_config(
    fixture: Mapping[str, object], case: Mapping[str, object]
) -> dict[str, object]:
    """Apply a case's overrides and removals to the fixture config."""
    config = copy.deepcopy(dict(cast("Mapping[str, object]", fixture["config"])))
    config.update(cast("Mapping[str, object]", case["config_overrides"]))
    # Removal models a truth table that predates the key.
    for key in cast("list[str]", case["remove_keys"]):
        config.pop(key, None)
    return config


def test_w1_glob_mention_tokens_are_dropped() -> None:
    """W1: a token carrying * or ? contributes no path in write-intent mode."""
    plan = task("Update `src/app.py`, `src/**/*.py`, and `src/a?.py`.")

    result = extract_write_intent_plan_paths(plan, root_surfaces=(), path_roots=())

    assert "src/**/*.py" in extract_plan_paths(plan), "current extraction keeps it"
    assert result == ("src/app.py",)


def test_w1_feature_folder_glob_is_never_dropped() -> None:
    """The feature-folder glob survives derivation and the token-level filter."""
    radius = derive(task("Update `src/app.py`."), make_config(path_roots=["src"]))
    kept = select_write_intent_path_entries(
        [FOLDER_GLOB], root_surfaces=(), path_roots=("src",)
    )

    assert FOLDER_GLOB in radius.paths
    assert kept == (FOLDER_GLOB,)


def test_w2_multi_word_span_tokens_are_dropped() -> None:
    """W2: every token of a span that splits into more than one word is dropped."""
    plan = task("Update `src/app.py`, then run `git add src/other.py`.")

    result = extract_write_intent_plan_paths(plan, root_surfaces=(), path_roots=())

    assert "src/other.py" in extract_plan_paths(plan), "current extraction keeps it"
    assert result == ("src/app.py",)


def test_w3_read_task_tokens_are_dropped() -> None:
    """W3: a read task drops its window's tokens; a heading closes the window."""
    plan = "\n".join(
        (
            task("Read `src/policy.py` in full."),
            "      Also cite `src/policy_detail.py`.",
            "### Phase 2 — Next",
            "Prose citing `src/after_heading.py`.",
            task("**Baseline:** Read `src/base.py`.", 2),
        )
    )

    result = extract_write_intent_plan_paths(plan, root_surfaces=(), path_roots=())

    assert result == ("src/after_heading.py",)
    # Every read verb qualifies, case-insensitively.
    for verb in READ_VERBS:
        assert is_read_task_title(f"{verb.lower()} `x/y.md`."), verb


def test_w3_write_verb_overrides_read_verb() -> None:
    """W3: a read-verb title that also carries a write verb is not a read task."""
    plan = task("Verify and fix `src/fixme.py`.")

    result = extract_write_intent_plan_paths(plan, root_surfaces=(), path_roots=())

    assert result == ("src/fixme.py",)
    assert not is_read_task_title("Review and UPDATE the file.")
    assert is_read_task_title("Review the fixme notes.")


def test_w4_tokens_outside_path_roots_are_dropped() -> None:
    """W4: a first segment outside path_roots drops a non-root-surface token."""
    plan = task(
        "Update `src/app.py`, `./src/beta.py`, `research/notes.md`, and `poetry.lock`."
    )

    result = extract_write_intent_plan_paths(
        plan, root_surfaces=("poetry.lock",), path_roots=("src",)
    )

    assert result == ("./src/beta.py", "poetry.lock", "src/app.py")


def test_w4_disabled_when_path_roots_empty() -> None:
    """W4: an empty or absent path_roots keeps every classified token."""
    plan = task("Update `src/app.py` and `research/notes.md`.")
    config = make_config()
    del config["path_roots"]

    result = extract_write_intent_plan_paths(plan, root_surfaces=(), path_roots=())
    radius = derive(plan, config)

    assert result == ("research/notes.md", "src/app.py")
    assert "research/notes.md" in radius.paths


def test_w5_spec_contributes_contracts_only() -> None:
    """W5: the spec adds no path, and W1 and W2 filter its contract tokens."""
    spec = "## Public API\n\n- `computeWidget`\n- `src/spec_only.py`\n"
    spec += "- `*.ts`\n- `git add widget`\n"

    radius = derive(task("Update `src/app.py`."), make_config(), spec)

    assert radius.paths == (FOLDER_GLOB, "src/app.py")
    assert radius.contracts == ("computeWidget",)
    assert extract_write_intent_contracts(spec) == ("computeWidget",)


def test_w6_placeholder_stem_tokens_are_dropped() -> None:
    """W6: a final-component stem in the placeholder set drops the token."""
    plan = task(
        "Update `src/app.py`, `src/X.ts`, `tests/foo.py`, `tests/Example.md`, "
        "and `src/foo_bar.py`."
    )

    result = extract_write_intent_plan_paths(plan, root_surfaces=(), path_roots=())

    assert result == ("src/app.py", "src/foo_bar.py")


def test_shared_surface_read_citation_is_not_hard() -> None:
    """A read citation of a shared surface is not hard; a written one is."""
    config = make_config()
    reader = derive(
        "\n".join(
            (
                task("Read `config/blast-radius.json` in full."),
                task("Update `src/alpha.py`.", 2),
            )
        ),
        config,
        folder="demo-reader",
    )
    writer = derive(
        task("Update `config/blast-radius.json` to add a key."),
        config,
        folder="demo-writer",
    )
    second = derive(
        task("Update `config/blast-radius.json` again."), config, folder="demo-second"
    )

    assert reader.shared_surfaces == ()
    assert "src/alpha.py" in reader.paths
    assert not decide_pair(reader, writer, config).conflict
    assert decide_pair(writer, second, config).hard


def test_flag_absent_matches_current_behavior() -> None:
    """Without the key, derivation, normalization, and validation are current."""
    plan = task("Update `src/app.py`; run `git add src/other.py`; see `src/**/*.py`.")
    config = make_config()
    del config["write_intent_extraction"]
    baseline = make_config()
    del baseline["write_intent_extraction"]
    del baseline["path_roots"]

    radius = derive(plan, config)
    recorded = BlastRadius(
        ("src/**/*.py", "src/x.ts"), (), (), (), "declared", COMPUTED_AT
    )

    assert radius == derive(plan, baseline)
    assert {"src/**/*.py", "src/other.py"} <= set(radius.paths)
    assert normalize_declared_radius(recorded, config) == recorded
    assert (
        validate_blast_radius(
            radius, plan, config, tracked_file_count=TRACKED_FILE_COUNT
        )
        == []
    )


def test_flag_false_matches_current_behavior() -> None:
    """With the key false, derivation and normalization are current."""
    plan = task("Update `src/app.py`; run `git add src/other.py`; see `src/**/*.py`.")
    config = make_config(write_intent_extraction=False)
    baseline = make_config()
    del baseline["write_intent_extraction"]
    del baseline["path_roots"]

    radius = derive(plan, config)
    recorded = BlastRadius(
        ("research/x.md", "src/x.ts"), (), (), (), "declared", COMPUTED_AT
    )

    assert radius == derive(plan, baseline)
    assert normalize_declared_radius(recorded, config) == recorded
    assert select_plan_paths(plan, config, root_surfaces=()) == extract_plan_paths(plan)


def test_derived_radius_passes_v1_v2_in_write_intent_mode() -> None:
    """Every fixture item's derived radius passes V1 and V2 against its own plan."""
    checked = 0
    # Walk every item of every fixture under its first case's config.
    for stem in WRITE_INTENT_STEMS:
        fixture = load_fixture(stem)
        config = case_config(fixture, records(fixture["cases"])[0])
        for item in records(fixture["items"]):
            plan = cast("str", item["plan_text"])
            radius = derive_blast_radius(
                plan,
                cast("str", item["spec_text"]),
                cast("str", item["feature_folder"]),
                config,
                computed_at=COMPUTED_AT,
            )
            findings = validate_blast_radius(
                radius, plan, config, tracked_file_count=TRACKED_FILE_COUNT
            )
            assert [f for f in findings if f.rule in ("V1", "V2")] == [], stem
            checked += 1

    assert checked == 11, "every fixture item must be validated"


def test_write_intent_vocabularies_match_powershell() -> None:
    """The three vocabularies equal the B33 lists that the Pester twin pins."""
    assert READ_VERBS == EXPECTED_READ_VERBS
    assert WRITE_VERBS == tuple(EXPECTED_WRITE_VERBS)
    assert PLACEHOLDER_STEMS == EXPECTED_PLACEHOLDER_STEMS


def test_property_write_intent_rules_never_add_a_token() -> None:
    """Exhaustively: write-intent output is a subset of current output (decision 11)."""
    titles = ("Update", "Read", "Verify and fix", "**Baseline:** Read", "Inspect")
    pool = (
        "`src/app.py`",
        "`src/**/*.py`",
        "`git add src/other.py`",
        "`research/notes.md`",
        "`tests/foo.py`",
        "`./src/b.py`",
        "`poetry.lock`",
        "`src/x.ts`",
    )
    strictly_smaller = 0
    equal_nonempty = 0
    # Every title, span pair, and path_roots setting is one enumerated input.
    for title, pair, roots in itertools.product(
        titles, itertools.combinations(pool, 2), ((), ("src", "tests"))
    ):
        plan = task(f"{title} {pair[0]} and {pair[1]}.")
        current = set(extract_plan_paths(plan, root_surfaces=("poetry.lock",)))
        narrowed = set(
            extract_write_intent_plan_paths(
                plan, root_surfaces=("poetry.lock",), path_roots=roots
            )
        )
        filtered = set(
            select_write_intent_path_entries(
                sorted(current), root_surfaces=("poetry.lock",), path_roots=roots
            )
        )
        assert narrowed <= current, plan
        assert filtered <= current, plan
        strictly_smaller += narrowed < current
        equal_nonempty += bool(narrowed) and narrowed == current

    assert strictly_smaller > 0 and equal_nonempty > 0, "domain must not be vacuous"


@pytest.mark.parametrize("stem", WRITE_INTENT_STEMS)
def test_write_intent_fixture_reproduces_expected_radius(stem: str) -> None:
    """Each fixture case reproduces its radii, edges, normalization, and findings."""
    fixture = load_fixture(stem)
    items = {cast("int", item["key"]): item for item in records(fixture["items"])}

    # Each case is evaluated under its own config.
    for case in records(fixture["cases"]):
        config = case_config(fixture, case)
        derived: dict[int, BlastRadius] = {}
        # Derive every item, then compare the four levels with the pinned radius.
        for expected in records(case["expected_radii"]):
            key = cast("int", expected["key"])
            item = items[key]
            plan = cast("str", item["plan_text"])
            radius = derive_blast_radius(
                plan,
                cast("str", item["spec_text"]),
                cast("str", item["feature_folder"]),
                config,
                computed_at=COMPUTED_AT,
            )
            derived[key] = radius
            actual = {
                level: list(cast("Sequence[str]", getattr(radius, level)))
                for level in ("paths", "modules", "shared_surfaces", "contracts")
            }
            assert actual == {
                level: expected[level] for level in actual
            }, f"{stem}/{case['name']}/{key}"
            if "expected_findings" in case:
                findings = validate_blast_radius(
                    radius, plan, config, tracked_file_count=TRACKED_FILE_COUNT
                )
                assert [f.subject for f in findings] == case["expected_findings"]

        if "expected_edges" in case:
            result = schedule_conflict_edges(
                [
                    SchedulingItem(key=key, radius=radius)
                    for key, radius in sorted(derived.items())
                ],
                config,
            )
            edges = [
                {
                    "a": e.a,
                    "b": e.b,
                    "reason": e.reason,
                    "hard": e.hard,
                    "cost": e.cost,
                    "benefit": e.benefit,
                }
                for e in result.edges
            ]
            assert edges == case["expected_edges"]
            assert [(t.a, t.b) for t in result.tolerated_overlaps] == case[
                "expected_tolerated"
            ]

        if "normalization" in case:
            spec = cast("Mapping[str, object]", case["normalization"])
            recorded = BlastRadius(
                cast("list[str]", spec["paths"]), (), (), (), "declared", COMPUTED_AT
            )
            assert (
                list(normalize_declared_radius(recorded, config).paths)
                == spec["expected_paths"]
            )


@pytest.mark.parametrize(
    ("key", "value"),
    [
        pytest.param("write_intent_extraction", "true", id="flag-string"),
        pytest.param("write_intent_extraction", 1, id="flag-int"),
        pytest.param("path_roots", "src", id="path-roots-string"),
        pytest.param("path_roots", ["src", 3], id="path-roots-non-string-entry"),
    ],
)
def test_write_intent_reader_rejects_invalid_shape(key: str, value: object) -> None:
    """Both readers fail fast with an error naming the offending key."""
    config = make_config(**{key: value})
    readers = {
        "write_intent_extraction": config_write_intent_extraction,
        "path_roots": config_path_roots,
    }

    with pytest.raises((TypeError, ValueError), match=key):
        readers[key](config)


def test_normalization_keeps_feature_folder_glob_in_write_intent_mode() -> None:
    """Normalization applies W1, W4, and W6 but keeps the feature-folder glob."""
    recorded = BlastRadius(
        (FOLDER_GLOB, "src/**/*.py", "research/x.md", "src/x.ts", "src/app.py"),
        (),
        (),
        (),
        "declared",
        COMPUTED_AT,
    )

    normalized = normalize_declared_radius(recorded, make_config(path_roots=["src"]))

    assert normalized.paths == (FOLDER_GLOB, "src/app.py")
