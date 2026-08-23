# preimplementation-gate-rejects-absolute-checkpoint-path (Issue #516)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/preimplementation-gate-rejects-absolute-checkpoint-path/ (Issue #516)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #516
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/516
- Last Updated: 2026-08-23
## Summary

`enforce-orchestration-preimplementation-gate.ps1` exempts the orchestrator checkpoint from the gate by comparing the tool's `file_path` for exact equality against the repo-relative literal `artifacts/orchestration/orchestrator-state.json`. It normalizes backslashes to forward slashes but never strips the workspace root, so an absolute path to that same file fails the exemption, matches the `\.json$` implementation pattern, and is blocked. The orchestrator cannot create its own checkpoint through the `Write` tool, which supplies absolute paths by contract.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a — hooks are PowerShell; PowerShell 7.6.5
- Command/flags used: `Write` tool with `file_path` set to an absolute Windows path ending `artifacts\orchestration\orchestrator-state.json`
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` at commit `bee15c06`; observed live during an orchestration run on 2026-08-23

## Steps to Reproduce

1. Start from a worktree with no `artifacts/orchestration/orchestrator-state.json`, which is the state at the beginning of any new orchestration.
2. Attempt to create that checkpoint using the `Write` tool, passing the absolute path — for example `C:\Users\<user>\repos\<repo>\artifacts\orchestration\orchestrator-state.json`. The `Write` tool requires an absolute path, so this is not an avoidable choice.
3. Observe the hook decision.
4. As a control, invoke the hook's decision function directly with `file_path` set to the repo-relative `artifacts/orchestration/orchestrator-state.json` and observe that it is allowed.

## Expected Behavior

The checkpoint path is explicitly exempted from the gate; the exemption exists precisely so the orchestrator can write its own state before implementation begins. The exemption should hold for any path that resolves to that file, whether expressed relative to the workspace root or absolutely. Otherwise the gate blocks the one write that is a precondition for satisfying it.

## Actual Behavior

Step 2 is denied:

```text
PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require
artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder,
route metadata, lifecycle readiness, and checkpoint state before implementation begins.
```

Step 4 is allowed. The decision logic is sound; the path comparison is what fails.

The relevant code is a two-line sequence in `Invoke-OrchestrationPreimplementationGateDecision`:

```powershell
$normalized = ([string]$filePath) -replace '\\', '/'
$requiresReadyCheckpoint = Test-ImplementationPath -NormalizedPath $normalized
```

`Test-ImplementationPath` then exempts the path only on exact equality with the repo-relative literal:

```powershell
if ($NormalizedPath -eq $script:CheckpointPath) {
    return $false
}
return $NormalizedPath -match '\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$'
```

An absolute path survives both checks and is classified as an implementation write. The gate then reads a checkpoint that does not exist yet, cannot find the required fields, and blocks — a circular precondition: the checkpoint is required to exist before it may be created.

The same normalization gap affects the `docs/features/active/` exemption in `Test-FeatureDocumentationOrEvidencePath`, which uses `StartsWith`. An absolute path to a feature document does not start with that prefix either, so feature-documentation writes carrying absolute paths are also misclassified. That path is only reachable for the file extensions in the pattern above — a `.json` or `.yml` artifact inside a feature folder — since `.md` is not matched.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet is inlined under **Actual Behavior** above.
- Workaround used at the time: write the checkpoint through the shell with a workspace-relative path instead of the `Write` tool. That is a workaround, not a fix, and it is only discoverable by reading the hook source.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. It fails closed, so it is not a safety hole — but it blocks the documented orchestration path at its first step, and the obstruction is silent about its real cause: the message describes missing checkpoint fields, which sends the reader looking for a content problem rather than a path-comparison problem. An agent that trusts the message will try to populate fields in a file it is not permitted to create.

Not a Blocker because a workaround exists once the cause is known.

## Suspected Cause / Notes

- The hook was almost certainly written and tested against repo-relative payloads. Its tests likely construct `file_path` relative, which is why the gap is invisible to the suite — the same test-shape blind spot recorded in the resolved issue #501, where every hook test constructed a flat payload the harness never sends.
- The fix is path normalization relative to the workspace root before classification, applied once and shared. Candidate home: the existing `.claude/lib/hook-payload/` module, which already centralizes envelope parsing for exactly this reason.
- A tolerant comparison is preferable to a second literal: resolve the incoming path against the workspace root and compare the resulting repo-relative form, so both spellings work and future exemptions need only the relative literal.
- Check every other hook that classifies a `file_path` for the same pattern. `enforce-evidence-locations.ps1` and `enforce-feature-folder-order.ps1` both make path-prefix decisions and are the most likely to share it.
- Related: the checkpoint exemption also requires `lifecycle_ready` to be truthy, which is undocumented in the skill. That is a separate observation and not part of this defect.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — for each exemption in the hook, a paired test asserting the same decision for the repo-relative and the absolute spelling of the same path, on both separator styles. Keep the existing relative cases and add absolute twins; replacing them would relocate the blind spot rather than close it.
- [x] Integration scenario to retest — end-to-end: with no checkpoint present, a `Write` of the checkpoint via its absolute path must be allowed, and a `Write` of a production source file via its absolute path must still be blocked. Both halves are required; a fix that allowed everything absolute would be worse than the defect.
- [x] Manual verification notes — confirm the gate still blocks genuine implementation writes after the change, and confirm the block message is reached only for real checkpoint-content failures. Consider distinguishing the two failure reasons in the message text so the next reader is not misdirected.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
