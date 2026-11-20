Timestamp: 2026-10-20T14-55
Command: `.venv/Scripts/python.exe -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/gateway.py packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py packages/discovery-runtime/src/drm_copilot_discovery/doctor.py tests/discovery_runtime/test_gateway.py tests/discovery_runtime/test_gateway_local.py tests/discovery_runtime/test_doctor.py`
EXIT_CODE: 1
Output Summary: loop1-ruff; exit 1; elapsed 0.148 seconds.

```text
F401 [*] `drm_copilot_discovery.models.canonical_json` imported but unused
  --> tests\discovery_runtime\test_gateway.py:16:67
   |
14 | from drm_copilot_discovery.findings import Finding
15 | from drm_copilot_discovery.gateway_local import LocalServiceIO
16 | from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
   |                                                                   ^^^^^^^^^^^^^^
17 | from drm_copilot_discovery.resources import ResourceError
18 | from drm_copilot_discovery.schema_validation import validate_document
   |
help: Remove unused import: `drm_copilot_discovery.models.canonical_json`

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_gateway.py:30:5
   |
29 |   if TYPE_CHECKING:
30 | /     from drm_copilot_discovery.analyzer.registry import InventoryRegistry
31 | |     from drm_copilot_discovery.catalog import SchemaCatalog
32 | |     from drm_copilot_discovery.models import JsonValue
33 | |     from drm_copilot_discovery.repository_reader import RepositoryReader
34 | |     from drm_copilot_discovery.service_contracts import Clock, ServiceIO
35 | |     from typing import Literal
   | |______________________________^
36 |
37 |   REQUEST = b'{"operation":"doctor","mode":"structural"}'
   |
help: Organize imports

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\test_gateway.py:272:89
    |
270 |     known: bool,
271 | ) -> None:
272 |     """Emergency bytes validate against intact schemas without pretending live validation."""
    |                                                                                         ^^^^^
273 |     failed = gateway._failure(
274 |         code="RUNTIME_UNAVAILABLE",
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_gateway.py:313:89
    |
311 |     failure: Exception,
312 | ) -> None:
313 |     """A completed or invalid result cannot be relabeled an empty preexecution failure."""
    |                                                                                         ^^
314 |
315 |     def fail(self: DiscoveryResult) -> str:
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_gateway_local.py:159:89
    |
157 |     config_catalog: SchemaCatalog,
158 | ) -> None:
159 |     """The local adapter forwards real capture and revocation instead of a placeholder."""
    |                                                                                         ^^
160 |     case, local, baseline = memory_io(config_catalog)
161 |     authority = local.authorize(doctor_request(case), baseline=baseline)
    |

E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_gateway_local.py:369:89
    |
367 |     monkeypatch: pytest.MonkeyPatch,
368 | ) -> None:
369 |     """Production factory composes real ports without reads through patched native seams."""
    |                                                                                         ^^^^
370 |     case = ConfigurationCase(config_catalog)
371 |     monkeypatch.setattr(Path, "resolve", lambda self, strict=False: self)
    |

Found 6 errors.
[*] 2 fixable with the `--fix` option.

```
