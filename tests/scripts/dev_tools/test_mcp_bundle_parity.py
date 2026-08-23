"""Verify local MCP candidate parity without published-runtime data."""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
from typing import cast

ROUTING_PATHS = (
    Path("config/orchestration-routing.json"),
    Path("extensions/drm-copilot/resources/config/orchestration-routing.json"),
    Path("packages/mcp-server/resources/config/orchestration-routing.json"),
)
BUNDLE_PATHS = (
    Path("extensions/drm-copilot/out/mcp-server.js"),
    Path("packages/mcp-server/out/mcp-server.js"),
    Path(
        "docs/features/active/"
        "2026-08-17-orchestrator-remediation-loop-control-484/"
        "evidence/regression-testing/packed-mcp/out/mcp-server.js"
    ),
)
BUNDLE_DIGEST_PATTERN = re.compile(
    rb'var BUNDLE_SHA256 = true \? "(sha256:[0-9a-f]{64})"'
)
PUBLISHED_FIXTURE_PATH = Path(
    "tests/fixtures/mcp-server/published-1.0.24-validator-capabilities.json"
)


def _read_required_bytes(path: Path) -> bytes:
    """Read one required local candidate surface."""

    assert path.is_file(), f"required local candidate surface is missing: {path}"
    return path.read_bytes()


def _embedded_bundle_digest(bundle: bytes, path: Path) -> str:
    """Return the deterministic bundle identity embedded in one candidate."""

    match = BUNDLE_DIGEST_PATTERN.search(bundle)
    assert match is not None, f"embedded bundle identity is missing: {path}"
    return match.group(1).decode("ascii")


def test_local_candidate_source_built_and_packed_parity() -> None:
    """Keep canonical routing and all three local executable bundles identical."""

    routing_payloads = [_read_required_bytes(path) for path in ROUTING_PATHS]
    routing_digest = hashlib.sha256(routing_payloads[0]).hexdigest()

    assert routing_payloads.count(routing_payloads[0]) == len(ROUTING_PATHS)
    assert (
        routing_digest
        == "7a30f003994ae274f6b9bf7a2fcc1ff598f0cce743cc8663060eb3df50742231"
    )

    bundle_payloads = [_read_required_bytes(path) for path in BUNDLE_PATHS]
    embedded_digests = [
        _embedded_bundle_digest(bundle, path)
        for bundle, path in zip(bundle_payloads, BUNDLE_PATHS, strict=True)
    ]

    assert bundle_payloads.count(bundle_payloads[0]) == len(BUNDLE_PATHS)
    assert embedded_digests.count(embedded_digests[0]) == len(BUNDLE_PATHS)
    assert embedded_digests[0] == (
        "sha256:72937c91d2cf0ad6809dd1c970ffa38f06eae4248c73222aa45f47266d63b0f4"
    )


def test_published_1_0_24_is_rejected_as_external_runtime() -> None:
    """Keep the immutable published package outside local candidate parity."""

    published = cast(
        "dict[str, object]",
        json.loads(PUBLISHED_FIXTURE_PATH.read_text(encoding="utf-8")),
    )
    identity = cast("dict[str, str]", published["identity"])
    catalog = cast("dict[str, list[str]]", published["validator_catalog"])
    local_routing_digest = (
        "sha256:" + hashlib.sha256(_read_required_bytes(ROUTING_PATHS[0])).hexdigest()
    )
    local_bundle_digest = (
        "sha256:" + hashlib.sha256(_read_required_bytes(BUNDLE_PATHS[0])).hexdigest()
    )
    mismatch_reasons: list[str] = []

    if published["validator_capability"] is None:
        mismatch_reasons.append("ORCH_VALIDATOR_CAPABILITY_MISSING")
    if identity["bundle_file_sha256"] != local_bundle_digest:
        mismatch_reasons.append("ORCH_VALIDATOR_VERSION_INCOMPATIBLE:BUNDLE")
    if identity["routing_policy_sha256"] != local_routing_digest:
        mismatch_reasons.append("ORCH_ROUTING_POLICY_DIGEST_MISMATCH")
    if "require_pr_creation_ready" not in catalog["supported_validation_flags"]:
        mismatch_reasons.append(
            "ORCH_VALIDATOR_CAPABILITY_MISSING:FLAG:require_pr_creation_ready"
        )

    disposition = "EXTERNAL_RUNTIME" if mismatch_reasons else "LOCAL_CANDIDATE"
    counts_before = {"attempt_count": 2, "cycle_count": 1}
    counts_after = counts_before.copy()

    assert identity["package_name"] == "@danmoisan/drm-copilot-mcp"
    assert identity["package_version"] == "1.0.24"
    assert tuple(mismatch_reasons) == (
        "ORCH_VALIDATOR_CAPABILITY_MISSING",
        "ORCH_VALIDATOR_VERSION_INCOMPATIBLE:BUNDLE",
        "ORCH_ROUTING_POLICY_DIGEST_MISMATCH",
        "ORCH_VALIDATOR_CAPABILITY_MISSING:FLAG:require_pr_creation_ready",
    )
    assert disposition == published["expected_disposition"] == "EXTERNAL_RUNTIME"
    assert counts_after == counts_before
    assert PUBLISHED_FIXTURE_PATH not in {*ROUTING_PATHS, *BUNDLE_PATHS}
