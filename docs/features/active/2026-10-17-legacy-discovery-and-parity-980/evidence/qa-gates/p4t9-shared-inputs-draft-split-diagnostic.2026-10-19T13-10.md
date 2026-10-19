# P4-T9 Draft Test Split Diagnostic

Timestamp: 2026-10-19T13-10
Command: `poetry run python SCRATCH/issue-980-shared-inputs-split.py`
EXIT_CODE: 1
Output Summary: The draft test-mover comparison used the Windows default cp1252 decoder for UTF-8 source. Only the Unicode parameter-matrix function differed under that incorrect decoder.

The original helper is preserved by hash in the paired JSON. This failed check
does not establish AST equivalence. The four copied test functions remain in the
approved split and the UTF-8 Unicode cases run in the focused suite. No accepted
source or test module was affected. Subsequent evidence readers specify UTF-8.
