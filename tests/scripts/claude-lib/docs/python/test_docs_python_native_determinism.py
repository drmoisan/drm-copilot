"""Determinism tests (S20): identical requests give identical bytes in any order."""

import io
import json

from docs_python_native.protocol import main

E_ACUTE = chr(0xE9)
FILES = [
    {"path": "src/pkg/__init__.py", "text": "from . import api\n"},
    {
        "path": "src/pkg/api.py",
        "text": "import click\n@click.command()\ndef go():\n    pass\n",
    },
    {
        "path": "src/pkg/web.py",
        "text": (
            "from fastapi import FastAPI\napp = FastAPI()\n@app.get('/x')\ndef x():\n"
            "    pass\n"
        ),
    },
    {
        "path": "src/pkg/t.py",
        "text": (
            "import typer\napp = typer.Typer()\n@app.command()\ndef run(n: int = 1):\n"
            "    pass\n"
        ),
    },
]


def _run(files: list[dict[str, str]]) -> bytes:
    """Run the helper main over the given files and return the raw response bytes."""
    request = {
        "protocol_version": 1,
        "analyzers": [
            "python-public-api",
            "python-http",
            "python-cli",
            "python-architecture",
        ],
        "source_roots": ["src"],
        "console_scripts": [],
        "files": files,
        "limits": {"max_files": 50000, "max_file_bytes": 1048576},
    }
    stdout = io.BytesIO()
    assert main(io.BytesIO(json.dumps(request).encode("utf-8")), stdout) == 0
    return stdout.getvalue()


def test_same_request_twice_gives_identical_bytes() -> None:
    """Scenario: same request twice gives identical bytes."""
    assert _run(FILES) == _run(FILES)


def test_every_rotation_and_the_reversal_give_identical_bytes() -> None:
    """Scenario: every rotation and the reversal give identical bytes."""
    baseline = _run(FILES)
    orders = [FILES[i:] + FILES[:i] for i in range(len(FILES))] + [
        list(reversed(FILES))
    ]
    # Every reordering of the request files must give the baseline bytes.
    for order in orders:
        assert _run(order) == baseline


def test_non_ascii_identifier_gives_ascii_bytes() -> None:
    """Scenario: non ascii identifier gives ascii bytes."""
    cafe = "caf" + E_ACUTE
    text = f"def {cafe}():\n    pass\n{E_ACUTE}t{E_ACUTE} = 1\n"
    output = _run([{"path": "src/m.py", "text": text}])
    assert all(byte < 0x80 for byte in output)
    declarations = [f["declaration"] for f in json.loads(output)["files"][0]["facts"]]
    assert "m." + cafe in declarations
