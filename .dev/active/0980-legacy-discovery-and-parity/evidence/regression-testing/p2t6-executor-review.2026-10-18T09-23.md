# P2-T6 consolidated independent review

Timestamp: 2026-10-18T09-23

Command: `poetry run python SCRATCH/issue-980-review-p2t6.py`

EXIT_CODE: 0

Output Summary: 46 bounded cases executed; 44 passed and two established production defects. All artifacts in the two failing cases pass the authoritative schemas, and both cases have zero upstream reference, evidence, claim and revision findings. The diagnostic collector intentionally records failures without asserting success; this result does not accept P2-T6.

Machine result: [46-case review](p2t6-executor-review.2026-10-18T09-23.json).

1. A confirmed feature-only scope, with no explicit roots or component IDs, has a path-specific blocking parse diagnostic and an unreadable input but zero detected components. Coverage completion produces no finding because selects_path does not include that failed input. Conservative feature-only selection must include unclassified inputs as well as detected components.
2. An imported historical source scope/ledger/inventory shares the target checkout repository ID, while source pin a repeated 40 times and target pin b repeated 40 times remain distinct. Current target input modern/New.cs triggers COVERAGE_INPUTS against the historical source inventory. Current-local input accounting must use origin/pin identity as well as repository ID.

The specialist and coordinator received these two findings together. No prior-task production or policy changes were requested. Source hashes stayed unchanged across all 46 cases: coverage_rules.py 843aa872c69f10751b833f0c2d5eb619a9c949225de53b3609821140d0d0fc46; coverage_scope_rules.py b34a8064bea43e0005a8650a73eaa00a7ab14f245a63046f369af65d1f091b3e.

Passing cases cover valid complete and structural graphs, honest drafts, missing/duplicate/foreign ledger components, blocked/unassigned dispositions, supporting/excluded rationales, runtime declarations, evidence categories, scope confirmation and ownership, exact input accounting, deterministic scan configuration, source hash composition, path-component boundaries and supported Python syntax. Canonical result details distinguish expected upstream failures from coverage-specific findings.

Earlier setup and preliminary command receipts are retained separately at this write timestamp. No task or acceptance criterion was checked off.
