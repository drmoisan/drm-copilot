# P5-T2 final reader hygiene

Timestamp: 2026-10-20T07-18
Command: Read-only reader search and SHA-256 comparison
EXIT_CODE: 0
Output Summary: All five existing scripts avoid locale-dependent text decoding; no modifications required.

Source, JSON and command streams are read as bytes. Text decoding is explicit UTF-8; authored writes specify UTF-8 and LF. Raw coverage JSON without a terminal newline remains valid exact tool output. Authored readable receipts retain their separate newline convention.

No production, test or runner changed. No behavioral command or final gate ran.
