# Remediation Cycle 1 Coverage Artifacts and Evidence Locations (P7-T5)

Timestamp: 2026-10-16T04-26
Command: ls -l extensions/drm-copilot/coverage/lcov.info artifacts/python/lcov.info; git ls-files -- extensions/drm-copilot/coverage artifacts/python; grep -c -e '^SF:' artifacts/python/lcov.info; grep -c -F -e 'epic-planner-state-core.ts' extensions/drm-copilot/coverage/lcov.info; grep -c -F -e 'epic-orchestrator-state-launch-binding.ts' extensions/drm-copilot/coverage/lcov.info; grep -c -F -e 'epic-planner-git-integrity.ts' extensions/drm-copilot/coverage/lcov.info; poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT_CODE: 0
Output Summary:
- -rw-r--r-- 1 DanMoisan 197121 497505 Oct 16 00:16 artifacts/python/lcov.info
- -rw-r--r-- 1 DanMoisan 197121 715392 Oct 16 00:20 extensions/drm-copilot/coverage/lcov.info
- git ls-files: no output (neither artifact is tracked or committed)
- SF: records in artifacts/python/lcov.info: 214 (greater than 1)
- TypeScript per-file records: epic-planner-state-core.ts 1; epic-orchestrator-state-launch-binding.ts 1; epic-planner-git-integrity.ts 1
- validate_evidence_locations.py --root .: exit 0, no output, no VIOLATION: line
