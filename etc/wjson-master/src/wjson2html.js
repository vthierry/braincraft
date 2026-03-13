#!/usr/bin/env node

/** 
 * @function wjson2html
 * @static
 * @description Command line wrapper to reformat a strong or weak JSON syntax string to a normalized weak JSON format.
 *
 * - Only available as a command line application, see also [wJSON](./wJSON.html) object.
 * ```
 *     Usage: ./src/wjson2html.js < json-file.json > json-file.html
 * ```
 */

const wJSON = require("./wJSON.js");
const converter = wJSON.wjson2wjson;

// Standard command to convert a file from a format to another
console.log(converter(require("fs").readFileSync(require("process").stdin.fd, "utf-8"), "html"));
