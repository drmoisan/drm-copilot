"""Verify explicit adapter selection and immutable input construction boundaries."""

from __future__ import annotations

import builtins
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.findings import diagnostic, row, source_reference
from drm_copilot_discovery.analyzer.models import (
    Analysis,
    InventoryCapture,
    InventoryInput,
)
from drm_copilot_discovery.analyzer.registry import select_analyzers
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import ProfileError, ProfileV2
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import (
    inventory_capture,
    inventory_profile,
)

if TYPE_CHECKING:
    from types import ModuleType
    from typing import Literal

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject


def test_registry_loads_only_explicit_core_adapters(
    analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Selecting core inventory performs no optional imports or executable dispatch.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture. monkeypatch (pytest.MonkeyPatch): isolated patches restored by pytest.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    profile = inventory_profile(analyzer_catalog)

    original_import = builtins.__import__
    seen: list[str] = []

    def observe_import(
        name: str,
        globals: dict[str, object] | None = None,
        locals: dict[str, object] | None = None,
        fromlist: tuple[str, ...] = (),
        level: int = 0,
    ) -> ModuleType:
        """Allow core typed views while observing any optional adapter import.

        Parameters: name (str): requested import name. globals (dict[str, object] |
        None): forwarded import global namespace. locals (dict[str, object] | None):
        forwarded import local namespace. fromlist (tuple[str, ...]): forwarded
        imported members. level (int): forwarded relative-import depth.

        Returns ModuleType from the original importer. Raises AssertionError for
        optional adapters; records names and uses the ordinary import cache.
        """
        seen.append(name)
        # Core profile views are allowed; optional adapter imports remain observable.
        assert not any(token in name for token in ("dotnet", "vsto", "lxml"))
        return original_import(name, globals, locals, fromlist, level)

    with monkeypatch.context() as context:
        context.setattr(builtins, "__import__", observe_import)
        selected = select_analyzers(profile)
    assert [adapter.identifier for adapter in selected] == ["repository"]
    assert seen and set(seen) == {"drm_copilot_discovery.profile_v2"}


@pytest.mark.parametrize("enabled", [[], ["dotnet"], ["repository", "csharp-symbols"]])
def test_registry_rejects_unavailable_selections_without_fallback(
    analyzer_catalog: SchemaCatalog, enabled: list[str]
) -> None:
    """Unimplemented adapter identifiers never silently produce a partial inventory.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture. enabled (list[str]): explicit configured adapter names.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    profile = inventory_profile(
        analyzer_catalog,
        analyzers={
            "enabled": enabled,
            "options": {},
            "ignored_paths": [],
            "extension_result_manifests": [],
        },
    )
    with pytest.raises(ValueError, match="Unavailable analyzer"):
        select_analyzers(profile)


@pytest.mark.parametrize(
    "status,rationale,file",
    [
        ("bad", None, None),
        ("inspected", None, None),
        (
            "inspected",
            "Not allowed",
            SnapshotFile(path="src/a", content=b"a", category="source"),
        ),
        ("excluded", None, None),
        ("unreadable", " ", None),
        (
            "excluded",
            "Excluded",
            SnapshotFile(path="src/a", content=b"a", category="source"),
        ),
    ],
)
def test_input_model_rejects_dishonest_or_ambiguous_accounting(
    status: str, rationale: str | None, file: SnapshotFile | None
) -> None:
    """Only inspected inputs carry bytes; every unavailable input has a reason.

    Parameters: status (str): requested input state, including invalid cases.
    rationale (str | None): authored unavailable-input reason. file (SnapshotFile |
    None): optional retained source bytes.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    with pytest.raises(ValueError):
        InventoryInput(
            path="src/a",
            status=cast("Literal['inspected', 'excluded', 'unreadable']", status),
            rationale=rationale,
            file=file,
        )


def test_models_reject_untyped_rows_profile_inputs_and_collisions(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Unsafe caller-constructed values cannot bypass the immutable analyzer
    boundary.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    capture = inventory_capture(analyzer_catalog)
    with pytest.raises(ValueError, match="validated profile"):
        InventoryCapture(profile=cast("ProfileV2", object()), inputs=())
    with pytest.raises(ValueError, match="typed captured"):
        replace(capture, inputs=cast("tuple[InventoryInput, ...]", (object(),)))
    with pytest.raises(PathPolicyError):
        replace(capture, inputs=(capture.inputs[0], capture.inputs[0]))
    with pytest.raises(ValueError, match="immutable JSON"):
        Analysis(components=cast("tuple[JsonObject, ...]", ({},)))
    with pytest.raises(ValueError, match="inspected captured bytes"):
        source_reference(
            capture,
            InventoryInput(path="src/no", status="excluded", rationale="Excluded."),
        )
    assert (
        diagnostic("notice", None, "Review this input.", blocking=False)["severity"]
        == "warning"
    )


def test_draft_and_input_count_limits_fail_closed(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Incomplete configuration and excessive selected files cannot reach adapters.

    Parameters: analyzer_catalog (SchemaCatalog): immutable installed schema
    fixture.

    Returns None. Raises AssertionError when the asserted contract differs; uses
    only test-local memory and immutable schema fixtures.
    """
    draft = inventory_profile(analyzer_catalog, profile_state="draft")
    with pytest.raises(ProfileError):
        InventoryCapture(profile=draft, inputs=())
    profile = inventory_profile(analyzer_catalog, limits={"source_files": 1})
    # Both typed rows are valid individually but exceed the configured total budget.
    inputs = tuple(
        InventoryInput(path=name, status="excluded", rationale="Excluded.")
        for name in ("src/a", "src/b")
    )
    with pytest.raises(ValueError, match="input count"):
        InventoryCapture(profile=profile, inputs=inputs)
    assert Analysis(components=(row(id="one"),)).components == (row(id="one"),)
