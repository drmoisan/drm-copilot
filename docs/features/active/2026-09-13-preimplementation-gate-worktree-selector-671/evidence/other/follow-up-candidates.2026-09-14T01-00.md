# Follow-Up Candidates (issue #671)

Timestamp: 2026-09-17T08-32
Task: [P7-T3]

Neither of the two planned candidates below is implemented by this change. Both are outside F2 scope.

## Planned candidates

1. **Upstream closure of the nested-subdirectory escape.** A `-C` selector naming a nested subdirectory of a worktree passes LACS lexically while relocating what a relative operand denotes. Once the epic's F1 target-worktree resolution module exists, it can compose upstream of LACS and reject a selector that is not a worktree root, with no change to the LACS schema or to the helpers module's purity contract. Not implemented by this change.
2. **Add `enforce-orchestration-preimplementation-gate-modes.ps1` to `$script:SharedModuleNames`** at `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30. Today that file is outside the Codex parse check, 500-line check, byte-identity check, and pack-manifest assertion. Not implemented by this change.

## Additional findings recorded during execution (not implemented; for triage)

3. **Pre-existing empty-token fail-open in the #539 exemption.** `Test-ExemptOrchestrationSegmentToken` declares `[string[]] $Token` without `[AllowEmptyString()]` (helpers line 221). A segment containing an empty quoted token fails parameter binding. Under the default `Continue` preference, the failed `if` at line 344 is skipped and `Test-ExemptOrchestrationStagingCommand` returns `True`. Gate-level probes with a not-ready checkpoint returned `allow` for `git commit -m "" -- src/foo.ts` and for `git add -- src/foo.ts ""`. Evidence: `evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md`. This blocks spec row L8 and is also a fail-open independent of the selector axis.
4. **Spec rows L3a and L3b do not match the gate trigger.** Their commands carry no `add`/`commit`, so gate-level deny assertions for them cannot pass. A trigger-matching fixture would isolate the same condition, for example `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md` for L3a and `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md` for L3b; the replacement fixtures must be verified before adoption.
5. **Unchanged helpers line 319 lost coverage.** After the absorption, it is reached only when a `-C` selector is followed by a non-`add`/`commit` subcommand inside a trigger-matching line, and no suite carries such a row.
6. **`git -Cfoo status` is refused by `PARALLEL_WORKTREE_REMOVAL_BLOCKED`.** That guard appears to misclassify a `-C`-prefixed git command as a worktree removal ([P0-T5] evidence).
