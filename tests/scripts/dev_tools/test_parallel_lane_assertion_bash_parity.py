"""Python-lane assertions over the shared lane-assertion parity corpus.

Parametrize over every ``tests/fixtures/parallel_lane_assertion/*.json`` record
and assert that ``scripts/dev_tools/parallel_lane_assertion.py`` -- the
repository's reference implementation -- reproduces each record's
``expected_stdout`` exactly and returns its ``expected_status``. The same corpus
is asserted by the bash lane in ``tests/shell/parallel_lane_assertion_parity.bats``,
so the records are the single artifact that pins the two implementations
together; neither suite may relax an expectation without the other observing the
change.

Record shape. Every record carries ``name``, ``notes``, ``manifest_path`` (a
repo-relative path to a checked-in manifest under the corpus ``manifests/``
subdirectory), ``manifest_text`` (that file's exact content), ``edges`` (the raw
``--edges`` string), ``expected_stdout`` (the full report as one string with
``\\n`` separators and no trailing newline), ``expected_status`` (always 0), and
an optional ``divergence`` marker. Every ``expected_stdout`` value was derived by
running the reference over the record's manifest and edges, never hand authored.

Verified scope and declared divergence classes. Parity between the Python and
bash lanes is byte-exact for every record in this corpus, with exactly five
declared classes, stated identically in the bats lane's header:

1. (inherited) The M1 YAML-parse-failure message. The bash ``YP_DETAIL`` text is
   not PyYAML's exception text, so a record exercising that branch would pin the
   prefix only. No record in this corpus exercises it.
2. (inherited) Non-printable string-repr escapes. A string carrying a control
   character other than ``\\n``, ``\\r``, or ``\\t`` renders its escape
   differently between the two lanes, so no corpus record contains one.
3. The ``--edges`` integer lexis. The port applies the strict lexis
   ``^-?(0|[1-9][0-9]*)$`` rather than reproducing Python ``int()``'s
   permissiveness. The excluded input class has EXACTLY FOUR MEMBERS: an endpoint
   token bearing a leading zero, a leading ``+``, an underscore digit separator,
   or a non-ASCII decimal digit. All four are excluded from this corpus and are
   pinned bash-side by ``tests/shell/parallel_lane_assertion.bats``.

   WHITESPACE INSIDE AN ENDPOINT IS NOT A MEMBER OF CLASS 3. Both implementations
   split the ``--edges`` value on whitespace before partitioning a token on its
   first colon, so neither can observe interior whitespace and the two CONVERGE
   on it. It is carried inside this corpus as the convergence record
   ``edges_endpoint_interior_whitespace``, whose report is byte-identical to the
   ``edges_empty`` record for the same manifest. Do not move it into class 3.
4. The manifest-unreadable detail text. Python emits the ``OSError`` string,
   which bash cannot reproduce, so only the prefix
   ``Lane assertion: manifest unreadable (`` is parity scoped and the class is
   excluded from this corpus and covered bash-side.
5. Out-of-subset manifests. The bash scanner refuses constructs the Python
   authority parses, so the Python lane has no counterpart. The port prints a
   distinct refusal line and exits 0. The class is excluded from this corpus and
   covered bash-side; its fixtures live under
   ``tests/fixtures/parallel_lane_assertion_bash/``, outside the corpus
   directory, so the exclusion holds by construction.

The corpus files are committed and read-only here. No temporary file is created,
no external process is started, and no bash is invoked: parity is asserted
against a shared artifact rather than by cross-process execution.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools.parallel_lane_assertion import main

if TYPE_CHECKING:
    from collections.abc import Iterator

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py, so the
# repository root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_DIR = REPO_ROOT / "tests" / "fixtures" / "parallel_lane_assertion"
FIXTURE_SUFFIX = ".json"

# Floor on corpus size. An empty or partially matched glob would make every
# parametrized case below disappear and the suite would pass vacuously, so the
# count is asserted in a dedicated test rather than inferred from a passing run.
MINIMUM_FIXTURE_COUNT = 20


def load_record(path: Path) -> dict[str, object]:
    """Read one corpus record and guard that it deserializes to a JSON object.

    Args:
        path (Path): Absolute path to a corpus file.

    Returns:
        dict[str, object]: The parsed record.

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
    """Guard a record value that must be a JSON string.

    Args:
        value (object): Value read from a parsed record.
        label (str): Dotted record path used in the failure message.

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


def discover_record_paths() -> list[Path]:
    """List the corpus records in deterministic name order.

    Returns:
        list[Path]: Every ``*.json`` file at depth 1 of the corpus directory,
        sorted by path so parametrization ids are stable across platforms.

    Raises:
        None.

    Side Effects:
        Reads the corpus directory listing.
    """

    return sorted(FIXTURE_DIR.glob(f"*{FIXTURE_SUFFIX}"))


RECORD_PATHS = discover_record_paths()


@pytest.fixture
def repo_root_cwd(monkeypatch: pytest.MonkeyPatch) -> Iterator[None]:
    """Run the wrapped test with the repository root as the working directory.

    Every record's ``manifest_path`` is repo-relative, and the reference resolves
    it against the process working directory, so the two agree only when the test
    runs from the repository root. Pinning it here keeps the assertion
    independent of the directory pytest happened to be invoked from.

    Yields:
        None: Control returns to the test with the working directory changed.

    Side Effects:
        Changes and restores the process working directory through monkeypatch.
    """

    monkeypatch.chdir(REPO_ROOT)
    yield


def test_corpus_meets_declared_floor() -> None:
    """Assert the corpus is at least as large as the declared floor.

    A broken glob or a moved directory would silently empty the parametrized
    cases below, so the floor is asserted directly rather than inferred from a
    passing parametrized run.
    """

    # Arrange / Act: the module-level discovery already ran.
    discovered = len(RECORD_PATHS)

    # Assert
    assert discovered >= MINIMUM_FIXTURE_COUNT, (
        f"Lane-assertion parity corpus has {discovered} records; the declared "
        f"floor is {MINIMUM_FIXTURE_COUNT}. Restore the missing records or lower "
        f"the floor deliberately."
    )


@pytest.mark.parametrize("record_path", RECORD_PATHS, ids=lambda path: path.stem)
@pytest.mark.usefixtures("repo_root_cwd")
def test_reference_reproduces_every_corpus_fixture(
    record_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Assert the reference reproduces one record's report and status.

    The reference is called in-process rather than as a subprocess, so this lane
    asserts the return value of ``main`` where the bash lane asserts a process
    exit status. Both are the record's ``expected_status``.

    Args:
        record_path (Path): One corpus file supplied by parametrization.
        capsys (pytest.CaptureFixture[str]): Captures the report the reference
            prints to stdout.
    """

    # Arrange
    record = load_record(record_path)
    label = record_path.stem
    manifest_path = require_text(record.get("manifest_path"), f"{label}.manifest_path")
    edges = require_text(record.get("edges"), f"{label}.edges")
    expected_stdout = require_text(
        record.get("expected_stdout"), f"{label}.expected_stdout"
    )
    expected_status = record.get("expected_status")

    # Act
    status = main(["--manifest", manifest_path, "--edges", edges])
    captured = capsys.readouterr()

    # Assert: the record stores the report without its trailing newline, which
    # the reference's single print() supplies.
    assert (
        captured.out == expected_stdout + "\n"
    ), f"{label}: the reference's report does not match expected_stdout."
    assert (
        status == expected_status
    ), f"{label}: the reference returned {status}, expected {expected_status}."


def test_manifest_text_matches_manifest_path() -> None:
    """Assert every record's embedded manifest text equals its manifest file.

    The two can only drift if a manifest is edited without its records being
    regenerated, and that drift would silently change what both parity lanes
    believe they are comparing, so it is asserted directly.
    """

    # Arrange
    mismatched: list[str] = []

    # Act
    for record_path in RECORD_PATHS:
        record = load_record(record_path)
        label = record_path.stem
        manifest_path = require_text(
            record.get("manifest_path"), f"{label}.manifest_path"
        )
        embedded = require_text(record.get("manifest_text"), f"{label}.manifest_text")
        on_disk = (REPO_ROOT / manifest_path).read_text(encoding="utf-8")
        if embedded != on_disk:
            mismatched.append(f"{label} (against {manifest_path})")

    # Assert
    assert not mismatched, (
        f"These records embed a manifest_text that differs from the file at "
        f"their manifest_path: {mismatched}."
    )
