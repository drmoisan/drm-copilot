# P5-T5 RC2 focused repair

Black, Ruff and scoped Pyright passed. The single new public-renderer guard control passed in 2.013 seconds and executed line 179 and branch 178 -> 179 of `_trace` with a real exhausted byte budget. It verified zero JSON serialization and no returned partial bundle.

All 77 existing renderer nodes, original test bytes/assertions and frozen production/dependency/example streams remain preserved. No existing batch was replayed. The named-body narrow result is 7/9 statements and 3/4 branches; exact-source union with retained 118-case coverage gives 9/9 and 4/4. This is supporting branch proof; the authoritative 119-case aggregate and independent confirmation remain pending.

Exact evidence, raw archive and qualifications: `p5t5-renderer-rc2-freeze.2026-10-20T13-44.json`.
Stage only the explicit union in `p5t5-renderer-rc2-staging.2026-10-20T13-44.json`.
