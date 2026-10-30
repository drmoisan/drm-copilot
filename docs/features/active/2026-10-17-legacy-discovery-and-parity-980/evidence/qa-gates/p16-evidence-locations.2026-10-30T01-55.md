# P16-T8 Evidence-location validator

Timestamp: 2026-10-30T01-55
Task: [P16-T8] Run the repository and publication contracts under the tiered file-size policy.
Command: poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT_CODE: 0
Output Summary: The validator exited 0 with no finding printed: every evidence artifact of the feature is under `<FEATURE>/evidence/<kind>/` and no artifact lives under a non-canonical `artifacts/` path (the P15-T2 cleanup holds after Phases 15 and 16).
Run window 2026-10-30T01-53 to 01-55 UTC on the remediated tree (`git status --porcelain` empty at start and end).
Result: PASS
