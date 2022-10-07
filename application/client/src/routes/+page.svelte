<script>
    import { SiweMessage } from 'siwe';
    import axios from 'axios';
    import { getContext, onMount } from 'svelte';
    import { goto } from '$app/navigation';
    import { PUBLIC_API_PREFIX } from "$env/static/public";

    const domain = window.location.host;
    const origin = window.location.origin;
    const provider = getContext('provider');
    const signer = provider ? provider.getSigner() : undefined;

    onMount(() => {
        if (sessionStorage.getItem('token')) {
            goto('/dashboard');
        }
    });

    const createSiweMessage = async (address, statement) => {
        const res = await axios.get(`/${PUBLIC_API_PREFIX}/nonce`, {
            withCredentials: true,
        });
        const message = new SiweMessage({
            domain,
            address,
            statement,
            uri: origin,
            version: '1',
            chainId: 1,
            nonce: res.data.nonce,
        });

        return {
            message: message.prepareMessage(),
            csrfToken: res.data.csrfToken,
        };
    };

    const signInWithEthereum = async (type) => {
        const { message, csrfToken } = await createSiweMessage(
            await signer.getAddress(),
            'Sign in with Ethereum to the App'
        );
        const signature = await signer.signMessage(message);

        axios
            .post(
                `/${PUBLIC_API_PREFIX}/login`,
                { message, signature, type },
                {
                    headers: {
                        'Content-Type': 'application/json',
                        'xsrf-token': csrfToken,
                    },
                    withCredentials: true,
                }
            )
            .then((res) => {
                console.log(res.data);
                sessionStorage.setItem('token', res.data.token);
                goto('/dashboard')
            })
            .catch((err) => {
                console.log(err);
                switch (err.response.status) {
                    case 404:
                        if (type === 'doctor') {
                            alert('Login failed. Please try again');
                        } else {
                            goto(err.response.headers.location);
                        }
                        break;

                    default:
                        alert('Login failed. Please try again');
                        break;
                }
            });
    };
</script>

<div class="flex flex-col">
    <h1 class="text-4xl">Welcome! Please login with your wallet</h1>

    <div class="grid gap-4 sm:grid-cols-1 md:grid-cols-2">
        <div>
            <h2>For Patient</h2>
            <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla eu ex sed sem
                hendrerit accumsan. In hac habitasse platea dictumst. Lorem ipsum dolor sit amet,
                consectetur adipiscing elit. Sed mi nisi, viverra non eros ut, vestibulum imperdiet
                ante. Duis nulla metus, sollicitudin et augue nec, vulputate rhoncus tellus. Sed
                placerat urna eu ex bibendum hendrerit. Proin a gravida eros, dignissim scelerisque
                neque.
            </p>
            <button on:click={() => signInWithEthereum('patient')}>Patient Login</button>
        </div>
        <div>
            <h2>For Doctor</h2>
            <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla eu ex sed sem
                hendrerit accumsan. In hac habitasse platea dictumst. Lorem ipsum dolor sit amet,
                consectetur adipiscing elit. Sed mi nisi, viverra non eros ut, vestibulum imperdiet
                ante. Duis nulla metus, sollicitudin et augue nec, vulputate rhoncus tellus. Sed
                placerat urna eu ex bibendum hendrerit. Proin a gravida eros, dignissim scelerisque
                neque.
            </p>
            <button on:click={() => signInWithEthereum('doctor')}>Doctor Login</button>
        </div>
    </div>
</div>

<style>
    /* .logo {
        height: 6em;
        padding: 1.5em;
        will-change: filter;
    }
    .logo:hover {
        filter: drop-shadow(0 0 2em #646cffaa);
    }
    .logo.svelte:hover {
        filter: drop-shadow(0 0 2em #ff3e00aa);
    } */
</style>
