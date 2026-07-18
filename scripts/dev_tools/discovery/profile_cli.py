"""Console entry point that loads and displays a resolved discovery profile.

Purpose:
    Provide the ``dev.discovery.profile`` command. It loads a domain-profile
    file, applies defaults for every omitted optional field, and prints the
    resolved profile as aligned ``key: value`` text or as JSON.

Responsibilities:
    - Parse a flat argument surface (one optional positional path and a
      ``--json`` flag).
    - Delegate loading and validation to ``load_domain_profile``.
    - Render the resolved profile and map ``DomainProfileError`` to exit code 1
      with the full multi-error message on stderr.

Invariants / Constraints:
    - Only ``DomainProfileError`` is caught; there is no broad exception handler.
    - Exit codes: ``0`` on success, ``1`` on ``DomainProfileError``, and ``2``
      for argparse usage errors (argparse's built-in behavior).

Side Effects:
    Reads one file (via ``load_domain_profile``); writes to stdout and stderr.
"""

from __future__ import annotations

import argparse
import dataclasses
import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.discovery.domain_profile import (
    DEFAULT_PROFILE_FILENAME,
    load_domain_profile,
)
from scripts.dev_tools.discovery.domain_profile_models import (
    DomainProfile,
    DomainProfileError,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

_NONE_DISPLAY = "(none)"


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Parse the flat command-line surface.

    Args:
        argv: Argument vector; ``None`` uses ``sys.argv[1:]``.

    Returns:
        A namespace with ``profile_path`` (str) and ``json`` (bool).
    """
    parser = argparse.ArgumentParser(
        prog="dev.discovery.profile",
        description="Load and display a resolved discovery domain profile.",
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
    """Format an optional scalar value for aligned text output."""
    if value is None:
        return _NONE_DISPLAY
    return str(value)


def _format_sequence(values: tuple[str, ...]) -> str:
    """Format a tuple of strings for aligned text output."""
    if not values:
        return _NONE_DISPLAY
    return ", ".join(values)


def _format_conventions(profile: DomainProfile) -> str:
    """Format the artifact conventions mapping for aligned text output."""
    conventions = profile.artifacts.conventions_map
    if not conventions:
        return _NONE_DISPLAY
    return ", ".join(f"{key}={value}" for key, value in conventions.items())


def _resolved_rows(profile: DomainProfile) -> list[tuple[str, str]]:
    """Return the ordered ``(dotted_key, value)`` rows of the resolved profile."""
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
    """Render the resolved profile as aligned ``key: value`` text."""
    rows = _resolved_rows(profile)
    width = max(len(key) for key, _ in rows)
    return "\n".join(f"{key.ljust(width)} : {value}" for key, value in rows)


def render_json(profile: DomainProfile) -> str:
    """Render the resolved profile as JSON with sorted keys."""
    return json.dumps(dataclasses.asdict(profile), sort_keys=True, indent=2)


def main(argv: Sequence[str] | None = None) -> int:
    """Load a profile and print its resolved form.

    Args:
        argv: Argument vector; ``None`` uses ``sys.argv[1:]``.

    Returns:
        ``0`` on success, ``1`` when the profile is missing, unreadable, or
        invalid.
    """
    args = parse_args(argv)
    try:
        profile = load_domain_profile(Path(args.profile_path))
    except DomainProfileError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    output = render_json(profile) if args.json else render_text(profile)
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
