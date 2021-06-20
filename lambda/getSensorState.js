'use strict';
var AWS = require('aws-sdk');
var iotdata = new AWS.IotData({endpoint:"a1wn4qi9a26ti-ats.iot.us-east-1.amazonaws.com"});
exports.handler = async (event) => {
      
    var params = {
        thingName: 'final_test',
        shadowName: 'final',
        };
 
    const promise = new Promise((resolve,reject) => {
        
        iotdata.getThingShadow(params, (err, data) => {
            if(err){
                console.log("error "+ err); 
                reject();
            }
            else{
                console.log(JSON.parse(data['payload'])['state']['reported']); 
                 let responseBody = {
                    message: JSON.parse(data['payload'])['state']['reported'],
                    input: event
                };
                
                let response = {
                    statusCode: 200,
                    headers: {
                    },
                    body: JSON.stringify(responseBody)
                };
                console.log("response: " + JSON.stringify(response))
                resolve(response)
            }
        });
    });
    return promise;
};
