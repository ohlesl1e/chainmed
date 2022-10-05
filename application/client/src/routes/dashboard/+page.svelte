<script>
    import { onMount } from 'svelte/internal';
    import DoctorDash from '../../lib/dash/DoctorDash.svelte';
    import PatientDash from '../../lib/dash/PatientDash.svelte';
    import { goto } from '$app/navigation';
    import keyraw from '../../lib/jwtRS256.key.pub?raw';

    let type;
    let token = sessionStorage.getItem('token').split('.');
    let key = keyraw.split(' ')[1];
    let keybytes = atob(key);
    let keybuffer = new Uint8Array(keybytes.length);
    for (let i = 0; i < keybytes.length; i++) {
        keybuffer[i] = keybytes.charCodeAt(i);
    }

    onMount(() => {
        if (!token) {
            goto('/');
        }
        let jwt = JSON.parse(atob(token[1]));
        type = jwt.type;
    });
</script>

<div>
    {#if type === 'doctor'}
        <DoctorDash />
    {:else if type === 'patient'}
        <PatientDash />
    {/if}
</div>
