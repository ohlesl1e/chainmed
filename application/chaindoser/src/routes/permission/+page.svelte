<script>
    import { patientContract, applicationContract, token } from "$lib/store";
    import { provider } from "$lib/store";
    import axios from "axios";
    import { goto } from "$app/navigation";
    import { DoubleBounce } from "svelte-loading-spinners";

    let loading = false;

    const handleSubmit = async () => {
        loading = true;

        try {
            const role = await $patientContract.APPLICATION_ROLE();
            const tx = await $patientContract.grantRole(
                role,
                $applicationContract.address
            );
            const receipt = await tx.wait();
            console.log({ receipt });
            if (receipt.events[0].event === "RoleGranted") {
                axios
                    .post(
                        `/api/signup`,
                        { address: await $provider.getSigner().getAddress() },
                        {
                            headers: {
                                "Content-Type": "application/json",
                                // "xsrf-token": preflight.data.csrfToken,
                            },
                            withCredentials: true,
                        }
                    )
                    .then(async (res) => {
                        console.log(res.data);
                        loading = false;
                        localStorage.setItem("token", res.data.token);
                        token.set(res.data.token);
                        window.location.href = "/";
                    })
                    .catch((err) => {
                        console.log(err);
                    });
            } else {
                loading = false;
                handleLogout();
            }
        } catch (error) {
            console.log(error);
            handleLogout();
        }
    };

    const handleLogout = async () => {
        localStorage.removeItem("token");
        token.set(undefined);
        // window.location.href = "/";
        if ("serviceWorker" in navigator) {
            try {
                navigator.serviceWorker.controller.postMessage({
                    tag: "clear",
                });
                let reg = await navigator.serviceWorker.getRegistration();
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
            } catch (error) {
                goto("/");
            }
        }
        goto("/");
    };
</script>

<div>
    <form
        class="flex flex-col p-10 items-start gap-5 border-2 rounded-xl"
        on:submit|preventDefault={handleSubmit}
    >
        <h1>Access requested</h1>
        <h2>
            This application is requesting permission to add treatments to your
            record
        </h2>
        <p>
            Learn more about this application <a
                href={`https://etherscan.io/address/${$applicationContract.address}`}
                target="_blank"
                rel="noreferrer">here</a
            >
        </p>
        <div>
            <button type="button" on:click={handleLogout}>Cancel</button>
            <button type="submit">Accept</button>
            {#if loading}
                <DoubleBounce size="40" />
            {/if}
        </div>
    </form>
</div>
