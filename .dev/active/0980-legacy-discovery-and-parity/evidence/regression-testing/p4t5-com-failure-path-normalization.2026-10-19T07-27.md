# P4-T5 COM failure evidence path normalization

Timestamp: 2026-10-19T07-27
Command: python SCRATCH/issue-980-p4t5-com-freeze.py
EXIT_CODE: 0
Output Summary: Two environment-repr lines per presentation were redacted; all original bytes were preserved under SCRATCH.

The original Windows setup and teardown failure diagnostics remain intact. Only host-local environment representations were replaced; exit code, command, actual times, duration, source hashes, test result, assertion traceback and error messages are unchanged. The paired JSON binds exact original and published hashes and line positions. This is evidence sanitization, not Git normalization or a behavioral correction. All three source/test files and all passing command receipts remain unchanged. No test was rerun for this normalization.
