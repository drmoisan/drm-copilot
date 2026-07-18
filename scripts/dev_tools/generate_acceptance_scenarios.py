"""Deterministic, domain-neutral acceptance-scenario generator.

Transforms three discovery artifacts (Feature Contract, Parity Matrix, and
Runtime Characterization Scenario) into a single JSON acceptance-scenario-set
document. The transform is pure: identical inputs produce byte-identical output,
with no seeded RNG and no wall-clock read. ``source_digest`` is a SHA-256 over
the canonicalized inputs, never a clock value.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, Any, cast

if TYPE_CHECKING:
    from collections.abc import Sequence

GENERATOR_ID = "dev.discovery.acceptance-scenarios"
SCHEMA_VERSION = "v1"
SCHEMA_SELF_REF = "schemas/v1/acceptance-scenario-set.schema.json"


class GenerationError(Exception):
    """Raised when an input artifact is missing, malformed, or incomplete.

    A single, specific exception type lets the CLI entry point translate any
    expected failure into exit code 1 with a clear message.
    """


def resolve_discovery_schema(
    schema_name: str,
    *,
    root: Path,
    version: str | None = None,
) -> Path:
    """Return the filesystem path to a versioned discovery schema.

    Isolates all schema-location knowledge behind a single seam so this feature
    can proceed before feature #9002 lands. ``schema_name`` is a domain-neutral
    key such as ``feature-contract``. Until #9002 lands this raises
    ``FileNotFoundError`` whose message names the expected
    ``schemas/vN/<schema_name>.schema.json`` convention.
    """
    resolved_version = version or SCHEMA_VERSION
    expected = root / "schemas" / resolved_version / f"{schema_name}.schema.json"
    if expected.is_file():
        return expected
    raise FileNotFoundError(
        "Discovery schema tree is not present. Feature #9002 owns the schema "
        "definitions; the expected convention is "
        f"schemas/v<version>/{schema_name}.schema.json (resolved candidate: "
        f"{expected}). Supply explicit input paths on the command line until "
        "#9002 lands."
    )


def resolve_schema_self_ref(root: Path) -> str:
    """Return the ``$schema`` self-reference via the schema-location seam.

    Routes the ``$schema`` value through ``resolve_discovery_schema`` so
    downstream code never hard-codes a schema path. Before feature #9002 lands
    the seam raises and this falls back to the ``schemas/vN/`` convention string.
    """
    try:
        resolved = resolve_discovery_schema("acceptance-scenario-set", root=root)
    except FileNotFoundError:
        return SCHEMA_SELF_REF
    return resolved.as_posix()


@dataclass(frozen=True)
class FeatureContractProjection:
    """Read surface for the Feature Contract input."""

    feature_ref: str
    title: str
    given: tuple[str, ...] = ()
    when: tuple[str, ...] = ()
    then: tuple[str, ...] = ()
    evidence_refs: tuple[str, ...] = ()


@dataclass(frozen=True)
class ParityRow:
    """A single Parity Matrix row keyed to a feature."""

    parity_ref: str
    feature_ref: str
    then: tuple[str, ...] = ()
    evidence_refs: tuple[str, ...] = ()


@dataclass(frozen=True)
class ParityMatrixProjection:
    """Read surface for the Parity Matrix input."""

    rows: tuple[ParityRow, ...] = ()


@dataclass(frozen=True)
class CharacterizationScenario:
    """A single Runtime Characterization Scenario observation."""

    characterization_ref: str
    feature_ref: str
    given: tuple[str, ...] = ()
    when: tuple[str, ...] = ()
    evidence_refs: tuple[str, ...] = ()


@dataclass(frozen=True)
class RuntimeCharacterizationProjection:
    """Read surface for the Runtime Characterization Scenario input."""

    scenarios: tuple[CharacterizationScenario, ...] = ()


def _require_str(document: dict[str, Any], key: str, *, context: str) -> str:
    """Return a required non-empty string field or raise ``GenerationError``."""
    value = document.get(key)
    if not isinstance(value, str) or not value.strip():
        raise GenerationError(
            f"{context}: required field '{key}' is missing or not a non-empty string"
        )
    return value


def _string_tuple(document: dict[str, Any], key: str) -> tuple[str, ...]:
    """Return a tuple of strings for an optional array field, ignoring absence."""
    value = document.get(key, [])
    if not isinstance(value, list):
        return ()
    return tuple(str(item) for item in cast("list[Any]", value))


def project_feature_contract(document: dict[str, Any]) -> FeatureContractProjection:
    """Project a Feature Contract document onto the generator read surface.

    Unknown or extra keys are ignored so a #9002 field-name change touches only
    this adapter. Raises ``GenerationError`` when a required field is missing.
    """
    context = "feature contract"
    return FeatureContractProjection(
        feature_ref=_require_str(document, "feature_ref", context=context),
        title=_require_str(document, "title", context=context),
        given=_string_tuple(document, "given"),
        when=_string_tuple(document, "when"),
        then=_string_tuple(document, "then"),
        evidence_refs=_string_tuple(document, "evidence_refs"),
    )


def project_parity_matrix(document: dict[str, Any]) -> ParityMatrixProjection:
    """Project a Parity Matrix document onto the generator read surface.

    Unknown or extra keys are ignored. Raises ``GenerationError`` when a required
    field is missing or malformed.
    """
    raw_rows = document.get("rows", [])
    if not isinstance(raw_rows, list):
        raise GenerationError("parity matrix: required field 'rows' must be an array")
    rows: list[ParityRow] = []
    for index, raw_item in enumerate(cast("list[Any]", raw_rows)):
        if not isinstance(raw_item, dict):
            raise GenerationError(f"parity matrix: row {index} must be an object")
        raw = cast("dict[str, Any]", raw_item)
        context = f"parity matrix row {index}"
        rows.append(
            ParityRow(
                parity_ref=_require_str(raw, "parity_ref", context=context),
                feature_ref=_require_str(raw, "feature_ref", context=context),
                then=_string_tuple(raw, "then"),
                evidence_refs=_string_tuple(raw, "evidence_refs"),
            )
        )
    return ParityMatrixProjection(rows=tuple(rows))


def project_runtime_characterization(
    document: dict[str, Any],
) -> RuntimeCharacterizationProjection:
    """Project a Runtime Characterization document onto the read surface.

    Unknown or extra keys are ignored. Raises ``GenerationError`` when a required
    field is missing or malformed.
    """
    raw_scenarios = document.get("scenarios", [])
    if not isinstance(raw_scenarios, list):
        raise GenerationError(
            "runtime characterization: required field 'scenarios' must be an array"
        )
    scenarios: list[CharacterizationScenario] = []
    for index, raw_item in enumerate(cast("list[Any]", raw_scenarios)):
        if not isinstance(raw_item, dict):
            raise GenerationError(
                f"runtime characterization: scenario {index} must be an object"
            )
        raw = cast("dict[str, Any]", raw_item)
        context = f"runtime characterization scenario {index}"
        scenarios.append(
            CharacterizationScenario(
                characterization_ref=_require_str(
                    raw, "characterization_ref", context=context
                ),
                feature_ref=_require_str(raw, "feature_ref", context=context),
                given=_string_tuple(raw, "given"),
                when=_string_tuple(raw, "when"),
                evidence_refs=_string_tuple(raw, "evidence_refs"),
            )
        )
    return RuntimeCharacterizationProjection(scenarios=tuple(scenarios))


def derive_scenario_id(
    feature_ref: str,
    parity_ref: str | None,
    characterization_ref: str | None,
) -> str:
    """Derive a stable ``scn-<16 hex>`` identifier from input references only.

    Deterministic: no RNG and no wall-clock value participate, so identical
    inputs always yield the same identifier.
    """
    key = "|".join([feature_ref, parity_ref or "", characterization_ref or ""])
    digest = hashlib.sha256(key.encode("utf-8")).hexdigest()[:16]
    return f"scn-{digest}"


def _scenario_sort_key(scenario: dict[str, Any]) -> tuple[str, str, str, str]:
    """Return the stable total-order key for a scenario object."""
    return (
        str(scenario["feature_ref"]),
        str(scenario["parity_ref"] or ""),
        str(scenario["characterization_ref"] or ""),
        str(scenario["id"]),
    )


def assemble_scenarios(
    feature: FeatureContractProjection,
    parity_matrix: ParityMatrixProjection,
    characterization: RuntimeCharacterizationProjection,
) -> list[dict[str, Any]]:
    """Combine the three projections into scenario objects.

    Produces one scenario per applicable combination of parity row and
    characterization scenario for the feature. When no parity row or no
    characterization applies, the corresponding reference is ``None``. Each
    scenario carries ``id``, ``title``, ``feature_ref``, ``parity_ref``,
    ``characterization_ref``, ``given``, ``when``, ``then``, and ``evidence_refs``.
    """
    parity_rows = sorted(
        (row for row in parity_matrix.rows if row.feature_ref == feature.feature_ref),
        key=lambda row: row.parity_ref,
    )
    char_scenarios = sorted(
        (
            scenario
            for scenario in characterization.scenarios
            if scenario.feature_ref == feature.feature_ref
        ),
        key=lambda scenario: scenario.characterization_ref,
    )
    parity_options: list[ParityRow | None] = list(parity_rows) or [None]
    char_options: list[CharacterizationScenario | None] = list(char_scenarios) or [None]

    scenarios: list[dict[str, Any]] = []
    for parity_row in parity_options:
        for char_scenario in char_options:
            parity_ref = parity_row.parity_ref if parity_row is not None else None
            characterization_ref = (
                char_scenario.characterization_ref
                if char_scenario is not None
                else None
            )
            given = list(feature.given)
            when = list(feature.when)
            then = list(feature.then)
            evidence = list(feature.evidence_refs)
            if char_scenario is not None:
                given.extend(char_scenario.given)
                when.extend(char_scenario.when)
                evidence.extend(char_scenario.evidence_refs)
            if parity_row is not None:
                then.extend(parity_row.then)
                evidence.extend(parity_row.evidence_refs)
            scenarios.append(
                {
                    "id": derive_scenario_id(
                        feature.feature_ref, parity_ref, characterization_ref
                    ),
                    "title": feature.title,
                    "feature_ref": feature.feature_ref,
                    "parity_ref": parity_ref,
                    "characterization_ref": characterization_ref,
                    "given": given,
                    "when": when,
                    "then": then,
                    "evidence_refs": sorted(set(evidence)),
                }
            )
    return scenarios


def compute_source_digest(
    feature_doc: dict[str, Any],
    parity_doc: dict[str, Any],
    characterization_doc: dict[str, Any],
) -> str:
    """Return a 64-char SHA-256 hex digest over the canonicalized inputs.

    A deterministic content fingerprint that changes only when input content
    changes. This is never a clock value.
    """
    canonical = "".join(
        json.dumps(document, sort_keys=True, ensure_ascii=False)
        for document in (feature_doc, parity_doc, characterization_doc)
    )
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def build_document(
    feature_doc: dict[str, Any],
    parity_doc: dict[str, Any],
    characterization_doc: dict[str, Any],
    *,
    root: Path,
) -> dict[str, Any]:
    """Assemble the top-level acceptance-scenario-set document.

    Projects the three inputs, assembles and sorts the scenarios, and builds the
    document with ``$schema``, ``schema_version``, ``generator``,
    ``source_digest``, and ``scenarios``. Raises ``GenerationError`` when an input
    is missing a required field.
    """
    feature = project_feature_contract(feature_doc)
    parity = project_parity_matrix(parity_doc)
    characterization = project_runtime_characterization(characterization_doc)
    scenarios = sorted(
        assemble_scenarios(feature, parity, characterization),
        key=_scenario_sort_key,
    )
    return {
        "$schema": resolve_schema_self_ref(root),
        "schema_version": SCHEMA_VERSION,
        "generator": GENERATOR_ID,
        "source_digest": compute_source_digest(
            feature_doc, parity_doc, characterization_doc
        ),
        "scenarios": scenarios,
    }


def format_document(document: dict[str, Any]) -> str:
    """Serialize with sorted keys, two-space indent, and one trailing newline."""
    return json.dumps(document, sort_keys=True, indent=2, ensure_ascii=False) + "\n"


def collect_input_paths(paths: Sequence[str] | Sequence[Path]) -> list[Path]:
    """Return input paths sorted by POSIX string form.

    Ensures input-path processing order is stable across platforms and does not
    depend on filesystem ``glob``/``rglob`` yield order.
    """
    return sorted((Path(entry) for entry in paths), key=lambda entry: entry.as_posix())


def _load_json_document(path: Path, *, label: str) -> dict[str, Any]:
    """Read one existing input artifact, enforcing JSON parse and object root.

    Existence is validated by the caller (``_generate_from_args``). Raises
    ``GenerationError`` when the content does not parse as JSON or the root is
    not an object.
    """
    text = path.read_text(encoding="utf-8")
    try:
        parsed = json.loads(text)
    except json.JSONDecodeError as exc:
        raise GenerationError(f"{label}: invalid JSON in {path}: {exc}") from exc
    if not isinstance(parsed, dict):
        raise GenerationError(f"{label}: JSON root must be an object: {path}")
    return cast("dict[str, Any]", parsed)


def _generate_from_args(args: argparse.Namespace, *, root: Path) -> dict[str, Any]:
    """Load the three CLI-named inputs and build the document.

    Uses the stable sorted-path view for a deterministic missing-file diagnostic,
    then loads each artifact in its fixed positional role. Raises
    ``GenerationError`` when any input is missing, malformed, or incomplete.
    """
    ordered_paths = collect_input_paths(
        [args.feature_contract, args.parity_matrix, args.runtime_characterization]
    )
    for path in ordered_paths:
        if not path.is_file():
            raise GenerationError(f"input file not found: {path}")
    feature_doc = _load_json_document(
        Path(args.feature_contract), label="feature contract"
    )
    parity_doc = _load_json_document(Path(args.parity_matrix), label="parity matrix")
    characterization_doc = _load_json_document(
        Path(args.runtime_characterization), label="runtime characterization"
    )
    return build_document(feature_doc, parity_doc, characterization_doc, root=root)


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Parse CLI arguments into the input paths, ``output``, and ``check``."""
    parser = argparse.ArgumentParser(
        description=(
            "Generate a deterministic, domain-neutral acceptance-scenario-set "
            "document from discovery artifacts."
        )
    )
    parser.add_argument(
        "--feature-contract",
        required=True,
        help="Path to the Feature Contract input JSON.",
    )
    parser.add_argument(
        "--parity-matrix",
        required=True,
        help="Path to the Parity Matrix input JSON.",
    )
    parser.add_argument(
        "--runtime-characterization",
        required=True,
        help="Path to the Runtime Characterization Scenario input JSON.",
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Output path for the generated document; prints to stdout when omitted.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Assert the on-disk output matches regenerated output without writing.",
    )
    return parser.parse_args(list(argv) if argv is not None else None)


def _run_check(rendered: str, output: str | None) -> int:
    """Return ``0`` when the on-disk document matches regenerated output, else ``1``."""
    if output is None:
        print("error: --check requires --output", file=sys.stderr)
        return 1
    output_path = Path(output)
    if not output_path.is_file():
        print(f"error: --check target does not exist: {output_path}", file=sys.stderr)
        return 1
    existing = output_path.read_text(encoding="utf-8")
    if existing != rendered:
        print(f"error: --check mismatch: {output_path} is out of date", file=sys.stderr)
        return 1
    print(f"ok: {output_path} matches regenerated output")
    return 0


def main(argv: Sequence[str] | None = None) -> int:
    """CLI entry point: ``0`` on success; ``1`` on any failure."""
    args = parse_args(argv or sys.argv[1:])
    root = Path(__file__).resolve().parents[2]

    try:
        document = _generate_from_args(args, root=root)
    except GenerationError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    rendered = format_document(document)

    if args.check:
        return _run_check(rendered, args.output)

    if args.output:
        Path(args.output).write_text(rendered, encoding="utf-8")
        print(f"ok: wrote {args.output}")
    else:
        sys.stdout.write(rendered)
    return 0


if __name__ == "__main__":
    sys.exit(main())
