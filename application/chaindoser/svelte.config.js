import adapter from '@sveltejs/adapter-node';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter(),
		csrf: {
			checkOrigin: true
		},
		serviceWorker: {
			register: true,
		},
		prerender: {
			enabled: false,
		},
	}
};

export default config;
