"""Tests for docs_python_native.route_model: the FastAPI and Flask framework table."""

from docs_python_native.route_model import FRAMEWORKS, GENERIC_METHODS


class TestFastApiEntry:
    """Scenarios for the FastAPI entry in docs_python_native.route_model."""

    def test_constructors_prefix_key_call_and_mount_names(self) -> None:
        """Scenario: constructors prefix key call and mount names."""
        entry = FRAMEWORKS["fastapi"]
        assert entry.constructors == {
            "fastapi.FastAPI": "app",
            "fastapi.APIRouter": "router",
        }
        assert entry.prefix_key == "prefix"
        assert entry.call == "add_api_route"
        assert entry.mount == "include_router"
        assert entry.mount_key == "prefix"

    def test_method_set_includes_websocket_and_the_generic_route(self) -> None:
        """Scenario: method set includes websocket and the generic route."""
        entry = FRAMEWORKS["fastapi"]
        assert entry.methods == frozenset(
            {
                "get",
                "post",
                "put",
                "patch",
                "delete",
                "options",
                "head",
                "trace",
                "api_route",
                "websocket",
            }
        )
        assert GENERIC_METHODS["fastapi"] == "api_route"


class TestFlaskEntry:
    """Scenarios for the Flask entry in docs_python_native.route_model."""

    def test_constructors_prefix_key_call_and_mount_names(self) -> None:
        """Scenario: constructors prefix key call and mount names."""
        entry = FRAMEWORKS["flask"]
        assert entry.constructors == {
            "flask.Flask": "app",
            "flask.Blueprint": "blueprint",
        }
        assert entry.prefix_key == "url_prefix"
        assert entry.call == "add_url_rule"
        assert entry.mount == "register_blueprint"
        assert entry.mount_key == "url_prefix"

    def test_method_set_includes_the_generic_route(self) -> None:
        """Scenario: method set includes the generic route."""
        entry = FRAMEWORKS["flask"]
        assert entry.methods == frozenset(
            {"get", "post", "put", "patch", "delete", "route"}
        )
        assert GENERIC_METHODS["flask"] == "route"


class TestTable:
    """Scenarios for the framework table in docs_python_native.route_model."""

    def test_table_holds_exactly_the_two_frameworks(self) -> None:
        """Scenario: table holds exactly the two frameworks."""
        assert sorted(FRAMEWORKS) == ["fastapi", "flask"]
        assert sorted(GENERIC_METHODS) == ["fastapi", "flask"]
