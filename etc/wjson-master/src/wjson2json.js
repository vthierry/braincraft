#!/usr/bin/env node

/** 
 * @function wjson2json
 * @static
 * @description Command line wrapper to reformats a weak JSON syntax string to a normalized standard JSON format.
 * @param {string} Input string, in wjson or json format.
 * @return {string} Output string in pretty json format.
 *
 * - Also available as a line command application (see also [wJSON](./wJSON.html) object):
 * ```
 *     Usage: ./src/wjson2json.js < wjson-file.json > json-file.json
 * ```
 */

const wJSON = require("./wJSON.js")
const converter = wJSON.wjson2json;

// Standard command to convert a file from a format to another
console.log(converter(require("fs").readFileSync(require("process").stdin.fd, "utf-8")));
