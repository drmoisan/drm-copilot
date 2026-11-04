# Runbook: Require Only `CI Required Gate` in Ruleset 15241672 (Issue #1074)

This runbook replaces the 20 individually required status-check contexts of ruleset 15241672 (`protect-main`) with the single context `CI Required Gate`. It is applied manually by the repository owner or the coordinator after the issue #1074 pull request is merged. The implementing run documents it and does not apply it.

Run every command from a working directory outside the repository, so the saved JSON files cannot be committed. PowerShell 7 is required for the `pwsh` blocks; the `jq` blocks are an equivalent for a POSIX shell.

## 1. Preconditions and timing

Apply the change only when both conditions hold:

1. The issue #1074 pull request is merged into `main`.
2. `CI Required Gate` has reported `success` on a `push` run of `ci.yml` on `main` that includes the merge.

Confirm the second condition with these two commands. The first lists the newest `ci.yml` push runs on `main`; take the `headSha` of the newest run whose `conclusion` is `success`. The second reads the gate check run on that commit.

```bash
gh run list --workflow ci.yml --branch main --event push --limit 5 --json databaseId,headSha,conclusion,url
gh api "repos/drmoisan/drm-copilot/commits/<main head sha>/check-runs?check_name=CI%20Required%20Gate"
```

Expected result of the second command: `total_count` at least 1, `check_runs[0].name` `CI Required Gate`, `check_runs[0].conclusion` `success`, and `check_runs[0].app.id` 15368.

Why earlier application blocks every pull request: a required context that no run reports stays pending, and a pending required context blocks the merge. Before the merge, no pull-request head except the issue #1074 branch contains the `ci-required-gate` job, so `CI Required Gate` would never report on those pull requests and every one of them would be blocked. Confirming the context on a `main` push run also proves that the context name and the `integration_id` in section 4 match what GitHub reports.

## 2. Gate context name and current required contexts

Gate context name, verified from a real `ci.yml` run on the issue #1074 branch: `CONTEXT-PENDING-CI-PROOF`. Reporting app (`app.id`, which must equal the `integration_id` in section 4): `CONTEXT-PENDING-CI-PROOF`.

The 20 contexts that ruleset 15241672 requires before the change (read on 2026-11-04 through a read-only `GET`; each has `integration_id` 15368):

1. `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)`
2. `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`
3. `docs-validation / Documentation Validation`
4. `poshqc / PowerShell QC`
5. `shell-coverage / Shell Coverage (Bats + kcov)`
6. `security-scan / Security Scanning`
7. `quality-checks7 / Code Quality & Tests (3.11)`
8. `quality-checks7 / Code Quality & Tests (3.12)`
9. `quality-checks7 / Code Quality & Tests (3.13)`
10. `build-check / Build Package`
11. `NPM Audit Gate / npm audit (extensions/drm-copilot)`
12. `NPM Audit Gate / npm audit (.)`
13. `NPM Audit Gate / npm audit (packages/mcp-server)`
14. `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)`
15. `root-typescript-tests / Root TypeScript Tests (windows-latest)`
16. `poshqc / PowerShell QC shard 1`
17. `poshqc / PowerShell QC shard 2`
18. `poshqc / PowerShell QC shard 3`
19. `poshqc / PowerShell QC static`
20. `poshqc / PowerShell hook suites (Linux)`

The saved backup of section 3 is the exact restore source. This list is a secondary reconstruction source only.

## 3. Read and save the ruleset

Save the current ruleset before any change:

```bash
gh api repos/drmoisan/drm-copilot/rulesets/15241672 > ruleset-15241672.backup.json
```

The backup file `ruleset-15241672.backup.json` is the rollback source. Keep it outside the repository; it is never committed.

Check that the backup contains a `bypass_actors` property. GitHub returns `bypass_actors` only when the token has write access to the ruleset. A backup without it cannot be used to build a `PUT` body, because a body without `bypass_actors` would drop the existing bypass actor; the builders in section 4 refuse such a backup.

## 4. Apply the change (API and web UI)

Required permission: repository Administration: write (a fine-grained token with that permission), or the repository admin role. The Codespace token does not have it.

`PUT /repos/{owner}/{repo}/rulesets/{ruleset_id}` accepts the writable fields `name`, `target`, `enforcement`, `bypass_actors`, `conditions`, and `rules`. The body therefore carries all six, copied from the backup, and changes only the `required_status_checks` parameter of the one `required_status_checks` rule. Read-only `GET` fields (`id`, `source_type`, `source`, `node_id`, `_links`, `current_user_can_bypass`, `created_at`, `updated_at`) are dropped. `name`, `target`, `enforcement`, `conditions`, `bypass_actors`, every other rule (`deletion`, `non_fast_forward`, `pull_request`), and every other parameter (`strict_required_status_checks_policy`, `do_not_enforce_on_create`) are preserved.

Build the body with PowerShell 7. This block makes no network call:

```powershell
# Block B: build the PUT body from the saved ruleset (no network call).
$before = 'ruleset-15241672.backup.json'
$after = 'ruleset-15241672.single-gate.json'

# Builds a PUT body with only the six writable fields; read-only GET fields are dropped.
function New-RulesetPutBody {
    param([hashtable] $Ruleset, [scriptblock] $TransformRule = { param($Rule) $Rule })
    if (-not $Ruleset.ContainsKey('bypass_actors')) { throw 'bypass_actors absent: the token lacks write access to the ruleset' }
    [ordered]@{
        name          = $Ruleset.name
        target        = $Ruleset.target
        enforcement   = $Ruleset.enforcement
        bypass_actors = @($Ruleset.bypass_actors)
        conditions    = $Ruleset.conditions
        rules         = @($Ruleset.rules | ForEach-Object { & $TransformRule $_ })
    }
}

$ruleset = Get-Content -Raw -LiteralPath $before | ConvertFrom-Json -AsHashtable
if (@($ruleset.rules | Where-Object { $_.type -eq 'required_status_checks' }).Count -ne 1) { throw 'expected exactly one required_status_checks rule' }
$body = New-RulesetPutBody -Ruleset $ruleset -TransformRule {
    param($Rule)
    if ($Rule.type -eq 'required_status_checks') {
        $Rule.parameters.required_status_checks = @(@{ context = 'CI Required Gate'; integration_id = 15368 })
    }
    $Rule
}
$body | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $after -Encoding utf8NoBOM
```

The `jq` equivalent writes the same body:

```bash
jq -f build-single-gate.jq ruleset-15241672.backup.json > ruleset-15241672.single-gate.json
```

with `build-single-gate.jq` containing:

```text
if (has("bypass_actors") | not) then error("bypass_actors absent: the token lacks write access to the ruleset")
elif ([.rules[] | select(.type == "required_status_checks")] | length) != 1 then error("expected exactly one required_status_checks rule")
else {name, target, enforcement, bypass_actors, conditions,
      rules: [.rules[] | if .type == "required_status_checks"
                         then .parameters.required_status_checks = [{"context": "CI Required Gate", "integration_id": 15368}]
                         else . end]}
end
```

After the change, the `required_status_checks` rule in the body is:

```json
{
  "type": "required_status_checks",
  "parameters": {
    "strict_required_status_checks_policy": false,
    "do_not_enforce_on_create": false,
    "required_status_checks": [
      { "context": "CI Required Gate", "integration_id": 15368 }
    ]
  }
}
```

Review `ruleset-15241672.single-gate.json`, then send it:

```bash
gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input ruleset-15241672.single-gate.json
```

Web UI path: Settings > Rules > Rulesets > `protect-main` > Require status checks to pass (required status checks). Remove the 20 listed checks, add `CI Required Gate` with the source GitHub Actions, keep every other setting, and save.

## 5. Verification

Read the ruleset again and confirm one context, the same strict flag, the same rule types, the same bypass actors, and the same conditions:

```bash
gh api repos/drmoisan/drm-copilot/rulesets/15241672
```

Then verify the behavior with two pull requests into `main`:

1. A throwaway docs-only pull request that changes one Markdown file under `docs/features/active/`. Expected: `Change scope` reports `code=false`; `CI Required Gate` is `success`; `gh pr view <number> --json mergeStateStatus` is not `BLOCKED` (the pull request is mergeable); the individual job checks are still listed in the checks view, including the skipped ones. Close the pull request without merging.
2. A code pull request in which one needed job fails, for example a throwaway step `run: exit 1` in a job of `_docs-validation.yml`. Expected: the failing job reports `failure`, `CI Required Gate` is `failure`, its summary row for that job shows `failure`, and the pull request is blocked. Close the pull request without merging.

## 6. Rollback

Restore the saved ruleset unchanged. Build the rollback body from the backup with the same builder (the read-only fields are dropped), then send it. Run Block B first in the same PowerShell session so `New-RulesetPutBody` and `$before` are defined:

```powershell
# Block C: build the rollback body from the saved ruleset (no network call).
$rollback = 'ruleset-15241672.rollback.json'
$saved = Get-Content -Raw -LiteralPath $before | ConvertFrom-Json -AsHashtable
New-RulesetPutBody -Ruleset $saved | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $rollback -Encoding utf8NoBOM
```

```bash
gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input ruleset-15241672.rollback.json
```

The `jq` equivalent of the rollback body:

```bash
jq -f build-rollback.jq ruleset-15241672.backup.json > ruleset-15241672.rollback.json
```

with `build-rollback.jq` containing:

```text
if (has("bypass_actors") | not) then error("bypass_actors absent: the token lacks write access to the ruleset")
else {name, target, enforcement, bypass_actors, conditions, rules}
end
```

Web UI equivalent: Settings > Rules > Rulesets > `protect-main` > Require status checks to pass; remove `CI Required Gate`, add back the 20 contexts listed in section 2 with the source GitHub Actions, and save.

Order: restore the ruleset before removing the `ci-required-gate` job from `ci.yml`. Removing the job first leaves the required context unreported, and every pull request then waits on it.

## 7. What does not change

- Every `ci.yml` job keeps its id, name, `needs:`, `if:`, inputs, and behavior, and every reusable workflow is unchanged. The individual job checks still run and stay visible on every pull request; only their required status changes.
- The docs-only change-scope decision (`scripts/ci/Invoke-CiChangeScope.ps1`) and its allowlist are unchanged.
- The other rules of ruleset 15241672 (`deletion`, `non_fast_forward`, `pull_request`), its conditions, and its bypass actor are unchanged.
- Pull requests into `epic/**` integration branches are not covered by ruleset 15241672, which targets the default branch only; their checks are not required before or after this change.
