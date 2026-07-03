# Remediation Plan (R1, Remediation Cycle 2) — two-axis-model-selection (Issue #286)

- Timestamp: 2026-07-03T20-00
- Cycle: 2 (post-PR CI-failure handling)
- Source inputs: `docs/features/active/2026-07-03-two-axis-model-selection-286/remediation-inputs.2026-07-03T20-00.md`
- CI run under remediation: https://github.com/drmoisan/drm-copilot/actions/runs/28685430030 (PR #295, head 51936fc)
- Findings addressed: CI-1 (Blocking), CI-2 (Blocking)
- Scope: additive/textual fixes only. No changes to Python logic, validators, `model_policy`/`model_budget` config, or acceptance criteria.
- Source-of-truth rule: repo-root `.claude/` is authoritative; bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/` is updated in lockstep.

## Feature and Evidence Roots

- FEATURE: `docs/features/active/2026-07-03-two-axis-model-selection-286`
- Baseline evidence: `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/remediation-baseline/`
- QA-gate evidence: `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/qa-gates/`

All evidence artifacts resolve to `<FEATURE>/evidence/<kind>/` per `evidence-and-timestamp-conventions`. No `artifacts/` evidence paths are used.

## Pack-Manifest Governance Finding (CI-2 investigation result)

The pack manifests under `extensions/drm-copilot/resources/claude-customizations/pack-manifests/` are bundle-only and are NOT governed by a repo-root source-of-truth copy or a root-to-bundle parity contract.

- The Python contract test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_pack_manifests_are_outside_the_parity_scope` asserts that `pack-manifests/` lives outside the `.claude/**` parity scope (`SCOPED_ROOTS == (Path(".claude"),)`) and that no `.claude/**` payload path references `pack-manifests`. The manifests are therefore never pushed from a repo-root copy; the bundled files are the sole source of truth.
- The Codex manifest set `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` uses a separate `.agents/`/`.codex/` path namespace and does not reference `.claude/agents/*`. It is unaffected and MUST NOT be edited by this change.

Conclusion: the CI-2 fix is a single edit to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. No lockstep root copy or additional governing contract requires a mirrored update. The authoritative verifier is the CI Jest run (`claude-pack-manifest-completeness.test.ts`), which is not runnable in this local environment.

## Fix Text Reference (CI-1)

Current text matches the forbidden regex `context:\s*fork` because it places `context:` immediately before `fork`. The reworded text describes a skill routed via `fork` with its frontmatter `context` field set to the value `fork`, worded so the `context:`-then-`fork` adjacency does not occur. Tone policy (`.claude/rules/tonality.md`) applies to the reworded prose. Meaning to preserve: a fork-routed skill inherits the parent model and ignores a model override.

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read policy files in the required order (`CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/powershell.md`; `.claude/rules/typescript.md`; `.claude/rules/tonality.md`) and write `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/remediation-baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read. Acceptance: artifact exists with all three fields populated.

- [x] [P0-T2] Capture the baseline (pre-fix) state of the Pester structural guard by running `mcp__drm-copilot__run_poshqc_test` over `tests/scripts/claude-runtime` and write `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/remediation-baseline/pester-baseline.2026-07-03T20-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording that `claude-runtime-structure.Tests.ps1` "requires .claude/skills/orchestrate/SKILL.md to avoid context fork and orchestrator agent routing" currently fails. Acceptance: artifact records the failing baseline result.

- [x] [P0-T3] Capture the baseline `context:\s*fork` match locations by running `pwsh -NoProfile -Command "$f=@('.claude/skills/orchestrate/SKILL.md','.claude/skills/epic-orchestrate/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md'); Select-String -Path $f -Pattern 'context:\s*fork'"` and write `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/remediation-baseline/fork-pattern-baseline.2026-07-03T20-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing the expected pre-fix match lines (orchestrate and epic-orchestrate, repo-root and bundled). Acceptance: artifact records the current match locations.

- [x] [P0-T4] Capture the baseline pack-manifest completeness gap by running `pwsh -NoProfile -Command "$agents = Get-ChildItem 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/*.md' | ForEach-Object Name; $listed = @(); Get-ChildItem 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json' | ForEach-Object { $listed += (Get-Content $_.FullName -Raw | ConvertFrom-Json).paths }; $missing = $agents | Where-Object { ('.claude/agents/' + $_) -notin $listed -and $_ -ne 'pr-author.md' }; 'MISSING: ' + (($missing | Sort-Object) -join ', ')"` and write `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/remediation-baseline/pack-manifest-baseline.2026-07-03T20-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording `MISSING: commit-message.md, human-exception-runbook.md`. Acceptance: artifact records exactly the two missing agent files.

### Phase 1 — CI-1: Reword the Fork Caveat in Skill Files

- [x] [P1-T1] Edit `.claude/skills/orchestrate/SKILL.md` (the `**`fork` caveat.**` sentence, ~line 86) to reword the caveat so the text no longer matches `context:\s*fork`, preserving the meaning that a fork-routed skill inherits the parent model and ignores a model override (describe the skill as routed via `fork` with its frontmatter `context` field set to the value `fork`, avoiding any `context:`-then-`fork` adjacency). Acceptance: the caveat sentence is reworded and conveys the unchanged meaning.

- [x] [P1-T2] Edit `.claude/skills/epic-orchestrate/SKILL.md` (the fork-caveat sentence, ~lines 122–125) to apply the same rewording so the text no longer matches `context:\s*fork`, preserving meaning. Acceptance: the caveat sentence is reworded and conveys the unchanged meaning.

- [x] [P1-T3] Mirror the P1-T1 edit byte-for-byte into `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` so the reworded caveat text is identical to the repo-root file. Acceptance: the reworded caveat sentence in the bundled file is byte-identical to the repo-root file.

- [x] [P1-T4] Mirror the P1-T2 edit byte-for-byte into `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` so the reworded caveat text is identical to the repo-root file. Acceptance: the reworded caveat sentence in the bundled file is byte-identical to the repo-root file.

- [x] [P1-T5] Verify zero `context:\s*fork` matches across all four files by running `pwsh -NoProfile -Command "$f=@('.claude/skills/orchestrate/SKILL.md','.claude/skills/epic-orchestrate/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md'); $m=Select-String -Path $f -Pattern 'context:\s*fork'; if ($m) { $m; exit 1 } else { 'NO MATCHES'; exit 0 }"`. Acceptance: command prints `NO MATCHES` and exits 0.

- [x] [P1-T6] Confirm byte-identity of the reworded caveat between repo-root and each bundled mirror by running `pwsh -NoProfile -Command "if ((Get-FileHash '.claude/skills/orchestrate/SKILL.md').Hash -ne (Get-FileHash 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md').Hash) { 'ORCHESTRATE MISMATCH'; exit 1 }; if ((Get-FileHash '.claude/skills/epic-orchestrate/SKILL.md').Hash -ne (Get-FileHash 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md').Hash) { 'EPIC MISMATCH'; exit 1 }; 'IDENTICAL'; exit 0"`. Note: full-file hash equality holds only if the repo-root and bundled files were already byte-identical before this change; if they were not, instead confirm the reworded caveat sentence is identical between each repo-root file and its bundled mirror by inspection. Acceptance: reworded caveat text matches between each repo-root/bundled pair.

### Phase 2 — CI-2: Register New Agents in the Core Pack Manifest

- [x] [P2-T1] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` to add `".claude/agents/commit-message.md"` (inserted after `".claude/agents/atomic-planner.md"` and before `".claude/agents/epic-orchestrator.md"`) and `".claude/agents/human-exception-runbook.md"` (inserted after `".claude/agents/feature-review.md"` and before `".claude/agents/orchestrator.md"`), preserving the existing alphabetical ordering and JSON formatting (two-space indentation, trailing comma placement). Do NOT add `".claude/agents/pr-author.md"` (documented pre-existing exception). Do NOT edit any language-specific pack manifest or the Codex manifests. Acceptance: both new agent paths are present in the `paths` array in alphabetical position; `pr-author.md` is not added.

- [x] [P2-T2] Validate that `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` remains well-formed JSON and contains both new entries by running `pwsh -NoProfile -Command "$p=(Get-Content 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json' -Raw | ConvertFrom-Json).paths; if (($p -contains '.claude/agents/commit-message.md') -and ($p -contains '.claude/agents/human-exception-runbook.md') -and ($p -notcontains '.claude/agents/pr-author.md')) { 'OK'; exit 0 } else { 'FAIL'; exit 1 }"`. Acceptance: command prints `OK` and exits 0.

### Phase 3 — Final QA and Closure

- [x] [P3-T1] Run the final Pester QA over `tests/scripts/claude-runtime` via `mcp__drm-copilot__run_poshqc_test` and write `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/qa-gates/pester-final.2026-07-03T20-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` confirming `claude-runtime-structure.Tests.ps1` passes. Acceptance: artifact records a passing Pester result (EXIT_CODE 0).

- [x] [P3-T2] Run the final `context:\s*fork` check `pwsh -NoProfile -Command "$f=@('.claude/skills/orchestrate/SKILL.md','.claude/skills/epic-orchestrate/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md','extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md'); $m=Select-String -Path $f -Pattern 'context:\s*fork'; if ($m) { $m; exit 1 } else { 'NO MATCHES'; exit 0 }"` and write `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/qa-gates/fork-pattern-final.2026-07-03T20-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording zero matches. Acceptance: artifact records zero matches (command prints `NO MATCHES`, exits 0).

- [x] [P3-T3] Run the final deterministic (non-Jest) pack-manifest completeness check `pwsh -NoProfile -Command "$agents = Get-ChildItem 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/*.md' | ForEach-Object Name; $listed = @(); Get-ChildItem 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json' | ForEach-Object { $listed += (Get-Content $_.FullName -Raw | ConvertFrom-Json).paths }; $missing = $agents | Where-Object { ('.claude/agents/' + $_) -notin $listed -and $_ -ne 'pr-author.md' }; if ($missing) { 'MISSING: ' + (($missing | Sort-Object) -join ', '); exit 1 } else { 'MISSING: (none)'; exit 0 }"` and write `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/qa-gates/pack-manifest-final.2026-07-03T20-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording an empty missing set. State in the artifact that authoritative verification is the CI Jest run of `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` on the next push (the TS suite is not runnable locally: no npm/node/node_modules). Acceptance: artifact records an empty missing set and names the authoritative CI Jest verifier.

- [x] [P3-T4] Write the closure-check artifact `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/qa-gates/closure-check.2026-07-03T20-00.md` mapping each finding to its verification: CI-1 → P3-T1 (Pester pass) and P3-T2 (zero `context:\s*fork` matches, repo-root and bundled) with byte-identity confirmed by P1-T6; CI-2 → P2-T2 and P3-T3 (both new agents listed, `pr-author.md` excluded, missing set empty), with the note that the pack-manifest change is consistent with the governance finding (no parity contract requires a lockstep root copy) and that the authoritative CI Jest run executes on the next push against the new head SHA. Acceptance: artifact maps CI-1 and CI-2 to their verification task IDs and states the residual CI-Jest dependency for CI-2.
