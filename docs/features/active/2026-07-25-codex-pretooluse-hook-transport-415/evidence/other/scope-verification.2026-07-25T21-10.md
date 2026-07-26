# Scope and Hygiene Verification (Issue #415)

Timestamp: 2026-07-25T21-10

Merge-base of `main`: `009808510363081d0db7684f7b555f2ded4b0b7c` (`git merge-base HEAD origin/main`).

## Commands and EXIT_CODEs

| # | Command | EXIT_CODE |
|---|---|---|
| 1 | `git merge-base HEAD origin/main` | 0 |
| 2 | `git diff --stat 00980851` | 0 |
| 3 | `git status --porcelain` | 0 |
| 4 | `git diff .codex/config.toml` | 0 |
| 5 | `git diff 00980851 -- .codex/config.toml` | 0 |
| 6 | `git diff --diff-filter=D --name-only 00980851` | 0 |

## Output Summary — the four required assertions

### (a) NO path under `.claude/` appears in the change set — HOLDS

- `git diff --stat 00980851 -- .claude/` produces **0 lines of output**: no tracked file under `.claude/` differs from the merge-base.
- `git status --porcelain | grep -c "\.claude/"` returns **0**: no working-tree modification, addition, deletion, or untracked file under `.claude/`.

This holds for the bundled `.claude` copy as well, since the check is a path-prefix match over the entire change set. Hard Constraint 1 is satisfied. `.claude/rules/*` and `.claude/skills/*` were read for policy compliance only.

Of note: `.claude/hooks/validate-orchestrator-output.ps1` and `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`, which the rebase brought in from issues #413/#414, appear nowhere in this change set.

### (b) NO `.codex/state/*` file is staged or committed — HOLDS

- `git status --porcelain | grep -c "\.codex/state"` returns **0**.
- `git ls-files | grep -c "\.codex/state"` returns **0**: no `.codex/state` path is tracked at all.

The transient `.codex/state/powershell-batch-budget.019f9b0e-....json` found at Phase 0 was Codex hook runtime output from a prior session. It was deleted as environment hygiene (recorded in `phase0-pytest-parity.2026-07-25T19-20.md`), never added to version control, and never recreated. Convention C4's payload choice — every test payload targets `README.md` or a read-only command — kept the batch-budget entrypoints from writing state across roughly 130 process spawns in the new suites. The committed assertion `leaves no Codex batch-budget state behind` in `codex-pretooluse-integration.Tests.ps1` enforces this going forward.

### (c) `git diff .codex/config.toml` is empty; registration set and matchers unchanged — HOLDS

- `git diff .codex/config.toml` produces **0 lines**.
- `git diff 00980851 -- .codex/config.toml` produces **0 lines**: `.codex/config.toml` is byte-identical to the merge-base.
- Root and bundle `config.toml` SHA256 are equal: `160C5A0601918775D4190EF5EB14BB9F5DCD3FB8D8CF7FC3F80A20DCC4F704BD` — the same hash recorded in the plan's Verified Preconditions.
- `[[hooks.PreToolUse]]` matcher-group handler counts: **5 / 5 / 8**, matching the required before-state exactly.

Hard Constraint 2 is satisfied: no registration was disabled, removed, bypassed, or weakened; the registration set and matchers after the change equal the set before it.

### (d) The only deleted file is the bundle orphan `enforce-pr-author-skill.ps1` — HOLDS

`git diff --diff-filter=D --name-only 00980851` returns exactly one path:

```
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1
```

`git status --porcelain | grep "^D"` likewise returns exactly that one entry. Its removal is justified in `FEATURE/evidence/regression-testing/issue-335-bundle-orphan-removal.2026-07-25T19-33.md`: it was registered in neither the root nor the bundled `config.toml`, had no root counterpart, and used legacy `CLAUDE_TOOL_INPUT` transport with no stdin read.

## Full change set versus merge-base

`git diff --stat 00980851` — 29 files changed, 1296 insertions, 1332 deletions:

**Production hooks (8 rewired, root + bundle mirror each = 16 entries):**

```
.codex/hooks/check-powershell-test-purity.ps1                          |  74 +--
.codex/hooks/check-python-test-purity.ps1                              |  74 +--
.codex/hooks/enforce-checkpoint-monotonic.ps1                          | 121 +----
.codex/hooks/enforce-completion-consistency.ps1                        |  19 +-
.codex/hooks/enforce-evidence-locations.ps1                            |  82 ++--
.codex/hooks/enforce-orchestration-preimplementation-gate.ps1          |  55 +--
.codex/hooks/enforce-powershell-batch-budget.ps1                       |  68 +--
.codex/hooks/enforce-python-batch-budget.ps1                           |  68 +--
  ... plus the eight byte-identical bundle mirrors
```

**Deletion:** `.../.codex/hooks/enforce-pr-author-skill.ps1 | 500 ---------` (the orphan).

**Manifest:** `.../pack-manifests/core.json | 1 +` (the new shared module path).

**Tests:** `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 53 ++-` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py | 1 -`.

**Documentation:** the feature folder (issue, spec, plan, research), the potential-entry note, and Phase 0 evidence.

**Untracked additions (not yet staged):**

```
.codex/hooks/codex-pretooluse-file-mapping.ps1                                        (new shared module, root)
extensions/.../.codex/hooks/codex-pretooluse-file-mapping.ps1                         (byte-identical mirror)
tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1                        (new, 269 lines)
tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1                      (new, 198 lines)
docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/...      (evidence artifacts)
```

## Additional hygiene checks

**Whole-directory root/bundle parity.** Verified across every `.ps1` in `.codex/hooks`, not only the files this feature touched:

```
rootHooks=26 mismatches=0
```

The check requires, for each of the 26 root hooks, that a bundle counterpart exists and that the two SHA256 hashes are equal, and separately requires that no bundle-only orphan remains. All conditions hold. Hard Constraint 4 is satisfied.

**File-size limit.** Every production, test, and reusable script file this feature touched or added is within the 500-line cap, measured as `(Get-Content -LiteralPath $path).Count`:

| File | Lines |
|---|---|
| `.codex/hooks/codex-pretooluse-file-mapping.ps1` (new) | 474 |
| `.codex/hooks/check-python-test-purity.ps1` | 166 (was 222) |
| `.codex/hooks/check-powershell-test-purity.ps1` | 166 (was 222) |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 254 (was 284) |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 256 (was 286) |
| `.codex/hooks/enforce-evidence-locations.ps1` | 196 (was 218) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 265 (was 264) |
| `.codex/hooks/enforce-checkpoint-monotonic.ps1` | 339 (was 420) |
| `.codex/hooks/enforce-completion-consistency.ps1` | 438 (was 425) |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 273 (was 243) |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (new) | 269 |
| `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (new) | 198 |

Extracting the shared transport module reduced the two files that were closest to the cap: `enforce-checkpoint-monotonic.ps1` fell from 420 to 339 lines, which was the structural reason `spec.md:69` required extraction rather than inlining.

**No git hook or quality gate was bypassed.** No commit was made with `--no-verify`; the single analyzer finding encountered during Phase 7 was fixed at its cause and the C3 loop restarted from format.
