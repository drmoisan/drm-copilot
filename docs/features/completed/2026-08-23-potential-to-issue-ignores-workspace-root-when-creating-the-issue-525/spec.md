# 2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue (Spec)

- **Issue:** #525
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-25T10-14
- **Status:** Implemented
- **Work Mode:** full-bug
- **Version:** 1.0

> This spec is the sole acceptance-criteria source for this item, per `acceptance-criteria-tracking`
> and the `full-bug` work mode recorded in `issue.md`. `user-story.md` is intentionally absent.
>
> Authoritative investigation:
> `research/2026-08-23T23-40-workspace-root-gh-repo-selector-research.md`. Section references
> below are to that document.

## Problem Statement

`mcp__drm-copilot__potential_to_issue` accepts a `workspace_root` parameter and honours it for the
filesystem half of a promotion — the promoted record is written and moved under `workspace_root` —
while ignoring it for the GitHub half. The issue is created in whichever repository the GitHub CLI
resolves implicitly from the MCP server process's own working directory.

When `workspace_root` names a checkout other than the one the server was launched from, the two
halves of a single promotion land in **different repositories**. The record is correct; the issue is
filed against the wrong repository and must be reconciled by a manual `gh issue transfer`, which
renumbers the issue and invalidates every reference written before the transfer.

### Observed impact

Two properties make this more damaging than a recoverable misfile:

1. **The failure is silent and the wrong outcome is the default.** The call returns `ok: true` with
   a plausible issue URL. Nothing in the result signals the mismatch. The only detection method
   available today is for an operator to cross-read `destination_path` against the `artifacts` URL
   by eye. `workspace_root` is the only repository-selection parameter the tool exposes, so an
   operator who supplies it correctly has no remaining lever and no warning.
2. **Issue numbers collide across the two repositories.** Both repositories carry issue numbers in
   the same range, so a misfiled reference commonly resolves to a real but unrelated issue rather
   than to nothing. A reader following the reference lands on the wrong ticket with no error.

### Occurrence record

The defect has been observed **four** times. The first three are tabulated in `issue.md`:
`TaskMaster#579` (transferred to `drm-copilot#501`), `TaskMaster#580` (to `drm-copilot#502`), and
`TaskMaster#598` (to `drm-copilot#524`).

The fourth occurrence is **this feature's own promotion.** The record describing this defect was
itself misfiled by the behavior it describes: it was created as `drmoisan/TaskMaster#599` while its
record was written under `drm-copilot`, and required a manual `gh issue transfer` to become
`drmoisan/drm-copilot#525`. The canonical number for this item is therefore the post-transfer
number, #525.

## Root Cause

The defect is **two independent omissions on one call path.** Either omission alone is sufficient to
cause the misfiling, and both are present. Both must be addressed.

**Omission 1 — no repository selector on the argument vector.** The argument vector built for issue
creation carries no `--repo` selector. The two sibling repository-scoped invocations built in the
same module — the label-create recovery call and the issue-view call — share the omission. All three
therefore let the GitHub CLI resolve the target repository implicitly (research §1.1).

**Omission 2 — no working directory on the process spawn.** Neither of the two spawn paths used by
this tool supplies a `cwd`, so the implicit resolution falls back to the working directory the CLI
inherits. The subprocess-runner contract already exposes `cwd` and honours it; the value is simply
never supplied on this path (research §1.1).

**Why the fallback selects the wrong repository.** The MCP server is a long-lived stdio process
whose working directory is fixed at launch to the **first workspace folder of the VS Code window
that launched it** — not to the `workspace_root` of any individual call. A server launched from
window A therefore resolves every implicit `gh` operation to repository A regardless of the
`workspace_root` argument (research §1.1).

**The exact propagation break.** `workspace_root` is threaded correctly through MCP dispatch, input
resolution, the handler, and the service, and then stops at a single expression: the construction of
the real GitHub client in `potential-to-issue-service-call.ts`. `input.workspaceRoot` is in scope on
that line and is not passed to the client, to its command adapter, or to any invocation the client
subsequently makes. **Four lines later the same value IS passed** to the filesystem half of the
promotion. That asymmetry is precisely why one half of a promotion is correct and the other is not
(research §1.2).

The downstream promotion workflow module is not where the defect lives. It receives the workspace
value and consumes it faithfully for every effect it owns, both of them filesystem effects; it never
hands the value to the GitHub client because the client was never given a way to accept it.

**Contrast.** Every other `gh`-invoking surface in the extension supplies a working directory seeded
from `workspace_root`. The promotion tool is the only one that supplies neither a `cwd` nor a
`--repo` (research §1.1, §7).

## Required Behavior

### R1 — The target repository is resolved from `workspace_root`

Before any repository-scoped GitHub operation runs, the promotion path MUST resolve the target
repository to an explicit `owner/name` slug **from the checkout at the resolved `workspace_root`**.
Resolution MUST occur after `workspace_root` normalization, so it always operates on the resolved
value rather than on the raw argument.

The resolved slug MUST be passed explicitly on every repository-scoped argument vector, so that the
process working directory becomes irrelevant to repository selection. This closes both omissions at
once: an explicit selector makes Omission 1 moot, and an explicit selector makes Omission 2 unable
to influence the outcome even if a `cwd` is never supplied.

**Required resolution mechanism.** The slug MUST be resolved by running the GitHub CLI's
repository-view operation for the `nameWithOwner` field, executed with its working directory set to
`workspace_root`, through the already-injected command runner (research §2, Recommended). This
reuses a command, field selection, and tolerance behaviour already proven elsewhere in the
repository, and yields exactly the slug the CLI would itself have resolved from that checkout.

This mechanism is mandatory, not a default the implementation may substitute. **Parsing the `origin`
remote URL is rejected**, both as the primary mechanism and as a fallback leg: it would require a new
URL-parsing surface covering SSH forms, HTTPS forms, the optional `.git` suffix, and enterprise
hosts — none of which exists in the repository — in order to reproduce what one already-proven CLI
call returns, and it would enlarge the write set with a parsing surface this fix does not need
(research §2, Rejected alternatives). No leg of the resolver reads a remote URL.

**No reusable helper exists.** A search across the extension source and the script tree established
that **no git-remote URL parser exists anywhere in the repository**. An existing `repoName()` helper
on the PR-context client performs a related resolution but is **not directly reusable**: its
constructor demands a filesystem dependency and it eagerly performs a second authentication probe on
construction, duplicating a probe the promotion path already makes. Its command and field selection
are reusable as precedent; the class is not. A new, separately tested slug-resolution module is
therefore required (research §1.6).

### R2 — All repository-scoped legs name the same repository

The resolved slug MUST be applied to **every** repository-scoped invocation on the promotion path,
not only to issue creation:

- the issue-creation call;
- the label-create recovery call;
- the issue-view call;
- the **re-created issue on the missing-label recovery leg.** The recovery sequence is
  create → detect missing label → ensure label → re-create; the retry must carry the same slug as
  the initial attempt (research §3, Ordering rules).

### R3 — The same-repository case must be unchanged

A promotion whose `workspace_root` already matches the checkout the server defaults to is the case
that works today. Its outcome MUST be unchanged: the issue is created in that repository, the record
is written under it, and every pre-existing element of the result (summary text, `destination_path`,
`artifacts`) is unchanged. The only observable addition is the echoed slug required by R4.

Backward compatibility also applies at the client boundary: when no repository binding is supplied,
the argument vectors MUST remain byte-identical to their pre-change form, so the existing default
construction in the promotion workflow module continues to work without modification.

### R4 — The result payload must expose the resolved target repository

The result MUST carry the resolved `owner/name` slug in a dedicated field, so a caller can assert
the target at the call site instead of inferring it from an issue URL. **Silent defaulting is what
makes this defect dangerous;** an explicit echoed value makes a mismatch visible without cross-
reading two unrelated fields.

Contract constraints established by the research (§1.3):

- The result is assembled by an explicit three-stage projection, so an unprojected field is silently
  dropped. The new field must be projected at every stage to reach the caller.
- The field is presented snake-cased on the MCP surface, consistent with the existing result keys.
- The field MUST be optional on the shared execution-result contract, so results returned by every
  other tool are unchanged and the field is simply absent for them.
- No tool definition declares an output schema, and the input schemas are unaffected, so no tool
  definition changes and no input-schema constraint can be violated by the addition.
- No orchestrator-state validator imposes a shape on the promotion receipt, and no test pins the
  exact key set of a `potential_to_issue` result, so the addition is additive and non-breaking.

## Error Handling

Repository policy (`.claude/rules/general-code-change.md`) requires failing fast and explicitly and
prohibits silently ignoring errors. Both apply directly here, because the specific silent fallback
available on this path is *the defect itself*.

### E1 — Fail closed on unresolvable slug

When the target repository cannot be resolved from `workspace_root`, the call MUST fail with an
explicit error that names the `workspace_root` that could not be resolved. It MUST NOT fall back to
implicit CLI resolution, and MUST NOT proceed with an absent selector. **A silent fallback to the
old behavior reintroduces the defect**, converting a loud failure into the same silent misfiling.

The cost of failing closed is bounded: the promotion path already requires an authenticated CLI, and
the subsequent create call requires network access regardless, so an environment in which resolution
fails is an environment in which the promotion could not have succeeded (research §2, Failure
policy).

### E2 — Resolution failure occurs before any side effect

The failure transition MUST occur before any GitHub write and before the filesystem move of the
potential record. A failed resolution therefore leaves the potential record in place and creates no
issue, so the operation is safely retryable after the underlying cause is corrected (research §4,
State model).

### E3 — Enumerated unresolvable conditions

The following conditions are all "cannot resolve" and all take the E1 path:

- the checkout at `workspace_root` has **no `origin` remote**;
- the resolution command exits non-zero;
- the resolution command produces empty output;
- the output is unparseable, or is parseable but is not an object;
- the expected owner/name field is missing, or is present but is not a string;
- the remote URL is in an **unrecognized form** (see E4). **UNREACHABLE under the adopted
  mechanism.** E4 is retired: the resolver required by R1 runs the GitHub CLI repository-view
  operation and reads no remote URL on any leg, so there is no point at which a URL form could be
  encountered, and this condition cannot arise. The bullet is annotated rather than deleted because
  deleting it would silently shrink a stated requirement enumeration; retaining it preserves the
  audit trail and records that no implementation branch and no test exists for it, so a later reader
  does not implement a branch that cannot be reached. This annotation becomes void if a future
  change introduces a leg that parses a remote URL, at which point E4's stated condition for
  becoming binding again applies.

The tolerance behaviour for the middle four conditions mirrors the proven behaviour of the existing
PR-context resolver, with one deliberate difference: where that resolver converts an unusable
outcome into a null result, this one MUST convert it into an explicit throw, because this caller must
fail closed (research §2, §4).

### E4 — Remote URL forms (retired)

**This requirement is retired and imposes no obligation on this change.** The mechanism required by
R1 resolves the slug through the GitHub CLI and reads no remote URL on any leg, so there is no point
at which a URL form could be encountered, normalized, or rejected.

The obligation originated in the **Suspected Cause / Notes** section of the promoted bug report,
which stated that the fix was "probably" to derive the repository from the `origin` remote. That was
a reporter's hypothesis recorded before any investigation, not a requirement. The subsequent research
established by search that no git-remote URL parser exists anywhere in the repository and that
building one would reproduce what one already-proven CLI call returns. The mechanism ruling follows
the evidence rather than the hypothesis, and the URL-form obligation retires with the hypothesis that
produced it. The E3 cross-reference to this section is likewise unreachable for the same reason; E3
is retained verbatim.

**Condition under which this becomes binding again.** If a future change introduces any leg that
parses a remote URL, this requirement becomes binding at that point in full: that leg MUST accept the
SSH form `git@host:owner/name` and the HTTPS form `https://host/owner/name`, MUST treat the trailing
`.git` suffix as optional and absent from the resolved slug, and MUST treat an unrecognized form as
an unresolvable condition under E1. Such a change must restate the obligation as a live requirement
rather than rely on this note.

### E5 — Pre-existing failure surfaces are preserved

All existing failure behaviour is unchanged: promotion-error propagation, the non-zero-exit throw
from the command runner, and the destination-existence post-condition (research §3).

## Scope & Non-Goals

### In scope

- Explicit repository selection on every repository-scoped GitHub invocation of the promotion path.
- A new, separately tested slug-resolution module with the fail-closed policy of E1–E3.
- Threading `workspace_root` past the propagation break identified in the Root Cause section.
- Echoing the resolved slug through the result projection chain to the MCP surface.
- Correcting the stale parity claim described in the non-goal below, in-file.

### Explicit non-goals

**`scripts/dev_tools/potential_to_issue.py` is out of the write set.** The Python sibling carries the
same two omissions in its own code, but it is excluded on a structural ground, not on convenience:
**the Python CLI exposes no workspace parameter at all.** Its argument parser declares no workspace
flag and its entry point passes none, so the workspace path is unconditionally the repository the
script itself lives in. The defect under repair is "one parameter, two effects, one honoured"; that
divergence **cannot be exhibited** on a surface that has no such parameter. Adding a repository
selector derived from a workspace value there would bind to a value that is by construction the
script's own repository. This follows the precedent recorded for the immediately preceding defect in
the same subsystem, where a deliberate TypeScript-only correction was documented with a structural
justification (research §1.5, §5).

> **Documentation obligation that does follow.** A docstring in the TypeScript GitHub client claims
> that its argument vectors are **byte-identical** to those of the Python sibling. That claim becomes
> **false** the moment `--repo` is added. It MUST be corrected in the same change, in-file, to state
> the divergence and its reason. The file is already in the write set, so this adds no blast radius
> (research §5).

**The PR-context sibling defect is out of scope.** `collect_pr_context` was checked and its
*repository selection* is already correct — its working directory is threaded from `workspace_root`.
The separately tracked defect against that tool (an artifact written to the main checkout while
worktree paths are reported) concerns **output-path resolution, not repository selection**. It is a
different defect in a different dimension and is not folded into this item (research §7).

**Also excluded**, each for a stated reason:

- The MCP provider's launch-time working-directory binding. It is correct for its own purpose
  (relative-path resolution for a single-window session). This fix removes the promotion path's
  *dependence* on it rather than changing it.
- The promotion workflow module and its shared test support. Binding the repository on the client
  leaves the client's method signatures and the workflow untouched.
- The tool-definition modules. No input-schema property is added and neither declares an output
  schema.
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` and its three bundled copies. They are held
  in byte-parity by test; editing the skill would drag three to four additional files into the write
  set for a documentation change this defect does not require. The documentation obligation is
  satisfied by the module docstrings in files already being changed (research §8).
- No policy rule under `.claude/rules/`, no `quality-tiers.yml` entry, and no `.github/instructions/`
  document is edited. The fix introduces no new invariant, checkpoint field, enum member, or
  validator.

### Push-down parity

No bundled copy of the affected logic exists, so **no push-down parity obligation follows from the
code change.** This was verified by enumerating the bundled resource tree and by content search
across it (research §8).

## Verification Strategy and the Recorded Human-Interaction Disposition

### Recorded disposition: `scope_change` (do not relitigate)

One inherited acceptance criterion, carried from `issue.md`, required an integration retest that
promotes a **throwaway record against a second real repository** and **deletes the resulting issue
afterwards**. That criterion cannot complete unattended:

- it creates a real GitHub issue in a second repository, which the promotion-gate hook exists
  specifically to keep off the agent command surface; and
- **GitHub issues cannot be deleted through the CLI** — deletion is an administrative web-UI action —
  so the cleanup step has no automated form and would leave residue in a real repository.

**The orchestrator has recorded the disposition `scope_change`.** The live integration retest is
replaced by **hermetic argument-boundary assertions against an injected fake GitHub CLI**, which
assert the **exact argument vector** handed to the CLI rather than inferring the target repository
from a returned URL.

This is a **stronger assertion, not a weaker substitute.** The live test could only observe the
target repository indirectly, through the issue URL in the result; the hermetic form observes the
selector at the exact point of the defect and additionally reaches the failure branches of E3
on demand, which a live run could not. `exception` was inappropriate because no runbook is needed —
there is a fully equivalent automated path, not a gap to be supervised. `halt` was inappropriate
because nothing about the fix is blocked; one verification technique is substituted (research,
Automation Feasibility).

**A later reviewer must not read the removal of the live-integration criterion as a dropped
requirement.** It is a recorded scope change with a stronger replacement.

**The same-repository criterion is RETAINED in full.** A promotion whose `workspace_root` already
matches the default must keep working (R3), and it is verified in the same test pass.

### Test seams

The seams required for hermetic verification already exist (research §1.4, §6):

- a recording command-runner fake at the process-runner boundary, which already asserts exact
  argument vectors for all three repository-scoped invocations;
- a client-level fake implementing the GitHub-client interface;
- an in-memory filesystem fake, so no test creates a temporary file — consistent with
  `.claude/rules/general-unit-test.md`, which prohibits temporary files in tests;
- the CLI executable is never located or executed: the child-process module is mocked and the path
  lookup is injected.

Tests live in the existing mirror of the production tree, plus one new test file mirroring the new
resolver module one-for-one, as the tree-mirroring rule requires. No ad-hoc test location is needed.

### Fail-before demonstrability

Both required cases are demonstrable hermetically. The case where `workspace_root` differs from the
server default fails today on a **value assertion** — the resolver is never invoked and the echoed
field does not exist — rather than on a crash, which is the fine-grained fail-before signal. The
argument-boundary assertion supplies a coarser compile-level fail-before against unmodified source.
The two together cover the chain end to end (research §6).

## Assumptions, Constraints, Dependencies

- **Assumption.** `workspace_root` names a git checkout with a resolvable `origin`. A linked git
  worktree resolves the same slug as its primary checkout, so worktrees need no special handling
  (research §3, Edge cases).
- **Constraint — coverage.** The extension's Jest configuration uses **per-changed-file** coverage
  thresholds with no global key. Threshold entries must exist for the changed extension files, at
  85% line and 75% branch per `.claude/rules/quality-tiers.md`. An interface-only contract file is
  already documented as excluded from the threshold gate and needs no entry (research §4).
- **Constraint — performance.** One additional CLI invocation per promotion, on a path that already
  makes three to four. No latency budget is defined for this path and none is introduced.
- **Dependency.** The GitHub CLI, already a hard dependency of this path.

## Acceptance Criteria

- [x] The argument vector for issue creation carries an explicit `--repo <owner/name>` selector whose
      slug was resolved from the call's `workspace_root`, asserted at the injected CLI boundary by a
      recording fake with no live GitHub call.
- [x] The label-create recovery call and the issue-view call carry the same `--repo <owner/name>`
      selector as the issue-creation call.
- [x] The re-created issue on the missing-label recovery leg carries the same `--repo <owner/name>`
      selector as the initial creation attempt.
- [x] The slug-resolution operation is performed against the checkout at the resolved
      `workspace_root`, asserted through an injected seam that records the workspace value it was
      handed; the recorded value equals the `workspace_root` supplied to the call and is not the
      process working directory.
- [x] With no repository binding supplied to the GitHub client, the three repository-scoped argument
      vectors are byte-identical to their pre-change form, so the existing default construction in
      the promotion workflow module is unaffected.
- [x] A promotion whose `workspace_root` equals the server's own checkout produces unchanged summary
      text, `destination_path`, and `artifacts` values, and echoes that checkout's slug; every
      pre-existing assertion in the affected test suites passes without modification to its expected
      values.
- [x] A successful promotion result exposes the resolved `owner/name` slug in a dedicated field that
      reaches the MCP surface snake-cased, verified through the full result projection chain rather
      than only at the service-call return.
- [x] The echoed field is optional on the shared execution-result contract, and results returned by
      tools other than `potential_to_issue` are unchanged, with the field absent.
- [x] When the slug cannot be resolved, the call fails with an explicit error whose message names
      the `workspace_root` that could not be resolved; no `--repo`-less GitHub invocation and no
      implicit-resolution fallback occurs on that path.
- [x] On a resolution failure, no issue-creation invocation is made and the potential record is not
      moved, asserted against the recording CLI fake and the in-memory filesystem fake.
- [x] The slug resolver has unit tests covering, at minimum: successful resolution; a checkout with
      no `origin` remote; non-zero exit of the resolution command; empty output; unparseable output;
      a parseable payload that is not an object; and a missing or non-string owner/name field.
- [x] The docstring in the TypeScript GitHub client no longer asserts byte-identical argument vectors
      with the Python sibling, and states the divergence and its reason.
- [x] `scripts/dev_tools/potential_to_issue.py` and its three dedicated pytest modules are unmodified
      in the branch diff.
- [x] No file under `.claude/skills/feature-promotion-lifecycle/`, no bundled copy of it, no file
      under `.claude/rules/`, and no tool-definition module appears in the branch diff.
- [x] Per-changed-file Jest coverage thresholds of 85% line and 75% branch are configured for and met
      by every changed extension source file, including the new resolver module.
- [x] New and updated tests create no temporary files, mock the child-process boundary, and inject
      the CLI path lookup, so the suite passes with no network access and no real GitHub CLI
      execution.
- [x] The full seven-stage toolchain (format → lint → type-check → architecture → unit tests →
      contract checks → integration tests) completes without errors in a single pass.

## Risks & Mitigations

- **Risk — the added CLI invocation fails in an environment where the promotion would otherwise have
  succeeded.** Mitigated by the bounded-cost argument in E1: the path already requires an
  authenticated CLI and a network call, so the failure surface is not materially widened.
- **Risk — fail-closed converts a previously "successful" call into an error.** This is intended.
  The previously successful outcome in the affected case was a misfiled issue. The mitigation is
  that E2 places the failure before any side effect, leaving the promotion retryable.
- **Risk — the added result field breaks a strict-shape consumer.** Assessed as low: no output
  schema is declared, no validator constrains the promotion receipt, no test pins the result key
  set, and the VS Code command surface discards the result entirely (research §1.3).
- **Risk — a later reader finds the SSH/HTTPS language in the bug report and treats its absence from
  the implementation as a dropped requirement.** Mitigated by the retirement statement under E4,
  which records that the obligation originated in pre-investigation speculation, that the required
  mechanism reads no remote URL, and the condition under which the obligation would become binding
  again.

## Rollout & Follow-up

- No feature flag, migration, or staged rollout. The change is a behavioural correction on a
  developer-tooling path with no persistent state.
- **Follow-up already tracked separately:** the PR-context output-path defect described under
  non-goals. It is not scheduled by this item.
- **Follow-up recorded, not scheduled:** a stale docstring in a sibling content module references a
  bundled Python script path that does not exist in the tree. Only the instance in the file already
  being changed is corrected here (research §7).
- Links: issue #525; research document referenced in the header.
