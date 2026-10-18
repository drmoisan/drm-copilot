"""Check platform authority locations without environment reads or real filesystem
I/O."""

from __future__ import annotations

from typing import TYPE_CHECKING, Literal, cast

import pytest
from drm_copilot_discovery.activation_filesystem import RegistryLocation

if TYPE_CHECKING:
    from collections.abc import Callable


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
