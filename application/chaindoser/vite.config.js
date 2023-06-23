import { sveltekit } from '@sveltejs/kit/vite';
import { extractorSvelte, presetUno } from 'unocss';
import UnoCss from 'unocss/vite';
import fs from 'fs'

/** @type {import('vite').UserConfig} */
const config = {
	plugins: [
		sveltekit(),
		UnoCss({
			extractors: [extractorSvelte],
			shortcuts: {},
			presets: [
				presetUno(),
			]
		}),
	],
	server: {
		port: 4000,
		host: true,
		https: {
			key: fs.readFileSync('./.cert/cert-key.pem'),
			cert: fs.readFileSync('./.cert/cert.pem'),
		},
		cors: {
			origin: ['*://10.0.0.202:8545/', 'https://*.lhackerman.duckdns.org/', 'https://manager.lhackerman.duckdns.org/']
		}
	},
	build: {
		minify: false
	},
	preview: {
		host: true,
		port: 4000
	}
};

export default config;
