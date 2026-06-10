function byId(id) {
    return document.getElementById(id);
}

function setStatus(text, type) {
    var status = byId("status");
    status.textContent = text;
    status.className = "status" + (type ? " " + type : "");
}

function trimTrailingSlash(text) {
    return String(text || "").replace(/\/+$/, "");
}

function loadSavedConfig() {
    try {
        var saved = JSON.parse(localStorage.getItem(configStorageKey) || "{}");
        if (saved.baseUrl) byId("baseUrl").value = saved.baseUrl;
        if (saved.accessKey) byId("accessKey").value = saved.accessKey;
        if (saved.accessSecret) byId("accessSecret").value = saved.accessSecret;
    } catch (error) {
        localStorage.removeItem(configStorageKey);
    }
}

function saveConfig() {
    localStorage.setItem(configStorageKey, JSON.stringify({
        baseUrl: byId("baseUrl").value.trim(),
        accessKey: byId("accessKey").value.trim(),
        accessSecret: byId("accessSecret").value
    }));
}

function resetConfig(defaultBaseUrl) {
    localStorage.removeItem(configStorageKey);
    byId("baseUrl").value = defaultBaseUrl || "https://esimapi.esimtours.com";
    byId("accessKey").value = "";
    byId("accessSecret").value = "";
}

function bindConfigInputs() {
    ["baseUrl", "accessKey", "accessSecret"].forEach(function (id) {
        byId(id).addEventListener("change", saveConfig);
        byId(id).addEventListener("input", saveConfig);
    });
}

function randomNonce(length) {
    var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var result = "";
    var values = new Uint32Array(length);
    crypto.getRandomValues(values);
    for (var i = 0; i < length; i++) {
        result += chars[values[i] % chars.length];
    }
    return result;
}

function bytesToHex(buffer) {
    var bytes = new Uint8Array(buffer);
    var hex = "";
    for (var i = 0; i < bytes.length; i++) {
        hex += bytes[i].toString(16).padStart(2, "0");
    }
    return hex;
}

async function hmacSha256Hex(text, secret) {
    var encoder = new TextEncoder();
    var key = await crypto.subtle.importKey(
        "raw",
        encoder.encode(secret || ""),
        { name: "HMAC", hash: "SHA-256" },
        false,
        ["sign"]
    );
    var signature = await crypto.subtle.sign("HMAC", key, encoder.encode(text || ""));
    return bytesToHex(signature);
}

async function buildHeaders(accessKey, accessSecret) {
    var timestamp = Math.floor(Date.now() / 1000);
    var nonce = randomNonce(16);
    var canonicalText = [timestamp, nonce, accessKey || ""].join("|");
    var signature = await hmacSha256Hex(canonicalText, accessSecret);
    return {
        "Content-Type": "application/json",
        "X-Access-Key": accessKey,
        "X-Timestamp": String(timestamp),
        "X-Nonce": nonce,
        "X-Signature": signature
    };
}

function normalizePositiveNumber(value, fallback) {
    var number = Number(value || fallback);
    if (!Number.isFinite(number) || number < 1) {
        return fallback;
    }
    return Math.floor(number);
}

function detailCard(label, value) {
    var displayValue = value == null || value === "" ? "-" : value;
    return '<div class="detail-card">' +
        '<div class="detail-label">' + escapeHtml(label) + '</div>' +
        '<div class="detail-value">' + escapeHtml(displayValue) + '</div>' +
        '</div>';
}

function escapeHtml(value) {
    return String(value == null ? "" : value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
