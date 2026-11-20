# Feature Audit: subagent-tree-mcp-and-dropdown (#334)

---

**Audit Date:** 2026-07-09
**Feature Folder:** `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-07-09T09-18`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `d5242b2d3dbb881a5d140da4ba5ed1662fb87209`)
- **Head branch/commit:** `drm-copilot-wt-2026-07-09T09-18` (commit `c215c87d8f0ba54ef10a69b5702977212c2ba464`)
- **Merge base:** `d5242b2d3dbb881a5d140da4ba5ed1662fb87209`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff d5242b2..c215c87`
  - Feature evidence: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/**` (baseline + qa-gates, 2026-07-09T09-59)
  - Additional evidence: reviewer re-runs at head (Prettier check, ESLint, tsc, Jest 1611 tests, Pester 14 tests, lcov/JaCoCo parsing) recorded in `policy-audit.2026-07-09T11-07.md`
- **Feature folder used:** `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334`
- **Requirements source:** `spec.md` and `user-story.md` (multiple files)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`, so acceptance criteria come from `spec.md` and `user-story.md` per the acceptance-criteria-tracking rules. The `issue.md` "Acceptance Criteria (early draft)" section is not authoritative in this mode and was left untouched.
- **Scope note:** Full feature-vs-base audit of the 60-file branch diff. No versioned feature subfolders exist; artifacts are written to the feature root. No caller scope narrowing was attempted.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/spec.md` — primary source (13 checkbox items)
- `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/user-story.md` — co-authoritative source (9 checkbox items)

### Acceptance criteria

#### From spec.md

1. Given more than one root-session candidate, the quick-pick shows one entry per candidate whose label begins with the candidate's last-activity timestamp (`yyyy-MM-dd HH:mm`, UTC, derived from transcript mtime) followed by a right-anchored path label of at most 60 characters whose final characters always equal the final characters of the real path; the entry's detail line shows the full absolute path.
2. Quick-pick entries are ordered by last-activity timestamp descending; candidates with an unreadable mtime sort last and render the timestamp as `unknown`; equal timestamps order by path ascending.
3. Selecting an entry renders exactly the same tree as before (no change to `buildSubagentTree`/`formatTree` output); a single candidate still bypasses the prompt; a stat failure on one candidate does not break the prompt.
4. The MCP server advertises `render_subagent_tree` with required `session_id` and optional `workspace_root` (`additionalProperties: false`); calling it with a valid session id returns `ok: true` and a `rendered_tree` field equal to `formatTree(buildSubagentTree(...))` for the resolved transcript, with a summary naming the session id and transcript path.
5. Calling `render_subagent_tree` with an unknown session id returns `ok: false` with a summary naming the searched location; calling it with a malformed session id (charset outside `^[0-9A-Za-z-]{8,64}$`, path separators, `..`, empty, over-length) returns `ok: false` naming the validation rule, and malformed ids never touch the filesystem.
6. The session-transcript resolver matches the encoded workspace directory and its `-wt-` worktree siblings case-insensitively, and the first directory containing `<session_id>.jsonl` wins deterministically; the tool description states this search scope.
7. A SessionStart hook (`.claude/hooks/persist-session-id.ps1`) persists the current session id: with `CLAUDE_ENV_FILE` set it appends `CLAUDE_SESSION_ID=<id>`; with it unset it writes `.claude/state/current-session-id`; on malformed or empty input it exits 0 without writing; it always exits 0.
8. `.claude/skills/identify-session-id/SKILL.md` resolves the current session id without human input and documents the ordered fallbacks (env var → state file → newest-mtime transcript), reporting which source was used.
9. `.claude/skills/show-my-agent-tree/SKILL.md` resolves the session id via `identify-session-id`, invokes `mcp__drm-copilot__render_subagent_tree` with `session_id` and explicit `workspace_root`, and prints the rendered tree in the assistant reply (fenced code block), including under `/btw`; `.claude/settings.json` carries the SessionStart hook entry and the tool/skill allow-list additions.
10. The extension toolchain passes in order (Prettier → ESLint → tsc → Jest); every new production file has a per-file 85% line / 75% branch `coverageThreshold` entry in `jest.config.cjs`; no production file is excluded from coverage; the PowerShell hook passes PoshQC and its Pester suite.
11. All touched files remain under 500 lines; no new runtime dependency is added.
12. New `src/lib/**` modules import neither `vscode` nor `node:fs` (I/O only via injected seams, with `RealFileTimes` living in `file-system.ts`); the MCP bundle builds without esbuild changes.
13. Local feature-review reports no blocking findings.

#### From user-story.md

14. Quick-pick entries lead with the candidate's last-activity timestamp (`yyyy-MM-dd HH:mm`, UTC, from transcript mtime) followed by a right-anchored path label of at most 60 characters whose final characters always equal the final characters of the real path; the detail line shows the full absolute path.
15. Entries are ordered most-recent-first; unreadable mtimes sort last and render as `unknown`; equal timestamps order by path ascending; a stat failure on one candidate does not break the prompt.
16. Selecting an entry renders exactly the same tree as before; a single candidate still bypasses the prompt.
17. The MCP tool `render_subagent_tree` (required `session_id`, optional `workspace_root`) returns `ok: true` with `rendered_tree` equal to `formatTree(buildSubagentTree(...))` for a valid session id, reusing the existing pure builder/renderer.
18. Unknown session ids return `ok: false` naming the searched location; malformed session ids return `ok: false` naming the validation rule and never touch the filesystem.
19. The `identify-session-id` skill lets the assistant determine its current session id without human input, backed by the `persist-session-id.ps1` SessionStart hook, with documented ordered fallbacks (env var → state file → newest-mtime transcript).
20. The `show-my-agent-tree` skill resolves the current session id, invokes `mcp__drm-copilot__render_subagent_tree`, and prints the rendered tree in the assistant reply, including under `/btw`.
21. Full extension toolchain passes (Prettier → ESLint → tsc → Jest); coverage >= 85% line / >= 75% branch on every new production file via per-file `jest.config.cjs` thresholds; no production file excluded from coverage; all touched files under 500 lines; no new runtime dependencies; new `src/lib/**` modules remain host-neutral (no `vscode`/`node:fs` imports).
22. Local feature-review clean of blocking findings.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Timestamp-first label, right-anchored 60-char path, detail = full path | PASS | `quick-pick-labels.ts` (`MAX_PATH_LABEL_LENGTH = 60`, `truncateLeftAnchored` preserves the exact tail, label = `${timestamp}  ${truncatedPath}`, `detail: candidate.path`); tests assert exact label strings and tail preservation | `npm run test` (quick-pick-labels suite, 20 tests) | UTC parts only; `padStart` zero-padding verified at epoch 0 |
| 2 | Ordering desc, unreadable mtime last as `unknown`, path-asc tie-break | PASS | `compareCandidates` total ordering; tests: most-recent-first, `undefined` last, equal-timestamp tie, double-`undefined` tie | `npm run test` | Deterministic; input array not mutated (tested) |
| 3 | Same tree rendered; single-candidate bypass; stat failure tolerated | PASS | `buildSubagentTree`/`formatTree` untouched in diff; command tests: single-candidate auto-select (incl. with injected FileTimes), unreadable-mtime prompt survival | `git diff d5242b2..HEAD -- extensions/drm-copilot/src/lib/subagent-tree/` shows no change to builder/renderer modules | Scanner/parser/assembler/formatter files absent from diff |
| 4 | Tool advertised (required session_id, optional workspace_root, additionalProperties false); ok:true with rendered_tree and summary | PASS | Tool definition in `mcp-repo-automation-tool-definitions.ts`; `rendered_tree` mapping in `mcp-tools.ts`; service call composes `formatTree(buildSubagentTree(...))`; advertisement + happy-path tests | `npm run test` (`repo-automation-render-subagent-tree.test.ts`, `tool-advertised` evidence) | Summary format: `Rendered subagent tree for session <id> (<path>).` |
| 5 | Unknown id names searched location; malformed id names rule, no filesystem access | PASS | Resolver throws before any FS call on pattern mismatch; not-found error joins searched directories; test asserts zero fake-FS invocations for malformed id | `npm run test` | Traversal blocked by charset (no `/`, `\`, `.`) |
| 6 | Case-insensitive workspace + `-wt-` sibling matching, deterministic first hit, scope stated in description | PASS | `matchEncodedDirectories` reuse; tests for case-insensitivity, sibling resolution, deterministic first match; tool description names the search scope verbatim | `npm run test`; description text in `mcp-repo-automation-tool-definitions.ts` lines 452-455 | Same scope as the VS Code command |
| 7 | SessionStart hook persists id via env file or state file; no write on malformed input; always exits 0 | PASS | `persist-session-id.ps1`: append `CLAUDE_SESSION_ID=<id>` (env-file), `Set-Content` state file with directory ensure, `none` decision on malformed/empty, explicit `exit 0`; 14 Pester tests pass (reviewer re-run) | `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/persist-session-id.Tests.ps1"` | Registered in `.claude/settings.json` SessionStart |
| 8 | identify-session-id skill: no human input, ordered fallbacks, source reported | PASS | `SKILL.md` documents env var → state file → newest-mtime transcript, requires source reporting, and notes the heuristic's limitation | File inspection | Frontmatter: name/description/allowed-tools (Read, Bash) |
| 9 | show-my-agent-tree skill: resolves via identify-session-id, calls tool with explicit workspace_root, prints fenced tree incl. /btw; settings wiring complete | PASS | `SKILL.md` steps 1-3 match; error handling section covers ok:false paths; `.claude/settings.json` diff adds SessionStart hook entry, `mcp__drm-copilot__render_subagent_tree`, `Skill(identify-session-id *)`, `Skill(show-my-agent-tree *)` | `git diff d5242b2..HEAD -- .claude/settings.json`; strict JSON parse | Behavioral end-to-end use requires a live session; contract verified structurally |
| 10 | Toolchain passes in order; per-file 85/75 thresholds for every new production file; no production exclusion; hook passes PoshQC + Pester | PASS | Reviewer re-ran Prettier check/ESLint/tsc/Jest at head (all clean); `jest.config.cjs` has entries for all 6 new production files; `collectCoverageFrom` excludes only `*.d.ts`; PoshQC format/analyze/test evidence exit 0; 14/14 Pester | `npx prettier --check src test jest.config.cjs && npm run lint && npm run typecheck && npm run test` | Interface-only `types.ts` omission documented and rule-sanctioned |
| 11 | All touched files < 500 lines; no new runtime dependency | PASS | Largest: test 499, `repo-automation-service.ts` 487; `package.json` files unchanged in diff | `wc -l` on all touched files; `git diff --name-status d5242b2..HEAD` | 499-line test file flagged Info in code review |
| 12 | New lib modules host-neutral; MCP bundle builds without esbuild changes | PASS | grep for `vscode`/`node:fs` imports in the two new `src/lib/**` modules: zero matches; no esbuild config in diff; both bundles built exit 0 | grep (reviewer); `bundle-extension` / `bundle-mcp-server` evidence | `RealFileTimes` in `file-system.ts` per sanctioned exception |
| 13 | Local feature-review reports no blocking findings | PASS | This review: policy audit FULLY COMPLIANT, code review Go with zero Blocker/Major findings, all validators pass | `python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit/code-review/feature-audit <paths>` | Checked off as part of this audit |
| 14 | (user-story) label format + detail line | PASS | Same evidence as #1 | `npm run test` | Duplicate of #1 |
| 15 | (user-story) ordering + resilience | PASS | Same evidence as #2 and #3 (stat-failure case) | `npm run test` | Duplicate of #2/#3 |
| 16 | (user-story) same tree; single-candidate bypass | PASS | Same evidence as #3 | `npm run test` | Duplicate |
| 17 | (user-story) tool returns ok:true + rendered_tree, reusing pure builder/renderer | PASS | Same evidence as #4 | `npm run test` | Duplicate |
| 18 | (user-story) unknown/malformed id failure contracts | PASS | Same evidence as #5 | `npm run test` | Duplicate |
| 19 | (user-story) identify-session-id backed by hook, ordered fallbacks | PASS | Same evidence as #7 and #8 | File inspection; Pester run | Duplicate |
| 20 | (user-story) show-my-agent-tree flow incl. /btw | PASS | Same evidence as #9 | File inspection | Duplicate |
| 21 | (user-story) toolchain + coverage + file size + deps + host-neutrality | PASS | Same evidence as #10, #11, #12; per-file coverage: all new TS files 100% lines (branch min 77.78%), hook 87.04% command/line | Coverage parsing commands in policy audit Appendix B | Duplicate composite |
| 22 | (user-story) local feature-review clean of blocking findings | PASS | Same evidence as #13 | Validator runs | Checked off as part of this audit |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 22 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After merge, exercise the live end-to-end flow once (`Show my agent tree` in a fresh session) to confirm the SessionStart hook populates `CLAUDE_SESSION_ID` on the running Claude Code version, since `CLAUDE_ENV_FILE` availability varies by CLI version (spec Risk #2; automated fallbacks cover absence).
2. On the next change to `test/subagent-tree-command.test.ts` (499 lines), split the suite before adding tests.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

Newly checked off by this review (both previously unchecked, both evaluated PASS):
- `spec.md`: "Local feature-review reports no blocking findings."
- `user-story.md`: "Local feature-review clean of blocking findings."

All other checkbox items were already checked by the executor and were verified rather than re-checked.

### AC Status Summary

- Source: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/spec.md`, `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/user-story.md`
- Total AC items: 22 (13 spec + 9 user-story)
- Checked off (delivered): 22
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 13 | 13 | 0 | Checkbox-backed |
| `user-story.md` | 9 | 9 | 0 | Checkbox-backed |

The `issue.md` early-draft checklist was intentionally left unmodified: under `full-feature` work mode it is not an authoritative AC source.
