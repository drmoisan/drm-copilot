"""Shared JSON-schema loading and caching for discovery validators.

Purpose:
    Provide the single public schema-resolution seam reused by
    ``validate_json.py`` and by the discovery-artifact schema validators, per
    the legacy-discovery-and-parity epic's Shared Design schema-loading reuse
    requirement (``docs/features/epics/legacy-discovery-and-parity/epic.md``).
    This module isolates the scheme-resolution logic (scheme-less relative
    paths, ``file://`` absolute paths, ``http(s)://`` fetched-and-cached
    schemas) so both callers resolve schemas identically.

Side Effects:
    ``load_schema`` may read from and write to the on-disk schema cache
    directory and may perform a network fetch for ``http(s)://`` schema URIs.
"""

from __future__ import annotations

import hashlib
import json
import urllib.request
from pathlib import Path
from typing import Any
from urllib.parse import urlparse


def cache_path(cache_dir: Path, uri: str) -> Path:
    """Return the deterministic on-disk cache path for a schema URI.

    Purpose:
        Compute a stable, collision-resistant cache filename for a given
        schema URI so repeated loads of the same URI reuse the same cache
        entry.

    Args:
        cache_dir (Path): Directory in which cached schema files are stored.
        uri (str): Schema URI being cached.

    Returns:
        Path: ``cache_dir / f"{sha256(uri)}.json"``.

    Raises:
        None.

    Side Effects:
        None.
    """

    digest = hashlib.sha256(uri.encode("utf-8")).hexdigest()
    return cache_dir / f"{digest}.json"


def load_schema(
    uri: str, cache_dir: Path, base_path: Path | None = None
) -> dict[str, Any]:
    """Resolve and load a JSON schema document from a ``$schema`` URI.

    Purpose:
        Resolve a schema reference using the same scheme-based rules
        regardless of caller: a scheme-less URI resolves relative to
        ``base_path``'s parent directory, a ``file://`` URI resolves to an
        absolute local path, and an ``http(s)://`` URI is fetched once and
        cached under ``cache_dir``.

    Args:
        uri (str): The schema URI to resolve (a document's ``$schema`` value).
        cache_dir (Path): Directory used to cache fetched ``http(s)://``
            schemas.
        base_path (Path | None): The source document's path, used to resolve
            scheme-less relative schema URIs. Required when ``uri`` has no
            scheme.

    Returns:
        dict[str, Any]: The parsed schema document.

    Raises:
        ValueError: When ``uri`` has no scheme and no ``base_path`` was
            supplied, or when ``uri`` uses an unsupported scheme.
        FileNotFoundError: When a resolved local schema file does not exist.

    Side Effects:
        May read a local file, fetch a remote URL, and write a cached copy of
        a fetched schema to ``cache_dir``.
    """

    parsed = urlparse(uri)

    if not parsed.scheme:
        if base_path is None:
            raise ValueError("Unsupported schema URI scheme: missing")

        local_path = (base_path.parent / uri).resolve()
        if not local_path.is_file():
            raise FileNotFoundError(f"Schema file not found: {local_path}")

        return json.loads(local_path.read_text())

    if parsed.scheme == "file":
        local_path = Path(parsed.path)
        if not local_path.is_file():
            raise FileNotFoundError(f"Schema file not found: {local_path}")

        return json.loads(local_path.read_text())

    if parsed.scheme not in {"http", "https"}:
        raise ValueError(f"Unsupported schema URI scheme: {parsed.scheme or 'missing'}")

    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_file = cache_path(cache_dir, uri)
    if cache_file.exists():
        return json.loads(cache_file.read_text())

    resp = urllib.request.urlopen(uri)  # noqa: S310 - fetching trusted schema URL
    with resp:
        content = resp.read().decode("utf-8")
    cache_file.write_text(content)
    return json.loads(content)
