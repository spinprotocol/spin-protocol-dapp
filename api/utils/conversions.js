import { utils } from 'ethers';

export function parseToken(value, decimals=18) {
  // console.log('parseToken - Value:', value.toString(10));
  // let oneToken = utils.bigNumberify('10').pow(decimals);
  // return utils.bigNumberify(value.toString(10)).mul(oneToken).toString(10);

  return utils.parseEther(value.toString(10));
}

export function formatToken(value, decimals=18) {
  // console.log('formatToken - Value:', value);
  // let oneToken = utils.bigNumberify('10').pow(decimals);
  // return utils.bigNumberify(value.toString(10)).div(oneToken).toString(10);

  return utils.formatEther(value);
}

export function formatDate(timestamp, locale='us') {
  let options = {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  };

  return new Date(timestamp).toLocaleDateString(locale, options);
}