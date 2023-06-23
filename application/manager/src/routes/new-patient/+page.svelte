<script>
	import { goto } from '$app/navigation';
	import { utils } from 'ethers';
	import { DoubleBounce } from 'svelte-loading-spinners';
	// import axios from 'axios';
	import { provider } from '$lib/store';
	import { managerContract } from '$lib/store';
	const BACKEND_ADDR = '/api';

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
		'Poultry meat',
		'Rice',
		'Sesame',
		'Shellfish',
		'Tartrazine',
		'Tree nut',
		'Wheat'
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
		'Local anesthetics'
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

	let loading = false;

	const handleSubmit = async () => {
		loading = true;
		console.log({
			name,
			gender,
			dob,
			height,
			weight,
			allergy,
			alcohol,
			smoke,
			cannabis
		});

		try {
			const tx = await $managerContract.addPatient(
				[utils.formatBytes32String(name), utils.formatBytes32String(gender)],
				new Date(dob).getTime() / 1000,
				[height, Math.ceil(weight * 100)],
				allergy,
				[alcohol, smoke, cannabis],
				[false, await $provider.getSigner().getAddress()]
			);
			const receipt = await tx.wait();
			let address = await $provider.getSigner().getAddress();
			console.log({ tx, receipt, address });
			goto('/');
			// axios
			// 	.post(
			// 		`/api/signup`,
			// 		{ address },
			// 		{
			// 			headers: {
			// 				'Content-Type': 'application/json'
			// 				// "xsrf-token": preflight.data.csrfToken,
			// 			},
			// 			withCredentials: true
			// 		}
			// 	)
			// 	.then(async (res) => {
			// 		loading = false;
			// 		localStorage.setItem('token', res.data.token);
			// 		window.location.href = '/dashboard';
			// 	})
			// 	.catch((err) => {
			// 		console.log(err);
			// 	});
		} catch (error) {
			console.log(error);
			loading = false;
		}
	};
</script>

<div class="max-w-lg mx-auto">
	<form
		class="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4"
		on:submit|preventDefault={handleSubmit}
	>
		<div class="flex flex-col gap-2">
			<h1 class="text-2xl text-black font-bold">New patient form</h1>
			<p>Please fill in this form to create your profile.</p>

			<div class="mb-4">
				<label class="block text-gray-700 font-bold mb-2" for="name"><b>Name</b></label>
				<input
					class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
					type="text"
					bind:value={name}
					placeholder="Enter name"
					required
				/>
			</div>

			<div class="mb-4">
				<label class="block text-gray-700 font-bold mb-2" for="gender"><b>Gender</b></label>
				<select
					class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
					bind:value={gender}
					on:change={() => {
						console.log(gender);
					}}
					required
				>
					<option value="">Select Gender</option>
					<option value="male">Male</option>
					<option value="female">Female</option>
					<option value="non-binary">Non-binary</option>
				</select>
			</div>

			<div class="mb-4">
				<label class="block text-gray-700 font-bold mb-2" for="dob"><b>Date of birth</b></label>
				<input
					class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
					type="date"
					placeholder="mm/dd/yyyy"
					bind:value={dob}
					required
				/>
			</div>

			<div class="mb-4">
				<label class="block text-gray-700 font-bold mb-2" for="height"><b>Height</b>(cm)</label>
				<input
					class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
					type="number"
					bind:value={height}
					required
				/>
			</div>

			<div class="mb-4">
				<label class="block text-gray-700 font-bold mb-2" for="weight"><b>Weight</b>(kg)</label>
				<input
					class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
					type="number"
					step=".01"
					bind:value={weight}
					required
				/>
			</div>

			<div class="mb-4">
				<label class="block text-gray-700 font-bold mb-2" for="allergy"
					><b>Allergy</b>(Select all that apply)</label
				>
				<label class="block text-gray-700 font-bold mb-2" for="food">Food</label>
				<div class="mb-2 flex flex-col">
					{#each foodAllergy as allergen}
						<label>
							<input class="form-checkbox" type="checkbox" bind:group={allergy} value={allergen} />
							{allergen}
						</label>
					{/each}
				</div>
				<label class="block text-gray-700 font-bold mb-2" for="med">Medicine</label>
				<div class="mb-2 flex flex-col">
					{#each medAllergy as allergen}
						<label>
							<input class="form-checkbox" type="checkbox" bind:group={allergy} value={allergen} />
							{allergen}
						</label>
					{/each}
				</div>
			</div>

			<div class="mb-4">
				<label class="block text-gray-700 font-bold mb-2" for="sub"><b>Other substance</b></label>
				<div class="flex flex-col">
					<label
						><input class="form-checkbox" type="checkbox" bind:checked={alcohol} /> Do you drink alcohol?</label
					>
					<label
						><input class="form-checkbox" type="checkbox" bind:checked={smoke} /> Do you smoke cigarette?</label
					>
					<label
						><input class="form-checkbox" type="checkbox" bind:checked={cannabis} /> Do you use cannabis?</label
					>
				</div>
			</div>

			<p>
				By creating an account you agree to our <a href="/" style="color:dodgerblue"
					>Terms & Privacy</a
				>.
			</p>

			<div class="flex items-center gap-2">
				<button
					class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
					type="button"
					on:click={() => goto('/')}>Cancel</button
				>
				<button
					class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
					type="submit">Complete</button
				>
				{#if loading}
					<DoubleBounce size="40" />
				{/if}
			</div>
		</div>
	</form>
</div>
