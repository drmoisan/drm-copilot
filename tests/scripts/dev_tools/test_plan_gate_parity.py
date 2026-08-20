"""Cross-runtime parity tests for the atomic-plan acceptance gates.

The eight `PARITY_*` fixtures below are duplicated verbatim in
`extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`, together
with the same expected finding strings, so a divergence in either runtime's
message text fails on both sides (spec AC9).

The no-`repr` message-formatting prohibition is asserted against the set of
Python gate modules named by `_PYTHON_GATE_MODULES` — currently
`plan_gate_discrimination.py` and `plan_gate_coverage.py` — rather than against
a single file, so relocating finding-string code between those modules cannot
escape the check. Its TypeScript companion asserts over the three TypeScript
gate modules for the same reason.
"""

from __future__ import annotations

import re
from pathlib import Path

from scripts.dev_tools.plan_gate_commands import PLAN_GATE_TASK_RE
from scripts.dev_tools.plan_gate_discrimination import (
    G5_SEVERITY,
    PlanGateContext,
    evaluate_plan_gates,
)
from scripts.dev_tools.validate_orchestration_artifacts import PLAN_TASK_RE

_REPO_ROOT = Path(__file__).resolve().parents[3]
_TYPESCRIPT_MODULE = (
    _REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "src"
    / "lib"
    / "validate"
    / "plan-gate-discrimination.ts"
)
_PYTHON_GATE_MODULES = (
    _REPO_ROOT / "scripts" / "dev_tools" / "plan_gate_discrimination.py",
    _REPO_ROOT / "scripts" / "dev_tools" / "plan_gate_coverage.py",
)

_G5_SEVERITY_TS_RE = re.compile(r'G5_SEVERITY\s*:\s*string\s*=\s*"([^"]+)"')


def _parity_plan(acceptance: str) -> str:
    """Build the shared one-task parity fixture around an acceptance command."""

    return "\n".join(
        [
            "### Phase 1 — Work",
            "- [ ] [P1-T1] Do the thing",
            f"  - Acceptance: `{acceptance}` reports the result.",
            "",
        ]
    )


PARITY_G1 = _parity_plan("poetry run pytest --cov=scripts/dev_tools/foo.py")
PARITY_G2 = _parity_plan("poetry run pytest --cov=scripts/dev_tools/foo")
PARITY_G3 = _parity_plan("poetry run pytest --cov=scripts/dev_tools/missing")
PARITY_G4 = _parity_plan("poetry run pytest --cov tests.foo")
PARITY_G5 = _parity_plan("grep -F -n 'pinned items occupy' docs/design.md")
PARITY_G6 = PARITY_G5
PARITY_G1_APOSTROPHE = _parity_plan(
    'poetry run pytest "--cov=scripts/dan\'s_tools/foo.py"'
)
PARITY_G5_APOSTROPHE = _parity_plan('grep -F -n "the planner\'s cohort" docs/design.md')

_EXPECTED_G1 = (
    "[P1-T1] --cov argument `scripts/dev_tools/foo.py` names a filesystem "
    "path; coverage.py accepts only directories or importable names. "
    "Use --cov=scripts.dev_tools.foo."
)
_EXPECTED_G2 = (
    "[P1-T1] --cov argument `scripts/dev_tools/foo` names a tracked module "
    "file path; coverage.py accepts only directories or importable names. "
    "Use --cov=scripts.dev_tools.foo."
)
_EXPECTED_G3 = (
    "[P1-T1] --cov argument `scripts/dev_tools/missing` contains a path "
    "separator but resolves to neither a tracked file nor a tracked "
    "directory; coverage may collect no data. Use the importable dotted form "
    "or a tracked directory."
)
_EXPECTED_G4 = (
    "[P1-T1] --cov argument value `tests.foo` is supplied space-separated; "
    "the ambiguous form can bind the following positional argument. "
    "Use the --cov=<module> form."
)
_EXPECTED_G5 = (
    "[P1-T1] search literal `pinned items occupy` is absent from the tracked "
    "tree and is not quoted in the plan; the search returns zero matches "
    "whatever the executor does. Quote the exact literal the task will "
    "create, or assert a literal that exists."
)
_EXPECTED_G6 = (
    "[P1-T1] search literal `pinned items occupy` is present only across "
    "adjacent lines of a tracked file and matches no single line; a "
    "line-oriented search returns zero matches. Search a shorter single-line "
    "token."
)
_EXPECTED_G1_APOSTROPHE = (
    "[P1-T1] --cov argument `scripts/dan's_tools/foo.py` names a filesystem "
    "path; coverage.py accepts only directories or importable names. "
    "Use --cov=scripts.dan's_tools.foo."
)
_EXPECTED_G5_APOSTROPHE = (
    "[P1-T1] search literal `the planner's cohort` is absent from the tracked "
    "tree and is not quoted in the plan; the search returns zero matches "
    "whatever the executor does. Quote the exact literal the task will "
    "create, or assert a literal that exists."
)


class _ParityGitRepository:
    """Tracked-tree stub configured per parity fixture.

    Attributes:
        tracked_files (set[str]): Paths reported as tracked files.
        matches (dict[str, list[str]]): `files_containing` answers by literal.
        texts (dict[str, str]): `read_tracked_text` answers by path.
    """

    def __init__(
        self,
        *,
        tracked_files: set[str] | None = None,
        matches: dict[str, list[str]] | None = None,
        texts: dict[str, str] | None = None,
    ) -> None:
        self.tracked_files = tracked_files or set()
        self.matches = matches or {}
        self.texts = texts or {}

    def files_containing(self, literal: str) -> list[str]:
        """Return the configured match list for the literal."""

        return list(self.matches.get(literal, []))

    def is_tracked_file(self, path: str) -> bool:
        """Return whether the path is in the configured tracked-file set."""

        return path in self.tracked_files

    def is_tracked_directory(self, path: str) -> bool:
        """Return False; no parity fixture declares a tracked directory."""

        return False

    def read_tracked_text(self, path: str) -> str:
        """Return the configured committed text for the path."""

        return self.texts.get(path, "")


class _ParityFileSystem:
    """Read-only filesystem stub that answers negatively and reads nothing."""

    def is_file(self, path: Path) -> bool:
        """Return False; no rule consults the filesystem seam."""

        return False

    def is_dir(self, path: Path) -> bool:
        """Return False; no rule consults the filesystem seam."""

        return False

    def read_text(self, path: Path) -> str:
        """Return an empty string; no rule consults the filesystem seam."""

        return ""

    def read_bytes(self, path: Path) -> bytes:
        """Return empty bytes; no rule consults the filesystem seam."""

        return b""

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        """Return an empty list; no rule consults the filesystem seam."""

        return []


def _context(git: _ParityGitRepository) -> PlanGateContext:
    """Wrap a parity git stub in a context with a stub filesystem."""

    return PlanGateContext(
        workspace_root=Path("/workspace"),
        file_system=_ParityFileSystem(),
        git=git,
    )


_G6_GIT = _ParityGitRepository(
    matches={"pinned": ["docs/design.md"]},
    texts={"docs/design.md": "the pinned\nitems occupy the cohort\n"},
)

_ParityCase = tuple[str, str, _ParityGitRepository, list[str], list[str]]

# One row per parity fixture: name, plan text, git stub, blocking, warnings.
# The G5 rows route through `G5_SEVERITY`, so their channel is selected below
# rather than hard-coded, keeping the table valid under either severity.
_PARITY_CASES: tuple[_ParityCase, ...] = (
    ("PARITY_G1", PARITY_G1, _ParityGitRepository(), [_EXPECTED_G1], []),
    (
        "PARITY_G2",
        PARITY_G2,
        _ParityGitRepository(tracked_files={"scripts/dev_tools/foo.py"}),
        [_EXPECTED_G2],
        [],
    ),
    ("PARITY_G3", PARITY_G3, _ParityGitRepository(), [], [_EXPECTED_G3]),
    ("PARITY_G4", PARITY_G4, _ParityGitRepository(), [], [_EXPECTED_G4]),
    ("PARITY_G6", PARITY_G6, _G6_GIT, [], [_EXPECTED_G6]),
    (
        "PARITY_G1_APOSTROPHE",
        PARITY_G1_APOSTROPHE,
        _ParityGitRepository(),
        [_EXPECTED_G1_APOSTROPHE],
        [],
    ),
)

# The two G5 rows are held separately because their channel depends on
# `G5_SEVERITY` rather than on the rule that produced them.
_PARITY_G5_CASES: tuple[tuple[str, str, str], ...] = (
    ("PARITY_G5", PARITY_G5, _EXPECTED_G5),
    ("PARITY_G5_APOSTROPHE", PARITY_G5_APOSTROPHE, _EXPECTED_G5_APOSTROPHE),
)


def test_parity_findings_match_expected_strings() -> None:
    """All eight parity fixtures produce the exact expected finding lists."""

    # Arrange / Act / Assert: one exact list comparison per fixture.
    for name, text, git, blocking, warnings in _PARITY_CASES:
        report = evaluate_plan_gates(text, context=_context(git))
        assert report.blocking == blocking, name
        assert report.warnings == warnings, name

    # The G5 rows assert the finding on the channel `G5_SEVERITY` names and the
    # absence of any finding on the other channel.
    for name, text, expected in _PARITY_G5_CASES:
        report = evaluate_plan_gates(text, context=_context(_ParityGitRepository()))
        if G5_SEVERITY == "blocking":
            assert report.blocking == [expected], name
            assert report.warnings == [], name
        else:
            assert report.warnings == [expected], name
            assert report.blocking == [], name


def test_g5_severity_constant_matches_typescript() -> None:
    """The TypeScript `G5_SEVERITY` literal equals the Python constant."""

    # Arrange
    source = _TYPESCRIPT_MODULE.read_text(encoding="utf-8")

    # Act
    match = _G5_SEVERITY_TS_RE.search(source)

    # Assert
    assert match is not None, "G5_SEVERITY literal not found in the TS module"
    assert match.group(1) == G5_SEVERITY


def test_no_repr_formatting_in_gate_messages() -> None:
    """Every Python gate module renders values without `repr`-style formatting.

    The prohibition covers the whole module set rather than one file, so moving
    finding-string code into a sibling module cannot silently escape it.
    """

    # Arrange / Act / Assert: both prohibited substrings are checked for every
    # module in the set, and each assertion names the module it read so a
    # failure identifies the offending file directly.
    for module in _PYTHON_GATE_MODULES:
        source = module.read_text(encoding="utf-8")
        assert "!r" not in source, f"`!r` conversion present in {module.name}"
        assert "repr(" not in source, f"`repr(` call present in {module.name}"


def test_extractor_task_pattern_matches_validator_pattern() -> None:
    """The extractor's task pattern is textually identical to the validator's."""

    # Arrange / Act / Assert
    assert PLAN_GATE_TASK_RE.pattern == PLAN_TASK_RE.pattern
