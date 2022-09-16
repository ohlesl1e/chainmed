<script>
	import { goto } from '$app/navigation';

	// let multiStepForm;
	// let formStep;
</script>

<div class="flex flex-col prescribe-form">
	<h1 class="text-4xl">Prescribe medicine</h1>
	<form class="bg-zinc-800 p-6 rd-3" multi-step-form>
		<div bind class="form-step active" step="1">
			<!-- patient -->
			<div class="form-group flex flex-col gap-4 m-b-5">
				<label for="addredd">Patient address</label>
				<input type="text" />
			</div>
			<button type="button" on:click={() => goto('/')}>Cancel</button>
			<button type="button">Next</button>
		</div>
		<div class="form-step" step="2">
			<!-- medicine -->
			<div class="form-group flex flex-col gap-2">
				<label for="addredd">Add medicine</label>
				<p>You can search for a medicine</p>
				<input type="text" />
			</div>
			<button>Previous</button>
			<button>Next</button>
		</div>
		<div class="form-step" step="3">
			<!-- type -->
			<div class="form-group flex flex-col gap-2">
				<label for="addredd">Patient address</label>
				<input type="text" />
			</div>
			<button>Previous</button>
			<button>Next</button>
		</div>
		<div class="form-step" step="4">
			<!-- dosage -->
			<button>Previous</button>
			<button>Next</button>
		</div>
		<div class="form-step" step="5">
			<!-- schedule -->
			<button>Previous</button>
			<button>Next</button>
		</div>
		<div class="form-step" step="6">
			<!-- review -->
			<button>Previous</button>
			<button>Sumbit</button>
		</div>
	</form>
</div>

<style>
	.prescribe-form {
		height: calc(100vh - 48px - 136px);
	}

	.form-step {
		padding: 2em;
		display: none;
	}

	.form-step.active {
		display: block;
	}

	.form-group {
		min-width: 640px;
	}

	.form-group input {
		font-size: 1.5rem;
	}
</style>
