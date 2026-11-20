# Python Partial Branches — potential_to_issue.py (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

Command: poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term-missing (from repo root)

EXIT_CODE: 0

Output Summary:
Baseline per-module row: scripts/dev_tools/potential_to_issue.py — Stmts 200, Miss 18, Branch 66, BrPart 21, Cover 85% (line 45/66 = 68.18% branch).

Missing/partial locations reported for potential_to_issue.py:
- Protocol stub bodies (`...`), hard to cover without invoking the abstract members: 81->exit, 83->exit, 85->exit, 87->exit (GhClient), 216->exit, 218->exit, 220->exit, 222->exit, 224->exit, 226->exit, 228->exit (FileSystem).
- RealGhClient: 117->119 (explicit gh_path skips PATH lookup), 128 (is_authenticated unresolved-path guard), 140 (_run unresolved-path guard).
- RealFileSystem methods 255, 258, 261, 264, 267-268, 271, 274-275 (only exercised with real disk IO; out of scope under no-real-filesystem constraint).
- promote_potential: 398 (invalid work_mode raise), 415 (empty content raise), 425-426 (relpath ValueError fallback), 432-433 (invalid mode/type combo re-raise), 459->463 (existing Evidence Checklist skips default), 500 (dead `if fallback_reason:` emit — fallback_reason is always ""; uncoverable without a production change), 512->515 (failed ensure_label skips create retry), 530->535 (no issue_number skips view), 535->548 (no issue_number/url skips metadata).

Targeted branches for the new test file (coverable with in-memory fakes, no production change): 117->119, 128, 140, 397->398, 414->415, 423->425/425->426, 430->432/432-433, 459->463, 512->515, 530->535, 535->548.

Not targeted (documented rationale): the Protocol `...` stub arcs and the RealFileSystem disk-IO lines require either invoking abstract members or real filesystem access; line 500 is dead code guarded by an always-empty `fallback_reason` and cannot be reached without a production-code change, which R2 prohibits.
