// services/lambda-1/index.js
// 

exports.handler = async (event) => {
  console.log('Lambda-1 event:', JSON.stringify(event, null, 2));

  // Handle different domains
  if (event.requestContext.domainName === 'test.lumifidental.com') {
    // Original behavior for test.lumifidental.com
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Testing Lumifi Backend!!!!!" }),
    };
  }

  // Handle app-dev.lumifidental.com with /api/v1 prefix
  const path = event.rawPath.replace('/api/v1', '');
  // Add your actual route handlers here
  if (path === '/state/list') {
    return {
      statusCode: 200,
      body: JSON.stringify({ states: ["State1", "State2", "State3"] }),
    };
  }

  // Default response for unhandled paths
  return {
    statusCode: 404,
    body: JSON.stringify({ error: "Endpoint not found" }),
  };
};