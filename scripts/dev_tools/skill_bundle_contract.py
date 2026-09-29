"""Check that every script a skill invokes is published with that skill.

Purpose:
    A skill is pushed down through the Claude customization bundle; a skill that
    invokes a script the bundle does not carry fails in the destination (issue
    #762). This module extracts a skill's script references and decides, from a
    snapshot of the repository, bundle, and pack manifests, whether each one is
    published with the skill.

Responsibilities and flow:
    Pure logic only; the I/O boundary is ``skill_bundle_contract_cli.py``.
    ``extract_script_references`` reads invocation forms from a skill text,
    ``evaluate_skill_bundle`` classifies references and skill-folder files,
    ``find_violations`` applies that to every skill minus registered exceptions,
    and ``find_stale_exceptions`` reports exceptions that match no violation.

Key invariants, raises, and side effects:
    A reason is exactly ``missing-file``, ``not-in-bundle``, or
    ``not-in-skill-pack``; folder location is never a reason. No function
    performs I/O or mutates its arguments. Unterminated or unparseable
    frontmatter raises ``ValueError``, as does an unknown violation reason.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import TYPE_CHECKING, cast

import yaml

if TYPE_CHECKING:
    from collections.abc import Iterable, Mapping

# Top-level folders the push-down publishes. Mirrors the ``ROOT_FOLDERS``
# constant of extensions/drm-copilot/src/lib/push-down/claude-customizations.ts;
# a repository test pins the two equal.
PUBLISHED_ROOT_FOLDERS: tuple[str, ...] = (".claude", "config")

_VIOLATION_REASONS = frozenset({"missing-file", "not-in-bundle", "not-in-skill-pack"})
_CORE_PACK = "core"

# A path token: path characters only, ending in a script suffix.
_PATH_TOKEN = re.compile(r"[A-Za-z0-9_./-]+\.(?:sh|ps1|psm1|py)")
# Characters that mark a glob or a placeholder; such a token names no file.
_PLACEHOLDER_CHARACTERS = frozenset("*<>{}$")
# A candidate token ends at whitespace, a quote, a backtick, a parenthesis, or
# the end of the text; the candidate is then validated against _PATH_TOKEN.
_CANDIDATE = r"(?P<path>[^\s'\"`()]+)"
_INVOCATION_PATTERNS: tuple[re.Pattern[str], ...] = (
    # bash/sh/source <path>; the look-behind keeps "bash" from also matching "sh".
    re.compile(r"(?<![A-Za-z0-9_-])(?:bash|sh|source)\s+" + _CANDIDATE),
    # pwsh ... -File <path>, on one line.
    re.compile(r"(?<![A-Za-z0-9_-])pwsh\b[^\n]*?-File\s+" + _CANDIDATE),
    # & <path> (PowerShell call operator).
    re.compile(r"&\s+" + _CANDIDATE),
    # . <path> (dot-source), preceded by line start, whitespace, "(", or a backtick.
    re.compile(r"(?:^|(?<=[\s(`]))\.\s+" + _CANDIDATE, re.MULTILINE),
    # Import-Module <path>.
    re.compile(r"Import-Module\s+" + _CANDIDATE),
    # Import-Module (Join-Path <expr> '<path>') with single or double quotes.
    re.compile(r"Import-Module\s+\(Join-Path\s+[^'\"\n]*['\"](?P<path>[^'\"\n]+)['\"]"),
)
_PYTHON_PATH_PATTERN = re.compile(r"(?<![A-Za-z0-9_-])python3?\s+" + _CANDIDATE)
_PYTHON_MODULE_PATTERN = re.compile(
    r"(?<![A-Za-z0-9_-])python3?\s+-m\s+"
    r"(?P<module>[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)+)"
)
_BASH_WRAPPER = re.compile(r"Bash\((?P<inner>.*)\)", re.DOTALL)
_ALLOWED_TOOLS_KEY = "allowed-tools:"
_FRONTMATTER_FENCE = "---"


@dataclass(frozen=True)
class SkillBundleViolation:
    """One script reference or skill-folder file that is not published.

    Purpose:
        Names the skill, the repository-relative path, and the reason the path
        would not reach a destination workspace with that skill.

    Key invariants:
        ``reason`` is one of ``missing-file`` (the path is not a file in the
        repository), ``not-in-bundle`` (the path is outside the published root
        folders or absent from the bundle), or ``not-in-skill-pack`` (the
        bundle carries the path but no pack that installs the skill lists it).

    Attributes:
        skill (str): Skill folder name under ``.claude/skills/``.
        path (str): Repository-relative POSIX path of the reference or file.
        reason (str): One of the three reasons above.
    """

    skill: str
    path: str
    reason: str

    def __post_init__(self) -> None:
        """Reject a reason outside the three documented values.

        Returns:
            None.

        Raises:
            ValueError: When ``reason`` is not a documented violation reason.
        """

        if self.reason not in _VIOLATION_REASONS:
            raise ValueError(f"Unknown skill bundle violation reason: {self.reason}")


@dataclass(frozen=True)
class KnownUnbundledReference:
    """A registered, issue-linked exception to the bundling rule.

    Purpose:
        Records a reference that is known to be unpublished and is tracked by
        a follow-up issue, so the guard does not fail on it while the issue is
        open. A stale entry is reported by ``find_stale_exceptions``.

    Attributes:
        skill (str): Skill folder name that makes the reference.
        path (str): Repository-relative POSIX path of the reference.
        issue (str): Tracking issue, for example ``#763``.
    """

    skill: str
    path: str
    issue: str


# The two Python CLI references whose ports into a bundled runtime are tracked
# by issue #763. Each entry must keep matching a real violation (AC7).
KNOWN_UNBUNDLED_REFERENCES: tuple[KnownUnbundledReference, ...] = (
    KnownUnbundledReference(
        "parallel-orchestrate",
        "scripts/dev_tools/parallel_drift_detection_cli.py",
        "#763",
    ),
    KnownUnbundledReference(
        "parallel-remove",
        "scripts/dev_tools/parallel_mutation_abandon_cli.py",
        "#763",
    ),
)


@dataclass(frozen=True)
class SkillBundleInputs:
    """Snapshot of the repository, bundle, and pack state the guard reads.

    Purpose:
        Carries every fact the evaluation needs so the evaluation itself stays
        pure and testable with inline data.

    Attributes:
        skill_texts (Mapping[str, str]): Skill name to ``SKILL.md`` text.
        skill_folder_files (Mapping[str, frozenset[str]]): Skill name to the
            repository-relative POSIX paths of every file in its folder.
        repository_files (frozenset[str]): Repository-relative POSIX paths
            known to exist as files.
        bundle_files (frozenset[str]): Paths relative to the bundle root.
        pack_paths (Mapping[str, frozenset[str]]): Pack name to the ``paths``
            listed by its manifest.
    """

    skill_texts: Mapping[str, str]
    skill_folder_files: Mapping[str, frozenset[str]]
    repository_files: frozenset[str]
    bundle_files: frozenset[str]
    pack_paths: Mapping[str, frozenset[str]]


def _split_frontmatter(skill_text: str) -> tuple[list[str] | None, str]:
    """Split a skill text into its frontmatter lines and its body.

    Args:
        skill_text (str): Full ``SKILL.md`` text.

    Returns:
        tuple[list[str] | None, str]: The lines between the opening and the
        closing ``---`` fence (``None`` when the text has no frontmatter), and
        the body that follows the closing fence (the whole text when there is
        no frontmatter).

    Raises:
        ValueError: When an opening ``---`` fence has no closing fence.
    """

    lines = skill_text.splitlines()
    if not lines or lines[0].strip() != _FRONTMATTER_FENCE:
        return None, skill_text
    # Find the first closing fence after the opening line.
    for index in range(1, len(lines)):
        if lines[index].strip() == _FRONTMATTER_FENCE:
            return lines[1:index], "\n".join(lines[index + 1 :])
    raise ValueError("Skill frontmatter opens with '---' but is never closed.")


def _allowed_tools_block(frontmatter: list[str]) -> str | None:
    """Return the ``allowed-tools`` key and its continuation lines as YAML text.

    The rest of the frontmatter is deliberately not parsed, because some
    ``description:`` values carry an unquoted colon that ``yaml.safe_load``
    rejects.

    Args:
        frontmatter (list[str]): Lines between the frontmatter fences.

    Returns:
        str | None: The block text, or ``None`` when no line starts with
        ``allowed-tools:``.
    """

    # Locate the key line; its value continues on indented or list-item lines.
    for start, line in enumerate(frontmatter):
        if not line.startswith(_ALLOWED_TOOLS_KEY):
            continue
        block = [line]
        # Collect continuation lines until the next top-level key.
        for continuation in frontmatter[start + 1 :]:
            if continuation[:1] in (" ", "\t", "-") or not continuation.strip():
                block.append(continuation)
                continue
            break
        return "\n".join(block)
    return None


def parse_allowed_tools(skill_text: str) -> tuple[str, ...]:
    """Return the ``allowed-tools`` entries declared in a skill's frontmatter.

    Args:
        skill_text (str): Full ``SKILL.md`` text.

    Returns:
        tuple[str, ...]: The entries in declaration order. A list value is
        returned entry by entry; a scalar string value (``Bash Read``) is split
        on whitespace. Empty when there is no frontmatter or no key.

    Raises:
        ValueError: When the frontmatter is unterminated or the
            ``allowed-tools`` block is not valid YAML.
    """

    frontmatter, _ = _split_frontmatter(skill_text)
    if frontmatter is None:
        return ()
    block = _allowed_tools_block(frontmatter)
    if block is None:
        return ()
    try:
        parsed = yaml.safe_load(block)
    except yaml.YAMLError as error:
        raise ValueError(f"allowed-tools block is not valid YAML: {error}") from error
    value = cast("dict[str, object]", parsed).get("allowed-tools")
    # Route by the YAML shape: a list is taken entry by entry, a scalar string
    # is the space-separated form, and an empty key declares no tools.
    if isinstance(value, list):
        return tuple(str(entry) for entry in cast("list[object]", value))
    if isinstance(value, str):
        return tuple(value.split())
    return ()


def _normalize_candidate(candidate: str) -> str | None:
    """Validate one candidate token and return it as a repository path.

    Args:
        candidate (str): Text captured after an invocation form.

    Returns:
        str | None: The path with any leading ``./`` removed, or ``None`` when
        the token is a glob or placeholder or is not a script path.
    """

    if any(character in _PLACEHOLDER_CHARACTERS for character in candidate):
        return None
    if _PATH_TOKEN.fullmatch(candidate) is None:
        return None
    return candidate[2:] if candidate.startswith("./") else candidate


def _references_in_chunk(chunk: str) -> set[str]:
    """Collect the script paths invoked by one piece of text.

    Args:
        chunk (str): A skill body or one unwrapped ``allowed-tools`` entry.

    Returns:
        set[str]: Repository-relative script paths found in the chunk.
    """

    found: set[str] = set()
    # Apply every generic invocation form and keep the tokens that are paths.
    for pattern in _INVOCATION_PATTERNS:
        for match in pattern.finditer(chunk):
            path = _normalize_candidate(match.group("path"))
            if path is not None:
                found.add(path)
    # The python path form only accepts .py targets.
    for match in _PYTHON_PATH_PATTERN.finditer(chunk):
        path = _normalize_candidate(match.group("path"))
        if path is not None and path.endswith(".py"):
            found.add(path)
    # python -m <dotted.name> resolves the dotted module to a .py file path.
    for match in _PYTHON_MODULE_PATTERN.finditer(chunk):
        found.add(match.group("module").replace(".", "/") + ".py")
    return found


def extract_script_references(skill_text: str) -> tuple[str, ...]:
    """Return every script path a skill invokes, sorted and de-duplicated.

    Scans the body and every ``allowed-tools`` entry; a ``Bash(...)`` entry is
    scanned with its wrapper removed. A backticked path with no invocation form
    is a citation and is not returned.

    Args:
        skill_text (str): Full ``SKILL.md`` text.

    Returns:
        tuple[str, ...]: Sorted repository-relative script paths.

    Raises:
        ValueError: When the frontmatter is unterminated or unparseable.
    """

    _, body = _split_frontmatter(skill_text)
    chunks = [body]
    # Unwrap Bash(...) permission entries so their command text is scanned.
    for entry in parse_allowed_tools(skill_text):
        wrapped = _BASH_WRAPPER.fullmatch(entry)
        chunks.append(wrapped.group("inner") if wrapped else entry)
    references: set[str] = set()
    # Merge the references of every chunk into one set.
    for chunk in chunks:
        references |= _references_in_chunk(chunk)
    return tuple(sorted(references))


def _skill_packs(
    skill: str, pack_paths: Mapping[str, frozenset[str]]
) -> tuple[str, ...]:
    """Return the packs that install a skill, identified by its ``SKILL.md``.

    Args:
        skill (str): Skill folder name.
        pack_paths (Mapping[str, frozenset[str]]): Pack name to listed paths.

    Returns:
        tuple[str, ...]: Sorted names of the packs listing the skill's text.
    """

    skill_text_path = f".claude/skills/{skill}/SKILL.md"
    # Keep only the packs whose manifest lists this skill's SKILL.md.
    return tuple(
        sorted(name for name, paths in pack_paths.items() if skill_text_path in paths)
    )


def _publication_reason(
    path: str, inputs: SkillBundleInputs, skill_packs: tuple[str, ...]
) -> str | None:
    """Classify whether an existing file is published with a skill.

    Args:
        path (str): Repository-relative POSIX path.
        inputs (SkillBundleInputs): Snapshot being evaluated.
        skill_packs (tuple[str, ...]): Packs that install the skill.

    Returns:
        str | None: ``not-in-bundle``, ``not-in-skill-pack``, or ``None`` when
        the path is bundled and carried.
    """

    # Bundle membership is decided first: a path outside the published roots
    # can never be carried, whatever the manifests list.
    if (
        path.split("/", 1)[0] not in PUBLISHED_ROOT_FOLDERS
        or path not in inputs.bundle_files
    ):
        return "not-in-bundle"
    # Carried through core (always installed) or through every pack that
    # installs the skill; a skill listed by no pack is carried only via core.
    if path in inputs.pack_paths.get(_CORE_PACK, frozenset()):
        return None
    if skill_packs and all(path in inputs.pack_paths[name] for name in skill_packs):
        return None
    return "not-in-skill-pack"


def evaluate_skill_bundle(
    skill: str, references: Iterable[str], inputs: SkillBundleInputs
) -> tuple[SkillBundleViolation, ...]:
    """Classify one skill's references and folder files against the snapshot.

    Args:
        skill (str): Skill folder name.
        references (Iterable[str]): Script paths the skill invokes.
        inputs (SkillBundleInputs): Snapshot being evaluated.

    Returns:
        tuple[SkillBundleViolation, ...]: Violations in evaluation order,
        references first and then folder files, without duplicates.
    """

    skill_packs = _skill_packs(skill, inputs.pack_paths)
    violations: dict[SkillBundleViolation, None] = {}
    # A reference must exist before its publication can be judged.
    for path in references:
        reason = (
            "missing-file"
            if path not in inputs.repository_files
            else _publication_reason(path, inputs, skill_packs)
        )
        if reason is not None:
            violations[SkillBundleViolation(skill, path, reason)] = None
    # Every file in the skill folder must travel with the skill as well.
    for path in sorted(inputs.skill_folder_files.get(skill, frozenset())):
        reason = _publication_reason(path, inputs, skill_packs)
        if reason is not None:
            violations[SkillBundleViolation(skill, path, reason)] = None
    return tuple(violations)


def _all_violations(inputs: SkillBundleInputs) -> tuple[SkillBundleViolation, ...]:
    """Evaluate every skill in sorted order with no exceptions applied.

    Args:
        inputs (SkillBundleInputs): Snapshot being evaluated.

    Returns:
        tuple[SkillBundleViolation, ...]: Every violation of every skill.
    """

    skills = sorted(set(inputs.skill_texts) | set(inputs.skill_folder_files))
    violations: list[SkillBundleViolation] = []
    # Skills with folder files but no text are still checked for folder files.
    for skill in skills:
        references = extract_script_references(inputs.skill_texts.get(skill, ""))
        violations.extend(evaluate_skill_bundle(skill, references, inputs))
    return tuple(violations)


def find_violations(
    inputs: SkillBundleInputs,
    *,
    exceptions: Iterable[KnownUnbundledReference] = KNOWN_UNBUNDLED_REFERENCES,
) -> tuple[SkillBundleViolation, ...]:
    """Return every unregistered violation across all skills.

    Args:
        inputs (SkillBundleInputs): Snapshot being evaluated.
        exceptions (Iterable[KnownUnbundledReference]): Registered exceptions;
            a violation whose ``(skill, path)`` matches one is dropped.

    Returns:
        tuple[SkillBundleViolation, ...]: Remaining violations, skills sorted.
    """

    exempt = {(exception.skill, exception.path) for exception in exceptions}
    # Drop only the violations that a registered exception names exactly.
    return tuple(
        violation
        for violation in _all_violations(inputs)
        if (violation.skill, violation.path) not in exempt
    )


def find_stale_exceptions(
    inputs: SkillBundleInputs,
    *,
    exceptions: Iterable[KnownUnbundledReference] = KNOWN_UNBUNDLED_REFERENCES,
) -> tuple[KnownUnbundledReference, ...]:
    """Return every exception that no longer matches a violation.

    Args:
        inputs (SkillBundleInputs): Snapshot being evaluated.
        exceptions (Iterable[KnownUnbundledReference]): Registered exceptions.

    Returns:
        tuple[KnownUnbundledReference, ...]: Exceptions whose ``(skill, path)``
        does not occur among the violations computed with no exceptions.
    """

    present = {
        (violation.skill, violation.path) for violation in _all_violations(inputs)
    }
    # Keep the exceptions whose target violation has disappeared.
    return tuple(
        exception
        for exception in exceptions
        if (exception.skill, exception.path) not in present
    )
