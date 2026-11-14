# Code Review: Preimplementation Gate Blocks Post-Fan-In Integration Writes (Issue #1136)

- **Branch:** `bug/preimpl-gate-post-fanin-writes` @ `caa0879c1fa046b154e6c75af6bd2b46ff7160ff`
- **Base:** `main`, merge base `a90d522c6ac239bca858d7bc800d52860e823219` (equal to `origin/main` after fetch); HEAD already merges current `origin/main`
- **Scope:** full branch diff, 43 files
- **Reviewer:** feature-review agent, 2026-11-08

## Executive Summary

- The change is narrow and fails closed. The allowance is evaluated only inside epic scope, only after `Get-EpicCommandLegReadinessFailure` returns exactly `'merge-in-progress'` (its last conjunct, so every earlier readiness conjunct already holds), only when `Test-EpicFanInComplete` binds the checkpoint's `integration_branch` case-sensitively to the worktree HEAD with every feature `merged` or `worktree_removed`, and only for allowlisted paths or modelled `git add` / `git commit` shapes. Every other outcome returns the original failure, so all deny texts are unchanged.
- `Get-EpicFanInAllowance` wraps its body in `try`/`catch` and answers not allowed on any error; the dot-source in both gates is guarded with `Add-HookDependencyFailure`.
- Command text is first screened by the existing `Test-OrchestrationCommandTextUnresolvable` (which rejects `$`, backtick, `<`, `>`, `#`, braces, parentheses, `@`, and any backslash outside safe quoting) and split by `Split-OrchestrationCommandLine` on `;`, `&`, `|`, and newlines, so every chained segment must itself be a modelled add or commit.
- The four `hook-epic-fan-in.ps1` copies share one SHA-256; each epic-scope gate equals its bundle copy; the six brief copies share one SHA-256; the frozen-surface pin equals the skill digest at HEAD.
- The merge `caa0879c1` of `origin/main` arrived after the final gate runs. It touched 13 branch files (skills, both `core.json` manifests, the pin file) and no file in the changed hooks' dependency chain. The reviewer re-ran the six covering Python contract modules at HEAD (83 passed).

No blocking finding. Verdict: PASS.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/hook-epic-fan-in.ps1` (and three byte-identical copies) | Line 70 (`Get-EpicFanInPropertyText` null object) and line 266 (`Test-EpicFanInStagedIndex` null result) | CR1. Two return commands never execute in the final gate run. Line coverage is 100% (91 of 91) because each line is partly executed, but no row drives a staged-index reader that returns `$null`. | Optional: add one unit row in `hook-epic-fan-in.Tests.ps1` with a reader returning `$null`, asserting `Allowed` is false. | The behavior is correct by reading (both return the fail-closed value); the gap is in test pinning, not in production logic. | JaCoCo `mi` greater than 0 on lines 70 and 266 in `artifacts/pester/powershell-coverage.xml` |
| Nit | `docs/features/active/2026-11-08-preimpl-gate-blocks-post-fanin-integration-writes-1136/issue.md` | `- Status:` line | CR2. The status line names `docs/features/active/preimpl-gate-blocks-post-fanin-integration-writes/`; the active folder carries the `2026-11-08-` prefix and `-1136` suffix. | Optional: correct the path when the folder is next edited. | Documentation accuracy only. | `issue.md` line 5 |
| Info | `.claude/hooks/hook-epic-fan-in.ps1` | `Test-EpicFanInCommitShape` signature | CR3. The spec signature is `-Token <string[]>`; the implementation also takes `-StatusDocPath`, because the add and pathspec shapes depend on the checkpoint's status document. Return values match the spec. | None required. | Disclosed in `self-review.2026-11-08T17-49.md`; the AC lists function names, not signatures. | `hook-epic-fan-in.ps1` lines 222 to 246 |
| Info | `.claude/hooks/hook-epic-fan-in.ps1` | `Get-EpicFanInShapeDetail` | CR4. `git commit -m --amend` is admitted, because `--amend` is consumed as the value of `-m`. Git's option parser also takes it as the message text, so no amend occurs. | None required. | The shape model matches how git consumes a required option value. | Reviewer probe, section Adversarial Probe |
| Info | Feature evidence | `pester-final.2026-11-08T17-42.md`, `pytest-final.2026-11-08T17-47.md` | CR5. The final gate runs are at `c36255592`, before the main merge `caa0879c1`. The merge changes no PowerShell file in the gate's dependency chain; the merged skill, manifest, and pin files are covered by the reviewer's post-merge Python contract run. CI on the PR head will confirm the full suite at HEAD. | None required for this item; S9 owns the CI result. | Pending-CI, not a finding. | `git diff --name-only c36255592 caa0879c1`; reviewer pytest run, 83 passed |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at 506 logical lines; the largest production file is the Codex epic-scope gate at 456. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Production logic

- `Test-EpicFanInComplete` restates the terminal-status set and the route id; a unit row pins the set equal to `$script:TerminalMergeStatuses` in `EpicScopeReadiness.psm1`, and a matrix row shows agreement with `Get-EpicPrCreationReadinessFailure`.
- `Get-EpicFanInStatusDocRelativePath` admits only a single plain slug segment (`^[A-Za-z0-9][A-Za-z0-9._-]*$`), which excludes `..`, separators, and a leading dot, and refuses a disagreeing `epic_status_doc_path`.
- Path legs: relative and absolute paths are normalised to forward slashes; absolute paths are made relative through `Get-HookTargetWorktreeRelativePath` against the scope root and refused outside it; the allowlist match is anchored and case-sensitive, so `..` segments, upper-case variants, and suffix tricks fail.
- Command legs: `git -C` must be followed by an absolute path; only `add [--] <status doc>` and `commit` with `-m`, `--message`, `-F`, `--file`, `--trailer` (each with a value) and an optional `-- <status doc>` are modelled. The `--opt=value` forms, `-c`, `-a`, `--amend`, extra pathspecs, and `./`-prefixed pathspecs are refused.
- A pathless commit reads the scope root's index through the injected reader and needs exactly one NUL-terminated name equal to the status document.
- Composition in both gates: the scriptblock passed to `Resolve-OrchestrationEpicTargetOutcome` keeps the original failure value on every non-allowed path. The Codex gate passes `$legPaths` and `$legCommand`, so an `apply_patch` leg is judged on every marker path.

### Adversarial Probe

The reviewer dot-sourced the helpers file, `HookTargetWorktree.psm1`, and `hook-epic-fan-in.ps1` in a fresh `pwsh 7` process and called `Get-EpicFanInAllowance` with a fan-in-complete scope and a reader returning exactly the status document. Refused as expected: a commit pathspec with an extra production path; `git add` of the status document plus a production path; `> file` and `-m >file` redirections (unresolvable); `&& rm -rf scripts` (unmodelled segment); `git -c ...`; `git -C rel`; `--file=`; `$(...)` outside quotes; `./`-prefixed pathspec; absolute paths that climb with `..` or lie in a sibling root; `ARTIFACTS/` upper case; a status-doc path through `../t/`. Admitted as expected: the absolute body path inside the root; the status document; `-- <status doc>` commit; `git add -- <status doc>`; `--trailer` with a quoted value; `-m 'a$(b)'` in single quotes (literal); a newline-chained commit and add with the exact index.

### Tests

- The fail-before rows were captured before any production change and failed with the `'merge-in-progress'` deny (`fail-before.2026-11-08T17-19.md`).
- Deny rows assert `-BeExactly` the text produced by the production `Resolve-OrchestrationEpicTargetOutcome`, so they detect both a fall-through to allow and any wording change.
- The `epic_manifest_path` row shows the allowance does not apply to any other failure even when fan-in is complete.
- The "another slug's `epic-status.md`" case is exercised through the staged index at gate level and through the unit allowlist rows; a gate-level Write row would not discriminate, because the gate does not classify `.md` Writes.

### Documentation and mirrors

The skill paragraphs and brief bullet state the allowlist, the exact-failure condition, the two documented limits (backslash `-F` values, chained add with a pathless commit), and that the allowance is a policy-level control. Both `core.json` manifests list the new file, and `legacy-codex-hook-contracts.Tests.ps1` adds it to the Codex shared-module list so it is excluded from process-level invocation loops.

## Recommendation

Proceed to PR authoring. CR1 and CR2 may be addressed opportunistically; neither blocks the merge.
