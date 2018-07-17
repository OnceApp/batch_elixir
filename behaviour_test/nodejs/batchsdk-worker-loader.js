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
  self.addEventListener(eventName, (event) => {
    event.waitUntil(
      workerReady
        .then(() => {
          return self.handleBatchSDKEvent(eventName, event);
        })
        .catch(() => { })
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

    client.postMessage("SW Says: '" + msg + "'", [msg_chan.port2]);
  });
}
function send_message_to_all_clients(msg) {
  console.log(clients)
  clients.matchAll().then(clients => {
    clients.forEach(client => {
      send_message_to_client(client, msg).then(m => console.log("SW Received Message: " + m));
    })
  })
}
send_message_to_all_clients("test")