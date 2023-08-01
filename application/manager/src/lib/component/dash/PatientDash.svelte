<script>
	import { onMount } from 'svelte';
	import Patient from '$lib/contracts/Patient.json';
	import Application from '$lib/contracts/Application.json';
	import Doctor from '$lib/contracts/Doctor.json';
	import { provider } from '$lib/store';
	import { ethers, utils, Contract } from 'ethers';
	import { patientContract, managerContract } from '$lib/store';
	import { encryptInfo, getCurrentKeyAndIv } from '$lib/crypto';
	import _ from 'lodash';
	// import { QRious } from "@phippsytech/svelte-qrious";

	const APPLICATION_ROLE = utils.id('APPLICATION_ROLE');
	const DOCTOR_ROLE = utils.id('DOCTOR_ROLE');

	let profile;
	let changedProfile;
	let applicationQueue;
	let doctorQueue;
	let profileUpdates;
	let tempAllergy;
	let expanded = false;
	let init = false;
	let requests = [];
	export let patientAddress;

	let qrShowed = false;

	const basicInfo = [
		'id',
		'name',
		'gender',
		'dob',
		'height',
		'weight',
		'allergy',
		'alcohol',
		'smoke',
		'cannabis',
		'requests'
	];

	let infoChanged = false;

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

	onMount(async () => {
		// let token = sessionStorage.getItem("token").split(".");
		patientContract.set(new ethers.Contract(patientAddress, Patient.abi, $provider.getSigner()));
		let { key, iv } = await getCurrentKeyAndIv(
			localStorage.getItem('key'),
			localStorage.getItem('iv')
		);
		try {
			console.log({ patientAddress, $patientContract });
			let info = await $patientContract.getInfo();

			info = new Uint8Array(info.split(','));

			// const uintInfo = new Uint8Array(info.split(','));
			// console.log({ info: uintInfo });
			// console.log(uintInfo.buffer);
			// const buffered = uintInfo.buffer;

			// key = await crypto.subtle.importKey('raw', key, 'AES-GCM', true, ['encrypt', 'decrypt']);
			// console.log({ key, iv });

			let decrypted;
			try {
				decrypted = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, info.buffer);
			} catch (error) {
				console.log(error);
				alert('Invalid key');
				localStorage.removeItem('key');
				window.location.reload();
			}
			let dec = new TextDecoder();

			let { alcohol, allergy, cannabis, dob, gender, height, name, smoke, weight } = JSON.parse(
				dec.decode(decrypted)
			);
			// let dob = new Date(BigNumber.from(info[1]).toNumber() * 1000);
			// console.log({ requests: info[6] });
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
				cannabis
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
				cannabis
			};
		} catch (error) {
			console.log(error);
		}

		try {
			let tempRequests = await $patientContract.getRequests();
			if (tempRequests.length) {
				for (const request of tempRequests) {
					const doctorAddress = await $managerContract.getDoctor(request);
					const doctorContract = new ethers.Contract(
						doctorAddress,
						Doctor.abi,
						$provider.getSigner()
					);
					console.log({ request, doctorAddress });
					try {
						const doctorInfo = await doctorContract.getInfo();
						console.log({
							address: request,
							res: doctorInfo,
							name: utils.parseBytes32String(doctorInfo[0]),
							affiliate: utils.parseBytes32String(doctorInfo[1])
						});
						requests = [
							...requests,
							{
								address: request,
								name: utils.parseBytes32String(doctorInfo[0]),
								affiliate: utils.parseBytes32String(doctorInfo[1])
							}
						];
					} catch (error) {
						console.log(error);
					}
				}
			}
		} catch (error) {
			console.log(error);
		}
		try {
			//Access management
			const applicationQueueLength = (
				await $patientContract.getRoleMemberCount(APPLICATION_ROLE)
			).toNumber();
			const doctorQueueLength = (await $patientContract.getRoleMemberCount(DOCTOR_ROLE)).toNumber();

			console.log({
				applicationQueueLength,
				doctorQueueLength
			});

			const appQueue = [];
			const docQueue = [];

			for (let index = 0; index < applicationQueueLength; index++) {
				const appAddress = await $patientContract.getRoleMember(APPLICATION_ROLE, index);
				const appContract = new Contract(appAddress, Application.abi, $provider);
				const appName = utils.parseBytes32String(await appContract.getName());
				appQueue.push({ address: appAddress, name: appName });
				console.log({ appAddress, appName });
			}

			for (let index = 0; index < doctorQueueLength; index++) {
				const docWallet = await $patientContract.getRoleMember(DOCTOR_ROLE, index);
				const docAddress = await $managerContract.getDoctor(docWallet);
				const docContract = new Contract(docAddress, Doctor.abi, $provider.getSigner());
				const docInfo = await docContract.getInfo();
				docQueue.push({
					address: docWallet,
					name: utils.parseBytes32String(docInfo[0]),
					affiliate: utils.parseBytes32String(docInfo[1])
				});
				console.log({ docAddress, docInfo });
			}
			applicationQueue = appQueue;
			doctorQueue = docQueue;

			console.log({ profile });

			init = true;
		} catch (error) {
			console.log(error);
		}

		try {
			// let { key, iv } = await getCurrentKeyAndIv(
			// 	localStorage.getItem('key'),
			// 	localStorage.getItem('iv')
			// );
			let dec = new TextDecoder();
			let updates = await $patientContract.getUpdates();
			let tempUpdates = [];
			for (let index = 0; index < updates.length; index++) {
				const update = new Uint8Array(updates[index].split(','));
				// console.log({ update });
				let decrypted;
				try {
					decrypted = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, update);
					const updateEntry = JSON.parse(dec.decode(decrypted));
					const objKeys = _.union(Object.keys(profile), Object.keys(updateEntry));
					const differences = objKeys.reduce((result, key) => {
						if (!_.isEqual(profile[key], updateEntry[key])) {
							result[key] = `${_.has(profile, key) ? profile[key] : 'undefined'} -> ${
								_.has(updateEntry, key) ? updateEntry[key] : 'undefined'
							}`;
						}
						return result;
					}, {});
					tempUpdates.push(differences);
				} catch (error) {
					console.log(error);
					tempUpdates.push('Error decrypting');
				}
			}
					tempUpdates.push('Error decrypting');
			profileUpdates = tempUpdates;
			console.log({ profileUpdates });
		} catch (error) {
			console.log(error);
		}
	});

	const checkChange = () => {
		infoChanged = !_.isEqual(profile, changedProfile);
	};

	const updateInfo = async () => {
		let { key, iv } = await getCurrentKeyAndIv(
			localStorage.getItem('key'),
			localStorage.getItem('iv')
		);
		let newInfo = await encryptInfo(key, iv, changedProfile);

		console.log({ newInfo });

		try {
			let tx = await $patientContract.updateInfo(newInfo);
			let receipt = await tx.wait();
			window.location.reload();
		} catch (error) {
			console.log(error);
		}
	};

	const approveUpdate = async (index) => {
		try {
			let tx = await $patientContract.approveUpdate(index);
			let receipt = await tx.wait();
			window.location.reload();
		} catch (error) {
			console.log(error);
		}
	};

	const removeUpdate = async (index) => {
		try {
			let tx = await $patientContract.removeUpdate(index);
			let receipt = await tx.wait();
			window.location.reload();
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
				profile.requests = profile.requests.filter((value) => value.address !== doctor);
				console.log({ res, requests: profile.requests });
				window.location.reload();
			})
			.catch((err) => {
				console.log(err);
			});
	};
</script>

<div class="flex flex-col">
	<div class="flex justify-between items-center mb-3">
		<h1 class="text-2xl text-black font-bold">Patient Profile</h1>
		<button
			class="bg-black hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
			on:click={() => (qrShowed = true)}>Show QRcode</button
		>
	</div>
	<div class="flex flex-col gap-2">
		<div>
			<div class="flex justify-between items-center">
				<h2 class="text-xl text-black font-semibold">Info</h2>
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
			{#if qrShowed}
				<div class="fixed z-10 inset-0 overflow-y-auto">
					<div
						class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0"
					>
						<div class="fixed inset-0 transition-opacity" aria-hidden="true">
							<div class="absolute inset-0 bg-gray-500 opacity-75" />
						</div>

						<span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true"
							>&#8203;</span
						>

						<div
							class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle"
							role="dialog"
							aria-modal="true"
							aria-labelledby="modal-headline"
						>
							<div class="bg-white px-4 pt-5 pb-4">
								<img
									src={`https://api.qrserver.com/v1/create-qr-code/?size=220x220&data={"address":"${patientAddress}","key":[${localStorage.getItem(
										'key'
									)}]}`}
									alt="QR Code"
								/>
							</div>

							<div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
								<button
									type="button"
									class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-indigo-600 text-base font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:ml-3 sm:w-auto sm:text-sm"
									on:click={() => (qrShowed = false)}
								>
									Close
								</button>
							</div>
						</div>
					</div>
				</div>
			{/if}
			{#if profile}
				<div class="bg-white min-w-[50vw] mb-4">
					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2">Name</label>
						<input
							class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
							type="text"
							bind:value={changedProfile.name}
							on:input={checkChange}
						/>
					</div>

					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2">Gender</label>
						<select
							class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
							bind:value={changedProfile.gender}
							on:change={checkChange}
						>
							<option value="male">Male</option>
							<option value="female">Female</option>
							<option value="non-binary">Non-binary</option>
						</select>
					</div>

					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2">Date of birth</label>
						<input
							class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
							type="date"
							bind:value={changedProfile.dob}
							on:input={checkChange}
						/>
					</div>

					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2">Height (cm)</label>
						<input
							class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
							type="number"
							bind:value={changedProfile.height}
							on:input={checkChange}
						/>
					</div>

					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2">Weight (kg)</label>
						<input
							class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
							type="number"
							bind:value={changedProfile.weight}
							on:input={checkChange}
						/>
					</div>

					<div>
						<label for="" class="block text-gray-700 font-bold">Allergy</label>
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
								class="mb-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
								on:click={() => (expanded = !expanded)}
							>
								{#if expanded}
									Hide options
								{:else}
									More options
								{/if}
							</button>

							{#if expanded}
								<label class="block text-gray-700 font-bold mb-2" for="food">Food</label>
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
								<label class="block text-gray-700 font-bold mb-2" for="med">Medicine</label>
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

					<label for="habits" class="block text-gray-700 font-bold">Habits</label>
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
							<input type="checkbox" bind:checked={changedProfile.smoke} on:change={checkChange} />
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
				</div>
				{#each Object.keys(changedProfile).filter((value) => !basicInfo.includes(value)) as key}
					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2"
							>{key.replace(/^\w/, (c) => c.toUpperCase())}</label
						>
						<input
							class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
							type="number"
							bind:value={changedProfile[key]}
							on:input={checkChange}
						/>
					</div>
				{/each}
			{/if}
		</div>
		<div class="mb-3">
			<h2 class="text-xl text-black font-semibold">Updates</h2>
			{#if profile && profileUpdates}
				{#if profileUpdates.length}
					{#each profileUpdates as update, i}
						<div class="mt-3">
							{#if update !== 'Error decrypting'}
								<!-- content here -->

								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									on:click|preventDefault={() => {
										approveUpdate(i);
									}}>Accept</button
								>
							{/if}
							<button
								class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
								on:click|preventDefault={() => {
									removeUpdate(i);
								}}>Discard</button
							>
							<div class="mt-3">
								<pre>{JSON.stringify(update, undefined, 2)
										.replaceAll('"', '')
										.replace(/\{\n/, '')
										.replace(/\}/, '')}</pre>
							</div>
							<hr />
						</div>
					{/each}
				{:else}
					<h3>No updates at the moment</h3>
				{/if}
			{/if}
		</div>
		<div class="mb-3">
			<h2 class="text-xl text-black font-semibold">Access requests</h2>
			{#if profile}
				<div class="overflow-auto h-md">
					{#if requests.length}
						{#each requests as doctor}
							<div class="flex justify-between items-center">
								<h4>{doctor.name} / {doctor.affiliate}</h4>
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									on:click|preventDefault={() => {
										giveAccess(doctor.address);
									}}>Accept</button
								>
							</div>
						{/each}
					{:else}
						<h3>No access request at the moment</h3>
					{/if}
				</div>
			{/if}
		</div>
		<div>
			<h2 class="text-xl text-black font-semibold mb-2">Access Management</h2>
			{#if profile}
				<div class="overflow-auto h-md">
					{#if applicationQueue}
						<label for="" class="block text-gray-700 font-bold mb-2">Applications</label>
						{#each applicationQueue as application}
							<div class="flex justify-between items-center">
								<h4>
									{application.name} / {application.address.substring(
										0,
										6
									)}...{application.address.substring(38)}
								</h4>
								<button
									class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									on:click|preventDefault={async () => {
										try {
											await (
												await $patientContract.revokeRole(APPLICATION_ROLE, application.address)
											).wait();
											window.location.reload();
										} catch (error) {
											console.log(error);
										}
									}}>Revoke</button
								>
							</div>
						{/each}
					{:else}
						<h3>No applications at the moment</h3>
					{/if}
				</div>
				<div class="overflow-auto h-md">
					{#if doctorQueue}
						<label for="" class="block text-gray-700 font-bold mb-2">Doctor</label>
						{#each doctorQueue as doctor}
							<div class="flex justify-between items-center">
								<h4>{doctor.name} / {doctor.affiliate}</h4>
								<button
									class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									on:click|preventDefault={async () => {
										try {
											await (await $patientContract.revokeAccess(doctor.address)).wait();
											window.location.reload();
										} catch (error) {
											console.log(error);
										}
									}}>Revoke</button
								>
							</div>
						{/each}
					{:else}
						<h3>No doctors at the moment</h3>
					{/if}
				</div>
			{/if}
		</div>
	</div>
</div>
