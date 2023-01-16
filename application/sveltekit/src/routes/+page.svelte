<script>
    import { SiweMessage } from "siwe";
    import axios from "axios";
    import { onMount } from "svelte";
    import { accountProvider as provider } from "$lib/provider";
    import { token } from "$lib/store";
    import { goto } from "$app/navigation";

    const domain = window.location.host;
    const origin = window.location.origin;

    onMount(async () => {
        token.set(sessionStorage.getItem("token"));
        if ($token) {
            goto("/dashboard");
            // }
            // try {
            //     let reg = await navigator.serviceWorker.getRegistration();
            //     let notiPerm = await Notification.requestPermission();

            //     if (notiPerm !== "granted") {
            //         throw "Notification permission not granted";
            //     }

            //     if (!(await reg.pushManager.getSubscription())) {
            //         const subscription = await reg.pushManager.subscribe({
            //             userVisibleOnly: true,
            //             applicationServerKey: PUBLIC_PUSH_KEY,
            //         });

            //         fetch("/api/subscribe", {
            //             method: "POST",
            //             headers: { "Content-Type": "application/json" },
            //             body: JSON.stringify({
            //                 subscription,
            //                 address: "0x2bF706cCf47878F46DF7618F4634cBcA3e38b89D",
            //             }),
            //         })
            //             .then((res) => res.json())
            //             .then((data) => console.log(data));
            //     }

            // let timestamp = new Date().getTime() + 10 * 1000;
            // let notificationOpt = {
            //     tag: timestamp,
            //     body: "get some notification",
            //     timestamp: timestamp,
            //     data: {
            //         url: window.location.href,
            //     },
            // };
            // navigator.permissions
            //     .query({
            //         name: "periodic-background-sync",
            //     })
            //     .then((permission) => {
            //         if (permission.state === "granted") {
            //             navigator.serviceWorker.ready.then(
            //                 async (registration) => {
            //                     if ("periodicSync" in registration) {
            //                         registration.periodicSync
            //                             .register("test-notification", {
            //                                 minInterval: 60 * 1000,
            //                             })
            //                             .catch((err) => {
            //                                 console.log(err);
            //                             });
            //                         registration.periodicSync
            //                             .register("test-multiple", {
            //                                 minInterval: 120 * 1000,
            //                             })
            //                             .catch((err) => {
            //                                 console.log(err);
            //                             });
            //                         registration.periodicSync
            //                             .getTags()
            //                             .then((tags) => console.log(tags));
            //                     }
            //                 }
            //             );
            //         }
            //     });
            // } catch (error) {
            //     console.log(error);
        }
    });

    const createSiweMessage = async (address, statement) => {
        const res = await axios.get(`/api/nonce`, {
            withCredentials: true,
        });
        const message = new SiweMessage({
            domain,
            address,
            statement,
            uri: origin,
            version: "1",
            chainId: 5777,
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
                sessionStorage.setItem("token", res.data.token);
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
    <h1 class="text-4xl">Welcome! Please login with your wallet</h1>

    <div class="grid gap-4 sm:grid-cols-1 md:grid-cols-2">
        <div>
            <h2>For Patient</h2>
            <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla
                eu ex sed sem hendrerit accumsan. In hac habitasse platea
                dictumst. Lorem ipsum dolor sit amet, consectetur adipiscing
                elit. Sed mi nisi, viverra non eros ut, vestibulum imperdiet
                ante. Duis nulla metus, sollicitudin et augue nec, vulputate
                rhoncus tellus. Sed placerat urna eu ex bibendum hendrerit.
                Proin a gravida eros, dignissim scelerisque neque.
            </p>
            <button on:click={() => signInWithEthereum("patient")}
                >Patient Login</button
            >
        </div>
        <div>
            <h2>For Doctor</h2>
            <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla
                eu ex sed sem hendrerit accumsan. In hac habitasse platea
                dictumst. Lorem ipsum dolor sit amet, consectetur adipiscing
                elit. Sed mi nisi, viverra non eros ut, vestibulum imperdiet
                ante. Duis nulla metus, sollicitudin et augue nec, vulputate
                rhoncus tellus. Sed placerat urna eu ex bibendum hendrerit.
                Proin a gravida eros, dignissim scelerisque neque.
            </p>
            <button on:click={() => signInWithEthereum("doctor")}
                >Doctor Login</button
            >
        </div>
    </div>
</div>
