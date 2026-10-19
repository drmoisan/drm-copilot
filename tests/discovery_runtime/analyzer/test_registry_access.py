"""Verify registry candidates and shared access allocation/linear-work contracts."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast, overload

import pytest
from drm_copilot_discovery.analyzer import api_access, api_syntax
from drm_copilot_discovery.analyzer.api_syntax import (
    AccessSite,
    ApiSurface,
    access_sites,
)
from drm_copilot_discovery.analyzer.csharp_tokens import (
    SourceScanError,
    Token,
    tokenize_csharp,
)
from drm_copilot_discovery.analyzer.filesystem_access import (
    FILESYSTEM_SURFACE,
    FilesystemAccessAnalyzer,
)
from drm_copilot_discovery.analyzer.models import Analysis, InventoryInput
from drm_copilot_discovery.analyzer.registry_access import (
    REGISTRY_SURFACE,
    RegistryAccessAnalyzer,
)

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture, properties
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
from tests.discovery_runtime.analyzer.test_filesystem_access import serialized
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from collections.abc import Callable, Iterator

    from drm_copilot_discovery.analyzer.models import InventoryCapture
    from drm_copilot_discovery.catalog import SchemaCatalog

    Projector = Callable[
        [InventoryCapture, InventoryInput, ApiSurface, tuple[AccessSite, ...], bool],
        Analysis,
    ]


@pytest.mark.parametrize("prefix", ["", "Microsoft.Win32.", "global::Microsoft.Win32."])
@pytest.mark.parametrize(
    "expression,api",
    [
        (
            'Registry.GetValue("VALUE_SENTINEL", "VALUE_SENTINEL", null)',
            "Registry.GetValue",
        ),
        (
            'Registry.SetValue("VALUE_SENTINEL", "VALUE_SENTINEL", value)',
            "Registry.SetValue",
        ),
        ("RegistryKey.OpenBaseKey(hive, view)", "RegistryKey.OpenBaseKey"),
        (
            'RegistryKey.OpenRemoteBaseKey(hive, "VALUE_SENTINEL")',
            "RegistryKey.OpenRemoteBaseKey",
        ),
        ('Registry.CurrentUser.OpenSubKey("VALUE_SENTINEL")', "Registry.CurrentUser"),
        ("Registry.LocalMachine", "Registry.LocalMachine"),
        ("Registry.ClassesRoot", "Registry.ClassesRoot"),
        ("Registry.Users", "Registry.Users"),
        ("Registry.CurrentConfig", "Registry.CurrentConfig"),
        ("Registry.PerformanceData", "Registry.PerformanceData"),
    ],
)
def test_known_registry_syntax_keeps_platform_and_key_unresolved(
    catalog: SchemaCatalog, prefix: str, expression: str, api: str
) -> None:
    """Catalog/str syntax parameters select fixed calls and property-root declarations.

    Returns None; Windows applicability, receivers and runtime keys stay unknown.
    """
    result = RegistryAccessAnalyzer().analyze(
        capture(catalog, (("src/a.cs", (prefix + expression + ";").encode()),))
    )
    assert len(result.findings) == 1
    assert properties(result.findings[0])["api"] == "Microsoft.Win32." + api
    assert result.findings[0]["classification"] == "inferred"
    assert "VALUE_SENTINEL" not in serialized(result)
    assert '"platform_applicability":"unresolved"' in serialized(result)


@pytest.mark.parametrize(
    "source",
    [
        "MyRegistry.GetValue();",
        "Other.Registry.GetValue();",
        "registry.GetValue();",
        "RegistryKey.GetValue();",
        "key.OpenSubKey();",
        "new RegistryKey();",
        "Registry.CurrentUser();",
        "Registry.UnknownRoot;",
        "Registry + GetValue();",
        "Registry.CurrentUser local;",
        "using R = Microsoft.Win32.Registry; R.GetValue();",
        "using R = Registry.CurrentUser;",
        "namespace Registry.CurrentUser;",
        "System.Registry.GetValue();",
        '"Registry.GetValue()";',
        '$"{Registry.GetValue("VALUE_SENTINEL", null, null)}"',
    ],
)
def test_non_registry_receivers_and_declarations_are_not_candidates(
    source: str,
) -> None:
    """str source exercises unknown names, unrelated receivers and masked expressions.

    Returns None; no alias/dataflow assumption can turn these into registry claims.
    """
    assert access_sites(source, REGISTRY_SURFACE) == ()


def test_registry_roots_keep_repeated_offsets_and_no_argument_anchor() -> None:
    """Repeated property syntax returns exact immutable sites without call arguments.

    Returns None; root anchors end at the property rather than a descendant call.
    """
    source = (
        'Registry.\r\nCurrentUser.OpenSubKey("VALUE_SENTINEL"); Registry.CurrentUser;'
    )
    sites = access_sites(source, REGISTRY_SURFACE)
    assert len(sites) == 2 and sites[0].start == 0
    assert sites[0].end == source.index(".OpenSubKey")
    assert sites[0].line == 1 and sites[0].end_line == 2
    assert sites[1].start == source.rindex("Registry")
    assert sites[0].operation == sites[1].operation == "property"


@pytest.mark.parametrize(
    "case",
    [
        "empty",
        "long-namespace",
        "too-many",
        "name",
        "identifier",
        "overlap",
        "pair",
        "mutable",
    ],
)
def test_invalid_fixed_definitions_fail_before_scanning(case: str) -> None:
    """str case chooses a bounded-definition invariant; construction raises ValueError.

    Returns None; no malformed or mutable source-supplied rules are retained.
    """
    with pytest.raises(ValueError):
        # Each branch isolates one immutable configuration invariant.
        if case == "empty":
            replace(REGISTRY_SURFACE, namespace=())
        elif case == "long-namespace":
            replace(REGISTRY_SURFACE, namespace=("A",) * 5)
        elif case == "too-many":
            # A small deterministic rule population exceeds the fixed 128-rule cap.
            replace(
                REGISTRY_SURFACE,
                constructors=frozenset("T" + str(index) for index in range(129)),
            )
        elif case == "name":
            replace(REGISTRY_SURFACE, namespace=("Invalid.Name",))
        elif case == "identifier":
            replace(REGISTRY_SURFACE, identifier="x" * 65)
        elif case == "overlap":
            replace(REGISTRY_SURFACE, properties=REGISTRY_SURFACE.calls)
        elif case == "pair":
            replace(
                REGISTRY_SURFACE,
                calls=cast("frozenset[tuple[str, str]]", frozenset({("A",)})),
            )
        else:
            replace(REGISTRY_SURFACE, constructors=cast("frozenset[str]", {"A"}))


@pytest.mark.parametrize(
    "records,payloads",
    [
        (1, (("src/a.cs", b"Registry.GetValue();"),)),
        (2, (("src/a.cs", b"Registry.GetValue();"),)),
        (3, (("src/a.cs", b"Registry.GetValue(); Registry.GetValue();"),)),
        (
            5,
            (
                ("src/a.cs", b"Registry.GetValue();"),
                ("src/b.cs", b"Registry.CurrentUser;"),
            ),
        ),
    ],
)
def test_record_overflow_discards_the_whole_aggregate(
    catalog: SchemaCatalog, records: int, payloads: tuple[tuple[str, bytes], ...]
) -> None:
    """Catalog/int records/bytes payloads exhaust base, per-file or aggregate rows.

    Returns None; one fixed blocker replaces every partial component/finding.
    """
    result = RegistryAccessAnalyzer().analyze(
        capture(catalog, payloads, records=records)
    )
    assert not result.components and not result.findings and not result.relationships
    assert (
        len(result.diagnostics) == 1
        and result.diagnostics[0]["code"] == "analysis-limit"
    )


def test_zero_candidate_budget_permits_absence_but_never_allocates_a_site(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """MonkeyPatch installs a fail-if-constructed site sentinel for the zero budget.

    Returns None; parsing a candidate raises its limit before allocating a record.
    """

    def prohibited_site(**values: object) -> AccessSite:
        """Fail if scanner allocates any site from supplied keyword values; no I/O.

        Returns no value; AssertionError marks an allocation before its budget.
        """
        raise AssertionError(f"Unexpected allocation keys: {tuple(values)}")

    monkeypatch.setattr(api_syntax, "AccessSite", prohibited_site)
    assert access_sites("class Empty {}", REGISTRY_SURFACE, max_sites=0) == ()
    with pytest.raises(SourceScanError) as error:
        access_sites("Registry.GetValue();", REGISTRY_SURFACE, max_sites=0)
    assert error.value.code == "source-record-limit"


@pytest.mark.parametrize("kind", ["base", "sites", "cross-file", "unreadable"])
def test_text_reservations_precede_projection_and_discard_partial_claims(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, kind: str
) -> None:
    """Catalog/patch fixture and str kind exercise prospective encoded-byte limits.

    Returns None; counted row batches prove overflow never projects excess output.
    """
    payloads = (("src/a.cs", b"Registry.CurrentUser;"),)
    base = capture(catalog, payloads)
    cost_function = cast(
        "Callable[[InventoryCapture, InventoryInput, ApiSurface], int]",
        vars(api_access)["_row_cost"],
    )
    cost = cost_function(base, base.inputs[0], REGISTRY_SURFACE)
    # Select independent base, candidate and aggregate exhaustion boundaries.
    if kind == "base":
        budget = cost
    elif kind == "sites":
        budget = cost * 2
    elif kind == "cross-file":
        payloads += (("src/b.cs", b"Registry.GetValue();"),)
        budget = cost * 5
    else:
        budget = cost
    inputs = replace(
        capture(catalog, payloads),
        profile=inventory_profile(catalog, limits={"document_bytes": budget}),
    )
    if kind == "unreadable":
        inputs = replace(
            inputs,
            inputs=(
                InventoryInput(
                    path="src/a.cs", status="unreadable", rationale="VALUE_SENTINEL"
                ),
                InventoryInput(
                    path="src/b.cs", status="unreadable", rationale="VALUE_SENTINEL"
                ),
            ),
        )
    projected: list[str] = []
    original = cast(
        "Projector",
        vars(api_access)["_project"],
    )

    def counted(
        captured: InventoryCapture,
        item: InventoryInput,
        surface: ApiSurface,
        sites: tuple[AccessSite, ...],
        pinned: bool,
    ) -> Analysis:
        """Record captured/item/surface/site/pin projection; return real Analysis.

        Mutates only the test's path list; original projection failures propagate.
        """
        projected.append(item.path)
        return original(captured, item, surface, sites, pinned)

    monkeypatch.setattr(api_access, "_project", counted)
    result = RegistryAccessAnalyzer().analyze(inputs)
    assert projected == (["src/a.cs"] if kind == "cross-file" else [])
    assert not result.components and not result.findings
    assert (
        len(result.diagnostics) == 1
        and result.diagnostics[0]["code"] == "analysis-text-limit"
    )
    assert "VALUE_SENTINEL" not in serialized(result)


@pytest.mark.parametrize("ensure_ascii", [False, True])
def test_unicode_provenance_serializes_within_documented_byte_reservations(
    catalog: SchemaCatalog, ensure_ascii: bool
) -> None:
    """Catalog and bool encoding exercise BMP, astral and escaped path identifiers.

    Returns None; both compact JSON representations fit the exact reserved budget.
    """
    base = capture(catalog, (("src/Ω/~😀.cs", b"File.Open();"),))
    cost_function = cast(
        "Callable[[InventoryCapture, InventoryInput, ApiSurface], int]",
        vars(api_access)["_row_cost"],
    )
    budget = 3 * cost_function(base, base.inputs[0], FILESYSTEM_SURFACE)
    inputs = replace(
        base, profile=inventory_profile(catalog, limits={"document_bytes": budget})
    )
    result = FilesystemAccessAnalyzer().analyze(inputs)
    encoded = json.dumps(
        json.loads(serialized(result)), ensure_ascii=ensure_ascii, separators=(",", ":")
    ).encode()
    assert len(result.findings) == 1 and len(encoded) <= budget


def test_missing_pin_and_byte_limit_are_explicit_fixed_failures(
    catalog: SchemaCatalog,
) -> None:
    """Catalog builds unpinned and over-limit captured payloads without extra reads.

    Returns None; missing pins downgrade candidates and size failure has no claims.
    """
    unpinned = RegistryAccessAnalyzer().analyze(
        capture(catalog, (("src/a.cs", b"Registry.GetValue();"),), pinned=False)
    )
    assert unpinned.findings[0]["confidence"] == "low"
    assert unpinned.diagnostics[-1]["code"] == "source-revision-unverified"
    too_large = RegistryAccessAnalyzer().analyze(
        capture(catalog, (("src/a.cs", b"Registry.GetValue();"),), max_bytes=1)
    )
    assert not too_large.components and not too_large.findings
    assert too_large.diagnostics[0]["code"] == "source-limit"


class CountedTokens:
    """Count accesses to immutable tokens for deterministic scanner-work tests."""

    def __init__(self, values: tuple[Token, ...]) -> None:
        """Store Token tuple values and zero visits; return None, without I/O."""
        self.values = values
        self.visits = 0

    def __len__(self) -> int:
        """Return stored token count (int), without mutation or external effects."""
        return len(self.values)

    @overload
    def __getitem__(self, index: int) -> Token:
        """Describe indexed Token return for int index; no implementation effects."""

    @overload
    def __getitem__(self, index: slice) -> tuple[Token, ...]:
        """Describe tuple return for slice index; no implementation effects."""

    def __getitem__(self, index: int | slice) -> Token | tuple[Token, ...]:
        """Count int/slice access and return stored tokens; IndexError propagates."""
        self.visits += 1
        return self.values[index]

    def __iter__(self) -> Iterator[Token]:
        """Yield immutable tokens while counting each visit; no external effects."""
        # The counter measures complete forward passes as well as indexed lookups.
        for value in self.values:
            self.visits += 1
            yield value


@pytest.mark.parametrize(
    "source",
    [
        "x." * 80 + "File.Open();",
        "File.Open();" * 40,
        "using Alias = " + "Name." * 40 + "Type;",
        "Registry.CurrentUser." + "Member." * 40 + "Call();",
        "class C : File { void File.Open() {} }" * 40,
        "class C : File { void File.Open() { File.Open(); } }" * 20,
        "File.Open(" * 20 + "value" + ")" * 20 + ";",
    ],
)
def test_aggregate_token_work_is_linear_for_long_and_repeated_chains(
    monkeypatch: pytest.MonkeyPatch, source: str
) -> None:
    """Patch fixture and str source count work deterministically without timing gates.

    Returns None; long prefixes and repeated sites cannot trigger suffix rescans.
    """
    counted = CountedTokens(tokenize_csharp(source))

    def retained_tokens(text: str, *, max_tokens: int = 100000) -> tuple[Token, ...]:
        """Return counted retained tokens for str text/int bound; no source evaluation.

        Mutates no external state; the test double exposes sequence-access counts.
        """
        assert text == source and max_tokens == 100000
        return cast("tuple[Token, ...]", counted)

    monkeypatch.setattr(api_syntax, "tokenize_csharp", retained_tokens)
    access_sites(source, FILESYSTEM_SURFACE)
    assert counted.visits <= 15 * len(counted)


def test_token_limit_never_emits_partial_candidates() -> None:
    """A small explicit token bound rejects repeated valid sites without partial output.

    Returns None; SourceScanError retains only the deterministic token-limit code.
    """
    with pytest.raises(SourceScanError) as error:
        access_sites("File.Open(); File.Open();", FILESYSTEM_SURFACE, max_tokens=8)
    assert error.value.code == "source-token-limit"


@pytest.mark.parametrize("family", ["filesystem", "registry"])
@pytest.mark.parametrize("body", ["empty", "arrow", "nested", "nested-arrow"])
def test_explicit_interface_declarations_preserve_only_real_call_sites(
    catalog: SchemaCatalog, family: str, body: str
) -> None:
    """Catalog and str family/body separate declarations from body invocations.

    Returns None; both original review inputs and expression bodies produce no
    false type/call claim. Nested genuine calls retain exact offsets and inference.
    """
    # Keep the exact reviewed interface declarations while varying only the body.
    if family == "filesystem":
        prefix = "interface File { void Open(); } class C : File { void "
        method = "File.Open"
        empty = "{}"
        invocation = "File.Open();"
        surface = FILESYSTEM_SURFACE
        analyzer = FilesystemAccessAnalyzer()
    else:
        prefix = (
            "interface Registry { object GetValue(); } class C : Registry { object "
        )
        method = "Registry.GetValue"
        empty = "{ return null; }"
        invocation = "return Registry.GetValue();"
        surface = REGISTRY_SURFACE
        analyzer = RegistryAccessAnalyzer()
    # Body and arrow terminators identify declarations independently of binding.
    bodies = {
        "empty": empty,
        "arrow": "=> throw new Exception();",
        "nested": "{ " + invocation + " }",
        "nested-arrow": "=> " + method + "();",
    }
    source = prefix + method + "() " + bodies[body] + " }"
    sites = access_sites(source, surface)
    result = analyzer.analyze(capture(catalog, (("src/a.cs", source.encode()),)))
    assert len(sites) == len(result.findings) == int(body.startswith("nested"))
    if sites:
        assert sites[0].start == source.rindex(method)
        assert sites[0].end == sites[0].start + len(method)
        assert result.findings[0]["classification"] == "inferred"
        assert result.findings[0]["confidence"] == "medium"
