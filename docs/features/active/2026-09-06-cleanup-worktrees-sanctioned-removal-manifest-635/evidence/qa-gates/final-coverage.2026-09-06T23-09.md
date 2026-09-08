# Final Post-Change Coverage Evidence (CI `_poshqc.yml` Dispatch)

Timestamp: 2026-09-08T08-41

Task: [P8-T5]

Command:
`gh workflow run _poshqc.yml --ref bug/cleanup-worktrees-sanctioned-removal-manifest-635-r2`

EXIT_CODE: 0

## First step — commit, performed by the orchestrator

The plan assigns this task a commit-and-push first step. That step was performed by the
orchestrator under the `orchestrate` skill's Pre-Feature-Review Commit contract before this
executor turn began, so it is recorded here rather than re-performed. Re-running it would have
produced an empty commit and could not have improved the evidence.

| Field | Value |
| --- | --- |
| Feature commit | `c5d4a089593a6fe0b4a08379c0ff63c03ec13d5a` |
| Feature commit message | `fix(cleanup-worktrees): authorize worktree removal via manifest gate` |
| Feature commit size | 54 files, 5854 insertions, 351 deletions |
| Merge commit (current `HEAD`) | `05bbc4e1c1a2aa014dea5aaa4c5b7fce68b2d24f` |
| `origin/bug/cleanup-worktrees-sanctioned-removal-manifest-635-r2` | equals local `HEAD` |
| Diff anchor for this feature's own changes | `d250cf72ee24139735e7f08b07d002ae0e4f1d00` |

The integration branch advanced from `d250cf72` to `0ea7e577` while Phases 1 through 8 ran and was
merged in, producing the merge commit above. The only change it carried was 7 lines in the epic
folder's `epic-status.md`. It touched no file this feature changed, so no conflict arose and no gate
in this plan is affected. `d250cf72ee24139735e7f08b07d002ae0e4f1d00` therefore remains the correct
diff anchor for Phase 7 and [P8-T2].

The acceptance conditions of the commit step are satisfied: the resolved `HEAD` is
`05bbc4e1c1a2aa014dea5aaa4c5b7fce68b2d24f`, which differs from
`d250cf72ee24139735e7f08b07d002ae0e4f1d00`; `origin/...-635-r2` equals local `HEAD`; and the
porcelain status run at the start of this turn produced no output at all, which is stricter than the
stated condition of no entry outside the feature folder.

Command: `git status --porcelain`, exit status 0, zero output lines.
Command: `git rev-parse HEAD`, exit status 0, output `05bbc4e1c1a2aa014dea5aaa4c5b7fce68b2d24f`.

## Run identity

Command: `gh run view 34205298954 --json databaseId,headSha,status,conclusion,createdAt,updatedAt,event`,
exit status 0. Complete result transcribed verbatim:

```json
{"conclusion":"success","createdAt":"2026-09-08T08:35:13Z","databaseId":34205298954,"event":"workflow_dispatch","headSha":"05bbc4e1c1a2aa014dea5aaa4c5b7fce68b2d24f","status":"completed","updatedAt":"2026-09-08T08:40:58Z"}
```

| Field | Value |
| --- | --- |
| Workflow | `.github/workflows/_poshqc.yml` |
| Run id | `34205298954` |
| Head SHA | `05bbc4e1c1a2aa014dea5aaa4c5b7fce68b2d24f` |
| Event | `workflow_dispatch` |
| Status | `completed` |
| Conclusion | `success` |

The recorded run id `34205298954` is **not** `34186767775`, and the recorded head SHA
`05bbc4e1c1a2aa014dea5aaa4c5b7fce68b2d24f` is **not**
`d250cf72ee24139735e7f08b07d002ae0e4f1d00`. Those two values identify the [P0-T7] baseline run,
which this gate must not re-read.

The run id was resolved from the dispatch itself rather than from a `--limit 1` listing. The
dispatch command printed the run URL
`https://github.com/drmoisan/drm-copilot/actions/runs/34205298954` directly, and a pre-dispatch
listing recorded that the only run then existing on this branch was the baseline:

```json
[{"conclusion":"success","createdAt":"2026-09-08T04:22:35Z","databaseId":34186767775,"headSha":"d250cf72ee24139735e7f08b07d002ae0e4f1d00","status":"completed"}]
```

Resolving the id this way removes the failure mode in which `--limit 1` returns the baseline run
because the dispatched run has not yet registered.

The recorded head SHA equals the pushed branch tip recorded in the commit-step table above, so the
measured tree is the tree this feature's work produced.

`status` was confirmed `completed` before any file was read from the artifact. The blocking wait was
`gh run watch 34205298954 --exit-status --interval 20`, exit status 0, which returned only after the
run reached a terminal state; the `gh run view` call above then re-confirmed
`"status":"completed"` independently.

## Artifact retrieval

Command:
`gh run download 34205298954 --name poshqc-test-results --dir artifacts/poshqc-ci/final`,
exit status 0.

All three uploaded members were produced:

```
pester-junit.xml                    1588399 bytes
powershell-coverage.koverage.xml     745767 bytes
powershell-coverage.xml              748955 bytes
```

`_poshqc.yml:44-52` carries no `if: always()` on its upload step, so an artifact exists only when
the Format, Analyze and Test steps all succeeded. The artifact's presence is therefore positive
evidence that all three steps passed, and the missing-artifact failure branch of this gate was not
taken.

The download directory `artifacts/poshqc-ci/final/` is distinct from
`artifacts/poshqc-ci/baseline-34186767775/`, which [P0-T7] wrote. The three member filenames are
identical across runs, so the separation is what preserves the baseline that [P8-T6] reads. Both
directories were confirmed populated after the download.

## Path resolution rule applied

Each `sourcefile` element's repo-relative path is the enclosing `package` element's `name` joined to
the `sourcefile` element's `name` with `/`, which is the shape [P0-T7]'s `Coverage XML Shape:` block
recorded. The `package` `name` attributes in the CI-produced `.koverage.xml` are already
repo-relative because `Convert-PoshQCCoverageToRelative` ran on the runner, so no prefix strip is
needed.

## Value 1 — overall line coverage

The report-level `counter` elements, direct children of the root `report` element of
`artifacts/poshqc-ci/final/powershell-coverage.koverage.xml` (lines 14023-14026), transcribed
verbatim:

```xml
  <counter type="INSTRUCTION" missed="636" covered="11764" />
  <counter type="LINE" missed="408" covered="8563" />
  <counter type="METHOD" missed="36" covered="725" />
  <counter type="CLASS" missed="0" covered="97" />
```

Overall line coverage = 8563 / (8563 + 408) = 8563 / 8971 = **95.4520%**.

The `counter type="CLASS" covered="97"` value records a 97-file denominator, one file larger than
the 96 the baseline run measured. The added file is the new module, which is the direct
observation that the `CodeCoverage.Path` entry [P6-T3] added took effect on this route.

## Values 2 through 4 — per-file line coverage

| Repo-relative path | LINE `covered` | LINE `missed` | Line coverage | At least 85 |
| --- | --- | --- | --- | --- |
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | 100 | 8 | 100 / 108 = **92.5926%** | **yes** |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 100 | 5 | 100 / 105 = **95.2381%** | **yes** |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 74 | 5 | 74 / 79 = **93.6709%** | **yes** |

All three are at least 85, so no per-file coverage shortfall is present.

## Presence of the new module in the denominator

A `sourcefile` entry resolving under the join rule to
`.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` **is present** in the downloaded
coverage XML. Its `package` start tag and `class` element (line 6114) and its `sourcefile` element
(line 6156) are transcribed here, with the `sourcefile` element's trailing counters (lines
6265-6269):

```xml
  <package name=".claude/lib/cleanup-manifest">
    <class name=".claude/lib/cleanup-manifest/CleanupWorktreeManifest" sourcefilename="CleanupWorktreeManifest.psm1">
```

```xml
    <sourcefile name="CleanupWorktreeManifest.psm1">
```

```xml
      <counter type="INSTRUCTION" missed="9" covered="122" />
      <counter type="LINE" missed="8" covered="100" />
      <counter type="METHOD" missed="1" covered="6" />
      <counter type="CLASS" missed="0" covered="1" />
    </sourcefile>
```

The join of the `package` `name` `.claude/lib/cleanup-manifest` to the `sourcefile` `name`
`CleanupWorktreeManifest.psm1` yields exactly the required repo-relative path. This is what proves
the new file sits inside the coverage denominator rather than outside it, and it is the property
AC-25 exists to secure. Its absence would have meant the registration did not take effect and AC-25
would have failed.

An enumeration of every `package`/`sourcefile` pair in the downloaded file counted **97** distinct
`sourcefile` entries, matching the report-level `counter type="CLASS" covered="97"` exactly, so the
per-file index this artifact reads is complete rather than partial.

## Test outcome of the same run, recorded for context

Root `testsuites` start tag of `artifacts/poshqc-ci/final/pester-junit.xml`, transcribed verbatim:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4460" errors="0" failures="0" disabled="9" time="187.741">
```

CI passed = 4460 - 0 - 0 - 9 = **4451**, CI failed = **0**. The suite is clean in the canonical
environment. The two members of the Known-Local-Red Inventory are absent here for the reason
[P0-T7] recorded: `/artifacts` is gitignored, so the orchestration checkpoint that produces both
local denials does not exist on the runner.

## Route reconciliation with AC-25

AC-25 names the self-hosted invocation and excludes `mcp__drm-copilot__run_poshqc_test`. This CI
step is that invocation: `_poshqc.yml:41-42` imports the repository's own `PoshQC.psm1`, which binds
`$script:PesterSettings` to the repository's `settings/pester.runsettings.psd1`
(`scripts/powershell/PoshQC/PoshQC.psm1:1-3`), and calls the same `Invoke-PoshQCTest` function.
Omitting `-SettingsPath` in CI binds exactly the file the criterion's parenthetical passes
explicitly. Only the host differs, and it differs because the local `pwsh` process cannot start
under the runtime worktree-isolation guard. The 97-file denominator measured here against the
88 files the local MCP route emitted is the observed confirmation that the two routes differ in
precisely the way the criterion cares about. The criterion text is not altered.

Output Summary: Post-change coverage captured from `workflow_dispatch` run **34205298954** of
`.github/workflows/_poshqc.yml` at head **05bbc4e1c1a2aa014dea5aaa4c5b7fce68b2d24f**, status
`completed`, conclusion `success`; the run id differs from the [P0-T7] baseline `34186767775` and
the head SHA differs from `d250cf72ee24139735e7f08b07d002ae0e4f1d00`. The `poshqc-test-results`
artifact downloaded to `artifacts/poshqc-ci/final/` with all three members, which confirms the
Format, Analyze and Test steps all passed. Overall line coverage **95.4520%** (8563 / 8971) over a
**97**-file denominator, one file larger than the baseline's 96. Per-file line coverage:
`.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` **92.5926%** (100 / 108),
`.claude/hooks/enforce-epic-worktree-removal-gate.ps1` **95.2381%** (100 / 105),
`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` **93.6709%** (74 / 79). All three are at
least 85. A `sourcefile` entry resolving to the new module is present, proving it is inside the
denominator. The run's Pester totals were 4451 passed and 0 failed of 4460. No failure branch of
this gate was taken.
