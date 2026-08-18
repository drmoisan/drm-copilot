"""Input guards, truth-table resolution, and the V1-V3 blast-radius validators.

Purpose and responsibilities:
    Carry the validation half of the facade
    ``scripts/dev_tools/compute_blast_radius.py``. This module guards
    caller-supplied values, reads the truth table ``config/blast-radius.json``,
    resolves path entries to modules and concrete paths to shared surfaces, and
    emits the V1, V2, and V3 findings. Building radius objects and deciding
    contention belong to the facade and its contention helper.

Usage:
    The facade re-exports ``RadiusFinding`` and ``validate_blast_radius``, and
    calls ``resolve_modules`` and ``resolve_shared_surfaces`` during derivation;
    that sharing keeps a derived radius passing its own V1 and V2.

Invariants, constraints, and side effects:
    Returned collections are deduplicated and ordinally sorted. Findings are
    sorted by rule then subject, at most one per rule per subject; V1 and V2 are
    Blocking, V3 Advisory with at most one finding. The PowerShell mirror
    reproduces these rules; this module is the authoritative reference. Every
    function is pure and mutates no input: no filesystem, subprocess, network,
    or wall-clock access.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, cast

from scripts.dev_tools._blast_radius_extraction import extract_plan_paths
from scripts.dev_tools._blast_radius_glob import (
    concrete_entries,
    is_path_subsumed,
    matches_glob,
)
from scripts.dev_tools._blast_radius_guards import (
    require_mapping as require_mapping,
)
from scripts.dev_tools._blast_radius_guards import (
    require_str_tuple as require_str_tuple,
)
from scripts.dev_tools._blast_radius_guards import (
    require_text as require_text,
)
from scripts.dev_tools._blast_radius_thresholds import config_over_breadth_fraction

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

    from scripts.dev_tools.compute_blast_radius import BlastRadius

# Finding vocabulary. These strings are contract literals consumed by the
# downstream parallel schema and planner features, so they are named constants.
RULE_COVERAGE = "V1"
RULE_SHARED_SURFACE = "V2"
RULE_OVER_BREADTH = "V3"
SEVERITY_BLOCKING = "Blocking"
SEVERITY_ADVISORY = "Advisory"
FINDING_RULES: tuple[str, ...] = (RULE_COVERAGE, RULE_SHARED_SURFACE, RULE_OVER_BREADTH)
FINDING_SEVERITIES: tuple[str, ...] = (SEVERITY_BLOCKING, SEVERITY_ADVISORY)

# Keys read from the parsed ``config/blast-radius.json`` truth table.
CONFIG_SHARED_SURFACES = "shared_surfaces"
CONFIG_SHARED_SURFACE_GLOBS = "shared_surface_globs"
CONFIG_MODULES = "modules"
CONFIG_MANDATE_READS = "mandate_reads"


@dataclass(frozen=True)
class RadiusFinding:
    """Immutable record of one blast-radius validation failure.

    Reports a single rule violation against a single subject; the emitting rule
    chooses the severity and callers decide whether a Blocking finding stops
    work. Validation constructs one instance per uncovered plan path (V1), per
    unenumerated shared surface (V2), and at most one for an over-broad radius
    (V3). Construction checks both vocabularies; the instance is frozen and has
    no side effects.

    Attributes:
        rule (str): Rule identifier: ``V1``, ``V2``, or ``V3``.
        severity (str): ``Blocking`` for V1 and V2, ``Advisory`` for V3.
        subject (str): The path, surface, or radius level the finding is about.
        message (str): Literal human-readable explanation.
    """

    rule: str
    severity: str
    subject: str
    message: str

    def __post_init__(self) -> None:
        """Reject any finding outside the frozen rule and severity vocabulary.

        Returns:
            None.

        Raises:
            ValueError: If ``rule`` or ``severity`` is outside its vocabulary,
                or ``subject`` or ``message`` is blank.
        """
        # Membership doubles as a type check: a non-string value can never be a
        # member of either vocabulary tuple.
        if self.rule not in FINDING_RULES:
            raise ValueError(f"RadiusFinding rule must be one of {FINDING_RULES}.")
        if self.severity not in FINDING_SEVERITIES:
            raise ValueError(
                f"RadiusFinding severity must be one of {FINDING_SEVERITIES}."
            )
        require_text(self.subject, "RadiusFinding.subject")
        require_text(self.message, "RadiusFinding.message")


def config_string_list(config: Mapping[str, object], key: str) -> tuple[str, ...]:
    """Read an optional list-of-strings entry from the truth table.

    Args:
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
        key (str): Truth-table key to read.

    Returns:
        tuple[str, ...]: Entries sorted and deduplicated; an absent key yields
        an empty tuple so a minimal config stays usable.

    Raises:
        TypeError: If the entry is present but is not a list of strings.
        ValueError: If an entry is blank.
    """
    value = config.get(key)
    if value is None:
        return ()
    return require_str_tuple(value, f'config["{key}"]')


def config_root_surfaces(config: Mapping[str, object]) -> tuple[str, ...]:
    """Read the separator-free subset of the configured shared surfaces.

    This is the sole source of separator-free path acceptance (issue #452). The
    extraction layer has no access to the truth table, so both entry points that
    must agree — ``derive_blast_radius`` and ``validate_blast_radius`` — call
    this reader on the same ``config`` mapping and forward the result. Deriving
    the set from ``config["shared_surfaces"]`` rather than a second hardcoded
    list is what keeps extraction and surface resolution from desynchronizing.

    Args:
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
            Only the ``shared_surfaces`` key is read; ``shared_surface_globs``
            is deliberately not a source, because a glob can never be an exact
            token match.

    Returns:
        tuple[str, ...]: The entries of ``config["shared_surfaces"]`` that carry
        no ``/``, sorted and deduplicated. A config with no ``shared_surfaces``
        key yields an empty tuple, which reproduces pre-change behaviour.

    Raises:
        TypeError: If ``shared_surfaces`` is present but is not a list of
            strings.
        ValueError: If a ``shared_surfaces`` entry is blank.

    Side Effects:
        None; the input mapping is not mutated.
    """
    listed = config_string_list(config, CONFIG_SHARED_SURFACES)

    # Keep only the entries a token could match exactly. A surface carrying a
    # separator is already reachable through the ordinary path-shape rules, so
    # admitting it here would widen nothing; a separator-free surface is the
    # only kind the classifier's separator test made unreachable.
    return tuple(surface for surface in listed if "/" not in surface)


def config_mandate_reads(config: Mapping[str, object]) -> tuple[str, ...]:
    """Read the read-by-mandate exclusion list from the truth table.

    Mandate reads are the paths every agent is instructed to read before doing
    any work: policy rules, the tier map, and the process artifacts. A citation
    of one of them in a plan is evidence that the author obeyed the reading
    order, not evidence that the change will write the file, so these entries
    are excluded from derived contention (issue #489). Both entry points that
    must agree — ``derive_blast_radius`` and ``validate_blast_radius`` — call
    this reader on the same ``config`` mapping and forward the result.

    Args:
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
            Only the ``mandate_reads`` key is read. Entries may be exact paths
            or ``**`` subtree globs.

    Returns:
        tuple[str, ...]: The entries of ``config["mandate_reads"]``, sorted and
        deduplicated. A config with no ``mandate_reads`` key yields an empty
        tuple, which excludes nothing and reproduces pre-change behaviour.

    Raises:
        TypeError: If ``mandate_reads`` is present but is not a list of
            strings.
        ValueError: If a ``mandate_reads`` entry is blank.

    Side Effects:
        None; the input mapping is not mutated.
    """
    return config_string_list(config, CONFIG_MANDATE_READS)


def config_modules(
    config: Mapping[str, object],
) -> tuple[tuple[str, tuple[str, ...]], ...]:
    """Read the module map from the truth table as ordered name/glob pairs.

    Args:
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.

    Returns:
        tuple[tuple[str, tuple[str, ...]], ...]: Each module name paired with
        its glob tuple, ordered by name; an absent key yields an empty tuple.

    Raises:
        TypeError: If the entry is not a mapping of names to string lists.
        ValueError: If a module name or glob is blank.
    """
    value = config.get(CONFIG_MODULES)
    if value is None:
        return ()

    # Validate each module as it is read so a malformed truth table fails at the
    # first offending module rather than producing a partial resolution.
    module_map = require_mapping(value, f'config["{CONFIG_MODULES}"]')
    pairs: list[tuple[str, tuple[str, ...]]] = []
    for name, globs in module_map.items():
        module = require_text(name, f'config["{CONFIG_MODULES}"] key')
        pairs.append((module, require_str_tuple(globs, f'config["modules"][{module}]')))

    return tuple(sorted(pairs))


def resolve_modules(
    path_entries: Sequence[str], config: Mapping[str, object]
) -> tuple[str, ...]:
    """Resolve path entries to the module names of the truth-table map.

    Args:
        path_entries (Sequence[str]): Concrete paths and globs of a radius.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.

    Returns:
        tuple[str, ...]: Matched module names, deduplicated and ordinally
        sorted. A path matching no glob resolves to no module.

    Raises:
        TypeError: If the truth table's module map is malformed.
    """
    # A module joins the radius as soon as one of its globs covers one entry, so
    # the search stops at the first hit per module.
    matched: set[str] = set()
    for module, globs in config_modules(config):
        if any(
            matches_glob(pattern, entry) for pattern in globs for entry in path_entries
        ):
            matched.add(module)

    return tuple(sorted(matched))


def resolve_shared_surfaces(
    concrete_paths: Sequence[str], config: Mapping[str, object]
) -> tuple[str, ...]:
    """Select the concrete paths that are shared surfaces.

    Args:
        concrete_paths (Sequence[str]): Wildcard-free paths of a radius or plan.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.

    Returns:
        tuple[str, ...]: Touched surfaces, deduplicated and ordinally sorted.

    Raises:
        TypeError: If either truth-table surface entry is malformed.
    """
    listed = set(config_string_list(config, CONFIG_SHARED_SURFACES))
    surface_globs = config_string_list(config, CONFIG_SHARED_SURFACE_GLOBS)

    # Membership has two independent sources: the literal truth-table list and
    # the membership globs. A glob hit counts even when the path is absent from
    # the literal list, which is the fail-closed direction.
    touched: set[str] = set()
    for path in concrete_paths:
        if path in listed or any(
            matches_glob(pattern, path) for pattern in surface_globs
        ):
            touched.add(path)

    return tuple(sorted(touched))


def validate_blast_radius(
    radius: BlastRadius,
    plan_text: str,
    config: Mapping[str, object],
    *,
    tracked_file_count: int,
) -> list[RadiusFinding]:
    """Apply validation rules V1, V2, and V3 to a radius against its plan.

    Args:
        radius (BlastRadius): Radius under validation; its collections are taken
            at face value and never rebuilt here.
        plan_text (str): Approved atomic-plan text the radius claims to cover.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
        tracked_file_count (int): Files tracked in the repository, a caller
            input so the library performs no subprocess call.

    Returns:
        list[RadiusFinding]: Findings sorted by rule then subject; an empty list
        means the radius is valid.

    Raises:
        TypeError: If an argument or the truth table has a wrong type.
        ValueError: If ``tracked_file_count`` is not positive.
    """
    require_text(plan_text, "plan_text", allow_empty=True)

    # The root-surface set comes from the same ``config`` mapping that V1 and V2
    # use below to resolve modules and shared surfaces, and from the same reader
    # ``derive_blast_radius`` calls. That shared source is what keeps a derived
    # radius passing V1 and V2 against its own plan (issue #452).
    plan_concrete = concrete_entries(
        extract_plan_paths(plan_text, root_surfaces=config_root_surfaces(config))
    )

    findings: list[RadiusFinding] = list(_coverage_findings(radius, plan_concrete))
    findings.extend(_shared_surface_findings(radius, plan_concrete, config))
    findings.extend(
        _over_breadth_findings(radius, config, tracked_file_count=tracked_file_count)
    )

    # Sorting by rule then subject makes the finding list deterministic, which
    # the parity corpus and downstream planner records both depend on.
    findings.sort(key=lambda finding: (finding.rule, finding.subject))
    return findings


def _coverage_findings(
    radius: BlastRadius, plan_concrete: Sequence[str]
) -> tuple[RadiusFinding, ...]:
    """Emit rule V1 findings for plan paths the radius does not cover.

    Args:
        radius (BlastRadius): Radius whose ``paths`` must subsume the plan.
        plan_concrete (Sequence[str]): Concrete paths extracted from the plan.

    Returns:
        tuple[RadiusFinding, ...]: One Blocking finding per uncovered path.
    """
    # Coverage is subsumption, not equality: an exact entry, a listed directory,
    # or a glob in the radius all cover a plan path.
    findings: list[RadiusFinding] = []
    for path in plan_concrete:
        if not is_path_subsumed(path, radius.paths):
            findings.append(
                RadiusFinding(
                    rule=RULE_COVERAGE,
                    severity=SEVERITY_BLOCKING,
                    subject=path,
                    message=f"Plan path {path} is not subsumed by blast_radius.paths.",
                )
            )

    return tuple(findings)


def _shared_surface_findings(
    radius: BlastRadius, plan_concrete: Sequence[str], config: Mapping[str, object]
) -> tuple[RadiusFinding, ...]:
    """Emit rule V2 findings for touched shared surfaces left unenumerated.

    Args:
        radius (BlastRadius): Radius that must name every touched surface
            explicitly by concrete path in ``shared_surfaces``.
        plan_concrete (Sequence[str]): Concrete plan paths, included so a radius
            covering a surface only by glob is still caught.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.

    Returns:
        tuple[RadiusFinding, ...]: One Blocking finding per unenumerated surface.

    Raises:
        TypeError: If the truth-table surface entries are malformed.
    """
    touched_source = tuple(concrete_entries(radius.paths)) + tuple(plan_concrete)
    declared = set(radius.shared_surfaces)

    # Enumeration is exact-path membership. Glob coverage in either ``paths`` or
    # ``shared_surfaces`` is deliberately insufficient, so a surface reachable
    # only through a wildcard still produces a finding.
    findings: list[RadiusFinding] = []
    for surface in resolve_shared_surfaces(touched_source, config):
        if surface not in declared:
            findings.append(
                RadiusFinding(
                    rule=RULE_SHARED_SURFACE,
                    severity=SEVERITY_BLOCKING,
                    subject=surface,
                    message=(
                        f"Shared surface {surface} is touched but is not "
                        f"enumerated in blast_radius.shared_surfaces."
                    ),
                )
            )

    return tuple(findings)


def _over_breadth_findings(
    radius: BlastRadius, config: Mapping[str, object], *, tracked_file_count: int
) -> tuple[RadiusFinding, ...]:
    """Emit the single rule V3 finding when a radius is over-broad.

    Args:
        radius (BlastRadius): Radius whose concrete coverage is measured.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.
        tracked_file_count (int): Files tracked in the repository.

    Returns:
        tuple[RadiusFinding, ...]: At most one Advisory finding. An over-broad
        radius is safe but serializes the batch, so the rule only reports.

    Raises:
        TypeError: If ``tracked_file_count`` or the threshold has a wrong type.
        ValueError: If ``tracked_file_count`` or the threshold is out of range.
    """
    # Widening to ``object`` keeps the runtime guard meaningful for callers whose
    # value arrives from parsed JSON, where the declared type is not enforced.
    supplied_count = cast("object", tracked_file_count)
    if isinstance(supplied_count, bool) or not isinstance(supplied_count, int):
        raise TypeError("tracked_file_count must be an integer.")
    if tracked_file_count <= 0:
        raise ValueError("tracked_file_count must be a positive integer.")

    # The threshold is applied by multiplication rather than division so the
    # boundary is exact: a radius sitting exactly at the fraction does not
    # trigger, and the PowerShell mirror computes the identical comparison.
    threshold = config_over_breadth_fraction(config)
    covered = len(concrete_entries(radius.paths))
    if covered <= threshold * tracked_file_count:
        return ()

    return (
        RadiusFinding(
            rule=RULE_OVER_BREADTH,
            severity=SEVERITY_ADVISORY,
            subject="blast_radius.paths",
            message=(
                f"Radius covers {covered} of {tracked_file_count} tracked files, "
                f"which exceeds the configured over-breadth fraction."
            ),
        ),
    )
