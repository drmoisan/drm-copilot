# Feature Audit: subagent-tree-mcp-and-dropdown (#334)

**Audit Date:** 2026-07-09
**Audit Timestamp:** 2026-07-09T12-23
**Feature Folder:** `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-07-09T09-18`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification (after cycles 2026-07-09T15-35 and 2026-07-09T15-57)
**Template provenance:** Created from the byte-identical bundled asset source at `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md`.

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `d5242b2d3dbb881a5d140da4ba5ed1662fb87209`)
- **Head branch/commit:** `drm-copilot-wt-2026-07-09T09-18` @ `8eee21c9284a9f9e0ab990ea64e85822e5008663`
- **Merge base:** `d5242b2d3dbb881a5d140da4ba5ed1662fb87209` (equal to the base tip; supplied by the caller and confirmed with `git merge-base HEAD main`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (fresh — head SHA matches `8eee21c9`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/**` (45 files: baseline, qa-gates, regression-testing, other)
  - Additional evidence: commands re-executed at head during this audit (Prettier check, ESLint, tsc, targeted Jest, pytest contract suite, `cmp` byte-parity, lcov re-parse, `validate_evidence_locations.py`)
- **Feature folder used:** `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334`
- **Requirements source:** `spec.md` and `user-story.md` (both authoritative for `full-feature`)
- **Work mode resolution note:** Explicit marker `- Work Mode: full-feature` present in `issue.md` (also mirrored in `spec.md` and `user-story.md` headers).
- **Scope note:** Full branch diff vs merge base (104 files). This is a re-audit after two remediation cycles fixed CI-caught bundle-packaging findings; the remediation deltas (bundle mirror, `core.json` registration) are included in the audited diff.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/spec.md` — primary source (13 checkbox items under `## Acceptance Criteria`)
- `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/user-story.md` — co-authoritative source (9 checkbox items under `## Acceptance Criteria`)

All 22 items are already checked `[x]` in the source files (checked off during the initial 2026-07-09T11-07 review); this re-audit re-verifies each against the post-remediation head.

### From spec.md

1. Quick-pick label: last-activity timestamp (`yyyy-MM-dd HH:mm`, UTC, from mtime) + right-anchored path label of at most 60 characters preserving the exact path tail; detail line shows the full absolute path.
2. Ordering: timestamp descending; unreadable mtime sorts last rendering `unknown`; equal timestamps order by path ascending.
3. Selection renders exactly the same tree as before; single candidate bypasses the prompt; a stat failure on one candidate does not break the prompt.
4. MCP server advertises `render_subagent_tree` (required `session_id`, optional `workspace_root`, `additionalProperties: false`); valid id returns `ok: true` with `rendered_tree` = `formatTree(buildSubagentTree(...))` and a summary naming the id and transcript path.
5. Unknown id → `ok: false` naming the searched location; malformed id (charset outside `^[0-9A-Za-z-]{8,64}$`, separators, `..`, empty, over-length) → `ok: false` naming the validation rule; malformed ids never touch the filesystem.
6. Resolver matches the encoded workspace directory and `-wt-` siblings case-insensitively; first directory containing `<session_id>.jsonl` wins deterministically; the tool description states the search scope.
7. SessionStart hook persists the session id (env-file append when `CLAUDE_ENV_FILE` set; state-file otherwise; no write and exit 0 on malformed/empty input; always exits 0).
8. `identify-session-id` skill resolves the current session id without human input with documented ordered fallbacks, reporting the source used.
9. `show-my-agent-tree` skill resolves the id via `identify-session-id`, invokes the MCP tool with explicit `workspace_root`, prints the tree as a fenced code block including under `/btw`; `.claude/settings.json` carries the hook entry and allow-list additions.
10. Toolchain passes in order (Prettier → ESLint → tsc → Jest); per-file 85/75 `coverageThreshold` entries for every new production file; no production file excluded from coverage; the hook passes PoshQC and its Pester suite.
11. All touched files remain under 500 lines; no new runtime dependency.
12. New `src/lib/**` modules import neither `vscode` nor `node:fs`; the MCP bundle builds without esbuild changes.
13. Local feature-review reports no blocking findings.

### From user-story.md

1. Quick-pick entries lead with timestamp + right-anchored path label (<= 60 chars, exact tail); detail shows the full path.
2. Most-recent-first ordering; unreadable mtimes last as `unknown`; path-ascending tiebreak; stat failure does not break the prompt.
3. Same tree as before on selection; single candidate bypasses the prompt.
4. `render_subagent_tree` returns `ok: true` with `rendered_tree` from the existing pure builder/renderer for a valid id.
5. Unknown ids → `ok: false` naming the searched location; malformed ids → `ok: false` naming the rule, never touching the filesystem.
6. `identify-session-id` skill with the hook-backed ordered fallbacks.
7. `show-my-agent-tree` skill invokes the MCP tool and prints the tree in the reply, including under `/btw`.
8. Full extension toolchain passes; >= 85% line / >= 75% branch on every new production file via per-file thresholds; no production exclusions; files under 500 lines; no new runtime dependencies; host-neutral `src/lib/**`.
9. Local feature-review clean of blocking findings.

---

## Acceptance Criteria Evaluation

Spec and user-story criteria overlap substantially; rows note the paired user-story item where applicable.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Label format + detail line (US-1) | PASS | `quick-pick-labels.ts` (`MAX_PATH_LABEL_LENGTH = 60`, `truncateLeftAnchored` preserves exact tail, UTC-part timestamp); `buildRootSessionPickEntries` sets `detail: candidate.path`; boundary tests re-run at head | `npm run test -- --testPathPattern quick-pick-labels` (part of the 5-suite targeted run, 59/59 pass) | Lines 34-39, 54-68, 94-106 inspected |
| 2 | Ordering: desc, `unknown` last, path tiebreak (US-2) | PASS | `compareCandidates` (mtime desc, `undefined` → 1/-1, path-ascending tiebreak); ordering tests re-run at head | Same targeted Jest run | Total, deterministic comparator; input copied before sort |
| 3 | Same tree; single-candidate bypass; stat-failure resilience (US-2/US-3) | PASS | `subagent-tree-command.ts` diff leaves `buildSubagentTree`/`formatTree` untouched; single-candidate early return preserved; `RealFileTimes` maps stat failure to `undefined` for that candidate only; command-wiring tests re-run at head | `git diff d5242b2d..HEAD -- extensions/drm-copilot/src/lib/subagent-tree/` shows no change to scanner/parser/assembler/formatter; targeted Jest run | Non-goal (unchanged tree content) confirmed by diff absence |
| 4 | Tool advertised with required schema; success contract (US-4) | PASS | Tool definition in `mcp-repo-automation-tool-definitions.ts` (`required: ["session_id"]`, `additionalProperties: false`); service returns `rendered_tree` = `formatTree(buildSubagentTree(...))`; definition/list/dispatch tests re-run at head | Targeted Jest run incl. `repo-automation-render-subagent-tree` and tool-definition suites | `rendered_tree` mapped in `toMcpToolResult` following the `asset_id` pattern |
| 5 | Unknown/malformed id error contract; no filesystem access for malformed ids (US-5) | PASS | `SESSION_ID_PATTERN` tested before any `fileSystem` call (resolver lines 50-54); not-found error names searched directories; negative-path tests re-run at head | Targeted Jest run | Path traversal blocked by charset construction |
| 6 | Case-insensitive `-wt-` sibling search; deterministic first hit; scope in description | PASS | Resolver reuses `matchEncodedDirectories`; first-match loop; tool description text states the search scope verbatim | Inspected `session-transcript-resolver.ts` and the tool definition diff | Same search scope as the VS Code command |
| 7 | SessionStart hook persistence contract | PASS | `persist-session-id.ps1`: env-file append / state-file fallback / no-write on malformed input / guarded `exit 0`; 14 Pester tests; hook registered in `.claude/settings.json` | Executor evidence `final-ps-test.2026-07-09T09-59.md`, `phase6-ps-test.2026-07-09T09-59.md` (14/14); hook source inspected at head | PS sources unchanged since the passing evidence run |
| 8 | `identify-session-id` skill with ordered fallbacks (US-6) | PASS | Skill documents env var → state file → newest-mtime transcript, requires source reporting, no human input | Read `.claude/skills/identify-session-id/SKILL.md` at head | Matches spec skill contract |
| 9 | `show-my-agent-tree` flow + settings wiring (US-7) | PASS | Skill resolves via `identify-session-id`, calls the MCP tool with explicit `workspace_root`, prints fenced code block, documents `/btw`; settings diff adds the SessionStart hook entry and the three allow-list entries | Read `.claude/skills/show-my-agent-tree/SKILL.md`; `git diff d5242b2d..HEAD -- .claude/settings.json` | Error handling section covers `ok: false` paths |
| 10 | Toolchain + per-file coverage gates + no production exclusions (US-8) | PASS | Re-run at head: Prettier check clean, `npm run lint` exit 0, `npm run typecheck` exit 0, targeted Jest 59/59; lcov re-parse: all six new files 100% lines, lowest branch 77.78%; `jest.config.cjs` has per-file 85/75 entries for every new production file and `collectCoverageFrom` excludes no `src/**` production path; PoshQC format/analyze/test evidence exit 0 | Commands in policy-audit Appendix B; `python <lcov parser>` re-parse | Full numeric detail in `policy-audit.2026-07-09T12-23.md` §1.2/§1.2.1 |
| 11 | Files < 500 lines; no new runtime dependency (US-8) | PASS | `wc -l` at head: max production 487 (`repo-automation-service.ts`), max test 499; `dependency-check.2026-07-09T09-59.md` shows no `package.json` dependency delta | `wc -l <touched files>`; `git diff main -- extensions/drm-copilot/package.json packages/mcp-server/package.json` | `executeScript` extraction performed specifically to hold the cap |
| 12 | Host-neutral `src/lib/**`; MCP bundle builds without esbuild changes (US-8) | PASS | No `vscode`/`node:fs` imports in `quick-pick-labels.ts` or `session-transcript-resolver.ts` (inspected; `RealFileTimes` in `file-system.ts` per the sanctioned exception); no esbuild config in the diff; bundle build evidence exit 0 | `host-neutrality-check.2026-07-09T09-59.md`; `bundle-extension.2026-07-09T09-59.md`; `bundle-mcp-server.2026-07-09T09-59.md` | Diff contains no `esbuild-*.cjs` changes |
| 13 | Local feature-review clean of blocking findings (US-9) | PASS | This re-audit: zero Blocking findings; both prior CI-caught Blocking findings verified fixed at head (byte-identical mirror via `cmp`; manifest registration via passing completeness suite) | `cmp` on all four mirrored files (all IDENTICAL); `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` (7 passed); targeted Jest run | `policy-audit.2026-07-09T12-23.md` and `code-review.2026-07-09T12-23.md` report no blockers |

User-story items US-1 through US-9 are each covered by the paired rows above; all PASS.

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary (spec.md 13 + user-story.md 9 = 22 items, evaluated as 13 merged rows):**
- **PASS:** 22 criteria (13 spec + 9 user-story)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Orchestrator re-runs the S9 CI green gate against head `8eee21c9284a9f9e0ab990ea64e85822e5008663`; the two previously failing checks (`quality-checks7 / Code Quality & Tests (3.10)` Python contract test; `drm-copilot-extension-tests` manifest completeness) were re-run locally at head in this audit and pass.
2. Normal PR flow (PR body draft exists at `artifacts/pr_body_334.md`).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 22 checkbox items in `spec.md` and `user-story.md` were already checked `[x]` during the initial 2026-07-09T11-07 review.
- This re-audit re-evaluated every item against the post-remediation head and confirmed each remains PASS; no item required unchecking, and no new check-off edits were needed.
- No source-file checkbox change was made in this run because every PASS item was already checked; the source files therefore already reflect delivered work.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/spec.md`, `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/user-story.md`
- Total AC items: 22
- Checked off (delivered): 22
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 13 | 13 | 0 | Checkbox-backed; all re-verified PASS at head |
| `user-story.md` | 9 | 9 | 0 | Checkbox-backed; all re-verified PASS at head |
