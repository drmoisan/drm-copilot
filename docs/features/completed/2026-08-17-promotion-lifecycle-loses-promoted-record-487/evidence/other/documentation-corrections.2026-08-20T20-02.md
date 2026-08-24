# Documentation Corrections [P5-T5]

Timestamp: 2026-08-20T20-02

Records the disposition of P5-T1 through P5-T4. All four were **applied**; none was declined.

---

## P5-T1 — `docs/engineering/Feature Playbook.md:14`

Disposition: **applied**

Before:

> `scripts/dev_tools/new_active_feature_folder.py` – create/seed `docs/features/active/<feature>-<issue>/` from templates and matching potential/promoted doc; auto-fill issue/owner/last updated and move the promoted potential into the active folder as `issue.md` (Python).

After:

> `scripts/dev_tools/new_active_feature_folder.py` – create/seed `docs/features/active/<feature>-<issue>/` from templates and matching potential/promoted doc; auto-fill issue/owner/last updated and copy the promoted potential into the active folder as `issue.md`, retaining the promoted record under `docs/features/potential/promoted/` (Python). A potential file that was not promoted — one resolved from `docs/features/potential/` directly — is still moved rather than copied.

The correction changes "move" to "copy" for the promoted case, states the retention explicitly, and adds the move case so the sentence describes both arms of the disposition rule rather than replacing one wrong absolute with another.

---

## P5-T2 — `docs/features/potential/README.md:6`

Disposition: **applied**

Before:

> 2. Move the file into `docs/features/active/<feature-name>/` using the folder template.

After:

> 2. Copy the file into `docs/features/active/<feature-name>/` using the folder template. Once the file has been promoted it lives under `promoted/`, and that record is retained there rather than moved, so the promotion history survives.

---

## P5-T3 — `docs/research/2026-07-09-potential-entries-duplicate-audit.md`

Disposition: **applied — appended only; the historical body is unchanged**

A dated section `## Correction — 2026-08-20 (issue #487)` was appended at the end of the file. No line of the original body was rewritten, deleted, or reworded, in accordance with the plan's "append only" instruction.

The appended note records:

1. **The falsified claim.** Line 15 (repeated at line 28) asserted that files moved into `promoted/` "stay there permanently as the historical record of promotion; no code path deletes or relocates them afterward." The note states this was false when written and identifies the code path that relocated them: `new_active_feature_folder`'s unconditional move at `flow.ts:283` and `:346`, mirrored in Python at `new_active_feature_folder_flow.py:206` and `:266`.
2. **Why the audit missed it,** on two independent grounds. First, the supporting grep at line 24 was scoped to `extensions/drm-copilot/src/lib/potential-to-issue/` only, while the deleting code lived in the never-examined `new-active-feature-folder` cluster; a directory-scoped search cannot establish a repository-scoped negative claim. Second, the term set `delete|remove|cleanup|unlink` would have missed the defect even in the right directory, because the destroying operation was `move` — and the claim at line 15 explicitly covered relocation as well as deletion.
3. **What is not retracted.** The readings of `promotePotential` and `potential_to_issue.py` at lines 19 and 21 were accurate and remain so; the error was generalizing from those two functions to a repository-wide invariant without examining the consuming workflow.
4. **Current state,** including that the described behavior now holds by fix rather than by prior fact, and that retroactive repair of previously lost records was out of scope, so the historical gap is permanent.
5. **A method note** for future audits about matching claim scope to search scope.

---

## P5-T4 — `.claude/skills/feature-promotion-lifecycle/SKILL.md`

Disposition: **applied** (the plan marked this optional per spec; it was implemented rather than declined, so no decline reason is recorded)

Two changes were made to the post-`new_active_feature_folder` integrity checks:

1. A line was added to the existing step `4a) Verify minor-audit folder integrity before proceeding`:

   > - the promoted record under `docs/features/potential/promoted/` is still present (see 4b)

2. A new step `4b` was added immediately after it:

   > 4b) Verify the promoted record was retained after `new_active_feature_folder`:
   > - the promoted file the earlier `potential_to_issue` step reported as its `destination_path` must still exist under `docs/features/potential/promoted/`
   > - `new_active_feature_folder` COPIES a promoted source into the active folder as `issue.md`; it MOVES a source resolved from `docs/features/potential/` directly. An absent promoted record after a promoted-source run is a defect, not expected cleanup (issue #487).
   > - this check applies to every work mode, not only `minor-audit`

The check is bound to the `destination_path` the `potential_to_issue` receipt reports, which is the same value the P3-T4 post-condition now verifies at the service-call layer, so the skill-level check and the code-level check reference the same path rather than two independently derived ones.

---

## Scope Note

`.claude/skills/feature-promotion-lifecycle/SKILL.md` is a skill file, not a policy file. No file under `.claude/rules/` or `.github/instructions/` was modified by this phase or by any other phase of this plan; that is verified independently at P6-T6.
