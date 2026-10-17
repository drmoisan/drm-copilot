# Cycle 2 Final QC: Scope and AC-State Check (Issue #931)

Timestamp: 2026-10-16T05-43
Command: git diff --no-renames --name-status 7051d8a8d -- . ':(exclude)docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931'; git status --porcelain; git diff --name-only 7051d8a8d -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md; git grep -c -F -e "- [x] AC" -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md; git grep -c -F -e "- [ ] AC" -- docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md
EXIT_CODE: 0
Output Summary: Scope equals the six `## Writes` paths (CheckClassification reported as D). issue.md unchanged and absent from porcelain. Checked AC count 6; unchecked AC count command printed nothing and exited 1 (expected).

## 1. Scope diff (exit 0)

```text
A	scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1
M	scripts/dev-tools/Invoke-FullReleaseFlow.ps1
D	tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1
A	tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
M	tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
M	tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
```

## 2. git status --porcelain (exit 0)

Entries outside the feature folder: `?? SCRATCH/` only (excluded). All other entries are inside the feature folder (the plan file and cycle 2 evidence files); none is `issue.md`.

Union outside the feature folder, excluding `SCRATCH/`: exactly the six `## Writes` paths above.

## 3. issue.md diff against 7051d8a8d (exit 0)

Output: (empty)

## 4. Checked AC count (exit 0)

```text
docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md:6
```

## 5. Unchecked AC count (exit 1)

Output: (empty). Exit 1 is the expected result: no unchecked AC line exists.
