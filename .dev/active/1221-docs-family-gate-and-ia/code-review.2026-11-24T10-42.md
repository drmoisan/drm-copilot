# Code Review: docs-family-gate-and-ia (#1221)

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1221-docs-family-gate-and-ia`
**Feature Folder Selection Rule:** Named by the delegation; no version subfolder exists.
**Base Branch:** `origin/epic/documentation-estate-families-integration` (merge base `7a84f85cdea1f1aef83613952277af31566bfcd5`)
**Head Branch:** `feature/docs-family-gate-and-ia-1221` at `e5e96e58dcb6fca9fe37820fcd95a9e290a6fd89`
**Review Type:** Re-audit at the exit of remediation cycle 1 (S7), epic child of #1217

---

## Executive Summary

This review covers the full branch diff from the merge base `7a84f85cd` to head `e5e96e58d` (87 changed paths). The feature itself is unchanged from the prior review at `40b69e354` (verdict PASS): the new pure module `.claude/lib/docs/DocsFamilyCheck.psm1`, its wiring into the docs-complete validation layer and the coverage command, the `docs-plan-ia` family step in four copies, and two MCP description strings.

Remediation cycle 1 (commit `e5e96e58d`) resolves finding R-1 of `remediation-inputs.2026-11-24T08-32.md`. The root-file rule no longer depends on the case behavior of the host file system:

- `Read-DocsFamilyEvidence` keeps its two `TestFile` probes. When either probe is positive, it makes one `ListFile` call with the empty path and keeps a name only when the root listing contains it under `[System.StringComparer]::Ordinal`. No root listing is made when both probes are negative.
- `Get-DocsContextFileList` in `Invoke-DocsCommand.ps1` gains one branch: an empty `RelativeRoot` returns the file names of the repository root only (`TopDirectoryOnly`, ordinal-sorted). Every other value keeps its path check and recursive listing. The remediation plan (RP-2) records why the edit is required: no existing seam returned the stored names of the root entries, and a recursive root listing would enumerate `.git` and dependency trees on every docs-complete run.
- The in-memory twin in `DocsLedger.TestSupport.psm1` models the empty-root listing. Four new `Read-DocsFamilyEvidence root-file name case` cases use a fake seam with a case-insensitive `TestFile`. One existing call-log assertion gains the trailing `ListFile ` entry. Two context cases cover the empty-root listing on the in-memory and real contexts.
- Both production files have byte-identical bundle copies. Spec D7, `### Family evidence`, and the `## File Inventory` "Not edited" sentence record the change; no AC text changed.

Review checks at head: a real-process probe on this Windows host (NTFS, case-insensitive) with the production context. For a root holding `security.md` and `codeowners`, `TestFile('SECURITY.md')` returned `True` and `RootFile` returned `False` for both names. For a root holding `SECURITY.md` and `CODEOWNERS`, `RootFile` returned `True` for both. Other checks: the generator `-Check` (no drift), byte comparison of the bundle copies, the evidence-location validator (exit 0), logical line counts, and one targeted parallel Pester run of `tests/scripts/claude-lib/docs` at head (see the policy audit).

**What changed in the cycle:**
- `.claude/lib/docs/DocsFamilyCheck.psm1` (+11 lines of logic and help) and `.claude/lib/docs/Invoke-DocsCommand.ps1` (+7 lines), with their bundle copies.
- Tests: `DocsFamilyCheck.Tests.ps1` (helper plus four cases, one assertion updated), `Invoke-DocsCommand.Tests.ps1` (one case), `DocsLedger.TestSupport.psm1` and `DocsLedger.TestSupport.Tests.ps1` (empty-root listing and one case).
- Spec D7 sentence, the `### Family evidence` bullet, and the `## File Inventory` sentence.

**Top 3 risks:**
1. CI has not run at the head: no PR exists yet, so the integration-lane suites (`DocsCompleteIntegration.Tests.ps1`, `DocsReferenceIntegration.Tests.ps1`), which the launcher refuses locally, are unconfirmed (spec AC-26).
2. Every consumer repository whose profile was seeded by `docs-init` after #1218 fails docs-complete once this lands, until it adds pages, root files, or exclusions. A repository whose root file is named `security.md` now fails on every host, where before the cycle it passed on Windows and macOS. Spec D7 states this behavior.
3. `ListFile` now accepts the empty path (and `$null`, which binds to an empty string) as a request for the root file names, where it previously threw `DOCS_CONTEXT_PATH_INVALID`. Every other caller passes schema-validated `relative-path` values (`minLength: 1`), so the change is reachable only from the new caller (Info row).

**PR readiness recommendation:** **Ready** — no Blocker or Major finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `.claude/lib/docs/DocsLedgerCommands.psm1` (and its bundle copy) | whole file | The file is at 762 logical lines (advisory tier, at or above 700). This item added 2 lines; the cycle did not touch it. | No action required in this item. | File-size advisory tier; below the 800-line hard limit, and not listed in `config/file-size-baseline.json`. | `awk 'END{print NR}'` = 762 at head. |
| Info | `.claude/lib/docs/DocsFamilyCheck.psm1` | `Read-DocsFamilyEvidence`, lines 132-140 | R-1 resolved. A positive `TestFile` probe is confirmed against one root listing compared ordinally, so `security.md` and `codeowners` do not satisfy the rule on Windows, macOS, or Linux, and the exact names do. | None. | Matches the required outcome of `remediation-inputs.2026-11-24T08-32.md` and spec D7. | Review real-process probe (Windows host, production context); `fail-before.2026-11-24T09-47.md` (four expected failures before the fix); the four `root-file name case` cases pass at head. |
| Info | `.claude/lib/docs/Invoke-DocsCommand.ps1` | `Get-DocsContextFileList`, lines 324-329 | The empty-path branch bypasses `Test-DocsRelativePath` by design and returns bare file names, not repository-relative paths below a directory. `$null` binds to the empty string and takes the same branch. Before the cycle both inputs threw `DOCS_CONTEXT_PATH_INVALID`. | None in this item. A caller that needs the old rejection of an empty path must check the value itself. | Every existing caller (`DocsInventory`, `DocsLedgerCommands`, `DocsPageCheck`, `DocsProfileSourceRoot`) passes profile paths that the schema `relative-path` definition (`minLength: 1`) has validated, and `Test-DocsProfileRootListsFile` binds `Root` as a mandatory string. `..` still throws (review probe). The help text of `Get-DocsContextFileList` and `New-DocsCommandContext` states the new contract. | Review probe (`ListFile '..'` throws, `ListFile $null` lists the root); `grep` of `ListFile` callers. |
| Info | `.dev/active/1221-docs-family-gate-and-ia/spec.md` | `## File Inventory`, `### Family evidence`, D7 | The cycle edited three spec sentences, not only D7: the `### Family evidence` bullet now describes the root listing, and the `## File Inventory` "Not edited" sentence no longer lists `Invoke-DocsCommand.ps1` and records the cycle edit. No AC line changed. | None. | The remediation plan (RP-2, P1-T5) names all three edits; they keep the spec consistent with the code. | `git diff 40b69e354 HEAD -- spec.md` (3 lines); `task-check.P1-T5.2026-11-24T10-05.md` (0 changed `AC-` lines). |
| Info | `tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1` | `New-TestCaseInsensitiveSeam` | The helper carries a `PSUseShouldProcessForStateChangingFunctions` suppression with a justification, keeping the plan's helper name. | None. | Same pattern as `New-DocsLedgerTestContext`; recorded as executor decision 4 (`decisions.2026-11-24T10-37.md`). | Test file diff. |
| Info | `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | line 325 | Carried from the prior review: the sorted key assertion includes `placeholders` from the merged sibling #1219 beside the seven AC-15 keys. | None. | Every key the AC names is asserted. | Prior review `code-review.2026-11-24T07-55.md`. |
| Info | `.claude/lib/docs/DocsFamilyCheck.psm1` | `Get-DocsFamilyStatus` | Carried from the prior review: `missing_root_files` is filled for a non-excluded `security` entry whatever its `required` value; the finding is emitted only for `required: true`. | None. | Matches spec `### Family status`; executor decision 4 of `decisions.2026-11-23T13-10.md`. | Prior review. |
| Info | `.dev/potential/promoted/2026-11-23-docs-findings-limit-envelope-schema.md` | new file | Promotion record of the out-of-scope `FINDINGS_LIMIT` envelope defect (#1230), as spec D13 requires. | None. | Out of scope per the delegation and spec D13. | `decisions.2026-11-24T05-07.md` decision 2. |

No Blocker or Major finding. The Warning and Info rows are non-blocking.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix uses the existing seams. `Read-DocsFamilyEvidence` keeps its signature, and the context keeps its twelve members (`exposes the same member names as the in-memory context` passes).
- The comparison is ordinal (`HashSet[string]` with `StringComparer.Ordinal`), consistent with every other name comparison in the module.
- The root listing is made at most once and only when a probe is positive, so a profile without a security family, or a repository with neither root file, makes the same seam calls as before. `makes no root listing when both root probes are negative` asserts the call log exactly.
- The production branch lists the top directory only, so the cost is bounded and does not enumerate `.git` or nested worktrees.
- Non-string listing entries are ignored (`$entry -is [string]`), so a malformed seam answer cannot satisfy the rule.

#### API and safety notes

- `ListFile ''` is a new documented contract of the production and in-memory contexts; both return ordinal-sorted names of root files only. `Directory.EnumerateFiles` returns the names as stored on disk, which is what makes the ordinal match independent of the file system's case behavior.
- Bundle copies of both production files are byte-identical (`cmp` exit 0; hashes recorded in `final-push-down-contracts.2026-11-24T10-36.md`).

#### Error handling and logging

- A throwing `ListFile` during the root listing propagates to the existing `DOCS_CLI_RUNTIME` handler of the calling command, as for the family directory listings. No new catch was added.

### TypeScript implementation audit

- Unchanged in the cycle. Description strings only in `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts`; no logic change and no new file.

### Skill text audit

- Unchanged in the cycle. The generator `-Check` reports no drift at head.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `evidence/regression-testing/fail-before.2026-11-24T09-47.md` — the four new cases failed before the fix for the expected reasons (`RootFile` `$true` from the case-insensitive fake seam; no root listing; `DOCS_CONTEXT_PATH_INVALID` for the empty path).
- `evidence/qa-gates/final-pester-targeted.2026-11-24T10-19.md` — targeted union, 2851 passed, 0 failed; `DocsFamilyCheck.psm1` 100.00% (100/100), `Invoke-DocsCommand.ps1` 91.08% (194/213); changed-line map with every changed executable line covered.
- `evidence/qa-gates/final-push-down-contracts.2026-11-24T10-36.md` — 43 contract cases passed; bundle hashes equal.
- `evidence/qa-gates/final-static-powershell.2026-11-24T10-06.md` — 0 files needing format, 0 analyzer findings over the eight changed PowerShell files.
- `evidence/qa-gates/review-pester-targeted.2026-11-24T11-01.md` — the review's targeted run of `tests/scripts/claude-lib/docs` at head.

### Quality assessment

- **Discrimination:** the fake seam models a case-insensitive file system (`TestFile` with `OrdinalIgnoreCase`, `ListFile` returning stored names). A mutant that compares the listing with `OrdinalIgnoreCase`, or that skips the listing, makes `does not accept a wrong-case root security.md or codeowners` fail, as the fail-before record shows for the unfixed code.
- **Determinism and isolation:** in-memory seams; the real-context case reads committed root files (`README.md`, `AGENTS.md`) only. No temporary file is created.
- **Diagnostics:** Arrange-Act-Assert comments and `-Because` reasons on every new assertion.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | The diff contains no credential or token. |
| No unsafe subprocess or command construction | ✅ PASS | The cycle adds one top-directory enumeration of the repository root; no process call. |
| Input validation at boundaries | ✅ PASS | Non-empty `ListFile` paths keep the `Test-DocsRelativePath` check (`..` throws in the review probe). |
| Error handling remains explicit | ✅ PASS | Seam failures propagate to the existing runtime handler. |
| Configuration / path handling is safe | ✅ PASS | The empty-path branch enumerates the resolved repository root only. |
| Gate integrity | ✅ PASS | `DocsCompleteGate.psm1`, the receipt and envelope schemas, and `enforce-docs-complete-gate.ps1` are unchanged against the merge base (`git diff --exit-code` exit 0). |
| Host-independent root-file rule | ✅ PASS | Review real-process probe on Windows; seam cases model the case-insensitive host. |

---

## Research Log

No external research was performed. One real-process probe on this Windows host ran `Read-DocsFamilyEvidence` with the production `New-DocsCommandContext` over two scratch roots: wrong-case `security.md` and `codeowners`, and exact `SECURITY.md` and `CODEOWNERS`. It also called `ListFile` with `..` and `$null`. The scratch roots are in the session scratch directory, outside the worktree.

---

## Verdict

R-1 is resolved and the cycle introduced no regression. No blocking finding exists; the Warning and Info rows are non-blocking. The branch is ready for a PR to the integration branch; the integration-lane suites and the CI quality checks remain to be confirmed at the PR head (spec AC-26).
