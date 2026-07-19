"""Unit and integration tests for the .NET/C# inventory analyzer.

Pure detection tests feed inline C# strings and the raw ``.cs.txt`` fixtures to
the pure ``classify_text`` function (no filesystem). Error-path, glob-routing, and
end-to-end emission tests use the in-memory ``mem_fs_path`` fixture; no temporary
files are created and the injected clock is pinned for determinism.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.discovery.analyzer.dotnet_inventory import (
    DotnetInventoryAnalyzer,
    classify_text,
)
from scripts.dev_tools.discovery.analyzer.inventory import AnalyzerError
from scripts.dev_tools.discovery.analyzer.models import AnalyzerContext, ParseResult
from scripts.dev_tools.discovery.analyzer.pipeline import (
    RealAnalyzerFileSystem,
    run_analyzer,
)
from scripts.dev_tools.discovery.domain_profile_models import DomainProfileError

if TYPE_CHECKING:
    from scripts.dev_tools.discovery.analyzer.source_text import Detection

_REPO_ROOT = Path(__file__).resolve().parents[5]
_FIXTURES = _REPO_ROOT / "tests" / "fixtures" / "discovery_dotnet_vsto"
_SCHEMA_FILE = (
    _REPO_ROOT / "schemas" / "discovery" / "v1" / "evidence-reference.schema.json"
)

_ID_GRAMMAR = re.compile(r"^[a-z0-9][a-z0-9._-]*$")
_SCHEMA_VERSION_GRAMMAR = re.compile(r"^1\.\d+\.\d+$")
_REQUIRED_TOP_LEVEL_KEYS = {
    "$schema",
    "schema_version",
    "id",
    "kind",
    "location",
    "captured_at",
    "description",
}
_OPTIONAL_TOP_LEVEL_KEYS = {"content_hash", "tool", "metadata"}
_DETECTION_KIND_VOCABULARY = {
    "namespace",
    "type",
    "event_declaration",
    "delegate",
    "event_subscription",
    "ribbon_xml",
    "ribbon_extensibility",
    "com_attribute",
    "marshal_call",
    "progid_activation",
    "interop_using",
    "com_reference",
}


def _fixture_text(name: str) -> str:
    """Return the raw text of a committed fixture (real filesystem read)."""
    return (_FIXTURES / name).read_text(encoding="utf-8")


def _by_kind(detections: list[Detection], kind: str) -> list[Detection]:
    """Return detections filtered to one detection kind."""
    return [d for d in detections if d.detection_kind == kind]


def _extra_map(detection: Detection) -> dict[str, str | int]:
    """Return a detection's extra metadata pairs as a plain dict."""
    return dict(detection.extra)


class TestNamespaceDetection:
    """Namespace enumeration across block and file-scoped forms."""

    @pytest.mark.parametrize(
        ("source", "symbol", "form"),
        [
            ("namespace Foo.Bar {", "Foo.Bar", "block"),
            ("namespace Foo.Bar", "Foo.Bar", "block"),
            ("    namespace Nested.Space {", "Nested.Space", "block"),
            ("namespace Foo.Bar;", "Foo.Bar", "file_scoped"),
        ],
    )
    def test_namespace_forms(self, source: str, symbol: str, form: str) -> None:
        """Each namespace form is detected with the right declaration_form."""
        # Act
        detections = _by_kind(classify_text("a.cs", source), "namespace")

        # Assert
        assert len(detections) == 1
        assert detections[0].symbol == symbol
        assert detections[0].symbol_kind == "namespace"
        assert _extra_map(detections[0])["declaration_form"] == form

    def test_comment_namespace_trap_is_ignored(self) -> None:
        """A namespace look-alike inside a line comment does not match."""
        # Act
        detections = _by_kind(classify_text("a.cs", "// namespace Fake"), "namespace")

        # Assert
        assert detections == []


class TestTypeDetection:
    """Type enumeration across every supported kind and generic arity."""

    @pytest.mark.parametrize(
        ("source", "symbol", "symbol_kind", "arity"),
        [
            ("public class Widget {", "Widget", "class", 0),
            ("public sealed class Sealed {", "Sealed", "class", 0),
            ("struct PointValue {", "PointValue", "struct", 0),
            ("public interface IProcessor {", "IProcessor", "interface", 0),
            ("internal enum StatusCode {", "StatusCode", "enum", 0),
            ("public record PersonInfo(string N);", "PersonInfo", "record", 0),
            ("public record class AccountInfo(int I);", "AccountInfo", "record", 0),
            (
                "public readonly record struct Measurement(double A);",
                "Measurement",
                "record_struct",
                0,
            ),
            ("[Serializable] public class Attr {", "Attr", "class", 0),
            ("public class Repository<TEntity> {", "Repository", "class", 1),
            ("public class Pair<TFirst, TSecond> {", "Pair", "class", 2),
        ],
    )
    def test_type_forms(
        self, source: str, symbol: str, symbol_kind: str, arity: int
    ) -> None:
        """Type declarations normalize symbol_kind and capture generic arity."""
        # Act
        detections = _by_kind(classify_text("a.cs", source), "type")

        # Assert
        assert len(detections) == 1
        assert detections[0].symbol == symbol
        assert detections[0].symbol_kind == symbol_kind
        assert _extra_map(detections[0]).get("generic", 0) == arity

    def test_string_class_trap_is_ignored(self) -> None:
        """A class look-alike inside a string literal does not match."""
        # Act
        detections = _by_kind(
            classify_text("a.cs", 'var s = "class InString";'), "type"
        )

        # Assert
        assert detections == []


class TestDeclarationFixture:
    """Detection matrix driven by the raw declaration fixture."""

    def test_fixture_covers_all_forms_and_rejects_traps(self) -> None:
        """The declaration fixture yields all forms and no trap detections."""
        # Arrange / Act
        detections = classify_text(
            "declarations.cs", _fixture_text("csharp_declarations.cs.txt")
        )
        namespaces = _by_kind(detections, "namespace")
        types = _by_kind(detections, "type")
        namespace_symbols = {d.symbol for d in namespaces}
        type_symbols = {d.symbol for d in types}
        symbol_kinds = {d.symbol_kind for d in types}
        forms = {_extra_map(d)["declaration_form"] for d in namespaces}

        # Assert: both namespace forms and every type kind are present.
        assert {"block", "file_scoped"} <= forms
        assert "Delta.Epsilon" in namespace_symbols
        assert {
            "class",
            "struct",
            "interface",
            "enum",
            "record",
            "record_struct",
        } <= symbol_kinds
        # Assert: traps did not produce detections.
        assert "Fake" not in namespace_symbols
        assert "AlsoFake" not in namespace_symbols
        assert "InString" not in type_symbols
        assert "LiteralTrap" in type_symbols  # the enclosing class is a real type


class TestEventDelegateSubscription:
    """Event/delegate declarations and heuristic subscription detection."""

    @pytest.mark.parametrize(
        "source",
        [
            "publisher.Started += this.OnCompleted;",
            "publisher.Started += (sender, payload) => Handle(payload);",
            "publisher.Started += new EventHandler(this.OnCompleted);",
        ],
    )
    def test_subscription_positive_and_heuristic(self, source: str) -> None:
        """Handler subscriptions are detected and tagged heuristic."""
        # Act
        detections = _by_kind(classify_text("a.cs", source), "event_subscription")

        # Assert
        assert len(detections) == 1
        assert _extra_map(detections[0])["confidence"] == "heuristic"

    def test_unsubscription_records_operator(self) -> None:
        """An unsubscription records the ``-=`` operator in metadata."""
        # Act
        detections = _by_kind(
            classify_text("a.cs", "publisher.Completed -= this.OnCompleted;"),
            "event_subscription",
        )

        # Assert
        assert len(detections) == 1
        assert _extra_map(detections[0])["operator"] == "-="

    @pytest.mark.parametrize(
        "source",
        [
            "total += 3;",
            'var t = @"handler += SomeHandler";',
            'var m = $"count {total} += Other";',
        ],
    )
    def test_subscription_traps_rejected(self, source: str) -> None:
        """Arithmetic and string subscription look-alikes are rejected."""
        # Act
        detections = _by_kind(classify_text("a.cs", source), "event_subscription")

        # Assert
        assert detections == []

    def test_event_fixture_matrix(self) -> None:
        """The event fixture yields declarations, a delegate, and subscriptions."""
        # Arrange / Act
        detections = classify_text("events.cs", _fixture_text("csharp_events.cs.txt"))
        events = _by_kind(detections, "event_declaration")
        delegates = _by_kind(detections, "delegate")
        subscriptions = _by_kind(detections, "event_subscription")

        # Assert: named event and delegate declarations are present.
        event_symbols = {d.symbol for d in events}
        assert {"Started", "Completed", "Custom"} <= event_symbols
        assert {d.symbol for d in delegates} == {"MessageHandler"}
        # Assert: every subscription is heuristic and none target arithmetic.
        assert subscriptions
        assert all(_extra_map(d)["confidence"] == "heuristic" for d in subscriptions)
        assert all(d.symbol != "total" for d in subscriptions)


def _context(source_root: Path, out_root: Path) -> AnalyzerContext:
    """Return a pinned-clock run context for the analyzer under test."""
    return AnalyzerContext(
        source_root=source_root,
        include=(),
        exclude=(),
        artifact_root=out_root,
        schema_path=source_root.parent / "schemas" / "evidence-reference.schema.json",
        captured_at="2026-07-18T12:34:56Z",
    )


class TestErrorPathsAndRouting:
    """Narrowing failure, unreachable root, and include/exclude routing."""

    def test_classify_rejects_plain_parse_result(self) -> None:
        """classify raises AnalyzerError when handed a plain ParseResult."""
        # Arrange
        analyzer = DotnetInventoryAnalyzer(fs=RealAnalyzerFileSystem())

        # Act / Assert
        with pytest.raises(AnalyzerError):
            analyzer.classify(ParseResult(paths=("a.cs",)))

    def test_parse_unreachable_root_raises_analyzer_error(
        self, mem_fs_path: Path
    ) -> None:
        """parse fails fast with AnalyzerError, distinct from DomainProfileError."""
        # Arrange
        fs = RealAnalyzerFileSystem()
        analyzer = DotnetInventoryAnalyzer(fs=fs)
        ctx = _context(mem_fs_path / "missing", mem_fs_path / "out")

        # Act / Assert
        with pytest.raises(AnalyzerError) as exc_info:
            analyzer.parse(ctx)
        assert not isinstance(exc_info.value, DomainProfileError)
        assert "missing" in str(exc_info.value)

    @pytest.mark.parametrize(
        ("include", "exclude", "expected"),
        [
            ((), (), ("keep/a.cs", "skip/b.cs")),
            (("keep/*.cs",), (), ("keep/a.cs",)),
            ((), ("skip/*",), ("keep/a.cs",)),
            (("**/*.cs",), ("skip/*",), ("keep/a.cs",)),
            (("nomatch/*.cs",), (), ()),
        ],
    )
    def test_include_exclude_routing(
        self,
        mem_fs_path: Path,
        include: tuple[str, ...],
        exclude: tuple[str, ...],
        expected: tuple[str, ...],
    ) -> None:
        """parse honors include/exclude globs over consumer-relative paths."""
        # Arrange
        source_root = mem_fs_path / "consumer"
        (source_root / "keep").mkdir(parents=True, exist_ok=True)
        (source_root / "skip").mkdir(parents=True, exist_ok=True)
        (source_root / "keep" / "a.cs").write_text("class A {}", encoding="utf-8")
        (source_root / "skip" / "b.cs").write_text("class B {}", encoding="utf-8")
        (source_root / "keep" / "note.txt").write_text("x", encoding="utf-8")
        fs = RealAnalyzerFileSystem()
        analyzer = DotnetInventoryAnalyzer(fs=fs)
        ctx = AnalyzerContext(
            source_root=source_root,
            include=include,
            exclude=exclude,
            artifact_root=mem_fs_path / "out",
            schema_path=mem_fs_path / "schemas" / "s.json",
            captured_at="2026-07-18T12:34:56Z",
        )

        # Act
        parsed = analyzer.parse(ctx)

        # Assert: only ``.cs`` paths that survive the globs are selected.
        assert parsed.paths == expected


class TestEndToEndEmission:
    """End-to-end emission, schema conformance, and determinism."""

    def _build_tree(self, source_root: Path) -> None:
        """Populate an in-memory consumer tree from the raw fixtures."""
        source_root.mkdir(parents=True, exist_ok=True)
        (source_root / "declarations.cs").write_text(
            _fixture_text("csharp_declarations.cs.txt"), encoding="utf-8"
        )
        (source_root / "events.cs").write_text(
            _fixture_text("csharp_events.cs.txt"), encoding="utf-8"
        )

    def test_emits_schema_valid_instances(self, mem_fs_path: Path) -> None:
        """Every emitted instance validates against the discovery v1 schema."""
        # Arrange
        jsonschema = pytest.importorskip("jsonschema")
        validator_cls = jsonschema.Draft202012Validator
        schema = json.loads(_SCHEMA_FILE.read_text(encoding="utf-8"))
        validator = validator_cls(schema)
        source_root = mem_fs_path / "consumer"
        self._build_tree(source_root)
        fs = RealAnalyzerFileSystem()
        analyzer = DotnetInventoryAnalyzer(fs=fs)
        ctx = _context(source_root, mem_fs_path / "out")

        # Act
        result = run_analyzer(analyzer, ctx, fs)

        # Assert
        assert result.written_paths
        for path in result.written_paths:
            document = json.loads(path.read_text(encoding="utf-8"))
            validator.validate(document)
            top_level = set(document)
            assert _REQUIRED_TOP_LEVEL_KEYS <= top_level
            assert top_level <= _REQUIRED_TOP_LEVEL_KEYS | _OPTIONAL_TOP_LEVEL_KEYS
            assert document["kind"] == "file"
            assert "\n" not in document["location"]
            assert _ID_GRAMMAR.match(document["id"]) is not None
            assert _SCHEMA_VERSION_GRAMMAR.match(document["schema_version"]) is not None
            schema_ref = document["$schema"]
            assert not schema_ref.startswith("/")
            assert ":" not in schema_ref.split("/", 1)[0]
            assert document["metadata"]["detection_kind"] in _DETECTION_KIND_VOCABULARY

    def test_byte_identical_on_rerun(self, mem_fs_path: Path) -> None:
        """Re-running with a fixed clock produces byte-identical instances."""
        # Arrange
        source_root = mem_fs_path / "consumer"
        self._build_tree(source_root)
        fs = RealAnalyzerFileSystem()
        analyzer = DotnetInventoryAnalyzer(fs=fs)
        ctx = _context(source_root, mem_fs_path / "out")

        # Act
        first = run_analyzer(analyzer, ctx, fs)
        first_content = {
            p.name: p.read_text(encoding="utf-8") for p in first.written_paths
        }
        second = run_analyzer(analyzer, ctx, fs)
        second_content = {
            p.name: p.read_text(encoding="utf-8") for p in second.written_paths
        }

        # Assert
        assert first_content == second_content
