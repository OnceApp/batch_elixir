const request = indexedDB.open('BatchWebPush', 1);
const workerReady = new Promise((resolve, reject) => {
  request.onsuccess = (event) => {
    try {
      const db = event.target.result;
      const query = db.transaction(['BatchKVData'], 'readonly').objectStore('BatchKVData').get('lastconfig');
      query.onsuccess = (qevent) => {
        const data = qevent.target.result;
        if (typeof data !== 'undefined') {
          const workerScriptUrl = data.value.internal.workerScriptUrl;
          if (/^https:\/\/(?:[^.]+\.)?via\.batch\.com\/.*$/i.test(workerScriptUrl)) {
            importScripts(workerScriptUrl);
            resolve();
          } else {
            reject();
          }
        } else {
          reject();
        }
      };
      query.onerror = () => reject();
    } catch (err) {
      reject(err);
    }
  };
  request.onerror = () => reject();
});

const eventsList = ['pushsubscriptionchange', 'install', 'push', 'notificationclick', 'message'];
eventsList.forEach((eventName) => {
  self.addEventListener(eventName, function (event) {
    event.waitUntil(
      workerReady
        .then(function () {
          return self.handleBatchSDKEvent(eventName, event);
        })
        .catch(function () { })
    );
  });
});
function send_message_to_client(client, msg) {
  return new Promise(function (resolve, reject) {
    var msg_chan = new MessageChannel();

    msg_chan.port1.onmessage = function (event) {
      if (event.data.error) {
        reject(event.data.error);
      } else {
        resolve(event.data);
      }
    };

    client.postMessage(msg, [msg_chan.port2]);
  });
}
function send_message_to_all_clients(msg) {
  clients
    .matchAll({ includeUncontrolled: true, type: 'window' })
    .then(clients =>
      clients
        .forEach(client =>
          send_message_to_client(client, msg)
        )
    )
    .catch(console.log)
}

self.addEventListener('push', function (event) {
  event.waitUntil(
    workerReady
      .then(() => {
        if (event.data) {
          send_message_to_all_clients(event.data.json());
        } else {
          send_message_to_all_clients(false)
        }
      })
      .catch(() => { })
  )
})