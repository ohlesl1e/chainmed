<script>
	import { goto } from '$app/navigation';
	import { utils } from 'ethers';
	import { DoubleBounce } from 'svelte-loading-spinners';
	// import axios from 'axios';
	import { provider } from '$lib/store';
	import { managerContract } from '$lib/store';
	import { sha256 } from 'js-sha256';
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
	let showModal = false;
	let key = undefined;

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
			const random = crypto.randomUUID();
			let hash = sha256.update(random);
			// hash.update(random);
			// console.log(await $provider.getSigner().getAddress());
			// let key = hash.hex().substring(0, 32);
			key = await crypto.subtle.generateKey({ name: 'AES-GCM', length: 256 }, true, [
				'encrypt',
				'decrypt'
			]);
			let address = await $provider.getSigner().getAddress();
			console.log({ address });
			let hash2 = sha256.update(address);
			let iv = hash2.arrayBuffer();
			// console.log({ key: await crypto.subtle.exportKey('raw', key), iv });
			let enc = new TextEncoder();

			let encrypted = await crypto.subtle.encrypt(
				{ name: 'AES-GCM', iv },
				key,
				enc.encode(
					JSON.stringify({
						name,
						gender,
						dob,
						height,
						weight,
						allergy,
						alcohol,
						smoke,
						cannabis
					})
				)
			);

			console.log({
				json: JSON.stringify({
					name,
					gender,
					dob,
					height,
					weight,
					allergy,
					alcohol,
					smoke,
					cannabis
				}),
				encoded: enc.encode(
					JSON.stringify({
						name,
						gender,
						dob,
						height,
						weight,
						allergy,
						alcohol,
						smoke,
						cannabis
					})
				)
			});

			localStorage.setItem('key', new Uint32Array(await crypto.subtle.exportKey('raw', key)));
			localStorage.setItem('iv', new Uint32Array(iv));

			console.log(encrypted);

			const tx = await $managerContract.addPatient(
				// [utils.formatBytes32String(name), utils.formatBytes32String(gender)],
				// new Date(dob).getTime() / 1000,
				// [height, Math.ceil(weight * 100)],
				// allergy,
				// [alcohol, smoke, cannabis],
				[false, await $provider.getSigner().getAddress()],
				new Uint8Array(encrypted).join()
			);
			const receipt = await tx.wait();
			console.log({ tx, receipt, address });
			key = new Uint32Array(await crypto.subtle.exportKey('raw', key));
			console.log({ key });
			loading = false;
			showModal = true;
			modal.showModal();
			// goto('/');
		} catch (error) {
			console.log(error);
			loading = false;
		}
	};
</script>

<div class="max-w-lg mx-auto">
	{#if key && showModal}
		<div
			class="fixed top-0 left-0 w-full h-full bg-opacity-50 bg-black flex justify-center items-center break-words"
		>
			<div class="bg-white p-4 rounded-md max-w-sm text-center">
				<h2 class="h2">Keep this key somewhere safe</h2>
				<p>{key.join()}</p>
				<button on:click={() => goto('/')}>Close</button>
			</div>
		</div>
	{/if}

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
