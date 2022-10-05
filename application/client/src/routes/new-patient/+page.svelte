<script>
    import { goto } from '$app/navigation';
    import { ContractFactory, ethers } from 'ethers';
    import { getContext } from 'svelte';
    import CDPatient from '$lib/contracts/CDPatient.json';
    import CDManager from '$lib/contracts/CDManager.json';
    import axios from 'axios';

    const MANAGER_ADDRESS = '0x1d84248Cc15b9d9443D550c181D0473c4b17E0a1';
    const BACKEND_ADDR = '/api';

    const provider = getContext('provider');

    const foodAllergy = [
        'Balsam of Peru',
        'Buckwheat',
        'Celery',
        'Egg',
        'Fish',
        'Fruit',
        'Garlic',
        'Oats',
        'Maize',
        'Milk',
        'Mustard',
        'Peanut',
        'Poultry Meat',
        'Rice',
        'Sesame',
        'Shellfish',
        'Tartrazine',
        'Tree nut',
        'Wheat',
    ];
    const medAllergy = [
        'Tetracycline',
        'Dilantin',
        'Tegretol',
        'Penicillin',
        'Cephalosporins',
        'Sulfonamides',
        'Non-steroidal anti-inflammatories',
        'Intravenous contrast dye',
        'Local anesthetics',
    ];

    let name = '';
    let gender;
    let dob = '1990-01-01';
    let height;
    let weight;
    let allergy = [];
    let alcohol = false;
    let smoke = false;
    let cannabis = false;

    const handleSubmit = async (e) => {
        e.preventDefault();
        const preflight = await axios.get(`${BACKEND_ADDR}/nonce`, {
            withCredentials: true,
        });
        // const factory = new ContractFactory(
        //     CDPatient.abi,
        //     CDPatient.bytecode,
        //     provider.getSigner()
        // );
        // let patient = await factory.deploy(
        //     ethers.utils.formatBytes32String(name),
        //     ethers.utils.formatBytes32String(gender),
        //     Math.floor(new Date(dob).getTime() / 1000),
        //     height,
        //     weight,
        //     allergy,
        //     alcohol,
        //     smoke,
        //     cannabis
        // );

        let manager = new ethers.Contract(MANAGER_ADDRESS, CDManager.abi, provider.getSigner());
        manager
            .register(
                ethers.utils.formatBytes32String(name),
                ethers.utils.formatBytes32String(gender),
                Math.floor(new Date(dob).getTime() / 1000),
                height,
                weight,
                allergy,
                alcohol,
                smoke,
                cannabis
            )
            .then(async (res) => {
                console.log(res);
                let address = await provider.getSigner().getAddress();
                console.log(address);
                axios
                    .post(
                        `${BACKEND_ADDR}/register`,
                        { address },
                        {
                            headers: {
                                'Content-Type': 'application/json',
                                'xsrf-token': preflight.data.csrfToken,
                            },
                            withCredentials: true,
                        }
                    )
                    .then((res) => {
                        sessionStorage.setItem('token', res.data.token);
                        goto('/dashboard');
                    })
                    .catch((err) => {
                        console.log(err);
                    });
            })
            .catch((err) => {
                console.log(err);
                alert('Please try again');
            });
    };
</script>

<div class="bg-zinc-800 p-6 rd-3">
    <form on:submit={(e) => handleSubmit(e)}>
        <div class="flex flex-col gap-2">
            <h1>New patient form</h1>
            <p>Please fill in this form to create your profile.</p>
            <label for="name"><b>Name</b></label>
            <input type="text" bind:value={name} placeholder="Enter name" required />

            <label for="gender"><b>Gender</b></label>
            <select bind:value={gender} required>
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="non-binary">Non-binary</option>
            </select>

            <label for="dob"><b>Date of birth</b></label>
            <input type="date" placeholder="mm/dd/yyyy" bind:value={dob} required />

            <label for="height"><b>Height</b>(cm)</label>
            <input type="number" bind:value={height} required />

            <label for="weight"><b>Weight</b>(kg)</label>
            <input type="number" bind:value={weight} required />

            <label for="allergy"><b>Allergy</b>(Select all that apply)</label>
            <label for="food">Food</label>
            {#each foodAllergy as allergen}
                <label>
                    <input type="checkbox" bind:group={allergy} value={allergen} />
                    {allergen}
                </label>
            {/each}
            <label for="med">Medicine</label>
            {#each medAllergy as allergen}
                <label>
                    <input type="checkbox" bind:group={allergy} value={allergen} />
                    {allergen}
                </label>
            {/each}

            <label for="sub"><b>Other substance</b></label>
            <label><input type="checkbox" bind:checked={alcohol} />Do you drink alcohol?</label>
            <label><input type="checkbox" bind:checked={smoke} />Do you smoke cigarette?</label>
            <label><input type="checkbox" bind:checked={cannabis} />Do you use cannabis?</label>

            <p>
                By creating an account you agree to our <a href="/" style="color:dodgerblue"
                    >Terms & Privacy</a
                >.
            </p>

            <div class="">
                <button type="button" on:click={() => goto('/')}>Cancel</button>
                <button type="submit">Complete</button>
            </div>
        </div>
    </form>
</div>
