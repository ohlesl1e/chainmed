<script>
    import Header from '$lib/Header.svelte'
	import { ethers } from 'ethers';

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    console.log(provider.connection)
</script>

<div>
<Header provider={provider} connected={false}/>
</div>

<main>
    <slot></slot>
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
        overflow: auto;
    }

    footer {
        overflow: auto;
        height: 136px;
    }


	.read-the-docs {
		color: #888;
	}
</style>