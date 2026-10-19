"""Classify bounded dependency values without retaining reference targets."""

from __future__ import annotations

import re
from dataclasses import dataclass
from string import ascii_letters, digits
from typing import Literal, cast

Ecosystem = Literal["node", "python", "dotnet"]
_NAME = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]{0,127}\Z")
_NPM_NAME = re.compile(r"(?:@[a-z0-9][a-z0-9._-]{0,63}/)?[a-z0-9][a-z0-9._-]{0,127}\Z")
_CORE_CHARACTERS = frozenset(ascii_letters + digits + "*")
_SUFFIX_CHARACTERS = frozenset(ascii_letters + digits + ".-")


def safe_identifier(
    value: str | None, *, ecosystem: Ecosystem = "python"
) -> str | None:
    """Return an allowlisted name without I/O or mutation.

    Args:
        value (str | None): Untrusted name; None means unavailable.
        ecosystem (Ecosystem): Select Node's scoped grammar or the default grammar.
    Returns:
        str | None: Original ASCII spelling when safe; otherwise None.
    Raises:
        ValueError: The ecosystem or value type violates the public contract.
    """
    if ecosystem not in {"node", "python", "dotnet"}:
        raise ValueError("Unknown dependency ecosystem")
    if value is None:
        return None
    if not isinstance(cast("object", value), str):
        raise ValueError("Dependency identifier must be text or null")
    pattern = _NPM_NAME if ecosystem == "node" else _NAME
    return value if len(value) <= 214 and pattern.fullmatch(value) else None


def _version_term(value: str) -> str | None:
    """Scan one version in forward-only character work without mutation.

    Args:
        value (str): An already bounded term without range operators.
    Returns:
        str | None: literal, constraint for wildcard components, or None.
    Raises:
        None: Malformed grammar is represented by None.
    """
    if value in {"*", "x", "X"}:
        return "constraint"
    cursor = int(value.startswith("v"))
    start = cursor
    # Consume the numeric root once; each subsequent scan advances its cursor.
    while cursor < len(value) and value[cursor] in digits:
        cursor += 1
    if cursor == start:
        return None
    wildcard = False
    # Dots delimit disjoint core components, so no separator can be reconsidered.
    while cursor < len(value) and value[cursor] == ".":
        cursor += 1
        start = cursor
        # Scan each component once before inspecting its finite wildcard spelling.
        while cursor < len(value) and value[cursor] in _CORE_CHARACTERS:
            cursor += 1
        if cursor == start:
            return None
        component = value[start:cursor]
        wildcard = wildcard or component in {"x", "X"} or "*" in component
    # A suffix permits hyphens internally; only plus starts another suffix segment.
    if cursor < len(value):
        if value[cursor] not in "-+":
            return None
        segment = False
        # Visit the suffix once instead of backtracking over overlapping hyphens.
        for character in value[cursor + 1 :]:
            if character == "+":
                if not segment:
                    return None
                segment = False
            elif character in _SUFFIX_CHARACTERS:
                segment = True
            else:
                return None
        if not segment:
            return None
    return "constraint" if wildcard else "literal"


def _version_kind(value: str) -> str | None:
    """Classify finite version, range and tag syntax without evaluation.

    Args:
        value (str): Untrusted text; at most 256 characters enter grammar scanning.
    Returns:
        str | None: Safe syntactic category, or None when unsupported.
    Raises:
        None: This pure classifier does not raise for malformed text.
    """
    if not value or len(value) > 256:
        return None
    kind = _version_term(value)
    if kind is not None:
        return kind
    if value in {"latest", "next", "alpha", "beta", "stable"}:
        return "tag"
    terms = re.split(r"[ ,|()\[\]]+", value.strip(" ,|()[]"))
    # Separators partition the bounded input; each term is scanned at most once.
    for term in terms:
        cursor = 0
        # A finite operator prefix is separate from the forward-only version scan.
        while cursor < len(term) and term[cursor] in "<>=!~^":
            cursor += 1
        if cursor > 3 or _version_term(term[cursor:]) is None:
            return None
    return "constraint"


@dataclass(frozen=True)
class DependencyValue:
    """Immutable sanitized version syntax or a redacted reference category.

    Construct directly only with canonical kind/value pairs; otherwise use
    dependency_value. Validation stores no raw target and performs no I/O.
    kind distinguishes exact syntax, constraints and tags from fixed redactions;
    value is an allowlisted str for the first three categories and None otherwise.
    Neither category establishes installed versions or evaluated resolution.
    """

    kind: str
    value: str | None = None

    def __post_init__(self) -> None:
        """Validate this carrier's str kind and optional str value; return None.

        Raises ValueError for a noncanonical pair. No external side effects occur.
        """
        if self.kind not in {
            "literal",
            "constraint",
            "tag",
            "missing",
            "dynamic",
            "url",
            "vcs",
            "local",
            "workspace",
            "alias",
            "unsupported",
        }:
            raise ValueError("Unknown dependency value classification")
        # Safe categories retain grammar-checked text; every other category is null.
        if self.kind in {"literal", "constraint", "tag"}:
            if (
                not isinstance(self.value, str)
                or _version_kind(self.value) != self.kind
            ):
                raise ValueError(
                    "Dependency version does not match its safe classification"
                )
        elif self.value is not None:
            raise ValueError("Redacted dependency values must be null")


def dependency_value(value: str | None) -> DependencyValue:
    """Return safe version syntax or a fixed redaction without I/O or mutation.

    Args:
        value (str | None): Untrusted version or reference; empty/None is missing.
    Returns:
        DependencyValue: Immutable category with no URL, local target or secret.
    Raises:
        ValueError: The supplied value is neither str nor None.
    """
    if value is None or value == "":
        return DependencyValue("missing")
    if not isinstance(cast("object", value), str):
        raise ValueError("Dependency value must be text or null")
    kind = _version_kind(value)
    if kind is not None:
        return DependencyValue(kind, value)
    # Fixed reference prefixes take precedence over generic dynamic/unknown text.
    lower = value[:32].lower()
    prefixes = (
        ("workspace:", "workspace"),
        ("npm:", "alias"),
        ("git", "vcs"),
        ("hg+", "vcs"),
        ("svn+", "vcs"),
        ("file:", "local"),
        ("link:", "local"),
        ("./", "local"),
        ("../", "local"),
        ("/", "local"),
        ("\\", "local"),
    )
    # Preserve categories without retaining any corresponding target argument.
    for prefix, classification in prefixes:
        if lower.startswith(prefix):
            return DependencyValue(classification)
    if re.match(r"[a-z]:[\\/]", lower):
        return DependencyValue("local")
    if re.match(r"[a-z][a-z0-9+.-]*://", lower):
        return DependencyValue("url")
    if "$" in value or "%" in value or "{" in value:
        return DependencyValue("dynamic")
    return DependencyValue("unsupported")
