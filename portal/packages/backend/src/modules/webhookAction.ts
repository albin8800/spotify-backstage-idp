import { createBackendModule } from '@backstage/backend-plugin-api';
import {
  createTemplateAction,
  scaffolderActionsExtensionPoint,
} from '@backstage/plugin-scaffolder-node';

export const scaffolderModuleWebhookAction = createBackendModule({
  pluginId: 'scaffolder',
  moduleId: 'webhook-action',
  register(env) {
    env.registerInit({
      deps: {
        scaffolder: scaffolderActionsExtensionPoint,
      },
      async init({ scaffolder }) {
        scaffolder.addActions(
          createTemplateAction({
            id: 'webhook:notify',
            description: 'Sends a post-scaffold notification payload to a webhook receiver',
            schema: {
              input: (z) =>
                z.object({
                  url: z.string().describe('Target HTTP URL for the notification'),
                  payload: z.record(z.any()).describe('Data payload to transmit'),
                }),
            },
            async handler(ctx) {
              const { url, payload } = ctx.input;
              ctx.logger.info(`[Platform Hook] Dispatching webhook to ${url}...`);

              const response = await fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload),
              }); 

              if (!response.ok) { 
                throw new Error(`Webhook failed with HTTP ${response.status}`);
              } 

              ctx.logger.info(`[Platform Hook] Webhook acknowledged successfully!`);
            },
          }),
        );
      },
    }); 
  },
});
