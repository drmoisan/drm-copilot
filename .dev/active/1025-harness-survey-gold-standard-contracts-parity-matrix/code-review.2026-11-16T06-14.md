# Code Review: Harness Survey, Gold-Standard Contracts and Parity Matrix (#1025)

---

**Review Date:** 2026-11-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`
**Feature Folder Selection Rule:** the folder whose name carries the canonical issue number 1025, named by the delegation prompt.
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `bba58bac90a30fd9f4bd3b6bf5ae8d69bf86a0ee`)
**Head Branch:** `feature/harness-survey-gold-standard-contracts-parity-matrix-1025` (head `6ad9b31f62c479a18d1b41d75dcf8db38add93b2`)
**Review Type:** Re-audit after light remediation cycle 1 (prior review `code-review.2026-11-16T05-19.md`)

---

## Executive Summary

The branch delivers epic #1018 child 1: the skill survey, the difference classification and approval record, 65 gold-standard contracts at `.agents/skills/<name>/references/standard.md` with byte-identical bundle copies, the parity matrix (655 entries) with its Draft 2020-12 schema, and three PowerShell modules with four Pester test files. This re-audit covered the full diff `bba58bac..6ad9b31` (293 files) and, in detail, the cycle 1 commit `6ad9b31f6`, which changed 32 contracts and their 32 bundle copies.

**Findings R1 and R2 are closed.** The reviewer re-ran the closure greps over both trees: `grep -n ";\.$\|,\.$\|:\.$\|listed above\|listed below"` and `grep -l "Produce the outcome that the"` return no match, the cycle 1 sweep grep returns no match, and `cmp -s` finds no differing pair among the 65 contract pairs. Every rewritten item and objective was compared with its source: the 26 R1 items, the 7 R2 objectives and the 18 sweep items match the named `SKILL.md` section or batch-record `Objective (draft)` text in substance, with tool-specific mechanisms replaced by neutral wording (detail under `## Cycle 1 Verification`). The cycle also left one gap of its own: the same generator class has residue that neither the review grep nor the sweep grep matches.

A source-comparison scan of all 65 contracts (each Observable Behavior item matched against the list items of the `SKILL.md` section it names) found 73 items that copy one list item of a multi-item section. Most are complete behavior sentences that state one rule among several, which is acceptable for a floor standard. Together with one item found by a tool-name grep, twenty-nine items are not acceptable: 8 are sentence fragments, template placeholders or references to text the contract does not contain (CR-9); 17 present one member of an enumerated set or order as the section's behavior (CR-10); and 4 state the behavior through a tool-specific mechanism, contrary to spec `### Contract Format` rule 6 (CR-11).

**What changed since the prior review:**
64 contract files (32 contracts plus bundle copies) and three evidence records. No code, test, schema, matrix or configuration file changed.

**Top 3 risks:**
1. Twelve contracts state one member of a required set as the section's behavior (CR-10), for example `policy-compliance-order` OB-1 states the reading order as the Python rule files only; child 3 would judge a neutral skill body that omits the rest of the set as conformant.
2. Six contracts hold fragment or placeholder items (CR-9), for example `skill-canonical-location-audit` OB-3 "Item: <canonical item name>." and `evidence-and-timestamp-conventions` OB-5 "Use the list order", whose list is not in the contract.
3. Three contracts name a tool-specific mechanism as the behavior (CR-11), for example `translate-copilot-to-claude` OB-2 "Read the full file with `Read`".

**PR readiness recommendation:** **Needs Revision** — three contained, autonomous content findings in files already on the branch. The prior cycle was light, so this cycle takes the full path.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.agents/skills/{acceptance-criteria-tracking,atomic-plan-contract,evidence-and-timestamp-conventions,policy-audit-template-usage,review-epic,skill-canonical-location-audit}/references/standard.md` and their bundle copies | `## Observable Behaviors` | CR-9: 8 items are fragments, template placeholders or references to absent text: `acceptance-criteria-tracking` OB-4 "The executor's final completion report (after last plan task)."; `atomic-plan-contract` OB-4 "1) Baseline capture block." and OB-5 "`DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`."; `evidence-and-timestamp-conventions` OB-5 "Use the list order by default for audit fidelity." (the list is not in the contract); `policy-audit-template-usage` OB-2 "Required Steps: `## Appendix A: Test Inventory`."; `review-epic` OB-1 "Evidence and child-feature context under that epic." ("that epic" has no antecedent); `skill-canonical-location-audit` OB-2 "1) Inventory canonical-location statements." and OB-3 "Item: <canonical item name>.". | Rewrite each item as one complete, tool-neutral behavior sentence that states the behavior of the whole `SKILL.md` section it names; keep the `- **OB-<n>** <Heading>: ` prefix, numbering and `AC-<n>` citations; copy each file byte for byte to its bundle mirror. | Same defect class as R1 (spec `### Contract Format`: an Observable Behavior is "a behavior an observer can see"). The R1 closure grep and the cycle 1 sweep grep match only line endings and named phrases, so these items passed both. | `sh firstitem.sh` source-comparison scan (method under `## Cycle 1 Verification`); the `SKILL.md` sections named by each item |
| Major | `.agents/skills/{csharp-orchestration-state-machine,evidence-and-timestamp-conventions,execute-hard-lock,feature-promotion-lifecycle,feature-review-workflow,fill-feature-docs,invoke-csharp-engineer,invoke-powershell-engineer,invoke-python-engineer,policy-compliance-order,powershell-orchestration-state-machine,pr-context-artifacts}/references/standard.md` and their bundle copies | `## Observable Behaviors` | CR-10: 17 items state one member of an enumerated set or order as the section's behavior: `policy-compliance-order` OB-1 (reading order given as the Python rule files only, of 8 entries); `evidence-and-timestamp-conventions` OB-3 (1 of 5 locations); `csharp-orchestration-state-machine` OB-2 and `powershell-orchestration-state-machine` OB-2 (`path_selected` only, of the required checkpoint fields); `feature-promotion-lifecycle` OB-3 (1 canonical variable) and OB-4 (`issue.md` only, of 5 required handoff outputs); `feature-review-workflow` OB-1 (1 of 6 required shared skills); `fill-feature-docs` OB-2 (1 of 2 output paths); `invoke-csharp-engineer`, `invoke-powershell-engineer`, `invoke-python-engineer` OB-3 (the Baseline entry only, of 5 reporting-block entries) and OB-5 (1 of 6 preloaded contracts); `pr-context-artifacts` OB-1 (summary only, of summary and appendix); `execute-hard-lock` OB-2 (`target` only; the section also requires `workspace_root`) and OB-5 (1 of the preloaded shared skills). | Rewrite each item so that it states the section's behavior as a whole, naming every member of the set or the full order in tool-neutral terms; keep prefix, numbering and citations; copy each file byte for byte to its bundle mirror. | A gold standard that names one member of a required set lets child 3 accept a skill body that omits the others; for `policy-compliance-order` OB-1 and `execute-hard-lock` OB-2 the item misstates the section. | Source-comparison scan; `SKILL.md` sections `## Required Policy Reading Order (Baseline)`, `## Canonical Evidence Locations`, `## Required Checkpoint Fields`, `## Canonical Variables`, `## Required Outputs for Downstream Handoffs`, `## Required Shared Skills`, `## Output Paths`, `## Required Reporting Block`, `## Preloaded Contracts`, `## Canonical Artifact Locations`, `## Invocation Flow`, `## Delegation Contract` |
| Major | `.agents/skills/{epic-plan,orchestrate,translate-copilot-to-claude}/references/standard.md` and their bundle copies | `## Observable Behaviors` | CR-11: 4 items state the behavior through a tool-specific mechanism: `translate-copilot-to-claude` OB-2 "Read the full file with `Read`." and OB-5 "`Read` the existing file when it exists." (a Claude tool name); `orchestrate` OB-1 "Read `AGENTS.md` ..." and `epic-plan` OB-1 "... must read `AGENTS.md`, the applicable language policies under `.agents/skills/` ..." (the Codex standing-instruction file and Codex policy mirror). | State the tool-neutral behavior (for example "reads the full source file", "reads the repository standing instructions and the applicable language policies"); keep prefix, numbering and citations; copy each file byte for byte to its bundle mirror. | Spec `### Contract Format` rule 6: tool names appear only to state that mechanism differs; the objective and behaviors are tool-neutral. Cycle 1 applied the same neutralization to `policy-compliance-order` OB-2 and three objectives. | `grep -n "^- \*\*OB-" .agents/skills/*/references/standard.md \| grep -E 'AGENTS\.md\|`Read`'` (4 lines) |
| Info | 45 further items across the contracts (for example `commit-message` OB-1, `pr-author` OB-2, `pr-base-branch-merge-base` OB-2, `orchestrate` OB-2) | `## Observable Behaviors` | CR-12: the source-comparison scan also matched 45 items that copy one rule of a multi-rule section and are complete behavior sentences. | No change. These items are accepted as written; the remediation scope is CR-9, CR-10 and CR-11 only. | Each states a real, observable behavior; a contract is a floor standard and need not restate every rule of a section. Stating the boundary here prevents the next cycle from widening scope. | Source-comparison scan output (73 matches, minus the 28 of them in CR-9 to CR-11) |
| Info | `.agents/skills/{docs-author-page,docs-plan-ia,docs-reconcile-behavior}/references/standard.md` | `## Observable Behaviors` | CR-13: four items name the docs MCP tools `run_docs_check` and `run_docs_coverage`. | No change. | The docs MCP tools are the same mechanism in every runtime that runs these skills, so rule 6 does not apply. | grep over the contracts |
| Nit | `.agents/skills/powershell-qa-gate/references/standard.md` | OB-2 | CR-14: the rewritten item states the coverage check as an unconditional fourth step; the source qualifies it as "(when enforced by task/repo flow)". | Optional: add the qualifier when the file is next edited. | No conformance impact; the qualifier narrows when the step applies. | `.agents/skills/powershell-qa-gate/SKILL.md` `## Toolchain Execution Sequence` step 4 |
| Info | `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/survey/difference-approval.md` | `## Bulk Approval Set` | CR-3 (carried): the 278 bulk rows use five fixed rationale texts and the class follows section presence; approved at the owner stop. | No change in this item. Child 3 should confirm each `positive` port direction against the skill objective before porting. | Re-classifying would reopen an approved owner decision. | Prior review |
| Info | `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/survey/difference-approval.md` | line 4 | CR-4 (carried): `Approved-By` records the autonomous orchestrator decision rather than the owner's handle. | No change. | Writing the owner's handle would misattribute an autonomous decision. | `evidence/other/owner-stop-decision.2026-11-16T03-51.md` |
| Info | `config/harness-parity-matrix.json` | `claude:mcp-server:drm-copilot`, `codex:mcp-server:drm-copilot` | CR-5 (carried): two entries stay `provisional` with a `pending-source:mcp-server` origin. | No change. | Required by the schema conditional rule `pending-source-requires-provisional`. | Prior review |
| Info | `scripts/harness/HarnessInventory.psm1` | 466-477 | CR-6 (carried): the default listing enumerates the working tree, including untracked files. | No change required now. | Spec `### Constraints & Risks` accepts this risk. | Prior review |
| Nit | `scripts/harness/HarnessParityMatrix.psm1` | 237-242 | CR-7 (carried): `New-HarnessParityMatrixSkeleton` declares `SupportsShouldProcess` although it changes no state. | Optional. | No behavior impact. | Code inspection |

No covered file in the branch diff is at or above 700 logical lines (largest `scripts/harness/HarnessInventory.psm1`, 515), so no Warning row applies. `config/file-size-baseline.json` is not in the branch diff.

---

## Cycle 1 Verification

### R1 and R2 closure

| Check | Command | Result |
|---|---|---|
| R1 truncation and dangling-phrase grep, both trees | `grep -n ';\.$\|,\.$\|:\.$\|listed above\|listed below' <tree>/*/references/standard.md` | no match |
| R2 placeholder grep, both trees | `grep -l "Produce the outcome that the" <tree>/*/references/standard.md` | no match |
| Cycle 1 sweep grep, both trees | `grep -n "^- \*\*OB-" ... \| grep -E "these \|this (exact )?order\|this closed set\|the following\|below\|above\|\(issue\.$\|skills//\|The skill defines its"` | no match (one `...` hit in `acceptance-criteria-tracking` OB-1 is the literal marker `- Work Mode: ...` from the source) |
| Mirror identity | `cmp -s` of each of the 65 base contracts against its bundle copy | 0 differing pairs |
| Scope of the cycle commit | `git diff --stat 668108e95 HEAD` | 68 files: 64 contract files, 3 evidence records, the remediation-inputs check-off |

### Source accuracy of the rewritten text

Each added line of `git diff 668108e95 HEAD -- .agents/skills` was compared with the `SKILL.md` section it names (or, for objectives, with the batch-record `Objective (draft)`):

- R1 items: the eight docs `Prerequisites` items match `## Prerequisites` of each docs skill (helper library under PowerShell 7.4 or later; root steps unavailable without it; docs MCP tools stay available). `test-execution-policy` OB-1 and OB-5 match `## Commands` and `## Hook`. `epic-plan` OB-4 matches `## Preparation Worktree Records` item 1 (repository-relative `path`, never absolute). `epic-run` OB-1 matches `## Procedure` steps 1 and 2. `human-exception-runbook` OB-5 matches `## Conformance`. `remediation-handoff-atomic-planner` OB-1 matches `## Required Remediation Inputs`. `pr-base-branch-merge-base` OB-5 matches `## Evidence Recommendation`. The C#, PowerShell and Python QA-gate `Required Inputs` and `Evidence Storage` items match their sections. The two budget-router OB-2 items and the three `Documentation Expectations` items match their sections with the `drm-copilot` MCP mechanism replaced by "the repository automation tools". `feature-promotion-lifecycle` OB-2 matches `## Agent-Session Promotion Execution Rule` without the dangling "listed above".
- R2 objectives: the seven objectives match the batch records named in `evidence/other/task-check.P0-T2.2026-11-16T06-00.md`, with the stated tool-neutral adjustments.
- Sweep items: the QA-gate `Toolchain Execution Sequence` items match the four-step order of each source (CR-14 notes one dropped qualifier); `documentation-workflow` OB-2 matches the eight-step `## Dispatch Order`; `epic-orchestrate` OB-2 matches `## Cross-Epic Dependencies`; `execute-hard-lock` OB-3 and OB-4 match `## Abort Conditions` and `## Equivalent Entry Points`; `make-skill-template` OB-3 and OB-5 match `## Example: Complete Skill Structure` and `## Validation Checklist`; `owner-directives` OB-3 matches `## Directive Classes`; the four `Worker Routing` items match their worker names; `translate-copilot-to-claude` OB-3 matches the seven ordered decision rules of `## Phase 2`; `skill-canonical-location-audit` OB-1 and `policy-compliance-order` OB-2 state the intent of their sources without the substitution defects (cycle decision D2).

### Residue scan (source-comparison method)

For each contract, each Observable Behavior item's heading was located in `.agents/skills/<name>/SKILL.md`, the list items of that section were collected, and the item was flagged when its text equals or contains one list item of a section with two or more list items. The scan flagged 73 items; the reviewer read each against its source and classified them as CR-9 (8), CR-10 (17), CR-11 (3: `translate-copilot-to-claude` OB-2 and OB-5, `orchestrate` OB-1) and CR-12 (45 accepted). The fourth CR-11 item, `epic-plan` OB-1, was found by the tool-name grep. The scan scripts are session scratch files and are not part of the branch.

---

## Implementation Audit

### PowerShell implementation audit

No PowerShell file changed in cycle 1. The prior assessment stands: file listing and reading are injected script-block parameters with on-disk defaults; the identifier encoder and decoder follow spec `### Parity Matrix: Identifier Encoding`; `Get-HarnessParityMatrixRuleSet` returns the rules as data and the repository gate compares the schema against it; ordering and uniqueness use ordinal comparison.

#### API and safety notes

- Each module exports only its documented functions; helpers stay private.
- All functions are advanced functions with `OutputType`; PSScriptAnalyzer reports zero findings.
- The 515-line inventory module is in the 500-line guidance tier only.

#### Error handling and logging

- Violations are returned as objects with `Subject`, `Rule` and `Message`; the gate prints every message.
- Non-canonical ids, more than 99 same-file duplicates and unknown kinds throw with specific messages.

---

## Test Quality Audit

The cycle 1 parallel Pester gate passed (27490 tests, 0 failures, 0 errors), including the repository gate (7 tests, 0 failures, 0 skipped) and the contract unit tests; the Python bundle-parity set passed (92). The harness modules remain at 100.00%, 99.25% and 100.00% line coverage. The contract lint checks structure only (D-R6), which is why CR-9 to CR-11 pass every gate; the remediation is verified by the reviewer's source comparison, not by a new test, and adding a sentence-content test is outside this item's spec.

### Reviewed test and QA artifacts

- `evidence/qa-gates/light-remediation-cycle-1.2026-11-16T06-00.md` — contract lint (32 contracts, 0 violations), parallel Pester gate, Python contract set (first attempt exit 75 on the machine lock, re-run 92 passed), six greps.
- `evidence/other/task-check.P0-T1.2026-11-16T05-44.md`, `evidence/other/task-check.P0-T2.2026-11-16T06-00.md` — per-task selection and results (335 selected Pester tests, 0 failures, through the parallel launcher).
- `tests/scripts/harness/*.Tests.ps1` — unchanged since the prior review.

### Quality assessment prompts

- **Determinism:** no clock, randomness or network; injected I/O; ordinal ordering.
- **Isolation:** one rule per `It`; `-ForEach` tables isolate enumerated cases.
- **Speed:** unit tests operate on in-memory data; the repository gate reads the tree once.
- **Diagnostics:** each failure lists the offending id or contract path.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or tokens in the diff; leak scan 0 failures (plan B). |
| No unsafe subprocess or command construction | ✅ PASS | The modules start no process and use no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Matrix entries are validated field by field; ids are validated against the anchored pattern before decoding. |
| Error handling remains explicit | ✅ PASS | Specific `throw` messages; no silent catch. |
| Configuration / path handling is safe | ✅ PASS | Paths are normalized to forward-slash relative form; `Test-HarnessRepositoryPath` rejects leading `/`, drive letters, backslashes and `..`. |
| Generated content correctness | ⚠️ PARTIAL | R1 and R2 closed; CR-9, CR-10 and CR-11 leave 29 items in 20 contracts that do not state their section's behavior. |

---

## Research Log

No external research was required. The review used the spec, the remediation inputs and cycle 1 evidence, the branch diff, the source `SKILL.md` files and batch records, and `artifacts/pester/powershell-coverage.xml`.

---

## Verdict

R1 and R2 are closed in every contract and every bundle copy, and the cycle 1 rewrites are accurate to their sources. The code, tests, schema and matrix are unchanged and remain ready. Three content findings of the same generator origin remain (CR-9, CR-10, CR-11: 29 items in 20 contracts and their bundle copies). They are contained, autonomous fixes to files already on the branch and are recorded in `remediation-inputs.2026-11-16T06-14.md`. Because the prior cycle was light, this cycle uses the full path. CR-12 states the boundary of accepted items so that the remediation scope is closed.
