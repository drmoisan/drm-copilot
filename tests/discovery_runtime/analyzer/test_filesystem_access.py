"""Verify inferred filesystem syntax, exact anchors and redacted captured sources."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer import api_syntax
from drm_copilot_discovery.analyzer.api_syntax import access_sites
from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.filesystem_access import (
    FILESYSTEM_SURFACE,
    FilesystemAccessAnalyzer,
)
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.models import Analysis, InventoryInput
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture, properties
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject


def serialized(analysis: Analysis) -> str:
    """Return complete inert JSON for Analysis, including every diagnostic and row.

    No files are read or written; invalid internal JSON propagates as ValueError.
    """
    return canonical_json(
        row(
            components=analysis.components,
            findings=analysis.findings,
            relationships=analysis.relationships,
            diagnostics=analysis.diagnostics,
        )
    ).decode()


@pytest.mark.parametrize("prefix", ["", "System.IO.", "global::System.IO."])
@pytest.mark.parametrize(
    "expression,api",
    [
        ('File.ReadAllText("VALUE_SENTINEL")', "File.ReadAllText"),
        ('File.Open("VALUE_SENTINEL", mode)', "File.Open"),
        ('File.WriteAllTextAsync("VALUE_SENTINEL", value)', "File.WriteAllTextAsync"),
        ('Directory.EnumerateFiles("VALUE_SENTINEL")', "Directory.EnumerateFiles"),
        ("Directory.GetCurrentDirectory()", "Directory.GetCurrentDirectory"),
        ('new FileInfo("VALUE_SENTINEL")', "FileInfo"),
        ('new DirectoryInfo("VALUE_SENTINEL")', "DirectoryInfo"),
        ('new FileStream("VALUE_SENTINEL", mode)', "FileStream"),
        ('new StreamReader("VALUE_SENTINEL")', "StreamReader"),
        ('new StreamWriter("VALUE_SENTINEL")', "StreamWriter"),
    ],
)
def test_fixed_filesystem_forms_are_inferred_without_arguments(
    catalog: SchemaCatalog, prefix: str, expression: str, api: str
) -> None:
    """Catalog and str prefix/expression/api select qualified call/constructor forms.

    Returns None; fixed API identities retain unresolved binding and no values.
    """
    source = (
        expression.replace("new ", "new " + prefix)
        if expression.startswith("new ")
        else prefix + expression
    )
    result = FilesystemAccessAnalyzer().analyze(
        capture(catalog, (("src/a.cs", source.encode()),))
    )
    assert len(result.findings) == 1
    finding = result.findings[0]
    assert finding["classification"] == "inferred" and finding["confidence"] == "medium"
    assert properties(finding)["api"] == "System.IO." + api
    assert "VALUE_SENTINEL" not in serialized(result)
    assert "platform_applicability" in serialized(
        result
    ) and "unresolved" in serialized(result)


@pytest.mark.parametrize(
    "source",
    [
        "",
        "File.ReadAllText;",
        "File + ReadAllText();",
        "File.ReadAllText + 1;",
        "Other.File.ReadAllText();",
        "Other.System.IO.File.Open();",
        "SystemX.IO.File.Open();",
        "file.ReadAllText();",
        "MyFile.Open();",
        "new MemoryStream();",
        "new Stream();",
        "new MyFileStream();",
        "new File.Open();",
        "FileInfo.OpenRead();",
        "stream.Read();",
        "DirectoryInfo.Delete();",
        "global::File.Open();",
        "Alias::File.Open();",
        "global.System.IO.File.Open();",
        "@global.System.IO.File.Open();",
        "File?.Open();",
        "holder?.File.Open();",
        "System::IO.File.Open();",
        ".File.Open();",
        "using F = System.IO.File; F.Open();",
        "using static System.IO.File; Open();",
        "namespace File.Open { class A {} }",
        "class File { void Open() {} }",
        'var raw = """ File.Open("VALUE_SENTINEL"); """;',
        '$"{File.Open("VALUE_SENTINEL")}";',
        "// File.Open();\n/*new FileInfo();*/",
        '@"File.Open(""VALUE_SENTINEL"")";',
        "#define File.Open\n",
    ],
)
def test_non_access_and_masked_syntax_never_becomes_evidence(source: str) -> None:
    """str source includes arithmetic, lookalikes, declarations and masked content.

    Returns None; no filesystem candidate may be inferred from these inputs.
    """
    assert access_sites(source, FILESYSTEM_SURFACE) == ()


@pytest.mark.parametrize("newline", ["\n", "\r", "\r\n"])
def test_repeated_multiline_sites_keep_exact_physical_offsets(newline: str) -> None:
    """str newline selects physical boundaries; decoded offsets preserve occurrences.

    Returns None; assertions exclude argument spans from exact API source anchors.
    """
    first = newline.join(["global::System", ".IO.File", ".Open(", '"VALUE_SENTINEL");'])
    source = first + newline + "new" + newline + "FileInfo(); File.Open();"
    result = access_sites(source, FILESYSTEM_SURFACE)
    assert len(result) == 3
    assert result[0].start == 0 and result[0].end == first.index("(")
    assert result[0].line == 1 and result[0].end_line == 3
    assert result[1].start == source.index("new") and result[1].line == 5
    assert result[1].end == source.index("FileInfo") + len("FileInfo")
    assert result[2].start == source.rindex("File.Open")
    assert result[2].line == result[2].end_line == 6


def test_custom_types_aliases_and_preprocessing_never_resolve_bindings(
    catalog: SchemaCatalog,
) -> None:
    """Catalog creates lexically matching custom/alias types and inactive branches.

    Returns None; candidates remain inferred even when runtime usage is uncertain.
    """
    source = (
        b"using File = Custom; class File { void Open() {} }\n"
        b"#if DISABLED\nFile.Open();\n#endif\n@File.Open();"
    )
    result = FilesystemAccessAnalyzer().analyze(
        capture(catalog, (("src/a.cs", source),))
    )
    assert len(result.findings) == 2
    # Known spellings cannot prove that the compiler selected a framework symbol.
    assert all(finding["classification"] == "inferred" for finding in result.findings)
    assert "not-resolved" in serialized(result) and "not-evaluated" in serialized(
        result
    )
    assert result.diagnostics[0]["code"] == "api-binding-unresolved"
    assert result.diagnostics[0]["blocking"] is False


@pytest.mark.parametrize("encoding", ["utf-8-sig", "utf-16", "utf-32"])
def test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory(
    catalog: SchemaCatalog, encoding: str
) -> None:
    """Catalog and str encoding provide immutable payload/pin provenance.

    Returns None; composition validates source hashes and repeated deterministic IDs.
    """
    content = '// Ω\nFile.Open("VALUE_SENTINEL"); File.Open("VALUE_SENTINEL");'.encode(
        encoding
    )
    inputs = capture(catalog, (("src/a.CS", content),))
    result = FilesystemAccessAnalyzer().analyze(inputs)
    assert len(result.findings) == 2
    # Repeated API calls on one line must retain distinct occurrence identifiers.
    assert len({finding["finding_id"] for finding in result.findings}) == 2
    source = cast("JsonObject", result.findings[0]["source"])
    assert source["sha256"] == hashlib.sha256(content).hexdigest()
    assert source["line_range"] == row(start=2, end=2)
    assert FilesystemAccessAnalyzer().analyze(inputs) == result
    document = inventory_result(
        inputs,
        (result,),
        analyzer_ids=("filesystem-access",),
        timestamp="2026-10-19T00:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=catalog,
    )
    # The established emitter sorts complete rows by ID, preserving their contents.
    assert document.document["findings"] == tuple(
        sorted(result.findings, key=lambda finding: cast("str", finding["finding_id"]))
    )
    assert "VALUE_SENTINEL" not in serialized(result)


def test_arguments_do_not_define_ids_and_unchanged_pin_is_not_reused(
    catalog: SchemaCatalog,
) -> None:
    """Catalog builds equal-length changed arguments with an intentionally stale pin.

    Returns None; identity stays lexical while exact source provenance downgrades.
    """
    first = capture(catalog, (("src/a.cs", b'File.Open("VALUE_SENTINEL_A");'),))
    changed = capture(catalog, (("src/a.cs", b'File.Open("VALUE_SENTINEL_B");'),))
    original = FilesystemAccessAnalyzer().analyze(first)
    stale = FilesystemAccessAnalyzer().analyze(
        replace(changed, repository_files=first.repository_files)
    )
    assert original.findings[0]["finding_id"] == stale.findings[0]["finding_id"]
    assert original.findings[0]["source"] != stale.findings[0]["source"]
    assert stale.findings[0]["confidence"] == "low"
    assert stale.diagnostics[-1]["code"] == "source-revision-unverified"
    assert "VALUE_SENTINEL" not in serialized(original) + serialized(stale)


@pytest.mark.parametrize(
    "payload,code",
    [
        (b"\xffVALUE_SENTINEL", "source-encoding"),
        (b'File.Open("VALUE_SENTINEL");\0', "source-encoding"),
        (b'File.Open("VALUE_SENTINEL"); }', "source-delimiter"),
        (b'File.Open("VALUE_SENTINEL"); (', "source-delimiter"),
        (b'File.Open("VALUE_SENTINEL"); [)', "source-delimiter"),
    ],
)
def test_malformed_input_discards_its_candidates_and_redacts_errors(
    catalog: SchemaCatalog, payload: bytes, code: str
) -> None:
    """Catalog/bytes payload/str code isolate failure after a potential valid prefix.

    Returns None; no partial file claims or exception/value text is published.
    """
    result = FilesystemAccessAnalyzer().analyze(
        capture(catalog, (("src/a.cs", payload),))
    )
    assert not result.components and not result.findings
    assert len(result.diagnostics) == 1 and result.diagnostics[0]["code"] == code
    assert "VALUE_SENTINEL" not in serialized(result)


def test_unavailable_excluded_and_unrelated_files_preserve_selection(
    catalog: SchemaCatalog,
) -> None:
    """Catalog supplies explicit omissions and unrelated bytes without source access.

    Returns None; only selected unreadable input gets one redacted diagnostic.
    """
    base = capture(catalog, (("src/a.txt", b'File.Open("VALUE_SENTINEL");'),))
    inputs = replace(
        base,
        inputs=base.inputs
        + (
            InventoryInput(
                path="src/b.cs", status="excluded", rationale="VALUE_SENTINEL_EXCLUDED"
            ),
            InventoryInput(
                path="src/c.cs", status="unreadable", rationale="VALUE_SENTINEL_READ"
            ),
        ),
    )
    result = FilesystemAccessAnalyzer().analyze(inputs)
    assert not result.components and not result.findings
    assert (
        len(result.diagnostics) == 1
        and result.diagnostics[0]["code"] == "input-unreadable"
    )
    assert "VALUE_SENTINEL" not in serialized(result)


@pytest.mark.parametrize("maximum", [-1, 100001])
def test_invalid_candidate_bounds_fail_explicitly(maximum: int) -> None:
    """int maximum is outside the supported range; SourceScanError exposes a code.

    Returns None; no parsing or partial result occurs for an invalid bound.
    """
    with pytest.raises(SourceScanError) as error:
        access_sites("File.Open();", FILESYSTEM_SURFACE, max_sites=maximum)
    assert error.value.code == "source-record-limit"


class CountedPin:
    """Count identity inspections of retained immutable pin data locally."""

    def __init__(self, source: RepositoryFile, visits: list[int]) -> None:
        """Keep RepositoryFile source and local count list; return None, without I/O."""
        self.source = source
        self.path = source.path
        self.content = source.content
        self.visits = visits

    @property
    def repository(self) -> RepositoryIdentity:
        """Increment local visits and return the immutable RepositoryIdentity."""
        self.visits[0] += 1
        return self.source.repository


def test_whole_capture_provenance_matching_visits_each_pin_once(
    catalog: SchemaCatalog,
) -> None:
    """Catalog builds 32 exact pins whose identity visits expose quadratic rescanning.

    Returns None; every finding remains pinned with at most two identity reads per
    object. All counting wrappers and captures stay in memory.
    """
    # A bounded multi-file population separates indexed work from repeated scans.
    inputs = capture(
        catalog, tuple((f"src/a{index:02}.cs", b"File.Open();") for index in range(32))
    )
    visits = [0]
    # Preserve each retained pin's identity and bytes while measuring accesses.
    counted = tuple(
        cast("RepositoryFile", CountedPin(source, visits))
        for source in inputs.repository_files
    )
    result = FilesystemAccessAnalyzer().analyze(
        replace(inputs, repository_files=counted)
    )
    assert len(result.findings) == 32 and visits[0] <= 2 * len(counted)
    # Indexing must retain the exact confidence behavior of successful pins.
    assert all(finding["confidence"] == "medium" for finding in result.findings)


def test_provenance_index_preserves_any_exact_matching_identity(
    catalog: SchemaCatalog,
) -> None:
    """Catalog creates wrong identities, bytes, paths and duplicate exact pins.

    Returns None; one exact source wins without confusing another revision/repo.
    """
    inputs = capture(catalog, (("src/a.cs", b"File.Open();"),))
    source = inputs.repository_files[0]
    pins = (
        replace(
            source,
            repository=RepositoryIdentity(
                id="other", revision=source.repository.revision
            ),
        ),
        replace(
            source,
            repository=RepositoryIdentity(id=source.repository.id, revision="b" * 40),
        ),
        replace(source, path="src/missing.cs"),
        replace(source, content=b"File.Open(1);"),
        source,
        source,
    )
    result = FilesystemAccessAnalyzer().analyze(replace(inputs, repository_files=pins))
    assert result.findings[0]["confidence"] == "medium"
    assert len(result.diagnostics) == 1


def test_provenance_count_is_bounded_before_any_pin_inspection(
    catalog: SchemaCatalog,
) -> None:
    """Catalog creates too many retained pins for one configured source slot.

    Returns None; a fixed whole-result blocker precedes indexing or pin inspection.
    """
    inputs = capture(catalog, (("src/a.cs", b"File.Open();"),))
    visits = [0]
    pin = cast("RepositoryFile", CountedPin(inputs.repository_files[0], visits))
    inputs = replace(
        inputs,
        repository_files=(pin, pin),
        profile=inventory_profile(catalog, limits={"source_files": 1}),
    )
    result = FilesystemAccessAnalyzer().analyze(inputs)
    assert not result.components and not result.findings and visits == [0]
    assert len(result.diagnostics) == 1
    assert result.diagnostics[0]["code"] == "analysis-work-limit"


@pytest.mark.parametrize("kind", ["pins", "inputs"])
def test_aggregate_byte_work_is_bounded_separately_from_output(
    catalog: SchemaCatalog, kind: str
) -> None:
    """Catalog and str kind exercise retained-pin and selected-input byte budgets.

    Returns None; individually admissible files cannot exceed the aggregate work
    budget or leave partial successful claims. All bytes are small memory fixtures.
    """
    payload = b"File.Open(); //" + b"x" * 51000
    inputs = capture(catalog, (("src/a.cs", payload),), pinned=False)
    profile = inventory_profile(catalog, limits={"document_bytes": 100000})
    # Foreign and duplicate pins count even when neither can verify a local input.
    if kind == "pins":
        source = RepositoryFile(
            repository=RepositoryIdentity(id="foreign", revision="b" * 40),
            path="src/unused.cs",
            content=payload,
        )
        inputs = replace(inputs, profile=profile, repository_files=(source, source))
    else:
        inputs = replace(
            capture(
                catalog, (("src/a.cs", payload), ("src/b.cs", payload)), pinned=False
            ),
            profile=profile,
        )
    result = FilesystemAccessAnalyzer().analyze(inputs)
    assert not result.components and not result.findings
    assert len(result.diagnostics) == 1
    assert result.diagnostics[0]["code"] == "analysis-work-limit"


class OversizedText(str):
    """Report an over-limit length without allocating a large test payload."""

    def __len__(self) -> int:
        """Return an int above the decoded-character bound; no mutation or I/O."""
        return 67108865


@pytest.mark.parametrize(
    "capacity,maximum,code",
    [
        ("sites", True, "source-record-limit"),
        ("sites", False, "source-record-limit"),
        ("sites", 0.5, "source-record-limit"),
        ("sites", None, "source-record-limit"),
        ("sites", "1", "source-record-limit"),
        ("tokens", True, "source-token-limit"),
        ("tokens", False, "source-token-limit"),
        ("tokens", 0.5, "source-token-limit"),
        ("tokens", None, "source-token-limit"),
        ("tokens", "1", "source-token-limit"),
        ("tokens", 0, "source-token-limit"),
        ("tokens", 100001, "source-token-limit"),
        ("text", None, "source-limit"),
    ],
)
def test_public_bounds_reject_before_masking_or_token_allocation(
    monkeypatch: pytest.MonkeyPatch, capacity: str, maximum: object, code: str
) -> None:
    """Patch masking; str capacity/code and object maximum select invalid inputs.

    Returns None; every failure must precede mask/token work and redact source text.
    The length-reporting string avoids a large allocation in this unit test.
    """

    def prohibited_mask(text: str) -> str:
        """Reject any mask request for str text with AssertionError; no allocation."""
        raise AssertionError("Masking must not run for invalid public bounds")

    monkeypatch.setattr(api_syntax, "strip_comments_and_strings", prohibited_mask)
    source = OversizedText("VALUE_SENTINEL") if capacity == "text" else "VALUE_SENTINEL"
    with pytest.raises(SourceScanError) as error:
        access_sites(
            source,
            FILESYSTEM_SURFACE,
            max_sites=cast("int", maximum) if capacity == "sites" else 100000,
            max_tokens=cast("int", maximum) if capacity == "tokens" else 100000,
        )
    assert error.value.code == code and "VALUE_SENTINEL" not in str(error.value)
