# R5 documentation Batch B expected-red receipt

Timestamp: 2026-08-12T16:24:16.7580809Z

Command:

```powershell
$R5Checker = @'
import ast
import hashlib
import sys
from pathlib import Path

CONTRACT_FIELDS = ("Args:", "Returns:", "Raises:", "Side Effects:")
ADJACENCY_NODES = (
    ast.For,
    ast.AsyncFor,
    ast.While,
    ast.ListComp,
    ast.DictComp,
    ast.SetComp,
    ast.GeneratorExp,
)
READINESS_PATH = "scripts/dev_tools/validate_parallel_codex_readiness.py"
READINESS_GENERATOR = '(part in (".", "..") for part in path.parts)'


def is_docstring_statement(node: ast.stmt) -> bool:
    return (
        isinstance(node, ast.Expr)
        and isinstance(node.value, ast.Constant)
        and isinstance(node.value.value, str)
    )


class StripDocstrings(ast.NodeTransformer):
    def strip(self, node: ast.AST) -> ast.AST:
        self.generic_visit(node)
        body = getattr(node, "body", None)
        if isinstance(body, list) and body and is_docstring_statement(body[0]):
            body.pop(0)
        return node

    visit_Module = strip
    visit_ClassDef = strip
    visit_FunctionDef = strip
    visit_AsyncFunctionDef = strip


paths: list[str] = []
owners: list[str] = []
allow_guard = False
for argument in sys.argv[1:]:
    if argument.startswith("--owner="):
        owners.append(argument.removeprefix("--owner="))
    elif argument == "--allow-readiness-guard-adjudication":
        allow_guard = True
    else:
        paths.append(argument)

findings: list[str] = []
guard_seen = False
for path_text in paths:
    path = Path(path_text)
    source = path.read_text(encoding="utf-8")
    source_lines = source.splitlines()
    tree = ast.parse(source, filename=path_text)
    parents = {
        child: parent
        for parent in ast.walk(tree)
        for child in ast.iter_child_nodes(parent)
    }
    callables = sorted(
        (
            node
            for node in ast.walk(tree)
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
        ),
        key=lambda node: (node.lineno, node.col_offset),
    )
    contract_failures = 0
    for node in callables:
        docstring = ast.get_docstring(node, clean=False) or ""
        missing = [field for field in CONTRACT_FIELDS if field not in docstring]
        if missing:
            contract_failures += 1
            findings.append(
                f"CALLABLE {path_text}:{node.name}@{node.lineno} missing={','.join(missing)}"
            )

    adjacency_nodes = sorted(
        (node for node in ast.walk(tree) if isinstance(node, ADJACENCY_NODES)),
        key=lambda node: (node.lineno, node.col_offset, type(node).__name__),
    )
    adjacency_failures = 0
    adjudicated = 0
    for node in adjacency_nodes:
        segment = " ".join((ast.get_source_segment(source, node) or "").split())
        parent = parents.get(node)
        is_guard = (
            path.as_posix() == READINESS_PATH
            and isinstance(node, ast.GeneratorExp)
            and segment == READINESS_GENERATOR
            and isinstance(parent, ast.Call)
            and isinstance(parent.func, ast.Name)
            and parent.func.id == "any"
            and len(parent.args) == 1
            and parent.args[0] is node
            and not parent.keywords
        )
        if is_guard and allow_guard:
            guard_seen = True
            adjudicated += 1
            print(
                "ADJUDICATED "
                f"{path_text}:audit-line-231/current-line-{node.lineno} GeneratorExp "
                "reason=trivial generator guard is a policy false positive; no R5 change authorized"
            )
            continue
        previous = source_lines[node.lineno - 2].strip() if node.lineno > 1 else ""
        if not previous.startswith("#") or not previous.removeprefix("#").strip():
            adjacency_failures += 1
            findings.append(
                f"ADJACENCY {path_text}:{type(node).__name__}@{node.lineno} missing=immediate-intent-comment"
            )

    semantic_tree = StripDocstrings().visit(ast.parse(source, filename=path_text))
    semantic_dump = ast.dump(ast.fix_missing_locations(semantic_tree), include_attributes=False)
    semantic_sha = hashlib.sha256(semantic_dump.encode("utf-8")).hexdigest().upper()
    print(
        f"SUMMARY {path_text} callables={len(callables)} "
        f"contract_failures={contract_failures} adjacency_nodes={len(adjacency_nodes)} "
        f"adjacency_failures={adjacency_failures} adjudicated={adjudicated}"
    )
    print(f"SEMANTIC_SHA256 {path_text} {semantic_sha}")

for owner_text in owners:
    owner = Path(owner_text)
    owner_sha = hashlib.sha256(owner.read_bytes()).hexdigest().upper()
    print(f"OWNER_SHA256 {owner_text} {owner_sha}")

if allow_guard and not guard_seen:
    findings.append("ADJUDICATION readiness audit-line-231 guard was not found exactly")
for finding in findings:
    print(f"FAIL {finding}")
raise SystemExit(1 if findings else 0)
'@
$R5Checker | poetry run python - scripts/dev_tools/validate_parallel_codex_readiness.py --owner=tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py --allow-readiness-guard-adjudication
```

EXIT_CODE: 1

Output Summary:

- `scripts/dev_tools/validate_parallel_codex_readiness.py`: 12 callables, 12 incomplete contracts, 16 total iteration nodes, 2 actionable adjacency failures, and 1 adjudicated false positive.
- Incomplete callables: `_is_non_empty_string@88`, `_mixed_state_paths@93`, `validate_parallel_state_is_standalone@112`, `validate_parallel_launch_provenance@123`, `validate_zero_lost_ledger@191`, `_guarded_path@226`, `_readiness_item_paths@236`, `_validate_kickoff_identity@250`, `_validate_status@296`, `_receipt_document@325`, `_validate_referenced_receipts@343`, and `validate_parallel_codex_checkpoint_readiness@420`. Each was missing `Args:`, `Returns:`, `Raises:`, and `Side Effects:`.
- Actionable adjacency failures: `ListComp@160` and `ListComp@271`.
- Adjudication: the `GeneratorExp` at audit/current line 231 had the exact segment `(part in (".", "..") for part in path.parts)`. Its parent was verified as an `ast.Call` to the name `any`, with that generator as its sole positional argument and no keywords. It is therefore the single authorized trivial generator-guard false positive and was not treated as an actionable failure.
- `SEMANTIC_SHA256 scripts/dev_tools/validate_parallel_codex_readiness.py BE8753F4922604A5B0894E455C4A081C88973ADAB2C6401DB24B924A5AD1933B`
- `OWNER_SHA256 tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py 55AA3400137E160BB00DDB11973529F551EF66CDD2C57DB84AB621923794347C`
- Pre/post SHA-256 verification confirmed both files remained byte-identical. The production file SHA-256 remained `0872968961A70CD736082E691388FC2084E4D91C9140D184E532AB5264E59C24`.

Acceptance result: PASS. The expected-red checker attributed all 12 incomplete callable contracts, exactly two actionable list-comprehension gaps, and exactly one structurally verified generator-guard adjudication before any Batch B production edit.
