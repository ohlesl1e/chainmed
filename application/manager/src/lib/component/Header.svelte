<script>
    import { page } from "$app/stores";
    import logo from "$lib/assets/svelte.svg";
    import { connectMetamask, disconnect, connected } from "$lib/provider";
    import { token } from "$lib/store";
    import { onMount } from "svelte";

    const logout = async () => {
        localStorage.removeItem("token");
        token.set(undefined);
        window.location.href = "/";
        if ("serviceWorker" in navigator) {
            navigator.serviceWorker.controller.postMessage({
                tag: "clear",
            });
            let reg = await navigator.serviceWorker.getRegistration()
            let subscription = await reg.pushManager.getSubscription();
            console.log(subscription);
            if (subscription) {
                await fetch("/api/subscribe", {
                    method: "DELETE",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        endpoint: subscription.endpoint,
                    }),
                });
                subscription.unsubscribe();
            }
        }
    };

    onMount(async () => {});
</script>

<header>
    <div class="corner">
        <a href="/">
            <img src={logo} alt="SvelteKit" />
        </a>
    </div>

    <nav data-sveltekit-prefetch>
        <svg viewBox="0 0 2 3" aria-hidden="true">
            <path d="M0,0 L1,2 C1.5,3 1.5,3 2,3 L2,0 Z" />
        </svg>
        <ul>
            <li class:active={$page.url.pathname === ("/" || "/dashboard")}>
                <a href="/">Home</a>
            </li>
            <li class:active={$page.url.pathname === "/account"}>
                <a href="/account">Account</a>
            </li>
            <li class:active={$page.url.pathname === "/prescribe"}>
                <a href="/prescribe">Prescribe</a>
            </li>
        </ul>
        <svg viewBox="0 0 2 3" aria-hidden="true">
            <path d="M0,0 L0,3 C0.5,3 0.5,3 1,2 L2,0 Z" />
        </svg>
    </nav>

    <div class="corner">
        {#if $token}
            <button on:click={logout}>Logout</button>
        {/if}
        <!-- {#if !connected}
            <button on:click={connectMetamask}>Connect via MetaMask</button>
            <button on:click={connectWalletConnect}
                >Connect via WalletConnect</button
            >
        {/if} -->
        {#if $connected}
            <button on:click={disconnect}>Disconnect</button>
        {:else}
            <button on:click={connectMetamask}>Connect Wallet</button>
        {/if}
    </div>
</header>

<style>
    header {
        display: flex;
        justify-content: space-between;
        height: 48px;
        width: 95vw;
    }

    .corner {
        width: 15em;
        height: 3em;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .corner a {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 100%;
    }

    .corner img {
        width: 2em;
        height: 2em;
        object-fit: contain;
    }

    nav {
        display: flex;
        justify-content: center;
        --background: #646cff;
    }

    svg {
        width: 2em;
        height: 3em;
        display: block;
    }

    path {
        fill: var(--background);
    }

    ul {
        position: relative;
        padding: 0;
        margin: 0;
        height: 3em;
        display: flex;
        justify-content: center;
        align-items: center;
        list-style: none;
        background: var(--background);
        background-size: contain;
    }

    li {
        position: relative;
        height: 100%;
    }

    li.active::before {
        --size: 6px;
        content: "";
        width: 0;
        height: 0;
        position: absolute;
        top: 0;
        left: calc(50% - var(--size));
        border: var(--size) solid transparent;
        border-top: var(--size) solid var(--accent-color);
    }

    nav a {
        display: flex;
        height: 100%;
        align-items: center;
        padding: 0 1em;
        color: var(--heading-color);
        font-weight: 700;
        font-size: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        text-decoration: none;
        transition: color 0.2s linear;
    }

    a:hover {
        color: var(--accent-color);
    }
</style>
