"""Preserve legacy text validators through the authoritative offline runtime.

Existing calls select frozen v1 explicitly. A trusted caller may request v2 with
schema_version; artifact metadata never selects a weaker or remote validator.
cache_dir remains accepted for source compatibility and is never read or written.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from drm_copilot_discovery.catalog import load_catalog
from drm_copilot_discovery.schema_validation import validate_document

if TYPE_CHECKING:
    from collections.abc import Mapping

_DEFAULT_CACHE_DIR = Path(".cache/schemas")


def load_schema(uri: str, cache_dir: Path = _DEFAULT_CACHE_DIR) -> dict[str, object]:
    """Resolve registered offline aliases only; preserve the unused cache argument."""
    del cache_dir
    return load_catalog().schema_for_alias(_extract_schema_uri({"$schema": uri}))


def _extract_schema_uri(data: Mapping[str, object]) -> str:
    """Retain metadata inspection compatibility without granting schema authority."""
    schema_value = data.get("$schema")
    if not isinstance(schema_value, str) or not schema_value:
        raise ValueError("missing $schema")
    return schema_value


def _validate_against_schema(
    text: str,
    artifact_type: str,
    *,
    cache_dir: Path = _DEFAULT_CACHE_DIR,
    schema_version: str = "1.0.0",
) -> list[str]:
    """Return authoritative diagnostics while retaining text-wrapper call shapes."""
    del cache_dir
    kind = (
        "runtime-characterization-scenario"
        if artifact_type == "runtime-scenario"
        else artifact_type
    )
    result = validate_document(
        text, expected_kind=kind, expected_version=schema_version
    )
    # Preserve the legacy list-of-errors API while using authoritative finding codes.
    return [
        f"{finding.code} {finding.pointer}: {finding.message}"
        for finding in result.findings
        if finding.severity == "error"
    ]


def validate_feature_contract_text(
    text: str,
    *,
    cache_dir: Path = _DEFAULT_CACHE_DIR,
    schema_version: str = "1.0.0",
) -> list[str]:
    """Validate expected feature-contract text; v1 success is compatibility-only."""
    return _validate_against_schema(
        text, "feature-contract", cache_dir=cache_dir, schema_version=schema_version
    )


def validate_coverage_ledger_text(
    text: str,
    *,
    cache_dir: Path = _DEFAULT_CACHE_DIR,
    schema_version: str = "1.0.0",
) -> list[str]:
    """Validate expected coverage-ledger text; v1 success is compatibility-only."""
    return _validate_against_schema(
        text, "coverage-ledger", cache_dir=cache_dir, schema_version=schema_version
    )


def validate_runtime_scenario_text(
    text: str,
    *,
    cache_dir: Path = _DEFAULT_CACHE_DIR,
    schema_version: str = "1.0.0",
) -> list[str]:
    """Validate expected runtime-scenario text; v1 success is compatibility-only."""
    return _validate_against_schema(
        text, "runtime-scenario", cache_dir=cache_dir, schema_version=schema_version
    )


def validate_parity_matrix_text(
    text: str,
    *,
    cache_dir: Path = _DEFAULT_CACHE_DIR,
    schema_version: str = "1.0.0",
) -> list[str]:
    """Validate expected parity-matrix text; v1 success is compatibility-only."""
    return _validate_against_schema(
        text, "parity-matrix", cache_dir=cache_dir, schema_version=schema_version
    )


def validate_unspecified_behavior_text(
    text: str,
    *,
    cache_dir: Path = _DEFAULT_CACHE_DIR,
    schema_version: str = "1.0.0",
) -> list[str]:
    """Validate expected unspecified-behavior text; v1 success is compatibility-only."""
    return _validate_against_schema(
        text, "unspecified-behavior", cache_dir=cache_dir, schema_version=schema_version
    )


def validate_product_decision_text(
    text: str,
    *,
    cache_dir: Path = _DEFAULT_CACHE_DIR,
    schema_version: str = "1.0.0",
) -> list[str]:
    """Validate expected product-decision text; v1 success is compatibility-only."""
    return _validate_against_schema(
        text, "product-decision", cache_dir=cache_dir, schema_version=schema_version
    )


def validate_evidence_reference_text(
    text: str,
    *,
    cache_dir: Path = _DEFAULT_CACHE_DIR,
    schema_version: str = "1.0.0",
) -> list[str]:
    """Validate expected evidence-reference text; v1 success is compatibility-only."""
    return _validate_against_schema(
        text, "evidence-reference", cache_dir=cache_dir, schema_version=schema_version
    )
