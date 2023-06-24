<script>
	import { goto } from '$app/navigation';
	import {
		accountChainId,
		connected,
		connectMetamask,
		connectWalletConnect,
		disconnect,
		walletAddress,
		accountProvider
	} from '$lib/provider';
	import { provider, managerContract } from '$lib/store';
	import { onMount } from 'svelte';
	import { utils, constants, Contract, providers } from 'ethers';
	import { PUBLIC_MANAGER_ADDRESS } from '$env/static/public';
	import Manager from '$lib/contracts/Manager.json';
	import PatientDash from '../lib/component/dash/PatientDash.svelte';
	import { sha256 } from 'js-sha256';

	let hasPatient = false;
	let patientAddress = undefined;
	let needKey = false;
	let key;

	onMount(async () => {
		console.log('onMount', { $accountProvider, $provider });
		// provider.set(new providers.Web3Provider($accountProvider));
		// managerContract.set(new Contract(PUBLIC_MANAGER_ADDRESS, Manager.abi, $provider.getSigner()));
		// console.log({ $connected, $provider });
	});

	const loadContract = () => {
		console.log('loading contract', { $accountProvider, $provider });
		managerContract.set(new Contract(PUBLIC_MANAGER_ADDRESS, Manager.abi, $provider.getSigner()));
		console.log({ $connected, $provider, $managerContract });
	};

	const loadPatient = async () => {
		console.log('load patient', $provider);
		try {
			console.log({ $managerContract });
			let address = await $managerContract.getPatient($walletAddress);
			console.log({ address });
			if (utils.isAddress(address) && address === constants.AddressZero) {
				console.log('This is a zero address.');
				patientAddress = constants.AddressZero;
			} else {
				let hasKey = await checkKeys();
				if (hasKey) {
					hasPatient = true;
					patientAddress = address;
					console.log({ hasPatient, patientAddress });
				} else {
					needKey = true;
				}
			}
		} catch (error) {
			console.log(error);
		}
	};

	const checkKeys = async () => {
		let key = localStorage.getItem('key');
		let iv = localStorage.getItem('iv');
		console.log({ key, iv });
		let hash = sha256.update(await $provider.getSigner().getAddress());
		let signerIv = new Uint32Array(hash.arrayBuffer());

		if (key === null || iv === null) {
			return false;
		}

		try {
			console.log({ iv, signerIv });
			if (iv === signerIv.join()) {
				return true;
			}
		} catch (error) {
			console.log(error);
		}
		return false;
	};

	const saveKey = async () => {
		let hash = sha256.update(await $provider.getSigner().getAddress());
		let signerIv = new Uint32Array(hash.arrayBuffer());

		try {
			console.log({ key, signerIv });
			key = new Uint32Array(key.split(','));
			localStorage.setItem('key', key.join());
			localStorage.setItem('iv', signerIv.join());
			needKey = false;
			loadPatient();
		} catch (error) {
			alert('invalid key');
			console.log(error);
		}
	};

	$: {
		if ($provider) {
			loadContract();
		}
	}

	$: {
		if ($walletAddress !== constants.AddressZero && $connected && $managerContract) {
			console.log({
				address: $walletAddress,
				provider: $provider,
				connected: $connected
			});
			loadPatient();
		}
	}
</script>

<main class="flex flex-col p-10 w-screen h-screen items-center gap-5 font-serif">
	<h1 class="text-5xl text-black font-bold">Health Record Manager</h1>

	<section class="flex flex-col min-w-[50vw] p-10 items-start gap-5 border-2 rounded-xl">
		<h1 class="text-2xl text-black font-bold">Wallet and Provider</h1>
		<h2 class="text-xl text-black font-semibold">$connected: {$connected}</h2>
		<h2 class="text-xl text-black font-semibold">$walletAddress: {$walletAddress}</h2>
		<h2 class="text-xl text-black font-semibold">
			$accountChainId: {JSON.stringify($accountChainId)}
		</h2>
		{#if $connected}
			<div class="flex justify-between w-full">
				{#if patientAddress === constants.AddressZero}
					<a href="/new-patient">
						<button
							class="p-3 rounded-xl text-xl bg-blue-500 text-white font-semibold hover:scale-[1.05] transition transition-200"
							>Register
						</button>
					</a>
				{/if}
				<button
					on:click={disconnect}
					class="p-3 rounded-xl text-xl bg-black text-white font-semibold hover:scale-[1.05] transition transition-200"
					>Disconnect</button
				>
			</div>
		{:else}
			<button
				on:click={connectMetamask}
				class="p-3 rounded-xl text-xl bg-black text-white font-semibold hover:scale-[1.05] transition transition-200"
				>Connect via MetaMask</button
			>
			<button
				on:click={connectWalletConnect}
				class="p-3 rounded-xl text-xl bg-black text-white font-semibold hover:scale-[1.05] transition transition-200"
				>Connect via WalletConnect</button
			>
		{/if}
	</section>
	{#if needKey}
		<form on:submit={saveKey}>
			<label for="" class="block text-gray-700 font-bold mb-2">Enter your key</label>
			<div class="flex gap-2">
				<input
					class="shadow appearance-none border rounded w-[65ch] py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
					type="password"
					bind:value={key}
				/>
				<button
					class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
					type="submit">Save</button
				>
			</div>
		</form>
	{/if}
	{#if patientAddress && patientAddress !== constants.AddressZero}
		<section class="flex flex-col p-10 items-start gap-5 border-2 rounded-xl">
			<h1 class="text-2xl text-black font-bold">Patient Profile</h1>
			<PatientDash {patientAddress} />
		</section>
	{/if}
</main>
