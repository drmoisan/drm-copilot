# cleanup-worktrees-preserve-file-consolidation — User Story

- Issue: #637
- Parent: epic `cleanup-merged-worktrees-hardening` (child F; gap 5)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-09-07
- Work Mode: `full-bug`

## Why this document exists for a `full-bug`

`.claude/skills/feature-promotion-lifecycle/SKILL.md` treats `user-story.md` as normally absent for
`full-bug` work. **It is required here, and producing it is permitted.** Both halves of that
statement were verified by reading the enforcing code on 2026-09-07:

- **Required.** `scripts/dev_tools/epic_planner_readiness.py` line 187 iterates
  `("issue.md", "spec.md", "user-story.md")` and calls `_read_required` for each one inside every
  prepared epic-child feature folder. An epic child whose folder lacks `user-story.md` therefore
  cannot reach execution readiness, whatever its work mode.
- **Permitted.** `.claude/hooks/enforce-prd-feature-before-planner.ps1`
  `Get-PrdFeatureRequiredFile` returns `spec.md` alone for `full-bug`, and the predicate that
  consumes it, `Get-PrdFeatureMissingFile`, reports only the subset of *required* files that is
  missing. It never inspects the folder for additional files, so the hook does not deny when
  `user-story.md` is additionally present.

The hook's docstring nonetheless states that `user-story.md` "is required to be ABSENT for
full-bug and minor-audit work". That prose conflicts with `epic_planner_readiness.py`; the enforced
behavior does not. The conflict is recorded as a documentation-correction item in `spec.md` and is
not fixed by this child.

**`spec.md` is the authoritative acceptance-criteria source for this `full-bug`.** This document
deliberately carries no acceptance-criteria checkbox list, so there is exactly one place where
criteria are tracked and checked off.

## Story Statement

- As the **operator running `/cleanup-merged-worktrees`**, I want the tool to stage the untracked
  and modified files that my editorial pass marked `PRESERVE`, so that consolidating a run whose
  only unique content was never committed is a deterministic script action rather than an hour of
  manual copying.
- As the **operator**, I want each preserved lesson file's `MEMORY.md` index line carried into the
  destination namespace's index, so that a preserved lesson is reachable from the index instead of
  becoming an orphaned file nobody finds.
- As the **operator**, I want the index line written in the index file's own line-ending
  convention, re-derived from that file's current bytes, so that appending to a CRLF index does not
  leave it with mixed endings.
- As the **repository owner**, I want the tool to refuse outright — not warn — when a file about to
  be staged still carries an account or host token, so that a personal path or address cannot reach
  a pushed commit through an automated step.
- As the **reviewer of a cleanup run**, I want one machine-readable record per preserved file, so
  that the run's report shows what was preserved, from which worktree, and under which triage
  verdict, without reading the diff.

## Problem / Why

The 2026-09-06 `/cleanup-merged-worktrees` run produced the case the tool handles worst. Report mode
emits `COMMIT|` records only for committed residual commits; that run had none. What it did have was
roughly 140 never-committed files across 20 worktrees — untracked `.claude/agent-memory/**` lesson
files and modified feature-folder drafts — and the script had no way to see or stage any of them.

Two independent reasons made that content invisible. The script's only consolidation input is the
`COMMIT|` record stream, and there is no untracked or modified staging path anywhere in
`scripts/bash/`. Separately, the repository-root `.claude/agent-memory` tree is gitignored, so it
does not appear in a plain `git status --porcelain` either.

The consolidation was therefore done by hand: copy the files into a manually created
`documentationandmemories` worktree, append each file's `MEMORY.md` index line taken from the source
worktree, normalize line endings, sanitize account and host tokens, commit, push. Each of the three
manual steps failed at least once during that run: a dropped index line left a lesson file
unreachable from its index; an LF line appended to a CRLF index produced mixed endings; and an
unsanitized token reached a commit.

One correction to the original report matters enough to state in the narrative, because it changes
what "the step did nothing" means. **The consolidation step was never reachable.** Verified by
execution on 2026-09-07: `scripts/bash/cleanup-worktrees.sh` dispatches only report, apply, and
help, and `--consolidate` falls through to a usage error with exit 2. The step did not run and find
nothing; it did not run.

## Personas & Scenarios

### Persona — the cleanup operator

- **Who they are.** The engineer or agent driving `/cleanup-merged-worktrees` at the end of an epic,
  working from a Windows 11 host with the bash toolchain under WSL Ubuntu.
- **What they care about.** Finishing cleanup in one session, and not losing a lesson file that
  cost real investigation to write.
- **Their constraints.** They cannot force-remove a dirty worktree, cannot delete a `NOT_MERGED`
  branch through the script, and must confirm every destructive action individually. They are also
  working across many worktrees at once, so anything they must do per file, by hand, is where
  mistakes happen.
- **Their frustration today.** The one step that is supposed to protect content is the step that
  silently protects nothing, and the manual substitute is precisely the error-prone work the tool
  exists to remove.

### Persona — the repository owner

- **Who they are.** The owner of the public repository the consolidation PR is pushed to.
- **What they care about.** That an automated step never pushes a commit containing a personal
  account path, a machine path, or an email address.
- **Their constraint.** The repository legitimately contains those strings in many places —
  `.claude/settings.json` holds an absolute path with the account name, and hundreds of tracked
  documents quote Windows paths — so a blanket repository scan is not an option. The check has to be
  narrow enough to be usable and strict enough to be worth having.

### Scenario — a cleanup run whose only unique content was never committed

1. **Trigger.** An epic's PRs have merged. The operator runs
   `bash scripts/bash/cleanup-worktrees.sh` in report mode. It classifies branches and worktrees and
   emits no `COMMIT|` records: nothing unique was ever committed.
2. **Triage.** Several worktrees are reported dirty. The operator runs the skill's Dirty Worktree
   Triage Procedure, fanning out read-only investigations, and each returns a per-file verdict. Some
   files are `SAFE_TO_DELETE`; a handful of agent-memory lesson files come back `GENUINELY_NEW`.
3. **Recording the findings.** The editorial pass writes the run's manifest, including one
   `preserved_files[]` entry per `PRESERVE` finding: which worktree holds it, its path, whether it
   is untracked or modified, its verdict, where it should land on the consolidation branch, its
   `MEMORY.md` index line, and its evidence.
4. **Staging.** With a consolidation worktree already in place, the operator runs the tool's
   preserve pass. It reads the manifest, validates every field fail-closed, and — before writing
   anything — scans the bytes of each named source file for account and host tokens.
5. **An obstacle occurs.** One lesson file quotes the operator's own home directory. The pass stops.
   Nothing is copied, nothing is appended, nothing is staged — not for that file and not for any
   other. The report names the file and the pattern that matched, and the pass exits with a distinct
   non-zero status.
6. **Recovery.** The operator edits that one file to remove the path and re-runs the pass. The
   second run is idempotent: files already correct are staged again without duplicating index
   entries.
7. **Outcome.** Each preserved file is copied to its destination on the consolidation branch and
   staged. Each new lesson file's index line is appended to the destination namespace's `MEMORY.md`,
   terminated in that file's own convention as re-derived from its current bytes — not from the
   value the manifest advised, which in one case was stale and is reported as a mismatch. The report
   carries one `PRESERVE|` record per file plus a companion result record per outcome. The operator
   commits, pushes, and proceeds to the PR step with the content preserved and the index intact.

### Scenario — the destination index does not exist yet

1. A preserved lesson file belongs to an agent namespace that has no `MEMORY.md` on `main`. This is
   the normal case, not an edge case: the consolidation worktree is created from `main`, and only
   two namespaces carry a tracked index there.
2. The pass creates the index containing the carried line, and reports the creation explicitly
   rather than treating it as an ordinary append.
3. The run does not report a clean success. The operator is told an index was created, because a
   newly created index may need scope frontmatter depending on where it landed, and the tool does
   not invent content it was not given.

## Observable Outcome

After this change, a cleanup run whose only unique content is untracked or modified produces:

- one `PRESERVE|` record per preserved file, naming the worktree, the source path, and the triage
  verdict;
- one companion result record per file naming the outcome — staged, blocked on a host token,
  refused because the destination is gitignored, skipped because a manifest field was missing, or
  skipped because the source file was gone;
- the preserved files copied and staged on the consolidation branch, with no force flag used
  anywhere;
- each carried index line appended verbatim, terminated in the destination index's re-derived
  convention, with a reported signal whenever the manifest's advisory value disagreed;
- nothing at all staged when any file still carries an account or host token, and a distinct exit
  status saying so.

## Non-Goals

Stated here as narrative boundaries. The full list, each with its reason, is in `spec.md` under
`## Out of scope / non-goals`.

- This work does not restore the missing consolidation driver. Creating the consolidation worktree
  and cherry-picking committed residuals remain unwired; that is a larger defect than the one this
  story describes, and it is recorded as a follow-up candidate rather than absorbed here.
- This work does not commit or push. It stages, and the refusal is enforced at the staging boundary,
  which is strictly earlier than a commit.
- This work does not decide whether preserved agent-memory files belong at the gitignored repository
  root or in the tracked push-down mirror. That is a cross-child contract question, escalated to the
  epic planner; this work behaves correctly and visibly for either answer and never forces an
  ignored path into the index.
- This work does not scan the repository, the push-down bundle, or the manifest for host tokens. It
  scans the bytes of the file it is about to stage, and nothing else.
- This work changes no enforcement hook and does not grow
  `scripts/bash/cleanup_worktrees_lib.sh`.

## Where the Acceptance Criteria Live

`docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/spec.md`, under
the `## Acceptance Criteria` heading, as identified checkboxes AC-01 onward. This document
intentionally carries none, so there is a single tracked source.
