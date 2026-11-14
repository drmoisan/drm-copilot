# Fail-Before Evidence (issue #1141, [P1-T3])

Timestamp: 2026-11-08T19-39
Command: sh SCRATCH/issue-1141-pester.sh failbefore (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; $result = Invoke-PoshQCParallelTest -Root <worktree root>; exit $result.ExitCode), run with the two new test files committed and no production change; failures read from the shard JUnit files under artifacts/pester/parallel/shard-<i>/pester-junit.xml
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Invoke-PoshQCParallelTest returned ExitCode 1 (shards 2 and 3 non-zero; no merged artifact written); workers=8; wall-clock=715.12s.
- Shard totals: tests=20324, failed=18, disabled=10. All 18 failures are rows of the two new files; no other test failed (the [P0-T3] baseline had zero failures).
- Claude file (11 failures, every `fail-before` and `allows` row):
  - fail-before: "allows git commit -F with a pathspec under a merged feature folder" -> deny, failed readiness predicate 'merge-in-progress'.
  - fail-before: "allows a pathless git commit -m when the staged index is under a merged feature folder" -> deny, 'merge-in-progress'.
  - allows: Write of a json under the completed root of child-a -> 'merge-in-progress'.
  - allows: Edit of a json under the completed root of child-a -> 'merge-in-progress'.
  - allows: absolute Write into the integration root under the completed root of child-c -> target-not-ready wording naming 'merge-in-progress'.
  - allows: git add of a child-a and a child-c completed path -> 'merge-in-progress'.
  - allows: git add -- of a child-c completed path -> 'merge-in-progress'.
  - allows: git -C the integration root commit --message with a child-a completed pathspec -> target-not-ready wording naming 'merge-in-progress'.
  - allows: git commit --file --trailer with a child-c completed pathspec -> 'merge-in-progress'.
  - allows: "allows git commit -F with the epic status document as pathspec" -> 'merge-in-progress'.
  - allows: pathless git commit -m whose index holds a child-a active and a child-c completed path -> 'merge-in-progress'.
- Codex file (7 failures, every `fail-before` and `allows` row):
  - fail-before: "allows git commit -F with a pathspec under a merged feature folder" -> 'merge-in-progress'.
  - fail-before: "allows a pathless git commit -m when the staged index is under a merged feature folder" -> 'merge-in-progress'.
  - allows: file_path Write of a json under the completed root of child-a -> 'merge-in-progress'.
  - allows: apply_patch adding a json under the completed root of child-c -> 'merge-in-progress'.
  - allows: git add of a child-a completed path -> 'merge-in-progress'.
  - allows: git commit --file with a child-c completed pathspec -> 'merge-in-progress'.
  - allows: git commit --file with the epic status document as pathspec -> 'merge-in-progress'.
- Passing as required: the interception probes, both `already admitted` rows (#539 exemption), every `denies with unchanged text` and `denies` row (including the `..`, backslash, and glob operands, the epic_manifest_path row, and the hand-authored lifecycle_ready row), and both outside-epic-scope rows.
