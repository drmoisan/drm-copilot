# collect-pr-context-omits-claude-tree (Issue #633)

- Date captured: 2026-09-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/collect-pr-context-omits-claude-tree/ (Issue #633)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #633
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/633
- Last Updated: 2026-09-07
- Work Mode: full-bug

## Summary

`collect_pr_context` (`mcp__drm-copilot__collect_pr_context`) renders a "Changed files overview" section that silently drops the large majority of changed files, including everything under `.claude/**`, because the bucketing logic in `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` is an allowlist with no terminal `else`.

## Environment

- OS/version: Windows 11 Pro (10.0.26200)
- Python version: n/a (TypeScript component; a parity Python implementation also exists)
- Command/flags used: `mcp__drm-copilot__collect_pr_context` invoked during PR body preparation for a large consolidation PR
- Data source or fixture: a real PR diff touching 92 changed files, most under `.claude/**`

## Steps to Reproduce

1. Produce a changeset touching files that are not `.py`/`.ps1`, do not start with `docs/` or `.github`, and do not contain `AGENTS` in their path (for example, files under `.claude/skills/**`, `.claude/hooks/**`, `.claude/rules/**`, `.claude/agents/**`, or any `.ts`/`.sh`/`.bats`/`.json` file).
2. Run `collect_pr_context` (or the Python parity module `scripts/dev_tools/pr_context/collector_documents.py`) against that changeset.
3. Inspect the rendered "Changed files overview" section of the output.

## Expected Behavior

Every changed, non-renamed file should be enumerated in exactly one of the three overview buckets (`Core logic changes`, `Mechanical moves/renames`, `Docs/templates/agents/tooling`), or the tool should make an explicit, documented decision about which paths are intentionally summarized only in an appendix.

## Actual Behavior

Observed against a real 92-file changeset: only 2 of 92 changed files appeared in the "Changed files overview" section. The PR body had to point reviewers at an appendix instead. Reading `extensions/drm-copilot/src/lib/pr-context/collector-core.ts:316-333` confirms the mechanism: the per-file partition loop is an `if`/`else if`/`else if` chain with no final `else`, so a non-renamed file reaches a bucket only if it ends in `.py` or `.ps1`, or starts with `docs/` or `.github`, or contains `AGENTS`. Every other extension and path — notably the entire `.claude/**` tree (skills, hooks, rules, agents), plus `.ts`, `.sh`, `.bats`, and `.json` files anywhere in the repository — is silently dropped from all three buckets and never appears in the overview. The observed symptom ("`.claude/**` is missing") is a visible instance of this broader allowlist gap, not an isolated `.claude`-specific exclusion; there is no `.claude` string anywhere in the bucketing code.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet:

```typescript
// extensions/drm-copilot/src/lib/pr-context/collector-core.ts:316-333
  const bucketCore: BucketEntry[] = [];
  const bucketRenames: BucketEntry[] = [];
  const bucketDocs: BucketEntry[] = [];
  // Partition changed files into core/renames/docs buckets by status and path.
  for (const [path, status] of statusMap) {
    const stats = perFileStats.get(path) ?? [0, 0];
    if (status.startsWith("R")) {
      bucketRenames.push([path, stats]);
    } else if (path.endsWith(".py") || path.endsWith(".ps1")) {
      bucketCore.push([path, stats]);
    } else if (
      path.startsWith("docs/") ||
      path.startsWith(".github") ||
      path.includes("AGENTS")
    ) {
      bucketDocs.push([path, stats]);
    }
  }
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- Root cause is the missing terminal `else` in the bucket-partition loop at `extensions/drm-copilot/src/lib/pr-context/collector-core.ts:316-333`, consumed by `collector-output.ts:230-235` (`bucketText("Core logic changes", ...)`, `bucketText("Mechanical moves/renames", ...)`, `bucketText("Docs/templates/agents/tooling", ...)`) via `summary-helpers.ts:270`.
- A parity Python implementation exists at `scripts/dev_tools/pr_context/collector_documents.py:262-267` rendering the same section from `bucket_core` / `bucket_renames` / `bucket_docs`. Whether a parity contract binds both implementations together is an open research question for this bug's `spec.md`.
- `.claude/agent-memory/**` is listed in `.gitignore`; whether such paths can appear in the changed-file set collected for a consolidation PR at all is an open research question.
- No existing test in `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts` or `collector-output.test.ts` asserts the `.claude/**` (or broader unbucketed-path) drop in either direction.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add a fail-before test asserting a non-`.py`/`.ps1`/`docs`/`.github`/`AGENTS` path (e.g. under `.claude/**`) is included in the rendered overview after the fix.
- [ ] Integration scenario to retest: run `collect_pr_context` against a changeset containing `.claude/**` files and confirm the overview enumerates them.
- [ ] Manual verification notes: confirm whether the Python parity module requires an equivalent fix and equivalent tests.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
