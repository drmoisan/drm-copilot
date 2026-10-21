# NCF2 checked repair freeze

Timestamp: 2026-10-21T05-15

Command: `SCRATCH/issue-980-p6t1-gateway-ncf2-freeze.py`

EXIT_CODE: 0

Output Summary: Two owned paths frozen after a clean Black/Ruff/Pyright/Pytest pass and 34 passing focused controls. Package/native/isolation and final acceptance remain coordinator-owned and pending.

Only _canonical_state_location changes in production. It resolves the complete RegistryLocation-derived path and accepts only an absolute result beneath the resolved trusted base with the exact native component suffix and workspace digest. The unchanged store still checks canonicality and external location. Lexical validation remains before resolution; no construction writes, fallback or host authority are introduced. No package-specific prefix is encoded.

The changed helper has fresh BODY coverage of 8/8 executable lines and 2/2 branches. Qualified file coverage is 139/140 lines (99.286%) and 39/40 branches (97.5%), combining fresh observations with exact AST-identical retained ranges. Raw focused coverage remains separate. The original uncovered line 145 and branch 144-to-145 are unchanged.

Eight new node IDs cover generic one/three intermediate components with existing/missing leaves, and relative/out-of-base/altered-layout/altered-partition refusals. All 26 original focused IDs and all existing test callable ASTs/assertions remain intact. Source/test sizes are 431/410 lines. The unchanged legacy factory test and low-level direct-store controls are retained.

The initial Black check required test formatting and is preserved with its formatter receipt. The single inserted-prefix reproducer then failed against the original helper, as required. After repair, all four loop1 gates passed with no input drift. No other failure or behavioral run occurred.

The JSON enumerates this repair's two code paths and 25 evidence paths, including its externally bound self: 27 paths total. The seven-path NCF2 diagnosis and prior NCF1 repair/native failures remain immutable references outside this repair-only union. No package, native fixture, checkpoint, staging, Git or acceptance state was changed here.

All readable views use UTF-8/LF without trailing whitespace. The proof archives exact original/current source and coverage bytes; its diff view normalizes both sides to LF. Raw process outputs remain lossless and their readable path aliases are explicitly qualified.
