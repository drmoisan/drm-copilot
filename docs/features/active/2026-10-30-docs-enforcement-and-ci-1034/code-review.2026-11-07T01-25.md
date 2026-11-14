# Code Review: docs-enforcement-and-ci (#1034)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
**Feature Folder Selection Rule:** supplied by the caller; matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `e3e4aa551`)
**Head Branch:** `feature/docs-enforcement-and-ci-1034-r2` at `48892dc05`
**Review Type:** Initial review

---

## Executive Summary

The branch adds an opt-in merge gate hook with pure predicates, a `surface-delta` subcommand with two read-only revision members on the command context, a consumer workflow template, and a documentation surface check in the `feature-review` surfaces. The code is well separated, the formatter and analyzer are clean, coverage is high, and the push-down mirrors are byte-identical.

The `surface-delta` path works with real processes. A scratch consumer repository reported an unledgered added command with exit 1, exit 0 once the ledger recorded it, and the same results from another directory with `-RepositoryRoot`. Non-ASCII ledger text survived `git show`.

The merge gate has two fail-open defects. Both were found by running the decision function or the shipped hook, because every existing test uses a numeric selector and a file seam that returns normally.

**What changed:** 4 new PowerShell production files, 2 edited, 1 YAML template, settings registration, manifest rows, 4 review surfaces, and their bundle copies, with 5 new test suites.

**Top 3 risks:**
1. The gate can allow an integration merge with no receipt when the lookup resolves a different pull request (F1).
2. An unreadable profile disables an enabled gate without a deny (F2).
3. Passing tests give limited assurance for these paths: the suites never run the hook as a process and never vary the selector form.

**PR readiness recommendation:** **Needs Revision** - the gate does not reliably perform the denial that is its purpose in the two cases below.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-docs-complete-gate.ps1` | `Get-DocsCompleteGatePullRequest`, lines 162-167 | F1: the lookup does not bind to the pull request the command merges. A null selector number falls through to a bare `gh pr view`, which resolves the current branch. Only the first merge in a command is read. `--repo` is not forwarded. | Forward the selector token and any `--repo` value to `gh pr view`. Deny `PR_UNRESOLVED` when an in-scope command names a target the hook cannot resolve (GraphQL node identifier, Indeterminate match). Evaluate every merge invocation in the command, or deny more than one. | With the gate enabled and no receipt, an integration merge is allowed. `Get-EpicMergeGateSelectorPrNumber` documents that a null result needs fail-closed handling by its caller. | Probe table below. |
| Blocker | `.claude/hooks/enforce-docs-complete-gate.ps1` | `Get-DocsCompleteGateFileText`, line 136; decision lines 222-225 | F2: a read failure on an existing profile yields `allow`. The exception does not stop the function, `$profileText` stays `$null`, and `$null` means "no profile", so the gate is disabled. | Catch read failures in the seam and return a distinct outcome. Deny `PROFILE_UNREADABLE` for the profile. For the receipt, deny with a reason that does not say the file is absent. | `.claude/rules/general-code-change.md` requires failing fast and not ignoring errors. The hook header states that anomalies fail closed. | Real hook process with the profile exclusively locked and the gate enabled printed `MethodInvocationException` at line 136 and then `permissionDecision: allow`, exit 0. |
| Minor | `tests/scripts/claude-lib/docs/Invoke-DocsCommand.RevisionContext.Tests.ps1` | line 114 | N1: the BOM assertion cannot fail. `Should -BeExactly` compares with `-ceq`, for which U+FEFF is ignorable. | Assert ordinally, for example `$result[0]` or `[string]::Equals(..., Ordinal)`. | The specified BOM removal has no effective test. | M10 (BOM line deleted) passed 23 of 23. `($bom + "{}") -ceq "{}"` returns `True`. |
| Minor | `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1` | removed-element cases | N2: no test covers a removed element that has no ledger entry at base or head. | Add a case asserting no `DOCS_SURFACE_REMOVED_ENTRY_RETAINED`. | A false warning would not be detected. | M5 passed 17 of 17. |
| Minor | `.claude/agents/feature-review.md` and three mirrors | `## Documentation Surface Check`, steps 4-5 | N3: an artifact recording `EXIT_CODE: 2` or `3` receives no verdict. Step 4 covers absent and 1; step 5 covers 0. | Treat any non-zero exit code as the blocking case, and update `spec.md` to match. | A usage or runtime failure of `surface-delta` proves nothing about the ledger. | Text inspection; both exit codes are defined in `spec.md`. |
| Minor | `.claude/lib/docs/templates/_docs-quality.yml` | lines 11, 18, 64 | N4: `base-ref` is described as "revision or branch", but a bare `main` does not resolve in the detached checkout, and the receipt upload path is fixed to the starter default. | State that a remote-tracking form such as `origin/main` is required. Note that a changed `validation_receipt` path needs a matching upload path. | A consumer following the description gets `DOCS_SURFACE_BASE_UNRESOLVED`. | Detached clone: `git rev-parse --verify --end-of-options 'main^{commit}'` is fatal; `origin/main^{commit}` resolves. |
| Minor | `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/spec.md` | Design, Owner Questions, Acceptance Criteria | N5: spec text trails adopted decisions: `900008` anchors (merged as `1034`), OQ-1 still provisional, `evidence/coverage/`, the "no changed or removed line" wording, and the `Join-Path` template row. Later children read this file. | Reconcile the spec and user story with the plan `## Notes`. | `## Decisions Later Children Must Honor` is a contract. | Plan lines 301-305; `DocsProfileCommands.psm1` row. |
| Info | `.claude/hooks/enforce-docs-complete-gate.ps1` | line 177 | N6: `-cnotmatch` on `headRefOid` has no test for an uppercase value. | Optional row. | `gh` returns lowercase, so the effect is small. | M9 passed 41 of 41. |
| Info | `.claude/settings.json` | Bash `PreToolUse` group | N7: the hook adds one PowerShell start per Bash call in every consumer, including disabled ones. | No change requested; track if hook latency becomes a concern. | The opt-in default still pays this cost. | Real runs: 487 to 573 ms for allow decisions on this host. |

No file reaches the 700-line advisory tier. No suppression was added beyond two justified attributes on in-memory factories and one on an ordinal hashtable.

### F1 probe results

The real `Invoke-DocsCompleteGateDecision` ran with an enabled profile, no receipt, and a `gh` stand-in following `gh` semantics: number 12 is the integration pull request, and no selector returns the current branch's pull request (`feature/current-branch` into `development`).

| Command | Lookup issued | Decision | Expected |
|---|---|---|---|
| `gh pr merge 12 --merge` | `pr view 12` | deny `RECEIPT_ABSENT` | deny |
| `gh pr merge https://github.com/o/r/pull/12 --merge` | `pr view 12` | deny `RECEIPT_ABSENT` | deny |
| `gh pr merge epic/x-integration --merge` | `pr view` | **allow** | deny |
| `gh api graphql` with `mergePullRequest(input:{pullRequestId:"PR_kwabc"})` | `pr view` | **allow** | deny |
| `gh pr merge 99 --merge; gh pr merge 12 --merge` | `pr view 99` | **allow** | deny |
| `gh pr merge 12 -R other/repo --merge` | `pr view 12` | deny, from the local repository's pull request 12 | lookup in `other/repo` |

Conditions: the first two allow results need a checkout whose branch has a different open pull request. On the integration branch itself the bare lookup finds the right pull request, and on a branch with no pull request the result is `PR_UNRESOLVED`. The header's residual limits list a mutation supplied from a file and an ambient `GH_REPO`, but none of the cases above.

The epic merge gate does not close this gap. From reading `Test-EpicCheckpointAllowsMerge`, a null number passes when the epic checkpoint records a green `ci_gate`, which is the state at integration merge time. This was read, not executed.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Pure predicates with string inputs, in the required import closure; the contract suites confirm it.
- Decision order matches the spec, and the head revision comes from `headRefOid`, never local `HEAD`.
- `-Base` validation runs before any read. `--end-of-options` and full-revision checks guard the revision calls. `--upload-pack=x` exits 2 in a real run.
- Field names read by the gate and `surface-delta` match the committed schemas, and real `validate -WriteReceipt` output carries them. A real failing receipt produced `RECEIPT_FAILING`.

#### API and safety notes

- Added context members are additive; the whitespace-insensitive diff of the two edited files removes 0 lines.
- `git show` treats every non-zero exit as absent. This matches the spec, and `ResolveRevision` runs first, so a repository-level failure surfaces as `DOCS_SURFACE_BASE_UNRESOLVED`.

#### Error handling and logging

See F2. The hook does not set `$ErrorActionPreference`, unlike the modules it imports.

---

## Test Quality Audit

### Reviewed test and QA artifacts

The five new suites, the five edited test files, `evidence/qa-gates/*.2026-11-07T00-07.md`, `self-review.2026-11-07T01-03.md` and `pester-isolation.2026-11-07T01-02.md`.

### Quality assessment prompts

Mutants were applied to a scratch copy, one at a time. The worktree was not modified.

| Mutant | Result |
|---|---|
| M1 revision compare ignores case | killed |
| M2 any base accepted | killed |
| M3 truthy enabled value | killed |
| M4 pin change ignored | killed |
| M5 no retained-entry check | survived (N2) |
| M6 `..` accepted | inconclusive, control failed in the scratch copy |
| M7 stale digest check removed | inconclusive, control failed in the scratch copy |
| M8 `--match-head-commit` check removed | killed |
| M9 case-insensitive head pattern | survived (N6) |
| M10 BOM removal deleted | survived (N1) |
| M11 `--end-of-options` dropped | killed |
| M12 integration-target check removed | killed |

---

## Security / Correctness Checks

- Command injection: `-Base` is restricted before use, and processes start without a shell.
- Workflow injection: values reach `run:` through `env:`; `permissions` is `contents: read`; actionlint exit 0.
- Authorization: F1 and F2 are the correctness failures of this control.

---

## Research Log

- `.claude/hooks/enforce-epic-merge-gate-command.ps1` and `enforce-epic-merge-gate.ps1`, for selector semantics.
- `.claude/lib/docs/schemas/v1/`, for receipt, ledger, pin and snapshot fields.
- A scratch consumer repository built from `.claude/lib` and `.claude/hooks`, for `init`, `inventory`, `update-ledger`, `check`, `validate`, `surface-delta` and the hook. A passing receipt was not produced, because the sample estate had no pins or parity matrix.

---

## Verdict

**Needs Revision.** Two Blockers (F1, F2), five Minor and two Info findings. No Major findings.
