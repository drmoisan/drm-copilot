"""Tests for docs_python_native.module_names: dotted names, packages, relatives."""

import pytest
from docs_python_native.module_names import (
    module_dotted_name,
    module_package,
    resolve_relative,
)


class TestModuleNames:
    """Scenarios for module names in docs_python_native.module_names."""

    @pytest.mark.parametrize(
        ("path", "roots", "expected"),
        [
            ("src/pkg/mod.py", ["src"], "pkg.mod"),
            ("src/pkg/__init__.py", ["src/"], "pkg"),
            ("src/pkg/sub/mod.py", ["src", "src/pkg"], "sub.mod"),
            ("mod.py", ["."], "mod"),
            ("other/mod.py", ["src"], None),
            ("src/pkg/data.txt", ["src"], None),
            ("src/__init__.py", ["src"], None),
            ("__init__.py", [""], None),
            ("src/pkg/bad-name.py", ["src"], None),
        ],
    )
    def test_module_dotted_name(
        self, path: str, roots: list[str], expected: str | None
    ) -> None:
        """Scenario: a path gives its dotted name under the longest root, or None."""
        assert module_dotted_name(path, roots) == expected

    def test_unvalidated_name_keeps_a_non_identifier_segment(self) -> None:
        """Scenario: unvalidated name keeps a non identifier segment."""
        assert module_dotted_name(
            "src/pkg/bad-name.py", ["src"], require_identifiers=False
        ) == ("pkg.bad-name")

    @pytest.mark.parametrize(
        ("path", "module", "expected"),
        [
            ("src/pkg/__init__.py", "pkg", "pkg"),
            ("src/pkg/mod.py", "pkg.mod", "pkg"),
            ("src/top.py", "top", ""),
            ("x.py", None, None),
        ],
    )
    def test_module_package(
        self, path: str, module: str | None, expected: str | None
    ) -> None:
        """Scenario: a module gives itself for __init__, else its parent package."""
        assert module_package(path, module) == expected

    @pytest.mark.parametrize(
        ("module", "package", "expected"),
        [
            ("pkg.mod", "x", "pkg.mod"),
            (".mod", "pkg.sub", "pkg.sub.mod"),
            ("..mod", "pkg.sub", "pkg.mod"),
            ("...mod", "pkg.sub", "mod"),
            ("....mod", "pkg.sub", None),
            (".", "pkg", "pkg"),
            ("..", "pkg", None),
            (".mod", "", None),
            (".mod", None, None),
        ],
    )
    def test_resolve_relative_climbs_and_stops_above_the_root(
        self, module: str, package: str | None, expected: str | None
    ) -> None:
        """Scenario: resolve relative climbs and stops above the root."""
        assert resolve_relative(module, package) == expected
