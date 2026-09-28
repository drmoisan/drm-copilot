# Research — workspace_root is not applied to GitHub issue creation (Issue #525)

- **Issue:** #525
- **Feature folder:** `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/`
- **Work mode:** full-bug
- **Timestamp:** 2026-08-23T23-40
- **Scope:** read-only investigation. No production or test source file was modified.

---

## 1. Current State Analysis

### 1.1 Exact defect locus

There are **two** independent omissions, both on the same call path. Either one alone would
be sufficient to cause the reported misfiling, and both are present.

**Omission 1 — no repository selector on the argument vector.**

`extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts`, lines 281-293:

```ts
  issueCreate(title: string, body: string, promotionType: string): GhResult {
    const args = [
      "issue",
      "create",
      "--title",
      title,
      "--body-file",
      "-",
      "--label",
      promotionType,
    ];
    return this.runGh(args, body);
  }
```

No `--repo`. The same omission is present on the two sibling invocations built in the same
file: `ensureLabel` (lines 301-312) and `issueView` (lines 320-329). All three therefore let
the GitHub CLI resolve the target repository implicitly.

**Omission 2 — no working directory on either process spawn.**

Because there is no explicit selector, the CLI falls back to resolving the repository from
its own process working directory. Neither spawn path sets one.

`gh-client.ts`, lines 143-159 (`SpawnSyncGhCommandRunner.run`, used for the single stdin-bearing
`issue create` call):

```ts
    const completed = spawnSync(ghPath, [...args], {
      shell: false,
      encoding: "utf8",
      ...(input === undefined ? {} : { input }),
    });
```

`extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts`,
line 133 (`CommandRunnerGhAdapter.run`, used for the non-stdin auth/label/view calls):

```ts
    const result = this.runner.run([ghPath, ...args], { allowError: true });
```

`CommandRunOptions` in `extensions/drm-copilot/src/lib/subprocess-runner.ts` (lines 25-28)
*does* expose `cwd`, and `SubprocessRunner.run` honours it (lines 107-112). It is simply
never supplied here.

**Why the fallback resolves to the wrong repository.** The MCP server is a long-lived stdio
process whose working directory is fixed at launch by
`extensions/drm-copilot/src/mcp-provider.ts`, lines 45-48:

```ts
        const workspaceCwd = vscode.workspace.workspaceFolders?.[0]?.uri;
        if (workspaceCwd) {
          serverDef.cwd = workspaceCwd;
        }
```

The cwd is the **first VS Code workspace folder of the window that launched the server**, not
the `workspace_root` of any individual call. That is exactly the mechanism the issue reports:
the server was launched from the `TaskMaster` window, so every implicit `gh` resolution named
`drmoisan/TaskMaster` regardless of the `workspace_root` argument. This is also the mechanism
that produced this feature's own record (filed as `drmoisan/TaskMaster#599`, transferred to
`drmoisan/drm-copilot#525`).

**Contrast — the repository already gets this right elsewhere.** Every other tool that shells
`gh` sets a working directory:

| Surface | `gh` invocation | Working directory |
| --- | --- | --- |
| `collect_pr_context` | `extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts` lines 148-151, 193-196, 229 | `cwd: this.cwdValue`, seeded from `repoRoot: input.workspaceRoot` (`pr-context-service-call.ts:73`) |
| `link_parent_child` | bundled `extensions/drm-copilot/resources/templates/link-parent-child.ps1` | spawned by `runCommandWithOutput` with `cwd` (`command-runtime.ts:215-219`), seeded from `workspaceRoot` |
| potential-to-issue promotion | `gh-client.ts:148`, `potential-to-issue-service-call.ts:133` | **none** |

The promotion tool is the only `gh`-invoking surface in the extension that supplies neither a
`cwd` nor a `--repo`.

### 1.2 How `workspace_root` is threaded

`workspace_root` is threaded correctly for four hops and then stops. The propagation stops at
one specific expression.

| Hop | File / line | `workspace_root` present? |
| --- | --- | --- |
| 1. MCP dispatch | `extensions/drm-copilot/src/mcp-tools.ts:199-201` -> `handlePotentialToIssue` | raw argument object |
| 2. Input resolution | `extensions/drm-copilot/src/mcp-tool-inputs-potential-to-issue.ts:35-38` | resolved to `workspaceRoot`; also used to resolve a relative `potential_path` (lines 43-47) |
| 3. Handler | `extensions/drm-copilot/src/mcp-handlers/feature-entry-handlers.ts:32-33` | forwarded whole |
| 4. Service | `extensions/drm-copilot/src/repo-automation-service.ts:239-246` | `workspaceRoot: input.workspaceRoot` |
| 5a. Filesystem half | `potential-to-issue-service-call.ts:163-171` -> `promotePotential({ workspace: input.workspaceRoot })` | **YES — correct** |
| 5b. GitHub half | `potential-to-issue-service-call.ts:155-157` | **NO — propagation stops here** |

The stopping expression is `potential-to-issue-service-call.ts`, lines 155-157:

```ts
  const ghClient =
    input.gh ??
    new RealGhClient({ runner: new CommandRunnerGhAdapter(input.runner) });
```

`input.workspaceRoot` is in scope on that line and is not passed to the client, to the
adapter, or to any invocation the client subsequently makes.

Downstream of the stop, `promotePotential`
(`extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`) receives `workspace` and
consumes it in exactly two places, both filesystem-only:

- line 336 — `computeRelativePath(resolved, workspacePath)` for the issue-body footer;
- line 433 — `posixJoin(workspacePath, "docs/features/potential/promoted")` for the move target.

It never hands `workspacePath` to `ghClient` (`promotion.ts:367`, `375`, `381`, `408`). The
workflow module is therefore *not* where the defect lives; it faithfully uses the workspace
for every effect it owns.

**Answer to "what cwd is set on the subprocess?"** None is set by this code path. Both spawns
inherit the MCP server process cwd, which `mcp-provider.ts:45-48` pins to the launching VS Code
window's first workspace folder.

### 1.3 Result-payload contract

Assembly is a three-stage projection, and the projection is **explicit at every stage** — an
unprojected field is silently dropped.

1. `potentialToIssueServiceCall` returns `PotentialToIssueServiceCallResult`
   (`potential-to-issue-service-call.ts:82-88`, built at lines 200-208): `tool`,
   `workspaceRoot`, `summary`, optional `destinationPath`, optional `artifacts`.
2. That value is returned as `RepoAutomationExecutionResult`
   (`extensions/drm-copilot/src/repo-automation-service-contract.ts:25-35`), a closed
   interface listing `tool`, `workspaceRoot`, `summary`, `artifacts`, `assetId`,
   `bundledSourcePath`, `destinationPath`, `renderedTree`, `warnings`.
3. `toMcpToolResult` (`mcp-tools.ts:89-110`) snake-cases and re-projects it into
   `RepoAutomationMcpToolResult` (`mcp-tools.ts:60-72`), which is what
   `toCallToolResult` (`mcp-server.ts:45-56`) serialises into both `content[0].text` and
   `structuredContent`.

**Consumers.**

- The MCP client (agent session). Per `.claude/skills/feature-promotion-lifecycle/SKILL.md`
  lines 34-39, the orchestrator persists the **raw receipt payload** into
  `delegation_receipts.promotion.issue` in the orchestrator-state checkpoint "without lossy
  normalization". Line 75 of the same skill has the orchestrator read back `destination_path`.
- The VS Code command surface **discards** the return value:
  `extensions/drm-copilot/src/repo-automation-command-registration-feature-workflows.ts`
  lines 166-171 and 197-203 both `await` without binding the result.

**Cost and blast radius of echoing the resolved target repository.** Low, and additive.

- No tool definition declares an `outputSchema`. Both
  `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (lines 200-233) and
  `extensions/drm-copilot/src/mcp-tool-definitions.ts` (lines 180-213) declare only
  `inputSchema`, with `additionalProperties: false` on the **input** object. A new output
  field therefore requires no definition change and cannot violate an input schema.
- The orchestrator-state validators impose no shape on `delegation_receipts.promotion.*`;
  `.claude/rules/orchestrator-state.md` requires only that receipt arrays are lists, and a
  grep of `scripts/dev_tools/` finds no `promotion` receipt validation at all. An extra key is
  tolerated.
- No test asserts the exact key set of a `potential_to_issue` result. The only exact-shape
  assertion in the extension suite is
  `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts:93`
  (`Object.keys(result)` for the *validate-orchestration* service call) and the two
  `toStrictEqual` comparisons in `extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts`
  (lines 172, 207), which compare push-down **tool definitions**, not results.
- Two files must nonetheless change because the projections are closed:
  `repo-automation-service-contract.ts` (add the optional property to
  `RepoAutomationExecutionResult`) and `mcp-tools.ts` (add the optional property to
  `RepoAutomationMcpToolResult` and add the conditional spread in `toMcpToolResult`).

**Consumers that would need to tolerate the added field:** none require modification. The
VS Code registration discards the result; the orchestrator stores it verbatim; no validator or
test pins the key set.

### 1.4 Existing test coverage and the injection seam

The seam is **constructor injection of a fake, at two different levels.**

*Level 1 — the process-runner seam (`GhCommandRunner`).* Used by
`extensions/drm-copilot/test/lib/potential-to-issue/gh-client.test.ts`. `makeRunner`
(lines 45-59) returns an object recording `{ ghPath, args, input }` per call, and
`RealGhClient` is constructed with `{ runner, ghPathLookup }` so neither PATH nor a real
process is touched (lines 61-62, 84-87). The suite already asserts the **exact argument
vector** for all three invocations:

- `issueCreate` — lines 123-132 (`["issue","create","--title","My Title","--body-file","-","--label","feature"]`)
- `ensureLabel` — lines 152-160
- `issueView` — lines 179-186

*Level 2 — the client seam (`GhClient`).* `FakeGhClient` in
`extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts` (lines 61-100)
implements the four-method interface, records `["create", [title, body, promotionType]]`, and
returns queued `GhResult` values. It is consumed by `promotion.test.ts`,
`promotion.missing-label.test.ts`, and `potential-to-issue-service-call.test.ts`
(which imports it at lines 9-14 and reads recorded calls at lines 165-168).

The filesystem is faked in the same file by `FakePotentialFileSystem` (Map-backed, lines
19-58). No temporary files are created anywhere in the suite, consistent with
`.claude/rules/general-unit-test.md`.

*`extensions/drm-copilot/test/mcp-tools.workspace-root.test.ts`* covers only the
dispatch-boundary failure envelope for an **omitted** `workspace_root` (lines 48-69). It
builds a fully mocked `RepoAutomationService` and asserts the service is never invoked. It
does **not** exercise the promotion path and is not the home for this regression.

### 1.5 Python sibling and the parity question

`scripts/dev_tools/potential_to_issue.py` carries the identical omission:

- `issue_create` (lines 157-168) builds the same vector with no `--repo`.
- `_run` (lines 137-155) calls `subprocess.run([gh_exe, *args], ...)` with no `cwd=`.

The module is **live, not dead**: `pyproject.toml` line 78 registers
`"dev.potential-to-issue" = "scripts.dev_tools.potential_to_issue:main"`, and four dedicated
pytest modules exercise it (`tests/scripts/dev_tools/test_potential_to_issue.py`,
`..._branches.py`, `..._content.py`, `..._missing_label_regression.py`).

It is **not bundled**: `extensions/drm-copilot/resources/scripts/dev_tools/` does not exist.
The docstrings in `gh-client.ts` (line 7) and `content.ts` (line 6) that call it "the bundled
`resources/scripts/dev_tools/potential_to_issue.py`" are stale and describe a path that is not
present in the tree.

**The decisive structural fact:** the Python CLI has **no workspace parameter**. `parse_args`
(lines 576-599) declares only `--potential-path`, `--promotion-type`, and `--work-mode`.
`main` (lines 621-627) calls `promote_potential` without `workspace=`, so `workspace_path`
always falls back to `_resolve_workspace()` (line 402 -> lines 308-327), which is
`Path(__file__).resolve().parents[2]` — the repository the script itself lives in. The
`workspace` keyword exists only for in-process and test callers.

Consequently the reported defect — *"a parameter honoured for the filesystem effect and
ignored for the remote effect"* — **cannot be exhibited by the Python CLI as invoked**, because
there is no such parameter on that surface.

This matches the precedent set by the immediately preceding defect in this same subsystem.
`docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/ts-python-parity-inspection.2026-08-20T20-08.md`
mirrored the behavioural change in both languages but recorded a deliberate TypeScript-only
asymmetry under the heading *"Receipt Post-Condition — Deliberately TypeScript-Only (INV-6)"*,
justified because "the Python CLI emits no receipt ... Adding an existence assertion there would
guard nothing." The same reasoning applies here: the Python CLI accepts no workspace selector,
so adding a repository selector derived from one would bind to a value that is by construction
the script's own repository.

### 1.6 Owner/name resolution — does a helper already exist?

**Verified: yes for the `gh`-based form; no for a git-remote-parsing form.**

| Candidate | Path | Verdict |
| --- | --- | --- |
| `GhClient.repoName()` | `extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts` lines 185-212 | **Exists and is tested.** Runs `["repo","view","--json","nameWithOwner"]` with `{ cwd: this.cwdValue, allowError: true }`, tolerates non-zero exit, empty stdout, invalid JSON, non-object payload, and a non-string field; caches the result. |
| `_repo_name` (Python sibling) | `scripts/dev_tools/pr_context/github.py` lines 77-104 | Byte-parallel implementation of the above. |
| Any `git remote get-url origin` parser | — | **None exists.** A grep for `remote get-url`, `github\.com[:/]`, `repoSlug`, `ownerRepo`, and `nameWithOwner` across `extensions/drm-copilot/src/` and `scripts/` returns only the two `gh repo view` sites above. No module in the repository parses a remote URL into an owner/name pair. |

`GhClient.repoName()` is **not directly reusable** as-is: its constructor
(`gh-client-core.ts:81-89`) requires a `FileSystem`, and it eagerly runs
`hydrateAvailability()` — a second `gh auth status` plus a `gh repo view` — on construction
(lines 141-175). Reusing it from the promotion path would duplicate the auth probe that
`promotePotential` already performs at `promotion.ts:311`. The *command and field selection*
are reusable as a precedent; the class is not.

---

## 2. Candidate Approaches

### Recommended — derive the slug from `workspace_root` and pass `--repo` explicitly, then echo it

Bind an optional repository slug to the `gh` client at construction and prepend
`--repo <slug>` to the three repository-scoped argument vectors; resolve the slug in the
service-call layer from `workspace_root` through the already-injected `CommandRunner`; and
project the resolved slug into the result.

**Why this one.**

- It is the only option that makes the target **explicit and echoable**. The issue's stated
  root cause ("silent misfiling is the default outcome") is not fixed by any change that leaves
  the target implicit; an explicit `--repo` plus an echoed value lets the caller assert the
  target at the call site, which is what the reporter asked for in `issue.md` line 93.
- `--repo` makes the process working directory **irrelevant** to repository selection, so the
  fix is robust against the `mcp-provider.ts:45-48` cwd binding rather than merely working
  around it. It also works when the CLI is invoked outside any git checkout.
- The slug is directly assertable at the argument boundary in the existing
  `gh-client.test.ts` seam, so the regression test does not need to observe a spawn option
  that the current `GhCommandRunner` signature does not carry.
- It leaves `promotion.ts` and `promotion-test-support.ts` untouched, because the binding is
  on the client rather than on the `GhClient` method signatures.

**Resolution mechanism.** Run `["repo","view","--json","nameWithOwner"]` with
`{ cwd: workspaceRoot, allowError: true }` through the injected `CommandRunner`. This reuses the
exact command, field list, and tolerance behaviour already proven in
`gh-client-core.ts:185-212`, and yields precisely the slug the CLI would itself have resolved
from that checkout — which makes the fix provably equivalent to "resolve from the right
directory", with the added benefit of an echoable value. The alternative of parsing
`git remote get-url origin` is offline but requires a new URL-parsing surface covering
SSH/HTTPS forms, an optional `.git` suffix, and enterprise hosts, none of which exists in the
repository today; it is recorded below as the rejected alternative.

**Failure policy: fail closed.** When the slug cannot be resolved, throw rather than fall back
to implicit resolution. Falling back reinstates the exact defect. The cost is bounded because
`promotePotential` already requires an authenticated CLI (`promotion.ts:311-315`) and the
subsequent create call requires network regardless, so an environment in which resolution fails
is an environment in which the promotion could not have succeeded anyway.

### Rejected alternatives (brief)

- **Set `cwd: workspaceRoot` on the two spawns and change nothing else.** Smallest diff and it
  would fix the misfiling. Rejected because it leaves the target implicit — nothing is echoed,
  so the "silent" half of the defect survives — and because asserting it requires widening
  `GhCommandRunner.run` (which takes `(ghPath, args, input)` only) so a fake can observe the
  option. Worth adding *alongside* the recommendation as defence in depth, but not instead of it.
- **Parse `git remote get-url origin` locally.** Offline and cheap, but no such parser exists in
  the repository, and a new one must handle SSH, HTTPS, `.git` suffixes, and enterprise hosts —
  each an edge case needing its own tests — to reproduce what one already-proven `gh` call
  returns.
- **Reuse `pr-context`'s `GhClient` class directly.** Rejected: its constructor demands a
  `FileSystem` and eagerly performs a second `gh auth status` probe, duplicating
  `promotion.ts:311`.
- **Widen `GhClient.issueCreate` to take a repo argument and thread it through
  `promotePotential`.** Rejected: it forces changes to `promotion.ts`,
  `promotion-test-support.ts`, and the Python `GhClient` Protocol, enlarging the write set and
  the blast radius for no additional assertive power.
- **Mirror the change into `scripts/dev_tools/potential_to_issue.py`.** Rejected on the evidence
  in section 1.5 and detailed in section 5.

---

## 3. Behavior Semantics

**Success conditions.**

1. Given `workspace_root` = B, the argument vector passed to the CLI for issue creation
   contains `--repo` followed by B's `owner/name` slug.
2. The same holds for the label-create recovery call and the issue-view call, so all three
   repository-scoped operations name the same repository.
3. The returned result carries the resolved slug in a dedicated field, and it is consistent
   with `destination_path` and `workspace_root`.
4. Given `workspace_root` equal to the server's own checkout (the case that works today), the
   behaviour is unchanged in outcome: the issue is created in that repository and the result
   echoes its slug.

**Ordering rules.**

- Slug resolution occurs **before** the client is constructed and therefore before any
  repository-scoped invocation. It occurs after `workspace_root` normalisation
  (`mcp-tool-inputs-potential-to-issue.ts:35`), so it always operates on the resolved value.
- The authentication probe at `promotion.ts:311` is repository-independent and its position is
  unchanged.
- The missing-label recovery sequence (`promotion.ts:371-383`: create -> detect -> ensure label
  -> re-create) must carry the same slug on every leg, including the retry.

**Failure conditions.**

- Slug resolution fails (CLI absent, unauthenticated, non-zero exit, empty stdout, unparseable
  JSON, missing or non-string `nameWithOwner`): the call fails with an explicit message naming
  the `workspace_root` that could not be resolved. It must **not** fall back to implicit
  resolution.
- All pre-existing failure surfaces are preserved unchanged: `PromotionError` propagation
  (`potential-to-issue-service-call.ts:26-27`), the non-zero-exit
  `Command exited with code <n>.` throw (lines 176-180), and the destination-existence
  post-condition (lines 191-198).

**Edge cases.**

- `workspace_root` is a git worktree rather than a primary checkout — `gh` resolves the same
  slug from a linked worktree, so no special handling is required.
- `workspace_root` names a directory with no `origin` remote — resolution fails; fail closed.
- The promotion label is absent and the recovery path fires — the retry must carry the slug
  (covered by success condition 2).
- A slug is resolved but the create call still fails — the existing non-zero path is unchanged.

---

## 4. Requirements Mapping

### Design

Add an optional repository binding to the promotion `gh` client, a slug resolver, and a result
field.

1. **`gh-client.ts`** — add an optional `repo` to the `RealGhClient` constructor options
   (alongside the existing `runner` and `ghPathLookup`), store it, and prepend
   `["--repo", repo]` after the subcommand in `issueCreate`, `ensureLabel`, and `issueView`
   when it is present. Keeping it optional preserves the existing default construction at
   `promotion.ts:306` (`options.gh ?? new RealGhClient()`), so the workflow module needs no
   change. Update the module docstring, whose current "byte-identical to the Python source"
   claim about the argument vectors (lines 12-14) becomes false once `--repo` is added; replace
   it with an explicit statement of the divergence and its reason.
2. **New module in the same folder** — a slug resolver taking an injected `CommandRunner` and a
   workspace root, running the `repo view --json nameWithOwner` form with `cwd` set and
   `allowError: true`, and returning the slug or throwing a specific error. It reproduces the
   tolerance behaviour of `gh-client-core.ts:197-211` (non-zero exit, empty stdout, invalid
   JSON, non-object payload, non-string field) but converts the `null` outcome into an
   explicit throw, because this caller must fail closed.
3. **`potential-to-issue-service-call.ts`** — resolve the slug from `input.workspaceRoot`,
   pass it into the `RealGhClient` construction at lines 155-157, add an optional injected
   resolver seam to the input interface so the regression test is hermetic, and add the
   resolved slug to the returned record at lines 200-208.
4. **`repo-automation-service-contract.ts`** — add the optional property to
   `RepoAutomationExecutionResult` so the enriched record remains assignable at
   `repo-automation-service.ts:239`.
5. **`mcp-tools.ts`** — add the optional snake-cased property to `RepoAutomationMcpToolResult`
   (lines 60-72) and the conditional spread in `toMcpToolResult` (lines 92-109).
6. **`jest.config.cjs`** — the config uses **per-changed-file** coverage thresholds with no
   `global` key (see the comment at lines 20-24). `./src/mcp-tools.ts` already has an entry
   (lines 151-154); the three potential-to-issue lib files do not. Per the stated convention
   that the gate applies to the feature's changed files, entries must be added for
   `gh-client.ts`, `potential-to-issue-service-call.ts`, and the new resolver module.
   `repo-automation-service-contract.ts` is interface-only and is deliberately excluded from
   the threshold gate (documented at lines 155-161), so it needs no entry.

### State model

There is no persistent state. The added value is a single derived string with three states:

| State | Trigger | Effect |
| --- | --- | --- |
| unresolved | before resolution | no repository-scoped invocation may run |
| resolved | resolver returns a slug | slug is bound to the client and echoed in the result |
| resolution failed | resolver cannot determine a slug | call throws; no issue is created; no file is moved |

The failure transition occurs before any `gh` write and before the filesystem move at
`promotion.ts:437-440`, so a failed resolution leaves the potential record untouched.

### Acceptance-criteria mapping

| Spec AC (`spec.md` lines 143-150) | Satisfied by |
| --- | --- |
| Repro steps produce expected behaviour | Design items 1-3; slug derived from `workspace_root` governs both halves |
| Regression test(s) added and passing | Section 6 test homes |
| Edge cases and invalid inputs handled | Fail-closed resolution policy; tolerance cases mirrored from `gh-client-core.ts:197-211` |
| No unintended behaviour changes outside scope | `promotion.ts`, `content.ts`, `promotion-filesystem.ts`, and the tool definitions are untouched; the optional `repo` keeps the existing default construction working |
| Logs/telemetry updated | The emitted line at `promotion.ts:366` already names the title and label; no new emission is required by the issue |
| Performance constraints | One additional `gh` invocation per promotion, on a path that already makes three to four |
| Full toolchain pass | Standard seven-stage loop |
| Docs/config references updated | Module docstrings in the touched files; **not** the skill documents (see section 9) |

---

## 5. Parity Obligation — determination

**Determination: `scripts/dev_tools/potential_to_issue.py` is a live sibling but is NOT in the
required write set for this fix.**

Evidence for "live": registered console script (`pyproject.toml:78`); four dedicated pytest
modules; referenced by `tests/test_pytest_collection.py`.

Evidence for "not obligated by this defect":

1. **No analogous parameter.** `parse_args` (lines 576-599) exposes no workspace flag and
   `main` (lines 621-627) passes none, so `workspace_path` is unconditionally the script's own
   repository (`_resolve_workspace`, lines 308-327). The defect is "one parameter, two effects,
   one honoured" — the Python surface has no such parameter.
2. **Precedent for a documented one-sided change in this exact subsystem.** The #487 parity
   inspection evidence explicitly records a TypeScript-only correction with a structural
   justification and confirms `potential_to_issue.py` was left unmodified (its final line).
3. **Cost of doing it anyway.** Changing `issue_create` would require touching the `GhClient`
   Protocol (line 83), `RealGhClient` (lines 157-168), and the `FakeGhClient` subclasses in
   `tests/scripts/dev_tools/test_potential_to_issue.py` (line 85),
   `test_potential_to_issue_branches.py` (line 89), and
   `test_potential_to_issue_missing_label_regression.py` (line 283) — five files — with no
   behaviour change reachable from `main`.

**Obligation that *does* follow:** the parity claim in the `gh-client.ts` docstring (lines
12-14, "Argument vectors for `auth status`, `issue create`, `label create`, and `issue view` ...
are byte-identical to the Python source") becomes false and must be corrected in the same
change. That correction is inside a file already in the write set.

---

## 6. Testing Implications

Repository policy (`.claude/rules/general-unit-test.md`) requires tests to mirror the production
tree and forbids temporary files. The production tree is
`extensions/drm-copilot/src/lib/potential-to-issue/`; the mirror is
`extensions/drm-copilot/test/lib/potential-to-issue/`. Both already exist and are populated,
so **no new ad-hoc location is needed** — the existing files are the correct homes.

### Correct test homes

| Assertion | Home | Why this file |
| --- | --- | --- |
| `--repo <slug>` present, in the correct position, in all three argument vectors | `extensions/drm-copilot/test/lib/potential-to-issue/gh-client.test.ts` | Already owns the exact-vector assertions (lines 123-132, 152-160, 179-186) via the recording `GhCommandRunner` fake |
| Absent `repo` leaves the three vectors byte-identical (backward compatibility for the `promotion.ts:306` default) | same file | same seam |
| Slug resolver behaviour: success, non-zero exit, empty stdout, invalid JSON, non-object payload, non-string field, `cwd` equals the supplied workspace root | **new** `extensions/drm-copilot/test/lib/potential-to-issue/repo-slug.test.ts` | Mirrors the new production module one-for-one, as the tree-mirroring rule requires |
| Slug is derived from the passed `workspace_root` (not the process cwd) and echoed in the result, for a differing root **and** a matching root | `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` | Already owns the result-contract assertions (lines 104-112, 324-325) and already imports `FakeGhClient` / `FakePotentialFileSystem` |

`extensions/drm-copilot/test/mcp-tools.workspace-root.test.ts` is **not** a home for this
regression: it covers only the omitted-`workspace_root` failure envelope with a fully mocked
service and never reaches the promotion path. `promotion.test.ts` and
`promotion.missing-label.test.ts` need no change under the recommended design, because the
binding is on the client and `promotePotential` is untouched.

### Fail-before feasibility

**Both required cases are demonstrable, hermetically, with no live GitHub call.**

*Case A — `workspace_root` differs from the server default (broken today).*

Arrange `potentialToIssueServiceCall` with `FakePotentialFileSystem`, a recording
`CommandRunner`, an injected slug resolver that records the workspace root it was handed and
returns a fixed slug for repository B, and `workspaceRoot` set to B's path. Act. Assert the
resolver received exactly B's path, and that the returned record's repository field equals B's
slug.

- **Before the fix:** the field does not exist on the returned record and the resolver is never
  invoked — the assertions fail on the value, not on a crash.
- **After the fix:** both assertions pass.

*Case B — `workspace_root` matches the server default (works today, must keep working).*

Identical arrangement with `workspaceRoot` set to the default checkout and the resolver
returning repository A's slug. Assert the resolver received that path, the record echoes A's
slug, and every pre-existing assertion in the suite (summary string, `destinationPath`,
`artifacts`) is unchanged.

*Argument-boundary half.* In `gh-client.test.ts`, construct `RealGhClient` with the recording
runner, the injected path lookup, and the repository binding; assert the create vector equals
`["issue","create","--repo","<slug>","--title", ...]`. Against the unmodified source the
constructor option does not exist, so ts-jest reports a compile failure for the suite — a
legitimate but coarse fail-before signal. Case A above is the fine-grained, value-level
fail-before, and the two together cover the chain end to end.

*Cross-cut.* Add the missing-label recovery case to the argument-boundary suite so the retry
leg is asserted to carry the same slug (the recovery is driven by `promotion.ts:371-383`).

### Coverage

Per-file thresholds of 85% line / 75% branch apply to the changed files per the
`jest.config.cjs` convention. The new resolver module is small and fully branch-covered by the
six enumerated failure cases plus the success case. The new conditional in `toMcpToolResult` is
a single ternary whose both arms are exercised by any existing tool result (present for
promotion, absent for every other tool).

---

## 7. Sibling Tools Sharing the Pattern (out of scope)

Every other `gh`-invoking or remote-calling surface in the extension was checked.

| Tool | Remote call | Honours `workspace_root`? |
| --- | --- | --- |
| `collect_pr_context` | `gh` via `pr-context/gh-client-core.ts` | **Yes** for repository selection — `cwd` is threaded from `workspaceRoot` (`pr-context-service-call.ts:73` -> `gh-client-core.ts:83`, used at lines 149, 195, 229) |
| `link_parent_child` | `gh` via the bundled `link-parent-child.ps1` | **Yes** — spawned with `cwd` = `workspaceRoot` (`command-runtime.ts:215-219` via `repo-automation-execute-script.ts:48-55`) |
| `collect_commit_context` | git only, no remote API | Yes (`repo-automation-service-support.ts:115`) |
| `new_potential_entry`, `new_potential_bug_entry`, `new_active_feature_folder` | none | Filesystem-only, as the issue states |
| `potential_to_issue` | `gh` | **No** — this defect |

**Boundary confirmation for `collect_pr_context`.** Its repository selection is correct: the
`cwd` is threaded. The separately tracked defect (`TaskMaster#589` per `issue.md` line 94) is a
**different** defect — an artifact written to the main checkout while worktree paths are
reported — and concerns output-path resolution, not repository selection. It is **not** folded
into this item's scope and requires no change here.

**Other observations, strictly out of scope and recorded only:**

- `mcp-tool-definitions.ts` is imported by no production module (only by five test files) while
  `mcp-repo-automation-tool-definitions.ts` is the live surface. The two are kept in parity by
  test assertion. Not a defect; noted because it is a duplicated surface a future change must
  keep in sync.
- The docstrings in `gh-client.ts:7` and `content.ts:6` reference
  `resources/scripts/dev_tools/potential_to_issue.py`, a path that does not exist. The
  `gh-client.ts` instance is corrected as part of this fix; the `content.ts` instance is out of
  scope.

---

## 8. Push-Down / Bundled Parity

**No bundled copy of the affected logic exists, so no push-down parity obligation follows from
the code change.**

Verified: `extensions/drm-copilot/resources/scripts/dev_tools/` does not exist. A search of
`extensions/drm-copilot/resources/**` for issue-creation logic returns only
`resources/templates/link-parent-child.ps1` (a different tool) and documentation/agent-memory
files. `extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts` lines 80-86 confirms the
direction of travel: the push-down **rewrites references** to
`scripts.dev_tools.potential_to_issue` into the VS Code command id
`drmCopilotExtension.potentialToIssue`, rather than publishing the script.

**A conditional obligation does exist for documentation.**
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` line 23 lists
`.claude/skills/feature-promotion-lifecycle/SKILL.md` in a byte-parity set, asserted at line 123
against the bundled copy at
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md`.
Parallel copies exist under
`extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md`
and `extensions/drm-copilot/resources/customizations/.github/skills/feature-promotion-lifecycle/SKILL.md`.
**Therefore: do not edit the skill document as part of this fix.** Doing so would drag three to
four additional files into the write set and widen the blast radius for a documentation change
the defect does not require. The "docs updated" acceptance criterion is satisfied by the module
docstrings in the files already being changed.

---

## 9. Exact Write Set

Every file the fix must WRITE, deduplicated, repo-relative, concrete paths only.

**Production source (5):**

1. `extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts`
2. `extensions/drm-copilot/src/lib/potential-to-issue/repo-slug.ts` *(new)*
3. `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts`
4. `extensions/drm-copilot/src/repo-automation-service-contract.ts`
5. `extensions/drm-copilot/src/mcp-tools.ts`

**Test source (3):**

6. `extensions/drm-copilot/test/lib/potential-to-issue/gh-client.test.ts`
7. `extensions/drm-copilot/test/lib/potential-to-issue/repo-slug.test.ts` *(new)*
8. `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts`

**Configuration (1):**

9. `extensions/drm-copilot/jest.config.cjs`

**Feature documents updated during delivery (2):**

10. `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/spec.md`
11. `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/issue.md`

### Explicitly NOT in the write set

Stated explicitly so the blast-radius computation is not padded:

- **No policy rule under `.claude/rules/` requires editing.** The fix introduces no new
  invariant, no checkpoint field, no enum member, and no validator. The applicable rules
  (`general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`) are read-by-mandate
  citations, not write targets.
- **`quality-tiers.yml` is not edited.** No project is added or reclassified.
- **No instruction document under `.github/instructions/` is edited.**
- `scripts/dev_tools/potential_to_issue.py` — see section 5.
- `tests/scripts/dev_tools/test_potential_to_issue.py`,
  `tests/scripts/dev_tools/test_potential_to_issue_branches.py`,
  `tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py` — unchanged,
  because the Python module is unchanged.
- `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` and
  `extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts` — the
  recommended design binds the repository on the client, leaving the `GhClient` method
  signatures and the workflow untouched.
- `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` and
  `extensions/drm-copilot/src/mcp-tool-definitions.ts` — no input-schema property is added and
  neither declares an output schema.
- `extensions/drm-copilot/src/repo-automation-service.ts` — already forwards both `runner` and
  `workspaceRoot` (lines 239-246); no change needed.
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` and its three bundled copies — see
  section 8.
- `extensions/drm-copilot/src/mcp-provider.ts` — the cwd binding at lines 45-48 is correct for
  its own purpose (relative-path resolution for a single-window session); the fix removes the
  promotion path's dependence on it rather than changing it.

---

## Automation Feasibility

**The fix and its verification can be completed entirely without human interaction. No live
GitHub call, no second real repository, and no web-UI step is required.**

Basis:

- Both halves of the defect are observable at an **injected seam that already exists**. The
  argument vector is recorded by the `GhCommandRunner` fake in `gh-client.test.ts` (lines
  45-59); the slug derivation and the echoed result are observable through the injected
  resolver seam and the returned record in `potential-to-issue-service-call.test.ts`.
- The GitHub CLI is never executed in the test suite: `gh-client.test.ts` mocks
  `node:child_process` (lines 5-8) and injects `ghPathLookup` (lines 61-62), so neither PATH
  nor a real process is touched.
- The filesystem is faked in-memory (`FakePotentialFileSystem`), so the prohibition on
  temporary files in tests is satisfied without concession.
- Both required cases — `workspace_root` differing from the server default, and
  `workspace_root` matching it — are expressible as pure argument variations against the same
  fakes.

**One unautomatable item is present in the inherited acceptance criteria.** `spec.md` line 130
(carried from `issue.md` line 99) asks for an integration scenario that promotes a throwaway
record against a second real checkout and then deletes the throwaway issue. This is not
automatable in this repository:

- it creates a real GitHub issue in a second repository, which the promotion-gate hook
  `.claude/hooks/enforce-promotion-mcp-only.ps1` exists specifically to keep off the agent
  command surface;
- GitHub issues cannot be deleted by the standard CLI surface — deletion requires an
  administrative action in the web UI — so the "delete the throwaway issue afterwards" step has
  no automated form and would leave residue in a real repository.

**Disposition: `scope_change`.** Replace the live integration retest with the hermetic
injected-CLI regression tests described in section 6. The justification is that the injected
seam observes the **exact argument vector** handed to the CLI, which is the assertion the live
test would only reach indirectly through an issue URL; the hermetic form therefore yields
strictly more precise evidence at the point of the defect, plus deterministic coverage of the
failure branches a live run could not reach on demand.

`exception` is inappropriate — no runbook is needed, because there is a fully equivalent
automated verification path rather than a gap to be worked around under supervision. `halt` is
inappropriate — nothing about the fix is blocked; only one inherited verification technique is
being substituted.

The manual verification note in `spec.md` line 131 ("keep a same-repository promotion in the
same test pass") is retained in full and is satisfied automatically by Case B in section 6.

---

## Verification Notes

- Every line number and quotation in this document was read from the working tree at
  `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3cf396793cc12352` on
  2026-08-23. No claim is inferred from documentation alone.
- The absence of an owner/name resolution helper based on the git remote (section 1.6) was
  established by search across `extensions/drm-copilot/src/` and `scripts/`, not assumed.
- The absence of a bundled copy of the promotion logic (section 8) was established by
  enumerating `extensions/drm-copilot/resources/scripts/dev_tools/` (does not exist) and by
  content search across `extensions/drm-copilot/resources/`.
- No obstruction from `.claude/hooks/enforce-promotion-mcp-only.ps1` was encountered: this
  investigation used the Grep, Glob, and Read tools exclusively and issued no Bash command.
