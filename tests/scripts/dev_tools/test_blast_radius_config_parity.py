"""Two-copy key-partition contract for the blast-radius truth table.

The blast-radius truth table is committed twice: ``config/blast-radius.json``
governs this repository, and
``extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json``
is published into a destination workspace by the Claude push-down. The two
copies are not interchangeable, and neither plain byte-equality nor unconstrained
independence is the right relation between them. This module pins the
three-class partition that is correct (issue #500):

* **Class 1 — byte-equal.** ``version``, ``over_breadth_fraction``, and
  ``mandate_reads`` describe the runtime, not a repository layout, so the two
  copies must agree exactly.
* **Class 2 — portable subset.** ``shared_surfaces`` and
  ``shared_surface_globs`` in the bundled copy are the destination-portable
  subset of the self-hosted sets, never a copy of them.
* **Class 3 — payload subset.** The bundled ``modules`` key set is a subset of
  the payload module names declared by the TypeScript push-down.

The module also carries the two regression tests for the defect that motivated
the partition, one per failure direction, and the umbrella-denylist,
separator-free, non-vacuity, and parse-and-version assertions that keep the two
copies honest.

The gate lives here rather than in ``test_blast_radius_config.py`` because that
module stands at 499 of the 500 lines ``.claude/rules/general-code-change.md``
permits and cannot receive one additional line. The shared helpers are imported
from it rather than duplicated, following the two-copy config-parity naming
convention already used by ``test_orchestration_routing_config_parity.py``.

Reading the committed configurations is the point of these tests. No temporary
file is created and no external process is started.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.compute_blast_radius import conflicts, derive_blast_radius
from tests.scripts.dev_tools.blast_radius_parity_test_support import (
    BUNDLED_CONFIG,
    BYTE_EQUAL_KEYS,
    CLASS_THREE_KEY_ASSERTIONS,
    CLASS_THREE_KEYS,
    CLASS_TWO_KEY_ASSERTIONS,
    CLASS_TWO_KEYS,
    DECLARED_TOP_LEVEL_KEYS,
    PAYLOAD_MODULE_NAMES,
    PORTABLE_SHARED_SURFACES,
    ROOT_SURFACE_FILENAME,
    SELF_HOSTED_CONFIG,
    SELF_HOSTED_CONFIG_LABEL,
    UMBRELLA_MODULE_NAMES,
    config_key,
    module_names,
    shared_surface_globs,
    shared_surfaces,
    unconsumed_class_keys,
)
from tests.scripts.dev_tools.test_blast_radius_config import (
    BUNDLED_CONFIG_LABEL,
    COMMITTED_CONFIGS,
    load_config_file,
)

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.compute_blast_radius import BlastRadius, ConflictResult

# Timestamp handed to every derived radius below. A constant rather than a clock
# read, so the derivation tests are deterministic.
COMPUTED_AT = "2026-08-15T09-48"


def derive_bundled_radius(feature_folder: str, plan_text: str) -> BlastRadius:
    """Derive one work item's radius against the published truth table.

    Args:
        feature_folder (str): Bare feature-folder name. Callers pass distinct
            names so the radii carry distinct feature-folder globs, making the
            verdict depend on the truth table rather than on a shared document
            tree.
        plan_text (str): Approved-plan text citing paths in inline code.

    Returns:
        BlastRadius: The derived radius, with a fixed timestamp.

    Side Effects:
        None beyond the module-level read of the committed configuration.
    """
    return derive_blast_radius(
        plan_text, "", feature_folder, BUNDLED_CONFIG, computed_at=COMPUTED_AT
    )


def reason_pairs(result: ConflictResult) -> tuple[tuple[str, str], ...]:
    """Read every triggered contention reason as a kind and detail pair.

    Args:
        result (ConflictResult): Verdict returned by ``conflicts``.

    Returns:
        tuple[tuple[str, str], ...]: One ``(kind, detail)`` pair per reason, in
        the fixed order the relation reports them. Returning pairs rather than
        bare kinds lets a presence assertion name both halves of the reason it
        expected, which is what makes the failure message actionable.
    """
    return tuple((reason.kind, reason.detail) for reason in result.reasons)


def test_unrelated_claude_citations_do_not_contend_under_the_bundled_table() -> None:
    """Reject a published module map that makes unrelated agent work contend.

    Fail-closed direction. Two work items whose plans cite different files under
    the ``.claude`` tree — one a hook, one a skill document — have nothing in
    common but the runtime directory they live in. Every agent in the runtime is
    instructed to read the policy rules and process skills before doing any
    work, so a ``.claude/**`` umbrella module matches nearly every radius: it
    carries no contention information and only suppresses concurrency. The pair
    must therefore schedule together.
    """
    # Arrange: two items whose only structural similarity is the runtime tree.
    hook_item = derive_bundled_radius(
        "2026-08-21-example-hook-item",
        "- [ ] [P1-T1] Edit `.claude/hooks/enforce-mermaid-validation.ps1`.",
    )
    skill_item = derive_bundled_radius(
        "2026-08-21-example-skill-item",
        "- [ ] [P1-T1] Edit `.claude/skills/parallel-add/SKILL.md`.",
    )

    # Act: ask the contention relation whether the two items may run together.
    result = conflicts(hook_item, skill_item, BUNDLED_CONFIG)

    # Assert: no disjunct may fire. The reason tuple is reported in the failure
    # message so a regression names the level that forced the false contention.
    assert result.conflict is False, (
        "Two items citing unrelated .claude files must not contend under the "
        f"published truth table; observed reasons {reason_pairs(result)}."
    )


def test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table() -> (
    None
):
    """Require contention for two items editing the same root build file.

    Fail-open direction. A separator-free root filename such as
    ``package-lock.json`` is accepted by the path-token classifier only when the
    truth table declares that exact name as a shared surface. A published table
    carrying no separator-free shared surface therefore discards the token
    entirely, and two items that both rewrite the lockfile are scheduled
    concurrently even though they cannot both merge cleanly.
    """
    # Arrange: two items with distinct feature folders citing the same root file.
    citation = f"- [ ] [P1-T1] Regenerate `{ROOT_SURFACE_FILENAME}`."
    left_item = derive_bundled_radius("2026-08-21-example-lock-left", citation)
    right_item = derive_bundled_radius("2026-08-21-example-lock-right", citation)

    # Act: ask the contention relation whether the two items may run together.
    result = conflicts(left_item, right_item, BUNDLED_CONFIG)

    # Assert: the pair must contend, and the shared-surface level specifically
    # must fire. Presence is asserted over the reason collection rather than
    # equality over the whole tuple, because a corrected table also reports a
    # path_overlap reason for the same token, and a tuple-equality assertion
    # would then fail against the fixed state.
    observed = reason_pairs(result)
    assert result.conflict is True, (
        "Two items editing the same separator-free root surface must contend "
        f"under the published truth table; observed reasons {observed}."
    )
    assert ("shared_surface_overlap", ROOT_SURFACE_FILENAME) in observed, (
        "A shared_surface_overlap reason naming "
        f"{ROOT_SURFACE_FILENAME} must be present; observed reasons {observed}."
    )


@pytest.mark.parametrize("key", BYTE_EQUAL_KEYS)
def test_class_one_keys_are_equal_across_both_committed_copies(key: str) -> None:
    """Require byte-equality for the keys that describe the runtime.

    Class 1. ``version``, ``over_breadth_fraction``, and ``mandate_reads``
    describe the runtime rather than any repository's directory layout, so the
    two copies must agree exactly. This closes the failure mode structurally: an
    addition to one copy's ``mandate_reads`` cannot land without the same
    addition to the other.
    """
    # Arrange / Act: read the same key from each parsed copy.
    self_hosted_value = config_key(SELF_HOSTED_CONFIG, key)
    bundled_value = config_key(BUNDLED_CONFIG, key)

    # Assert: the failure message names both repo-relative labels so a
    # maintainer knows which pair of files disagreed.
    assert self_hosted_value == bundled_value, (
        f"Key {key!r} must be equal across the two committed copies. "
        f"{SELF_HOSTED_CONFIG_LABEL} declares {self_hosted_value!r}; "
        f"{BUNDLED_CONFIG_LABEL} declares {bundled_value!r}."
    )


def test_every_top_level_key_is_classified_and_shared_by_both_copies() -> None:
    """Require every top-level key to be shared by both copies and classified.

    Exhaustiveness check closing the key-set gap the three declared classes
    leave open by construction: each class asserts a property of the keys it
    names, but none of them asserts that the two copies' key *sets* are
    identical or that every key belongs to a declared class. A key added to
    one copy only is caught by the first assertion below; a key added to both
    copies but claimed by none of Class 1, Class 2, or Class 3 is caught by
    the second. ``DECLARED_TOP_LEVEL_KEYS`` is derived from ``BYTE_EQUAL_KEYS``
    plus the Class 2 and Class 3 key names, not hardcoded, so it stays in sync
    with the declared classes above.
    """
    # Arrange / Act: read each copy's top-level key set.
    self_hosted_keys = frozenset(SELF_HOSTED_CONFIG.keys())
    bundled_keys = frozenset(BUNDLED_CONFIG.keys())

    # Assert: the two copies must declare exactly the same key set. The
    # failure message names the symmetric difference so a maintainer knows
    # which key is missing from which copy.
    assert self_hosted_keys == bundled_keys, (
        f"{SELF_HOSTED_CONFIG_LABEL} and {BUNDLED_CONFIG_LABEL} must declare "
        "the same top-level key set; symmetric difference "
        f"{sorted(self_hosted_keys ^ bundled_keys)}."
    )

    # Assert: every declared key, across both copies, must be claimed by one
    # of the three declared classes. The failure message names any
    # unclassified key.
    all_keys = self_hosted_keys | bundled_keys
    unclassified = sorted(all_keys - DECLARED_TOP_LEVEL_KEYS)
    assert not unclassified, (
        "Every top-level key in either committed copy must be classified by "
        f"DECLARED_TOP_LEVEL_KEYS; unclassified keys {unclassified}."
    )


def test_class_two_bundled_shared_surfaces_are_the_portable_set() -> None:
    """Require the bundled shared surfaces to equal the portable set.

    Class 2. Portable-set equality plus a subset relation against the
    self-hosted list is the correct gate for this key, not byte-equality: the
    bundled sets were authored narrow when the copy was created and were never a
    copy of the self-hosted set that fell behind. Equality against a declared
    constant fails on drift in either direction: a silently dropped entry and a
    silently added drm-copilot-specific entry both break it.
    """
    assert "shared_surfaces" in CLASS_TWO_KEYS

    # Arrange / Act
    bundled = frozenset(shared_surfaces(BUNDLED_CONFIG))
    self_hosted = frozenset(shared_surfaces(SELF_HOSTED_CONFIG))

    # Assert: equality against the declared portable set, then containment in
    # the self-hosted set. The second assertion is not implied by the first: it
    # states that no portable entry is unknown to this repository's own table.
    assert bundled == PORTABLE_SHARED_SURFACES, (
        f"{BUNDLED_CONFIG_LABEL} shared_surfaces must equal the declared "
        f"portable set. Missing: {sorted(PORTABLE_SHARED_SURFACES - bundled)}; "
        f"unexpected: {sorted(bundled - PORTABLE_SHARED_SURFACES)}."
    )
    assert bundled <= self_hosted, (
        f"{BUNDLED_CONFIG_LABEL} shared_surfaces must be a subset of "
        f"{SELF_HOSTED_CONFIG_LABEL}; observed extra entries "
        f"{sorted(bundled - self_hosted)}."
    )


def test_class_two_bundled_shared_surface_globs_are_empty() -> None:
    """Require the bundled shared-surface glob list to be empty.

    Class 2, second key. Every self-hosted glob is a ``scripts/dev_tools``
    pattern naming this repository's own Python dev-tooling module families, so
    none of them describes any destination. An empty list is correct rather than
    merely tolerable, because a glob is never a source of root-token acceptance.
    """
    assert "shared_surface_globs" in CLASS_TWO_KEYS

    # Arrange / Act
    bundled = shared_surface_globs(BUNDLED_CONFIG)
    self_hosted = frozenset(shared_surface_globs(SELF_HOSTED_CONFIG))

    # Assert: emptiness, then the subset relation the empty set satisfies
    # vacuously today but which keeps holding force if the key is ever filled.
    assert bundled == (), (
        f"{BUNDLED_CONFIG_LABEL} shared_surface_globs must be empty; observed "
        f"{list(bundled)}."
    )
    assert frozenset(bundled) <= self_hosted, (
        f"{BUNDLED_CONFIG_LABEL} shared_surface_globs must be a subset of "
        f"{SELF_HOSTED_CONFIG_LABEL}; observed extra entries "
        f"{sorted(frozenset(bundled) - self_hosted)}."
    )


def test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle() -> None:
    """Require every separator-free self-hosted surface to reach the bundle.

    Directional invariant closing the residual Class 2 gap (issue #500
    remediation). Portable-set equality against ``PORTABLE_SHARED_SURFACES``
    and the ``bundled <= self_hosted`` subset relation together do not observe
    the self-hosted copy gaining a portable separator-free surface that never
    reaches the bundle: both checks are satisfied by a bundled set that stays
    fixed while the self-hosted set grows. This test asserts the reverse
    containment restricted to separator-free entries, so a self-hosted
    separator-free addition that is never carried into the bundled copy fails
    loudly instead of passing silently.
    """
    # Arrange: select the separator-free entries from each committed copy,
    # since only a separator-free entry is accepted by the root-token
    # extractor and therefore only a separator-free omission is a live gap.
    self_hosted_separator_free = frozenset(
        entry for entry in shared_surfaces(SELF_HOSTED_CONFIG) if "/" not in entry
    )
    bundled_separator_free = frozenset(
        entry for entry in shared_surfaces(BUNDLED_CONFIG) if "/" not in entry
    )

    # Assert: every self-hosted separator-free entry must also appear in the
    # bundled separator-free set. The failure message names the missing
    # entries and both config labels so a maintainer knows which copy to
    # amend.
    missing = sorted(self_hosted_separator_free - bundled_separator_free)
    assert not missing, (
        f"{SELF_HOSTED_CONFIG_LABEL} separator-free shared_surfaces entries "
        f"{missing} are missing from {BUNDLED_CONFIG_LABEL} separator-free "
        "shared_surfaces; every portable separator-free self-hosted surface "
        "must reach the bundled copy."
    )


def test_class_three_bundled_modules_are_payload_modules_only() -> None:
    """Require the bundled module map to name payload modules only.

    Class 3. A destination's module map is derived from the destination's own
    layout by ``assembleModules``, which never reads this key, so the only
    module name that legitimately appears here is one the push-down itself
    creates. A subset relation rather than equality is asserted because
    shrinking the payload set must not require editing this test in lockstep.
    """
    assert "modules" in CLASS_THREE_KEYS

    # Arrange / Act
    bundled = frozenset(module_names(BUNDLED_CONFIG))

    # Assert
    assert bundled <= PAYLOAD_MODULE_NAMES, (
        f"{BUNDLED_CONFIG_LABEL} modules must be a subset of the payload module "
        f"set {sorted(PAYLOAD_MODULE_NAMES)}; observed extra names "
        f"{sorted(bundled - PAYLOAD_MODULE_NAMES)}."
    )


def test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion() -> (  # noqa: E501
    None
):
    """Require every Class 2 and Class 3 key to be consumed, not merely present.

    Closes the CR-3 residual (cycle 4, R1): a key added to a registry and to
    both committed copies, with no assertion that genuinely references it,
    previously passed silently because the only check was membership in
    ``CLASS_TWO_KEYS`` / ``CLASS_THREE_KEYS`` — a tuple the key was just added
    to. ``unconsumed_class_keys`` checks consumption instead. The three
    existing membership lines are left unchanged; this adds a check.
    """
    # Check both registries against this module's namespace, where the
    # registered assertion functions live.
    unresolved = unconsumed_class_keys(
        CLASS_TWO_KEY_ASSERTIONS, globals()
    ) + unconsumed_class_keys(CLASS_THREE_KEY_ASSERTIONS, globals())
    assert not unresolved, (
        "Every Class 2 and Class 3 registry key must be consumed by its "
        f"registered assertion; unresolved pairs {unresolved}."
    )


@pytest.mark.parametrize(("label", "path"), COMMITTED_CONFIGS)
def test_no_committed_copy_declares_an_umbrella_module(label: str, path: Path) -> None:
    """Reject a disqualified umbrella module in either committed truth table.

    Extends the existing two-name location-bucket pin to the five umbrella names
    issue #489 removed, and applies it to both copies rather than to the
    self-hosted one only. An umbrella keyed on a top-level directory that
    essentially every item writes into matches almost every radius, so a level
    that always fires carries no information and only suppresses concurrency.
    """
    # Arrange: read the copy under test rather than a module-level constant, so
    # the parametrized failure names the offending file.
    names = frozenset(module_names(load_config_file(path)))

    # Assert: collect every disqualified name so the message can list all of
    # them rather than stopping at the first.
    offenders = sorted(names & frozenset(UMBRELLA_MODULE_NAMES))
    assert (
        not offenders
    ), f"{label} must declare no disqualified umbrella module; observed {offenders}."


def test_every_separator_free_bundled_shared_surface_is_wildcard_free() -> None:
    """Reject a wildcard in a separator-free bundled shared surface.

    A separator-free entry is the sole gate on whether the path-token extractor
    accepts a separator-free token. A wildcard-bearing separator-free entry
    would be admitted by the root-surface accessor yet classified as a glob,
    which silently breaks root-token extraction for every destination.
    """
    # Arrange: select the separator-free entries.
    separator_free = tuple(
        entry for entry in shared_surfaces(BUNDLED_CONFIG) if "/" not in entry
    )

    # Assert: the selection must be non-empty, otherwise the loop below would
    # pass vacuously while the fail-open defect remained.
    assert separator_free, (
        f"{BUNDLED_CONFIG_LABEL} must declare at least one separator-free "
        "shared surface, otherwise no destination can detect two items editing "
        "the same root build file."
    )
    # Check every separator-free entry so the failure names the offending value.
    for entry in separator_free:
        assert "*" not in entry and "?" not in entry, (
            f"{BUNDLED_CONFIG_LABEL} separator-free shared surface {entry!r} "
            "must contain no wildcard character."
        )


def test_the_gate_compares_non_empty_collections() -> None:
    """Reject a renamed key that would make the gate pass vacuously.

    Non-vacuity floor. Every accessor above returns an empty collection for an
    absent or malformed key, so a rename could turn a subset or equality
    assertion into one that holds trivially. This case states that each
    collection the gate compares and intends to be non-empty is in fact
    non-empty, and that the parametrized cases cover exactly two copies.

    Most tested cells are pre-empted upstream by ``require_string_list`` and
    ``load_module_globs`` (from ``test_blast_radius_config.py``) raising
    ``TypeError``; only the remaining states reach this assertion directly.
    """
    # Arrange: name each collection so the failure identifies which one emptied.
    populated: dict[str, tuple[str, ...] | frozenset[str]] = {
        f"{SELF_HOSTED_CONFIG_LABEL} shared_surfaces": shared_surfaces(
            SELF_HOSTED_CONFIG
        ),
        f"{BUNDLED_CONFIG_LABEL} shared_surfaces": shared_surfaces(BUNDLED_CONFIG),
        f"{SELF_HOSTED_CONFIG_LABEL} modules": module_names(SELF_HOSTED_CONFIG),
        f"{BUNDLED_CONFIG_LABEL} modules": module_names(BUNDLED_CONFIG),
        "PORTABLE_SHARED_SURFACES": PORTABLE_SHARED_SURFACES,
        "PAYLOAD_MODULE_NAMES": PAYLOAD_MODULE_NAMES,
    }

    # Assert: the parametrized cases must cover both committed copies and no
    # more, so a dropped entry cannot silently narrow their scope.
    assert len(COMMITTED_CONFIGS) == 2, (
        "COMMITTED_CONFIGS must hold exactly the two committed copies; observed "
        f"{[label for label, _ in COMMITTED_CONFIGS]}."
    )
    # Every named collection must be non-empty for the comparisons above to
    # carry discriminating force.
    for name, collection in populated.items():
        assert collection, f"{name} must be non-empty for the gate to discriminate."

    # mandate_reads is checked separately because it is compared by equality
    # rather than by containment, and an equality of two empty lists would hold.
    for label, config in (
        (SELF_HOSTED_CONFIG_LABEL, SELF_HOSTED_CONFIG),
        (BUNDLED_CONFIG_LABEL, BUNDLED_CONFIG),
    ):
        mandate_reads = config_key(config, "mandate_reads")
        assert isinstance(mandate_reads, list) and mandate_reads, (
            f"{label} mandate_reads must be a non-empty list; observed "
            f"{mandate_reads!r}."
        )


@pytest.mark.parametrize(("label", "path"), COMMITTED_CONFIGS)
def test_every_committed_copy_parses_and_declares_schema_version_one(
    label: str, path: Path
) -> None:
    """Require both committed copies to parse and declare schema version one.

    Extends the existing self-hosted-only version pin to the bundled copy. A
    published document that does not parse, or that declares a version the
    library does not implement, is a defect a destination cannot diagnose.
    """
    # Arrange / Act: load_config_file raises TypeError on a non-object root, so
    # a successful call is itself the parse assertion.
    config = load_config_file(path)

    # Assert
    assert isinstance(config, dict), f"{label} must parse to a JSON object."
    observed_version = config_key(config, "version")
    assert (
        observed_version == 1
    ), f"{label} must declare schema version 1; observed {observed_version!r}."
