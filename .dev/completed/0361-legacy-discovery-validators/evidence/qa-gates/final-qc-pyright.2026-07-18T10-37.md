Timestamp: 2026-07-18T10-37
Command: poetry run pyright
EXIT_CODE: 0
Output Summary: "0 errors, 0 warnings, 0 informations" on the final run of
this loop. One earlier run in this same Phase-7 pass reported two errors
(reportUnknownVariableType in validate_discovery_profile.py's
`_parse_profile_mapping`, and reportUnusedFunction on validate_json.py's
`_cache_path`, both visible only once pyright analyzed the whole
scripts+tests program rather than a per-file subset). Both were fixed
(`cast("dict[str, Any]", parsed)` narrowing; adding `_cache_path` to
`validate_json.py`'s `__all__` since it is a legitimate public seam retained
only for the `tests/scripts/dev_tools/test_validate_json.py` monkeypatch
target, per Phase 1's shared-extraction) and the loop was restarted from
P7-T1, yielding this clean final pass.
