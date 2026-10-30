# P6-T1 publication repair lint

Timestamp: 2026-10-21T08-16

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py packages/discovery-runtime/src/drm_copilot_discovery/migration_capture.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py tests/discovery_runtime/test_service_publication.py tests/discovery_runtime/test_service_migration.py`

EXIT_CODE: 1

Output Summary: FAIL; 0.260 seconds; 0 passed nodes.

```text
E501 Line too long (91 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\migration_capture.py:62:89
   |
60 |         """Bind io (InitializationIO), base (CapturedWorkspace), limits (ParseLimits).
61 |
62 |         Return None; reject aggregate file/byte/work excess with ReportLimitError. Existing
   |                                                                                         ^^^
63 |         immutable bytes are retained by reference; no profile setting is changed.
64 |         """
   |

E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\migration_capture.py:114:89
    |
112 |         self.path_work(entry.identity or "", 1)
113 |         self.path_work(entry.resolved_path or "", 1)
114 |         # Metadata is a trusted bounded return, but subsequent namespace work is not free.
    |                                                                                         ^^
115 |         for child in entry.children:
116 |             self.path_work(child, len(entry.children))
    |

E501 Line too long (95 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\migration_capture.py:217:89
    |
215 |         directories: tuple[str, ...] = (),
216 |     ) -> InitializationCapture:
217 |         """Capture typed proposal inputs plus selected originals; return InitializationCapture.
    |                                                                                         ^^^^^^^
218 |
219 |         profile_path (str), profile_bytes (bytes), directories (tuple[str, ...])
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_service_migration.py:213:89
    |
211 |     )
212 |     assert bound is not io.initialization
213 |     # Binding copies public capabilities by identity, never reconstructing private state.
    |                                                                                         ^
214 |     for port in (
215 |         "workspace_root",
    |

Found 4 errors.

```
