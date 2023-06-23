<script>
    import { onMount } from "svelte";
    import Patient from "$lib/contracts/Patient.json";
    import Treatment from "$lib/contracts/Treatment.json";
    import { provider } from "$lib/store";
    import { ethers, utils, BigNumber } from "ethers";
    import { managerContract } from "$lib/store";

    /** @type {import('./$types').PageData} */
    export let data;
    console.log(data.id);
    let profile;

    onMount(async () => {
        // let token = localStorage.getItem("token").split(".");
        let patientAddress = await $managerContract.getPatient(data.id);
        let patientContract = new ethers.Contract(
            patientAddress,
            Patient.abi,
            $provider.getSigner()
        );

        try {
            const info = await patientContract.getInfo();
            // console.log(info);
            profile = {
                id: patientAddress,
                name: utils.parseBytes32String(info[0][0]),
                gender: utils.parseBytes32String(info[0][1]),
                age:
                    new Date().getFullYear() -
                    new Date(BigNumber.from(info[1]).toNumber()).getFullYear(),
                height: info[2][0],
                weight: info[2][1] / 100,
                allergy: info[3],
                alcohol: info[4][0],
                smoke: info[4][1],
                cannabis: info[4][2],
                treatments: [],
                requests: info[6] ? info[6] : [],
            };
            // console.log(profile);
            for (const treatment of info[5]) {
                const treatmentContract = new ethers.Contract(
                    treatment,
                    Treatment.abi,
                    $provider.getSigner()
                );
                const [medicine_, isComplete_] =
                    await treatmentContract.getMedicine();

                // console.log(treat);
                if (!isComplete_) {
                    profile.treatments = [...profile.treatments, medicine_];
                }
            }
            console.log(profile);
        } catch (error) {
            console.log(error);
            profile = "denied";
        }
    });
</script>

{#if profile && profile !== "denied"}
    <div class="flex flex-row justify-around">
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
                            {al},
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
            <div class="flex flex-row gap-2">
                <h3 class="m-1">Treatments:</h3>
                <div class="flex-col gap-2">
                    {#if profile.treatments.length}
                        {#each profile.treatments as medicine}
                            <h4 class="m-1">
                                {medicine}
                            </h4>
                        {/each}
                    {:else}
                        <h4 class="m-1">None</h4>
                    {/if}
                </div>
            </div>
        </div>
    </div>
{:else if profile === "denied"}
    <div class="flex justify-around items-center">
        <h2>Access denied</h2>
    </div>
{/if}
