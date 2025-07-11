
// exports.handler = async (event) => {
//     console.log('Lambda-1 event:', JSON.stringify(event, null, 2));
//     return {
//         statusCode: 200,
//         headers: {
//             "Cache-Control": "no-cache, no-store, must-revalidate",
//             "Pragma": "no-cache",
//             "Expires": "0"
//         },
//         body: JSON.stringify({ message: "Testing Lumifi Dental Project!" }),
//     };
// };


exports.handler = async (event) => {
  // For any request to /test, return success
  if (event.requestContext.http.path.startsWith('/test')) {
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Testing Lumifi Backend!!!!!" }),
    };
  }
  
  // Default 404 response
  return {
    statusCode: 404,
    body: JSON.stringify({ error: "Endpoint not found" }),
  };
};


// exports.handler = async (event) => {
//   console.log('Lambda-1 event:', JSON.stringify(event, null, 2));

//   // Handle test endpoint
//   if (event.rawPath === '/test' || event.rawPath === '/test/') {
//     return {
//       statusCode: 200,
//       headers: {
//         "Content-Type": "application/json",
//         "Cache-Control": "no-cache, no-store, must-revalidate",
//         "Pragma": "no-cache",
//         "Expires": "0"
//       },
//       body: JSON.stringify({ message: "Testing Lumifi Backend!!!!!" }),
//     };
//   }

//   // Default response for unhandled paths
//   return {
//     statusCode: 404,
//     headers: {
//       "Content-Type": "application/json",
//       "Cache-Control": "no-cache, no-store, must-revalidate",
//       "Pragma": "no-cache",
//       "Expires": "0"
//     },
//     body: JSON.stringify({ error: "Endpoint not found" }),
//   };
// };