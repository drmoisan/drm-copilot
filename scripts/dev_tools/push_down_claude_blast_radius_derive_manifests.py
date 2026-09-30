"""Manifest vocabulary and project-directory classification for the derivation.

Purpose:
    Python port of
    ``extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts``.
    Own the manifest names, the two manifest-suffix families, the exclusion set,
    and the classification step (algorithm step 2). A .NET project or solution
    file is a structure signal that is not a module (issue #643), so the module
    and non-module questions are answered separately.

Invariants / Constraints:
    - ``MANIFEST_SUFFIXES`` is the concatenation of the module and non-module
      families, so ``is_manifest_file_name`` covers both.
    - Ordinal comparison is plain Python string ordering (code-point order),
      which matches the TypeScript ``<``/``>`` comparison for the ASCII names
      the scan observes.
    - No I/O; every function is pure and mutates no input.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Sequence

__all__ = [
    "EXCLUDED_DIR_NAMES",
    "MANIFEST_FILENAMES",
    "MANIFEST_SUFFIXES",
    "MODULE_MANIFEST_SUFFIXES",
    "NON_MODULE_MANIFEST_SUFFIXES",
    "DirectoryObservation",
    "ProjectDirectoryClassification",
    "classify_project_directories",
    "compare_ordinal",
    "is_excluded_directory_name",
    "is_manifest_file_name",
    "is_module_manifest_file_name",
    "is_non_module_manifest_file_name",
]


@dataclass(frozen=True)
class DirectoryObservation:
    """One visited destination directory and its shallow file listing.

    Attributes:
        relative_path (str): Destination-relative POSIX path; the root is ``""``.
        file_names (tuple[str, ...]): Names of the files directly inside the
            directory, excluding subdirectories.
    """

    relative_path: str
    file_names: tuple[str, ...]


@dataclass(frozen=True)
class ProjectDirectoryClassification:
    """Result of classifying a destination's directory observations.

    Attributes:
        module_paths (tuple[str, ...]): Paths that become modules, ordinally
            sorted.
        structure_observed (bool): Whether any project directory was observed,
            module-bearing or not; ``True`` suppresses the top-level fallback.
    """

    module_paths: tuple[str, ...]
    structure_observed: bool


# Exact file names whose presence marks a directory as a project directory.
MANIFEST_FILENAMES: frozenset[str] = frozenset(
    {
        "build.gradle",
        "build.gradle.kts",
        "Cargo.toml",
        "go.mod",
        "package.json",
        "pom.xml",
        "pyproject.toml",
        "setup.py",
    }
)

# Suffixes whose bearing directory becomes a module. Empty today; declared so a
# future module-naming suffix has a home.
MODULE_MANIFEST_SUFFIXES: tuple[str, ...] = ()

# Suffixes that mark a project directory without making it a module.
NON_MODULE_MANIFEST_SUFFIXES: tuple[str, ...] = (
    ".csproj",
    ".fsproj",
    ".vbproj",
    ".sln",
    ".slnx",
)

# File-name suffixes whose presence marks a directory as a project directory.
MANIFEST_SUFFIXES: tuple[str, ...] = (
    *MODULE_MANIFEST_SUFFIXES,
    *NON_MODULE_MANIFEST_SUFFIXES,
)

# Directory names the destination scan never descends into. Dot-prefixed names
# are excluded by ``is_excluded_directory_name``, not by membership here.
EXCLUDED_DIR_NAMES: frozenset[str] = frozenset(
    {
        "__pycache__",
        "artifacts",
        "bin",
        "build",
        "coverage",
        "dist",
        "doc",
        "docs",
        "node_modules",
        "obj",
        "out",
        "target",
        "test",
        "tests",
        "venv",
    }
)


def compare_ordinal(left: str, right: str) -> int:
    """Compare two strings ordinally.

    Args:
        left (str): First string.
        right (str): Second string.

    Returns:
        int: Negative, zero, or positive per the comparator contract.
    """

    if left < right:
        return -1
    return 1 if left > right else 0


def is_excluded_directory_name(name: str) -> bool:
    """Report whether a directory name is excluded from the destination scan.

    Args:
        name (str): A single directory name, not a path.

    Returns:
        bool: ``True`` when the name is a pruned bucket or begins with a dot.
    """

    return name.startswith(".") or name in EXCLUDED_DIR_NAMES


def is_manifest_file_name(file_name: str) -> bool:
    """Report whether a file name marks its directory as a project directory.

    Args:
        file_name (str): A single file name, not a path.

    Returns:
        bool: ``True`` for an exact manifest name or any manifest suffix.
    """

    if file_name in MANIFEST_FILENAMES:
        return True
    return any(file_name.endswith(suffix) for suffix in MANIFEST_SUFFIXES)


def is_module_manifest_file_name(file_name: str) -> bool:
    """Report whether a file name marks its directory as a module.

    Args:
        file_name (str): A single file name, not a path.

    Returns:
        bool: ``True`` for an exact manifest name or a module-family suffix.
    """

    if file_name in MANIFEST_FILENAMES:
        return True
    return any(file_name.endswith(suffix) for suffix in MODULE_MANIFEST_SUFFIXES)


def is_non_module_manifest_file_name(file_name: str) -> bool:
    """Report whether a file name is a structure signal that is not a module.

    Args:
        file_name (str): A single file name, not a path.

    Returns:
        bool: ``True`` for a non-module-family suffix that is not an exact
        manifest name.
    """

    return file_name not in MANIFEST_FILENAMES and any(
        file_name.endswith(suffix) for suffix in NON_MODULE_MANIFEST_SUFFIXES
    )


def classify_project_directories(
    observations: Sequence[DirectoryObservation],
) -> ProjectDirectoryClassification:
    """Select the observations that are project directories (algorithm step 2).

    Args:
        observations (Sequence[DirectoryObservation]): Every visited
            directory, including the root.

    Returns:
        ProjectDirectoryClassification: The sorted module paths and whether
        structure was observed.
    """

    module_paths: list[str] = []
    structure_observed = False
    # The root is skipped categorically: a root-level manifest would name the
    # whole destination and yield the universal glob.
    for observation in observations:
        if observation.relative_path == "":
            continue
        if any(is_module_manifest_file_name(name) for name in observation.file_names):
            module_paths.append(observation.relative_path)
            structure_observed = True
            continue
        # A non-module manifest contributes no path but records structure.
        if any(
            is_non_module_manifest_file_name(name) for name in observation.file_names
        ):
            structure_observed = True
    return ProjectDirectoryClassification(
        module_paths=tuple(sorted(module_paths)),
        structure_observed=structure_observed,
    )
