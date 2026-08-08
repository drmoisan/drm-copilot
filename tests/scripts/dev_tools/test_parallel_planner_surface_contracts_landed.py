"""Landed-contract and F4-obligation tests for the parallel planning skill.

Split out of `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`
under the [P6-T3] conditional-split instruction so that neither test module
exceeds the repository's 500-line file-size limit, following the same convention
already applied in this feature to
`test_parallel_kickoff_contract.py` / `test_parallel_kickoff_contract_tables.py`.
The positive and negative surface scenarios stay in the first module, from which
the read helper and path constants are imported.

This module encodes two things the first module does not:

* The Phase 1 supersessions — the skill must cite the LANDED F1 and F2 contracts
  (`conflicts(a, b, config)`, `derive_blast_radius` over document text plus the
  parsed `config/blast-radius.json`, and the two-parameter `compute_cohorts`),
  not the spec's superseded `[ASSUMPTION]` phrasing.
* The F4-owned obligations that F3's landed rules file assigns to this planner
  surface: the cohort recomputation-parity check (F3 planner invariant P5) and
  the per-branch git-integrity verification.

Each guarantee is expressed as a small predicate over document text so the same
predicate can be asserted true against the delivered skill and false against an
in-memory counterexample, proving the assertion discriminates rather than
passing vacuously.
"""

from __future__ import annotations

from tests.scripts.dev_tools.test_parallel_planner_surface_contracts import (
    PARALLEL_PLAN_SKILL_RELATIVE,
    read_repo_text,
)

# Counterexample text carrying the superseded pre-Phase-1 phrasing. Every
# predicate below must reject it, which is what proves the predicate has teeth.
SUPERSEDED_SKILL_TEXT = """
Reach the blast-radius module with `python -m scripts.dev_tools.compute_blast_radius`
and the scheduler with `python -m scripts.dev_tools.parallel_cohort_computation`.
The contention relation is `conflicts(a, b)`. Derivation takes the plan path and
the spec path. Seeding calls `compute_cohorts(item_keys, conflict_edges, pinned)`
with an empty pinned set at seeding time. Git integrity is F3-owned, and the
kickoff contract module is an F3 recommendation pending a contingency.
"""


def skill_text() -> str:
    """Return the delivered parallel-plan skill document text.

    Returns:
        The UTF-8 text of `.claude/skills/parallel-plan/SKILL.md`.
    """

    return read_repo_text(PARALLEL_PLAN_SKILL_RELATIVE)


def states_three_argument_contention(text: str) -> bool:
    """Report whether the text cites the landed three-argument contention form.

    F1 landed `conflicts(a, b, config)`; the spec's superseded two-argument form
    `conflicts(a, b)` must be absent so the skill cannot mislead a caller into
    omitting the parsed truth table.

    Args:
        text: Document text to inspect.

    Returns:
        True when the three-argument form is present and the two-argument form
        is absent; False otherwise.
    """

    return "conflicts(a, b, config)" in text and "conflicts(a, b)" not in text


def states_import_only_upstream_invocation(text: str) -> bool:
    """Report whether the text avoids CLI-subprocess instructions for F1 and F2.

    Both upstream libraries landed import-only with no CLI entry point, so a
    `python -m` instruction against either would name an entry point that does
    not exist.

    Args:
        text: Document text to inspect.

    Returns:
        True when neither `python -m` module invocation appears.
    """

    return (
        "python -m scripts.dev_tools.compute_blast_radius" not in text
        and "python -m scripts.dev_tools.parallel_cohort_computation" not in text
    )


def states_two_parameter_cohort_seeding(text: str) -> bool:
    """Report whether the text cites the landed two-parameter seeding signature.

    F2 landed `compute_cohorts(item_keys, conflict_edges)` with no pinned-set
    parameter; recoloring state belongs to F6 and F8.

    Args:
        text: Document text to inspect.

    Returns:
        True when the two-parameter signature is present and no pinned-set
        reference appears.
    """

    return (
        "compute_cohorts(item_keys, conflict_edges)" in text
        and "pinned" not in text.lower()
    )


def states_derivation_over_document_text(text: str) -> bool:
    """Report whether the text cites the landed derivation inputs.

    `derive_blast_radius` takes document text plus the parsed
    `config/blast-radius.json`, never file paths.

    Args:
        text: Document text to inspect.

    Returns:
        True when the landed signature, the config file, and the explicit
        not-a-path statement are all present.
    """

    return (
        "derive_blast_radius(plan_text, spec_text, feature_folder, config, "
        "*, source, computed_at)" in text
        and "config/blast-radius.json" in text
        and "It does not take file paths" in text
    )


def states_recomputation_parity_obligation(text: str) -> bool:
    """Report whether the text documents the F4-owned parity check.

    F3 planner invariant P5 assigns recomputation parity to this planner
    surface. The procedure must re-invoke the library, order the check before
    kickoff emission, and treat a mismatch as Blocking.

    Args:
        text: Document text to inspect.

    Returns:
        True when the re-invocation step, the before-kickoff ordering, and the
        Blocking-on-mismatch rule are all present.
    """

    return (
        "re-invoke `compute_cohorts` over exactly the `item_keys` and "
        "`conflict_edges` recorded in the" in text
        and "**before** emitting the kickoff artifact" in text
        and "A mismatch is a **Blocking** condition" in text
    )


def states_git_integrity_is_f4_owned(text: str) -> bool:
    """Report whether the text attributes per-branch git integrity to F4.

    F3's `require_ready_for_execution` gate is structural only, so verifying
    committed plan blobs against each per-item branch ref is F4's obligation.

    Args:
        text: Document text to inspect.

    Returns:
        True when the F4 attribution and the per-item-branch scope are present.
    """

    return (
        "**Git integrity is F4-owned.**" in text
        and "Per-branch git-integrity requirement — F4-owned" in text
        and "against each per-item" in text
    )


def states_kickoff_contract_is_delivered_here(text: str) -> bool:
    """Report whether the text claims the kickoff contract as delivered by F4.

    The epic-manifest adjudication assigns the module and the artifact type to
    F4, so the skill must describe them as landed rather than as a pending F3
    recommendation.

    Args:
        text: Document text to inspect.

    Returns:
        True when the module, the artifact type, and the delivered-here framing
        are all present.
    """

    return (
        "scripts/dev_tools/parallel_kickoff_contract.py" in text
        and 'artifact_type: "parallel-kickoff"' in text
        and "are F4-owned and are **delivered by this feature**" in text
    )


def test_skill_cites_three_argument_contention_signature() -> None:
    """Require the landed `conflicts(a, b, config)` form and reject the old one."""

    assert states_three_argument_contention(skill_text())
    assert not states_three_argument_contention(SUPERSEDED_SKILL_TEXT)


def test_skill_uses_import_only_upstream_invocation() -> None:
    """Require no `python -m` CLI instruction for either upstream library."""

    assert states_import_only_upstream_invocation(skill_text())
    assert not states_import_only_upstream_invocation(SUPERSEDED_SKILL_TEXT)


def test_skill_cites_two_parameter_cohort_seeding_signature() -> None:
    """Require the landed seeding signature and no pinned-set reference."""

    assert states_two_parameter_cohort_seeding(skill_text())
    assert not states_two_parameter_cohort_seeding(SUPERSEDED_SKILL_TEXT)


def test_skill_cites_derivation_over_document_text() -> None:
    """Require derivation to be documented over text plus the parsed config."""

    assert states_derivation_over_document_text(skill_text())
    assert not states_derivation_over_document_text(SUPERSEDED_SKILL_TEXT)


def test_skill_documents_the_cohort_recomputation_parity_obligation() -> None:
    """Require the F4-owned recomputation-parity procedure (F3 invariant P5)."""

    assert states_recomputation_parity_obligation(skill_text())
    assert not states_recomputation_parity_obligation(SUPERSEDED_SKILL_TEXT)


def test_skill_attributes_git_integrity_verification_to_f4() -> None:
    """Require per-branch git-integrity verification to be attributed to F4."""

    assert states_git_integrity_is_f4_owned(skill_text())
    assert not states_git_integrity_is_f4_owned(SUPERSEDED_SKILL_TEXT)


def test_skill_claims_the_kickoff_contract_as_delivered_by_this_feature() -> None:
    """Require the kickoff module and artifact type to be framed as delivered."""

    assert states_kickoff_contract_is_delivered_here(skill_text())
    assert not states_kickoff_contract_is_delivered_here(SUPERSEDED_SKILL_TEXT)


def test_skill_cites_planner_invariant_p5_as_the_parity_basis() -> None:
    """Require the parity procedure to cite F3 planner invariant P5.

    Recording the basis keeps a later reader from deleting the check as
    redundant with the F3 validator, which deliberately omits it.
    """

    text = skill_text()

    assert "Planner invariant P5 in `.claude/rules/parallel-orchestration.md`" in text
    assert "deliberately absent from the" in text
