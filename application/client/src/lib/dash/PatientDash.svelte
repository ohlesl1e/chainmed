<script>
    import { goto } from '$app/navigation';
    import { getContext, onMount } from 'svelte';
    import CDPatient from '$lib/contracts/CDPatient.json';
    import { ethers, utils, BigNumber } from 'ethers';

    let provider = getContext('provider');
    let profileContract;
    let profile;

    onMount(() => {
        let token = sessionStorage.getItem('token').split('.');
        let patientAddress = JSON.parse(atob(token[1])).address;
        profileContract = new ethers.Contract(patientAddress, CDPatient.abi, provider.getSigner());
        profileContract
            .getInfo()
            .then((res) => {
                profile = {
                    name: utils.parseBytes32String(res[0]),
                    gender: utils.parseBytes32String(res[1]),
                    age:
                        new Date().getFullYear() -
                        new Date(BigNumber.from(res[2]).toNumber()).getFullYear(),
                    height: res[3],
                    weight: res[4] / 100,
                    allergy: res[5],
                    alcohol: res[6],
                    smoke: res[7],
                    cannabis: res[8],
                    treatments: res[9].map((value) => {
                        return {
                            medicine: value.medicine,
                            form: utils.parseBytes32String(value.form),
                            dosage: {
                                strength: value.dosage.strength,
                                unit: utils.parseBytes32String(value.dosage.unit),
                            },
                            schedule: {
                                startDate: new Date(
                                    BigNumber.from(value.schedule.startDate).toNumber()
                                ).toLocaleDateString(),
                                endDate: new Date(
                                    BigNumber.from(value.schedule.endDate).toNumber()
                                ).toLocaleDateString(),
                                frequency: value.schedule.frequency,
                                interval: value.schedule.interval,
                                daysOfWeek: value.schedule.daysOfWeek.map((value) =>
                                    utils.parseBytes32String(value)
                                ),
                                timesOfDay: value.schedule.timesOfDay.map((value) => {
                                    return `${Math.floor(value / 100)}:${value % 100}`;
                                }),
                            },
                        };
                    }),
                };
            })
            .catch((err) => {
                console.log(err);
            });
    });
</script>

<div class="flex flex-col">
    <h1 class="text-5xl">Patient dashboard</h1>

    <div class="grid gap-5 sm:grid-cols-1 md:grid-cols-2">
        <div>
            <h2>Current treatments</h2>
            {#if profile}
                {#if profile.treatments.length}
                    <ul>
                        {#each profile.treatments as item}
                            <li>
                                <h2>
                                    Medicine:
                                    <small>
                                        {#if item.medicine}
                                            {item.medicine}, {item.form}, {item.dosage.strength}
                                            {item.dosage.unit}
                                        {:else}
                                            null
                                        {/if}
                                    </small>
                                </h2>
                                <h2>
                                    Schedule: <small
                                        >{item.schedule.startDate} - {item.schedule.endDate}
                                    </small>
                                </h2>
                                {#if item.schedule.frequency === 0}
                                    {#if item.schedule.interval === 1}
                                        <h3>Every day</h3>
                                    {:else if item.schedule.interval === 2}
                                        <h3>Every other days</h3>
                                    {:else}
                                        <h3>Every {item.schedule.interval} days</h3>
                                    {/if}
                                    <ul>
                                        {#each item.schedule.timesOfDay as time}
                                            <li>{time}</li>
                                        {/each}
                                    </ul>
                                {:else if item.schedule.frequency === 1}
                                    <h3>{item.schedule.daysOfWeek.join(', ')}</h3>
                                    <ul>
                                        {#each item.schedule.timesOfDay as time}
                                            <li>{time}</li>
                                        {/each}
                                    </ul>
                                {:else}
                                    <h3>As needed</h3>
                                {/if}
                            </li>
                        {/each}
                    </ul>
                {:else}
                    <h3>You don't have any treatments at the moment</h3>
                {/if}
            {/if}
        </div>
        <div>
            <h2>Info</h2>
            {#if profile}
                <div class="flex flex-row justify-around mb-3">
                    <div class="flex flex-col gap-2">
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Name:</h3>
                            <h4 class="m-1">{profile.name}</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Gender:</h3>
                            <h4 class="m-1">{profile.gender}</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Age:</h3>
                            <h4 class="m-1">{profile.age}</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Height:</h3>
                            <h4 class="m-1">{profile.height} cm</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Weight:</h3>
                            <h4 class="m-1">{profile.weight} kg</h4>
                        </div>
                    </div>
                    <div class="flex flex-col gap-2">
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Allergy:</h3>
                            <h4 class="m-1">
                                {#if profile.allergy.length}
                                    {#each profile.allergy as al}
                                        {al},{' '}
                                    {/each}
                                {:else}
                                    {'N/A'}
                                {/if}
                            </h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Alcohol:</h3>
                            <h4 class="m-1">{profile.alcohol}</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Smokes:</h3>
                            <h4 class="m-1">{profile.smoke}</h4>
                        </div>
                        <div class="flex flex-row gap-2">
                            <h3 class="m-1">Cannabis:</h3>
                            <h4 class="m-1">{profile.cannabis}</h4>
                        </div>
                    </div>
                </div>
            {/if}
            <button on:click={() => goto('/account')}>Edit</button>
        </div>
    </div>
</div>
