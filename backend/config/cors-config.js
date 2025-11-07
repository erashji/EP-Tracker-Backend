const corsOptions = {
    origin: (origin, callback) => {
        // Allow requests from any origin that matches the pattern
        const allowedOrigins = [
            new RegExp('^' + (process.env.FRONTEND_URL ? process.env.FRONTEND_URL.replace(/[.*+?^${}()|[\\]\\]/g, '\\$&') : 'http://localhost:3004') + '$'),
            new RegExp('^' + (process.env.FRONTEND_URL_SECONDARY ? process.env.FRONTEND_URL_SECONDARY.replace(/[.*+?^${}()|[\\]\\]/g, '\\$&') : 'http://0.0.0.0:3004') + '$')
        ];
        
        if (!origin || allowedOrigins.some(pattern => pattern.test(origin))) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-jwt-token'],
    credentials: true,
    optionsSuccessStatus: 200
};

module.exports = corsOptions;
