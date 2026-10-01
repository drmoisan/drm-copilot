# Test Isolation (AC-12) (#623)

Timestamp: 2026-09-30T08-56
Command: grep -c -E "tmp_path|tmpdir|tempfile|TemporaryDirectory|NamedTemporaryFile|mkdtemp|mkstemp|os\.tmpdir|mkdtempSync|writeFileSync|node:fs" <six test files>; grep -c -F "monkeypatch.setattr" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"
EXIT_CODE: 0
Output Summary: The first command printed six `path:count` lines, each ending `:0`. The second printed 9 (at least 7). The seven RealFileSystem nodes PASSED in P5-T5 (py-filesystem-tests.2026-09-30T08-43.md). P8-T5 (py-test-coverage.2026-09-30T08-54.md, case (a)) reported no failing node under tests/scripts/dev_tools/test_potential_to_issue.

## First command output (verbatim)

```
tests/scripts/dev_tools/test_potential_to_issue_move_verification.py:0
tests/scripts/dev_tools/test_potential_to_issue_filesystem.py:0
extensions/drm-copilot/test/lib/potential-to-issue/promotion.move-verification.test.ts:0
extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts:0
extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts:0
extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts:0
```

## Second command output

```
9
```

Seven PASSED RealFileSystem nodes (P5-T5): test_resolve_path_expands_user_then_resolves, test_exists_delegates_to_path_exists, test_read_text_reads_utf8, test_write_text_writes_utf8, test_write_lines_joins_lines_with_newlines, test_ensure_dir_creates_parents, test_move_creates_parent_then_moves.

Note: the file now also contains an eighth test, test_file_system_protocol_members_declare_no_behavior, added during the Phase 8 remediation (see py-test-coverage-pass1-failed.2026-09-30T08-46.md). It uses no monkeypatching and no disk IO: it calls the protocol placeholder bodies, which return None, and it PASSED in the P8-T5 full run.
