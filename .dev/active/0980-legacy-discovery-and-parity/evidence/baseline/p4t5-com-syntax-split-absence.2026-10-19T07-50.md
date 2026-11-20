# P4-T5 COM syntax split absence

Timestamp: 2026-10-19T07-50
Command: python SCRATCH/issue-980-p4t5-com-syntax-split.py
EXIT_CODE: 0
Output Summary: Approved new pure syntax module was absent before creation; three reviewed streams were preserved exactly.

Only `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/com_syntax.py` is added to the existing ownership. The fixed C# allowlists and candidate scanner move together; `com_interop.com_source_candidates` remains an explicit re-export. XML, retained-input provenance and inventory projection remain in `com_interop.py`. This provides space for bounded R1 context discrimination without compressing the existing 496-line module. R3 adds intent comments without changing assertions. The paired JSON binds the immutable shared baseline and reviewed source streams.
