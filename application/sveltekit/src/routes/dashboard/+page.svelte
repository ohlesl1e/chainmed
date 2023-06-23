<script>
    import { onMount } from "svelte/internal";
    import DoctorDash from "$lib/component/dash/DoctorDash.svelte";
    import PatientDash from "$lib/component/dash/PatientDash.svelte";
    import { goto } from "$app/navigation";
    import { token } from "$lib/store";

    let type;
    token.set(sessionStorage.getItem("token"));

    onMount(() => {
        if (!token) {
            goto("/");
        }
        let jwt = JSON.parse(atob($token.split(".")[1]));
        type = jwt.type;
    });
</script>

<div>
    {#if type === "doctor"}
        <DoctorDash />
    {:else if type === "patient"}
        <PatientDash />
    {/if}
</div>
