import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
// import fs from 'fs'

export default defineConfig({
	plugins: [sveltekit()],
	server: {
		port: 3000,
		host: true,
		// https: {
		// 	key: fs.readFileSync('./.cert/cert-key.pem'),
		// 	cert: fs.readFileSync('./.cert/cert.pem')
		// },
		cors: {
			origin: ['*://10.0.0.202:8545']
		}
	},
	preview: {
		host: true,
		port: 3000
	}
});
