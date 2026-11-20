# P4-T7 .NET parser candidate

Timestamp: 2026-10-19T10-09
Command: poetry run python SCRATCH/p4t7-dotnet-freeze.py
EXIT_CODE: 0

63 in-memory cases passed. Black, Ruff and scoped Pyright passed on unchanged bytes. Coverage:126/126 executable lines and66/66 branches; all9 callable ranges100%. Source332lines, tests408lines. Raw streams and SQLite stay in SCRATCH with checksums; coverage JSON has repository-relative paths. Earlier format/import failures remain retained.

Entrypoint: parse_dotnet_dependencies(content, *, format, limits). Selectors: project, packages-config, packages-lock. The result contains sanitized candidates only. Declared operations, version roles and lock edges remain unresolved syntax. Conservative JSON limits use max_nodes//64 structural records; budgets below64 fail closed.

Final composed validation must bind the repaired shared module. Independent review and task acceptance remain pending. See p4t7-dotnet-freeze.2026-10-19T10-09.json for exact bindings, callable ranges, timings and receipts.
