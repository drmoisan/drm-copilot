# p4t5-com-focused3-lint

Timestamp: 2026-10-19T07-23
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/com_interop.py tests/discovery_runtime/analyzer/test_com_interop.py tests/discovery_runtime/analyzer/test_com_candidates.py
EXIT_CODE: 1
Output Summary: FAIL scoped COM stage 2; duration 1.189 seconds. Exact bytes and original command output are in the paired JSON.

```text
E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\com_interop.py:109:89
    |
107 |     max_tokens/max_candidates (int, default 100000) bound token and result counts.
108 |     Zero candidate capacity is permitted for proving that no findings exist. Invalid
109 |     limits raise ValueError; SourceScanError rejects lexical input, delimiters or limits.
    |                                                                                         ^
110 |     Attributes use bracket context; calls require a known owner/member and opening
111 |     parenthesis. Binding, aliases, preprocessing and generic calls are unresolved.
    |

Found 1 error.
```
