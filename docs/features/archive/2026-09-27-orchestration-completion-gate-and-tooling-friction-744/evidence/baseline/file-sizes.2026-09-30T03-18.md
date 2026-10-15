# Baseline File Sizes

Timestamp: 2026-10-02T01-18
Timestamp-Correction: original value 2026-10-02T01-17 was a Phase 0 start reading reused through Phase 4; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T02-02.md), an upper bound on the command run time.
Command: wc -l scripts/dev_tools/pr_context/verification_evidence.py extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts tests/scripts/dev_tools/pr_context/test_verification_evidence.py extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts
EXIT_CODE: 0
Output Summary:
- scripts/dev_tools/pr_context/verification_evidence.py: 215 (ceiling 225)
- extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts: 293 (ceiling 300)
- tests/scripts/dev_tools/pr_context/test_verification_evidence.py: 408 (ceiling 420)
- extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts: 456 (ceiling 460)
- total: 1372
- All four counts equal the planning-session counts; none exceeds its ceiling.
