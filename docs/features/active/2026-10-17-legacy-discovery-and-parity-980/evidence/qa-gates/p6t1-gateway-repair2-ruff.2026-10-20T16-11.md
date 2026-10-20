Timestamp: 2026-10-20T16-11
Command: `.venv/Scripts/python.exe -m ruff check --fix packages/discovery-runtime/src/drm_copilot_discovery/gateway.py packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py packages/discovery-runtime/src/drm_copilot_discovery/doctor.py tests/discovery_runtime/test_gateway.py tests/discovery_runtime/test_gateway_local.py tests/discovery_runtime/test_doctor.py tests/discovery_runtime/gateway_test_support.py tests/discovery_runtime/test_gateway_boundaries.py`
EXIT_CODE: 1
Output Summary: repair2-ruff; exit 1; elapsed 0.118 seconds.

```text
E501 Line too long (90 > 88)
  --> tests\discovery_runtime\gateway_test_support.py:97:89
   |
96 | def result_for(exit_code: int = 0) -> DiscoveryResult:
97 |     """Build a complete memory result with an actually observed empty input set. exit_code
   |                                                                                         ^^
98 |     (int): selected supported outcome code. Returns DiscoveryResult; memory-only
99 |     effects; AssertionError on mismatch.
   |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\gateway_test_support.py:190:89
    |
188 |     repository: RepositoryReader | None = None,
189 | ) -> tuple[ConfigurationCase, LocalServiceIO, CapturedWorkspace]:
190 |     """Bind the real local adapter to a complete fresh captured memory workspace. catalog
    |                                                                                         ^
191 |     (SchemaCatalog): verified immutable schema catalog. repository (RepositoryReader |
192 |     None): exact optional repository reader. Returns tuple[ConfigurationCase,
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\gateway_test_support.py:219:89
    |
218 |     def __init__(self, content: bytes, *, code: int = 0, pipe: bool = True) -> None:
219 |         """Retain isolated output and completion flags. content (bytes): immutable input or
    |                                                                                         ^^^
220 |         simulated output bytes. code (int): selected fixed failure or simulated process
221 |         status. pipe (bool): whether simulated stdout is available. Returns None;
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\gateway_test_support.py:245:89
    |
244 |     def wait(self, timeout: float | None = None) -> int:
245 |         """Complete the simulated command and return its selected exit code. timeout (float
    |                                                                                         ^^^
246 |         | None): optional process wait deadline in seconds. Returns int; memory-only
247 |         effects; AssertionError on mismatch.
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_doctor.py:402:89
    |
401 |     def select(self: ActivationStore, **options: object) -> ConfigurationSelection:
402 |         """Request an intentionally stricter bound through the composed read port. options
    |                                                                                         ^^
403 |         (object): captured fixed keyword options. Returns ConfigurationSelection;
404 |         memory-only effects; AssertionError on mismatch.
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_gateway.py:166:89
    |
164 |     config_catalog: SchemaCatalog,
165 | ) -> None:
166 |     """A second JSON document arriving after a short read cannot be ignored. config_catalog
    |                                                                                         ^^^
167 |     (SchemaCatalog): verified immutable schema fixture. Returns None; memory-only
168 |     effects; AssertionError on mismatch.
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_gateway.py:175:89
    |
174 |         def read(self, size: int | None = -1) -> bytes:
175 |             """Return at most two bytes; the caller must continue to true EOF. size (int |
    |                                                                                         ^^
176 |             None): requested bounded read size. Returns bytes; memory-only effects;
177 |             AssertionError on mismatch.
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_gateway.py:200:89
    |
199 |         def read(self, size: int | None = -1) -> bytes:
200 |             """Return one excess byte to exercise the boundary contract. size (int | None):
    |                                                                                         ^^^
201 |             requested bounded read size. Returns bytes; memory-only effects;
202 |             AssertionError on mismatch.
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_gateway.py:368:89
    |
366 |         root: str, repository: RepositoryReader | None, principal: str, author: str
367 |     ) -> LocalServiceIO:
368 |         """Bind isolated storage to the exact entry-selected repository reader. root (str):
    |                                                                                         ^^^
369 |         trusted absolute canonical workspace. repository (RepositoryReader | None):
370 |         exact optional repository reader. principal (str): explicit outer principal;
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_gateway_boundaries.py:108:89
    |
106 |     assert errors == "Discovery result failed unexpectedly; no replacement emitted.\n"
107 |     assert "private-" not in raw + errors
108 |     # A flush failure may follow a whole document; write failures retain only their prefix.
    |                                                                                         ^^^
109 |     if stage == "flush":
110 |         assert raw.endswith("\n")
    |

E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_gateway_boundaries.py:132:89
    |
131 |     def raced_kill() -> None:
132 |         """Model exit during cancellation; mark completion then raise ProcessLookupError."""
    |                                                                                         ^^^^
133 |         process.finished = True
134 |         raise ProcessLookupError("synthetic completed child")
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_gateway_local.py:173:89
    |
171 |     config_catalog: SchemaCatalog,
172 | ) -> None:
173 |     """A capture from another root never enters authorization or mutation. config_catalog
    |                                                                                         ^
174 |     (SchemaCatalog): verified immutable schema fixture. Returns None; memory-only
175 |     effects; AssertionError on mismatch.
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_gateway_local.py:371:89
    |
370 |     def start(argv: tuple[str, ...], **options: object) -> MemoryProcess:
371 |         """Record safe process arguments without invoking an executable. argv (tuple[str,
    |                                                                                         ^
372 |         ...]): fixed outer argument sequence. options (object): captured fixed keyword
373 |         options. Returns MemoryProcess; memory-only effects; AssertionError on mismatch.
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_gateway_local.py:438:89
    |
436 |     monkeypatch: pytest.MonkeyPatch,
437 | ) -> None:
438 |     """Compose real ports without reads through patched native boundaries. config_catalog
    |                                                                                         ^
439 |     (SchemaCatalog): verified immutable schema fixture. monkeypatch
440 |     (pytest.MonkeyPatch): test-local restoration of injected seams. Returns None;
    |


Fixed 18 errors:
- tests\discovery_runtime\test_gateway.py:
    9 × F401 (unused-import)
    1 × I001 (unsorted-imports)
- tests\discovery_runtime\test_gateway_local.py:
    7 × F401 (unused-import)
    1 × I001 (unsorted-imports)

Found 32 errors (18 fixed, 14 remaining).

```
