"""Cross-language parity assertions over the committed blast-radius corpus.

Parametrize over every ``tests/fixtures/blast_radius/*.json`` file and assert
that the Python reference implementation reproduces each fixture's ``expected``
block exactly: the derived radius dict, the sorted findings list, and the
contention result. The same corpus is asserted by
``tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1``, so the
fixtures are the single artifact that pins the two implementations together;
neither suite may relax an expectation without the other observing the change.

Fixture shape. A derivation or validation fixture carries ``input`` with
``plan_text``, ``spec_text``, ``feature_folder``, ``config``,
``tracked_file_count`` and ``computed_at``, plus the optional ``source`` (the
confidence source passed to derivation, defaulting to ``derived``) and the
optional ``radius`` (a hand-authored declared radius to validate instead of the
derived one, which is how a V1 or V2 failure can be expressed at all, since a
derived radius always passes V1 and V2 against its own plan). A conflict fixture
carries ``input`` with ``radius_a``, ``radius_b`` and ``config``. The two kinds
are told apart by the presence of ``radius_a``.

The corpus files are committed and read-only here. No temporary file is created,
no external process is started, and no PowerShell is invoked: parity is asserted
against a shared artifact rather than by cross-process execution.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    conflicts,
    derive_blast_radius,
    validate_blast_radius,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

    from scripts.dev_tools.compute_blast_radius import ConflictReason, RadiusFinding

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_blast_radius_parity.py, so the repository root is
# three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_DIR = REPO_ROOT / "tests" / "fixtures" / "blast_radius"
FIXTURE_SUFFIX = ".json"

# Floor on corpus size. An empty or partially matched glob would make every
# parametrized case below disappear and the suite would pass vacuously, so the
# count is asserted twice: against this floor and against the files on disk.
MINIMUM_FIXTURE_COUNT = 12

# Presence of this input key marks a contention fixture; its absence marks a
# derivation or validation fixture.
CONFLICT_MARKER_KEY = "radius_a"

# Confidence source derivation records when a fixture does not name one.
DEFAULT_SOURCE = "derived"


def require_mapping(value: object, label: str) -> Mapping[str, object]:
    """Guard a fixture value that must be a JSON object.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        Mapping[str, object]: The validated mapping.

    Raises:
        TypeError: If the value is not a JSON object.
    """
    if not isinstance(value, dict):
        raise TypeError(f"{label} must be a JSON object, got {type(value).__name__}.")
    return cast("Mapping[str, object]", value)


def require_text(value: object, label: str, *, allow_empty: bool = False) -> str:
    """Guard a fixture value that must be a JSON string.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.
        allow_empty (bool): When ``True`` an empty string is accepted, which the
            plan and spec text fields need.

    Returns:
        str: The validated string.

    Raises:
        TypeError: If the value is not a string.
        ValueError: If the value is blank and ``allow_empty`` is ``False``.
    """
    if not isinstance(value, str):
        raise TypeError(f"{label} must be a string, got {type(value).__name__}.")
    if not allow_empty and not value.strip():
        raise ValueError(f"{label} must not be empty.")
    return value


def require_int(value: object, label: str) -> int:
    """Guard a fixture value that must be a JSON integer.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        int: The validated integer.

    Raises:
        TypeError: If the value is not an integer. Booleans are rejected because
            Python treats them as integers and the library rejects them too.
    """
    if isinstance(value, bool) or not isinstance(value, int):
        raise TypeError(f"{label} must be an integer, got {type(value).__name__}.")
    return value


def require_records(value: object, label: str) -> list[Mapping[str, object]]:
    """Guard a fixture value that must be a JSON array of objects.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        list[Mapping[str, object]]: The validated records in fixture order.

    Raises:
        TypeError: If the value is not a list, or holds a non-object entry.
    """
    if not isinstance(value, list):
        raise TypeError(f"{label} must be a JSON array, got {type(value).__name__}.")

    # Validate every entry as it is read so a malformed corpus fails at load time
    # naming the offending record rather than inside an assertion body.
    records: list[Mapping[str, object]] = []
    for index, entry in enumerate(cast("list[object]", value)):
        records.append(require_mapping(entry, f"{label}[{index}]"))

    return records


def load_fixture(path: Path) -> Mapping[str, object]:
    """Read and parse one committed corpus file.

    Args:
        path (Path): Absolute path to a corpus JSON file.

    Returns:
        Mapping[str, object]: The parsed top-level fixture object.

    Raises:
        TypeError: If the file does not parse to a JSON object.

    Side Effects:
        Reads the committed fixture file. The corpus is read-only for this suite.
    """
    parsed = cast("object", json.loads(path.read_text(encoding="utf-8")))
    return require_mapping(parsed, path.name)


FIXTURE_PATHS: tuple[Path, ...] = tuple(sorted(FIXTURE_DIR.glob(f"*{FIXTURE_SUFFIX}")))
FIXTURES: tuple[tuple[str, Mapping[str, object]], ...] = tuple(
    (path.stem, load_fixture(path)) for path in FIXTURE_PATHS
)


def fixture_input(name: str, fixture: Mapping[str, object]) -> Mapping[str, object]:
    """Read the ``input`` block of a fixture.

    Args:
        name (str): Fixture stem, used in failure messages.
        fixture (Mapping[str, object]): Parsed fixture object.

    Returns:
        Mapping[str, object]: The input block.

    Raises:
        TypeError: If the block is absent or is not a JSON object.
    """
    return require_mapping(fixture.get("input"), f"{name}.input")


def fixture_expected(name: str, fixture: Mapping[str, object]) -> Mapping[str, object]:
    """Read the ``expected`` block of a fixture.

    Args:
        name (str): Fixture stem, used in failure messages.
        fixture (Mapping[str, object]): Parsed fixture object.

    Returns:
        Mapping[str, object]: The expected block.

    Raises:
        TypeError: If the block is absent or is not a JSON object.
    """
    return require_mapping(fixture.get("expected"), f"{name}.expected")


def is_conflict_fixture(name: str, fixture: Mapping[str, object]) -> bool:
    """Report whether a fixture describes a contention case.

    Args:
        name (str): Fixture stem, used in failure messages.
        fixture (Mapping[str, object]): Parsed fixture object.

    Returns:
        bool: ``True`` when the input names a first radius to compare.
    """
    return CONFLICT_MARKER_KEY in fixture_input(name, fixture)


DERIVATION_CASES: tuple[tuple[str, Mapping[str, object]], ...] = tuple(
    case for case in FIXTURES if not is_conflict_fixture(*case)
)
CONFLICT_CASES: tuple[tuple[str, Mapping[str, object]], ...] = tuple(
    case for case in FIXTURES if is_conflict_fixture(*case)
)
DERIVATION_IDS: list[str] = [name for name, _ in DERIVATION_CASES]
CONFLICT_IDS: list[str] = [name for name, _ in CONFLICT_CASES]


def derive_fixture_radius(name: str, data: Mapping[str, object]) -> BlastRadius:
    """Derive the radius a derivation or validation fixture describes.

    Args:
        name (str): Fixture stem, used in failure messages.
        data (Mapping[str, object]): The fixture's input block.

    Returns:
        BlastRadius: The derived radius, recording the fixture's ``source`` when
        it names one and ``derived`` otherwise.

    Raises:
        TypeError: If an input field has a wrong type.
        ValueError: If a required input field is blank.
    """
    source = DEFAULT_SOURCE
    if "source" in data:
        source = require_text(data["source"], f"{name}.input.source")

    return derive_blast_radius(
        require_text(
            data.get("plan_text"), f"{name}.input.plan_text", allow_empty=True
        ),
        require_text(
            data.get("spec_text"), f"{name}.input.spec_text", allow_empty=True
        ),
        require_text(data.get("feature_folder"), f"{name}.input.feature_folder"),
        require_mapping(data.get("config"), f"{name}.input.config"),
        source=source,
        computed_at=require_text(data.get("computed_at"), f"{name}.input.computed_at"),
    )


def radius_under_validation(name: str, data: Mapping[str, object]) -> BlastRadius:
    """Select the radius a validation fixture applies rules V1 to V3 against.

    A fixture that names an explicit ``radius`` is exercising a hand-authored or
    stale declared radius, which is the only way a V1 or V2 failure can arise: a
    radius produced by derivation always passes both rules against its own plan.
    Every other fixture validates the derived radius.

    Args:
        name (str): Fixture stem, used in failure messages.
        data (Mapping[str, object]): The fixture's input block.

    Returns:
        BlastRadius: The radius to validate.

    Raises:
        TypeError: If the declared radius has a wrong shape.
        ValueError: If the declared radius carries an invalid value.
    """
    if "radius" in data:
        return BlastRadius.from_dict(
            require_mapping(data["radius"], f"{name}.input.radius")
        )
    return derive_fixture_radius(name, data)


def finding_to_dict(finding: RadiusFinding) -> dict[str, str]:
    """Render a finding in the fixture's serialized shape.

    Args:
        finding (RadiusFinding): Finding emitted by validation.

    Returns:
        dict[str, str]: The four contract-literal fields of the finding.
    """
    return {
        "rule": finding.rule,
        "severity": finding.severity,
        "subject": finding.subject,
        "message": finding.message,
    }


def reason_to_dict(reason: ConflictReason) -> dict[str, str]:
    """Render a contention reason in the fixture's serialized shape.

    Args:
        reason (ConflictReason): Reason emitted by the contention relation.

    Returns:
        dict[str, str]: The kind and detail of the reason.
    """
    return {"kind": reason.kind, "detail": reason.detail}


def test_corpus_meets_the_documented_minimum_size() -> None:
    """Guard every parametrized case below against an empty corpus glob."""
    # Arrange: the corpus is discovered at import.
    # Act: measure the discovered set.
    discovered = len(FIXTURE_PATHS)

    # Assert: a short corpus would silently drop scenarios the parity claim
    # depends on, and an empty one would make the whole suite pass vacuously.
    assert discovered >= MINIMUM_FIXTURE_COUNT, (
        f"Expected at least {MINIMUM_FIXTURE_COUNT} fixtures under "
        f"{FIXTURE_DIR}, discovered {discovered}."
    )


def test_discovered_fixture_count_equals_the_json_file_count() -> None:
    """Require the discovery glob to reach every JSON file in the corpus."""
    # Arrange: enumerate the directory without the glob, so a pattern that
    # silently skipped files would be caught rather than reproduced.
    on_disk = tuple(
        entry
        for entry in FIXTURE_DIR.iterdir()
        if entry.is_file() and entry.suffix == FIXTURE_SUFFIX
    )

    # Act / Assert: the two counts must agree, otherwise the PowerShell suite
    # and this one could be iterating different subsets of the same directory.
    assert len(FIXTURE_PATHS) == len(on_disk), (
        f"Discovered {len(FIXTURE_PATHS)} fixtures but {len(on_disk)} "
        f"{FIXTURE_SUFFIX} files exist under {FIXTURE_DIR}."
    )


def test_corpus_covers_both_fixture_kinds() -> None:
    """Require the corpus to exercise derivation and contention alike."""
    # Arrange / Act: the two case lists are partitioned at import.
    # Assert: an all-derivation or all-conflict corpus would leave one of the
    # two parametrized suites with zero cases.
    assert DERIVATION_CASES, "The corpus declares no derivation fixture."
    assert CONFLICT_CASES, "The corpus declares no conflict fixture."


@pytest.mark.parametrize(("name", "fixture"), DERIVATION_CASES, ids=DERIVATION_IDS)
def test_derivation_fixture_reproduces_the_expected_radius(
    name: str, fixture: Mapping[str, object]
) -> None:
    """Assert derivation reproduces the fixture's expected radius exactly."""
    # Arrange: the fixture's input and its spec-derived expectation.
    data = fixture_input(name, fixture)
    expected = require_mapping(
        fixture_expected(name, fixture).get("radius"), f"{name}.expected.radius"
    )

    # Act: derive the radius from the plan, spec, feature folder, and config.
    radius = derive_fixture_radius(name, data)

    # Assert: the serialized dict matches key for key and element for element,
    # which is the same comparison the PowerShell suite performs.
    assert radius.to_dict() == dict(
        expected
    ), f"Fixture {name} derived a radius that differs from its expected block."


@pytest.mark.parametrize(("name", "fixture"), DERIVATION_CASES, ids=DERIVATION_IDS)
def test_derivation_fixture_reproduces_the_expected_findings(
    name: str, fixture: Mapping[str, object]
) -> None:
    """Assert validation reproduces the fixture's expected findings exactly."""
    # Arrange: the radius under validation, its plan, truth table, and count.
    data = fixture_input(name, fixture)
    expected = require_records(
        fixture_expected(name, fixture).get("findings"), f"{name}.expected.findings"
    )
    radius = radius_under_validation(name, data)

    # Act: apply rules V1, V2, and V3.
    findings = validate_blast_radius(
        radius,
        require_text(
            data.get("plan_text"), f"{name}.input.plan_text", allow_empty=True
        ),
        require_mapping(data.get("config"), f"{name}.input.config"),
        tracked_file_count=require_int(
            data.get("tracked_file_count"), f"{name}.input.tracked_file_count"
        ),
    )

    # Assert: the findings match in content and in the documented sort order by
    # rule then subject, since a list comparison is order sensitive.
    assert [finding_to_dict(finding) for finding in findings] == [
        dict(record) for record in expected
    ], f"Fixture {name} produced findings that differ from its expected block."


@pytest.mark.parametrize(("name", "fixture"), CONFLICT_CASES, ids=CONFLICT_IDS)
def test_conflict_fixture_reproduces_the_expected_verdict(
    name: str, fixture: Mapping[str, object]
) -> None:
    """Assert the contention relation reproduces the fixture's verdict."""
    # Arrange: the two radii and the truth table.
    data = fixture_input(name, fixture)
    expected = fixture_expected(name, fixture)
    left = BlastRadius.from_dict(
        require_mapping(data.get("radius_a"), f"{name}.input.radius_a")
    )
    right = BlastRadius.from_dict(
        require_mapping(data.get("radius_b"), f"{name}.input.radius_b")
    )

    # Act: evaluate the four disjuncts.
    result = conflicts(
        left, right, require_mapping(data.get("config"), f"{name}.input.config")
    )

    # Assert: the boolean verdict matches the fixture.
    assert result.conflict is expected.get("conflict"), (
        f"Fixture {name} produced verdict {result.conflict}, expected "
        f"{expected.get('conflict')!r}."
    )


@pytest.mark.parametrize(("name", "fixture"), CONFLICT_CASES, ids=CONFLICT_IDS)
def test_conflict_fixture_reproduces_the_expected_reasons(
    name: str, fixture: Mapping[str, object]
) -> None:
    """Assert every triggered reason appears in the documented kind order."""
    # Arrange: the two radii, the truth table, and the ordered expectation.
    data = fixture_input(name, fixture)
    expected = require_records(
        fixture_expected(name, fixture).get("reasons"), f"{name}.expected.reasons"
    )
    left = BlastRadius.from_dict(
        require_mapping(data.get("radius_a"), f"{name}.input.radius_a")
    )
    right = BlastRadius.from_dict(
        require_mapping(data.get("radius_b"), f"{name}.input.radius_b")
    )

    # Act: evaluate the four disjuncts.
    result = conflicts(
        left, right, require_mapping(data.get("config"), f"{name}.input.config")
    )

    # Assert: the reason list matches element for element, so both the reported
    # details and the fixed kind order are pinned by the corpus.
    assert [reason_to_dict(reason) for reason in result.reasons] == [
        dict(record) for record in expected
    ], f"Fixture {name} produced reasons that differ from its expected block."
