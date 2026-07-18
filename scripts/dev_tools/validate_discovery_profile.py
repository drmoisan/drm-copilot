"""Validate a domain-profile discovery configuration document.

Purpose:
    Provide the deterministic `validate_profile_text` entry point that checks
    a domain-profile configuration document's structure against the upstream
    contract defined by `legacy-discovery-config-contract` (#9001). This
    module checks profile structure independently of #9001's typed loader.

Constraints:
    #9001's final field contract has not shipped as of this module's
    authorship. Only `legacy_source_path` is enforced as a placeholder
    required field, per the illustrative example in spec.md's API/CLI Surface
    section. `_check_required_profile_fields` is the single isolated seam
    that will change once #9001 finalizes its field contract.
"""

from __future__ import annotations

from typing import Any

import yaml

# TODO(#9001): replace with the finalized field contract once #9001 ships.
_PLACEHOLDER_REQUIRED_FIELDS: tuple[str, ...] = ("legacy_source_path",)


def _parse_profile_mapping(text: str) -> tuple[dict[str, Any] | None, list[str]]:
    """Parse profile text into a mapping, or report a single error string.

    Purpose:
        Isolate the untyped `yaml.safe_load` boundary and narrow its result to
        a mapping the required-field checker can consume.

    Args:
        text (str): Raw profile document text.

    Returns:
        tuple[dict[str, Any] | None, list[str]]: `(mapping, [])` on success;
        `(None, [<error>])` on a YAML parse failure or a non-mapping root.

    Raises:
        None.

    Side Effects:
        None.
    """

    try:
        parsed = yaml.safe_load(text)
    except yaml.YAMLError as exc:
        return None, [f"Profile document is not valid YAML: {exc}"]

    if not isinstance(parsed, dict):
        return None, ["Profile document root must be a mapping."]

    return parsed, []


def _check_required_profile_fields(mapping: dict[str, Any]) -> list[str]:
    """Check `mapping` for the placeholder required-field set.

    Purpose:
        Report every missing required field so a maintainer can correct a
        profile document in a single pass.

    Args:
        mapping (dict[str, Any]): Parsed profile mapping.

    Returns:
        list[str]: One `"Missing required field: <field>."` entry per absent
        field; `[]` when every placeholder field is present.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    # TODO(#9001): replace with the finalized field contract once #9001 ships.
    for field in _PLACEHOLDER_REQUIRED_FIELDS:
        if field not in mapping:
            errors.append(f"Missing required field: {field}.")
    return errors


def validate_profile_text(text: str) -> list[str]:
    """Validate domain-profile document text.

    Purpose:
        Provide the stable, pure conformance check for a domain-profile
        configuration document, following the canonical
        `validate_<artifact>_text` contract.

    Args:
        text (str): Raw profile document text, already read from disk by the
            caller.

    Returns:
        list[str]: Empty list when the document conforms; otherwise one or
        more human-readable error strings.

    Raises:
        None.

    Side Effects:
        None.
    """

    if not text.strip():
        return ["Profile document is empty."]

    mapping, errors = _parse_profile_mapping(text)
    if mapping is None:
        return errors

    return _check_required_profile_fields(mapping)
