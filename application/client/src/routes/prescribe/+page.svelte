<script>
    import { goto } from '$app/navigation';
    import FormProgress from '../../lib/FormProgress.svelte';

    let steps = ['patient', 'medicine', 'type', 'dosage', 'schedule', 'review'];
    let dow = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    let searchedMedicine = [];
    let types = [
        'Liquid filled capsule',
        'Tablet',
        'Capsule',
        'Cream',
        'Device',
        'Drops',
        'Foam',
        'Gel',
        'Inhaler',
        'Injection',
        'Liquid',
        'Lotion',
        'Ointment',
        'Patch',
        'Powder',
        'Spray',
        'Suppository',
        'Topical',
    ];
    let currentTab = 0;
    let progressBar;

    let patient;
    let medicine;
    let medicineType;
    let scheduleType = 0;
    let interval = '';
    let days = [];
    let tod = [];

    const handleProgress = (n) => progressBar.handleProgress(n);
</script>

<div class="flex flex-col prescribe-form">
    <h1 class="text-4xl">Prescribe medicine</h1>
    <FormProgress {steps} bind:currentTab bind:this={progressBar} />
    <form class="flex flex-col justify-between bg-zinc-800 p-6 rd-3">
        {#if currentTab === 0}
            <!-- patient -->
            <div bind class="form-step">
                <h2 class="m-t-0">Patient wallet address</h2>
                <div class="form-group flex flex-col gap-4">
                    <input
                        type="text"
                        placeholder="e.g. 0x71C7656EC7ab88b098defB751B7401B5f6d8976F"
                        bind:value={patient}
                    />
                </div>
            </div>
        {:else if currentTab === 1}
            <!-- medicine -->
            <div class="form-step">
                <h2 class="m-t-0">Add medicine</h2>
                <div class="form-group flex flex-col">
                    <label for="medicine">You can search for a medicine</label>
                    <input type="text" placeholder="Type medicine name" />
                    <div>
                        <ul>
                            {#each searchedMedicine as med}
                                <li on:click={() => (medicine = med)}>{med}</li>
                            {/each}
                        </ul>
                    </div>
                </div>
            </div>
        {:else if currentTab === 2}
            <!-- type -->
            <div class="form-step">
                <h2 class="m-t-0">Choose the medicine type</h2>
                <div class="form-group flex flex-col gap-2">
                    <select bind:value={medicineType}>
                        {#each types as type}
                            <option value={type}>{type}</option>
                        {/each}
                    </select>
                </div>
            </div>
        {:else if currentTab === 3}
            <!-- dosage -->
            <div class="form-step">
                <h2 class="m-t-0">Dosage</h2>
                <div class="form-group flex flex-col gap-2">
                    <label for="Strength">Strength</label>
                    <input type="number" placeholder="Add strength" />
                </div>
                <div class="form-group flex flex-col gap-2">
                    <label for="unit">Choose unit</label>
                    <select>
                        <option>mg</option>
                        <option>mcg</option>
                        <option>g</option>
                        <option>mL</option>
                        <option>%</option>
                    </select>
                </div>
            </div>
        {:else if currentTab === 4}
            <!-- schedule -->
            <div class="form-step">
                <h2 class="m-t-0">When to take?</h2>
                <div class="form-group flex flex-col gap-2">
                    <label for="frequency">Frequency</label>
                    <select bind:value={scheduleType}>
                        <option value={0}>At regular intervals</option>
                        <option value={1}>On specific days of the week</option>
                        <option value={2}>As needed</option>
                    </select>
                </div>
                {#if scheduleType === 0}
                    <div class="form-group flex flex-col gap-2">
                        <label for="interval">Choose interval<br />Every</label>
                        <select bind:value={interval}>
                            <option value="0">Day</option>
                            <option value="1">Other days</option>
                            {#each Array(97) as _, n}
                                <option value={n + 2}>{n + 3} days</option>
                            {/each}
                        </select>
                    </div>
                {:else if scheduleType === 1}
                    <div class="form-group flex flex-col">
                        <label for="days">Choose days</label>
                        <div class="display-inherit justify-between">
                            {#each dow as day, i}
                                <label
                                    ><input
                                        type="checkbox"
                                        bind:group={days}
                                        value={i}
                                    />{day}</label
                                >
                            {/each}
                        </div>
                    </div>
                {/if}
                {#if scheduleType !== 2}
                    <div class="form-group flex flex-col gap-2">
                        <label for="interval">Start date</label>
                        <input type="date" placeholder="mm/dd/yyyy" />
                    </div>
                    <div class="form-group flex flex-col gap-2">
                        <label for="time">Time of day</label>
                        {#if tod.length}
                            {#each tod as _, i}
                                <div>
                                    <input
                                        type="time"
                                        style="width: 50%"
                                        bind:value={tod[i]}
                                        on:input={() => console.log(tod)}
                                    />
                                    <button
                                        style="width: 20%"
                                        on:click={(e) => {
                                            e.preventDefault();
                                            tod.splice(i, 1);
                                            tod = tod;
                                        }}>Remove</button
                                    >
                                </div>
                            {/each}
                        {/if}
                        <button
                            on:click={(e) => {
                                e.preventDefault();
                                let time = new Date();
                                let hour = time.getHours();
                                let minute = time.getMinutes();
                                tod = [
                                    ...tod,
                                    `${hour < 10 ? '0' : ''}${hour}:${
                                        minute < 10 ? '0' : ''
                                    }${minute}`,
                                ];
                            }}>Add a time</button
                        >
                    </div>
                {/if}
            </div>
        {:else}
            <!-- review -->
            <div class="form-step" />
        {/if}

        <div class="text-center">
            {#if currentTab === 0}
                <button type="button" on:click={() => goto('/')}>Cancel</button>
            {:else}
                <button type="button" on:click={() => handleProgress(-1)}>Prev</button>
            {/if}
            {#if currentTab === steps.length - 1}
                <button type="submit">Submit</button>
            {:else}
                <button type="button" on:click={() => handleProgress(1)}>Next</button>
            {/if}
        </div>
    </form>
</div>

<style>
    form {
        height: calc(100vh - 48px - 136px - 60px - 36px - 2.5rem - 1.34em);
        overflow-y: auto;
    }

    .prescribe-form {
        height: calc(100vh - 48px - 136px);
    }

    .form-step {
        padding: 2em;
    }

    .form-group {
        min-width: 640px;
        margin-bottom: 1.5rem;
    }

    .form-group input {
        font-size: 1.3rem;
        max-width: 100%;
    }

    .form-group select {
        font-size: 1.3rem;
        max-width: 100%;
    }

    .text-center button {
        width: 8rem;
    }
</style>
