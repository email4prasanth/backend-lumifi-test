// exports.handler = async (event) => {
//     console.log('Lambda-1 event:', JSON.stringify(event, null, 2));
//     return {
//         statusCode: 200,
//         body: JSON.stringify({ message: "Testing Lumifi Dental Project!" }),
//     };
// };

// exports.handler = async (event) => {
//     if (event.rawPath === '/test' || event.rawPath === '/test/') {
//     console.log('Lambda-1 event:', JSON.stringify(event, null, 2));
//     return {
//         statusCode: 200,
//         headers: {
//             "Cache-Control": "no-cache, no-store, must-revalidate",
//             "Pragma": "no-cache",
//             "Expires": "0"
//         },
//         body: JSON.stringify({ message: "Testing Lumifi Dental Project-1!" }),
//     };
// };
// };

exports.handler = async (event) => {
  console.log('Lambda-1 event:', JSON.stringify(event, null, 2));
  
  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-cache, no-store, must-revalidate",
      "Pragma": "no-cache",
      "Expires": "0"
    },
    body: JSON.stringify({ 
      message: "Testing Lumifi Dental Project!",
      path: event.rawPath,
      method: event.requestContext.http.method
    }),
  };
};