# P3-T7 additional repaired diagnostics

Timestamp: 2026-10-19T00-09
Command: expanded scoped type checks and 75-case coverage run
EXIT_CODE: 1
Output Summary: The expanded run passed 73 cases and failed two fixture setup cases in 110.17 seconds. Production coverage was 301/303 lines with both missing statements associated with the unexecuted negative fixtures. No production change was required.

- `test_proposal_preserves_existing_bytes_or_reports_explicit_conflicts[record-conflict]` passed immutable JsonObject descendants to the test helper that accepts plain Python JSON data. It failed with `TypeError: Object of type JsonObject is not JSON serializable` before invoking the intended collision path. The fixture now builds immutable JSON directly.
- `test_effective_profile_limits_and_output_roots_are_rechecked[False]` indexed optional profile member `limits` and failed with `KeyError: limits`. The fixture now uses the schema default empty object before setting its explicit limit.
- Four unused test imports and one possibly-unbound test variable were corrected without suppressions. Formatting was reapplied to changed tests before the final ordered sequence.

The first gate recorder invocation successfully ran Black but its console echo failed on Windows cp1252 output encoding (`UnicodeEncodeError` for the formatter status characters). The actual Black result was 0 and its receipt was already durable. The session-local recorder now explicitly emits UTF-8. Pass 1 is retained as preliminary; the complete ordered sequence restarts as pass 2. No production, schema, or test semantic change was made for the recorder fix.

The shell-based attempt to write this evidence was rejected by the promotion hook as `PROMOTION_MCP_ONLY_BLOCKED`. That attempted command created no issue and invoked no GitHub command. This authorized evidence file was subsequently written with the file-edit tool. No promotion, permission, or hook setting was changed.
