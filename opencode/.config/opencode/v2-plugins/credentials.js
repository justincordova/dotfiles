// Read credentials through V2; never copy secrets into plugin configuration.
export async function legacyAuth(ctx, integrationID) {
  const connection = await ctx.integration.connection.active(integrationID);
  if (!connection) return undefined;
  const value = await ctx.integration.connection.resolve(connection);
  if (!value) return undefined;
  return value.type === "key" ? { type: "api", key: value.key } : value;
}
