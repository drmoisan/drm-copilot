"""Focused additive routing-merge parity contracts for the Python publisher."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

from scripts.dev_tools.push_down_codex_routing_merge import (
    AdditiveRoutingMergeFileSystem,
    RoutingMergeConflictError,
    merge_additive_routing_documents,
)


@dataclass
class MemoryFile:
    """Represent one in-memory text file."""

    content: str


class MemoryFileSystem:
    """Provide the publisher filesystem protocol without disk I/O."""

    def __init__(self, files: dict[Path, str]) -> None:
        self.files = {path: MemoryFile(content) for path, content in files.items()}
        self.directories: set[Path] = set()

    def list_files(self, root: Path) -> list[Path]:
        """Return deterministic in-memory descendants."""

        return sorted(path for path in self.files if path.is_relative_to(root))

    def is_dir(self, path: Path) -> bool:
        """Return whether a directory is tracked."""

        return path in self.directories

    def is_file(self, path: Path) -> bool:
        """Return whether a file is tracked."""

        return path in self.files

    def read_text(self, path: Path) -> str:
        """Read one tracked file."""

        return self.files[path].content

    def write_text(self, path: Path, content: str) -> None:
        """Write one tracked file."""

        self.files[path] = MemoryFile(content)

    def ensure_dir(self, path: Path) -> None:
        """Track one directory."""

        self.directories.add(path)


def _document(value: dict[str, object]) -> str:
    """Render one deterministic JSON fixture."""

    return f"{json.dumps(value, indent=2)}\n"


def test_merge_preserves_destination_and_sorts_source_additions() -> None:
    """Preserve destination ownership and append source keys deterministically."""

    destination = _document(
        {
            "routes": {"destination": {"owner": "destination"}},
            "destination_only": {"enabled": True},
        }
    )
    source = _document(
        {
            "source_z": 2,
            "routes": {
                "beta": {"owner": "source"},
                "alpha": {"owner": "source"},
            },
            "source_a": 1,
        }
    )

    merged = json.loads(
        merge_additive_routing_documents(
            destination,
            source,
            "config/orchestration-routing.json",
        )
    )

    assert list(merged) == [
        "routes",
        "destination_only",
        "source_a",
        "source_z",
    ]
    assert list(merged["routes"]) == ["destination", "alpha", "beta"]
    assert merged["routes"]["destination"] == {"owner": "destination"}
    assert merged["destination_only"] == {"enabled": True}


def test_equal_entries_are_skipped_without_rewriting_destination_bytes() -> None:
    """Treat structurally equal entries as already merged."""

    destination = '{"routes":{"shared":{"a":1,"b":2}},"owned":true}\n'
    source = '{"routes":{"shared":{"b":2,"a":1}}}\n'

    merged = merge_additive_routing_documents(
        destination,
        source,
        "config/orchestration-routing.json",
    )

    assert merged == destination


def test_substantive_collisions_fail_in_sorted_reason_order() -> None:
    """Reject changed destination-owned routes before writing any bytes."""

    target = Path("/dest/config/orchestration-routing.json")
    destination = _document(
        {
            "routes": {
                "zeta": {"owner": "destination"},
                "alpha": {"owner": "destination"},
            }
        }
    )
    source = _document(
        {
            "routes": {
                "zeta": {"owner": "source"},
                "alpha": {"owner": "source"},
            }
        }
    )
    inner = MemoryFileSystem({target: destination})
    fs = AdditiveRoutingMergeFileSystem(
        inner,
        destination_root=Path("/dest"),
        merge_relative_path=Path("config/orchestration-routing.json"),
    )

    try:
        fs.write_text(target, source)
    except RoutingMergeConflictError as error:
        assert error.reason_code == "ROUTING_MERGE_SUBSTANTIVE_COLLISION"
        assert error.conflicts == ("routes.alpha", "routes.zeta")
        assert str(error) == (
            "ROUTING_MERGE_SUBSTANTIVE_COLLISION: "
            "/dest/config/orchestration-routing.json: "
            "routes.alpha, routes.zeta"
        )
    else:
        raise AssertionError("Expected a substantive routing collision")
    assert inner.read_text(target) == destination


def test_filesystem_merges_only_the_configured_routing_path() -> None:
    """Delegate unrelated configuration and all non-write protocol operations."""

    routing_path = Path("/dest/config/orchestration-routing.json")
    unrelated_path = Path("/dest/config/blast-radius.json")
    inner = MemoryFileSystem(
        {
            routing_path: _document({"routes": {}}),
            unrelated_path: "destination-owned\n",
        }
    )
    fs = AdditiveRoutingMergeFileSystem(
        inner,
        destination_root=Path("/dest"),
        merge_relative_path=Path("config/orchestration-routing.json"),
    )

    fs.ensure_dir(Path("/dest/config"))
    fs.write_text(unrelated_path, "source-content\n")

    assert fs.list_files(Path("/dest")) == [unrelated_path, routing_path]
    assert fs.is_dir(Path("/dest/config"))
    assert fs.is_file(unrelated_path)
    assert fs.read_text(unrelated_path) == "source-content\n"
