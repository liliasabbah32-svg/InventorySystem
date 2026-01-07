"use client";

export default async function GridGlobalization() {
    let globalization;

    // Read direction safely at runtime to avoid module-scope access to `window`.
    const dir =
        typeof window !== "undefined" && window.$ && window.$.strings && window.$.strings.dir
            ? window.$.strings.dir
            : typeof document !== "undefined"
            ? document.documentElement.dir || "ltr"
            : "ltr";

    switch (dir) {
        case "rtl":
            globalization = await import(
                "@grapecity/wijmo/cultures/wijmo.culture.ar"
            );
            break;

        default:
            globalization = await import(
                "@grapecity/wijmo/cultures/wijmo.culture.en"
            );
            break;
    }

    return globalization;
}
