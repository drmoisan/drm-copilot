"""Check platform authority locations without environment reads or real filesystem
I/O."""

from __future__ import annotations

import os
from contextlib import contextmanager
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, Literal, cast

import pytest
from drm_copilot_discovery import activation_store
from drm_copilot_discovery.activation_filesystem import NativeRegistry, RegistryLocation

from tests.discovery_runtime.mutation_test_support import MemoryDirectory, MemoryDisk
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog

if TYPE_CHECKING:
    from collections.abc import Callable, Generator
    from contextlib import AbstractContextManager

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_filesystem import Directory


@pytest.mark.parametrize(
    "platform,home,local,state,expected",
    [
        (
            "windows",
            "C:/Users/Example",
            "C:/Users/Example/AppData/Local",
            None,
            "C:/Users/Example/AppData/Local/drm-copilot/discovery",
        ),
        (
            "macos",
            "/Users/example",
            None,
            None,
            "/Users/example/Library/Application Support/drm-copilot/discovery",
        ),
        (
            "linux",
            "/home/example",
            None,
            None,
            "/home/example/.local/state/drm-copilot/discovery",
        ),
        (
            "linux",
            "/home/example",
            None,
            "/trusted/state",
            "/trusted/state/drm-copilot/discovery",
        ),
    ],
)
def test_registry_locations_are_platform_fixed_and_workspace_partitioned(
    platform: str, home: str, local: str | None, state: str | None, expected: str
) -> None:
    """Trusted host values select the mandated registry location without session
    dependence."""
    workspace = "C:/Workspace" if platform == "windows" else "/workspace"
    location = RegistryLocation.for_host(
        workspace_root=workspace,
        platform=cast('Literal["windows", "macos", "linux"]', platform),
        user_home=home,
        local_app_data=local,
        xdg_state_home=state,
    )
    assert location.directory == expected + "/workspaces/" + location.workspace_sha256
    assert len(location.workspace_sha256) == 64
    assert location.workspace == workspace


def test_windows_workspace_hash_uses_canonical_case_and_native_separators() -> None:
    """Case/forward-slash aliases share the existing native authority-store identity."""
    first = RegistryLocation.for_host(
        workspace_root="C:/Workspace",
        platform="windows",
        user_home="C:/Users/Example",
        local_app_data="C:/State",
    )
    second = RegistryLocation.for_host(
        workspace_root="c:\\workspace\\",
        platform="windows",
        user_home="C:/Users/Example",
        local_app_data="C:/State",
    )
    assert first.workspace_sha256 == second.workspace_sha256


@pytest.mark.parametrize(
    "changes",
    [
        {"platform": "other"},
        {"workspace_root": "relative"},
        {"user_home": "relative"},
        {"xdg_state_home": "/workspace"},
        {"xdg_state_home": "/state/../other"},
        {
            "platform": "windows",
            "workspace_root": "C:/Workspace",
            "user_home": "C:/Users/Example",
        },
    ],
)
def test_unsafe_missing_or_internal_host_locations_fail_before_io(
    changes: dict[str, object],
) -> None:
    """Unsupported platforms and workspace-contained authority roots cannot provision
    state."""
    arguments = {
        "workspace_root": "/workspace",
        "platform": "linux",
        "user_home": "/home/example",
        **changes,
    }
    factory: Callable[..., RegistryLocation] = RegistryLocation.for_host
    with pytest.raises(ValueError):
        factory(**arguments)


class RegistryDirectory(MemoryDirectory):
    """Translate missing fake keys into the native file-not-found contract."""

    def read(self, name: str, *, limit: int) -> bytes:
        """Preserve bounded reads and distinguish absent from inaccessible files."""
        if self.name(name) in self.disk.store.failures:
            raise PermissionError("protected record is unreadable")
        try:
            return super().read(name, limit=limit)
        except KeyError as error:
            raise FileNotFoundError(self.name(name)) from error


class RegistryDisk(MemoryDisk):
    """Supply isolated native directory seams without touching a host path."""

    def __init__(self) -> None:
        """Bind the real registry to a fresh synthetic absolute namespace."""
        super().__init__()
        self.location = RegistryLocation.for_host(
            workspace_root=self.root,
            platform="windows" if os.name == "nt" else "linux",
            user_home="C:/users/example" if os.name == "nt" else "/users/example",
            local_app_data="C:/state" if os.name == "nt" else None,
        )
        self.base = "/".join(Path(self.location.directory).parts[1:])
        self.registry = NativeRegistry(
            self.location, opener=self.anchor, nonce=lambda: "owned"
        )

    @contextmanager
    def open(self, path: str = ".") -> Generator[Directory, None, None]:
        """Require existing ordinary directories and unwind every retained handle."""
        if self.store.metadata(path).kind == "missing":
            raise FileNotFoundError(path)
        with super().open(path):
            yield RegistryDirectory(self, path)

    @contextmanager
    def anchor(self, path: Path) -> Generator[Directory, None, None]:
        """Accept only the native root anchor requested by the registry."""
        assert path == Path(Path(self.location.directory).anchor)
        with self.open() as directory:
            yield directory


def test_native_registry_absence_create_replace_and_guard_cleanup() -> None:
    """Protected reads are inert; guarded publication preserves exact bytes."""
    disk = RegistryDisk()
    before = dict(disk.store.metadata.entries)
    assert disk.registry.read() is None
    assert disk.store.metadata.entries == before and disk.held == 0
    with pytest.raises(OSError, match="requires its guard"):
        disk.registry.write(b"first", expected=None)
    with disk.registry.guard():
        assert disk.registry.read() is None
        disk.registry.write(b"first", expected=None)
        assert disk.registry.read() == b"first"
        disk.registry.write(b"second", expected=b"first")
        assert disk.registry.read() == b"second" and disk.held > 0
        with pytest.raises(OSError, match="changed before publication"):
            disk.registry.write(b"stale", expected=b"first")
    assert disk.held == 0 and set(disk.limits) == {65536}
    assert disk.store.files == {disk.base + "/activation.json": b"second"}


def test_concurrent_registry_guards_preserve_the_existing_lock() -> None:
    """Reentry and a second cooperating writer cannot acquire an owned lock."""
    disk = RegistryDisk()
    second = NativeRegistry(disk.location, opener=disk.anchor)
    with disk.registry.guard():
        with pytest.raises(OSError, match="already held"), disk.registry.guard():
            pytest.fail("reentrant guard must not yield")
        with pytest.raises(FileExistsError), second.guard():
            pytest.fail("concurrent guard must not yield")
        assert disk.base + "/mutation.lock" in disk.store.files
    assert disk.held == 0 and not disk.store.files


@pytest.mark.parametrize("failure", ["foreign-stage", "publication", "cleanup"])
def test_registry_write_failures_retain_foreign_bytes_and_bound_cleanup(
    failure: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Only owned stages are cleaned; publication and cleanup errors propagate."""
    disk = RegistryDisk()
    staged = disk.base + "/.activation-owned"
    record = disk.base + "/activation.json"
    with disk.registry.guard():
        if failure == "foreign-stage":
            disk.store.put(staged, b"foreign")
        elif failure == "publication":
            disk.fail_publish = True
        else:
            original = RegistryDirectory.remove

            def failed_cleanup(directory: RegistryDirectory, name: str) -> None:
                """Fail only owned stage cleanup, allowing guard release to finish."""
                if name == ".activation-owned":
                    raise OSError("stage cleanup failed")
                original(directory, name)

            monkeypatch.setattr(RegistryDirectory, "remove", failed_cleanup)
        with pytest.raises(OSError):
            disk.registry.write(b"proposed", expected=None)
        if failure == "foreign-stage":
            assert (
                disk.store.files[staged] == b"foreign"
                and record not in disk.store.files
            )
        elif failure == "publication":
            assert staged not in disk.store.files and record not in disk.store.files
        else:
            assert disk.store.files[record] == b"proposed"
            assert disk.store.files[staged] == b"proposed"
    assert disk.held == 0 and disk.base + "/mutation.lock" not in disk.store.files


@pytest.mark.parametrize("change", ["replacement", "missing"])
def test_retained_registry_ancestor_changes_reject_read_and_write(change: str) -> None:
    """An active guard cannot adopt a replacement or disappear into inactive state."""
    disk = RegistryDisk()
    ancestor = disk.base.split("/")[0]
    with disk.registry.guard():
        if change == "missing":
            disk.store.metadata.remove(ancestor)
        else:
            disk.store.metadata.add(ancestor, kind="directory", identity="replaced")
        with pytest.raises(OSError, match="identity changed|disappeared"):
            disk.registry.read()
        with pytest.raises(OSError, match="identity changed|disappeared"):
            disk.registry.write(b"unpublished", expected=None)
        assert disk.base + "/activation.json" not in disk.store.files
    assert disk.held == 0


@pytest.mark.parametrize("failure", ["unreadable", "oversized"])
def test_native_registry_read_errors_cannot_become_absent(failure: str) -> None:
    """Unreadable or oversized protected state remains a blocking I/O error."""
    disk = RegistryDisk()
    record = disk.base + "/activation.json"
    disk.store.put(record, b"x" * 65537 if failure == "oversized" else b"record")
    if failure == "unreadable":
        disk.store.failures.add(record)
    with pytest.raises(OSError):
        disk.registry.read()
    assert disk.held == 0 and disk.store.files[record]


@pytest.mark.parametrize("condition", ["canonical", "alias", "internal"])
def test_local_factory_requires_canonical_external_host_locations(
    config_catalog: SchemaCatalog, condition: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Trusted composition validates host paths and wires the shared native guard."""
    disk = RegistryDisk()
    location = disk.location
    if condition == "internal":
        location = replace(location, directory=location.workspace + "/state")

    def resolved(path: Path, **_options: object) -> Path:
        """Inject canonical resolution without consulting the real filesystem."""
        return path / "resolved" if condition == "alias" else path

    def opened(path: Path) -> AbstractContextManager[Directory]:
        """Keep the factory's workspace opener anchored to the test-local disk."""
        assert path == Path(location.workspace)
        return disk.open()

    monkeypatch.setattr(Path, "resolve", resolved)
    monkeypatch.setattr(activation_store, "open_local_directory", opened)
    if condition != "canonical":
        with pytest.raises(ValueError):
            activation_store.ActivationStore.local(
                location=location,
                catalog=config_catalog,
                authorize_root=lambda: None,
                invalidate_authority=lambda: None,
            )
        return
    service = activation_store.ActivationStore.local(
        location=location,
        catalog=config_catalog,
        authorize_root=lambda: None,
        invalidate_authority=lambda: None,
    )
    assert service.location == location and isinstance(service.registry, NativeRegistry)
    with service.open_directory() as directory:
        assert directory.identity() == "root"
    assert disk.held == 0 and not disk.store.files
