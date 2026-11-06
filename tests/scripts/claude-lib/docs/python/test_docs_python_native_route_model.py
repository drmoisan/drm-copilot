"""Tests for docs_python_native.route_model: the FastAPI and Flask framework table."""

from docs_python_native.route_model import FRAMEWORKS, GENERIC_METHODS


class TestFastApiEntry:
    def test_constructors_prefix_key_call_and_mount_names(self) -> None:
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
    def test_constructors_prefix_key_call_and_mount_names(self) -> None:
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
        entry = FRAMEWORKS["flask"]
        assert entry.methods == frozenset(
            {"get", "post", "put", "patch", "delete", "route"}
        )
        assert GENERIC_METHODS["flask"] == "route"


class TestTable:
    def test_table_holds_exactly_the_two_frameworks(self) -> None:
        assert sorted(FRAMEWORKS) == ["fastapi", "flask"]
        assert sorted(GENERIC_METHODS) == ["fastapi", "flask"]
