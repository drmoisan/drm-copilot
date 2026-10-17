# Coverage Artifacts and Evidence Locations (P9-T5)

Timestamp: 2026-10-16T06-51
Command: ls -l extensions/drm-copilot/coverage/lcov.info artifacts/python/lcov.info; git ls-files -- extensions/drm-copilot/coverage artifacts/python; grep -c -e '^SF:' artifacts/python/lcov.info; grep -c -F -e 'epic-planner-readiness-integrity.ts' extensions/drm-copilot/coverage/lcov.info; grep -c -F -e 'epic-planner-git-integrity.ts' extensions/drm-copilot/coverage/lcov.info; poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT_CODE: 0
Output Summary:
- -rw-r--r-- 1 DanMoisan 197121 497444 Oct 16 02:41 artifacts/python/lcov.info
- -rw-r--r-- 1 DanMoisan 197121 716442 Oct 16 02:47 extensions/drm-copilot/coverage/lcov.info
- git ls-files: empty (both coverage outputs untracked and git-ignored).
- Python SF: count 214 (> 1).
- TypeScript per-file records: epic-planner-readiness-integrity.ts 1, epic-planner-git-integrity.ts 1.
- validate_evidence_locations.py: exit 0, no output, no VIOLATION: line.
