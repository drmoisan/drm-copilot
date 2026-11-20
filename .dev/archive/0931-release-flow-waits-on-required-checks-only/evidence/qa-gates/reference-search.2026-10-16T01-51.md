# Repository Reference Search for AC5 (Issue #931)

Timestamp: 2026-10-16T01-51
Command: git grep -n -F -e "A required check failed" -- . ':(exclude)docs/features'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PASS. The superseded stderr message appears nowhere outside docs/features (no output, exit 1). The FullReleaseFlow references are exactly the expected eight paths. The only required-only description is a dated historical audit record, which is recorded with its disposition and not edited. `.vscode/tasks.json` says "waits for gh checks", which does not say required-only.

## Search 1

Command: `git grep -n -F -e "A required check failed" -- . ':(exclude)docs/features'`
Output: (none)
Exit: 1

## Search 2

Command: `git grep -l -F -e "FullReleaseFlow" -- . ':(exclude)docs/features'`
Exit: 0
Output:

```
.vscode/tasks.json
docs/research/2026-07-09-active-features-delivery-status-audit.md
scripts/dev-tools/Invoke-FullReleaseFlow.ps1
tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1
tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
```

These are the script, the four release-flow Pester files, `.vscode/tasks.json`, the dated research audit, and the contract test. No other path appears.

## docs/research/2026-07-09-active-features-delivery-status-audit.md

Command: `git grep -n -F -e "required checks to register and complete" -- docs/research/2026-07-09-active-features-delivery-status-audit.md`
Exit: 0
Matching line (line 31, quoted excerpt): `` `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` contains a documented "Waits for a pull request's required checks to register and complete" routine with a timeout message, matching the fix. ``

Disposition: historical dated delivery-status snapshot (2026-07-09) of the code as delivered by #298 to #325; not edited, because rewriting a dated audit record is outside this item.

## .vscode/tasks.json

Command: `git grep -n -F -e "waits for gh checks" -- .vscode/tasks.json`
Matching line 298 (excerpt): `"Automates the guarded full release flow: verifies clean up-to-date main, opens the release PR, waits for gh checks, merges through gh, updates main, and invokes the post-merge release tag-push script."`

The description ('waits for gh checks') does not say required-only; no edit is needed.
