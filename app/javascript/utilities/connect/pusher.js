// import Pusher from 'pusher-js';

export function setupPusher(credentials, callbackObjects) {
  return import('pusher-js').then((_) => {
    const {
      pusher = new Pusher(credentials.key, {
        authEndpoint: '/pusher/auth',
        auth: {
          headers: {
            'X-CSRF-Token': window.csrfToken,
          },
        },
        cluster: credentials.cluster,
        encrypted: true,
      }),
    } = window;

    window.pusher = pusher;

    const channel = pusher.subscribe(callbackObjects.channelId.toString());
    channel.bind('message-created', callbackObjects.messageCreated);
    channel.bind('message-deleted', callbackObjects.messageDeleted);
    channel.bind('message-edited', callbackObjects.messageEdited);
    channel.bind('mentioned', callbackObjects.mentioned);
    channel.bind('message-opened', callbackObjects.messageOpened);
    channel.bind('channel-cleared', callbackObjects.channelCleared);
    channel.bind('user-banned', callbackObjects.redactUserMessages);

    channel.bind('pusher:subscription_error', callbackObjects.channelError);

    return channel;
  });
}
