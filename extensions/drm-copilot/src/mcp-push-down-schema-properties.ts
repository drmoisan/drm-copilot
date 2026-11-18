export const workspaceRootProperty = {
  type: "string",
  description:
    "Required absolute path to the root of the target checkout or worktree. The MCP server cannot infer the calling agent's checkout, so this value must be supplied explicitly.",
} as const;

const codexPacksProperty = {
  type: "array",
  items: {
    type: "string",
  },
  description:
    "Optional Codex language pack names to publish. When omitted, the full tree is published. 'core' is always included.",
} as const;

const codexCsharpVariantProperty = {
  type: "string",
  enum: ["modern", "legacy"],
  description:
    "Optional Codex C# toolchain variant to source ('modern' default or 'legacy').",
} as const;

const codexMemoryModeProperty = {
  type: "string",
  enum: ["overwrite", "merge", "skip"],
  description:
    "Optional inert Codex memory parity field: 'overwrite' (default), 'merge', or 'skip'.",
} as const;

/** Optional dry-run flag shared by the three push-down tools (issue #1029). */
const dryRunProperty = {
  type: "boolean",
  description:
    "Optional. When true, plan the push-down and return push_down_report without writing any file (default false).",
} as const;

/** Optional O-4 opt-in shared by the three push-down tools (issue #1029). */
const overwriteUnmanagedProperty = {
  type: "boolean",
  description:
    "Optional. When true, overwrite destination files that have no manifest entry and differ from the payload (default false).",
} as const;

/** Run options added to every push-down tool schema. */
const pushDownRunProperties = {
  dry_run: dryRunProperty,
  overwrite_unmanaged: overwriteUnmanagedProperty,
} as const;

export const codexPushDownSelectionProperties = {
  packs: codexPacksProperty,
  csharp_variant: codexCsharpVariantProperty,
  memory_mode: codexMemoryModeProperty,
  ...pushDownRunProperties,
} as const;

export const copilotPushDownSelectionProperties = {
  packs: {
    type: "array",
    items: {
      type: "string",
    },
    description:
      "Optional Copilot pack names to publish ('python', 'powershell', 'typescript', 'csharp'). When omitted, the recorded selection is reused, else the full tree is published. 'core' is always included.",
  },
  ...pushDownRunProperties,
} as const;

export const claudePushDownSelectionProperties = {
  packs: {
    type: "array",
    items: {
      type: "string",
    },
    description:
      "Optional language pack names to publish (for example 'core', 'typescript'). When omitted, the full tree is published. 'core' is always included.",
  },
  csharp_variant: {
    type: "string",
    enum: ["modern", "legacy"],
    description:
      "Optional C# toolchain variant to source ('modern' default or 'legacy').",
  },
  memory_mode: {
    type: "string",
    enum: ["overwrite", "merge", "skip"],
    description:
      "Optional agent-memory handling mode: 'overwrite' (default), 'merge', or 'skip'.",
  },
  ...pushDownRunProperties,
} as const;
