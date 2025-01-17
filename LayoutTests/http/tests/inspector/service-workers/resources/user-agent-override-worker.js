function dumpUserAgent()
{
    fetch('http://127.0.0.1:8000/inspector/resources/echo-headers.php')
        .then(function(response) {
            return response.text();
        }).then(function(body) {
            var userAgentLine = /HTTP_USER_AGENT:.*/.exec(body)[0];
            console.log(userAgentLine);
        }).catch(function(err) {
            console.log('fetch failed: ' + err.message);
        });
}

self.oninstall = function(event) {
    dumpUserAgent();
};
