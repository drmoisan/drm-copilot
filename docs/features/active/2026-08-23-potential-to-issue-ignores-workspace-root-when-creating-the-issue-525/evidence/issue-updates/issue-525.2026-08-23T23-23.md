# Issue Update Mirror — issue #525

Timestamp: 2026-08-25T10-14
Task: [P5-T3]
Target document: docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/issue.md
Section: `## Proposed Fix / Validation Ideas`
PostedAs: unknown
Posting note: The text below was written into the local feature issue document only. It was not posted to the GitHub issue body and not posted as a GitHub comment. [P5-T3] scopes the update to the local `issue.md` document and this mirror; no task in this plan authorizes a GitHub write, and the promotion-gate hook keeps GitHub writes off the agent command surface.
Issue URL: https://github.com/drmoisan/drm-copilot/issues/525

## Exact text written into the issue document

### Delivered fix (recorded 2026-08-25)

The fix closes both omissions on the one call path. Neither omission alone was addressed, because either one alone leaves the defect reachable.

- **Slug resolution from `workspace_root`.** A new module `extensions/drm-copilot/src/lib/potential-to-issue/repo-slug.ts` exports `resolveRepoSlug` and `REPO_SLUG_UNRESOLVED_PREFIX`. It runs the GitHub CLI repository-view operation for the `nameWithOwner` field through the already-injected command runner, with the runner's working directory set to the resolved `workspace_root`. The reporter's hypothesis of parsing the `origin` remote URL was rejected: no git-remote URL parser exists anywhere in the repository, and building one would reproduce what one already-proven CLI call returns. No leg of the resolver reads a remote URL.
- **Explicit repository selector.** `RealGhClient` gained an optional `repo` constructor option. When present, the selector flag and its value are inserted into the issue-creation, label-create recovery, and issue-view argument vectors, including the re-created issue on the missing-label recovery leg. When absent, all three vectors remain byte-identical to their pre-change form, so the existing default construction in the promotion workflow module is unaffected.
- **Threading past the propagation break.** `potential-to-issue-service-call.ts` resolves the slug from the resolved workspace root unconditionally, before the GitHub client is constructed, and passes it in as the `repo` option.
- **Echoed target repository.** The resolved slug is exposed as `targetRepository` on the TypeScript execution-result contract and as `target_repository` on the MCP surface, optional at every stage, so results returned by other tools are unchanged and the field is simply absent for them.
- **Fail closed.** An unresolvable slug throws an error naming the `workspace_root` that could not be resolved, before any GitHub write and before the filesystem move, so no issue is created and the potential record stays in place. There is no implicit-resolution fallback; a silent fallback would reintroduce the defect.
- **Corrected parity claim.** The TypeScript GitHub client docstring no longer claims its argument vectors are byte-identical to the Python sibling, and now states that the repository selector is a deliberate TypeScript-only divergence. `scripts/dev_tools/potential_to_issue.py` is out of the write set on a structural ground: the Python CLI exposes no workspace parameter at all, so the "one parameter, two effects, one honoured" divergence cannot be exhibited there.

**Recorded `scope_change` disposition on the integration retest.** The second checkbox above required promoting a throwaway record against a second real repository and deleting the resulting issue afterwards. That criterion cannot complete unattended: it creates a real GitHub issue in a second repository, which the promotion-gate hook exists specifically to keep off the agent command surface, and GitHub issues cannot be deleted through the CLI — deletion is an administrative web-UI action — so the cleanup step has no automated form and would leave residue in a real repository.

The orchestrator recorded the disposition `scope_change`. The live integration retest is replaced by hermetic argument-boundary assertions against an injected fake GitHub CLI, which assert the exact argument vector handed to the CLI rather than inferring the target repository from a returned URL. This is a stronger assertion, not a weaker substitute: the live test could only observe the target repository indirectly through the issue URL in the result, while the hermetic form observes the selector at the exact point of the defect and additionally reaches the enumerated unresolvable branches on demand, which a live run could not. `exception` was inappropriate because no runbook is needed — there is a fully equivalent automated path, not a gap to be supervised. `halt` was inappropriate because nothing about the fix is blocked; one verification technique is substituted. **A later reviewer must not read the removal of the live-integration criterion as a dropped requirement.**

The third checkbox is retained in full: the same-repository promotion is verified in the same test pass and its summary text, `destination_path`, and `artifacts` values are unchanged.
