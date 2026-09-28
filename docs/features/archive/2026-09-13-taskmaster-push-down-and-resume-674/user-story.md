# `2026-09-13-taskmaster-push-down-and-resume` — User Story

- Issue: #674
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-09-14T09-15

## Story Statement

- As an engineer whose local hand-fix to a `drm-copilot`-delivered file (for example, TaskMaster's
  fix to `enforce-model-routing-receipt.ps1`, commit `4389d95b`) can be silently overwritten by the
  next push-down, I want the push-down procedure to gate on a confirmed-fresh source payload and a
  pre-push-down check for un-superseded destination fixes, so that a fix I made in the consumer
  repository is not lost a second time.
- As the operator of TaskMaster parallel run `bugs-2026-09-11`, which reached a complete standstill
  with zero agents runnable, I want the epic's corrected `drm-copilot` hooks and MCP behavior
  delivered to TaskMaster and confirmed to take effect, so that the run's five gate-blocked items
  and one unlandable fix can proceed.
- As a reviewer auditing this feature's evidence after execution, I want every claim that a file
  does or does not carry specific content to name the grep, its scope, and its result, so that I
  can independently confirm the delivery happened rather than trusting a narrative summary.

## Problem / Why

`.claude/**` (166 files) plus `config/blast-radius.json` and `config/orchestration-routing.json` are
pushed from `drm-copilot` into consumer repositories with zero templating. A fix made in a consumer
repository is overwritten by the next push-down. That has already occurred: a local fix to
`enforce-model-routing-receipt.ps1` in TaskMaster (commit `4389d95b`, 2026-09-02) was lost.

The `worktree-scoped-state-resolution` epic repairs a defect class in which `drm-copilot` hooks and
MCP tools resolve orchestration state against the invoking session's current working directory
instead of against the worktree the tool call actually pertains to. Six upstream features produce
the corrected hook, library, and MCP content. Without a delivery step, that content never reaches
the repository whose stalled run motivated the epic.

TaskMaster parallel run `bugs-2026-09-11` is the consumer: a 13-item run reached a standstill with
zero agents runnable, three items merged, five blocked behind gates, and one blocked fix the
orchestration that produced it could not land.

## Personas & Scenarios

- **Persona: Consumer-repository engineer with an at-risk local fix.**
  - Who: an engineer working in TaskMaster (or another consumer repository) who has made a direct
    fix to a file that `drm-copilot`'s push-down also publishes.
  - What they care about: that their fix survives the next time someone runs the push-down tool
    against their repository.
  - Their constraints: they have no visibility into when or from where a push-down will run, and
    the push-down tool itself offers no dry-run, diff, or backup mode to protect them.
  - Their goals and frustrations: they want their fix preserved or consciously superseded by an
    equivalent upstream fix — not silently discarded with no error and no log entry distinguishing
    the two outcomes.
  - Their context and motivations: this has already happened once (commit `4389d95b`), so their
    trust in the push-down mechanism is already reduced.

- **Persona: Orchestration operator resuming a stalled TaskMaster run.**
  - Who: the operator responsible for TaskMaster parallel run `bugs-2026-09-11`.
  - What they care about: getting the run's five gate-blocked items and one unlandable fix moving
    again, and being able to tell a genuine resumption from a false-approval outcome where a gate
    silently validated one item against a sibling item's state.
  - Their constraints: TaskMaster is a separate repository not present in this checkout; they must
    use TaskMaster's own resume tooling and cannot assume `drm-copilot`-style paths apply there.
  - Their goals and frustrations: a run that "moves forward" is not enough evidence on its own,
    per `runbooks/confirm-taskmaster-run-resume.runbook.md`'s explicit false-approval case; they
    need a way to confirm each proceeding item's gate actually consulted that item's own state.
  - Their context and motivations: the standstill blocked all further remediation work until the
    fix landed and was delivered.

- **Scenario: Delivering the epic's fix to TaskMaster after F2-F6 merge.**
  - Who is acting: `epic-orchestrator`, executing F7's plan after F2, F3, F4, F5, and F6 have
    merged into the epic integration branch.
  - What triggered the action: the epic's wave-2 dependency edge `[F2, F3, F4, F5, F6]` on F7 is
    satisfied.
  - What steps do they take: rebuild and reinstall the extension
    (`pwsh -NoProfile -File scripts/dev-tools/publish-sideloaded-extension.ps1 -UseInsiders -Force`);
    hand off to a human to reload the VS Code window (HI-2 exception,
    `runbooks/reload-vscode-window-for-mcp-payload.runbook.md`); grep the installed payload across
    all four discovered `drm-copilot`-identity directories for a changed literal derived from
    `git diff` against the pre-epic base; confirm F1's module is registered in `core.json`'s
    `paths[]`; check the TaskMaster destination for the still-unsuperseded `4389d95b` fix or its
    equivalent; invoke `mcp__drm-copilot__push_down_claude_customizations` with the
    operator-supplied TaskMaster `workspace_root`; grep the destination for the same literal used
    in the pre-push-down check; hand off to a human to confirm run `bugs-2026-09-11` resumes
    (HI-1 exception, `runbooks/confirm-taskmaster-run-resume.runbook.md`).
  - What obstacles or decisions occur: if the pre-push-down staleness grep still finds the old
    literal, the reload did not take effect and the operator repeats the reload step before
    proceeding; if the destination hand-fix check finds an un-superseded fix, the push-down does
    not run against that path until an equivalent upstream fix exists.
  - What outcome do they expect: the destination carries the epic's corrected content (confirmed
    by grep, not by the push-down's exit code), no destination fix was overwritten with a stale
    version, and run `bugs-2026-09-11` resumes its remediation cycles.

## Acceptance Criteria

- [ ] Before any push-down runs, the installed extension's bundled payload is confirmed to carry
      the epic's corrected content, proven by a grep for the changed literal selected per the
      research's `## Q3` guidance, run against `resources/claude-customizations/.claude/hooks/`
      under every installed `drm-copilot`-identity directory discovered at execution time, not by
      the rebuild command's exit code alone.
- [ ] The rebuild-and-reinstall command
      (`pwsh -NoProfile -File scripts/dev-tools/publish-sideloaded-extension.ps1 -UseInsiders -Force`)
      is run and the VS Code window hosting the extension is reloaded per
      `runbooks/reload-vscode-window-for-mcp-payload.runbook.md` (HI-2 exception) before the
      staleness grep above is attempted.
- [ ] F1's `.claude/lib/` module path is confirmed present exactly once in
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`'s
      `paths[]` array (by the parameterized grep in research `## Q2` or F1's own
      `<ModuleName>.Manifest.Tests.ps1` passing both `It` blocks) before the push-down call uses
      `--packs core`.
- [ ] Before the push-down call, the TaskMaster destination is checked for any known,
      still-unsuperseded local hand-fix (for example, the fix TaskMaster commit `4389d95b` made to
      `enforce-model-routing-receipt.ps1`, if still present and not yet matched by an equivalent
      upstream fix from F5); if one is found without an equivalent upstream fix, the push-down does
      not run against that path.
- [ ] `mcp__drm-copilot__push_down_claude_customizations` is invoked with an explicit,
      operator-supplied `workspace_root` naming the TaskMaster destination.
- [ ] After the push-down call, the destination files are confirmed to carry the new content by
      grepping the destination for the identical literal used in the pre-push-down staleness grep
      — the same literal, not a newly chosen one — and this grep result, not the push-down's exit
      code or JSON summary artifact, is the evidence of record.
- [ ] No destination fix is overwritten with a stale version: the pre-push-down hand-fix check
      found either no un-superseded local fix, or one confirmed superseded by the pushed-down
      content, and this is stated in the evidence record.
- [ ] TaskMaster run `bugs-2026-09-11` is confirmed to resume its remediation cycles, per
      `runbooks/confirm-taskmaster-run-resume.runbook.md` (HI-1 exception), which requires
      distinguishing genuine resumption from a false-approval sibling-checkpoint read.
- [ ] Every negative claim recorded in this feature's evidence (for example, "the old literal is
      absent from the destination") carries `SearchScope`, `SearchPatterns`, and `SearchResult`.

## Non-Goals

- No new logic, and no change to hook or MCP behavior. This feature is procedural delivery only; a
  plan that grows an implementation phase changing hook or MCP behavior has taken on another
  feature's scope.
- No change to the upstream features' (F1-F6) content. F7 delivers what F2-F6 produce; it does not
  re-derive, re-implement, or adjust their fixes.
- No VS Code Marketplace publish. The rebuild/reinstall uses the local sideload path
  (`publish-sideloaded-extension.ps1`); the Marketplace publish path
  (`Publish-DrmCopilotExtension.ps1 -Publish`, `.github/workflows/publish-extension.yml`) is
  out of scope and is not touched by this feature.
- No automated substitute for the VS Code window reload (HI-2) or the TaskMaster resume
  confirmation (HI-1). Both remain human-exception steps with their own runbooks; this feature does
  not attempt to script a window reload by killing and relaunching VS Code, nor does it attempt to
  automate an observation inside TaskMaster's own orchestration session.
- No widening of the push-down tool's input schema or addition of a dry-run/diff/backup mode to it.
  The safety check against overwriting a destination fix is an external, plan-level step, not a
  tool-level feature added by this work.
