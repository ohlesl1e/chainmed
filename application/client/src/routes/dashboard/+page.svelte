<script>
    import { onMount } from 'svelte/internal';
    import DoctorDash from '../../lib/dash/DoctorDash.svelte';
    import PatientDash from '../../lib/dash/PatientDash.svelte';
    import { goto } from '$app/navigation';
    import keyraw from '../../lib/jwtRS256.key.pub?raw';

    const base64StringToArrayBuffer = (b64str) => {
        var byteStr = atob(b64str);
        var bytes = new Uint8Array(byteStr.length);
        for (var i = 0; i < byteStr.length; i++) {
            bytes[i] = byteStr.charCodeAt(i);
        }
        return bytes.buffer;
    };

    const textToArrayBuffer = (str) => {
        var buf = unescape(encodeURIComponent(str)); // 2 bytes for each char
        var bufView = new Uint8Array(buf.length);
        for (var i = 0; i < buf.length; i++) {
            bufView[i] = buf.charCodeAt(i);
        }
        return bufView;
    };

    const convertPemToBinary = (pem) => {
        var lines = pem.split('\n');
        var encoded = '';
        for (var i = 0; i < lines.length; i++) {
            if (
                lines[i].trim().length > 0 &&
                lines[i].indexOf('-BEGIN PRIVATE KEY-') < 0 &&
                lines[i].indexOf('-BEGIN PUBLIC KEY-') < 0 &&
                lines[i].indexOf('-END PRIVATE KEY-') < 0 &&
                lines[i].indexOf('-END PUBLIC KEY-') < 0
            ) {
                encoded += lines[i].trim();
            }
        }
        return base64StringToArrayBuffer(encoded);
    };

    let type;
    let token = sessionStorage.getItem('token');

    var signAlgorithm = {
        name: 'RSASSA-PKCS1-v1_5',
        hash: {
            name: 'SHA-256',
        },
        modulusLength: 2048,
        extractable: false,
        publicExponent: new Uint8Array([1, 0, 1]),
    };

    onMount(() => {
        let key = convertPemToBinary(keyraw);
        // crypto.subtle
        //     .importKey('spki', key, signAlgorithm, true, ['verify'])
        //     .then((result) => {
        //         let jwt = token.split('.');
        //         console.log(atob(jwt[0]) + atob(jwt[1]));
        //         crypto.subtle
        //             .verify(
        //                 signAlgorithm,
        //                 result,
        //                 token,
        //                 textToArrayBuffer(atob(jwt[0]) + atob(jwt[1]))
        //             )
        //             .then((result) => {
        //                 console.log(result);
        //             })
        //             .catch((err) => {
        //                 console.log(err);
        //             });
        //     })
        //     .catch((err) => {
        //         console.log(err);
        //     });
        if (!token) {
            goto('/');
        }
        let jwt = JSON.parse(atob(token.split('.')[1]));
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
