Set-StrictMode -Version Latest

# Unit suite for the opt-in branch-protection command scripts/ci/Set-CiRequiredChecks.ps1 (issue #1050).
#
# The script is dot-sourced, so its dot-source guard skips the command call and only the functions are
# defined in the test scope; dot-sourcing the file (rather than rebuilding the functions from its AST) keeps
# the functions attributed to the file, so Pester code coverage measures them. The script's shape is checked
# through its AST. The gh wrapper Invoke-GhExe and the data seam Get-CiRequiredChecksDataText are mocked with
# the production parameter names, so no gh process starts and no file is written.

BeforeAll {
    $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/Set-CiRequiredChecks.ps1'
    if (-not (Test-Path -LiteralPath $script:ScriptPath)) {
        throw "The script under test does not exist: $script:ScriptPath"
    }
    . $script:ScriptPath

    $script:ValidData = '{"required_contexts":["CI Required Gate"],"schema_version":"1.0.0","workflow":"CI","workflow_file":".github/workflows/drm-copilot-ci.yml"}'
}

Describe 'Set-CiRequiredChecks.ps1 script shape' {
    It 'declares SupportsShouldProcess and runs exactly one guarded call outside functions' {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:ScriptPath, [ref] $tokens, [ref] $parseErrors)

        $statements = @($ast.EndBlock.Statements | Where-Object { $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] })
        $binding = @($ast.ParamBlock.Attributes | Where-Object { $_.TypeName.Name -eq 'CmdletBinding' })
        $calls = @($statements | ForEach-Object { $_.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) } |
                ForEach-Object { $_.GetCommandName() })

        @($parseErrors).Count | Should -Be 0
        $statements.Count | Should -Be 1 -Because 'the script body outside functions is one statement'
        $statements[0] | Should -BeOfType ([System.Management.Automation.Language.IfStatementAst])
        $calls | Should -Be @('Invoke-SetCiRequiredChecks')
        $binding[0].Extent.Text | Should -Match 'SupportsShouldProcess'
    }
}

Describe 'Set-CiRequiredChecks.ps1 direct run' {
    It 'fails before any gh call when no data file lies beside the script' {
        # scripts/ci holds no ci-required-checks.json, so the default -DataFilePath does not exist and the
        # command stops at the data read; Invoke-GhExe is never reached, so no process starts.
        { & $script:ScriptPath } | Should -Throw '*CI data file not found*'
    }
}

Describe 'Invoke-GhExe' {
    BeforeAll {
        # Test double passed through -GhCommand: echoes its arguments and any piped request body.
        function Invoke-TestGhDouble {
            [CmdletBinding(PositionalBinding = $false)]
            [OutputType([string])]
            param(
                [Parameter(ValueFromPipeline = $true)] [string] $Body,
                [Parameter(ValueFromRemainingArguments = $true)] [string[]] $Rest
            )
            process {
                if ($Body) { "body:$Body" }
            }
            end {
                "args:$($Rest -join ' ')"
            }
        }
    }

    It 'runs the command with the arguments and joins its output' {
        $result = Invoke-GhExe -GhArgs @('api', 'repos/o/r/rulesets') -GhCommand 'Invoke-TestGhDouble'

        $result.Output | Should -Be 'args:api repos/o/r/rulesets'
        $result.PSObject.Properties.Name | Should -Contain 'ExitCode'
    }

    It 'pipes the request body to the command when InputText is given' {
        $result = Invoke-GhExe -GhArgs @('api', 'repos/o/r/rulesets') -InputText '{"a":1}' -GhCommand 'Invoke-TestGhDouble'

        $result.Output | Should -Be "body:{`"a`":1}`nargs:api repos/o/r/rulesets"
    }

    It 'returns standard output only when the command writes a warning to standard error' {
        # A native command's standard error arrives through 2>&1 as error records; this double writes one.
        function Invoke-TestGhWarningDouble {
            [CmdletBinding(PositionalBinding = $false)]
            [OutputType([string])]
            param([Parameter(ValueFromRemainingArguments = $true)] [string[]] $Rest)
            $null = $Rest
            # Native standard error never terminates, so the record is written non-terminating under any preference.
            Write-Error -Message 'warning: rate limit is low' -ErrorAction Continue
            '[{"id":1}]'
        }

        $result = Invoke-GhExe -GhArgs @('api', 'repos/o/r/rulesets') -GhCommand 'Invoke-TestGhWarningDouble'

        @($result.Output | ConvertFrom-Json)[0].id | Should -Be 1
        $result.ErrorOutput | Should -Be 'warning: rate limit is low'
    }
}

Describe 'New-CiRequiredChecksRulesetBody' {
    It 'targets the default branch and requires the context read from the data text' {
        $body = New-CiRequiredChecksRulesetBody -DataText $script:ValidData -RulesetName 'gate' | ConvertFrom-Json

        $body.name | Should -Be 'gate'
        $body.target | Should -Be 'branch'
        $body.enforcement | Should -Be 'active'
        @($body.conditions.ref_name.include) | Should -Be @('~DEFAULT_BRANCH')
        $body.rules[0].type | Should -Be 'required_status_checks'
        @($body.rules[0].parameters.required_status_checks.context) | Should -Be @('CI Required Gate')
    }

    It 'uses every context the data text names' {
        $data = '{"required_contexts":["Gate A","Gate B"]}'

        $body = New-CiRequiredChecksRulesetBody -DataText $data -RulesetName 'gate' | ConvertFrom-Json

        @($body.rules[0].parameters.required_status_checks.context) | Should -Be @('Gate A', 'Gate B')
    }

    It 'throws for malformed data text <Label>' -ForEach @(
        @{ Label = 'that is not JSON'; Text = '{' }
        @{ Label = 'that is empty'; Text = '' }
        @{ Label = 'that is a JSON array'; Text = '[1]' }
        @{ Label = 'without required_contexts'; Text = '{"workflow":"CI"}' }
        @{ Label = 'with an empty required_contexts'; Text = '{"required_contexts":[]}' }
        @{ Label = 'with a blank context'; Text = '{"required_contexts":[" "]}' }
        @{ Label = 'with a non-string context'; Text = '{"required_contexts":[5]}' }
    ) {
        { New-CiRequiredChecksRulesetBody -DataText $Text -RulesetName 'gate' } | Should -Throw '*malformed*'
    }
}

Describe 'Get-CiRequiredChecksDataText' {
    It 'throws when the data file does not exist' {
        $missing = Join-Path -Path $PSScriptRoot -ChildPath 'no-such-ci-required-checks.json'

        { Get-CiRequiredChecksDataText -Path $missing } | Should -Throw '*not found*'
    }

    It 'returns the text of an existing file' {
        $text = Get-CiRequiredChecksDataText -Path $script:ScriptPath

        $text | Should -Match 'Invoke-SetCiRequiredChecks'
    }
}

Describe 'Invoke-SetCiRequiredChecks' {
    BeforeEach {
        # The list call runs with --paginate --slurp, so gh prints one JSON array whose elements are the pages.
        $script:ExistingRulesets = '[[]]'
        $script:CreateExitCode = 0
        $script:ListExitCode = 0
        $script:ListErrorOutput = ''
        $script:ViewResult = [pscustomobject]@{ ExitCode = 0; Output = "owner/repo`n"; ErrorOutput = '' }
        Mock Get-CiRequiredChecksDataText { param([string] $Path) $null = $Path; $script:ValidData }
        Mock Invoke-GhExe {
            param([string[]] $GhArgs, [string] $InputText)
            $null = $InputText
            if ($GhArgs[0] -eq 'repo') { return $script:ViewResult }
            if ($GhArgs -contains 'POST') { return [pscustomobject]@{ ExitCode = $script:CreateExitCode; Output = '{"id":42}'; ErrorOutput = '' } }
            return [pscustomobject]@{ ExitCode = $script:ListExitCode; Output = $script:ExistingRulesets; ErrorOutput = $script:ListErrorOutput }
        }
    }

    It 'prints the body and issues no gh call by default' {
        $output = @(Invoke-SetCiRequiredChecks -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo')

        ($output -join "`n") | Should -Match '~DEFAULT_BRANCH'
        ($output -join "`n") | Should -Match 'Dry run'
        Should -Invoke Invoke-GhExe -Times 0 -Exactly
    }

    It 'issues no write under -WhatIf' {
        $null = Invoke-SetCiRequiredChecks -Apply -WhatIf -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo'

        Should -Invoke Invoke-GhExe -Times 0 -Exactly -ParameterFilter { $GhArgs -contains 'POST' }
    }

    It 'issues one POST that targets the default branch and requires CI Required Gate under -Apply' {
        $output = @(Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo')

        Should -Invoke Invoke-GhExe -Times 1 -Exactly -ParameterFilter {
            ($GhArgs -join ' ') -eq 'api --method POST repos/owner/repo/rulesets --input -' -and
            ($InputText | ConvertFrom-Json).conditions.ref_name.include -contains '~DEFAULT_BRANCH' -and
            ($InputText | ConvertFrom-Json).rules[0].parameters.required_status_checks[0].context -eq 'CI Required Gate'
        }
        ($output -join "`n") | Should -Match 'Created ruleset'
    }

    It 'resolves the repository through gh repo view when none is given' {
        $null = Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json'

        Should -Invoke Invoke-GhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[0] -eq 'repo' }
        Should -Invoke Invoke-GhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -eq 'api --method POST repos/owner/repo/rulesets --input -' }
    }

    It 'reports an existing ruleset of the same name and issues no write' {
        $script:ExistingRulesets = '[[{"id":7,"name":"drm-copilot CI Required Gate"}]]'

        $output = @(Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo')

        ($output -join "`n") | Should -Match 'already exists'
        Should -Invoke Invoke-GhExe -Times 0 -Exactly -ParameterFilter { $GhArgs -contains 'POST' }
    }

    It 'issues no PUT, PATCH or DELETE in any case' {
        $null = Invoke-SetCiRequiredChecks -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo'
        $null = Invoke-SetCiRequiredChecks -Apply -WhatIf -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo'
        $null = Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo'
        $script:ExistingRulesets = '[[{"id":7,"name":"drm-copilot CI Required Gate"}]]'
        $null = Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo'

        Should -Invoke Invoke-GhExe -Times 0 -Exactly -ParameterFilter { @($GhArgs | Where-Object { $_ -in @('PUT', 'PATCH', 'DELETE') }).Count -gt 0 }
    }

    It 'lists the rulesets with --paginate and --slurp' {
        $null = Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo'

        Should -Invoke Invoke-GhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -eq 'api repos/owner/repo/rulesets --paginate --slurp' }
    }

    It 'finds a same-name ruleset on the second page and issues no write' {
        # Without --paginate gh returns the first page only; with --paginate --slurp it returns every page.
        Mock Invoke-GhExe {
            param([string[]] $GhArgs, [string] $InputText)
            $null = $InputText
            if ($GhArgs -contains 'POST') { return [pscustomobject]@{ ExitCode = 0; Output = '{"id":42}'; ErrorOutput = '' } }
            if ($GhArgs -contains '--paginate' -and $GhArgs -contains '--slurp') {
                return [pscustomobject]@{ ExitCode = 0; Output = '[[{"id":1,"name":"other"}],[{"id":9,"name":"drm-copilot CI Required Gate"}]]'; ErrorOutput = '' }
            }
            return [pscustomobject]@{ ExitCode = 0; Output = '[{"id":1,"name":"other"}]'; ErrorOutput = '' }
        }

        $output = @(Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo')

        ($output -join "`n") | Should -Match 'already exists in owner/repo \(id 9\)'
        Should -Invoke Invoke-GhExe -Times 0 -Exactly -ParameterFilter { $GhArgs -contains 'POST' }
    }

    It 'throws when the repository cannot be resolved' {
        $script:ViewResult = [pscustomobject]@{ ExitCode = 1; Output = 'not a repo' }

        { Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' } | Should -Throw '*Could not resolve*'
    }

    It 'throws when the rulesets cannot be listed' {
        $script:ListExitCode = 1

        { Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo' } | Should -Throw '*Could not list*'
    }

    It 'names the gh call and its error output when listing fails' {
        $script:ListExitCode = 1
        $script:ListErrorOutput = 'HTTP 404: Not Found'

        { Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo' } |
            Should -Throw '*api repos/owner/repo/rulesets*HTTP 404: Not Found*'
    }

    It 'names the gh call when the ruleset list is not JSON' {
        $script:ExistingRulesets = 'not json'

        { Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo' } |
            Should -Throw '*gh api repos/owner/repo/rulesets*not JSON*'
        Should -Invoke Invoke-GhExe -Times 0 -Exactly -ParameterFilter { $GhArgs -contains 'POST' }
    }

    It 'throws when the POST fails' {
        $script:CreateExitCode = 1

        { Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo' } | Should -Throw '*Creating the ruleset failed*'
    }

    It 'throws for malformed data text before any gh call' {
        Mock Get-CiRequiredChecksDataText { param([string] $Path) $null = $Path; '{"workflow":"CI"}' }

        { Invoke-SetCiRequiredChecks -Apply -DataFilePath 'ci-required-checks.json' -Repository 'owner/repo' } | Should -Throw '*malformed*'
        Should -Invoke Invoke-GhExe -Times 0 -Exactly
    }
}
