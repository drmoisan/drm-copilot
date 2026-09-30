"""Python reference lane of the parallel drift parity corpus (issue #763).

Why this test exists:
    ``.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`` is the bundled
    destination-runtime port of ``scripts/dev_tools/parallel_drift_detection_cli.py``.
    The committed corpus ``tests/fixtures/parallel_drift/*.json`` pins the two
    implementations together: this lane asserts that the Python reference
    reproduces every fixture's expected payload or expected error, and
    ``tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1``
    asserts the same expectations against the PowerShell port.

How it runs the reference:
    A fixture carrying ``expected`` is evaluated twice: through the pure
    ``evaluate_drift`` function, and through ``parallel_drift_detection_cli.main``
    with ``scripts.dev_tools._parallel_drift_cli_io.read_json_file`` monkeypatched
    to return the fixture's inline ``state`` or ``config`` by path name, so the
    command line's argument handling and JSON serialization are covered too. A
    fixture carrying ``expected_error`` is run through ``main`` only and must exit
    1 with the documented stderr prefix.

Declared divergence classes (spec "Backward-compatibility expectations"):
    - JSON byte formatting: the lanes compare parsed JSON values, not bytes, so
      ``ensure_ascii`` and indentation differences are out of scope.
    - Error-message text after the ``parallel drift detection failed: `` prefix:
      the Python reference embeds ``repr()`` text, so only the prefix is compared.

Determinism:
    No file is read other than the committed corpus, no clock is read (every
    fixture supplies both timestamps), and no temporary file is created.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools import parallel_drift_detection_cli as drift_cli
from scripts.dev_tools.parallel_drift_detection_cli import evaluate_drift

if TYPE_CHECKING:
    from collections.abc import Callable

# Repo root, resolved from this module: tests/scripts/dev_tools/<file> is three
# levels below it.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests/fixtures/parallel_drift"

# Floor on corpus size, so a broken glob cannot make the parametrized lanes
# assert nothing.
MINIMUM_FIXTURE_COUNT = 18

# The module attribute the command line's loader calls; patching it here keeps
# every test off the filesystem.
READ_SEAM = "scripts.dev_tools._parallel_drift_cli_io.read_json_file"

# Placeholder paths handed to the command line; the patched reader selects the
# fixture's inline document by these names.
CHECKPOINT_NAME = "fixture-checkpoint.json"
CONFIG_NAME = "fixture-config.json"

# Every drift case the spec's test strategy requires the corpus to cover.
REQUIRED_CASES = frozenset(
    {
        "no-escape-inside-radius",
        "no-escape-empty-changed-paths",
        "escape-without-conflict",
        "halt-one-pair",
        "halt-several-pairs",
        "halt-drifter-started-later",
        "halt-equal-start-timestamps",
        "halt-one-start-absent",
        "halt-both-starts-absent",
        "reversed-existing-edge-not-new",
        "non-object-edge-ignored",
        "malformed-peer-radius-fails-closed",
        "tolerated-overlap-under-conflict-tolerance",
        "peer-not-in-flight-ignored",
        "peer-radius-iso-timestamp-evaluated",
        "error-items-not-a-list",
        "error-item-key-missing",
        "error-non-object-root",
    }
)


def _fixture_paths() -> list[Path]:
    """Return the committed corpus fixtures in name order.

    Returns:
        list[Path]: Every ``*.json`` file in the corpus directory, sorted so the
        parametrized node IDs are stable.
    """

    return sorted(CORPUS_DIR.glob("*.json"))


def _load_fixture(path: Path) -> dict[str, object]:
    """Read one corpus fixture as a JSON object.

    Args:
        path (Path): The fixture file.

    Returns:
        dict[str, object]: The parsed fixture.

    Raises:
        AssertionError: If the fixture root is not a JSON object.
    """

    document: object = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(document, dict), f"{path.name} must hold one JSON object"
    return cast("dict[str, object]", document)


def _paths_carrying(key: str) -> list[Path]:
    """Return the fixtures whose document carries one expectation key.

    Args:
        key (str): ``expected`` or ``expected_error``.

    Returns:
        list[Path]: The matching fixtures, in name order.
    """

    # Partition the corpus by expectation kind; each fixture carries exactly one.
    return [path for path in _fixture_paths() if key in _load_fixture(path)]


def _reader_for(fixture: dict[str, object]) -> Callable[[Path], object]:
    """Build a replacement for the command line's JSON file reader.

    Args:
        fixture (dict[str, object]): The parsed fixture.

    Returns:
        Callable[[Path], object]: A reader returning the fixture's inline
        ``state`` for the checkpoint placeholder and its ``config`` otherwise.
    """

    def read(path: Path) -> object:
        """Return the inline document selected by the requested path name.

        Args:
            path (Path): The path the command line asked to read.

        Returns:
            object: The fixture's ``state`` or ``config`` value.
        """

        return fixture["state"] if path.name == CHECKPOINT_NAME else fixture["config"]

    return read


def _cli_argv(fixture: dict[str, object]) -> list[str]:
    """Build the command-line argument vector for one fixture.

    Args:
        fixture (dict[str, object]): The parsed fixture.

    Returns:
        list[str]: Options naming the placeholder paths and both timestamps,
        followed by the fixture's changed paths.
    """

    return [
        "--item-key",
        str(fixture["item_key"]),
        "--checkpoint",
        CHECKPOINT_NAME,
        "--config",
        CONFIG_NAME,
        "--at",
        cast("str", fixture["at"]),
        "--computed-at",
        cast("str", fixture["computed_at"]),
        *cast("list[str]", fixture["changed_paths"]),
    ]


def _stem(path: object) -> str:
    """Render a fixture path as its parametrized node ID.

    Args:
        path (object): The fixture path pytest passes to the id callable.

    Returns:
        str: The file stem.
    """

    return cast("Path", path).stem


def test_drift_corpus_meets_floor() -> None:
    """The committed corpus holds at least the declared number of fixtures."""

    # Arrange / Act
    count = len(_fixture_paths())

    # Assert
    assert (
        count >= MINIMUM_FIXTURE_COUNT
    ), f"Expected at least {MINIMUM_FIXTURE_COUNT} drift fixtures, found {count}"


def test_drift_corpus_covers_every_named_case() -> None:
    """Every drift case the spec requires has a fixture of that name."""

    # Arrange / Act
    names = {path.stem for path in _fixture_paths()}

    # Assert
    missing = sorted(REQUIRED_CASES - names)
    assert not missing, f"Drift corpus lacks the required cases: {missing}"


@pytest.mark.parametrize("fixture_path", _paths_carrying("expected"), ids=_stem)
def test_reference_matches_fixture_payload(
    fixture_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """The pure function and the command line both reproduce the payload."""

    # Arrange
    fixture = _load_fixture(fixture_path)
    expected = fixture["expected"]
    monkeypatch.setattr(READ_SEAM, _reader_for(fixture))

    # Act
    payload = evaluate_drift(
        state=cast("dict[str, object]", fixture["state"]),
        config=cast("dict[str, object]", fixture["config"]),
        item_key=cast("int", fixture["item_key"]),
        changed_paths=cast("list[str]", fixture["changed_paths"]),
        at=cast("str", fixture["at"]),
        computed_at=cast("str", fixture["computed_at"]),
    )
    exit_code = drift_cli.main(_cli_argv(fixture))
    captured = capsys.readouterr()

    # Assert
    assert payload == expected, f"{fixture_path.stem}: evaluate_drift {payload}"
    assert exit_code == 0, f"{fixture_path.stem}: exit {exit_code} {captured.err!r}"
    assert (
        json.loads(captured.out) == expected
    ), f"{fixture_path.stem}: stdout {captured.out}"


@pytest.mark.parametrize("fixture_path", _paths_carrying("expected_error"), ids=_stem)
def test_reference_reports_fixture_error(
    fixture_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """The command line exits 1 with the failure prefix for an error fixture."""

    # Arrange
    fixture = _load_fixture(fixture_path)
    expected_error = cast("dict[str, object]", fixture["expected_error"])
    monkeypatch.setattr(READ_SEAM, _reader_for(fixture))

    # Act
    exit_code = drift_cli.main(_cli_argv(fixture))
    captured = capsys.readouterr()

    # Assert
    assert exit_code == expected_error["exit_code"], f"{fixture_path.stem}: {exit_code}"
    assert captured.err.startswith(
        cast("str", expected_error["stderr_prefix"])
    ), f"{fixture_path.stem}: stderr {captured.err!r}"
    assert captured.out == "", f"{fixture_path.stem}: stdout {captured.out!r}"
