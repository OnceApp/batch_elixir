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
        .catch(() => {})
    );
  });
});
