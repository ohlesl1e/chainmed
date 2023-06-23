<script>
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';
	import Patient from '$lib/contracts/Patient.json';
	import Application from '$lib/contracts/Application.json';
	import Doctor from '$lib/contracts/Doctor.json';
	import { provider } from '$lib/store';
	import { ethers, utils, BigNumber, Contract } from 'ethers';
	import { patientContract, managerContract } from '$lib/store';
	// import { QRious } from "@phippsytech/svelte-qrious";

	const APPLICATION_ROLE = utils.id('APPLICATION_ROLE');
	const DOCTOR_ROLE = utils.id('DOCTOR_ROLE');

	let profile;
	let changedProfile;
	let tempAllergy;
	let expanded = false;
	const domain = window.location.host;
	const origin = window.location.origin;
	let init = false;
	export let patientAddress;

	let qrShowed = false;

	let nameChanged = false;
	let genderChanged = false;
	let dobChanged = false;
	let heightChanged = false;
	let weightChanged = false;
	let allergyChanged = false;
	let alcoholChanged = false;
	let smokeChanged = false;
	let cannabisChanged = false;

	let reportQueue = [];

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

		try {
			const info = await $patientContract.getInfo();
			let dob = new Date(BigNumber.from(info[1]).toNumber() * 1000);
			console.log({ requests: info[6] });
			tempAllergy = info[3];
			profile = {
				id: patientAddress,
				name: utils.parseBytes32String(info[0][0]),
				gender: utils.parseBytes32String(info[0][1]),
				dob: `${dob.getFullYear()}-${(dob.getMonth() + 1).toString().padStart(2, '0')}-${(
					dob.getDate() + 1
				)
					.toString()
					.padStart(2, '0')}`,
				height: info[2][0],
				weight: info[2][1] / 100,
				allergy: info[3],
				alcohol: info[4][0],
				smoke: info[4][1],
				cannabis: info[4][2],
				treatments: [],
				requests: []
			};
			changedProfile = {
				id: patientAddress,
				name: utils.parseBytes32String(info[0][0]),
				gender: utils.parseBytes32String(info[0][1]),
				dob: `${dob.getFullYear()}-${(dob.getMonth() + 1).toString().padStart(2, '0')}-${(
					dob.getDate() + 1
				)
					.toString()
					.padStart(2, '0')}`,
				height: info[2][0],
				weight: info[2][1] / 100,
				allergy: info[3],
				alcohol: info[4][0],
				smoke: info[4][1],
				cannabis: info[4][2],
				treatments: [],
				requests: info[6] ? info[6] : []
			};
			if (info[6].length) {
				for (const request of info[6]) {
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
						profile.requests = [
							...profile.requests,
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
			profile.appQueue = appQueue;
			profile.docQueue = docQueue;

			console.log({ profile });

			init = true;
		} catch (error) {
			console.log(error);
		}
	});

	const checkName = () => {
		nameChanged = profile.name === changedProfile.name ? false : true;
	};

	const checkGender = () => {
		genderChanged = profile.gender === changedProfile.gender ? false : true;
	};

	const checkDob = () => {
		dobChanged = profile.dob === changedProfile.dob ? false : true;
	};

	const checkHeight = () => {
		heightChanged = profile.height === changedProfile.height ? false : true;
	};

	const checkWeight = () => {
		weightChanged = profile.weight === changedProfile.weight ? false : true;
	};

	const checkAllergy = () => {
		allergyChanged =
			profile.allergy.sort().toString() === changedProfile.allergy.sort().toString() ? false : true;
	};

	const checkAlcohol = (event) => {
		changedProfile.alcohol = event.target.checked;
		alcoholChanged = profile.alcohol === changedProfile.alcohol ? false : true;
	};

	const checkSmoke = (event) => {
		changedProfile.smoke = event.target.checked;
		smokeChanged = profile.smoke === changedProfile.smoke ? false : true;
	};

	const checkCannabis = (event) => {
		changedProfile.cannabis = event.target.checked;
		cannabisChanged = profile.cannabis === changedProfile.cannabis ? false : true;
	};

	const updatePhysics = async () => {
		try {
			const tx = await $patientContract.setPhysique([
				changedProfile.height,
				Math.ceil(changedProfile.weight * 100)
			]);
			const receipt = await tx.wait();
			window.location.reload();
		} catch (error) {
			console.log(error);
		}
	};

	const updateHabits = async () => {
		try {
			const tx = await $patientContract.setHabits([
				changedProfile.alcohol,
				changedProfile.smoke,
				changedProfile.cannabis
			]);
			const receipt = await tx.wait();
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
	<div class="flex flex-col gap-2">
		<div>
			<div class="flex justify-between items-center">
				<h2 class="text-xl text-black font-semibold">Info</h2>
				<button
					class="bg-black hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
					on:click={() => (qrShowed = true)}>Show QRcode</button
				>
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
									src={`https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${profile.id}`}
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
						<div class="flex gap-2">
							<input
								class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
								type="text"
								bind:value={changedProfile.name}
								on:input={checkName}
							/>
							{#if nameChanged}
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									on:click={async () => {
										try {
											await (
												await $patientContract.setName(
													utils.formatBytes32String(changedProfile.name)
												)
											).wait();
											window.location.reload();
										} catch (error) {}
									}}>Save</button
								>
							{:else}
								<button
									class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									disabled>Save</button
								>
							{/if}
						</div>
					</div>

					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2">Gender</label>
						<div class="flex gap-2">
							<select
								class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
								bind:value={changedProfile.gender}
								on:change={checkGender}
							>
								<option value="male">Male</option>
								<option value="female">Female</option>
								<option value="non-binary">Non-binary</option>
							</select>
							{#if genderChanged}
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									on:click={async () => {
										console.log({
											old: profile.gender,
											new: changedProfile.gender
										});
										try {
											const tx = await $patientContract.setGender(
												utils.formatBytes32String(changedProfile.gender)
											);
											console.log(tx);

											const receipt = await tx.wait();
											console.log(receipt);

											window.location.reload();
										} catch (error) {
											console.log(error);
										}
									}}>Save</button
								>
							{:else}
								<button
									class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									disabled>Save</button
								>
							{/if}
						</div>
					</div>

					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2">Date of birth</label>
						<div class="flex gap-2">
							<input
								class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
								type="date"
								bind:value={changedProfile.dob}
								on:input={checkDob}
							/>
							{#if dobChanged}
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									on:click={async () => {
										try {
											await (
												await $patientContract.setDob(new Date(changedProfile.dob).getTime() / 1000)
											).wait();
											window.location.reload();
										} catch (error) {}
									}}>Save</button
								>
							{:else}
								<button
									class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									disabled>Save</button
								>
							{/if}
						</div>
					</div>

					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2">Height (cm)</label>
						<div class="flex gap-2">
							<input
								class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
								type="number"
								bind:value={changedProfile.height}
								on:input={checkHeight}
							/>
							{#if heightChanged}
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									on:click={updatePhysics}>Save</button
								>
							{:else}
								<button
									class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									disabled>Save</button
								>
							{/if}
						</div>
					</div>

					<div class="mb-4">
						<label for="" class="block text-gray-700 font-bold mb-2">Weight (kg)</label>
						<div class="flex gap-2">
							<input
								class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
								type="number"
								bind:value={changedProfile.weight}
								on:input={checkWeight}
							/>
							{#if weightChanged}
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									on:click={updatePhysics}>Save</button
								>
							{:else}
								<button
									class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									disabled>Save</button
								>
							{/if}
						</div>
					</div>

					<div>
						<div class="flex gap-2 justify-between items-start">
							<label for="" class="block text-gray-700 font-bold">Allergy</label>
							{#if allergyChanged}
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									on:click={async () => {
										try {
											await (await $patientContract.setAllergy(changedProfile.allergy)).wait();
											window.location.reload();
										} catch (error) {
											console.log(error);
										}
									}}>Save</button
								>
							{:else}
								<button
									class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									disabled>Save</button
								>
							{/if}
						</div>
						<div class="mb-2 flex flex-col">
							{#each tempAllergy as allergen}
								<label>
									<input
										class="form-checkbox"
										type="checkbox"
										bind:group={changedProfile.allergy}
										value={allergen}
										on:change={checkAllergy}
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
								<!-- content here -->

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
												on:change={checkAllergy}
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
												on:change={checkAllergy}
											/>
											{allergen}
										</label>
									{/each}
								</div>
							{/if}
						</div>
					</div>

					<label for="habits" class="block text-gray-700 font-bold">Habits</label>
					<div class="mb-4">
						<div class="flex gap-2 justify-between items-center">
							<label for="alcohol">
								<input
									class="form-checkbox"
									type="checkbox"
									bind:checked={changedProfile.alcohol}
									on:change={checkAlcohol}
								/> Drink alcohol
							</label>

							{#if alcoholChanged}
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									on:click={updateHabits}>Save</button
								>
							{:else}
								<button
									class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									disabled>Save</button
								>
							{/if}
						</div>
					</div>

					<div class="mb-4">
						<div class="flex gap-2 justify-between items-center">
							<label for="">
								<input type="checkbox" bind:checked={changedProfile.smoke} on:change={checkSmoke} />
								Smoke cigarette
							</label>

							{#if smokeChanged}
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									on:click={updateHabits}>Save</button
								>
							{:else}
								<button
									class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									disabled>Save</button
								>
							{/if}
						</div>
					</div>

					<div class="mb-4">
						<div class="flex gap-2 justify-between items-center">
							<label for="">
								<input
									type="checkbox"
									bind:checked={changedProfile.cannabis}
									on:change={checkCannabis}
								/>
								Use cannabis
							</label>

							{#if cannabisChanged}
								<button
									class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									on:click={updateHabits}>Save</button
								>
							{:else}
								<button
									class="invisible bg-gray-500 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
									type="button"
									disabled>Save</button
								>
							{/if}
						</div>
					</div>
				</div>
			{/if}
		</div>
		<div class="mb-3">
			<h2 class="text-xl text-black font-semibold">Access requests</h2>
			{#if profile}
				<div class="overflow-auto h-md">
					{#if profile.requests.length}
						{#each profile.requests as doctor}
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
					{#if profile.appQueue}
						<label for="" class="block text-gray-700 font-bold mb-2">Applications</label>
						{#each profile.appQueue as application}
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
					{#if profile.docQueue}
						<label for="" class="block text-gray-700 font-bold mb-2">Doctor</label>
						{#each profile.docQueue as doctor}
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
