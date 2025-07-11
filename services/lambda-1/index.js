
exports.handler = async (event) => {
    console.log('Lambda-1 event:', JSON.stringify(event, null, 2));
    if (event.rawPath === '/test' || event.rawPath === '/test/') {
    return {
        statusCode: 200,
        headers: {
            "Cache-Control": "no-cache, no-store, must-revalidate",
            "Pragma": "no-cache",
            "Expires": "0"
        },
        body: JSON.stringify({ message: "Testing Lumifi Dental Project!" }),
    };
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