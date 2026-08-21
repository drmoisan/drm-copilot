# Research — Blast-radius bundled config drift (Issue #500)

- Timestamp: 2026-08-21T17-16
- Feature folder: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
- Work mode: full-bug
- Repository root (worktree): `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16`
- Authoritative defect statement read first: `issue.md` `## Suspected Cause / Notes` (lines 77-114), which
  supersedes the `## Summary` framing (lines 20-21).

## Tooling Limitation (declared before any claim)

This research thread was provisioned with read-only tools (`Read`, `Grep`, `Glob`, `Write`, `Edit`,
`WebFetch`). No `Bash` or PowerShell execution tool was available. Consequently:

- **No command in this document was executed.** Every command in `## 5. Reproduction and Verification
  Commands` is marked `STATUS: NOT EXECUTED` and is derived by reading the exact parameter contracts of
  the functions it invokes. Each command carries the `file:line` citations that fix its parameter names
  and types.
- **No `git log --follow` output is reported.** Question 1's divergence question is answered instead from
  in-repository evidence that is stronger than a commit walk: the parity gate that protects one tree and
  not the other, and the test-helper comment that records the bundled skeleton as a deliberate design
  choice. The commit-level confirmation is listed as an executor obligation in
  `## Executor Verification Obligations`.

No fabricated output appears anywhere in this document.

## Policy Reading Order Completed

Read in the order `CLAUDE.md` mandates: `.github/copilot-instructions.md`;
`.github/instructions/general-code-change.instructions.md`; the `.claude/rules/` mirror set supplied in
context (`general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`, `tonality.md`,
`parallel-orchestration.md`, `orchestrator-state.md`, `plan-acceptance-gates.md`, `python.md`,
`python-suppressions.md`, `typescript.md`, `typescript-suppressions.md`, `powershell.md`,
`self-explanatory-code-commenting.md`, `architecture-boundaries.md`, `benchmark-baselines.md`,
`ci-workflows.md`).

---

## Executive Summary — the corrected causal chain

The defect has **two independent causes**, and the issue text attributes both to one file. Correcting the
attribution changes the fix.

**Cause A (fail-closed, `claude-runtime`) is NOT the bundled config file.** The bundled document's
`modules` key is never read by the code that publishes it. The push-down replaces the module map
wholesale with one derived from the destination's own layout, and injects `claude-runtime` from a
hardcoded constant:

- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:131-135` —
  `PAYLOAD_MODULES` is `{ "claude-runtime": [".claude/**"], config: ["config/**"] }`.
- `claude-blast-radius-derive-core.ts:334-358` — `assembleModules(derivedPaths)` builds the map from the
  destination scan plus `PAYLOAD_MODULES`. It never reads `source["modules"]`.
- `claude-blast-radius-derive-core.ts:442-449` — the emitted document takes `modules` from
  `assembleModules`, not from the bundled document.

The issue's own TaskMaster observation confirms this: "20 modules — 18 hand-added C# project modules,
plus `claude-runtime` and `config`" (`issue.md:93`) is exactly `18 derived project directories + the two
`PAYLOAD_MODULES` entries`. The 18 were not hand-added; they were derived
(`claude-blast-radius-derive-core.ts:266-303`, `claude-blast-radius-derive.ts:163-207`).

**Cause B (fail-open, missing surfaces and globs) IS the bundled config file.** Five top-level keys are
carried verbatim from the bundled document into the destination:

- `claude-blast-radius-derive-core.ts:153-159` — `CARRIED_KEYS = ["version", "shared_surfaces",
  "shared_surface_globs", "over_breadth_fraction", "mandate_reads"]`.
- `claude-blast-radius-derive-core.ts:442-449` — those five values are copied straight from the parsed
  bundled document.

So the bundled file's 3 `shared_surfaces` and 0 `shared_surface_globs`
(`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json:3-8`) reach every
destination unchanged, against 10 and 3 in the self-hosted copy
(`config/blast-radius.json:3-19`). This matches the issue's measured table (`issue.md:91-93`) exactly.

**Cause C (secondary, applies to BOTH copies).** The `mandate_reads` lists are byte-identical between the
two copies (`config/blast-radius.json:20-27` and the bundled file lines 9-16), so the four gaps issue
#500 names are self-hosted defects too, not only bundled ones. In this repository they cause contention
through `path_overlap` rather than `module_overlap`, because the self-hosted map has no `claude-runtime`
umbrella to absorb them. See `## 3.3`.

---

## 1. How the bundled copy is produced, and why the two diverged

### 1.1 There is no generator. The bundle is hand-maintained.

Searched for any copy, sync, or generation step from `config/**` or `.claude/**` into
`extensions/drm-copilot/resources/**`. The only sync tool in the repository is
`scripts/dev_tools/agentic_sync.py`, and its scope is `.github/**` between two local repository
workspaces only:

- `scripts/dev_tools/agentic_sync.py:1-9` — "Synchronize shared .github documents between two local
  repos."
- `scripts/dev_tools/agentic_sync.py:24-29` — `ROOT_FOLDERS = (.github/agents, .github/instructions,
  .github/prompts, .github/skills)`.

No other script writes into `extensions/drm-copilot/resources/`. The bundled tree is therefore a
hand-maintained checked-in copy, and its only protection is a test.

### 1.2 The protecting test's scope is `.claude/**` and excludes `config/**`

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:20` — `SCOPED_ROOTS: tuple[Path,
  ...] = (Path(".claude"),)`.
- `test_push_down_claude_resource_contracts.py:101-126` —
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` asserts, for every repository
  `.claude/**` file except `settings.local.json` and `.claude/agent-memory/**`, both that the bundled
  counterpart exists and that `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)`.

This is why `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
carries the current issue-#489 Blast-Radius Contention Doctrine text while the bundled
`config/blast-radius.json` beside it does not: the rules file is inside the parity scope and the config
file is not.

**This is the precise divergence mechanism.** Issue #462 extended the *payload* to include `config/`
(`extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:41-50`, `ROOT_FOLDERS = [".claude",
"config"]`) without extending `SCOPED_ROOTS` in the parity test. The `config/` tree entered the shipped
payload without entering the parity scope.

### 1.3 `config/orchestration-routing.json` escaped this because it received a bespoke pin

The routing document has parity coverage in two places, so it never drifted:

- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py:33-56` — byte-identity between
  `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json`.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:200-204` — the same
  pair asserted again, plus `assert not BUNDLE_ROUTING_CONFIG.exists()` for the Codex bundle.
- `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:84-108` — byte-identity
  between the repository root file and the *Claude-bundle* copy
  (`resources/claude-customizations/config/orchestration-routing.json`).

`config/blast-radius.json` has **no** parity pin of any kind. It has only two shared *negative* pins
(no location-bucket module), described in `## 4.4`.

### 1.4 The bundled skeleton was a deliberate design decision, not an accidental staleness

The push-down deliberately does not ship the self-hosted module map, and the reasoning is recorded in
code and in tests:

- `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:52-65` — "`config/blast-radius.json`
  is intercepted by `BlastRadiusDeriveFileSystem`, which replaces the bundled bytes with a module map
  derived from the destination's own layout (the bundled map describes drm-copilot and names none of an
  unrelated destination's modules)."
- `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts:61-72` — "The constant
  mirrors the shape of **the corrected bundled copy** ... which declares only the two payload modules."
- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1:91-100` — the `claude-runtime`
  prohibition is scoped to the repository table only, on the stated ground that "the bundled base
  document is a push-down template whose module map describes the DESTINATION repository's subsystems,
  so it is not held to this repository's granularity decision."

**That stated ground is factually wrong, and this is the key finding of the research.** The bundled
`modules` key describes nothing in the destination, because it is never read (`## Executive Summary`,
Cause A). The exemption therefore protects a dead field, while the live source of `claude-runtime` in a
destination — `PAYLOAD_MODULES` — is pinned *positively* by
`extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts:470-477`.

### 1.5 A second, unrelated divergence found in passing: the Python push-down publishes no `config/`

- `scripts/dev_tools/push_down_claude_customizations.py:101` — `ROOT_FOLDERS: tuple[Path, ...] =
  (Path(".claude"),)`.
- `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:50` — `ROOT_FOLDERS = [".claude",
  "config"]`.

The Python CLI entry point (`python -m scripts.dev_tools.push_down_claude_customizations`) publishes no
`config/` tree at all, and applies neither the routing merge nor the blast-radius derivation (both are
TypeScript decorators, `claude-customizations.ts:270-287`). The production path is the TypeScript one:
`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:166-201` wires the MCP tool
`push_down_claude_customizations` to `pushDownClaude` with
`sourceRoot = <extensionRoot>/resources/claude-customizations`.

**Recommendation:** record this as a separate follow-up (a destination pushed via the Python CLI receives
no truth table and cannot resolve one). It is out of scope for #500 and must not be widened into it, per
`.github/instructions/general-code-change.instructions.md:36-37`.

---

## 2. Full inventory of self-hosted vs bundled duplication

Enumerated by globbing `extensions/drm-copilot/resources/**` and cross-checking each root against the
repository tree. Seven dual-location pairs exist.

| # | Self-hosted | Bundled | Parity enforcement today |
| - | --- | --- | --- |
| 1 | `.claude/**` (minus `settings.local.json`, `agent-memory/**`) | `resources/claude-customizations/.claude/**` | **Byte-identical, enforced** — `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` |
| 2 | `.codex/**`, `.agents/**` | `resources/codex-and-agents-customizations/` | **Byte-identical, enforced** — `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:207-214` |
| 3 | `config/orchestration-routing.json` | `resources/config/orchestration-routing.json` | **Byte-identical, enforced twice** — `test_orchestration_routing_config_parity.py:33-56`; `test_push_down_codex_and_agents_resource_contracts.py:203` |
| 4 | `config/orchestration-routing.json` | `resources/claude-customizations/config/orchestration-routing.json` | **Byte-identical, enforced** — `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:84-108` |
| 5 | `config/blast-radius.json` | `resources/claude-customizations/config/blast-radius.json` | **NO parity pin.** Only two negative pins (no `docs`/`tests` bucket): `tests/scripts/dev_tools/test_blast_radius_config.py:483-499`; `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1:208-241` |
| 6 | `.github/**` | `resources/customizations/.github/**` | Not located during this research. Not asserted either way. |
| 7 | `.mcp.json` | `resources/claude-dir-customizations/.mcp.json` | Not located during this research. Not asserted either way. |

### 2.1 Verification of the `.claude/rules/parallel-orchestration.md` "mirrored byte-for-byte" claim

`.claude/rules/parallel-orchestration.md` (Enforcement section) states the `parallel` route entry "lives
in `config/orchestration-routing.json` ... and is mirrored byte-for-byte in
`extensions/drm-copilot/resources/config/orchestration-routing.json`."

**Verified true, and stronger than stated.** Both files were read in full (356 lines each) and are
identical line for line, including the two idiosyncratic indentation regions at lines 253-269 and
311-340 that a re-serialization would have normalized. Reading the same content twice is weaker evidence
than a byte compare, but a byte compare is already asserted by
`test_orchestration_routing_config_parity.py:47-56`, which reads both files with `read_bytes()`. The
third copy (`resources/claude-customizations/config/orchestration-routing.json`) is byte-pinned to the
same source by `claude-config-carriage.test.ts:103-107`.

**Diff summary per pair:**

- Pair 3: no diff. Enforced.
- Pair 4: no diff. Enforced.
- Pair 5: **six differences**, enumerated below.
- Pairs 1, 2: no diff by construction of the enforcing test.

### 2.2 Precise diff for pair 5 (`config/blast-radius.json`)

Self-hosted (`config/blast-radius.json:1-38`) vs bundled
(`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json:1-22`):

| Key | Self-hosted | Bundled | Consumed in a destination? |
| --- | --- | --- | --- |
| `version` | `1` | `1` | Yes (carried verbatim) — identical |
| `shared_surfaces` | 10 entries (lines 4-13) | 3 entries (lines 4-6) | **Yes (carried verbatim)** — 7 missing |
| `shared_surface_globs` | 3 entries (lines 16-18) | `[]` (line 8) | **Yes (carried verbatim)** — 3 missing |
| `mandate_reads` | 6 entries (lines 21-26) | 6 identical entries (lines 10-15) | Yes (carried verbatim) — identical |
| `modules` | 7 subsystem modules (lines 29-35) | `claude-runtime`, `config` (lines 18-19) | **No — ignored by the derivation** |
| `over_breadth_fraction` | `0.25` (line 37) | `0.25` (line 21) | Yes (carried verbatim) — identical |

The seven missing `shared_surfaces` entries are `poetry.lock`, `package-lock.json`,
`extensions/drm-copilot/package-lock.json`, `packages/mcp-server/package-lock.json`, `quality-tiers.yml`,
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and
`extensions/drm-copilot/resources/config/orchestration-routing.json`. The three missing globs are
`scripts/dev_tools/validate_*.py`, `scripts/dev_tools/_orchestrator_state_*.py`, and
`scripts/dev_tools/_epic_orchestrator_state_*.py`.

### 2.3 Incidental finding: `quality-tiers.yml` does not exist in this repository

`config/blast-radius.json:11` lists `quality-tiers.yml` as a shared surface and line 26 lists it as a
mandate read. `BlastRadius.TruthTable.Tests.ps1:200-205` asserts both memberships.
`.claude/rules/quality-tiers.md` states the file "at repo root maps every project to a tier" and that
"Adding a project without a tier classification fails CI."

Globbing `*.yml` at the repository root returns only `.github/dependabot.yml` and the 13
`.github/workflows/*.yml` files. Globbing `**/quality-tiers.y*ml` returns no files. The string
`quality-tiers` appears in code and tests only in the two blast-radius configs, the core pack manifest,
and blast-radius tests. `.gitignore` contains no `quality-tiers` entry. `docs/ci.research.md`, named by
`.claude/rules/quality-tiers.md` as the tier-system source of truth, also does not exist.

**Consequence:** the `quality-tiers.yml` shared-surface entry is presently inert in this repository (no
plan can cite a path that does not exist), and question 6 cannot be answered from the tier map. See
`## 6`. This is a pre-existing condition, not caused by and not fixed by #500; it is recorded so a
planner does not assume the file is readable.

---

## 3. What a destination-neutral default truth table should contain

### 3.0 The governing asymmetry, established from the code rather than assumed

The task prompt hypothesized an asymmetry between surface entries and module globs. The mechanism
confirms it, and the confirmation is more specific than the hypothesis.

**Module globs actively suppress concurrency.** `Resolve-BlastRadiusModule`
(`.claude/lib/blast-radius/BlastRadiusNormalization.psm1:133-182`) admits a module as soon as one of its
globs covers one radius entry. Two items whose only commonality is that both matched the same module glob
therefore contend at `module_overlap` (`.claude/lib/blast-radius/BlastRadius.psm1:457-468`). An
over-matching glob costs concurrency on every pair it touches. `.claude/rules/parallel-orchestration.md:257`
states the criterion directly: "A candidate module belongs in the map when it names a subsystem an item
could plausibly not touch. A candidate that matches the majority of work items belongs nowhere."

**Surface entries and mandate reads are inert when the named path is absent.**
`Resolve-BlastRadiusSharedSurface` (`.claude/lib/blast-radius/BlastRadiusConfig.psm1:408-460`) iterates
the radius's concrete paths and tests each against the configured list and globs. A configured surface
that no plan ever cites contributes nothing. Likewise `Test-MandateRead`
(`BlastRadiusNormalization.psm1:185-242`) only removes entries a plan actually cited.

**One qualification the hypothesis omits, and it strengthens the case rather than weakening it.** A
separator-free shared surface is not merely a resolution input; it is the *sole* gate on whether the
extractor accepts a separator-free token at all:

- `.claude/lib/blast-radius/BlastRadiusConfig.psm1:231-281` — `Get-ConfigRootSurface` returns exactly the
  `shared_surfaces` entries containing no `/`.
- `.claude/lib/blast-radius/BlastRadiusExtraction.psm1:328-342` — `Get-PathTokenKind` accepts a token as
  `concrete` if and only if it is an exact ordinal member of `RootSurface`; otherwise a token with no `/`
  (index `< 0`) or a leading `/` (index `== 0`) returns `$null` and is dropped.
- `.claude/lib/blast-radius/BlastRadius.psm1:166-175` — both extraction calls receive the same
  `RootSurface` derived from the same config, which is what keeps derivation and validation
  self-consistent.

The bundled document's three `shared_surfaces` all contain `/`, so in every destination
`Get-ConfigRootSurface` returns an empty array and **no separator-free root token is extractable at all**.
That is exactly the issue's fail-open case (`issue.md:100-103`): `coverage.config`,
`Directory.Build.props`, `Directory.Build.targets`, `package-lock.json` are all dropped from the radius
before resolution, so two items editing the same root build file report `conflict=False`.

**Conclusion, stated explicitly as requested:** the safe default is to **ship the broader set for
`shared_surfaces`, `shared_surface_globs`, and `mandate_reads`, and the narrower set for `modules`.** For
surfaces the cost of an entry a destination lacks is zero and the cost of a missing entry is a false
negative in a fail-closed relation; for modules the cost of an over-broad entry is paid on every pair.

### 3.1 Per-key disposition

#### `shared_surfaces` — MIX. Ship the portable subset, expanded from 3 to 6.

| Entry | Classification | Reason |
| --- | --- | --- |
| `.claude/settings.json` | Portable — KEEP | The push-down writes it (`core.json:5`); present in every destination that received the payload. |
| `config/orchestration-routing.json` | Portable — KEEP | Written by the push-down (`core.json:140`); merged, not overwritten (`claude-customizations.ts:66`), so destination-local routes make it a genuine contention point. |
| `config/blast-radius.json` | Portable — KEEP | Written by the push-down (`core.json:141`). |
| `quality-tiers.yml` | Portable in intent — **ADD** | `.claude/rules/quality-tiers.md` requires a repo-root tier map in any repository using this runtime; `.claude/rules/parallel-orchestration.md:228-230` fixes it as both a shared surface and a mandate read. Separator-free, so adding it also restores root-token extraction. Inert in a destination that lacks it. |
| `package-lock.json` | Portable — **ADD** | Any npm-bearing destination has it; two items both touching it genuinely contend. Separator-free. Inert otherwise. |
| `poetry.lock` | Portable — **ADD** | Same argument for a Poetry-bearing destination. Separator-free. Inert otherwise. Weaker than `package-lock.json` but the cost of being wrong is zero. |
| `extensions/drm-copilot/package-lock.json` | drm-copilot-specific — EXCLUDE | Names this repository's directory layout. |
| `packages/mcp-server/package-lock.json` | drm-copilot-specific — EXCLUDE | As above. |
| `extensions/drm-copilot/resources/config/orchestration-routing.json` | drm-copilot-specific — EXCLUDE | This is the bundled mirror path; meaningless in a destination. |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | drm-copilot-specific — EXCLUDE | PoshQC is this repository's toolchain, at this repository's path. |

Recommended bundled `shared_surfaces` (6 entries): `.claude/settings.json`,
`config/blast-radius.json`, `config/orchestration-routing.json`, `package-lock.json`, `poetry.lock`,
`quality-tiers.yml`.

**Tension to disclose to the planner.** `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:284-294`
asserts the *published* document contains none of `"**"`, `"docs/**"`, `"tests/**"`, `scripts/dev_tools`,
`packages/mcp-server`, `poetry.lock`, `package-lock.json`. That assertion runs against the hermetic
in-memory constant `SOURCE_BLAST_RADIUS` (`config-carriage.test-helpers.ts:74-91`), not against the real
bundled file, so adding `poetry.lock` and `package-lock.json` to the real bundled file **does not**
mechanically fail it. It does, however, contradict the intent that test encodes. The recommendation above
is that the intent was drawn too wide: the entries that must never reach a destination are those naming
*this repository's directory layout*, not root-level lockfile names that any destination may legitimately
carry. If the planner disagrees, the fallback is to add `quality-tiers.yml` alone (restoring root-token
extraction for the one path the rules mandate) and leave the two lockfiles out. Either choice must update
the AC8 forbidden-substring list and its rationale comment, so the decision is visible in the diff.

#### `shared_surface_globs` — DESTINATION-SPECIFIC. Keep empty in the bundle.

All three self-hosted globs are `scripts/dev_tools/*.py` patterns
(`config/blast-radius.json:16-18`) naming this repository's Python dev-tooling module families. They
describe no destination. Keeping the bundled list empty is correct and requires no change.

Note the constraint that makes an empty list acceptable rather than merely tolerable: a glob is *not* a
source of root-token acceptance (`BlastRadiusConfig.psm1:244-247` states this explicitly — "a glob can
never be an exact token match"), so an empty glob list costs nothing beyond glob-based surface membership,
and no destination-portable glob is known upstream.

#### `mandate_reads` — PORTABLE. Currently identical in both copies; both need the same four additions.

Every current entry is portable: `.claude/rules/**`, `.claude/skills/atomic-plan-contract/SKILL.md`,
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.github/instructions/**`, `artifacts/**`,
`quality-tiers.yml`. The first three and the sixth are payload paths (`core.json:54-63, 65, 78`); the
fourth is written by the Copilot push-down; the fifth is a process-artifact tree.

One current entry is already inert: `artifacts/**` can never be extracted, because `artifacts/` was
removed from the extractor's known top-level segments —
`.claude/lib/blast-radius/BlastRadiusExtraction.psm1:61-67` ("`artifacts/` is deliberately absent (issue
#489)"). Harmless; leave it.

#### `modules` — DESTINATION-SPECIFIC AND DEAD IN THE BUNDLE.

The derivation computes the map from the destination scan
(`claude-blast-radius-derive-core.ts:423-451`) and never reads `source["modules"]`. Two options:

- **Recommended:** leave `modules` in the bundled file but reduce it to `{ "config": ["config/**"] }` so
  it matches the corrected `PAYLOAD_MODULES`, and add a gate assertion that the bundled `modules` key
  set is a subset of `PAYLOAD_MODULES`. Rationale: a maintainer reading the bundled file must not be
  told that `claude-runtime` will be published, because it must no longer be published; keeping the file
  honest about a dead field is cheaper than removing the field and reasoning about readers who expect it.
- Not recommended: delete the `modules` key entirely. `Get-ConfigModuleEntry`
  (`BlastRadiusConfig.psm1:339-342`) tolerates an absent key, and the derivation ignores it, so deletion
  is safe — but `tests/scripts/dev_tools/test_blast_radius_config.py:490` calls `load_module_globs` on
  the bundled copy, which raises `TypeError` when `modules` is absent (line 144-145). Deletion therefore
  requires a test change that buys nothing.

#### `over_breadth_fraction` — PORTABLE. `0.25` in both copies. No change.

### 3.2 `claude-runtime` under the module-map granularity criterion, applied explicitly

`.claude/rules/parallel-orchestration.md:242-257` removed five umbrella modules, `claude-runtime` among
them (line 251), on the stated ground that "an umbrella that matches almost every radius is not a
coherent unit of contention, because a level that always fires carries no information and only suppresses
concurrency." Applying the criterion to the destination case:

1. **Does `.claude/**` name a subsystem an item could plausibly not touch?** No. Every agent in the
   runtime is instructed to read the policy rules and process skills before doing any work
   (`.claude/rules/parallel-orchestration.md:208-215`), and plans cite those paths in inline code, which
   is precisely what the extractor harvests (`BlastRadiusExtraction.psm1:400-442`). The measured rate in
   the issue is 10 of 16 plans, 62% (`issue.md:44`).
2. **Does removal weaken contention below the path level?** No. `.claude/rules/parallel-orchestration.md:253-256`
   records the general answer, and the mechanism confirms it: two items editing the same hook still
   contend at `path_overlap` (`BlastRadius.psm1:345-375`, `451-455`), and two items editing a declared
   shared surface still contend at `shared_surface_overlap`.
3. **Is the no-signal floor still non-empty after removal?** Yes.
   `claude-blast-radius-derive-core.ts:334-357` merges `PAYLOAD_MODULES` unconditionally, so with
   `{ config: ["config/**"] }` remaining the assembled map is never empty and
   `assertNoForbiddenGlob` (lines 366-376) has a non-vacuous input.

**Therefore `claude-runtime` must be removed from `PAYLOAD_MODULES`**, and `config` retained. `config/**`
in a destination holds only the two published files, both declared shared surfaces, so `config` names a
subsystem an item can plausibly not touch and it satisfies the criterion.

### 3.3 The four `mandate_reads` gaps named in issue #500, verified individually

| Candidate | Exists in this repository? | Read by mandate? | Recommendation |
| --- | --- | --- | --- |
| `.claude/skills/acceptance-criteria-tracking/SKILL.md` | Yes — `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:64` lists it; it is a payload path, and `config/orchestration-routing.json:22, 48, 71, 112, 133` names `acceptance-criteria-tracking` as a `required_skills` entry on five routes. | Yes. Required by route contract, therefore read on every run of those routes. | **ADD to both copies.** |
| `.claude/skills/policy-compliance-order/SKILL.md` | Yes — `core.json:95`. | Yes. It is the skill statement of the `CLAUDE.md` "Policy Compliance Reading Order" section; citing it is a compliance report. | **ADD to both copies.** |
| `.claude/agent-memory/**` | Yes in the bundle; the repository-root tree is untracked. `test_push_down_claude_resource_contracts.py:104-107` states "general memories live in the bundle but not at the gitignored root", and lines 113-117 exclude the subtree from parity. | Yes. Every agent with a memory scope reads its `MEMORY.md` index at session start. | **ADD to both copies.** A glob entry matches an identical glob citation by ordinal equality and a concrete citation by containment (`BlastRadiusNormalization.psm1:223-239`), so the `**` form covers both citation shapes. |
| `.agents/skills/**` | Yes — 65 files under `.agents/skills/` (globbed), including `.agents/skills/policy-compliance-order/SKILL.md` and `.agents/skills/acceptance-criteria-tracking/SKILL.md`. It is the Codex-native mirror of the skill surface. | Yes, for the Codex surface, on the same reading-order grounds as `.github/instructions/**` which is already listed. | **ADD to both copies.** Symmetry argument: `.github/instructions/**` (the Copilot surface) is already excluded; excluding the Copilot mirror and not the Codex mirror is arbitrary. |

**Why these four and not a blanket `.claude/skills/**`.** A blanket subtree exclusion would be actively
harmful *in this repository*, where editing `.claude/skills/*/SKILL.md` is ordinary feature work: the
exclusion would remove genuine write claims from the derived radius, and the planner would have to
re-append each one by hand under bounding constraint 1
(`.claude/rules/parallel-orchestration.md:222-225`). The four named paths are process documents that
unrelated features cite and essentially never write, so the exclusion describes their real relationship.
Bounding constraint 3 (`detect_escaped_paths`, lines 231-234) is the backstop if a plan does write one.

**Why these belong in the self-hosted copy too, contrary to the issue's framing.** With
`claude-runtime` absent from the self-hosted map, an unexcluded skill citation resolves to no module —
but two plans citing the *same* skill file still contend at `path_overlap`
(`BlastRadius.psm1:451-455`, via `Get-SmallestPathOverlap`, lines 345-375). Since
`acceptance-criteria-tracking` is a `required_skills` entry on five of six routes
(`config/orchestration-routing.json:22, 48, 71, 112, 133`), near-universal co-citation is expected, and
the issue measured 6 of 16 plans (`issue.md:46`). The self-hosted gap is real.

`mandate_reads` is in the "must be byte-equal" class of the recommended gate (`## 4.5`), so both copies
must receive the same four additions in the same commit.

---

## 4. How the drift gate should be implemented and what it should assert

### 4.1 Existing parity/drift checks of this class, and the pattern each uses

| Location | Pattern |
| --- | --- |
| `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py:33-56` | Module-level `Path` constants resolved from `Path(__file__).resolve().parents[3]`; single test; `read_bytes()` equality; failure message names both paths and the remedy. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:20, 34-43, 101-126` | `SCOPED_ROOTS` tuple; `rglob("*")` enumeration into sorted relative paths; per-file existence plus `read_text()` equality; documented exemption predicate (`_is_agent_memory_path`, lines 71-98). |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:200-204` | Positive parity plus an explicit negative existence assertion (`assert not BUNDLE_ROUTING_CONFIG.exists()`) to pin *where a copy must not be*. |
| `tests/scripts/dev_tools/test_blast_radius_config.py:474-499` | **Closest precedent.** `COMMITTED_CONFIGS: tuple[tuple[str, Path], ...]` naming both copies with a repo-relative label, `@pytest.mark.parametrize(("label", "path"), COMMITTED_CONFIGS)`, and a per-copy loader (`load_config_file`, lines 86-105). Failure messages carry the label so the offending file is named. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1:52-59, 208-241` | PowerShell mirror; loads both copies in `BeforeAll`; iterates `@($CommittedConfig, $BundledConfig)` accumulating offenders into a `List[string]`; `Should -BeNullOrEmpty`. |
| `tests/scripts/dev_tools/test_codex_topology_policy_config_parity.py:73` | `CONFIG_PATH.read_bytes() == BUNDLED_CONFIG_PATH.read_bytes()`. |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:84-108` | Real-filesystem `Buffer.equals` pin inside an otherwise hermetic suite, with an explicit "Scope note" in the file header (lines 40-48) declaring which case reads real disk. |
| `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:42-64, 216-235` | Real-filesystem walk plus a non-vacuity floor (`MINIMUM_CONFIG_FILE_COUNT = 2`) so a broken glob fails rather than passing empty. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1:26-31, 62-75` | Discover-from-disk rather than restate, then assert manifest membership and bundled-counterpart existence. |

Two conventions to carry into the new gate, both already established: a **non-vacuity floor** (so the
gate cannot pass on an empty enumeration) and a **repo-relative label** in every failure message.

### 4.2 Recommended approach: a three-class key-partition gate

Partition the six top-level keys and assert a different relation for each class.

**Class 1 — must be byte-equal between the two copies:** `version`, `over_breadth_fraction`,
`mandate_reads`.

These are policy values with no repository-specific content. Byte-equality is the strongest available
assertion and it is cheap. It also closes Cause C structurally: the four `mandate_reads` additions cannot
land in one copy only.

**Class 2 — bundled must be a subset of self-hosted AND equal to a declared portable set:**
`shared_surfaces`, `shared_surface_globs`.

Two assertions, not one, and each catches a distinct failure:
- *Subset of self-hosted* catches a bundled entry that the self-hosted table does not recognize (a typo,
  or a divergent spelling of the same intent).
- *Equality with an in-test `PORTABLE_SHARED_SURFACES` frozenset* catches both directions of drift: an
  entry silently dropped (the present defect) and a drm-copilot-specific entry silently added.

The portable set is declared in the test module as a named constant with a one-line rationale per entry,
mirroring how `PRE_EXISTING_UNRELATED_EXCEPTIONS`
(`claude-pack-manifest-completeness.test.ts:66-71`) documents its own membership.

**Class 3 — bundled `modules` must be a subset of `PAYLOAD_MODULES`, and must contain no disqualified
umbrella:** `modules`.

The umbrella list is the five names `.claude/rules/parallel-orchestration.md:250-252` records as removed:
`python-dev-tools`, `vscode-extension`, `claude-runtime`, `copilot-surface`, `agents-surface`. This
extends the existing negative pin at `test_blast_radius_config.py:483-499` from two location-bucket names
to five umbrella names, applied to **both** copies rather than the repository copy only.

**Plus a non-vacuity floor:** assert each parsed key is present and each compared collection is non-empty
where non-emptiness is intended, so a renamed key cannot make the gate pass silently.

**Plus one assertion outside the config files:** `PAYLOAD_MODULES` must not contain `claude-runtime`. This
is the live source of Cause A and it lives in TypeScript, so it is asserted in TypeScript
(`## 4.3`).

### 4.3 Language placement

`.claude/rules/general-unit-test.md` "Test File Location" requires tests to live in a `tests/` tree
mirroring production structure. Applying it to each artifact in scope:

| Artifact changed | Test location | Justification |
| --- | --- | --- |
| `config/blast-radius.json`, `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | **`tests/scripts/dev_tools/test_blast_radius_config.py`** (extend) | Established location for content pins on this exact pair: `COMMITTED_CONFIGS` (lines 477-480) already names both copies, and `load_config_file` (lines 86-105) already parses either. Python is also where the routing parity gates live (`test_orchestration_routing_config_parity.py`, `test_codex_topology_policy_config_parity.py`). |
| Same pair, PowerShell mirror obligation | **`tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`** (extend) | The file already loads both copies (lines 52-59) and already runs a both-copies negative pin (lines 208-241). The PowerShell library is the destination runtime that consumes the published table, so the mirror must agree with the Python reference — the two-language-mirror obligation stated at `.claude/lib/blast-radius/BlastRadiusConfig.psm1:13-17`. Its 269 lines leave room under the 500-line limit. |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` (`PAYLOAD_MODULES`) | **`extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts`** (update) | Exact mirror of the production path; already pins `PAYLOAD_MODULES` at lines 470-477. |
| End-to-end publish behaviour | **`extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts`** and/or `claude-config-carriage.test.ts` (update) | Existing homes for the decorator and carriage behaviour. |

**More than one language is required, and the reason is not symmetry for its own sake.** The bundled
config is data consumed by two runtimes (the TypeScript push-down that ships it and the PowerShell
library that reads it in the destination), and `PAYLOAD_MODULES` is TypeScript-only. A Python-only gate
would not see the `claude-runtime` injection at all. A note on `.claude/rules/shell.md`: no bash gate is
warranted, because `.claude/lib/bash/` contains no blast-radius implementation (globbed:
`compute-cohorts.sh`, `compute-concurrency-batches.sh`, `parallel-cohorts.sh`, `parallel-common.sh`,
`parallel-items-validate.sh`, `parallel-manifest-validate.sh`, `parallel-yaml-emit.sh`,
`parallel-yaml-scan.sh`, `validate-parallel-manifest.sh`) and no bash file references
`blast-radius.json`.

### 4.4 How to express the "explicitly declared, reviewable delta" — three options weighed

**Option A — extend `SCOPED_ROOTS` to `config/` and require byte-identity.**

Simplest and strongest, and it is what `config/orchestration-routing.json` already does. **Rejected**
because it forces drm-copilot-specific content into every destination: byte-identity would carry
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`,
`extensions/drm-copilot/resources/config/orchestration-routing.json`, and the three
`scripts/dev_tools/*.py` globs into a destination whose layout contains none of them, and would restore a
7-module map that the derivation then discards. It also directly contradicts the documented design
purpose of the derivation (`claude-customizations.ts:52-65`).

**Option B — a checked-in expected-delta manifest file** (for example
`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.delta.json`) that the gate
diffs against.

**Rejected.** It adds a third artifact whose own staleness is unguarded — the failure mode that produced
this bug reappears one level up. It also has no consumer at runtime, so nothing except the gate would
ever read it, and `.claude/rules/plan-acceptance-gates.md` ("Scope of Invocation") records this
repository's position that a suppression or exception artifact whose only reachable use is to silence the
gate currently being authored is a liability.

**Option C — a generated-from-source bundled file plus a "regeneration is a no-op" gate.**

A script would read `config/blast-radius.json`, apply a declared portability filter, and emit the bundled
document; the gate would assert regeneration produces byte-identical output. This is the option that best
survives the next push-down, because a future self-hosted change flows through the filter automatically.

**Rejected for this fix, recommended as a follow-up.** It adds a production script plus its own tests
(and its own tier obligations) to a bug fix, against
`.github/instructions/general-code-change.instructions.md:36-37` ("Change only what is needed ... avoid
opportunistic refactors"). Its central asset — the declared portability filter — is exactly the
`PORTABLE_SHARED_SURFACES` constant that Option D introduces as data. Option D can be promoted to Option
C later by moving that constant from the test into a generator, with no change to what is asserted.

**Option D — RECOMMENDED: the three-class key-partition gate of `## 4.2`, with the portable set declared
as a named test constant.**

- The delta is explicit: three named classes, one named portable-set constant, one named umbrella-denylist
  constant. A reviewer reading the test knows exactly which key may differ and why.
- The delta is reviewable: changing what is permitted to differ requires editing a named constant in a
  test, which appears in the diff and cannot be done by editing the config alone.
- No new production artifact, no new suppression surface, no new file whose staleness is unguarded.
- It extends two files that already read both copies, so it follows the established pattern rather than
  inventing one.
- **Survival across the next push-down:** the bundled file is not a push-down destination — it is the
  push-down *source*, so nothing overwrites it. The durability question is whether a future self-hosted
  change silently fails to reach it, and Class 1 (byte-equality for `mandate_reads`) plus Class 2
  (equality with the declared portable set) both fail loudly in that case. Option C would additionally
  remove the manual step; Option D only guarantees that skipping the manual step is caught.

### 4.5 What the gate asserts, enumerated

1. Both copies parse to JSON objects and declare `version == 1`. *(Extends the existing pin at
   `test_blast_radius_config.py:167-177` to the bundled copy.)*
2. `version`, `over_breadth_fraction`, and `mandate_reads` are equal between the two copies.
3. Bundled `shared_surfaces` equals the declared `PORTABLE_SHARED_SURFACES` constant (as a set), and is
   a subset of self-hosted `shared_surfaces`.
4. Bundled `shared_surface_globs` is empty, and is a subset of self-hosted `shared_surface_globs`
   (vacuously true, asserted so a future non-empty bundled value must be justified).
5. Bundled `modules` key set is a subset of the `PAYLOAD_MODULES` name set.
6. Neither copy declares any of the five disqualified umbrella module names, nor either
   location-bucket glob. *(Extends the existing two-name pin to five names, both copies.)*
7. Every separator-free bundled `shared_surfaces` entry is wildcard-free. *(Extends the existing
   self-hosted-only pin at `test_blast_radius_config.py:269-287` to the bundled copy; a wildcard-bearing
   separator-free entry would be admitted by `Get-ConfigRootSurface` yet classified as a glob, silently
   breaking root-token extraction.)*
8. Non-vacuity floor: each compared collection that is intended to be non-empty is non-empty, and
   `COMMITTED_CONFIGS` has exactly two members.
9. (TypeScript) `PAYLOAD_MODULES` does not contain `claude-runtime`, and its glob set contains no member
   of `FORBIDDEN_GLOBS`.
10. (TypeScript) A publish into a destination with no observable layout emits a `modules` map whose keys
    do not include `claude-runtime`.

### 4.6 Existing tests: what each asserts and whether the fix changes it

| Test | Asserts today | Impact of the fix |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_config.py` | Version `1` (167-177); non-vacuity of three collections (180-191); every module has ≥1 glob (194-205); `over_breadth_fraction` in `(0,1]` (208-225); every shared surface repo-relative (228-246); every glob has a wildcard (249-258); every separator-free surface wildcard-free (269-287); two disjoint items do not contend (346-379); three behaviour-preservation matrix cases (407-463); no location-bucket module in either copy (483-499). All module-level pins read the **self-hosted** copy via `CONFIG` (line 157). | **Extended, not broken.** Adding `mandate_reads` entries does not affect any existing assertion. Adding three `shared_surfaces` entries: line 228 (repo-relative) passes for all three; line 269 (separator-free wildcard-free) passes for all three; line 180 non-vacuity unaffected. The three matrix cases (407-463) cite `scripts/benchmarks/example_shared.py`, `tests/scripts/dev_tools/test_example_shared.py`, and `config/blast-radius.json` — none of the new entries, so all three are unaffected. **New tests appended per `## 4.5`.** |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | Version (62-67); module map non-empty (70-73); **exactly the seven ratified modules** (75-89); no removed umbrella in the repository table (91-111); every module has ≥1 glob (113-121); fraction in `(0,1]` (124-134); surfaces and globs both non-empty (137-141); surfaces repo-relative (143-155); globs wildcard-bearing (157-167); separator-free surfaces wildcard-free (169-184); `mandate_reads` non-empty and blank-free (188-198); `quality-tiers.yml` in both lists (200-205); no location bucket in either copy (208-241); disjoint items do not contend (243-268). | **Extended, and one comment must be corrected.** No assertion breaks: the seven-module pin (75-89) reads the self-hosted copy, which is unchanged; the surface additions satisfy 143-184. The comment at lines 96-98 asserting that the bundled module map "describes the DESTINATION repository's subsystems" is factually wrong (`## 1.4`) and must be rewritten, and the umbrella pin extended to both copies. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` | Every `.claude/lib/blast-radius/*.psm1` is listed in `core.json` paths (44-50); the facade appears exactly once (52-59); a bundled counterpart exists for each module (63-74). | **No change.** No library module is added or renamed by this fix. |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | Both config files published on a plain publish (51-63) and under `--packs core` (65-77); `ROOT_FOLDERS == [".claude","config"]` (79-82); **routing byte-identity across repo root and Claude bundle (84-108)**; six routing-merge cases (111-265); **published blast-radius is generic — must contain `"src/App"` and must NOT contain `"**"`, `"docs/**"`, `"tests/**"`, `scripts/dev_tools`, `packages/mcp-server`, `poetry.lock`, `package-lock.json` (268-295)**; blast-radius overwritten not merged (297-321); Copilot/Codex publish no config (324-379); payload-only publish clears four blockers (381-401). | **Must be updated.** (a) If the `poetry.lock` / `package-lock.json` additions are adopted, the forbidden list at lines 284-293 must drop those two names and its rationale comment must be rewritten to say "no entry naming this repository's directory layout" (see the disclosed tension in `## 3.1`). (b) The seeded `SOURCE_BLAST_RADIUS` constant in `config-carriage.test-helpers.ts:74-91` and its 61-72 comment must be updated to mirror the corrected bundled file. |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | Among others: root-manifest exclusion floor `["claude-runtime","config"]` (127-139); nested-project case `["claude-runtime","config","service"]` (141-157); ordinal sort `["Alpha","alpha","beta","claude-runtime","config"]` (321-341); carried-key equality and `mandate_reads` omission (260-295); non-object source throws (443-451); **`PAYLOAD_MODULES` pinned to `{claude-runtime, config}` (470-477)**. | **Must be updated.** Every expectation naming `claude-runtime` changes (lines 137, 152-156, 334-340, 473-476). This is the mechanical bulk of the fix and the file is its correct home. |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | Decorator behaviour with seeded documents at lines 41-44, 114-124, 292, 387; `mandate_reads` carriage verbatim, emission order, and omission (425-475). | **Must be updated** wherever a seeded expectation names `claude-runtime` (41-44, 118-124, 292, 387). The `mandate_reads` carriage suite (425-475) is unaffected by content changes because it asserts a seeded round-trip, not a specific list. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `.claude/**` byte parity (101-126) and five scope-boundary assertions (129-213). | **No change required** by the recommended approach. Note for the executor: because line 101-126 enforces `.claude/**` byte parity, **any edit to `.claude/rules/parallel-orchestration.md` must be mirrored into `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` in the same commit**, or this test fails. |
| `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` | Manifest completeness for `.claude` agents/hooks/skills/rules/lib (199-214) and `config/` (216-235); required-path membership (237-272). | **No change.** No file is added to or removed from the bundle. |
| `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`, `test_codex_topology_policy_config_parity.py`, `test_push_down_codex_and_agents_resource_contracts.py` | Routing byte-identity for pairs 3 and 4 of the inventory. | **No change.** Question 2 confirms these pairs are already in parity; the recommended gate does not touch routing. |

---

## 5. Reproduction and Verification Commands

**STATUS: NOT EXECUTED.** No execution tool was available in this thread (see `## Tooling Limitation`).
Each command below is constructed from the exact parameter contracts cited beside it. The planner must
treat every one as an executor obligation, not as evidence.

Every command runs from the worktree root `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16`
under PowerShell 7.

### 5.1 Fail-closed: false `module_overlap` against the BUNDLED truth table

Contracts fixing this command: `Get-BlastRadius` parameters `-PlanText`, `-SpecText`, `-FeatureFolder`,
`-Config`, `-ComputedAt` (`.claude/lib/blast-radius/BlastRadius.psm1:142-161`); `Test-BlastRadiusConflict`
parameters `-RadiusA`, `-RadiusB`, `-Config` (`BlastRadius.psm1:432-444`); `-AsHashtable` required
because `Get-RequiredMapping` accepts a hashtable, an `IDictionary`, or a `PSCustomObject`
(`BlastRadiusConfig.psm1:170-192`); result keys `conflict` and `reasons` (`BlastRadius.psm1:470-473`);
reason keys `kind` and `detail` (`BlastRadius.psm1:454`, `466`).

```powershell
Import-Module ./.claude/lib/blast-radius/BlastRadius.psm1 -Force
$bundled = Get-Content -Raw `
  ./extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json |
  ConvertFrom-Json -AsHashtable
$a = Get-BlastRadius -PlanText '- [ ] [P1-T1] Edit `.claude/hooks/enforce-mermaid-validation.ps1`.' `
  -SpecText '' -FeatureFolder '2026-08-21-item-a' -Config $bundled -ComputedAt '2026-08-21T17-16'
$b = Get-BlastRadius -PlanText '- [ ] [P1-T1] Edit `.claude/skills/parallel-add/SKILL.md`.' `
  -SpecText '' -FeatureFolder '2026-08-21-item-b' -Config $bundled -ComputedAt '2026-08-21T17-16'
$r = Test-BlastRadiusConflict -RadiusA $a -RadiusB $b -Config $bundled
"conflict = $($r['conflict'])"
$r['reasons'] | ForEach-Object { "  $($_['kind']) : $($_['detail'])" }
```

Predicted result, derived from the code: `conflict = True` with a single reason
`module_overlap : claude-runtime`. Derivation of the prediction:
`Get-PathTokenKind` accepts both tokens (`.claude/` is a known top-level segment,
`BlastRadiusExtraction.psm1:64-67`; `.ps1` and `.md` are recognized extensions, lines 82-88; both are
wildcard-free with a recognized extension, so line 368-369 returns `concrete`). Neither survives the
mandate-read filter check as an exclusion, because `.claude/rules/**` does not match a hook or a skill
path (`BlastRadiusNormalization.psm1:223-239`). `Resolve-BlastRadiusModule` then matches
`claude-runtime -> .claude/**` for both radii (`BlastRadiusNormalization.psm1:164-181`), and
`Get-SmallestCommonEntry` returns `claude-runtime` (`BlastRadius.psm1:379-402`), producing the
`module_overlap` reason. The two feature-folder globs differ, so no `path_overlap` fires.

### 5.2 Negative control: the same pair against the SELF-HOSTED truth table

```powershell
$self = Get-Content -Raw ./config/blast-radius.json | ConvertFrom-Json -AsHashtable
$a2 = Get-BlastRadius -PlanText '- [ ] [P1-T1] Edit `.claude/hooks/enforce-mermaid-validation.ps1`.' `
  -SpecText '' -FeatureFolder '2026-08-21-item-a' -Config $self -ComputedAt '2026-08-21T17-16'
$b2 = Get-BlastRadius -PlanText '- [ ] [P1-T1] Edit `.claude/skills/parallel-add/SKILL.md`.' `
  -SpecText '' -FeatureFolder '2026-08-21-item-b' -Config $self -ComputedAt '2026-08-21T17-16'
(Test-BlastRadiusConflict -RadiusA $a2 -RadiusB $b2 -Config $self)['conflict']
```

Predicted result: `False`. The self-hosted map has no glob covering `.claude/**`
(`config/blast-radius.json:29-35`). This control is what makes 5.1 attributable to the truth table rather
than to the relation.

### 5.3 Fail-open: two items editing the same separator-free root token report no conflict

Contract fixing this command: `Get-ConfigRootSurface` returns only the separator-free `shared_surfaces`
entries (`BlastRadiusConfig.psm1:266-280`); `Get-PathTokenKind` drops a token with no `/` unless it is an
exact ordinal member of that set (`BlastRadiusExtraction.psm1:328-342`).

```powershell
$plan = '- [ ] [P1-T1] Edit `Directory.Build.targets` and `coverage.config`.'
$x = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder '2026-08-21-item-x' `
  -Config $bundled -ComputedAt '2026-08-21T17-16'
$y = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder '2026-08-21-item-y' `
  -Config $bundled -ComputedAt '2026-08-21T17-16'
"root surfaces  : $((Get-ConfigRootSurface -Config $bundled) -join ', ')"
"x paths        : $($x['paths'] -join ', ')"
"conflict       : $((Test-BlastRadiusConflict -RadiusA $x -RadiusB $y -Config $bundled)['conflict'])"
```

Predicted result: `root surfaces` empty; `x paths` containing only
`docs/features/active/2026-08-21-item-x/**` (the feature-folder glob added unconditionally at
`BlastRadius.psm1:186-188`); `conflict : False`. Both root tokens are dropped before resolution.

### 5.4 Fail-open contrast: the same token pair against the SELF-HOSTED table

```powershell
$plan2 = '- [ ] [P1-T1] Edit `package-lock.json`.'
$p = Get-BlastRadius -PlanText $plan2 -SpecText '' -FeatureFolder '2026-08-21-item-p' `
  -Config $self -ComputedAt '2026-08-21T17-16'
$q = Get-BlastRadius -PlanText $plan2 -SpecText '' -FeatureFolder '2026-08-21-item-q' `
  -Config $self -ComputedAt '2026-08-21T17-16'
$rr = Test-BlastRadiusConflict -RadiusA $p -RadiusB $q -Config $self
"conflict = $($rr['conflict'])"
$rr['reasons'] | ForEach-Object { "  $($_['kind']) : $($_['detail'])" }
```

Predicted result: `conflict = True` with `path_overlap : package-lock.json ~ package-lock.json` and
`shared_surface_overlap : package-lock.json`. `package-lock.json` is a separator-free self-hosted shared
surface (`config/blast-radius.json:8`), so `Get-ConfigRootSurface` admits it and the extractor accepts the
token. This is the behaviour the bundled table currently cannot produce for any token, and it is the
positive control for the fix.

### 5.5 Toolchain commands (per `.claude/rules/python.md`, `typescript.md`, `powershell.md`)

```powershell
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py `
  tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py `
  tests/scripts/dev_tools/test_orchestration_routing_config_parity.py `
  --cov=scripts.dev_tools --cov-branch --cov-report=term-missing
```

The `--cov` value is written as an importable dotted name with the `=` form, per
`.claude/rules/plan-acceptance-gates.md` ("Authoring Guidance for Plan Authors") and rules G1 through G4.

TypeScript (from `extensions/drm-copilot`):

```powershell
npm run format ; npm run lint ; npm run typecheck ; npm run test:unit
```

PowerShell: use the MCP functions `mcp__drm-copilot__run_poshqc_format`,
`mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`, per
`.claude/rules/powershell.md` ("Use the MCP server functions; do not substitute VS Code task wrappers").

---

## 6. Module rigor tier and coverage obligations

### 6.1 The tier map named as authoritative does not exist

`.claude/rules/quality-tiers.md` names `quality-tiers.yml` at the repository root as the source of truth
and `docs/ci.research.md` section 1 as the tier-system definition. **Neither file exists** (`## 2.3`).
The tier of each file in scope therefore cannot be read; it must be inferred from the tier definitions in
the rule prose. This is stated as an inference, not a lookup.

### 6.2 Inferred tiers

| File in scope | Inferred tier | Basis |
| --- | --- | --- |
| `config/blast-radius.json` | T4 | Configuration data. `.claude/rules/quality-tiers.md` "Tiers" lists "build scripts, dev tooling, generated code, manifests" under T4. Not executable, so it carries no coverage denominator of its own. |
| `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | T4 | As above. |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | T4 | Push-down publishing tooling — "dev tooling" under the T4 examples. It is nonetheless pure logic with no I/O (its own header, lines 21-27, states "no `fs`, no `child_process`, no network, and no clock or randomness access"), so it is fully unit-testable and there is no coverage-exclusion argument available for it. |
| `.claude/rules/parallel-orchestration.md` and its bundled mirror | n/a | Markdown documentation; exempt from the 500-line limit per `.claude/rules/general-code-change.md` "File Size Limit" and carrying no coverage obligation. |
| Test files under `tests/scripts/dev_tools/`, `tests/scripts/claude-lib/`, `extensions/drm-copilot/test/` | n/a | Test code; excluded from the coverage denominator per the "Permitted `exclude` entries" list in `.claude/rules/general-unit-test.md`. |

### 6.3 Resulting obligations

**Uniform, applying regardless of tier** (`.claude/rules/quality-tiers.md`, "Uniform across all tiers"):

- Format check 100% pass; lint errors 0; type errors 0; architecture violations 0.
- **Line coverage >= 85%**, **branch coverage >= 75%** for Python and TypeScript.
- PowerShell: line >= 85% only. Pester measures no branch coverage, so no branch gate applies
  (`.claude/rules/quality-tiers.md`, "Rationale"; `.claude/rules/powershell.md`, "Testing Standards").
- **No coverage regression on changed lines.** This is the binding constraint here: the TypeScript change
  edits an exported constant in a module whose test file already exists, so any drop in that file's
  measured coverage is a blocking finding.

**Tier-dependent, at T4:**

- Untyped escape hatches: unlimited by the matrix. Not exercised — no `any` is introduced, and
  `.claude/rules/typescript.md` requires avoiding `any` independently.
- **Property-based tests: NOT required.** The matrix requires ">= 1 per pure function" only at T1 and T2.
  Recorded explicitly because `claude-blast-radius-derive-core.ts` is a pure module and would attract a
  property-test obligation if it were T1/T2.
- **Mutation score: NOT required** (T1 only).
- **Golden tests: NOT required** (T1 classifier-output modules only).
- Contract breaking changes: `n/a` at T3/T4 per the matrix. Note nonetheless that `PAYLOAD_MODULES` and
  the bundled config content are consumed across a repository boundary (they reach destination
  workspaces), so the change is a behaviour change for destinations and must be described as such in the
  PR body even though no version bump is demanded by the matrix.
- Determinism (retry rate): `n/a` at T4. The derivation's own byte-stability pin
  (`blast-radius-derive-core.test.ts:343-357`) must still pass.

**Coverage Exclusion Policy** (`.claude/rules/general-unit-test.md`): no production file may be excluded.
No `exclude` entry is added or needed by this fix.

---

## Recommended Fix Shape (one approach, for the planner)

Four coordinated edits plus gates. Ordered so each is independently verifiable.

1. **Remove `claude-runtime` from `PAYLOAD_MODULES`** —
   `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:131-135` becomes
   `{ config: ["config/**"] }`, with its doc comment (lines 123-130) rewritten to state why the `.claude`
   tree is not a module. Update `blast-radius-derive-core.test.ts` lines 137, 152-156, 334-340, 473-476,
   and `blast-radius-derive.test.ts` lines 41-44, 118-124, 292, 387. Add the assertion of `## 4.5` item 9.
   *This is the fail-closed half; it is the whole of Cause A.*

2. **Correct the bundled config** —
   `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`: expand
   `shared_surfaces` to the six portable entries of `## 3.1`; keep `shared_surface_globs` empty; add the
   four `mandate_reads` entries of `## 3.3`; reduce `modules` to `{ "config": ["config/**"] }`.
   *This is the fail-open half; it is Cause B.*

3. **Add the four `mandate_reads` entries to the self-hosted config** — `config/blast-radius.json:20-27`.
   *This is Cause C, and it is what Class 1 of the gate then holds in place.*

4. **Amend `.claude/rules/parallel-orchestration.md`** — record, under the Blast-Radius Contention
   Doctrine, that (a) the destination module map is derived and the bundled `modules` key is not consumed,
   (b) `PAYLOAD_MODULES` carries `config` only and `claude-runtime` is disqualified in a destination by
   the same granularity criterion that removed it here, and (c) the bundled `shared_surfaces` and
   `shared_surface_globs` sets are the destination-portable subset, with the surfaces/modules asymmetry of
   `## 3.0` as the stated reason. **Mirror the same edit into
   `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`** or
   `test_push_down_claude_resource_contracts.py:101-126` fails.

5. **Add the gate** — extend `tests/scripts/dev_tools/test_blast_radius_config.py` with the ten
   assertions of `## 4.5` items 1-8, and extend
   `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` with the mirror of items 2,
   5, 6, and 7, correcting the incorrect comment at its lines 96-98.

6. **Regression test proving the fix** — per
   `.github/instructions/general-code-change.instructions.md:31-33` (failing regression test first): a
   test that derives two radii citing unrelated `.claude/**` files against the **published** document and
   asserts `conflict=False`, plus a test that two items citing the same separator-free root surface
   report `conflict=True`. The natural home for the first is the TypeScript publish path; for the second,
   `test_blast_radius_config.py` parametrized over both copies.

### Rejected alternatives (brief)

- **Byte-identity for `config/**` (extend `SCOPED_ROOTS`).** Rejected: forces drm-copilot-specific paths
  and a discarded 7-module map into every destination, and contradicts the documented purpose of the
  derivation. `## 4.4` Option A.
- **A checked-in expected-delta manifest.** Rejected: introduces a third artifact whose own staleness is
  unguarded, reproducing the present failure one level up, and adds a suppression surface with no runtime
  consumer. `## 4.4` Option B.
- **Generated-from-source bundled file with a regeneration no-op gate.** Rejected *for this fix* as scope
  widening on a bug (a new production script plus its tests), and recommended as the follow-up that
  Option D is designed to be promoted into. `## 4.4` Option C.
- **A blanket `.claude/skills/**` mandate-read entry instead of four named paths.** Rejected: skill
  documents are ordinary feature-work targets in this repository, so a blanket exclusion would strip
  genuine write claims from derived radii. `## 3.3`.
- **Fixing the two files named in the original report downstream (in TaskMaster).** Rejected by the issue
  itself (`issue.md:107-109`): both are push-down destinations and the next push-down would destroy the
  fix. Recorded here because it is the intuitive move and it is wrong.

## Out of Scope (do not widen)

- The placeholder-extraction defect in `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`
  (`Get-PlanPaths` harvesting `<FEATURE>/spec.md`) — filed separately (`issue.md:111-114`).
- The Python/TypeScript push-down `ROOT_FOLDERS` divergence (`## 1.5`) — file as a follow-up.
- The absence of `quality-tiers.yml` and `docs/ci.research.md` (`## 2.3`) — file as a follow-up.
- The absence of a merge decorator for `config/blast-radius.json`, which means destination-local
  `shared_surfaces` additions are destroyed on every push
  (`claude-config-carriage.test.ts:297-321` pins the overwrite) — file as a follow-up; it is the
  structural reason the portable set must be correct upstream.
- Parity coverage for inventory pairs 6 and 7 (`.github/**`, `.mcp.json`) — not located during this
  research; file as a follow-up rather than assume either state.

## Executor Verification Obligations

Because this thread had no execution tool, the following must be run and recorded as evidence under
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/`:

1. `git log --follow -- config/blast-radius.json` and
   `git log --follow -- extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`,
   to identify the commit at which the two histories diverged and confirm the `## 1.2` mechanism.
2. Every command in `## 5`, with its real exit code and output, into
   `evidence/regression-testing/` (fail-before) and `evidence/qa-gates/` (pass-after), per
   `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` ("Evidence Artifact Schema").
3. A byte compare of inventory pair 4 (`fc /b` or `Get-FileHash`) to confirm independently of the TS test.

## Automation Feasibility

**Every step of the planned fix and of its verification is automatable. No human interaction is
required.** Justification, step by step:

- **Diagnosis** — pure file reads and PowerShell module invocation. No UI.
- **Edits** — four JSON/TypeScript/Markdown files plus test files. No UI.
- **Verification** — `poetry run` (Black, Ruff, Pyright, Pytest), `npm run` (Prettier, ESLint, tsc,
  Jest), and the PoshQC MCP functions. All are non-interactive CLI or MCP calls. The blast-radius
  reproduction runs in-process in PowerShell 7 against pure functions: `.claude/lib/blast-radius/`
  performs "no filesystem, subprocess, network, or wall-clock access"
  (`BlastRadiusConfig.psm1:16-17`), and `computed_at` is caller-supplied
  (`BlastRadius.psm1:23-24`), so no wait, poll, or approval step exists.
- **Third-party UI** — none is touched. The push-down is exercised through the in-process TypeScript port
  with an injected filesystem (`claude-customizations.ts:235-315`), never through the VS Code UI. No
  GitHub web UI step is needed: PR creation and CI monitoring go through `gh`.
- **The one item that is *not* automatable is a decision, not a step:** the disclosed tension in `## 3.1`
  over whether `poetry.lock` and `package-lock.json` belong in the destination-portable set requires a
  human policy judgment, because it narrows a forbidden-substring list an earlier feature deliberately
  set (`claude-config-carriage.test.ts:284-293`). Both branches are named with their consequences, so the
  planner can decide from this document without a live interaction; if the planner prefers not to decide,
  the conservative branch (add `quality-tiers.yml` only) is fully specified and independently sufficient
  to restore separator-free root-token extraction.

EVIDENCE_LOCATION_OVERRIDE_REJECTED: none. No non-canonical evidence path was supplied to this agent, and
this artifact is a research note written to the orchestrator-supplied research path, not evidence.
