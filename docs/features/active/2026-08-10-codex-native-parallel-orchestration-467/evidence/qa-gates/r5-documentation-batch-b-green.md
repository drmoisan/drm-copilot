# R5 documentation Batch B green gate

Timestamp: 2026-08-12T16:31:39.7330077Z

## Restart receipt

The first attempt ran Black successfully with both files unchanged, then Ruff failed with 12 `E501` findings on the 12 line-neutral contract docstrings. No later gate ran. The docstring lines were shortened within the P13-T14 documentation-only allowlist, with semantic digest and line count unchanged, and the sequence restarted from Black.

Command: `poetry run black scripts/dev_tools/validate_parallel_codex_readiness.py tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py`

EXIT_CODE: 0

Output Summary: Black left both files unchanged in the accepted restarted pass.

Command: `poetry run ruff check scripts/dev_tools/validate_parallel_codex_readiness.py tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py`

EXIT_CODE: 0

Output Summary: Ruff reported all checks passed.

Command: `poetry run pyright scripts/dev_tools/validate_parallel_codex_readiness.py tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py`

EXIT_CODE: 0

Output Summary: Pyright reported 0 errors, 0 warnings, and 0 informations.

Command: `poetry run pytest -o "addopts=" -q tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py`

EXIT_CODE: 0

Output Summary: 20 tests passed in 0.08 seconds.

## Exact R5 checker

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

EXIT_CODE: 0

Output Summary:

- 12 callables, 0 contract failures, 16 total iteration nodes, 0 actionable adjacency failures, and exactly 1 adjudication.
- The exact audit-line-231 generator guard was structurally verified at current line 232 as the sole positional argument to `any(...)`, with no keywords. It remained unchanged.
- `SEMANTIC_SHA256 scripts/dev_tools/validate_parallel_codex_readiness.py BE8753F4922604A5B0894E455C4A081C88973ADAB2C6401DB24B924A5AD1933B`, equal to P13-T13.
- `OWNER_SHA256 tests/scripts/dev_tools/test_validate_parallel_codex_readiness.py 55AA3400137E160BB00DDB11973529F551EF66CDD2C57DB84AB621923794347C`, equal to P13-T13.

Acceptance result: PASS. The restarted Black, Ruff, Pyright, focused Pytest, and exact checker sequence completed without interruption; semantic and owner digests remained unchanged.
