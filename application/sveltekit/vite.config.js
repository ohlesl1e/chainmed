import { sveltekit } from '@sveltejs/kit/vite';
import { extractorSvelte, presetUno } from 'unocss';
import UnoCss from 'unocss/vite';
import fs from 'fs'

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
		https: {
			key: fs.readFileSync('./.cert/cert-key.pem'),
			cert: fs.readFileSync('./.cert/cert.pem')
		}
	},
	build: {
		minify: false
	}
};

export default config;
