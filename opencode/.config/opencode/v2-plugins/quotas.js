import { Plugin } from "@opencode/plugin";
import { MyStatusPlugin } from "./vendor/opencode-mystatus/plugin/mystatus.js";

export default Plugin.define({
  id: "local.quotas",
  async setup(ctx) {
    const plugins = await Promise.all([MyStatusPlugin(ctx)]);
    await ctx.tool.transform((editor) => {
      for (const plugin of plugins) {
        for (const [name, tool] of Object.entries(plugin.tool)) {
          editor.add({
            name,
            description: tool.description,
            input: { type: "object", properties: {}, additionalProperties: false },
            execute: async () => ({ content: await tool.execute({}) }),
          });
        }
      }
    });
  },
});
