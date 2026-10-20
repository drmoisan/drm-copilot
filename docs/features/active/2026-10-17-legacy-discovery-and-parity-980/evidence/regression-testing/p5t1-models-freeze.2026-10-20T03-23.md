# P5-T1 checked helper and legacy subset

Timestamp: 2026-10-20T03-23

Status: Frozen for bounded independent confirmation; P5-T1 acceptance remains pending.

Recovered ordered pass7: Black, Ruff, Pyright and 114 passing cases (77 model and all 37 frozen legacy callers). Helper: 141/141 statements and 64/64 branches. Wrapper: 38/38 statements and 4/4 branches. All measured callable/class ranges have no uncovered executable statement or branch.

SR1 changes only the two immutable mapping traversal sites to direct member traversal. The original 64-member comparison probe is preserved; the new counted tests observe zero Mapping searches at 1, 16 and 64 members. All frozen legacy files remain byte-identical.

The paired JSON binds exact source bytes, ordered nodes, raw/portable coverage, static import closure against HEAD, original diagnostics, executed harnesses and qualified readable normalization. Runtime coverage graph drafts remain excluded and unchanged.
