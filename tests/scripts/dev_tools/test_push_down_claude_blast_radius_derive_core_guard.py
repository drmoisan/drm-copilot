"""Tests for the derivation core guard, parse errors, and constants (issue #507).

Mirrors the forbidden-glob guard, source-document parse failure, and exported
scan-constant cases of
``extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts``.
"""

from __future__ import annotations

import json

import pytest

from scripts.dev_tools.push_down_claude_blast_radius_derive_core import (
    BLAST_RADIUS_RELATIVE_PATH,
    FORBIDDEN_GLOBS,
    PAYLOAD_MODULES,
    SCAN_DEPTH_LIMIT,
    BlastRadiusDeriveError,
    BlastRadiusGuardError,
    DirectoryObservation,
    derive_destination_module_map,
)

SOURCE_DOCUMENT = json.dumps({"version": 1, "modules": {}}, indent=2) + "\n"


def _observe(relative_path: str, *file_names: str) -> DirectoryObservation:
    """Build an observation from a relative path and its shallow file names."""

    return DirectoryObservation(relative_path, tuple(file_names))


@pytest.mark.parametrize("bucket", ["docs", "tests"])
def test_forbidden_glob_raises_guard_error(bucket: str) -> None:
    """A location bucket reaching the core as a module trips the guard."""

    observations = [_observe(""), _observe(bucket, "package.json")]

    with pytest.raises(BlastRadiusGuardError):
        derive_destination_module_map(observations, SOURCE_DOCUMENT)


def test_guard_error_names_module_and_glob() -> None:
    """The guard error carries the offending module name and glob."""

    observations = [_observe(""), _observe("docs", "package.json")]

    with pytest.raises(BlastRadiusGuardError) as caught:
        derive_destination_module_map(observations, SOURCE_DOCUMENT)

    assert isinstance(caught.value, ValueError)
    assert caught.value.module_name == "docs"
    assert caught.value.glob == "docs/**"
    assert str(caught.value) == (
        "Derived blast-radius module docs would emit the forbidden glob docs/**; "
        "the derivation was aborted before writing."
    )


@pytest.mark.parametrize("text", ["{ not json at all\n", '{"version": NaN}'])
def test_unparseable_source_raises_derive_error(text: str) -> None:
    """Unparseable source text raises a derive error naming the document path."""

    with pytest.raises(BlastRadiusDeriveError) as caught:
        derive_destination_module_map([_observe("")], text)

    assert isinstance(caught.value, ValueError)
    assert caught.value.path == BLAST_RADIUS_RELATIVE_PATH
    assert str(caught.value).startswith(
        "Bundled blast-radius document is not valid JSON and was not written: "
        "config/blast-radius.json ("
    )


@pytest.mark.parametrize("text", ["[]", "null", '"text"', "7"])
def test_non_object_source_raises_derive_error(text: str) -> None:
    """A non-object source root raises a derive error."""

    with pytest.raises(BlastRadiusDeriveError) as caught:
        derive_destination_module_map([_observe("")], text)

    assert str(caught.value).endswith("(document root is not a JSON object)")


def test_scan_constants_pin_depth_and_payload_modules() -> None:
    """The depth bound, derive path, and payload module set are pinned."""

    assert SCAN_DEPTH_LIMIT == 3
    assert BLAST_RADIUS_RELATIVE_PATH == "config/blast-radius.json"
    assert dict(PAYLOAD_MODULES) == {"config": ("config/**",)}
    assert FORBIDDEN_GLOBS == ("**", "docs/**", "tests/**")


def test_payload_modules_declare_no_forbidden_glob() -> None:
    """No payload module is an umbrella or declares a forbidden glob."""

    names = list(PAYLOAD_MODULES)
    globs = [glob for module_globs in PAYLOAD_MODULES.values() for glob in module_globs]

    assert "claude-runtime" not in names
    for forbidden in FORBIDDEN_GLOBS:
        assert forbidden not in globs, forbidden
