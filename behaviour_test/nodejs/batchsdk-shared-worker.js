// WARNING: This worker IS ONLY TO BE USED if you want to integrate Batch with your own
// service worker. Please use batchsdk-worker-loader.js otherwise
function setupSharedBatchSDK() {
  // Try to load the SDK
  // If it fails, and we are in a shared SW, register an event listener to wait for the configuration
  // to arrive, and then attempt to reload the SDK once.
  let installEventToReplay = null;
  let sdkLoaded = false;
  function loadSDK() {
    if (sdkLoaded) {
      return Promise.resolve();
    }

    const request = indexedDB.open('BatchWebPush', 1);
    return new Promise((resolve, reject) => {
      request.onupgradeneeded = (event) => {
        // Create the schema, otherwise the DB will be in an unexpected state on the main page
        // Needs to be in sync with the SDK
        try {
          const db = event.target.result;
          db.createObjectStore('BatchKVData', { keyPath: 'k' });
        } catch (err) {
          reject(err);
        }
      };
      request.onsuccess = (event) => {
        try {
          const db = event.target.result;
          const query = db.transaction(['BatchKVData'], 'readonly').objectStore('BatchKVData').get('lastconfig');
          query.onsuccess = (qevent) => {
            const data = qevent.target.result;
            if (typeof data !== 'undefined') {
              const workerScriptUrl = data.value.internal.workerScriptUrl;
              if (/^https:\/\/(?:[^.]+\.)?via\.batch\.com\/.*$/i.test(workerScriptUrl)) {
                // Race condition safeguard
                if (!sdkLoaded) {
                  importScripts(workerScriptUrl);
                  if (installEventToReplay) {
                    self.handleBatchSDKEvent('install', installEventToReplay);
                    installEventToReplay = null;
                  }
                }
                sdkLoaded = true;
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
  }

  // In a shared SW, the initial load should return a new promise on failure,
  // which will wait on the SDK configuration to arrive
  let resolveConfigLoadPromise;
  const workerSDKReady = loadSDK().catch(() => {
    return new Promise((resolve, reject) => {
      // Don't let a promise hang for too long, as this might break SW updates
      const loadTimeout = setTimeout(() => {
        reject();
        resolveConfigLoadPromise = null;
      }, 30000);

      resolveConfigLoadPromise = (val) => {
        resolveConfigLoadPromise = null;
        clearTimeout(loadTimeout);
        resolve(val);
      };
    }).catch(() => {});
  });

  const eventsList = ['pushsubscriptionchange', 'push', 'notificationclick'];
  eventsList.forEach((eventName) => {
    self.addEventListener(eventName, (event) => {
      event.waitUntil(
        workerSDKReady
          .then(() => {
            return self.handleBatchSDKEvent(eventName, event);
          })
          .catch(() => {}) // SDK was not ready for the event
      );
    });
  });

  self.addEventListener('message', (event) => {
    if (resolveConfigLoadPromise && event.data === 'batchSDKConfigLoaded') {
      resolveConfigLoadPromise(loadSDK());
    } else {
      event.waitUntil(
        workerSDKReady
          .then(() => {
            return self.handleBatchSDKEvent('message', event);
          })
          .catch(() => {}) // SDK was not ready for the event
      );
    }
  });

  self.addEventListener('install', (event) => {
    workerSDKReady
      .then(() => {
        return self.handleBatchSDKEvent('install', event);
      })
      .catch(() => {
        // SDK was not ready for the event, enqueue it
        installEventToReplay = event;
      });
  });
}

setupSharedBatchSDK();
