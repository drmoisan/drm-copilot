# AC18 Verification — Feature Review

Timestamp: 2026-08-26T09-05

Repository worktree: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`
Branch: `bug/tag-push-can-silently-skip-npm-publish-526`
Commit under review: `c8867713453c25ec749bc412308b5516de402616`
Pull request: #564, https://github.com/drmoisan/drm-copilot/pull/564, base `main`, state `OPEN`.

This artifact records the independent re-derivation of the evidence used to decide AC18. It does not
trust the run identifiers or conclusions supplied in the task prompt; each was re-queried directly
against GitHub.

## AC18 verbatim text

> AC18 — A green run of `publish-mcp-npm.yml` against the branch head exists, produced by the new
> `pull_request` trigger, and the run's publish-step conclusion is `skipped`. The run URL and the
> step conclusion are recorded under
> `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/`.
> This satisfies `modified-workflow-needs-green-run` and consumes no version number.

## Clause-by-clause verification

### Clause 1 — "A green run of `publish-mcp-npm.yml` ... exists"

Command:
```
gh run list --workflow=publish-mcp-npm.yml --event=pull_request --limit 10 --json databaseId,event,headSha,headBranch,conclusion,status,url,createdAt
```

Observed output (single matching run):
```json
[{"conclusion":"success","createdAt":"2026-08-26T08:45:28Z","databaseId":32949401667,
  "event":"pull_request","headBranch":"bug/tag-push-can-silently-skip-npm-publish-526",
  "headSha":"c8867713453c25ec749bc412308b5516de402616","status":"completed",
  "url":"https://github.com/drmoisan/drm-copilot/actions/runs/32949401667"}]
```

Run `32949401667` has `status: completed` and `conclusion: success`. **Verdict: PASS.**

### Clause 2 — "against the branch head"

Command:
```
git rev-parse HEAD
git branch --show-current
gh pr view 564 --json headRefOid,headRefName,baseRefName,state
```

Observed:
- `git rev-parse HEAD` -> `c8867713453c25ec749bc412308b5516de402616`
- `git branch --show-current` -> `bug/tag-push-can-silently-skip-npm-publish-526`
- `gh pr view 564` -> `{"baseRefName":"main","headRefName":"bug/tag-push-can-silently-skip-npm-publish-526","headRefOid":"c8867713453c25ec749bc412308b5516de402616","state":"OPEN"}`

The run's `headSha` (`c8867713453c25ec749bc412308b5516de402616`) matches both the worktree's current
`HEAD` and PR #564's `headRefOid`. The run is against the current branch head, not an earlier commit.
**Verdict: PASS.**

### Clause 3 — "produced by the new `pull_request` trigger"

Two checks: (a) the run's `event` field, (b) that the trigger is in fact new (added on this branch,
absent from `main`).

(a) The run listing above shows `"event":"pull_request"` for run `32949401667`.

(b) Command:
```
sed -n '1,20p' .github/workflows/publish-mcp-npm.yml
git merge-base main HEAD
git show <merge-base>:.github/workflows/publish-mcp-npm.yml | sed -n '1,20p'
```

Observed: the working-tree file's `on:` block carries:
```yaml
on:
  push:
    tags:
      - "mcp-server-v*"
  workflow_dispatch:
  # Validate build/package on PRs that touch the mcp-server package or this workflow.
  # ...this provides the green branch-head run required by
  # the modified-workflow-needs-green-run rule for a diff to this file (issue #526).
  pull_request:
    paths:
      - "packages/mcp-server/**"
      - ".github/workflows/publish-mcp-npm.yml"
```

The merge-base (`b36179b2bcdaf541242241301f3aa3e170b96363`, on `main`) version of the same file
carries only:
```yaml
on:
  push:
    tags:
      - "mcp-server-v*"
  workflow_dispatch:
```

No `pull_request` trigger is present at the merge-base. The trigger is new to this branch, and the
observed run's `event: pull_request` confirms it is the mechanism that produced the run. **Verdict:
PASS.**

### Clause 4 — "the run's publish-step conclusion is `skipped`"

Command:
```
gh run view 32949401667 --json name,event,headSha,conclusion,status,jobs
```

Observed (relevant excerpt, `Publish to npm` job, step `Publish to npm`, step number 9):
```json
{"completedAt":"2026-08-26T08:46:50Z","conclusion":"skipped","name":"Publish to npm","number":9,
 "startedAt":"2026-08-26T08:46:50Z","status":"completed"}
```

The step literally named `Publish to npm` (distinct from the job of the same name) concluded
`skipped`. The two other tag-guarded steps in the same job (`Verify tag version matches the
mcp-server manifest`, step 8; `Verify the published version resolves on the registry`, step 10) also
concluded `skipped`, consistent with the ref-based guard design (BR-10/BR-11/BR-12) that gates every
tag-dependent step on `refs/tags/mcp-server-v*`, which a pull-request ref (`refs/pull/564/merge`)
never satisfies. **Verdict: PASS.**

### Clause 5 — "The run URL and the step conclusion are recorded under `evidence/qa-gates/`"

`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/green-branch-head-run.2026-08-26T02-05.md`
was updated in this pass to replace its `Run URL:` and `Run Conclusion:` `DEFERRED` literals in
Section 1 with the observed run URL
(`https://github.com/drmoisan/drm-copilot/actions/runs/32949401667`) and the observed conclusion
(`success`, publish step `skipped`). This artifact (`ac18-verification.2026-08-26T09-05.md`) records
the same values independently. **Verdict: PASS.**

## Required-checks cross-check (supporting evidence, not an AC18 clause)

Command:
```
gh pr checks 564 --required
```

Observed: all 11 required checks report `pass` (`build-check`, `docs-validation`,
`drm-copilot-extension-tests` x2, `poshqc`, `quality-checks7` x4, `security-scan`,
`shell-coverage`). No required check is failing or pending.

## Companion workflow (context only — not an AC18 clause)

AC18's text names only `publish-mcp-npm.yml`. The companion workflow
`verify-published-releases.yml` (added by this same change, Layer C) was also re-verified for
completeness of the evidence artifact it shares a deferral record with:

Command:
```
gh run list --workflow=verify-published-releases.yml --event=pull_request --limit 10 --json databaseId,event,headSha,conclusion,status,url
gh run view 32949401794 --json name,event,headSha,conclusion,status,jobs
```

Observed: run `32949401794`, `event: pull_request`, `headSha: c8867713453c25ec749bc412308b5516de402616`
(matches branch head), `conclusion: success`. Step `Reconcile pushed tags against published versions`
concluded `skipped` (gated off the pull-request event, as designed); step `Validate the reconciliation
comparison offline` concluded `success`. This is consistent with the design intent recorded in
`spec.md` `## 3.4`/`## 6.1`-adjacent text but is not itself part of the AC18 gate.

## Overall verdict

All five clauses of AC18 are satisfied by evidence re-derived independently in this pass:

| Clause | Verdict |
|---|---|
| 1. Green run of `publish-mcp-npm.yml` exists | PASS |
| 2. Run is against the branch head | PASS |
| 3. Run produced by the new `pull_request` trigger | PASS |
| 4. Run's publish-step conclusion is `skipped` | PASS |
| 5. Run URL and step conclusion recorded under `evidence/qa-gates/` | PASS |

AC18 is fully satisfied. The checkbox for AC18 has been changed from `- [ ]` to `- [x]` in
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md`. No other line
in `spec.md` was modified.

## Scope note

This verification is narrow by design, per task instructions: only AC18 was evaluated. No other
acceptance criterion was re-audited, re-tested, or modified. AC21 (checked, PARTIAL grade per prior
review) was left untouched.
