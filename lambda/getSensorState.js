var AWS = require('aws-sdk');
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
var s3 = new AWS.S3({apiVersion: '2006-03-01'});
var params1 = {
  ProjectionExpression: 'video, #t',
  ExpressionAttributeNames : { '#t' : 'timestamp'},
  TableName: 'Camera_Upload_Video'
};

exports.handler = async (event) => {
    
    var message = new Array();
    const promise = new Promise((resolve,reject) => {
      ddb.scan(params1, function(err, data) {
        if (err) {
          console.log("Error", err);
          reject(err);
        } else {
          
          //console.log("Success", data.Items);
          data.Items.forEach(function(element, index, array) {
            //console.log(element.video.S + " (" + element.timestamp.S + ")");
            var params2 = {
                Bucket: element.video.S.split('/')[0],
                Key: element.video.S.split('/')[1],
              };
            
            var url = s3.getSignedUrl('getObject', params2);
            
            var tmp = new Object();
            tmp = { 
              "video" : element.video.S.split('/')[1], 
              "link" :  url.split('?')[0],
              "timestamp" : element.timestamp.S.trim('()')};
      
            message.push(tmp);
          });
          //console.log(JSON.stringify(message));
          var js = JSON.stringify(message);
          //console.log(JSON.parse(js.replace(/'/g,'"')));
          let responseBody = {
                      message: JSON.parse(js.replace(/'/g,'"')),
                      input: event
                  };
          let response = {
              statusCode: 200,
              headers: {
              },
              body: JSON.stringify(responseBody)
          };
          //console.log("response: " + JSON.stringify(responseBody))*/
          resolve(response);
        }
      });
    });
    
  return promise;
};
