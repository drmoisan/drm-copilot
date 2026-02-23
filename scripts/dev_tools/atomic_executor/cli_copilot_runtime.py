"""Copilot invocation runtime helpers for atomic executor CLI."""

from __future__ import annotations

import codecs
import contextlib
import json
import os
import queue
import subprocess
import sys
import threading
import time
from pathlib import Path
from typing import IO, cast

from scripts.dev_tools.atomic_executor.copilot_runner import CopilotRunResult

DEFAULT_COPILOT_AGENT = "atomic_executor"
DEFAULT_COPILOT_ALLOW_SHELL = True
DEFAULT_COPILOT_ALLOW_ALL_PATHS = True
DEFAULT_COPILOT_ALLOW_ALL_URLS = False
DEFAULT_COPILOT_TRUST_WORKSPACE = True

COPILOT_PERMISSION_DENIED_SUBSTRING = (
    "Permission denied and could not request permission from user"
)


class CopilotPermissionDeniedError(RuntimeError):
    """Raised when Copilot output indicates an approval/permission dead-end."""


def run_copilot(
    *,
    workspace: Path,
    prompt_text: str,
    log_file: Path,
    task_id: str,
    preferred_model: str | None,
    run_id: str,
    resume_session: bool = False,
    is_first_task: bool = True,
    allow_all_paths: bool = DEFAULT_COPILOT_ALLOW_ALL_PATHS,
    allow_all_urls: bool = DEFAULT_COPILOT_ALLOW_ALL_URLS,
    allow_shell: bool = DEFAULT_COPILOT_ALLOW_SHELL,
    trust_workspace: bool = DEFAULT_COPILOT_TRUST_WORKSPACE,
    _idle_timeout_seconds: float | None = None,
    _output_tail_bytes: int | None = None,
) -> CopilotRunResult:
    """Invoke GitHub Copilot CLI with prompt and tool permissions."""

    output_tail_bytes = 4096 if _output_tail_bytes is None else _output_tail_bytes
    if output_tail_bytes < 0:
        output_tail_bytes = 0

    def normalize_copilot_model(model: str) -> str:
        """Normalize a human-facing model name into a Copilot CLI --model choice."""
        raw = model.strip()
        if not raw:
            raise ValueError("Model name cannot be empty")

        known_choices = {
            "claude-sonnet-4.5",
            "claude-haiku-4.5",
            "claude-opus-4.5",
            "claude-sonnet-4",
            "gpt-5.1-codex-max",
            "gpt-5.1-codex",
            "gpt-5.2-codex",
            "gpt-5.2",
            "gpt-5.1",
            "gpt-5",
            "gpt-5.1-codex-mini",
            "gpt-5-mini",
            "gpt-4.1",
            "gemini-3-pro-preview",
        }

        lowered = raw.lower()
        if lowered in known_choices:
            return lowered

        cleaned = lowered
        cleaned = cleaned.replace("(preview)", "preview")
        cleaned = cleaned.replace("(", " ").replace(")", " ")
        cleaned = " ".join(cleaned.split())
        cleaned = cleaned.replace(" ", "-")
        cleaned = cleaned.replace("--", "-")

        if cleaned in known_choices:
            return cleaned

        return cleaned

    def is_vscode_copilot_shim(exe_path: str) -> bool:
        """Identify the VS Code Copilot Chat extension shim."""
        norm = exe_path.replace("\\", "/").lower()
        while "//" in norm:
            norm = norm.replace("//", "/")
        return "/github.copilot-chat/" in norm and "/copilotcli/" in norm

    copilot_exe = None
    path_env = os.environ.get("PATH", "")
    for path_dir in path_env.split(os.pathsep):
        for candidate_name in ["copilot.exe", "copilot.cmd", "copilot.bat", "copilot"]:
            candidate = Path(path_dir) / candidate_name
            if candidate.exists() and not is_vscode_copilot_shim(str(candidate)):
                copilot_exe = str(candidate)
                break
        if copilot_exe:
            break

    if not copilot_exe:
        raise FileNotFoundError(
            "Required executable not found on PATH: copilot. "
            "Install GitHub Copilot CLI via either: "
            "winget install GitHub.Copilot  OR  npm install -g @github/copilot"
        )

    log_file.parent.mkdir(parents=True, exist_ok=True)

    if trust_workspace:
        _ensure_trusted_workspace(workspace=workspace)

    share_dir = log_file.parent / "copilot_sessions"
    share_dir.mkdir(parents=True, exist_ok=True)
    share_path = share_dir / f"copilot_session_{run_id}_{task_id}.md"
    if resume_session and not share_path.exists():
        share_path.touch()

    prompt_dir = log_file.parent / "prompts"
    prompt_dir.mkdir(parents=True, exist_ok=True)
    prompt_file = prompt_dir / f"prompt_{run_id}_{task_id}.md"
    prompt_file.write_text(prompt_text, encoding="utf-8")

    argv: list[str] = [
        copilot_exe,
        "--agent",
        DEFAULT_COPILOT_AGENT,
    ]

    normalized_model: str | None = None
    if preferred_model:
        normalized_model = normalize_copilot_model(preferred_model)
        argv.extend(["--model", normalized_model])

    use_continue = False
    if resume_session or not is_first_task:
        argv.append("--continue")
        use_continue = True

    argv.extend(
        [
            "--share",
            str(share_path),
            "--add-dir",
            str(workspace),
            "--allow-tool",
            "write",
            "--allow-tool",
            "shell(poetry)",
            "--allow-tool",
            "shell(python)",
            "--allow-tool",
            "shell(python3)",
            "--allow-tool",
            "shell(git)",
        ]
    )

    if allow_shell:
        argv.extend(["--allow-tool", "shell"])
    if allow_all_paths:
        argv.append("--allow-all-paths")
    if allow_all_urls:
        argv.append("--allow-all-urls")

    argv.extend(["-p", f"Follow these instructions exactly: @{prompt_file}"])

    with log_file.open("a", encoding="utf-8") as f:
        f.write("\n\n=== Copilot invocation ===\n")
        f.write(f"task_id: {task_id}\n")
        if preferred_model:
            f.write(f"preferred_model: {preferred_model}\n")
        if normalized_model:
            f.write(f"normalized_model: {normalized_model}\n")
        session_mode = (
            "continue" if use_continue else "resume" if resume_session else "new"
        )
        f.write(f"session_mode: {session_mode}\n")
        f.write(f"share_path: {share_path}\n")
        f.write(f"prompt_file: {prompt_file}\n")
        f.write("(prompt omitted from log for brevity; use --print-prompt to view)\n")
        f.flush()

        process = subprocess.Popen(  # noqa: S603
            argv,
            cwd=workspace,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )

        decoder = codecs.getincrementaldecoder("utf-8")(errors="replace")
        idle_timeout = _resolve_idle_timeout_seconds(_idle_timeout_seconds)
        try:
            exit_code, output_tail = _stream_copilot_output(
                process=process,
                decoder=decoder,
                log_file=f,
                task_id=task_id,
                idle_timeout_seconds=idle_timeout,
                output_tail_bytes=output_tail_bytes,
            )
        except CopilotPermissionDeniedError as exc:
            argv_summary = " ".join(argv)
            raise RuntimeError(
                "Copilot CLI reported a permissions dead-end and cannot request "
                "approval from the user in this environment. "
                f"Detected: {COPILOT_PERMISSION_DENIED_SUBSTRING!r}. "
                f"argv: {argv_summary}. "
                "Guidance: ensure the executor uses programmatic mode (-p/--prompt) "
                "and includes explicit tool and directory permissions "
                "(e.g. --allow-tool write, --allow-tool shell(poetry), "
                "--allow-tool shell(python3), --allow-tool shell(git), "
                "--allow-tool shell, --allow-all-paths, "
                "and --add-dir <workspace>). "
                "If policy blocks headless execution, run the command interactively to "
                "grant approvals."
            ) from exc

    _clean_session_file(share_path, prompt_text)
    return CopilotRunResult(exit_code=exit_code, output_tail=output_tail)


def _resolve_idle_timeout_seconds(configured: float | None) -> float | None:
    """Resolve the idle timeout value from argument or environment."""
    if configured is not None:
        return configured if configured > 0 else None

    env_val = os.environ.get("ATOMIC_EXECUTOR_COPILOT_IDLE_TIMEOUT_SECONDS")
    if env_val is None:
        return 300.0

    env_val = env_val.strip()
    if not env_val:
        return 300.0

    try:
        parsed = float(env_val)
    except ValueError:
        return 300.0

    return parsed if parsed > 0 else None


def _copilot_config_dir() -> Path:
    """Resolve the Copilot CLI configuration directory."""
    xdg_home = os.environ.get("XDG_CONFIG_HOME")
    if xdg_home and xdg_home.strip():
        return Path(xdg_home).expanduser().resolve() / "copilot"
    return Path.home() / ".copilot"


def _ensure_trusted_workspace(*, workspace: Path) -> None:
    """Ensure the workspace appears in Copilot CLI trusted_folders."""
    config_dir = _copilot_config_dir()
    config_dir.mkdir(parents=True, exist_ok=True)
    config_file = config_dir / "config.json"

    config_data: dict[str, object] = {}
    if config_file.exists():
        try:
            config_data = json.loads(config_file.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise RuntimeError(
                "Copilot CLI config.json is invalid JSON. "
                f"Fix or remove: {config_file}"
            ) from exc

    trusted_folders = config_data.get("trusted_folders")
    if trusted_folders is None:
        trusted_folders_list: list[str] = []
    elif isinstance(trusted_folders, list):
        trusted_folders_list = [
            str(item) for item in cast(list[object], trusted_folders)
        ]
    else:
        raise RuntimeError(
            "Copilot CLI config.json has non-list trusted_folders. "
            f"Fix: {config_file}"
        )

    workspace_path = str(workspace.resolve())
    if workspace_path not in trusted_folders_list:
        trusted_folders_list.append(workspace_path)
        config_data["trusted_folders"] = trusted_folders_list
        config_file.write_text(
            json.dumps(config_data, indent=2, sort_keys=True),
            encoding="utf-8",
        )


def _stream_copilot_output(
    *,
    process: subprocess.Popen[bytes],
    decoder: codecs.IncrementalDecoder,
    log_file: IO[str],
    task_id: str,
    idle_timeout_seconds: float | None,
    output_tail_bytes: int | None,
) -> tuple[int, str]:
    """Stream Copilot output with hang detection."""

    def _terminate_process(process_to_kill: subprocess.Popen[bytes]) -> None:
        kill_fn = getattr(process_to_kill, "kill", None)
        term_fn = getattr(process_to_kill, "terminate", None)

        if callable(kill_fn):
            kill_fn()
        elif callable(term_fn):
            term_fn()

        with contextlib.suppress(subprocess.TimeoutExpired, AttributeError):
            process_to_kill.wait(timeout=5)

    output_tail_bytes = 0 if output_tail_bytes is None else output_tail_bytes
    if output_tail_bytes < 0:
        output_tail_bytes = 0
    tail_buffer = bytearray()

    q: queue.Queue[bytes | None] = queue.Queue()

    def _reader() -> None:
        stream = process.stdout
        if stream is None:
            q.put(None)
            return

        read1 = getattr(stream, "read1", None)
        try:
            while True:
                chunk: bytes = (
                    cast(bytes, read1(4096)) if callable(read1) else stream.read(4096)
                )

                if not chunk:
                    break

                q.put(chunk)
        finally:
            q.put(None)

    reader_thread = threading.Thread(target=_reader, daemon=True)
    reader_thread.start()

    last_activity = time.monotonic()
    saw_eof = False
    permission_scan_window = ""
    permission_scan_window_max_chars = 2048

    while True:
        try:
            item = q.get(timeout=0.1)
        except queue.Empty:
            item = None

        if item is None:
            if not reader_thread.is_alive() and not saw_eof:
                saw_eof = True
        else:
            if output_tail_bytes > 0:
                tail_buffer.extend(item)
                if len(tail_buffer) > output_tail_bytes:
                    del tail_buffer[:-output_tail_bytes]

            text_chunk = decoder.decode(item, final=False)
            if text_chunk:
                permission_scan_window = (permission_scan_window + text_chunk)[
                    -permission_scan_window_max_chars:
                ]
                if COPILOT_PERMISSION_DENIED_SUBSTRING in permission_scan_window:
                    _terminate_process(process)
                    raise CopilotPermissionDeniedError(
                        COPILOT_PERMISSION_DENIED_SUBSTRING
                    )
                print(text_chunk, end="", flush=True)
                log_file.write(text_chunk)
                log_file.flush()
            last_activity = time.monotonic()

        if process.poll() is not None and saw_eof and q.empty():
            break

        if idle_timeout_seconds is not None and process.poll() is None:
            idle_duration = time.monotonic() - last_activity
            if idle_duration > idle_timeout_seconds:
                _terminate_process(process)
                raise TimeoutError(
                    "Copilot CLI produced no output for "
                    f"{idle_timeout_seconds} seconds while executing task "
                    f"{task_id}; terminated to avoid hanging."
                )

    remaining = decoder.decode(b"", final=True)
    if remaining:
        print(remaining, end="", flush=True)
        log_file.write(remaining)
        log_file.flush()

    return_code = process.wait()
    return (return_code, tail_buffer.decode("utf-8", errors="replace"))


def _clean_session_file(session_path: Path, prompt_text: str) -> None:
    """Remove the prompt from the beginning of the session file."""
    if not session_path.exists():
        return

    try:
        content = session_path.read_text(encoding="utf-8")
        if content.startswith(prompt_text):
            cleaned_content = content[len(prompt_text) :].lstrip()
            cleaned_content = "# Copilot Session Transcript\n\n" + cleaned_content
            session_path.write_text(cleaned_content, encoding="utf-8")
    except Exception as e:  # noqa: BLE001
        print(
            f"Warning: Failed to clean session file {session_path}: {e}",
            file=sys.stderr,
        )


def log_msg(log_file: Path, msg: str) -> None:
    """Write message to log file and flush."""
    with log_file.open("a", encoding="utf-8") as f:
        f.write(f"{msg}\n")


_log_msg = log_msg
