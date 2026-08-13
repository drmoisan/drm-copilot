# Python batch 3 policy gate

Timestamp: 2026-08-12T10:34:40.539Z

Command: `$paths=@('scripts/dev_tools/resolve_codex_deployment.py','scripts/dev_tools/resolve_codex_topology.py','tests/scripts/dev_tools/test_resolve_codex_deployment.py','tests/scripts/dev_tools/test_resolve_codex_topology.py'); $rows=foreach($path in $paths){[pscustomobject]@{Path=$path;Lines=(Get-Content -LiteralPath $path).Count}}; $rows|Format-Table -AutoSize; if(($rows|Where-Object Lines -GT 500).Count -gt 0){exit 1}`

EXIT_CODE: 0

Output Summary: Physical line counts were 362, 414, 263, and 272 respectively; all 4 files are at or below 500 lines.

Command:

```powershell
@'
import ast
from pathlib import Path
paths=[Path('scripts/dev_tools/resolve_codex_deployment.py'),Path('scripts/dev_tools/resolve_codex_topology.py')]
missing=[]; counts={}
for path in paths:
 tree=ast.parse(path.read_text(encoding='utf-8'),filename=str(path))
 nodes=[n for n in ast.walk(tree) if isinstance(n,(ast.ClassDef,ast.FunctionDef,ast.AsyncFunctionDef))]
 counts[str(path)]=len(nodes)
 missing.extend(f'{path}:{n.lineno}:{n.name}' for n in nodes if ast.get_docstring(n,clean=False) is None)
print(f'documented_callables={sum(counts.values())}; per_file={counts}; missing={len(missing)}')
if missing:
 print('\n'.join(missing)); raise SystemExit(1)
'@ | poetry run python -
```

EXIT_CODE: 0

Output Summary: The AST audit found 23/23 production callables and classes documented: 11 deployment resolver nodes and 12 topology resolver nodes; missing=0.

Command: `$paths=@('scripts/dev_tools/resolve_codex_deployment.py','scripts/dev_tools/resolve_codex_topology.py'); $comments=Select-String -Path $paths -Pattern '^\s*#'; "intent_comment_count=$($comments.Count)"; $numbered=Select-String -Path $paths -Pattern '#\s*NOTE\s+\d+:' -CaseSensitive:$false; "numbered_note_findings=$($numbered.Count)"; if($numbered.Count -gt 0){exit 1}`

EXIT_CODE: 0

Output Summary: Manual iteration, comprehension, branch, and multi-step-block audit enumerated 13 intent comments and 0 numbered-note findings.

Command: `$paths=@('scripts/dev_tools/resolve_codex_deployment.py','scripts/dev_tools/resolve_codex_topology.py','tests/scripts/dev_tools/test_resolve_codex_deployment.py','tests/scripts/dev_tools/test_resolve_codex_topology.py'); $added=git diff --unified=0 -- $paths; $hits=$added|Select-String -Pattern '^\+.*(#\s*(noqa|type:\s*ignore|pyright:\s*ignore|fmt:|nosec)|pragma:\s*no\s*cover)' -CaseSensitive:$false; "added_suppression_findings=$($hits.Count)"; if($hits.Count -gt 0){$hits.Line;exit 1}`

EXIT_CODE: 0

Output Summary: added_suppression_findings=0.

Command: `$production=@('scripts/dev_tools/resolve_codex_deployment.py','scripts/dev_tools/resolve_codex_topology.py'); $tests=@('tests/scripts/dev_tools/test_resolve_codex_deployment.py','tests/scripts/dev_tools/test_resolve_codex_topology.py'); $badProduction=@($production|?{$_ -notlike 'scripts/dev_tools/*.py'});$badTests=@($tests|?{$_ -notlike 'tests/scripts/dev_tools/test_*.py'});$tempHits=Select-String -Path $tests -Pattern '\b(tmp_path|tmpdir|tempfile|TemporaryDirectory|NamedTemporaryFile|mkstemp)\b';"production_location_errors=$($badProduction.Count); test_location_errors=$($badTests.Count); temporary_file_findings=$($tempHits.Count)";if($badProduction.Count+$badTests.Count+$tempHits.Count -gt 0){exit 1}`

EXIT_CODE: 0

Output Summary: production_location_errors=0; test_location_errors=0; temporary_file_findings=0.

Command: `$expected=@('scripts/dev_tools/resolve_codex_deployment.py','scripts/dev_tools/resolve_codex_topology.py','tests/scripts/dev_tools/test_resolve_codex_deployment.py','tests/scripts/dev_tools/test_resolve_codex_topology.py')|Sort-Object;$actual=@(git diff --name-only -- $expected)|Sort-Object;$delta=@(Compare-Object $expected $actual);"expected_changed_paths=$($expected.Count); actual_changed_paths=$($actual.Count); path_set_delta=$($delta.Count)";$actual;if($delta.Count -gt 0){$delta|Format-Table;exit 1};git diff --check -- $expected`

EXIT_CODE: 0

Output Summary: expected_changed_paths=4; actual_changed_paths=4; path_set_delta=0; `git diff --check` reported no whitespace errors.

Acceptance result: PASS. The exact four-file batch respects documentation, suppression, location, no-temporary-file, changed-file, whitespace, and 500-line policies.
