# [P2-T3] Golden element identifiers and declaration-lines digests (issue #1022)

Timestamp: 2026-11-03T23-55
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p2t3-golden.ps1 -WorktreeRoot <item worktree> -RowOutputPath SCRATCH/issue-1022-p2t3-rows.txt (the independent helper: loads no module under .claude/lib, neither docs nor discovery-validation; uses System.Text.Json and System.Security.Cryptography.SHA256 only; computes element_id, parent_id and source_sha256 for every expected element of both corpus files and writes them into the files); then pwsh -NoProfile -File SCRATCH/issue-1022-p2t3-check.ps1 -WorktreeRoot <item worktree> -HelperD1 4b1f1972e4baea3016f1021a3cfe9ca6e6076ca82a0ae05a9b26de11403e24ea (the acceptance check: loads the branch's .claude/lib/docs/DocsSurface.psm1 and compares)
EXIT_CODE: 0
Output Summary: D1 self-check PASS: the helper's D1 digest is `4b1f1972e4baea3016f1021a3cfe9ca6e6076ca82a0ae05a9b26de11403e24ea`, equal to `Get-DocsDeclarationSha256 -Text <D1 text> -LineRange @(2, 3)` from the branch's `LIB/DocsSurface.psm1` and to the D1 row of `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/other/golden-identity-vectors.2026-11-03T11-51.md` (the lexicographically greatest match). python-surface-corpus.json: 110 expected elements, every `element_id` matches `^[a-z-]+-[0-9a-f]{64}$` and every `source_sha256` matches `^[0-9a-f]{64}$` (format_ok=110); config-surface-corpus.json: 38 of 38. Additional verification (not the source of the golden values): every `element_id` equals the branch's `Get-DocsElementId` and every `source_sha256` equals `Get-DocsDeclarationSha256` over the input text and `line_range` (110/110 and 38/38), and all 29 `parent_id` values equal `Get-DocsElementId` of the parent declaration. Both files parse with 0 findings and hold 0 CR bytes. The row table below has 148 rows: 110 for the python corpus and 38 for the config corpus, equal to the `expected_elements` count of each file.

## Rules applied by the helper

- Element identifier: `<kind>-` plus the lowercase hex SHA-256 of the UTF-8 bytes of the canonical JSON `{"declaration":D,"kind":K,"path":P}` (keys in ordinal order) followed by one LF.
- Escaping rule of the canonical JSON string: only the quote (`\"`), the backslash (`\\`) and C0 controls are escaped; the short forms `\b`, `\f`, `\n`, `\r`, `\t` are used where they exist and `\u00xx` (lowercase hex) for every other control; every other code point stays literal (UTF-8, no BOM).
- Declaration-lines digest (`DIGEST_RULE`, 1020 `#### Declaration-lines digest (D5)`, steps 1 to 5): remove one leading U+FEFF; replace CRLF with LF, then CR with LF; drop exactly one trailing LF; split on LF into lines numbered from 1 (the empty text has zero lines); select lines `line_range.start` through `line_range.end`, or every line when `line_range` is `null` (`architecture-component`); each selected line plus one LF; SHA-256 of the UTF-8 bytes, lowercase hex.
- D1 self-check: source text `a = 1<CR><LF>def handler():<CR><LF>    return 1<CR><LF>b = 2` (no final newline), range `@(2, 3)`, canonical text `def handler():<LF>    return 1<LF>`, digest `4b1f1972e4baea3016f1021a3cfe9ca6e6076ca82a0ae05a9b26de11403e24ea`; the helper throws before writing any value when this check fails.
- `parent_id` (CLI children): the element identifier of kind `cli-command` over the recorded `parent_path` and `parent_declaration`.

## Helper text (SCRATCH/issue-1022-p2t3-golden.ps1)

```powershell
#Requires -Version 7.0
<#
.SYNOPSIS
    [P2-T3] independent golden helper: computes element_id, parent_id and source_sha256 for every
    expected element of both corpus files and writes the values into the files. Loads no module
    under .claude/lib (neither docs nor discovery-validation); uses System.Text.Json and
    System.Security.Cryptography.SHA256 only. Self-checks against the 1020 golden vector D1 first.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $WorktreeRoot,
    [string] $RowOutputPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (@(Get-Module | Where-Object { $_.Path -like '*/.claude/lib/*' }).Count -gt 0) { throw 'a .claude/lib module is loaded' }

function ConvertTo-GoldenJsonString {
    # Escaping rule of the canonical JSON: only the quote, the backslash and C0 controls are
    # escaped (short forms \b \f \n \r \t, else \u00xx); every other code point stays literal.
    param([string] $Value)
    $builder = [System.Text.StringBuilder]::new('"')
    foreach ($character in $Value.ToCharArray()) {
        $code = [int] $character
        switch ($code) {
            34 { [void] $builder.Append('\"') }
            92 { [void] $builder.Append('\\') }
            8 { [void] $builder.Append('\b') }
            12 { [void] $builder.Append('\f') }
            10 { [void] $builder.Append('\n') }
            13 { [void] $builder.Append('\r') }
            9 { [void] $builder.Append('\t') }
            default { if ($code -lt 0x20) { [void] $builder.Append('\u' + $code.ToString('x4')) } else { [void] $builder.Append($character) } }
        }
    }
    return $builder.Append('"').ToString()
}

function Get-GoldenSha256Hex {
    param([string] $Text)
    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text)
    $hash = [System.Security.Cryptography.SHA256]::HashData($bytes)
    return ([System.BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
}

function Get-GoldenElementId {
    # <kind>- plus the SHA-256 of {"declaration":D,"kind":K,"path":P} (keys in ordinal order) plus one LF.
    param([string] $Kind, [string] $Path, [string] $Declaration)
    $canonical = '{"declaration":' + (ConvertTo-GoldenJsonString -Value $Declaration) + ',"kind":' + (ConvertTo-GoldenJsonString -Value $Kind) + ',"path":' + (ConvertTo-GoldenJsonString -Value $Path) + '}' + "`n"
    return $Kind + '-' + (Get-GoldenSha256Hex -Text $canonical)
}

function Get-GoldenDeclarationSha256 {
    # DIGEST_RULE steps 1 to 5: one BOM removed, CRLF then CR to LF, exactly one trailing LF
    # dropped, split on LF, select lines start..end (every line when no range), each plus LF.
    param([string] $Text, [object] $Start, [object] $End)
    $normalized = $Text
    if ($normalized.StartsWith([char]0xFEFF)) { $normalized = $normalized.Substring(1) }
    $normalized = $normalized.Replace("`r`n", "`n").Replace("`r", "`n")
    if ($normalized.EndsWith("`n")) { $normalized = $normalized.Substring(0, $normalized.Length - 1) }
    [string[]] $lines = @(if ($normalized.Length -eq 0) { @() } else { $normalized.Split("`n") })
    $first = 1
    $last = $lines.Count
    if ($null -ne $Start) {
        $first = [int] $Start
        $last = [int] $End
        if ($first -lt 1 -or $first -gt $last -or $last -gt $lines.Count) { throw "range $first..$last outside $($lines.Count) lines" }
    }
    $builder = [System.Text.StringBuilder]::new()
    for ($index = $first; $index -le $last; $index++) { [void] $builder.Append($lines[$index - 1]).Append("`n") }
    return Get-GoldenSha256Hex -Text $builder.ToString()
}

# D1 self-check (1020 golden vector).
$d1Text = "a = 1`r`ndef handler():`r`n    return 1`r`nb = 2"
$d1 = Get-GoldenDeclarationSha256 -Text $d1Text -Start 2 -End 3
Write-Output "D1 $d1"
if ($d1 -cne '4b1f1972e4baea3016f1021a3cfe9ca6e6076ca82a0ae05a9b26de11403e24ea') { throw 'D1 self-check failed' }
Write-Output 'D1-SELF-CHECK PASS (equals the 1020 golden-identity-vectors D1 row)'

$rows = [System.Collections.Generic.List[string]]::new()
foreach ($relative in @('tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json', 'tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json')) {
    $path = Join-Path -Path $WorktreeRoot -ChildPath $relative
    $text = [System.IO.File]::ReadAllText($path, [System.Text.UTF8Encoding]::new($false))
    $document = [System.Text.Json.Nodes.JsonNode]::Parse($text)
    $inputs = $document['inputs']
    $count = 0
    foreach ($element in $document['expected_elements'].AsArray()) {
        $kind = $element['kind'].ToString()
        $elementPath = $element['path'].ToString()
        $declaration = $element['declaration'].ToString()
        $id = Get-GoldenElementId -Kind $kind -Path $elementPath -Declaration $declaration
        $source = $inputs[$elementPath].ToString()
        $range = $element['line_range']
        $digest = if ($null -eq $range) { Get-GoldenDeclarationSha256 -Text $source -Start $null -End $null } else { Get-GoldenDeclarationSha256 -Text $source -Start ([long] $range['start'].ToString()) -End ([long] $range['end'].ToString()) }
        $element['element_id'] = [System.Text.Json.Nodes.JsonValue]::Create($id)
        $element['source_sha256'] = [System.Text.Json.Nodes.JsonValue]::Create($digest)
        $parentDeclaration = $element['parent_declaration']
        if ($null -ne $parentDeclaration) {
            $parentId = Get-GoldenElementId -Kind 'cli-command' -Path $element['parent_path'].ToString() -Declaration $parentDeclaration.ToString()
            $element['parent_id'] = [System.Text.Json.Nodes.JsonValue]::Create($parentId)
        }
        $rangeText = if ($null -eq $range) { 'null' } else { "$(([long] $range['start'].ToString()))-$(([long] $range['end'].ToString()))" }
        $rows.Add("| $kind | $elementPath | $declaration | $rangeText | $id | $digest |")
        $count++
    }
    $options = [System.Text.Json.JsonSerializerOptions]::new()
    $options.WriteIndented = $true
    $options.Encoder = [System.Text.Encodings.Web.JavaScriptEncoder]::UnsafeRelaxedJsonEscaping
    $output = $document.ToJsonString($options).Replace("`r`n", "`n").TrimEnd("`n") + "`n"
    $output = [regex]::Replace($output, '[^\x00-\x7F]', { param($m) '\u' + ([int][char] $m.Value).ToString('x4') })
    [System.IO.File]::WriteAllText($path, $output, [System.Text.UTF8Encoding]::new($false))
    Write-Output "WROTE $relative elements=$count"
}
if ($RowOutputPath) { [System.IO.File]::WriteAllLines($RowOutputPath, $rows.ToArray(), [System.Text.UTF8Encoding]::new($false)) }
Write-Output "ROWS $($rows.Count)"
```

## Rows (one per expected element; 110 python-surface-corpus.json rows then 38 config-surface-corpus.json rows)

| kind | path | declaration | line_range | element_id | source_sha256 |
|---|---|---|---|---|---|
| cli-command | pyproject.toml | tool | 5-5 | cli-command-d8e4d98ee1e896824b1619e729d9febc461fa5ad9d3b5aa7f1ea954b3cb9b5b5 | 35ba6fc18889b0be1afd352ac3ec6ec08d7c8bf37257b2f850569dacb5dbcf27 |
| cli-command | pyproject.toml | typ-script | 6-6 | cli-command-eaf4dd1b360ba8a886141f9277de3e7f4dd7b3d1f34d3ba947f819ddc5060bf9 | 11d2a5d0cc93397bd71d64c44978c736b62e68c0499ca7c283508f305a0957c2 |
| cli-command | pyproject.toml | missing | 7-7 | cli-command-7c488304e53eb00802845d3a48e9972d36d73ca8d4baf7ba7994a0a0d090f15a | 1030d09fcb80bba1888e8252a96c0d8357ef8b6f007cb3910f6c26b63e1b4fe1 |
| cli-command | pyproject.toml | gui | 10-10 | cli-command-3aa46dcf86c384908e976e39299fd2192b496866ae5d29611fc9c4c0458f3f28 | 6da864e590a1f25858af22befb680821548970e66593c23bcea838f08a3178e2 |
| cli-command | pyproject.toml | poet | 13-13 | cli-command-9d14685abf059b9955c96267a02f7d67fa7768461777908338c658774ac421d0 | d922ed28922e5b34f6ff86dc51dd2cbe33487347fd9f0dca00af46e92ccb4e80 |
| cli-option | src/pkg/_cli_argparse.py | tool --verbose | 6-6 | cli-option-316ad80ff70b3febadf60046599a4d2570cdd8ae5a8f7f8674da6162bc1e9541 | ea8acfd00f3f4c755f92caf8d64a8172bc5c22788cf8d00c2d4acaa84d37a023 |
| cli-option | src/pkg/_cli_argparse.py | tool path | 7-7 | cli-option-69119a6577b8ebece48721e55d18cbe9c4073501f9117fc858b95d7024984e1e | 3e461a4566d7d56b6c2f6d4ca9d88448d6fdfe8e706f719a6e0dcea91723e325 |
| cli-command | src/pkg/_cli_argparse.py | tool run | 9-9 | cli-command-22a5c3dfb6b26f5a5fc983b4a9bdea5088ea364e51e26ac1eeb45f65e88366a1 | 4dfd171a28e8588aeb9be0f4a4094cca01bfd09214ef601bb2e40750671d2158 |
| cli-option | src/pkg/_cli_argparse.py | tool run --count | 10-10 | cli-option-da282baafe0959e6bae75e01613b4d73af65102d5ef7a7072efa4772aa2a8518 | a49ce8f7a371f030a0ea08c4d7dbb98435adfdf5341993f67eae17f2eac4eb7a |
| cli-option | src/pkg/_cli_argparse.py | tool run --fast | 12-12 | cli-option-6399a4ccd6c6384f3890255f95df4765dd3d470800b1c6e63ab3dd1795da662b | 02516c74ed3a7cc43ed6cbadc9f1f853d32633080a09a1c3a2ad79a507c39f15 |
| cli-command | src/pkg/_cli_argparse.py | tool run deep | 14-14 | cli-command-f92124872a91ebf6b60322975e2b885631a2d723ae0a80cf3984d85223ac8928 | 8619388d5b5f6c009cead573a9a7fe836a274f560d7ecbadf7fbc52c44ab9bf4 |
| cli-option | src/pkg/_cli_argparse.py | tool run deep --level | 15-15 | cli-option-f5b6b1f0da30298d9014e179bbe4e1443f861cabef66f78b8eb1b8b577ab19d9 | 10b55c3c8e81b47f2a28df762dc6d6687bd2e5a2ad697c64e84d93bf664376fa |
| cli-command | src/pkg/_cli_argparse_diag.py | diag | 8-8 | cli-command-ad885923c31cc878c32b94e5703346b5467ab5b125f8874d928ad79a46502c1f | 8e3d0e1c5c5d712d7f799a971422226704e2ba6e68882680a3f1e9808109cd5f |
| cli-command | src/pkg/_cli_argparse_diag.py | child | 14-14 | cli-command-254f0a307da8568de8207d7503a95107369f80ab91d88ddcb9b4945ef21e0f7f | 5f90959c85d0e8e6c74352c12c2df00d0dfee0e6d6027b967df5210d902b51ba |
| cli-option | src/pkg/_cli_argparse_diag.py | child --own | 15-15 | cli-option-48b0225c57e0e5b4fc169396c5bb1fcf0bef4dde8d22e9473f271928c4c3fad7 | 0c7e71c2b2c5cefcbc5fab58f1135dba92ec4fbf340655ee68e57c6fe6e31c59 |
| cli-command | src/pkg/_cli_click.py | main | 5-7 | cli-command-1bc0796e7a3297eeb83a9e3bd0df0b81e394e962dbb1d21c9caf686fcd24e49d | 3c09229a8d35abbb74a6d26cd0f604e54c9df53beb9ccbeb677a57f3f7fbc516 |
| cli-option | src/pkg/_cli_click.py | main --debug | 6-6 | cli-option-9f17dcf174b6c8a441a3d28f6d3800e137123207c97928078cbb91fdc578e4f9 | 20736bdc8da1ee763bab48521f587e719ab685c80a780dad1b875cf3cfd454ec |
| cli-command | src/pkg/_cli_click.py | main sync | 11-14 | cli-command-b46151441c4913a5b52afaa20901cd40ee284224f392fd92cdaa6e92c88ecce6 | 28651554b291a0de25c2cdbb0ba7bf0935bc472dd4a722b9e57894e916209130 |
| cli-option | src/pkg/_cli_click.py | main sync --name | 12-12 | cli-option-e296f41ca8a005503917afed3b9710e4d55044be19512f9823ec177c428bafb2 | b512fb03c44801abe97fb7d44293f0e3b011fffca268950f2b671d8c80457132 |
| cli-option | src/pkg/_cli_click.py | main sync target | 13-13 | cli-option-55de9943d0bba0499deb2104d2b4159ffce793a34812e4c9dcba2ae2029e0498 | 8a050fc481ac525c63dd272ff555cc7481c0728671242eaf0278d5006ff78649 |
| cli-command | src/pkg/_cli_click.py | main nested | 18-19 | cli-command-861db7dcb72d1d899ccca37b94508ec3a5dc3b852e6a3d75f15d252ba1fe5f4c | ec0ca9529613ff162f8532e7813eda0958054b1e3584691bc5bf5135f0f9f88d |
| cli-command | src/pkg/_cli_click.py | main nested deep | 23-26 | cli-command-23a53c1782116b1bbc20c18eb8403f909f9795362c5a4d298ea1167a8c2d88e4 | d6b0c0e4eef1fadae5a0b19978cf7b4bfe1a69ef410000788975de44abf49f71 |
| cli-command | src/pkg/_cli_click.py | main plain | 30-31 | cli-command-53660d1ca069b63d3c2b7a95355f5ae18d0c9191a85d4b3ffbd8e37b2a5169f3 | afc66492c1449c130f998055275c53c519f1ee1f92d128aa377329d3bf241b8a |
| cli-command | src/pkg/_cli_click.py | main extra | 35-36 | cli-command-21378ccebfbff71e7f5447cffde8b5952548be6c2fa336a19b1bb9a2c1d6da59 | 6d17c8bc40e0dda2e9af182bbb813411088e1cffb49bbf34a3fbc00cc7e2fa34 |
| cli-command | src/pkg/_cli_click_diag.py | okgroup | 30-31 | cli-command-78cb60c3ab3c319b850431d74366eb475b031c3516e1d48ef5fcfb2efb8f60ad | 534e20fddd86c3ec14f2eb4749f334404649eed52e0ebd9934198d547cf9be01 |
| cli-command | src/pkg/_cli_click_diag.py | ok | 35-36 | cli-command-4a0a9b3034d4d07bb95532b43029b7fd6ec98401e96617912ebda64c08d488b3 | cce52ca3b14d90e2776aaf074814c7c7727ac70d141f323e4722b064974b5cc5 |
| cli-option | src/pkg/_cli_typer.py | typ-script --verbose | 10-10 | cli-option-267620c08031c3ed1a1b64e73f3c9d51047a4cf7cc635824a9a86772d75e7710 | 77a125f0a2120ce006c222955e31ce16af2e14db3ae6d81ec73ad1cc64d07533 |
| cli-command | src/pkg/_cli_typer.py | typ-script sub | 6-6 | cli-command-357211bd690da35ae37cd3b019f67c27679a3049db8cd00fdc4988aae4595c39 | cc5da23b4d55ed243869d8684e76b6696fc00a05e6dbb8b04c0dcf5c83c99424 |
| cli-command | src/pkg/_cli_typer.py | typ-script run-task | 14-20 | cli-command-2b5bcbd47198a999fc091c0b065da30f2903588139700c910a09a2562249306e | 066f92609832391d469ece822f7a60eefd78772d8d88119754a4a5420523a3cf |
| cli-option | src/pkg/_cli_typer.py | typ-script run-task name | 16-16 | cli-option-3cbc0aad6fcd067ddf3d3cc5f8f5d0c2749ef116c79c97676b07c1dc8be79e1b | ad4007137b69c9eb1d0444a8e28c2bf2587b0f4317cab3ab641f38833e37c356 |
| cli-option | src/pkg/_cli_typer.py | typ-script run-task --count | 17-17 | cli-option-d467be625d79c5bc0b29a456da230ae555d82353e465a90fa65d2ce29fa959dc | 7e2e50ca25c153489be68ebe5a14f3e8c95c50a49cfc898960b9bf08aec9291e |
| cli-option | src/pkg/_cli_typer.py | typ-script run-task --flag | 18-18 | cli-option-0d0ba49af8825c4b316bae73eddde5e00947d0a5adaebb98099762057f3b1c72 | acd79f8f49604e2d70be73eaf5b72a159bc5948077e2d1ba459487ff7d0e0fd2 |
| cli-option | src/pkg/_cli_typer.py | typ-script run-task --tag | 19-19 | cli-option-cab98b827eb79b6077abd3f910e07c53e705915d8ffcb932a12aa99edb853f09 | 5bcdeec3c68c0488a3911bfe01f05510996cbee9251ea8c933571b072a796427 |
| cli-command | src/pkg/_cli_typer.py | typ-script explicit-name | 24-25 | cli-command-ce1e38ff50445c601aed4880a5ff967ffc51f516119bde4ec0e4e0d650b27107 | 3ea7c1aec4feb8bdde67b4c31561b1c5144b4e71209383caa37ede3a8f8c0cb5 |
| cli-command | src/pkg/_cli_typer.py | typ-script sub inner-thing | 29-30 | cli-command-d63978efa6a662143f148710cbe0da2a1f0d5383b22282d7fbe3fdecddf2d81b | c63dba540708acad4cd4cce370fdae6075f6aea323b38648187a826acc9b7623 |
| cli-option | src/pkg/_cli_typer.py | typ-script sub inner-thing item | 30-30 | cli-option-7bd6f313b3c79dae7260c907aa7a34c2b546c3062f43f72a19b8ea3932dbe569 | 66b9f1ebbb4fdc7b775bd0286af501f9172cea36d23907edffee9fc8bbe0769b |
| cli-command | src/pkg/_cli_typer.py | pkg._cli_typer | 34-34 | cli-command-2eae1f12c6063bd7f0960e1a2e1e52cb7ca5b3be0066885f1e437ce4716b6402 | af8503beda87d15d4f78f79b1ba8dbba730fcbf521a37dedca4e19a8b271b37b |
| cli-option | src/pkg/_cli_typer.py | pkg._cli_typer --value | 34-34 | cli-option-549051664db25a22f45208b0fb133981f661509504bd8cb6e95c0157fc9470bb | af8503beda87d15d4f78f79b1ba8dbba730fcbf521a37dedca4e19a8b271b37b |
| cli-command | src/pkg/_cli_typer_diag.py | tdiag | 9-9 | cli-command-b7b4ab158c7e2bbc466582e899ae33a9f30baab4b4957c7ddd077b95e7eaec77 | 4b87fca16db4aff3d0a1c02a2b8f70d2261fc14a53cf90a84b9eafa7a4c1e41d |
| cli-command | src/pkg/_cli_typer_diag.py | tdiag unresolved | 12-13 | cli-command-e174d4a8870fd5b7504acc1198bf4e813ad5c541204d311f6a93d6e967096fea | 4bef0dd49128b891deea8ea44b04dc1f18c529b0f019b303d8318fc8c1b6b7df |
| cli-option | src/pkg/_cli_typer_diag.py | tdiag unresolved --other | 13-13 | cli-option-1faeae7a775562da69dad5dede3c864b0f96bbba15c60253351c901a75cfe8f4 | ecfe39e6d4492e3d55a28decf49aafa96e9ed2ea59bd8892d2e485b3df1cc1a5 |
| http-route | src/pkg/_http_fastapi.py | GET / | 9-10 | http-route-2374077c69d2ef7c498aa305a9219e09f64e69b5086ec80ea14e117a6ee2282e | 27975fd759f68c9f49a25ce2b9f0ed21a1a2819b06513fb44554569156d490e8 |
| http-route | src/pkg/_http_fastapi.py | GET /ping | 14-15 | http-route-2f2920ae4153321f5d0144a81098b69ad585e0d5843f7adcaf86028ab83d0c66 | 2ec9421361dc21d7970c4ec3f9740b98c021ed49d1344cf09841b9da9d483223 |
| http-route | src/pkg/_http_fastapi.py | POST /ping | 14-15 | http-route-31f3fa4f1470be5ee6fba01c95b1be1874dc7ee3bef909d1f34cd71bf01b94c2 | 2ec9421361dc21d7970c4ec3f9740b98c021ed49d1344cf09841b9da9d483223 |
| http-route | src/pkg/_http_fastapi.py | WEBSOCKET /ws | 19-20 | http-route-12f18d6f3317b2b76602a2005edac4cbaa2279dc9f064599e24481d6e86cfbab | 713a3b70a1a6e981fd78de7f0dcf75694f0a6eb2373a695443838882ac5c1ed5 |
| http-route | src/pkg/_http_fastapi.py | GET /items/{item_id} | 24-25 | http-route-5bca9ee62643e195c115e86dee19985f3702c0eccf2bc91e22f5ba37b9666467 | 881e3afc7cd112f5b116a7c41378559459aa230614afecb9eabcd2c16ec577c4 |
| http-route | src/pkg/_http_fastapi.py | GET /v2/items/{item_id} | 24-25 | http-route-1f551e76378c4cca23563db397e23366dec8760104ed0a221a84bd7235bd93c4 | 881e3afc7cd112f5b116a7c41378559459aa230614afecb9eabcd2c16ec577c4 |
| http-route | src/pkg/_http_fastapi.py | POST /items/ | 29-30 | http-route-94450ec3681192175329a251314e982f1a998c2c17b375e935e4667d8e566c69 | 190017fd833ce04ed2dcf052af19f03d640271f63efd0e39c14dcee9427ee1dc |
| http-route | src/pkg/_http_fastapi.py | POST /v2/items/ | 29-30 | http-route-52a46e46fc0baffb4114a6484839cc1f792b590b2e37476cbbefd9adfc06a74a | 190017fd833ce04ed2dcf052af19f03d640271f63efd0e39c14dcee9427ee1dc |
| http-route | src/pkg/_http_fastapi.py | HEAD /health | 37-37 | http-route-7546e3efbb221eca225d663d23ef26df8ea58ec3fccc15619bc37078a79728fe | 7e2d119fc0f5ac08f11fb2ca0bef08452fc76d403dbc0549ae8388e64709a086 |
| http-route | src/pkg/_http_fastapi.py | GET <dynamic>/items/{item_id} | 41-42 | http-route-6bbc1d52958011613aa71a4ddd909448f764d55fb28a62358762f03b301f137b | f68ab8dfaae09bdf66fdddfcee746caa58af999637b82ed394b330be1ea25beb |
| http-route | src/pkg/_http_fastapi.py | GET /orphan/x | 51-52 | http-route-b589236e18990fd90747d294c50f33dd45dc5fa6d0eb9987dc452dd5f19f814a | eada1f5c712ca28c07bea50515fe73a71dd202dc0b5032fc1964071c1c3313a1 |
| http-route | src/pkg/_http_routers.py | GET /users/u/{user_id} | 6-7 | http-route-5e54418b7f0af14dfc462ad5ccfb18244159fdaf1a0f0beaaefbfda8cea163a4 | 90532176c782a78295e4b7959669896c265f48100a040f7a34a7706b91af6594 |
| http-route | src/pkg/_http_routers.py | DELETE /users/u/{user_id} | 11-12 | http-route-dc5b96f9a32802602abf3774d7a04dee21e4800d5aa0217384e81506c3ebf131 | 493c10b3965a513d65340dff24991dce4acbcb6da272731aab437055b1987e15 |
| http-route | src/pkg/_http_flask.py | GET / | 12-13 | http-route-a35caa2424d43f3ed4c706d69cc45a3ebd92a06b75c8aee0f293cc1cd9e5aecb | 6fec4cfd95861220f228f31dc912ba591be4de7d9b4103ac2819fb24226e04b0 |
| http-route | src/pkg/_http_flask.py | GET /multi | 17-18 | http-route-8d7b2da908c66fdc62582d6baa6f16b6fd00bd32f14dac2c483a4f531b394098 | 3a69b98183212e9f165821bb4bd3d38ad6f1918315b61da3ea4e22d61b0bac2d |
| http-route | src/pkg/_http_flask.py | POST /multi | 17-18 | http-route-bf64e0a2111cb4153d88c65fd8da2c21d380b4dcd7f3eb951551b8e4522a10b7 | 3a69b98183212e9f165821bb4bd3d38ad6f1918315b61da3ea4e22d61b0bac2d |
| http-route | src/pkg/_http_flask.py | GET /bp/items/<int:item_id> | 22-23 | http-route-17ceb002e2a6308530a2d4ce56db0c78d1d9bc033f92c37ac4cf270e4284f34e | c55514cd1f35ce966e1bf133f92a9c0f2c329d7925d5ae3c4b282f7303948361 |
| http-route | src/pkg/_http_flask.py | GET /other/items/<int:item_id> | 22-23 | http-route-f793ac6b1aae2fc3d70fe7d9b15df7ba15eaab7e728f949ad002b9b6fbf5baa3 | c55514cd1f35ce966e1bf133f92a9c0f2c329d7925d5ae3c4b282f7303948361 |
| http-route | src/pkg/_http_flask.py | POST /bp/items | 27-28 | http-route-e19e1da2ad64990ca881a584cb7aa22c59872f8b895417c9a7fed843ec4e1bef | d13db5535fe5d22a545bb08325bf1ea8f19a1de554e08e76e13e52262cb0ff82 |
| http-route | src/pkg/_http_flask.py | POST /other/items | 27-28 | http-route-c8ec6eb1adb5325d24f8485303f69af9ab6c008b87ea99dbbdf6ce8acae728e7 | d13db5535fe5d22a545bb08325bf1ea8f19a1de554e08e76e13e52262cb0ff82 |
| http-route | src/pkg/_http_flask.py | PUT /rule | 34-34 | http-route-5e27d6be9d09428e29d91188c940d08b6e315c02835d4db14ce681a84dcac420 | d617e895d5d016fabfe23940e1000acb63189728e484ca4b95f804ae9e4c211c |
| http-route | src/pkg/_http_diag.py | GET /a/cycle | 40-41 | http-route-3289e18538376cf747092868943cc513eff6640c4ecb2a4988d70bd53266e493 | c9409a68d5cb9a1e0c0ba1a783a9f799af85467ae5f1067c7a8092ada315fd37 |
| http-route | src/pkg/_http_diag.py | GET /fine | 45-46 | http-route-c388222da4c7a1ca426de45afc76624918d30dddba345fbbfa87bbf0fe763ff8 | 051fe0798baa8b689424e6c03f63991780c395d0d1e845fde312d5da99df72d0 |
| public-symbol | src/pkg/util.py | pkg.util.helper | 3-3 | public-symbol-6afdb314162e13accf71910b1374d978d8e24f2f086bd0f2eada321a50efb607 | 1e11d8f1e218a3509f3b20b6e21d89e9718426d8b420803ae91b355072c01da6 |
| public-symbol | src/pkg/util.py | pkg.util.Helper | 6-6 | public-symbol-2b3b5079d73c648445f2ae9f7c35759382be2d7e9cd9af44f59f4770d570f780 | 99f2cec50b277ba4f19b74629ef6cf05c8863c15ace3809c16dab68033c928a9 |
| public-symbol | src/pkg/util.py | pkg.util.CONSTANT | 9-9 | public-symbol-1c57275e35e99be7cb2dc395f08df6e96413bb0c9b5af95d0a026c0a05fde268 | 34d4faa1929723c6f3ee69f2f14db6f6cda472b869cc20f06dc6c1930f4be83c |
| public-symbol | src/pkg/config.py | pkg.config.Settings | 1-1 | public-symbol-ddf7c8e15603fa7644d0d97c4383e5c305ce091a3c74dc57632064cbf2cdde80 | 69185682509b5b6138c20f20697ebf9d15587ccb6f314f17e85a0539aa0b78d3 |
| public-symbol | src/pkg/config.py | pkg.config.settings | 5-5 | public-symbol-5772fd7dab0c5cc7be70d72b1701d1bd230697320d6a973548a027a171fa8c59 | a8f4bf18761602d3b590b37d398fa99779730a77b68138fdd14073492e3766ed |
| public-symbol | src/pkg/api_all.py | pkg.api_all.first | 11-11 | public-symbol-61a69ee556dc7fb2f606ee43213b1a66cce8e1e0d0ffd9cb4397c057c17908c7 | f61c132276a514c185fbc7004359c4d0c8a1958739c0ec595158868d5f064fb4 |
| public-symbol | src/pkg/api_all.py | pkg.api_all.helper | 2-2 | public-symbol-bddf846b4d6f504ef6c81732893f45b250a1549ed38d76d1e240df8fa444e17b | 7f78c7188ca94a4442c7104834db062bc5693b5ae00459131f5446fc42e003ee |
| public-symbol | src/pkg/api_all.py | pkg.api_all.second | 15-15 | public-symbol-7e37a2b44813c93d1f48e2044e07308baf396b7adbbebff2c462f6a91d94a263 | 30c3db89f85206601bc2721003090d94d68d035f10690486392b3240a3dc07d0 |
| public-symbol | src/pkg/api_all.py | pkg.api_all.third | 19-19 | public-symbol-50efd3e03189f928760f7ea715af4b2bc17e9489559b4a7a92b25c6f75ab6575 | b6905cad756143515a2f0f92b8d7f2bbfbdca6b294314de85a1d34fc21f3c631 |
| public-symbol | src/pkg/api_all.py | pkg.api_all.ghost | 8-8 | public-symbol-fe19e62839a39af416d4e622c41fbb7bc5846138706258473f801ddc3a82bc1b | 18f327def68ba5780091de52bfdae99de3807450149f42d2cdd38a7ea8e8ac43 |
| public-symbol | src/pkg/api_all_tuple.py | pkg.api_all_tuple.alpha | 4-4 | public-symbol-322fa06b23b138298749791bfe6845bb9020a2e986e32f4dfa54479f86abb3bf | cb1f27ca781ef39be6f82ad5e73821b43a132b1aa9d13c612781bb807d2448f2 |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.platform_value | 5-5 | public-symbol-0d72a42d02c73f6439c12506e81e5777d3381ebfbe5114207461ad41b244aaa9 | 55fa3de3face106da6bb54333c45199a9fabce23bff25d756c1e38d7e8f1acdb |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.optional | 10-10 | public-symbol-e0c945878f42d0def85b7d191d00e662499b10840acc37f3904d5891f081c4ec | 41b5c772077b4fad01bb5839024bb9a6975c9972211fee4a188550be1c0d933f |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.cleanup | 14-14 | public-symbol-c4b49133c96e6017eff384e55d25091276c03e4a9f6bca8d05802cc96c835536 | 48b4f5ed9c17b151555b27ad4513849a8444ec06fb3291276359ebb999c19f3b |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.a | 16-16 | public-symbol-4472e1b0b02908197d491d8c4d94d95eb7484e10c6dd7e979316e07891d9e523 | 0ae728edff8cdfac5e9e3ed1e0fef9b6072834f0f276048641d2c73ff8d168ad |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.b | 16-16 | public-symbol-07fb24028e3c45cd7be0d84170829dddfac85ffec14c0ace14ce6c1d1528fca1 | 0ae728edff8cdfac5e9e3ed1e0fef9b6072834f0f276048641d2c73ff8d168ad |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.typed | 17-17 | public-symbol-763567a0291c249b7ffdbc260bfa406a6e58e6de9fec8182034cbe004f917d0e | 83a1852f53277c27835991055905a70e7dceaf62f496a82702d73c407f23f3c5 |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.decorated | 22-23 | public-symbol-8193e240d5c86dae7a86a92ad373c61ba5d95319e1221870169d3bfefae41b3d | 5c3ecaebccd3a8ceb5f5db29db9c89e2b5370cbaef442d65897b15d2903ac607 |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.Klass | 27-27 | public-symbol-88b9aa53204dbff5353203ec4ac362328a0aeb1041da692ddf5340352257fdd1 | a5729adca77566d738abe97e22bf28310c328e48cec666f846b9b8ef3f5b29b4 |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.App | 35-35 | public-symbol-fad501b504df080a5452f8d36acc28c7b35aae374d796d16b952d8a1fcca06f2 | ac5f3bc07383d8433a99b04ae9770680200576ed3163d2fcd26e830665dfcdb8 |
| public-symbol | src/pkg/api_naming.py | pkg.api_naming.app | 36-36 | public-symbol-ff6dfcf880722cda0c1ab857e0c47d537a2e024619faef50e352f3d387fc7c44 | cac8fce26388930c1078274af79f23f5898a16fcb701428ed145784f3414ace8 |
| public-symbol | src/pkg/api_dynamic.py | pkg.api_dynamic.one | 6-6 | public-symbol-2a1ded6105e17d7026f5d5f84fa156702221810e03313d515609564333844f2b | fc09444be05159c9a5a3396e9d788ff0fcf9a49ff54d821a1b4f7ac095015dce |
| public-symbol | src/pkg/api_dynamic.py | pkg.api_dynamic.two | 10-10 | public-symbol-8837715e864bcf31f0adb4271dded99b0ebd42df2b944abb408c12d5f45cec42 | 74fcbe5c085ccdeb567aca35f0b830c703276065c8ca3dac4f3faca61475a195 |
| public-symbol | src/pkg/arch.py | pkg.arch.load | 12-12 | public-symbol-ca2dd850446bdafac9765a7e6e6c736785e4f09b664bee5152106ad968abfe7f | 84ff6dfd573052743ee6b23d87ff505f2752880937625769c0dc95649ffe2dcb |
| public-symbol | src/toplevel.py | toplevel.VALUE | 3-3 | public-symbol-bcf4693474281c26c2e1dc46a6245e3688460763668f75b31a316969dd6230e2 | e13df8c44af5dea1e412403910b99cc5a48f2ccbf68a66b3374d6ab9cef9fc65 |
| public-symbol | src/pkg/lex_imports.py | pkg.lex_imports.inner | 6-6 | public-symbol-4adc658480e6207a930af31a4c166c85b3dbf0fc32ff8150f34349767e8b7a5c | 6d4edbb5d01f751345a71925a3c815f4a3d9d944b8d34fea634791f012a4046f |
| architecture-component | src/pkg/__init__.py | pkg | null | architecture-component-303d782630f7bd983a8b8eaa73742ab0862d7eb6796b39284d64f0352b388bac | 1b5af566d6a24b8b78f2df1e0bc5888161e4bbdccd57940693b4f581928493bd |
| architecture-component | src/pkg/util.py | pkg.util | null | architecture-component-fcb34138acad0c642470fc5c437b64e31e24c1b854b631773820a7aecd80ac5b | a14e932f6ec4ec229ecf4f71a46574c284de5dac2ff39350b8e214d6593b0041 |
| architecture-component | src/pkg/config.py | pkg.config | null | architecture-component-553847895318f4005df7201f6cba5519e20f19021ce93a01db5ec4675c64e6c6 | 412a717e7118cf04347e8555728e6875f973499ed423779c9d0c8a99bed296f4 |
| architecture-component | src/pkg/_cli_argparse.py | pkg._cli_argparse | null | architecture-component-8418e3b58ee1fc8ed17c447be12800538ac67aaface1fbf4bd741df6e4b8c693 | 6943f8bd5c3a432102a76113c40ce302131300b2d6b81aea221060e63835bed9 |
| architecture-component | src/pkg/_cli_argparse_diag.py | pkg._cli_argparse_diag | null | architecture-component-3c0941d14d320d711c45b4aab40e38c8dc604990deb6c056927c5157567f285c | 934af86afc5cc6731aa35146b2afea02f75e32faa0cd6a189c50b05042f12360 |
| architecture-component | src/pkg/_cli_click.py | pkg._cli_click | null | architecture-component-1f4c0f249000b19e240b7bcdd154f5cc853873a5c060675124b0aca75f427940 | 1fb16309f06a08f952ff3e29679a82f014f1f24fbe89228a110a9b8a4618388a |
| architecture-component | src/pkg/_cli_click_diag.py | pkg._cli_click_diag | null | architecture-component-a4a36dc6f8cbda90c98f9332e9fb26b4dec368826508f87ddf2624699893be63 | 9ffec0c17ef75448bfb61621fe72f5754f03d2682623e37c1fd248b1d756f0fa |
| architecture-component | src/pkg/_cli_typer.py | pkg._cli_typer | null | architecture-component-bc2155cca311418428fd0a3108dba62f467452338078e5ff5bc7e7d96889244e | c89ee730f35116683b4629e9ba3984637cd11f939f94970d4e21c4a7f2d1879c |
| architecture-component | src/pkg/_cli_typer_diag.py | pkg._cli_typer_diag | null | architecture-component-ca857a9cfbc4fe476ae5a63c044fb010f03943bc39b2c149b71643855fb6dcac | d36852e7da169eb15d347bbb9354cd65064269bd4734d3d3d17fcd6df1f5e08c |
| architecture-component | src/pkg/_http_fastapi.py | pkg._http_fastapi | null | architecture-component-d780e81e52c3e77c089778865c2bd234aa0213d126a982e8e14b354f42f8be1d | 4fc647921b78c3b1b113bc1e5152f7781f23b8e2f65ab9b395b2d6c149bbfcf1 |
| architecture-component | src/pkg/_http_routers.py | pkg._http_routers | null | architecture-component-29c28784902c9bb03bf27996733b52c32cad2d207e896fd7de5908a41aed9eec | e3ba16a81a4961687e2b935f5835421f39a9b37d58274d94f69da4731d6e1ba3 |
| architecture-component | src/pkg/_http_flask.py | pkg._http_flask | null | architecture-component-28fa15c3be29394f4aa515790cb01738664d0efa9ccf5759852b7b000b5cb600 | c1ee12c88bc0f2c2e452a49413eb5e33d1474b717fe8220e804158f3b1f11934 |
| architecture-component | src/pkg/_http_diag.py | pkg._http_diag | null | architecture-component-95b68e292ebad28814ae1dd5c7e7a88361a3fef0f335a95720169c0fc336cb64 | 830e96f843aa462f991a990fc3448fd20256e850b0633096d1d7d6bf5ddf20aa |
| architecture-component | src/pkg/api_all.py | pkg.api_all | null | architecture-component-80ea41f54b2ef0a264582784782e0c3c24bd943a732163065afa19fbd7b24b20 | d1ed534c69745c9714dc41ff9b8f13db911ee2613cb788969127cfc06d621efc |
| architecture-component | src/pkg/api_all_tuple.py | pkg.api_all_tuple | null | architecture-component-79159ce2f8c1506429b06646999daeccd7992f0635ca08910876ced62f2d5e2e | 912787e4f646534102bab50e70e81f688360a16d966a1b25c5b176b9e888d4ac |
| architecture-component | src/pkg/api_naming.py | pkg.api_naming | null | architecture-component-32550f455fc605c9a263d97dc788a88e7f1687d092276169f8b81bdeba9f397d | 18ab94b222daabaad5f22ca178794bf1c6c3c7adb974eea9e8ee2ed342f09989 |
| architecture-component | src/pkg/api_dynamic.py | pkg.api_dynamic | null | architecture-component-c5a416a11f0a5b39ddc147b0a5ac547c47a9c07778a76ef99aea0ef80c136dc0 | 685fef2a2921abf8fe24522962a7add234713580191fbb6f0c203c531e1c6411 |
| architecture-component | src/pkg/arch.py | pkg.arch | null | architecture-component-02ef35614973e5ac205ae11773d06e2f18cbbeb01388f9b7626675314a904189 | 196f6d97112daf3e10a8376ef0ccaf724078d5498f3698b08a335f2dd280f842 |
| architecture-component | src/toplevel.py | toplevel | null | architecture-component-a59bfbc9af0d8df7085799986c759a15f9785734500404ddafcb9491975d8615 | 6a6c0f7536bd0c69eb49c29eb74d388e8eb3fe49817a6e6465255fa904c7d2f4 |
| architecture-component | src/pkg/lex_imports.py | pkg.lex_imports | null | architecture-component-20ebf5a5357435e7798a94847756cdeff9597f9b0755f9d714109d87e7e76deb | e9ab88d7abf3325244a7553dbe77d044b2687e30d987b06e8c1eb2903a8ad2b6 |
| config-key | config/pyproject.toml | tool.black | 7-9 | config-key-905c63ac3b5d8ba4ac10a031ed55247f8636daeb6f5630ab1cc5b95c69a6041a | 206e8c4a5bfaf867b6dc50eba0a3ff262b068bad36788591764d411b17a5385d |
| config-key | config/pyproject.toml | tool.black.line-length | 8-8 | config-key-b4b8455f5111e1f37470cabeaee9c0550928782e27d78a111a282e21297617c6 | 8ec03d9f52a0b74fe69be331ff9c9f5dd1021fd407a31dc8610ad1fb321be563 |
| config-key | config/pyproject.toml | tool.black.target-version | 9-9 | config-key-5ea3d515d64d68fc784f93d7034ed949baec103affca15734fb28ed771a37c5a | ab0dbf4c664d0da0598bb4283964238891601ee7bc7aa030522b8e7b3234e258 |
| config-key | config/pyproject.toml | tool.poetry | 11-12 | config-key-7f46373dd4e868ce12aa0657517a59bfe64b93a6ef20dd83abf4f6f10f0da655 | 0a98ae14882d775557510bff06981af56f1df277b1fad3638171d8a87b7eef97 |
| config-key | config/pyproject.toml | tool.poetry.name | 12-12 | config-key-d4508e88e1d22bfc7664233a98447691a210165b5641ad154cb74b00b2f5accf | 7444e2f603c63cfe8bc432cdc9a1de6deb3a6ddf2e7a44364bd98779957fbfa6 |
| config-key | config/pyproject.toml | tool.ruff | 29-33 | config-key-7e5409c9a68ca145d9dbfa68f1d1694358e265549d704b28acf7d04c4cf1238c | 0aa44f549e706f671b297505d872b71e0472498711723b509ce61a1cfec15863 |
| config-key | config/pyproject.toml | tool.ruff.select | 30-30 | config-key-a5b6b37e1dd775ce60c79b8fcf2d7bfee890f390e3efc3dd87f84aaca833c587 | f6bbb575b5893f36ff9c4a01bc5fbafc381722bf82d5dd0521c16fa5d0464034 |
| config-key | config/pyproject.toml | tool.ruff."quoted.key" | 31-31 | config-key-fddd54a4e1932441c86e4f72cc6764fd36bc81abdc29c656f4c0c3d46cecc58a | 00b2ee5e1770147301dc11c02e3402ad888a4add703dd3b340639200332676da |
| config-key | config/pyproject.toml | tool.ruff.inline | 32-32 | config-key-60259a050e36b1527ae24d81f69463db46298acfa353d4fcaeb887764ac315b9 | ea5eaae5cc4961eb59786bdb4008bc456a67e830ad2f57cf699dcd2ca9fa89d1 |
| config-key | config/pyproject.toml | tool.mypy.overrides | 35-37 | config-key-82e11a14c040de466014b769857383d0e13d168c68b3db8cddccaa0dc54aa680 | 4c3d6016f83da9dbc01e8b8325867d172ba1644193aca7254985f8684dadae35 |
| config-key | config/pyproject.toml | tool.mypy.overrides.[].module | 36-36 | config-key-5812206078cc068219cf3070bbe196872d7a4746c97f05d833c5f8e2a4868c9f | dc847d9e80bdebd7f135016d4352161cc04ce3fb39f624e594c72019041f38bf |
| config-key | config/pyproject.toml | tool.mypy.overrides.[].ignore_missing_imports | 37-37 | config-key-ca806fbe3780523a109f7828b9f311ab45dabb7b02443f2bb5d555b0fd3ee607 | 00b0f5ece38ef9704d39a50c3eb2f76055634adb19b80cb3c1cb43f2e5816304 |
| config-key | config/.env.example | API_KEY | 2-2 | config-key-5135293dc75560ee96ff0cf7f19df85ae07b169b11adf17197792b072a728c40 | 532a8b324b56f72d12726888f5b429aeb2652223a1fe0a62f3272276fd85448a |
| config-key | config/.env.example | DEBUG | 3-3 | config-key-ca095c96cdac6a480e990555e8f0929958cf769020b7e219509aeef6458903f9 | feff1d271aec46166cfd040b9576914eede0cc4e0eaeaaf41bd355d11b56e554 |
| config-key | config/.env.example | MULTI | 4-5 | config-key-4e36d86aa4f3d1010da136c5c6ed94fd4d579966101ea735838fb61cc435b89b | 9ea2c36ddad1f2e58e10e436192aab0307501057de2261d9cc1761f74721f0b6 |
| config-key | config/.env.example | EMPTY | 6-6 | config-key-9a49e9f5e3f7e2f6539b1416ab888a1a608f89660043f8286c2ce23300e0e3a0 | 7819c04858487b8325a083235e0697f271991cb446086084807fec586dc27427 |
| config-key | config/.env.sample | SAMPLE_KEY | 1-1 | config-key-39a250257001d2d8f7a0ab21d0682bdc5282b8f2f09881d5825261f6c707ebbe | 9c2f4c42c61bb441949eb48482cdf241b941f2348796c93e1397962c50d36174 |
| config-key | config/.env.dist | DIST_KEY | 1-1 | config-key-4ab28a0ee06eaeb888d321c85ad4c9185ddffd6ea3c88c0725edad813ae8efee | cf3dd6907d124682d5fcb7f42af64584daeaf66b58998545ec676566e4678385 |
| config-key | config/settings.schema.json | name | 5-5 | config-key-357c3670e32bf2bf7e0081f5bb8f29001008f35be9a1b61cf445578c0a82a13e | c43a1360ce81d4cea4208998ca022223014916ab13e0f3296466d97f60dda124 |
| config-key | config/settings.schema.json | mode | 6-6 | config-key-c8c49024ee367d5d6238cb7723287cd023a70f1e0b6b9643ee63e07a370cd419 | a3086d25cf5bbf7611718aaf6b995c48107c04572650fa2bbb040bee07ca4ee5 |
| config-key | config/settings.schema.json | nested | 7-7 | config-key-cc848345151f9f6e06b810bb28708aa5aa2ff1aefd2eadb0b5b99fe6755f2f9f | c3c564cd167d4dd6100a8cb1a964a7d076a1fe293dfed6816d44b58410b5d7e0 |
| config-key | config/settings.schema.json | nested.flag | 7-7 | config-key-934a1d1e0f1817b4c2684ada54496f720f1d46f4389516ebfff0d0e3a02952c5 | c3c564cd167d4dd6100a8cb1a964a7d076a1fe293dfed6816d44b58410b5d7e0 |
| config-key | config/settings.schema.json | list | 8-8 | config-key-04e9a653491130401fc8a6f3c84c64fa5a3154bf4d61b40f0b0b5bbef8a446a2 | 5a22924254967ec1011acc37b01ecdd30bb7295a9fbab28ac68537dc737c5a3a |
| config-key | config/settings.schema.json | list.[].id | 8-8 | config-key-fc07f88ca9c42c24a0aef87f5e82cea08be7110b512ae89d1e34698a7f52f422 | 5a22924254967ec1011acc37b01ecdd30bb7295a9fbab28ac68537dc737c5a3a |
| config-key | config/settings.schema.json | either | 9-9 | config-key-964785bd5bc30ba37b45f1b00c1bbd8494c5f0fc09bbfda0e6f6ee703b3f222c | 1b44089fcd424f1635c38f8ea114f341587e737924d2a3de1811cb04e51a4e93 |
| config-key | config/settings.schema.json | either.x | 9-9 | config-key-896604e2fe2c7ced77a2279ee7c7f4c8333fc45c4cd065b53a3ac949648521b0 | 1b44089fcd424f1635c38f8ea114f341587e737924d2a3de1811cb04e51a4e93 |
| config-key | config/settings.schema.json | ref | 10-10 | config-key-b5251993edaed1022342bc09eb350cec4a62dc7cbc01757ef5456eec7c9315d2 | 91188317d398fefaee9267ec92b0784938c4d44145b45f6c633050ec662f7375 |
| config-key | config/settings.schema.json | ref.deep | 14-14 | config-key-abce9920c12b88f86c4c233716486129bc8f5f06ca31c0ee409185adebd87d57 | 26185e537504ab0838a741ee0f30e9980cba9083526351cc542785a8f81e9bcf |
| config-key | config/settings.schema.json | broken | 11-11 | config-key-dbc7c0cd8320808c1c69d958cb8f2525f8805e3fc3c3263934f8eb8c6832efac | 438e75f52f15db6ca8f044cc0c94a063311f42201b0032d508e854835ab403d9 |
| config-key | config/other.json | alpha | 3-3 | config-key-5472f3797dc4c74a5420ec61a96589f3940cee5b214e72cc772f0cb9a865851f | f7db1495667689a7c84d7a36f6c6e1d3cd7056dd987c2f7f1be76660a10b4cb9 |
| config-key | config/app.yaml | database | 1-3 | config-key-ff923ea57b00378d31cdc6841b475baf065effd3a9b8fb0e826440cf21c606c0 | 0225b3e9004a838f62c95220b5ce35289a7f0aadf42816a0d6857fb77a736a22 |
| config-key | config/app.yaml | database.host | 2-2 | config-key-45b5f064c1fcfd010090870dddae5550fa5e3930ef27e272d48a56d8cf822283 | 7ab0a69b25c9ffe0040338eb8c293820f8e69aa1b796e3a41a305fb8f6a89864 |
| config-key | config/app.yaml | database.port | 3-3 | config-key-d03a1a9f05370b4ead6f1c37f0665cbfe57f1d10e04424793467d1e35a4ce51d | 7b24181daa1cef4f71aa2a550f52c48343348915a561f655e8ef37fbff99df7e |
| config-key | config/app.yaml | features | 4-7 | config-key-f8cd3d781ec120c04b6c6286222a7ca60a336d41e8466b6849feccaed9fc0e26 | 9038a207426ca976fd714ddd7e9181a3e38206824d662d21a5549d88d7ddead8 |
| config-key | config/app.yaml | features.[].name | 6-6 | config-key-fbfed1166de4487b06e0b249ef497ef93275741c31987776e7e630da85f3e0be | 99c68db317244e68407a3f47768dd03f6e0a78fb75a3f0b3e94d095373bbc70e |
| config-key | config/app.yaml | features.[].enabled | 7-7 | config-key-c0c81d766c8f0859ea3a12a4d38a9985b47ea7794a8e8f520859a9005fb524fd | 2eb7423d2e331462e1a7d183fc0b6edf2aa2ac51648a9b7b46efb41f92c2c4e0 |
| config-key | config/app.yaml | flow | 8-8 | config-key-81b2354d6bd1309b9a2d19edcadf1e3022f716887e1c89c0ff42170af0d5004b | e7830dd00ae9171b2cedd3987ab5d012bbdfe77e6bc12609570cbacafdb17bd4 |
| config-key | config/app.yaml | note | 10-11 | config-key-0c7f8cd425583a392490479ee02a3b385d329868050b16a4b67dacac45165298 | a574bb78dcbf5ab53c6bd087796e65f155ee09a3a6800058ad0ca3b2a5072af2 |
