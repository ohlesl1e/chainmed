<script>
    import { goto } from "$app/navigation";
    import Doctor from "$lib/contracts/Doctor.json";
    import Patient from "$lib/contracts/Patient.json";
    import Treatment from "$lib/contracts/Treatment.json";
    import { onMount } from "svelte";
    import { provider } from "$lib/store";
    import { managerContract, doctorContract, token } from "$lib/store";
    import { ethers, utils, BigNumber } from "ethers";
    import { PUBLIC_PUSH_KEY } from "$env/static/public";
    import DoctorChart from "./DoctorChart.svelte";
    import { sha256 } from "js-sha256";
    import { getCurrentKeyAndIv, decryptInfo } from "$lib/crypto";

    let profileContract;
    let treatments = [],
        patients = [];

    // onMount(async () => {
    const initialize = async () => {
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
            const patientAddresses = new Set();

            treatments = Array(res.length);
            let tempTreatments = [];
            let tempPatients = [];

            const patientKeys = localStorage.getItem("patientKeys");
            let vault = {};
            if (patientKeys) {
                vault = JSON.parse(patientKeys);
            }

            for (const treatment in res) {
                const treatmentContract = new ethers.Contract(
                    res[treatment],
                    Treatment.abi,
                    $provider.getSigner()
                );
                const treatmentData = await treatmentContract.getTreatment();
                const patient = await treatmentContract.getPatient();
                let patientProfile;
                if (!patientAddresses.has(patient)) {
                    try {
                        const profileAddress =
                            await $managerContract.getPatient(patient);
                        const patientContract = new ethers.Contract(
                            profileAddress,
                            Patient.abi,
                            $provider.getSigner()
                        );
                        const { key, iv } = await getCurrentKeyAndIv(
                            vault[patient].join(),
                            new Uint32Array(
                                sha256.update(patient).arrayBuffer()
                            ).join()
                        );

                        const info = await patientContract.getInfo();
                        const raw = new Uint8Array(info.split(","));
                        // console.log({ raw, key, iv });

                        let {
                            alcohol,
                            allergy,
                            cannabis,
                            dob,
                            gender,
                            height,
                            name,
                            smoke,
                            weight,
                        } = await decryptInfo(raw, key, iv, patient, "doctor");

                        patientProfile = {
                            id: patient,
                            name,
                            gender,
                            age:
                                new Date().getFullYear() -
                                new Date(dob).getFullYear(),
                            height,
                            weight,
                            allergy,
                            alcohol,
                            smoke,
                            cannabis,
                        };
                        // console.log(patientProfile);
                        tempPatients.push(patientProfile);
                        patientAddresses.add(patient);
                    } catch (error) {
                        console.error(error);
                        console.log(`No access to ${patient}`);
                    }
                } else {
                    patientProfile = tempPatients.find(
                        (value) => value.id === patient
                    );
                }
                // console.log(treatmentData);

                tempTreatments.push({
                    id: res[treatment],
                    completed:
                        Date.now() -
                            new Date(
                                BigNumber.from(treatmentData[3][1]).toNumber()
                            ).getTime() >
                        0,
                    patient: patientProfile.name,
                    medicine: treatmentData[0],
                });
            }
            treatments = tempTreatments;
            patients = tempPatients;
            // console.log({ treatments, patients });
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
                // if (!(await reg.pushManager.getSubscription())) {
                if (reg) {
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
                                address: await $provider
                                    .getSigner()
                                    .getAddress(),
                            }),
                        });
                    }
                }

                // }
            } catch (error) {
                console.log(error);
            }
        }
    };
    // });

    $: {
        if ($provider && $token) {
            initialize();
        }
    }
</script>

<div class="flex flex-col">
    <h1 class="text-5xl">Doctor dashboard</h1>
    <div>
        <DoctorChart
            ids={treatments
                .filter((value) => value.completed === false)
                .map((value) => [value.id, value.patient])}
        />
    </div>

    <div class="grid gap-4 sm:grid-cols-1 md:grid-cols-2">
        <div>
            <h2>Current treatments</h2>
            {#if treatments.length}
                <div class="overflow-auto h-md">
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
                </div>
            {:else}
                <h3>No treatments at the moment</h3>
            {/if}
        </div>
        <div>
            <div class="flex justify-between items-center gap-1">
                <h2>Prescribe medicine</h2>
                <button on:click={() => goto("/prescribe")}>Start</button>
            </div>
            <h2>Patients</h2>
            {#if patients.length}
                <div class="overflow-auto h-md">
                    {#each patients as patient}
                        <div class="mt-4">
                            <div class="flex items-start text-lg">
                                <a
                                    href={`/patient/${patient.id}`}
                                    class="ml-3 font-medium"
                                    >{`...${patient.id.substr(-4, 4)}`}
                                </a>
                            </div>
                            <p
                                class="mt-1 ml-4 pl-3 block text-md text-gray-200"
                            >
                                Name: {patient.name}<br />
                                Age: {patient.age}
                            </p>
                        </div>
                    {/each}
                </div>
            {/if}
        </div>
        <div>
            <h2>Completed treatments</h2>
            {#if treatments.length}
                <div class="overflow-auto h-md">
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
                </div>
            {:else}
                <h3>No treatments at the moment</h3>
            {/if}
        </div>
        <div />
    </div>
</div>
