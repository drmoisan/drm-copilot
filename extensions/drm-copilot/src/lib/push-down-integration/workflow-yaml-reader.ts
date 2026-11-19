/**
 * GitHub Actions workflow subset reader (issue #1051, rules S15 to S19).
 *
 * Purpose:
 *     Read workflow text written in a documented YAML subset and return the
 *     facts the push-down integration tools need: the top-level `name`, the
 *     trigger names of `on`, and per-job `name`, `uses`, `needs`, `if`,
 *     `strategy.matrix` values and step `with` version values.
 *
 * Supported subset:
 *     Block mappings and block sequences indented with spaces; full-line and
 *     trailing comments; plain, single-quoted and double-quoted scalars; block
 *     scalars `|` and `>` with the chomping indicators `-` and `+`; flow
 *     sequences and flow mappings on one line; one optional leading `---`;
 *     `${{ ... }}` expressions kept as opaque strings. Tab indentation,
 *     anchors, aliases, tags, a second document and complex keys return status
 *     `unsupported`; malformed text returns status `error`.
 *
 * Invariants / Constraints:
 *     Pure: no I/O and no module-level mutable state. Every scalar stays a
 *     string; LF and CR LF input return equal results.
 */

import { compareCodePoint } from "../string-ordering";

/** Constructs outside the subset, reported with status `unsupported`. */
export const UNSUPPORTED_CONSTRUCTS = [
  "tab-indentation",
  "anchor",
  "alias",
  "tag",
  "multiple-documents",
  "complex-key",
] as const;

/** One construct outside the subset. */
export type UnsupportedConstruct = (typeof UNSUPPORTED_CONSTRUCTS)[number];

/** Step `with` keys whose values are collected as tool versions (S18). */
export const WORKFLOW_VERSION_KEYS = [
  "dotnet-version",
  "node-version",
  "poetry-version",
  "python-version",
] as const;

/** One collected version key. */
export type WorkflowVersionKey = (typeof WORKFLOW_VERSION_KEYS)[number];

/** One job of a workflow read with status `ok`. */
export interface WorkflowJob {
  readonly id: string;
  readonly name: string | null;
  readonly uses: string | null;
  readonly needs: ReadonlyArray<string>;
  readonly if: string | null;
  /** `strategy.matrix` keys with their scalar values. */
  readonly matrix: Readonly<Record<string, ReadonlyArray<string>>>;
  /** Step `with` values per version key, in step order. */
  readonly with_versions: Readonly<
    Record<WorkflowVersionKey, ReadonlyArray<string>>
  >;
}

/** Result of reading text inside the subset. */
export interface WorkflowReadOk {
  readonly status: "ok";
  readonly name: string | null;
  readonly triggers: ReadonlyArray<string>;
  readonly jobs: ReadonlyArray<WorkflowJob>;
}

/** Result of reading text that uses a construct outside the subset. */
export interface WorkflowReadUnsupported {
  readonly status: "unsupported";
  readonly finding: {
    readonly line: number;
    readonly construct: UnsupportedConstruct;
  };
}

/** Result of reading malformed text. */
export interface WorkflowReadError {
  readonly status: "error";
  readonly line: number;
  readonly message: string;
}

/** Result of {@link readWorkflowText}. */
export type WorkflowReadResult =
  WorkflowReadOk | WorkflowReadUnsupported | WorkflowReadError;

/** Parsed node: a scalar string, a null, a sequence, or a mapping. */
type YamlNode = string | null | YamlNode[] | Map<string, YamlNode>;

/** Thrown internally for a construct outside the subset. */
class UnsupportedSignal {
  constructor(
    readonly line: number,
    readonly construct: UnsupportedConstruct,
  ) {}
}

/** Thrown internally for malformed text. */
class ErrorSignal {
  constructor(
    readonly line: number,
    readonly message: string,
  ) {}
}

/** Return whether text begins a block sequence item. */
function isSequenceItem(text: string): boolean {
  return text === "-" || text.startsWith("- ");
}

/** Return whether text begins a complex key. */
function isComplexKey(text: string): boolean {
  return text === "?" || text.startsWith("? ");
}

/** Return whether text is a document start or end marker. */
function isDocumentMarker(text: string): boolean {
  return /^(---|\.\.\.)(\s|$)/.test(text);
}

/** Remove a trailing ` #` comment from plain text. */
function stripPlainComment(text: string): string {
  const match = /(^|[ \t])#/.exec(text);
  return (match === null ? text : text.slice(0, match.index)).trim();
}

/** Line-oriented recursive-descent parser over one workflow text. */
class SubsetParser {
  private readonly lines: string[];
  private pos = 0;

  constructor(text: string) {
    this.lines = text.split(/\r\n|\r|\n/);
  }

  /** Parse the whole text as one document. */
  parseDocument(): YamlNode {
    let index = this.skip();
    if (index >= 0 && this.lineAt(index).trim() === "---") {
      this.pos = index + 1;
      index = this.skip();
    }
    if (index < 0) {
      return null;
    }
    const root = this.parseBlock(this.indentAt(index));
    const rest = this.skip();
    if (rest >= 0) {
      if (isDocumentMarker(this.lineAt(rest).trim())) {
        throw new UnsupportedSignal(rest + 1, "multiple-documents");
      }
      throw new ErrorSignal(rest + 1, "inconsistent indentation");
    }
    return root;
  }

  private lineAt(index: number): string {
    return this.lines[index] ?? "";
  }

  /** Advance past blank and comment lines; return the next index or -1. */
  private skip(): number {
    while (this.pos < this.lines.length) {
      const trimmed = this.lineAt(this.pos).trim();
      if (trimmed !== "" && !trimmed.startsWith("#")) {
        return this.pos;
      }
      this.pos += 1;
    }
    return -1;
  }

  /** Return the space indentation of a content line; reject tabs. */
  private indentAt(index: number): number {
    const line = this.lineAt(index);
    const lead = /^[ \t]*/.exec(line)?.[0] ?? "";
    if (lead.includes("\t")) {
      throw new UnsupportedSignal(index + 1, "tab-indentation");
    }
    return lead.length;
  }

  /** Parse the node that starts on the current content line. */
  private parseBlock(indent: number): YamlNode {
    const index = this.pos;
    const text = this.lineAt(index).slice(indent);
    if (isSequenceItem(text)) {
      return this.parseSequence(indent);
    }
    this.rejectKeyPrefix(text, index);
    if (this.splitKey(text, index) !== undefined) {
      return this.parseMapping(indent);
    }
    this.pos = index + 1;
    return this.parseScalarValue(text.trim(), index, indent);
  }

  /** Reject a complex key or a key that starts with an anchor, alias or tag. */
  private rejectKeyPrefix(text: string, index: number): void {
    if (isComplexKey(text)) {
      throw new UnsupportedSignal(index + 1, "complex-key");
    }
    this.rejectNodeProperty(text, index);
  }

  /** Reject text that starts with an anchor, alias or tag. */
  private rejectNodeProperty(text: string, index: number): void {
    const first = text.charAt(0);
    if (first === "&") {
      throw new UnsupportedSignal(index + 1, "anchor");
    }
    if (first === "*") {
      throw new UnsupportedSignal(index + 1, "alias");
    }
    if (first === "!") {
      throw new UnsupportedSignal(index + 1, "tag");
    }
  }

  /** Parse a block mapping whose keys sit at `indent`. */
  private parseMapping(indent: number): Map<string, YamlNode> {
    const mapping = new Map<string, YamlNode>();
    for (;;) {
      const index = this.skip();
      if (index < 0 || this.indentAt(index) < indent) {
        break;
      }
      if (this.indentAt(index) > indent) {
        throw new ErrorSignal(index + 1, "inconsistent indentation");
      }
      const text = this.lineAt(index).slice(indent);
      if (isDocumentMarker(text)) {
        throw new UnsupportedSignal(index + 1, "multiple-documents");
      }
      this.rejectKeyPrefix(text, index);
      const entry = isSequenceItem(text)
        ? undefined
        : this.splitKey(text, index);
      if (entry === undefined) {
        throw new ErrorSignal(index + 1, "expected a mapping key");
      }
      if (mapping.has(entry.key)) {
        throw new ErrorSignal(index + 1, `duplicate key '${entry.key}'`);
      }
      this.pos = index + 1;
      mapping.set(entry.key, this.parseEntryValue(entry.rest, index, indent));
    }
    return mapping;
  }

  /** Parse the value of a mapping entry whose key sits at `indent`. */
  private parseEntryValue(
    rest: string,
    index: number,
    indent: number,
  ): YamlNode {
    const value = rest.trim();
    if (value !== "" && !value.startsWith("#")) {
      return this.parseScalarValue(value, index, indent);
    }
    const next = this.skip();
    if (next < 0) {
      return null;
    }
    const nextIndent = this.indentAt(next);
    if (nextIndent > indent) {
      return this.parseBlock(nextIndent);
    }
    if (
      nextIndent === indent &&
      isSequenceItem(this.lineAt(next).slice(indent))
    ) {
      return this.parseSequence(indent);
    }
    return null;
  }

  /** Parse a block sequence whose dashes sit at `indent`. */
  private parseSequence(indent: number): YamlNode[] {
    const items: YamlNode[] = [];
    for (;;) {
      const index = this.skip();
      if (index < 0 || this.indentAt(index) < indent) {
        break;
      }
      if (this.indentAt(index) > indent) {
        throw new ErrorSignal(index + 1, "inconsistent indentation");
      }
      const text = this.lineAt(index).slice(indent);
      if (isDocumentMarker(text)) {
        throw new UnsupportedSignal(index + 1, "multiple-documents");
      }
      if (!isSequenceItem(text)) {
        break;
      }
      items.push(this.parseSequenceItem(text.slice(1), index, indent));
    }
    return items;
  }

  /** Parse the content after one item's dash. */
  private parseSequenceItem(
    after: string,
    index: number,
    indent: number,
  ): YamlNode {
    const content = after.trimStart();
    if (content === "" || content.startsWith("#")) {
      this.pos = index + 1;
      const next = this.skip();
      return next >= 0 && this.indentAt(next) > indent
        ? this.parseBlock(this.indentAt(next))
        : null;
    }
    const column = indent + 1 + (after.length - content.length);
    const opensBlock =
      isSequenceItem(content) ||
      isComplexKey(content) ||
      (!/^[&*!]/.test(content) && this.splitKey(content, index) !== undefined);
    if (opensBlock) {
      // The item's first line also starts a nested block at `column`.
      this.lines[index] = `${" ".repeat(column)}${content}`;
      this.pos = index;
      return this.parseBlock(column);
    }
    this.pos = index + 1;
    return this.parseScalarValue(content, index, indent);
  }

  /** Split `key: rest`, or return undefined when the text is not an entry. */
  private splitKey(
    text: string,
    index: number,
  ): { key: string; rest: string } | undefined {
    const first = text.charAt(0);
    if (first === '"' || first === "'") {
      const quoted = this.readQuoted(text, 0, index);
      const after = text.slice(quoted.end).trimStart();
      return /^:(\s|$)/.test(after)
        ? { key: quoted.value, rest: after.slice(1) }
        : undefined;
    }
    if (first === "[" || first === "{") {
      return undefined;
    }
    let depth = 0;
    for (let at = 0; at < text.length; at += 1) {
      if (text.startsWith("${{", at)) {
        depth += 1;
        at += 2;
      } else if (depth > 0 && text.startsWith("}}", at)) {
        depth -= 1;
        at += 1;
      } else if (depth === 0) {
        const char = text.charAt(at);
        if (char === "#" && at > 0 && /\s/.test(text.charAt(at - 1))) {
          return undefined;
        }
        if (char === ":" && /^(\s|$)/.test(text.slice(at + 1, at + 2))) {
          const key = text.slice(0, at).trim();
          return key === "" ? undefined : { key, rest: text.slice(at + 1) };
        }
      }
    }
    return undefined;
  }

  /** Parse an inline value that starts on line `index`. */
  private parseScalarValue(
    value: string,
    index: number,
    parentIndent: number,
  ): YamlNode {
    this.rejectNodeProperty(value, index);
    const first = value.charAt(0);
    if (first === "|" || first === ">") {
      const header = stripPlainComment(value);
      if (!/^[|>][-+]?$/.test(header)) {
        throw new ErrorSignal(index + 1, "unsupported block scalar header");
      }
      return this.readBlockScalar(header, parentIndent);
    }
    if (first === '"' || first === "'" || first === "[" || first === "{") {
      const parsed =
        first === '"' || first === "'"
          ? this.readQuoted(value, 0, index)
          : this.readFlow(value, 0, index);
      if (stripPlainComment(value.slice(parsed.end)) !== "") {
        throw new ErrorSignal(index + 1, "unexpected text after a value");
      }
      return parsed.value;
    }
    const parts = [stripPlainComment(value)];
    // A plain scalar continues on following lines indented past its parent.
    while (this.pos < this.lines.length) {
      const line = this.lineAt(this.pos);
      const trimmed = line.trim();
      if (trimmed === "" || trimmed.startsWith("#")) {
        break;
      }
      if (this.indentAt(this.pos) <= parentIndent) {
        break;
      }
      if (this.splitKey(trimmed, this.pos) !== undefined) {
        break;
      }
      parts.push(stripPlainComment(trimmed));
      this.pos += 1;
    }
    return parts.join(" ");
  }

  /** Read a block scalar body after its header line. */
  private readBlockScalar(header: string, parentIndent: number): string {
    const collected: string[] = [];
    let blockIndent = -1;
    while (this.pos < this.lines.length) {
      const line = this.lineAt(this.pos);
      if (line.trim() === "") {
        collected.push("");
        this.pos += 1;
        continue;
      }
      const spaces = /^ */.exec(line)?.[0].length ?? 0;
      if (blockIndent < 0) {
        if (line.charAt(spaces) === "\t") {
          throw new UnsupportedSignal(this.pos + 1, "tab-indentation");
        }
        if (spaces <= parentIndent) {
          break;
        }
        blockIndent = spaces;
      }
      if (spaces < blockIndent) {
        break;
      }
      collected.push(line.slice(blockIndent));
      this.pos += 1;
    }
    let end = collected.length;
    while (end > 0 && collected[end - 1] === "") {
      end -= 1;
    }
    const body = collected.slice(0, end);
    const text = header.startsWith("|") ? body.join("\n") : foldLines(body);
    if (header.endsWith("-") || body.length === 0) {
      return header.endsWith("+") ? "\n".repeat(collected.length - end) : text;
    }
    return header.endsWith("+")
      ? `${text}\n${"\n".repeat(collected.length - end)}`
      : `${text}\n`;
  }

  /** Read a quoted scalar starting at `start`. */
  private readQuoted(
    text: string,
    start: number,
    index: number,
  ): { value: string; end: number } {
    const quote = text.charAt(start);
    let value = "";
    for (let at = start + 1; at < text.length; at += 1) {
      const char = text.charAt(at);
      if (quote === "'" && char === "'") {
        if (text.charAt(at + 1) === "'") {
          value += "'";
          at += 1;
          continue;
        }
        return { value, end: at + 1 };
      }
      if (quote === '"' && char === "\\") {
        const escaped = text.charAt(at + 1);
        value += escaped === "n" ? "\n" : escaped === "t" ? "\t" : escaped;
        at += 1;
        continue;
      }
      if (quote === '"' && char === '"') {
        return { value, end: at + 1 };
      }
      value += char;
    }
    throw new ErrorSignal(index + 1, "unterminated quoted scalar");
  }

  /** Read a one-line flow sequence or flow mapping starting at `start`. */
  private readFlow(
    text: string,
    start: number,
    index: number,
  ): { value: YamlNode; end: number } {
    const open = text.charAt(start);
    const close = open === "[" ? "]" : "}";
    const sequence: YamlNode[] = [];
    const mapping = new Map<string, YamlNode>();
    let at = start + 1;
    const skipSpace = (): void => {
      while (at < text.length && /\s/.test(text.charAt(at))) {
        at += 1;
      }
    };
    for (;;) {
      skipSpace();
      if (at >= text.length) {
        throw new ErrorSignal(index + 1, "unterminated flow collection");
      }
      if (text.charAt(at) === close) {
        return {
          value: open === "[" ? sequence : mapping,
          end: at + 1,
        };
      }
      const item = this.readFlowItem(text, at, index, open === "{");
      at = item.end;
      if (open === "{") {
        skipSpace();
        if (text.charAt(at) !== ":") {
          throw new ErrorSignal(index + 1, "expected ':' in a flow mapping");
        }
        at += 1;
        skipSpace();
        const value = this.readFlowItem(text, at, index, false);
        const key = typeof item.value === "string" ? item.value : "";
        if (mapping.has(key)) {
          throw new ErrorSignal(index + 1, `duplicate key '${key}'`);
        }
        mapping.set(key, value.value);
        at = value.end;
      } else {
        sequence.push(item.value);
      }
      skipSpace();
      if (text.charAt(at) === ",") {
        at += 1;
      } else if (text.charAt(at) !== close) {
        throw new ErrorSignal(index + 1, "unterminated flow collection");
      }
    }
  }

  /** Read one flow item: a nested collection, a quoted or a plain scalar. */
  private readFlowItem(
    text: string,
    start: number,
    index: number,
    isKey: boolean,
  ): { value: YamlNode; end: number } {
    const first = text.charAt(start);
    this.rejectNodeProperty(first, index);
    if (first === "[" || first === "{") {
      return this.readFlow(text, start, index);
    }
    if (first === '"' || first === "'") {
      return this.readQuoted(text, start, index);
    }
    let at = start;
    let depth = 0;
    while (at < text.length) {
      if (text.startsWith("${{", at)) {
        depth += 1;
        at += 3;
        continue;
      }
      if (depth > 0 && text.startsWith("}}", at)) {
        depth -= 1;
        at += 2;
        continue;
      }
      const char = text.charAt(at);
      if (depth === 0 && (char === "," || char === "]" || char === "}")) {
        break;
      }
      if (depth === 0 && isKey && char === ":") {
        break;
      }
      at += 1;
    }
    return { value: text.slice(start, at).trim(), end: at };
  }
}

/** Fold block-scalar lines: adjacent text lines join with a space. */
function foldLines(body: ReadonlyArray<string>): string {
  let text = "";
  body.forEach((line, offset) => {
    const previous = offset > 0 ? body[offset - 1] : undefined;
    const joinsWithSpace =
      previous !== undefined &&
      previous !== "" &&
      line !== "" &&
      !line.startsWith(" ") &&
      !previous.startsWith(" ");
    text += offset === 0 ? line : `${joinsWithSpace ? " " : "\n"}${line}`;
  });
  return text;
}

/** Return the scalar strings of a scalar or a sequence of scalars. */
function scalarList(node: YamlNode | undefined): string[] {
  if (typeof node === "string") {
    return [node];
  }
  return Array.isArray(node)
    ? node.filter((item): item is string => typeof item === "string")
    : [];
}

/** Return a string value, or null for any other node. */
function stringOrNull(node: YamlNode | undefined): string | null {
  return typeof node === "string" ? node : null;
}

/** Return a mapping value, or an empty mapping for any other node. */
function asMapping(node: YamlNode | undefined): Map<string, YamlNode> {
  return node instanceof Map ? node : new Map<string, YamlNode>();
}

/** Build one job record from its mapping. */
function readJob(id: string, node: YamlNode | undefined): WorkflowJob {
  const job = asMapping(node);
  const matrixNode = asMapping(asMapping(job.get("strategy")).get("matrix"));
  const matrix: Array<[string, string[]]> = [];
  for (const [key, value] of matrixNode) {
    const scalars =
      typeof value === "string" ||
      (Array.isArray(value) && value.every((item) => typeof item === "string"));
    if (scalars) {
      matrix.push([key, scalarList(value)]);
    }
  }
  const versions: Record<WorkflowVersionKey, string[]> = {
    "dotnet-version": [],
    "node-version": [],
    "poetry-version": [],
    "python-version": [],
  };
  const steps = job.get("steps");
  for (const step of Array.isArray(steps) ? steps : []) {
    const withBlock = asMapping(asMapping(step).get("with"));
    for (const key of WORKFLOW_VERSION_KEYS) {
      const value = withBlock.get(key);
      if (typeof value === "string") {
        versions[key].push(value);
      }
    }
  }
  return {
    id,
    name: stringOrNull(job.get("name")),
    uses: stringOrNull(job.get("uses")),
    needs: scalarList(job.get("needs")),
    if: stringOrNull(job.get("if")),
    matrix: Object.fromEntries(matrix),
    with_versions: versions,
  };
}

/** Return the sorted trigger names of an `on` node. */
function readTriggers(node: YamlNode | undefined): string[] {
  const names =
    node instanceof Map ? [...node.keys()] : scalarList(node ?? undefined);
  return [...new Set(names)].sort(compareCodePoint);
}

/**
 * Read workflow text in the supported subset.
 *
 * @param text Workflow text with LF or CR LF line endings.
 * @returns Status `ok` with the name, triggers and jobs; status `unsupported`
 *   with the first construct outside the subset; or status `error` with a
 *   1-based line and a message.
 */
export function readWorkflowText(text: string): WorkflowReadResult {
  let root: YamlNode;
  try {
    root = new SubsetParser(text).parseDocument();
  } catch (signal) {
    if (signal instanceof UnsupportedSignal) {
      return {
        status: "unsupported",
        finding: { line: signal.line, construct: signal.construct },
      };
    }
    if (signal instanceof ErrorSignal) {
      return { status: "error", line: signal.line, message: signal.message };
    }
    throw signal;
  }
  if (root !== null && !(root instanceof Map)) {
    return {
      status: "error",
      line: 1,
      message: "the workflow root is not a mapping",
    };
  }
  const document = asMapping(root);
  const jobs = [...asMapping(document.get("jobs")).entries()]
    .map(([id, node]) => readJob(id, node))
    .sort((left, right) => compareCodePoint(left.id, right.id));
  return {
    status: "ok",
    name: stringOrNull(document.get("name")),
    triggers: readTriggers(document.get("on")),
    jobs,
  };
}
