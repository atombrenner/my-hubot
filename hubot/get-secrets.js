var fs = require('fs');
var AWS = require('aws-sdk');
AWS.config.region = 'eu-west-1';
var s3 = new AWS.S3();

s3.getObject({Bucket: 'your-secrets', Key: 'secrets.sh'}, function(err, data) {
  if (err) console.log(err, err.stack); // an error occurred
  else {
    var fd = fs.openSync('secrets.sh', 'w');
    fs.writeSync(fd, data.Body.toString());
    fs.closeSync(fd);
    fs.chmodSync('secrets.sh', '0700');
  }
});
