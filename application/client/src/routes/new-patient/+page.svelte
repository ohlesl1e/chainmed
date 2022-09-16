<script>
	import { goto } from '$app/navigation';
	import { getContext } from 'svelte';

	const provider = getContext('provider');

	let name = '';
	let gender;
	let dob = '1990-01-01';
	let heightFt = 0;
	let heightIn = 0;
	let weight;

	const handleSubmit = (e) => {
		e.preventDefault();
		console.log({
			name,
			gender,
			dob,
			height: `${heightFt}'${heightIn}"`,
			weight
		});
	};

    console.log(provider);
</script>

<div class="bg-zinc-800 p-6 rd-3">
	<form on:submit={(e) => handleSubmit(e)}>
		<div class="flex flex-col gap-2">
			<h1>New patient form</h1>
			<p>Please fill in this form to create your profile.</p>
			<label for="name"><b>Name</b></label>
			<input type="text" placeholder="Enter name" value={name} required />

			<label for="gender"><b>Gender</b></label>
			<select bind:value={gender} required>
				<option value="male">Male</option>
				<option value="female">Female</option>
				<option value="non-binary">Non-binary</option>
			</select>

			<label for="dob"><b>Date of birth</b></label>
			<input type="date" placeholder="mm/dd/yyyy" bind:value={dob} required />

			<label for="height"><b>Height</b></label>
			<div>
				<label for="height-ft">Feet</label>
				<input type="number" value={heightFt} min="2" max="9" step="1" required />
				<label for="height-in">Inches</label>
				<input type="number" value={heightIn} min="0" max="11" step="1" />
			</div>

			<label for="weight"><b>Weight</b></label>
			<input type="number" value={weight} required />

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
