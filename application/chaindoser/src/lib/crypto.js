export const encryptInfo = async (key, iv, data) => {
    let enc = new TextEncoder()
    let cipher = await crypto.subtle.encrypt(
        { name: 'AES-GCM', iv },
        key,
        enc.encode(JSON.stringify(data))
    )
    return new Uint8Array(cipher).join()
}

export const getCurrentKeyAndIv = async (keyString, ivString) => {
    let key = new Uint32Array(keyString.split(','))
    let iv = new Uint32Array(ivString.split(','))
    console.log({ key, iv });

    // key = await crypto.subtle.importKey('raw', key, 'AES-GCM', true, ['encrypt', 'decrypt'])
    return {
        key: await crypto.subtle.importKey('raw', key, 'AES-GCM', true, ['encrypt', 'decrypt']),
        iv: iv.buffer
    }
}

export const decryptInfo = async (raw, key, iv, address, userType) => {
    try {
        const decrypted = await crypto.subtle.decrypt(
            { name: "AES-GCM", iv },
            key,
            raw.buffer
        );
        console.log({ decrypted });
        let dec = new TextDecoder();

        return JSON.parse(dec.decode(decrypted));
    } catch (error) {
        console.log(error);
        alert("Invalid key");
        if (userType === 'patient') {
            localStorage.removeItem("key");
            window.location.reload();
        } else {
            const vault = JSON.parse(localStorage.getItem('patientKeys'))
            delete vault[address]
            localStorage.setItem("patientKeys", vault)
        }
    }
}