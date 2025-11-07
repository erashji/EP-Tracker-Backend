const corsOptions = {
    origin: (origin, callback) => {
        // Allow requests from any origin that matches the pattern
        const allowedOrigins = [];
        if (process.env.FRONTEND_URL) {
            allowedOrigins.push(new RegExp('^' + process.env.FRONTEND_URL.replace(/[.*+?^${}()|[\\]\\]/g, '\\$&') + '$'));
        }
        if (process.env.FRONTEND_URL_SECONDARY) {
            allowedOrigins.push(new RegExp('^' + process.env.FRONTEND_URL_SECONDARY.replace(/[.*+?^${}()|[\\]\\]/g, '\\$&') + '$'));
        }
        // If no env set, allow nothing (no fallback to localhost)
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
