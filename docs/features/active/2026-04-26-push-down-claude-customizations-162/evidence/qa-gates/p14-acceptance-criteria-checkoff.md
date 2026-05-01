# P14 Acceptance Criteria Checkoff

**Phase**: 14 — Final QA  
**Timestamp**: 2026-04-27T00:00:00Z

| # | Acceptance Criterion | Status | Evidence |
|---|---------------------|--------|----------|
| 1 | Zero local-script references remain in any `.claude/` markdown file (verified by repo-wide grep) | PASS | `evidence/qa-gates/p6-acceptance-criterion-1-grep.md` |
| 2 | Every replaced reference points at an MCP tool present in `extensions/drm-copilot/src/repo-automation-tool-names.ts` | PASS | `evidence/qa-gates/p6-mcp-reference-resolution.md` |
| 3 | `.claude/settings.json` allow list includes the seven previously-missing MCP tools | PASS | `evidence/qa-gates/p4-settings-allow-list-superset.md` |
| 4 | `feature-promotion-lifecycle/SKILL.md` no longer references VS Code command IDs; it references MCP tools and is reframed as "MCP-first" | PASS | `evidence/qa-gates/p1-feature-promotion-lifecycle-diff.md`, `evidence/qa-gates/p6-extension-first-cross-references.md` |
| 5 | `atomic-plan-contract/SKILL.md` and `policy-audit-template-usage/SKILL.md` use fully-qualified MCP tool names throughout | PASS | `evidence/qa-gates/p5-bare-tool-names-residual.md` |
| 6 | `scripts/dev_tools/push_down_claude_customizations.py` exists, runs end-to-end against in-memory destination, copies `.claude/` tree except `settings.local.json`, writes summary artifact under `artifacts/claude-customizations/` | PASS | `evidence/qa-gates/p8-python-targeted-qa.md`; tests `test_push_down_customizations_excludes_settings_local_json`, `test_push_down_customizations_writes_claude_artifact` all passing |
| 7 | New push-down script is bundled into the extension at `extensions/drm-copilot/resources/templates/` | PASS | `evidence/qa-gates/p9-bundled-copy-byte-identical.md` |
| 8 | Extension exposes `drmCopilotExtension.pushDownClaudeCustomizations` as VS Code command and `push_down_claude_customizations` as MCP tool | PASS | `evidence/qa-gates/p13-package-json-valid.md`; TypeScript tests for MCP tool registration (P12-T4) and command registration (P13-T3) all passing |
| 9 | Parity unit tests exist for the new Python module mirroring those for the Codex/Agents variant | PASS | `evidence/qa-gates/p8-python-targeted-qa.md` |
| 10 | Parity unit tests exist for the new TypeScript MCP handler, service method, and command registration | PASS | `evidence/qa-gates/p12-typescript-targeted-qa.md` |
| 11 | Repository-wide line coverage remains >= 80%; new modules reach >= 90% | PASS | `evidence/qa-gates/p14-coverage-delta.md` — Python 83% (>= 80%), new module 90% (>= 90%), TypeScript 94.95% (>= 80%), all changed TS files >= 90% |
| 12 | Toolchain passes in a single pass for both Python (Black → Ruff → Pyright → Pytest) and TypeScript (Prettier → ESLint → TSC → Jest) | PASS | `evidence/qa-gates/p14-python-format.md`, `p14-python-lint.md`, `p14-python-typecheck.md`, `p14-python-test-coverage.md`; `p14-typescript-format.md`, `p14-typescript-lint.md`, `p14-typescript-typecheck.md`, `p14-typescript-test-coverage.md` — all exit 0 in a single pass |
| 13 | `.claude/skills/orchestrate/SKILL.md` is present in the `.claude/skills/` tree and is included in the push-down output | PASS | `evidence/qa-gates/p9-bundled-copy-byte-identical.md` (orchestrate directory in `.claude/` tree copy), `evidence/qa-gates/p15-orchestrate-skill-diff.md` |
| 14 | The orchestrate skill implements checkpoint resumption from `artifacts/orchestration/orchestrator-state.json` | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — Checkpoint Handling section present in final file |
| 15 | The orchestrate skill's remediation loop terminates after at most 3 full iterations and records `step6_status: "blocked_remediation_loop_limit"` when the limit is reached | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — Remediation Loop (R1–R5) section with termination guard present |
| 16 | The orchestrate skill's PR creation gate requires all four specified conditions to be simultaneously true before proceeding to PR creation | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — PR Creation Gate section with all four conditions present |
| 17 | Every delegation prompt emitted by the orchestrate skill includes the canonical issue number derived from the active feature folder name | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — Issue Number Consistency section present with derivation rule and injection instruction |
| 18 | The orchestrate skill's feature-review delegation contains none of the four categories of prohibited prompt language | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — Step 6 Delegation — Prohibited Prompt Language section retained in final file |
| 19 | Pre-feature-review commit step is present in the orchestrate skill (stage, invoke commit-message skill, commit) | PASS | `evidence/qa-gates/p15-orchestrate-skill-diff.md` — Pre-Feature-Review Commit section present |

## AC Status Summary

Total: 19 / 19 PASS — 0 FAIL
