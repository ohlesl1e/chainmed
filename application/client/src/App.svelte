<script>
    import svelteLogo from "./assets/svelte.svg";
    import { ethers } from "ethers";
    import { SiweMessage } from "siwe";
    import axios from "axios";

    const domain = window.location.host;
    const origin = window.location.origin;
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const BACKEND_ADDR = "/api";

    const createSiweMessage = async (address, statement) => {
        const res = await axios.get(`${BACKEND_ADDR}/nonce`, {
            withCredentials: true,
        });
        const message = new SiweMessage({
            domain,
            address,
            statement,
            uri: origin,
            version: "1",
            chainId: 1,
            nonce: res.data.nonce,
        });

        return {
            message: message.prepareMessage(),
            csrfToken: res.data.csrfToken,
        };
    };

    const connectWallet = () => {
        provider
            .send("eth_requestAccounts", [])
            .catch(() => console.log("user rejected request"));
    };

    const signInWithEthereum = async () => {
        const { message, csrfToken } = await createSiweMessage(
            await signer.getAddress(),
            "Sign in with Ethereum to the App"
        );

        const signature = await signer.signMessage(message);

        const res = await axios.post(
            `${BACKEND_ADDR}/login`,
            { message, signature },
            {
                headers: {
                    "Content-Type": "application/json",
                    "xsrf-token": csrfToken,
                },
                withCredentials: true,
            }
        );
        console.log(await res.data);
    };
</script>

<main>
    <div>
        <a href="https://vitejs.dev" target="_blank">
            <img src="/vite.svg" class="logo" alt="Vite Logo" />
        </a>
        <a href="https://svelte.dev" target="_blank">
            <img src={svelteLogo} class="logo svelte" alt="Svelte Logo" />
        </a>
    </div>
    <h1>Vite + Svelte</h1>

    <div class="card">
        <button on:click={connectWallet}>Connect Wallet</button>
        <button on:click={signInWithEthereum}>Login</button>
    </div>

    <p>
        Check out <a
            href="https://github.com/sveltejs/kit#readme"
            target="_blank">SvelteKit</a
        >, the official Svelte app framework powered by Vite!
    </p>

    <p class="read-the-docs">
        Click on the Vite and Svelte logos to learn more
    </p>
</main>

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
    .read-the-docs {
        color: #888;
    }
</style>
