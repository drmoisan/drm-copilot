"""Forward profile commands while retaining pure historical v1 display helpers.

``main`` uses the installed CLI's bounded parser, typed results and trusted I/O.
``parse_args`` only describes the old syntax; its namespace grants no authority.
The renderers accept an already parsed v1 DomainProfile and perform no I/O.
Actual v1 readers remain available from the installed domain_profile module.
"""

from __future__ import annotations

import argparse
import dataclasses
import json
from typing import TYPE_CHECKING

from drm_copilot_discovery import cli as runtime_cli
from drm_copilot_discovery.domain_profile import DEFAULT_PROFILE_FILENAME

if TYPE_CHECKING:
    from collections.abc import Sequence

    from drm_copilot_discovery.domain_profile_models import DomainProfile

_NONE_DISPLAY = "(none)"


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Describe historical v1 arguments without reading or authorizing a profile.

    argv (Sequence[str] | None) supplies tokens or uses process arguments.
    Return argparse.Namespace with profile_path (str) and json (bool).
    Argparse may emit help/errors and raise SystemExit; no files are accessed.
    ``main`` never consumes this legacy namespace.
    """
    parser = argparse.ArgumentParser(
        prog="dev.discovery.profile",
        description="Inspect historical v1 profile syntax without executing it.",
    )
    parser.add_argument(
        "profile_path",
        nargs="?",
        default=DEFAULT_PROFILE_FILENAME,
        help=(
            "Path to the domain-profile file " f"(default: {DEFAULT_PROFILE_FILENAME})."
        ),
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit the resolved profile as JSON with sorted keys.",
    )
    return parser.parse_args(argv)


def _format_scalar(value: object) -> str:
    """Return display str for value (object), including None; no I/O or mutation."""
    if value is None:
        return _NONE_DISPLAY
    return str(value)


def _format_sequence(values: tuple[str, ...]) -> str:
    """Return display str for values (tuple[str, ...]); no I/O or mutation."""
    if not values:
        return _NONE_DISPLAY
    return ", ".join(values)


def _format_conventions(profile: DomainProfile) -> str:
    """Return conventions text for profile (DomainProfile); no I/O or mutation."""
    conventions = profile.artifacts.conventions_map
    if not conventions:
        return _NONE_DISPLAY
    # Preserve the resolved v1 convention order in the historical display.
    return ", ".join(f"{key}={value}" for key, value in conventions.items())


def _resolved_rows(profile: DomainProfile) -> list[tuple[str, str]]:
    """Return ordered list[tuple[str, str]] for profile (DomainProfile).

    Each row describes a resolved v1 value; no I/O or input mutation occurs.
    """
    return [
        ("profile_version", str(profile.profile_version)),
        ("profile_name", _format_scalar(profile.profile_name)),
        ("legacy_source.root", profile.legacy_source.root),
        (
            "legacy_source.description",
            _format_scalar(profile.legacy_source.description),
        ),
        ("legacy_source.include", _format_sequence(profile.legacy_source.include)),
        ("legacy_source.exclude", _format_sequence(profile.legacy_source.exclude)),
        ("target.root", profile.target.root),
        ("target.description", _format_scalar(profile.target.description)),
        ("technology_stack.legacy", _format_sequence(profile.technology_stack.legacy)),
        ("technology_stack.target", _format_sequence(profile.technology_stack.target)),
        ("artifacts.root", profile.artifacts.root),
        ("artifacts.conventions", _format_conventions(profile)),
    ]


def render_text(profile: DomainProfile) -> str:
    """Return aligned text str for profile (DomainProfile); no I/O or mutation."""
    rows = _resolved_rows(profile)
    # A shared width preserves alignment independently of optional field values.
    width = max(len(key) for key, _ in rows)
    # Keep the declared v1 field order rather than implying v2 result semantics.
    return "\n".join(f"{key.ljust(width)} : {value}" for key, value in rows)


def render_json(profile: DomainProfile) -> str:
    """Return sorted JSON str for profile (DomainProfile); no I/O or mutation."""
    return json.dumps(dataclasses.asdict(profile), sort_keys=True, indent=2)


def main(argv: Sequence[str] | None = None) -> int:
    """Forward argv (Sequence[str] | None) unchanged to installed profile CLI.

    Return its typed int exit (0/1/2/3). None retains bounded process-argument
    handling. The installed boundary owns streams and trusted workspace I/O;
    unsupported positional/legacy flags refuse before providers. No legacy
    path lookup, rendering, or error reinterpretation occurs here.
    """
    return runtime_cli.run_installed_cli("profile", argv)


if __name__ == "__main__":
    raise SystemExit(main())
