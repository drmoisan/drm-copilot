# Python batch 1 policy gate

Timestamp: 2026-08-12T10:08:42.357Z

Command: `$paths=@('scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py','scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py','scripts/dev_tools/parallel_codex_readiness_filesystem.py','tests/scripts/dev_tools/test_parallel_completion_receipts.py','tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py','tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py'); $rows=foreach($path in $paths){[pscustomobject]@{Path=$path;Lines=(Get-Content -LiteralPath $path).Count}}; $rows | Format-Table -AutoSize; if(($rows|Where-Object Lines -GT 500).Count -gt 0){exit 1}`

EXIT_CODE: 0

Output Summary: Physical line counts were 361, 443, 484, 290, 332, and 415 respectively; all 6 files are at or below 500 lines.

Command:

```powershell
@'
import ast
from pathlib import Path

paths = [
    Path("scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py"),
    Path("scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py"),
    Path("scripts/dev_tools/parallel_codex_readiness_filesystem.py"),
]
missing = []
counts = {}
for path in paths:
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    nodes = [
        node
        for node in ast.walk(tree)
        if isinstance(node, (ast.ClassDef, ast.FunctionDef, ast.AsyncFunctionDef))
    ]
    counts[str(path)] = len(nodes)
    missing.extend(
        f"{path}:{node.lineno}:{node.name}"
        for node in nodes
        if ast.get_docstring(node, clean=False) is None
    )
print(f"documented_callables={sum(counts.values())}; per_file={counts}; missing={len(missing)}")
if missing:
    print("\n".join(missing))
    raise SystemExit(1)
'@ | poetry run python -
```

EXIT_CODE: 0

Output Summary: The AST audit found 46/46 production callables and classes documented: 11 completion-receipt nodes, 11 mutation-receipt nodes, and 24 readiness-filesystem nodes; missing=0.

Command: `$paths=@('scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py','scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py','scripts/dev_tools/parallel_codex_readiness_filesystem.py'); $comments=Select-String -Path $paths -Pattern '^\s*#'; $comments | ForEach-Object { '{0}:{1}:{2}' -f $_.Path.Replace((Get-Location).Path + '\',''),$_.LineNumber,$_.Line.Trim() }; "intent_comment_count=$($comments.Count)"`

EXIT_CODE: 0

Output Summary: Manual decision/iteration/block audit enumerated 52 intent comments across the exact three production paths. Every loop/comprehension, non-trivial branch, and multi-step block has an accurate adjacent intent comment; numbered notes=0.

Command: `$paths=@('scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py','scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py','scripts/dev_tools/parallel_codex_readiness_filesystem.py','tests/scripts/dev_tools/test_parallel_completion_receipts.py','tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py','tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py'); $added=git diff --unified=0 -- $paths; $hits=$added | Select-String -Pattern '^\+.*(#\s*(noqa|type:\s*ignore|pyright:\s*ignore|fmt:|nosec)|pragma:\s*no\s*cover)' -CaseSensitive:$false; "added_suppression_findings=$($hits.Count)"; if($hits.Count -gt 0){$hits.Line; exit 1}`

EXIT_CODE: 0

Output Summary: added_suppression_findings=0.

Command: `$production=@('scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py','scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py','scripts/dev_tools/parallel_codex_readiness_filesystem.py'); $tests=@('tests/scripts/dev_tools/test_parallel_completion_receipts.py','tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py','tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py'); $badProduction=@($production|Where-Object{$_ -notlike 'scripts/dev_tools/*.py'}); $badTests=@($tests|Where-Object{$_ -notlike 'tests/scripts/dev_tools/test_*.py'}); $tempHits=Select-String -Path $tests -Pattern '\b(tmp_path|tmpdir|tempfile|TemporaryDirectory|NamedTemporaryFile|mkstemp)\b'; "production_location_errors=$($badProduction.Count); test_location_errors=$($badTests.Count); temporary_file_findings=$($tempHits.Count)"; if($badProduction.Count+$badTests.Count+$tempHits.Count -gt 0){exit 1}`

EXIT_CODE: 0

Output Summary: production_location_errors=0; test_location_errors=0; temporary_file_findings=0.

Command: `$expected=@('scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py','scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py','scripts/dev_tools/parallel_codex_readiness_filesystem.py','tests/scripts/dev_tools/test_parallel_completion_receipts.py','tests/scripts/dev_tools/test_parallel_mutation_receipt_bound_runtime.py','tests/scripts/dev_tools/test_parallel_codex_readiness_filesystem.py')|Sort-Object; $actual=@(git diff --name-only -- $expected)|Sort-Object; $delta=@(Compare-Object $expected $actual); "expected_changed_paths=$($expected.Count); actual_changed_paths=$($actual.Count); path_set_delta=$($delta.Count)"; $actual; if($delta.Count -gt 0){$delta|Format-Table; exit 1}; git diff --check -- $expected`

EXIT_CODE: 0

Output Summary: expected_changed_paths=6; actual_changed_paths=6; path_set_delta=0; `git diff --check` reported no whitespace errors.

Acceptance result: PASS. The six-file batch respects documentation, suppression, location, no-temporary-file, changed-file, whitespace, and 500-line policies.
