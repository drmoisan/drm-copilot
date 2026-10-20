"""Real-bundle dependency closure of the Claude and Codex pack manifests (issue #984).

Purpose:
    A destination that selects pack P receives the paths of `core` plus P
    (Codex also receives the `VIRTUAL_RESOURCE_PAIRS` destinations). A
    manifested PowerShell file that reaches a sibling through `$PSScriptRoot`,
    or a manifested settings, agent, or TOML file that names a hook script,
    fails in that destination when the target is outside that effective set.
    Issue #984 shipped `.claude/hooks/enforce-completion-consistency.ps1` in
    core without its dot-sourced helper, which denied every edit downstream.

Approach:
    Reads the real bundles and manifests from disk, like the completeness
    tests beside it, and applies the pure scanners in
    `tests/scripts/dev_tools/pack_manifest_dependency_scan.py`. Pack
    combination and the core-only published set come from the authoritative
    Python ports (`push_down_claude_pack_selection`,
    `push_down_codex_pack_selection`), not from restated constants. Every
    assertion compares sets and names each missing member.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools import push_down_claude_pack_selection as claude_packs
from scripts.dev_tools import push_down_codex_pack_selection as codex_packs
from scripts.dev_tools.push_down_codex_and_agents_customizations import (
    VIRTUAL_RESOURCE_PAIRS,
)
from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
    RealPushDownFileSystem,
)
from tests.scripts.dev_tools.pack_manifest_dependency_scan import (
    CODEX_ROUTING_MODULE_CANDIDATES,
    HookCommandSource,
    extract_hook_command_paths,
    find_missing_dependencies,
    find_unrecognized_psscriptroot,
)

if TYPE_CHECKING:
    from collections.abc import Callable

REPO_ROOT = Path(__file__).resolve().parents[3]
RESOURCES_ROOT = REPO_ROOT / "extensions" / "drm-copilot" / "resources"
CLAUDE_BUNDLE_ROOT = RESOURCES_ROOT / "claude-customizations"
CODEX_BUNDLE_ROOT = RESOURCES_ROOT / "codex-and-agents-customizations"
POWERSHELL_SUFFIXES = (".ps1", ".psm1")

ISSUE_984_CLAUDE_CORE_PATHS = (
    ".claude/hooks/enforce-completion-helpers.ps1",
    ".claude/agents/pr-author.md",
    ".claude/hooks/validate-pr-author-output.ps1",
    ".claude/hooks/check-python-test-purity.ps1",
    ".claude/hooks/enforce-python-batch-budget.ps1",
    ".claude/hooks/check-powershell-test-purity.ps1",
    ".claude/hooks/enforce-powershell-batch-budget.ps1",
)
ISSUE_984_CODEX_CORE_PATHS = (
    ".codex/hooks/enforce-completion-helpers.ps1",
    ".codex/scripts/post-codex-worktree-session.ps1",
)
CLAUDE_SCAN_ANCHOR = ".claude/hooks/enforce-completion-consistency.ps1"
CODEX_SCAN_ANCHOR = ".codex/hooks/enforce-completion-consistency.ps1"


@dataclass(frozen=True)
class Surface:
    """One bundle surface: its manifests, core name, and virtual resources.

    Attributes:
        bundle_root (Path): Bundle directory that holds `pack-manifests/`.
        core_name (str): The always-included pack name for the surface.
        manifests (dict[str, tuple[str, ...]]): Pack name to its `paths`.
        prefixed (frozenset[str]): Packs that read from a `source_prefix`.
        virtual (dict[str, Path]): Virtual destination to its resource file.
    """

    bundle_root: Path
    core_name: str
    manifests: dict[str, tuple[str, ...]]
    prefixed: frozenset[str]
    virtual: dict[str, Path]

    def effective(self, pack: str) -> frozenset[str]:
        """Return the paths a destination receives when ``pack`` is selected.

        Args:
            pack (str): A manifest name of this surface.

        Returns:
            frozenset[str]: Core paths, the pack's paths, and the virtual
            destinations.
        """

        return frozenset(
            (*self.manifests[self.core_name], *self.manifests[pack], *self.virtual)
        )

    def read(self, relative_path: str) -> str:
        """Return the text of one published path, virtual or bundled.

        Args:
            relative_path (str): Destination-relative POSIX path.

        Returns:
            str: The UTF-8 file text.
        """

        source = self.virtual.get(relative_path, self.bundle_root / relative_path)
        return source.read_text(encoding="utf-8")

    def powershell_sources(self) -> dict[str, list[str]]:
        """Return each pack's PowerShell sources; core also owns the virtual set.

        Returns:
            dict[str, list[str]]: Pack name to its `.ps1`/`.psm1` paths.

        Raises:
            AssertionError: When a `source_prefix` pack lists a PowerShell
                file, which this test does not resolve.
        """

        sources: dict[str, list[str]] = {}
        # Collect the PowerShell paths of every manifest of the surface.
        for pack, paths in self.manifests.items():
            listed = [path for path in paths if path.endswith(POWERSHELL_SUFFIXES)]
            assert not (listed and pack in self.prefixed), (
                f"{pack} reads from a source_prefix and lists PowerShell files "
                f"{listed}; extend this closure test to resolve them"
            )
            # Virtual resources are published under every selection, so core
            # owns their PowerShell sources.
            if pack == self.core_name:
                listed.extend(
                    path for path in self.virtual if path.endswith(POWERSHELL_SUFFIXES)
                )
            sources[pack] = sorted(listed)
        return sources


def _load_surface(
    bundle_root: Path, core_name: str, virtual: dict[str, Path]
) -> Surface:
    """Load every `pack-manifests/*.json` of a bundle into a ``Surface``.

    Args:
        bundle_root (Path): Bundle directory.
        core_name (str): The surface's core pack name.
        virtual (dict[str, Path]): Virtual destination to resource file.

    Returns:
        Surface: The loaded surface.
    """

    manifests: dict[str, tuple[str, ...]] = {}
    prefixed: set[str] = set()
    # Read each manifest file; the file stem is the pack name.
    for manifest_file in sorted((bundle_root / "pack-manifests").glob("*.json")):
        document = cast(
            "dict[str, object]", json.loads(manifest_file.read_text(encoding="utf-8"))
        )
        paths = cast("list[str]", document["paths"])
        manifests[manifest_file.stem] = tuple(paths)
        if document.get("source_prefix") is not None:
            prefixed.add(manifest_file.stem)
    return Surface(bundle_root, core_name, manifests, frozenset(prefixed), virtual)


def claude_surface() -> Surface:
    """Return the Claude bundle surface (no virtual resources).

    Returns:
        Surface: The Claude surface.
    """

    return _load_surface(CLAUDE_BUNDLE_ROOT, claude_packs.CORE_PACK_NAME, {})


def codex_surface() -> Surface:
    """Return the Codex bundle surface with its virtual resources.

    Returns:
        Surface: The Codex surface; virtual resources are read from their
        path under `extensions/drm-copilot/resources`.
    """

    # Map each virtual destination to the resource file it is published from.
    virtual = {
        destination.as_posix(): RESOURCES_ROOT / resource
        for destination, resource in VIRTUAL_RESOURCE_PAIRS
    }
    return _load_surface(CODEX_BUNDLE_ROOT, codex_packs.CORE_PACK_NAME, virtual)


def _closure_gaps(surface: Surface) -> list[str]:
    """Return one message per missing `$PSScriptRoot` dependency of a surface.

    Args:
        surface (Surface): The surface to check.

    Returns:
        list[str]: ``<pack>: <source> -> <target>`` messages.
    """

    gaps: list[str] = []
    # Check every pack's sources against that pack's effective set.
    for pack, sources in sorted(surface.powershell_sources().items()):
        texts = {source: surface.read(source) for source in sources}
        for source, target in find_missing_dependencies(texts, surface.effective(pack)):
            gaps.append(f"{pack}: {source} -> {target}")
    return gaps


def _scan_floor_gaps(
    label: str, scanned: set[str], expected: set[str], anchor: str
) -> list[str]:
    """Return one message per defect of a surface's scanned PowerShell set.

    Args:
        label (str): Surface name used in every message.
        scanned (set[str]): Sources the scanner actually visits.
        expected (set[str]): Sources derived independently from the manifests.
        anchor (str): A source known to carry a `$PSScriptRoot` dependency.

    Returns:
        list[str]: A missing-anchor message and a mismatch message (naming the
        missing and extra members) when each applies; empty when clean.
    """

    gaps: list[str] = []
    # Two independent defects: a dropped anchor source, and any drift between
    # the scanned set and the manifest-derived set (a silently narrowed scan).
    if anchor not in scanned:
        gaps.append(f"{label}: anchor {anchor} is not scanned")
    if scanned != expected:
        missing = sorted(expected - scanned)
        extra = sorted(scanned - expected)
        gaps.append(
            f"{label}: scanned {len(scanned)} sources, expected {len(expected)}; "
            f"missing {missing}; extra {extra}"
        )
    return gaps


def test_scan_floor_gaps_reports_each_defect() -> None:
    """The helper is silent when clean and names label, anchor, and mismatch."""

    anchor = "hooks/a.ps1"
    full = {anchor, "hooks/b.ps1"}

    assert _scan_floor_gaps("demo", full, full, anchor) == []

    missing_anchor = _scan_floor_gaps("demo", {"hooks/b.ps1"}, {"hooks/b.ps1"}, anchor)
    assert len(missing_anchor) == 1
    assert "demo" in missing_anchor[0] and anchor in missing_anchor[0]

    mismatch = _scan_floor_gaps("demo", {anchor}, full | {"hooks/c.ps1"}, anchor)
    assert len(mismatch) == 1
    assert "demo" in mismatch[0]
    assert "hooks/b.ps1" in mismatch[0] and "hooks/c.ps1" in mismatch[0]


def test_scanned_source_floor() -> None:
    """Scan every manifested PowerShell source, including the surface anchor."""

    gaps: list[str] = []
    # Compare each surface's scanned set with the distinct PowerShell entries of
    # its manifests and virtual resources, and require its anchor source.
    for label, surface, anchor in (
        ("claude", claude_surface(), CLAUDE_SCAN_ANCHOR),
        ("codex", codex_surface(), CODEX_SCAN_ANCHOR),
    ):
        scanned = {s for paths in surface.powershell_sources().values() for s in paths}
        expected = {
            path
            for path in (
                *surface.virtual,
                *(p for m in surface.manifests.values() for p in m),
            )
            if path.endswith(POWERSHELL_SUFFIXES)
        }
        gaps.extend(_scan_floor_gaps(label, scanned, expected, anchor))
    assert gaps == []


def _narrowed_to(kept: str) -> Callable[[Surface], dict[str, list[str]]]:
    """Return a ``Surface.powershell_sources`` stand-in that scans one source.

    Args:
        kept (str): The only PowerShell source the stand-in reports.

    Returns:
        Callable[[Surface], dict[str, list[str]]]: A method replacement that
        maps the core pack to ``kept``.
    """

    def narrowed(_surface: Surface) -> dict[str, list[str]]:
        """Report only ``kept`` under the core pack."""

        return {"core": [kept]}

    return narrowed


def test_scanned_source_floor_rejects_narrowed_scan(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A scan narrowed to one non-anchor source per surface fails the floor."""

    # Narrow each surface in turn to a single source that is not its anchor.
    for surface, anchor in (
        (claude_surface(), CLAUDE_SCAN_ANCHOR),
        (codex_surface(), CODEX_SCAN_ANCHOR),
    ):
        full = surface.powershell_sources()
        survivor = next(s for paths in full.values() for s in paths if s != anchor)
        monkeypatch.setattr(Surface, "powershell_sources", _narrowed_to(survivor))
        with pytest.raises(AssertionError):
            test_scanned_source_floor()
        monkeypatch.undo()


def test_claude_manifest_powershell_dependency_closure() -> None:
    """Every Claude `$PSScriptRoot` dependency is in core plus the owning pack."""

    assert _closure_gaps(claude_surface()) == []


def test_codex_manifest_powershell_dependency_closure() -> None:
    """Every Codex `$PSScriptRoot` dependency is in core plus the owning pack.

    The effective set also holds the `VIRTUAL_RESOURCE_PAIRS` destinations.
    """

    assert _closure_gaps(codex_surface()) == []


def test_every_psscriptroot_occurrence_is_recognized() -> None:
    """Every `$PSScriptRoot` occurrence in a scanned source matches a named form."""

    unrecognized: list[str] = []
    # Apply the exhaustiveness guard to every scanned source of both surfaces.
    for surface in (claude_surface(), codex_surface()):
        scanned = {s for paths in surface.powershell_sources().values() for s in paths}
        for source in sorted(scanned):
            unrecognized.extend(
                f"{source}: {line}"
                for line in find_unrecognized_psscriptroot(surface.read(source))
            )
    assert unrecognized == []


def test_codex_routing_module_candidates_are_in_codex_core() -> None:
    """The F8 dynamic routing-module candidates are published by Codex core."""

    surface = codex_surface()
    effective = surface.effective(surface.core_name)
    assert [c for c in CODEX_ROUTING_MODULE_CANDIDATES if c not in effective] == []


def _command_gaps(
    surface: Surface,
    source: str,
    kind: HookCommandSource,
    pack: str,
    read_path: str | None = None,
) -> list[str]:
    """Return one message per hook named by ``source`` outside ``E(pack)``.

    Args:
        surface (Surface): The surface that holds ``source``.
        source (str): Destination-relative path of the command-bearing file.
        kind (HookCommandSource): ``settings``, ``frontmatter``, or ``toml``.
        pack (str): The manifest whose effective set must hold the hooks.
        read_path (str | None): Bundle-relative path to read when it differs
            from ``source`` (a variant source); ``None`` reads ``source``.

    Returns:
        list[str]: ``<pack>: <source> names <hook>`` messages.
    """

    hooks = extract_hook_command_paths(surface.read(read_path or source), kind)
    effective = surface.effective(pack)
    return [f"{pack}: {source} names {hook}" for hook in hooks if hook not in effective]


def test_claude_command_text_closure() -> None:
    """Hooks named by settings and manifested agent frontmatter are published.

    `.claude/settings.json` is checked against `E(core)`; each manifested
    `.claude/agents/*.md` is checked against the effective set of every
    manifest that lists it.
    """

    surface = claude_surface()
    gaps = _command_gaps(
        surface, ".claude/settings.json", "settings", surface.core_name
    )
    # Check each manifested agent's frontmatter hooks against its listing pack.
    for pack, paths in sorted(surface.manifests.items()):
        for agent in sorted(p for p in paths if p.startswith(".claude/agents/")):
            # A source_prefix pack (csharp-legacy) publishes its agents from
            # the legacy variant tree, so the variant source is read instead.
            read_path = (
                claude_packs.resolve_variant_source_path(agent, "legacy")
                if pack in surface.prefixed
                else agent
            )
            gaps.extend(_command_gaps(surface, agent, "frontmatter", pack, read_path))
    assert gaps == []


def test_codex_command_text_closure() -> None:
    """Hooks named by the bundled `.codex/config.toml` are published by core."""

    surface = codex_surface()
    assert _command_gaps(surface, ".codex/config.toml", "toml", surface.core_name) == []


@pytest.mark.parametrize("expected_path", ISSUE_984_CLAUDE_CORE_PATHS)
def test_core_only_selection_publishes_issue_984_path(expected_path: str) -> None:
    """A Claude push-down that selects only core publishes each issue #984 path."""

    selection = frozenset({claude_packs.CORE_PACK_NAME})
    manifests = claude_packs.load_pack_manifests(
        CLAUDE_BUNDLE_ROOT / "pack-manifests", selection, RealPushDownFileSystem()
    )
    published = claude_packs.compute_published_paths(selection, manifests)
    assert published is not None
    assert expected_path in published, f"core-only push-down omits {expected_path}"


@pytest.mark.parametrize("expected_path", ISSUE_984_CODEX_CORE_PATHS)
def test_codex_core_selection_publishes_issue_984_path(expected_path: str) -> None:
    """A Codex push-down that selects only core publishes each issue #984 path."""

    selection = frozenset({codex_packs.CORE_PACK_NAME})
    manifests = codex_packs.load_pack_manifests(
        CODEX_BUNDLE_ROOT / "pack-manifests", selection, RealPushDownFileSystem()
    )
    published = codex_packs.compute_published_paths(selection, manifests)
    assert published is not None
    assert expected_path in published, f"core-only push-down omits {expected_path}"
