<script>
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";
    import Patient from "$lib/contracts/Patient.json";
    import Treatment from "$lib/contracts/Treatment.json";
    import { provider } from "$lib/store";
    import { ethers, utils, BigNumber } from "ethers";
    import { managerContract } from "$lib/store";
    import _ from "lodash";
    import { sha256 } from "js-sha256";
    import { getCurrentKeyAndIv, decryptInfo, encryptInfo } from "$lib/crypto";

    /** @type {import('./$types').PageData} */
    export let data;
    console.log(data.id);
    let init = false;
    let profile;
    let changedProfile;
    let treatments = [];
    let tempAllergy;
    let expanded = false;
    let patientContract;

    const basicInfo = [
        "id",
        "name",
        "gender",
        "dob",
        "height",
        "weight",
        "allergy",
        "alcohol",
        "smoke",
        "cannabis",
        "requests",
    ];

    let infoChanged = false;

    const foodAllergy = [
        "Balsam of Peru",
        "Buckwheat",
        "Celery",
        "Egg",
        "Fish",
        "Fruit",
        "Garlic",
        "Oats",
        "Maize",
        "Milk",
        "Mustard",
        "Peanut",
        "Poultry meat",
        "Rice",
        "Sesame",
        "Shellfish",
        "Tartrazine",
        "Tree nut",
        "Wheat",
    ];
    const medAllergy = [
        "Tetracycline",
        "Dilantin",
        "Tegretol",
        "Penicillin",
        "Cephalosporins",
        "Sulfonamides",
        "Non-steroidal anti-inflammatories",
        "Intravenous contrast dye",
        "Local anesthetics",
    ];

    const initialize = async () => {
        const patientKeys = localStorage.getItem("patientKeys");
        let vault = {};
        if (patientKeys) {
            vault = JSON.parse(patientKeys);
        }

        let patientAddress = await $managerContract.getPatient(data.id);
        patientContract = new ethers.Contract(
            patientAddress,
            Patient.abi,
            $provider.getSigner()
        );
        const { key, iv } = await getCurrentKeyAndIv(
            vault[data.id].join(),
            new Uint32Array(sha256.update(data.id).arrayBuffer()).join()
        );

        try {
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
            } = await decryptInfo(raw, key, iv, data.id, "doctor");
            // console.log(info);
            tempAllergy = allergy;
            profile = {
                name,
                gender,
                dob,
                height,
                weight,
                allergy,
                alcohol,
                smoke,
                cannabis,
            };
            changedProfile = {
                name,
                gender,
                dob,
                height,
                weight,
                allergy,
                alcohol,
                smoke,
                cannabis,
            };
            const tempTreatments = await patientContract.getTreatments();
            for (const treatment of tempTreatments) {
                const treatmentContract = new ethers.Contract(
                    treatment,
                    Treatment.abi,
                    $provider.getSigner()
                );
                const [medicine_, isComplete_] =
                    await treatmentContract.getMedicine();

                // console.log(treat);
                if (!isComplete_) {
                    treatments = [...treatments, medicine_];
                }
            }
            // console.log({ profile, changedProfile, treatments });
            // console.log({
            //     otherInfo: Object.keys(changedProfile).filter(
            //         (value) => !basicInfo.includes(value)
            //     ),
            // });
        } catch (error) {
            console.log(error);
            profile = "denied";
        }
        init = true;
    };

    const checkChange = () => {
        infoChanged = !_.isEqual(profile, changedProfile);
    };

    const updateInfo = async () => {
        const patientKeys = localStorage.getItem("patientKeys");
        let vault = {};
        if (patientKeys) {
            vault = JSON.parse(patientKeys);
        }
        let { key, iv } = await getCurrentKeyAndIv(
            vault[data.id].join(),
            new Uint32Array(sha256.update(data.id).arrayBuffer()).join()
        );
        let newInfo = await encryptInfo(key, iv, changedProfile);

        console.log({ newInfo });

        try {
            let tx = await patientContract.addUpdate(newInfo);
            let receipt = await tx.wait();
            goto("/");
        } catch (error) {
            console.log(error);
        }
    };

    $: if ($managerContract && !init) {
        initialize();
    }
</script>

{#if profile && profile !== "denied"}
    <!-- <div class="flex flex-row justify-around">
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
    </div> -->

    <div class="min-w-[50vw] max-w-[80vw] mb-4 mt-3">
        <div class="flex justify-between items-center">
            <h1 class="">Patient Info</h1>
            {#if infoChanged}
                <button
                    class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
                    on:click={updateInfo}>Save</button
                >
            {:else}
                <button
                    class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
                    type="button"
                    disabled>Save</button
                >
            {/if}
        </div>
        <div class="mb-4">
            <label for="" class="block text-gray-100 font-bold mb-2">Name</label
            >
            <input
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-100 leading-tight focus:outline-none focus:shadow-outline"
                type="text"
                bind:value={changedProfile.name}
                on:input={checkChange}
            />
        </div>

        <div class="mb-4">
            <label for="" class="block text-gray-100 font-bold mb-2"
                >Gender</label
            >
            <select
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-100 leading-tight focus:outline-none focus:shadow-outline"
                bind:value={changedProfile.gender}
                on:change={checkChange}
            >
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="non-binary">Non-binary</option>
            </select>
        </div>

        <div class="mb-4">
            <label for="" class="block text-gray-100 font-bold mb-2"
                >Date of birth</label
            >
            <input
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-100 leading-tight focus:outline-none focus:shadow-outline"
                type="date"
                bind:value={changedProfile.dob}
                on:input={checkChange}
            />
        </div>

        <div class="mb-4">
            <label for="" class="block text-gray-100 font-bold mb-2"
                >Height (cm)</label
            >
            <input
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-100 leading-tight focus:outline-none focus:shadow-outline"
                type="number"
                bind:value={changedProfile.height}
                on:input={checkChange}
            />
        </div>

        <div class="mb-4">
            <label for="" class="block text-gray-100 font-bold mb-2"
                >Weight (kg)</label
            >
            <input
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-100 leading-tight focus:outline-none focus:shadow-outline"
                type="number"
                bind:value={changedProfile.weight}
                on:input={checkChange}
            />
        </div>

        <div>
            <label for="" class="block text-gray-100 font-bold">Allergy</label>
            <div class="mb-2 flex flex-col">
                {#each tempAllergy as allergen}
                    <label>
                        <input
                            class="form-checkbox"
                            type="checkbox"
                            bind:group={changedProfile.allergy}
                            value={allergen}
                            on:change={checkChange}
                        />
                        {allergen}
                    </label>
                {/each}
            </div>
            <div class="flex flex-col">
                <button
                    type="button"
                    class="mb-2 px-4 py-2 text-sm font-medium text-gray-100 border border-gray-300 rounded-md hover:bg-gray-50"
                    on:click={() => (expanded = !expanded)}
                >
                    {#if expanded}
                        Hide options
                    {:else}
                        More options
                    {/if}
                </button>

                {#if expanded}
                    <label class="block text-gray-100 font-bold mb-2" for="food"
                        >Food</label
                    >
                    <div class="mb-2 flex flex-col">
                        {#each foodAllergy.filter((value) => {
                            return !tempAllergy.includes(value);
                        }) as allergen}
                            <label>
                                <input
                                    class="form-checkbox"
                                    type="checkbox"
                                    bind:group={changedProfile.allergy}
                                    value={allergen}
                                    on:change={checkChange}
                                />
                                {allergen}
                            </label>
                        {/each}
                    </div>
                    <label class="block text-gray-100 font-bold mb-2" for="med"
                        >Medicine</label
                    >
                    <div class="mb-2 flex flex-col">
                        {#each medAllergy.filter((value) => {
                            return !tempAllergy.includes(value);
                        }) as allergen}
                            <label>
                                <input
                                    class="form-checkbox"
                                    type="checkbox"
                                    bind:group={changedProfile.allergy}
                                    value={allergen}
                                    on:change={checkChange}
                                />
                                {allergen}
                            </label>
                        {/each}
                    </div>
                {/if}
            </div>
        </div>

        <label for="habits" class="block text-gray-100 font-bold">Habits</label>
        <div>
            <label for="alcohol">
                <input
                    class="form-checkbox"
                    type="checkbox"
                    bind:checked={changedProfile.alcohol}
                    on:change={checkChange}
                /> Drink alcohol
            </label>
        </div>
        <div>
            <label for="smoke">
                <input
                    type="checkbox"
                    bind:checked={changedProfile.smoke}
                    on:change={checkChange}
                />
                Smoke cigarette
            </label>
        </div>
        <div>
            <label for="weed">
                <input
                    type="checkbox"
                    bind:checked={changedProfile.cannabis}
                    on:change={checkChange}
                />
                Use cannabis
            </label>
        </div>
        {#each Object.keys(changedProfile).filter((value) => !basicInfo.includes(value)) as key}
            <div class="mb-4">
                <label for="" class="block text-gray-100 font-bold mb-2"
                    >{key.replace(/^\w/, (c) => c.toUpperCase())}</label
                >
                <input
                    class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-100 leading-tight focus:outline-none focus:shadow-outline"
                    type="number"
                    bind:value={changedProfile[key]}
                    on:input={checkChange}
                />
            </div>
        {/each}
        <div class="mb-4">
            <h2 class="text-xl font-semibold">Current treatments</h2>
            {#each treatments as treatment}
                <h4>{treatment}</h4>
            {/each}
        </div>
    </div>
{:else if profile === "denied"}
    <div class="flex justify-around items-center">
        <h2>Access denied</h2>
    </div>
{/if}
