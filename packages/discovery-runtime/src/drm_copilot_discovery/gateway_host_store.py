"""Read the protected host authority store through bounded, read-only seams.

The host gateway consumes protected records that the native adapters wrote. This
module defines the read-only seam it reads through and the installed filesystem
implementation of that seam. Nothing here writes, creates or latches an entry.
"""

from __future__ import annotations

from pathlib import Path
from typing import Protocol

RECORD_BYTE_LIMIT = 16777216


class HostStoreIO(Protocol):
    """Read-only seams over the protected authority store; nothing here writes."""

    def read_text(self, path: str) -> str | None:
        """Return the UTF-8 text at path, or None when the entry does not exist."""
        ...

    def list_entries(self, directory: str) -> tuple[str, ...]:
        """Return the immediate entry names of directory; empty when absent."""
        ...

    def exists(self, path: str) -> bool:
        """Return whether an entry exists at path without reading it."""
        ...


class InstalledHostStore:
    """Read the protected store through bounded filesystem reads; never write.

    Each method inspects one host path chosen by the gateway from the trusted
    registry location, never from request JSON. Reads are bounded by
    RECORD_BYTE_LIMIT; no method creates, modifies or removes an entry.
    """

    def read_text(self, path: str) -> str | None:
        """Return bounded UTF-8 text at path (str), or None when no file exists.

        Raises OSError when the record exceeds RECORD_BYTE_LIMIT and
        UnicodeDecodeError when the bytes are not UTF-8. Reads one file.
        """
        target = Path(path)
        if not target.is_file():
            return None
        with target.open("rb") as handle:
            content = handle.read(RECORD_BYTE_LIMIT + 1)
        if len(content) > RECORD_BYTE_LIMIT:
            raise OSError("Protected record exceeds its byte limit")
        return content.decode("utf-8")

    def list_entries(self, directory: str) -> tuple[str, ...]:
        """Return sorted entry names of directory (str); empty when it is absent."""
        target = Path(directory)
        if not target.is_dir():
            return ()
        # Names only; the gateway compares them to a reference it already holds.
        return tuple(sorted(entry.name for entry in target.iterdir()))

    def exists(self, path: str) -> bool:
        """Return whether path (str) names an existing entry; reads metadata only."""
        return Path(path).exists()
