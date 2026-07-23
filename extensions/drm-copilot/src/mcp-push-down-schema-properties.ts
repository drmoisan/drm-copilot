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

export const codexPushDownSelectionProperties = {
  packs: codexPacksProperty,
  csharp_variant: codexCsharpVariantProperty,
  memory_mode: codexMemoryModeProperty,
} as const;

export const copilotPushDownSelectionProperties = {} as const;

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
} as const;
