const axios = require('axios');

/**
 * Wrapper function for `axios.get()` which directly resolves with
 * the data field of response object or rejects with the error
 * message field of error object.
 */
exporta.get = async function(url, headers) {
  try {
    let res = await axios.get(url, {headers});
    return Promise.resolve(res.data);
  } catch (e) {
    return Promise.reject(new Error(e.response.data));
  }
}

/**
 * Wrapper function for `axios.post()` which directly resolves with
 * the data field of response object or rejects with the error
 * message field of error object.
 */
exports.post = async function (url, data, headers) {
  try {
    let res = await axios.post(url, data, {headers});
    return Promise.resolve(res.data);
  } catch (e) {
    return Promise.reject(new Error(e.response.data));
  }
}