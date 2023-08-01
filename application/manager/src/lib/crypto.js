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