# P2-T6 preliminary independent review

Timestamp: 2026-10-18T09-23

Command: `poetry run python SCRATCH/issue-980-review-p2t6.py`

EXIT_CODE: 0

Output Summary: 29 cases executed; 27 probe expectations passed and two needed correction to existing diagnostic codes. Both coverage behaviors rejected the invalid input as intended. The script was a diagnostic collector and did not assert all-case success.

The duplicate record also produced upstream DUPLICATE_RECORD_ID. The foreign component produced COVERAGE_FOREIGN_COMPONENT, COVERAGE_MISSING and COVERAGE_SCOPE, plus upstream REFERENCE_LINKAGE. The expectations were corrected without changing production.

Both production files changed during execution, so this preliminary result is not final-source verification. Initial hashes: coverage_rules.py 5ad00bf2fe6138073248f81d1483540fd906017bd294f66d3eb566a93818786d; coverage_scope_rules.py 374d4a84e91fda6d4dd3532f5307d097fedfd9aa7b551172eb580c8210ee680c. Final hashes: 843aa872c69f10751b833f0c2d5eb619a9c949225de53b3609821140d0d0fc46 and b34a8064bea43e0005a8650a73eaa00a7ab14f245a63046f369af65d1f091b3e respectively.
