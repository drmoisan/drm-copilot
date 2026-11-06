"""Dotted module names, packages and relative-import resolution for request paths.

The rules reproduce the 1022 scanner: a path maps to a module under its longest
containing source root, __init__.py names its package, and a relative module resolves
against the importing module's package.
"""

from __future__ import annotations


def _identifier(segment: str) -> bool:
    return segment.isidentifier()


def module_dotted_name(
    path: str, source_roots: list[str], *, require_identifiers: bool = True
) -> str | None:
    """Return the dotted module name of a .py path under its longest containing root.

    __init__.py gives the package name. None for a path under no root, a non-.py path, a
    root-level __init__.py, or (when require_identifiers) a segment that is not an
    identifier.
    """
    if not path.endswith(".py"):
        return None
    relative: str | None = None
    best = -1
    for root in source_roots:
        trimmed = root.rstrip("/")
        if trimmed in (".", ""):
            if best < 0:
                best, relative = 0, path
            continue
        if path.startswith(trimmed + "/") and len(trimmed) > best:
            best, relative = len(trimmed), path[len(trimmed) + 1 :]
    if relative is None:
        return None
    stem = relative[:-3]
    if stem.endswith("/__init__"):
        stem = stem[: -len("/__init__")]
    elif stem == "__init__":
        return None
    if stem == "":
        return None
    dotted = stem.replace("/", ".")
    if require_identifiers and not all(_identifier(part) for part in dotted.split(".")):
        return None
    return dotted


def module_package(path: str, module: str | None) -> str | None:
    """Return a module's package: itself for __init__.py, its parent, or '' at top."""
    if module is None:
        return None
    if path.endswith("/__init__.py"):
        return module
    if "." in module:
        return module[: module.rindex(".")]
    return ""


def resolve_relative(module: str, package: str | None) -> str | None:
    """Resolve a possibly relative dotted module against a package, or return None."""
    level = len(module) - len(module.lstrip("."))
    if level == 0:
        return module
    if not package:
        return None
    parts = package.split(".")
    if level - 1 > len(parts):
        return None
    kept = parts[: len(parts) - (level - 1)]
    rest = module[level:]
    if rest:
        kept.append(rest)
    if not kept:
        return None
    return ".".join(kept)
