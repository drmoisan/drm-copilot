# Code Review: github-instructions-not-migrated-to-claude (#151)

**Review Date:** 2026-04-18T18-50
**Base Branch:** `origin/development` @ `d742a7f8efef1ec95500edca6b2bd525bb78b819`
**Head:** `bug/github-instructions-not-migrated-to-claude-151` @ `b749258af75778cfdc24993363e83f7f91aab3aa`
**Scope:** Feature-vs-base. All 128 files changed on the branch.

## Executive Summary

The branch delivers three composite workstreams that landed on the same branch prior to this review:

1. **Issue-#151 policy-mirror migration** (documentation-only): six new `.claude/rules/*.md` files, four updates to existing rule files, updates to `feature-review-workflow` SKILL and `feature-review` agent, and a byte-identical synchronization of the bundled feature-review agent mirror.
2. **MCP discovery and hard-lock prompt delivery** (TypeScript + Python): additions to `mcp-tools.ts` and `repo-automation-service.ts` that wire `output`/`quiet` parameters into the `resolve_execute_hard_lock_prompt` MCP tool so callers can persist the prompt to an artifact path; corresponding Python resolver changes in `scripts/dev_tools/resolve_hard_lock_prompt.py` and its extension-bundled mirror.
3. **Claude runtime hooks** (PowerShell): two new `.claude/hooks/*.ps1` scripts that enforce Python test purity and a batch-budget limit on Python edits.

Overall code-quality disposition:

- TypeScript production changes in `mcp-tools.ts` and `repo-automation-service.ts` are targeted, type-safe, and preserve existing API shapes. They introduce a defensive invariant check (`quiet` requires `output`) that is good practice. Their drawback is file-size: both files continue to exceed 500 lines and grew on this branch.
- Python production changes in `resolve_hard_lock_prompt.py` are well-factored (path-normalization helper extracted, clear docstrings, explicit side-effect documentation). The extension mirror diverges from the canonical copy in deliberate ways (different import path, stripped inline comments) — this pattern is pre-existing and not introduced here.
- PowerShell hook scripts `.claude/hooks/check-python-test-purity.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1` have clear headers, solid error-path messaging, and explicit regex-based pattern matching. However, they are new production-type scripts with no Pester tests attached and are not present in the PowerShell coverage artifact.
- Markdown additions across `.claude/rules/` are well-structured, use consistent YAML frontmatter, and follow the condensed-summary convention. Acceptance criteria text is satisfied.

Remediation priorities (by severity):

- **Blocker:** PowerShell coverage floor (27.66% repo-wide) and absent per-file coverage for the two new hook scripts.
- **High:** Production `.ts` files over 500 lines; branch worsened the overage. Python mirror-copy coverage is not independently verifiable from existing lcov.
- **Medium:** Grown test files (`repo-automation-service.test.ts` +147 lines, `conftest.py` +1, `test_plan_parser.py` +2, `test_push_down_copilot_customizations_helpers.py` +22). Evidence gaps for TS/PowerShell toolchain runs.
- **Low:** Pre-existing pre-branch test-file overages persist without remediation.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/check-python-test-purity.ps1` | New file, 110 lines | NEW production-type script with no visible Pester test coverage. Not present in `artifacts/pester/powershell-coverage.xml`. | Add Pester tests covering: positive allow-list content, each forbidden-pattern detection (tempfile, network, subprocess, time.sleep, DB drivers), malformed `CLAUDE_TOOL_INPUT` envelope, and empty content. Include under the next Pester run so the artifact reflects >= 90% line coverage. | Per `general-unit-test` policy, new code must reach >= 90% line coverage. Per `feature-review-workflow` SKILL Step 5: absent per-file coverage for a new file is a FAIL that triggers remediation. | `artifacts/pester/powershell-coverage.xml` inspected 2026-04-18T18-50 — file not present as a `<sourcefile>` entry. |
| Blocker | `.claude/hooks/enforce-python-batch-budget.ps1` | New file, 135 lines | NEW production-type script with no visible Pester test coverage. Not present in `artifacts/pester/powershell-coverage.xml`. | Add Pester tests for batch-budget enforcement: allowed small edits, oversize writes blocked, edit-count aggregation, malformed input fallback, and session-reset behavior. | Same as above. | Same as above. |
| Blocker | `.claude/hooks/` (whole path) | Repo-wide PowerShell coverage | Repo-wide PowerShell coverage at 27.66% is far below the 80% floor mandated by `.claude/rules/powershell.md` and `.claude/rules/general-unit-test.md`. | Either (a) raise Pester coverage across `scripts/dev-tools/*.ps1` and `scripts/powershell/PoshQC/*.psm1` to >= 80%, or (b) scope coverage measurement to only code paths that are intended to be covered and exclude bootstrap/one-shot scripts (`bootstrap-host.ps1`, `publish-sideloaded-extension.ps1`, `verify-host.ps1`) with documented rationale. | See per-file coverage breakdown in `policy-audit.2026-04-18T18-50.md` Section 1.2.1. Nine scripts are at 0.00% coverage. | `artifacts/pester/powershell-coverage.xml`. |
| High | `extensions/drm-copilot/src/mcp-tools.ts` | 568 lines at HEAD | Exceeds 500-line production-file limit; was 564 at baseline; branch added 4 lines rather than reducing. | Extract the per-tool handler cases in `dispatchRepoAutomationTool` into dedicated per-tool handler functions in a new module (e.g., `mcp-handlers/*.ts`). Target <= 400 lines for this file. | `general-code-change.md`: "No production code, test code, or reusable script file may exceed 500 lines." | `wc -l extensions/drm-copilot/src/mcp-tools.ts` = 568; `git show d742a7f8:extensions/drm-copilot/src/mcp-tools.ts \| wc -l` = 564. |
| High | `extensions/drm-copilot/src/repo-automation-service.ts` | 545 lines at HEAD | Exceeds 500-line production-file limit; baseline was 506; branch added 39 lines. | Extract per-script argument-assembly and artifact-path logic into a helper (e.g., `execute-script-args.ts`). | Same as above. | `wc -l` = 545; baseline 506. |
| High | `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` + canonical `scripts/dev_tools/resolve_hard_lock_prompt.py` | Two-copy pattern | The extension mirror diverges from the canonical copy (different import path, stripped comments, missing `_normalize_prompt_path_value` helper). Per-file coverage for the mirror is not reported in `artifacts/python/lcov.info`. | Either produce a single lcov run that includes the mirror path (preferred), or document that the mirror is generated/synced from the canonical copy via a build step and is verified by bundle-parity tests (`tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt*.py`). Capture the sync/generation step explicitly so drift is prevented. | Inspection: `diff scripts/dev_tools/resolve_hard_lock_prompt.py extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` shows behavioural differences (normalization helper absent in mirror). | `diff` output captured during review. |
| Medium | `extensions/drm-copilot/test/repo-automation-service.test.ts` | 689 lines at HEAD | Test file grew 542 → 689 (+147). Exceeds 500-line limit; the policy applies to test code too. | Split into per-area test files (e.g., one for hard-lock resolution, one for orchestration artifacts, one for discovery tool dispatch). | `general-code-change.md`: the 500-line limit explicitly applies to test code. | `wc -l` at HEAD 689; baseline 542. |
| Medium | `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py` | 666 lines at HEAD | Test file grew 644 → 666 (+22). Exceeds 500-line limit; branch worsened a pre-existing overage. | Split by the helper area being tested. | Same as above. | `wc -l` comparison. |
| Medium | `extensions/drm-copilot/src/repo-automation-service.ts` | `resolveExecuteHardLockPrompt`, lines ~394-439 | Minor: the invariant `quiet requires output` is enforced with a thrown `Error`. Acceptable, but the error message mentions the internal method name rather than the MCP tool name surfaced to callers. | Change the thrown message to reference the MCP tool name (`resolve_execute_hard_lock_prompt`) so it is actionable for external callers. | `general-code-change.md`: "Fail fast and explicitly" — error messages should be actionable for the caller. | Inline review of diff. |
| Medium | `extensions/drm-copilot/src/mcp-tools.ts` | Case `resolve_execute_hard_lock_prompt`, lines ~535-546 | Hard-coded `"artifacts/hard_lock_prompt.txt"` as output path inside the dispatcher case. The dispatcher assumes the artifact is always under `artifacts/`. | Extract the default output path to a named constant at the top of the module (e.g., `const HARD_LOCK_PROMPT_DEFAULT_OUTPUT = "artifacts/hard_lock_prompt.txt";`) or accept the path from caller input with a tested default. | `general-code-change.md`: "Names must be descriptive" and separation of configuration from dispatch logic. | Inline review of diff. |
| Medium | TypeScript toolchain | Evidence window | No Prettier/ESLint/TSC/Jest result evidence file recorded in `artifacts/evidence/post-change/` for this review window. The coverage artifact `coverage/lcov.info` implies a successful Jest run but does not confirm Prettier/ESLint/TSC. | Run `npm run format:check && npm run lint && npm run type-check && npm run test:unit:coverage` and persist outputs under `artifacts/evidence/post-change/<ts>/post-change-{prettier,eslint,tsc,jest}.md`. | SKILL Step 5 requires format, lint, type-check, test, coverage evidence per language. | No TS result files in `artifacts/evidence/post-change/2026-04-18T17-29/`. |
| Medium | PowerShell toolchain | Evidence window | No PSScriptAnalyzer/Invoke-Formatter run evidence. Pester artifact dated 2026-04-17T22-28 pre-dates HEAD `b749258`. | Re-run Pester and PSScriptAnalyzer at HEAD; persist evidence artifacts. | Same as above. | File timestamp inspection: artifact mtime 2026-04-17T22-28 vs HEAD commit 2026-04-18. |
| Low | `.claude/hooks/check-python-test-purity.ps1` | Lines ~60-80 (forbidden-pattern list) | Forbidden-pattern regex list is a flat sequence of `if` checks. If extended, this pattern will grow. | Extract the forbidden-pattern list into a data structure (hashtable of name → regex) and iterate. Improves testability. | `general-code-change.md`: simplicity-first but also reusability and extensibility. The current form is simple; the suggestion is for incremental improvement, not blocking. | Inline review. |
| Low | `.claude/hooks/enforce-python-batch-budget.ps1` | Session-state handling | The script persists session counters on disk; file-handle contention or stale-state cleanup is not documented. | Document the session-file lifecycle in the script header (creation, read, update, cleanup). | `self-explanatory-code-commenting.md`: loops and branches must have intent comments. | Inline review. |
| Low | `tests/conftest.py` | 660 lines at HEAD | Pre-existing overage grew by 1 line. Not a new problem, but the conftest continues to accrete. | Track under a repo-hygiene follow-up: split shared fixtures by test area (executor, pr_context, templates). | Same 500-line rule. | `wc -l` comparison. |
| Low | Multiple test files | Nine tests files at > 500 lines | Pre-existing overages that did not materially improve on this branch. | Schedule a split/cleanup sweep as a standalone refactor issue; do not block this PR on these items alone. | Policy applies, but these are explicitly not introduced by this branch. | See `policy-audit.2026-04-18T18-50.md` Section 2.2. |
| Informational | `extensions/drm-copilot/src/mcp-tools.ts` | MCP dispatch case | The dispatch spreads the raw input and overrides `output`/`quiet`. Caller-supplied values for these fields are silently replaced. | Either document "output and quiet are controlled by the MCP handler and caller-supplied values are ignored," or pass the caller-supplied values through with a default when absent. Silent overwrite is surprising. | `general-code-change.md`: public APIs should not silently drop parameters. | Inline review of diff. |

## Typed-Python Review (files with Python changes)

- `scripts/dev_tools/resolve_hard_lock_prompt.py`: Google-style docstrings, explicit `Returns:` / `Raises:` / `Side Effects:` sections. Helper `_normalize_prompt_path_value` is properly scoped as module-private and has a clear contract. Pyright run at HEAD: EXIT_CODE 0.
- `scripts/dev_tools/push_down_copilot_customizations_filesystem.py`: small, targeted diff (`newline="\n"` added to `write_text`). Docstring updated to reflect LF normalization. PASS.
- `extensions/drm-copilot/resources/scripts/dev_tools/*.py`: mirror copies. Their divergence from canonical is intentional (different import context), but they drop inline-comment intent markers. Per `self-explanatory-code-commenting.md`, the bundled mirror should carry the same intent comments as canonical. **Non-blocking recommendation:** keep comments in sync when mirror is regenerated.

## Findings Summary by Severity

| Severity | Count |
|---|---|
| Blocker | 3 |
| High | 3 |
| Medium | 5 |
| Low | 4 |
| Informational | 1 |
| **Total** | **16** |

## Disposition

The branch cannot be approved as-is. The PowerShell coverage failure (Blocker × 3) must be resolved before PR merge, the TypeScript file-size overage (High) must be remediated or explicitly deferred with documented rationale, and the Python mirror-copy coverage gap (High) must be closed by either combined lcov or an explicit sync-and-parity test documentation.
