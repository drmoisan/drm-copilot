"""Forward generation to the installed captured-workspace acceptance service.

Historical values and pure utilities remain nonauthoritative compatibility data.
They establish no schema validity, v2 identity, readiness or publication grant.
The old three-document placeholder shape cannot supply a validated snapshot.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

from drm_copilot_discovery.cli import run_installed_cli

if TYPE_CHECKING:
    from collections.abc import Sequence

# Historical labels remain import-compatible; no schema is emitted from them.
GENERATOR_ID = "dev.discovery.acceptance-scenarios"
SCHEMA_VERSION = "v1"
SCHEMA_SELF_REF = "schemas/v1/acceptance-scenario-set.schema.json"
_MIGRATION = (
    "Legacy placeholder generation is unsupported. Use "
    "dev.discovery.generate-acceptance-scenarios --workspace-root <root> "
    "--profile <relative-profile> --repository-id <id> with configured v2 "
    "artifacts. Read-only --check is not --dry-run and establishes no readiness."
)


class GenerationError(Exception):
    """Reject unsupported legacy generation without reads or input mutation.

    Catch this historical exception type to display fixed migration guidance.
    It carries no schema, validation result, or publication authority.
    """


def resolve_discovery_schema(
    schema_name: str, *, root: Path, version: str | None = None
) -> Path:
    """Refuse checkout schema selection without probing its filesystem.

    Args:
        schema_name (str): Historical name; never used for lookup.
        root (Path): Historical checkout location; never inspected.
        version (str | None): Historical selector; never grants authority.
    Returns:
        Path: Never returned; the import-compatible signature remains.
    Raises:
        GenerationError: Always, with installed-command migration guidance.
    Effects:
        None; existing checkout schemas cannot enable this unsupported path.
    """
    raise GenerationError(_MIGRATION)


def resolve_schema_self_ref(root: Path) -> str:
    """Refuse the fabricated schema fallback without filesystem access.

    Args:
        root (Path): Historical checkout hint; never inspected.
    Returns:
        str: Never returned; no substitute schema reference is fabricated.
    Raises:
        GenerationError: Always, directing callers to installed generation.
    Effects:
        None.
    """
    raise GenerationError(_MIGRATION)


@dataclass(frozen=True)
class FeatureContractProjection:
    """Retain feature fields as frozen, nonauthoritative compatibility data.

    Construct from strings/tuples; fields are retained without interpretation,
    validation, I/O or generation. These values do not establish v2 provenance.
    """

    feature_ref: str
    title: str
    given: tuple[str, ...] = ()
    when: tuple[str, ...] = ()
    then: tuple[str, ...] = ()
    evidence_refs: tuple[str, ...] = ()


@dataclass(frozen=True)
class ParityRow:
    """Retain a historical row without asserting target equivalence.

    Construct from strings/tuples; frozen fields are neither interpreted nor
    verified. No I/O, mutable state or generation authority is introduced.
    """

    parity_ref: str
    feature_ref: str
    then: tuple[str, ...] = ()
    evidence_refs: tuple[str, ...] = ()


@dataclass(frozen=True)
class ParityMatrixProjection:
    """Store historical rows without validation, readiness or side effects.

    Construct from a row tuple; this frozen carrier neither traverses nor
    interprets its values and cannot authorize generation.
    """

    rows: tuple[ParityRow, ...] = ()


@dataclass(frozen=True)
class CharacterizationScenario:
    """Retain observation fields without claiming verified runtime evidence.

    Construct from strings/tuples; frozen values are not interpreted or linked.
    No I/O, validation, approval or scenario generation occurs.
    """

    characterization_ref: str
    feature_ref: str
    given: tuple[str, ...] = ()
    when: tuple[str, ...] = ()
    evidence_refs: tuple[str, ...] = ()


@dataclass(frozen=True)
class RuntimeCharacterizationProjection:
    """Store historical observations without evaluating their authority.

    Construct from a scenario tuple; this frozen carrier performs no traversal,
    generation or side effects and cannot establish accepted runtime evidence.
    """

    scenarios: tuple[CharacterizationScenario, ...] = ()


def project_feature_contract(document: dict[str, object]) -> FeatureContractProjection:
    """Reject placeholder projection without reading or mutating input fields.

    Args:
        document (dict[str, object]): Untrusted historical feature fields.
    Returns:
        FeatureContractProjection: Never returned from unsupported context.
    Raises:
        GenerationError: Always; use a configured captured workspace instead.
    Effects:
        None.
    """
    raise GenerationError(_MIGRATION)


def project_parity_matrix(document: dict[str, object]) -> ParityMatrixProjection:
    """Reject placeholder parity projection without assuming target readiness.

    Args:
        document (dict[str, object]): Untrusted historical parity fields.
    Returns:
        ParityMatrixProjection: Never returned from unsupported context.
    Raises:
        GenerationError: Always; use the installed generation command.
    Effects:
        None; inputs remain unexamined and unchanged.
    """
    raise GenerationError(_MIGRATION)


def project_runtime_characterization(
    document: dict[str, object],
) -> RuntimeCharacterizationProjection:
    """Reject placeholder observations without inventing evidence or approvals.

    Args:
        document (dict[str, object]): Untrusted historical observation fields.
    Returns:
        RuntimeCharacterizationProjection: Never returned from this context.
    Raises:
        GenerationError: Always; use the installed generation command.
    Effects:
        None; inputs are not traversed or mutated.
    """
    raise GenerationError(_MIGRATION)


def derive_scenario_id(
    feature_ref: str, parity_ref: str | None, characterization_ref: str | None
) -> str:
    """Preserve the historical hash utility, which is not a v2 scenario identity.

    Args:
        feature_ref (str): Historical feature token.
        parity_ref (str | None): Historical parity token; None becomes empty.
        characterization_ref (str | None): Historical observation token.
    Returns:
        str: Stable scn- prefix plus sixteen hexadecimal characters.
    Effects:
        None; no clock, randomness, validation or readiness claim participates.
    """
    key = "|".join([feature_ref, parity_ref or "", characterization_ref or ""])
    digest = hashlib.sha256(key.encode("utf-8")).hexdigest()[:16]
    return f"scn-{digest}"


def assemble_scenarios(
    feature: FeatureContractProjection,
    parity_matrix: ParityMatrixProjection,
    characterization: RuntimeCharacterizationProjection,
) -> list[dict[str, object]]:
    """Reject assembly because historical carriers lack a validated snapshot.

    Args:
        feature (FeatureContractProjection): Non-authoritative feature fields.
        parity_matrix (ParityMatrixProjection): Historical unverified rows.
        characterization (RuntimeCharacterizationProjection): Unverified fields.
    Returns:
        list[dict[str, object]]: Never returned; no scenarios are invented.
    Raises:
        GenerationError: Always, with actionable installed-command guidance.
    Effects:
        None; the carriers are not inspected, expanded or mutated.
    """
    raise GenerationError(_MIGRATION)


def compute_source_digest(
    feature_doc: dict[str, object],
    parity_doc: dict[str, object],
    characterization_doc: dict[str, object],
) -> str:
    """Preserve a pure historical hash without claiming a v2 input digest.

    Args:
        feature_doc (dict[str, object]): JSON-serializable feature data.
        parity_doc (dict[str, object]): JSON-serializable parity data.
        characterization_doc (dict[str, object]): Serializable observation data.
    Returns:
        str: Lowercase 64-character SHA-256 over ordered canonical documents.
    Raises:
        TypeError, ValueError: JSON cannot represent the supplied data.
    Effects:
        None; dictionary keys are sorted without modifying inputs.
    """
    # Preserve document roles while ignoring irrelevant dictionary key ordering.
    canonical = "".join(
        json.dumps(document, sort_keys=True, ensure_ascii=False)
        for document in (feature_doc, parity_doc, characterization_doc)
    )
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def build_document(
    feature_doc: dict[str, object],
    parity_doc: dict[str, object],
    characterization_doc: dict[str, object],
    *,
    root: Path,
) -> dict[str, object]:
    """Reject placeholder generation before reads, interpretation or publication.

    Args:
        feature_doc (dict[str, object]): Historical feature data.
        parity_doc (dict[str, object]): Historical parity data.
        characterization_doc (dict[str, object]): Unverified observation fields.
        root (Path): Checkout hint; never inspected or used for schema lookup.
    Returns:
        dict[str, object]: Never returned; use the authoritative installed CLI.
    Raises:
        GenerationError: Always, with configured-workspace migration guidance.
    Effects:
        None; no fallback scenarios, schemas, approvals or files are produced.
    """
    raise GenerationError(_MIGRATION)


def format_document(document: dict[str, object]) -> str:
    """Serialize historical data deterministically without endorsing its content.

    Args:
        document (dict[str, object]): JSON-serializable compatibility data.
    Returns:
        str: Sorted keys, two-space indentation, Unicode and one final LF.
    Raises:
        TypeError, ValueError: JSON cannot represent the supplied data.
    Effects:
        None; does not validate, generate, write or mutate the document.
    """
    return json.dumps(document, sort_keys=True, indent=2, ensure_ascii=False) + "\n"


def collect_input_paths(paths: Sequence[str] | Sequence[Path]) -> list[Path]:
    """Sort historical path values without resolving, reading or granting access.

    Args:
        paths (Sequence[str] | Sequence[Path]): Legacy path values.
    Returns:
        list[Path]: New list sorted by POSIX spelling; duplicates remain.
    Effects:
        None; filesystem existence and authorization remain unexamined.
    """
    # Retain portable ordering independently of filesystem enumeration.
    return sorted((Path(entry) for entry in paths), key=lambda entry: entry.as_posix())


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Retain legacy argument inspection only; canonical main never calls this.

    Args:
        argv (Sequence[str] | None): Historical tokens, or process arguments.
    Returns:
        argparse.Namespace: Raw input paths, output and check metadata.
    Raises:
        SystemExit: Argparse help or malformed legacy inspection arguments.
    Effects:
        Argparse may emit help/errors, but never reads or writes input files.
        Successful inspection supplies no generation or readiness authority.
    """
    parser = argparse.ArgumentParser(description=_MIGRATION)
    parser.add_argument("--feature-contract", required=True)
    parser.add_argument("--parity-matrix", required=True)
    parser.add_argument("--runtime-characterization", required=True)
    parser.add_argument("--output", default=None)
    parser.add_argument("--check", action="store_true")
    return parser.parse_args(list(argv) if argv is not None else None)


def main(argv: Sequence[str] | None = None) -> int:
    """Forward canonical arguments to the installed acceptance command unchanged.

    Args:
        argv (Sequence[str] | None): Canonical tokens; None uses process argv.
    Returns:
        int: Installed CLI status 0, 1, 2 or 3; no independent success decision.
    Effects:
        Installed CLI owns parsing, streams, validation and guarded publication.
        Unsupported legacy flags fail before workspace effects.
    """
    return run_installed_cli("generate-acceptance-scenarios", argv)


if __name__ == "__main__":
    raise SystemExit(main())
