"""Byte-identity guard for the orchestration routing configuration.

This module enforces that the canonical routing configuration at
``config/orchestration-routing.json`` and its bundled extension mirror at
``extensions/drm-copilot/resources/config/orchestration-routing.json`` remain
byte-for-byte identical. The bundled mirror is shipped inside the extension
resources, so any divergence between the two copies would let the runtime read
a different routing matrix than the repository's canonical source. The test is
deterministic: it reads both files from the repository tree using path
resolution relative to this test file and performs no network or filesystem
temporary-file operations.
"""

from __future__ import annotations

from pathlib import Path

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_orchestration_routing_config_parity.py, so the
# repository root is three parents above the file's resolved directory.
_REPO_ROOT = Path(__file__).resolve().parents[3]
_CANONICAL_CONFIG = _REPO_ROOT / "config" / "orchestration-routing.json"
_BUNDLED_CONFIG = (
    _REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "config"
    / "orchestration-routing.json"
)


def test_canonical_and_bundled_routing_config_are_byte_identical() -> None:
    """Assert the canonical and bundled routing configs are byte-identical.

    Reads both routing-configuration files as raw bytes and asserts equality.
    A mismatch indicates the bundled extension mirror has drifted from the
    canonical source and must be re-synchronized.

    Returns:
        None. The test passes when both files contain identical bytes and
        fails with an actionable message otherwise.
    """

    # Arrange: read both copies as raw bytes to detect any content difference,
    # including trailing-newline or encoding differences a text compare misses.
    canonical_bytes = _CANONICAL_CONFIG.read_bytes()
    bundled_bytes = _BUNDLED_CONFIG.read_bytes()

    # Act / Assert: require exact byte equality between the two copies.
    assert canonical_bytes == bundled_bytes, (
        "Routing config copies differ. The canonical file "
        f"'{_CANONICAL_CONFIG}' and the bundled mirror '{_BUNDLED_CONFIG}' must "
        "be byte-for-byte identical. Re-copy the canonical file over the "
        "bundled mirror to restore parity."
    )
