<script>
	// export const ssr = false;
	// export const prerender = true;
	import '../app.css';
	import { connected, accountProvider as provider } from '$lib/provider';
	import { managerContract } from '$lib/store';
	import { ethers } from 'ethers';
	import { onMount } from 'svelte';
	import { PUBLIC_MANAGER_ADDRESS } from '$env/static/public';
	import Manager from '$lib/contracts/Manager.json';

	onMount(() => {
		// if (window.ethereum) {
		// 	window.ethereum.request({ method: 'eth_accounts' }).then((res) => {
		// 		// console.log({ res });
		// 		if (res.length > 0) {
		// 			provider.set(new ethers.providers.Web3Provider(window.ethereum));
		// 			managerContract.set(
		// 				new ethers.Contract(PUBLIC_MANAGER_ADDRESS, Manager.abi, $provider.getSigner())
		// 			);
		// 			console.log({ $connected, $provider });
		// 		}
		// 	});
		// }
	});
</script>

<slot />
