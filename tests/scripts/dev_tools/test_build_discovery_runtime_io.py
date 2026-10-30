"""Cover staging CLI and filesystem/process boundaries with injected memory."""

from __future__ import annotations

import hashlib
import json
import stat
from dataclasses import dataclass
from pathlib import Path

import pytest
from drm_copilot_discovery.models import ParseLimits

from scripts.dev_tools import build_discovery_runtime as build
from tests.scripts.dev_tools.test_build_discovery_runtime import MemoryFileSystem
from tests.scripts.dev_tools.test_discovery_build_identity import (
    memory_build_metadata as memory_build_metadata,
)


@dataclass(frozen=True)
class FakeBuildResult:
    """Represent a process result without importing or starting a process."""

    returncode: int
    stdout: str
    stderr: str


@pytest.mark.parametrize(
    "kind", ("valid", "root-link", "child-link", "count", "depth", "other")
)
def test_build_source_enumeration_is_prospectively_bounded(
    kind: str,
    mem_fs_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    memory_build_metadata: dict[str, tuple[int, int]],
) -> None:
    """kind (str), memory Path and monkeypatch isolate bounded package traversal.

    memory_build_metadata (dict[str,tuple[int,int]]) controls mode/reparse flags.
    Returns None; assertions may fail. Only memory metadata is read or changed.
    """
    target = mem_fs_path / build.SOURCE_ROOT / "nested" / "source.py"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(b"")

    if kind == "root-link":
        memory_build_metadata[str(mem_fs_path)] = (stat.S_IFLNK, 0)
    elif kind in ("child-link", "other"):
        memory_build_metadata[str(target)] = (
            stat.S_IFLNK if kind == "child-link" else 0,
            0,
        )
    limits = ParseLimits(
        artifact_records=1 if kind == "count" else 100,
        nesting_depth=1 if kind == "depth" else 10,
    )
    filesystem = build.DiskBuildFileSystem(mem_fs_path)
    if kind == "valid":
        assert filesystem.list_build_files(limits=limits) == (
            f"{build.SOURCE_ROOT}/nested/source.py",
        )
    else:
        with pytest.raises(ValueError, match="Linked|Unsupported|limits"):
            filesystem.list_build_files(limits=limits)


def test_disk_boundary_reads_lists_and_writes_only_generated_paths(
    mem_fs_path: Path,
) -> None:
    """Check writes/limits with mem_fs_path (Path) backed entirely by memory.

    Returns None; assertions may fail. Only fixture-owned memory changes.
    """
    filesystem = build.DiskBuildFileSystem(mem_fs_path)
    output = f"{build.STAGE_ROOT}/schemas/example.json"
    filesystem.write_bytes(output, b"{}\n")
    assert filesystem.read_bytes(output) == b"{}\n"
    assert filesystem.read_bounded(output, limit=3) == b"{}\n"
    assert filesystem.list_files(build.STAGE_ROOT) == (output,)
    with pytest.raises(build.ResourceError, match="restricted"):
        filesystem.write_bytes("src/code.py", b"changed")
    with pytest.raises(build.ResourceError, match="unsafe"):
        filesystem.read_bytes("schemas/../outside")
    with pytest.raises(build.ResourceError, match="exceeds"):
        filesystem.read_bounded(output, limit=2)
    with pytest.raises(build.ResourceError, match="Invalid"):
        filesystem.read_bounded(output, limit=-1)
    filesystem.write_bytes(build.BUILD_MANIFEST_PATH, b"{}\n")
    assert filesystem.read_bytes(build.BUILD_MANIFEST_PATH) == b"{}\n"


def test_resolved_path_escape_is_rejected(
    mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A symlink-like resolved path cannot escape the declared build repository."""
    original = Path.resolve

    def resolve(path: Path, strict: bool = False) -> Path:
        if path == mem_fs_path / "schemas/escape":
            return mem_fs_path.parent / "outside"
        return original(path, strict=strict)

    monkeypatch.setattr(Path, "resolve", resolve)
    with pytest.raises(build.ResourceError, match="outside the repository"):
        build.DiskBuildFileSystem(mem_fs_path).read_bytes("schemas/escape")


@pytest.mark.parametrize("status", ("success", "failure", "missing-wheel"))
def test_wheel_build_uses_validated_interpreter_and_offline_flags(
    status: str, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Mock the process boundary and keep all output bytes in memory."""
    output = mem_fs_path / "dist"
    wheel = output / f"drm_copilot_discovery-{build.__version__}-py3-none-any.whl"
    calls: list[list[str]] = []

    def run(
        arguments: list[str], *, capture_output: bool, text: bool, check: bool
    ) -> FakeBuildResult:
        assert capture_output and text and not check
        calls.append(arguments)
        if status == "success":
            wheel.write_bytes(b"wheel")
        return FakeBuildResult(
            1 if status == "failure" else 0,
            "build output",
            "backend unavailable" if status == "failure" else "",
        )

    def verified_executable(_: str) -> str:
        return "/verified/python"

    monkeypatch.setattr(build.shutil, "which", verified_executable)
    monkeypatch.setattr(build.subprocess, "run", run)
    if status == "success":
        assert build.build_wheel(mem_fs_path, output) == wheel
    else:
        with pytest.raises(
            build.ResourceError, match="Wheel build failed|expected wheel"
        ):
            build.build_wheel(mem_fs_path, output)
    assert calls == [
        [
            "/verified/python",
            "-m",
            "pip",
            "wheel",
            "--no-index",
            "--no-deps",
            "--no-build-isolation",
            "--wheel-dir",
            str(output),
            str(mem_fs_path / build.PACKAGE_ROOT),
        ]
    ]


def test_missing_python_prevents_build(
    mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """No process runs when the active interpreter cannot be validated."""

    def missing_executable(_: str) -> None:
        return None

    monkeypatch.setattr(build.shutil, "which", missing_executable)
    with pytest.raises(build.ResourceError, match="executable is unavailable"):
        build.build_wheel(mem_fs_path, mem_fs_path / "dist")


def test_cli_build_reports_wheel_digest_with_injected_builder(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Check distinct digests using mem_fs_path (Path) and capsys (CaptureFixture).

    Returns None; assertions may fail. Local memory and captured output change;
    the injected wheel callback starts no process and performs no disk I/O.
    """
    calls: list[tuple[Path, Path]] = []

    def wheel_builder(repository: Path, output: Path) -> Path:
        calls.append((repository, output))
        return output / "runtime.whl"

    code = build.main(
        ["--repository", str(mem_fs_path), "--output", "wheels"],
        filesystem=MemoryFileSystem(),
        wheel_builder=wheel_builder,
        read_wheel=lambda _: b"wheel",
    )
    assert code == 0
    assert calls == [(mem_fs_path.resolve(), mem_fs_path.resolve() / "wheels")]
    report = json.loads(capsys.readouterr().out)
    assert report["wheel"] == "runtime.whl"
    assert report["wheel_sha256"] == hashlib.sha256(b"wheel").hexdigest()
    assert report["build_sha256"] != report["wheel_sha256"]
    assert report["policy_version"] == 2


def test_cli_stage_and_check_never_build(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Explicit staging and read-only checks do not invoke packaging processes."""
    filesystem = MemoryFileSystem()

    def forbidden_build(repository: Path, output: Path) -> Path:
        pytest.fail("build was not requested")

    common = ["--repository", str(mem_fs_path), "--output", str(mem_fs_path / "wheels")]
    assert (
        build.main(
            [*common, "--stage-only"],
            filesystem=filesystem,
            wheel_builder=forbidden_build,
        )
        == 0
    )
    assert (
        build.main(
            [*common, "--check"], filesystem=filesystem, wheel_builder=forbidden_build
        )
        == 0
    )
    assert "wheel_sha256" not in capsys.readouterr().out


def test_cli_reports_read_failure_and_nonzero_exit(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Missing configuration remains a blocking, actionable CLI error."""
    filesystem = MemoryFileSystem()
    del filesystem.content[build.ALLOWLIST_PATH]
    assert (
        build.main(["--repository", str(mem_fs_path), "--check"], filesystem=filesystem)
        == 1
    )
    assert "Discovery runtime build:" in capsys.readouterr().err


def test_cli_default_disk_boundary_is_injected(
    mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """The default boundary delegates to the supplied repository root."""
    filesystem = MemoryFileSystem()
    seen: list[Path] = []

    def boundary(root: Path) -> MemoryFileSystem:
        seen.append(root)
        return filesystem

    monkeypatch.setattr(build, "DiskBuildFileSystem", boundary)
    assert build.main(["--repository", str(mem_fs_path), "--stage-only"]) == 0
    assert seen == [mem_fs_path.resolve()]
