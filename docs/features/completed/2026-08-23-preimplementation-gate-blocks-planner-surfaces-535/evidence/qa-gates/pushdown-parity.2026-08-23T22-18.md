# Push-Down Parity Verification — issue #535

Timestamp: 2026-08-23T22-18

Command:
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`

These suites gate the two bundle mirrors edited in P2-T2 and P3-T2. The Claude suite asserts
content equality for every repo `.claude/**` file against its bundled counterpart.

EXIT_CODE: 0

Output Summary: `12 passed in 0.18s`, 0 failures. Both bundle mirrors satisfy the push-down
contracts, confirming the byte-identity recorded in
`evidence/other/claude-pair-hash.2026-08-23T21-48.md` and
`evidence/other/codex-pair-hash.2026-08-23T21-58.md` from the contract test's own
perspective.

## First Attempt and Its Cause (recorded for audit)

The first invocation exited 1 with `11 passed, 1 failed`:

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.default.json
```

The failing path is not part of this feature's diff. It is transient per-session hook state
written by `.claude/hooks/enforce-powershell-batch-budget.ps1`, recreated during the batch-2
production writes after the P2-T9 reset. Two facts establish it is outside the diff:

- `git check-ignore -v .claude/state/powershell-batch-budget.default.json` resolves to
  `.gitignore:68:.claude/state/`, and `git ls-files .claude/state/` returns zero entries, so
  the path is gitignored and untracked.
- The file did not exist at baseline; it was first created at 21:34 during this session's
  first PowerShell write. The contract test walks the filesystem rather than the git index,
  so any transient file under `.claude/` makes it fail regardless of the code change.

Remediation applied: the transient state file was removed with the same mechanism P2-T9
used (`Remove-Item -Force -ErrorAction SilentlyContinue`), restoring the baseline filesystem
condition. `ls -A .claude/state/` then reported zero entries and the re-run passed 12/12.

No PowerShell source file changed as part of this remediation, and `.codex` byte-identity was
never at issue (the failure named a `.claude/state/` path, not a hook copy), so the plan's
"restore byte-identity and restart the PowerShell loop from P4-T1" branch did not apply and
no loop restart was performed.
