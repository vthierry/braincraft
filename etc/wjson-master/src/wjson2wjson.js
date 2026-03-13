#!/usr/bin/env node

/** 
 * @function wjson2wjson
 * @static
 * @description Command line wrapper to reformat a strong or weak JSON syntax string to a normalized weak JSON format.
 * @param {string} Input string, in wjson or json format.
 * @return {string} Output string in pretty wjson format.
 *
 * - Also available as a line command application, (see also [wJSON](./wJSON.html) object):
 * ```
 *     Usage: ./src/wjson2wjson.js < json-file.json > wjson-file.json
 * ```
 */

const wJSON = require("./wJSON.js")
const converter = wJSON.wjson2wjson;

// Standard command to convert a file from a format to another
console.log(converter(require("fs").readFileSync(require("process").stdin.fd, "utf-8")));
