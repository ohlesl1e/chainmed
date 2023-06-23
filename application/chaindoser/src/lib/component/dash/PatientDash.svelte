<script>
    import { SiweMessage } from "siwe";
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";
    import Patient from "$lib/contracts/Patient.json";
    import Doctor from "$lib/contracts/Doctor.json";
    import Treatment from "$lib/contracts/Treatment.json";
    import { provider } from "$lib/store";
    import { ethers, utils, BigNumber } from "ethers";
    import {
        applicationContract,
        patientContract,
        managerContract,
        token,
    } from "$lib/store";
    import { PUBLIC_PUSH_KEY, PUBLIC_PORT } from "$env/static/public";
    // import { QRious } from "@phippsytech/svelte-qrious";

    let profile;
    const domain = window.location.host;
    const origin = window.location.origin;
    let init = false;

    let reportQueue = [];

    // onMount(async () => {
    // let token = sessionStorage.getItem("token").split(".");
    const initialize = async () => {
        let patientAddress = JSON.parse(atob($token.split(".")[1])).address;
        patientContract.set(
            new ethers.Contract(
                patientAddress,
                Patient.abi,
                $provider.getSigner()
            )
        );

        try {
            checkPermission();
            const info = await $patientContract.getInfo();
            console.log({ info });
            profile = {
                id: patientAddress,
                name: utils.parseBytes32String(info[0][0]),
                gender: utils.parseBytes32String(info[0][1]),
                age:
                    new Date().getFullYear() -
                    new Date(
                        BigNumber.from(info[1]).toNumber() * 1000
                    ).getFullYear(),
                height: info[2][0],
                weight: info[2][1] / 100,
                allergy: info[3],
                alcohol: info[4][0],
                smoke: info[4][1],
                cannabis: info[4][2],
                treatments: [],
                requests: info[6] ? info[6] : [],
            };
            console.log("Before populating treatments", { profile });
            const temp = [];
            for (const treatment of info[5]) {
                const treatmentContract = new ethers.Contract(
                    treatment,
                    Treatment.abi,
                    $provider.getSigner()
                );
                const treatmentData = await treatmentContract.getTreatment();
                console.log(profile.treatments);
                temp.push({
                    id: treatment,
                    completed:
                        Date.now() -
                            new Date(
                                BigNumber.from(treatmentData[3][1]).toNumber()
                            ).getTime() >
                        0,
                    medicine: treatmentData[0],
                    form: utils.parseBytes32String(treatmentData[1]),
                    dosage: {
                        strength: treatmentData[2][0],
                        unit: utils.parseBytes32String(treatmentData[2][1]),
                    },
                    schedule: {
                        startDate: new Date(
                            BigNumber.from(treatmentData[3][0]).toNumber()
                        ).toLocaleDateString(),
                        endDate: new Date(
                            BigNumber.from(treatmentData[3][1]).toNumber()
                        ).toLocaleDateString(),
                        frequency: treatmentData[3][2],
                        interval: treatmentData[3][3],
                        daysOfWeek: treatmentData[3][4].map((treatmentData) =>
                            utils.parseBytes32String(treatmentData)
                        ),
                        timesOfDay: treatmentData[3][5].map((treatmentData) => {
                            return `${String(
                                Math.floor(treatmentData / 100)
                            ).padStart(2, "0")}:${String(
                                treatmentData % 100
                            ).padStart(2, "0")}`;
                        }),
                    },
                });
                // profile.treatments = [
                //     ...profile.treatments,
                //     {
                //         id: treatment,
                //         completed:
                //             Date.now() -
                //                 new Date(
                //                     BigNumber.from(
                //                         treatmentData[3][1]
                //                     ).toNumber()
                //                 ).getTime() >
                //             0,
                //         medicine: treatmentData[0],
                //         form: utils.parseBytes32String(treatmentData[1]),
                //         dosage: {
                //             strength: treatmentData[2][0],
                //             unit: utils.parseBytes32String(treatmentData[2][1]),
                //         },
                //         schedule: {
                //             startDate: new Date(
                //                 BigNumber.from(treatmentData[3][0]).toNumber()
                //             ).toLocaleDateString(),
                //             endDate: new Date(
                //                 BigNumber.from(treatmentData[3][1]).toNumber()
                //             ).toLocaleDateString(),
                //             frequency: treatmentData[3][2],
                //             interval: treatmentData[3][3],
                //             daysOfWeek: treatmentData[3][4].map(
                //                 (treatmentData) =>
                //                     utils.parseBytes32String(treatmentData)
                //             ),
                //             timesOfDay: treatmentData[3][5].map(
                //                 (treatmentData) => {
                //                     return `${String(
                //                         Math.floor(treatmentData / 100)
                //                     ).padStart(2, "0")}:${String(
                //                         treatmentData % 100
                //                     ).padStart(2, "0")}`;
                //                 }
                //             ),
                //         },
                //     },
                // ];
            }

            if (info[6].length) {
                let tempRequest = [];
                for (const request of info[6]) {
                    const doctorAddress = await $managerContract.getDoctor(
                        request
                    );
                    const doctorContract = new ethers.Contract(
                        doctorAddress,
                        Doctor.abi,
                        $provider.getSigner()
                    );
                    console.log({ request, doctorAddress });
                    try {
                        const doctorInfo = await doctorContract.getInfo();
                        console.log({
                            address: request,
                            res: doctorInfo,
                            name: utils.parseBytes32String(doctorInfo[0]),
                            affiliate: utils.parseBytes32String(doctorInfo[1]),
                        });
                        tempRequest.push({
                            address: request,
                            name: utils.parseBytes32String(doctorInfo[0]),
                            affiliate: utils.parseBytes32String(doctorInfo[1]),
                        });
                        profile.requests = [
                            ...profile.requests,
                            {
                                address: request,
                                name: utils.parseBytes32String(doctorInfo[0]),
                                affiliate: utils.parseBytes32String(
                                    doctorInfo[1]
                                ),
                            },
                        ];
                    } catch (error) {
                        console.log(error);
                    }
                }
                profile.requests = tempRequest;
            }

            profile.treatments = temp;
            console.log("after populating treatments", {
                treatments: profile.treatments,
                init,
            });
            init = true;
        } catch (error) {
            console.log(error);
        }
        if ("serviceWorker" in navigator) {
            try {
                let reg = await navigator.serviceWorker.getRegistration();
                let permission = await Notification.requestPermission();
                if (permission !== "granted") {
                    throw "Notification permission not granted";
                }
                let subscription = await reg.pushManager.getSubscription();
                // console.log("Check old sub", { subscription });
                let needUpdate = true;
                if (subscription) {
                    try {
                        let res = await fetch(
                            `/api/subscribe?address=${await $provider
                                .getSigner()
                                .getAddress()}&endpoint=${
                                subscription.endpoint
                            }`
                        );
                        // console.log(res);
                        if (res.status === 200) {
                            needUpdate = false;
                        }
                    } catch (error) {
                        // console.log({error});
                    }
                } else {
                    subscription = await reg.pushManager.subscribe({
                        userVisibleOnly: true,
                        applicationServerKey: PUBLIC_PUSH_KEY,
                    });
                }
                // console.log("Confirm sub", { subscription });
                if (needUpdate) {
                    fetch("/api/subscribe", {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({
                            subscription,
                            address: await $provider.getSigner().getAddress(),
                        }),
                    });
                }

                // Periodic sync
                if ("SyncManager" in window) {
                    navigator.permissions
                        .query({
                            name: "periodic-background-sync",
                        })
                        .then(async (permission) => {
                            console.log(permission);
                            if (permission.state === "granted") {
                                const registration = await navigator
                                    .serviceWorker.ready;
                                if ("periodicSync" in registration) {
                                    const tags =
                                        await registration.periodicSync.getTags();
                                    if (!tags.includes("reminder-check")) {
                                        // Request permission for background sync
                                        await registration.periodicSync.register(
                                            "reminder-check",
                                            {
                                                // Adjust the minimum interval to 6 hours (in seconds)
                                                minInterval: 6 * 60 * 60,
                                            }
                                        );
                                    }
                                    registration.periodicSync
                                        .getTags()
                                        .then((tags) => console.log(tags));
                                    // registration.periodicSync
                                    //     .register("test-notification", {
                                    //         minInterval: 60 * 1000,
                                    //     })
                                    //     .catch((err) => {
                                    //         console.log(err);
                                    //     });
                                    // registration.periodicSync
                                    //     .register("test-multiple", {
                                    //         minInterval: 120 * 1000,
                                    //     })
                                    //     .catch((err) => {
                                    //         console.log(err);
                                    //     });
                                    // registration.periodicSync
                                    //     .register("reminder-check", {
                                    //         minInterval: 60 * 60 * 1000,
                                    //     })
                                    //     .catch((err) => {
                                    //         console.log(err);
                                    //     });
                                    // registration.periodicSync
                                    //     .getTags()
                                    //     .then((tags) => console.log(tags));
                                }
                            }
                        });
                }
            } catch (error) {
                console.log(error);
            }
        }
    };
    // });

    const checkPermission = async () => {
        const role = await $patientContract.APPLICATION_ROLE();
        // console.log({role,application: $applicationContract.address});
        const hasPermission = await $patientContract.hasRole(
            role,
            $applicationContract.address
        );
        console.log({
            role,
            application: $applicationContract.address,
            hasPermission,
        });
        if (!hasPermission) {
            goto("/permission");
        }
    };

    const createSiweMessage = async (address, statement) => {
        const res = await fetch(`/api/nonce`);
        const data = await res.json();
        const message = new SiweMessage({
            domain,
            address,
            statement,
            uri: origin,
            version: "1",
            chainId: (await $provider.getNetwork()).chainId,
            nonce: data.nonce,
        });

        return message.prepareMessage();
    };

    const report = async () => {
        const message = await createSiweMessage(
            await $provider.getSigner().getAddress(),
            "Reporting medicine"
        );

        const signature = await $provider.getSigner().signMessage(message);

        try {
            console.log({ reportQueue });
            let result = await fetch("/api/report", {
                method: "POST",
                body: JSON.stringify({
                    message,
                    signature,
                    treatments: reportQueue,
                }),
            });

            console.log(await result.json());

            reportQueue = [];
        } catch (error) {
            console.log(error);
        }
    };

    const giveAccess = (doctor) => {
        console.log(doctor);
        $patientContract
            .acceptRequest(doctor)
            .then(async (res) => {
                await res.wait();
                profile.requests = profile.requests.filter(
                    (value) => value.address !== doctor
                );
                fetch("/api/push", {
                    method: "POST",
                    body: JSON.stringify({
                        address: doctor,
                        access: "granted",
                    }),
                });
                console.log({ res, requests: profile.requests });
            })
            .catch((err) => {
                console.log(err);
            });
    };

    const updateTreatments = async () => {
        if ("serviceWorker" in navigator) {
            console.log(profile.treatments);
            let reg = await navigator.serviceWorker.getRegistration();
            reg.active.postMessage({
                tag: "treatment-meta",
                treatments: profile.treatments
                    .filter((value) => !value.completed)
                    .map((value) => {
                        return {
                            id: value.id,
                            medicine: value.medicine,
                            schedule: value.schedule,
                        };
                    }),
            });
        }
    };

    $: {
        if ($provider && $token) {
            initialize();
        }
    }

    $: {
        if (profile && profile.treatments) {
            console.log("update service worker", {
                init,
                treatments: profile.treatments,
            });
            // profile.treatments.onChange()
            if (init) {
                updateTreatments();
            }
        }
    }
</script>

<div class="flex flex-col">
    <h1 class="text-5xl">Patient dashboard</h1>
    <div class="grid gap-5 sm:grid-cols-1 md:grid-cols-2">
        <div>
            <div class="flex justify-between items-center">
                <h2>Info</h2>
                <button
                    on:click={() =>
                        (window.location.href = `https://manager.lhackerman.duckdns.org/`)}
                    >Edit</button
                >
            </div>

            {#if profile}
                <div class="grid grid-cols-2">
                    <div class="justify-around mb-3">
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Name:</h3>
                            <h4 class="m-1">{profile.name}</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Gender:</h3>
                            <h4 class="m-1">{profile.gender}</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Age:</h3>
                            <h4 class="m-1">{profile.age}</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Height:</h3>
                            <h4 class="m-1">{profile.height} cm</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Weight:</h3>
                            <h4 class="m-1">{profile.weight} kg</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Allergy:</h3>
                            <h4 class="m-1">
                                {#if profile.allergy.length}
                                    {#each profile.allergy as al}
                                        {al},{" "}
                                    {/each}
                                {:else}
                                    {"None"}
                                {/if}
                            </h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Alcohol:</h3>
                            <h4 class="m-1">
                                {profile.alcohol ? "Yes" : "No"}
                            </h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Smokes:</h3>
                            <h4 class="m-1">
                                {profile.smoke ? "Yes" : "No"}
                            </h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Cannabis:</h3>
                            <h4 class="m-1">
                                {profile.cannabis ? "Yes" : "No"}
                            </h4>
                        </div>
                    </div>
                    <div class="">
                        <img
                            src={`https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${profile.id}`}
                            alt="QR Code"
                        />
                        <!-- <QRious value={profile.id} /> -->
                    </div>
                </div>
            {/if}
        </div>
        <div>
            <div class="flex justify-between items-center">
                <h2>Current treatments</h2>
                {#if profile}
                    {#if profile.treatments.length}
                        <button
                            on:click|preventDefault={report}
                            disabled={reportQueue.length ? false : true}
                            >Report</button
                        >
                    {/if}
                {/if}
            </div>

            {#if profile}
                <div class="overflow-auto h-md">
                    {#if profile.treatments.filter((value) => value.completed === false).length}
                        {#each profile.treatments.filter((value) => value.completed === false) as item}
                            <div class="mt-4">
                                <div class="flex items-start text-lg">
                                    <div class="flex items-center">
                                        <input
                                            type="checkbox"
                                            id={item.id}
                                            value={item.id}
                                            bind:group={reportQueue}
                                            class="form-checkbox border-gray-400 h-4 w-4 text-indigo-600"
                                        />
                                    </div>

                                    <label
                                        for={item.id}
                                        class="ml-3 font-medium"
                                        >{#if item.medicine}
                                            {item.medicine}, {item.form}, {item
                                                .dosage.strength}
                                            {item.dosage.unit}
                                        {:else}
                                            null
                                        {/if}
                                    </label>
                                </div>
                                <p
                                    class="mt-1 ml-4 pl-3 block text-md text-gray-200"
                                >
                                    {item.schedule.startDate} - {item.schedule
                                        .endDate}<br />
                                    {#if item.schedule.frequency === 0}
                                        {#if item.schedule.interval === 1}
                                            Every day
                                        {:else if item.schedule.interval === 2}
                                            Every other days
                                        {:else}
                                            Every {item.schedule.interval} days
                                        {/if}
                                        <ul class="mt-1">
                                            {#each item.schedule.timesOfDay as time}
                                                <li>{time}</li>
                                            {/each}
                                        </ul>
                                    {:else if item.schedule.frequency === 1}
                                        <p>
                                            {item.schedule.daysOfWeek.join(
                                                ", "
                                            )}
                                        </p>
                                        <ul>
                                            {#each item.schedule.timesOfDay as time}
                                                <li>{time}</li>
                                            {/each}
                                        </ul>
                                    {:else}
                                        <p>As needed</p>
                                    {/if}
                                </p>
                            </div>
                        {/each}
                    {:else}
                        <h3>No treatments at the moment</h3>
                    {/if}
                </div>
            {/if}
        </div>
        <div>
            <h2>Access requests</h2>
            {#if profile}
                <div class="overflow-auto h-md">
                    {#if profile.requests.length}
                        {#each profile.requests as doctor}
                            <div class="flex justify-between items-center">
                                <h4>{doctor.name} / {doctor.affiliate}</h4>
                                <button
                                    on:click|preventDefault={() => {
                                        giveAccess(doctor.address);
                                    }}>Accept</button
                                >
                            </div>
                        {/each}
                    {:else}
                        <h3>No access request at the moment</h3>
                    {/if}
                </div>
            {/if}
        </div>
        <div>
            <h2>Completed treatments</h2>
            {#if profile}
                <div class="overflow-auto h-md">
                    {#if profile.treatments.filter((value) => value.completed === true).length}
                        {#each profile.treatments.filter((value) => value.completed === true) as item}
                            <div class="mt-4">
                                <div class="flex items-start text-lg">
                                    <label
                                        for={item.id}
                                        class="ml-3 font-medium"
                                        >{#if item.medicine}
                                            {item.medicine}, {item.form}, {item
                                                .dosage.strength}
                                            {item.dosage.unit}
                                        {:else}
                                            null
                                        {/if}
                                    </label>
                                </div>
                                <p
                                    class="mt-1 ml-4 pl-3 block text-md text-gray-200"
                                >
                                    {item.schedule.startDate} - {item.schedule
                                        .endDate}<br />
                                    {#if item.schedule.frequency === 0}
                                        {#if item.schedule.interval === 1}
                                            Every day
                                        {:else if item.schedule.interval === 2}
                                            Every other days
                                        {:else}
                                            Every {item.schedule.interval} days
                                        {/if}
                                        <ul class="mt-1">
                                            {#each item.schedule.timesOfDay as time}
                                                <li>{time}</li>
                                            {/each}
                                        </ul>
                                    {:else if item.schedule.frequency === 1}
                                        <p>
                                            {item.schedule.daysOfWeek.join(
                                                ", "
                                            )}
                                        </p>
                                        <ul>
                                            {#each item.schedule.timesOfDay as time}
                                                <li>{time}</li>
                                            {/each}
                                        </ul>
                                    {:else}
                                        <p>As needed</p>
                                    {/if}
                                </p>
                            </div>
                        {/each}
                    {:else}
                        <h3>No completed treatments at the moment</h3>
                    {/if}
                </div>
            {/if}
        </div>
    </div>
</div>
