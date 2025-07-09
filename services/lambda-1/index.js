exports.handler = async (event) => {
    console.log('Lambda-1 event:', JSON.stringify(event, null, 2));
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Testing Lumifi Dental Project!" }),
    };
};