# P6-T3 compatibility subset lint

Timestamp: 2026-10-21T16-42

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m ruff check scripts/dev_tools/validate_discovery_artifacts.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`

EXIT_CODE: 1

Output Summary: FAIL; 0.209 seconds; 0 passed nodes.

```text
E501 Line too long (91 > 88)
   --> tests\scripts\dev_tools\test_validate_discovery_artifacts_dispatch.py:222:89
    |
221 |     def installed(command: str, argv: Sequence[str] | None = None) -> int:
222 |         """Record command (str), argv (Sequence[str] | None); return exit 1 without I/O."""
    |                                                                                         ^^^
223 |         calls.append((command, argv))
224 |         return 1
    |

E501 Line too long (89 > 88)
   --> tests\scripts\dev_tools\test_validate_discovery_artifacts_dispatch.py:283:89
    |
282 |     def measure(_self: ReportBudget, value: str) -> None:
283 |         """Record value (str) for _self (ReportBudget); return None without traversal."""
    |                                                                                         ^
284 |         measured.append(value)
    |

E501 Line too long (89 > 88)
   --> tests\scripts\dev_tools\test_validate_discovery_artifacts_dispatch.py:366:89
    |
365 | def test_report_mixed_routes_refuse_before_callbacks() -> None:
366 |     """Return None after fixed ValueError for mixed routes; no callbacks or I/O exist."""
    |                                                                                         ^
367 |     with pytest.raises(ValueError, match="separately"):
368 |         validator.report_arguments(
    |

E501 Line too long (92 > 88)
   --> tests\scripts\dev_tools\test_validate_discovery_artifacts_dispatch.py:384:89
    |
383 |     def read(path: Path, encoding: str | None = None) -> str:
384 |         """Record path (Path), encoding (str | None); return text or raise fixed OSError."""
    |                                                                                         ^^^^
385 |         calls.append((path, encoding))
386 |         if path.name == "bad":
    |

Found 4 errors.

```
