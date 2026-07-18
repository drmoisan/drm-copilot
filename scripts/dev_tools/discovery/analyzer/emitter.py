"""Evidence Reference v1 serialization for the analyzer framework.

Purpose:
    Turn an ``EvidenceRecord`` into a discovery v1 Evidence Reference JSON
    document string. This module owns the ``$schema`` relative-path computation
    and deterministic serialization; the record owns the field-set assembly.

Invariants / Constraints:
    - ``$schema`` is a scheme-less relative POSIX path from the emitted instance
      file to the schema file. It never contains a drive letter or a leading
      ``/`` (absolute Windows paths are prohibited).
    - Serialization is deterministic: ``json.dumps(..., sort_keys=True,
      indent=2)``.
    - Standard library only; no domain-specific identifiers.

Side Effects:
    None. Writing instances to disk is the caller's responsibility (via the
    filesystem seam).
"""

from __future__ import annotations

import json
import os
from pathlib import PurePosixPath
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.discovery.analyzer.models import EvidenceRecord


def compute_schema_ref(instance_path: Path, schema_path: Path) -> str:
    """Compute the scheme-less relative POSIX ``$schema`` path.

    Args:
        instance_path: Path of the emitted instance file.
        schema_path: Path of the discovery v1 Evidence Reference schema file.

    Returns:
        A relative POSIX path from the instance file's directory to the schema
        file, with no drive letter and no leading ``/``.

    Raises:
        ValueError: When a scheme-less relative path cannot be produced (for
            example the paths are on different drives, or the result would be
            absolute).
    """
    try:
        relative = os.path.relpath(str(schema_path), start=str(instance_path.parent))
    except ValueError as exc:
        raise ValueError(
            f"cannot compute a relative $schema path from {instance_path} "
            f"to {schema_path}: {exc}"
        ) from exc
    posix = PurePosixPath(relative.replace(os.sep, "/")).as_posix()
    if posix.startswith("/") or ":" in posix.split("/", 1)[0]:
        raise ValueError(
            f"computed $schema path is not scheme-less relative: {posix!r}"
        )
    return posix


def serialize_record(
    record: EvidenceRecord, instance_path: Path, schema_path: Path
) -> str:
    """Build and deterministically serialize an Evidence Reference instance.

    Args:
        record: The evidence record to serialize.
        instance_path: Path where the instance will be written (drives ``$schema``).
        schema_path: Path of the schema file that the instance references.

    Returns:
        The JSON text of the Evidence Reference instance with sorted keys.
    """
    schema_ref = compute_schema_ref(instance_path, schema_path)
    document = record.to_json_dict(schema_ref)
    return json.dumps(document, sort_keys=True, indent=2)
