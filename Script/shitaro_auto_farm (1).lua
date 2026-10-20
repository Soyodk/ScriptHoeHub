if not LPH_OBFUSCATED then
        local a = function() end
        local g = getgenv and getgenv() or _G
        g.LPH_ATTRIBUTES = a
        g.ENCRYPT, g.VM, g.PRESET, g.OPTIMIZE, g.TRANSFORM, g.ERROR_HANDLING = a, a, a, a, a, a
        g.UNROLL, g.INLINE, g.NO_UPVALUES = a, a, a
        g.NONE, g.OPAL, g.ONYX, g.FAST, g.BALANCED, g.SECURE = a, a, a, a, a, a
        g.EXTRACT, g.CONTROL_FLOW, g.REWRITE_NAMECALLS, g.GLOBALS, g.CONSTANTS = a, a, a, a, a
end

print("shitaro auto farm + alta performance + whitelist + webhook + multi-contas loaded")
local shhttp = rawget(getfenv(), "request")
        or (syn and syn.request)
        or (http and http.request)
        or (fluxus and fluxus.request)
        or (getgenv and getgenv().request)

if type(shhttp) ~= "function" then
        shhttp = function()
                return nil
        end
end

local shjson = game:GetService("HttpService")
local shnet = {}

--============================================================
-- KEYLESS BUILD
-- The Jnkie license gate (verifyOpen SDK + SCRIPT_KEY + the
-- 60s revalidation thread + the LocalPlayer:Kick path) is gone.
-- No network, no key, no kick. Same local API surface so the
-- rest of the script keeps working unchanged.
--============================================================
local shkey = {
        alive = true,
        reason = "KEYLESS",
        value = "FREE",
        unload = nil,
}

function shkey.bind(fn)
        if type(fn) == "function" then
                shkey.unload = fn
        end
end

function shkey.stop()
        shkey.alive = false
end

function shkey.watch()
        shkey.alive = true
end

function shkey.open()
        local genv = getgenv()
        local prev = genv.SHKEY

        if type(prev) == "table" and type(prev.stop) == "function" then
                pcall(prev.stop)
        end

        shkey.alive = true
        shkey.reason = "KEYLESS"

        genv.SCRIPT_KEY = shkey.value
        genv.SHKEY = shkey
        genv.JD_IS_PREMIUM = true
        genv.JD_REASON = "KEYLESS"

        shkey.watch()

        return true
end

if not shkey.open() then
        return
end

do
        local band, bxor, bnot = bit32.band, bit32.bxor, bit32.bnot
        local rrot, rshift = bit32.rrotate, bit32.rshift
        local schar, sbyte, srep, ssub = string.char, string.byte, string.rep, string.sub
        local tconcat = table.concat
        local floor = math.floor

        local K = {
                0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
                0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
                0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
                0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
                0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
                0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
                0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
                0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
        }

        local function sha256(msg)
                local h1,h2,h3,h4,h5,h6,h7,h8 =
                        0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
                        0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19

                local L = #msg
                local bitLenLo = (L * 8) % 4294967296
                local bitLenHi = floor((L * 8) / 4294967296)
                local pad = (56 - (L + 1) % 64) % 64
                msg = msg .. "\128" .. srep("\0", pad)
                        .. schar(
                                floor(bitLenHi / 16777216) % 256,
                                floor(bitLenHi / 65536) % 256,
                                floor(bitLenHi / 256) % 256,
                                bitLenHi % 256,
                                floor(bitLenLo / 16777216) % 256,
                                floor(bitLenLo / 65536) % 256,
                                floor(bitLenLo / 256) % 256,
                                bitLenLo % 256
                        )

                local W = table.create and table.create(64, 0) or {}
                for chunk = 1, #msg, 64 do
                        for i = 0, 15 do
                                local o = chunk + i * 4
                                W[i+1] = sbyte(msg, o) * 16777216 + sbyte(msg, o+1) * 65536 + sbyte(msg, o+2) * 256 + sbyte(msg, o+3)
                        end
                        for i = 17, 64 do
                                local w15 = W[i-15]
                                local w2 = W[i-2]
                                local s0 = bxor(rrot(w15, 7), rrot(w15, 18), rshift(w15, 3))
                                local s1 = bxor(rrot(w2, 17), rrot(w2, 19), rshift(w2, 10))
                                W[i] = (W[i-16] + s0 + W[i-7] + s1) % 4294967296
                        end
                        local a,b,c,d,e,f,g,hh = h1,h2,h3,h4,h5,h6,h7,h8
                        for i = 1, 64 do
                                local S1 = bxor(rrot(e, 6), rrot(e, 11), rrot(e, 25))
                                local ch = bxor(band(e, f), band(bnot(e), g))
                                local t1 = (hh + S1 + ch + K[i] + W[i]) % 4294967296
                                local S0 = bxor(rrot(a, 2), rrot(a, 13), rrot(a, 22))
                                local mj = bxor(band(a, b), band(a, c), band(b, c))
                                local t2 = (S0 + mj) % 4294967296
                                hh = g; g = f; f = e; e = (d + t1) % 4294967296
                                d = c; c = b; b = a; a = (t1 + t2) % 4294967296
                        end
                        h1 = (h1 + a) % 4294967296
                        h2 = (h2 + b) % 4294967296
                        h3 = (h3 + c) % 4294967296
                        h4 = (h4 + d) % 4294967296
                        h5 = (h5 + e) % 4294967296
                        h6 = (h6 + f) % 4294967296
                        h7 = (h7 + g) % 4294967296
                        h8 = (h8 + hh) % 4294967296
                end

                local function w4(v)
                        return schar(floor(v / 16777216) % 256, floor(v / 65536) % 256, floor(v / 256) % 256, v % 256)
                end
                return w4(h1)..w4(h2)..w4(h3)..w4(h4)..w4(h5)..w4(h6)..w4(h7)..w4(h8)
        end

        local function hmac256(key, msg)
                if #key > 64 then key = sha256(key) end
                if #key < 64 then key = key .. srep("\0", 64 - #key) end
                local outer, inner = {}, {}
                for j = 1, 64 do
                        local kb = sbyte(key, j)
                        outer[j] = schar(bxor(kb, 0x5c))
                        inner[j] = schar(bxor(kb, 0x36))
                end
                return sha256(tconcat(outer) .. sha256(tconcat(inner) .. msg))
        end

        local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
        local function b64url_enc(s)
                local out, oi = {}, 0
                local n = #s
                local i = 1
                while i <= n do
                        local a = sbyte(s, i)
                        local b = sbyte(s, i+1)
                        local c = sbyte(s, i+2)
                        local trip = a * 65536 + (b or 0) * 256 + (c or 0)
                        oi = oi + 1; out[oi] = ssub(b64chars, floor(trip / 262144) + 1, floor(trip / 262144) + 1)
                        oi = oi + 1; out[oi] = ssub(b64chars, floor(trip / 4096) % 64 + 1, floor(trip / 4096) % 64 + 1)
                        if b then
                                oi = oi + 1; out[oi] = ssub(b64chars, floor(trip / 64) % 64 + 1, floor(trip / 64) % 64 + 1)
                        end
                        if c then
                                oi = oi + 1; out[oi] = ssub(b64chars, trip % 64 + 1, trip % 64 + 1)
                        end
                        i = i + 3
                end
                return tconcat(out)
        end

        local b64map = {}
        for i = 1, 64 do
                local ch = ssub("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", i, i)
                b64map[ch] = i - 1
        end
        local function b64url_dec(s)
                s = (s:gsub("-", "+"):gsub("_", "/"):gsub("[^A-Za-z0-9+/=]", ""))
                local pad = (4 - #s % 4) % 4
                s = s .. srep("=", pad)
                local out, oi = {}, 0
                for i = 1, #s, 4 do
                        local a = b64map[ssub(s, i, i)] or 0
                        local b = b64map[ssub(s, i+1, i+1)] or 0
                        local c = b64map[ssub(s, i+2, i+2)] or 0
                        local d = b64map[ssub(s, i+3, i+3)] or 0
                        local n = a*262144 + b*4096 + c*64 + d
                        oi = oi + 1; out[oi] = schar(floor(n / 65536) % 256)
                        if ssub(s, i+2, i+2) ~= "=" then
                                oi = oi + 1; out[oi] = schar(floor(n / 256) % 256)
                        end
                        if ssub(s, i+3, i+3) ~= "=" then
                                oi = oi + 1; out[oi] = schar(n % 256)
                        end
                end
                return tconcat(out)
        end

        local function hex2bin(h)
                return (h:gsub("..", function(hh) return schar(tonumber(hh, 16)) end))
        end

        local libKey = hex2bin("02d417c2bd7b033a00d3c4e9fda43fc56761f68f516cf68a68a6110f2cb99e49")
        local rng = Random.new((tick() * 1e6) % 2147483647 + os.time())

        local function randBytes(n)
                local t = {}
                for i = 1, n do t[i] = schar(rng:NextInteger(0, 255)) end
                return tconcat(t)
        end

        local function be64(v)
                local t = {}
                for i = 8, 1, -1 do t[i] = schar(v % 256); v = floor(v / 256) end
                return tconcat(t)
        end

        local function escape(s)
                return (string.gsub(s, "[^%w%-%._~/]", function(c)
                        return string.format("%%%02X", string.byte(c))
                end))
        end

        local lshift, rshift32, band32 = bit32.lshift, bit32.rshift, bit32.band

        local function stream(seed)
                local function word(i)
                        local a, b, c, d = sbyte(seed, i, i + 3)
                        return d * 16777216 + c * 65536 + b * 256 + a
                end

                local s0, s1, s2, s3 = word(1), word(5), word(9), word(13)

                if s0 == 0 and s1 == 0 and s2 == 0 and s3 == 0 then
                        s0, s1, s2, s3 = 0x9e3779b9, 0x243f6a88, 0xb7e15162, 0x85ebca6b
                end

                return function()
                        local t = s0
                        t = bxor(t, lshift(t, 11))
                        t = bxor(t, rshift32(t, 8))
                        s0, s1, s2 = s1, s2, s3
                        local u = s3
                        u = bxor(u, rshift32(u, 19))
                        u = bxor(u, t)
                        s3 = u
                        return u
                end
        end

        local function unmask(body, nonce)
                local nextWord = stream(hmac256(libKey, "SHITARO-ASSET-MASK-v1\0" .. nonce))
                local n = #body

                if buffer and buffer.fromstring then
                        local buf = buffer.fromstring(body)
                        local i = 0

                        while i + 4 <= n do
                                buffer.writeu32(buf, i, bxor(buffer.readu32(buf, i), nextWord()))
                                i = i + 4
                        end

                        if i < n then
                                local k = nextWord()
                                local j = 0

                                while i + j < n do
                                        buffer.writeu8(buf, i + j, bxor(buffer.readu8(buf, i + j), band32(rshift32(k, j * 8), 255)))
                                        j = j + 1
                                end
                        end

                        return buffer.tostring(buf)
                end

                local out, oi = {}, 0
                local i = 1

                while i <= n do
                        local k = nextWord()

                        for j = 0, 3 do
                                if i + j <= n then
                                        oi = oi + 1
                                        out[oi] = schar(bxor(sbyte(body, i + j), band32(rshift32(k, j * 8), 255)))
                                end
                        end

                        i = i + 4
                end

                return tconcat(out)
        end

        local function signed(base, kind, name)
                local nonce = randBytes(16)
                local tsb = be64(os.time())
                local tok = b64url_enc(nonce .. tsb .. hmac256(libKey, "SHITARO-" .. kind .. "-REQ-v1\0" .. name .. "\0" .. nonce .. "\0" .. tsb))

                local ok, resp = pcall(shhttp, {
                        Url = base .. escape(name),
                        Method = "GET",
                        Headers = {
                                ["X-Shitaro-Token"] = tok,
                                ["Accept"] = "*/*",
                                ["Cache-Control"] = "no-cache",
                        },
                })

                if not ok or type(resp) ~= "table" or resp.StatusCode ~= 200 then
                        return nil
                end

                local body = resp.Body

                if type(body) ~= "string" or #body == 0 then
                        return nil
                end

                local hd = resp.Headers or {}
                local sigStr = hd["X-Shitaro-Sig"] or hd["x-shitaro-sig"] or ""

                if sigStr == "" then
                        return nil
                end

                if b64url_dec(sigStr) ~= hmac256(libKey, "SHITARO-" .. kind .. "-RESP-v1\0" .. name .. "\0" .. nonce .. "\0" .. be64(#body) .. body) then
                        return nil
                end

                if kind == "ASSET" then
                        return unmask(body, nonce)
                end

                return body
        end

        function shnet.lib(name)
                return signed("https://shitaro.lol/api/library/", "LIB", name)
        end

        function shnet.asset(name)
                return signed("https://shitaro.lol/api/assets/", "ASSET", name)
        end
end

local shblob

do
        local bxor, lrotate, lshift, rshift, band = bit32.bxor, bit32.lrotate, bit32.lshift, bit32.rshift, bit32.band
        local sbyte, schar, ssub, tconcat = string.byte, string.char, string.sub, table.concat

        local vault = {
                0x5B, 0x27, 0xE4, 0x91, 0x0C, 0xBD, 0x7A, 0x36,
                0xF1, 0x48, 0x92, 0xAE, 0x63, 0xD5, 0x1F, 0x8C,
                0x2A, 0x74, 0xB0, 0x59, 0xEE, 0x13, 0xC7, 0x6D,
                0x9F, 0x35, 0x88, 0x4C, 0xA1, 0x70, 0xDB, 0x26,
        }

        local seeds = {
                { 0x9E3779B9, 0x85EBCA6B },
                { 0x243F6A88, 0xC2B2AE35 },
                { 0xB7E15162, 0x27D4EB2F },
                { 0x85EBCA6B, 0x165667B1 },
        }

        local lut = nil

        local function alphabet()
                if lut then
                        return lut
                end

                local abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
                lut = {}

                for i = 1, #abc do
                        lut[sbyte(abc, i)] = i - 1
                end

                return lut
        end

        local function unb64(text)
                local tbl = alphabet()
                local out, n = {}, 0
                local acc, bits = 0, 0

                for i = 1, #text do
                        local c = sbyte(text, i)
                        local v = tbl[c]

                        if v then
                                acc = acc * 64 + v
                                bits = bits + 6

                                if bits >= 8 then
                                        bits = bits - 8
                                        local div = 2 ^ bits
                                        local byte = math.floor(acc / div)
                                        acc = acc - byte * div
                                        n = n + 1
                                        out[n] = schar(byte % 256)
                                end
                        elseif c ~= 61 and c ~= 10 and c ~= 13 and c ~= 32 and c ~= 9 then
                                return nil
                        end
                end

                return tconcat(out)
        end

        local function churn(feed, init, salt)
                local h = init

                for i = 1, #feed do
                        h = bxor(h, feed[i])
                        h = lrotate(h, 7)
                        h = bxor(h, salt)
                end

                return h
        end

        local function flow(nonce)
                local feed = table.create(#vault + #nonce)

                for i = 1, #vault do
                        feed[i] = vault[i]
                end

                for i = 1, #nonce do
                        feed[#vault + i] = sbyte(nonce, i)
                end

                local s0 = churn(feed, seeds[1][1], seeds[1][2])
                local s1 = churn(feed, seeds[2][1], seeds[2][2])
                local s2 = churn(feed, seeds[3][1], seeds[3][2])
                local s3 = churn(feed, seeds[4][1], seeds[4][2])

                if s0 == 0 and s1 == 0 and s2 == 0 and s3 == 0 then
                        s0, s1, s2, s3 = 0x9E3779B9, 0x243F6A88, 0xB7E15162, 0x85EBCA6B
                end

                return function()
                        local t = s0
                        t = bxor(t, lshift(t, 11))
                        t = bxor(t, rshift(t, 8))
                        s0, s1, s2 = s1, s2, s3
                        local u = s3
                        u = bxor(u, rshift(u, 19))
                        u = bxor(u, t)
                        s3 = u
                        return u
                end
        end

        local function peel(nonce, body)
                local nextWord = flow(nonce)
                local n = #body

                if buffer and buffer.fromstring then
                        local buf = buffer.fromstring(body)
                        local i = 0

                        while i + 4 <= n do
                                buffer.writeu32(buf, i, bxor(buffer.readu32(buf, i), nextWord()))
                                i = i + 4
                        end

                        if i < n then
                                local k = nextWord()
                                local j = 0

                                while i + j < n do
                                        buffer.writeu8(buf, i + j, bxor(buffer.readu8(buf, i + j), band(rshift(k, j * 8), 255)))
                                        j = j + 1
                                end
                        end

                        return buffer.tostring(buf)
                end

                local out, oi = {}, 0
                local i = 1

                while i <= n do
                        local k = nextWord()

                        for j = 0, 3 do
                                if i + j <= n then
                                        oi = oi + 1
                                        out[oi] = schar(bxor(sbyte(body, i + j), band(rshift(k, j * 8), 255)))
                                end
                        end

                        i = i + 4
                end

                return tconcat(out)
        end

        local function stamp(text)
                local h = 0x243F6A88
                local n = #text
                local i = 1

                while i + 7 <= n do
                        local b1, b2, b3, b4, b5, b6, b7, b8 = sbyte(text, i, i + 7)
                        h = bxor(lrotate(bxor(h, b1), 7), 0x9E3779B9)
                        h = bxor(lrotate(bxor(h, b2), 7), 0x9E3779B9)
                        h = bxor(lrotate(bxor(h, b3), 7), 0x9E3779B9)
                        h = bxor(lrotate(bxor(h, b4), 7), 0x9E3779B9)
                        h = bxor(lrotate(bxor(h, b5), 7), 0x9E3779B9)
                        h = bxor(lrotate(bxor(h, b6), 7), 0x9E3779B9)
                        h = bxor(lrotate(bxor(h, b7), 7), 0x9E3779B9)
                        h = bxor(lrotate(bxor(h, b8), 7), 0x9E3779B9)
                        i = i + 8
                end

                while i <= n do
                        h = bxor(lrotate(bxor(h, sbyte(text, i)), 7), 0x9E3779B9)
                        i = i + 1
                end

                return h
        end

        shblob = function(data)
                if type(data) ~= "string" or #data < 11 then
                        return nil
                end

                local raw = data

                if sbyte(raw, 1) ~= 0x53 then
                        raw = unb64(data)

                        if type(raw) ~= "string" or #raw < 11 then
                                return nil
                        end
                end

                if sbyte(raw, 1) ~= 0x53 then
                        return nil
                end

                local ver = sbyte(raw, 2)

                if ver ~= 1 and ver ~= 2 then
                        return nil
                end

                local a, b, c, d = sbyte(raw, 7, 10)
                local plain = peel(ssub(raw, 3, 6), ssub(raw, 11))

                if stamp(plain) ~= d * 16777216 + c * 65536 + b * 256 + a then
                        return nil
                end

                return plain
        end
end

local shcontent = game:GetService("ContentProvider")

local assetIds = {}
local assetTemps = {}
local assetIndex = nil
local assetProbed = false
local assetKeep = false
local assetBook = nil
local assetNames = nil

local function assetParse(raw)
        if type(raw) ~= "string" or #raw == 0 then
                return nil
        end

        local ok, tbl = pcall(function()
                return shjson:JSONDecode(raw)
        end)

        if ok and type(tbl) == "table" and type(tbl.f) == "table" then
                return tbl
        end

        return nil
end

local assetLedger = string.char(98, 53, 51, 50, 50, 55, 102, 48, 100, 97, 46, 112, 110, 103)

local function assetBind()
        if assetBook then
                return assetBook
        end

        local plain = shblob(shnet.asset(assetLedger))

        if type(plain) ~= "string" or #plain == 0 then
                return nil
        end

        local book, names = {}, {}

        for line in string.gmatch(plain, "([^\n]+)") do
                local logical, server, size, kind = string.match(line, "^(.-)\t(.-)\t(%d+)\t(%a+)$")
                local bytes = tonumber(size)

                if logical and logical ~= "" and server and server ~= "" and bytes and bytes > 0 then
                        book[logical] = { srv = server, size = bytes, kind = kind }

                        if kind ~= "data" then
                                names[#names + 1] = logical
                        end
                end
        end

        if not next(book) then
                return nil
        end

        table.sort(names)

        assetBook, assetNames = book, names

        return book
end

local function assetRows()
        local book = assetBind()

        if book then
                local out = {}

                for i = 1, #assetNames do
                        local entry = book[assetNames[i]]
                        out[i] = { n = assetNames[i], s = entry.size }
                end

                return out
        end

        if assetIndex then
                return assetIndex.f
        end

        local got = assetParse(shnet.asset("index"))

        if got then
                assetIndex = got

                return got.f
        end

        return {}
end

local function assetSize(name)
        local book = assetBind()

        if book then
                local entry = book[name]

                return entry and entry.size or nil
        end

        if not assetIndex then
                return nil
        end

        for _, e in ipairs(assetIndex.f) do
                if type(e) == "table" and e.n == name then
                        return e.s
                end
        end
end

local function assetCustom()
        return getcustomasset
                or getsynasset
                or (syn and syn.get_custom_asset)
                or (fluxus and fluxus.get_custom_asset)
end

local function assetKind(name)
        if string.match(name, "%.mp3$") or string.match(name, "%.wav$") or string.match(name, "%.ogg$") then
                return "sound"
        end

        return "image"
end

local function assetReady(id, kind)
        local holder

        if kind == "sound" then
                holder = Instance.new("Sound")
                holder.SoundId = id
        else
                holder = Instance.new("ImageLabel")
                holder.Image = id
        end

        local state = nil

        pcall(function()
                shcontent:PreloadAsync({ holder }, function(_, st)
                        state = st
                end)
        end)

        pcall(function()
                holder:Destroy()
        end)

        return state == Enum.AssetFetchStatus.Success
end

local function assetDrop(path)
        if type(delfile) ~= "function" then
                return false
        end

        return pcall(delfile, path) == true
end

local function assetSlot(name)
        local ext = string.match(name, "(%.%w+)$") or ""

        return string.format("shv_%08x%08x%s", math.random(0, 268435455), math.random(0, 268435455), ext)
end

local function assetMake(name, data)
        local custom = assetCustom()

        if type(custom) ~= "function" or type(writefile) ~= "function" then
                return nil
        end

        local kind = assetKind(name)
        local path = assetSlot(name)

        if not pcall(writefile, path, data) then
                return nil
        end

        local ok, id = pcall(custom, path)

        if not ok or type(id) ~= "string" or id == "" then
                assetDrop(path)
                return nil
        end

        assetReady(id, kind)

        if not assetProbed and not assetKeep then
                assetProbed = true

                if assetDrop(path) then
                        if assetReady(id, kind) then
                                return id
                        end

                        assetKeep = true

                        if not pcall(writefile, path, data) then
                                return nil
                        end

                        local again, fresh = pcall(custom, path)

                        if not again or type(fresh) ~= "string" or fresh == "" then
                                return nil
                        end

                        id = fresh
                        assetReady(id, kind)
                else
                        assetKeep = true
                end
        end

        if assetKeep or not assetDrop(path) then
                assetTemps[#assetTemps + 1] = path
        end

        return id
end

local function assetGet(name)
        if type(name) ~= "string" or name == "" then
                return nil
        end

        name = string.gsub(name, "\\", "/")
        name = string.gsub(name, "^%./", "")

        local hit = assetIds[name]

        if hit then
                return hit
        end

        local book = assetBind()
        local entry = book and book[name]
        local data = shnet.asset(entry and entry.srv or name)

        if type(data) ~= "string" or #data == 0 then
                return nil
        end

        if entry then
                data = shblob(data)

                if type(data) ~= "string" or #data ~= entry.size then
                        return nil
                end
        else
                local size = assetSize(name)

                if type(size) == "number" and size > 0 and #data ~= size then
                        return nil
                end
        end

        local id = assetMake(name, data)
        data = nil

        if id then
                assetIds[name] = id
        end

        return id
end

local function assetPurge()
        if type(delfile) ~= "function" then
                return
        end

        local stale = { "assets/shitaro_index.dat", "assets/cloud_accent.png" }

        for _, e in ipairs(assetRows()) do
                if type(e) == "table" and type(e.n) == "string" then
                        stale[#stale + 1] = string.find(e.n, "/", 1, true) and e.n or ("assets/" .. e.n)
                end
        end

        for _, p in ipairs(stale) do
                if type(isfile) == "function" then
                        local ok, has = pcall(isfile, p)

                        if ok and has then
                                pcall(delfile, p)
                        end
                end
        end

        if type(listfiles) ~= "function" then
                return
        end

        local ok, entries = pcall(listfiles, "")

        if not ok or type(entries) ~= "table" then
                return
        end

        for _, f in ipairs(entries) do
                local nm = string.match(string.gsub(tostring(f), "\\", "/"), "([^/]+)$")

                if nm and (string.match(nm, "^shitaro_snd_%d+") or string.match(nm, "^shv_%x+")) then
                        pcall(delfile, nm)
                end
        end
end

local function assetFlush()
        for i = #assetTemps, 1, -1 do
                assetDrop(assetTemps[i])
                assetTemps[i] = nil
        end
end

getgenv().shitaro_asset = assetGet

getgenv().shitaro_data = function(name)
        local book = assetBind()
        local entry = book and book[name]

        if not entry then
                return nil
        end

        local plain = shblob(shnet.asset(entry.srv))

        if type(plain) ~= "string" or #plain ~= entry.size then
                return nil
        end

        return plain
end

getgenv().shitaro_assetlist = function(prefix)
        local out = {}

        for _, e in ipairs(assetRows()) do
                if type(e) == "table" and type(e.n) == "string" then
                        if type(prefix) ~= "string" or prefix == "" or string.sub(e.n, 1, #prefix) == prefix then
                                out[#out + 1] = e.n
                        end
                end
        end

        return out
end

getgenv().shitaro_volatile = function(path, id, kind)
        if type(path) ~= "string" or type(id) ~= "string" or id == "" then
                return id
        end

        kind = kind == "sound" and "sound" or "image"

        assetReady(id, kind)

        if assetKeep or not assetDrop(path) then
                assetTemps[#assetTemps + 1] = path
        end

        return id
end

getgenv().shitaro_assetflush = assetFlush

task.spawn(assetPurge)

local cloudAssetPath = "assets/cloud.png"

local cloudIconPath = "assets/cloud_accent.png"

local pngRecolorWhite

do
        local floor = math.floor
        local unpack = table.unpack or unpack

        local function slowXor(a, b)
                local r, bit = 0, 1
                while a > 0 or b > 0 do
                        local ab, bb = a % 2, b % 2
                        if ab ~= bb then r = r + bit end
                        a = (a - ab) / 2
                        b = (b - bb) / 2
                        bit = bit * 2
                end
                return r
        end

        local bxor = (bit32 and bit32.bxor) or slowXor

        local crcTable

        local function crc32(s)
                if not crcTable then
                        crcTable = {}
                        for i = 0, 255 do
                                local c = i
                                for _ = 1, 8 do
                                        if c % 2 == 1 then
                                                c = bxor(floor(c / 2), 3988292384)
                                        else
                                                c = floor(c / 2)
                                        end
                                end
                                crcTable[i] = c
                        end
                end

                local crc = 4294967295
                for i = 1, #s do
                        crc = bxor(crcTable[bxor(crc % 256, string.byte(s, i))], floor(crc / 256))
                end
                return bxor(crc, 4294967295)
        end

        local LBASE = {3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258}
        local LEXT = {0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0}
        local DBASE = {1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577}
        local DEXT = {0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13}
        local CLORDER = {16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15}

        local function inflate(data, startPos)
                local pos = startPos
                local buf, cnt = 0, 0
                local out, outn = {}, 0

                local function bits(n)
                        if n == 0 then return 0 end
                        while cnt < n do
                                buf = buf + (string.byte(data, pos) or 0) * 2 ^ cnt
                                pos = pos + 1
                                cnt = cnt + 8
                        end
                        local v = buf % 2 ^ n
                        buf = (buf - v) / 2 ^ n
                        cnt = cnt - n
                        return v
                end

                local function build(lengths, n)
                        local count, symbol = {}, {}
                        for i = 0, 15 do count[i] = 0 end
                        for i = 0, n - 1 do
                                local l = lengths[i] or 0
                                count[l] = count[l] + 1
                        end
                        count[0] = 0
                        local offs = {}
                        offs[1] = 0
                        for l = 1, 15 do offs[l + 1] = offs[l] + count[l] end
                        for i = 0, n - 1 do
                                local l = lengths[i] or 0
                                if l ~= 0 then
                                        symbol[offs[l]] = i
                                        offs[l] = offs[l] + 1
                                end
                        end
                        return { count = count, symbol = symbol }
                end

                local function decode(h)
                        local code, first, index = 0, 0, 0
                        for len = 1, 15 do
                                code = code + bits(1)
                                local c = h.count[len]
                                if code - c < first then
                                        return h.symbol[index + (code - first)]
                                end
                                index = index + c
                                first = (first + c) * 2
                                code = code * 2
                        end
                        return nil
                end

                local fixedL, fixedD

                while true do
                        local last = bits(1)
                        local btype = bits(2)

                        if btype == 0 then
                                buf, cnt = 0, 0
                                local len = (string.byte(data, pos) or 0) + (string.byte(data, pos + 1) or 0) * 256
                                pos = pos + 4
                                for _ = 1, len do
                                        outn = outn + 1
                                        out[outn] = string.byte(data, pos) or 0
                                        pos = pos + 1
                                end
                        elseif btype == 1 or btype == 2 then
                                local lcodes, dcodes

                                if btype == 1 then
                                        if not fixedL then
                                                local l = {}
                                                for i = 0, 143 do l[i] = 8 end
                                                for i = 144, 255 do l[i] = 9 end
                                                for i = 256, 279 do l[i] = 7 end
                                                for i = 280, 287 do l[i] = 8 end
                                                fixedL = build(l, 288)
                                                local d = {}
                                                for i = 0, 29 do d[i] = 5 end
                                                fixedD = build(d, 30)
                                        end
                                        lcodes, dcodes = fixedL, fixedD
                                else
                                        local hlit = bits(5) + 257
                                        local hdist = bits(5) + 1
                                        local hclen = bits(4) + 4
                                        local cl = {}
                                        for i = 0, 18 do cl[i] = 0 end
                                        for i = 1, hclen do cl[CLORDER[i]] = bits(3) end
                                        local clh = build(cl, 19)
                                        local lens = {}
                                        local i = 0
                                        while i < hlit + hdist do
                                                local sym = decode(clh)
                                                if sym == nil then return nil end
                                                if sym < 16 then
                                                        lens[i] = sym
                                                        i = i + 1
                                                elseif sym == 16 then
                                                        local prev = lens[i - 1] or 0
                                                        for _ = 1, 3 + bits(2) do
                                                                lens[i] = prev
                                                                i = i + 1
                                                        end
                                                elseif sym == 17 then
                                                        for _ = 1, 3 + bits(3) do
                                                                lens[i] = 0
                                                                i = i + 1
                                                        end
                                                else
                                                        for _ = 1, 11 + bits(7) do
                                                                lens[i] = 0
                                                                i = i + 1
                                                        end
                                                end
                                        end
                                        local ll, dl = {}, {}
                                        for j = 0, hlit - 1 do ll[j] = lens[j] or 0 end
                                        for j = 0, hdist - 1 do dl[j] = lens[hlit + j] or 0 end
                                        lcodes = build(ll, hlit)
                                        dcodes = build(dl, hdist)
                                end

                                while true do
                                        local sym = decode(lcodes)
                                        if sym == nil then return nil end
                                        if sym < 256 then
                                                outn = outn + 1
                                                out[outn] = sym
                                        elseif sym == 256 then
                                                break
                                        else
                                                sym = sym - 256
                                                if sym > 29 then return nil end
                                                local length = LBASE[sym] + bits(LEXT[sym])
                                                local dsym = decode(dcodes)
                                                if dsym == nil or dsym > 29 then return nil end
                                                local dist = DBASE[dsym + 1] + bits(DEXT[dsym + 1])
                                                local from = outn - dist
                                                if from < 0 then return nil end
                                                for k = 1, length do
                                                        outn = outn + 1
                                                        out[outn] = out[from + k]
                                                end
                                        end
                                end
                        else
                                return nil
                        end

                        if last == 1 then break end
                end

                return out, outn
        end

        local function bytesToString(t, n)
                local parts, p = {}, 0
                local i = 1
                while i <= n do
                        local j = i + 2047
                        if j > n then j = n end
                        p = p + 1
                        parts[p] = string.char(unpack(t, i, j))
                        i = j + 1
                end
                return table.concat(parts)
        end

        local function u32(v)
                return string.char(floor(v / 16777216) % 256, floor(v / 65536) % 256, floor(v / 256) % 256, v % 256)
        end

        local function pngChunk(typ, data)
                return u32(#data) .. typ .. data .. u32(crc32(typ .. data))
        end

        pngRecolorWhite = function(data, maxSize)
                if type(data) ~= "string" or string.sub(data, 1, 8) ~= "\137PNG\13\10\26\10" then
                        return nil
                end

                local pos = 9
                local w, h, depth, ctype, interlace
                local idat = {}

                while pos + 8 <= #data + 1 do
                        local b1, b2, b3, b4 = string.byte(data, pos, pos + 3)
                        local len = ((b1 * 256 + b2) * 256 + b3) * 256 + b4
                        local typ = string.sub(data, pos + 4, pos + 7)
                        local body = string.sub(data, pos + 8, pos + 7 + len)

                        if typ == "IHDR" then
                                local p = string.byte
                                w = ((p(body, 1) * 256 + p(body, 2)) * 256 + p(body, 3)) * 256 + p(body, 4)
                                h = ((p(body, 5) * 256 + p(body, 6)) * 256 + p(body, 7)) * 256 + p(body, 8)
                                depth = p(body, 9)
                                ctype = p(body, 10)
                                interlace = p(body, 13)
                        elseif typ == "IDAT" then
                                idat[#idat + 1] = body
                        elseif typ == "IEND" then
                                break
                        end

                        pos = pos + 12 + len
                end

                if not w or depth ~= 8 or interlace ~= 0 then return nil end

                local bpp = (ctype == 6 and 4) or (ctype == 4 and 2) or nil
                if not bpp then return nil end

                local z = table.concat(idat)
                if #z < 3 then return nil end

                local px, pxn = inflate(z, 3)
                if not px then return nil end

                local stride = w * bpp
                if pxn < h * (stride + 1) then return nil end

                local rows = {}
                local src = 1
                local prev

                for y = 0, h - 1 do
                        local filter = px[src]
                        src = src + 1
                        local row = {}
                        for i = 1, stride do
                                row[i] = px[src]
                                src = src + 1
                        end

                        if filter == 1 then
                                for i = bpp + 1, stride do
                                        row[i] = (row[i] + row[i - bpp]) % 256
                                end
                        elseif filter == 2 then
                                if prev then
                                        for i = 1, stride do
                                                row[i] = (row[i] + prev[i]) % 256
                                        end
                                end
                        elseif filter == 3 then
                                for i = 1, stride do
                                        local left = (i > bpp) and row[i - bpp] or 0
                                        local up = prev and prev[i] or 0
                                        row[i] = (row[i] + floor((left + up) / 2)) % 256
                                end
                        elseif filter == 4 then
                                for i = 1, stride do
                                        local left = (i > bpp) and row[i - bpp] or 0
                                        local up = prev and prev[i] or 0
                                        local ul = (prev and i > bpp) and prev[i - bpp] or 0
                                        local pp = left + up - ul
                                        local pa, pb, pc = math.abs(pp - left), math.abs(pp - up), math.abs(pp - ul)
                                        local pr = ul
                                        if pa <= pb and pa <= pc then
                                                pr = left
                                        elseif pb <= pc then
                                                pr = up
                                        end
                                        row[i] = (row[i] + pr) % 256
                                end
                        elseif filter ~= 0 then
                                return nil
                        end

                        rows[y] = row
                        prev = row
                end

                local tw, th = w, h
                if maxSize and w > maxSize then
                        tw = maxSize
                        th = floor(h * maxSize / w + 0.5)
                        if th < 1 then th = 1 end
                end

                local raw, rn = {}, 0

                for y = 0, th - 1 do
                        local y0 = floor(y * h / th)
                        local y1 = floor((y + 1) * h / th) - 1
                        if y1 < y0 then y1 = y0 end

                        rn = rn + 1
                        raw[rn] = 0

                        for x = 0, tw - 1 do
                                local x0 = floor(x * w / tw)
                                local x1 = floor((x + 1) * w / tw) - 1
                                if x1 < x0 then x1 = x0 end

                                local sum, count = 0, 0
                                for yy = y0, y1 do
                                        local row = rows[yy]
                                        for xx = x0, x1 do
                                                sum = sum + row[xx * bpp + bpp]
                                                count = count + 1
                                        end
                                end

                                raw[rn + 1] = 255
                                raw[rn + 2] = 255
                                raw[rn + 3] = 255
                                raw[rn + 4] = floor(sum / count + 0.5)
                                rn = rn + 4
                        end
                end

                local s1, s2 = 1, 0
                for i = 1, rn do
                        s1 = (s1 + raw[i]) % 65521
                        s2 = (s2 + s1) % 65521
                end

                local body = bytesToString(raw, rn)
                local blocks = {"\120\1"}
                local off = 1

                while off <= #body do
                        local last = (off + 65535 > #body) and 1 or 0
                        local part = string.sub(body, off, off + 65534)
                        local len = #part
                        local nlen = 65535 - len
                        blocks[#blocks + 1] = string.char(last, len % 256, floor(len / 256), nlen % 256, floor(nlen / 256)) .. part
                        off = off + len
                end

                blocks[#blocks + 1] = u32(s2 * 65536 + s1)

                return "\137PNG\13\10\26\10"
                        .. pngChunk("IHDR", u32(tw) .. u32(th) .. string.char(8, 6, 0, 0, 0))
                        .. pngChunk("IDAT", table.concat(blocks))
                        .. pngChunk("IEND", "")
        end
end

local function ensureCloudIcon()
        if type(isfile) ~= "function" or type(readfile) ~= "function" or type(writefile) ~= "function" then
                return false
        end

        local existsOk, exists = pcall(isfile, cloudIconPath)
        if existsOk and exists then
                return true
        end

        local srcOk, src = pcall(isfile, cloudAssetPath)
        if not srcOk or not src then
                return false
        end

        local readOk, data = pcall(readfile, cloudAssetPath)
        if not readOk or type(data) ~= "string" then
                return false
        end

        local convOk, out = pcall(pngRecolorWhite, data, 64)
        if not convOk or type(out) ~= "string" or #out == 0 then
                return false
        end

        return pcall(writefile, cloudIconPath, out)
end

if not ensureCloudIcon() then
        cloudIconPath = cloudAssetPath
end


local lib = nil
local prevLib = getgenv().shitaroebet

if prevLib then
        pcall(function()
                prevLib:unload()
        end)

        getgenv().shitaroebet = nil
end

do
        local function libsrc(name)
                local ok_is, has = pcall(isfile, name)

                if ok_is and has then
                        local ok_rd, body = pcall(readfile, name)

                        if ok_rd and type(body) == "string" and #body > 0 then
                                return body
                        end
                end

                for _ = 1, 3 do
                        local body = shnet.lib(name)

                        if type(body) == "string" and #body > 0 then
                                return body
                        end

                        task.wait(0.5)
                end
        end

        local uiSrc = libsrc("shitaroebet.lua")

        if uiSrc then
                local uiLoad = loadstring(uiSrc, "@shitaroebet")
                uiSrc = nil

                if uiLoad then
                        local ok2, r2 = pcall(uiLoad)

                        if ok2 then
                                lib = r2
                        end
                end
        end
end

if type(lib) ~= "table" or type(lib.window) ~= "function" then
        warn("[shitaro] failed to load ui lib")
        return
end

if getgenv().shitaroebet and getgenv().shitaroebet ~= lib then
        pcall(function()
                getgenv().shitaroebet:unload()
        end)
end

prevLib = nil

getgenv().shitaroebet = lib

local ICONMAP = {
        ["circle-x"] = "x",
        ["circle-check"] = "shield-check",
        ["clipboard"] = "file-text",
        ["cube-vertexes"] = "box",
        ["mouse-scrollwheel"] = "mouse-pointer",
        ["person"] = "user",
        ["crosshairs"] = "crosshair",
        ["chart-four-vertical-bars"] = "activity",
        ["memory-card"] = "database",
        ["gamepad"] = "gamepad-2",
}

local function art(v, fallback)
        if type(v) == "number" then
                return v
        end

        if type(v) ~= "string" or v == "" then
                return fallback
        end

        return ICONMAP[string.lower(v)] or v
end

local function CreateIndicator()
        local ind = {}

        function ind:Set() end
        function ind:SetRender() end
        function ind:SetText() end
        function ind:Remove() end

        return ind
end

local __Notification = {
        new = function(c)
                c = c or {}
                lib:notify({
                        title = c.Title or "SHITARO",
                        text = c.Content or "",
                        icon = art(c.Icon, "info"),
                        life = c.Duration or 5,
                })
        end,
}

local __Logging = {
        new = function(ic, txt, dur, col)
                lib:notify({
                        title = tostring(txt or ""),
                        icon = art(ic, "file-text"),
                        life = dur or 4,
                        tone = (typeof(col) == "Color3") and col or nil,
                })
        end,
}

getgenv().UI_SYNC = { stamp = 0, count = 0, start = os.clock() }

local function wrapCallback(fn)
        if type(fn) ~= "function" then
                return nil
        end

        return function(...)
                local sync = getgenv().UI_SYNC
                if sync then
                        local now = os.clock()
                        if now - sync.stamp > 0.4 then sync.count = 0 end
                        sync.stamp = now
                        sync.count = sync.count + 1
                end
                return fn(...)
        end
end

local function wrapContainer(sec)
        local w = { __sec = sec }

        function w:AddToggle(cfg)
                cfg = cfg or {}

                local el = sec:toggle({
                        name = cfg.Name or "toggle",
                        default = cfg.Default and true or false,
                        options = cfg.Option and true or false,
                        flag = cfg.Flag,
                        callback = wrapCallback(cfg.Callback),
                })

                local o = { __el = el }

                if cfg.Option and el.options then
                        o.Option = wrapContainer(el.options)
                end

                function o:GetValue() return el:get() end
                function o:SetValue(v) el:set(v) end

                return o
        end

        function w:AddSlider(cfg)
                cfg = cfg or {}

                local dec = tonumber(cfg.Round or cfg.Rounding) or 0
                local step = (dec > 0) and (1 / (10 ^ dec)) or 1

                local el = sec:slider({
                        name = cfg.Name or "slider",
                        min = tonumber(cfg.Min) or 0,
                        max = tonumber(cfg.Max) or 100,
                        default = cfg.Default,
                        step = step,
                        suffix = (type(cfg.Type) == "string" and cfg.Type ~= "") and cfg.Type or "",
                        flag = cfg.Flag,
                        callback = wrapCallback(cfg.Callback),
                })

                local o = { __el = el }

                function o:GetValue() return el:get() end
                function o:SetValue(v) el:set(v) end

                return o
        end

        function w:AddDropdown(cfg)
                cfg = cfg or {}

                local el = sec:combo({
                        name = cfg.Name or "dropdown",
                        list = cfg.Values or {},
                        default = cfg.Default,
                        multi = cfg.Multi and true or false,
                        flag = cfg.Flag,
                        callback = wrapCallback(cfg.Callback),
                })

                local o = { __el = el }

                function o:GetValue() return el:get() end
                function o:SetValue(v) el:set(v) end
                function o:SetValues(v) el:setlist(v) end
                function o:Generate() end

                return o
        end

        function w:AddColorPicker(cfg)
                cfg = cfg or {}

                local hook = cfg.Callback

                local el = sec:color({
                        name = cfg.Name or "color",
                        default = cfg.Default,
                        flag = cfg.Flag,
                        callback = hook and wrapCallback(function(c)
                                hook(c, cfg.Transparency)
                        end) or nil,
                })

                local o = { __el = el }

                function o:GetValue() return el:get() end
                function o:SetValue(v) el:set(v) end

                return o
        end

        function w:AddKeybind(cfg)
                cfg = cfg or {}

                local el = sec:keybind({
                        name = cfg.Name or "keybind",
                        default = cfg.Default,
                        flag = cfg.Flag,
                        callback = wrapCallback(cfg.Callback),
                })

                local o = { __el = el }

                function o:GetValue() return el:get() end
                function o:SetValue(v) el:set(v) end

                return o
        end

        function w:AddButton(cfg)
                cfg = cfg or {}

                local el = sec:button({
                        name = cfg.Name or "Button",
                        icon = art(cfg.Icon),
                        callback = cfg.Callback,
                })

                return { __el = el }
        end

        function w:AddLabel(name, wrapText)
                local el = sec:label({
                        name = tostring(name or ""),
                        wrap = wrapText and true or false,
                })

                local o = { __el = el }

                function o:SetValue(v) el:set(v) end
                function o:GetValue() return el:get() end

                return o
        end

        return w
end

local function side_of(pos)
        if pos == "full" or pos == 3 then
                return "full"
        end

        return (pos == "right" or pos == 2) and "right" or "left"
end

local function popmenu(cfg)
        if type(lib.popup) == "function" then
                lib:popup(cfg)
        end
end

local function askinput(cfg)
        if type(lib.ask) == "function" then
                return lib:ask(cfg)
        end
end

local function wrapPage(tab, name)
        local menu = { Name = name, __tab = tab }

        menu.Root = setmetatable({}, {
                __index = function(_, key)
                        if key == "Visible" then
                                local ok, v = pcall(function() return tab.page.Visible end)
                                return ok and v or false
                        end
                end,
        })

        function menu:AddSection(scfg)
                scfg = scfg or {}

                return wrapContainer(tab:section({
                        name = scfg.Name or "SECTION",
                        side = side_of(scfg.Position),
                }))
        end

        function menu:AddClone(ccfg)
                ccfg = ccfg or {}

                return tab:clone({
                        name = ccfg.Name or "Character",
                        side = side_of(ccfg.Position),
                        height = tonumber(ccfg.Height) or 250,
                        zoom = tonumber(ccfg.Zoom),
                        fov = tonumber(ccfg.Fov),
                        callback = ccfg.Callback,
                })
        end

        function menu:AddImageList(icfg)
                icfg = icfg or {}

                local g = tab:gallery({
                        name = icfg.Name or "LIST",
                        icon = art(icfg.Icon, "list"),
                        side = side_of(icfg.Position),
                        height = tonumber(icfg.Height) or 250,
                        multi = icfg.Multi and true or false,
                        thumb = icfg.Thumb or "Asset",
                        cell = tonumber(icfg.Cell),
                        gap = tonumber(icfg.Gap),
                        search = icfg.Search ~= false,
                        tools = icfg.Tools ~= false,
                        reset = icfg.Reset and true or false,
                        blank = icfg.Blank,
                        empty = icfg.Empty,
                        buttons = icfg.Buttons,
                        action = icfg.Action,
                        context = icfg.Context,
                        list = icfg.Values or {},
                        default = icfg.Default,
                        flag = icfg.Flag,
                        callback = wrapCallback(icfg.Callback),
                })

                local o = { __el = g }

                function o:SetData(v) g:setdata(v) end
                function o:SetValues(v) g:setdata(v) end
                function o:SetDefault(v) g:setdefault(v) end
                function o:SetValue(v) g:set(v) end
                function o:GetValue() return g:get() end
                function o:Refresh() g:refresh() end
                function o:Clear() g:clear() end
                function o:All() g:all() end
                function o:Search(q) g:search(q) end
                function o:Generate() end

                return o
        end

        if type(tab.sub) == "function" then
                function menu:AddSub(bcfg)
                        bcfg = bcfg or {}

                        local branch = tab:sub({
                                name = bcfg.Name or "SUB",
                                icon = art(bcfg.Icon, "circle-dot"),
                                tip = bcfg.Tip or "",
                        })

                        if type(tab.setopen) == "function" then
                                pcall(tab.setopen, tab, true)
                        end

                        return wrapPage(branch, bcfg.Name)
                end
        end

        return menu
end

local fatality = {}
fatality.Colors = { Black = Color3.fromRGB(16, 16, 16) }

function fatality:CreateNotifier()
        return {
                Notify = function(_, c)
                        c = c or {}
                        __Notification.new(c)
                end,
        }
end

function fatality:CreateEventNotifier()
        return {
                Notify = function(_, c)
                        c = c or {}
                        __Logging.new(c.Icon or "clipboard", c.Title or c.Content or "", c.Duration or 4, c.Color)
                end,
        }
end

function fatality:Loader() end
function fatality:RegisterColorElement() end
function fatality:UpdateColors() end

local root = nil

function fatality.new(cfg)
        cfg = cfg or {}

        root = lib:window({ bind = "Insert" })

        local win = {}

        win.Menus = {}
        win.ClickSoundId = ""
        win.__win = root

        function win:SetSize() end
        function win:Set3DRender() end

        function win:Toggle()
                root:toggle()
        end

        function win:AddMenu(mcfg)
                mcfg = mcfg or {}

                local tab = root:tab({
                        name = mcfg.Name or "TAB",
                        icon = art(mcfg.Icon, "circle-dot"),
                        tip = mcfg.Tip or "",
                })

                local menu = wrapPage(tab, mcfg.Name)

                table.insert(win.Menus, menu)

                return menu
        end

        function win:AddColors()
                local ct = root:tab({ name = "colors", icon = "palette", tip = "menu colors" })

                ct:color({ name = "accent", key = "accent", side = "left" })
                ct:color({ name = "text", key = "text", side = "right" })
                ct:color({ name = "panel", key = "panel", side = "left" })
                ct:color({ name = "header", key = "head", side = "right" })
                ct:color({ name = "sidebar", key = "side", side = "left" })
                ct:color({ name = "outline", key = "line", side = "right" })
                ct:color({ name = "muted", key = "dim", side = "left" })
                ct:color({ name = "network", key = "glow", side = "right" })
                ct:color({ name = "background", key = "bg", side = "left" })

                return ct
        end

        function win:AddConfig()
                local ct = root:tab({ name = "config", icon = "save", tip = "menu settings" })

                ct:configs({ name = "Configs", side = "left" })

                return ct, ct:section({ name = "Menu", side = "right" })
        end

        function win:SetBind(v)
                root:setbind(v)
        end

        return win
end

local notification = fatality:CreateNotifier()
local event_notify = fatality:CreateEventNotifier()



task.spawn(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("BasePart") and obj.Name == "GlowShell")
                        or (obj:IsA("Model") and (obj.Name == "GlowChr" or obj.Name == "ChamsChr")) then
                        pcall(function() obj:Destroy() end)
                end
        end
end)

fatality:Loader({
        Name = "SHITARO",
        Duration = 4
});

notification:Notify({
        Title = "SHITARO",
        Content = "yo, "..game.Players.LocalPlayer.DisplayName.." welcome back",
        Icon = "clipboard"
})

local window = fatality.new({
        Name = "SHITARO",
        Expire = "Never",
});


--============================================================
-- SINGLE PAGE: AUTO FARM
--============================================================
local farm_page = window:AddMenu({
        Name = "auto farm",
        Icon = "database",
        Tip = "auto farm",
        AutoFill = false
})

local farm_sec = farm_page:AddSection({
        Name = "farm",
        Position = "left"
})

local perf_sec = farm_page:AddSection({
        Name = "performance",
        Position = "right"
})

local status_lbl = farm_sec:AddLabel("coins: 0 | farm: off", false)

do
        local players = game:GetService("Players")
        local lp = players.LocalPlayer

        local autograb_on = false

        local grab_rs = game:GetService("ReplicatedStorage")
        local grab_round_mod = nil
        local function grab_has_role()
                if not grab_round_mod then
                        local ok, m = pcall(function()
                                return require(grab_rs:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
                        end)
                        if ok and type(m) == "table" then grab_round_mod = m end
                end
                local d = grab_round_mod and grab_round_mod.PlayerData
                if type(d) ~= "table" then return false end
                local me = d[lp.Name]
                return me ~= nil and me.Role ~= nil and not me.Dead
        end

        local function has_knife()
                local char = lp.Character
                if char and char:FindFirstChild("Knife") then return true end
                local backpack = lp:FindFirstChildOfClass("Backpack")
                if backpack and backpack:FindFirstChild("Knife") then return true end
                return false
        end

        local function grab_gun(obj)
                if not autograb_on or has_knife() then return end
                if not grab_has_role() then return end
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                pcall(function() obj.CFrame = root.CFrame end)
                local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                        pcall(function() fireproximityprompt(prompt) end)
                end
        end

        local function scan_guns()
                for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                                grab_gun(obj)
                        end
                end
        end

        local grab_desc_conn = nil

        local function grab_desc_added(obj)
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                        task.wait(0.1)
                        grab_gun(obj)
                end
        end

        local function grab_desc_stop()
                if grab_desc_conn then
                        pcall(function() grab_desc_conn:Disconnect() end)
                        grab_desc_conn = nil
                end
        end

        local run = game:GetService("RunService")
        local cs = game:GetService("CollectionService")
        local rs = game:GetService("ReplicatedStorage")

        local autofarm_on = false
        local autoreset_on = false
        local autokill_on = false
        local coins_done = false
        local saw_coins = false
        local farm_target = nil
        local nc_cache = {}
        local FARM_SPEED = 23
        local round_mod = nil
        local collected_ids = {}
        local collected_count = 0

        local wl_enabled = false
        local wl_conn_add = nil
        local wl_conn_rem = nil

        local farm_mode = "Basic"
        local avoid_murder = false
        local was_down = false
        local down_ref_y = nil
        local last_touch = 0
        local DOWN_DEPTH = 14
        local DOWN_RISE_XZ = 4
        local AVOID_DIST = 40
        local RISE_SAFE_DIST = 20

        getgenv().AUTOFARM_HOLD = false

        -- forward decls preenchidos pelo modulo multi-contas (sync chat)
        local sync_announce_full = nil
        local sync_reset_round = nil
        local sync_turn_off = nil

        --============================================================
        -- DISCORD WEBHOOK (core)
        -- Envia eventos do farm para um webhook do Discord. A URL
        -- fica salva em "shitaro_webhook.txt" e pode ser definida
        -- pelo botao "set url" no menu.
        --============================================================
        local wh_on = false
        local wh_url = ""
        local wh_last = 0
        local kill_announced = false
        local WH_FILE = "shitaro_webhook.txt"

        pcall(function()
                if type(isfile) == "function" and type(readfile) == "function" and isfile(WH_FILE) then
                        local body = readfile(WH_FILE)
                        if type(body) == "string" then
                                body = string.gsub(body, "^%s+", "")
                                body = string.gsub(body, "%s+$", "")
                                wh_url = body
                        end
                end
        end)

        local function wh_save_url()
                getgenv().AUTOFARM_WEBHOOK = wh_url
                pcall(function()
                        if type(writefile) == "function" then
                                writefile(WH_FILE, wh_url)
                        end
                end)
        end

        local function wh_send(msg, force)
                if not (force or wh_on) then return end
                if type(msg) ~= "string" or wh_url == "" then return end
                local now = os.clock()
                if not force and now - wh_last < 1.5 then return end
                wh_last = now
                task.spawn(function()
                        pcall(function()
                                shhttp({
                                        Url = wh_url,
                                        Method = "POST",
                                        Headers = { ["Content-Type"] = "application/json" },
                                        Body = shjson:JSONEncode({ username = "shitaro", content = msg }),
                                })
                        end)
                end)
        end

        --============================================================
        -- FARM DOCE (evento)
        -- Alem das moedas (tag CoinVisual), coleta partes com
        -- "candy"/"halloween" no nome que tenham TouchTransmitter.
        --============================================================
        local candy_on = true
        local candy_alive = true
        local candy_cache = {}

        local function candy_match(v)
                local n = string.lower(v.Name)
                return string.find(n, "candy", 1, true) ~= nil
                        or string.find(n, "halloween", 1, true) ~= nil
        end

        local function candy_valid(v)
                return v and v.Parent and v:IsA("BasePart")
                        and v:FindFirstChildOfClass("TouchTransmitter") ~= nil
                        and not v:GetAttribute("Collected") and not v:GetAttribute("Delete")
        end

        local function candy_scan()
                local out = {}
                pcall(function()
                        for _, v in ipairs(workspace:GetDescendants()) do
                                if v:IsA("BasePart") and candy_match(v) and candy_valid(v) then
                                        out[#out + 1] = v
                                end
                        end
                end)
                candy_cache = out
        end

        task.spawn(function()
                while candy_alive do
                        task.wait(8)
                        if candy_on then
                                pcall(candy_scan)
                        end
                end
        end)

        local function farm_hrp()
                local c = lp.Character
                return c and c:FindFirstChild("HumanoidRootPart")
        end

        local function get_round_data()
                if not round_mod then
                        local ok, m = pcall(function()
                                return require(rs:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
                        end)
                        if ok and type(m) == "table" then round_mod = m end
                end
                return round_mod and round_mod.PlayerData
        end

        local function can_farm()
                local char = lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return false end
                local d = get_round_data()
                if type(d) == "table" then
                        local me = d[lp.Name]
                        if not me or not me.Role or me.Dead then return false end
                end
                return true
        end

        local function coin_bags_full()
                local pg = lp:FindFirstChild("PlayerGui")
                local main = pg and pg:FindFirstChild("MainGUI")
                local gg = main and main:FindFirstChild("Game")
                local bags = gg and gg:FindFirstChild("CoinBags")
                local container = bags and bags:FindFirstChild("Container")
                if not container then return false end
                local any = false
                for _, v in ipairs(container:GetChildren()) do
                        if v:IsA("Frame") and v.Visible then
                                any = true
                                local full = v:FindFirstChild("Full")
                                if not (full and full.Visible) then
                                        return false
                                end
                        end
                end
                return any
        end

        local function update_hold()
                getgenv().AUTOFARM_HOLD = autofarm_on and autokill_on and not coins_done
        end

        local function reset_farm_progress()
                collected_ids = {}
                collected_count = 0
                coins_done = false
                saw_coins = false
                farm_target = nil
                kill_announced = false
                update_hold()
                if sync_reset_round then pcall(sync_reset_round) end
        end

        task.spawn(function()
                local ok, remote = pcall(function()
                        return rs:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("CoinsStarted", 15)
                end)
                if ok and remote then
                        remote.OnClientEvent:Connect(reset_farm_progress)
                end
        end)

        lp.CharacterAdded:Connect(function()
                reset_farm_progress()
        end)

        local function coin_available(v)
                return v and v.Parent and v:IsA("BasePart") and not v:GetAttribute("Collected") and not v:GetAttribute("Delete")
        end

        local function available_coins()
                local list = {}
                for _, v in ipairs(cs:GetTagged("CoinVisual")) do
                        if coin_available(v) then
                                list[#list + 1] = v
                        end
                end
                return list
        end

        local function nearest_coin(pos, list)
                local best, bd = nil, math.huge
                for _, v in ipairs(list) do
                        local d = (v.Position - pos).Magnitude
                        if d < bd then bd = d best = v end
                end
                return best
        end

        local function set_farm_noclip(on)
                local char = lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if on then
                        if not char then return end
                        if hum then pcall(function() hum.PlatformStand = true end) end
                        for _, p in ipairs(char:GetDescendants()) do
                                if p:IsA("BasePart") and p.CanCollide then
                                        if nc_cache[p] == nil then nc_cache[p] = p.CanCollide end
                                        p.CanCollide = false
                                end
                        end
                else
                        if hum then pcall(function() hum.PlatformStand = false end) end
                        for p, v in pairs(nc_cache) do
                                if p and p.Parent then pcall(function() p.CanCollide = v end) end
                        end
                        nc_cache = {}
                end
        end

        local up_params = RaycastParams.new()
        up_params.FilterType = Enum.RaycastFilterType.Exclude
        up_params.IgnoreWater = true

        local function return_to_surface()
                local hrp = farm_hrp()
                if not hrp then return end
                local origin = hrp.Position
                up_params.FilterDescendantsInstances = { lp.Character }
                local res = workspace:Raycast(origin, Vector3.new(0, 400, 0), up_params)
                local y = res and (res.Position.Y + 5) or (down_ref_y and down_ref_y + 5 or nil)
                if not y then return end
                pcall(function()
                        hrp.CFrame = CFrame.new(origin.X, y, origin.Z)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                end)
        end

        local function farm_release()
                if was_down then
                        was_down = false
                        return_to_surface()
                end
                set_farm_noclip(false)
        end

        local murder_hrp_cache, murder_hrp_t = nil, 0
        local function murderer_hrp()
                local now = os.clock()
                if now - murder_hrp_t < 0.25 then return murder_hrp_cache end
                murder_hrp_t = now
                murder_hrp_cache = nil
                local d = get_round_data()
                if type(d) == "table" then
                        local me = d[lp.Name]
                        if me and me.Role == "Murderer" then return nil end
                        for name, info in pairs(d) do
                                if type(info) == "table" and info.Role == "Murderer" and not info.Dead and name ~= lp.Name then
                                        local pl = players:FindFirstChild(name)
                                        local char = pl and pl.Character
                                        local h = char and char:FindFirstChild("HumanoidRootPart")
                                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                                        if h and (not hum or hum.Health > 0) then murder_hrp_cache = h end
                                        break
                                end
                        end
                end
                return murder_hrp_cache
        end

        local function flat_dist(a, b)
                return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
        end

        local function pick_coin(pos, list, mpos)
                if not (avoid_murder and mpos) then
                        return nearest_coin(pos, list)
                end
                local safe, sd = nil, math.huge
                local far, fd = nil, -1
                for _, v in ipairs(list) do
                        local md = flat_dist(v.Position, mpos)
                        if md > fd then fd = md far = v end
                        if md >= AVOID_DIST then
                                local d = (v.Position - pos).Magnitude
                                if d < sd then sd = d safe = v end
                        end
                end
                if safe then return safe end
                if far and fd >= AVOID_DIST * 0.6 then return far end
                return nil
        end

        local function coin_ok_now(v, mpos)
                if not coin_available(v) then return false end
                if avoid_murder and mpos and flat_dist(v.Position, mpos) < AVOID_DIST * 0.6 then return false end
                return true
        end

        local function avoid_steer(cur, dest, mpos)
                if not (avoid_murder and mpos) then return dest end
                local dm = flat_dist(cur, mpos)
                if dm >= AVOID_DIST then return dest end
                local away = Vector3.new(cur.X - mpos.X, 0, cur.Z - mpos.Z)
                if away.Magnitude < 0.1 then away = Vector3.new(1, 0, 0) end
                away = away.Unit
                local want = Vector3.new(dest.X - cur.X, 0, dest.Z - cur.Z)
                local mag = want.Magnitude
                if mag < 0.1 then return dest end
                local weight = 1 + (1 - dm / AVOID_DIST) * 2
                local blend = (want.Unit + away * weight)
                if blend.Magnitude < 0.1 then blend = away else blend = blend.Unit end
                local np = cur + blend * mag
                return Vector3.new(np.X, dest.Y, np.Z)
        end

        local function touch_targets(coin)
                local list = {}
                local seen = {}
                local function add(p)
                        if p and not seen[p] and p:IsA("BasePart") and p:FindFirstChildOfClass("TouchTransmitter") then
                                seen[p] = true
                                list[#list + 1] = p
                        end
                end
                add(coin)
                for _, v in ipairs(coin:GetChildren()) do add(v) end
                local par = coin.Parent
                if par then
                        if par:IsA("BasePart") then add(par) end
                        for _, v in ipairs(par:GetChildren()) do add(v) end
                end
                if #list == 0 then list[1] = coin end
                return list
        end

        local function fire_touch(coin)
                if type(firetouchinterest) ~= "function" then return end
                if not coin or not coin.Parent then return end
                local now = os.clock()
                if now - last_touch < 0.05 then return end
                last_touch = now
                local hrp = farm_hrp()
                if not hrp then return end
                for _, p in ipairs(touch_targets(coin)) do
                        pcall(firetouchinterest, hrp, p, 0)
                        pcall(firetouchinterest, hrp, p, 1)
                end
        end

        local function farm_move(hrp, dest, dt)
                local dir = dest - hrp.Position
                local dist = dir.Magnitude
                local np = dest
                if dist > 0.1 then
                        np = hrp.Position + dir.Unit * math.min(FARM_SPEED * dt, dist)
                end
                local cf = CFrame.new(np)
                if farm_mode == "Down" then
                        cf = cf * CFrame.Angles(-math.pi * 0.5, 0, 0)
                        was_down = true
                end
                pcall(function()
                        hrp.CFrame = cf
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                end)
        end

        local farm_conn = run.Stepped:Connect(function(_, dt)
                if not autofarm_on then return end
                if not can_farm() then
                        farm_target = nil
                        was_down = false
                        set_farm_noclip(false)
                        return
                end
                local hrp = farm_hrp()
                if not hrp then return end

                local list = {}
                for _, v in ipairs(cs:GetTagged("CoinVisual")) do
                        if v and v.Parent and v:IsA("BasePart") then
                                if v:GetAttribute("Collected") then
                                        local id = v:GetAttribute("CoinID")
                                        if id and not collected_ids[id] then
                                                collected_ids[id] = true
                                                collected_count = collected_count + 1
                                        end
                                elseif not v:GetAttribute("Delete") then
                                        list[#list + 1] = v
                                end
                        end
                end

                if candy_on then
                        for _, v in ipairs(candy_cache) do
                                if candy_valid(v) then
                                        list[#list + 1] = v
                                end
                        end
                end

                local function finish()
                        farm_target = nil
                        farm_release()
                        if not coins_done then
                                coins_done = true
                                update_hold()
                                wh_send("[shitaro] bags cheias - " .. tostring(collected_count) .. " moedas coletadas")
                                if sync_announce_full then pcall(sync_announce_full) end
                                if autoreset_on then
                                        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                                        if hum then pcall(function() hum.Health = 0 end) end
                                end
                        end
                end

                if saw_coins and coin_bags_full() then
                        finish()
                        return
                end

                if #list > 0 then
                        saw_coins = true
                        if coins_done then coins_done = false update_hold() end

                        local mhrp = avoid_murder and murderer_hrp() or nil
                        local mpos = mhrp and mhrp.Position or nil

                        if not coin_ok_now(farm_target, mpos) then
                                farm_target = pick_coin(hrp.Position, list, mpos)
                        end

                        if farm_target then
                                set_farm_noclip(true)
                                local cpos = farm_target.Position
                                down_ref_y = cpos.Y
                                local dest = cpos

                                if farm_mode == "Down" then
                                        local xz = flat_dist(hrp.Position, cpos)
                                        local safe_to_rise = (not mpos) or flat_dist(hrp.Position, mpos) > RISE_SAFE_DIST
                                        if xz <= DOWN_RISE_XZ and safe_to_rise then
                                                dest = cpos
                                                fire_touch(farm_target)
                                        else
                                                dest = Vector3.new(cpos.X, cpos.Y - DOWN_DEPTH, cpos.Z)
                                        end
                                elseif (cpos - hrp.Position).Magnitude <= 6 then
                                        fire_touch(farm_target)
                                end

                                dest = avoid_steer(hrp.Position, dest, mpos)
                                farm_move(hrp, dest, dt)
                        elseif mpos then
                                set_farm_noclip(true)
                                local away = Vector3.new(hrp.Position.X - mpos.X, 0, hrp.Position.Z - mpos.Z)
                                if away.Magnitude < 0.1 then away = Vector3.new(1, 0, 0) end
                                away = away.Unit
                                local y = hrp.Position.Y
                                if farm_mode == "Down" and down_ref_y then y = down_ref_y - DOWN_DEPTH end
                                farm_move(hrp, hrp.Position + away * 40 + Vector3.new(0, y - hrp.Position.Y, 0), dt)
                        end
                else
                        farm_target = nil
                        farm_release()
                        if saw_coins and not coins_done and collected_count > 0 then
                                finish()
                        end
                end
        end)

        local misc_section = farm_sec

        misc_section:AddToggle({
                Name = "grab gun",
                ToolTip = "Automatically grabs the gun when it drops",
                Default = false,
                Flag = "Auto Gun",
                Callback = function(v)
                        autograb_on = v
                        if v then
                                if not grab_desc_conn then
                                        grab_desc_conn = workspace.DescendantAdded:Connect(grab_desc_added)
                                end
                                task.spawn(scan_guns)
                        else
                                grab_desc_stop()
                        end
                end
        })

        local farm_tgl = misc_section:AddToggle({
                Name = "farm",
                ToolTip = "Automatically farms coins",
                Default = false,
                Flag = "Auto Farm",
                Option = true,
                Callback = function(v)
                        autofarm_on = v
                        reset_farm_progress()
                        if not v then
                                farm_release()
                        end
                end
        })

        farm_tgl.Option:AddDropdown({
                Name = "type",
                Default = "Basic",
                Values = { "Basic", "Down" },
                Flag = "farm type detka",
                Callback = function(v)
                        local nv = type(v) == "table" and v[1] or v
                        if nv ~= "Basic" and nv ~= "Down" then nv = "Basic" end
                        if nv == farm_mode then return end
                        farm_mode = nv
                        farm_target = nil
                        if farm_mode == "Basic" and was_down then
                                was_down = false
                                return_to_surface()
                        end
                end
        })

        farm_tgl.Option:AddToggle({
                Name = "murder check",
                Default = false,
                Flag = "bypass by shitaro ezez",
                Callback = function(v)
                        avoid_murder = v
                        farm_target = nil
                end
        })

        farm_tgl.Option:AddToggle({
                Name = "auto reset",
                ToolTip = "Automatically resets if the coin bags are full",
                Default = false,
                Flag = "Auto Reset",
                Callback = function(v)
                        autoreset_on = v
                end
        })

        farm_tgl.Option:AddToggle({
                Name = "auto kill",
                ToolTip = "Automatically kill murder or all players if the\ncoin bags are full",
                Default = false,
                Flag = "Auto FarmK",
                Callback = function(v)
                        autokill_on = v
                        update_hold()
                end
        })

        misc_section:AddToggle({
                Name = "farm doce",
                ToolTip = "Tambem coleta os doces do evento (partes com candy/halloween no nome)",
                Default = true,
                Flag = "Auto Candy",
                Callback = function(v)
                        candy_on = v and true or false
                        if candy_on then
                                candy_scan()
                        else
                                candy_cache = {}
                        end
                end
        })

        getgenv().AUTOFARM_UNLOAD = function()
                autofarm_on = false
                autoreset_on = false
                autokill_on = false
                coins_done = false
                saw_coins = false
                farm_target = nil
                getgenv().AUTOFARM_HOLD = false
                avoid_murder = false
                farm_mode = "Basic"
                wl_enabled = false
                if wl_conn_add then pcall(function() wl_conn_add:Disconnect() end) wl_conn_add = nil end
                if wl_conn_rem then pcall(function() wl_conn_rem:Disconnect() end) wl_conn_rem = nil end
                if sync_turn_off then pcall(sync_turn_off) end
                candy_on = false
                candy_alive = false
                candy_cache = {}
                if farm_conn then pcall(function() farm_conn:Disconnect() end) farm_conn = nil end
                farm_release()
        end

        getgenv().AUTOGRAB_UNLOAD = function()
                autograb_on = false
                grab_desc_stop()
        end

        --============================================================
        -- WHITELIST
        -- Jogadores na whitelist nao sao mortos pelo auto kill: o
        -- script espera por ele (nao da facada / nao atira). A lista
        -- fica salva em arquivo e no getgenv() e volta quando o
        -- script carrega de novo.
        --============================================================
        local wl_sel = {}
        local wl_names = {}
        local wl_disp = {}
        local wl_dd = nil
        local wl_lbl = nil
        local wl_dd_ready = false
        local wl_kill_full = true
        local wl_limit = 50
        local wl_coins = {}
        local wl_full_notified = {}
        local wl_watched = {}
        local WL_FILE = "shitaro_whitelist.txt"

        local function wl_tokens(body)
                local out = {}
                for token in string.gmatch(tostring(body), "[^\r\n]+") do
                        token = string.gsub(token, "^%s+", "")
                        token = string.gsub(token, "%s+$", "")
                        if token ~= "" then out[#out + 1] = token end
                end
                return out
        end

        local function wl_copy()
                local c = {}
                for i, n in ipairs(wl_sel) do c[i] = n end
                return c
        end

        local function wl_load()
                local ok = pcall(function()
                        if type(isfile) == "function" and type(readfile) == "function" and isfile(WL_FILE) then
                                wl_sel = wl_tokens(readfile(WL_FILE))
                        end
                end)
                if not ok or #wl_sel == 0 then
                        local saved = getgenv().AUTOFARM_WHITELIST
                        wl_sel = {}
                        if type(saved) == "table" then
                                for _, n in ipairs(saved) do
                                        if type(n) == "string" and n ~= "" then
                                                wl_sel[#wl_sel + 1] = n
                                        end
                                end
                        end
                end
        end

        local function wl_save()
                local arr = {}
                for _, n in ipairs(wl_sel) do arr[#arr + 1] = n end
                getgenv().AUTOFARM_WHITELIST = arr
                pcall(function()
                        if type(writefile) == "function" then
                                writefile(WL_FILE, table.concat(arr, "\n"))
                        end
                end)
        end

        local function wl_rebuild()
                wl_names = {}
                wl_disp = {}
                for _, n in ipairs(wl_sel) do
                        if type(n) == "string" and n ~= "" then
                                local low = string.lower(n)
                                wl_names[low] = true
                                wl_disp[low] = n
                        end
                end
        end

        local function is_whitelisted(plr)
                if not wl_enabled or plr == lp then return false end
                local n = plr and plr.Name
                if not n then return false end

                local function check(key)
                        if wl_names[key] then
                                if wl_kill_full and (wl_coins[key] or 0) >= wl_limit then
                                        return false
                                end
                                return true
                        end
                        return nil
                end

                local r = check(string.lower(n))
                if r ~= nil then return r end
                local dn = plr.DisplayName
                if dn ~= nil then
                        r = check(string.lower(dn))
                        if r ~= nil then return r end
                end
                return false
        end

        -- credita a moeda pro jogador vivo mais perto dela
        local function wl_credit(pos)
                if not pos then return end
                local best, bd = nil, math.huge
                for _, plr in ipairs(players:GetPlayers()) do
                        local c = plr.Character
                        local h = c and c:FindFirstChildOfClass("Humanoid")
                        local r = c and c:FindFirstChild("HumanoidRootPart")
                        if h and h.Health > 0 and r then
                                local d = (r.Position - pos).Magnitude
                                if d < bd then bd = d best = plr end
                        end
                end
                if not best or bd > 14 then return end
                local nkey = string.lower(best.Name)
                wl_coins[nkey] = (wl_coins[nkey] or 0) + 1
                local dn = best.DisplayName
                if dn and string.lower(dn) ~= nkey then
                        local dkey = string.lower(dn)
                        wl_coins[dkey] = (wl_coins[dkey] or 0) + 1
                end
                if best ~= lp and wl_names[nkey] and not wl_full_notified[nkey]
                        and (wl_coins[nkey] or 0) >= wl_limit then
                        wl_full_notified[nkey] = true
                        wh_send("[shitaro] " .. best.Name .. " encheu as bags ("
                                .. tostring(wl_coins[nkey]) .. ") - whitelist liberada pra ele")
                end
        end

        local function wl_watch_coin(v)
                if wl_watched[v] then return end
                wl_watched[v] = true
                local pos = nil
                pcall(function() pos = v.Position end)
                local done = false
                local function hit()
                        if done then return end
                        done = true
                        pcall(function() wl_credit(pos) end)
                end
                pcall(function()
                        v:GetAttributeChangedSignal("Collected"):Connect(function()
                                if v:GetAttribute("Collected") then hit() end
                        end)
                        v:GetAttributeChangedSignal("Delete"):Connect(function()
                                if v:GetAttribute("Delete") then hit() end
                        end)
                end)
        end

        for _, v in ipairs(cs:GetTagged("CoinVisual")) do wl_watch_coin(v) end
        cs:GetInstanceAddedSignal("CoinVisual"):Connect(wl_watch_coin)

        task.spawn(function()
                local ok, remote = pcall(function()
                        return rs:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("CoinsStarted", 15)
                end)
                if ok and remote then
                        remote.OnClientEvent:Connect(function()
                                wl_coins = {}
                                wl_full_notified = {}
                                wl_watched = {}
                        end)
                end
        end)

        local function wl_label_text()
                local parts = {}
                for _, n in ipairs(wl_sel) do
                        if type(n) == "string" and n ~= "" then parts[#parts + 1] = n end
                end
                if #parts == 0 then return "wl: vazio" end
                table.sort(parts)
                return "wl: " .. table.concat(parts, ", ")
        end

        local function wl_status()
                if wl_lbl then
                        pcall(function() wl_lbl:SetValue(wl_label_text()) end)
                end
        end

        local function wl_feed_text()
                if not wl_enabled then return "off" end
                local n = 0
                for _ in pairs(wl_names) do n = n + 1 end
                local d = get_round_data()
                if type(d) == "table" then
                        for name, info in pairs(d) do
                                if type(info) == "table" and info.Role == "Murderer" and not info.Dead
                                        and wl_names[string.lower(name)] then
                                        return tostring(n) .. " | esperando: " .. name
                                end
                        end
                end
                return tostring(n)
        end

        local function wl_values()
                local seen = {}
                local out = {}
                for _, n in ipairs(wl_sel) do
                        if type(n) == "string" and n ~= "" and not seen[string.lower(n)] then
                                seen[string.lower(n)] = true
                                out[#out + 1] = n
                        end
                end
                for _, plr in ipairs(players:GetPlayers()) do
                        if plr ~= lp and not seen[string.lower(plr.Name)] then
                                seen[string.lower(plr.Name)] = true
                                out[#out + 1] = plr.Name
                        end
                end
                return out
        end

        local function wl_sync()
                if wl_dd then
                        pcall(function() wl_dd:SetValues(wl_values()) end)
                        pcall(function() wl_dd:SetValue(wl_copy()) end)
                end
                wl_status()
        end

        local function wl_pick(v)
                local picked = {}
                if type(v) == "table" then
                        for k, val in pairs(v) do
                                if type(val) == "string" and val ~= "" then
                                        picked[#picked + 1] = val
                                elseif type(k) == "string" and val == true then
                                        picked[#picked + 1] = k
                                end
                        end
                elseif type(v) == "string" and v ~= "" then
                        picked[1] = v
                end
                return picked
        end

        wl_load()
        wl_rebuild()

        local wl_sec = farm_page:AddSection({
                Name = "whitelist",
                Position = "right"
        })

        wl_sec:AddToggle({
                Name = "whitelist",
                ToolTip = "Nao mata quem esta na whitelist: o auto kill espera por ele",
                Default = false,
                Flag = "Auto Whitelist",
                Callback = function(v)
                        wl_enabled = v and true or false
                        wl_status()
                end
        })

        wl_sec:AddToggle({
                Name = "matar quando encher",
                ToolTip = "Para de poupar o jogador da whitelist quando as bags dele enchem",
                Default = true,
                Flag = "Auto Whitelist KillFull",
                Callback = function(v)
                        wl_kill_full = v and true or false
                end
        })

        wl_sec:AddSlider({
                Name = "moedas pra encher",
                Min = 5,
                Max = 100,
                Default = 50,
                Round = 0,
                Flag = "Auto Whitelist Limit",
                Callback = function(v)
                        wl_limit = tonumber(v) or 50
                end
        })

        pcall(function()
                wl_dd = wl_sec:AddDropdown({
                        Name = "jogadores",
                        Default = wl_copy(),
                        Values = wl_values(),
                        Multi = true,
                        Flag = "Auto Whitelist List",
                        Callback = function(v)
                                local picked = wl_pick(v)
                                if #picked == 0 and #wl_sel > 0 and not wl_dd_ready then return end
                                local oldset = {}
                                for _, n in ipairs(wl_sel) do oldset[string.lower(n)] = true end
                                local newset = {}
                                for _, n in ipairs(picked) do newset[string.lower(n)] = true end
                                for _, n in ipairs(picked) do
                                        if not oldset[string.lower(n)] then
                                                wh_send("[shitaro] whitelist add: " .. n)
                                        end
                                end
                                for _, n in ipairs(wl_sel) do
                                        if not newset[string.lower(n)] then
                                                wh_send("[shitaro] whitelist del: " .. n)
                                        end
                                end
                                wl_sel = picked
                                wl_rebuild()
                                wl_save()
                                wl_status()
                        end
                })
        end)

        task.delay(1, function() wl_dd_ready = true end)

        wl_sec:AddButton({
                Name = "refresh",
                Icon = "refresh-cw",
                Callback = wl_sync
        })

        wl_lbl = wl_sec:AddLabel(wl_label_text(), false)

        wl_conn_add = players.PlayerAdded:Connect(function()
                task.defer(wl_sync)
        end)

        wl_conn_rem = players.PlayerRemoving:Connect(function()
                task.defer(wl_sync)
        end)

        wl_sync()

        -- avisa no webhook quando comeca/para de esperar o murderer da whitelist
        local wl_wait_last = nil
        task.spawn(function()
                while true do
                        task.wait(1)
                        local waitname = nil
                        if wl_enabled then
                                local d = get_round_data()
                                if type(d) == "table" then
                                        for name, info in pairs(d) do
                                                if type(info) == "table" and info.Role == "Murderer" and not info.Dead then
                                                        local pl = players:FindFirstChild(name)
                                                        if is_whitelisted(pl) then waitname = name end
                                                        break
                                                end
                                        end
                                end
                        end
                        if waitname ~= wl_wait_last then
                                if waitname then
                                        wh_send("[shitaro] esperando o murderer da whitelist: " .. waitname)
                                else
                                        local still = false
                                        local d = get_round_data()
                                        if type(d) == "table" then
                                                for name, info in pairs(d) do
                                                        if type(info) == "table" and info.Role == "Murderer" and not info.Dead then
                                                                still = true
                                                                break
                                                        end
                                                end
                                        end
                                        if still then
                                                wh_send("[shitaro] murderer liberado da whitelist - pode atirar")
                                        end
                                end
                                wl_wait_last = waitname
                        end
                end
        end)

        --============================================================
        -- DISCORD WEBHOOK (UI)
        --============================================================
        local dc_sec = farm_page:AddSection({
                Name = "discord",
                Position = "right"
        })

        local dc_lbl = nil

        local function dc_label_text()
                if wh_url == "" then return "webhook: nao definido" end
                if #wh_url > 38 then
                        return "webhook: ..." .. string.sub(wh_url, -30)
                end
                return "webhook: " .. wh_url
        end

        local function dc_status()
                if dc_lbl then
                        pcall(function() dc_lbl:SetValue(dc_label_text()) end)
                end
        end

        dc_sec:AddToggle({
                Name = "webhook",
                ToolTip = "Envia eventos do farm pro Discord",
                Default = false,
                Flag = "Discord Webhook",
                Callback = function(v)
                        wh_on = v and true or false
                        if wh_on then
                                wh_send("[shitaro] webhook conectado - " .. lp.Name
                                        .. " (place " .. tostring(game.PlaceId) .. ")")
                        end
                end
        })

        dc_sec:AddButton({
                Name = "set url",
                Icon = "link",
                Callback = function()
                        if type(lib.ask) ~= "function" then
                                notification:Notify({
                                        Title = "SHITARO",
                                        Content = "sem popup nesta lib - coloque a url no arquivo shitaro_webhook.txt",
                                        Icon = "clipboard"
                                })
                                return
                        end
                        askinput({
                                title = "webhook url",
                                icon = "link",
                                hint = "https://discord.com/api/webhooks/...",
                                accept = "salvar",
                                deny = "cancelar",
                                callback = function(val)
                                        if type(val) == "string" and string.find(val, "discord", 1, true) then
                                                wh_url = string.gsub(val, "^%s+", "")
                                                wh_url = string.gsub(wh_url, "%s+$", "")
                                                wh_save_url()
                                                dc_status()
                                                wh_send("[shitaro] webhook url salva", true)
                                        end
                                end
                        })
                end
        })

        dc_sec:AddButton({
                Name = "test",
                Icon = "send",
                Callback = function()
                        if wh_url == "" then return end
                        wh_send("[shitaro] teste do webhook - " .. lp.Name, true)
                end
        })

        dc_lbl = dc_sec:AddLabel(dc_label_text(), false)
        dc_status()

        --============================================================
        -- MULTI-CONTAS (sync pelo chat do Roblox)
        -- Todas as contas rodam este script e farmam ao mesmo tempo.
        --
        -- Protocolo (mensagens no chat geral):
        --   shitaro: HELLO <coins> <estado>  -> avisou que esta na sala
        --   shitaro: STATUS <coins> <estado> -> status periodico (30s)
        --   shitaro: FULL <coins>            -> encheu as bags (50)
        --   shitaro: ACK <nome>              -> confirmacao de leitura
        --
        -- Estados: COLETANDO / AGUARDANDO / CHEIO / CONFIRMADO
        --
        -- Fluxo: quando uma conta enche as bags ela manda FULL; cada
        -- outra conta valida quem enviou (whitelist) e o conteudo,
        -- registra o estado dela e responde ACK. Quem mandou FULL fica
        -- AGUARDANDO ate chegar o ACK (vira CONFIRMADO, reenvia 3x).
        -- Receber FULL tambem libera a whitelist dele: o auto kill
        -- passa a poder mata-lo (mata depois que encheu). Se uma das
        -- contas for o murderer a regra e a mesma: farma junto e so
        -- mata quem ja encheu.
        --============================================================
        local sync_on = false
        local sync_conns = {}
        local sync_states = {}
        local sync_dedup = {}
        local sync_my_state = "COLETANDO"
        local sync_full_sent_at = 0
        local sync_full_tries = 0
        local sync_last_status = 0
        local sync_only_wl = true
        local sync_reject_last = 0
        local sync_lbl = nil

        local SYNC_PREFIX = "shitaro:"
        local SYNC_STATUS_EVERY = 30
        local SYNC_RESEND_AFTER = 12
        local SYNC_MAX_TRIES = 3
        local SYNC_STALE = 240

        local function sync_send_chat(text)
                task.spawn(function()
                        local sent = false
                        pcall(function()
                                local tcs = game:GetService("TextChatService")
                                if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                                        local ch = tcs:FindFirstChild("TextChannels")
                                        local gen = ch and ch:FindFirstChild("RBXGeneral")
                                        if gen then
                                                sent = true
                                                local ok, fut = pcall(function() return gen:SendAsync(text) end)
                                                if ok and fut then
                                                        pcall(function() fut:await() end)
                                                end
                                        end
                                end
                        end)
                        if not sent then
                                pcall(function()
                                        local ce = rs:FindFirstChild("DefaultChatSystemChatEvents")
                                        local say = ce and ce:FindFirstChild("SayMessageRequest")
                                        if say and say:IsA("RemoteEvent") then
                                                say:FireServer(text, "All")
                                        end
                                end)
                        end
                end)
        end

        -- quem enviou e de confianca? (whitelist, sem o release de full)
        local function sync_member(plr)
                if plr == nil or plr == lp then return false end
                local n = plr.Name
                if type(n) ~= "string" then return false end
                if wl_names[string.lower(n)] then return true end
                local dn = plr.DisplayName
                return type(dn) == "string" and wl_names[string.lower(dn)] == true
        end

        local function sync_label_text()
                if not sync_on then return "multi: off" end
                local parts = { "eu: " .. sync_my_state .. " " .. tostring(collected_count) }
                for _, st in pairs(sync_states) do
                        parts[#parts + 1] = tostring(st.name) .. ": " .. tostring(st.state)
                                .. " " .. tostring(st.coins)
                end
                if #parts == 1 then parts[2] = "sem contas ainda" end
                return "multi: " .. table.concat(parts, " | ")
        end

        local function sync_status()
                if sync_lbl then
                        pcall(function() sync_lbl:SetValue(sync_label_text()) end)
                end
        end

        -- libera a whitelist de quem anunciou FULL via chat: o
        -- is_whitelisted passa a devolver false e o auto kill pode mata-lo
        local function sync_release(plr, coins)
                local nkey = string.lower(plr.Name)
                local val = tonumber(coins) or wl_limit
                if val < wl_limit then val = wl_limit end
                if (wl_coins[nkey] or 0) > val then val = wl_coins[nkey] end
                wl_coins[nkey] = val
                local dn = plr.DisplayName
                if type(dn) == "string" then
                        local dkey = string.lower(dn)
                        if dkey ~= nkey then wl_coins[dkey] = val end
                end
                if wl_names[nkey] and not wl_full_notified[nkey] then
                        wl_full_notified[nkey] = true
                        wh_send("[shitaro] " .. plr.Name .. " encheu via chat ("
                                .. tostring(val) .. ") - whitelist liberada")
                end
        end

        local function sync_state_word()
                if sync_my_state == "OFF" or sync_my_state == "" then
                        return "COLETANDO"
                end
                return sync_my_state
        end

        local function sync_cmd_status()
                if not sync_on then return end
                sync_last_status = os.clock()
                sync_send_chat(SYNC_PREFIX .. " STATUS "
                        .. tostring(collected_count) .. " " .. sync_state_word())
        end

        local function sync_cmd_full()
                if not sync_on then return end
                sync_full_sent_at = os.clock()
                sync_send_chat(SYNC_PREFIX .. " FULL " .. tostring(collected_count))
        end

        local function sync_handle(plr, raw)
                if not sync_on or type(raw) ~= "string" then return end
                if plr == nil or plr == lp then return end
                local low = string.lower(raw)
                if string.sub(low, 1, #SYNC_PREFIX) ~= SYNC_PREFIX then return end

                local rest = string.sub(raw, #SYNC_PREFIX + 1)
                local cmd, a1, a2 = string.match(rest, "^%s*(%S+)%s*(%S*)%s*(.-)%s*$")
                if not cmd then return end
                cmd = string.upper(cmd)

                local now = os.clock()

                -- 1) valida quem enviou
                if sync_only_wl and not sync_member(plr) then
                        if now - sync_reject_last > 30 then
                                sync_reject_last = now
                                wh_send("[shitaro] multi: msg ignorada de "
                                        .. tostring(plr.Name) .. " (fora da whitelist)")
                        end
                        return
                end

                -- 2) valida o conteudo
                local coins = tonumber(a1)
                if cmd ~= "ACK" and coins == nil then return end

                -- 3) dedupe (chatted + message received podem repetir)
                local sig = cmd .. ":" .. tostring(a1) .. ":" .. tostring(a2)
                local dkey = string.lower(plr.Name) .. "|" .. sig
                if sync_dedup[dkey] and now - sync_dedup[dkey] < 3 then return end
                sync_dedup[dkey] = now

                if cmd == "FULL" then
                        sync_states[string.lower(plr.Name)] = {
                                name = plr.Name, coins = coins, state = "CHEIO", t = now
                        }
                        sync_release(plr, coins)
                        task.delay(0.2 + math.random() * 0.8, function()
                                if sync_on then
                                        sync_send_chat(SYNC_PREFIX .. " ACK " .. plr.Name)
                                end
                        end)
                elseif cmd == "STATUS" or cmd == "HELLO" then
                        local st = string.upper(a2 or "")
                        if st == "" then st = "COLETANDO" end
                        if coins >= wl_limit then st = "CHEIO" end
                        sync_states[string.lower(plr.Name)] = {
                                name = plr.Name, coins = coins, state = st, t = now
                        }
                        if coins >= wl_limit then
                                sync_release(plr, coins)
                        end
                        if cmd == "HELLO" then
                                task.delay(0.3 + math.random() * 1.2, function()
                                        if sync_on then sync_cmd_status() end
                                end)
                        end
                elseif cmd == "ACK" then
                        if a1 ~= "" and string.lower(a1) == string.lower(lp.Name)
                                and (sync_my_state == "AGUARDANDO" or sync_my_state == "CHEIO") then
                                sync_my_state = "CONFIRMADO"
                                wh_send("[shitaro] multi: " .. tostring(plr.Name)
                                        .. " confirmou meu full (ACK)")
                        end
                end

                sync_status()
        end

        local function sync_disconnect()
                for _, c in ipairs(sync_conns) do
                        pcall(function() c:Disconnect() end)
                end
                sync_conns = {}
        end

        local function sync_connect()
                sync_disconnect()
                local function hook(plr)
                        sync_conns[#sync_conns + 1] = plr.Chatted:Connect(function(msg)
                                sync_handle(plr, msg)
                        end)
                end
                for _, plr in ipairs(players:GetPlayers()) do
                        pcall(hook, plr)
                end
                sync_conns[#sync_conns + 1] = players.PlayerAdded:Connect(function(plr)
                        pcall(hook, plr)
                end)
                sync_conns[#sync_conns + 1] = players.PlayerRemoving:Connect(function(plr)
                        sync_states[string.lower(plr.Name)] = nil
                        sync_status()
                end)
                pcall(function()
                        local tcs = game:GetService("TextChatService")
                        local ch = tcs:FindFirstChild("TextChannels")
                        local gen = ch and ch:FindFirstChild("RBXGeneral")
                        if gen then
                                sync_conns[#sync_conns + 1] = gen.MessageReceived:Connect(function(msg)
                                        local src = msg and msg.TextSource
                                        if src then sync_handle(src, msg.Text) end
                                end)
                        end
                end)
        end

        local function sync_set(on)
                on = on and true or false
                if on == sync_on then return end
                sync_on = on
                if sync_on then
                        sync_my_state = "COLETANDO"
                        sync_full_tries = 0
                        sync_connect()
                        sync_send_chat(SYNC_PREFIX .. " HELLO "
                                .. tostring(collected_count) .. " COLETANDO")
                        wh_send("[shitaro] multi-contas ligado - " .. lp.Name)
                else
                        sync_disconnect()
                        sync_states = {}
                end
                sync_status()
        end

        sync_turn_off = function()
                sync_set(false)
        end

        -- chamado pelo farm quando as bags enchem
        sync_announce_full = function()
                if not sync_on then return end
                sync_my_state = "AGUARDANDO"
                sync_full_tries = 0
                sync_cmd_full()
                wh_send("[shitaro] multi: anunciei FULL (" .. tostring(collected_count)
                        .. ") - aguardando ACK")
                sync_status()
        end

        -- chamado a cada nova rodada / respawn
        sync_reset_round = function()
                sync_my_state = "COLETANDO"
                sync_full_tries = 0
                sync_full_sent_at = 0
                sync_status()
        end

        task.spawn(function()
                while true do
                        task.wait(2)
                        if sync_on then
                                local now = os.clock()
                                if sync_my_state == "AGUARDANDO"
                                        and now - sync_full_sent_at > SYNC_RESEND_AFTER
                                        and sync_full_tries < SYNC_MAX_TRIES then
                                        sync_full_tries = sync_full_tries + 1
                                        sync_cmd_full()
                                end
                                if now - sync_last_status > SYNC_STATUS_EVERY then
                                        sync_cmd_status()
                                end
                                for k, st in pairs(sync_states) do
                                        if now - (st.t or 0) > SYNC_STALE then sync_states[k] = nil end
                                end
                                for k, t in pairs(sync_dedup) do
                                        if now - t > 10 then sync_dedup[k] = nil end
                                end
                                sync_status()
                        end
                end
        end)

        local mc_sec = farm_page:AddSection({
                Name = "multi-contas",
                Position = "right"
        })

        mc_sec:AddToggle({
                Name = "multi-contas",
                ToolTip = "Sincroniza as contas pelo chat: FULL quando encher, ACK de confirmacao, status a cada 30s",
                Default = false,
                Flag = "Multi Sync",
                Callback = function(v)
                        sync_set(v)
                end
        })

        mc_sec:AddToggle({
                Name = "so aceitar whitelist",
                ToolTip = "So aceita mensagens de contas que estao na whitelist",
                Default = true,
                Flag = "Multi OnlyWl",
                Callback = function(v)
                        sync_only_wl = v and true or false
                end
        })

        mc_sec:AddButton({
                Name = "anunciar status",
                Icon = "send",
                Callback = function()
                        if not sync_on then return end
                        sync_cmd_status()
                end
        })

        mc_sec:AddButton({
                Name = "anunciar cheio",
                Icon = "check",
                Callback = function()
                        if not sync_on then return end
                        if sync_announce_full then sync_announce_full() end
                end
        })

        sync_lbl = mc_sec:AddLabel(sync_label_text(), false)
        sync_status()

        --============================================================
        -- SELF-CONTAINED AUTO KILL
        -- Holds while the farm is running; when the coin bags are
        -- done: murderer sweeps everyone / sheriff shoots the murder.
        --============================================================
        do
                local last_auto_kill = 0

                local function farm_tool(name)
                        local char = lp.Character
                        local tool = char and char:FindFirstChild(name)
                        if tool then return tool end
                        local bp = lp:FindFirstChildOfClass("Backpack")
                        return bp and bp:FindFirstChild(name) or nil
                end

                local function alive_parts()
                        local out = {}
                        for _, plr in ipairs(players:GetPlayers()) do
                                if plr ~= lp and not is_whitelisted(plr) then
                                        local c = plr.Character
                                        local h = c and c:FindFirstChildOfClass("Humanoid")
                                        local part = c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head"))
                                        if h and h.Health > 0 and part then
                                                out[#out + 1] = part
                                        end
                                end
                        end
                        return out
                end

                local function stab_knife(knife)
                        local events = knife:FindFirstChild("Events")
                        local stabbed = events and events:FindFirstChild("KnifeStabbed")
                        if stabbed then pcall(function() stabbed:FireServer() end) end
                end

                local function touch_knife(knife, part)
                        local events = knife:FindFirstChild("Events")
                        local touched = events and events:FindFirstChild("HandleTouched")
                        if touched then pcall(function() touched:FireServer(part) end) end
                end

                local function murder_sweep()
                        local knife = farm_tool("Knife")
                        if not knife then return end
                        local char = lp.Character
                        if char and not knife:IsDescendantOf(char) then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if hum then pcall(function() hum:EquipTool(knife) end) end
                        end
                        stab_knife(knife)
                        for _, part in ipairs(alive_parts()) do
                                touch_knife(knife, part)
                        end
                end

                local function sheriff_shot()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not char or not hrp then return end
                        local gun = farm_tool("Gun")
                        if not gun then return end
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and not gun:IsDescendantOf(char) then
                                pcall(function() hum:EquipTool(gun) end)
                        end
                        local shoot = gun:FindFirstChild("Shoot")
                        if not (shoot and shoot:IsA("RemoteEvent")) then return end
                        local mpart = nil
                        local d = get_round_data()
                        if type(d) == "table" then
                                for name, info in pairs(d) do
                                        if type(info) == "table" and info.Role == "Murderer" and not info.Dead then
                                                local pl = players:FindFirstChild(name)
                                                if is_whitelisted(pl) then
                                                        return
                                                end
                                                local c = pl and pl.Character
                                                mpart = c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head"))
                                                break
                                        end
                                end
                        end
                        if not mpart then
                                for _, plr in ipairs(players:GetPlayers()) do
                                        if plr ~= lp and not is_whitelisted(plr) then
                                                local c = plr.Character
                                                local bp = plr:FindFirstChildOfClass("Backpack")
                                                if c and (c:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife"))) then
                                                        mpart = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head")
                                                        break
                                                end
                                        end
                                end
                        end
                        if not mpart then return end
                        local handle = gun:FindFirstChild("Handle")
                        local start_cf = (handle and gun:IsDescendantOf(char)) and handle.CFrame or hrp.CFrame
                        pcall(function() shoot:FireServer(start_cf, CFrame.new(mpart.Position)) end)
                end

                task.spawn(function()
                        while true do
                                task.wait(0.35)
                                if autofarm_on and autokill_on and coins_done and os.clock() - last_auto_kill > 0.4 then
                                        last_auto_kill = os.clock()
                                        local d = get_round_data()
                                        local me = (type(d) == "table") and d[lp.Name] or nil
                                        local role = me and me.Role or nil
                                        if not kill_announced then
                                                kill_announced = true
                                                wh_send("[shitaro] auto kill ativo - role: " .. tostring(role or "?"))
                                        end
                                        if role == "Murderer" and not me.Dead then
                                                murder_sweep()
                                        elseif role == "Sheriff" or role == "Hero" then
                                                sheriff_shot()
                                        elseif farm_tool("Knife") then
                                                murder_sweep()
                                        end
                                end
                        end
                end)
        end

        -- live status label feed
        do
                task.spawn(function()
                        while true do
                                task.wait(0.5)
                                if status_lbl then
                                        pcall(function()
                                                status_lbl:SetValue("coins: " .. tostring(collected_count)
                                                        .. " | farm: " .. (autofarm_on and "on" or "off")
                                                        .. " | wl: " .. wl_feed_text())
                                        end)
                                end
                                if sync_lbl then
                                        pcall(function() sync_lbl:SetValue(sync_label_text()) end)
                                end
                        end
                end)
        end

end

--============================================================
-- ALTA PERFORMANCE
-- Removes textures, decals, particles, clothing textures and
-- disables shadows / post effects / terrain decoration to
-- boost FPS. Fully reversible (toggle off restores everything).
--============================================================
do
        local lighting = game:GetService("Lighting")
        local terrain = workspace:FindFirstChildOfClass("Terrain")

        local perf_on = false
        local perf_conn = nil
        local saved = setmetatable({}, { __mode = "k" })
        local detached = {}
        local post_saved = nil
        local light_saved = nil
        local terrain_saved = nil
        local quality_saved = nil

        local FX = {
                ParticleEmitter = true,
                Trail = true,
                Beam = true,
                Fire = true,
                Smoke = true,
                Sparkles = true,
        }

        local function record(inst)
                if saved[inst] ~= nil then return end

                local ok, rec = pcall(function()
                        if inst:IsA("BasePart") then
                                local r = { material = inst.Material, reflectance = inst.Reflectance }
                                if inst:IsA("MeshPart") then r.texture = inst.TextureID end
                                return r
                        elseif inst:IsA("Decal") or inst:IsA("Texture") then
                                return { transparency = inst.Transparency }
                        elseif inst:IsA("SpecialMesh") then
                                return { texture = inst.TextureId }
                        elseif FX[inst.ClassName] then
                                return { enabled = inst.Enabled }
                        elseif inst:IsA("Shirt") then
                                return { shirt = inst.ShirtTemplate }
                        elseif inst:IsA("Pants") then
                                return { pants = inst.PantsTemplate }
                        elseif inst:IsA("ShirtGraphic") then
                                return { graphic = inst.Graphic }
                        end
                        return nil
                end)

                if ok and type(rec) == "table" then
                        saved[inst] = rec
                end
        end

        local function strip(inst)
                pcall(function()
                        if inst:IsA("BasePart") then
                                inst.Material = Enum.Material.SmoothPlastic
                                inst.Reflectance = 0
                                if inst:IsA("MeshPart") then inst.TextureID = "" end
                        elseif inst:IsA("Decal") or inst:IsA("Texture") then
                                inst.Transparency = 1
                        elseif inst:IsA("SpecialMesh") then
                                inst.TextureId = ""
                        elseif inst:IsA("SurfaceAppearance") then
                                if inst.Parent and not detached[inst] then
                                        detached[inst] = inst.Parent
                                        inst.Parent = nil
                                end
                        elseif FX[inst.ClassName] then
                                inst.Enabled = false
                        elseif inst:IsA("Shirt") then
                                inst.ShirtTemplate = ""
                        elseif inst:IsA("Pants") then
                                inst.PantsTemplate = ""
                        elseif inst:IsA("ShirtGraphic") then
                                inst.Graphic = ""
                        end
                end)
        end

        local function scan_all()
                for _, inst in ipairs(workspace:GetDescendants()) do
                        record(inst)
                        strip(inst)
                end
        end

        local function perf_enable()
                if perf_on then return end
                perf_on = true

                pcall(function()
                        quality_saved = settings().Rendering.QualityLevel
                        settings().Rendering.QualityLevel = 1
                end)

                light_saved = {
                        shadows = lighting.GlobalShadows,
                        fogstart = lighting.FogStart,
                        fogend = lighting.FogEnd,
                        brightness = lighting.Brightness,
                }
                pcall(function() lighting.GlobalShadows = false end)
                pcall(function() lighting.FogStart = 0 end)
                pcall(function() lighting.FogEnd = 100000 end)
                pcall(function() lighting.Brightness = 1 end)

                post_saved = {}
                for _, e in ipairs(lighting:GetChildren()) do
                        if e:IsA("PostEffect") then
                                post_saved[#post_saved + 1] = { inst = e, enabled = e.Enabled }
                                pcall(function() e.Enabled = false end)
                        end
                end

                if terrain then
                        terrain_saved = {
                                decoration = terrain.Decoration,
                                wavesize = terrain.WaterWaveSize,
                                wavespeed = terrain.WaterWaveSpeed,
                                reflect = terrain.WaterReflectance,
                                transp = terrain.WaterTransparency,
                        }
                        pcall(function() terrain.Decoration = false end)
                        pcall(function() terrain.WaterWaveSize = 0 end)
                        pcall(function() terrain.WaterWaveSpeed = 0 end)
                        pcall(function() terrain.WaterReflectance = 0 end)
                        pcall(function() terrain.WaterTransparency = 1 end)
                end

                scan_all()

                perf_conn = workspace.DescendantAdded:Connect(function(inst)
                        task.defer(function()
                                if perf_on and inst and inst.Parent then
                                        record(inst)
                                        strip(inst)
                                end
                        end)
                end)
        end

        local function perf_disable()
                if not perf_on then return end
                perf_on = false

                if perf_conn then
                        pcall(function() perf_conn:Disconnect() end)
                        perf_conn = nil
                end

                for inst, rec in pairs(saved) do
                        pcall(function()
                                if inst.Parent then
                                        if rec.material then inst.Material = rec.material end
                                        if rec.reflectance then inst.Reflectance = rec.reflectance end
                                        if rec.texture then
                                                if inst:IsA("SpecialMesh") then
                                                        inst.TextureId = rec.texture
                                                elseif inst:IsA("MeshPart") then
                                                        inst.TextureID = rec.texture
                                                end
                                        end
                                        if rec.transparency then inst.Transparency = rec.transparency end
                                        if rec.enabled ~= nil then inst.Enabled = rec.enabled end
                                        if rec.shirt then inst.ShirtTemplate = rec.shirt end
                                        if rec.pants then inst.PantsTemplate = rec.pants end
                                        if rec.graphic then inst.Graphic = rec.graphic end
                                end
                        end)
                end
                table.clear(saved)

                for inst, par in pairs(detached) do
                        if inst and par then
                                pcall(function() inst.Parent = par end)
                        end
                end
                table.clear(detached)

                if post_saved then
                        for _, e in ipairs(post_saved) do
                                pcall(function() e.inst.Enabled = e.enabled end)
                        end
                        post_saved = nil
                end

                if light_saved then
                        pcall(function() lighting.GlobalShadows = light_saved.shadows end)
                        pcall(function() lighting.FogStart = light_saved.fogstart end)
                        pcall(function() lighting.FogEnd = light_saved.fogend end)
                        pcall(function() lighting.Brightness = light_saved.brightness end)
                        light_saved = nil
                end

                if terrain_saved and terrain then
                        pcall(function() terrain.Decoration = terrain_saved.decoration end)
                        pcall(function() terrain.WaterWaveSize = terrain_saved.wavesize end)
                        pcall(function() terrain.WaterWaveSpeed = terrain_saved.wavespeed end)
                        pcall(function() terrain.WaterReflectance = terrain_saved.reflect end)
                        pcall(function() terrain.WaterTransparency = terrain_saved.transp end)
                        terrain_saved = nil
                end

                if quality_saved then
                        pcall(function() settings().Rendering.QualityLevel = quality_saved end)
                        quality_saved = nil
                end
        end

        perf_sec:AddToggle({
                Name = "alta performance",
                ToolTip = "Removes textures, decals, particles and shadows to boost FPS",
                Default = false,
                Flag = "High Performance",
                Callback = function(v)
                        if v then
                                perf_enable()
                        else
                                perf_disable()
                        end
                end
        })

        getgenv().PERF_UNLOAD = function()
                perf_disable()
        end
end

do
        window:AddColors()

        local _, pref = window:AddConfig()

        

        if #lib.cursorlist > 0 then
                pref:toggle({
                        name = "custom cursor",
                        default = false,
                        flag = "MenuCursor",
                        callback = function(v)
                                lib:setcursor(v)
                        end,
                })

                pref:dropdown({
                        name = "preset",
                        list = lib.cursorlist,
                        default = lib.cursorlist[1],
                        flag = "MenuCursorStyle",
                        callback = function(v)
                                lib:setstyle(v)
                        end,
                })
        end

        pref:toggle({
                name = "menu sounds",
                default = false,
                flag = "MenuSounds",
                callback = function(v)
                        lib:setsound(v)
                end,
        })

        pref:dropdown({
                name = "sound",
                list = lib.tonelist,
                default = "Click",
                flag = "MenuTone",
                callback = function(v)
                        lib:settone(v)
                end,
        })
        pref:toggle({
                name = "furry",
                default = true,
                flag = "MenuFurry",
                callback = function(v)
                        if window.__win and type(window.__win.setfury) == "function" then
                                window.__win:setfury(v)
                        end
                end,
        })
        pref:toggle({
                name = "hotkeys",
                default = true,
                flag = "MenuHotkeys",
                callback = function(v)
                        lib:sethotkeys(v)
                end,
        })

        pref:toggle({
                name = "watermark",
                default = true,
                flag = "Watermark",
                callback = function(v)
                        lib:setwatermark(v)
                end,
        })

        pref:keybind({
                name = "menu key",
                default = "Insert",
                flag = "MenuKeybind",
                callback = function(v)
                        window:SetBind(v)
                end,
        })

        local function tdown()
                shkey.stop()

                pcall(function()
                        local unloads = {
                                "AUTOFARM_UNLOAD","AUTOGRAB_UNLOAD","PERF_UNLOAD"
                        }
                        for _, key in ipairs(unloads) do
                                local fn = getgenv()[key]
                                if fn then
                                        pcall(fn)
                                        getgenv()[key] = nil
                                end
                        end


                        pcall(function()
                                local lighting = game:GetService("Lighting")
                                if getgenv().WORLD_FOG_ENABLED then
                                        lighting.FogColor = Color3.fromRGB(192, 192, 192)
                                        lighting.FogStart = 0
                                        lighting.FogEnd = 100000
                                        getgenv().WORLD_FOG_ENABLED = false
                                end
                                if getgenv().WORLD_FULLBRIGHT_ENABLED then
                                        lighting.Brightness = 1
                                        lighting.ClockTime = 14
                                        lighting.FogEnd = 100000
                                        lighting.GlobalShadows = true
                                        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                                        getgenv().WORLD_FULLBRIGHT_ENABLED = false
                                end
                                if getgenv().WORLD_AMBIENT_ENABLED then
                                        lighting.Ambient = Color3.fromRGB(0, 0, 0)
                                        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                                        getgenv().WORLD_AMBIENT_ENABLED = false
                                end
                                if getgenv().WORLD_SKYBOX_ENABLED then
                                        for _, sky in pairs(lighting:GetChildren()) do
                                                if sky:IsA("Sky") and sky.Name == "CustomSky" then
                                                        sky:Destroy()
                                                end
                                        end
                                        getgenv().WORLD_SKYBOX_ENABLED = false
                                end
                                for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                                        if gui.Name == "SkyboxInput" then gui:Destroy() end
                                end
                                for _, effect in pairs(lighting:GetChildren()) do
                                        if effect:IsA("BlurEffect") then effect:Destroy() end
                                end
                        end)

                        if esp and esp._loaded then
                                pcall(function() esp.Unload() end)
                        end
                end)

                pcall(function() lib:unload() end)

                getgenv().shitaroebet = nil
                getgenv().SHKEY = nil
        end

        shkey.bind(tdown)

        pref:button({
                name = "Unload",
                icon = "log-out",
                callback = tdown,
        })
end
