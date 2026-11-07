"""Dotted module names, packages and relative-import resolution for request paths.

The rules reproduce the 1022 scanner: a path maps to a module under its longest
containing source root, __init__.py names its package, and a relative module resolves
against the importing module's package.
"""

from __future__ import annotations


def _identifier(segment: str) -> bool:
    """Report whether a dotted-name segment is a Python identifier.

    Args:
        segment: One segment of a dotted module name.

    Returns:
        True when the segment is an identifier (str.isidentifier).
    """
    return segment.isidentifier()


def module_dotted_name(
    path: str, source_roots: list[str], *, require_identifiers: bool = True
) -> str | None:
    """Return the dotted module name of a .py path under its longest containing root.

    Args:
        path: A repository-relative request path with forward slashes.
        source_roots: The configured source roots; "." or "" stands for the
            repository root and is used only when no other root contains the path.
        require_identifiers: When True, a name with a non-identifier segment is
            rejected; analyzers that report such modules pass False.

    Returns:
        The dotted name ("__init__.py" gives the package name), or None for a path
        under no root, a non-.py path, a root-level __init__.py, or (when
        require_identifiers) a segment that is not an identifier.
    """
    if not path.endswith(".py"):
        return None
    relative: str | None = None
    best = -1
    # Keep the longest root that contains the path; the repository-root forms only
    # apply when no named root has matched.
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
    # A package __init__ names its directory; a root-level __init__ names nothing.
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
    """Return the package that relative imports in a module resolve against.

    Args:
        path: The request path of the module.
        module: The module's dotted name, or None.

    Returns:
        The module itself for __init__.py, its parent package otherwise, "" for a
        top-level module, or None when module is None.
    """
    if module is None:
        return None
    # Routing: a package resolves against itself, a submodule against its parent.
    if path.endswith("/__init__.py"):
        return module
    if "." in module:
        return module[: module.rindex(".")]
    return ""


def resolve_relative(module: str, package: str | None) -> str | None:
    """Resolve a possibly relative dotted module against a package.

    Args:
        module: The imported module text, with one leading dot per level.
        package: The importing module's package, or None.

    Returns:
        The absolute dotted module; the module unchanged when it is absolute; None when
        the package is empty or absent or the dots climb above the top package.
    """
    level = len(module) - len(module.lstrip("."))
    if level == 0:
        return module
    if not package:
        return None
    # Each extra dot climbs one package; climbing past the root is unresolved.
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
