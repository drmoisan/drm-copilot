# Code Review: propagate-claude-ecosystem-hardening (#187)

**Review Date:** 2026-06-16
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187`
**Feature Folder Selection Rule:** Suffix `-187` matches the issue number in the branch name `feature/propagate-claude-ecosystem-hardening-187`.
**Base Branch:** `main` (merge-base `c903b1f9531a164a4470524171b17ef63759ee93`)
**Head Branch:** `feature/propagate-claude-ecosystem-hardening-187` @ `24353b0bf4527092832cdfaea81c37b0367614c5`
**Review Type:** Initial review

---

## Executive Summary

The change propagates seven hardened Claude-ecosystem elements from an audited source tree into the canonical `.claude/` runtime, both bundled mirrors, and the Python orchestrator-state validator. The implementation is cohesive, additive, and backward-compatible: every new gate passes when its triggering key/section is absent, and all changes follow the established helper-plus-error-list (Python) and `Ok`/`Message` hashtable (PowerShell) patterns already present in the touched files.

**What changed:**
- `validate-orchestrator-output.ps1`: adds `Test-HumanInteractionShape` (six ordered rejection branches + absent-key pass + injectable `$FileExistsCheck` seam), wired after the required-fields/objective checks in `Invoke-OrchestratorOutputValidation`.
- `validate-task-researcher-output.ps1`: adds `Test-AutomationFeasibilitySection` (detection pattern `autonomous-execution|human-interaction`, requires an `## Automation Feasibility` heading, injectable `$ReadFileContent` seam).
- `validate_orchestrator_state.py`: adds `_validate_human_interaction` and four module constants; invoked only when the `human_interaction` key is present.
- Documentation/skills: `orchestrate/SKILL.md` (Autonomous-Execution Mandate), new `human-exception-runbook/` skill (SKILL + example), expanded `remediation-handoff-atomic-planner/SKILL.md`, additive `general-unit-test.md` and `orchestrator-state.md` sections.
- The eight `.claude/` files are byte-identical across canonical and both mirrors.

**Top 3 risks:**
1. `scripts/dev_tools/validate_orchestrator_state.py` is now 505 lines, exceeding the 500-line hard limit; a follow-up that grows it further will compound the violation.
2. `orchestrate/SKILL.md` and the orchestrator hook docstring reference a schema file (`.claude/schemas/orchestrator-state.schema.json`) that does not exist in the repo, which can mislead a future maintainer into copying the prohibited foreign schema.
3. The `packages/mcp-server/` mirror has no automated parity gate (git-ignored `resources/`); future `.claude/` edits could silently desynchronize that mirror without a contract-test failure.

**PR readiness recommendation:** **Needs Revision** — functionally complete and toolchain-clean, but the 500-line file-size hard limit is violated and must be remediated before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/dev_tools/validate_orchestrator_state.py` | whole file (505 lines) | File exceeds the 500-line hard limit in `general-code-change.md` line 49 after +89 lines (base 416). | Extract a validator group (e.g., the `human_interaction` helper + constants, or the remediation-cycle helpers) into a sibling module imported by this file; keep `validate_orchestrator_state_text` signature unchanged. | The 500-line limit is a non-negotiable repo policy for production code. | `wc -l scripts/dev_tools/validate_orchestrator_state.py` -> 505; `general-code-change.md:49` |
| Minor | `.claude/skills/orchestrate/SKILL.md` | line 53 | References `.claude/schemas/orchestrator-state.schema.json` as the schema "defining" the `human_interaction` object, but that file does not exist in the repo. | Reword to state invariants are enforced by `validate_orchestrator_state.py` validator logic (and `Test-HumanInteractionShape`), not an imported schema; or add a repo-local schema that complies with the foreign-schema policy. | Documentation accuracy; avoids inviting a verbatim foreign-schema copy that `orchestrator-state.md` prohibits. | `ls .claude/schemas/orchestrator-state.schema.json` -> No such file; `orchestrate/SKILL.md:53` |
| Minor | `.claude/hooks/validate-orchestrator-output.ps1` | lines 63-65 (function help) | `Test-HumanInteractionShape` comment-based help also cites the non-existent schema path. | Update the help text to match the actual enforcement source (validator + hook logic). | Same dangling-reference concern as above. | function docstring at lines 60-83 |
| Info | `packages/mcp-server/resources/claude-customizations/.claude/...` | mirror tree | Mirror is git-ignored (`packages/mcp-server/.gitignore: resources/`) and absent from the branch diff; it is byte-identical to canonical in the working tree. | No action for #187 (documented Non-Goal). Consider adding a parity contract test for this mirror in a future change to remove the manual-sync risk. | The spec explicitly excludes an automated parity gate for this mirror. | `git ls-files` empty for path; `cmp` MATCH on all 8 files |
| Info | `artifacts/evidence/**` (pre-existing) | repo-wide | `validate_evidence_locations.py` exits 1 with 37 violations, all dated 2026-04-18/2026-04-25 from prior features; none introduced by this branch. | Out of scope for #187; recommend a separate cleanup change to relocate/remove the stale `artifacts/evidence/**` files. | This branch's evidence is correctly under the feature folder. | `git diff --name-only c903b1f..24353b0b | grep artifacts/evidence` -> empty |

No Blocker findings. One Major finding (file size) requires remediation before merge.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `_validate_human_interaction` follows the existing helper-plus-error-list convention used by `_validate_remediation_cycle`, returning one error string per violated invariant and continuing past a malformed requirement (`continue`) so callers receive a complete error list rather than stopping at the first failure.
- The invariant is strictly additive: it runs only when `HUMAN_INTERACTION_KEY in state_map`, preserving identical behavior for checkpoints without the key. A dedicated backward-compatibility test (`test_no_human_interaction_is_backward_compatible`) proves this.
- The foreign-schema constraint is honored: no schema file is imported; the enum and conditional invariants are expressed inline.

#### Typing and API notes

- Signature `(_validate_human_interaction(human_interaction: object) -> list[str])` and the public `validate_orchestrator_state_text` signature are unchanged. `cast("dict[str, Any]", ...)` / `cast("list[object]", ...)` are used after explicit `isinstance` guards, so the casts are sound and Pyright reports 0 errors.

#### Error handling and logging

- No broad exception handling; malformed shapes produce specific, checkpoint-context-prefixed error strings. The function does not mutate its input.

### PowerShell implementation audit

#### What changed well

- `Test-HumanInteractionShape` implements the documented rejection order exactly (absent-key pass; missing `requirements`; missing/blank `response`; out-of-enum `response`; `halt`; `exception` with empty or non-existent `runbook_path`) and returns precise, index-qualified messages.
- Both new functions add an injectable scriptblock seam (`$FileExistsCheck`, `$ReadFileContent`) with a production default, enabling deterministic tests without temporary files — consistent with the repo's minimal-DI seam guidance.
- Wiring is placed correctly after the existing required-field and objective checks, and the dot-source guard (`if ($MyInvocation.InvocationName -eq '.') { return }`) keeps the entrypoint test-safe.

#### API and safety notes

- Advanced functions with `[CmdletBinding()]`, `[OutputType([hashtable])]`, `[AllowNull()]`, and typed parameters. Approved verb `Test-`. No global state. `Set-StrictMode -Version Latest`.

#### Error handling and logging

- Failures surface through the `Ok`/`Message` contract; the script entrypoint converts a non-Ok result into `Write-Error` + `exit 1`. No silent catch-alls.

---

## Test Quality Audit

The verification evidence is strong and independently reproduced during this review.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py` — 8 tests covering absent-key (backward-compat), non-object block, non-list requirements, non-object requirement, out-of-enum response, exception-without-runbook (empty and missing), and a well-formed pass. Re-ran: 25 total pass with module coverage 88.43% line.
- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` and `validate-task-researcher-output.Tests.ps1` — re-ran scoped: 36 pass, 91.11% command coverage on the two hooks.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — 4 pass (extensions mirror parity).
- `evidence/qa-gates/p7-coverage-delta.2026-06-16T11-00.md`, `evidence/qa-gates/p7-poshqc-final.2026-06-16T11-00.md` — corroborate the executor's measured deltas.

### Quality assessment prompts

- **Determinism:** No wall-clock, RNG, network, or temp-file dependencies; filesystem existence/read injected via scriptblocks.
- **Isolation:** Each test targets one invariant branch.
- **Speed:** pytest 0.12s, Pester 1.22s.
- **Diagnostics:** Specific, index-qualified failure messages and substring assertions identify the exact violated invariant.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials/tokens added; changes are validation logic and documentation. |
| No unsafe subprocess or command construction | ✅ PASS | No `Invoke-Expression`; no shell construction; Python helper does no I/O. |
| Input validation at boundaries | ✅ PASS | `isinstance` guards (Python) and `PSObject.Properties.Name` membership checks (PowerShell) before dereferencing. |
| Error handling remains explicit | ✅ PASS | Specific errors per invariant; no broad catch-alls. |
| Configuration / path handling is safe | ✅ PASS | `runbook_path` existence checked via `Test-Path -LiteralPath ... -PathType Leaf` behind an injectable seam; no path concatenation from untrusted input. |

---

## Research Log

No external research was required. All findings derive from the branch diff, the AC source files (`spec.md`, `user-story.md`), the executor evidence artifacts, repo policy files (`general-code-change.md`, `general-unit-test.md`, `powershell.md`, `python.md`, `orchestrator-state.md`), and independently re-run toolchain commands.

---

## Verdict

The implementation is well-structured, additive, backward-compatible, and supported by deterministic tests with adequate coverage; both bundled mirrors are byte-identical to canonical. The change is not ready for normal PR flow as-is because `scripts/dev_tools/validate_orchestrator_state.py` exceeds the 500-line hard limit (505 lines). After the file is split below the limit and the dangling schema reference is corrected, re-running the Python and PowerShell toolchains and re-verifying mirror parity should clear the path to merge. This conclusion is consistent with the Findings Table (one Major, two Minor, two Info) and the Needs-Revision readiness recommendation.
