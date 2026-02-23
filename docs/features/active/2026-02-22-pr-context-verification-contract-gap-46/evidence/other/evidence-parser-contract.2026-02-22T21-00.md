Timestamp: 2026-02-22T21-00
Command: parser normalization contract freeze (manual)
EXIT_CODE: 0
Output Summary: Evidence parser normalization and fallback rules frozen.

Normalization Rules:
- `EXIT_CODE == 0 -> pass`
- `EXIT_CODE != 0 -> fail`
- missing required field => `unparseable` fallback
