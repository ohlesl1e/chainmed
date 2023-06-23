<script>
    import { goto } from "$app/navigation";
    import Doctor from "$lib/contracts/Doctor.json";
    import Patient from "$lib/contracts/Patient.json";
    import Treatment from "$lib/contracts/Treatment.json";
    import { onMount } from "svelte";
    import { accountProvider as provider } from "$lib/provider";
    import { managerContract, doctorContract, token } from "$lib/store";
    import { ethers, utils, BigNumber } from "ethers";
    import { PUBLIC_PUSH_KEY } from "$env/static/public";
    import DoctorChart from "./DoctorChart.svelte";

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
            const patientAddresses = new Set();

            treatments = Array(res.length);

            for (const treatment in res) {
                const treatmentContract = new ethers.Contract(
                    res[treatment],
                    Treatment.abi,
                    $provider.getSigner()
                );
                const treatmentData = await treatmentContract.getTreatment();
                const patient = await treatmentContract.getPatient();
                if (!patientAddresses.has(patient)) {
                    try {
                        const profileAddress =
                            await $managerContract.getPatient(patient);
                        const patientContract = new ethers.Contract(
                            profileAddress,
                            Patient.abi,
                            $provider.getSigner()
                        );
                        const info = await patientContract.getInfo();
                        // console.log(info[0]);
                        patients = [
                            ...patients,
                            {
                                id: patient,
                                name: utils.parseBytes32String(info[0][0]),
                                gender: utils.parseBytes32String(info[0][1]),
                                age:
                                    new Date().getFullYear() -
                                    new Date(
                                        BigNumber.from(info[1]).toNumber()
                                    ).getFullYear(),
                                height: info[2][0],
                                weight: info[2][1] / 100,
                                allergy: info[3],
                                alcohol: info[4][0],
                                smoke: info[4][1],
                                cannabis: info[4][2],
                            },
                        ];
                    } catch (error) {
                        console.log(error);
                        console.log(`No access to ${patient}`);
                    }
                    patientAddresses.add(patient);
                }
                // console.log(treatmentData);

                treatments[treatment] = {
                    id: res[treatment],
                    completed:
                        Date.now() -
                            new Date(
                                BigNumber.from(treatmentData[3][1]).toNumber()
                            ).getTime() >
                        0,
                    patient,
                    medicine: treatmentData[0],
                    // form: utils.parseBytes32String(treatmentData[1]),
                    // dosage: {
                    //     strength: treatmentData[2][0],
                    //     unit: utils.parseBytes32String(treatmentData[2][1]),
                    // },
                    // schedule: {
                    //     startDate: new Date(
                    //         BigNumber.from(treatmentData[3][0]).toNumber()
                    //     ).toLocaleDateString(),
                    //     endDate: new Date(
                    //         BigNumber.from(treatmentData[3][1]).toNumber()
                    //     ).toLocaleDateString(),
                    //     frequency: treatmentData[3][2],
                    //     interval: treatmentData[3][3],
                    //     daysOfWeek: treatmentData[3][4].map(
                    //         (treatmentData) =>
                    //             utils.parseBytes32String(treatmentData)
                    //     ),
                    //     timesOfDay: treatmentData[3][5].map(
                    //         (treatmentData) => {
                    //             return `${String(
                    //                 Math.floor(treatmentData / 100)
                    //             ).padStart(2, "0")}:${String(
                    //                 treatmentData % 100
                    //             ).padStart(2, "0")}`;
                    //         }
                    //     ),
                    // },
                };
            }
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
    <div>
        <DoctorChart
            ids={treatments.map((value) => [value.id, value.patient])}
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
                                    >
                                        {`...${item.id.substr(-4, 4)}`}
                                    </a>
                                </div>
                                <p
                                    class="mt-1 ml-4 pl-3 block text-md text-gray-200"
                                >
                                    Medicine:
                                    {#if item.medicine}
                                        {item.medicine}
                                    {:else}
                                        null
                                    {/if}<br />
                                    Patient: {`...${item.patient.substr(
                                        -4,
                                        4
                                    )}`}
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
            <div class="flex justify-between items-center">
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
