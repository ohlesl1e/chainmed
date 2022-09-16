import { sveltekit } from '@sveltejs/kit/vite';

const config = {
    plugins: [sveltekit()],
    server: {
        host: true,
        proxy: {
            '/api': {
                target: 'http://localhost:4000',
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/api/, ''),
                secure: false,
            }
        },
    }
};

export default config;
