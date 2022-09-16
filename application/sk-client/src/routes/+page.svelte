<script>
	import svelteLogo from '../assets/svelte.svg';
	import viteLogo from '../assets/vite.svg';
	import { ethers } from 'ethers';
	import { SiweMessage } from 'siwe';
	import axios from 'axios';
	import { connectWallet } from '../lib/helper';

	const domain = window.location.host;
	const origin = window.location.origin;
	const provider = new ethers.providers.Web3Provider(window.ethereum);
	const signer = provider.getSigner();
	const BACKEND_ADDR = '/api';

	const createSiweMessage = async (address, statement) => {
		const res = await axios.get(`${BACKEND_ADDR}/nonce`, {
			withCredentials: true
		});
		const message = new SiweMessage({
			domain,
			address,
			statement,
			uri: origin,
			version: '1',
			chainId: 1,
			nonce: res.data.nonce
		});

		return {
			message: message.prepareMessage(),
			csrfToken: res.data.csrfToken
		};
	};

	const signInWithEthereum = async (type) => {
		const { message, csrfToken } = await createSiweMessage(
			await signer.getAddress(),
			'Sign in with Ethereum to the App'
		);
		const signature = await signer.signMessage(message);

		const res = await axios.post(
			`${BACKEND_ADDR}/login`,
			{ message, signature, type },
			{
				headers: {
					'Content-Type': 'application/json',
					'xsrf-token': csrfToken
				},
				withCredentials: true
			}
		);
		console.log(res.status);
	};
</script>

<div>
	<div>
		<a href="https://vitejs.dev" target="_blank">
			<img src={viteLogo} class="logo" alt="Vite Logo" />
		</a>
		<a href="https://svelte.dev" target="_blank">
			<img src={svelteLogo} class="logo svelte" alt="Svelte Logo" />
		</a>
	</div>
	<h1>Vite + Svelte</h1>

	<div class="card">
		<button on:click={() => connectWallet(provider)}>Connect Wallet</button>
		<button on:click={() => signInWithEthereum('patient')}>Patient Login</button>
		<button on:click={() => signInWithEthereum('doctor')}>Doctor Login</button>
	</div>
</div>

<style>
	.logo {
		height: 6em;
		padding: 1.5em;
		will-change: filter;
	}
	.logo:hover {
		filter: drop-shadow(0 0 2em #646cffaa);
	}
	.logo.svelte:hover {
		filter: drop-shadow(0 0 2em #ff3e00aa);
	}
</style>
