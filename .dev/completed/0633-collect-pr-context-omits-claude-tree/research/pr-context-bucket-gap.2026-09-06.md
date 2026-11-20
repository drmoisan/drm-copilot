# Research: `collect_pr_context` bucket-partition allowlist gap (issue #633)

- Issue: #633
- Feature folder: `docs/features/active/2026-09-06-collect-pr-context-omits-claude-tree-633/`
- Scope: research only, no code changes made.

## Current State Analysis

The bucket-partition loop lives in
`extensions/drm-copilot/src/lib/pr-context/collector-core.ts:316-333`, confirmed by direct
read of the current file:

```typescript
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

`statusMap` and `perFileStats` are built from two `git diff` invocations in the same
function (`collector-core.ts:264-280`):

```typescript
  if (contextResult.mergeBase && contextResult.headSha) {
    nameStatusText = git.diffRange(["--name-status", contextResult.mergeBase, contextResult.headSha]);
    numstatText = git.diffRange(["--numstat", contextResult.mergeBase, contextResult.headSha]);
  } else {
    nameStatusText = git.diffRange(["--name-status"]);
    numstatText = git.diffRange(["--numstat"]);
  }
```

`GitClient.diffRange` (`git-client.ts:197-199`) runs `git diff <args...>` with
`allowError: true`; no `--exclude-standard`, `-uno`, or ignore-related flag is passed at
any point in this path.

The three buckets are rendered by `collector-output.ts` via `bucketText(...)` calls (per
the delegation prompt's line references, consistent with the section titles found in the
Python renderer, quoted below) and are the only representation of individual changed
files in the "Changed files overview" section; anything not placed in one of the three
buckets is invisible in that section (it may still appear in the full diff appendix,
which is a separate, unbucketed artifact).

## Q1 — True blast radius

**Method:** read the current loop (above) and enumerate real, committed repository paths
against each of the three admission rules, plus a walk of representative extensions
across the tree (`.claude/**`, `.agents/**`, `extensions/drm-copilot/src/**`,
`extensions/drm-copilot/test/**`, `tests/shell/**`, `scripts/bash/**`, `.codex/**`,
`.devcontainer/**`, root config files).

**Reaches a bucket:**
- Any path with `status` starting with `"R"` (a rename), regardless of extension —
  bucket `Renames`.
- Any non-renamed path ending in `.py` or `.ps1` — bucket `Core`. This is a naming
  mismatch worth flagging: `.claude/hooks/*.ps1` (e.g.
  `.claude/hooks/enforce-evidence-locations.ps1`,
  `.claude/hooks/validate-bash.ps1`, 39 files total by direct Glob count) all end in
  `.ps1`, so they do reach a bucket today, but are labelled "Core logic changes" rather
  than "Docs/templates/agents/tooling" even though they are enforcement/tooling scripts,
  not application core logic.
- Any non-renamed, non-`.py`/`.ps1` path starting with `docs/`, starting with `.github`,
  or containing the literal substring `AGENTS` (case-sensitive) — bucket `Docs`. Verified
  concretely: `AGENTS.md` (repo root), `docs/features/templates/policy_audit/AGENTS.md`,
  `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md`, and three
  more under `virtual/*/proposed-tree/AGENTS.md` all match via the substring rule.
  `.github/workflows/ci.yml` matches via the `.github` prefix rule, as does
  `.github/codex/codex-web-maintenance.sh` (a `.sh` file that only reaches a bucket
  *because* it happens to sit under `.github`).

**Drops silently (no bucket, confirmed present and committed in this repository):**
- `.claude/agents/*.md` (24 files, e.g. `.claude/agents/orchestrator.md`,
  `.claude/agents/task-researcher.md`) — the path contains lowercase `agents`, and the
  `includes("AGENTS")` check is case-sensitive, so it does **not** match.
- `.claude/rules/*.md` (20 files, e.g. `.claude/rules/tonality.md`,
  `.claude/rules/general-code-change.md`).
- `.claude/skills/**/*.md` (over 100 files by direct Glob enumeration, e.g.
  `.claude/skills/pr-context-artifacts/SKILL.md`,
  `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`).
- `.claude/settings.json`, `.claude/settings.local.json`.
- `.agents/skills/**/SKILL.md` (a parallel Codex-facing skill tree; ~65 files, e.g.
  `.agents/skills/orchestrate/SKILL.md`) — same case-sensitivity gap.
- All `extensions/drm-copilot/src/**/*.ts` files (Glob returned >100 matches before
  truncation, e.g. `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` itself,
  `extensions/drm-copilot/src/extension.ts`).
- All `extensions/drm-copilot/test/**/*.ts` files (the test suite for the same code).
- `tests/shell/*.bats` (23 files, e.g.
  `tests/shell/test_cleanup_worktrees_classification.bats`).
- `scripts/bash/*.sh` (8 files, e.g. `scripts/bash/cleanup-worktrees.sh`,
  `scripts/bash/shell-qc.sh`) and `.claude/lib/bash/*.sh` (9 files).
- `.codex/codex-web-setup.sh`, `.devcontainer/post-create.sh`,
  `.devcontainer/verify-container.sh` — `.sh` files that are *not* under `.github`, so
  the one accidental save (`.github/codex/*.sh`) does not generalize.
- Root/package config JSON and YAML: `package.json`, `package-lock.json`,
  `extensions/drm-copilot/package.json`, `extensions/drm-copilot/tsconfig.json`,
  `packages/mcp-server/package.json`, `.mcp.json`, `config/blast-radius.json`,
  `config/orchestration-routing.json`, `.agents/skills/*/agents/openai.yaml`.
- `docs/discovery/templates/artifacts/*.json` would actually be caught by the `docs/`
  prefix rule (bucketed), but `schemas/discovery/v1/*.schema.json` and
  `examples/discovery/v1/*.example.json` are not under `docs/` and drop.

**Blast radius, stated plainly:** of the file-category population actually present in
this repository, only three categories reach a bucket (`.py`/`.ps1` by extension,
anything renamed regardless of extension, and anything under `docs/`, `.github`, or
matching the `AGENTS` substring). Every other category drops — concretely this includes
the entire `.ts`/`.tsx`/`.js` surface of the extension and MCP server source and test
trees, the entire `.claude/agents/**`, `.claude/rules/**`, `.claude/skills/**`,
`.agents/skills/**` documentation/skill trees (all lowercase "agents", so the
case-sensitive `AGENTS` substring never matches them), all `.json`/`.yml`/`.yaml`
configuration outside `docs/`/`.github`, all `.sh` files outside `.github`, and all
`.bats` test files. The feature's own `spec.md` (`spec.md:36`) independently recorded an
observed real-world instance: **2 of 92** changed files in a live consolidation PR
reached the overview. This research's independent category walk corroborates that the
gap is broad rather than `.claude`-specific: there is no `.claude` string anywhere in the
bucketing code, and the drop is a property of the allowlist's extension/prefix/substring
tests, not of any particular directory.

**Answer:** The current code admits exactly 3 path categories (rename status; `.py`/`.ps1`
extension; `docs/`/`.github`/`AGENTS`-substring path) and drops everything else with no
terminal `else`. At least 6 broad, concretely populated categories in this repository
drop through today: TypeScript source and test files, `.claude/agents/**`,
`.claude/rules/**`, `.claude/skills/**` and the parallel `.agents/skills/**` tree, shell
scripts outside `.github`, Bats test files, and JSON/YAML configuration outside
`docs/`/`.github`. The one-off exceptions that do accidentally reach a bucket
(`.github/codex/*.sh`, `.ps1` files under `.claude/hooks/**` landing in "Core logic
changes") are incidental side effects of the existing rules, not evidence of a narrower
gap.

## Q2 — `.gitignore` interaction with `.claude/agent-memory/**`

**`.gitignore` verification:** two `.gitignore` files exist in the repository
(`Glob "**/.gitignore"` → `.gitignore` and `packages/mcp-server/.gitignore`). The
root `.gitignore` contains, at line 67, a bare `.claude/agent-memory` entry (no
trailing `/**`), which git's directory-pattern matching treats as excluding the
directory and everything beneath it. `packages/mcp-server/.gitignore` does not
reference `.claude` or `agent-memory` at all.

**Which git command computes the bucketed file set:** `collector-core.ts:264-280`,
via `GitClient.diffRange` (`git-client.ts:197-199`), which runs plain
`git diff --name-status [<merge-base> <head>]` (or `git diff --numstat` for stats),
with no ref arguments when `mergeBase`/`headSha` are unavailable (working tree vs
index). This is the sole source of `statusMap`, which is the sole input to the bucket
loop. A separate call, `GitClient.untracked()` (`git-client.ts:132-134`,
`git ls-files --others --exclude-standard`), is invoked from `render.ts:148` only
when `includeUntracked` is true, and its output feeds a display-only "Untracked
files" text block built in `buildPrContext`/`render.ts` — it never touches
`statusMap`, `perFileStats`, or the three buckets.

**(a) Force-added-and-already-tracked path:** `git diff <ref> <ref>` (or `git diff`
against the index/working tree) compares tracked content — trees, the index, and the
working tree — not the untracked-file universe. `.gitignore` only governs whether git
treats a *not-yet-tracked* path as a candidate for `git add .`, `git status`'s "??"
untracked section, or `ls-files --others --exclude-standard`; once a path is added to
the index (including via `git add -f` against an ignore rule) and committed, it is
ordinary tracked content and every subsequent `git diff` between refs that include a
change to that path will report it exactly like any other tracked file, with no
special-casing for the fact that its path also matches an ignore pattern. So: **yes,
under the condition that some commit in history force-added a path under
`.claude/agent-memory/**` and it remains tracked**, that path's changes would appear in
`statusMap` and be subject to the same bucket-loop gap as any other path.

**(b) Untracked-and-ignored path:** `git diff --name-status` with no pathspec, run
either between two commits or against the working tree/index, never surfaces untracked
files at all — ignored or not — because `git diff`'s default scope is tracked content.
This is a property of `git diff` itself, independent of `.gitignore`: an untracked file
that is *not* ignored also would not appear in a plain `git diff --name-status` call
(it would need `git add -N`/intent-to-add, or explicit inclusion via `git status
--porcelain`, which the bucket computation does not use). So a purely untracked,
gitignored `.claude/agent-memory/**` file **cannot** enter `statusMap` through the code
path the bucket loop reads, regardless of the bucket-loop defect.

**Verification limitation:** this research agent does not have shell/Bash execution
access in this session and could not run `git ls-files -- .claude/agent-memory` or
inspect the repository's git object history to determine whether any path under
`.claude/agent-memory/**` has, in fact, ever been force-added and remains tracked today.
This is recorded as an open verification item, not assumed either way.

**Orchestrator follow-up verification (2026-09-06):** run directly with Bash access:

```
$ git ls-files -- .claude/agent-memory | wc -l
0
```

`git check-ignore -v .claude/agent-memory/orchestrator/MEMORY.md` reports a match against
`.gitignore:67:.claude/agent-memory` (the root-anchored bare entry), while the same probe
against the *nested* copy that does exist in the tree today,
`extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/orchestrator/MEMORY.md`,
reports no match — confirming the root `.gitignore` entry is slash-anchored to the
repository root and does not reach identically-named nested directories. `git ls-files`
against the tracked-file index confirms zero tracked paths under the root-level
`.claude/agent-memory/**` today. The nested, tracked copies under
`extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/**` (14 files
found via `git ls-files | grep -i agent-memory`) are a different, non-ignored path and are
already tracked template content unrelated to the runtime memory directory this bug's
scope discusses; they already reach the `docs`-adjacent question moot because they are not
under the gitignored root `.claude/agent-memory/` path at all.

This closes the open verification item: as of this commit, no path under the
gitignored root `.claude/agent-memory/**` is tracked, so condition (a) above does not
currently hold in this repository. The conditional analysis in (a) remains the correct
general answer (it would apply if that ever changed), but the concrete current-state
answer for this repository is that root-level `.claude/agent-memory/**` cannot appear in
`collect_pr_context`'s diff-based file set today, for the stronger reason that it holds no
tracked content, in addition to the general untracked/ignored-scope reason given in (b)
below.

**Answer:** No, a purely untracked-and-ignored `.claude/agent-memory/**` file cannot
appear in the diff the bucket loop consumes, because `git diff --name-status` only
reports tracked content and never surfaces untracked files (ignored or not) in the first
place — this is inherent to `git diff`'s scope, not a gitignore-specific behavior. Yes,
conditionally: if such a path was ever force-added and committed, its subsequent changes
would appear in that same diff like any other tracked path and would be subject to the
identical bucket-drop defect. Whether that condition currently holds for any path under
`.claude/agent-memory/**` in this repository is unverified in this research pass (no git
plumbing access) and should be checked with `git ls-files -- .claude/agent-memory`
before any fix assumes the directory is entirely absent from tracked history.

## Q3 — Python parity contract

**Correction to the prompt's file reference:** the bucket-partition loop's Python
counterpart is not in `collector_documents.py`. Reading `collector_documents.py:262-267`
shows only the *rendering* call sites (`bucket_text("Core logic changes", ...)`, etc.),
consistent with the TypeScript `collector-output.ts` role. The actual partition loop is
in `scripts/dev_tools/pr_context/collector.py:320-330`:

```python
    bucket_core: list[tuple[str, tuple[int, int]]] = []
    bucket_renames: list[tuple[str, tuple[int, int]]] = []
    bucket_docs: list[tuple[str, tuple[int, int]]] = []
    for path, status in status_map.items():
        stats = per_file_stats.get(path, (0, 0))
        if status.startswith("R"):
            bucket_renames.append((path, stats))
        elif path.endswith(".py") or path.endswith(".ps1"):
            bucket_core.append((path, stats))
        elif path.startswith("docs/") or path.startswith(".github") or "AGENTS" in path:
            bucket_docs.append((path, stats))
```

This is the same three-branch `if`/`elif`/`elif` chain with no terminal `else`, using
identical predicates to the TypeScript version. **The Python implementation has the
identical missing-terminal-else defect.** A fix limited to `collector-core.ts` alone
would leave `scripts/dev_tools/pr_context/collector.py` producing the same silent drop.

**Is there a binding parity contract?**
- No CI job compares Python and TypeScript pr-context output: a search of
  `.github/workflows/*.yml` for `pr_context`/`pr-context` (case-insensitive) returned no
  matches.
- No test file in `extensions/drm-copilot/test/lib/pr-context/` asserts behavioral parity
  against the Python module; `collector-core.test.ts` and `collector-output.test.ts` only
  reference `collector.py` in doc-comments describing what half of the Python file each
  TypeScript module ports (`collector-core.test.ts:12`, `collector-output.test.ts:15`),
  with no executable comparison.
- One historical, non-enforced artifact exists: an epic acceptance criterion,
  `docs/features/completed/2026-06-25-port-python-commands-to-typescript-240/spec.md:16-18`
  — "AC-E1: Every Python command script invoked by the extension or MCP server has a
  TypeScript equivalent with behavior parity (CLI output, exit codes, file artifacts,
  JSON shapes)." This is marked complete (`[x]`) for that epic and is not re-checked by
  any ongoing gate.
- One manual, ad-hoc precedent for cross-runtime comparison exists for a *different*
  pr-context concern (verification-evidence duplicate-key parsing), documented in
  `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/other/additive-corpus-parity.2026-08-20T09-53.md` — a one-time,
  manually-run corpus differential using a throwaway Jest harness and a scratch Python
  script, not a repeatable or CI-enforced check, and it does not cover the bucket
  partition logic.
- A related potential-bug write-up,
  `docs/features/potential/2026-08-20-pr-context-duplicate-required-key-precedence-divergence.md`,
  independently documents that the Python and TypeScript pr-context implementations have
  *already* diverged on another point (duplicate required-key precedence), which is
  further evidence that nothing currently enforces ongoing parity between the two
  runtimes.

**Answer:** No binding, enforced contract exists today. The only documented parity
expectation is a completed epic's acceptance criterion (AC-E1 in the epic-240 spec),
which describes intent at the time of the original Python-to-TypeScript port but is not
re-validated by any current CI job, test, or repository rule file. This is this research
pass's independent finding, not an assumption carried from the delegation prompt. The
Python `collector.py` bucket-partition loop (not `collector_documents.py`) has the
identical missing-terminal-else defect as the TypeScript version, confirmed by direct
read and quote above.

## Recommendation

A narrow fix (add `.claude/**` to the `docs`-bucket prefix list, or otherwise special-case
one directory) would not close the gap found in Q1: the drop is a property of the
allowlist's predicates (extension, prefix, case-sensitive substring), not of any single
directory, and this repository's own file tree demonstrates at least six broad,
independently-populated categories (TypeScript source/tests, two parallel
`.claude/skills`+`.agents/skills` documentation trees, `.claude/agents/**`,
`.claude/rules/**`, non-`.github` shell scripts, Bats tests, and non-`docs`/`.github`
JSON/YAML) that would still drop after a `.claude`-only patch. A narrow fix would also
leave the `AGENTS` case-sensitivity gap in place (the fix's own target directory,
`.claude/agents/**`, contains lowercase `agents` and would still need a second, separate
carve-out even under a `.claude`-only patch).

A fully general fix — adding a terminal `else` that routes every unmatched path into an
existing bucket (most plausibly the `Docs`/tooling bucket, given its current membership
already includes non-code tooling and config surfaces) or a new fourth bucket — closes
the defect for the entire family in one change and matches the "every changed,
non-renamed file should be enumerated in exactly one of the three overview buckets"
expectation already stated in this feature's `spec.md:33`. Because Q3 found the
identical defect in `scripts/dev_tools/pr_context/collector.py:320-330`, the general fix
should be applied to both the TypeScript and Python bucket loops in the same change to
avoid re-opening a Python/TypeScript divergence of the kind already recorded in the
potential-bug backlog (`2026-08-20-pr-context-duplicate-required-key-precedence-divergence.md`).
Any bucket-label rename (e.g., re-labelling `.claude/hooks/*.ps1` more accurately) is a
separate, smaller decision that does not block closing the terminal-else gap and can be
scoped independently.
