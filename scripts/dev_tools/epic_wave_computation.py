"""Compute epic wave numbers from a feature dependency manifest.

Purpose:
    Provide the canonical, tested reference implementation of the
    longest-path-layering wave formula documented in
    `.claude/skills/epic-orchestrate/SKILL.md` (`## Wave Assignment`) and
    `.claude/agents/epic-orchestrator.md` (`## Wave Scheduling`):
    `wave(f) = 0` when `depends_on(f)` is empty, otherwise
    `wave(f) = 1 + max(wave(d) for d in depends_on(f))`.

Responsibilities:
    Given a mapping of `feature_folder -> depends_on` entries, compute each
    feature's wave number via memoized recursion, and raise a dedicated
    exception when the manifest contains a dependency cycle. This module does
    not read or write any manifest file; it operates purely on the mapping
    passed in by the caller.

Usage:
    Callers (for example the epic-orchestrator agent) parse an epic manifest
    into a `feature_folder -> depends_on` mapping and pass it to
    `compute_wave_numbers`. The returned mapping assigns every feature folder
    its wave number, ready for wave-barrier scheduling.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence


class EpicWaveCycleError(ValueError):
    """Raised when the dependency manifest contains a cycle.

    Purpose:
        Signal that `compute_wave_numbers` encountered a `feature_folder`
        that is still being resolved higher up its own recursive call chain,
        meaning the manifest's `depends_on` edges form a cycle and no finite
        wave number can be assigned.

    Attributes:
        feature_folder (str): The feature folder at which the cycle was
            detected (the folder being revisited while still in progress).
    """

    def __init__(self, feature_folder: str) -> None:
        """Initialize the exception with the cycle-triggering feature folder.

        Args:
            feature_folder (str): The feature folder at which the cycle was
                detected.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            None.
        """

        self.feature_folder = feature_folder
        super().__init__(
            f"Epic dependency manifest contains a cycle at feature folder "
            f"{feature_folder!r}; wave numbers cannot be computed for a "
            f"cyclic dependency graph."
        )


def compute_wave_numbers(
    manifest: Mapping[str, Sequence[str]],
) -> dict[str, int]:
    """Compute the wave number of every feature folder in a dependency manifest.

    Args:
        manifest (Mapping[str, Sequence[str]]): A mapping of
            `feature_folder -> depends_on`, where `depends_on` lists the
            feature folders (keys of the same mapping) that the feature
            depends on. An empty `depends_on` sequence means the feature has
            no dependencies.

    Returns:
        dict[str, int]: A mapping of `feature_folder -> wave_number`, where
        `wave_number` follows the longest-path-layering formula:
        `wave(f) = 0` when `depends_on(f)` is empty, else
        `wave(f) = 1 + max(wave(d) for d in depends_on(f))`.

    Raises:
        EpicWaveCycleError: If the manifest's `depends_on` edges form a
            cycle, so no finite wave number can be assigned to the features
            on that cycle.

    Side Effects:
        None. This function is pure: it does not read or write any file, and
        it does not mutate the input `manifest`.
    """

    wave_numbers: dict[str, int] = {}
    # Tracks feature folders currently on the active recursion path, so a
    # revisit of one of them proves a cycle rather than legitimate reuse of
    # an already-resolved dependency (which is instead served from the
    # `wave_numbers` memo below).
    in_progress: set[str] = set()

    def resolve(feature_folder: str) -> int:
        """Resolve one feature folder's wave number via memoized recursion.

        Args:
            feature_folder (str): The feature folder whose wave number is
                being resolved.

        Returns:
            int: The resolved wave number.

        Raises:
            EpicWaveCycleError: If `feature_folder` is already on the active
                recursion path (a cycle).

        Side Effects:
            Populates `wave_numbers` and `in_progress` as a side effect of
            the recursive resolution.
        """

        if feature_folder in wave_numbers:
            return wave_numbers[feature_folder]

        if feature_folder in in_progress:
            raise EpicWaveCycleError(feature_folder)

        in_progress.add(feature_folder)
        try:
            depends_on = manifest.get(feature_folder, ())
            if not depends_on:
                wave_number = 0
            else:
                # Walk each dependency, resolving it first (recursively) so
                # this feature's wave is one layer above the deepest
                # dependency it relies on.
                wave_number = 1 + max(resolve(dependency) for dependency in depends_on)
        finally:
            in_progress.discard(feature_folder)

        wave_numbers[feature_folder] = wave_number
        return wave_number

    # Resolve every feature folder in the manifest so the returned mapping
    # covers all features, not just those reachable from a single root.
    for feature_folder in manifest:
        resolve(feature_folder)

    return wave_numbers
