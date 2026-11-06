"""Tests for docs_python_native.facts: raw facts, their protocol objects and outputs."""

from docs_python_native.facts import AnalyzerOutput, Fact, RawDiagnostic


class TestAnalyzerOutput:
    def test_facts_sort_properties_and_serialize_parents(self) -> None:
        output = AnalyzerOutput("python-cli")
        output.add_fact(
            "a.py",
            "cli-option",
            "r --x",
            "--x",
            (1, 2),
            {"b": True, "a": "v"},
            ("cli-command", "r", "a.py"),
        )
        output.add_fact("a.py", "architecture-component", "a", "a", None, {})
        first, second = output.facts["a.py"]
        assert first.to_json()["parent"] == {
            "kind": "cli-command",
            "declaration": "r",
            "path": "a.py",
        }
        assert first.to_json()["properties"] == {"a": "v", "b": True}
        assert (
            second.to_json()["line_start"] is None
            and second.to_json()["parent"] is None
        )

    def test_add_diagnostic_records_a_raw_diagnostic_per_path(self) -> None:
        output = AnalyzerOutput("python-http")
        output.add_diagnostic("a.py", "HTTP_DYNAMIC_ROUTE", 3)
        output.add_diagnostic("a.py", "HTTP_ROUTE_IN_LOOP", 5)
        assert output.diagnostics == {
            "a.py": [
                RawDiagnostic("HTTP_DYNAMIC_ROUTE", 3),
                RawDiagnostic("HTTP_ROUTE_IN_LOOP", 5),
            ]
        }


class TestFactToJson:
    def test_fact_with_a_parent_serializes_kind_declaration_and_path(self) -> None:
        fact = Fact(
            "python-cli",
            "cli-option",
            "tool --verbose",
            "--verbose",
            ("cli-command", "tool", "pyproject.toml"),
            4,
            6,
            (("framework", "click"), ("positional", False)),
        )
        assert fact.to_json() == {
            "analyzer_id": "python-cli",
            "kind": "cli-option",
            "declaration": "tool --verbose",
            "name": "--verbose",
            "parent": {
                "kind": "cli-command",
                "declaration": "tool",
                "path": "pyproject.toml",
            },
            "line_start": 4,
            "line_end": 6,
            "properties": {"framework": "click", "positional": False},
        }

    def test_fact_without_a_parent_serializes_a_null_parent(self) -> None:
        fact = Fact("python-public-api", "public-symbol", "pkg.f", "f", None, 1, 1, ())
        assert fact.to_json()["parent"] is None
        assert fact.to_json()["properties"] == {}

    def test_fact_with_a_none_span_serializes_null_line_bounds(self) -> None:
        fact = Fact(
            "python-architecture",
            "architecture-component",
            "pkg",
            "pkg",
            None,
            None,
            None,
            (("import_count", 0),),
        )
        serialized = fact.to_json()
        assert serialized["line_start"] is None and serialized["line_end"] is None
