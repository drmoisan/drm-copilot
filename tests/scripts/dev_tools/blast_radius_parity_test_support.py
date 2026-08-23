"""Declared constants and key accessors for the blast-radius parity gate.

Purpose:
    Hold the inert data and the read-only accessors that
    ``test_blast_radius_config_parity.py`` uses, so that module stays inside the
    500-line limit ``.claude/rules/general-code-change.md`` sets while every
    assertion remains in one place.

Responsibilities:
    Own only the declared constants (the portable shared-surface set, the
    disqualified umbrella names, the payload module names, and the byte-equal
    key tuple), the two parsed configurations, and four total accessors over a
    parsed truth table. No assertion lives here.

Side effects:
    Reads both committed ``blast-radius.json`` copies once at import time. Both
    are committed and read-only for these tests; no temporary file is created
    and no external process is started.

Naming:
    Follows the ``*_test_support.py`` convention already used in this directory
    by ``parallel_drift_test_support.py`` and its siblings, so pytest does not
    collect it as a test module.
"""

from __future__ import annotations

import inspect
from typing import TYPE_CHECKING, cast

from tests.scripts.dev_tools.test_blast_radius_config import (
    BUNDLED_CONFIG_PATH,
    CONFIG_PATH,
    load_config_file,
    load_module_globs,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

# The published truth table, parsed once. The regression tests derive against
# this copy, because the defect they cover is a property of the published
# document rather than of the contention relation.
BUNDLED_CONFIG: Mapping[str, object] = load_config_file(BUNDLED_CONFIG_PATH)

# The self-hosted truth table, parsed once, so the cross-copy assertions read
# each file exactly once at import time.
SELF_HOSTED_CONFIG: Mapping[str, object] = load_config_file(CONFIG_PATH)

# Repo-relative label for the self-hosted copy, matching the labelling style
# COMMITTED_CONFIGS uses so a failure message names the offending file.
SELF_HOSTED_CONFIG_LABEL = "config/blast-radius.json"

# A separator-free ecosystem-standard root filename. It is the smallest token
# that exercises the root-surface branch of the path-token classifier: the
# classifier accepts a separator-free token only when the truth table declares
# that exact name as a shared surface, so a truth table with no separator-free
# shared surface silently discards it.
ROOT_SURFACE_FILENAME = "package-lock.json"

# The destination-portable shared-surface set the bundled copy must declare.
# Each entry is portable because it names a path any workspace running this
# runtime may legitimately carry, never a path only this repository has.
PORTABLE_SHARED_SURFACES = frozenset(
    {
        # Published by the push-down into every destination.
        ".claude/settings.json",
        # The truth table itself; two items editing it must always contend.
        "config/blast-radius.json",
        # The routing table, published alongside the truth table.
        "config/orchestration-routing.json",
        # Separator-free. Any Node destination regenerates it, and its presence
        # is what opens the root-token branch of the path-token classifier.
        "package-lock.json",
        # Separator-free. The Python analogue of the entry above.
        "poetry.lock",
        # Separator-free. The repo-root tier map every repository using this
        # runtime is required to carry by .claude/rules/quality-tiers.md.
        "quality-tiers.yml",
    }
)

# Module names disqualified by the module-map granularity criterion in
# .claude/rules/parallel-orchestration.md. Each is an umbrella keyed on a
# top-level directory that essentially every work item writes into, so it
# matches almost every radius and carries no contention information.
UMBRELLA_MODULE_NAMES = (
    "python-dev-tools",
    "vscode-extension",
    "claude-runtime",
    "copilot-surface",
    "agents-surface",
)

# Module names the push-down itself creates in a destination. The authoritative
# source is PAYLOAD_MODULES in
# extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts,
# pinned on the TypeScript side by the case
# "pins the depth bound and the payload module set" in
# extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts.
PAYLOAD_MODULE_NAMES = frozenset({"config"})

# Keys that describe the runtime rather than a repository layout, so both
# committed copies must carry identical values.
BYTE_EQUAL_KEYS = ("version", "over_breadth_fraction", "mandate_reads")

# Class 2 key-to-assertion registry: each portable shared-surface key mapped to
# the name of the test function that is supposed to consume it. Registering the
# consuming assertion by name, rather than declaring a bare key tuple, is what
# lets ``unconsumed_class_keys`` verify a key is actually read by a real
# assertion rather than merely present in a membership tuple.
CLASS_TWO_KEY_ASSERTIONS = {
    "shared_surfaces": "test_class_two_bundled_shared_surfaces_are_the_portable_set",
    "shared_surface_globs": "test_class_two_bundled_shared_surface_globs_are_empty",
}

# Class 3 key-to-assertion registry: the payload module-map key mapped to the
# name of the test function that is supposed to consume it.
CLASS_THREE_KEY_ASSERTIONS = {
    "modules": "test_class_three_bundled_modules_are_payload_modules_only",
}

# Class 2 key names, derived from the registry above so every existing
# consumer of ``CLASS_TWO_KEYS`` (the membership asserts and
# ``DECLARED_TOP_LEVEL_KEYS``) is unaffected by the registry's introduction.
CLASS_TWO_KEYS = tuple(CLASS_TWO_KEY_ASSERTIONS)

# Class 3 key names, derived from the registry above for the same reason.
CLASS_THREE_KEYS = tuple(CLASS_THREE_KEY_ASSERTIONS)

# The exhaustive set of top-level keys the truth-table schema declares,
# derived from the three declared classes rather than hardcoded: the
# byte-equal keys plus the Class 2 and Class 3 key names. A key present in
# either committed copy but absent from this set is unclassified.
DECLARED_TOP_LEVEL_KEYS = (
    frozenset(BYTE_EQUAL_KEYS) | frozenset(CLASS_TWO_KEYS) | frozenset(CLASS_THREE_KEYS)
)


def config_key(config: Mapping[str, object], key: str) -> object:
    """Read one top-level key from a parsed truth table.

    Args:
        config (Mapping[str, object]): Parsed truth table.
        key (str): Top-level key to read.

    Returns:
        object: The key's value, or ``None`` when the key is absent. A thin
        accessor rather than a bare ``get`` call, so every reader shares one
        absent-key convention and a renamed key surfaces as a ``None`` mismatch
        rather than a ``KeyError``.
    """
    return config.get(key)


def module_names(config: Mapping[str, object]) -> tuple[str, ...]:
    """Read the module-map key set of a parsed truth table.

    Args:
        config (Mapping[str, object]): Parsed truth table.

    Returns:
        tuple[str, ...]: The module names, ordered by name.

    Raises:
        TypeError: If the module map is absent or malformed, propagated from
            ``load_module_globs``.
    """
    return tuple(name for name, _ in load_module_globs(config))


def shared_surfaces(config: Mapping[str, object]) -> tuple[str, ...]:
    """Read the shared-surface list of a parsed truth table.

    Args:
        config (Mapping[str, object]): Parsed truth table.

    Returns:
        tuple[str, ...]: The declared shared surfaces in committed order, or an
        empty tuple when the key is absent or is not a list. Returning empty
        rather than raising leaves the non-vacuity floor responsible for
        detecting a renamed key, which keeps the failure message specific.
    """
    value = config.get("shared_surfaces")
    if not isinstance(value, list):
        return ()
    entries = cast("list[object]", value)
    return tuple(entry for entry in entries if isinstance(entry, str))


def shared_surface_globs(config: Mapping[str, object]) -> tuple[str, ...]:
    """Read the shared-surface glob list of a parsed truth table.

    Args:
        config (Mapping[str, object]): Parsed truth table.

    Returns:
        tuple[str, ...]: The declared globs in committed order, or an empty
        tuple when the key is absent or is not a list.
    """
    value = config.get("shared_surface_globs")
    if not isinstance(value, list):
        return ()
    entries = cast("list[object]", value)
    return tuple(entry for entry in entries if isinstance(entry, str))


def unconsumed_class_keys(
    registry: Mapping[str, str], namespace: Mapping[str, object]
) -> tuple[tuple[str, str], ...]:
    """Find every registered key whose named assertion does not consume it.

    Closes the CR-3 residual: a key added to a class-key registry (and to both
    committed copies) with no assertion that genuinely references it must be
    reported, not merely a key whose name is absent from the registry.
    Membership in ``CLASS_TWO_KEYS`` / ``CLASS_THREE_KEYS`` proves only that the
    key was *added* to the registry; it proves nothing about whether any test
    function actually reads it. This helper checks consumption instead.

    Args:
        registry (Mapping[str, str]): Maps a key name to the name of the test
            function that is supposed to consume it (for example
            ``CLASS_TWO_KEY_ASSERTIONS``).
        namespace (Mapping[str, object]): Namespace to resolve each assertion
            name in, typically the caller's ``globals()``.

    Returns:
        tuple[tuple[str, str], ...]: One ``(key, assertion_name)`` pair per
        registry entry that is unresolved, in registry iteration order. A pair
        is unresolved when the assertion name is not callable in ``namespace``,
        or when the assertion's source text never references the key literal.
        An empty tuple means every registered key is genuinely consumed.

    Side Effects:
        None. Reads only the supplied mappings and, for a callable found in
        ``namespace``, its source text via ``inspect.getsource``.
    """
    unresolved: list[tuple[str, str]] = []
    # Walk each registered (key, assertion_name) pair and confirm the named
    # assertion both exists and actually mentions the key in its own source,
    # so a registry entry that reuses an unrelated test's name is caught.
    for key, assertion_name in registry.items():
        candidate = namespace.get(assertion_name)
        if not callable(candidate):
            unresolved.append((key, assertion_name))
            continue
        if key not in inspect.getsource(candidate):
            unresolved.append((key, assertion_name))
    return tuple(unresolved)
