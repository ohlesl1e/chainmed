import { sveltekit } from '@sveltejs/kit/vite';
import { extractorSvelte, presetAttributify, presetUno } from 'unocss';
import UnoCss from 'unocss/vite';

const config = {
    plugins: [
        sveltekit(),
        UnoCss({
            extractors: [extractorSvelte],
            shortcuts: {},
            presets: [
                presetUno(),
                presetAttributify()
            ]
        })
    ],
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
