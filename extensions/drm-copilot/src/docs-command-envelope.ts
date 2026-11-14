/**
 * Pure structural parser for the `Invoke-DocsCommand.ps1 -Json` envelope.
 *
 * The envelope shape is fixed by `schemas/docs/v1/docs-command-envelope.schema.json`
 * (issue #1020): exactly the keys `command`, `exit_code`, `findings`, `ok` and
 * `result`, with each finding carrying exactly the docs-common `finding` keys.
 * `result` is opaque. This module performs no I/O and holds no mutable state.
 */

/** Host failure codes raised by the docs MCP tools (spec `### Host failure codes`). */
export type DocsHostErrorCode =
  | "DOCS_WORKSPACE_ROOT_INVALID"
  | "DOCS_ENTRY_SCRIPT_MISSING"
  | "DOCS_PWSH_UNAVAILABLE"
  | "DOCS_RUNTIME_UNAVAILABLE"
  | "DOCS_ENVELOPE_EMPTY"
  | "DOCS_ENVELOPE_MALFORMED"
  | "DOCS_ENVELOPE_EXIT_MISMATCH"
  | "DOCS_ENVELOPE_COMMAND_MISMATCH";

/** Severity values of a docs-common finding. */
export type DocsFindingSeverity = "error" | "warning" | "info";

/** One docs-common `finding` object. */
export interface DocsFinding {
  readonly code: string;
  readonly severity: DocsFindingSeverity;
  readonly artifact_path: string | null;
  readonly pointer: string;
  readonly related_ids: ReadonlyArray<string>;
  readonly related_paths: ReadonlyArray<string>;
  readonly message: string;
  readonly next_action: string;
}

/** The canonical `-Json` envelope printed by `Invoke-DocsCommand.ps1`. */
export interface DocsCommandEnvelope {
  readonly command: string | null;
  readonly exit_code: 0 | 1 | 2 | 3;
  readonly findings: ReadonlyArray<DocsFinding>;
  readonly ok: boolean;
  readonly result: unknown;
}

/** Top-level envelope keys, sorted; equals the schema `required` set. */
export const DOCS_ENVELOPE_KEYS = [
  "command",
  "exit_code",
  "findings",
  "ok",
  "result",
] as const;

/** Docs-common `finding` keys, sorted. */
export const DOCS_FINDING_KEYS = [
  "artifact_path",
  "code",
  "message",
  "next_action",
  "pointer",
  "related_ids",
  "related_paths",
  "severity",
] as const;

const FINDING_SEVERITIES: ReadonlyArray<string> = ["error", "warning", "info"];
const STDERR_EXCERPT_LINES = 8;

/** A docs host failure; the message is prefixed by the code. */
export class DocsHostError extends Error {
  readonly code: DocsHostErrorCode;

  constructor(code: DocsHostErrorCode, message: string) {
    super(`${code}: ${message}`);
    this.name = "DocsHostError";
    this.code = code;
  }
}

/** Process facts the parsed envelope must agree with. */
export interface DocsEnvelopeContext {
  readonly exitCode: number | null;
  readonly stderr: string;
  readonly command: string;
}

function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function hasExactKeys(
  record: Readonly<Record<string, unknown>>,
  expected: ReadonlyArray<string>,
): boolean {
  const keys = Object.keys(record).sort();
  return (
    keys.length === expected.length &&
    keys.every((key, index) => key === expected[index])
  );
}

function isStringArray(value: unknown): value is ReadonlyArray<string> {
  return (
    Array.isArray(value) && value.every((item) => typeof item === "string")
  );
}

function isExitCode(value: unknown): value is 0 | 1 | 2 | 3 {
  return value === 0 || value === 1 || value === 2 || value === 3;
}

function isFinding(value: unknown): value is DocsFinding {
  if (!isRecord(value) || !hasExactKeys(value, DOCS_FINDING_KEYS)) {
    return false;
  }
  const artifactPath = value["artifact_path"];
  return (
    typeof value["code"] === "string" &&
    typeof value["severity"] === "string" &&
    FINDING_SEVERITIES.includes(value["severity"]) &&
    (artifactPath === null || typeof artifactPath === "string") &&
    typeof value["pointer"] === "string" &&
    isStringArray(value["related_ids"]) &&
    isStringArray(value["related_paths"]) &&
    typeof value["message"] === "string" &&
    typeof value["next_action"] === "string"
  );
}

function malformed(detail: string): DocsHostError {
  return new DocsHostError(
    "DOCS_ENVELOPE_MALFORMED",
    `The docs command output is not a valid envelope: ${detail}.`,
  );
}

function parseJsonDocument(text: string): unknown {
  try {
    return JSON.parse(text) as unknown;
  } catch (error) {
    const reason = error instanceof Error ? error.message : String(error);
    throw malformed(`stdout is not exactly one JSON document (${reason})`);
  }
}

function toEnvelope(document: unknown): DocsCommandEnvelope {
  if (!isRecord(document)) {
    throw malformed("the JSON document is not an object");
  }
  if (!hasExactKeys(document, DOCS_ENVELOPE_KEYS)) {
    throw malformed(
      `the key set is ${JSON.stringify(Object.keys(document).sort())}`,
    );
  }
  const command = document["command"];
  const exitCode = document["exit_code"];
  const findings = document["findings"];
  const ok = document["ok"];
  if (command !== null && typeof command !== "string") {
    throw malformed("command is not a string or null");
  }
  if (!isExitCode(exitCode)) {
    throw malformed("exit_code is not one of 0, 1, 2 or 3");
  }
  if (typeof ok !== "boolean") {
    throw malformed("ok is not a boolean");
  }
  if (ok !== (exitCode === 0)) {
    throw malformed("ok disagrees with exit_code");
  }
  if (!Array.isArray(findings) || !findings.every(isFinding)) {
    throw malformed("findings is not an array of docs-common findings");
  }
  return {
    command,
    exit_code: exitCode,
    findings,
    ok,
    result: document["result"],
  };
}

/**
 * Parses the stdout of one docs command into the typed envelope.
 *
 * @param stdout The complete process stdout.
 * @param context The process exit code, stderr and the requested subcommand.
 * @returns The envelope, unchanged in content.
 * @throws DocsHostError with an envelope host failure code.
 */
export function parseDocsEnvelope(
  stdout: string,
  context: DocsEnvelopeContext,
): DocsCommandEnvelope {
  const text = stdout.trim();
  if (text.length === 0) {
    throw new DocsHostError(
      "DOCS_ENVELOPE_EMPTY",
      `The docs command printed no envelope (process exit code ${String(context.exitCode)}).`,
    );
  }
  const envelope = toEnvelope(parseJsonDocument(text));
  if (envelope.exit_code !== context.exitCode) {
    throw new DocsHostError(
      "DOCS_ENVELOPE_EXIT_MISMATCH",
      `The envelope exit_code ${String(envelope.exit_code)} differs from the process exit code ${String(context.exitCode)}.`,
    );
  }
  if (envelope.command !== context.command) {
    throw new DocsHostError(
      "DOCS_ENVELOPE_COMMAND_MISMATCH",
      `The envelope command ${JSON.stringify(envelope.command)} differs from the requested subcommand ${JSON.stringify(context.command)}.`,
    );
  }
  return envelope;
}

/**
 * Formats the 1020 summary line `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>`.
 *
 * @param envelope A parsed envelope.
 * @returns The summary line counted from the finding severities.
 */
export function formatDocsSummary(envelope: DocsCommandEnvelope): string {
  const count = (severity: DocsFindingSeverity): number =>
    envelope.findings.filter((finding) => finding.severity === severity).length;
  return `${envelope.command ?? "unknown"}: exit=${String(envelope.exit_code)} errors=${String(count("error"))} warnings=${String(count("warning"))} infos=${String(count("info"))}`;
}

/**
 * Returns the first eight non-empty, trimmed stderr lines, or undefined when none.
 *
 * @param stderr The complete process stderr.
 * @returns The excerpt joined with newlines.
 */
export function excerptDocsStderr(stderr: string): string | undefined {
  const lines = stderr
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .slice(0, STDERR_EXCERPT_LINES);
  return lines.length > 0 ? lines.join("\n") : undefined;
}
