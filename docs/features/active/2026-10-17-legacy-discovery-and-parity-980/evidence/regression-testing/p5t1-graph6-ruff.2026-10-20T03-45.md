# P5-T1 graph6-ruff

Timestamp: 2026-10-20T03-45
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/coverage_report.py packages/discovery-runtime/src/drm_copilot_discovery/coverage_population.py tests/discovery_runtime/test_coverage_report.py tests/discovery_runtime/test_coverage_report_contract.py
EXIT_CODE: 1

Duration seconds: 1.139

```text
E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_coverage_report.py:166:89
    |
164 |     valid: bool,
165 | ) -> None:
166 |     """Excluded authored status alone cannot hide an undispositioned scope obligation."""
    |                                                                                         ^
167 |     snapshot = coverage_snapshot(
168 |         snapshot_profile,
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_coverage_report.py:251:89
    |
249 |     expected: int,
250 | ) -> None:
251 |     """Only validated observation/pass claims with exact runtime proof support coverage."""
    |                                                                                         ^^^
252 |     known = "Recorded behavior." if status == "passed" else None
253 |     runs = [execution(status, known, id="one"), execution(status, known, id="two")]
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_coverage_report.py:299:89
    |
297 |     defect: str,
298 | ) -> None:
299 |     """Authored observed status remains visible while missing/invalid proof counts zero."""
    |                                                                                         ^^^
300 |     record = scenario(
301 |         snapshot_profile,
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_coverage_report.py:387:89
    |
385 |     verified: int,
386 | ) -> None:
387 |     """Actual proof supports either confidence while observation status stays separate."""
    |                                                                                         ^^
388 |     snapshot = coverage_snapshot(snapshot_profile, snapshot_catalog)
389 |     snapshot = change(
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_coverage_report_contract.py:123:89
    |
121 |     monkeypatch: pytest.MonkeyPatch,
122 | ) -> None:
123 |     """The producer rejects prospective UTF-8 excess before invoking graph assessment."""
    |                                                                                         ^
124 |     profile = profile_with(
125 |         snapshot_profile, snapshot_catalog, limits={"document_bytes": 4096}
    |

Found 5 errors.

```
