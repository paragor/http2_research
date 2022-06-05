import {check} from 'k6';
import http from 'k6/http';


const workers = parseInt(__ENV.WORKERS)
const httpVersion = parseInt(__ENV.HTTP_VERSION)
if (workers === 0 || httpVersion === 0) {
    throw "bad env WORKERS HTTP_VERSION should be int"
}
if (httpVersion !== 1 && httpVersion !== 2) {
    throw "bad env  HTTP_VERSION should be 1 or 2"
}

export const options = {
    insecureSkipTLSVerify: true,
    vus: workers,
    //tags: {workers: workers, http_version: httpVersion},
    duration: "5m",

};

function http11() {
    const res = http.get("https://192.168.100.10:8081");
    check(res, {
        'status is 200': (r) => r.status === 200,
        'protocol is HTTP/1.1': (r) => r.proto === 'HTTP/1.1',
    });
}

function http2() {
    const res = http.get("https://192.168.100.10:8082");
    check(res, {
        'status is 200': (r) => r.status === 200,
        'protocol is HTTP/2': (r) => r.proto === 'HTTP/2.0',
    });
}

export default function () {
    if (httpVersion === 1) {
        http11()
    } else {
        http2()
    }
}
