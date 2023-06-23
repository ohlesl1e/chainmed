<script>
    import { goto } from "$app/navigation";
    import Doctor from "$lib/contracts/Doctor.json";
    import Patient from "$lib/contracts/Patient.json";
    import { onMount } from "svelte";
    import { accountProvider as provider } from "$lib/provider";
    import { applicationContract, doctorContract, token } from "$lib/store";
    import { ethers, utils, BigNumber } from "ethers";
    import { id } from "ethers/lib/utils";
    import { PUBLIC_PUSH_KEY } from "$env/static/public";

    // let provider = getContext('provider');
    let profileContract;
    let treatments = [],
        patients = [];

    onMount(async () => {
        let doctorAddress = JSON.parse(atob($token.split(".")[1])).address;
        doctorContract.set(
            new ethers.Contract(
                doctorAddress,
                Doctor.abi,
                $provider.getSigner()
            )
        );
        try {
            const res = await $doctorContract.getTreatments();
            treatments = res.map((value) => {
                return {
                    id: value.id,
                    completed: value.completed,
                    patient: value.patient,
                    medicine: value.medicine,
                };
            });
            const patientAddresses = [
                ...new Set(res.map((item) => item.patient)),
            ];
            patientAddresses.forEach(async (value) => {
                try {
                    const address = await $applicationContract.getPatient(
                        value
                    );
                    const patientContract = new ethers.Contract(
                        address,
                        Patient.abi,
                        $provider.getSigner()
                    );
                    const info = await patientContract.getInfo();
                    patients = [
                        ...patients,
                        {
                            id: value,
                            name: utils.parseBytes32String(info[0]),
                            gender: utils.parseBytes32String(info[1]),
                            age:
                                new Date().getFullYear() -
                                new Date(
                                    BigNumber.from(info[2]).toNumber()
                                ).getFullYear(),
                            height: info[3],
                            weight: info[4] / 100,
                            allergy: info[5],
                            alcohol: info[6],
                            smoke: info[7],
                            cannabis: info[8],
                        },
                    ];
                } catch (error) {
                    console.log(error);
                    console.log(`No access to ${value}`);
                }
            });
            console.log({ treatments, patients });
        } catch (error) {
            console.log(error);
        }
        // $doctorContract
        //     .getTreatments()
        //     .then((res) => {
        //         console.log(res);
        //         profile = {
        //             treatments: res.map((value) => {
        //                 return {
        //                     id: value.id,
        //                     completed: value.completed,
        //                     patient: value.patient,
        //                     medicine: value.medicine,
        //                 };
        //             }),
        //         };
        //     })
        //     .catch((err) => {
        //         console.log(err);
        //     });
        if ("serviceWorker" in navigator) {
            try {
                let reg = await navigator.serviceWorker.getRegistration();
                let permission = await Notification.requestPermission();
                if (permission !== "granted") {
                    throw "Notification permission not granted";
                }
                // if (!(await reg.pushManager.getSubscription())) {
                if (reg) {
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
                }

                // }
            } catch (error) {
                console.log(error);
            }
        }
    });
</script>

<div class="flex flex-col">
    <h1 class="text-5xl">Doctor dashboard</h1>

    <div class="grid gap-4 sm:grid-cols-1 md:grid-cols-2">
        <div>
            <h2>Current treatments</h2>
            {#if treatments.length}
                {#if treatments.filter((value) => value.completed === false).length}
                    <!-- <form> -->
                    {#each treatments.filter((value) => value.completed === false) as item}
                        <div class="mt-4">
                            <div class="flex items-start text-lg">
                                <a
                                    href={`/treatment/${item.id}`}
                                    class="ml-3 font-medium"
                                    >{#if item.medicine}
                                        {item.medicine}
                                    {:else}
                                        null
                                    {/if}
                                </a>
                            </div>
                            <p
                                class="mt-1 ml-4 pl-3 block text-md text-gray-200"
                            >
                                ID: {item.id}<br />
                                Patient: {item.patient}
                            </p>
                        </div>
                    {/each}
                    <!-- </form> -->
                {:else}
                    <h3>No treatments at the moment</h3>
                {/if}
            {/if}
        </div>
        <div>
            <div class="flex justify-between items-center">
                <h2>Prescribe medicine</h2>
                <button on:click={() => goto("/prescribe")}>Start</button>
            </div>
        </div>
        <div>
            <h2>Completed treatments</h2>
            {#if treatments.length}
                {#if treatments.filter((value) => value.completed === true).length}
                    <form>
                        {#each treatments.filter((value) => value.completed === true) as item}
                            <div class="mt-4">
                                <div class="flex items-start text-lg">
                                    <a
                                        href={`/treatment/${item.id}`}
                                        class="ml-3 font-medium"
                                        >{#if item.medicine}
                                            {item.medicine}
                                        {:else}
                                            null
                                        {/if}
                                    </a>
                                </div>
                                <p
                                    class="mt-1 ml-4 pl-3 block text-md text-gray-200"
                                >
                                    ID: {item.id}<br />
                                    Patient: {item.patient}
                                </p>
                            </div>
                        {/each}
                    </form>
                {:else}
                    <h3>No treatments at the moment</h3>
                {/if}
            {/if}
        </div>
        <div>
            <h2>Patients</h2>
            {#if patients.length}
                {#each patients as patient}
                    <div class="mt-4">
                        <div class="flex items-start text-lg">
                            <a
                                href={`/patient/${patient.id}`}
                                class="ml-3 font-medium"
                                >{patient.id}
                            </a>
                        </div>
                        <p class="mt-1 ml-4 pl-3 block text-md text-gray-200">
                            Name: {patient.name}<br />
                            Age: {patient.age}
                        </p>
                    </div>
                {/each}
            {/if}
        </div>
    </div>
</div>
