<script>
    import "uno.css";
    import Header from "$lib/component/Header.svelte";
    import { connected, accountProvider } from "$lib/provider";
    import {
        provider,
        applicationContract,
        managerContract,
        token,
    } from "$lib/store";
    import { ethers } from "ethers";
    import { onMount } from "svelte";
    import {
        PUBLIC_APPLICATION_ADDRESS,
        PUBLIC_MANAGER_ADDRESS,
    } from "$env/static/public";
    import Chaindoser from "$lib/contracts/Chaindoser.json";
    import Manager from "$lib/contracts/Manager.json";

    let hasSW = false;

    onMount(() => {
        // if ($provider) {
        //     applicationContract.set(
        //         new ethers.Contract(
        //             PUBLIC_APPLICATION_ADDRESS,
        //             Application.abi,
        //             $provider.getSigner()
        //         )
        //     );
        //     managerContract.set(
        //         new ethers.Contract(
        //             PUBLIC_MANAGER_ADDRESS,
        //             Manager.abi,
        //             $provider.getSigner()
        //         )
        //     );
        //     console.log($applicationContract);
        // }
        if (window.ethereum) {
            window.ethereum.request({ method: "eth_accounts" }).then((res) => {
                // console.log({ res });
                if (res.length > 0) {
                    provider.set(
                        new ethers.providers.Web3Provider(window.ethereum)
                    );
                    applicationContract.set(
                        new ethers.Contract(
                            PUBLIC_APPLICATION_ADDRESS,
                            Chaindoser.abi,
                            $provider.getSigner()
                        )
                    );
                    managerContract.set(
                        new ethers.Contract(
                            PUBLIC_MANAGER_ADDRESS,
                            Manager.abi,
                            $provider.getSigner()
                        )
                    );
                    console.log({
                        $connected,
                        $provider,
                        $applicationContract,
                        $managerContract,
                    });
                }
            });
        }
        if ("serviceWorker" in navigator) {
            // window.addEventListener("load", () => {
            navigator.serviceWorker
                .register("service-worker.js", { scope: "/" })
                .then(function (reg) {
                    // registration worked
                    console.log("Registration succeeded", reg);
                    hasSW = true;
                })
                .catch(function (error) {
                    // registration failed
                    console.log("Registration failed with " + error);
                });
            // });
        } else {
            console.log("serviceWorker not found");
        }

        token.set(localStorage.getItem("token"));
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
