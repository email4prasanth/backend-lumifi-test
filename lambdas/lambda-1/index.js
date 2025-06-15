exports.handler = async (event) => {
    console.log('Lambda-1 event:', JSON.stringify(event, null, 2));
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Hello from Lambda-1!" }),
    };
};
