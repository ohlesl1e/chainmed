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

	let hasPatient = false;
	let patientAddress = undefined;

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
				hasPatient = true;
				patientAddress = address;
				console.log({ hasPatient, patientAddress });
			}
		} catch (error) {
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
	{#if patientAddress && patientAddress !== constants.AddressZero}
		<section class="flex flex-col p-10 items-start gap-5 border-2 rounded-xl">
			<h1 class="text-2xl text-black font-bold">Patient Profile</h1>
			<PatientDash {patientAddress} />
		</section>
	{/if}
</main>
