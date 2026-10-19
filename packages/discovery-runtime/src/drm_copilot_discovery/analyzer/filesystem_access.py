"""Inventory fixed filesystem API spellings; arguments and runtime paths stay local.

Only listed System.IO static invocations and constructors are candidates. Instance
receiver types, aliases and compiler binding are deliberately unresolved. Generic
Stream/MemoryStream and similarly named application APIs are not recognized.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.analyzer.api_access import analyze_access
from drm_copilot_discovery.analyzer.api_syntax import ApiSurface

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture

_FILE_METHODS = (
    "AppendAllLines",
    "AppendAllLinesAsync",
    "AppendAllText",
    "AppendAllTextAsync",
    "AppendText",
    "Copy",
    "Create",
    "CreateSymbolicLink",
    "CreateText",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Exists",
    "GetAttributes",
    "GetCreationTime",
    "GetCreationTimeUtc",
    "GetLastAccessTime",
    "GetLastAccessTimeUtc",
    "GetLastWriteTime",
    "GetLastWriteTimeUtc",
    "GetUnixFileMode",
    "Move",
    "Open",
    "OpenHandle",
    "OpenRead",
    "OpenText",
    "OpenWrite",
    "ReadAllBytes",
    "ReadAllBytesAsync",
    "ReadAllLines",
    "ReadAllLinesAsync",
    "ReadAllText",
    "ReadAllTextAsync",
    "ReadLines",
    "ReadLinesAsync",
    "Replace",
    "ResolveLinkTarget",
    "SetAttributes",
    "SetCreationTime",
    "SetCreationTimeUtc",
    "SetLastAccessTime",
    "SetLastAccessTimeUtc",
    "SetLastWriteTime",
    "SetLastWriteTimeUtc",
    "SetUnixFileMode",
    "WriteAllBytes",
    "WriteAllBytesAsync",
    "WriteAllLines",
    "WriteAllLinesAsync",
    "WriteAllText",
    "WriteAllTextAsync",
)
_DIRECTORY_METHODS = (
    "CreateDirectory",
    "CreateSymbolicLink",
    "CreateTempSubdirectory",
    "Delete",
    "EnumerateDirectories",
    "EnumerateFiles",
    "EnumerateFileSystemEntries",
    "Exists",
    "GetCreationTime",
    "GetCreationTimeUtc",
    "GetCurrentDirectory",
    "GetDirectories",
    "GetDirectoryRoot",
    "GetFiles",
    "GetFileSystemEntries",
    "GetLastAccessTime",
    "GetLastAccessTimeUtc",
    "GetLastWriteTime",
    "GetLastWriteTimeUtc",
    "GetLogicalDrives",
    "GetParent",
    "Move",
    "ResolveLinkTarget",
    "SetCreationTime",
    "SetCreationTimeUtc",
    "SetCurrentDirectory",
    "SetLastAccessTime",
    "SetLastAccessTimeUtc",
    "SetLastWriteTime",
    "SetLastWriteTimeUtc",
)

# The finite allowlist is independent of captured source values and loaded domains.
FILESYSTEM_SURFACE = ApiSurface(
    identifier="filesystem-access",
    namespace=("System", "IO"),
    # Pair only fixed type/member definitions; no source-derived names enter rules.
    calls=frozenset(
        (type_name, member)
        for type_name, members in (
            ("File", _FILE_METHODS),
            ("Directory", _DIRECTORY_METHODS),
        )
        for member in members
    ),
    constructors=frozenset(
        {"FileInfo", "DirectoryInfo", "FileStream", "StreamReader", "StreamWriter"}
    ),
)


class FilesystemAccessAnalyzer:
    """Project inferred filesystem syntax without resolving paths or performing I/O."""

    identifier = "filesystem-access"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return Analysis for InventoryCapture using fixed filesystem definitions.

        Selected C# inputs are captured bytes only; malformed/unavailable inputs
        produce redacted diagnostics. Output is bounded and never writes files.
        """
        return analyze_access(capture, FILESYSTEM_SURFACE)
