# 2026-04-26-push-down-claude-customizations - Plan

- **Issue:** #162
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-26T13-49
- **Status:** Approved-for-execution (pending preflight)
- **Version:** 1.0
- **Work Mode:** full-feature
- **Feature folder:** `docs/features/active/2026-04-26-push-down-claude-customizations-162/`

## Required References

- Repository tone and policy: `.github/copilot-instructions.md`
- General code change policy: `.github/instructions/general-code-change.instructions.md`
- General unit test policy: `.github/instructions/general-unit-test.instructions.md`
- Python policy: `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`
- TypeScript policy: `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`
- Atomic plan contract: `.claude/skills/atomic-plan-contract/SKILL.md`
- Evidence and timestamp conventions: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

All work must comply with these policies; do not duplicate their content here. All evidence artifacts in this plan resolve to the canonical path `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/<kind>/`.

## Source Documents (Authoritative Inputs)

- `docs/features/active/2026-04-26-push-down-claude-customizations-162/issue.md`
- `docs/features/active/2026-04-26-push-down-claude-customizations-162/spec.md`
- `docs/features/active/2026-04-26-push-down-claude-customizations-162/user-story.md`
- `artifacts/research/20260425-push-down-claude-customizations-audit.md`
- `artifacts/orchestration/orchestrator-state.json`

## Implementation Strategy Notes

- **settings.local.json exclusion seam choice (Phase 5).** The exclusion is implemented as an additional explicit `excluded_relative_paths: tuple[Path, ...]` filter applied inside the new module's wrapping of `enumerate_source_files`, layered above the shared engine without modifying the engine signature. This keeps the engine reusable for the existing Copilot and Codex/Agents publishers (which pass an empty tuple by default) and contains the .claude/-specific exclusion logic in one local helper. A filesystem-wrapper alternative was rejected because it would couple the exclusion to file-system enumeration, increasing surface area for tests and forcing the wrapper to know about .claude/-specific semantics. The chosen seam keeps the engine pure and the exclusion declarative.
- **Per-batch budget.** Python batches contain at most 3 production files and 3 test files. TypeScript batches contain at most 3 production files. The plan honors this by splitting Phase 8 across two task groups when more than 3 source files are touched.
- **No-creation rule for source policy files.** `.claude/rules/*.md` and `.github/instructions/*.md` are read-only in this plan.

---

### Phase 0 — Preflight, Policy Reads, and Baseline Capture

- [x] [P0-T1] Read repository policy files in the order defined by `.claude/skills/policy-compliance-order/SKILL.md` and record evidence at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-instructions-read.md`. The artifact MUST contain `Timestamp:`, `Policy Order:`, and the explicit list of files read: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/tonality.md`.
  - Acceptance: artifact exists with all required fields; no policy file is modified.

- [x] [P0-T2] Confirm branch state and feature folder integrity. Verify branch is `feature/push-down-claude-customizations-162` (rename target per `orchestrator-state.json:variables.branch-target`) and that the active feature folder `docs/features/active/2026-04-26-push-down-claude-customizations-162/` contains `issue.md`, `spec.md`, `user-story.md`, and `plan.2026-04-26T13-49.md`. Record output at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-feature-state.md` with `Timestamp:`, `Command:` (`git rev-parse --abbrev-ref HEAD` and `ls docs/features/active/2026-04-26-push-down-claude-customizations-162/`), `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: branch name matches and all four feature documents are present.

- [x] [P0-T3] Capture Python format baseline. Run `poetry run black --check .` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-python-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact exists; Output Summary states pass/fail and any reformatted file count.

- [x] [P0-T4] Capture Python lint baseline. Run `poetry run ruff check .` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-python-lint.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact exists with violation count or "All checks passed".

- [x] [P0-T5] Capture Python type-check baseline. Run `poetry run pyright` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-python-typecheck.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact exists with error/warning counts.

- [x] [P0-T6] Capture Python test+coverage baseline. Run `poetry run pytest --cov --cov-report=term-missing` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-python-test-coverage.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` containing the numeric repository-wide line coverage percentage and the passed/failed test counts.
  - Acceptance: artifact contains a numeric coverage value (e.g. `Coverage: 87.4%`).

- [x] [P0-T7] Capture TypeScript format baseline. Run `npm --prefix extensions/drm-copilot run format -- --check` (or the project-equivalent prettier check) and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-typescript-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact exists.

- [x] [P0-T8] Capture TypeScript lint baseline. Run `npm --prefix extensions/drm-copilot run lint` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-typescript-lint.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact exists.

- [x] [P0-T9] Capture TypeScript type-check baseline. Run `npm --prefix extensions/drm-copilot run typecheck` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-typescript-typecheck.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact exists.

- [x] [P0-T10] Capture TypeScript test+coverage baseline. Run `npm --prefix extensions/drm-copilot run test:unit -- --coverage` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-typescript-test-coverage.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` containing the numeric line coverage and pass/fail counts.
  - Acceptance: artifact contains numeric coverage.

- [x] [P0-T11] Inventory in-scope script-reference occurrences before edits. Run `git grep -n -E "poetry run python -m scripts|scripts/dev[_-]tools|scripts\.dev_tools|\$\{workspaceFolder\}/scripts" -- ".claude/**/*.md"` and write the verbatim output to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-script-references-inventory.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` listing the count of matches and the file:line of each match. The pre-edit inventory must report the actual on-disk total of 11 occurrences across 4 files, partitioned as follows:
  - **In-scope occurrences (10 across 3 files; R1–R10 per the audit):** `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.claude/skills/pr-base-branch-merge-base/SKILL.md`, `.claude/skills/execute-hard-lock/SKILL.md`. These are the targets cleaned in Phases 1–3.
  - **Out-of-scope occurrence (1 across 1 file):** `.claude/rules/powershell.md:57` — the matched text `- Organize tests to mirror code structure (e.g., \`tests/scripts/dev-tools/ScriptName.Tests.ps1\`).` This is a test-path layout example in policy documentation, not a runnable script invocation. The file `.claude/rules/powershell.md` is a read-only policy rule per the Implementation Strategy Notes ("`.claude/rules/*.md` and `.github/instructions/*.md` are read-only in this plan") and is outside the spec.md "Out of Scope" boundary. The Output Summary must enumerate this occurrence explicitly with the rationale "policy rule documentation example of test layout, not a script invocation; out-of-scope per spec.md Edge Cases; recorded for traceability only". This occurrence is cross-referenced as the `EXCLUDED_DOCUMENTATION_PATHS` exclusion class enforced by P6-T1.
  - Acceptance: artifact exists; Output Summary states `Occurrences (total on disk): 11`, `In-scope occurrences: 10`, `Out-of-scope occurrences: 1`; lists in-scope files `feature-promotion-lifecycle/SKILL.md`, `pr-base-branch-merge-base/SKILL.md`, `execute-hard-lock/SKILL.md`; and explicitly enumerates the `.claude/rules/powershell.md:57` occurrence with the documented out-of-scope rationale.

- [x] [P0-T12] Inventory bare tool-name occurrences in the two normalization targets. Run `git grep -n -E "\b(validate_orchestration_artifacts|resolve_atomic_plan_prompt|resolve_policy_audit_template_asset)\b" -- ".claude/skills/atomic-plan-contract/SKILL.md" ".claude/skills/policy-audit-template-usage/SKILL.md"` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-bare-tool-names-inventory.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. The Output Summary must enumerate the verbatim occurrences that will be normalized in Phase 3.
  - Acceptance: artifact exists; Output Summary lists each match with file:line.
- [x] [P0-T13] Capture orchestrate skill baseline. Capture the current state of `.claude/skills/orchestrate/SKILL.md` (line count, SHA-256 or MD5 hash, section headings) and write to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase0-orchestrate-skill-baseline.md` with `Timestamp:`, `Command:` (recording how the hash was captured), `EXIT_CODE:`, `Output Summary:` (line count and section headings enumerated), `File Hash:`.
  - Acceptance: artifact exists at the cited path; Output Summary records the numeric line count and at least 6 known section headings; File Hash contains a non-placeholder SHA-256 or MD5 hash value.
---

### Phase 1 — Part A.1: feature-promotion-lifecycle/SKILL.md MCP-First Reframing

- [x] [P1-T1] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` frontmatter `description` field at line 3. Replace the verbatim text `Prefer VS Code extension command execution when extension tools are available; use underlying scripts only as fallback.` with `Prefer the drmCopilotExtension MCP tools when the MCP server is connected; the script forms documented under "Fallback only — when MCP server is unreachable" are reserved for direct-source developers without MCP access.`
  - Acceptance: line 3 ends with the new sentence; no other frontmatter field is modified.

- [x] [P1-T2] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` heading at line 18. Replace `## Extension-First Execution Rule` with `## MCP-First Execution Rule`.
  - Acceptance: line 18 is the new heading; no other line is modified.

- [x] [P1-T3] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` paragraph at line 20. Replace the verbatim sentence `When the agent has access to the VS Code extension tool surface (in particular `vscode/runCommand` plus extension access), execute the lifecycle through the contributed extension commands first.` with `When the agent has the drmCopilotExtension MCP server connected, execute the lifecycle through the MCP tools first; the MCP form is authoritative for agent sessions.`
  - Acceptance: line 20 contains the new sentence verbatim.

- [x] [P1-T4] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 22 heading-text `Canonical extension command invocations:` to `Canonical MCP tool invocations:`.
  - Acceptance: line 22 contains the new label.

- [x] [P1-T5] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 23 (audit decision_5, R-bullet 1). Replace the verbatim line `- feature potential entry: `drmCopilotExtension.newPotentialEntry` with `[`"-ShortName"`, `"${short-name}"`]`` with `- feature potential entry: `mcp__drmCopilotExtension__new_potential_entry` with `short_name=${short-name}``.
  - Acceptance: line 23 matches the new form exactly; no surrounding line is modified.

- [x] [P1-T6] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 24. Replace the verbatim line `- bug potential entry: `drmCopilotExtension.newPotentialBugEntry` with `[`"--short-name"`, `"${short-name}"`]`` with `- bug potential entry: `mcp__drmCopilotExtension__new_potential_bug_entry` with `short_name=${short-name}``.
  - Acceptance: line 24 matches the new form exactly.

- [x] [P1-T7] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 25. Replace the verbatim line `- potential-to-issue promotion: `drmCopilotExtension.potentialToIssue` with `[`"--potential-path"`, `"${relativeFile}"`, `"--promotion-type"`, `"${promotion-type}"`, `"--work-mode"`, `"${work-mode}"`]`` with `- potential-to-issue promotion: `mcp__drmCopilotExtension__potential_to_issue` with `potential_path=${relativeFile}`, `promotion_type=${promotion-type}`, `work_mode=${work-mode}``.
  - Acceptance: line 25 matches the new form exactly.

- [x] [P1-T8] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 26. Replace the verbatim line `- active feature folder creation: `drmCopilotExtension.newActiveFeatureFolder` with `[`"--feature-name"`, `"${long-name}"`, `"--type"`, `"${promotion-type}"`, `"--issue-number"`, `"${issue-num}"`, `"--work-mode"`, `"${work-mode}"`]`` with `- active feature folder creation: `mcp__drmCopilotExtension__new_active_feature_folder` with `feature_name=${long-name}`, `type=${promotion-type}`, `issue_number=${issue-num}`, `work_mode=${work-mode}``.
  - Acceptance: line 26 matches the new form exactly.

- [x] [P1-T9] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` heading at line 28 (`Fallback rule:`) and the two bullets at lines 29–30. Replace the entire 28–30 block with:

  ```
  Documented alternatives:
  - VS Code command IDs (e.g. `drmCopilotExtension.newPotentialEntry`) remain available for interactive command-palette use in VS Code with the extension installed. They are not authoritative for agent sessions.
  - When the MCP server is unreachable, fall back to the direct script form documented under the explicit `### Fallback only — when MCP server is unreachable` subsection below. The fallback form is reserved for direct-source developers; it is not pushed to destination workspaces.
  ```
  - Acceptance: lines 28–30 contain the replacement block; no other lines in the section are modified.

- [x] [P1-T10] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` heading at line 44. Replace `## Canonical Fallback Command Sequence` with the following two-line replacement:

  ```
  ## Canonical Fallback Command Sequence

  ### Fallback only — when MCP server is unreachable
  ```

  This introduces an explicit subsection heading without removing the parent section heading. The subsection heading is the documented filter target referenced by the Phase 4 grep (per spec.md Edge Cases: "fallback-section treatment").
  - Acceptance: lines 44–46 contain the parent heading, blank line, and the new subsection heading; the bullets at lines 47–48 remain intact below the new subsection.

- [x] [P1-T11] Insert an introductory paragraph immediately after the new `### Fallback only — when MCP server is unreachable` subsection heading (between the new subsection heading inserted by P1-T10 and the existing list at original line 47). Insert verbatim:

  ```
  The MCP form documented above is authoritative for agent sessions. The script bullets in this fallback subsection are documented only for direct-source developers running the source repository where `scripts/dev_tools/...` modules exist. They are intentionally not pushed to destination workspaces; in destinations they correctly become unreachable, which is the intended fallback semantic.
  ```
  - Acceptance: the new paragraph appears immediately after the subsection heading; the four script bullets (formerly lines 47, 48, 51, 57) remain unchanged below it.

- [x] [P1-T12] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` heading at the original line 59 (`## Canonical Fallback Short-Path Sequence (Minor Audit Mode)`). Insert immediately below it (above the original "When orchestrator routing selects short path..." sentence) a new subsection heading and paragraph identical in form to P1-T10/P1-T11:

  ```
  ### Fallback only — when MCP server is unreachable

  The MCP form is authoritative for agent sessions. The script bullets below are documented only for direct-source developers; they are intentionally not pushed to destination workspaces.
  ```
  - Acceptance: the original parent heading at line 59 remains; the new subsection heading and paragraph are inserted directly beneath it; the existing script bullets (originally lines 64, 70) and steps remain unchanged.

- [x] [P1-T13] Verify the file post-edit. Run `git diff -- .claude/skills/feature-promotion-lifecycle/SKILL.md` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p1-feature-promotion-lifecycle-diff.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` listing the lines added/removed and confirming the original script bullets at original lines 47, 48, 51, 57, 64, 70 are intact under the new subsection.
  - Acceptance: artifact records the diff and confirms script bullets remain.

---

### Phase 2 — Part A.1: pr-base-branch-merge-base/SKILL.md MCP Reference Updates

- [x] [P2-T1] Edit `.claude/skills/pr-base-branch-merge-base/SKILL.md` line 3 (audit R7). Replace the verbatim frontmatter `description` value `'Resolve PRBaseBranch for scripts.dev_tools.pr_context.collector using merge-base ancestry. Use when orchestrators or review workflows need the correct comparison base branch and must select the branch with the most recent common ancestor commit with HEAD.'` with `'Resolve PRBaseBranch for the collect_pr_context MCP tool (mcp__drmCopilotExtension__collect_pr_context) using merge-base ancestry. Use when orchestrators or review workflows need the correct comparison base branch and must select the branch with the most recent common ancestor commit with HEAD.'`
  - Acceptance: line 3 ends with the new description.

- [x] [P2-T2] Edit `.claude/skills/pr-base-branch-merge-base/SKILL.md` line 13 (audit R8). Replace the verbatim line `- running `scripts.dev_tools.pr_context.collector`,` with `- running `mcp__drmCopilotExtension__collect_pr_context`,`.
  - Acceptance: line 13 matches the new form exactly.

- [x] [P2-T3] Edit `.claude/skills/pr-base-branch-merge-base/SKILL.md` line 47 (audit R9). Replace the verbatim line `- `poetry run python -m scripts.dev_tools.pr_context.collector --base <resolved-PRBaseBranch>`` with `- `mcp__drmCopilotExtension__collect_pr_context` with `base=<resolved-PRBaseBranch>``.
  - Acceptance: line 47 matches the new form exactly.

- [x] [P2-T4] Verify post-edit. Run `git grep -n -E "scripts\.dev_tools|scripts/dev[_-]tools|poetry run python -m scripts" -- ".claude/skills/pr-base-branch-merge-base/SKILL.md"` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p2-pr-base-branch-grep.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Output Summary must show zero matches.
  - Acceptance: artifact records zero matches.

---

### Phase 3 — Part A.1: execute-hard-lock/SKILL.md Script Bullet Removal

- [x] [P3-T1] Edit `.claude/skills/execute-hard-lock/SKILL.md` line 66 (audit R10). Delete the entire bullet line `- Local task (development only): `poetry run python scripts/dev_tools/resolve_hard_lock_prompt.py --target ${file} --workspace ${workspaceFolder}` (same: stdout + clipboard).` so that the file ends the "Equivalent Entry Points (Reference)" section with only the MCP bullet (line 64) and the VS Code command bullet (line 65) remaining. Preserve the blank line separator above `## Delegation Contract`.
  - Acceptance: line 66 is removed; lines 64 and 65 remain unchanged; the section ends with the VS Code command bullet followed by a blank line and then `## Delegation Contract`.

- [x] [P3-T2] Verify post-edit. Run `git grep -n -E "scripts/dev_tools|poetry run python" -- ".claude/skills/execute-hard-lock/SKILL.md"` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p3-execute-hard-lock-grep.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Output Summary must show zero matches.
  - Acceptance: artifact records zero matches.

---

### Phase 4 — Part A.2: settings.json Allow-List Expansion

- [x] [P4-T1] Edit `.claude/settings.json` `permissions.allow` array. Insert the seven new entries immediately after the existing `mcp__drmCopilotExtension__resolve_execute_hard_lock_prompt` entry at current line 17 and before the `Agent(atomic-planner)` entry at current line 18. The seven additions, in this order, are:

  ```
  "mcp__drmCopilotExtension__collect_pr_context",
  "mcp__drmCopilotExtension__new_potential_entry",
  "mcp__drmCopilotExtension__new_potential_bug_entry",
  "mcp__drmCopilotExtension__potential_to_issue",
  "mcp__drmCopilotExtension__new_active_feature_folder",
  "mcp__drmCopilotExtension__validate_orchestration_artifacts",
  "mcp__drmCopilotExtension__resolve_atomic_plan_prompt",
  ```

  Insertion is additive only. No existing entry may be removed, reordered, or weakened. JSON formatting (two-space indentation, trailing comma rules) must match the surrounding entries.
  - Acceptance: `.claude/settings.json` is valid JSON; the seven new entries appear in the allow list; the original 5 PoshQC/hard-lock MCP entries, all `Bash(...)` entries, all `Agent(...)` entries, all `Skill(...)` entries, all `Edit(/...)`/`Write(/...)` entries, and the `deny` and `additionalDirectories` blocks are unchanged.

- [x] [P4-T2] Verify allow-list post-state is a strict superset. Run `python -c "import json; pre=json.load(open('docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase4-settings-pre.json')); post=json.load(open('.claude/settings.json')); pre_allow=set(pre['permissions']['allow']); post_allow=set(post['permissions']['allow']); missing=pre_allow-post_allow; added=post_allow-pre_allow; print('MISSING:', sorted(missing)); print('ADDED:', sorted(added)); assert not missing, missing; assert added == {'mcp__drmCopilotExtension__collect_pr_context','mcp__drmCopilotExtension__new_potential_entry','mcp__drmCopilotExtension__new_potential_bug_entry','mcp__drmCopilotExtension__potential_to_issue','mcp__drmCopilotExtension__new_active_feature_folder','mcp__drmCopilotExtension__validate_orchestration_artifacts','mcp__drmCopilotExtension__resolve_atomic_plan_prompt'}, added"`. Capture the pre-edit copy at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/baseline/phase4-settings-pre.json` before P4-T1 and write the verification result to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p4-settings-allow-list-superset.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` enumerating the seven added entries and confirming `MISSING: []`.
  - Acceptance: artifact shows `MISSING: []` and the seven expected `ADDED:` entries.

- [x] [P4-T3] Validate JSON parses. Run `python -c "import json; json.load(open('.claude/settings.json'))"` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p4-settings-json-valid.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: command exits 0.

---

### Phase 5 — Part A.3: Bare Tool-Name Normalization (decision_7)

- [x] [P5-T1] Edit `.claude/skills/atomic-plan-contract/SKILL.md` line 22. Replace the verbatim text `Plans must pass the `validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: <plan-path>` before they can be reported as approved.` with `Plans must pass the `mcp__drmCopilotExtension__validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: <plan-path>` before they can be reported as approved.`
  - Acceptance: line 22 contains the fully-qualified MCP identifier.

- [x] [P5-T2] Edit `.claude/skills/atomic-plan-contract/SKILL.md` line 156. Replace the verbatim text `- run the `validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: <plan-path>`,` with `- run the `mcp__drmCopilotExtension__validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: <plan-path>`,`.
  - Acceptance: line 156 contains the fully-qualified MCP identifier.

- [x] [P5-T3] Edit `.claude/skills/policy-audit-template-usage/SKILL.md` line 18. Replace the verbatim text `- Required template source: the MCP server tool `resolve_policy_audit_template_asset` with asset selector `template`.` with `- Required template source: the MCP server tool `mcp__drmCopilotExtension__resolve_policy_audit_template_asset` with asset selector `template`.`
  - Acceptance: line 18 contains the fully-qualified MCP identifier.

- [x] [P5-T4] Edit `.claude/skills/policy-audit-template-usage/SKILL.md` line 24. Replace the verbatim text `1) Resolve the policy-audit template through the MCP server tool `resolve_policy_audit_template_asset` with asset `template`, then copy the resolved asset to the target location using an ISO-8601 timestamp.` with `1) Resolve the policy-audit template through the MCP server tool `mcp__drmCopilotExtension__resolve_policy_audit_template_asset` with asset `template`, then copy the resolved asset to the target location using an ISO-8601 timestamp.`
  - Acceptance: line 24 contains the fully-qualified MCP identifier.

- [x] [P5-T5] Edit `.claude/skills/policy-audit-template-usage/SKILL.md` line 42. Replace the verbatim text `6) Run the `validate_orchestration_artifacts` MCP tool with `artifact_type: "policy-audit"` and `artifact_path: <path>` and fail closed on any non-zero result.` with `6) Run the `mcp__drmCopilotExtension__validate_orchestration_artifacts` MCP tool with `artifact_type: "policy-audit"` and `artifact_path: <path>` and fail closed on any non-zero result.`
  - Acceptance: line 42 contains the fully-qualified MCP identifier.

- [x] [P5-T6] Verify normalization completeness. Run `git grep -n -E "\\b(validate_orchestration_artifacts|resolve_atomic_plan_prompt|resolve_policy_audit_template_asset)\\b" -- ".claude/skills/atomic-plan-contract/SKILL.md" ".claude/skills/policy-audit-template-usage/SKILL.md" | grep -v "mcp__drmCopilotExtension__"` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p5-bare-tool-names-residual.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (exit code 1 expected when no matches; Output Summary must report `Residual bare tool-name matches: 0`).
  - Acceptance: artifact reports zero residual bare references.

---

### Phase 6 — Part A.4: Cleanup Cross-Verification

- [x] [P6-T1] Run the post-cleanup repo-wide grep for residual local-script references in `.claude/**/*.md`, applying two documented and auditable exclusions: (1) the fallback-subsection line ranges inside `feature-promotion-lifecycle/SKILL.md` (the `### Fallback only — when MCP server is unreachable` subsections inserted by P1-T10/P1-T12), and (2) the whole-file exclusion for `.claude/rules/powershell.md`. The second exclusion is required because `.claude/rules/powershell.md:57` contains the text `- Organize tests to mirror code structure (e.g., \`tests/scripts/dev-tools/ScriptName.Tests.ps1\`).`, which is a test-path layout example in policy documentation, not a runnable script invocation; the file is read-only per the Implementation Strategy Notes and the match is out-of-scope per spec.md "Out of Scope". A path-scoped (whole-file) exclusion is used in preference to narrowing the regex pattern, to keep the grep pattern intact and avoid unintended relaxation of the in-scope detection. Both exclusion classes must be recorded as separate, auditable entries in the Output Summary per the spec.md Edge Cases requirement that exclusions be documented filters, not silent omissions. Run the following command and capture the result at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p6-acceptance-criterion-1-grep.md`:

  ```
  python - <<'PY'
  import re, subprocess, pathlib
  patterns = [
      r"poetry run python -m scripts",
      r"scripts/dev[_-]tools",
      r"scripts\.dev_tools",
      r"\$\{workspaceFolder\}/scripts",
  ]
  combined = "(" + "|".join(patterns) + ")"
  proc = subprocess.run(["git", "grep", "-n", "-E", combined, "--", ".claude/**/*.md"], capture_output=True, text=True)
  matches = [l for l in proc.stdout.splitlines() if l]
  # Documented exclusion class #1: explicit fallback subsection line ranges in feature-promotion-lifecycle/SKILL.md.
  fp = pathlib.Path(".claude/skills/feature-promotion-lifecycle/SKILL.md")
  text = fp.read_text(encoding="utf-8").splitlines()
  fallback_ranges = []
  start = None
  for i, line in enumerate(text, start=1):
      if line.strip() == "### Fallback only — when MCP server is unreachable":
          start = i
      elif start is not None and line.startswith("## ") and i > start:
          fallback_ranges.append((start, i - 1))
          start = None
  if start is not None:
      fallback_ranges.append((start, len(text)))
  def in_fallback(file_path, line_no):
      if file_path != str(fp).replace("\\", "/"):
          return False
      return any(lo <= line_no <= hi for lo, hi in fallback_ranges)
  # Documented exclusion class #2: path-scoped (whole-file) exclusion for read-only policy
  # documentation files whose matches are layout/structure examples, not script invocations.
  # Each entry is (path, rationale).
  excluded_documentation_paths = {
      ".claude/rules/powershell.md": (
          "Read-only policy rule file; matched text at line 57 is a test-path layout example "
          "(`tests/scripts/dev-tools/ScriptName.Tests.ps1`), not a runnable script invocation; "
          "out-of-scope per spec.md \"Out of Scope\"."
      ),
  }
  def in_excluded_documentation_path(file_path):
      return file_path in excluded_documentation_paths
  filtered = []
  for m in matches:
      parts = m.split(":", 2)
      if len(parts) < 3:
          continue
      file_path, line_no_str = parts[0].replace("\\", "/"), parts[1]
      try:
          line_no = int(line_no_str)
      except ValueError:
          continue
      if in_fallback(file_path, line_no):
          continue
      if in_excluded_documentation_path(file_path):
          continue
      filtered.append(m)
  print("EXCLUDED_FALLBACK_RANGES:", fallback_ranges)
  print("EXCLUDED_DOCUMENTATION_PATHS:", excluded_documentation_paths)
  print("RESIDUAL_PRIMARY_SURFACE_MATCHES:", len(filtered))
  for f in filtered:
      print(f)
  raise SystemExit(0 if len(filtered) == 0 else 1)
  PY
  ```

  The artifact MUST contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` section that explicitly states each of the following as a separate, labeled entry:
  - `EXCLUDED_FALLBACK_RANGES`: the documented fallback-subsection line ranges in `feature-promotion-lifecycle/SKILL.md` that were excluded (file path + each line range).
  - `EXCLUDED_DOCUMENTATION_PATHS`: the documented whole-file exclusions for read-only policy documentation, which must include `.claude/rules/powershell.md` with the rationale stated above (test-path layout example, not a script invocation; out-of-scope per spec.md).
  - `RESIDUAL_PRIMARY_SURFACE_MATCHES: 0`: the residual count outside both exclusion classes.
  - Acceptance: artifact reports `RESIDUAL_PRIMARY_SURFACE_MATCHES: 0`; both exclusion classes (`EXCLUDED_FALLBACK_RANGES` and `EXCLUDED_DOCUMENTATION_PATHS`) are recorded as separate, auditable entries with rationales; no exclusion is silent.

- [x] [P6-T2] Run the cross-reference audit for the renamed "Extension-First" framing. Run `git grep -n -i -E "extension-first|Extension-First" -- ".claude/**/*.md" ".github/**/*.md"` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p6-extension-first-cross-references.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. For each match found, the Output Summary must classify it as either: (a) inside the in-scope `feature-promotion-lifecycle/SKILL.md` (must be zero after Phase 1), or (b) external reference requiring a follow-up edit. If any external references exist, P6-T2 stops and remediation tasks must be added to Phase 1 before continuing.
  - Acceptance: artifact records all matches and explicitly confirms zero in-scope-file matches; any external matches are tabulated for triage.

- [x] [P6-T3] Verify every newly-introduced MCP reference resolves to a name in `extensions/drm-copilot/src/repo-automation-tool-names.ts`. Run:

  ```
  python - <<'PY'
  import re, pathlib
  names_text = pathlib.Path("extensions/drm-copilot/src/repo-automation-tool-names.ts").read_text(encoding="utf-8")
  valid = set(re.findall(r'"([a-z_]+)"', names_text))
  files = [
      ".claude/skills/feature-promotion-lifecycle/SKILL.md",
      ".claude/skills/pr-base-branch-merge-base/SKILL.md",
      ".claude/skills/execute-hard-lock/SKILL.md",
      ".claude/skills/atomic-plan-contract/SKILL.md",
      ".claude/skills/policy-audit-template-usage/SKILL.md",
  ]
  missing = []
  for f in files:
      for m in re.finditer(r"mcp__drmCopilotExtension__([a-z_]+)", pathlib.Path(f).read_text(encoding="utf-8")):
          if m.group(1) not in valid:
              missing.append(f"{f}:{m.group(1)}")
  print("UNKNOWN_MCP_REFERENCES:", missing)
  raise SystemExit(0 if not missing else 1)
  PY
  ```

  Capture at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p6-mcp-reference-resolution.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` confirming `UNKNOWN_MCP_REFERENCES: []`.
  - Acceptance: artifact confirms zero unknown references.

---

### Phase 7 — Part B.1: Python Push-Down Module

- [x] [P7-T1] Create `scripts/dev_tools/push_down_claude_customizations.py`. The module must mirror `scripts/dev_tools/push_down_codex_and_agents_customizations.py` (118 lines) line-for-line with the following substitutions and additions:

  - Module docstring states the purpose: publish bundled `.claude` content into a destination workspace, excluding `settings.local.json`.
  - `ARTIFACT_DIRECTORY = "artifacts/claude-customizations"`
  - `MODULE_ENTRY_POINT = "scripts.dev_tools.push_down_claude_customizations"`
  - `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)`
  - `EXCLUDED_RELATIVE_PATHS: tuple[Path, ...] = (Path(".claude/settings.local.json"),)` declared as a module-level constant.
  - The `_passthrough_rewrite(text: str) -> tuple[str, int, int, list[str]]` helper is identical to the Codex variant (returns `(text, 0, 0, [])`).
  - `push_down_customizations(...)` mirrors the Codex variant signature but adds the exclusion. Implementation: enumerate source files via `enumerate_source_files(repo_root, fs, source_root=source_root, root_folders=ROOT_FOLDERS)`, then drop any file whose `relative_to(effective_source)` is in `EXCLUDED_RELATIVE_PATHS`. Pass the filtered list to a thin local copy loop that mirrors the engine's per-file write block. To preserve engine reuse, the new module shall call `push_down_scoped_customizations(...)` with `root_folders=ROOT_FOLDERS, artifact_directory=ARTIFACT_DIRECTORY, rewrite_references=_passthrough_rewrite` exactly as the Codex variant does, AND wrap the supplied `fs` in a small `_ExcludingFileSystem` adapter (declared in this same file, ≤ 30 lines) whose `list_files(root)` filters out paths matching `EXCLUDED_RELATIVE_PATHS` while delegating every other method (`is_dir`, `is_file`, `read_text`, `write_text`, `ensure_dir`) to the wrapped `fs`. The adapter is the concrete seam chosen per the implementation note above; document the rationale in the class docstring.
  - `parse_args(argv)` mirrors the Codex variant verbatim except the description string references `MODULE_ENTRY_POINT` and the `--destination` help text says `Destination workspace root that will receive the copied .claude tree.`
  - `main(argv, *, repo_root=None, fs=None) -> int` mirrors the Codex variant verbatim (resolve repo_root + destination via `resolve_cli_path`, default `fs` to `RealPushDownFileSystem`, call `push_down_customizations(...)`, print `f"Wrote push-down summary artifact to: {summary.artifact_path}"`, return `0`).
  - File length must remain under 200 lines; well under the 500-line repository cap.
  - Every class, function, and method (including the `_ExcludingFileSystem` adapter and `_passthrough_rewrite`) MUST have a docstring per `.claude/rules/self-explanatory-code-commenting.md`. Loops MUST have intent comments.
  - Acceptance: file exists at the stated path with the substitutions and adapter; `from scripts.dev_tools.push_down_claude_customizations import main, push_down_customizations, parse_args, ROOT_FOLDERS, ARTIFACT_DIRECTORY, EXCLUDED_RELATIVE_PATHS` succeeds.

---

### Phase 8 — Part B.2: Python Tests for the Push-Down Module

- [x] [P8-T1] Create `tests/scripts/dev_tools/test_push_down_claude_customizations.py`. Mirror `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` (297 lines) for parity, with these scenarios:
  - `RecordingFileSystem` and `MemoryFile` helpers identical to the Codex variant (re-declared locally; do not import test internals from the Codex test file).
  - `_load_module()` imports `scripts.dev_tools.push_down_claude_customizations`.
  - `test_module_exposes_claude_root_folders_and_artifact_directory()` asserts `module.ROOT_FOLDERS == (Path(".claude"),)` and `module.ARTIFACT_DIRECTORY == "artifacts/claude-customizations"` and `module.MODULE_ENTRY_POINT == "scripts.dev_tools.push_down_claude_customizations"`.
  - `test_passthrough_rewrite_returns_text_unchanged()` asserts `module._passthrough_rewrite("anything") == ("anything", 0, 0, [])`.
  - `test_push_down_customizations_copies_claude_tree_files()` populates a synthetic `.claude/` tree containing at least: `.claude/agents/orchestrator.md`, `.claude/skills/sample/SKILL.md`, `.claude/rules/python.md`, `.claude/hooks/validate-bash.ps1`, `.claude/settings.json`, `.claude/commands/sample.md`. Asserts the destination receives every file with byte-identical content.
  - `test_push_down_customizations_excludes_settings_local_json()` populates the source with both `.claude/settings.json` and `.claude/settings.local.json`. Asserts the destination receives `.claude/settings.json` but does NOT contain `.claude/settings.local.json` (per spec.md Edge Cases). Also asserts `summary.files` does not include `.claude/settings.local.json`.
  - `test_push_down_customizations_writes_claude_artifact()` asserts the artifact path contains `artifacts/claude-customizations/push-down-` and that the JSON payload reports `rewritten_reference_count=0`, `placeholder_rewrite_count=0`, `unmatched_references=[]` per the passthrough contract.
  - `test_main_prints_summary_artifact_path_for_claude_scope()` asserts the CLI prints `Wrote push-down summary artifact to: ` followed by a path containing `artifacts/claude-customizations/push-down-`.
  - `test_parse_args_requires_destination()` asserts `parse_args([])` raises `SystemExit`.
  - `test_parse_args_returns_destination_value()` asserts `parse_args(["--destination", "/tmp/dest"]).destination == "/tmp/dest"`.
  - `test_bundled_module_imports_without_repo_root_scripts_package(monkeypatch)` mirrors the Codex variant and exercises the bundled `dev_tools.push_down_claude_customizations` import path.
  - All tests follow Arrange–Act–Assert; each test has a docstring; no temp files; no external network/filesystem; assertions use clear messages.
  - Acceptance: file exists; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py -v` passes with all listed tests present.

- [x] [P8-T2] Create `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` mirroring `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`. Contract tests:
  - `BUNDLED_ROOT = REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"` (per parity with the Codex contracts test path).
  - `SCOPED_ROOTS: tuple[Path, ...] = (Path(".claude"),)`
  - `REQUIRED_BUNDLED_FILES` includes representative anchors: `.claude/settings.json`, `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/policy-audit-template-usage/SKILL.md`, `.claude/skills/execute-hard-lock/SKILL.md`, `.claude/skills/pr-base-branch-merge-base/SKILL.md`, `.claude/rules/python.md`, `.claude/rules/typescript.md`, `.claude/agents/orchestrator.md` (presence pending the bundling step in Phase 9; this test is expected to FAIL until that bundling step lands; tag this contract test set as `[expect-fail]` until Phase 9 completes).
  - `test_bundled_claude_payload_contains_required_runtime_files()` enumerates `BUNDLED_ROOT` and asserts every entry in `REQUIRED_BUNDLED_FILES` is present.
  - `test_bundled_claude_payload_contains_all_repo_runtime_contracts()` asserts every file under repo `.claude/` (except `.claude/settings.local.json`) is present and byte-identical in the bundled payload.
  - `test_bundled_claude_payload_excludes_settings_local_json()` asserts `(BUNDLED_ROOT / ".claude" / "settings.local.json").exists() is False`.
  - Acceptance: file exists with the listed tests; tests in this file are tagged `[expect-fail]` per the atomic plan contract until Phase 9 lands the bundled copy. Phase 11 final QA will re-verify they pass.

- [x] [P8-T3] Run targeted Python QA loop on the new module and tests. Execute the toolchain in order and capture each step:
  - Format: `poetry run black scripts/dev_tools/push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  - Lint: `poetry run ruff check scripts/dev_tools/push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  - Type check: `poetry run pyright scripts/dev_tools/push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_customizations.py`
  - Test (excluding the expect-fail contract suite): `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py --cov=scripts.dev_tools.push_down_claude_customizations --cov-report=term-missing`
  - Restart from format if any step changes files or fails.
  - Capture at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p8-python-targeted-qa.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each step. The test step's Output Summary must include the numeric coverage value for `scripts/dev_tools/push_down_claude_customizations.py` and assert it is >= 90%.
  - Acceptance: all four steps complete in a single pass; coverage on the new module is >= 90%.

---

### Phase 9 — Part B.3: Bundled Extension Copy of the Push-Down Script

- [x] [P9-T1] Copy `scripts/dev_tools/push_down_claude_customizations.py` to `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`. The copy must be byte-identical to the source. Use a deterministic copy command (e.g. `python -c "import shutil; shutil.copyfile('scripts/dev_tools/push_down_claude_customizations.py', 'extensions/drm-copilot/resources/templates/push_down_claude_customizations.py')"`).
  - Acceptance: target file exists; SHA-256 of source equals SHA-256 of bundled copy.

- [x] [P9-T2] Copy `scripts/dev_tools/push_down_claude_customizations.py` to `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py`. The copy must be byte-identical to the source. Use the same deterministic copy command pattern as P9-T1.
  - Acceptance: target file exists; SHA-256 of source equals SHA-256 of both bundled copies.

- [x] [P9-T3] Verify bundled copies via SHA-256 hash check; sums={f: hashlib.sha256(open(f,'rb').read()).hexdigest() for f in ['scripts/dev_tools/push_down_claude_customizations.py','extensions/drm-copilot/resources/templates/push_down_claude_customizations.py','extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py']}; print(sums); assert len(set(sums.values()))==1, sums"` and capture evidence at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p9-bundled-copy-byte-identical.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` listing the three identical SHA-256 values.
  - Acceptance: artifact records three matching SHA-256 hashes.

---

### Phase 10 — Part B.4: TypeScript Plumbing — Tool Name, Input Resolver, Tool Definitions

- [x] [P10-T1] Edit `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
  - Acceptance: array contains 19 entries; new entry is in canonical alphabetical neighborhood with the other push-down tools.

- [x] [P10-T2] Edit `extensions/drm-copilot/src/mcp-tool-inputs.ts`. Add `resolvePushDownClaudeCustomizationsToolInput`.

  ```ts
  export function resolvePushDownClaudeCustomizationsToolInput(
    rawInput: unknown,
    fallbackWorkspaceRoot?: string,
  ): WorkspaceToolInput {
    const args = asToolArgumentObject(rawInput);
    return {
      workspaceRoot: normalizeWorkspaceRoot(
        args["workspace_root"],
        fallbackWorkspaceRoot,
      ),
    };
  }
  ```
  - Acceptance: function exported with the exact signature; mirrors the Codex variant.

- [x] [P10-T3] Edit `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`. Add `push_down_claude_customizations` definition.

  ```ts
  {
    name: "push_down_claude_customizations",
    description:
      "Copy the bundled Claude customization payload (.claude tree, excluding settings.local.json) into the target workspace.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
      },
      additionalProperties: false,
    },
  },
  ```
  - Acceptance: new definition appears in `REPO_AUTOMATION_TOOL_DEFINITIONS`; ordering follows the existing push-down neighbors.

- [x] [P10-T4] Edit `extensions/drm-copilot/src/mcp-tool-definitions.ts`. Add `push_down_claude_customizations` entry.
  - Acceptance: both definition files contain the new entry; `name` is identical in both.

---

### Phase 11 — Part B.4: TypeScript Plumbing — Service Method, Handler, Dispatch

- [x] [P11-T1] Edit `extensions/drm-copilot/src/repo-automation-service.ts`. Add `pushDownClaudeCustomizations`.

  ```ts
  async pushDownClaudeCustomizations(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "push_down_claude_customizations",
      runtimeKind: "python",
      bundledRelativePath:
        "resources/templates/push_down_claude_customizations.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "push_down_claude_customizations",
      args: ["--destination", input.workspaceRoot],
      summary:
        "Pushed bundled Claude customizations into the destination workspace.",
      stdoutArtifactPattern: /Wrote push-down summary artifact to:\s*(.+)/i,
    });
  }
  ```
  - Acceptance: method exists with the exact signature and body; `tool` matches the canonical name added in P10-T1.

- [x] [P11-T2] Edit `extensions/drm-copilot/src/mcp-handlers/push-down-handlers.ts`. Add `handlePushDownClaudeCustomizations`.

  ```ts
  export async function handlePushDownClaudeCustomizations(
    rawInput: unknown,
    service: RepoAutomationService,
  ): Promise<RepoAutomationExecutionResult> {
    const input = resolvePushDownClaudeCustomizationsToolInput(rawInput);
    return service.pushDownClaudeCustomizations(input);
  }
  ```
  - Acceptance: file exports the new handler; imports are grouped correctly.

- [x] [P11-T3] Edit `extensions/drm-copilot/src/mcp-tools.ts`. Add new case for `push_down_claude_customizations`.

  ```ts
  case "push_down_claude_customizations": {
    return toMcpToolResult(
      await handlePushDownClaudeCustomizations(rawInput, service),
    );
  }
  ```
  - Acceptance: switch statement handles the new tool name; TypeScript exhaustiveness check passes.

---

### Phase 12 — Part B.5: TypeScript Tests (Handler, Service, Tool Registration)

- [x] [P12-T1] Create `extensions/drm-copilot/test/repo-automation-service.push-down-claude.test.ts`. Mirror existing service tests for the Codex push-down (locate parity in `extensions/drm-copilot/test/repo-automation-service.test.ts` for the Codex/Copilot push-down assertions). Tests:
  - `pushDownClaudeCustomizations invokes executeScript with the correct tool, runtimeKind, bundledRelativePath, args, summary, and stdoutArtifactPattern`. Assert via Jest `expect(mock).toHaveBeenCalledWith(expect.objectContaining({ tool: "push_down_claude_customizations", runtimeKind: "python", bundledRelativePath: "resources/templates/push_down_claude_customizations.py", args: ["--destination", workspaceRoot] }))`.
  - `pushDownClaudeCustomizations defaults invocationId to "push_down_claude_customizations" when omitted from input`.
  - `pushDownClaudeCustomizations forwards an explicit invocationId when provided`.
  - Use Arrange–Act–Assert structure. Mock `executeScript` via `jest.spyOn`. Reset mocks in `afterEach`.
  - Acceptance: file exists; tests pass when run via `npm --prefix extensions/drm-copilot run test:unit -- repo-automation-service.push-down-claude.test.ts`.

- [x] [P12-T2] Create `extensions/drm-copilot/test/push-down-claude-handler.test.ts`. Tests:
  - `handlePushDownClaudeCustomizations resolves input via resolvePushDownClaudeCustomizationsToolInput and calls service.pushDownClaudeCustomizations exactly once with the resolved input`.
  - `handlePushDownClaudeCustomizations propagates rejection when the resolver throws on missing workspace_root`.
  - Acceptance: file exists; tests pass.

- [x] [P12-T3] Edit `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` (or create `extensions/drm-copilot/test/mcp-tool-inputs.push-down-claude.test.ts` if the existing file is at risk of exceeding the 500-line cap). Tests:
  - `resolvePushDownClaudeCustomizationsToolInput returns workspaceRoot from "workspace_root" arg`.
  - `resolvePushDownClaudeCustomizationsToolInput falls back to fallbackWorkspaceRoot when workspace_root is omitted`.
  - `resolvePushDownClaudeCustomizationsToolInput throws when rawInput is not an object`.
  - Acceptance: file contains the three new tests; tests pass.

- [x] [P12-T4] Edit `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts`. Add a test asserting `REPO_AUTOMATION_TOOL_DEFINITIONS` contains a definition with `name === "push_down_claude_customizations"` whose `inputSchema.properties.workspace_root` is defined and `additionalProperties === false`.
  - Acceptance: new test passes; existing tests still pass.

- [x] [P12-T5] Edit `extensions/drm-copilot/test/repo-automation-dispatch.test.ts`. Add a test asserting `dispatchRepoAutomationTool("push_down_claude_customizations", { workspace_root: "/dest" }, mockService)` invokes `mockService.pushDownClaudeCustomizations` exactly once and returns a successful `RepoAutomationMcpToolResult` with `tool === "push_down_claude_customizations"`.
  - Acceptance: new test passes; existing tests still pass.

- [x] [P12-T6] Run targeted TypeScript QA loop on the new files. Execute in order and capture each step at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p12-typescript-targeted-qa.md`:
  - Format: `npm --prefix extensions/drm-copilot run format`
  - Lint: `npm --prefix extensions/drm-copilot run lint`
  - Type check: `npm --prefix extensions/drm-copilot run typecheck`
  - Test (coverage): `npm --prefix extensions/drm-copilot run test:unit -- --coverage --collectCoverageFrom=src/mcp-handlers/push-down-handlers.ts --collectCoverageFrom=src/repo-automation-service.ts --collectCoverageFrom=src/mcp-tool-inputs.ts`
  - Restart from format if any step changes files or fails.
  - Acceptance: all four steps complete in a single pass; coverage on the new handler, the new service method, and the new resolver each report >= 90%.

---

### Phase 13 — Part B.6: VS Code Command Wiring

- [x] [P13-T1] Edit `extensions/drm-copilot/package.json` `contributes.commands` array. Add a new command entry immediately after the `drmCopilotExtension.pushDownCodexAndAgentsCustomizations` entry at lines 61–64 and before the `drmCopilotExtension.syncAgentsFromInstructions` entry at line 65. Entry:

  ```json
  {
    "command": "drmCopilotExtension.pushDownClaudeCustomizations",
    "title": "drm-copilot: Push Down Claude Customizations"
  },
  ```
  - Acceptance: package.json is valid JSON; the new command appears in the array adjacent to the existing push-down entries.

- [x] [P13-T2] Edit `extensions/drm-copilot/src/extension.ts`. Insert a new `vscode.commands.registerCommand` block immediately after the `pushDownCodexAndAgentsCustomizationsDisposable` declaration at lines 193–204 and before `syncAgentsFromInstructionsDisposable` at line 206. Insertion:

  ```ts
  const pushDownClaudeCustomizationsDisposable =
    vscode.commands.registerCommand(
      "drmCopilotExtension.pushDownClaudeCustomizations",
      async () => {
        const commandId = "drmCopilotExtension.pushDownClaudeCustomizations";
        await service.pushDownClaudeCustomizations({
          workspaceRoot: getWorkspaceRoot(),
          invocationId: commandId,
        });
      },
    );
  ```

  Then update the disposables aggregation block at lines 639–640 to include `pushDownClaudeCustomizationsDisposable` in the same neighborhood as the existing push-down disposables.
  - Acceptance: command is registered and added to the disposable list; TypeScript compiles.

- [x] [P13-T3] Create `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts`. Mirror the existing extension command registration tests for the Codex push-down. Tests:
  - The command `drmCopilotExtension.pushDownClaudeCustomizations` is registered when `activate()` runs.
  - Invoking the registered command calls `service.pushDownClaudeCustomizations` with the workspace root resolved from `getWorkspaceRoot()` and `invocationId === "drmCopilotExtension.pushDownClaudeCustomizations"`.
  - Acceptance: tests pass.

- [x] [P13-T4] Validate package.json. Run `python -c "import json; json.load(open('extensions/drm-copilot/package.json'))"` and write evidence to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p13-package-json-valid.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: command exits 0.

---

### Phase 15 — Part C: Update orchestrate skill

- [x] [P15-T1] Add `## Pre-Feature-Review Commit` section to `.claude/skills/orchestrate/SKILL.md`. Insert the new section between the existing `## Completion Requirements` section and the existing `## Step 6 Delegation — Prohibited Prompt Language` section. Content to insert verbatim:

  ```
  ## Pre-Feature-Review Commit

  Before delegating to the `feature-review` subagent, the orchestrator must:

  1. Stage all modified and new files: `git add -A`.
  2. Invoke the `commit-message` skill to generate a conventional commit message from the staged diff.
  3. Commit using the generated message: `git commit -m "<generated message>"`.
  4. Only after a successful commit may the orchestrator proceed to the `feature-review` delegation.

  The review subagent compares against a base branch; uncommitted changes are invisible to the diff tool and cannot be audited.
  ```
  - Acceptance: section heading `## Pre-Feature-Review Commit` appears in `.claude/skills/orchestrate/SKILL.md` between `## Completion Requirements` and `## Step 6 Delegation — Prohibited Prompt Language`; no local-script references (`poetry run python -m scripts`, `scripts/dev[_-]tools`, `scripts\.dev_tools`) and no VS Code command IDs (`drmCopilotExtension.`) are present in the added content.

- [x] [P15-T2] Add `## Post-Review Outcome Evaluation` section to `.claude/skills/orchestrate/SKILL.md`. Insert the new section immediately after `## Pre-Feature-Review Commit`. Content to insert verbatim:

  ```
  ## Post-Review Outcome Evaluation

  After each `feature-review` delegation returns:

  1. Locate `remediation-inputs.<timestamp>.md` in the active feature folder (match the highest ISO-8601 timestamp).
  2. If no such file exists, treat as zero blocking findings and advance to the PR creation gate.
  3. If the file exists, count lines matching `BLOCKING` or `Severity: Blocking` (case-sensitive). If count >= 1, enter the remediation loop. If count = 0, advance to the PR creation gate.
  ```
  - Acceptance: section heading `## Post-Review Outcome Evaluation` appears immediately after `## Pre-Feature-Review Commit`; no local-script references; no VS Code command IDs in the added content.

- [x] [P15-T3] Add `## Remediation Loop (R1–R5)` section to `.claude/skills/orchestrate/SKILL.md`. Insert immediately after `## Post-Review Outcome Evaluation`. Content to insert verbatim:

  ```
  ## Remediation Loop (R1–R5)

  A bounded loop consisting of five steps. The loop variable `remediation_pass` starts at 1 and increments at R5 before returning to R1.

  - **R1 — Remediation planning:** Delegate to `atomic-planner` with `remediation-inputs.<timestamp>.md` path as primary context. Receive `remediation-plan.<timestamp>.md` in the active feature folder.
  - **R2 — Preflight clearance:** Delegate to `atomic-executor` for precondition validation only (no implementation). If the executor does not return `PREFLIGHT: ALL CLEAR`, return to R1 and re-delegate to `atomic-planner` with the required-changes output from the executor. Only after `PREFLIGHT: ALL CLEAR` may the orchestrator advance to R3.
  - **R3 — Remediation execution:** Delegate to `atomic-executor` with full execution authorization. Each task's toolchain loop (format → lint → type-check → test) is mandatory; no skipping.
  - **Pre-R4 commit:** Stage all changes (`git add -A`), invoke the `commit-message` skill to generate a commit message from the staged diff, commit with the generated message. Advance to R4 only after a successful commit.
  - **R4 — Re-audit:** Delegate to `feature-review` with the same inputs as the original review (resolved base branch, feature folder, refreshed PR context artifacts, acceptance-criteria source). No scope narrowing. The canonical issue number line must be included.
  - **R5 — Loop-exit decision:** If the re-audit produces zero blocking findings, exit the loop and advance to the PR creation gate. Otherwise, record `remediation_pass` increment in the checkpoint and return to R1.

  **Termination guard:** If `remediation_pass` reaches 3 without resolution, the orchestrator records `step6_status: "blocked_remediation_loop_limit"` in the checkpoint and halts. No further automation is attempted.
  ```
  - Acceptance: section heading `## Remediation Loop (R1–R5)` appears immediately after `## Post-Review Outcome Evaluation`; no local-script references; no VS Code command IDs in the added content.

- [x] [P15-T4] Add `## Issue Number Consistency` section to `.claude/skills/orchestrate/SKILL.md`. Insert immediately after `## Remediation Loop (R1–R5)`. Content to insert verbatim:

  ```
  ## Issue Number Consistency

  The canonical issue number is derived once from the active feature folder name: extract the trailing integer from the folder base name (e.g., `2026-04-26-push-down-claude-customizations-162` yields `162`). Record as `issue_num` in the checkpoint.

  Every delegation prompt to `atomic-planner`, `atomic-executor`, and `feature-review` must include the line:

  > `Canonical issue number for this feature is <issue_num>. All artifact content, file paths, and cross-references must use this number.`

  If a subagent artifact references a different issue number, the orchestrator rejects it, requests correction, and records the discrepancy under `artifact_errors` in the checkpoint.
  ```
  - Acceptance: section heading `## Issue Number Consistency` appears immediately after `## Remediation Loop (R1–R5)`; no local-script references; no VS Code command IDs in the added content.

- [x] [P15-T5] Add `## PR Creation Gate` section to `.claude/skills/orchestrate/SKILL.md`. Insert immediately after `## Issue Number Consistency`. Content to insert verbatim:

  ```
  ## PR Creation Gate

  The orchestrator must not create a PR, push a branch for PR purposes, or report work complete until all four conditions are simultaneously true:

  1. `blocking_findings_resolved: true` — the most recent `feature-review` produced zero blocking findings.
  2. The AC verification artifact (`p14-acceptance-criteria-checkoff.md` or equivalent) confirms all acceptance criteria pass.
  3. The mandatory toolchain passed in its most recent run on the branch (no linting/type-check/test failures).
  4. The checkpoint `next_step` is `S8_create_pr`.

  This gate is non-negotiable. Each condition is independently verified before PR creation proceeds.
  ```
  - Acceptance: section heading `## PR Creation Gate` appears immediately after `## Issue Number Consistency`; no local-script references; no VS Code command IDs in the added content.

- [x] [P15-T6] Verify orchestrate skill content integrity. Run a grep to confirm the updated `.claude/skills/orchestrate/SKILL.md` contains zero lines matching local-script patterns and zero lines matching VS Code command ID patterns. Run:

  ```
  python - <<'PY'
  import re, pathlib
  text = pathlib.Path(".claude/skills/orchestrate/SKILL.md").read_text(encoding="utf-8")
  script_patterns = [r"poetry run python -m scripts", r"scripts/dev[_-]tools", r"scripts\.dev_tools"]
  vscode_pattern = r"drmCopilotExtension\."
  script_hits = [l for l in text.splitlines() if any(re.search(p, l) for p in script_patterns)]
  vscode_hits = [l for l in text.splitlines() if re.search(vscode_pattern, l)]
  print("SCRIPT_REFERENCE_HITS:", script_hits)
  print("VSCODE_COMMAND_HITS:", vscode_hits)
  raise SystemExit(0 if not script_hits and not vscode_hits else 1)
  PY
  ```

  Write the result to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p15-orchestrate-skill-content-integrity.md` with `Timestamp:`, `Command:` (grep patterns used), `EXIT_CODE:`, `Output Summary:`, `Verdict:`.
  - Acceptance: artifact exists; `SCRIPT_REFERENCE_HITS: []` (zero local-script pattern hits in the file); `VSCODE_COMMAND_HITS: []` (zero VS Code command ID hits in the file); `Verdict: PASS`.

- [x] [P15-T7] Capture orchestrate skill diff against baseline. Run `git diff -- .claude/skills/orchestrate/SKILL.md` and write the output to `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p15-orchestrate-skill-diff.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (number of lines added, brief description of each added section by name).
  - Acceptance: artifact exists; diff shows additions only (no deletions from any line present in the baseline captured by P0-T13); Output Summary describes the 5 new sections added: `Pre-Feature-Review Commit`, `Post-Review Outcome Evaluation`, `Remediation Loop (R1–R5)`, `Issue Number Consistency`, `PR Creation Gate`.

---

### Phase 14 — Final QA, Coverage, and Acceptance Criteria Verification

- [x] [P14-T1] Run the Python QA loop end-to-end across the full repository in single-pass form. Execute in order, capturing each step's output:
  - Format: `poetry run black .`
  - Lint: `poetry run ruff check .`
  - Type check: `poetry run pyright`
  - Test+coverage: `poetry run pytest --cov --cov-report=term-missing`

  If any step changes files or fails, restart from `poetry run black .` and continue until a single pass completes cleanly. Capture each step at:
  - `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-python-format.md`
  - `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-python-lint.md`
  - `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-python-typecheck.md`
  - `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-python-test-coverage.md`

  Each artifact MUST contain `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. The test artifact's Output Summary MUST include the numeric repository-wide line coverage value and the numeric coverage value for `scripts/dev_tools/push_down_claude_customizations.py`.
  - Acceptance: all four steps exit 0 in a single pass; repository-wide coverage >= 80%; new module coverage >= 90%.

- [x] [P14-T2] Run the TypeScript QA loop end-to-end across the extension. Execute in order:
  - Format: `npm --prefix extensions/drm-copilot run format`
  - Lint: `npm --prefix extensions/drm-copilot run lint`
  - Type check: `npm --prefix extensions/drm-copilot run typecheck`
  - Test+coverage: `npm --prefix extensions/drm-copilot run test:unit -- --coverage`

  Restart from format if any step fails or changes files. Capture each step at:
  - `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-typescript-format.md`
  - `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-typescript-lint.md`
  - `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-typescript-typecheck.md`
  - `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-typescript-test-coverage.md`

  Each artifact MUST contain `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. The test artifact's Output Summary MUST include numeric line coverage for the extension overall and for the three changed files (`src/mcp-handlers/push-down-handlers.ts`, `src/repo-automation-service.ts`, `src/mcp-tool-inputs.ts`).
  - Acceptance: all four steps exit 0 in a single pass; extension-wide coverage >= 80%; coverage for each changed file >= 90% (no regression on changed lines).

- [x] [P14-T3] Compute coverage delta and threshold verification. Compare:
  - Python repo-wide baseline coverage from `phase0-python-test-coverage.md` versus post-change from `p14-python-test-coverage.md`.
  - TypeScript extension baseline coverage from `phase0-typescript-test-coverage.md` versus post-change from `p14-typescript-test-coverage.md`.
  - New-module coverage for `scripts/dev_tools/push_down_claude_customizations.py` from `p14-python-test-coverage.md`.
  - New-file coverage for `src/mcp-handlers/push-down-handlers.ts` (handler portion only), `src/repo-automation-service.ts` (delta on the new method), and `src/mcp-tool-inputs.ts` (delta on the new resolver).

  Write the comparison artifact at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-coverage-delta.md` with `Timestamp:`, `Command:` (the comparison procedure), `EXIT_CODE:`, `Output Summary:` containing all baseline, post-change, and new-code coverage values explicitly. Verdict MUST be `PASS` only if all three thresholds hold (>= 80% repo-wide, >= 90% new module, no regression on changed lines).
  - Acceptance: artifact records numeric values for every threshold and a non-placeholder verdict.

- [x] [P14-T4] Run the validator on this plan. Run the `mcp__drmCopilotExtension__validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: "docs/features/active/2026-04-26-push-down-claude-customizations-162/plan.2026-04-26T13-49.md"`. Capture the validator output at `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-plan-validator.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: validator exits 0; artifact records `validate_orchestration_artifacts: ok`.

- [x] [P14-T5] Verify each of the 19 acceptance criteria in `spec.md` (original 12 plus the 7 Part C criteria) against the on-disk evidence. Produce `docs/features/active/2026-04-26-push-down-claude-customizations-162/evidence/qa-gates/p14-acceptance-criteria-checkoff.md` with one row per AC. Each row MUST cite the supporting evidence artifact path. Mapping:
  1. Zero local-script references in `.claude/**/*.md` (primary surface) → `p6-acceptance-criterion-1-grep.md`.
  2. Every replaced reference points at an MCP tool present in `repo-automation-tool-names.ts` → `p6-mcp-reference-resolution.md`.
  3. `.claude/settings.json` allow list includes the seven new entries → `p4-settings-allow-list-superset.md`.
  4. `feature-promotion-lifecycle/SKILL.md` MCP-first reframing complete → `p1-feature-promotion-lifecycle-diff.md` plus `p6-extension-first-cross-references.md`.
  5. `atomic-plan-contract/SKILL.md` and `policy-audit-template-usage/SKILL.md` use fully-qualified MCP names → `p5-bare-tool-names-residual.md`.
  6. New Python push-down module exists, runs end-to-end, copies the `.claude/` tree except `settings.local.json`, writes summary artifact under `artifacts/claude-customizations/` → `p8-python-targeted-qa.md` and the test names `test_push_down_customizations_excludes_settings_local_json`, `test_push_down_customizations_writes_claude_artifact`.
  7. Bundled extension copies present → `p9-bundled-copy-byte-identical.md`.
  8. Extension exposes the VS Code command and the MCP tool → `p13-package-json-valid.md` and the test names from P12-T4 (tool registration) and P13-T3 (command registration).
  9. Parity Python tests exist → `p8-python-targeted-qa.md`.
  10. Parity TypeScript tests exist → `p12-typescript-targeted-qa.md`.
  11. Repository-wide coverage >= 80%; new modules >= 90% → `p14-coverage-delta.md`.
  12. Single-pass toolchain for both languages → `p14-python-*` and `p14-typescript-*`.
  13. `.claude/skills/orchestrate/SKILL.md` is present in the `.claude/skills/` tree and is included in the push-down output → `p9-bundled-copy-byte-identical.md` (orchestrate directory is included in the `.claude/` tree copy) and `p15-orchestrate-skill-diff.md` (skill file updated with Part C sections).
  14. Orchestrate skill implements checkpoint resumption from `artifacts/orchestration/orchestrator-state.json` → `p15-orchestrate-skill-diff.md` (Checkpoint Handling section present in final file).
  15. Remediation loop terminates after at most 3 full iterations, records `step6_status: "blocked_remediation_loop_limit"` when limit reached → `p15-orchestrate-skill-diff.md` (Termination guard content present in Remediation Loop section).
  16. PR creation gate requires all four conditions simultaneously true before PR creation → `p15-orchestrate-skill-diff.md` (PR Creation Gate section with four conditions present).
  17. Every delegation prompt includes canonical issue number derived from active feature folder name → `p15-orchestrate-skill-diff.md` (Issue Number Consistency section present with derivation rule and injection line).
  18. Feature-review delegation contains none of the four prohibited prompt language categories → `p15-orchestrate-skill-diff.md` (Step 6 Delegation — Prohibited Prompt Language section retained in final file).
  19. Pre-feature-review commit step is present in orchestrate skill (stage, invoke commit-message skill, commit) → `p15-orchestrate-skill-diff.md` (Pre-Feature-Review Commit section present).

  Each row MUST be marked `PASS` only when the cited evidence supports the claim; otherwise `FAIL` with a remediation pointer.
  - Acceptance: all 19 rows marked `PASS`; artifact stored at the cited path.

---

## Test Plan

- **Unit (Python):** `tests/scripts/dev_tools/test_push_down_claude_customizations.py` covers ROOT_FOLDERS injection, ARTIFACT_DIRECTORY, passthrough rewrite, settings.local.json exclusion, summary artifact path generation, CLI parse_args, CLI main, and bundled-import resilience. Coverage target on the new module: >= 90%.
- **Contract (Python):** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` covers byte-identical bundled payload of `.claude/` minus `settings.local.json`. Tagged `[expect-fail]` until Phase 9 completes; Phase 14 final QA verifies it passes.
- **Unit (TypeScript):** four test files cover the service method, the handler, the input resolver, the tool definition entry, and the dispatch switch case. The extension command registration test covers the new VS Code command. Coverage target on each changed module: >= 90%.
- **Integration:** end-to-end push-down against the in-memory `RecordingFileSystem` double in Python tests; MCP tool registration and command registration assertions in TypeScript tests.
- **Manual/CLI verification:** out of plan scope. Runtime extension activation in VS Code is excluded (no test host).
- **Coverage evidence:**
  - Baselines: `evidence/baseline/phase0-python-test-coverage.md`, `evidence/baseline/phase0-typescript-test-coverage.md`.
  - Post-change: `evidence/qa-gates/p14-python-test-coverage.md`, `evidence/qa-gates/p14-typescript-test-coverage.md`, `evidence/qa-gates/p8-python-targeted-qa.md`, `evidence/qa-gates/p12-typescript-targeted-qa.md`.
  - Comparison: `evidence/qa-gates/p14-coverage-delta.md`.

## Open Questions / Notes

- The Phase 6 grep filter for AC#1 explicitly excludes the line ranges of the `### Fallback only — when MCP server is unreachable` subsections introduced in Phase 1 (P1-T10 and P1-T12). The exclusion is a documented filter implemented in code, not a silent omission, per `spec.md` Edge Cases.
- Phase 8 contract tests are tagged `[expect-fail]` until Phase 9 lands the bundled copies. The tag is removed implicitly when Phase 9 completes; Phase 14 confirms they pass.
- The settings.local.json exclusion seam choice is documented in the Implementation Strategy Notes and is rationalized in the `_ExcludingFileSystem` class docstring per the commenting policy.
- Renaming "extension-first" to "MCP-first" is scoped to `feature-promotion-lifecycle/SKILL.md` only. Phase 6 (P6-T2) audits external `.md` references and surfaces any that require follow-up edits before the plan can be marked complete.
