<script>
    import { goto } from '$app/navigation';
    import axios from 'axios';
    import moment from 'moment';
    import FormProgress from '$lib/FormProgress.svelte';
    import { stopTyping } from '$lib/onStopTyping';
    import { onMount, getContext } from 'svelte';
    import CDPatient from '$lib/contracts/CDPatient.json';
    import { ethers, utils } from 'ethers';

    const provider = getContext('provider');
    const doctorManager = getContext('dm');
    const patientManager = getContext('pm');

    const BACKEND_ADDR = '/api';
    let steps = ['patient', 'medicine', 'form', 'dosage', 'schedule', 'review'];
    let cantContinue = true;
    let medQuery = '';
    let dow = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    let medResult = [];
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
    const today = new Date();
    const dd = String(today.getDate()).padStart(2, '0');
    const mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    const yyyy = today.getFullYear();
    let currentTab = 0;
    let progressBar;

    let patient;
    let info;
    let medicine;
    let form = '';
    let dosage = {
        strength: '',
        unit: '',
    };
    let duration = {
        num: 1,
        unit: 'd',
    };
    let schedule = {
        startDate: `${yyyy}-${mm}-${dd}`,
        endDate: '',
        frequency: 0,
        interval: 1,
        daysOfWeek: [],
        timesOfDay: [],
    };

    onMount(() => calculateEndDate());

    const getPatientInfo = async (e) => {
        e.preventDefault();
        let patientAddress = await patientManager.getPatient(patient);
        if (patientAddress != ethers.constants.AddressZero) {
            let patientContract = new ethers.Contract(
                patientAddress,
                CDPatient.abi,
                provider.getSigner()
            );
            patientContract
                .getInfo()
                .then((res) => {
                    info = {
                        name: ethers.utils.parseBytes32String(res[0]),
                        gender: ethers.utils.parseBytes32String(res[1]),
                        age:
                            new Date().getFullYear() -
                            new Date(ethers.BigNumber.from(res[2]).toNumber()).getFullYear(),
                        height: res[3],
                        weight: res[4],
                        allergy: res[5],
                        alcohol: res[6],
                        smoke: res[7],
                        cannabis: res[8],
                        treatment: res[9],
                    };
                })
                .catch((err) => {
                    console.log(err);
                    info = null;
                });
        } else {
            alert('Patient not found');
        }
    };

    const handleProgress = (n) => {
        progressBar.handleProgress(n);
        if (n > 0) {
            if (currentTab !== 2) cantContinue = true;
        } else {
            cantContinue = false;
        }
    };

    const calculateEndDate = () => {
        let start = moment(schedule.startDate);
        schedule.endDate = start.add(duration.num, duration.unit).format('yyyy-MM-DD');
    };

    const handleSearch = () => {
        axios
            .get(`${BACKEND_ADDR}/search_med?search=${medQuery}`)
            .then((res) => {
                medResult = res.data;
            })
            .catch((err) => {
                console.log(err);
            });
    };

    const validatePatient = () => {
        if (/^0x[a-fA-F0-9]{40}$/.test(patient)) {
            cantContinue = false;
        }
    };

    const validateMedicine = () => {
        if (medicine) cantContinue = false;
    };

    const validateDosage = () => {
        if (dosage.strength && dosage.unit) cantContinue = false;
    };

    const validateSchedule = () => {
        if (schedule.frequency === 2) {
            cantContinue = false;
            return;
        }
        if (schedule.timesOfDay.length) {
            if (schedule.frequency === 0 && schedule.interval) {
                cantContinue = false;
                return;
            }
            if (schedule.daysOfWeek.length) {
                cantContinue = false;
                return;
            }
        }
        cantContinue = true;
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        console.log({
            patientManager,
            patient,
            medicine,
            form,
            dosage,
            schedule,
        });

        doctorManager
            .prescribe(
                patientManager.address,
                patient,
                medicine,
                utils.formatBytes32String(form),
                [dosage.strength, utils.formatBytes32String(dosage.unit)],
                [
                    new Date(schedule.startDate).getTime(),
                    new Date(schedule.endDate).getTime(),
                    schedule.frequency,
                    schedule.interval === '' ? 0 : schedule.interval,
                    schedule.daysOfWeek.map((value) => utils.formatBytes32String(value)),
                    schedule.timesOfDay.map((value) => parseInt(value.split(':').join(''))),
                ]
            )
            .then(
                (res) => {
                    console.log(res);
                    alert('Successfully prescribed');
                    setTimeout(() => {
                        goto('/');
                    }, 3000);
                },
                (err) => {
                    console.log(err);
                }
            );
    };
</script>

<div class="flex flex-col prescribe-form">
    <h1 class="text-4xl">Prescribe medicine</h1>
    <FormProgress {steps} bind:currentTab bind:this={progressBar} />
    <form
        on:submit={(e) => handleSubmit(e)}
        class="flex flex-col justify-between bg-zinc-800 p-6 rd-3"
    >
        {#if currentTab === 0}
            <!-- patient -->
            <div class="form-step">
                <h2 class="m-t-0">Patient wallet address</h2>
                <div class="form-group flex flex-col gap-4 mb-3">
                    <input
                        type="text"
                        placeholder="e.g. 0x71C7656EC7ab88b098defB751B7401B5f6d8976F"
                        bind:value={patient}
                        on:input={validatePatient}
                    />
                    <button type="button" on:click={(e) => getPatientInfo(e)}>Search</button>
                </div>
                {#if info}
                    <div class="flex flex-row justify-around">
                        <div class="flex flex-col gap-2">
                            <div class="flex flex-row gap-2">
                                <h3 class="m-1">Name:</h3>
                                <h4 class="m-1">{info.name}</h4>
                            </div>
                            <div class="flex flex-row gap-2">
                                <h3 class="m-1">Gender:</h3>
                                <h4 class="m-1">{info.gender}</h4>
                            </div>
                            <div class="flex flex-row gap-2">
                                <h3 class="m-1">Age:</h3>
                                <h4 class="m-1">{info.age}</h4>
                            </div>
                            <div class="flex flex-row gap-2">
                                <h3 class="m-1">Height:</h3>
                                <h4 class="m-1">{info.height} cm</h4>
                            </div>
                            <div class="flex flex-row gap-2">
                                <h3 class="m-1">Weight:</h3>
                                <h4 class="m-1">{info.weight} kg</h4>
                            </div>
                        </div>
                        <div class="flex flex-col gap-2">
                            <div class="flex flex-row gap-2">
                                <h3 class="m-1">Allergy:</h3>
                                <h4 class="m-1">
                                    {#if info.allergy.length}
                                        {#each info.allergy as al}
                                            {al},
                                        {/each}
                                    {:else}
                                        {'N/A'}
                                    {/if}
                                </h4>
                            </div>
                            <div class="flex flex-row gap-2">
                                <h3 class="m-1">Alcohol:</h3>
                                <h4 class="m-1">{info.alcohol}</h4>
                            </div>
                            <div class="flex flex-row gap-2">
                                <h3 class="m-1">Smokes:</h3>
                                <h4 class="m-1">{info.smoke}</h4>
                            </div>
                            <div class="flex flex-row gap-2">
                                <h3 class="m-1">Cannabis:</h3>
                                <h4 class="m-1">{info.cannabis}</h4>
                            </div>
                        </div>
                    </div>
                {/if}
            </div>
        {:else if currentTab === 1}
            <!-- medicine -->
            <div class="form-step">
                <h2 class="m-t-0">Add medicine</h2>
                <div class="form-group flex flex-col">
                    <label for="medicine">You can search for a medicine</label>
                    <input
                        use:stopTyping
                        on:stopTyping={handleSearch}
                        type="text"
                        placeholder="Type medicine name"
                        bind:value={medQuery}
                    />
                    <ul class="list-none w-20/22">
                        {#each medResult as med, i}
                            <li
                                class={i === 0 ? 'w-20/22' : 'border-t-1 w-20/22'}
                                on:click={() => {
                                    medicine = med['PROPRIETARYNAME'];
                                    dosage.strength = med['ACTIVE_NUMERATOR_STRENGTH'];
                                    validateMedicine();
                                }}
                            >
                                {med['PROPRIETARYNAME']}<br />
                                <small
                                    >{med['NONPROPRIETARYNAME']}, {med['ACTIVE_NUMERATOR_STRENGTH']}
                                    {med['ACTIVE_INGRED_UNIT']}</small
                                >
                            </li>
                        {/each}
                    </ul>
                </div>
            </div>
        {:else if currentTab === 2}
            <!-- form -->
            <div class="form-step">
                <h2 class="m-t-0">Choose the medicine form</h2>
                <div class="form-group flex flex-col gap-2">
                    <select bind:value={form}>
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
                    <input
                        type="number"
                        placeholder="Add strength"
                        bind:value={dosage.strength}
                        on:input={validateDosage}
                    />
                </div>
                <div class="form-group flex flex-col gap-2">
                    <label for="unit">Choose unit</label>
                    <select bind:value={dosage.unit} on:change={validateDosage}>
                        <option value="mg">mg</option>
                        <option value="mcg">mcg</option>
                        <option value="g">g</option>
                        <option value="ml">mL</option>
                        <option value="%">%</option>
                    </select>
                </div>
            </div>
        {:else if currentTab === 4}
            <!-- schedule -->
            <div class="form-step">
                <h2 class="m-t-0">When to take?</h2>
                <div class="form-group flex flex-col gap-2">
                    <label for="frequency">Frequency</label>
                    <select bind:value={schedule.frequency} on:change={validateSchedule}>
                        <option value={0}>At regular intervals</option>
                        <option value={1}>On specific days of the week</option>
                        <option value={2}>As needed</option>
                    </select>
                </div>
                {#if schedule.frequency === 0}
                    <div class="form-group flex flex-col gap-2 m-t-2">
                        <label for="interval">Choose interval<br />Every</label>
                        <select bind:value={schedule.interval} on:change={validateSchedule}>
                            <option value="1">Day</option>
                            <option value="2">Other days</option>
                            {#each Array(97) as _, n}
                                <option value={n + 3}>{n + 3} days</option>
                            {/each}
                        </select>
                    </div>
                {:else if schedule.frequency === 1}
                    <div class="form-group flex flex-col gap-2 m-t-2">
                        <label for="days">Choose days</label>
                        <div class="display-inherit justify-between">
                            {#each dow as day, i}
                                <label
                                    ><input
                                        type="checkbox"
                                        bind:group={schedule.daysOfWeek}
                                        value={day}
                                        on:change={validateSchedule}
                                    />{day}</label
                                >
                            {/each}
                        </div>
                    </div>
                {/if}
                {#if schedule.frequency !== 2}
                    <div class="form-group flex flex-col gap-2 m-t-2">
                        <label for="start">Start date</label>
                        <input
                            type="date"
                            placeholder="mm/dd/yyyy"
                            bind:value={schedule.startDate}
                            on:input={calculateEndDate}
                        />
                        <label for="start">Duration</label>
                        <div class="flex justify-between">
                            <input class="w-11/22" type="number" bind:value={duration.num} />
                            <select
                                class="w-10/22"
                                bind:value={duration.unit}
                                on:change={calculateEndDate}
                            >
                                <option value={'d'}>day</option>
                                <option value={'w'}>week</option>
                                <option value={'M'}>month</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group flex flex-col gap-2 tod m-t-2">
                        <label for="time">Time of day</label>
                        {#if schedule.timesOfDay.length}
                            {#each schedule.timesOfDay as _, i}
                                <div class="flex justify-between">
                                    <input
                                        type="time"
                                        style="width: 70%"
                                        bind:value={schedule.timesOfDay[i]}
                                    />
                                    <button
                                        style="width: 20%; background-color: #F23535"
                                        on:click={(e) => {
                                            e.preventDefault();
                                            schedule.timesOfDay.splice(i, 1);
                                            schedule.timesOfDay = schedule.timesOfDay;
                                            validateSchedule();
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
                                schedule.timesOfDay = [
                                    ...schedule.timesOfDay,
                                    `${hour < 10 ? '0' : ''}${hour}:${
                                        minute < 10 ? '0' : ''
                                    }${minute}`,
                                ];
                                validateSchedule();
                            }}>Add a time</button
                        >
                    </div>
                {/if}
            </div>
        {:else}
            <!-- review -->
            <div class="form-step">
                <div style="width: 640px;">
                    <h1>Review</h1>
                    <h2>Patient: <small>{patient ? patient : 'null'}</small></h2>

                    <h2>
                        Medicine:
                        <small>
                            {#if medicine}
                                {medicine}, {form}, {dosage.strength} {dosage.unit}
                            {:else}
                                null
                            {/if}
                        </small>
                    </h2>

                    <h2>
                        Schedule: <small
                            >{schedule.startDate.replaceAll('-', '/')} - {schedule.endDate.replaceAll(
                                '-',
                                '/'
                            )}</small
                        >
                    </h2>
                    {#if schedule.frequency === 0}
                        {#if schedule.interval === 1}
                            <h3>Every day</h3>
                        {:else if schedule.interval === 2}
                            <h3>Every other days</h3>
                        {:else}
                            <h3>Every {schedule.interval} days</h3>
                        {/if}
                        <ul>
                            {#each schedule.timesOfDay as time}
                                <li>{time}</li>
                            {/each}
                        </ul>
                    {:else if schedule.frequency === 1}
                        <h3>{schedule.daysOfWeek.join(', ')}</h3>
                        <ul>
                            {#each schedule.timesOfDay as time}
                                <li>{time}</li>
                            {/each}
                        </ul>
                    {:else}
                        <h3>As needed</h3>
                    {/if}
                </div>
            </div>
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
                <button type="button" disabled={cantContinue} on:click={() => handleProgress(1)}
                    >Next</button
                >
            {/if}
        </div>
    </form>
</div>

<style>
    form {
        height: calc(100vh - 280px - 2.5rem - 1.34em);
        /* overflow-y: auto;  */
    }

    .prescribe-form {
        height: calc(100vh - 48px - 136px);
    }

    .form-step {
        padding: 2em;
        max-height: 100%;
    }

    .form-group {
        min-width: 640px;
    }

    .form-group input {
        font-size: 1.3rem;
        max-width: 100%;
    }

    .form-group select {
        font-size: 1.3rem;
        max-width: 100%;
    }

    .form-group ul {
        overflow-x: clip;
        overflow-y: auto;
        max-height: calc(100vh - 400px - 14rem);
        max-width: 640px;
    }

    .tod {
        overflow-y: auto;
        max-height: calc(100vh - 520px - 19.5rem);
    }

    .text-center button {
        width: 8rem;
    }
</style>
