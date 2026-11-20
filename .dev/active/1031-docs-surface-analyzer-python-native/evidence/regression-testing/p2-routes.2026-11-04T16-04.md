# [P2-T5] PKG/routes.py

Timestamp: 2026-11-04T16-04
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_routes.py
EXIT_CODE: 0
Output Summary: 17 passed, 0 failed, 0 errors. Cases: FastAPI verbatim and Flask joined template composition; literal methods= lists (absent, deduplicated upper-case, tuple, empty, name, non-literal item); FastAPI decorators, api_route, websocket (WEBSOCKET, protocol websocket), add_api_route, include_router with and without prefix, a cross-module prefix through from . import and an aliased from-import, a <dynamic> router and mount prefix (prefix_resolved false, HTTP_PREFIX_DYNAMIC), an unmounted router; the HTTP codes HTTP_DYNAMIC_ROUTE, HTTP_ROUTE_IN_LOOP, HTTP_MOUNT_UNRESOLVED, HTTP_UNBOUND_ROUTE, HTTP_INCLUDE_UNRESOLVED (cycle and depth 17), HTTP_METHOD_VIEW_UNRESOLVED and HTTP_PREFIX_DYNAMIC; Flask route, shortcuts, blueprint url_prefix replaced by register_blueprint, add_url_rule.
