# evidence-locations-hook-swallows-its-deny (Potential Bug)

- Date captured: 2026-08-20
- Author: Dan Moisan
- Status: Draft
- Severity: High — a registered PreToolUse gate is inert; forbidden evidence paths are not blocked

## Summary

`.claude/hooks/enforce-evidence-locations.ps1` never blocks anything. Its decision function computes
the correct `deny` payload, but the entry-point line

```powershell
exit (Invoke-EvidenceLocationEntryPoint)
```

consumes the function's entire output — both the decision JSON and the trailing exit code — as the
argument to `exit`. Nothing is written to stdout, so Claude Code receives no decision and the write
proceeds. The hook is registered on the `Write|Edit` matcher and appears to be enforcing, but a
forbidden evidence path is allowed through silently.

## Reproduction

Run from the repository root:

```powershell
$env:CLAUDE_TOOL_INPUT = '{"file_path":"artifacts/baselines/example.md","content":"x"}'
& pwsh -NoProfile -File .claude/hooks/enforce-evidence-locations.ps1
"exit code: $LASTEXITCODE"
```

Observed: no stdout at all (0 characters), exit code 0.

Now call the decision function directly, which shows the logic is correct and only the plumbing is
broken:

```powershell
. ./.claude/hooks/enforce-evidence-locations.ps1
Invoke-EvidenceLocationEntryPoint
```

Observed, as two separate pipeline items:

```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EVIDENCE_LOCATION_BLOCKED: 'artifacts/baselines/example.md' is not a canonical evidence location. Use <FEATURE>/evidence/<kind>/ instead. See .claude/skills/evidence-and-timestamp-conventions/SKILL.md for the canonical scheme."}}
0
```

The function emits the JSON, then the code. `exit (...)` receives both, discards the JSON, and exits.

## Scope

This is the only hook using the pattern. Confirmed:

```
Select-String -Path .claude/hooks/*.ps1 -Pattern '^exit \(Invoke-' -List
-> enforce-evidence-locations.ps1
```

Every other hook emits its decision with a write to stdout and then calls `exit 0` separately, which
is the correct form and is what `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`
asserts against.

## Impact

- The canonical evidence-location policy stated in `.claude/skills/orchestrate/SKILL.md` — that
  non-canonical `artifacts/` sub-paths "will be blocked by the `enforce-evidence-locations.ps1`
  PreToolUse hook" — is not enforced. Any agent may write evidence to `artifacts/baselines/`,
  `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/` without obstruction.
- The failure is silent and indistinguishable from a pass at the call site. Empty stdout plus exit 0
  is precisely what an allow looks like, so nothing in the hook's observable behavior reveals that
  its deny path is dead.
- Unit tests that exercise `Invoke-EvidenceLocationEntryPoint` directly pass, because the defect is
  in the entry-point plumbing rather than the decision logic. Test greenness therefore does not
  protect against this.

## How it was found

Observed during issue #491 execution. The same defect class was independently present in the new
`enforce-mermaid-validation.ps1` while it was being written — its entry point initially swallowed its
own stdout the same way — and was corrected there before landing. Checking whether the pattern
existed elsewhere surfaced this instance in a hook already in service.

## Proposed Fix

Separate the emission from the exit, matching every other hook in the directory:

```powershell
$decision = Invoke-EvidenceLocationEntryPoint
Write-Output $decision[0]
exit 0
```

Or have the entry-point function write the JSON itself and return nothing, then `exit 0`
unconditionally. Either way the hook must exit 0 on both allow and deny, per the contract asserted by
`PreToolUseSchema.Contract.Tests.ps1`.

## Test Conditions to Consider

- [ ] A forbidden path (`artifacts/baselines/x.md`) produces a `permissionDecision: deny` JSON on
      stdout at exit 0.
- [ ] A canonical path (`<FEATURE>/evidence/baseline/x.md`) produces an allow and does not block.
- [ ] The existing contract suite is extended to invoke the hook as a subprocess and assert on its
      stdout, not only to call the decision function in-process. A test that only calls the function
      cannot catch this defect class, which is the reason it survived.
- [ ] Negative control: the deny case is observed failing before the fix and passing after, so the
      repair is demonstrated rather than assumed.
- [ ] A repository-wide check that no hook uses the `exit (Invoke-...)` form, to prevent reintroduction.

## Next Step

- [ ] Promote to GitHub issue (bug template)
- [ ] Audit whether any evidence has already been written to forbidden `artifacts/` sub-paths while
      this gate was inert, since the policy has not actually been enforced for as long as the defect
      has existed.
