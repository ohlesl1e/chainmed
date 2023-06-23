<script>
    import "uno.css";
    import Header from "$lib/component/Header.svelte";
    import { connected, accountProvider as provider } from "$lib/provider";
    import { applicationContract, token } from "$lib/store";
    import { ethers } from "ethers";
    import { onMount } from "svelte";
    import { PUBLIC_APP_CONTRACT_ADDRESS } from "$env/static/public";
    import Application from "$lib/contracts/Application.json";
    let hasSW = false;

    onMount(() => {
        if ($provider) {
            applicationContract.set(
                new ethers.Contract(
                    PUBLIC_APP_CONTRACT_ADDRESS,
                    Application.abi,
                    $provider.getSigner()
                )
            );
            console.log($applicationContract);
        }
        if (window.ethereum) {
            window.ethereum.request({ method: "eth_accounts" }).then((res) => {
                // console.log({ res });
                if (res.length > 0) {
                    provider.set(
                        new ethers.providers.Web3Provider(window.ethereum)
                    );
                    applicationContract.set(
                        new ethers.Contract(
                            PUBLIC_APP_CONTRACT_ADDRESS,
                            Application.abi,
                            $provider.getSigner()
                        )
                    );
                }
            });
        }
        if ("serviceWorker" in navigator) {
            navigator.serviceWorker
                .register("service-worker.js", { scope: "/" })
                .then(function (reg) {
                    // registration worked
                    console.log(
                        "Registration succeeded. Scope is " + reg.scope
                    );
                    hasSW = true;
                })
                .catch(function (error) {
                    // registration failed
                    console.log("Registration failed with " + error);
                });
        } else {
            console.log("serviceWorker not found");
        }
        console.log({ $connected, $provider });

        token.set(sessionStorage.getItem("token"));
    });
</script>

<div>
    <Header />
    {#if !hasSW}
        <h1 style="text-align: center;">
            Service Worker not found. You will not be able to receive
            notification
        </h1>
    {/if}
</div>

<main class="flex justify-center mx-a px-5">
    <slot />
</main>

<style>
    main {
        min-height: calc(100vh - 48px);
        max-width: 1080px;
        text-align: start;
    }
</style>
