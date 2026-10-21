"""Exercise trusted state canonicalization through the real store constructor."""

from __future__ import annotations

from pathlib import Path
from types import SimpleNamespace
from typing import TYPE_CHECKING, NoReturn

import pytest
from drm_copilot_discovery import activation_store, gateway_local, mutation_filesystem
from drm_copilot_discovery.activation_filesystem import NativeRegistry, RegistryLocation
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.service_contracts import ServiceRequest

from tests.discovery_runtime.test_configuration import config_catalog as config_catalog

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.gateway_local import LocalServiceIO


class FactoryCase:
    """Model native path resolution for one isolated factory invocation.

    Tests populate aliases, missing paths or errors, then compose the real local
    store. Resolution records distinguish required workspace existence from absent
    state support. No filesystem is consulted; denied ports fail before effects.
    Mutable mappings and observation lists belong only to this test instance.
    """

    def __init__(self) -> None:
        """Create fixed native-flavor paths and empty observations; return None.

        Pure lexical Path operations select the current platform flavor. No host
        environment, current directory, filesystem or external process is read.
        """
        windows = Path("C:/").is_absolute()
        anchor = Path("C:/") if windows else Path("/")
        self.platform = "windows" if windows else "linux"
        self.root, self.home, self.base = (
            anchor / "workspace",
            anchor / "user",
            anchor / "state",
        )
        self.canonical_base = anchor / "canonical-state"
        self.location = RegistryLocation.for_host(
            workspace_root=self.root.as_posix(),
            platform="windows" if windows else "linux",
            user_home=self.home.as_posix(),
            local_app_data=self.base.as_posix(),
            xdg_state_home=self.base.as_posix(),
        )
        self.state = Path(self.location.directory)
        self.aliases: dict[Path, Path] = {}
        self.errors: dict[Path, OSError] = {}
        self.missing: set[Path] = set()
        self.answers: dict[Path, list[Path]] = {}
        self.resolutions: list[tuple[Path, bool]] = []
        self.effects: list[str] = []

    def resolve(self, path: Path, *, strict: bool) -> Path:
        """Resolve path (Path) through test-local metadata; strict requires presence.

        Return the configured canonical Path and record the read. OSError entries
        and strict missing paths raise unchanged; no actual filesystem is touched.
        """
        self.resolutions.append((path, strict))
        if path in self.errors:
            raise self.errors[path]
        if strict and path in self.missing:
            raise FileNotFoundError("Synthetic missing path")
        if self.answers.get(path):
            return self.answers[path].pop(0)
        # Prefer the most specific alias so tests can model a redirected partition.
        for source in sorted(
            self.aliases, key=lambda item: len(item.parts), reverse=True
        ):
            if path == source or source in path.parents:
                return self.aliases[source] / path.relative_to(source)
        return path

    def deny(self, *_args: object, **_kwargs: object) -> NoReturn:
        """Reject any native port call; object arguments are deliberately ignored.

        Record the attempted effect and raise AssertionError; no I/O is performed
        and no value is returned. Construction may retain these ports but not call.
        """
        self.effects.append("forbidden-port")
        raise AssertionError("Construction must not invoke a native port")

    def compose(self, *, principal: str = "local-user") -> LocalServiceIO:
        """Construct installed ports for this root and principal (str).

        Return LocalServiceIO from the real factory/store composition; propagate
        its validation/resolution errors. Only injected memory reads may occur.
        """
        return gateway_local.installed_local_io(
            self.root.as_posix(), None, principal, "test-user"
        )


@pytest.fixture
def factory_case(
    config_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> FactoryCase:
    """Bind real constructors to memory-only native seams for one test.

    config_catalog (SchemaCatalog) supplies immutable schemas; monkeypatch
    (pytest.MonkeyPatch) restores every seam. Return FactoryCase; assertions
    reject unexpected native calls. No service/store constructor is replaced.
    """
    case = FactoryCase()

    def resolve(path: Path, strict: bool = False) -> Path:
        """Read fake metadata for path (Path), honoring strict (bool); return Path.

        Propagate modeled resolution errors; only case observations are mutated.
        """
        return case.resolve(path, strict=strict)

    def home(cls: type[Path]) -> Path:
        """Return a fixed home as cls (type[Path]); no environment or I/O access."""
        return cls(case.home)

    def catalog() -> SchemaCatalog:
        """Return the exact immutable schema fixture without installed I/O."""
        return config_catalog

    monkeypatch.setattr(Path, "resolve", resolve)
    monkeypatch.setattr(Path, "home", classmethod(home))
    monkeypatch.setattr(gateway_local, "load_catalog", catalog)
    monkeypatch.setattr(gateway_local, "sys", SimpleNamespace(platform="linux"))
    monkeypatch.setenv("LOCALAPPDATA", case.base.as_posix())
    monkeypatch.setenv("XDG_STATE_HOME", case.base.as_posix())
    # Reject effects at the native ports while keeping all constructors real.
    monkeypatch.setattr(activation_store, "open_local_directory", case.deny)
    monkeypatch.setattr(mutation_filesystem, "open_local_directory", case.deny)
    monkeypatch.setattr(mutation_filesystem, "exclusive_workspace_lock", case.deny)
    monkeypatch.setattr(NativeRegistry, "guard", case.deny)
    monkeypatch.setattr(NativeRegistry, "write", case.deny)
    monkeypatch.setattr(
        mutation_filesystem.LocalMutationPrimitives, "create_exclusive", case.deny
    )
    monkeypatch.setattr(
        mutation_filesystem.LocalMutationPrimitives, "replace_if_digest", case.deny
    )
    return case


@pytest.mark.parametrize("alias", [False, True], ids=["canonical", "alias"])
@pytest.mark.parametrize("missing", [False, True], ids=["existing", "missing-leaf"])
def test_factory_preserves_partition_through_real_store(
    factory_case: FactoryCase, alias: bool, missing: bool
) -> None:
    """Compose canonical/aliased state and optional absence without write effects.

    factory_case (FactoryCase) owns memory seams; alias/missing (bool) select the
    state shape. Return None; assertions require exact identity and native wiring.
    """
    case = factory_case
    if alias:
        case.aliases[case.base] = case.canonical_base
    expected = (case.canonical_base if alias else case.base) / case.state.relative_to(
        case.base
    )
    if missing:
        case.missing.update((case.state, expected))

    local = case.compose()

    assert isinstance(local.activation, activation_store.ActivationStore)
    assert isinstance(local.activation.registry, NativeRegistry)
    assert local.activation.location.directory == expected.as_posix()
    assert local.activation.location.workspace == case.location.workspace
    assert local.activation.location.workspace_sha256 == case.location.workspace_sha256
    assert local.initialization.primitives is local.activation.primitives
    assert local.initialization.workspace_root == case.location.workspace
    assert (case.root, True) in case.resolutions and (
        expected,
        False,
    ) in case.resolutions
    # Missing state may be observed without requiring or creating its leaf.
    assert not case.effects and not any(
        strict for path, strict in case.resolutions if path in case.missing
    )


@pytest.mark.parametrize(
    "spelling", ["relative", "../state", "C:state", "\\state", "parent"]
)
def test_invalid_state_spelling_is_rejected_before_resolution(
    factory_case: FactoryCase, monkeypatch: pytest.MonkeyPatch, spelling: str
) -> None:
    """Reject unsupported/relative/parent spelling before normalization erases it.

    factory_case (FactoryCase), monkeypatch (pytest.MonkeyPatch) and spelling (str)
    supply one host input. Return None; ValueError and absence of state reads are
    asserted. Only memory environment seams and observations change.
    """
    value = (
        (factory_case.base / ".." / "state").as_posix()
        if spelling == "parent"
        else spelling
    )
    monkeypatch.setenv("LOCALAPPDATA", value)
    monkeypatch.setenv("XDG_STATE_HOME", value)

    with pytest.raises(ValueError, match="absolute and canonical"):
        factory_case.compose()

    assert factory_case.resolutions == [(factory_case.root, True)]
    assert not factory_case.effects


@pytest.mark.parametrize("internal", ["lexical", "resolved"])
def test_internal_state_cannot_become_trusted_storage(
    factory_case: FactoryCase, monkeypatch: pytest.MonkeyPatch, internal: str
) -> None:
    """Retain external-location checks before and after canonicalization.

    factory_case (FactoryCase) and monkeypatch (pytest.MonkeyPatch) supply memory
    paths; internal (str) chooses lexical/resolved input. Return None; assertions
    require ValueError and no effects, including no alternate storage fallback.
    """
    case = factory_case
    # Raw internal input fails before normalization; an alias is checked afterward.
    if internal == "lexical":
        monkeypatch.setenv("LOCALAPPDATA", case.root.as_posix())
        monkeypatch.setenv("XDG_STATE_HOME", case.root.as_posix())
    else:
        case.aliases[case.base] = case.root

    with pytest.raises(ValueError, match="outside|external"):
        case.compose()

    assert not case.effects


@pytest.mark.parametrize("redirect", ["layout", "partition", "store-race"])
def test_distinct_or_changing_derived_state_is_refused(
    factory_case: FactoryCase, redirect: str
) -> None:
    """Reject redirection that changes fixed layout or the final canonical guard.

    factory_case (FactoryCase) supplies memory resolution; redirect (str) selects
    the differing component or between-check change. Return None; assertions
    require ValueError without native calls or replacement authority.
    """
    case = factory_case
    # Layout/digest redirections violate derivation; a later change reaches the store.
    if redirect == "layout":
        case.aliases[case.state.parent] = case.base / "unexpected"
    elif redirect == "partition":
        case.aliases[case.state] = case.state.with_name("other-workspace")
    else:
        case.answers[case.state] = [case.state, case.state.with_name("changed")]

    with pytest.raises(ValueError, match="partition|canonical"):
        case.compose()

    assert not case.effects


@pytest.mark.parametrize("target", ["workspace", "base", "state"])
def test_resolution_errors_propagate_without_fallback(
    factory_case: FactoryCase, target: str
) -> None:
    """Preserve the exact I/O failure for one resolution target (str).

    factory_case (FactoryCase) binds the synthetic OSError. Return None;
    assertions require that same exception and no effects or alternate location.
    """
    case = factory_case
    path = {"workspace": case.root, "base": case.base, "state": case.state}[target]
    error = OSError("Synthetic resolution failure")
    case.errors[path] = error

    with pytest.raises(OSError) as caught:
        case.compose()

    assert caught.value is error and not case.effects


@pytest.mark.parametrize(
    "condition", ["noncanonical-workspace", "missing-workspace", "host"]
)
def test_factory_rejects_invalid_outer_authority(
    factory_case: FactoryCase, condition: str
) -> None:
    """Refuse changed/missing workspace identity or host principal before state I/O.

    factory_case (FactoryCase) supplies memory observations; condition (str)
    selects the denied authority. Return None; assertions require the applicable
    fixed exception without state reads or effects.
    """
    case = factory_case
    # Workspace guards precede host authorization and state-location derivation.
    if condition == "noncanonical-workspace":
        case.aliases[case.root] = case.root.with_name("different-workspace")
        exception = ValueError
    elif condition == "missing-workspace":
        case.missing.add(case.root)
        exception = FileNotFoundError
    else:
        exception = PermissionError

    with pytest.raises(exception):
        case.compose(principal="host" if condition == "host" else "local-user")

    assert case.resolutions == [(case.root, True)] and not case.effects


@pytest.mark.parametrize("marker", ["invocation", "authorization"])
def test_composed_ports_reject_host_references(
    factory_case: FactoryCase, marker: str
) -> None:
    """Preserve host-reference refusal after real trusted-state composition.

    factory_case (FactoryCase) provides memory ports; marker (str) selects the
    opaque reference. Return None; assertions require PermissionError and no
    native reads/writes. Request data never supplies the host storage location.
    """
    case = factory_case
    local = case.compose()
    request = ServiceRequest(
        id="doctor",
        request_id="request",
        operation="doctor",
        mode="structural",
        workspace_root=case.root.as_posix(),
        profile_path=None,
        dry_run=False,
        write=False,
        format="json",
        inputs=JsonObject(()),
        invocation_ref="opaque-invocation-0001" if marker == "invocation" else None,
        authorization_ref=(
            "opaque-authorization-0001" if marker == "authorization" else None
        ),
    )

    with pytest.raises(PermissionError, match="authority"):
        local.authorize(request, baseline=None)

    assert not case.effects


@pytest.mark.parametrize("missing", [False, True], ids=["existing", "missing-leaf"])
@pytest.mark.parametrize(
    "intermediate",
    [("cache",), ("tenant", "session", "state")],
    ids=["one-component", "three-components"],
)
def test_intermediate_state_components_preserve_partition(
    factory_case: FactoryCase, intermediate: tuple[str, ...], missing: bool
) -> None:
    """Accept complete-path resolution that adds contained host components.

    factory_case (FactoryCase) owns memory seams; intermediate (tuple[str, ...])
    selects generic host components and missing (bool) permits absent storage.
    Return None; assertions preserve the contract suffix, workspace identity and
    real store's canonical recheck without native effects.
    """
    case = factory_case
    suffix = case.state.relative_to(case.base)
    expected = case.base.joinpath(*intermediate) / suffix
    # Only the complete state moves; resolving its trusted base remains unchanged.
    case.aliases[case.state] = expected
    if missing:
        case.missing.update((case.state, expected))

    local = case.compose()

    assert isinstance(local.activation, activation_store.ActivationStore)
    assert local.activation.location.directory == expected.as_posix()
    assert local.activation.location.workspace == case.location.workspace
    assert local.activation.location.workspace_sha256 == case.location.workspace_sha256
    assert (case.base, False) in case.resolutions
    assert (expected, False) in case.resolutions
    assert local.initialization.primitives is local.activation.primitives
    assert not case.effects


@pytest.mark.parametrize(
    "redirect", ["relative", "outside-base", "layout", "partition"]
)
def test_intermediate_state_resolution_rejects_invalid_identity(
    factory_case: FactoryCase, redirect: str
) -> None:
    """Reject resolution that loses containment, layout or workspace partition.

    factory_case (FactoryCase) supplies memory paths; redirect (str) selects the
    violated invariant. Return None; ValueError and absent native effects prove
    no alternate storage or authority is substituted.
    """
    case = factory_case
    suffix = case.state.relative_to(case.base)
    contained = case.base / "cache" / suffix
    candidates = {
        "relative": Path("relative") / suffix,
        "outside-base": case.base.with_name("other-state") / suffix,
        "layout": contained.parent.with_name("unexpected") / contained.name,
        "partition": contained.with_name("other-workspace"),
    }
    case.aliases[case.state] = candidates[redirect]

    with pytest.raises(ValueError, match="partition"):
        case.compose()

    assert not case.effects
