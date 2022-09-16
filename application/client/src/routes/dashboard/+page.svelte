<script>
	import DoctorDash from '../../lib/dash/DoctorDash.svelte';
	import PatientDash from '../../lib/dash/PatientDash.svelte';

	let userType = sessionStorage.getItem('userType');
</script>

<div>
	{#if userType === 'doctor'}
		<DoctorDash />
	{:else}
		<PatientDash />
	{/if}
</div>
