# QA Gate: File Sizes

Timestamp: 2026-10-02T01-44
Command: wc -l scripts/dev_tools/pr_context/verification_evidence.py extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts tests/scripts/dev_tools/pr_context/test_verification_evidence.py tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py
EXIT_CODE: 0
Output Summary:
- `scripts/dev_tools/pr_context/verification_evidence.py`: 218 (ceiling 225)
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`: 295 (ceiling 300)
- `tests/scripts/dev_tools/pr_context/test_verification_evidence.py`: 403 (ceiling 420)
- `tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py`: 185 (ceiling 200)
- `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts`: 453 (ceiling 460)
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`: 402 (ceiling 480)
- total 1956. Every file is at or below its ceiling and below the 500-line limit.
