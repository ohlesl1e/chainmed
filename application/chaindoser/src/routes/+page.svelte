<script>
    import { SiweMessage } from "siwe";
    import axios from "axios";
    import { onMount } from "svelte";
    import DoctorDash from "$lib/component/dash/DoctorDash.svelte";
    import PatientDash from "$lib/component/dash/PatientDash.svelte";
    import { provider } from "$lib/store";
    import { token } from "$lib/store";
    import { goto } from "$app/navigation";
    import { PUBLIC_PUSH_KEY } from "$env/static/public";

    let type;
    let init = false;
    const domain = window.location.host;
    const origin = window.location.origin;
    // token.set(localStorage.getItem("token"));

    // token.subscribe((value) => {
    //     console.log({
    //         token: value,
    //         type,
    //         init,
    //     });
    //     if ($provider && !init && value) {
    //         let jwt = JSON.parse(atob(value.split(".")[1]));
    //         type = jwt.type;
    //         init = true;
    //     }
    // });

    onMount(async () => {
        token.set(localStorage.getItem("token"));
        // if ($token) {
        //     goto("/dashboard");
        // }
        // console.log({
        //     provider: $provider,
        //     token: $token,
        //     type,
        //     init,
        // });
        // if ($provider && !init && $token) {
        //     let jwt = JSON.parse(atob($token.split(".")[1]));
        //     type = jwt.type;
        //     init = true;
        //     console.log({
        //         token: $token,
        //         type,
        //         init,
        //     });
        // }
        try {
            let reg = await navigator.serviceWorker.getRegistration();
            let notiPerm = await Notification.requestPermission();

            if (notiPerm !== "granted") {
                throw "Notification permission not granted";
            }

            // if (!(await reg.pushManager.getSubscription())) {
            //     const subscription = await reg.pushManager.subscribe({
            //         userVisibleOnly: true,
            //         applicationServerKey: PUBLIC_PUSH_KEY,
            //     });

                // fetch("/api/subscribe", {
                //     method: "POST",
                //     headers: { "Content-Type": "application/json" },
                //     body: JSON.stringify({
                //         subscription,
                //         address: "0x2bF706cCf47878F46DF7618F4634cBcA3e38b89D",
                //     }),
                // })
                //     .then((res) => res.json())
                //     .then((data) => console.log(data));
            // }
        } catch (error) {
            console.log(error);
        }
    });

    $: {
        // console.log({
        //     provider: $provider,
        //     token: $token,
        //     type,
        //     init,
        // });
        if ($token && $provider && !init) {
            let jwt = JSON.parse(atob($token.split(".")[1]));
            type = jwt.type;
            init = true;
            console.log({
                provider: $provider,
                token: $token,
                type,
                init,
            });
        }
    }

    const createSiweMessage = async (address, statement) => {
        const res = await axios.get(`/api/nonce`, {
            withCredentials: true,
        });
        console.log(await $provider.getNetwork());
        const message = new SiweMessage({
            domain,
            address,
            statement,
            uri: origin,
            version: "1",
            chainId: (await $provider.getNetwork()).chainId,
            nonce: res.data.nonce,
        });

        return {
            message: message.prepareMessage(),
        };
    };

    const signInWithEthereum = async (type) => {
        const { message } = await createSiweMessage(
            await $provider.getSigner().getAddress(),
            "Sign in with Ethereum to the App"
        );
        const signature = await $provider.getSigner().signMessage(message);

        axios
            .post(
                `/api/login`,
                { message, signature, type },
                {
                    headers: {
                        "Content-Type": "application/json",
                        // "xsrf-token": csrfToken,
                    },
                    // withCredentials: true,
                }
            )
            .then((res) => {
                console.log(res.data);
                localStorage.setItem("token", res.data.token);
                token.set(res.data.token);
                window.location.href = "/";
            })
            .catch((err) => {
                console.log(err);
                switch (err.response.status) {
                    case 404:
                        if (type === "doctor") {
                            alert(
                                "Login failed. Please try again, or contact administrator"
                            );
                        } else {
                            goto(err.response.headers.location);
                        }
                        break;

                    default:
                        alert("Login failed. Please try again");
                        break;
                }
            });
    };
</script>

<div class="flex flex-col">
    {#if $token}
        {#if type === "doctor"}
            <DoctorDash />
        {:else if type === "patient"}
            <PatientDash />
        {/if}
    {:else}
        <!-- else content here -->

        <h1 class="text-4xl">Welcome! Please login with your wallet</h1>

        <div class="grid gap-4 sm:grid-cols-1 md:grid-cols-2">
            <div>
                <h2>For Patient</h2>
                <p>
                    Never miss a dose again - Keep track of your medications
                    with ease.
                </p>
                <button on:click={() => signInWithEthereum("patient")}
                    >Patient Login</button
                >
            </div>
            <div>
                <h2>For Doctor</h2>
                <p>
                    Keeping your patients healthy, one dose at a time - Track
                    your patients' medications with ease.
                </p>
                <button on:click={() => signInWithEthereum("doctor")}
                    >Doctor Login</button
                >
            </div>
        </div>
    {/if}
</div>
