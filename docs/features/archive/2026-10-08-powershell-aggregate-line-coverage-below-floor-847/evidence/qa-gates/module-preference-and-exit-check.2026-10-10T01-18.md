# Module Preference and Exit Check (Issue #847, AC-09)

Timestamp: 2026-10-10T01-18
Task: [P7-T9]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "P7-T9 AST check"), the `Parser::ParseFile` AST check is replaced by line-anchored `git grep` for `^Set-StrictMode -Version Latest`, `^$ErrorActionPreference = 'Stop'`, `exit` statements, and `Import-Module` / `-Force` in the entry scripts. Acceptance values (`strict=1 eap=1 exit=0` per module; `imports=1 forced=0` per entry) are unchanged.
Command:
1. `git grep -c -E -e '^Set-StrictMode -Version Latest\s*$' -- <five modules>`
2. `git grep -c -E -e "^[$]ErrorActionPreference = 'Stop'[[:space:]]*$" -- <five modules>`. A first attempt using `^\\\$...` inside double quotes matched nothing because of shell escaping; the raw lines were confirmed with `git grep -n -F -e 'ErrorActionPreference'` and the count was rerun with the bracket form.
3. `git grep -n -i -E -e '^[[:space:]]*exit([[:space:]]|$|;)' -e '[;{}][[:space:]]*exit([[:space:]]|$|;)' -- <five modules>; echo "EXIT_CODE=$?"` (exit in statement position), plus the broader `git grep -n -i -E -e '(^|[^-A-Za-z0-9_$])exit([[:space:]]|$|;)'` for review.
4. `git grep -n -i -e 'Import-Module' -- <three entry scripts>` and `git grep -n -i -e '-Force' -- <three entry scripts>`.
EXIT_CODE: 0
Output Summary:
- scripts/dev-tools/HostTooling.psm1 strict=1 eap=1 exit=0
- scripts/dev-tools/HostBootstrapWorkspace.psm1 strict=1 eap=1 exit=0
- scripts/dev-tools/HostBootstrap.psm1 strict=1 eap=1 exit=0
- scripts/dev-tools/HostVerification.psm1 strict=1 eap=1 exit=0
- scripts/dev-tools/SideloadedExtensionPublish.psm1 strict=1 eap=1 exit=0
- scripts/dev-tools/bootstrap-host.ps1 imports=1 forced=0 (line 23: `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostBootstrap.psm1')`)
- scripts/dev-tools/verify-host.ps1 imports=1 forced=0 (line 8: `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HostVerification.psm1')`)
- scripts/dev-tools/publish-sideloaded-extension.ps1 imports=1 forced=0 (line 56: `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'SideloadedExtensionPublish.psm1')`)
- Result: PASS (AC-09).

## Details

- Exit check: the statement-position search printed no lines (`EXIT_CODE=1`). The broader search matched only string literals and one help comment, none of which is an `exit` statement: `HostBootstrap.psm1:9` (comment: "contains no exit statement"), `HostBootstrap.psm1:147`, `HostBootstrapWorkspace.psm1:33`, `:205`, `:238`, `:272`, `:286` (`throw "... failed with exit code ..."`), and `SideloadedExtensionPublish.psm1:177` (format string `'Command failed with exit code {0}: ...'`).
- StrictMode lines: `HostTooling.psm1`, `HostBootstrap.psm1`, and `HostVerification.psm1` at line 12 and `HostBootstrapWorkspace.psm1` and `SideloadedExtensionPublish.psm1` at line 14 are each followed by the EAP line (13 or 15). Both lines start at column 0, at module scope.
- `-Force` search over the entries: one match, `publish-sideloaded-extension.ps1:13` (`- (Optional) code --install-extension <vsix> --force`, in the comment-based help block at lines 1-21). It is not an `Import-Module` argument, so forced=0 for all three entries.
