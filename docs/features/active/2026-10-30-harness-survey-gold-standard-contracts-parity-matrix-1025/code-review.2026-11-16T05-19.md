# Code Review: Harness Survey, Gold-Standard Contracts and Parity Matrix (#1025)

---

**Review Date:** 2026-11-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`
**Feature Folder Selection Rule:** the folder whose name carries the canonical issue number 1025, named by the delegation prompt.
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `bba58bac90a30fd9f4bd3b6bf5ae8d69bf86a0ee`)
**Head Branch:** `feature/harness-survey-gold-standard-contracts-parity-matrix-1025` (head `4d23522173644d386848a8651d5267274a6407c9`)
**Review Type:** Initial review

---

## Executive Summary

The branch delivers epic #1018 child 1: a content survey of the 102 skill names across the three skill trees, a difference classification and approval record, 65 gold-standard contracts at `.agents/skills/<name>/references/standard.md` with byte-identical bundle copies, the parity matrix `config/harness-parity-matrix.json` (655 entries) with its Draft 2020-12 schema, and three PowerShell modules with four Pester test files that enforce the matrix and contract rules. The review covered the full diff `bba58bac..4d23522` (286 files), the three modules line by line, the repository gate test, the final-QC evidence and the coverage report.

The PowerShell code is cohesive, follows the injected-seam pattern, and is fully tested (100.00%, 99.25% and 100.00% line coverage). The structural lint of the contracts passes, and the bundle copies are byte-identical (verified with `cmp` for all 65 pairs). The review found two defects in the content of the contracts, of the same class as the malformed `## Owner Questions` table that plan A P3-T8 produced: text written by the session contract generator (`SCRATCH/issue-1025-contract-gen.ps1`) that passes the structural lint but is truncated or substituted.

**What changed:**
Three modules under `scripts/harness/`, four test files under `tests/scripts/harness/`, two JSON files under `config/`, one `quality-tiers.yml` entry, 130 contract files (65 plus 65 bundle copies), and the survey, runbook and evidence documents of the feature folder.

**Top 3 risks:**
1. Twenty-one contracts carry 25 Observable Behavior items that are truncated sentence fragments or point at text that is not in the contract (CR-1); child 3 judges the neutral skill bodies against these items.
2. Seven contracts carry a placeholder `## Objective` that states no outcome, although the batch records hold a specific objective for each (CR-2).
3. The 278 bulk-approved classifications were assigned by a section-presence rule with five fixed rationale texts (CR-3); child 3 ports 98 `positive` differences on that basis.

**PR readiness recommendation:** **Needs Revision** — the two contract-content findings are contained, autonomous fixes in files already on the branch; the code and gates are otherwise ready.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.agents/skills/<name>/references/standard.md` (21 files) and their bundle copies | `## Observable Behaviors` | CR-1: 25 behavior items are truncated sentence fragments ending in `;.` or `,.` (24 items in 20 files: `csharp-change-budget-router` OB-2; `csharp-qa-gate` OB-1, OB-5; `docs-author-page`, `docs-init`, `docs-inventory-surface`, `docs-plan-ia`, `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`, `documentation-workflow` OB-1; `epic-plan` OB-4; `epic-run` OB-1; `human-exception-runbook` OB-5; `powershell-change-budget-router` OB-2, OB-4; `powershell-qa-gate` OB-1, OB-5; `pr-base-branch-merge-base` OB-5; `python-change-budget-router` OB-4; `python-qa-gate` OB-1, OB-5; `remediation-handoff-atomic-planner` OB-1; `test-execution-policy` OB-1, OB-5) or refer to text outside the contract (`feature-promotion-lifecycle` OB-2, "the MCP tool forms listed above"). Examples: `test-execution-policy` OB-1 "The suite name is the first argument;."; the eight docs contracts OB-1 "Without that library every root step in this skill is unavailable;." | Rewrite each item as a complete behavior sentence taken from the source `SKILL.md` section it names, keep the `- **OB-<n>** ` prefix and numbering, and copy each file byte for byte to the bundle mirror. | Spec `### Contract Format` defines an Observable Behavior as a behavior an observer can see; a truncated fragment or a dangling reference cannot be judged by child 3, which uses the contract to judge the neutral body. The structural lint does not check sentence content, so the defect passed every gate. | `grep -n ";\.$\|,\.$\|:\.$\|listed above" .agents/skills/*/references/standard.md` (25 lines); `evidence/other/contracts-a.2026-11-16T02-30.md` (generator command) |
| Major | `.agents/skills/{csharp-change-budget-router,execute-hard-lock,feature-promotion-lifecycle,make-skill-template,powershell-change-budget-router,pr-base-branch-merge-base,translate-copilot-to-claude}/references/standard.md` and their bundle copies | `## Objective` | CR-2: the objective is the placeholder "Produce the outcome that the <name> skill exists for, with the same observable result in every tool that runs it." The batch records hold a specific objective for each of these skills (for example `survey/batch-c-integration.md` `### feature-promotion-lifecycle`: "Deterministic promotion workflow from potential feature/bug entry to issue, branch, active feature folder, and downstream spec/research handoffs."). The generator dropped it. | Replace the placeholder sentence with the `Objective (draft)` text of the skill's batch record, keep the trailing tool-neutral sentence, and copy each file byte for byte to the bundle mirror. | Spec `### Contract Format` defines `## Objective` as "the outcome the skill exists to produce"; the plan states that contracts are written "from the batch records of Phase 1". The placeholder states no outcome and diverges from the record it was generated from. | `grep -l "Produce the outcome that the" .agents/skills/*/references/standard.md` (7 files); batch records under `survey/` |
| Info | `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/survey/difference-approval.md` | `## Bulk Approval Set` | CR-3: the 278 bulk rows use five fixed rationale texts (130 "The section exists in every copy...", 98 "Adds guidance that serves the objective...", 23, 16, 9, 2), and the class follows section presence (a section present in one copy and absent elsewhere is `positive`). The classes were approved at the owner stop. | No change in this item. Child 3 should treat the 98 `positive` port directions as presence-derived and confirm each against the skill objective before porting. | Re-classifying would reopen an approved owner decision; the acceptance criteria (class, port direction, exactly one placement) are met. | `awk` count of the rationale column of `difference-approval.md` |
| Info | `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/survey/difference-approval.md` | line 4 | CR-4: `Approved-By` records `orchestrator-autonomous-mode (...)` rather than the owner's GitHub handle named by spec `### Owner Approval Artifact`. | No change. The record states who decided; writing the owner's handle would misattribute an autonomous decision. | The acceptance criterion requires a filled `Approved-By`, which holds; the field rule is followed in substance. | `evidence/other/owner-stop-decision.2026-11-16T03-51.md` |
| Info | `config/harness-parity-matrix.json` | `claude:mcp-server:drm-copilot`, `codex:mcp-server:drm-copilot` | CR-5: two entries remain `provisional` with `decision_ref` `#1025:survey/difference-approval.md` after approval. | No change. `generated_from` is `pending-source:mcp-server`, and the schema requires `provisional` for a placeholder source; child 3 settles them when it creates the server list. | Consistent with the schema conditional rule `pending-source-requires-provisional`. | `pwsh` group-by of the matrix (`decision_status`, `decision_ref`) |
| Info | `scripts/harness/HarnessInventory.psm1` | 466-477 | CR-6: the default listing enumerates the working tree under the listing roots, including untracked or ignored files; a developer with a local, untracked skill folder sees a missing-entry violation that CI does not. | No change required now; `git ls-files --others` lists no untracked file under the listing roots at the reviewed head. A later child may switch the default listing to tracked files. | Spec `### Constraints & Risks` accepts this risk for the named local-scope paths only. | `git ls-files --others -- <listing roots>` (empty) |
| Nit | `scripts/harness/HarnessParityMatrix.psm1` | 237-242 | CR-7: `New-HarnessParityMatrixSkeleton` declares `SupportsShouldProcess` although it only returns objects and changes no state. | Optional: keep for the `New-` verb analyzer rule or drop it in a later change. | No behavior impact. | Code inspection |
| Info | `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/evidence/qa-gates/file-size.2026-11-16T03-41.md` | Command | CR-8: the file-size evidence measured with `wc -l`. | No change; the reviewer re-measured with `@(Get-Content).Count` and every count matches (largest 515). | Evidence is append-only; the measurement is confirmed. | `pwsh` line counts in `policy-audit.2026-11-16T05-19.md` section 2.3 |

No file in the branch diff is at or above 700 logical lines, so no Warning row applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- File listing and file reading are injected script-block parameters with on-disk defaults, so every unit test runs on in-memory input and creates no file.
- The identifier encoder and decoder implement spec `### Parity Matrix: Identifier Encoding` exactly: UTF-8 percent-encoding of non-unreserved bytes, rejection of lowercase hex, encoded unreserved characters and invalid UTF-8 (strict `UTF8Encoding`), and the duplicate tie-break with `~<source_path>` and `~<nn>`.
- `Get-HarnessParityMatrixRuleSet` returns the rules as data, and the repository gate compares the schema file against that data (property names, required lists, enums, conditional rules and the id pattern), so the module and the schema cannot drift silently within the D-R6 scope.
- Ordering and uniqueness use ordinal comparison throughout (`[string]::CompareOrdinal`, `StringComparer.Ordinal`, `-cnotmatch`, `-ccontains`), which removes culture dependence.

#### API and safety notes

- Each module exports only its documented functions; helpers stay private.
- All functions are advanced functions with `OutputType`; PSScriptAnalyzer reports zero findings.
- Script-scoped variables are read-only constants.
- The 515-line inventory module is in the 500-line guidance tier only; the spec anticipated a split by kind family if needed, and none is required.

#### Error handling and logging

- Violations are returned as objects with `Subject`, `Rule` and `Message`; the gate prints every message.
- Non-canonical ids, more than 99 same-file duplicates and unknown kinds throw with specific messages. The one `try`/`catch` re-throws with context.

---

## Test Quality Audit

The final parallel Pester gate passed with 27468 tests and no failure, the harness modules are at 100.00%, 99.25% and 100.00% line coverage, the leak scan reports zero failures, and the plan B gate repeated the plan A results with no drop. Every failure case named in the spec acceptance criteria has a dedicated `It`.

### Reviewed test and QA artifacts

- `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` — 76 tests: pass case covering every disposition and each invariant failure case, including the conditional rules and the top-level object rules.
- `tests/scripts/harness/HarnessSkillContract.Tests.ps1` — 25 tests: each structural rule of `### Contract Format`; it does not test sentence content, which is consistent with D-R6 and is why CR-1 and CR-2 passed the gate.
- `tests/scripts/harness/HarnessInventory.Tests.ps1` — 41 tests: each kind rule, the exclusion list, encoding, tie-breaks and the D-R1 dispatch registries.
- `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` — 7 tests on the committed tree; the `Test-Json` assertion is skipped below 7.4 and passed on 7.6.10.
- `evidence/qa-gates/final-pester-b.2026-11-16T05-10.md`, `coverage-delta-b.2026-11-16T05-10.md`, `final-leak-scan-b.2026-11-16T05-10.md`, `final-contract-checks-b.2026-11-16T05-11.md` — final QA loop records.

### Quality assessment prompts

- **Determinism:** no clock, randomness or network; injected I/O; ordinal ordering.
- **Isolation:** one rule per `It`; `-ForEach` tables isolate enumerated cases.
- **Speed:** unit tests operate on in-memory data; the repository gate reads the tree once.
- **Diagnostics:** each failure lists the offending id or contract path.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or tokens in the diff; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | The modules start no process and use no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Matrix entries are validated field by field; ids are validated against the anchored pattern before decoding. |
| Error handling remains explicit | ✅ PASS | Specific `throw` messages; no silent catch. |
| Configuration / path handling is safe | ✅ PASS | Paths are normalized to forward-slash relative form; `Test-HarnessRepositoryPath` rejects leading `/`, drive letters, backslashes and `..`. |
| Generated content correctness | ⚠️ PARTIAL | CR-1 and CR-2: contract text produced by the session generator is truncated in 21 files and substituted in 7 files. |

---

## Research Log

No external research was required. The review used the spec, the plans, the branch diff, the evidence artifacts and `artifacts/pester/powershell-coverage.xml`.

---

## Verdict

The PowerShell modules, tests, schema, matrix and bundle copies are ready for normal PR flow, and all policy checks pass. The contract content is not: 21 contracts hold truncated or dangling behavior items (CR-1) and 7 hold a placeholder objective (CR-2). Both are contained, autonomous fixes to files already on the branch and their bundle mirrors, with no change to code, tests, schema or acceptance criteria, and are recorded as light remediation tasks in `remediation-inputs.2026-11-16T05-19.md`.

No other defect of the P3-T8 class was found: a table-shape scan of every Markdown file in the feature folder (rows whose cell count differs from the header, or rows of one-character cells) found no malformed table, and the matrix, survey and contracts contain no serialized PowerShell object text. The `## Owner Questions` table now holds eight well-formed rows (Q1 to Q8).
