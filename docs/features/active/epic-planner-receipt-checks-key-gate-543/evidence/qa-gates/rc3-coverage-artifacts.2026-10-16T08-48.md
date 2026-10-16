# Remediation Cycle 3 Coverage Artifacts and Evidence Locations (P7-T5)

Timestamp: 2026-10-16T08-48
Command: ls -l extensions/drm-copilot/coverage/lcov.info artifacts/python/lcov.info; git ls-files -- extensions/drm-copilot/coverage artifacts/python; grep -c -e '^SF:' artifacts/python/lcov.info; grep -c -F -e 'epic-planner-readiness-integrity.ts' extensions/drm-copilot/coverage/lcov.info; poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT_CODE: 0
Output Summary:
- -rw-r--r-- 1 DanMoisan 197121 497453 Oct 16 04:38 artifacts/python/lcov.info (local time; P5-T5 run)
- -rw-r--r-- 1 DanMoisan 197121 716641 Oct 16 04:42 extensions/drm-copilot/coverage/lcov.info (local time; P6-T5 run)
- git ls-files output: (empty); neither coverage file is tracked
- Python lcov SF: count: 214 (greater than 1)
- TypeScript readiness record count: 1 (at least 1)
- Evidence-location validator: exit 0, no output, no VIOLATION: line
