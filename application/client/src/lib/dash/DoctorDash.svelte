<script>

	import { goto } from "$app/navigation";

</script>
<div class="flex flex-col">
    <h1 class="text-5xl">Doctor dashboard</h1>

    <div class="grid gap-4 sm:grid-cols-1 md:grid-cols-2">
        <div>
            <h2>Find Patient</h2>
            <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla eu ex sed sem hendrerit
                accumsan. In hac habitasse platea dictumst. Lorem ipsum dolor sit amet, consectetur
                adipiscing elit. Sed mi nisi, viverra non eros ut, vestibulum imperdiet ante. Duis nulla
                metus, sollicitudin et augue nec, vulputate rhoncus tellus. Sed placerat urna eu ex bibendum
                hendrerit. Proin a gravida eros, dignissim scelerisque neque.
            </p>
            <button on:click={() => goto('/search')}>Search</button>
        </div>
        <div>
            <h2>Prescribe medicine</h2>
            <p>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla eu ex sed sem hendrerit
                accumsan. In hac habitasse platea dictumst. Lorem ipsum dolor sit amet, consectetur
                adipiscing elit. Sed mi nisi, viverra non eros ut, vestibulum imperdiet ante. Duis nulla
                metus, sollicitudin et augue nec, vulputate rhoncus tellus. Sed placerat urna eu ex bibendum
                hendrerit. Proin a gravida eros, dignissim scelerisque neque.
            </p>
            <button on:click={() => goto('/prescribe')}>Start</button>
        </div>
    </div>
</div>
