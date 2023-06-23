<script>
    import { goto } from "$app/navigation";
    import { utils } from "ethers";
    import { DoubleBounce } from "svelte-loading-spinners";
    import axios from "axios";
    import { provider } from "$lib/store";
    import { applicationContract } from "$lib/store";
    const BACKEND_ADDR = "/api";

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
        "Poultry Meat",
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

    let name = "";
    let gender;
    let dob = "1990-01-01";
    let height;
    let weight;
    let allergy = [];
    let alcohol = false;
    let smoke = false;
    let cannabis = false;

    let loading = false;

    const handleSubmit = async () => {
        loading = true;
        try {
            const tx = await $applicationContract.register(
                utils.formatBytes32String(name),
                utils.formatBytes32String(gender),
                new Date(dob).getTime(),
                height,
                Math.ceil(weight * 100),
                allergy,
                alcohol,
                smoke,
                cannabis
            );
            const receipt = await tx.wait();
            let address = await $provider.getSigner().getAddress();
            console.log({ tx, receipt, address });
            axios
                .post(
                    `/api/signup`,
                    { address },
                    {
                        headers: {
                            "Content-Type": "application/json",
                            // "xsrf-token": preflight.data.csrfToken,
                        },
                        withCredentials: true,
                    }
                )
                .then(async (res) => {
                    loading = false;
                    localStorage.setItem("token", res.data.token);
                    window.location.href = "/";
                })
                .catch((err) => {
                    console.log(err);
                });
        } catch (error) {
            console.log(error);
        }
    };
</script>

<div class="bg-zinc-800 p-6 rd-3">
    <form on:submit|preventDefault={handleSubmit}>
        <div class="flex flex-col gap-2">
            <h1>New patient form</h1>
            <p>Please fill in this form to create your profile.</p>
            <label for="name"><b>Name</b></label>
            <input
                type="text"
                bind:value={name}
                placeholder="Enter name"
                required
            />

            <label for="gender"><b>Gender</b></label>
            <select bind:value={gender} required>
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="non-binary">Non-binary</option>
            </select>

            <label for="dob"><b>Date of birth</b></label>
            <input
                type="date"
                placeholder="mm/dd/yyyy"
                bind:value={dob}
                required
            />

            <label for="height"><b>Height</b>(cm)</label>
            <input type="number" bind:value={height} required />

            <label for="weight"><b>Weight</b>(kg)</label>
            <input type="number" step=".01" bind:value={weight} required />

            <label for="allergy"><b>Allergy</b>(Select all that apply)</label>
            <label for="food">Food</label>
            {#each foodAllergy as allergen}
                <label>
                    <input
                        type="checkbox"
                        bind:group={allergy}
                        value={allergen}
                    />
                    {allergen}
                </label>
            {/each}
            <label for="med">Medicine</label>
            {#each medAllergy as allergen}
                <label>
                    <input
                        type="checkbox"
                        bind:group={allergy}
                        value={allergen}
                    />
                    {allergen}
                </label>
            {/each}

            <label for="sub"><b>Other substance</b></label>
            <label
                ><input type="checkbox" bind:checked={alcohol} />Do you drink
                alcohol?</label
            >
            <label
                ><input type="checkbox" bind:checked={smoke} />Do you smoke
                cigarette?</label
            >
            <label
                ><input type="checkbox" bind:checked={cannabis} />Do you use
                cannabis?</label
            >

            <p>
                By creating an account you agree to our <a
                    href="/"
                    style="color:dodgerblue">Terms & Privacy</a
                >.
            </p>

            <div class="flex items-center gap-2">
                <button type="button" on:click={() => goto("/")}>Cancel</button>
                <button type="submit">Complete</button>
                {#if loading}
                    <DoubleBounce size="40" />
                {/if}
            </div>
        </div>
    </form>
</div>
