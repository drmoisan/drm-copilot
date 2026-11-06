"""Request validation, analyzer dispatch and canonical output of the native helper.

main reads one JSON request from a binary stream and writes one ASCII JSON object: a
response (exit code 0), or a protocol error (2 for an invalid request, 3 for an internal
error, 4 for an interpreter below the 3.11 floor). Error messages never quote source
text.
"""

from __future__ import annotations

import json
import sys
from dataclasses import dataclass
from typing import TYPE_CHECKING, BinaryIO, cast

from docs_python_native.architecture import analyze_architecture
from docs_python_native.cli import ConsoleScript, analyze_cli
from docs_python_native.imports import AnalyzedFile, build_tables
from docs_python_native.public_api import analyze_public_api
from docs_python_native.routes import analyze_http
from docs_python_native.source import PARSE_OK, normalize_source, parse_module

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence

    from docs_python_native.facts import AnalyzerOutput

PROTOCOL_VERSION = 1
FLOOR = (3, 11)
MAX_FILES = 50000
MAX_FILE_BYTES = 1048576
ANALYZERS = ("python-architecture", "python-cli", "python-http", "python-public-api")
EXIT_OK, EXIT_INVALID, EXIT_INTERNAL, EXIT_FLOOR = 0, 2, 3, 4
_REQUEST_KEYS = frozenset(
    {
        "protocol_version",
        "analyzers",
        "source_roots",
        "console_scripts",
        "files",
        "limits",
    }
)
_SCRIPT_KEYS = frozenset({"name", "table", "path", "target"})
_FILE_KEYS = frozenset({"path", "text"})
_LIMIT_KEYS = frozenset({"max_files", "max_file_bytes"})


class RequestError(ValueError):
    """An invalid request; the message names the defect without quoting source text.

    Raised only by parse_request and its helpers; main maps it to exit code 2 and the
    request-invalid error object.
    """


@dataclass(frozen=True)
class Request:
    """A validated request, as parse_request returns it.

    Attributes:
        analyzers: The requested analyzer identifiers (unique, all known).
        source_roots: The configured source roots.
        console_scripts: The console scripts read from pyproject.toml by the adapter.
        files: (path, text) pairs with unique paths, each within the byte limit.
    """

    analyzers: tuple[str, ...]
    source_roots: tuple[str, ...]
    console_scripts: tuple[ConsoleScript, ...]
    files: tuple[tuple[str, str], ...]


def _reject_duplicates(pairs: list[tuple[str, object]]) -> dict[str, object]:
    """Build a JSON object while rejecting a repeated key (json object_pairs_hook).

    Args:
        pairs: The key and value pairs of one JSON object in document order.

    Returns:
        The object as a dict.

    Raises:
        RequestError: A key occurs twice.
    """
    result: dict[str, object] = {}
    # Insert pairs in order; the first repeat makes the whole request invalid.
    for key, value in pairs:
        if key in result:
            raise RequestError("the request repeats an object key")
        result[key] = value
    return result


def _reject_constant(_name: str) -> object:
    """Reject NaN and Infinity literals (json parse_constant hook).

    Args:
        _name: The constant text ("NaN", "Infinity" or "-Infinity"); unused.

    Returns:
        Never returns.

    Raises:
        RequestError: Always.
    """
    raise RequestError("the request holds a non-finite number")


def _object(value: object, keys: frozenset[str], where: str) -> dict[str, object]:
    """Require a JSON object with exactly the given key set.

    Args:
        value: The decoded value.
        keys: The required key set (closed: no key may be missing or extra).
        where: The request location named in an error message.

    Returns:
        The object with string keys.

    Raises:
        RequestError: The value is not an object or its key set differs.
    """
    if not isinstance(value, dict):
        raise RequestError(f"{where} must be an object")
    items = cast("dict[object, object]", value)
    # Normalize keys to str so the key-set comparison is exact.
    found: dict[str, object] = {str(k): v for k, v in items.items()}
    if frozenset(found) != keys:
        raise RequestError(f"{where} must have exactly the keys {sorted(keys)}")
    return found


def _list(value: object, where: str) -> list[object]:
    """Require a JSON array.

    Args:
        value: The decoded value.
        where: The request location named in an error message.

    Returns:
        A copy of the array.

    Raises:
        RequestError: The value is not an array.
    """
    if not isinstance(value, list):
        raise RequestError(f"{where} must be an array")
    return list(cast("list[object]", value))


def _string(value: object, where: str) -> str:
    """Require a JSON string.

    Args:
        value: The decoded value.
        where: The request location named in an error message.

    Returns:
        The string.

    Raises:
        RequestError: The value is not a string.
    """
    if not isinstance(value, str):
        raise RequestError(f"{where} must be a string")
    return value


def _integer(value: object, where: str, maximum: int) -> int:
    """Require an integer (not a boolean) from 1 to a maximum.

    Args:
        value: The decoded value.
        where: The request location named in an error message.
        maximum: The largest accepted value.

    Returns:
        The integer.

    Raises:
        RequestError: The value is not an integer in range.
    """
    if (
        not isinstance(value, int)
        or isinstance(value, bool)
        or not 1 <= value <= maximum
    ):
        raise RequestError(f"{where} must be an integer from 1 to {maximum}")
    return value


def parse_request(data: bytes) -> Request:
    """Decode and validate one request.

    Args:
        data: The raw request bytes from standard input.

    Returns:
        The validated Request.

    Raises:
        RequestError: The bytes are not UTF-8 JSON, or any key, type, version, limit or
            uniqueness rule is violated.
    """
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError as error:
        raise RequestError("the request is not UTF-8") from error
    try:
        value: object = json.loads(
            text, object_pairs_hook=_reject_duplicates, parse_constant=_reject_constant
        )
    except json.JSONDecodeError as error:
        raise RequestError("the request is not JSON") from error
    root = _object(value, _REQUEST_KEYS, "the request")
    version = root["protocol_version"]
    if (
        not isinstance(version, int)
        or isinstance(version, bool)
        or version != PROTOCOL_VERSION
    ):
        raise RequestError("protocol_version must be 1")
    limits = _object(root["limits"], _LIMIT_KEYS, "limits")
    max_files = _integer(limits["max_files"], "limits.max_files", MAX_FILES)
    max_bytes = _integer(
        limits["max_file_bytes"], "limits.max_file_bytes", MAX_FILE_BYTES
    )
    # Every analyzer entry must be a string; uniqueness and membership follow.
    analyzers = [
        _string(a, "analyzers[]") for a in _list(root["analyzers"], "analyzers")
    ]
    if not analyzers or len(set(analyzers)) != len(analyzers):
        raise RequestError("analyzers must be a non-empty array of unique identifiers")
    if any(a not in ANALYZERS for a in analyzers):
        raise RequestError("analyzers holds an unknown identifier")
    # Every source root must be a string.
    roots = [
        _string(r, "source_roots[]")
        for r in _list(root["source_roots"], "source_roots")
    ]
    scripts: list[ConsoleScript] = []
    # Validate each console-script entry against its closed key set.
    for item in _list(root["console_scripts"], "console_scripts"):
        entry = _object(item, _SCRIPT_KEYS, "console_scripts[]")
        # The name, table and path fields must all be strings.
        fields = [
            _string(entry[k], f"console_scripts[].{k}")
            for k in ("name", "table", "path")
        ]
        target = _string(entry["target"], "console_scripts[].target")
        scripts.append(ConsoleScript(fields[0], fields[1], fields[2], target))
    files: list[tuple[str, str]] = []
    raw_files = _list(root["files"], "files")
    if len(raw_files) > max_files:
        raise RequestError("files holds more entries than limits.max_files")
    # Validate each file entry and its UTF-8 size against the byte limit.
    for item in raw_files:
        entry = _object(item, _FILE_KEYS, "files[]")
        path = _string(entry["path"], "files[].path")
        source = _string(entry["text"], "files[].text")
        if len(source.encode("utf-8", "surrogatepass")) > max_bytes:
            raise RequestError("a file text is larger than limits.max_file_bytes")
        files.append((path, source))
    if len({path for path, _text in files}) != len(files):
        raise RequestError("files repeats a path")
    return Request(tuple(analyzers), tuple(roots), tuple(scripts), tuple(files))


def run_request(request: Request) -> dict[str, object]:
    """Run the selected analyzers and return the response object.

    Every file is normalized and parsed once; files that parse get binding tables and
    are analyzed; the binding diagnostics of each file are reported under every
    analyzer. Facts are sorted by their canonical JSON and diagnostics are de-duplicated
    and sorted, so the output does not depend on request order.

    Args:
        request: The validated request.

    Returns:
        {protocol_version, files}, with one entry per request path in path order.
    """
    statuses: dict[str, str] = {}
    parsed_files: list[AnalyzedFile] = []
    # Parse each file once; only parsed files are analyzed.
    for path, text in request.files:
        parsed = parse_module(normalize_source(text))
        statuses[path] = parsed.status
        if parsed.status == PARSE_OK:
            parsed_files.append(AnalyzedFile(path, parsed, build_tables(parsed)))
    roots = list(request.source_roots)
    outputs: list[AnalyzerOutput] = []
    # Run each requested analyzer in identifier order.
    for analyzer in sorted(request.analyzers):
        # Dispatch table: python-cli needs the console scripts, the other analyzers
        # take files and roots; parse_request admitted only the four identifiers, so
        # the final branch is python-architecture.
        if analyzer == "python-cli":
            output = analyze_cli(parsed_files, roots, list(request.console_scripts))
        elif analyzer == "python-http":
            output = analyze_http(parsed_files, roots)
        elif analyzer == "python-public-api":
            output = analyze_public_api(parsed_files, roots)
        else:
            output = analyze_architecture(parsed_files, roots)
        # Report the shared binding diagnostics under this analyzer too.
        for analyzed in parsed_files:
            # Each binding diagnostic of the file is copied into this output.
            for diagnostic in analyzed.tables.diagnostics:
                output.add_diagnostic(analyzed.path, diagnostic.code, diagnostic.line)
        outputs.append(output)
    files: list[dict[str, object]] = []
    # Assemble one response entry per path: sorted facts and unique sorted diagnostics.
    for path in sorted(statuses):
        # Gather this path's facts from every analyzer output.
        facts = [f.to_json() for o in outputs for f in o.facts.get(path, [])]
        facts.sort(key=lambda fact: json.dumps(fact, sort_keys=True))
        # De-duplicate (analyzer, code, line) triples across analyzer outputs.
        diagnostics = sorted(
            {
                (o.analyzer_id, d.code, d.line)
                for o in outputs
                for d in o.diagnostics.get(path, [])
            }
        )
        files.append(
            {
                "path": path,
                "status": statuses[path],
                "facts": facts,
                # Helper diagnostics never block; the adapter maps them to warnings.
                "diagnostics": [
                    {"analyzer_id": a, "code": c, "line": n, "blocking": False}
                    for a, c, n in diagnostics
                ],
            }
        )
    return {"protocol_version": PROTOCOL_VERSION, "files": files}


def encode(value: dict[str, object]) -> bytes:
    """Serialize a response or error object as canonical ASCII JSON bytes.

    Args:
        value: The object to write.

    Returns:
        Sorted-key, compact, ASCII-escaped JSON bytes, independent of the code page.
    """
    text = json.dumps(value, ensure_ascii=True, sort_keys=True, separators=(",", ":"))
    return text.encode("ascii")


def error_object(code: str, message: str) -> dict[str, object]:
    """Return a protocol error object.

    Args:
        code: The error code (request-invalid, internal-error, version-below-floor).
        message: A message that never quotes source text.

    Returns:
        {protocol_version, error: {code, message}}.
    """
    return {
        "protocol_version": PROTOCOL_VERSION,
        "error": {"code": code, "message": message},
    }


def main(
    stdin: BinaryIO,
    stdout: BinaryIO,
    *,
    version_info: Sequence[object] = sys.version_info,
    run: Callable[[Request], dict[str, object]] = run_request,
) -> int:
    """Read one request, write one response or error object, and return the exit code.

    Args:
        stdin: The binary request stream.
        stdout: The binary response stream; exactly one object is written.
        version_info: The interpreter version; tests inject older versions.
        run: The request runner; tests inject a failing runner.

    Returns:
        EXIT_OK, EXIT_INVALID for a RequestError, EXIT_INTERNAL for any other
        exception, or EXIT_FLOOR for an interpreter below FLOOR.
    """
    if tuple(version_info[:2]) < FLOOR:
        stdout.write(
            encode(
                error_object("version-below-floor", "Python 3.11 or later is required")
            )
        )
        return EXIT_FLOOR
    try:
        request = parse_request(stdin.read())
    except RequestError as error:
        stdout.write(encode(error_object("request-invalid", str(error))))
        return EXIT_INVALID
    try:
        response = run(request)
    except Exception as error:  # every internal failure maps to exit code 3
        message = "internal error: " + type(error).__name__
        stdout.write(encode(error_object("internal-error", message)))
        return EXIT_INTERNAL
    stdout.write(encode(response))
    return EXIT_OK
