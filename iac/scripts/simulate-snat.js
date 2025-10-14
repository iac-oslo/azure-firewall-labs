import http from 'k6/http';
import { sleep } from 'k6';
import { expect } from "https://jslib.k6.io/k6-testing/0.5.0/index.js";

export const options = {
  vus: 1000,
  duration: '600s',
};

export default function() {
  let res = http.get('https://quickpizza.grafana.com');
  res = http.get('https://google.com');
  res = http.get('https://ifconfig.me');
  res = http.get('https://microsoft.com');
  sleep(1);
}

