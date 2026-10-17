# Acceptance-Criteria State (P9-T6)

Timestamp: 2026-10-16T06-51
Command: grep -c -e '^- \[x\] ' docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md; grep -c -e '^- \[ \] ' docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md
EXIT_CODE: 0
Output Summary:
- 17 checked, 1 unchecked; equal to P0-T18 (spec.md not edited this cycle).
- CR-6 closed by: rc2-cr6-parity-tests.2026-10-16T06-24.md, rc2-cr6-parity-discrimination.2026-10-16T06-24.md
- CR-8 closed by: fail-before-cr8-typescript.2026-10-16T06-26.md, fail-before-exception.2026-10-16T06-27.md, pass-after-cr8-cr10-python.2026-10-16T06-28.md, pass-after-cr8-cr10-typescript.2026-10-16T06-30.md
- CR-10 closed by: fail-before-cr10-typescript.2026-10-16T06-26.md, rc2-python-authority-before.2026-10-16T06-26.md, pass-after-cr8-cr10-typescript.2026-10-16T06-30.md
- CR-9 closed by: rc2-cr9-typescript-tests.2026-10-16T06-32.md, rc2-cr9-python-tests.2026-10-16T06-35.md, rc2-final-python-per-file-coverage.2026-10-16T06-44.md, rc2-final-typescript-lcov-coverage.2026-10-16T06-50.md
- O-1 (reported): Python _relative_path (now repository_relative_path) accepts drive-qualified C:/docs/x; TypeScript rejects it. Divergence remains; recommendation is a follow-up decision to add the drive rejection to Python.
- O-2 (reported): Python accepts plan_path equal to feature_folder; TypeScript requires the folder/ prefix. Not changed.
- O-3 (reported): residual readiness gaps remain (Python readiness 9 zero-hit lines; TypeScript readiness 23 zero-hit lines after renumbering); TypeScript baseline lines 37-40 and 42-43 moved and are now covered.
- AC18: deferred to S9
