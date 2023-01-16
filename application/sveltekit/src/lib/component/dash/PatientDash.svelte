<script>
    import { SiweMessage } from "siwe";
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";
    import Patient from "$lib/contracts/Patient.json";
    import { accountProvider as provider } from "$lib/provider";
    import { ethers, utils, BigNumber } from "ethers";
    import { applicationContract, patientContract, token } from "$lib/store";
    import { PUBLIC_PUSH_KEY } from "$env/static/public";

    let profile;
    const domain = window.location.host;
    const origin = window.location.origin;

    let reportQueue = [];

    onMount(async () => {
        // let token = sessionStorage.getItem("token").split(".");
        let patientAddress = JSON.parse(atob($token.split(".")[1])).address;
        patientContract.set(
            new ethers.Contract(
                patientAddress,
                Patient.abi,
                $provider.getSigner()
            )
        );
        $patientContract
            .getInfo()
            .then(async (res) => {
                console.log(res);
                profile = {
                    name: utils.parseBytes32String(res[0]),
                    gender: utils.parseBytes32String(res[1]),
                    age:
                        new Date().getFullYear() -
                        new Date(
                            BigNumber.from(res[2]).toNumber()
                        ).getFullYear(),
                    height: res[3],
                    weight: res[4] / 100,
                    allergy: res[5],
                    alcohol: res[6],
                    smoke: res[7],
                    cannabis: res[8],
                    treatments: res[9].map((value) => {
                        return {
                            id: value.id,
                            completed: value.completed,
                            medicine: value.medicine,
                            form: utils.parseBytes32String(value.form),
                            dosage: {
                                strength: value.dosage.strength,
                                unit: utils.parseBytes32String(
                                    value.dosage.unit
                                ),
                            },
                            schedule: {
                                startDate: new Date(
                                    BigNumber.from(
                                        value.schedule.startDate
                                    ).toNumber()
                                ).toLocaleDateString(),
                                endDate: new Date(
                                    BigNumber.from(
                                        value.schedule.endDate
                                    ).toNumber()
                                ).toLocaleDateString(),
                                frequency: value.schedule.frequency,
                                interval: value.schedule.interval,
                                daysOfWeek: value.schedule.daysOfWeek.map(
                                    (value) => utils.parseBytes32String(value)
                                ),
                                timesOfDay: value.schedule.timesOfDay.map(
                                    (value) => {
                                        return `${String(
                                            Math.floor(value / 100)
                                        ).padStart(2, "0")}:${String(
                                            value % 100
                                        ).padStart(2, "0")}`;
                                    }
                                ),
                            },
                        };
                    }),
                    requests: res[10] ? res[10] : [],
                };
                console.log(profile);
                $applicationContract
                    .getDoctorInfo(res[10])
                    .then((res) => {
                        profile.requests = res.map((value, index) => {
                            return {
                                address: profile.requests[index],
                                name: utils.parseBytes32String(value[0]),
                                affiliate: utils.parseBytes32String(value[1]),
                            };
                        });
                    })
                    .catch((err) => {
                        console.log({ loc: "get doc info", err });
                    });
                if ("serviceWorker" in navigator) {
                    navigator.serviceWorker.controller.postMessage({
                        tag: "treatment-meta",
                        treatments: profile.treatments.map((value) => {
                            return {
                                id: value.id,
                                medicine: value.medicine,
                                schedule: value.schedule,
                            };
                        }),
                    });
                }
            })
            .catch((err) => {
                console.log(err);
            });
        if ("serviceWorker" in navigator) {
            try {
                let reg = await navigator.serviceWorker.getRegistration();
                let permission = await Notification.requestPermission();
                if (permission !== "granted") {
                    throw "Notification permission not granted";
                }
                // if (!(await reg.pushManager.getSubscription())) {
                const subscription = await reg.pushManager.subscribe({
                    userVisibleOnly: true,
                    applicationServerKey: PUBLIC_PUSH_KEY,
                });
                console.log(subscription.endpoint);
                fetch("/api/subscribe", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        subscription,
                        address: await $provider.getSigner().getAddress(),
                    }),
                });
                // }
            } catch (error) {
                console.log(error);
            }
        }
    });

    const createSiweMessage = async (address, statement) => {
        const res = await fetch(`/api/nonce`);
        const data = await res.json();
        const message = new SiweMessage({
            domain,
            address,
            statement,
            uri: origin,
            version: "1",
            chainId: 5777,
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
</script>

<div class="flex flex-col">
    <h1 class="text-5xl">Patient dashboard</h1>
    <div class="grid gap-5 sm:grid-cols-1 md:grid-cols-2">
        <div>
            <div class="flex justify-between items-center">
                <h2>Info</h2>
                <button on:click={() => goto("/account")}>Edit</button>
            </div>

            {#if profile}
                <div class="flex flex-row justify-around mb-3">
                    <div class="flex flex-col gap-2">
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
                    </div>
                    <div class="flex flex-col gap-2">
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
                            <h4 class="m-1">{profile.smoke ? "Yes" : "No"}</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Cannabis:</h3>
                            <h4 class="m-1">
                                {profile.cannabis ? "Yes" : "No"}
                            </h4>
                        </div>
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
                            >report</button
                        >
                    {/if}
                {/if}
            </div>

            {#if profile}
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

                                <label for={item.id} class="ml-3 font-medium"
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
                                        {item.schedule.daysOfWeek.join(", ")}
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
            {/if}
        </div>
        <div>
            <h2>Access requests</h2>
            {#if profile}
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
            {/if}
        </div>
        <div>
            <h2>Completed treatments</h2>
            {#if profile}
                {#if profile.treatments.filter((value) => value.completed === true).length}
                    {#each profile.treatments.filter((value) => value.completed === true) as item}
                        <div class="mt-4">
                            <div class="flex items-start text-lg">
                                <label for={item.id} class="ml-3 font-medium"
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
                                        {item.schedule.daysOfWeek.join(", ")}
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
            {/if}
        </div>
    </div>
</div>
