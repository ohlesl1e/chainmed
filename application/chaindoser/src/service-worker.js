import { build, files, version } from '$service-worker';
const worker = self;
const FILES = `cache${version}`;
const to_cache = build.concat(files);
const staticAssets = new Set(to_cache);
let treatments = []
// listen for the install events
worker.addEventListener('install', (event) => {
    event.waitUntil(
        caches
            .open(FILES)
            .then((cache) => cache.addAll(to_cache))
            .then(() => {
                worker.skipWaiting();
            })
    );
});
// listen for the activate events
worker.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then(async (keys) => {
            // delete old caches
            for (const key of keys) {
                if (key !== FILES) await caches.delete(key);
            }
            worker.clients.claim();
        })
    );
    // event.waitUntil(
    //     self.registration.periodicSync.register('reminder-check', {
    //         minInterval: 6 * 60 * 60
    //     })
    // );
});
// attempt to process HTTP requests and rely on the cache if offline
async function fetchAndCache(request) {
    const cache = await caches.open(`offline${version}`);
    try {
        const response = await fetch(request);
        cache.put(request, response.clone());
        return response;
    } catch (err) {
        const response = await cache.match(request);
        if (response) return response;
        throw err;
    }
}
// listen for the fetch events
worker.addEventListener('fetch', (event) => {
    if (event.request.method !== 'GET' || event.request.headers.has('range')) return;
    const url = new URL(event.request.url);
    // only cache files that are local to your application
    const isHttp = url.protocol.startsWith('http');
    const isDevServerRequest =
        url.hostname === self.location.hostname && url.port !== self.location.port;
    const isStaticAsset = url.host === self.location.host && staticAssets.has(url.pathname);
    const skipBecauseUncached = event.request.cache === 'only-if-cached' && !isStaticAsset;
    if (isHttp && !isDevServerRequest && !skipBecauseUncached) {
        event.respondWith(
            (async () => {
                // always serve static files and bundler-generated assets from cache.
                // if your application has other URLs with data that will never change,
                // set this variable to true for them and they will only be fetched once.
                const cachedAsset = isStaticAsset && (await caches.match(event.request));
                return cachedAsset || fetchAndCache(event.request);
            })()
        );
    }
});

worker.addEventListener('push', async (event) => {
    let { title, body } = await event.data.json()
    console.log({ title, body })
    if (!(self.Notification && self.Notification.permission === 'granted')) {
        return
    }
    if (title === 'Reminder') {
        const id = body.split('for')[1].trim()
        showReminder(id)
    } else {
        self.registration.showNotification(title, {
            body
        })
    }

})

worker.addEventListener('notificationclick', event => {
    event.notification.close()

    clients.openWindow('https://chaindoser.lhackerman.duckdns.org/')
})

const showReminder = (id) => {
    if (self.Notification && self.Notification.permission === 'granted') {
        const treatment = treatments.find(value => value.id === id)
        if (treatment) {
            self.registration.showNotification("Medication Reminder", {
                body: `Remember to take ${treatment.medicine} for treatment ${id}`
            })
        }
    }
}

worker.addEventListener('periodicsync', async (event) => {
    console.log({ event, treatments })
    if (event.tag === "reminder-check") {
        for (const { id, schedule } of treatments) {
            try {
                const res = await fetch('/api/check', {
                    method: 'POST',
                    body: JSON.stringify({ address: id, schedule })
                })
                const reports = await res.json()
                if (schedule.frequency === 0) {
                    if (reports.length < schedule.timesOfDay.length) {
                        showReminder(id)
                    }
                }

                if (schedule.frequency === 1) {
                    if (reports.length < (schedule.timesOfDay.length * schedule.daysOfWeek.length)) {
                        showReminder(id)
                    }
                }
            } catch (error) {
                console.log(error);
            }
        }
    }
})

worker.addEventListener('sync', (event) => {
    console.log(event);
})

worker.addEventListener('message', event => {
    console.log({ treatments: event.data.treatments });
    switch (event.data.tag) {
        case "treatment-meta":
            treatments = event.data.treatments
            break;
        case "clear":
            treatments = undefined
        default:
            break;
    }
})