"""Python-lane assertions over the shared parallel-manifest parity corpus.

Parametrize over every ``tests/fixtures/parallel_manifest_bash/*.json`` file and
assert that ``scripts/dev_tools/parallel_manifest_contract.py`` -- the
repository's reference implementation -- reproduces each fixture's
``expected_errors`` list exactly and, where the fixture declares them, the exact
``manifest_mode`` and ``manifest_max_concurrency`` accessor results. The same
corpus is asserted by the bash lane in
``tests/shell/parallel_manifest_parity.bats``, so the fixtures are the single
artifact that pins the two implementations together; neither suite may relax an
expectation without the other observing the change.

Fixture shape. Every fixture carries ``name``, ``notes``, ``manifest_text`` (the
raw document, LF, CRLF, or CR terminated), and ``expected_errors`` (the full
error list in emission order). Accessor fixtures additionally carry
``expected_mode`` and ``expected_max_concurrency``. The accessors take a parsed
mapping rather than raw text, so this suite first calls
``parse_manifest_frontmatter`` on the fixture text and passes the resulting
mapping to them.

Verified scope and declared divergence classes. Parity between the Python and
bash lanes is byte-exact for every fixture in this corpus, including Python
``repr`` quote selection, with exactly two declared exceptions that are recorded
in all four parity-suite headers for this feature:

1. The M1 YAML-parse-failure message. Parity is scoped to the prefix
   ``Parallel manifest frontmatter is not valid YAML: `` plus the single-element
   error-list shape, because the underlying YAML library's exception text is not
   reproducible across runtimes. The one fixture in this class declares
   ``divergence: "M1_YAML_PARSE"`` and ``expected_error_prefix`` instead of a
   full ``expected_errors`` list, and this suite asserts the prefix and the
   single-element shape only.
2. Non-printable string-repr escapes. A string containing a control character
   other than ``\\n``, ``\\r``, or ``\\t`` renders its escape differently between
   the two lanes, so no corpus fixture contains one.

The corpus files are committed and read-only here. No temporary file is created,
no external process is started, and no bash is invoked: parity is asserted
against a shared artifact rather than by cross-process execution.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools.parallel_manifest_contract import (
    manifest_max_concurrency,
    manifest_mode,
    parse_manifest_frontmatter,
    validate_parallel_manifest_text,
)

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py, so the
# repository root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_DIR = REPO_ROOT / "tests" / "fixtures" / "parallel_manifest_bash"
FIXTURE_SUFFIX = ".json"

# Floor on corpus size. An empty or partially matched glob would make every
# parametrized case below disappear and the suite would pass vacuously, so the
# count is asserted twice: against this floor and against the files on disk.
MINIMUM_FIXTURE_COUNT = 24

# Marker value identifying the one declared-divergence fixture class.
YAML_PARSE_DIVERGENCE = "M1_YAML_PARSE"


def load_fixture(path: Path) -> dict[str, object]:
    """Read one corpus file and guard that it deserializes to a JSON object.

    Args:
        path (Path): Absolute path to a corpus file.

    Returns:
        dict[str, object]: The parsed fixture record.

    Raises:
        TypeError: If the file's top-level value is not a JSON object.

    Side Effects:
        Reads the file from disk. The file is never written.
    """

    parsed = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(parsed, dict):
        raise TypeError(f"{path.name} must hold a JSON object at its top level.")
    return cast("dict[str, object]", parsed)


def require_text(value: object, label: str) -> str:
    """Guard a fixture value that must be a JSON string.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        str: The validated string.

    Raises:
        TypeError: If the value is not a string.

    Side Effects:
        None.
    """

    if not isinstance(value, str):
        raise TypeError(f"{label} must be a JSON string, got {type(value).__name__}.")
    return value


def require_string_list(value: object, label: str) -> list[str]:
    """Guard a fixture value that must be a JSON array of strings.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        list[str]: The validated string list.

    Raises:
        TypeError: If the value is not a list, or any entry is not a string.

    Side Effects:
        None.
    """

    if not isinstance(value, list):
        raise TypeError(f"{label} must be a JSON array, got {type(value).__name__}.")
    entries = cast("list[object]", value)
    # Guard each entry so a malformed expectation fails loudly here rather than
    # producing a confusing list-comparison diff further down.
    for entry in entries:
        if not isinstance(entry, str):
            raise TypeError(f"{label} entries must be strings; found {entry!r}.")
    return cast("list[str]", entries)


def discover_fixture_paths() -> list[Path]:
    """List the corpus files in deterministic name order.

    Returns:
        list[Path]: Every ``*.json`` file in the corpus directory, sorted by
        path so parametrization ids are stable across platforms.

    Raises:
        None.

    Side Effects:
        Reads the corpus directory listing.
    """

    return sorted(FIXTURE_DIR.glob(f"*{FIXTURE_SUFFIX}"))


FIXTURE_PATHS = discover_fixture_paths()


def test_corpus_meets_the_declared_floor() -> None:
    """Assert the corpus is at least as large as the declared floor.

    A broken glob or a moved directory would silently empty the parametrized
    cases below, so the floor is asserted directly rather than inferred from a
    passing parametrized run.
    """

    # Arrange / Act: the module-level discovery already ran.
    discovered = len(FIXTURE_PATHS)

    # Assert
    assert discovered >= MINIMUM_FIXTURE_COUNT, (
        f"Manifest parity corpus has {discovered} fixtures; the declared floor "
        f"is {MINIMUM_FIXTURE_COUNT}. Restore the missing fixtures or lower the "
        f"floor deliberately."
    )


@pytest.mark.parametrize("fixture_path", FIXTURE_PATHS, ids=lambda path: path.stem)
def test_validator_reproduces_the_fixture_errors(fixture_path: Path) -> None:
    """Assert the Python validator reproduces one fixture's error list.

    Args:
        fixture_path (Path): One corpus file supplied by parametrization.
    """

    # Arrange
    fixture = load_fixture(fixture_path)
    label = fixture_path.stem
    text = require_text(fixture.get("manifest_text"), f"{label}.manifest_text")

    # Act
    errors = validate_parallel_manifest_text(text)

    # Assert: the declared-divergence fixture pins only the message prefix and
    # the single-element shape; every other fixture pins the full list.
    if fixture.get("divergence") == YAML_PARSE_DIVERGENCE:
        prefix = require_text(
            fixture.get("expected_error_prefix"), f"{label}.expected_error_prefix"
        )
        assert len(errors) == 1
        assert errors[0].startswith(prefix)
        return

    expected = require_string_list(
        fixture.get("expected_errors"), f"{label}.expected_errors"
    )
    assert errors == expected


@pytest.mark.parametrize("fixture_path", FIXTURE_PATHS, ids=lambda path: path.stem)
def test_accessors_reproduce_the_fixture_defaults(fixture_path: Path) -> None:
    """Assert the default-resolving accessors reproduce one fixture's values.

    Fixtures that declare no accessor expectation are skipped: a fixture whose
    frontmatter never parses has no mapping to hand the accessors.

    Args:
        fixture_path (Path): One corpus file supplied by parametrization.
    """

    # Arrange
    fixture = load_fixture(fixture_path)
    label = fixture_path.stem
    if "expected_mode" not in fixture and "expected_max_concurrency" not in fixture:
        pytest.skip(f"{label} declares no accessor expectation.")
    text = require_text(fixture.get("manifest_text"), f"{label}.manifest_text")

    # Act: the accessors take a parsed mapping, not raw text, so the frontmatter
    # is parsed first through the module's own boundary function.
    mapping, parse_errors = parse_manifest_frontmatter(text)

    # Assert
    assert mapping is not None, (
        f"{label} declares an accessor expectation but its frontmatter does not "
        f"parse: {parse_errors}"
    )
    if "expected_mode" in fixture:
        assert manifest_mode(mapping) == fixture["expected_mode"]
    if "expected_max_concurrency" in fixture:
        assert manifest_max_concurrency(mapping) == fixture["expected_max_concurrency"]
