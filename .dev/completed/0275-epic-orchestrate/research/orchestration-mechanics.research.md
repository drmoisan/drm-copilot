---
Timestamp: 2026-07-02T19-45
Feature: epic-orchestrate (Issue #275)
Scope: Mechanics research supporting spec.md items 3, 4, 6, 8, and the "Bundled mirror parity" section.
---

# Orchestration Mechanics Research — epic-orchestrate (#275)

This artifact reports verified, file:line-anchored findings for six mechanics questions raised by
`docs/features/active/2026-07-02-epic-orchestrate-275/spec.md`. It does not make final design
recommendations; that is the spec-writer's / planner's responsibility.

## 1. Base-branch hardcoding

### `pr-base-branch-merge-base` skill

`.claude/skills/pr-base-branch-merge-base/SKILL.md` does **not** assume a single hardcoded trunk as
the primary selection rule. Its `Selection Contract` (lines 17–23) and `Deterministic Procedure`
(lines 25–35) resolve `PRBaseBranch` purely from merge-base ancestry across all local/remote
candidate branches:

```
19	`PRBaseBranch` MUST be resolved from git ancestry, not guessed.
...
31	4. Select branch with maximum `merge_base_epoch(B)`.
32	5. Tie-breakers (in order):
33	   - `development`
34	   - `main`
35	   - `master`
```

`main` appears only as a **tie-breaker (position 2 of 3)** and as the last-resort fallback:

```
39	- Do not default to `main` unless merge-base resolution fails for all candidates.
```

This means the skill's core algorithm is branch-name-agnostic and would correctly resolve an
`epic/<slug>-integration` branch as `PRBaseBranch` if that branch has the most recent common
ancestor with `HEAD` — no code change to the selection algorithm itself is implied by epic mode.

### `pr-context-artifacts` skill and the `collect_pr_context` MCP tool

`.claude/skills/pr-context-artifacts/SKILL.md` (lines 22–29) requires an **explicit** `PRBaseBranch`
input and forbids inferring the refresh base from the repository default branch unless merge-base
resolution fails for all candidates. The MCP tool itself is fully parameterized, not hardcoded:

- `extensions/drm-copilot/src/mcp-tool-definitions.ts:35-51` — `collect_pr_context` input schema
  declares `base` as `required: ["base"]` with description "Explicit base branch or ref used for PR
  context collection." No default value is present.
- `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts:35-46,68-92` —
  `CollectPrContextServiceCallInput.base` is a required field threaded straight into
  `collectAndWrite({ base: input.base, ... })`; there is no fallback literal for `"main"` anywhere in
  this file.

**Caveat found:** `extensions/drm-copilot/src/pr-context-branches.ts` (a separate, VS Code
quick-pick-driven branch-discovery helper used by an interactive command, not by the headless MCP
`collect_pr_context` path) contains a hardcoded priority ranking:

```
56	export function scoreBranchForPriority(branchName: string): number {
58	  if (branchName === "main") {
59	    return 0;
60	  }
61	  if (branchName === "master") {
62	    return 1;
63	  }
64	  if (branchName === "develop") {
65	    return 2;
66	  }
67	  if (branchName === "trunk") {
68	    return 3;
69	  }
70	  if (/^release([/.-]|$)/.test(branchName)) {
71	    return 4;
72	  }
73	  return 5;
74	}
```

`discoverPrBaseBranches` (lines 113–188) still enumerates *all* remote/local refs as candidates (an
`epic/<slug>-integration` branch would appear in the list), but this scoring function would rank it
into the lowest-priority bucket (score 5) behind `main`/`master`/`develop`/`trunk`/`release*` when
computing the UI's suggested default. This file is interactive-UI-only (drives
`vscode.window.showQuickPick`, line 212) and is not in the orchestrator's automated S9/PR-creation
code path, so it does not block epic-mode automation, but it is a hardcoded-trunk-bias artifact
worth knowing about if any future automation reuses this helper for default-branch suggestion.

### `feature-review-workflow` skill and `feature-review` agent

`.claude/skills/feature-review-workflow/SKILL.md` "Ordered Procedure" step 1 (lines 79–82) resolves
the base branch the same way: use the supplied base branch when present, otherwise resolve via
`pr-base-branch-merge-base`. No literal `"main"` appears in this file except inside the words
"remediation" (not `grep`-matched) — a targeted grep for `main` in this file returned only that
transitive reference from `pr-base-branch-merge-base`'s own tie-breaker text quoted above; the
skill file itself hardcodes nothing.

`.claude/agents/feature-review.md` "Scope Invariant" section (lines 73–92) explicitly names "The
resolved base branch from `pr-base-branch-merge-base`" as the sole legitimate scope source (line
89) — again parameterized, not hardcoded.

### Where hardcoding-by-omission actually exists: `gh pr create`

`.claude/skills/pr-author/SKILL.md` and `.claude/agents/pr-author.md` (both read in full) describe
the mandatory PR-creation sequence and neither ever mentions a `--base` flag on `gh pr create`:

- `.claude/skills/pr-author/SKILL.md:66-67` — "Pass the body to the pull request via `--body-file
  artifacts/pr_body_<N>.md`; do not use inline `--body`." No `--base` is specified.
- `.claude/agents/pr-author.md:54-58` — "Issue the command immediately, passing the body via
  `--body-file`: `gh pr create --body-file artifacts/pr_body_<N>.md`." No `--base` is specified here
  either, and no other section of the agent file mentions `--base`.

Without an explicit `--base`, `gh pr create` falls back to the GitHub repository's configured default
branch (`main` in this repo) or to the branch the local branch is tracking. This is the one place in
the reviewed surface where the *absence* of a base-branch parameter, rather than a hardcoded literal,
is the risk: today `gh pr create` has no mechanism to target anything other than the implicit default
branch. Epic mode requires the PR to target `epic/<slug>-integration` instead of `main`, which means
`gh pr create` needs an explicit `--base <integration-branch>` argument threaded from the resolved
`PRBaseBranch` (or an epic-mode override) into the pr-author agent's command.

**Conclusion:** The `pr-base-branch-merge-base` skill's ancestry-based selection algorithm is already
branch-name-agnostic (aside from a `main`/`master` position in a 3-way tie-breaker and a
last-resort-only fallback), and `feature-review`/`feature-review-workflow`/`collect_pr_context` all
consume that resolved value without independently hardcoding `main`. The concrete gap for epic mode
is that `gh pr create` (invoked only by `pr-author`, per `.claude/agents/pr-author.md:27-29`) is never
passed an explicit `--base` argument anywhere in the current skill/agent text, so it implicitly
targets the repository default branch; this is the parameter that needs a base-branch-override input
for epic mode. `pr-context-branches.ts`'s `scoreBranchForPriority` is a secondary, UI-only,
hardcoded-trunk-bias artifact outside the automated orchestration path.

## 2. Checkpoint validator extension points

### `scripts/dev_tools/validate_orchestrator_state.py` (read in full, 471 lines)

Structure:
- Module-level constants: `REQUIRED_STATE_KEYS` (lines 40-63), `VALID_STEP_STATUS` (64-73),
  `VALID_BLOCKED_REASONS` (74-82), `REQUIRED_RECEIPT_KEYS` (83-92), promotion-receipt namespace
  constants (93-98), `CI_GATE_KEYS` (99), remediation-loop constants (100-109).
- `_validate_remediation_cycle(index, cycle)` (112-173) — per-cycle invariant checks.
- `_validate_remediation_loop(remediation_loop)` (176-198) — iterates `cycles[]`.
- `_missing_object_keys(value, keys)` (201-210) — generic missing/blank-key helper.
- `_validate_completion_ci_gate(state)` (213-244) — validates the `ci_gate` object and cross-checks
  `ci_gate.head_sha == pr_gate.head_sha`.
- `_validate_list_delegation_receipts` / `_validate_namespaced_delegation_receipts` (247-343) —
  legacy list vs. namespaced `delegation_receipts` shapes.
- **`validate_orchestrator_state_text(text, *, require_complete=False, strict_route_membership=False)`**
  (346-470) — the single public entry point. It:
  1. Parses JSON (380-386).
  2. Checks `REQUIRED_STATE_KEYS` presence (391-393).
  3. Checks step-status enum membership for `step5_status`..`step10_status` (395-405).
  4. Checks `blocked_reason` enum (407-409).
  5. Dispatches `delegation_receipts` shape validation (411-426).
  6. Conditionally validates `remediation_loop` (428-431) and `human_interaction` (433-436) — both
     **additive, keyed-presence-gated** blocks (only validated when the key exists in the checkpoint).
  7. Calls `validate_route_membership` unconditionally but only appends its errors when
     `strict_route_membership=True` (438-443).
  8. When `require_complete=True`, additionally requires all step statuses to be completion-safe,
     `blocked_reason == "none"`, and calls `validate_completion_pr_gate`, `_validate_completion_ci_gate`,
     `validate_phase_completeness`, and `validate_routing_contract` (445-468).

This file validates only the **existing** `orchestrator-state` artifact type (the per-feature
checkpoint at `artifacts/orchestration/orchestrator-state.json`). It has no artifact-type dispatch of
its own — dispatch lives one layer up, in `validate_orchestration_artifacts.py`.

### `scripts/dev_tools/_orchestrator_state_routing.py` (read in full, 478 lines)

This module holds routing/receipt logic consumed by `validate_orchestrator_state.py`:
- `ROUTING_MATRIX_PATH` (line 9-11) resolves `config/orchestration-routing.json` from the module's own
  location (`parents[2]`), i.e. it is hardwired to *this repo's* single routing matrix file, not to a
  parameterizable path.
- `load_routing_matrix(path=ROUTING_MATRIX_PATH)` (21-25).
- `_selected_route_id(state)` (28-52) — reads `route_id`, falling back to `path_selected`.
- `route_requires_pr_gate` (55-96), `validate_route_membership` (99-142), `validate_phase_completeness`
  (145-199, uses the static `MANDATORY_ROUTE_PHASES` map, currently only `"small"` is populated at
  line 16-18) — **routes without an entry in `MANDATORY_ROUTE_PHASES` impose no mandatory-phase
  requirement**, so a new `epic` route needs no change here unless mandatory phases are desired.
- `validate_completion_pr_gate` (236-279) — gated by `route_requires_pr_gate`, i.e. by the route's
  `requires_pr_gate` field in the routing matrix (only `"large"` currently sets this `true`, per
  `config/orchestration-routing.json:30`).
- `_receipt_agents` / `_receipt_skills` / `_mcp_tools` (324-382) — the three receipt-collection helpers
  referenced by `.claude/skills/orchestrate/SKILL.md`'s "Routing-Contract Receipt Emission" section.
- `validate_routing_contract(state, routing_matrix=None)` (419-477) — the top-level routing-contract
  check: loads the matrix, resolves `route_id`, compares `state["required_agents"]` /
  `required_skills` / `required_mcp_tools` against the matrix's lists for that route (443-457), then
  requires a receipt for every required agent/skill/tool (459-472), and validates
  `local_execution_overrides`/`delegation_bypasses` are empty and `lifecycle_operations` used the MCP
  surface (474-476).

None of this module validates a distinct `epic-orchestrator-state.json` artifact; it only validates
fields *embedded inside* whatever checkpoint text is handed to
`validate_orchestrator_state_text`. Adding an `epic` route to `config/orchestration-routing.json`
(per spec item 8) is orthogonal to this module and requires no code change here — the routing-matrix
functions already read routes generically by `route_id`.

### Dispatch layer: `scripts/dev_tools/validate_orchestration_artifacts.py` (read in full, 247 lines)

This is the "stable CLI entrypoint" (module docstring, lines 1-7) that the MCP tool
`validate_orchestration_artifacts` ultimately calls into (via the TS in-process port, see below). Its
artifact-type dispatch is a plain `if`-chain, not a registry:

```
196	    path = Path(args.path)
197	    text = _read_text(path)
198	    if args.artifact_type == "plan":
199	        return validate_plan_text(text)
200	    if args.artifact_type == "policy-audit":
201	        return validate_policy_audit_text(text)
202	    if args.artifact_type == "code-review":
203	        return validate_code_review_text(text)
204	    if args.artifact_type == "feature-audit":
205	        return validate_feature_audit_text(text)
206	    if args.artifact_type == "orchestrator-state":
207	        return validate_orchestrator_state_text(
208	            text, require_complete=bool(args.require_complete)
209	        )
210	    return [f"Unsupported artifact type: {args.artifact_type}"]
```

The CLI parser (`build_parser`, lines 136-173) registers subparsers for the same five literal names
(162, 166), with `orchestrator-state` alone getting the extra `--require-complete` flag (168-171).

### TypeScript mirror: `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`

This file's own docstring (lines 12-33) states it is a **direct port** of
`scripts/dev_tools/validate_orchestration_artifacts.py` — "Port
`scripts/dev_tools/validate_orchestration_artifacts.py`. Provide the canonical atomic-plan structural
validator and an in-process dispatcher that routes each supported artifact type to its validator." Its
`validateArtifact` function (159-188) is the same five-case `switch` (`plan`, `policy-audit`,
`code-review`, `feature-audit`, `orchestrator-state`, default `Unsupported artifact type: ...`). This
is invoked in-process by
`extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts:55-90`, which is what
actually backs the `mcp__drm-copilot__validate_orchestration_artifacts` MCP tool at runtime (per its
own docstring, lines 5-23: "Hold the body previously inlined in
`RepoAutomationService.validateOrchestrationArtifacts`"). **This means the MCP tool is served by the
TypeScript port, not the Python CLI directly** — the Python CLI (`validate_orchestration_artifacts.py`)
remains the "stable CLI entrypoint" for direct/test invocation, but the live MCP surface consulted by
the orchestrator goes through the TS dispatcher.

### Exact MCP schema location for the `artifact_type` enum

`extensions/drm-copilot/src/mcp-tool-definitions.ts:378-411`:

```
378	  {
379	    name: "validate_orchestration_artifacts",
380	    description:
381	      "Validate an orchestration artifact (plan, policy-audit, code-review, feature-audit, or orchestrator-state) against its structural schema.",
382	    inputSchema: {
383	      type: "object",
384	      properties: {
385	        workspace_root: workspaceRootProperty,
386	        artifact_type: {
387	          type: "string",
388	          enum: [
389	            "plan",
390	            "policy-audit",
391	            "code-review",
392	            "feature-audit",
393	            "orchestrator-state",
394	          ],
395	          description: "The type of orchestration artifact to validate.",
396	        },
397	        artifact_path: {
398	          type: "string",
399	          description:
400	            "Workspace-relative or absolute path to the artifact file.",
401	        },
402	        require_complete: {
403	          type: "boolean",
404	          description:
405	            "When true and artifact_type is 'orchestrator-state', require all phases to be complete.",
406	        },
407	      },
408	      required: ["artifact_type", "artifact_path"],
409	      additionalProperties: false,
410	    },
411	  },
412	];
```

Adding a new enum value (e.g. `epic-orchestrator-state`) mechanically requires editing the `enum`
array at lines 388-394 (and, if it should honor `require_complete`, updating the `description` at
line 405 and the surrounding tool `description` string at line 381). This file's enum is the sole
schema gate the MCP layer enforces on `artifact_type`; nothing downstream re-validates the string
against a second list except the dispatch `if`/`switch` chains described above (both of which would
need a new branch, in both the Python and TS files, to actually route the new value to a validator
rather than falling through to `Unsupported artifact type: ...`).

### Recommendation input for the planner: new validator function vs. sibling script

Facts relevant to that decision (not a recommendation — the spec explicitly reserves this to the
planner: "extend `scripts/dev_tools/validate_orchestrator_state.py` (or add a sibling validator)"):

- `validate_orchestrator_state.py`'s public function signature
  (`validate_orchestrator_state_text(text, *, require_complete=False, strict_route_membership=False)`)
  is specific to the per-feature checkpoint's `REQUIRED_STATE_KEYS` shape (objective,
  change_budget_estimate, path_selected, step5_status..step10_status, etc. — lines 40-63). An
  epic-level checkpoint (wave number, worktree path, branch name, PR number, merge status per child
  feature, per spec item 6) has a structurally different shape and would not satisfy
  `REQUIRED_STATE_KEYS` as written.
- The dispatch layer (`validate_orchestration_artifacts.py` and its TS mirror) already dispatches by a
  string literal (`args.artifact_type` / `input.artifactType`) to one of several *independent*
  functions (`validate_plan_text`, `validate_policy_audit_text`, ..., `validate_orchestrator_state_text`)
  living in separate modules (`validate_orchestration_review_artifacts.py`,
  `validate_policy_audit_artifact.py`, `validate_orchestrator_state.py`). This existing pattern is a
  same-file-family sibling-module convention, not a single monolithic validator — a new
  `epic-orchestrator-state` artifact type fits that existing pattern as an additional sibling module
  with its own `validate_epic_orchestrator_state_text`-style function, wired into the dispatch `if`
  chain, rather than as new branches crammed into `validate_orchestrator_state_text` itself (which is
  already 125 lines for one artifact shape and sits well inside, but not far from, the repository's
  500-line file cap referenced in `.claude/rules/general-code-change.md`).

**Conclusion:** `scripts/dev_tools/validate_orchestrator_state.py` and
`scripts/dev_tools/_orchestrator_state_routing.py` validate exactly one checkpoint shape
(`orchestrator-state`) and one routing-matrix contract, both keyed by string-literal artifact type at
the dispatch layer (`validate_orchestration_artifacts.py` line 206 and its TS port
`orchestration-artifacts.ts` line 172). Registering a new `epic-orchestrator-state` artifact type
requires: (a) adding `"epic-orchestrator-state"` to the `enum` array at
`extensions/drm-copilot/src/mcp-tool-definitions.ts:388-394`; (b) adding a dispatch branch in both
`scripts/dev_tools/validate_orchestration_artifacts.py` (`_validate_from_args`, lines 196-210) and its
TS mirror `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`
(`validateArtifact`, lines 159-188); and (c) the actual validator logic living in a new sibling module
(matching the existing `validate_orchestrator_state.py` / `validate_policy_audit_artifact.py` /
`validate_orchestration_review_artifacts.py` sibling-module pattern) rather than being folded into
`validate_orchestrator_state_text`, because the required-key/status shape of an epic checkpoint is
structurally different from the per-feature checkpoint's `REQUIRED_STATE_KEYS`. Both a Python and a
TypeScript change are required because the live MCP tool is served by the TS port, not the Python CLI.

## 3. Bundle mirror mechanics

### Test file located

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (read in full, 287 lines) is
the byte-for-byte parity contract test. Constants:

```
15	REPO_ROOT = Path(__file__).resolve().parents[3]
16	BUNDLED_ROOT = (
17	    REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"
18	)
19	SCOPED_ROOTS: tuple[Path, ...] = (Path(".claude"),)
```

### Scope of `.claude/agents/*.md` and `.claude/skills/*/SKILL.md`

`test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 100-125) is the operative
parity check, and it is **dynamic enumeration**, not a static allowlist:

```
109	    bundled_files = list_scoped_files(BUNDLED_ROOT)
112	    repo_runtime_files = [
113	        f
114	        for f in list_scoped_files(REPO_ROOT)
115	        if f != Path(".claude/settings.local.json") and not _is_agent_memory_path(f)
116	    ]
118	    for relative_path in repo_runtime_files:
119	        assert (
120	            relative_path in bundled_files
121	        ), f"Repo file missing from bundle: {relative_path}"
122	        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
123	            REPO_ROOT,
124	            relative_path,
125	        ), f"Bundle content differs from repo for: {relative_path}"
```

`list_scoped_files` (lines 33-42) walks `root / ".claude"` with `rglob("*")` and returns every file.
This means **every** file under `.claude/agents/**` and `.claude/skills/**/SKILL.md` at the repo root
— including a brand-new file that did not exist when this test was last run — is automatically pulled
into `repo_runtime_files` and required to (a) exist at the same relative path under `BUNDLED_ROOT` and
(b) be byte-identical to the repo copy. There is a second, narrower test,
`test_bundled_claude_payload_contains_required_runtime_files` (lines 51-64), that checks a **fixed**
anchor list (`REQUIRED_BUNDLED_FILES`, lines 20-30) which currently includes only
`.claude/agents/orchestrator.md` among agent files and no skill beyond
`feature-promotion-lifecycle`/`atomic-plan-contract`/`policy-audit-template-usage`/
`execute-hard-lock`/`pr-base-branch-merge-base` — this fixed list would need a manual addition only if
the planner wants `epic-orchestrator.md` (or the new `epic-orchestrate` skill) specifically
anchor-checked; it is not the mechanism that would catch a missing/stale mirror for a new file (the
dynamic test above already does that).

Excluded from the dynamic parity test: `.claude/settings.local.json` (exact path exclusion, line 115)
and the entire `.claude/agent-memory/**` subtree (`_is_agent_memory_path`, lines 70-97, excluded at
line 115). Nothing else is excluded — `.claude/agents/**` and `.claude/skills/**` are fully in scope.

### Is a new agent/skill file handled by the same test, or does it need separate registration?

**Handled by the same test, with no code-level "registration" step.** Because
`list_scoped_files`/`rglob("*")` enumerates the filesystem at test-run time, a new
`.claude/agents/epic-orchestrator.md` or `.claude/skills/epic-orchestrate/SKILL.md` is automatically
included in `repo_runtime_files` the moment it exists on disk. No manifest, index, or list needs a new
entry for the *dynamic* test to catch it. However, no automated copy mechanism was found in this
repository that populates `extensions/drm-copilot/resources/claude-customizations/.claude/agents/` or
`.../skills/` from the repo-root `.claude/` tree:

- Searches for a source-to-bundle sync script (`claude-customizations` sync/mirror/copy logic outside
  the destination-facing `push_down_claude_customizations.py`, which only *consumes* the already-built
  bundle to push it to a *destination* repo — see its module docstring reference to "Load the selected
  pack manifests from the bundle" at line 146) found none. `scripts/dev_tools/agentic_sync.py` is an
  unrelated two-repo reconciliation tool (`sync_repos(left_repo, right_repo)`, line 421), not a
  `.claude/` → bundle copier.
- No `.claude/hooks/*.ps1` file references `claude-customizations` or a resources path (targeted grep
  returned no matches).

**Conclusion:** the byte-for-byte mirror is maintained by manual copy today; the test that enforces it
(`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) requires no separate registration
step for a newly-added file because it enumerates the tree dynamically, but it *will fail* until the
new agent/skill file is physically copied into
`extensions/drm-copilot/resources/claude-customizations/.claude/...` at the identical relative path
with identical bytes. The fixed anchor list (`REQUIRED_BUNDLED_FILES`) is a separate, narrower
belt-and-suspenders check that a planner may optionally extend for the new files but is not required
for the dynamic parity test to catch drift.

### `packages/mcp-server/.gitignore` and the second mirror

`packages/mcp-server/.gitignore` (read in full, 4 lines):

```
1	out/
2	node_modules/
3	resources/
4	*.tgz
```

Line 3 confirms `resources/` is gitignored in `packages/mcp-server/`. This directory is not
hand-maintained; it is generated at pack time by `packages/mcp-server/prepack.cjs` (read in full),
which does:

```
13	const SOURCE_DIR = path.join(
14	  __dirname,
15	  "..",
16	  "..",
17	  "extensions",
18	  "drm-copilot",
19	  "resources",
20	);
21	const DESTINATION_DIR = path.join(__dirname, "resources");
...
51	cpSync(SOURCE_DIR, DESTINATION_DIR, {
52	  recursive: true,
53	  force: true,
54	  filter: shouldCopy,
55	});
```

`shouldCopy` (lines 33-49) excludes only `.py` files and anything under a `scripts/` path segment;
`claude-customizations/` payloads are explicitly called out in the file's header comment (lines 3-8:
"the PoshQC tree, and the customization data payloads) are still copied so the server's commands keep
working") and are not filtered out. A repo-root search for `packages/mcp-server/resources/**`
currently returns no files (confirmed via Glob), consistent with this directory being build-generated
and gitignored rather than committed.

No test referencing `packages/mcp-server/resources` parity was found anywhere in the repository
(targeted grep for that literal path across all files returned no hits). This is consistent with the
spec's own claim ("gitignored, no automated gate; verify per file with `cmp`").

**Conclusion:** `packages/mcp-server/.gitignore:3` confirms `resources/` is ignored there, and no
automated test covers that mirror; it is populated only by `prepack.cjs`'s `cpSync` from
`extensions/drm-copilot/resources/` at pack time and would need manual `cmp`-based verification per
the spec's stated plan, or (if desired) a new test — none exists today.

## 4. Routing config shape

`config/orchestration-routing.json` (read in full, 77 lines) currently defines three routes —
`small`, `large`, `remediation` — each an object with `description`, `required_agents[]`,
`required_skills[]`, `required_mcp_tools[]`, and (only for `large`) `requires_pr_gate: true`:

```
4	  "routes": {
5	    "small": { ... "required_agents": ["atomic-planner","atomic-executor","feature-review"], ... },
28	    "large": { "requires_pr_gate": true, "required_agents": ["task-researcher","prd-feature","atomic-planner","atomic-executor","feature-review","pr-author"], ... },
57	    "remediation": { "required_agents": ["atomic-planner","atomic-executor","feature-review"], ... }
```

The `orchestrate` SKILL.md "Routing-Contract Receipt Emission" section (full text, lines 241-301,
already reproduced verbatim from the earlier read) defines the exact receipt shapes an `epic` route
would need populated at runtime:

- `delegation_receipts[]` — one object per required agent, shape `{ "agent_name": "<name>" }` (lines
  247-263). Consumed by `_receipt_agents` in `_orchestrator_state_routing.py:324-332`.
- `skill_receipts[]` — one object per required skill, shape
  `{ "skill": "<name>", "required": true, "evidence": "<non-empty string>" }` (lines 265-281).
  Consumed by `_receipt_skills` (`_orchestrator_state_routing.py:335-357`).
- `mcp_call_receipts[]` — one object per required MCP tool, shape
  `{ "tool": "<name>", "ok": true, "evidence": "<non-empty string>" }` (lines 283-299). Consumed by
  `_mcp_tools` (`_orchestrator_state_routing.py:360-382`).

`validate_routing_contract` (`_orchestrator_state_routing.py:419-477`) additionally requires the
checkpoint's own `required_agents`/`required_skills`/`required_mcp_tools` lists (state-level, not
receipt-level) to **exactly equal** (`_state_list`, lines 300-310, uses `value != expected`) the
routing matrix's lists for the selected route (lines 443-457) — i.e., a new `epic` route's checkpoint
must echo the matrix's three lists verbatim as state fields, in addition to carrying receipts for each
entry.

`route_requires_pr_gate` (`_orchestrator_state_routing.py:55-96`) and `MANDATORY_ROUTE_PHASES`
(`_orchestrator_state_routing.py:16-18`, currently only populated for `"small"`) are both read
generically by `route_id` — an `epic` route would need explicit opt-in to either gate (via
`"requires_pr_gate": true` and/or a `MANDATORY_ROUTE_PHASES["epic"]` entry) if the planner wants those
gates to apply; absent explicit configuration, a new route inherits neither gate by default (both
functions return `False`/empty when the route/key is absent).

**Conclusion:** Adding an `epic` route to `config/orchestration-routing.json` follows the identical
object shape already used by `small`/`large`/`remediation` (`description`, `required_agents[]`,
`required_skills[]`, `required_mcp_tools[]`, optional `requires_pr_gate`), and the three receipt-array
shapes (`delegation_receipts[]`/`skill_receipts[]`/`mcp_call_receipts[]`) documented in
`.claude/skills/orchestrate/SKILL.md` lines 241-301 are already generic across routes — no
route-specific receipt-shape change is needed, only new entries in the matrix's required-name lists
and matching receipts/state-list-echoes at runtime.

## 5. S9 / PR-Creation-Gate exact text

Full text of the three relevant sections was read from `.claude/skills/orchestrate/SKILL.md` (lines
151-220), reproduced here for the planner's surgical-edit reference.

### `## Step S9 — CI Green Gate` (lines 151-197)

```
151	## Step S9 — CI Green Gate
152	
153	`S9_ci_green` runs after `S8_create_pr` and before any DONE transition. It is the structural guarantee that the orchestrator observes what GitHub Actions produces against the live PR head SHA before writing DONE. S9 applies to every feature, not only features that modify CI paths.
154	
155	S9 procedure:
156	
157	1. Resolve the live PR head SHA for the feature branch (`gh pr view --json headRefOid` or equivalent).
158	2. Invoke `gh pr checks --required --json bucket,name,state,link,workflow` (or an equivalent JSON-emitting command) against that head SHA. `gh` is the only sanctioned channel for querying GitHub Actions state.
159	3. Parse the JSON via `scripts/orchestration/Invoke-CiGateParser.ps1`, which emits the `ci_gate` object defined below and derives `ci_gate.conclusion` as `success` when all required checks pass, `failure` when any required check failed, and `pending` when any required check is still in progress.
160	4. Poll with a bounded interval and a documented total timeout while `conclusion == "pending"`. When the timeout is exhausted, set `step9_status: "failed_remediation_required"` and enter the remediation-loop CI-failure handling below with a timeout log.
161	5. Write the `ci_gate` object and `last_verified_ci_sha` to the checkpoint, and set `step9_status` to `passed` only when `ci_gate.conclusion == "success"` AND `ci_gate.head_sha` equals the current PR head SHA.
162	
163	DONE is not written while `step9_status` is anything other than `passed`.
```

**Surgical insertion point:** immediately after numbered step 5 (line 161) and before the standalone
sentence at line 163 ("DONE is not written...") is where an epic-mode branch fits — e.g. a new step 6
reading approximately "6. If `epic_mode` is true, execute `gh pr merge --merge` against the epic's
integration branch and record the resulting merge commit SHA in the checkpoint" — because step 5 is
where `step9_status` first becomes `passed`, which is the precondition the spec's item 4 names
("after `ci_gate.conclusion == 'success'` and head-SHA match, execute `gh pr merge --merge`...").

### `## Checkpoint Schema — CI Gate Fields` (lines 165-197)

```
165	## Checkpoint Schema — CI Gate Fields
166	
167	The orchestrator checkpoint (`artifacts/orchestration/orchestrator-state.json`) is extended with:
168	
169	- a top-level `ci_gate` object containing:
170	  - `head_sha` — the PR head SHA that the required checks were observed against.
171	  - `pr_pipeline_run_id` — the GitHub Actions run id for the PR Pipeline.
172	  - `pr_pipeline_run_url` — the URL of that run.
173	  - `conclusion` — one of `success`, `failure`, `pending`.
174	  - `verified_at` — ISO-8601 timestamp of when S9 recorded the result.
175	- a top-level `last_verified_ci_sha` — the most recent head SHA for which S9 recorded a result.
176	- a top-level `step9_status` — an enumeration with at minimum the values `pending`, `passed`, `failed_remediation_required`, and `blocked_ci_loop_limit`.
```

**Surgical insertion point:** a new bullet after line 176 (or a new nested field on `ci_gate`) is where
an `epic_merge` object (integration-branch merge commit SHA, target branch name, merge timestamp)
would be documented, following the existing "top-level object with named sub-fields" pattern used for
`ci_gate` itself.

### `## PR Creation Gate` (lines 209-220)

```
209	## PR Creation Gate
210	
211	The orchestrator must not create a PR, push a branch for PR purposes, or report work complete until all six conditions are simultaneously true:
212	
213	1. `blocking_findings_resolved: true` — the most recent `feature-review` produced zero blocking findings.
214	2. The AC verification artifact (`p14-acceptance-criteria-checkoff.md` or equivalent) confirms all acceptance criteria pass.
215	3. The mandatory toolchain passed in its most recent run on the branch (no linting/type-check/test failures).
216	4. The checkpoint `next_step` is `S8_create_pr` (precondition to entering S9).
217	5. PR body produced via the pr-author handoff: `artifacts/pr_body_<N>.md` exists with a matching `artifacts/pr_body_<N>.receipt.json`, created with `--body-file`.
218	6. `ci_gate.conclusion == "success"` AND `ci_gate.head_sha == current head SHA of the PR branch`. DONE is not written while either sub-condition is false.
219	
220	This gate is non-negotiable. Each condition is independently verified before PR creation proceeds. Conditions 1-4 are unchanged from the prior contract; condition 5 (receipt handoff) and condition 6 (CI-green gate) are additive.
```

**Surgical insertion point:** a new condition 7 after line 218 ("`epic_mode` false, or the
integration-branch merge (`gh pr merge --merge`) has completed and its commit SHA is recorded") would
extend the six-condition list to seven, following the same "Conditions N-M are additive" annotation
pattern used at line 220 for conditions 5-6.

**Conclusion:** All three sections give a single, precisely located insertion point each: S9 procedure
step 6 (after line 161, before line 163), a new `ci_gate`-adjacent bullet or sibling object (after line
176), and PR Creation Gate condition 7 (after line 218, following the existing "additive condition"
annotation convention at line 220). No section requires a rewrite of its existing numbered items; the
epic-mode behavior is additive at the end of each existing list, consistent with how conditions 5 and
6 were previously added to the PR Creation Gate.

## 6. atomic-executor / atomic-planner git tool access

### `.claude/agents/atomic-executor.md` (read in full)

Tool allowlist (frontmatter, lines 4-23):

```
4	tools:
5	  - Read
6	  - Grep
7	  - Glob
8	  - Edit
9	  - Write
10	  - "Bash(poetry run black *)"
11	  - "Bash(poetry run ruff *)"
12	  - "Bash(poetry run pyright *)"
13	  - "Bash(poetry run pytest *)"
14	  - "Bash(npx prettier *)"
15	  - "Bash(npx eslint *)"
16	  - "Bash(npx tsc *)"
17	  - "Bash(npx vitest *)"
18	  - "Bash(pwsh *)"
19	  - "Bash(git *)"
20	  - "mcp__drm-copilot__run_poshqc_format"
21	  - "mcp__drm-copilot__run_poshqc_analyze"
22	  - "mcp__drm-copilot__run_poshqc_test"
23	  - "mcp__drm-copilot__run_poshqc_analyze_autofix"
```

`Edit` and `Write` (lines 8-9) are **unscoped** — no path-prefix restriction such as
`Edit(docs/**)` is applied here (contrast with `atomic-planner` below), so `atomic-executor` can edit
any file in the working tree, including files carrying `<<<<<<<`/`=======`/`>>>>>>>` conflict markers.
`"Bash(git *)"` (line 19) is an **unrestricted wildcard** over all `git` subcommands — it is not
scoped to a subset such as `git diff`/`git status`/`git log` (those three are merely the ones called
out in the agent's own "## Toolchain Commands" prose at line 80, but the tool grant itself is the
unrestricted `git *` pattern). This means `git merge`, `git add`, `git commit`, `git checkout
--ours/--theirs`, and any other git subcommand are already mechanically permitted by the existing
tool allowlist.

### `.claude/agents/atomic-planner.md` (read in full)

Tool allowlist (frontmatter, lines 4-11):

```
4	tools:
5	  - Read
6	  - Grep
7	  - Glob
8	  - "Edit(docs/**)"
9	  - "Edit(artifacts/**)"
10	  - "Write(docs/**)"
11	  - "Write(artifacts/**)"
```

No `Bash` tool of any kind is granted to `atomic-planner`, and its `Edit`/`Write` grants are scoped to
`docs/**` and `artifacts/**` only. `atomic-planner` cannot run `git` at all and cannot edit source
files outside `docs/`/`artifacts/`; it is planning-only by construction, consistent with its own
"You are a planning-only agent... You do not execute implementation" statement (agent body, line 27).

**Conclusion:** `atomic-executor` already has `Bash(git *)` (unrestricted wildcard) plus unscoped
`Edit`/`Write` access, which together are mechanically sufficient to run `git merge`, resolve conflict
markers by editing any file, stage changes, and `git commit` — no new tool grant is required for
`atomic-executor` to perform a delegated merge-conflict-resolution task under the existing allowlist.
`atomic-planner` has no `Bash` access and scoped `Edit`/`Write`, so it cannot itself perform any git
operation or edit source files; a merge-conflict finding routed through the R1-R5 remediation loop
would need `atomic-planner` only for the plan text (which task describes touching which files) and
`atomic-executor` for the actual conflict-marker edits, `git add`, and `git commit` — consistent with
the two agents' existing planning/execution split.

## Rejected alternatives

None — this artifact answers factual mechanics questions rather than evaluating design alternatives.
No candidate-approach comparison was requested or performed.
