# blast-radius-bundled-config-stale-skeleton (Issue #500)

- Date captured: 2026-08-21
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/ (Issue #500)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #500
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/500
- Last Updated: 2026-08-21
- Work Mode: full-bug

> Provenance note: Issue #500 was filed against `drmoisan/TaskMaster` and transferred to this
> repository. The GitHub issue therefore predates this local promotion, so `potential_to_issue`
> was deliberately not invoked (it has no idempotent path and would have filed a duplicate
> issue). See `## Suspected Cause / Notes` for the authoritative, corrected root cause, which
> supersedes the original `## Summary` framing below.

## Summary
`config/blast-radius.json` still declares the umbrella module `claude-runtime -> .claude/**`, which its own governing rule states was removed under the module-map granularity criterion. Because almost every work item in this repository writes something under `.claude/**`, the module fires on nearly every radius, every pair reports `module_overlap`, and the parallel conflict graph approaches a clique. A second, related gap is that `mandate_reads` omits several live read-by-mandate trees, so citations of those paths also become contention.

## Environment
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a - the blast-radius implementation in TaskMaster is PowerShell (`.claude/lib/blast-radius/*.psm1`); PowerShell 7.6.5
- Command/flags used: `Get-BlastRadius`, `Test-BlastRadiusConflict` from `.claude/lib/blast-radius/BlastRadius.psm1`
- Data source or fixture: `config/blast-radius.json` and `.claude/rules/parallel-orchestration.md` at commit `b9a9b92c`

## Steps to Reproduce
1. Check out `main` at `b9a9b92c` (or later).
2. Import `.claude/lib/blast-radius/BlastRadius.psm1` and load `config/blast-radius.json`.
3. Derive two radii from structured plan text whose task lines cite two *unrelated* files under `.claude/**` in inline code - for example `` `.claude/hooks/enforce-mermaid-validation.ps1` `` for item A and `` `.claude/skills/parallel-add/SKILL.md` `` for item B.
4. Call `Test-BlastRadiusConflict` on the pair.
5. Read `.claude/rules/parallel-orchestration.md` around the "Module-map granularity criterion" heading and compare the module list it describes against the shipped config.

## Expected Behavior
Two items editing unrelated files under `.claude/**` - a hook and a skill document - are not editing a shared unit of contention and should report `conflict=False`, so cohort coloring can schedule them concurrently. Per the granularity criterion in the governing rule, `claude-runtime` should not exist as a module at all.

## Actual Behavior
The pair reports `conflict=True` with `{"kind":"module_overlap","detail":"claude-runtime"}`.

`config/blast-radius.json` contains `"claude-runtime": [".claude/**"]`. Meanwhile `.claude/rules/parallel-orchestration.md:251` states that `python-dev-tools`, `vscode-extension`, **`claude-runtime`**, `copilot-surface`, and `agents-surface` "were removed, leaving the seven subsystem modules `mcp-server`, `benchmarks`, `poshqc`, `powershell-dev-tools`, `codex-runtime`, `config`, and `schemas`." TaskMaster's config never received that removal, so it retains precisely the umbrella the rule disqualifies, and the rule's own stated reason applies verbatim: "an umbrella that matches almost every radius is not a coherent unit of contention, because a level that always fires carries no information and only suppresses concurrency."

Measured impact, from an independent derivation over the 16 committed plans under `docs/features/active/`: the `claude-runtime` module matched 10 of 16 plans (62%), the conflict graph reached 83.3% density (100 of 120 pairs), and `compute-cohorts.sh` produced 11 cohorts for 16 items with a maximum parallel width of 2. Under the per-edge barrier the binding constraint becomes cohort depth, so a large `max_concurrency` is inert.

Separately, `mandate_reads` lists only two skill files by exact path. Plans in this repository also routinely cite `.claude/skills/acceptance-criteria-tracking/SKILL.md` (6 of 16 plans), `.claude/skills/policy-compliance-order/SKILL.md` (3 of 16), `.claude/agent-memory/**` (4 of 16), and the `.agents/skills/**` tree (3 of 16) - none of which appear in `mandate_reads`, so reading-order citations become contention.

## Logs / Screenshots
- [x] Attached minimal logs or screenshot
- Snippet - observed on `b9a9b92c`:

  ```text
  claude-runtime globs : ['.claude/**']

  unrelated .claude files   -> conflict=True
     {"detail":"claude-runtime","kind":"module_overlap"}
  ```

  Negative control, two unrelated C# projects, confirming the graph is not simply always-true:

  ```text
  control, no placeholder   -> conflict=False
  ```

## Impact / Severity
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High: it does not fail a build, but it silently converts any parallel run into a near-serial one. A run configured for `max_concurrency: 16` measured a maximum width of 2. The cost is paid as wall-clock and as drift - a late item's plan is prepared against a `main` many merges stale.

## Source
From: docs/features/potential/2026-08-21-blast-radius-claude-runtime-umbrella-serializes-all-work.md


## Suspected Cause / Notes

Authoritative, corrected root cause (from the second issue comment; this supersedes the
`## Summary` framing above).

This repository's self-hosted `config/blast-radius.json` is already correct. It matches the
module-map granularity criterion in `.claude/rules/parallel-orchestration.md`: seven subsystem
modules, no `claude-runtime` umbrella. The defect is that the bundled resource copy shipped by
the push-down payload is a stale skeleton.

Comparison of all copies of `config/blast-radius.json` as of 2026-08-21:

| Copy | modules | shared_surfaces | shared_surface_globs |
| --- | --- | --- | --- |
| `config/blast-radius.json` (self-hosted) | 7 - `benchmarks`, `codex-runtime`, `config`, `mcp-server`, `poshqc`, `powershell-dev-tools`, `schemas`. No `claude-runtime`. | 10 | 3 |
| `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` (what ships) | 2 - `claude-runtime`, `config` | 3 | 0 |
| TaskMaster after push-down | 20 - 18 hand-added C# project modules, plus `claude-runtime` and `config` | 3 | 0 |

Consequences of the stale bundle:

1. It retains the `claude-runtime -> .claude/**` umbrella that the self-hosted config removed, so
   every destination receives a module that matches nearly every work item. This fails closed:
   unrelated items report `module_overlap` and the conflict graph approaches a clique.
2. It ships 3 `shared_surfaces` instead of 10 and zero `shared_surface_globs` instead of 3. This
   fails open: a separator-free root token such as `coverage.config` or `Directory.Build.targets`
   is dropped entirely, so two items editing the same root build file report `conflict=False`.
   This subsumes the separately reported missing-shared-surfaces defect; it is the same staleness.
3. `mandate_reads` omits live read-by-mandate trees that plans in this repository routinely cite,
   so reading-order citations become contention.

Both files named in the original report are push-down destinations, so a fix committed downstream
would be destroyed by the next `push_down_claude_customizations` run. The fix has to land in the
source of the payload, which is this repository.

The placeholder-extraction defect mentioned in the transfer note (`Get-PlanPaths` harvesting
`<FEATURE>/spec.md` as a real path) is genuinely separate, lives in
`.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, and is filed as its own issue. It is out of
scope here.

## Proposed Fix / Validation Ideas

Scope for this run, per the three items suggested in the issue comment:

- [ ] Establish how the bundled copy is produced from the self-hosted one and why the two diverged.
- [ ] Decide and document what a destination-neutral default should contain. `claude-runtime` must
      not be the fallback, because it matches nearly every item in any destination and therefore
      carries no information. A destination's project layout cannot be known upstream.
- [ ] Add a check that the bundled resource does not drift from the self-hosted config beyond an
      explicitly declared, reviewable delta. Also check
      `extensions/drm-copilot/resources/config/orchestration-routing.json`, which
      `.claude/rules/parallel-orchestration.md` states is mirrored byte-for-byte.
- [ ] Unit coverage areas: bundled-config content, drift-gate logic, and the parity assertion.
- [ ] Integration scenario to retest: derive two radii citing unrelated `.claude/**` files against
      the bundled truth table and assert `conflict=False`.

## Next Step

- [x] Promote to GitHub issue (bug-report template) - pre-existing as #500, transferred from
      `drmoisan/TaskMaster`; local `potential_to_issue` deliberately not invoked.
- [x] Move to active fix folder / branch
