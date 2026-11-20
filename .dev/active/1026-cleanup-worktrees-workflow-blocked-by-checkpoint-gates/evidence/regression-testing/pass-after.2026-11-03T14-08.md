# Pass-After Regression Run (Issue #1026)

Timestamp: 2026-11-03T14-08
Command: sh SCRATCH/issue-1026-regression.sh
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: every cleanup call C1-C7 is allowed and every control D1-D3 is denied by the branch hooks, so the script exits 0. The launcher is the file created in P0-T8, unchanged since the fail-before run (fail-before.2026-11-03T12-59.md); the same in-memory setup and seam overrides apply.

Output:

```
D1 reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations re
D2 reason: PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations re
D3 reason: MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author
C1|allow
C2|allow
C3|allow
C4|allow
C5|allow
D1|deny
D2|deny
C6|allow
D3|deny
C7|allow
```

| Call | Description | Fail-before | Pass-after |
|---|---|---|---|
| C1 | manifest Write at the session root with valid content | deny | allow |
| C2 | scratch `.ps1` Write under the temporary root | deny | allow |
| C3 | `git -C <consolidation root> add -- docs/research/y.md .claude/agent-memory/x/y.md` | deny | allow |
| C4 | `git -C <consolidation root> commit -F <file>` with an allowlisted staged index | deny | allow |
| C5 | receipt Write `<consolidation root>/artifacts/pr_body_7.receipt.json` | deny | allow |
| C6 | `Agent(pr-author)` with `branch: documentationandmemories` | deny | allow |
| C7 | `Get-PrAuthorBypassReason` for `gh pr create --head documentationandmemories --base main --body-file <absolute body>` | deny | allow |
| D1 | the C3 command against the feature worktree | deny | deny |
| D2 | a `.ps1` Write inside the feature worktree | deny | deny |
| D3 | `Agent(pr-author)` with `branch: bug/example` | deny | deny |
