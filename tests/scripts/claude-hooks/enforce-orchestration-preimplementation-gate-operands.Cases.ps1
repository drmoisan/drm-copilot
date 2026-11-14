<#
    Shared case tables for the command-operand resolution suites of issue #1188. Data only:
    this file holds hashtable and array literals and no command. It is dot-sourced at
    discovery by tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1
    and by tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1.

    OperandGRows drive Get-OrchestrationGateCommandTargetOperand alone: Command is the input,
    Paths the expected Paths in order, and Unresolved the expected flag (Paths is empty whenever
    Unresolved is true). Drive-letter rows are pure string inputs and touch no file system.

    OperandGateRows drive the gate's single-feature command leg. ItemBody and SessionBody name
    the checkpoint bodies (Ready, Unready, Absent) of /synthetic-worktrees/w-item and of the
    session root; ListingMode selects the in-memory worktree listing (Normal, Throws, Empty).
    ItemReads, SessionReads, and ListingCalls are exact call counts (ListingCalls -1 leaves the
    listing count unasserted, for the R3 control whose listing call starts with the fix); DetailPattern, when not
    empty, must match the deny reason.
#>

$script:OperandGRows = @(
    # AC-1: poetry directory selectors.
    @{ Name = 'AC-1 env -u prefix, poetry -C selector, and an absolute test path'; Command = 'env -u VIRTUAL_ENV poetry -C /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; Paths = @('/synthetic-worktrees/w-item', '/synthetic-worktrees/w-item/tests/x.py'); Unresolved = $false }
    @{ Name = 'AC-1 poetry --directory with a separate value'; Command = 'poetry --directory /synthetic-worktrees/w-item run pytest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'AC-1 poetry --directory with an inline value'; Command = 'poetry --directory=/synthetic-worktrees/w-item run pytest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'AC-1 poetry -P project selector'; Command = 'poetry -P /synthetic-worktrees/w-item run pytest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'poetry --project with an inline value'; Command = 'poetry --project=/synthetic-worktrees/w-item run pytest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'poetry attached -C value'; Command = 'poetry -C/synthetic-worktrees/w-item run pytest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'poetry attached -P value'; Command = 'poetry -P/synthetic-worktrees/w-item run pytest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'poetry standalone global options before the selector'; Command = 'poetry -q --no-interaction -vvv --no-ansi --no-cache -C /synthetic-worktrees/w-item run pytest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'poetry relative selector adds no path'; Command = 'poetry -C sub run pytest'; Paths = @(); Unresolved = $false }
    # Governed-word rows (decision rule 2): each family word harvests its record.
    @{ Name = 'governed word black'; Command = 'poetry -C /synthetic-worktrees/w-item run black'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'governed word ruff'; Command = 'poetry -C /synthetic-worktrees/w-item run ruff'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'governed word pyright'; Command = 'poetry -C /synthetic-worktrees/w-item run pyright'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'governed word prettier'; Command = 'npx --prefix /synthetic-worktrees/w-item prettier'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'governed word typecheck'; Command = 'npm --prefix /synthetic-worktrees/w-item run typecheck'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'governed word eslint'; Command = 'npx --prefix /synthetic-worktrees/w-item eslint'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'governed word tsc'; Command = 'npx --prefix /synthetic-worktrees/w-item tsc'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    # AC-2: npm and npx selectors.
    @{ Name = 'AC-2 npm --prefix selector'; Command = 'npm --prefix /synthetic-worktrees/w-item run test:unit'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'AC-2 npm -C selector'; Command = 'npm -C /synthetic-worktrees/w-item run lint'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'AC-2 npx --prefix selector'; Command = 'npx --prefix /synthetic-worktrees/w-item jest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'npm inline --prefix value after the script name'; Command = 'npm run test:unit --prefix=/synthetic-worktrees/w-item'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'npx -C selector'; Command = 'npx -C /synthetic-worktrees/w-item jest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    # AC-3: shell script operands.
    @{ Name = 'AC-3 sh launcher script operand'; Command = 'sh /synthetic-worktrees/w-item/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest'; Paths = @('/synthetic-worktrees/w-item/.claude/skills/test-execution-policy/scripts/run-test-suite.sh'); Unresolved = $false }
    @{ Name = 'AC-3 env -u prefix before the sh launcher'; Command = 'env -u VIRTUAL_ENV sh /synthetic-worktrees/w-item/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest'; Paths = @('/synthetic-worktrees/w-item/.claude/skills/test-execution-policy/scripts/run-test-suite.sh'); Unresolved = $false }
    @{ Name = 'bash script operand after an -o value'; Command = 'bash -o pipefail /synthetic-worktrees/w-item/run.sh pytest'; Paths = @('/synthetic-worktrees/w-item/run.sh'); Unresolved = $false }
    @{ Name = 'zsh script operand'; Command = 'zsh /synthetic-worktrees/w-item/run.zsh pytest'; Paths = @('/synthetic-worktrees/w-item/run.zsh'); Unresolved = $false }
    @{ Name = 'dash script operand'; Command = 'dash /synthetic-worktrees/w-item/run.dash pytest'; Paths = @('/synthetic-worktrees/w-item/run.dash'); Unresolved = $false }
    @{ Name = 'ksh script operand'; Command = 'ksh /synthetic-worktrees/w-item/run.ksh pytest'; Paths = @('/synthetic-worktrees/w-item/run.ksh'); Unresolved = $false }
    @{ Name = 'sh relative script operand adds no path'; Command = 'sh scripts/run.sh pytest'; Paths = @(); Unresolved = $false }
    @{ Name = 'bash -c cluster yields the payload operand only'; Command = 'bash -lc "pytest /synthetic-worktrees/w-item/tests"'; Paths = @('/synthetic-worktrees/w-item/tests'); Unresolved = $false }
    # AC-4: PowerShell hosts.
    @{ Name = 'AC-4 pwsh -File script operand'; Command = 'pwsh -NoProfile -File /synthetic-worktrees/w-item/tests/scripts/X.Tests.ps1'; Paths = @('/synthetic-worktrees/w-item/tests/scripts/X.Tests.ps1'); Unresolved = $false }
    @{ Name = 'AC-4 pwsh -WorkingDirectory selector with a -Command payload'; Command = 'pwsh -WorkingDirectory /synthetic-worktrees/w-item -Command "Invoke-Pester -Path tests/scripts"'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'pwsh -wd selector'; Command = 'pwsh -wd /synthetic-worktrees/w-item -c "Invoke-Pester"'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'pwsh -f script operand'; Command = 'pwsh -f /synthetic-worktrees/w-item/tests/scripts/Y.Tests.ps1'; Paths = @('/synthetic-worktrees/w-item/tests/scripts/Y.Tests.ps1'); Unresolved = $false }
    @{ Name = 'powershell -ExecutionPolicy value is not an operand'; Command = 'powershell -ExecutionPolicy Bypass -File /synthetic-worktrees/w-item/tests/scripts/Z.Tests.ps1'; Paths = @('/synthetic-worktrees/w-item/tests/scripts/Z.Tests.ps1'); Unresolved = $false }
    @{ Name = 'pwsh -Command payload absolute operand'; Command = 'pwsh -Command "Invoke-Pester -Path /synthetic-worktrees/w-item/tests/scripts"'; Paths = @('/synthetic-worktrees/w-item/tests/scripts'); Unresolved = $false }
    # AC-5: bare runner operands, including drive-letter strings.
    @{ Name = 'AC-5 bare runner absolute operand'; Command = 'pytest /synthetic-worktrees/w-item/tests/x.py'; Paths = @('/synthetic-worktrees/w-item/tests/x.py'); Unresolved = $false }
    @{ Name = 'drive-letter forward-slash operand'; Command = 'pytest C:/synthetic-worktrees/w-item/tests/x.py'; Paths = @('C:/synthetic-worktrees/w-item/tests/x.py'); Unresolved = $false }
    @{ Name = 'drive-letter backslash selector'; Command = 'npm --prefix C:\synthetic-worktrees\w-item run lint'; Paths = @('C:\synthetic-worktrees\w-item'); Unresolved = $false }
    # AC-6: shell-variable and substitution operands.
    @{ Name = 'V1 git -C shell variable'; Command = 'git -C $W add x'; Paths = @(); Unresolved = $true }
    @{ Name = 'V2 poetry -C braced variable'; Command = 'poetry -C ${W} run pytest'; Paths = @(); Unresolved = $true }
    @{ Name = 'V3 npm --prefix command substitution'; Command = 'npm --prefix $(pwd) run lint'; Paths = @(); Unresolved = $true }
    @{ Name = 'V3 npm --prefix quoted command substitution'; Command = 'npm --prefix "$(pwd)" run lint'; Paths = @(); Unresolved = $true }
    @{ Name = 'V4 sh script operand shell variable'; Command = 'sh $W/run-test-suite.sh pytest'; Paths = @(); Unresolved = $true }
    @{ Name = 'V5 runner operand shell variable'; Command = 'pytest $W/tests'; Paths = @(); Unresolved = $true }
    @{ Name = 'poetry --directory inline shell variable'; Command = 'poetry --directory=$W run pytest'; Paths = @(); Unresolved = $true }
    @{ Name = 'npm --prefix shell variable'; Command = 'npm --prefix $W run test:unit'; Paths = @(); Unresolved = $true }
    @{ Name = 'env -C shell variable'; Command = 'env -C $W pytest'; Paths = @(); Unresolved = $true }
    @{ Name = 'pwsh -wd shell variable'; Command = 'pwsh -wd $W -c "Invoke-Pester"'; Paths = @(); Unresolved = $true }
    @{ Name = 'pwsh -File shell variable'; Command = 'pwsh -File $W/tests/scripts/X.Tests.ps1'; Paths = @(); Unresolved = $true }
    @{ Name = 'runner operand braced substitution'; Command = 'pytest ${W}/tests'; Paths = @(); Unresolved = $true }
    @{ Name = 'runner operand command substitution'; Command = 'pytest $(pwd)/tests'; Paths = @(); Unresolved = $true }
    @{ Name = 'runner operand backtick substitution'; Command = 'pytest `pwd`/tests'; Paths = @(); Unresolved = $true }
    @{ Name = 'git -C shell variable on a non-staging segment'; Command = 'git -C $W status && pytest tests'; Paths = @(); Unresolved = $true }
    @{ Name = 'shell variable without a separator is not path-like'; Command = 'pytest $TESTS'; Paths = @(); Unresolved = $false }
    # AC-7 and AC-8: every absolute path is returned; the resolver decides ambiguity and outside paths.
    @{ Name = 'M1 operands in two registered worktrees'; Command = 'poetry -C /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-other/tests'; Paths = @('/synthetic-worktrees/w-item', '/synthetic-worktrees/w-other/tests'); Unresolved = $false }
    @{ Name = 'M2 registered worktree plus an outside path'; Command = 'pytest /synthetic-worktrees/w-item/tests /synthetic-elsewhere/x.py'; Paths = @('/synthetic-worktrees/w-item/tests', '/synthetic-elsewhere/x.py'); Unresolved = $false }
    @{ Name = 'R1 relative npm --prefix'; Command = 'npm --prefix extensions/drm-copilot run test:unit'; Paths = @(); Unresolved = $false }
    @{ Name = 'R2 relative runner operand'; Command = 'poetry run pytest tests/x.py'; Paths = @(); Unresolved = $false }
    @{ Name = 'R3 lone outside absolute path'; Command = 'pytest /synthetic-elsewhere/tests/x.py'; Paths = @('/synthetic-elsewhere/tests/x.py'); Unresolved = $false }
    # AC-10: malformed records and unresolvable selectors.
    @{ Name = 'malformed Unbalanced record'; Command = 'pytest "/synthetic-worktrees/w-item/tests/x.py'; Paths = @(); Unresolved = $true }
    @{ Name = 'malformed DecodeFailure record'; Command = 'pwsh -EncodedCommand AAA pytest'; Paths = @(); Unresolved = $true }
    @{ Name = 'malformed DepthLimit record'; Command = 'xargs xargs xargs xargs xargs pytest'; Paths = @(); Unresolved = $true }
    @{ Name = 'npm selector with no value at the end of the command'; Command = 'npm run test:unit --prefix'; Paths = @(); Unresolved = $true }
    @{ Name = 'poetry selector whose value is a substitution'; Command = 'poetry -C $(pwd) run pytest'; Paths = @(); Unresolved = $true }
    @{ Name = 'git -C with no value'; Command = 'pytest tests && git -C'; Paths = @(); Unresolved = $true }
    @{ Name = 'env -S split string'; Command = 'env -S "poetry run pytest"'; Paths = @(); Unresolved = $true }
    @{ Name = 'env --split-string with an inline value'; Command = 'env --split-string=pytest'; Paths = @(); Unresolved = $true }
    @{ Name = 'unmodelled poetry option before the selector'; Command = 'poetry --frobnicate -C /synthetic-worktrees/w-item run pytest'; Paths = @(); Unresolved = $true }
    @{ Name = 'U5 unmodelled env prefix option'; Command = 'env --frobnicate pytest /synthetic-worktrees/w-item/tests/x.py'; Paths = @(); Unresolved = $true }
    @{ Name = 'unmodelled timeout prefix option'; Command = 'timeout --frobnicate 30 pytest'; Paths = @(); Unresolved = $true }
    # Prefix walk.
    @{ Name = 'env -C selector'; Command = 'env -C /synthetic-worktrees/w-item pytest tests/x.py'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'env --chdir with an inline value'; Command = 'env --chdir=/synthetic-worktrees/w-item pytest'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'env standalone options and an assignment'; Command = 'env -i FOO=1 --ignore-environment pytest /synthetic-worktrees/w-item/t'; Paths = @('/synthetic-worktrees/w-item/t'); Unresolved = $false }
    @{ Name = 'env --unset with an inline value'; Command = 'env --unset=VIRTUAL_ENV pytest /synthetic-worktrees/w-item/t'; Paths = @('/synthetic-worktrees/w-item/t'); Unresolved = $false }
    @{ Name = 'env attached -u value'; Command = 'env -uVIRTUAL_ENV pytest /synthetic-worktrees/w-item/t'; Paths = @('/synthetic-worktrees/w-item/t'); Unresolved = $false }
    @{ Name = 'timeout, nohup, nice, time, and command prefixes'; Command = 'timeout -k 5 30 nohup nice -n 5 time -p command pytest /synthetic-worktrees/w-item/t'; Paths = @('/synthetic-worktrees/w-item/t'); Unresolved = $false }
    @{ Name = 'nice legacy digit option'; Command = 'nice -5 pytest /synthetic-worktrees/w-item/t'; Paths = @('/synthetic-worktrees/w-item/t'); Unresolved = $false }
    @{ Name = 'timeout inline signal value'; Command = 'timeout --signal=KILL 30 pytest /synthetic-worktrees/w-item/t'; Paths = @('/synthetic-worktrees/w-item/t'); Unresolved = $false }
    @{ Name = 'variable assignment prefix'; Command = 'PYTHONPATH=. pytest /synthetic-worktrees/w-item/t'; Paths = @('/synthetic-worktrees/w-item/t'); Unresolved = $false }
    # Redirections, git operands, and output shape.
    @{ Name = 'redirection targets are not collected'; Command = 'pytest /synthetic-worktrees/w-item/tests/x.py > /synthetic-worktrees/w-other/out.txt 2> /synthetic-elsewhere/err.txt'; Paths = @('/synthetic-worktrees/w-item/tests/x.py'); Unresolved = $false }
    @{ Name = 'attached redirection targets are not collected'; Command = 'pytest /synthetic-worktrees/w-item/tests/x.py 2>/synthetic-elsewhere/err.txt >>/synthetic-worktrees/w-other/log.txt 2>&1'; Paths = @('/synthetic-worktrees/w-item/tests/x.py'); Unresolved = $false }
    @{ Name = 'git commit -F absolute message file is not collected'; Command = 'git commit -F /synthetic-worktrees/w-other/msg.txt'; Paths = @(); Unresolved = $false }
    @{ Name = 'git -C absolute selector on git add'; Command = 'git -C /synthetic-worktrees/w-item add x'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'git add absolute operand'; Command = 'git add /synthetic-worktrees/w-item/scripts/A.ps1'; Paths = @('/synthetic-worktrees/w-item/scripts/A.ps1'); Unresolved = $false }
    @{ Name = 'git -C on a non-staging git segment'; Command = 'git -C /synthetic-worktrees/w-item status && pytest tests'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'git global options before -C'; Command = 'git --no-pager -c a=b -C /synthetic-worktrees/w-item status'; Paths = @('/synthetic-worktrees/w-item'); Unresolved = $false }
    @{ Name = 'git unmodelled global option stops the selector walk'; Command = 'git --frobnicate -C /synthetic-worktrees/w-item status'; Paths = @(); Unresolved = $false }
    @{ Name = 'duplicate paths collapse in first-seen order'; Command = 'poetry -C /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item /synthetic-worktrees/w-item/t /synthetic-worktrees/w-item'; Paths = @('/synthetic-worktrees/w-item', '/synthetic-worktrees/w-item/t'); Unresolved = $false }
    @{ Name = 'a record without a governed word is not harvested'; Command = 'cat /synthetic-worktrees/w-other/x.txt | pytest /synthetic-worktrees/w-item/t'; Paths = @('/synthetic-worktrees/w-item/t'); Unresolved = $false }
    @{ Name = 'an empty command'; Command = ''; Paths = @(); Unresolved = $false }
)

$script:OperandGateRows = @(
    # AC-1: P1 ready allow, P2 not-ready deny, P3 absent deny, for each poetry selector form.
    @{ Id = 'P1'; Label = 'poetry -C ready'; Command = 'env -u VIRTUAL_ENV poetry -C /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P1'; Label = 'poetry --directory ready'; Command = 'env -u VIRTUAL_ENV poetry --directory /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P1'; Label = 'poetry --directory= ready'; Command = 'env -u VIRTUAL_ENV poetry --directory=/synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P1'; Label = 'poetry -P ready'; Command = 'env -u VIRTUAL_ENV poetry -P /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P2'; Label = 'poetry -C not ready'; Command = 'env -u VIRTUAL_ENV poetry -C /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P2'; Label = 'poetry --directory not ready'; Command = 'env -u VIRTUAL_ENV poetry --directory /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P2'; Label = 'poetry --directory= not ready'; Command = 'env -u VIRTUAL_ENV poetry --directory=/synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P2'; Label = 'poetry -P not ready'; Command = 'env -u VIRTUAL_ENV poetry -P /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P3'; Label = 'poetry -C absent'; Command = 'env -u VIRTUAL_ENV poetry -C /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Absent'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P3'; Label = 'poetry --directory absent'; Command = 'env -u VIRTUAL_ENV poetry --directory /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Absent'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P3'; Label = 'poetry --directory= absent'; Command = 'env -u VIRTUAL_ENV poetry --directory=/synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Absent'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'P3'; Label = 'poetry -P absent'; Command = 'env -u VIRTUAL_ENV poetry -P /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Absent'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    # AC-2: npm and npx; N3 is unclassified (stage 1 does not match npx --prefix), so it reads nothing.
    @{ Id = 'N1'; Label = 'npm --prefix ready'; Command = 'npm --prefix /synthetic-worktrees/w-item run test:unit'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'N2'; Label = 'npm -C ready'; Command = 'npm -C /synthetic-worktrees/w-item run lint'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'N3'; Label = 'npx --prefix unclassified control'; Command = 'npx --prefix /synthetic-worktrees/w-item jest'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    @{ Id = 'N4'; Label = 'npm --prefix not ready'; Command = 'npm --prefix /synthetic-worktrees/w-item run test:unit'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    # AC-3: the absolute launcher path.
    @{ Id = 'L1'; Label = 'sh launcher ready'; Command = 'sh /synthetic-worktrees/w-item/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'L1'; Label = 'env -u sh launcher ready'; Command = 'env -u VIRTUAL_ENV sh /synthetic-worktrees/w-item/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'L2'; Label = 'sh launcher not ready'; Command = 'sh /synthetic-worktrees/w-item/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'L2'; Label = 'env -u sh launcher not ready'; Command = 'env -u VIRTUAL_ENV sh /synthetic-worktrees/w-item/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    # AC-4: PowerShell hosts are decided by the item checkpoint.
    @{ Id = 'W1'; Label = 'pwsh -File ready'; Command = 'pwsh -NoProfile -File /synthetic-worktrees/w-item/tests/scripts/X.Tests.ps1'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'W1'; Label = 'pwsh -File not ready'; Command = 'pwsh -NoProfile -File /synthetic-worktrees/w-item/tests/scripts/X.Tests.ps1'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'W2'; Label = 'pwsh -WorkingDirectory ready'; Command = 'pwsh -WorkingDirectory /synthetic-worktrees/w-item -Command "Invoke-Pester -Path tests/scripts"'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'W2'; Label = 'pwsh -WorkingDirectory not ready'; Command = 'pwsh -WorkingDirectory /synthetic-worktrees/w-item -Command "Invoke-Pester -Path tests/scripts"'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    # AC-5: a bare absolute runner operand.
    @{ Id = 'A1'; Label = 'bare runner operand ready'; Command = 'pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Ready'; SessionBody = 'Absent'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'A1'; Label = 'bare runner operand not ready'; Command = 'pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = ''; DetailPattern = ''; ItemReads = 1; SessionReads = 0; ListingCalls = 1 }
    # AC-6: unresolvable operands deny before any listing or checkpoint read, whatever the session root holds.
    @{ Id = 'V1'; Label = 'git -C shell variable'; Command = 'git -C $W add x'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    @{ Id = 'V2'; Label = 'poetry -C braced variable'; Command = 'poetry -C ${W} run pytest'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    # The unquoted $(pwd) form is not classified by stage 2 on either surface (classification is a
    # non-goal), so it is allowed before target resolution; V3 uses the classified quoted form.
    @{ Id = 'V3'; Label = 'npm --prefix quoted substitution'; Command = 'npm --prefix "$(pwd)" run lint'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    @{ Id = 'V3'; Label = 'npm --prefix unquoted substitution is unclassified control'; Command = 'npm --prefix $(pwd) run lint'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    @{ Id = 'V4'; Label = 'sh script shell variable'; Command = 'sh $W/run-test-suite.sh pytest'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    @{ Id = 'V5'; Label = 'runner operand shell variable'; Command = 'pytest $W/tests'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    # AC-7: ambiguity.
    @{ Id = 'M1'; Label = 'two registered worktrees'; Command = 'poetry -C /synthetic-worktrees/w-item run pytest /synthetic-worktrees/w-other/tests'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'; DetailPattern = ''; ItemReads = 0; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'M2'; Label = 'registered worktree plus an outside path'; Command = 'pytest /synthetic-worktrees/w-item/tests /synthetic-elsewhere/x.py'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'; DetailPattern = ''; ItemReads = 0; SessionReads = 0; ListingCalls = 1 }
    # AC-8: relative operands and a lone outside path keep the session root (controls).
    @{ Id = 'R1'; Label = 'relative npm --prefix'; Command = 'npm --prefix extensions/drm-copilot run test:unit'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 0; SessionReads = 1; ListingCalls = 0 }
    @{ Id = 'R2'; Label = 'relative runner operand'; Command = 'poetry run pytest tests/x.py'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 0; SessionReads = 1; ListingCalls = 0 }
    @{ Id = 'R3'; Label = 'lone outside absolute path'; Command = 'pytest /synthetic-elsewhere/tests/x.py'; ItemBody = 'Unready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'allow'; ReasonCode = ''; DetailPattern = ''; ItemReads = 0; SessionReads = 1; ListingCalls = -1 }
    # AC-9: listing failure and empty listing with a runner selector.
    @{ Id = 'F1'; Label = 'listing throws'; Command = 'poetry -C /synthetic-worktrees/w-item run pytest'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Throws'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'listing failed'; ItemReads = 0; SessionReads = 0; ListingCalls = 1 }
    @{ Id = 'F2'; Label = 'listing names no worktree'; Command = 'poetry -C /synthetic-worktrees/w-item run pytest'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Empty'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'listing failed'; ItemReads = 0; SessionReads = 0; ListingCalls = 1 }
    # AC-10 and decision rule 3: unresolvable records and options deny before any listing or read.
    @{ Id = 'U1'; Label = 'unbalanced record'; Command = 'pytest "/synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    @{ Id = 'U2'; Label = 'selector with no value'; Command = 'npm run test:unit --prefix'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    @{ Id = 'U3'; Label = 'env -S split string'; Command = 'env -S "poetry run pytest"'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    @{ Id = 'U4'; Label = 'unmodelled poetry option'; Command = 'poetry --frobnicate -C /synthetic-worktrees/w-item run pytest'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
    @{ Id = 'U5'; Label = 'unmodelled env prefix option'; Command = 'env --frobnicate pytest /synthetic-worktrees/w-item/tests/x.py'; ItemBody = 'Ready'; SessionBody = 'Ready'; ListingMode = 'Normal'; Decision = 'deny'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; DetailPattern = 'unresolvable operand'; ItemReads = 0; SessionReads = 0; ListingCalls = 0 }
)
