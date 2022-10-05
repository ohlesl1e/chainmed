<script>
	import 'uno.css';
	import Header from '$lib/Header.svelte';
	import { ethers } from 'ethers';
	import { setContext } from 'svelte';

	let provider;

	if (window.ethereum) {
		provider = new ethers.providers.Web3Provider(window.ethereum);
	}


	setContext('provider', provider);
</script>

<div>
	<Header {provider} connected={window.ethereum.isConnected()} />
</div>

<main class="flex items-center justify-center mx-a px-5">
	<slot />
</main>

<footer>
	<p>
		Check out <a href="https://github.com/sveltejs/kit#readme" target="_blank">SvelteKit</a>, the
		official Svelte app framework powered by Vite!
	</p>

	<p class="read-the-docs">Click on the Vite and Svelte logos to learn more</p>
</footer>

<style>
	main {
		min-height: calc(100vh - 48px - 136px);
		max-width: 1080px;
        text-align: start;
		/* overflow: auto; */
	}

	footer {
		overflow: auto;
		height: 136px;
	}

	.read-the-docs {
		color: #888;
	}
</style>
