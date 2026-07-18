"""Typed, fail-fast loader for the domain-neutral discovery profile.

Purpose:
    Parse a repository-local domain-profile configuration document (default
    filename ``discovery-profile.yaml``) into a frozen, fully typed
    ``DomainProfile`` dataclass graph. The loader validates shape and types
    only; it does not check that declared paths exist. Domain specificity is
    runtime configuration read from the profile, never hardcoded here.

Responsibilities:
    - Isolate the untyped ``yaml.safe_load`` boundary in a single helper that
      narrows the result to a string-keyed mapping and rejects non-mapping and
      syntactically invalid documents.
    - Walk the mapping section-by-section, collecting every field defect
      (missing required field, wrong type, empty string, empty list, unknown
      key, unsupported ``profile_version``) into one actionable error.
    - Provide a thin I/O wrapper (``load_domain_profile``) that reads a file and
      delegates to the pure text parser.

Invariants / Constraints:
    - The parse layer performs no I/O; all filesystem access is confined to
      ``load_domain_profile``.
    - Only ``profile_version`` equal to the integer ``1`` is accepted.
    - Each dataclass re-asserts its local invariants in ``__post_init__`` so a
      direct constructor call cannot produce an invalid instance.

Side Effects:
    ``load_domain_profile`` reads a single file from disk. No other side
    effects; no logging, telemetry, or global state.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

import yaml

from scripts.dev_tools.discovery.domain_profile_models import (
    ArtifactsConfig,
    DomainProfile,
    DomainProfileError,
    LegacySourceConfig,
    TargetConfig,
    TechnologyStackConfig,
)

if TYPE_CHECKING:
    from pathlib import Path

DEFAULT_PROFILE_FILENAME = "discovery-profile.yaml"

# Allowed key sets for strict, fail-fast typo protection.
_TOP_LEVEL_KEYS = frozenset(
    {
        "profile_version",
        "profile_name",
        "legacy_source",
        "target",
        "technology_stack",
        "artifacts",
    }
)
_LEGACY_SOURCE_KEYS = frozenset({"root", "description", "include", "exclude"})
_TARGET_KEYS = frozenset({"root", "description"})
_TECHNOLOGY_STACK_KEYS = frozenset({"legacy", "target"})
_ARTIFACTS_KEYS = frozenset({"root", "conventions"})

# Sentinel distinguishing an absent key from a present ``None`` value.
_MISSING = object()


def _type_name(value: object) -> str:
    """Return a friendly type name for an error message."""
    if value is _MISSING:
        return "missing value"
    return type(value).__name__


def _get(mapping: dict[str, object], key: str) -> object:
    """Return ``mapping[key]`` or the ``_MISSING`` sentinel when absent."""
    return mapping.get(key, _MISSING)


def _load_yaml_mapping(text: str, source: str) -> dict[str, object]:
    """Parse YAML text into a string-keyed mapping (the untyped seam).

    This is the only place ``yaml.safe_load`` is called. It narrows the
    ``Any`` result to ``dict[str, object]`` and rejects empty documents,
    non-mapping documents, and non-string top-level keys.

    Args:
        text: Raw YAML document text.
        source: Label naming the document origin (path or ``<string>``).

    Returns:
        The document as a string-keyed mapping.

    Raises:
        DomainProfileError: On YAML syntax errors, an empty document, a
            non-mapping top-level document, or non-string top-level keys.
    """
    try:
        raw = yaml.safe_load(text)
    except yaml.YAMLError as exc:
        raise DomainProfileError(f"{source}: YAML syntax error: {exc}") from exc
    if raw is None:
        raise DomainProfileError(f"{source}: profile document is empty")
    if not isinstance(raw, dict):
        raise DomainProfileError(
            f"{source}: expected a mapping at the top level, got {_type_name(raw)}"
        )
    raw_items = cast("dict[object, object]", raw)
    narrowed: dict[str, object] = {}
    for key, value in raw_items.items():
        if not isinstance(key, str):
            raise DomainProfileError(
                f"{source}: top-level keys must be strings, got {_type_name(key)}"
            )
        narrowed[key] = value
    return narrowed


def _require_mapping(
    value: object, path: str, errors: list[str]
) -> dict[str, object] | None:
    """Narrow ``value`` to a string-keyed mapping, recording defects."""
    if value is _MISSING:
        errors.append(f"{path}: required field is missing")
        return None
    if not isinstance(value, dict):
        errors.append(f"{path}: expected a mapping, got {_type_name(value)}")
        return None
    mapping_items = cast("dict[object, object]", value)
    narrowed: dict[str, object] = {}
    for key, item in mapping_items.items():
        if not isinstance(key, str):
            errors.append(
                f"{path}: mapping keys must be strings, got {_type_name(key)}"
            )
            continue
        narrowed[key] = item
    return narrowed


def _require_str(value: object, path: str, errors: list[str]) -> str:
    """Narrow ``value`` to a non-empty string, recording defects."""
    if value is _MISSING:
        errors.append(f"{path}: required field is missing")
        return ""
    if not isinstance(value, str):
        errors.append(f"{path}: expected non-empty string, got {_type_name(value)}")
        return ""
    if not value.strip():
        errors.append(f"{path}: expected non-empty string, got empty string")
        return ""
    return value


def _optional_str(value: object, path: str, errors: list[str]) -> str | None:
    """Narrow ``value`` to an optional string, recording type defects."""
    if value is _MISSING:
        return None
    if not isinstance(value, str):
        errors.append(f"{path}: expected string, got {_type_name(value)}")
        return None
    return value


def _str_list(
    value: object, path: str, errors: list[str], *, required: bool
) -> tuple[str, ...]:
    """Narrow ``value`` to a tuple of non-empty strings, recording defects."""
    if value is _MISSING:
        if required:
            errors.append(f"{path}: required field is missing")
        return ()
    if not isinstance(value, list):
        errors.append(
            f"{path}: expected a list of non-empty strings, got {_type_name(value)}"
        )
        return ()
    if required and not value:
        errors.append(f"{path}: expected a non-empty list, got empty list")
        return ()
    elements = cast("list[object]", value)
    items: list[str] = []
    for index, element in enumerate(elements):
        if not isinstance(element, str) or not element.strip():
            errors.append(
                f"{path}[{index}]: expected non-empty string, got {_type_name(element)}"
            )
            continue
        items.append(element)
    return tuple(items)


def _optional_str_pairs(
    value: object, path: str, errors: list[str]
) -> tuple[tuple[str, str], ...]:
    """Narrow ``value`` to ordered non-empty ``(key, value)`` string pairs."""
    if value is _MISSING:
        return ()
    if not isinstance(value, dict):
        errors.append(f"{path}: expected a mapping, got {_type_name(value)}")
        return ()
    convention_items = cast("dict[object, object]", value)
    pairs: list[tuple[str, str]] = []
    for key, item in convention_items.items():
        if not isinstance(key, str) or not key.strip():
            errors.append(
                f"{path}: convention keys must be non-empty strings, "
                f"got {_type_name(key)}"
            )
            continue
        if not isinstance(item, str) or not item.strip():
            errors.append(
                f"{path}.{key}: expected non-empty string, got {_type_name(item)}"
            )
            continue
        pairs.append((key, item))
    return tuple(pairs)


def _require_profile_version(value: object, path: str, errors: list[str]) -> int:
    """Narrow ``value`` to the supported integer profile version."""
    if value is _MISSING:
        errors.append(f"{path}: required field is missing")
        return 1
    if isinstance(value, bool) or not isinstance(value, int):
        errors.append(f"{path}: expected integer 1, got {_type_name(value)}")
        return 1
    if value != 1:
        errors.append(
            f"{path}: unsupported profile_version {value!r}; only 1 is accepted"
        )
        return 1
    return value


def _reject_unknown_keys(
    mapping: dict[str, object],
    allowed: frozenset[str],
    prefix: str,
    errors: list[str],
) -> None:
    """Record an error for each key not in ``allowed``."""
    allowed_list = ", ".join(sorted(allowed))
    for key in mapping:
        if key not in allowed:
            errors.append(f"{prefix}{key}: unknown key; allowed keys: {allowed_list}")


def _parse_legacy_source(value: object, errors: list[str]) -> LegacySourceConfig | None:
    """Parse the ``legacy_source`` section, returning ``None`` on any defect."""
    mapping = _require_mapping(value, "legacy_source", errors)
    if mapping is None:
        return None
    before = len(errors)
    _reject_unknown_keys(mapping, _LEGACY_SOURCE_KEYS, "legacy_source.", errors)
    root = _require_str(_get(mapping, "root"), "legacy_source.root", errors)
    description = _optional_str(
        _get(mapping, "description"), "legacy_source.description", errors
    )
    include = _str_list(
        _get(mapping, "include"), "legacy_source.include", errors, required=False
    )
    exclude = _str_list(
        _get(mapping, "exclude"), "legacy_source.exclude", errors, required=False
    )
    if len(errors) > before:
        return None
    return LegacySourceConfig(
        root=root, description=description, include=include, exclude=exclude
    )


def _parse_target(value: object, errors: list[str]) -> TargetConfig | None:
    """Parse the ``target`` section, returning ``None`` on any defect."""
    mapping = _require_mapping(value, "target", errors)
    if mapping is None:
        return None
    before = len(errors)
    _reject_unknown_keys(mapping, _TARGET_KEYS, "target.", errors)
    root = _require_str(_get(mapping, "root"), "target.root", errors)
    description = _optional_str(
        _get(mapping, "description"), "target.description", errors
    )
    if len(errors) > before:
        return None
    return TargetConfig(root=root, description=description)


def _parse_technology_stack(
    value: object, errors: list[str]
) -> TechnologyStackConfig | None:
    """Parse the ``technology_stack`` section, returning ``None`` on any defect."""
    mapping = _require_mapping(value, "technology_stack", errors)
    if mapping is None:
        return None
    before = len(errors)
    _reject_unknown_keys(mapping, _TECHNOLOGY_STACK_KEYS, "technology_stack.", errors)
    legacy = _str_list(
        _get(mapping, "legacy"), "technology_stack.legacy", errors, required=True
    )
    target = _str_list(
        _get(mapping, "target"), "technology_stack.target", errors, required=False
    )
    if len(errors) > before:
        return None
    return TechnologyStackConfig(legacy=legacy, target=target)


def _parse_artifacts(value: object, errors: list[str]) -> ArtifactsConfig | None:
    """Parse the ``artifacts`` section, returning ``None`` on any defect."""
    mapping = _require_mapping(value, "artifacts", errors)
    if mapping is None:
        return None
    before = len(errors)
    _reject_unknown_keys(mapping, _ARTIFACTS_KEYS, "artifacts.", errors)
    root = _require_str(_get(mapping, "root"), "artifacts.root", errors)
    conventions = _optional_str_pairs(
        _get(mapping, "conventions"), "artifacts.conventions", errors
    )
    if len(errors) > before:
        return None
    return ArtifactsConfig(root=root, conventions=conventions)


def _format_errors(source: str, errors: list[str]) -> str:
    """Format collected defects into one actionable multi-error message."""
    header = f"{source}: {len(errors)} profile error(s):"
    body = "\n".join(f"  - {message}" for message in errors)
    return f"{header}\n{body}"


def parse_domain_profile_text(text: str, source: str = "<string>") -> DomainProfile:
    """Parse profile text into a validated ``DomainProfile`` (pure, no I/O).

    Collects every field defect in one pass and raises a single
    ``DomainProfileError`` enumerating them with dotted field paths.

    Args:
        text: Raw YAML profile document.
        source: Label naming the document origin, used in error messages.

    Returns:
        The validated, frozen ``DomainProfile``.

    Raises:
        DomainProfileError: On a YAML syntax error, a non-mapping document, or
            any collected field defect.
    """
    mapping = _load_yaml_mapping(text, source)
    errors: list[str] = []

    _reject_unknown_keys(mapping, _TOP_LEVEL_KEYS, "", errors)
    profile_version = _require_profile_version(
        _get(mapping, "profile_version"), "profile_version", errors
    )
    profile_name = _optional_str(_get(mapping, "profile_name"), "profile_name", errors)
    legacy_source = _parse_legacy_source(_get(mapping, "legacy_source"), errors)
    target = _parse_target(_get(mapping, "target"), errors)
    technology_stack = _parse_technology_stack(
        _get(mapping, "technology_stack"), errors
    )
    artifacts = _parse_artifacts(_get(mapping, "artifacts"), errors)

    if (
        errors
        or legacy_source is None
        or target is None
        or technology_stack is None
        or artifacts is None
    ):
        raise DomainProfileError(_format_errors(source, errors))

    return DomainProfile(
        profile_version=profile_version,
        legacy_source=legacy_source,
        target=target,
        technology_stack=technology_stack,
        artifacts=artifacts,
        profile_name=profile_name,
    )


def load_domain_profile(path: Path) -> DomainProfile:
    """Read a profile file from disk and parse it (the only filesystem read).

    Args:
        path: Path to the domain-profile YAML file.

    Returns:
        The validated, frozen ``DomainProfile``.

    Raises:
        DomainProfileError: When the file is missing or unreadable, or when the
            content fails validation.
    """
    try:
        text = path.read_text(encoding="utf-8")
    except FileNotFoundError as exc:
        raise DomainProfileError(f"domain profile not found: {path}") from exc
    except OSError as exc:
        raise DomainProfileError(
            f"could not read domain profile {path}: {exc}"
        ) from exc
    return parse_domain_profile_text(text, source=str(path))
